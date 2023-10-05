
use Gnome::SourceSkimTool::ConstEnumType;
#use Gnome::SourceSkimTool::SkimGirSource;
use Gnome::SourceSkimTool::Doc;

use XML;
use XML::XPath;
use JSON::Fast;
use YAMLish;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::Code:auth<github:MARTIMM>;

has Gnome::SourceSkimTool::Doc $!grd;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {

  $!grd .= new;
}

#-------------------------------------------------------------------------------
method set-unit ( XML::Element $element, Bool :$callables = True --> Str ) {

  my Str $also = '';
  my Str $ctype = $element.attribs<c:type>;
  my Hash $h = self.search-name($ctype);

  # Check for parent class. There are never more than one. When there is
  # none, pick TopLevelClassSupport
  my Str $parent = $h<parent-raku-name> // 'Gnome::N::TopLevelClassSupport';

  # Misc is deprecated so shortcut to Widget. This is only for Gtk3!
  $parent = 'Gnome::Gtk3::Widget' if $parent ~~ m/ \:\: Misc $/;
  my Bool $available = self.add-import($parent);
  $also ~= ($available ?? '' !! '#') ~ "also is $parent;\n";

  my Bool $is-role = (($h<gir-type> // '' ) eq 'interface') // False;
  my Bool $is-class = (($h<gir-type> // '' ) eq 'class') // False;
  # If the object is a class
  if $is-class {
    # Check for roles to implement
    my Array $roles = $h<implement-roles>//[];
    for @$roles -> $role {
      $available = self.add-import($role);
      $also ~= ($available ?? '' !! '#') ~ "also does $role;\n";
#`{{ Simplified
      my Hash $role-h = self.search-name($role);
      if ?$role-h<class-name> {
        self.add-import($role-h<class-name>);
        $also ~= "also does $role-h<class-name>;\n";
      }
}}
    }

    # The Object module needs some extra classes and roles
    if $*work-data<raku-class-name> eq 'Gnome::GObject::Object' {
      self.add-import('Gnome::N::TopLevelClassSupport');
      $also ~= 'also is Gnome::N::TopLevelClassSupport;' ~ "\n";
      self.add-import('Gnome::N::GObjectSupport');
      $also ~= 'also does Gnome::N::GObjectSupport;' ~ "\n";
    }
  }

  self.add-import('Gnome::N::GnomeRoutineCaller') if ?$callables;
  my Str $code = qq:to/RAKUMOD/;

    {$!grd.pod-header('Module Imports')}
    __MODULE__IMPORTS__

    RAKUMOD

  if $is-role {
    $code ~= qq:to/RAKUMOD/;
      {$!grd.pod-header('Role Declaration');}
      unit role $h<class-name>:auth<github:MARTIMM>:api<2>;
      $also
      RAKUMOD
  }

  # Classes, records and unions
  else {
    $code ~= qq:to/RAKUMOD/;
      {$!grd.pod-header('Class Declaration');}
      unit class $*work-data<raku-class-name>:auth<github:MARTIMM>:api<2>;
      RAKUMOD
  }

  $code ~= "$also\n";

  $code
}

#-------------------------------------------------------------------------------
# This setup is for more simple structures like records, functions,
# enumerations, etc. There is no need for inheritence, BUILD, signals or
# properties.
method set-unit-for-file ( Str $class-name, Bool $has-functions --> Str ) {

  my Str $code = '';

  if $has-functions {
    $code ~= qq:to/RAKUMOD/;
    {$!grd.pod-header('Module Imports')}
    __MODULE__IMPORTS__
    RAKUMOD

    self.add-import('Gnome::N::TopLevelClassSupport');
    self.add-import('Gnome::N::GnomeRoutineCaller');
  }

  $code ~= qq:to/RAKUMOD/;

    {$!grd.pod-header('Class Declaration');}
    unit class $class-name\:auth<github:MARTIMM>:api<2>;
    RAKUMOD

  $code ~= "also is Gnome::N::TopLevelClassSupport;\n" if $has-functions;
  $code ~= "\n";

  $code
}

#-------------------------------------------------------------------------------
method generate-callables (
  XML::Element $element, XML::XPath $xpath, Bool :$is-interface = False
  --> Str
) {

  my Str $code = '';
  my Str $c;

  my Hash $hcs = self.get-constructors( $element, $xpath);
  # Generate constructors
  $code ~= self!generate-constructors($hcs) if ?$hcs;
  note "Generate constructors" if $*verbose and ?$code;

  # Get all methods in this class
  $hcs = self.get-methods( $element, $xpath);
  if ?$hcs {
    # Generate methods
    $c = self!generate-methods($hcs);
    $code ~= $c if ?$c;
    note "Generate methods" if $*verbose and ?$c;
  }

  # Get all functions in this class
  $hcs = self.get-functions( $element, $xpath);
  if ?$hcs {
    # Generate functions
    $code ~= self.generate-functions($hcs);
    note "Generate functions" if $*verbose and ?$c;
  }

  # if there are constructors, methods or functions, add the structure and
  # the fallback routine
  if ?$code {
    $c = qq:to/RAKUMOD/;

      {$!grd.pod-header('Native Routine Definitions');}
      my Hash \$methods = \%\(
      $code);

      {HLSEPARATOR}
      RAKUMOD

    # For interfaces/roles, there is another fallback api called from class
    if $is-interface {
      $c ~= q:to/RAKUMOD/;
        # This method is recognized in class Gnome::N::TopLevelClassSupport.
        method _fallback-v2 (
          Str $name, Bool $_fallback-v2-ok is rw,
          Gnome::N::GnomeRoutineCaller $routine-caller, *@arguments
        ) {
          if $methods{$name}:exists {
            my $native-object = self.get-native-object-no-reffing;
            $_fallback-v2-ok = True;
            return $routine-caller.call-native-sub(
              $name, @arguments, $methods, :$native-object
            );
          }
        }
        RAKUMOD
    }

    else {
      $c ~= q:to/RAKUMOD/;
        # This method is recognized in class Gnome::N::TopLevelClassSupport.
        method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
          if $methods{$name}:exists {
            $_fallback-v2-ok = True;
            if $methods{$name}<type>:exists and $methods{$name}<type> eq 'Constructor' {
        RAKUMOD

      $c ~= qq:to/RAKUMOD/;
              my Gnome::N::GnomeRoutineCaller \$routine-caller .= new\(
                :library\($*work-data<library>\), :sub-prefix\<$*work-data<sub-prefix>\>
              \);

        RAKUMOD

      $c ~= q:to/RAKUMOD/;
              # Check the function name. 
              return self.bless(
                :native-object(
                  $routine-caller.call-native-sub( $name, @arguments, $methods)
                )
              );
            }

            else {
              my $native-object = self.get-native-object-no-reffing;
              return $!routine-caller.call-native-sub(
                $name, @arguments, $methods, :$native-object
              );
            }
          }

          else {
        RAKUMOD

      # When there are roles implemented, generate calls to the role's fallback
      my Str $ctype = $element.attribs<c:type>;
      my Hash $h = self.search-name($ctype);
      my Array $roles = $h<implement-roles>//[];
      $c ~= '    my $r;' ~ "\n" if ?$roles;
      for @$roles -> $role {
#`{{ simplified
        my Hash $role-h = self.search-name($role);
        next unless ?$role-h;

        $c ~= qq:to/RAKUMOD/;
              \$r = self.{$role-h<class-name>}::_fallback-v2\(
                \$name, \$_fallback-v2-ok, \$!routine-caller, \@arguments
              \);
              return \$r if \$_fallback-v2-ok;

          RAKUMOD
}}

        my Bool $available = self.add-import($role);
        $c ~= "#`\{\{\n" unless $available;
        $c ~= qq:to/RAKUMOD/;
              \$r = self.{$role}::_fallback-v2\(
                \$name, \$_fallback-v2-ok, \$!routine-caller, \@arguments
              \);
              return \$r if \$_fallback-v2-ok;

          RAKUMOD
        $c ~= "\}\}\n" unless $available;
      }

      $c ~= q:to/RAKUMOD/;
            callsame;
          }
        }
        RAKUMOD
    }
  }

  $code = $c;

  $code
}

#-------------------------------------------------------------------------------
method make-build-submethod (
  XML::Element $element, XML::XPath $xpath --> Str
) {
  my Str $ctype = $element.attribs<c:type>;
  my Hash $h = self.search-name($ctype);

  # Signal administration
  my Str $role-signals = self.get-role-signals($h);
  my Str $signal-admin = self.get-signal-admin(
    $element, $xpath, $role-signals
  );

  my Str $c = '';
  if ?$signal-admin {
    $c ~= q:to/EOBUILD/;

      # Add signal registration helper
      my Bool $signals-added = False;
      EOBUILD
  }

  my List $gtk-init-code = self.get-gtk-init;

  # Generate code for signal admin and init of callable helper
  my Str $code = qq:to/EOBUILD/;
    {$!grd.pod-header('BUILD variables');}
    # Define callable helper
    has Gnome::N::GnomeRoutineCaller \$\!routine-caller;
    $c$gtk-init-code[0]
    {$!grd.pod-header('BUILD submethod');}
    submethod BUILD \( *\%options \) \{
    $gtk-init-code[1]$signal-admin
      # Initialize helper
      \$\!routine-caller .= new\( :library\($*work-data<library>\), :sub-prefix\<$*work-data<sub-prefix>\>);

    EOBUILD

  # >> In older versions, here was the test for inheritance <<
  $code ~= [~] '  # Prevent creating wrong widgets', "\n",
          '  if self.^name eq ', "'$*work-data<raku-class-name>'", ' {', "\n";

  self.add-import('Gnome::N::X');
  $code ~= q:to/EOBUILD/;
        # If already initialized using ':$native-object', ':$build-id', or
        # any '.new*()' constructor, the object is valid.
        die X::Gnome.new(:message("Native object not defined"))
          unless self.is-valid;
    EOBUILD

  $code ~= qq:to/EOBUILD/;

      # only after creating the native-object, the gtype is known
      self._set-class-info\('$*work-data<gnome-name>'\);
    \}
  \}
  EOBUILD

  # Check for parent class. When there is none, TopLevelClassSupport is set
  # and we need additional code
  unless ?$h<parent-raku-name> {
    $code ~= q:to/EOBUILD/;

      # Next two methods need checks for proper referencing or cleanup 
      method native-object-ref ( $n-native-object ) {
        $n-native-object
      }

      method native-object-unref ( $n-native-object ) {
      #  self._fallback-v2( 'free', my Bool $x);
      }
      EOBUILD
  }

  $code
}

#-------------------------------------------------------------------------------
method get-role-signals ( Hash $h --> Str ) {

  # See which roles to implement
  my Str $role-signals = '';
  my Array $roles = $h<implement-roles> // [];
  for @$roles -> $role {
    once $role-signals = "\n    # Signals from interfaces\n";

    my Bool $available = self.add-import($role);

    my Hash $role-h = self.search-name($role);
    if ?$role-h {
#note "$?LINE role $role, ", $role-h.gist;
      $role-signals ~= "#`\{\{\n" unless $available;
      $role-signals ~=
        "    self._add_$role-h<symbol-prefix>signal_types\(\$?CLASS\.^name)\n" ~
        "      if self.^can\('_add_$role-h<symbol-prefix>signal_types');\n";
      $role-signals ~= "\}\}\n" unless $available;
    }
  }

  $role-signals;
}

#-------------------------------------------------------------------------------
method get-signal-admin (
  XML::Element $element, XML::XPath $xpath, Str $role-signals --> Str
) {

  my Str $signal-admin = '';

  # Check if signal administration is needed
  my Hash $sig-info = self.signals( $element, $xpath);
  if ? $role-signals or ? $sig-info {
    my Str $sig-list = '';
    if ? $sig-info {
      my Hash $signal-levels = %();
      for $sig-info.keys -> $signal-name {
        my Str $level = $sig-info{$signal-name}<level>.Str;
        $signal-levels{$level} = [] unless $signal-levels{$level}:exists;
        $signal-levels{$level}.push: $signal-name;
      }

      for ^10 -> Str() $level {
        if ?$signal-levels{$level} {
          $sig-list ~=
            [~] '      :w', $level, '<', $signal-levels{$level}.join(' '),
                ">,\n";
        }
      }

      $sig-list = 'self.add-signal-types( $?CLASS.^name,' ~
                  "\n" ~ $sig-list ~ "    );\n" if ? $sig-list;
    }

    $signal-admin ~= qq:to/EOBUILD/;
        # Add signal administration info.
        unless \$signals-added \{
          $sig-list$role-signals    \$signals-added = True;
        \}
      EOBUILD
  }

  $signal-admin;
}

#-------------------------------------------------------------------------------
method get-gtk-init ( --> List ) {
  my Str $code = '';
  my Str $init-gtk = '';

  if $*work-data<raku-class-name> eq 'Gnome::GObject::Object' {
    $code ~= q:to/EOBUILD/;

      # Check on native library initialization.
      my Bool $gui-initialized = False;
      my Bool $may-not-initialize-gui = False;
      EOBUILD

    # Check for initialization of Gtk libraries, but check for
    # certain conditions.
    $init-gtk ~= q:to/EOBUILD/;

        # check GTK+ init except when GtkApplication / GApplication is used
        $may-not-initialize-gui = [or]
          $may-not-initialize-gui,
          $gui-initialized,
          # Check for Application from Gio. That one inherits from Object.
          # Application from Gtk3 inherits from Gio, so this test is always ok.
          ?(self.^mro[0..*-3].gist ~~ m/'(Application) (Object)'/);

        self.gtk-initialize unless $may-not-initialize-gui or $gui-initialized;

        # What ever happens, init is done in (G/Gtk)Application or just here
        $gui-initialized = True;
      EOBUILD
  }

  ( $code, $init-gtk)
}

#-------------------------------------------------------------------------------
method get-constructors (
  XML::Element $element, XML::XPath $xpath, Bool :$user-side = False --> Hash
) {
  my Hash $hcs = %();

  my @constructors =
    $xpath.find( 'constructor', :start($element), :to-list);

  for @constructors -> $cn {
    # Skip deprecated constructors
    next if $cn.attribs<deprecated>:exists and $cn.attribs<deprecated> eq '1';

    my ( $function-name, %h) =
      self!get-constructor-data( $cn, :$xpath, :$user-side);
    $hcs{$function-name} = %h;
  }

  $hcs
}

#-------------------------------------------------------------------------------
method !get-constructor-data (
  XML::Element $e, XML::XPath :$xpath, Bool :$user-side = False --> List ) {
  my Bool $missing-type = False;
  my Str $function-name = $e.attribs<c:identifier>;

  my Str $sub-prefix = $*work-data<sub-prefix>;

  # Find suitable option names for the BUILD submethod.
  # Constructors have '_new' in the name. To get a name for the build options
  # remove the subroutine prefix and the 'new_' string from the subroutine
  # name.
  my Str $option-name = $function-name;
  $option-name ~~ s/^ $sub-prefix new '_'? //;
  $function-name ~~ s/^ $sub-prefix //;

  # Remove any other prefix ending in '_'.
  my Int $last-u = $option-name.rindex('_');
  $option-name .= substr($last-u + 1) if $last-u.defined;

  # When nothing is left, make it empty.
  $option-name = '' if $option-name ~~ m/^ \s* $/;

  # Find return value; constructors should return a native N-GObject while
  # the gnome might say e.g. gtkwidget 
  my XML::Element $rvalue = $xpath.find( 'return-value', :start($e));
  my Str ( $rv-type, $return-raku-type) = self!get-type( $rvalue, :$user-side);
  $missing-type = True if !$return-raku-type or $return-raku-type ~~ /_UA_ $/;
  $return-raku-type ~~ s/ _UA_ $//;

  # Get all parameters. Mostly the instance parameters come first
  # but I am not certain.
  my @parameters = ();
  my @prmtrs = $xpath.find(
    'parameters/instance-parameter | parameters/parameter',
    :start($e), :to-list
  );

  my Str ( $type, $raku-type);
  my Bool $variable-list = False;
  my Bool $first = True;
  for @prmtrs -> $p {

    # Process first argument type to attach to option name
    if $first {
      # We need the native type to keep the $option-name the same in all cases
      ( $type, $raku-type) = self!get-type( $p, :!user-side);
      with $raku-type {
        when 'Str' {
          $option-name ~= (?$option-name ?? '-' !! '') ~ 'text';
        }

        when m/^ guint / {
          $option-name ~= (?$option-name ?? '-' !! '') ~ 'uint';
        }

        when m/^ gint / {
          $option-name ~= (?$option-name ?? '-' !! '') ~ 'int';
        }

        when any(<gdouble gfloat>) {
          $option-name ~= (?$option-name ?? '-' !! '') ~ 'number';
        }

        when 'N-GObject' {
          $option-name ~= (?$option-name ?? '-' !! '') ~ 'object';
        }

        when 'GEnum' {
          $option-name ~= (?$option-name ?? '-' !! '') ~ 'enum';
        }

        when 'GFlag' {
          $option-name ~= (?$option-name ?? '-' !! '') ~ 'mask';
        }
      }

#note "$?LINE get-constructor-data $user-side, $raku-type -> $option-name";
      $first = False;
    }

    else {
      ( $type, $raku-type) = self!get-type( $p, :$user-side);
    }

    $missing-type = True if !$raku-type or $raku-type ~~ /_UA_ $/;
    $raku-type ~~ s/ _UA_ $//;

    my Hash $attribs = $p.attribs;
    my Str $parameter-name = $attribs<name>;
    $parameter-name ~~ s:g/ '_' /-/;

    # When '...', there will be no type for that parameter. It means that
    # a variable argument list is used ending in a Nil.
    if $parameter-name eq '...' {
      $type = $raku-type = '…';
      $variable-list = True;
    }

    my Hash $ph = %( :name($parameter-name), :$type, :$raku-type);

    $ph<allow-none> = $attribs<allow-none>.Bool;
    $ph<nullable> = $attribs<nullable>.Bool;
    $ph<is-instance> = False;

    @parameters.push: $ph;
  }

  ( $function-name, %(
      :$option-name, :@parameters, :$variable-list,
      :$rv-type, :$return-raku-type, :$missing-type
    )
  );
}

#-------------------------------------------------------------------------------
method !generate-constructors ( Hash $hcs --> Str ) {

  my Str $sub-prefix = $*work-data<sub-prefix>;
#  my Str $pattern = '';
  my Str $temp-inhibit = '';
  my Str $variable-list = '';

  my Str $code = qq:to/EOSUB/;

    {SEPARATOR( 'Constructors', 2);}
    EOSUB

  for $hcs.keys.sort -> $function-name is copy {
    my Hash $curr-function := $hcs{$function-name};
    $temp-inhibit = ?$curr-function<missing-type> ?? '#' !! '';

#    $pattern = $curr-function<variable-list> ?? ':pattern([' !! '';
    $variable-list = $curr-function<variable-list> ?? ':variable-list, ' !! '';

    # Get a list of types for the arguments
    my $par-list = '';
#    my Str $pattern-starter = '';
    for @($curr-function<parameters>) -> $parameter {
      last if $parameter<raku-type> eq '…';
      # Enumerations and bitfields are returned as GEnum:Name and GFlag:Name
      my ( $rnt0, $rnt1) = $parameter<raku-type>.split(':');
#      $par-list ~= ", $rnt0";
#`{{
      if $curr-function<variable-list> {
        # When variable list, the last type is '…', Finish the pattern.
        if $parameter<raku-type> eq '…' {
          # A pattern consists of a character key and some value of an unknown
          # type. This repeats until user data is exhausted. Then end with a 0.
          # The first argument in the pattern is a string (mostly) then a value
          # followed by the type of that value. Take glib types!

          #TODO investigate if this is always true in gnome variable lists.
          $pattern ~= "$pattern-starter, Nil]), ";
          last;
        }

        else {
          # The $par-list will have the non-repetative arguments
          $par-list ~= ", $pattern-starter" if ?$pattern-starter;
          $pattern-starter = $rnt0;
        }
      }

      else {
}}
        $par-list ~= ", $rnt0";
#      }
    }

    # Remove first comma
    $par-list ~~ s/^ . //;
    my Str $parameters = ?$par-list ?? ":parameters\(\[$par-list\]\)," !! '';

    # Save as a user recognizable name. This makes it possible
    # to postpone the translation as late as possible at run time
    # and only once per function.
    $function-name ~~ s:g/ '_' /-/;
    
    my Str $isnew = '';
    if $function-name eq 'new' {
      my Str $gname = $*work-data<gnome-name>;
      my Str $prefix = $*work-data<name-prefix>;
      $gname ~~ s:i/^ $prefix //;
      $function-name ~= '-' ~ $gname.lc;

      $isnew = ':isnew, ';
    }

    my $xtype = $curr-function<return-raku-type>;
    $code ~= [~] '  ', $temp-inhibit, $function-name,
                ' => %( :type(Constructor), ', $isnew,
                ':returns(', $xtype, '), ',
                $variable-list, $parameters, "),\n";

    # drop last comma from arg list
    $code ~~ s/ '),)' /))/;
  }

  $code
}

#-------------------------------------------------------------------------------
method get-methods (
  XML::Element $element, XML::XPath $xpath, Bool :$user-side = False --> Hash
) {
  my Hash $hms = %();

  my @methods = $xpath.find( 'method', :start($element), :to-list);

  for @methods -> $function {
    # Skip deprecated methods
    next if $function.attribs<deprecated>:exists and
            $function.attribs<deprecated> eq '1';

    my ( $function-name, %h) =
      self!get-method-data( $function, :$xpath, :$user-side);
    $hms{$function-name} = %h;
  }

  $hms
}

#-------------------------------------------------------------------------------
method !generate-methods ( Hash $hcs --> Str ) {

  # Get all methods in this class
  #my Hash $hcs = self.get-methods( $element, $xpath);
  #return '' unless ?$hcs;

#  my Str $ctype = $element.attribs<c:type>;
#  my Hash $h = self.search-name($ctype);
#  my Str $symbol-prefix = $h<symbol-prefix> // $h<c:symbol-prefix> // '';
  my Str $symbol-prefix = $*work-data<sub-prefix>;
#  my Str $pattern = '';
  my Str $temp-inhibit = '';
  my Str $variable-list = '';

  my Str $code = qq:to/EOSUB/;

    {SEPARATOR( 'Methods', 2);}
    EOSUB

  for $hcs.keys.sort -> $function-name is copy {
    my Str $cnv-return = '';
    my Hash $curr-function := $hcs{$function-name};
    $temp-inhibit = ?$curr-function<missing-type> ?? '#' !! '';

#note "$?LINE  $function-name, inhibit: $temp-inhibit, $curr-function<missing-type>";

    #$pattern = $curr-function<variable-list> ?? ':pattern([' !! '';
    $variable-list = $curr-function<variable-list> ?? ':variable-list, ' !! '';

    # get method name, drop the prefix
#    my Str $hash-fname = $function-name;
#    $hash-fname ~~ s/^ $symbol-prefix //;

    # Save as a user recognizable name. This makes it possible
    # to postpone the translation as late as possible at run time
    # and only once per function.
    $function-name ~~ s:g/ '_' /-/;

    # get parameter lists
    my Str $par-list = '';
    my Bool $first-param = True;

#    my Str $pattern-starter = '';
    for @($curr-function<parameters>) -> $parameter {
#note "  $?LINE $parameter<name> $parameter<raku-type>";
      last if $parameter<raku-type> eq '…';

      # Get a list of types for the arguments but skip the first native type
      # This is the instance variable which is inserted automatically in the
      # fallback routines.
      if $first-param {
        $first-param = False;
      }

      else {
        my Str $xtype = $parameter<raku-type>;
        # Signatures have a colon at the first char followed by '('
        if $xtype ~~ m/^ ':(' / {
          $par-list ~= ", $xtype";
        }

        else {
          # Enumerations and bitfields are returned as GEnum:Name and GFlag:Name
          # Here we only need the type.
          my ( $rnt0, $rnt1) = $xtype.split(':');
#        $par-list ~= ", $rnt0";

#`{{
          if $curr-function<variable-list> {
            # When variable list, the last type is '…', Finish the pattern.
            if $parameter<raku-type> eq '…' {
              # A pattern consists of a character key and some value of an 
              # unknown type. This repeats until user data is exhausted.
              # Then end with a 0. The first argument in the pattern is a string
              # (mostly) then a value followed by the type of that value. Take
              # glib types!

              #TODO investigate if this is always true in gnome variable lists.
              $pattern ~= "$pattern-starter, Nil]), ";
              last;
            }

            else {
              # The $par-list will have the non-repetative arguments
              $par-list ~= ", $pattern-starter" if ?$pattern-starter;
              $pattern-starter = $rnt0;
            }
          }

          else {
}}
            $par-list ~= ", $rnt0";
#          }
        }
      }
    }

    # Remove first comma and space
    $par-list ~~ s/^ .. //;
#    $par-list ~~ s/^ . // unless $par-list ~~ m/ \, /;
    $par-list = ?$par-list ?? [~] ' :parameters([', $par-list, ']),' !! '';

    # Return type
    my $xtype = $curr-function<return-raku-type>;
    my Str $returns = '';

    # Enumerations and bitfields are returned as GEnum:Name and GFlag:Name
    my ( $rnt0, $rnt1) = $xtype.split(':');
    if ?$rnt1 {
      $returns = " :returns\($rnt0\),";
      $cnv-return = " :cnv-return\($rnt1\),";
    }

    elsif ?$rnt0 and $xtype ne 'void' {
      $returns = " :returns\($rnt0\),";
      if $xtype eq 'gboolean' {
        $cnv-return = ' :cnv-return(Bool),';
      }
    }

#note "$?LINE $function-name";
#note "$?LINE $returns";
#note "$?LINE $par-list";

    $code ~= [~] '  ', $temp-inhibit, $function-name, ' => %(',
             $variable-list, $returns, $cnv-return, $par-list, "),\n";

    # drop last comma from arg list
    $code ~~ s/ '),)' /))/;
  }

  $code
}

#-------------------------------------------------------------------------------
method generate-functions ( Hash $hcs --> Str ) {

  return '' unless ?$hcs;

#  my Str $symbol-prefix = $*work-data<sub-prefix>;
#  my Str $pattern = '';
  my Str $temp-inhibit = '';
  my Str $variable-list = '';

  # Get all functions from the Hash
  my Str $code = qq:to/EOSUB/;

    {SEPARATOR( 'Functions', 2);}
    EOSUB

  for $hcs.keys.sort -> $function-name is copy {
    my Str $cnv-return = '';
    my Hash $curr-function := $hcs{$function-name};
    $temp-inhibit = ?$curr-function<missing-type> ?? '#' !! '';

     # Get method name, drop the prefix and substitute '_'
#    my Str $hash-fname = $function-name;
#    $hash-fname ~~ s/^ $symbol-prefix //;
#    # keep this version for later
#    my Str $hash-fname = $method-name;
#    $method-name ~~ s:g/ '_' /-/;

    # Save as a user recognizable name. This makes it possible
    # to postpone the translation as late as possible at run time
    # and only once per function.
    $function-name ~~ s:g/ '_' /-/;

#    my Str $function-doc = $curr-function<function-doc>;
#    $function-doc = "No documentation of function." unless ?$function-doc;

    # Get parameter lists
    my Str (
      $par-list #, $call-list, #$own, $raku-list, $returns-doc, $items-doc, 
    ) =  '';
    my @rv-list = ();

#    $pattern = $curr-function<variable-list> ?? ':pattern([' !! '';
    $variable-list = $curr-function<variable-list> ?? ':variable-list, ' !! '';

#    my Str $pattern-starter = '';
    for @($curr-function<parameters>) -> $parameter {
#      self!get-types(
#        $parameter, #$raku-list, 
#        $call-list, #$items-doc,
#        @rv-list #, $returns-doc
#      );
      last if $parameter<raku-type> eq '…';

#TODO emptied when signature found: starts with ':('
      # Enumerations and bitfields are returned as GEnum:Name and GFlag:Name
      my ( $rnt0, $rnt1) = $parameter<raku-type>.split(':');

#`{{
      if $curr-function<variable-list> {
        # When variable list, the last type is '…', Finish the pattern.
        if $parameter<raku-type> eq '…' {
          # A pattern consists of a character key and some value of an unknown
          # type. This repeats until user data is exhausted. Then end with a 0.
          # The first argument in the pattern is a string (mostly) then a value
          # followed by the type of that value. Take glib types!

          #TODO investigate if this is always true in gnome variable lists.
          $pattern ~= "$pattern-starter, Nil]), ";
          last;
        }

        else {
          # The $par-list will have the non-repetative arguments
          $par-list ~= ", $pattern-starter" if ?$pattern-starter;
          $pattern-starter = $rnt0;
        }
      }

      else {
}}
        $par-list ~= ", $rnt0";
#      }
    }

    # Remove first comma and space when there is only one parameter
    $par-list ~~ s/^ . //;
    $par-list ~~ s/^ . // unless $par-list ~~ m/ \, /;
    $par-list = ?$par-list
              ?? [~] ' :parameters([', $par-list, ']),'
              !! '';

#`{{
    my $xtype = $curr-function<return-raku-rtype>;
    if ?$xtype and $xtype ne 'void' {
      $raku-list ~= "  --> $xtype";
      $own = '';
      $own = "\(transfer ownership: $curr-function<transfer-ownership>\) "
        if ?$curr-function<transfer-ownership> and
            $curr-function<transfer-ownership> ne 'none';
}}
#`{{
      # Check if there is info about the return value
      if ?$curr-function<rv-doc> {
        $returns-doc = "\nReturn value; $own$curr-function<rv-doc>\n";
      }

      elsif $raku-list ~~ / '-->' / {
        $returns-doc =
          "\nReturn value; No documentation about its value and use\n";
      }
    }
}}
#`{{
    # Assumed that there are no multiple methods to return values. I.e not
    # returning an array and pointer arguments to receive values in those vars.
    elsif ?@rv-list {
      $returns-doc = "Returns a List holding the values\n$returns-doc";
      #$return-list = [~] '  (', @rv-list.join(', '), ")\n";
      $raku-list ~= "  --> List";
    }
}}
    # remove first comma
#    $raku-list ~~ s/^ . //;
#`{{
    $doc ~= qq:to/EOSUB/;
      {HLSEPARATOR}
      =begin pod
      =head2 $method-name

      $function-doc

      =begin code
      method $method-name \(
       $raku-list
      \)
      =end code

      $items-doc
      $returns-doc
      =end pod

      EOSUB
}}

    # Return type
    # Enumerations and bitfields are returned as GEnum:Name and GFlag:Name
    my Str $returns = '';
    my $xtype = $curr-function<return-raku-type>;
    my ( $rnt0, $rnt1) = $xtype.split(':');
    if ?$rnt1 {
      $returns = " :returns\($rnt0\)";
      $cnv-return = " :cnv-return\($rnt1\),";
    }

    elsif ?$rnt0 and $xtype ne 'void' {
      $returns = " :returns\($rnt0\),";
      if $xtype eq 'gboolean' {
        $cnv-return = ' :cnv-return(Bool),';
      }
    }

#note "$?LINE $function-name, {$returns//'-'}, {$par-list//'-'}";
#TM:0:$function-name
    $code ~= [~] '  ', $temp-inhibit, $function-name,
             ' => %( :type(Function), ', $variable-list, $returns,
             $par-list, "),\n";

    # drop last comma from arg list
    $code ~~ s/ '),)' /))/;
  }

  $code
}

#-------------------------------------------------------------------------------
method get-functions (
  XML::Element $element, XML::XPath $xpath, Bool :$user-side = False --> Hash
) {
  my Hash $hms = %();

  my @methods = $xpath.find( 'function', :start($element), :to-list);

  for @methods -> $function {
    # Skip deprecated methods
    next if $function.attribs<deprecated>:exists and
            $function.attribs<deprecated> eq '1';

    my ( $function-name, %h) =
      self!get-method-data( $function, :$xpath, :$user-side);
    $hms{$function-name} = %h;
  }

  $hms
}

#-------------------------------------------------------------------------------
method get-standalone-functions (
  Array $function-names, Bool :$user-side = False --> Hash
) {
  my Hash $hms = %();

  my Str $file = $*work-data<gir-module-path> ~ 'repo-function.gir';
  my XML::XPath $xpath .= new(:$file);

  my @methods = ();
  for @$function-names -> $name {
    my XML::Element $element =
      $xpath.find( '//function[@name="' ~ $name ~ '"]', :!to-list);
#note "$?LINE ", '//function[@name="' ~ $name ~ '"] ', ($element//'-').Str;

    # Skip empty elements deprecated functions
    next unless ?$element;
    next if $element.attribs<deprecated>:exists and
            $element.attribs<deprecated> eq '1';

    @methods.push: $element
  }

  for @methods -> $cn {
    my ( $function-name, %h) = self!get-method-data( $cn, :$xpath, :$user-side);
    $hms{$function-name} = %h;
  }

  $hms
}

#-------------------------------------------------------------------------------
# Get a callback function pattern. This is used as a type in function arguments
# and other places
method get-callback-function ( Str $function-name --> Hash ) {
  my Str $file = $*work-data<gir-module-path> ~ 'repo-callback.gir';
  my XML::XPath $xpath .= new(:$file);

  my XML::Element $element =
    $xpath.find( '//callback[@name="' ~ $function-name ~ '"]', :!to-list);

  # Skip empty elements deprecated functions
  return %() unless ?$element;
  return %() if $element.attribs<deprecated>:exists and
                $element.attribs<deprecated> eq '1';

  self!get-callback-data( $element, :$xpath)
}

#-------------------------------------------------------------------------------
method generate-callback (
#  Str $function-name, Hash $cb-data, Bool :$named-parameter = False --> Str
  Str $function-name, Hash $cb-data --> Str
) {
  return '' unless ?$cb-data;

  my Bool $available = True;
  my Str $par-list = '';
  for @($cb-data<parameters>) -> $parameter {
    my ( $rnt0, $rnt1) = $parameter<raku-type>.split(':');
    if $rnt0 ~~ / _UA_ $/ {
      $available = False;
      $rnt0 ~~ s/ _UA_ $//;
    }
    $par-list ~= ", $rnt0";
  }

  # Remove first comma and space when there is only one parameter
  $par-list ~~ s/^ . //;

  my Str $returns;
  my $xtype = $cb-data<return-raku-type>;
  my ( $rnt0, $rnt1) = $xtype.split(':');
  if ?$rnt0 and $rnt0 eq 'void' {
    $returns = '';
  }

  elsif ?$rnt0 {
    if $rnt0 ~~ / _UA_ $/ {
      $available = False;
      $rnt0 ~~ s/ _UA_ $//;
    }
    $returns = $rnt0;
  }

  else {
    $returns = '';
  }

#Must do it differently, no argument spec but type => signature
#  my $code = [~] 'Callable ', ($named-parameter ?? ':$' !! '$'),
#                  $function-name, ' (', $par-list,
#                  (?$returns ?? " --> $returns \)" !! ' )');

  my $code = [~] ':(', $par-list, ?$returns ?? " --> $returns \)" !! ' )';
  $code ~= ' _UA_' unless $available;

  $code
}

#-------------------------------------------------------------------------------
method generate-enumerations-code ( Array:D $enum-names --> Str ) {

  # Return empty string if no enums found.
  return '' unless ?$enum-names;

  # Open enumerations file for xpath
  my Str $file = $*work-data<gir-module-path> ~ 'repo-enumeration.gir';
  my XML::XPath $xpath .= new(:$file);

#  my Str $symbol-prefix = $*work-data<sub-prefix>;
  my Str $code = qq:to/EOENUM/;
    {HLSEPARATOR}
    {SEPARATOR('Enumerations');}
    {HLSEPARATOR}
    EOENUM

  # For each of the found names
  for $enum-names.sort -> $enum-name {
    my Str $name = $enum-name;
    my Str $package = $*gnome-package.Str;
    if $package ~~ / Glib || GObject || Gio / {
      $package = 'G';
    }
    
    else {
      $package ~~ s/ \d+ $//;
    }

    $name ~~ s/^ $package //;

    # Get the XML element of the enum data
    my XML::Element $e = $xpath.find(
      '//enumeration[@name="' ~ $name ~ '"]', :!to-list
    );

    $code ~= qq:to/EOENUM/;
      enum $enum-name is export \<
      EOENUM

#    my Str $edoc =
#      ($xpath.find( 'doc/text()', :start($e), :!to-list) // '').Str;
#    my Str $s = self.modify-text($edoc);
#    $doc = self.cleanup($s);

    my Str $member-name-list = '';
    my @members = $xpath.find( 'member', :start($e), :to-list);
    for @members -> $m {
      $member-name-list ~= $m.attribs<c:identifier> ~ ' ';
    }

    $code ~= "  $member-name-list\n\>;\n\n";
  }
#note "$?LINE $code";
#exit;
  $code
}

#`{{
#-------------------------------------------------------------------------------
# When in a class the enumerations are found in separate files. To find the
# correct file, look them up using the filename of the current class. Then use
# that name to find the enumeration names having the same filename. The filename
# is set in the field 'source-filename'.
method !get-enumeration-names ( --> Array ) {

  # Get all enumerations for this class
  my $name = $*work-data<gnome-name>;

  # First get the name of the file of this class
  my Hash $h0 = self.search-name($name);
  return [] unless ?$h0;

  my Str $source-filename = $h0<source-filename>;

  # Now get all other types defined in this class file
  my Hash $h1 = self.search-entries( 'source-filename', $source-filename);

  # Keep all enumeration names
  my Array $enum-names = [];
  for $h1.kv -> $k, $v {
#note $?LINE $k, $v<gir-type>";
    $enum-names.push: $k if $v<gir-type> eq 'enumeration';
  }

  $enum-names
}
}}

#-------------------------------------------------------------------------------
method generate-bitfield-code ( Array:D $bitfield-names --> Str ) {

  # Don't look bitfield names up if array is provided
#  $bitfield-names = self!get-bitfield-names unless ?$bitfield-names;

  # Return empty string if no bitfields found.
  return '' unless ?$bitfield-names;
#note "$?LINE e names: $bitfield-names.gist()";

  # Open bitfields file for xpath
  my Str $file = $*work-data<gir-module-path> ~ 'repo-bitfield.gir';
  my XML::XPath $xpath .= new(:$file);

#  my Str $symbol-prefix = $*work-data<sub-prefix>;
  my Str $code = qq:to/EOENUM/;
    {HLSEPARATOR}
    {SEPARATOR('Bitfields');}
    {HLSEPARATOR}
    EOENUM

#`{{
  my Str $doc = qq:to/EOENUM/;
    {HLSEPARATOR}
    {SEPARATOR('Bitfields');}
    {HLSEPARATOR}
    =begin pod
    =head1 Bitfields
    =end pod

    EOENUM
}}

  # For each of the found names
  for $bitfield-names.sort -> $bitfield-name {
    my Str $name = $bitfield-name;
    my Str $package = $*gnome-package.Str;
    if $package ~~ / Glib || GObject || Gio / {
      $package = 'G';
    }
    
    else {
      $package ~~ s/ \d+ $//;
    }

    $name ~~ s/^ $package //;

#note "$?LINE $bitfield-name, $package, $name";
    # Get the XML element of the bitfield data
    my XML::Element $e = $xpath.find(
      '//bitfield[@name="' ~ $name ~ '"]', :!to-list
    );

#TE:0:$bitfield-name
#      {HLSEPARATOR}
    $code ~= "enum $bitfield-name is export \(\n  ";

#    my Str $edoc =
#      ($xpath.find( 'doc/text()', :start($e), :!to-list) // '').Str;
#    my Str $s = self.modify-text($edoc);
#    $doc = self.cleanup($s);

    my Str $member-name-list = '';
    my @members = $xpath.find( 'member', :start($e), :to-list);
    my @l = ();
    for @members -> $m {
#note "$?LINE $m.attribs()<c:identifier>, $m.attribs()<value>";
      @l.push: [~] ':', $m.attribs<c:identifier>, '(', $m.attribs<value>, ')';
    }

    $code ~= @l.join(', ') ~ "\n\);\n\n";
  }
#note "$?LINE $code";
#exit;
  $code
}

#`{{
#-------------------------------------------------------------------------------
method !get-bitfield-names ( --> Array ) {

  # Get all bitfields for this class
  my $name = $*work-data<gnome-name>;

  # First get the name of the file of this class
  my Hash $h0 = self.search-name($name);
  return [] unless ?$h0;

  my Str $class-file = $h0<source-filename>;

  # Now get all other types defined in this class file
  my Hash $h1 = self.search-entries( 'class-file', $class-file);

  # Keep all bitfield names
  my Array $bitfield-names = [];
  for $h1.kv -> $k, $v {
#note $?LINE $k, $v<gir-type>";
    $bitfield-names.push: $k if $v<gir-type> eq 'bitfield';
  }

  $bitfield-names
}
}}

#-------------------------------------------------------------------------------
method generate-constants ( @constants --> Str ) {
  
  # Don't look enum names up if array is provided
#  @constants = self!get-constant-names unless ?@constants;

  # Return empty string if no enums found.
  return '' unless ?@constants;

  # Open constants file for xpath
#  my Str $file = $*work-data<gir-module-path> ~ 'repo-constant.gir';
#  my XML::XPath $xpath .= new(:$file);

#  my Str $symbol-prefix = $*work-data<sub-prefix>;
  my Str $code = qq:to/EOENUM/;
    {HLSEPARATOR}
    {SEPARATOR('Constants');}
    {HLSEPARATOR}
    EOENUM

#`{{
  my Str $doc = qq:to/EOENUM/;
    {HLSEPARATOR}
    {SEPARATOR('Bitfields');}
    {HLSEPARATOR}
    =begin pod
    =head1 Bitfields
    =end pod

    EOENUM
}}

  # For each of the found names
  for @constants -> $constant {
#note "$?LINE ", $constant.gist;
#    my Str $name = $constant-name;
#    my Str $package = $*gnome-package.Str;
#    $package ~~ s/ \d+ $//;
#    $name ~~ s/^ $package //;

    # Get the XML element of the constant data
#    my XML::Element $e = $xpath.find(
#      '//constant[@name="' ~ $constant[0] ~ '"]', :!to-list
#    );

    my Str $value = $constant[2];
    $value = "'$value'" if $constant[1] ~~ / char /;

#TE:0:$constant[0]
#      {HLSEPARATOR}

    $code ~= "constant $constant[0] is export = $value;\n";

#    my Str $edoc =
#      ($xpath.find( 'doc/text()', :start($e), :!to-list) // '').Str;
#    my Str $s = self.modify-text($edoc);
#    $doc = self.cleanup($s);

#    my Str $member-name-list = '';
#    my @members = $xpath.find( 'member', :start($e), :to-list);
#    my @l = ();
#    for @members -> $m {
#      @l.push: [~] ':', $m.attribs<c:identifier>, '(', $m.attribs<value>, ')';
#    }

#    $code ~= @l.join(', ') ~ "\n\);\n";
  }
#note "$?LINE $code";
#exit;
  $code ~ "\n"
}

#-------------------------------------------------------------------------------
method generate-structure (
  XML::XPath $xpath, XML::Element $element, Bool :$user-side = False
) {

  my $temp-external-modules = $*external-modules;
  $*external-modules = %(
    :NativeCall(EMTRakudo), 'Gnome::N::NativeLib' => EMTInApi2,
    'Gnome::N::N-GObject' => EMTInApi2,
    'Gnome::N::GlibToRakuTypes' => EMTInApi2,
  );

  my Str $name = $*work-data<gnome-name>;
  my Hash $h0 = self.search-name($name);
  my Str $class-name = $h0<class-name>;
#  my Str $parent-class-name = $*work-data<raku-package> ~ '::' ~
#                              $h0<container-class>;
  my Str $record-class = $h0<record-class>;

#TT:1:$class-name:
  my Str $code = qq:to/RAKUMOD/;
    # Command to generate: $*command-line
    use v6;
    RAKUMOD

  my @fields = $xpath.find( 'field', :start($element), :to-list);
  if ?@fields {
    my Str ( $tweak-pars, $build-pars, $tweak-ass, $build-ass) = '' xx 4;

    $code ~= qq:to/EOREC/;

      {$!grd.pod-header('Module Imports')}
      __MODULE__IMPORTS__

      {$!grd.pod-header('Record Structure')}
      unit class $record-class\:auth<github:MARTIMM>\:api<2> is export is repr\('CStruct');

      EOREC

    for @fields -> $field {
      my $field-name = $field.attribs<name>;
#note "$?LINE $field-name";
      my Str ( $type, $raku-type, $raku-rtype) =
        self!get-type( $field, :$user-side);

      $field-name ~~ s:g/ '_' /-/;
      if ?$type {
        # Enumerations and bitfields are returned as GEnum:Name and GFlag:Name
        my Str ( $rnt0, $rnt1) = $raku-type.split(':');
#note "\n$?LINE $raku-type, $raku-rtype, $rnt0, {$rnt1//'-'}\n$field.attribs()gist()" if $class-name eq 'N-GClosureNotifyData';
        if ?$rnt1 {
          $code ~= "has $rnt0 \$.$field-name;           # $rnt1\n";
        }

        #NOTE raku cannot handle this in native structures.
        # Must become a pointer
        elsif $rnt0 ~~ m/ Callable / {
          $code ~= "has gpointer \$.$field-name;\n";
        }

        else {
          $code ~= "has $rnt0 \$.$field-name;\n";
        }

        if $raku-type eq 'N-GObject' {
          $tweak-pars ~= "$raku-type :\$$field-name, ";
          $tweak-ass ~= "  \$!$field-name := \$$field-name if ?\$$field-name;\n";
        }

        else {
          if $rnt0 eq 'GEnum' {
            $build-pars ~= "$rnt0 :\$$field-name, ";
            $build-ass ~= "  \$!$field-name = \$$field-name.value if ?\$$field-name;\n";
          }

          elsif $rnt0 ~~ m/ Callable / {
            $build-pars ~= "gpointer :\$.$field-name;\n";
          }

          else {
            $build-pars ~= "$rnt0 :\$\!$field-name, ";
          }
        }
      }

      # no type found, is it a callback spec?
      else {
        my XML::Element $cb-element =
          $xpath.find( 'callback', :start($field), :!to-list);
        if ?$cb-element {
#NOTE raku cannot handle this in native structures. Must become a pointer
#          my Str $function-name = $cb-element.attribs<name>;
#          my %h = self!get-callback-data( $cb-element, :$xpath);
#          my Str $c = self.generate-callback( $function-name, %h);
#          $code ~= "has $c \$.$field-name;\n";

          $code ~= "  has gpointer \$.$field-name;\n";
          $build-pars ~= "gpointer :\$\!$field-name, ";
        }
      }
    }

    if ?$build-pars {
      $code ~= qq:to/EOREC/;

      submethod BUILD \(
        $build-pars
      \) \{
      $build-ass\}
      EOREC
    }

    if ?$tweak-pars {
      $code ~= qq:to/EOREC/;

      submethod TWEAK \(
        $tweak-pars
      \) \{
      $tweak-ass\}
      EOREC
    }

    $code ~= qq:to/EOREC/;

    method COERCE \( \$no --> $record-class \) \{
      note "Coercing from \{\$no.^name\} to ", self.^name if \$Gnome::N::x-debug;
      nativecast\( $record-class, \$no\)
    \}
    EOREC

#    $code ~= "\n\n";
    self.add-import('Gnome::N::X');
    $code = self.substitute-MODULE-IMPORTS( $code, $class-name, $class-name);
  }

  else {
    # Generate structure as a pointer when no fields are documented
    $code ~= qq:to/EOREC/;
      {$!grd.pod-header('Record Structure')}
      # This is an opaque type of which fields are not available.
      unit class $record-class is export is repr\('CPointer');

      EOREC
  }

  # Reset to original and add this structure
  $*external-modules = $temp-external-modules;
  self.add-import($class-name);

#  my Str $cdir = "$*work-data<result-mods>$h0<container-class>";
#  mkdir $cdir, 0o700 unless $cdir.IO.e;
#  my Str $fname = [~] $cdir, '/', $h0<record-class>, '.rakumod';
  my Str $fname =
     [~] $*work-data<result-mods>, '/', $h0<record-class>, '.rakumod';
  self.save-file( $fname, $code, "record structure");
}

#-------------------------------------------------------------------------------
method generate-union (
  XML::XPath $xpath, XML::Element $element, Bool :$user-side = False
) {

  my $temp-external-modules = $*external-modules;
  $*external-modules = %(
    :NativeCall(EMTRakudo), 'Gnome::N::NativeLib' => EMTInApi2,
    'Gnome::N::N-GObject' => EMTInApi2,
    'Gnome::N::GlibToRakuTypes' => EMTInApi2,
  );

  my Str $name = $*work-data<gnome-name>;
  my Hash $h0 = self.search-name($name);
  my Str $class-name = $h0<class-name>;
  my Str $union-class = $h0<union-class>;

#TT:1:$class-name:
  my Str $code = qq:to/RAKUMOD/;
    # Command to generate: $*command-line
    use v6;
    RAKUMOD

#`{{
    {$!grd.pod-header('Module Imports')}
    __MODULE__IMPORTS__

    {$!grd.pod-header('Union Structure')}
    unit class $class-name\:auth<github:MARTIMM>\:api<2> is export is repr\('CUnion');
}}

  my @fields = $xpath.find( 'field', :start($element), :to-list);
#  return '' unless ?@fields;
  if ?@fields {
    my Str ( $tweak-pars, $build-pars, $tweak-ass, $build-ass) = '' xx 4;

    $code ~= qq:to/EOREC/;

      {$!grd.pod-header('Module Imports')}
      __MODULE__IMPORTS__

      {$!grd.pod-header('Union Structure')}
      unit class $union-class\:auth<github:MARTIMM>\:api<2> is export is repr\('CUnion');

      EOREC

    for @fields -> $field {
      my $field-name = $field.attribs<name>;
      my Str ( $type, $raku-type, $raku-rtype) =
        self!get-type( $field, :$user-side);

      $field-name ~~ s:g/ '_' /-/;
      if ?$type {
        # Enumerations and bitfields are returned as GEnum:Name and GFlag:Name
        my Str ( $rnt0, $rnt1) = $raku-type.split(':');
        if ?$rnt1 {
          $code ~= "HAS $rnt0 \$.$field-name;           # $rnt1\n";
        }

        else {
          $code ~= "HAS $rnt0 \$.$field-name;\n";
        }

        if $raku-type eq 'N-GObject' {
          $tweak-pars ~= "$raku-type :\$$field-name, ";
          $tweak-ass ~= "  \$!$field-name := \$$field-name if ?\$$field-name;\n";
        }

        else {
          if $rnt0 eq 'GEnum' {
            $build-pars ~= "$rnt0 :\$$field-name, ";
            $build-ass ~= "  \$!$field-name = \$$field-name.value if ?\$$field-name;\n";
          }

          else {
            $build-pars ~= "$rnt0 :\$\!$field-name, ";
          }
        }
      }
    }

    if ?$build-pars {
      $code ~= qq:to/EOREC/;

      submethod BUILD \(
        $build-pars
      \) \{
      $build-ass\}
      EOREC
    }

    if ?$tweak-pars {
      $code ~= qq:to/EOREC/;

      submethod TWEAK \(
        $tweak-pars
      \) \{
      $tweak-ass\}
      EOREC
    }

    $code ~= qq:to/EOREC/;

      method COERCE \( \$no --> $union-class \) \{
        note "Coercing from \{\$no.^name\} to ", self.^name if \$Gnome::N::x-debug;
        nativecast\( $union-class, \$no\)
      \}
      
      EOREC
  }

  else {
    # Generate union as a pointer when no fields are documented
    $code ~= qq:to/EOREC/;
      {$!grd.pod-header('Union Structure')}
      # This is an opaque type of which fields are not available.
      unit class $union-class is export is repr\('CPointer');

      EOREC
  }

  self.add-import('Gnome::N::X');
  $code = self.substitute-MODULE-IMPORTS(
    $code, $class-name ~ '::' ~ $union-class
  );

  # Reset to original and add this structure
  $*external-modules = $temp-external-modules;
  self.add-import($class-name ~ '::' ~ $union-class);


#  my Str $cdir = "$*work-data<result-mods>$h0<container-class>";
#  mkdir $cdir, 0o700 unless $cdir.IO.e;
#  my Str $fname = [~] $cdir, '/', $h0<union-class>, '.rakumod';
  my Str $fname =
     [~] $*work-data<result-mods>, '/', $h0<union-class>, '.rakumod';
  self.save-file( $fname, $code, "union structure");
}

#-------------------------------------------------------------------------------
method signals ( XML::Element $element, XML::XPath $xpath --> Hash ) {

  my Hash $signals = %();

  my @signal-info = $xpath.find( 'glib:signal', :start($element), :to-list);
  for @signal-info -> $si {
    my Hash $attribs = $si.attribs;
    next if $attribs<deprecated>:exists and  $attribs<deprecated> == 1;

    # Get signal name and number of parameters (this becomes its level).
    my Str $signal-name = $attribs<name>;
    my Hash $curr-signal := $signals{$signal-name} = %();

    my @prmtrs = $xpath.find( 'parameters/parameter', :start($si), :to-list);
    $curr-signal<level> = @prmtrs.elems.Str;
  }

  note "Get signal info" if $*verbose and ?$signals;
  $signals
}


#-------------------------------------------------------------------------------
method generate-role-init ( XML::Element $element, XML::XPath $xpath --> Str ) {
#  my Str $ctype = $element.attribs<c:type>;
#  my Hash $h = self.search-name($ctype);

  my Str $code = '';

  # Check if signal admin is needed
  my Hash $sig-info = self.signals( $element, $xpath);
  if ?$sig-info<doc> {
#:w3<move-cursor>, :w0<copy-clipboard activate-current-link>,
#:w1<populate-popup activate-link>,
    my Hash $signal-levels = %();
    for $sig-info<signals>.keys -> $signal-name {
      my Str $level = $sig-info<signals>{$signal-name}<parameters>.elems.Str;
      $signal-levels{$level} = [] unless $signal-levels{$level}:exists;
      $signal-levels{$level}.push: $signal-name;
    }

    my Str $sig-list = '';
    for ^10 -> Str() $level {
      if ?$signal-levels{$level} {
        $sig-list ~=
           [~] '    :w', $level, '<', $signal-levels{$level}.join(' '), ">,\n";
      }
    }

    my Str $role-ini-method-name =
      "_add_$*work-data<sub-prefix>signal_types";
#TM:1:$role-ini-method-name:
    $code ~= qq:to/EOBUILD/;
      method $role-ini-method-name ( Str \$class-name ) \{
        self\.add-signal-types\( \$class-name,
      $sig-list  );
      \}

      EOBUILD
  }

#  $code ~= qq:to/RAKUMOD/;
#
#    {$!grd.pod-header('Native Routine Definitions');}
#    my Hash \$methods = \%\(
#    RAKUMOD

  $code
}

#-------------------------------------------------------------------------------
method add-import ( Str $import --> Bool ) {
  my Bool $available = False;

#if $import eq 'Gnome::GObject::N-GValue::N-GValue' {
#  say Backtrace.new.nice;
#  exit;
#}

  # Add only when $import is not in the hash.
  if $*external-modules{$import}:exists {
    $available = True unless $*external-modules{$import} == EMTNotImplemented;
  }

  else {
    $available = True;
    if $*lib-content-list-file{$import}:exists {
      $*external-modules{$import} = ExternalModuleType(
        ExternalModuleType.enums{$*lib-content-list-file{$import}}
      );
    }

    else {
      $*external-modules{$import} = EMTNotImplemented;
      $available = False;
    }
  }

  $available
}

#-------------------------------------------------------------------------------
# Fill in the __MODULE__IMPORTS__ string inserted at the start of the code
# generation. It is the place where the 'use' statements must come.
method substitute-MODULE-IMPORTS ( Str $code is copy, *@exclasses --> Str ) {
  note "Set modules to import" if $*verbose;

  # any does not support slurpy args
  my @exceptclasses := @exclasses;

  my $import = '';
  for $*external-modules.kv -> $m, $s {
    $import ~= "use $m;\n" if $s ~~ EMTRakudo;
  }

  $import ~= "\n";

  for $*external-modules.kv -> $m, $s {
    $import ~= "use $m;\n" if $s ~~ EMTInApi1;
  }

  $import ~= "\n";

  for $*external-modules.keys.sort -> $m {
    if $*external-modules{$m} ~~ EMTNotImplemented {
      $import ~= "#use $m\:api\<2\>;\n";
    }

    elsif $*external-modules{$m} ~~ EMTInApi2 {
      $import ~= "use $m\:api\<2\>;\n" unless $m ~~ any(@exceptclasses);
    }
  }

  $code ~~ s/__MODULE__IMPORTS__/$import/;

  $code
}

#-------------------------------------------------------------------------------
method init-xpath ( Str $element-name, Str $gir-filename --> List ) {
#  my XML::XPath $xpath .= new(:file($*work-data{$gir-filename}));
  my XML::XPath $xpath .= new(:file($gir-filename));
  my XML::Element $element = $xpath.find("//$element-name");
  die "//$element-name elements not found in $gir-filename for $*work-data<raku-class-name>" unless ?$element;

  ( $xpath, $element )
}

#-------------------------------------------------------------------------------
method !get-method-data (
  XML::Element $e, XML::XPath :$xpath, Bool :$user-side = False --> List
) {
  my Str $function-name = $e.attribs<name>;   #$e.attribs<c:identifier>;
#  my Str $sub-prefix = $*work-data<sub-prefix>;
  my Bool $missing-type = False;

#note "\n$?LINE $function-name";
  my XML::Element $rvalue = $xpath.find( 'return-value', :start($e));
  #my Str $rv-transfer-ownership = $rvalue.attribs<transfer-ownership>;
#  my Str ( $rv-type, $return-raku-type, $return-raku-rtype) =
  my Str ( $rv-type, $return-raku-type) = self!get-type( $rvalue, :$user-side);
  $missing-type = True if !$return-raku-type or $return-raku-type ~~ /_UA_ $/;
  $return-raku-type ~~ s/ _UA_ $//;

  # Get all parameters. Mostly the instance parameters come first
  # but I am not certain.
  my @parameters = ();
  my @prmtrs = $xpath.find(
    'parameters/instance-parameter | parameters/parameter',
    :start($e), :to-list
  );

  my Bool $variable-list = False;
  for @prmtrs -> $p {
#    my Str ( $type, $raku-type, $raku-rtype) = self!get-type( $p, :$user-side);
    my Str ( $type, $raku-type) = self!get-type( $p, :$user-side);
    $missing-type = True
      if !$raku-type or $raku-type ~~ /_UA_ $/ or $raku-type ~~ / ':(' /;
    $raku-type ~~ s/ _UA_ $//;
#note "$?LINE $raku-type, $missing-type";
    my Hash $attribs = $p.attribs;
    my Str $parameter-name = $attribs<name>;
    $parameter-name ~~ s:g/ '_' /-/;

    # When '...', there will be no type for that parameter. It means that
    # a variable argument list is used ending in a Nil.
    if $parameter-name eq '...' {
#      $type = $raku-type = $raku-rtype = '…';
      $type = $raku-type = '…';
      $variable-list = True;
    }

    my Hash $ph = %(
      :name($parameter-name), :$type, :$raku-type,
#      :transfer-ownership($attribs<transfer-ownership>),
#      :$raku-rtype
    );
#`{{
    if $p.name eq 'instance-parameter' {
      $ph<allow-none> = False;
      $ph<nullable> = False;
      $ph<is-instance> = True;
    }

    elsif $p.name eq 'parameter' {
      $ph<allow-none> = $attribs<allow-none>.Bool;
      $ph<nullable> = $attribs<nullable>.Bool;
      $ph<is-instance> = False;
    }
}}
    @parameters.push: $ph;
  }
#note "  $?LINE $function-name, miss types: $missing-type";

  ( $function-name, %(
      :@parameters, :$variable-list, :$rv-type, :$return-raku-type,
      :$missing-type
#      :$return-raku-rtype,
#      :$rv-transfer-ownership,
    )
  );
}

#-------------------------------------------------------------------------------
# A simplified method
method !get-callback-data (
  XML::Element $e, XML::XPath :$xpath, Bool :$user-side = False --> Hash
) {
  my XML::Element $rvalue = $xpath.find( 'return-value', :start($e));
  #my Str $rv-transfer-ownership = $rvalue.attribs<transfer-ownership>;
  my Str ( $rv-type, $return-raku-type) = self!get-type( $rvalue, :$user-side);

  # Get all parameters. Mostly the instance parameters come first
  # but I am not certain.
  my @parameters = ();
  my @prmtrs = $xpath.find(
    'parameters/instance-parameter | parameters/parameter',
    :start($e), :to-list
  );

  my Bool $variable-list = False;
  for @prmtrs -> $p {

    my Str ( $type, $raku-type) = self!get-type( $p, :$user-side);
    my Hash $attribs = $p.attribs;
    my Str $parameter-name = $attribs<name>;
    $parameter-name ~~ s:g/ '_' /-/;

    # When '...', there will be no type for that parameter. It means that
    # a variable argument list is used ending in a Nil.
    if $parameter-name eq '...' {
      $type = $raku-type = '…';
      $variable-list = True;
    }

    my Hash $ph = %( :name($parameter-name), :$type, :$raku-type);

    $ph<allow-none> = $attribs<allow-none>.Bool;
    $ph<nullable> = $attribs<nullable>.Bool;
    $ph<is-instance> = False;

    @parameters.push: $ph;
  }

  %(
    :@parameters, :$variable-list, :$rv-type, :$return-raku-type,
  )
}

#-------------------------------------------------------------------------------
method !get-type ( XML::Element $e, Bool :$user-side = False --> List ) {

  # With variable argument lists, the name is '...'. It would not have a type
  # so return something to prevent it marked as a missing type
  return ('...', '...')
    if $e.attribs<name>:exists and $e.attribs<name> eq '...';
#note "$?LINE $e";

  my Str ( $ctype, $raku-type) = '' xx 2;
  for $e.nodes -> $n {
    next if $n ~~ XML::Text;

    with $n.name {
      when 'type' {
        $ctype = $n.attribs<c:type> // $n.attribs<name>;
        $raku-type = $user-side
                   ?? self.convert-rtype($ctype)
                   !! self.convert-ntype($ctype)
                   ;
      }

      when 'array' {
        # Sometimes there is no 'c:type', assume an array of strings
        $ctype = $n.attribs<c:type> // 'gchar**';
        $raku-type = $user-side
                   ?? self.convert-rtype($ctype)
                   !! self.convert-ntype($ctype)
                   ;
      }
    }
  }

#my $name = $e.attribs()<name> // '-';
#note "$?LINE $name, $user-side, $ctype, $raku-type";

  ( $ctype, $raku-type)
}

#-------------------------------------------------------------------------------
method convert-ntype (
  Str $ctype is copy --> Str
#  Str $ctype is copy, Bool :$return-type = False --> Str
) {
  return '' unless ?$ctype;
#note "\n$?LINE convert-ntype ctype: $ctype";

  # ignore const and spaces
  my Str $orig-ctype = $ctype;
  $ctype ~~ s:g/ const //;
  $ctype ~~ s:g/ volatile //;
  $ctype ~~ s:g/ \s+ //;

  my Str $raku-type = '';
  with $ctype {

#TODO int/num/pointers as '$x is rw'
    # ignore const
    when /g? char '**'/       { $raku-type = 'gchar-pptr'; }
    when /g? char '*'/        { $raku-type = 'Str'; }
    when /g? int '*'/         { $raku-type = 'gint-ptr'; }
    when /g? uint '*'/        { $raku-type = 'guint-ptr'; }
    when /g? uint16 '*'/      { $raku-type = 'CArray[uint16]'; }
    when /g? uint32 '*'/      { $raku-type = 'CArray[uint32]'; }
    when /g? size '*'/        { $raku-type = 'CArray[gsize]'; }
    when /g? double '*'/      { $raku-type = 'CArray[gdouble]'; }
    when /g? pointer '*'/     { $raku-type = 'CArray[gpointer]'; }
    when /:i g? object '*'/   { $raku-type = 'N-GObject'; }
#    when /:i g? pixbuf '*'/   { $raku-type = 'N-GObject'; }
#    when /:i g? error '*'/    { $raku-type = 'N-GObject'; }
    when /:i g? quark /       { $raku-type = 'GQuark'; }

    when any(
        <gboolean gchar gdouble gfloat gint gint16 gint32 gint64 gint8 
        glong gpointer gshort gsize gssize guchar guint guint16
        guint32 guint64 guint8 gulong gunichar gushort
        >
    ) {
      $raku-type = $ctype;
    }

    when any(
        <boolean char double float int int16 int32 int64 int8 
        long pointer short size ssize uchar uint uint16
        uint32 uint64 uint8 ulong unichar ushort
        >) {
      $raku-type = "g$ctype";
    }

#TODO check for any other types in gir files
#grep 'name="' Gtk-3.0.gir | grep '<type' | sed 's/^[[:space:]]*//' | sort -u

    when 'GType'              { $raku-type = 'GType'; }

    when 'void'               { $raku-type = 'void'; }


    # Default handles complex types. Single pointer ('*') is handled by
    # Raku automatically, Double pointers ('**') must become CArray[object].
    default {
      # remove any pointer marks
      my Bool $is-pointer = $ctype ~~ m/ '*' .*? '*' / ?? True !! False;
      $ctype ~~ s:g/ '*' //;

      my Hash $h = self.search-name($ctype);
#note "  $?LINE $is-pointer, $ctype, $h.gist";
      given $h<gir-type> // '-' {
        when 'class' {
          $raku-type = 'N-GObject';
          $raku-type = "CArray[$raku-type]" if $is-pointer;
        }

        when 'interface' {
          $raku-type = 'N-GObject';
          $raku-type = "CArray[$raku-type]" if $is-pointer;
        }

        when 'record' {
#NOTE changed somewhere? add-import creates cyclic dependency -> make it an Object;
          $raku-type = "N-$h<gnome-name>";
          $raku-type = "CArray[$raku-type]" if $is-pointer;
          $raku-type ~= ' _UA_' unless self.add-import($h<class-name>);
        }

        when 'union' {
#NOTE changed somewhere? add-import creates cyclic dependency -> make it an Object;
#          $raku-type = "N-$h<gnome-name>";
#          self.add-import($h<class-name>);
#          $raku-type = 'N-GObject';
          $raku-type = "N-$h<gnome-name>";
          $raku-type = "CArray[$raku-type]" if $is-pointer;
          $raku-type ~= ' _UA_' unless self.add-import($h<class-name>);
        }

        when 'constant' {
          $raku-type = "$ctype";
          $raku-type = "CArray[$raku-type]" if $is-pointer;
        }

        when 'enumeration' {
          $raku-type = "GEnum:$ctype";
          $raku-type ~= ' _UA_' unless self.add-import($h<class-name>);
        }

        when 'bitfield' {
          $raku-type = "GFlag:$ctype";
          $raku-type ~= ' _UA_' unless self.add-import($h<class-name>);
        }

#        when 'alias' { $raku-type = $h<class-name>; }
        when 'alias' { }

        when 'callback' {
          my %h = self.get-callback-function($h<callback-name>);
          $raku-type = self.generate-callback( $h<callback-name>, %h);
        }

        default {
          note "Unknown ctype to convert: $orig-ctype";
        }
      }
    }
  }

#note "  $?LINE $ctype, $raku-type";
  $raku-type
}

#-------------------------------------------------------------------------------
method convert-rtype (
  Str $ctype is copy, Bool :$return-type = False --> Str
) {
  return '' unless ?$ctype;
#note "$?LINE convert-rtype $ctype";

  # ignore const and spaces
  my Str $orig-ctype = $ctype;
  $ctype ~~ s:g/ const //;
  $ctype ~~ s:g/ volatile //;
  $ctype ~~ s:g/ \s+ //;

  my Str $raku-type = '';
  with $ctype {

#TODO int/num/pointers as '$x is rw'
    when /g? char '**'/         { $raku-type = 'Array[Str]'; }
    when /g? char '*'/          { $raku-type = 'Str'; }
    when /g? int \d* '*'/       { $raku-type = 'Array[Int]'; }
    when /g? uint \d* '*'/      { $raku-type = 'Array[UInt]'; }
    when /g? size '*'/          { $raku-type = 'Array[gsize]'; }
#    when /:i g? error '*'/      { $raku-type = 'Array[N-GError]'; }
#    when /:i g? pixbuf '*'/     { $raku-type = 'N-GObject'; }
#    when /:i g? error '*'/      { $raku-type = 'N-GObject'; }
    when /g? pointer '*'/       { $raku-type = 'Array'; }

    when / g? boolean / {
      $raku-type = 'Bool';
      $raku-type ~= '()';     # unless $return-type;
    }

    when any(<gchar gint gint16 gint32 gint64 gint8
         glong gshort gsize gssize char int int16 int32 int64 int8
         long short size ssize
         >) {
      $raku-type = 'Int';
      $raku-type ~= '()' unless $return-type;
    }

    when any(<guchar guint guint16 guint32 guint64
         guint8 gulong gunichar gushort uchar uint uint16 uint32 uint64
         uint8 ulong unichar ushort
         >) {
      $raku-type = 'UInt';
      $raku-type ~= '()' unless $return-type;
    }

    when /g [float || double]/ {
      $raku-type = 'Num';
      $raku-type ~= '()' unless $return-type;
    }

    when 'GType' { $raku-type = 'GType'; }

    when /GQuark/ { $raku-type = 'UInt'; }
    when /GList/ {
      $raku-type = 'N-GList';
      $raku-type ~= '()' unless $return-type;
    }

    when /GSList/ {
      $raku-type = 'N-GSList';
      $raku-type ~= '()' unless $return-type;
    }

#TODO check for any other types in gir files
#grep 'name="' Gtk-3.0.gir | grep '<type' | sed 's/^[[:space:]]*//' | sort -u

    when 'void' { $raku-type = 'void'; }
    when 'gpointer' { $raku-type = 'gpointer'; }

    default {
      # remove any pointer marks because objects are provided by pointer
#      my Bool $is-pointer = $ctype ~~ m/ '*' / ?? True !! False;
      $ctype ~~ s:g/ '*' //;

      my Hash $h = self.search-name($ctype);
      given $h<gir-type> // '-' {
        when 'class' {
          $raku-type = 'N-GObject';
          $raku-type ~= '()' unless $return-type;
        }

        when 'interface' {
          $raku-type = 'N-GObject';
          $raku-type ~= '()' unless $return-type;          
        }

        when 'record' {
#note "$?LINE record $orig-ctype $h.gist()";
#          $raku-type = "N-$h<gnome-name>";
#          self.add-import($h<structure-name>);
          $raku-type = 'N-GObject';
        }

        when 'union' {
#          $raku-type = "N-$h<gnome-name>";
#          self.add-import($h<structure-name>);
          $raku-type = 'N-GObject';
        }

        when 'enumeration' {
          # All C enumerations are integers and can coerce to the enum type
          # in input and output. Need to prefix package name because
          # enumerations are mentioned without it
#          $raku-type = $h<class-name> ~ '()';
          $raku-type = "GEnum:$ctype";
          $raku-type ~= ' _UA_' unless self.add-import($h<class-name>);
        }

        when 'bitfield' {
#          $raku-type = 'UInt';
#          $raku-type ~= '()' unless $return-type;
          $raku-type = "UInt:$ctype";
          $raku-type ~= ' _UA_' unless self.add-import($h<class-name>);
        }

        when 'alias' { }

        when 'callback' {
#          my Hash %h = self.get-callback-function();
#          $raku-type = self.generate-callback( $ctype, %h);
        }

        default {
          note 'Unknown gir type to convert to raku type \'',
            $h<gir-type> // '-', '\' for ctype \'', $orig-ctype,
            '\', \'', $*work-data<gnome-type>, '\'';
        }
      }
    }
  }

  $raku-type
}

#-------------------------------------------------------------------------------
method search-name ( Str $name is copy --> Hash ) {

  self.check-search-list;

  if $name ~~ m/ '::' / {
    my Str $raku-package = $*work-data<raku-package>;
    $name ~~ s/^ $raku-package '::' //;
    $name ~~ s/^ [<[NTR]> '-']? //;
  }

  my Hash $h = %();
  for @*map-search-list -> $map-name {
    self.check-map($map-name);

#note "Search for $name in map $map-name" if $*verbose;
#say "$?LINE: search $name, $map-name" if $name ~~ m:i/ orientable /;

    # It is possible that not all hashes are loaded
    next unless $*object-maps{$map-name}:exists
            and ( $*object-maps{$map-name}{$name}:exists 
                  or $*object-maps{$map-name}{$map-name ~ $name}:exists
                );

    # Get the Hash from the object maps
    $h = $*object-maps{$map-name}{$name}
         // $*object-maps{$map-name}{$map-name ~ $name};

    # Add package name to this hash
#    $h<raku-package> = $*other-work-data{$map-name}<raku-package>;
    last;
  }

#say Backtrace.new.nice if $name eq 'GdkPixbufPixbuf';

  $h
}

#-------------------------------------------------------------------------------
# Search for names of specific type in object maps 
method search-names ( Str $prefix-name, Str $entry-name, Str $value --> Hash ) {

  self.check-search-list;

  my Hash $h = %();
  for @*map-search-list -> $map-name {
    self.check-map($map-name);

#    note "Search for $prefix-name in map $map-name where field $entry-name ≡? $value" if $*verbose;
    # It is possible that not all hashes are loaded
    next unless $*object-maps{$map-name}:exists;

    for $*object-maps{$map-name}.kv -> $name, $value-hash {
#note "$?LINE snames $map-name, $prefix-name, $entry-name, $value, $name, $value-hash.gist()";
      next unless $value-hash{$entry-name}:exists;

      next unless $value-hash{$entry-name} eq $value;
      next unless $name ~~ m/^ [ $map-name ]? $prefix-name /;
      $h{$name} = $value-hash;

      # Add package name to this hash
#      $h{$name}<raku-package> = $*other-work-data{$map-name}<raku-package>;
    }

    last if ?$h;
  }

#say "$?LINE: search names for $entry-name -> $h.gist()";

  $h
}

#-------------------------------------------------------------------------------
# Search for names of specific type in object maps 
method search-entries ( Str $entry-name, Str $value --> Hash ) {

  self.check-search-list;

  my Hash $h = %();
  for @*map-search-list -> $map-name {
    self.check-map($map-name);

#    note "Search for entries in map $map-name where field $entry-name ≡? $value"
#      if $*verbose;
    # It is possible that not all hashes are loaded
    next unless $*object-maps{$map-name}:exists;

    for $*object-maps{$map-name}.kv -> $name, $value-hash {
      next unless $value-hash{$entry-name}:exists;

      next unless $value-hash{$entry-name} eq $value;
      $h{$name} = $value-hash;

      # Add package name to this hash
#      $h{$name}<raku-package> = $*other-work-data{$map-name}<raku-package>;
    }

    last if ?$h;
  }

#say "$?LINE: search entries for $entry-name -> $h.gist()";

  $h
}

#-------------------------------------------------------------------------------
method check-search-list ( ) {
  unless ?@*map-search-list {
    my Str $package = $*gnome-package.Str;

    # Gtk version 3 and 4 depend on these at least
    @*map-search-list = <Gtk Gdk Atk Gio Cairo PangoCairo Pango>
      if $package ~~ m/^ Gtk /;

    # Add Gsk when processing Gtk version 4
    @*map-search-list.push: 'Gsk' if $package eq 'Gtk4';

    # Add Pixbuf when processing Gtk version 3
    @*map-search-list.push: 'GdkPixbuf' if $package eq 'Gtk3';

    # Only process these when gdk version 3
    @*map-search-list = <Gdk GdkPixbuf Cairo> if $package eq 'Gdk3';

    # Only process this when gdk version 4
    @*map-search-list = <Gdk Cairo> if $package eq 'Gdk4';

    # Some lesser packages
    @*map-search-list = <Pango Cairo PangoCairo>
      if $package ~~ m/ Pango || Cairo /;

    @*map-search-list = 'Gio' if $package eq 'Gio';

    # And always add the following
    @*map-search-list.push: 'Glib', 'GObject';
  }  
}

#-------------------------------------------------------------------------------
method check-map ( Str $map ) {
  unless $*object-maps{$map}:exists {
    my Str $package = $*gnome-package.Str;
    my Str $module-path;

    if $package ~~ m/ '3' $/ and $map ~~ any(<Gtk Gdk>) {
      $module-path = SKIMTOOLDATA ~ $map ~ '3/';
    }

    elsif $package ~~ m/ '4' $/ and $map ~~ any(<Gtk Gdk Gsk>) {
      $module-path = SKIMTOOLDATA ~ $map ~ '4/';
    }

    else {
      $module-path = SKIMTOOLDATA ~ $map ~ '/';
    }

    $*object-maps{$map} = self.load-map( $map, $module-path);
  }
}

#-------------------------------------------------------------------------------
method load-map ( Str $map, Str $object-map-path --> Hash ) {

  my $fname = $object-map-path ~ 'repo-object-map.yaml';
  if $fname.IO.r {
    note "Load object map for $map" if $*verbose;
    load-yaml($fname.IO.slurp)
  }

  else {
    note "File object map '$fname' not found";
    %()
  }
}

#-------------------------------------------------------------------------------
method save-file ( Str $filename is copy, Str $content, Str $comment ) {
note "$?LINE $filename";

  my Bool $save-it = True;

  # Ask to overwrite or save aside files
  if $filename.IO.e {
    say "\nFile $filename.IO.basename() found,",
     " Overwrite(o), new version(v), skip(s)";
    my Str $a = prompt "[o,v,s] s is default> ";
    given $a.lc {
      when 'o' { }

      when 'v' {
        my $f = $filename;
        my Int $v = 1;
        $filename ~= ";$v";
        while $filename.IO.e {
          $v++;
          $filename = "$f;$v";
        }
      }

      # when 's'
      default {
        $save-it = False;
      }
    }
  }

  if $save-it {
    $filename.IO.spurt($content);
    $*saved-file-summary.push: $filename.IO.basename;
  }
}













=finish

#-------------------------------------------------------------------------------
method make-build-submethod (
  XML::Element $element, XML::XPath $xpath --> Str
) {
  my Str $ctype = $element.attribs<c:type>;
  my Hash $h = self.search-name($ctype);

  my Str $signal-admin = '';
#---
  # See which roles to implement
  my Str $role-signals = '';
  my Array $roles = $h<implement-roles> // [];
  for @$roles -> $role {
    my Hash $role-h = self.search-name($role);
    if ?$role-h {
#note "$?LINE role $role, ", $role-h.gist;
      $role-signals ~=
        "    self._add_$role-h<symbol-prefix>signal_types\(\$?CLASS\.^name)\n" ~
        "      if self.^can\('_add_$role-h<symbol-prefix>signal_types');\n";
    }
  }

  $role-signals = "\n    # Signals from interfaces\n" ~ $role-signals
    if ?$role-signals;
#---
  # Check if signal administration is needed
  my Hash $sig-info = self.signals( $element, $xpath);
  if ? $role-signals or ? $sig-info {
    my Str $sig-list = '';
    if ? $sig-info {
      my Hash $signal-levels = %();
      for $sig-info.keys -> $signal-name {
        my Str $level = $sig-info{$signal-name}<level>.Str;
        $signal-levels{$level} = [] unless $signal-levels{$level}:exists;
        $signal-levels{$level}.push: $signal-name;
      }

      for ^10 -> Str() $level {
        if ?$signal-levels{$level} {
          $sig-list ~=
            [~] '      :w', $level, '<', $signal-levels{$level}.join(' '),
                ">,\n";
        }
      }

      $sig-list = 'self.add-signal-types( $?CLASS.^name,' ~
                  "\n" ~ $sig-list ~ "    );\n" if ? $sig-list;
    }

    $signal-admin ~= qq:to/EOBUILD/;
        # Add signal administration info.
        unless \$signals-added \{
          $sig-list$role-signals    \$signals-added = True;
        \}
      EOBUILD

  }

  my Str $c = '';
  if ?$signal-admin {
    $c ~= q:to/EOBUILD/;

      # Add signal registration helper
      my Bool $signals-added = False;
      EOBUILD
  }
#---
  my Str $init-gtk = '';
  if $*work-data<raku-class-name> eq 'Gnome::GObject::Object' {
    $c ~= q:to/EOBUILD/;

      # Check on native library initialization.
      my Bool $gui-initialized = False;
      my Bool $may-not-initialize-gui = False;
      EOBUILD

    $init-gtk ~= q:to/EOBUILD/;

        # check GTK+ init except when GtkApplication / GApplication is used
        $may-not-initialize-gui = [or]
          $may-not-initialize-gui,
          $gui-initialized,
          # Check for Application from Gio. That one inherits from Object.
          # Application from Gtk3 inherits from Gio, so this test is always ok.
          ?(self.^mro[0..*-3].gist ~~ m/'(Application) (Object)'/);

        self.gtk-initialize unless $may-not-initialize-gui or $gui-initialized;

        # What ever happens, init is done in (G/Gtk)Application or just here
        $gui-initialized = True;
      EOBUILD
  }
#---
  my Str $code = qq:to/EOBUILD/;
    {$!grd.pod-header('BUILD variables');}
    # Define callable helper
    has Gnome::N::GnomeRoutineCaller \$\!routine-caller;
    $c
    {$!grd.pod-header('BUILD submethod');}
    submethod BUILD \( *\%options \) \{
    $init-gtk$signal-admin
      # Initialize helper
      \$\!routine-caller .= new\( :library\($*work-data<library>\), :sub-prefix\<$*work-data<sub-prefix>\>);

    EOBUILD
#---

  # Check if inherit code is to be inserted
#  my Str $ctype = $element.attribs<c:type>;
#  my Hash $h = self.search-name($ctype);
  if $h<inheritable> {
    $code ~= [~] '  # Prevent creating wrong widgets', "\n",
            '  if self.^name eq ', "'$*work-data<raku-class-name>'",
            ' or %options<', $*work-data<gnome-name>, '> {', "\n";
  }

  else {
    $code ~= [~] '  # Prevent creating wrong widgets', "\n",
            '  if self.^name eq ', "'$*work-data<raku-class-name>'", ' {', "\n";
  }
#---

  # Add first few tests
  my Str $b-id-str = ?$h<inheritable>
                     ?? "\n" ~ '    elsif %options<build-id>:exists { }' !! '';
  $code ~= qq:to/EOBUILD/;

        # If already initialized in some parent, the object is valid
        if self.is-valid \{ \}

        # Check if common options are handled by some parent
        elsif \%options\<native-object>:exists \{ \}$b-id-str

        else \{
          my N-GObject\(\) \$no;
    EOBUILD

  my Bool $simple-func-new = False;
  my Str $ifelse = 'if';
  my Hash $hcs = self.get-constructors( $element, $xpath);
  if ?$hcs {
    for $hcs.keys.sort -> $function-name is copy {

      my Hash $curr-function := $hcs{$function-name};
      my Str $par-list = '';
      my Str $decl-list = '';
      my Str $temp-inhibit =
        ( $curr-function<missing-type> || $curr-function<variable-list> )
        ?? '#' !! '';

      # Save as a user recognizable name. This makes it possible
      # to postpone the translation as late as possible at run time
      # and only once per function.
      $function-name ~~ s:g/ '_' /-/;

      # Insert a method without args if there are no parameters.
      $simple-func-new = True unless ?$curr-function<parameters>;

      # Process arguments if there are any.
      unless $simple-func-new {
        # Use the option name if it is the first arg.
        my Bool $first = True;
        for @($curr-function<parameters>) -> $parameter {
          $par-list ~= ", \$$parameter<name>";
          $decl-list ~= [~]
            '        ', $temp-inhibit, 'my $', $parameter<name>, ' = %options<',
            ($first ?? $curr-function<option-name> !! $parameter<name>), '>;',
            "\n";

            $first = False;
        }

        # Remove first comma and first space
        $par-list ~~ s/^ .. //;

        $code ~= qq:to/EOBUILD/;
                $ifelse \%options\<$curr-function<option-name>\>:exists \{
          $decl-list
                  # 'my Bool \$x' is needed but value ignored
                  $temp-inhibit\$no = self\._fallback-v2\( '$function-name', my Bool \$x, $par-list\);
                \}

          EOBUILD

        $ifelse = "elsif";
      }
    }
  }

  if !$h<inheritable> {
    $code ~= qq:to/EOBUILD/;
          # check if there are unknown options
          $ifelse %options.elems \{
            die X::Gnome.new\(
              :message\(
                'Unsupported, undefined, incomplete or wrongly typed options for ' ~
                self\.\^name ~ ': ' ~ \%options.keys.join\(', '\)
              \)
            \);
          \}

    EOBUILD

    $ifelse = "elsif";
  }

#`{{
  $code ~= qq:to/EOBUILD/;
        #`\{\{ when there are no defaults use this
        # Check if there are any options
        $ifelse \%options.elems == 0 \{
          die X::Gnome.new\(:message\('No options specified ' ~ self.^name\)\);
        \}
        \}\}

  EOBUILD
#  $ifelse = "elsif";
}}


  # A simple call for a new() without arguments
  if $simple-func-new {
    if $ifelse eq 'if' {
      $code ~= qq:to/EOBUILD/;

            # Create default object
            \$no = self\._fallback-v2\( 'new', my Bool \$x\);
            self\._set-native-object\(\$no);
      EOBUILD
    }

    else {
      # When there are defaults, a new() without arguments
      $code ~= qq:to/EOBUILD/;

            # Create default object
            else \{
              \$no = self\._fallback-v2\( 'new', my Bool \$x\);
            \}
      EOBUILD
    }
  }

  $code ~= qq:to/EOBUILD/;
        if ?\$no \{
          self\._set-native-object\(\$no);
        }

        else \{
          die X::Gnome.new\(:message\('Native object for class $*work-data<raku-class-name> not created'\)\);
        \}
      \}
  EOBUILD

  self.add-import('Gnome::N::X');
  $code ~= qq:to/EOBUILD/;

      # only after creating the native-object, the gtype is known
      self._set-class-info\('$*work-data<gnome-name>'\);
    \}
  \}
  EOBUILD

  $code
}
