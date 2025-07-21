use v6.d;

use Gnome::SourceSkimTool::ConstEnumType;
use Gnome::SourceSkimTool::DocText;
use Gnome::SourceSkimTool::Resolve;

use XML;
use XML::XPath;
use JSON::Fast;
use YAMLish;

#use Pod::Load;
#use Pod::To::Markdown;
#use Pod::To::MarkDown2;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::Code:auth<github:MARTIMM>;

has Hash $!protected-files;
has Gnome::SourceSkimTool::Resolve $!solve;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {
  # Load list of protected files. These are files which are changed by hand
  # after generating and thus don't want those be reset by an
  # accidental overwrite action.
  my Hash $h = load-yaml((SKIMTOOLROOT ~ 'protected-files.yaml').IO.slurp);

  # Select part of current requested package
  $!protected-files = $h{$*gnome-package.Str} // %();
}

#-------------------------------------------------------------------------------
method set-unit ( XML::Element $element, Bool :$callables = True --> Str ) {

  my Bool $available;
  my Str $also = '';
  
  my Str $unit-header = '';
  my Str $unit-type = '';

  # Try glib:type-name if c:type is missing
  my Str $ctype =
    $element.attribs<c:type> // $element.attribs<glib:type-name> // '';
  my Hash $h = $!solve.search-name($ctype) // %();

note "$?LINE $h<gir-type>";
  # Parenting is only for classes
  my Bool $is-class = False;
  my Bool $is-role = False;
  if $h<gir-type> eq 'class' {
    $is-class = True;
    $unit-type = 'class';

    # Check for parent class. There are never more than one. When there is
    # none, pick TopLevelClassSupport
    my Str $parent = $h<parent-raku-name> // 'Gnome::N::TopLevelClassSupport';

    # Misc is deprecated so shortcut to Widget. This is only for Gtk3!
    $parent = 'Gnome::Gtk3::Widget' if $parent ~~ m/ \:\: Misc $/;
    $available = self.add-import($parent);
    $also ~= ($available ?? '' !! '#') ~ "also is $parent;\n";
  }

  $is-role = (($h<gir-type> // '' ) eq 'interface') // False;
note "$?LINE role $is-role";

  # If the object is a class
  if $is-class {
    # Check for roles to implement
    my Array $roles = $h<implement-roles>//[];
    for @$roles -> $role {
      $available = self.add-import($role);
      $also ~= ($available ?? '' !! '#') ~ "also does $role;\n";
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

  my Str $classname = $!solve.set-object-name( $h, :name-type(ClassnameType));

#`{{
  # Find out if class is deprecated
  my Str $depr-msg = '';
  if ?$h<deprecated> {
    self.add-import('Gnome::N');
    $depr-msg = [~] "\n", 'Gnome::N::deprecate(', "\n",
      "  '$classname', ', Str, ',\n  ", "'", $h<deprecated-version>//'', "'",
      ', Str,', "\n  ", ':class, :gnome-lib(', $*work-data<library>, ')', "\n);\n";
  }
}}

  # Roles
  if $is-role {
    $unit-header ~= pod-header('Role Declaration');
    $unit-type = 'role';
  }

  # Records and unions
  elsif $h<gir-type> ~~ m/ [record | union] / {
    self.add-import('Gnome::N::TopLevelClassSupport');
    $also ~= 'also is Gnome::N::TopLevelClassSupport;' ~ "\n";
    $unit-header ~= pod-header('Structure Declaration');
    $unit-type = 'class';
  }

  # Classes
  else {
    $unit-header ~= pod-header('Class Declaration');
  }

  # Generate import section to be filled in later, and start unit.
  my Str $code = qq:to/RAKUMOD/;

    {pod-header('Module Imports')}
    __MODULE__IMPORTS__

    $unit-header
    unit $unit-type $classname\:auth<github:MARTIMM>:api<2>;
    $also
    RAKUMOD

    #$depr-msg
  $code
}

#-------------------------------------------------------------------------------
# This setup is for types like standalone functions, bitfield, constants and
# enumerations. There is no need for inheritence, BUILD, signals or
# properties.
method set-unit-for-file (
  Str $class-name, Bool $has-functions = False, Bool $has-structs = False
  --> Str
) {

  my Str $code = '';

  if $has-functions or $has-structs {
    $code ~= qq:to/RAKUMOD/;
    {pod-header('Module Imports')}
    __MODULE__IMPORTS__
    RAKUMOD

    self.add-import('Gnome::N::TopLevelClassSupport');
    self.add-import('Gnome::N::GnomeRoutineCaller');
  }

  $code ~= qq:to/RAKUMOD/;
    {pod-header('Class Declaration');}
    unit class $class-name\:auth<github:MARTIMM>:api<2>;
    RAKUMOD

  $code ~= "also is Gnome::N::TopLevelClassSupport;\n" if $has-functions;
#  $code ~= "\n";

  $code
}

#-------------------------------------------------------------------------------
method make-build-submethod (
  XML::Element $element, XML::XPath $xpath --> Str
) {
  my Str $ctype = $element.attribs<c:type>//'';
  my Hash $h = $!solve.search-name($ctype)//%();

  # Find out if class is deprecated
  my Str $depr-msg = '';
  if ?$h<deprecated> {
    my Str $classname = $!solve.set-object-name( $h, :name-type(ClassnameType));
    self.add-import('Gnome::N');
    $depr-msg = [~] "\n  ", 'Gnome::N::deprecate(', "\n    ",
      "'$classname', ', Str, ',\n    ", "'", $h<deprecated-version>//'', "'",
      ', Str,', "\n    ", ':class, :gnome-lib(', $*work-data<library>, ')',
      "  \n  );\n";
  }

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

  # Generate code for signal admin and init of callable helper
  my Str $code = qq:to/EOBUILD/;
    {pod-header('BUILD variables');}
    # Define callable helper
    has Gnome::N::GnomeRoutineCaller \$\!routine-caller;
    $c
    {pod-header('BUILD submethod');}
    submethod BUILD \( *\%options \) \{
    $depr-msg
    $signal-admin
      # Initialize helper
      \$\!routine-caller .= new\(:library\($*work-data<library>\)\);

    EOBUILD

  # >> In older versions, here was the test for inheritance <<
  $code ~= [~] '  # Prevent creating wrong widgets', "\n",
          '  if self.^name eq ', "'$*work-data<raku-class-name>'", ' {', "\n";

  self.add-import('Gnome::N::X');
  $code ~= q:to/EOBUILD/;
        # If already initialized using ':$native-object', ':$build-id', or
        # any '.new*()' constructor, the object is valid.
        note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;
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
method generate-callables (
  XML::Element $element, XML::XPath $xpath, Bool :$is-interface = False
  --> Str
) {

  my Str $code = '';
  my Str $c;

  my Hash $hcs =
    self.get-native-subs( $element, $xpath, :routine-type<constructor>);
  # Generate constructors
  $code ~= self!generate-constructors($hcs) if ?$hcs;
  note "Generate constructors" if $*verbose and ?$code;

  # Get all methods in this class
  $hcs = self.get-native-subs( $element, $xpath, :routine-type<method>);
  if ?$hcs {
    # Generate methods
    $c = self!generate-methods($hcs);
    $code ~= $c if ?$c;
    note "Generate methods" if $*verbose and ?$c;
  }

  # Get all functions in this class
  $hcs = self.get-native-subs( $element, $xpath, :routine-type<function>);
  if ?$hcs {
    # Generate functions
    $code ~= self.generate-functions($hcs);
    note "Generate functions" if $*verbose and ?$c;
  }

  # if there are constructors, methods or functions, add the structure and
  # the fallback routine
  if ?$code {
    $c = qq:to/RAKUMOD/;

      {pod-header('Native Routine Definitions');}
      my Hash \$methods = \%\(
      $code);

      {HLSEPARATOR}
      RAKUMOD

    # For interfaces/roles, there is another fallback api called from class
    if $is-interface {
      my Hash $role-h = $!solve.search-name($*work-data<gnome-name>);
      $c ~= qq:to/RAKUMOD/;
        # This method is recognized in class Gnome::N::TopLevelClassSupport.
        method _do_$role-h<symbol-prefix>fallback-v2 \(
          Str \$name, Bool \$_fallback-v2-ok is rw,
          Gnome\:\:N\:\:GnomeRoutineCaller \$routine-caller, \@arguments, \$native-object
        ) \{
          if \$methods\{\$name}:exists \{
            \$_fallback-v2-ok = True;
            return \$routine-caller.call-native-sub\(
              \$name, \@arguments, \$methods, \$native-object
            );
          }
        }
        RAKUMOD
    }

    else {
      $c ~= q:to/RAKUMOD/;
        # This method is recognized in class Gnome::N::TopLevelClassSupport.
        method _fallback-v2 (
          Str $name, Bool $_fallback-v2-ok is rw, *@arguments, *%options
        ) {
          if $methods{$name}:exists {
            $_fallback-v2-ok = True;
            if $methods{$name}<type>:exists and $methods{$name}<type> eq 'Constructor' {
        RAKUMOD

      $c ~= qq:to/RAKUMOD/;
              my Gnome::N::GnomeRoutineCaller \$routine-caller .= new\(
                :library\($*work-data<library>\)
              \);

        RAKUMOD

      $c ~= q:to/RAKUMOD/;
              return self.bless(
                :native-object(
                  $routine-caller.call-native-sub( $name, @arguments, $methods)
                ),
                |%options
              );
            }

            elsif $methods{$name}<type>:exists and $methods{$name}<type> eq 'Function' {
              return $!routine-caller.call-native-sub( $name, @arguments, $methods);
            }

            else {
              my $native-object = self.get-native-object-no-reffing;
              return $!routine-caller.call-native-sub(
                $name, @arguments, $methods, $native-object
              );
            }
          }

          else {
        RAKUMOD

      # When there are roles implemented, generate calls to the role's fallback
      my Str $ctype = $element.attribs<c:type>//'';
      my Hash $h = $!solve.search-name($ctype)//%();
      my Array $roles = $h<implement-roles>//[];
      if ?$roles {
        $c ~= [~] '    my $r;', "\n",
              '    my $native-object = self.get-native-object-no-reffing;',
              "\n";

        for @$roles -> $role {
          my Bool $available = self.add-import($role);
          $c ~= "#`\{\{\n" unless $available;

          my Hash $role-h = $!solve.search-name($role);
          my Str $cb-name = "_do_$role-h<symbol-prefix>fallback-v2";
          $c ~= qq:to/RAKUMOD/;
                \$r = self.$cb-name\(
                  \$name, \$_fallback-v2-ok, \$!routine-caller, \@arguments, \$native-object
                \) if self.^can\('$cb-name');
                return \$r if \$_fallback-v2-ok;

            RAKUMOD
          $c ~= "\}\}\n" unless $available;
        }
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
method get-role-signals ( Hash $h --> Str ) {

  # See which roles to implement
  my Str $role-signals = '';
  my Array $roles = $h<implement-roles> // [];
  for @$roles -> $role {
    once $role-signals = "\n    # Signals from interfaces\n";

    my Bool $available = self.add-import($role);

    my Hash $role-h = $!solve.search-name($role);
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
method !generate-constructors ( Hash $hcs --> Str ) {

#  my Str $sub-prefix = $*work-data<sub-prefix>;
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
      $par-list ~= ", $rnt0";
    }

    # Remove first comma
    $par-list ~~ s/^ . //;
    my Str $parameters = ?$par-list ?? ":parameters\(\[$par-list\]\), " !! '';

    # Save as a user recognizable name. This makes it possible
    # to postpone the translation as late as possible at run time
    # and only once per function.
    #$function-name ~~ s:g/ '_' /-/;
    
    # Set the full native subroutine name
    my Str $sub-prefix = $*work-data<sub-prefix>;
    my Str $is-symbol = $sub-prefix ~ $function-name;
    $is-symbol ~~ s:g/ '-' /_/;
    $is-symbol = ':is-symbol<' ~ $is-symbol ~ '>, ';

    # Change the name of 'new' into 'new-<classname.lc>'. E.g. new-button.
    if $function-name eq 'new' {
      my Str $name-prefix = $*work-data<name-prefix>;
      my Str $gname = $*work-data<gnome-name>;
      $gname ~~ s:i/^ $name-prefix //;
      $function-name ~= '-' ~ $gname.lc;
    }

    # Add deprecation parameters
    my Str $dep-str = '';
    if $curr-function<deprecated> {
      $dep-str = [~] ':deprecated', ', :deprecated-version<',
                     $curr-function<deprecated-version>, '>, ';
    }

    my $xtype = $curr-function<return-raku-type>;
    $code ~= [~] '  ', $temp-inhibit, $function-name,
                ' => %( :type(Constructor), ', $is-symbol,
                ':returns(', $xtype, '), ', $dep-str,
                $variable-list, $parameters, "),\n";

    # drop last comma from arg list
    $code ~~ s/ '),)' /))/;
  }

  $code
}

#-------------------------------------------------------------------------------
method get-native-subs (
  XML::Element $element, XML::XPath $xpath,
  Bool :$user-side = False, Str :$routine-type = 'method'
  --> Hash
) {
  my Hash $hms = %();
  my @subs = $xpath.find( $routine-type, :start($element), :to-list);

  for @subs -> $native-sub {
    my ( $function-name, %h) =
      self!get-method-data( $native-sub, :$xpath, :$user-side);

    # Function names which are returned emptied, are assumably internal
    next unless ?$function-name and ?%h;

    # Add to hash with functionname as its
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
#  my Hash $h = $!solve.search-name($ctype);
#  my Str $symbol-prefix = $h<symbol-prefix> // $h<c:symbol-prefix> // '';
#  my Str $symbol-prefix = $*work-data<sub-prefix>;
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

    #$pattern = $curr-function<variable-list> ?? ':pattern([' !! '';
    $variable-list = $curr-function<variable-list> ?? ':variable-list, ' !! '';

    # get method name, drop the prefix
#    my Str $hash-fname = $function-name;
#    $hash-fname ~~ s/^ $symbol-prefix //;

    # Save as a user recognizable name. This makes it possible
    # to postpone the translation as late as possible at run time
    # and only once per function.
    #$function-name ~~ s:g/ '_' /-/;

    # get parameter lists
    my Str $par-list = '';
    my Bool $first-param = True;

    for @($curr-function<parameters>) -> $parameter {
      last if $parameter<raku-type> eq '…';

      # Get a list of types for the arguments but skip the first native type
      # This is the instance variable which is inserted automatically in the
      # fallback routines.
      if $first-param {
        $first-param = False;
      }

      else {
        my Str $xtype = $parameter<raku-type>;

        if $xtype ~~ m/ ':' / and $xtype !~~ m/ '::' / {
          # Signatures have a colon at the first char followed by '('
          if $xtype ~~ m/^ ':(' / {
            $par-list ~= ", $xtype";
          }

          else {
            # Enumerations and bitfields are returned as GEnum:Name and GFlag:Name
            # Here we only need the type.
            my ( $rnt0, $rnt1) = $xtype.split(':');
            $par-list ~= ", $rnt0";
          }
        }

        else {
          $par-list ~= ", $xtype";
        }
      }
    }

    # Remove first comma and space
    $par-list ~~ s/^ .. //;
    $par-list = ?$par-list ?? [~] ':parameters([', $par-list, ']), ' !! '';

    # Return type
    my $xtype = $curr-function<return-raku-type>;
    my Str $returns = '';

    if $xtype ~~ m/ ':' / and $xtype !~~ m/ '::' / {
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
    }

    elsif ?$xtype {
      $returns = ":returns\($xtype), " unless $xtype eq 'void';
    }

    # Set the full native subroutine name
    my Str $sub-prefix = $*work-data<sub-prefix>;
    my Str $is-symbol = $sub-prefix ~ $function-name;
    $is-symbol ~~ s:g/ '-' /_/;
    $is-symbol = ':is-symbol<' ~ $is-symbol ~ '>, ';

    # Add deprecation parameters
    my Str $dep-str = '';
    if $curr-function<deprecated> {
      $dep-str = [~] ':deprecated', ', :deprecated-version<',
                     $curr-function<deprecated-version>, '>, ';
    }

    # Sometimes names of function have a digit after the underscore. Examples
    # are found in Gsk4 'gtk_snapshot_rotate_3d'. It is translated into
    # 'rotate-3d' which is not a legal Raku function name. So, need an extra
    # convertion here.
    $function-name ~~ s:g/ '-' (\d) /$0/ if $function-name ~~ m/ '-' \d /;

    $code ~= [~] '  ', $temp-inhibit, $function-name, ' => %(', $is-symbol,
             $variable-list, $returns, $cnv-return, $par-list, $dep-str, "),\n";

    # drop last comma from arg list
    $code ~~ s/ '),)' /))/;
  }

  $code
}

#-------------------------------------------------------------------------------
method generate-functions ( Hash $hcs, Bool :$standalone = False --> Str ) {

  return '' unless ?$hcs;

#  my Str $symbol-prefix = $*work-data<sub-prefix>;
#  my Str $pattern = '';
  my Str $temp-inhibit = '';
  my Str $variable-list = '';

  # Get all functions from the Hash
  my Str $code = qq:to/EOSUB/;

    {SEPARATOR( 'Functions', 2);}
    EOSUB

  for $hcs.keys.sort -> $function-name {
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
    #$function-name ~~ s:g/ '_' /-/;

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
#      self.get-types(
#        $parameter, #$raku-list, 
#        $call-list, #$items-doc,
#        @rv-list #, $returns-doc
#      );
      last if $parameter<raku-type> eq '…';

      my Str $xtype = $parameter<raku-type>;
#note "$?LINE $xtype";
      if $xtype ~~ m/ ':' / and $xtype !~~ m/ '::' /  {
        # Test for callback routine spec
        if $xtype ~~ m/^ ':(' / {
          $par-list ~= ", $xtype";
        }

        # Test for single colon
        elsif $xtype ~~ m/ ':' / {
          # Enumerations and bitfields are returned as GEnum:Name and GFlag:Name
          my ( $rnt0, $rnt1) = $parameter<raku-type>.split(':');
          if $rnt0 eq 'GEnum' {
            $par-list ~= ", $rnt1";
          }

          else { # ≡ GFlag
            $par-list = ', UInt';
          }
        }
      }

      else {
        $par-list ~= ", $xtype";
      }
    }

    # Remove first comma and space when there is only one parameter
    $par-list ~~ s/^ . //;
    $par-list ~~ s/^ . // unless $par-list ~~ m/ \, /;
    $par-list = ?$par-list
              ?? [~] ':parameters([', $par-list, ']), '
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
      $returns = ":returns\($rnt0\), ";
      $cnv-return = ":cnv-return\($rnt1\), ";
    }

    elsif ?$rnt0 and $xtype ne 'void' {
      $returns = ":returns\($rnt0\), ";
      if $xtype eq 'gboolean' {
        $cnv-return = ':cnv-return(Bool), ';
      }
    }

#note "$?LINE $function-name, {$returns//'-'}, {$par-list//'-'}";
    
    # Set the full native subroutine name
    my Str $sub-prefix = $standalone ?? "$*work-data<name-prefix>_"
                                     !! $*work-data<sub-prefix>;
    my Str $is-symbol = $sub-prefix ~ $function-name;
    $is-symbol ~~ s:g/ '-' /_/;
    $is-symbol = ':is-symbol<' ~ $is-symbol ~ '>, ';

    # Add deprecation parameters
    my Str $dep-str = '';
    if $curr-function<deprecated> {
      $dep-str = [~] ':deprecated', ', :deprecated-version<',
                     $curr-function<deprecated-version>, '>, ';
    }
    $code ~= [~] '  ', $temp-inhibit, $function-name,
             ' => %( :type(Function), ', $is-symbol, $variable-list, $returns,
             $par-list, $dep-str, "),\n";

    # drop last comma from arg list
    $code ~~ s/ '),)' /))/;
  }

  $code
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

    # Skip empty elements deprecated functions
    next unless ?$element;

    @methods.push: $element
  }

  for @methods -> $cn {
    my ( $function-name, %h) = self!get-method-data( $cn, :$xpath, :$user-side);

    # Function names which are returned emptied, are assumably internal
    next unless ?$function-name and ?%h;

    # Add to hash with functionname as its
    $hms{$function-name} = %h;
  }

  $hms
}

#-------------------------------------------------------------------------------
# Get a callback function pattern. This is used as a type in function arguments
# and other places
method !get-callback-function ( Hash $callback-data --> Hash ) {
  my Str $function-name = $callback-data<callback-name>;
  my Str $file = self.get-repo-data-path($callback-data<class-name>) ~
                 'repo-callback.gir';
  my XML::XPath $xpath .= new(:$file);

  my XML::Element $element =
    $xpath.find( '//callback[@name="' ~ $function-name ~ '"]', :!to-list);

  # Skip empty elements deprecated functions
  return %() unless ?$element;

  self!get-callback-data( $element, :$xpath)
}
 
#-------------------------------------------------------------------------------
method get-repo-data-path ( Str $class-name --> Str ) {
  my Str $path = SKIMTOOLDATA;
  given $class-name {
    when m/ Gtk4 / {
      $path ~= 'Gtk4/';
    }

    when m/ Gsk4 / {
      $path ~= 'Gsk4/';
    }

    when m/ Gdk4 / {
      $path ~= 'Gdk4/';
    }

    when m/ Gio / {
      $path ~= 'Gio/';
    }

    when m/ Glib / {
      $path ~= 'Glib/';
    }

    when m/ GObject / {
      $path ~= 'GObject/';
    }
  }

  $path
}

#-------------------------------------------------------------------------------
method generate-callback ( Hash $cb-data --> Str ) {
  return '' unless ?$cb-data;

  my Bool $available = True;
  my Str $par-list = '';
  for @($cb-data<parameters>) -> $parameter {
    my Str $xtype = $parameter<raku-type>;
    my Str $parameter-name = $parameter<name>;
    if $xtype ~~ m/ ':' / and $xtype !~~ m/ '::' / {
      my ( $rnt0, $rnt1) = $xtype.split(':');
      if $rnt0 ~~ / _UA_ $/ {
        $available = False;
        $rnt0 ~~ s/ _UA_ $//;
      }
      $parameter-name ~~ s/ '-' $//;
      $par-list ~= ", $rnt0 \$$parameter-name";
    }

    else {
      $par-list ~= ", $xtype \$$parameter-name";
    }
  }

  # Remove first comma and space when there is only one parameter
  $par-list ~~ s/^ . //;

  my Str $returns = '';
  my Str $xtype = $cb-data<return-raku-type>;
  if $xtype ~~ m/ ':' / and $xtype !~~ m/ '::' / {
    my ( $rnt0, $rnt1) = $xtype.split(':');
    if ?$rnt0 and $rnt0 ne 'void' {
      if $rnt0 ~~ / _UA_ $/ {
        $available = False;
        $rnt0 ~~ s/ _UA_ $//;
      }
      $returns = $rnt0;
    }

    else {
      $par-list ~= ", $xtype";
    }
  }

#  my $code = [~] $cb-data<function-name>, '=:(', $par-list, ?$returns ?? " --> $returns \)" !! ' )';
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
  my Str $package = $*gnome-package.Str;
  for $enum-names.sort -> $enum-name {
#    my Str $name = $enum-name;

    # Must have a name to search using the @name attribute on an element
#    my Str $prefix = $*work-data<name-prefix>.tc;
#    my Str $name = $enum-name;
#    $name ~~ s/^ $prefix //;

##`{{
    if $package ~~ / Glib || GObject || Gio / {
      $package = 'G';
    }
    
    elsif $package ~~ / GdkPixbuf / {
      $package = 'Gdk';
    }

    else {
      $package ~~ s/ \d+ $//;
    }

    my Str $name = $enum-name;
    $name ~~ s/^ $package //;
#}}
#note "$?LINE $package, $enum-name, $name";

    # Get the XML element of the enum data
    my XML::Element $e = $xpath.find(
      '//enumeration[@name="' ~ $name ~ '"]', :!to-list
    );

    $code ~= qq:to/EOENUM/;
      enum $enum-name is export \<
      EOENUM

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
  my Str $package = $*gnome-package.Str;
  for $bitfield-names.sort -> $bitfield-name {
    my Str $package = $*gnome-package.Str;
    if $package ~~ / Glib || GObject || Gio / {
      $package = 'G';
    }
    
    elsif $package ~~ / GdkPixbuf / {
      $package = 'Gdk';
    }

    else {
      $package ~~ s/ \d+ $//;
    }

    my Str $name = $bitfield-name;
    $name ~~ s/^ $package //;
#}}
#note "$?LINE $package, $bitfield-name, $name";

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
  --> Str
) {
#`{{
  my $temp-external-modules = $*external-modules;
  $*external-modules = %(
    :NativeCall(EMTRakudo), 'Gnome::N::NativeLib' => EMTInApi2,
    'Gnome::N::N-Object' => EMTInApi2,
    'Gnome::N::GlibToRakuTypes' => EMTInApi2,
  );
}}

  my Str $name = $*work-data<gnome-name>;
  my Hash $h0 = $!solve.search-name($name);
  my Str $class-name = $!solve.set-object-name( $h0, :name-type(ClassnameType));
  self.add-import($class-name);
  my Str $record-class = $h0<record-class>;

#`{{
  my Str $code = qq:to/RAKUMOD/;
    # Command to generate: $*command-line
    use v6.d;
    RAKUMOD
}}

  my $code = '';

  my @fields = $xpath.find( 'field', :start($element), :to-list);
  if ?@fields {
    my Str ( $tweak-pars, $build-pars, $tweak-ass, $build-ass) = '' xx 4;

#`{{
    $code ~= qq:to/EOREC/;

      {pod-header('Module Imports')}
      __MODULE__IMPORTS__
      EOREC
}}

    $code ~= qq:to/EOREC/;

      class $record-class\:auth<github:MARTIMM>\:api<2> is export is repr\('CStruct') \{

      EOREC

    for @fields -> $field {
      my $field-name = self.cleanup-id($field.attribs<name>);
      my Str ( $type, $raku-type) = self.get-type( $field, :$user-side);

      if ?$type {
        # Enumerations and bitfields are returned as GEnum:Name and GFlag:Name
        my Str ( $rnt0, $rnt1) = $raku-type.split(':');
        if ?$rnt1 {
          $code ~= "  has $rnt0 \$.$field-name;           # $rnt1\n";
        }

        #NOTE raku cannot handle this in native structures.
        # Must become a pointer
        elsif $rnt0 ~~ m/ Callable / {
          $code ~= "  has gpointer \$.$field-name;\n";
        }

        else {
          $code ~= "  has $rnt0 \$.$field-name;\n";
        }

        if $raku-type eq 'N-Object' {
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

#`{{
TODO can we have callback fields in a structure?
      # no type found, is it a callback spec?
      else {
        my XML::Element $cb-element =
          $xpath.find( 'callback', :start($field), :!to-list);
        if ?$cb-element {
          my %h = self!get-callback-data( $cb-element, :$xpath);
          my Str $c = self.generate-callback(%h);
          $code ~= "has $c \$.$field-name;\n";

          $code ~= "  has gpointer \$.$field-name;\n";
          $build-pars ~= "gpointer :\$\!$field-name, ";
        }
      }
}}
      else {
        $code ~= "  has \$.$field-name;\n";
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
    \}

    EOREC

    self.add-import('Gnome::N::X');
#    $code = self.substitute-MODULE-IMPORTS( $code, $class-name, $class-name);
  }

  else {
    # Generate structure as a pointer when no fields are documented
    $code ~= qq:to/EOREC/;
      # This is an opaque type of which fields are not available.
      class $record-class\:auth<github:MARTIMM>\:api<2> is export is repr\('CPointer') \{ \}

      EOREC
  }

#`{{
  # Reset to original and add this structure
  $*external-modules = $temp-external-modules;
  self.add-import($class-name);
}}
#`{{
  my Str $fname = [~] $*work-data<result-mods>, '/',
                      $!solve.set-object-name( $h0, :name-type(FilenameType)),
                      '.rakumod';
#     [~] $*work-data<result-mods>, '/', $h0<record-class>, '.rakumod';
  self.save-file( $fname, $code, "record structure");
}}

  $code
}

#-------------------------------------------------------------------------------
method generate-union (
  XML::XPath $xpath, XML::Element $element, Bool :$user-side = False
) {

  my $temp-external-modules = $*external-modules;
  $*external-modules = %(
    :NativeCall(EMTRakudo), 'Gnome::N::NativeLib' => EMTInApi2,
    'Gnome::N::N-Object' => EMTInApi2,
    'Gnome::N::GlibToRakuTypes' => EMTInApi2,
  );

  my Str $name = $*work-data<gnome-name>;
  my Hash $h0 = $!solve.search-name($name);
#  my Str $class-name = $h0<class-name>;
  my Str $class-name = $!solve.set-object-name( $h0, :name-type(ClassnameType));
  my Str $union-class = $h0<union-class>;

  my Str $code = qq:to/RAKUMOD/;
    $*command-line
    use v6.d;

    RAKUMOD

  my @fields = $xpath.find( 'field', :start($element), :to-list);
  if ?@fields {
    my Str ( $tweak-pars, $build-pars, $tweak-ass, $build-ass) = '' xx 4;

    $code ~= qq:to/EOREC/;

      {pod-header('Module Imports')}
      __MODULE__IMPORTS__

      unit class $union-class\:auth<github:MARTIMM>\:api<2> is export is repr\('CUnion');

      EOREC

    for @fields -> $field {
      my $field-name = self.cleanup-id($field.attribs<name>);
      my Str ( $type, $raku-type, $raku-rtype) =
        self.get-type( $field, :$user-side);

      #$field-name ~~ s:g/ '_' /-/;
      if ?$type {
        # Enumerations and bitfields are returned as GEnum:Name and GFlag:Name
        my Str ( $rnt0, $rnt1) = $raku-type.split(':');
        if ?$rnt1 {
          $code ~= "HAS $rnt0 \$.$field-name;           # $rnt1\n";
        }

        else {
          $code ~= "HAS $rnt0 \$.$field-name;\n";
        }

        if $raku-type eq 'N-Object' {
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
      {pod-header('Union Structure')}
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

  my Str $fname = [~] $*work-data<result-mods>, '/',
                      $!solve.set-object-name( $h0, :name-type(FilenameType)),
                      '.rakumod';
#     [~] $*work-data<result-mods>, '/', $h0<union-class>, '.rakumod';
  self.save-file( $fname, $code, "union structure");
}

#-------------------------------------------------------------------------------
method signals ( XML::Element $element, XML::XPath $xpath --> Hash ) {

  my Hash $signals = %();

  my @signal-info = $xpath.find( 'glib:signal', :start($element), :to-list);
  for @signal-info -> $si {
    my Hash $attribs = $si.attribs;
    #next if $attribs<deprecated>:exists and  $attribs<deprecated> == 1;

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
#  my Hash $h = $!solve.search-name($ctype);

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
#    {pod-header('Native Routine Definitions');}
#    my Hash \$methods = \%\(
#    RAKUMOD

  $code
}

#-------------------------------------------------------------------------------
method cleanup-id ( $id is copy, Bool :$is-function = False --> Str ) {
 
  if $is-function {
    # Skip function names ending in '_'. Assumed that those are for internal use
    return '' if $id ~~ m/ '_' $/;

    # Remove package prefix from function name
    my Str $sub-prefix = $*work-data<sub-prefix>;
    $id ~~ s/^ $sub-prefix //;
  }

  # Drop the last underscore of variable if there is one, it's ugly 😎.
  $id ~~ s/ '_' $//;

  # Cleanup the name, convert _ to - and ending numbers in words
  $id ~~ s:g/ '_' /-/;
#  $id ~~ s/ '-' (\d+) $/-{cnv-to-word($0)}/;
  $id ~~ s/ '-' (\d+) $/$0/;
  $id ~~ s/ '...' /…/;

  $id
}

#`{{
#-------------------------------------------------------------------------------
# simple converter to convert last digit of function name into a word.
# It is never a big number (assumably)
sub cnv-to-word ( $i --> Str ) {
  <zero one two three>[$i.Int]
}
}}

#-------------------------------------------------------------------------------
method add-import ( Str $import --> Bool ) {
  my Bool $available = False;

#note "\n$?LINE $import";
#note Backtrace.new.nice if $import ~~ m:i/layout/;

#if $import eq 'Gnome::GObject::N-GValue::N-GValue' {
#  say Backtrace.new.nice;
#  exit;
#}

  # Add only when $import is not in the hash.
  if $*external-modules{$import}:exists {
#note "\n$?LINE $*external-modules{$import}";
    $available = True unless $*external-modules{$import} == EMTNotImplemented;
  }

  else {
#note "\n$?LINE $*external-modules{$import}";
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
method substitute-MODULE-IMPORTS (
  Str $code is copy, *@exclasses, Bool :$skip-n-mods = False
  --> Str
) {
  note "Set modules to import" if $*verbose;

  # any() does not support slurpy args
  my @exceptclasses := @exclasses;

  my $import = '';
  for $*external-modules.kv -> $m, $s {
    next if $skip-n-mods and $m !~~ m/ '::N-Object' / and $m ~~ m/ '::N-' /;
    $import ~= "use $m;\n" if $s ~~ EMTRakudo;
  }

  $import ~= "\n";

  # External module dependencies
  for $*external-modules.kv -> $m, $s {
    $import ~= "use $m;\n" if $s ~~ EMTExtDep;
  }

  $import ~= "\n";

  for $*external-modules.kv -> $m, $s {
    next if $skip-n-mods and $m !~~ m/ '::N-Object' / and $m ~~ m/ '::N-' /;
    $import ~= "use $m;\n" if $s ~~ EMTInApi1;
  }

  $import ~= "\n";

#note "\n$?LINE ex: $*external-modules.join(', ')";
  for $*external-modules.keys.sort -> $m {
#note " $?LINE use $m, $*external-modules{$m}";
    next if $skip-n-mods and $m !~~ m/ '::N-Object' / and $m ~~ m/ '::N-' /;

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
  my XML::Element $element = $xpath.find("//namespace/$element-name");
  die "//$element-name elements not found in $gir-filename for $*work-data<raku-class-name>" unless ?$element;

  ( $xpath, $element )
}

#-------------------------------------------------------------------------------
method !get-method-data (
  XML::Element $e, XML::XPath :$xpath, Bool :$user-side = False --> List
) {
  # Get function name. Sometimes it ends in '-1' which is not a raku id.
  # This must be converted.
  my Str $function-name = self.cleanup-id( $e.attribs<name>, :is-function);

  # Skip emptied function names. Assumed that those are for internal use.
  return ( '', %()) unless ?$function-name;

  my Bool $missing-type = False;

#note "\n$?LINE $function-name";
  my XML::Element $rvalue = $xpath.find( 'return-value', :start($e));
  #my Str $rv-transfer-ownership = $rvalue.attribs<transfer-ownership>;
#  my Str ( $rv-type, $return-raku-type, $return-raku-rtype) =
  my Str ( $rv-type, $return-raku-type) = self.get-type( $rvalue, :$user-side);
  $missing-type = True if !$return-raku-type or $return-raku-type ~~ /_UA_ $/;
  $return-raku-type ~~ s/ _UA_ $//;
#note "$?LINE rv: $return-raku-type, $missing-type";

  # Get all parameters. Mostly the instance parameters come first
  # but I am not certain.
  my @parameters = ();
  my @prmtrs = $xpath.find(
    'parameters/instance-parameter | parameters/parameter',
    :start($e), :to-list
  );

  my Bool $variable-list = False;
  for @prmtrs -> $p {
#    my Str ( $type, $raku-type, $raku-rtype) = self.get-type( $p, :$user-side);
    my Str ( $type, $raku-type) = self.get-type( $p, :$user-side);
    $missing-type = True if !$raku-type or $raku-type ~~ /_UA_ $/;
    $raku-type ~~ s/ _UA_ $//;
#note "$?LINE p: $raku-type, $missing-type";
    my Hash $attribs = $p.attribs;
    my Str $parameter-name = self.cleanup-id($attribs<name>);

    # When '…', there will be no type for that parameter. It means that
    # a variable argument list is used ending in a Nil.
    if $parameter-name eq '…' {
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

  # It is possible that there is a 'throws' option which, when 1, needs
  # an extra argument to store an error object.
  if $e.attribs<throws>:exists and $e.attribs<throws> eq '1' {
    self.add-import('Gnome::Glib::T-error');
    @parameters.push: %(
      :name<err>, :type<CArray[N-Error]>, :raku-type<CArray[N-Error]>,
    );
  }

#note "  $?LINE $function-name, miss types: $missing-type";

  my Bool $deprecated = ?$e.attribs<deprecated>;
  my Str $deprecated-version =
    $deprecated ?? $e.attribs<deprecated-version> !! '';

  ( $function-name, %(
      :@parameters, :$variable-list, :$rv-type, :$return-raku-type,
      :$missing-type, :$deprecated, :$deprecated-version,
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
  my Str ( $rv-type, $return-raku-type) = self.get-type( $rvalue, :$user-side);

  # Get all parameters. Mostly the instance parameters come first
  # but I am not certain.
  my @parameters = ();
  my @prmtrs = $xpath.find(
    'parameters/instance-parameter | parameters/parameter',
    :start($e), :to-list
  );

#  my Bool $variable-list = False;
  for @prmtrs -> $p {
    my Str ( $type, $raku-type) = self.get-type( $p, :$user-side);
    my Hash $attribs = $p.attribs;
    my Str $parameter-name = self.cleanup-id($attribs<name>);

#`{{
    # When '…', there will be no type for that parameter. It means that
    # a variable argument list is used ending in a Nil.
    if $parameter-name eq '…' {
      $type = $raku-type = '…';
      $variable-list = True;
    }
}}
    my Hash $ph = %( :name($parameter-name), :$type, :$raku-type);

    $ph<allow-none> = $attribs<allow-none>.Bool;
    $ph<nullable> = $attribs<nullable>.Bool;
    $ph<is-instance> = False;

    @parameters.push: $ph;
  }

#  %( :@parameters, :$variable-list, :$rv-type, :$return-raku-type )
  %( :@parameters, :$rv-type, :$return-raku-type )
}

#-------------------------------------------------------------------------------
method get-type ( XML::Element $e, Bool :$user-side = False --> List ) {

  # With variable argument lists, the name is '…'. It would not have a type
  # so return something to prevent it marked as a missing type
  return ('…', '…')
    if $e.attribs<name>:exists and $e.attribs<name> eq '...';
#note "$?LINE {$e.attribs<name> // '-'}";

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
        # Sometimes there is no 'c:type', assume an array of strings because
        # that once has happened in the XML description
        $ctype = $n.attribs<c:type> // 'gchar**';
        $raku-type = $user-side
                   ?? self.convert-rtype($ctype)
                   !! self.convert-ntype($ctype)
                   ;
      }
    }
  }
#note "$?LINE {$e.attribs()<name> // '-'}, $user-side, $ctype, $raku-type";
#note Backtrace.new.nice if $ctype ~~ m:i/pango/;

  ( $ctype, $raku-type)
}

#-------------------------------------------------------------------------------
method convert-ntype (
  Str $ctype is copy --> Str
#  Str $ctype is copy, Bool :$return-type = False --> Str
) {
  return '' unless ?$ctype;
#note "\n$?LINE convert-ntype ctype: $ctype" if $ctype ~~ m:i/ cairo /;

  # ignore const and spaces
  my Str $orig-ctype = $ctype;
  $ctype ~~ s:g/ const //;
  $ctype ~~ s:g/ volatile //;
  $ctype ~~ s:g/ \s+ //;

  my Str $raku-type = '';
  with $ctype {

    # Make packages depending on Cairo of Timo
    when / 'cairo_content_t' / {
      $raku-type = "GEnum:Content"; #'UInt';
      self.add-import('Cairo');
    }

    when / cairo [ '_' <alnum>+ ]? '_t' '*' / {
      $ctype ~~ s:g/ '*' //;
      $raku-type = "Cairo::$ctype";
      self.add-import('Cairo');
    }

    # ignore const
    when /g? char '**'/       { $raku-type = 'gchar-pptr'; }
    when /g? char '*'/        { $raku-type = 'Str'; }
    when /g? int '*'/         { $raku-type = 'gint-ptr'; }
    when /g? uint '*'/        { $raku-type = 'guint-ptr'; }
    when /g? uint16 '*'/      { $raku-type = 'CArray[uint16]'; }
    when /g? uint32 '*'/      { $raku-type = 'CArray[uint32]'; }
    when /g? uint64 '*'/      { $raku-type = 'CArray[uint64]'; }
    when /g? size '*'/        { $raku-type = 'CArray[gsize]'; }
    when /g? float '*'/       { $raku-type = 'CArray[gfloat]'; }
    when /g? double '*'/      { $raku-type = 'CArray[gdouble]'; }
    when /g? pointer '*'/     { $raku-type = 'CArray[gpointer]'; }
    when /:i g? object '*'/   { $raku-type = 'N-Object'; }
#    when /:i g? pixbuf '*'/   { $raku-type = 'N-Object'; }
#    when /:i g? error '*'/    { $raku-type = 'N-Object'; }
    when /:i g? quark /       { $raku-type = 'GQuark'; }

    # Graphene
    when / _Bool /            { $raku-type = 'gboolean'; }

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

      my Hash $h = $!solve.search-name($ctype);
#note "  $?LINE $is-pointer, $ctype, $h<gir-type>" if $ctype ~~ m:i/ cairo /;
      given $h<gir-type> // '-' {
        when 'class' {
          $raku-type = 'N-Object';
          $raku-type = "CArray[$raku-type]" if $is-pointer;
        }

        when 'interface' {
          $raku-type = 'N-Object';
          $raku-type = "CArray[$raku-type]" if $is-pointer;
        }

        when 'record' {
#note "  $?LINE record $orig-ctype $h.gist()";
#          $raku-type = $h<record-class>;
#          $raku-type = "CArray[$raku-type]" if $is-pointer;
          $raku-type = 'N-Object';
          self.add-import('Gnome::N::N-Object');

          my Str $class-name =
            $!solve.set-object-name( $h, :name-type(ClassnameType));
          self.add-import($class-name);

          # Record modules have their structs in type files
          my Str $type-name = $class-name;
          $type-name ~~ s/ '::N-' .* $/::T-$h<source-filename>/;
          self.add-import($type-name);
        }

        when 'union' {
#NOTE changed somewhere? add-import creates cyclic dependency -> make it an Object;
#          $raku-type = "N-$h<gnome-name>";
#          self.add-import($h<class-name>);
#          $raku-type = $h<record-class>;
#          $raku-type = "CArray[$raku-type]" if $is-pointer;
          $raku-type = 'N-Object';
          self.add-import('Gnome::N::N-Object');

          my $class-name =
            $!solve.set-object-name( $h, :name-type(ClassnameType));
          self.add-import($class-name);

          # Union modules have their structs in type files
          my Str $type-name = $class-name;
          $type-name ~~ s/ '::N-' /::T-/;
          self.add-import($type-name);
        }

        when 'constant' {
          $raku-type = "$ctype";
          $raku-type = "CArray[$raku-type]" if $is-pointer;
        }

        when 'enumeration' {
          $raku-type = "GEnum:$ctype";
          my $class-name =
            $!solve.set-object-name( $h, :name-type(ClassnameType));
          $raku-type ~= ' _UA_' unless self.add-import($class-name);
        }

        when 'bitfield' {
          $raku-type = "GFlag:$ctype";
          my $class-name =
            $!solve.set-object-name( $h, :name-type(ClassnameType));
          $raku-type ~= ' _UA_' unless self.add-import($class-name);
        }

#        when 'alias' { $raku-type = $h<class-name>; }
        when 'alias' { }

        when 'callback' {
          my %cb = self!get-callback-function($h);
          $raku-type = self.generate-callback(%cb);
        }

        default {
          note "Unknown ctype to convert: $orig-ctype";
        }
      }
    }
  }

#note "\n$?LINE convert $ctype --> $raku-type";
#note "\n$?LINE $ctype, $raku-type" if $ctype ~~ m:i/ cairo /;
  $raku-type
}

#-------------------------------------------------------------------------------
method convert-rtype (
  Str $ctype is copy, Bool :$return-type = False --> Str
) {
  return '' unless ?$ctype;
#note "$?LINE convert-rtype $ctype";
#note "\n$?LINE convert-rtype ctype: $ctype" if $ctype ~~ m:i/ cairo /;

  # ignore const and spaces
  my Str $orig-ctype = $ctype;
  $ctype ~~ s:g/ const //;
  $ctype ~~ s:g/ volatile //;
  $ctype ~~ s:g/ \s+ //;

  my Str $raku-type = '';
  with $ctype {

    # Make packages depending on Cairo of Timo
    when / 'cairo_content_t' / {
      $raku-type = "GEnum:Content";
      self.add-import('Cairo');
    }

    when / cairo [ '_' <alnum>+ ]? '_t' '*' / {
      $ctype ~~ s:g/ '*' //;
      $raku-type = "Cairo::$ctype";
      self.add-import('Cairo');
    }

#TODO int/num/pointers as '$x is rw'
    when /g? char '**'/         { $raku-type = 'Array[Str]'; }
    when /g? char '*'/          { $raku-type = 'Str'; }
    when /g? int \d* '*'/       { $raku-type = 'Array[Int]'; }
    when /g? uint \d* '*'/      { $raku-type = 'Array[UInt]'; }
    when /g? size '*'/          { $raku-type = 'Array[gsize]'; }
#    when /:i g? error '*'/      { $raku-type = 'Array[N-Error]'; }
#    when /:i g? error '*'/      { $raku-type = 'N-Object'; }
#    when /:i g? pixbuf '*'/     { $raku-type = 'N-Object'; }
    when /g? pointer '*'/       { $raku-type = 'Array'; }

    # Graphene
    when / _Bool /              { $raku-type = 'gboolean'; }

    # Other packages like those from Pango might not have
    # the 'g' prefixed
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

    when /g? [float || double]/ {
      $raku-type = 'Num';
      $raku-type ~= '()' unless $return-type;
    }

    when 'GType' { $raku-type = 'GType'; }

    when /GQuark/ { $raku-type = 'UInt'; }
    when /GList/ {
      $raku-type = 'N-List';
      $raku-type ~= '()' unless $return-type;
    }

    when /GSList/ {
      $raku-type = 'N-SList';
      $raku-type ~= '()' unless $return-type;
    }

#TODO check for any other types in gir files
#grep 'name="' Gtk-3.0.gir | grep '<type' | sed 's/^[[:space:]]*//' | sort -u

    when 'void' { $raku-type = 'void'; }
    when 'gpointer' { $raku-type = 'gpointer'; }

    default {
      # remove any pointer marks because objects are provided by pointer
      my Bool $is-pointer = $ctype ~~ m/ '*' / ?? True !! False;
      $ctype ~~ s:g/ '*' //;

      my Hash $h = $!solve.search-name($ctype);
      given $h<gir-type> // '-' {
        when 'class' {
          $raku-type = 'N-Object';
          $raku-type ~= '()' unless $return-type;
        }

        when 'interface' {
          $raku-type = 'N-Object';
          $raku-type ~= '()' unless $return-type;          
        }

        when 'record' {
#note "$?LINE record $orig-ctype $h.gist()";
#          $raku-type = "N-$h<gnome-name>";
#          self.add-import($h<structure-name>);
#          $raku-type = "$h<record-class>";
#          $raku-type = "CArray[$raku-type]" if $is-pointer;
          $raku-type = 'N-Object';
          self.add-import('Gnome::N::N-Object');

          my $class-name =
            $!solve.set-object-name( $h, :name-type(ClassnameType));
          self.add-import($class-name);
#          $raku-type ~= ' _UA_' unless self.add-import($class-name);

          # Record modules have their structs in type files
          my Str $type-name = $class-name;
          $type-name ~~ s/ '::N-' .* $/::T-$h<source-filename>/;
          self.add-import($type-name);
        }

        when 'union' {
#          $raku-type = "N-$h<gnome-name>";
#          self.add-import($h<structure-name>);
#          $raku-type = "$h<record-class>";
#          $raku-type = "CArray[$raku-type]" if $is-pointer;
          $raku-type = 'N-Object';
          self.add-import('Gnome::N::N-Object');

          my $class-name =
            $!solve.set-object-name( $h, :name-type(ClassnameType));
          self.add-import($class-name);
#          $raku-type ~= ' _UA_' unless self.add-import($class-name);

          # Union modules have their structs in type files
          my Str $type-name = $class-name;
          $type-name ~~ s/ '::N-' /::T-/;
          self.add-import($type-name);
        }

        when 'constant' {
          $raku-type = "$ctype";
          $raku-type = "CArray[$raku-type]" if $is-pointer;
        }

        when 'enumeration' {
          # All C enumerations are integers and can coerce to the enum type
          # in input and output. Need to prefix package name because
          # enumerations are mentioned without it
#          $raku-type = $h<class-name> ~ '()';
          $raku-type = "GEnum:$ctype";
          my $class-name =
            $!solve.set-object-name( $h, :name-type(ClassnameType));
          $raku-type ~= ' _UA_' unless self.add-import($class-name);
        }

        when 'bitfield' {
#          $raku-type = 'UInt';
#          $raku-type ~= '()' unless $return-type;
          $raku-type = "UInt:$ctype";
          my $class-name =
            $!solve.set-object-name( $h, :name-type(ClassnameType));
          $raku-type ~= ' _UA_' unless self.add-import($class-name);
        }

        when 'alias' { }

        when 'callback' {
          my %cb = self!get-callback-function($h);
note "$?LINE $h<callback-name>";
          $raku-type = self.generate-callback(%cb);
note "$?LINE $raku-type";
        }

        default {
          note 'Unknown gir type to convert to raku type \'',
            $h<gir-type> // '-', '\' for ctype \'', $orig-ctype,
            '\', \'', $*work-data<gnome-type>, '\'';
        }
      }
    }
  }
#note "\n$?LINE $ctype, $raku-type" if $ctype ~~ m:i/ cairo /;

  $raku-type
}

#-------------------------------------------------------------------------------
method save-file ( Str $filename is copy, Str $content is copy, Str $comment ) {
#note "\n$?LINE $filename";

  my Bool $save-it;

  # Ask to write a new file(w), overwrite original file, or save a new version
  # aside files or skip saving.
  if $filename.IO.e {
    my Str $basename = $filename.IO.basename();

    # The check is done on filename without extension.
    my Str $checkfname = $basename;
    $checkfname ~~ s/ '.' <-[.]>+ $//;
#note "$?LINE $basename, $checkfname";

    my Bool $protect = False;
    if $*generate-code {
      $protect = $!protected-files<c>.first($checkfname).Bool;
    }

    elsif $*generate-doc {
      $protect = $!protected-files<d>.first($checkfname).Bool;
    }

    elsif $*generate-test {
      $protect = $!protected-files<t>.first($checkfname).Bool;
    }

    my Str $a;
    if $protect {
      say "\nFile $basename found, new version(v) or skip(s)";
       $a = prompt "[v,s] s is default> ";
    }

    else {
      if $*overwrite {
        $a = 'o';
      }

      else {
        say "\nFile $basename found, Overwrite(o), new version(v) or skip(s)";
        $a = prompt "[o,v,s] s is default> ";
      }
    }

    given $a.lc {
      when 'o' {
        $save-it = !$protect and True;
      }

      when 'v' {
        my $f = $filename;
        my Int $v = 1;
        $filename ~= ";$v";
        while $filename.IO.e {
          $v++;
          $filename = "$f;$v";
        }

        $save-it = True;
      }

      # when 's'
      default {
        $save-it = False;
      }
    }
  }

  # File not found, create a new one
  else {
    my Str $a;
    if $*overwrite {
      $a ='w';
    }

    else {
      say "\nFile $filename.IO.basename() not yet saved,",
        " Write(w), skip(s)";
      $a = prompt "[w,s] s is default> ";
    }
    $save-it = $a.lc eq 'w';
  }

  my Gnome::SourceSkimTool::DocText $dtxt .= new;
  if $save-it {
    if $*generate-doc {
      $content = $dtxt.modify-text( $filename.IO.basename, $content);
    }

    $filename.IO.spurt($content);
    $*saved-file-summary.push: $filename.IO.basename;
  }

  # Must reset before another module gets documented
  $dtxt.reset;

#`{{
    if $*generate-doc {
      $content ~~ s/ 'use v6.d;' //;
      my $pod = load($content);
      my Str $md = pod2markdown($pod);

      my Str $md-dir = $*work-data<result-docs> ~ 'md/';
      mkdir $md-dir, 0o755 unless $md-dir.IO.e;
      my Str $md-filename = $md-dir ~ $filename.IO.basename;
      $md-filename ~~ s/ '.rakudoc' /.md/;
      $md-filename.IO.spurt($md);
      $*saved-file-summary.push: $md-filename.IO.basename;
    }
}}
}
















=finish

#-------------------------------------------------------------------------------
multi method set-object-name (
  Str $type-letter = '', ObjectNameType :$name-type = ClassnameType
  --> Str
) {
  my Str $object-name;
  given $name-type {
    when ClassnameType {
      if ?$type-letter {
        $object-name = $*work-data<raku-package> ~ '::' ~
                      $type-letter ~ '-' ~ $*work-data<raku-name>;
      }

      else {
        $object-name = $*work-data<raku-class-name>;
      }
    }

    when FilenameType {
      if ?$type-letter {
        $object-name = $type-letter ~ '-' ~ $*work-data<raku-name>;
      }

      else {
        $object-name = $*work-data<raku-name>;
      }
    }
  }

  $object-name
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
    #next if $cn.attribs<deprecated>:exists and $cn.attribs<deprecated> eq '1';

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
  my Str $function-name =
    self.cleanup-id( $e.attribs<c:identifier>, :is-function);

#  my Str $sub-prefix = $*work-data<sub-prefix>;
#  $function-name ~~ s/^ $sub-prefix //;

#`{{
  # Find suitable option names for the BUILD submethod.
  # Constructors have '_new' in the name. To get a name for the build options
  # remove the subroutine prefix and the 'new_' string from the subroutine
  # name.
  my Str $option-name = $function-name;
  $option-name ~~ s/^ $sub-prefix new '_'? //;

  # Remove any other prefix ending in '_'.
  my Int $last-u = $option-name.rindex('_');
  $option-name .= substr($last-u + 1) if $last-u.defined;

  # When nothing is left, make it empty.
  $option-name = '' if $option-name ~~ m/^ \s* $/;
}}

  # Find return value; constructors should return a native N-Object while
  # the gnome might say e.g. gtkwidget 
  my XML::Element $rvalue = $xpath.find( 'return-value', :start($e));
  my Str ( $rv-type, $return-raku-type) = self.get-type( $rvalue, :$user-side);
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
#  my Bool $first = True;
  for @prmtrs -> $p {

#`{{
    # Process first argument type to attach to option name
    if $first {
      # We need the native type to keep the $option-name the same in all cases
      ( $type, $raku-type) = self.get-type( $p, :!user-side);
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

        when 'N-Object' {
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
}}
      ( $type, $raku-type) = self.get-type( $p, :$user-side);
#    }

    $missing-type = True if !$raku-type or $raku-type ~~ /_UA_ $/;
    $raku-type ~~ s/ _UA_ $//;

    my Hash $attribs = $p.attribs;
    my Str $parameter-name = self.cleanup-id($attribs<name>);

    # When '…', there will be no type for that parameter. It means that
    # a variable argument list is used ending in a Nil.
    if $parameter-name eq '…' {
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
      :@parameters, :$variable-list,
#      :$option-name, :@parameters, :$variable-list,
      :$rv-type, :$return-raku-type, :$missing-type
    )
  );
}

#-------------------------------------------------------------------------------
method get-functions (
  XML::Element $element, XML::XPath $xpath, Bool :$user-side = False --> Hash
) {
  my Hash $hms = %();

  my @methods = $xpath.find( 'function', :start($element), :to-list);

  for @methods -> $function {
    # Skip deprecated methods
    #next if $function.attribs<deprecated>:exists and
    #        $function.attribs<deprecated> eq '1';

    my ( $function-name, %h) =
      self!get-method-data( $function, :$xpath, :$user-side);

    # Function names which are returned emptied, are assumably internal
    next unless ?$function-name and ?%h;

    # Add to hash with functionname as its key
    $hms{$function-name} = %h;
  }

  $hms
}

#-------------------------------------------------------------------------------
method get-methods (
  XML::Element $element, XML::XPath $xpath, Bool :$user-side = False --> Hash
) {
  my Hash $hms = %();

  my @methods = $xpath.find( 'method', :start($element), :to-list);

  for @methods -> XML::Element $function {
    # Skip deprecated methods
    #next if $function.attribs<deprecated>:exists and
    #        $function.attribs<deprecated> eq '1';

    my ( $function-name, %h) =
      self!get-method-data( $function, :$xpath, :$user-side);

    # Function names which are returned emptied, are assumably internal
    next unless ?$function-name and ?%h;

    # Add to hash with functionname as its key
    $hms{$function-name} = %h;
  }

  $hms
}







