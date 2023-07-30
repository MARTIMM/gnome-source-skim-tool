
use Gnome::SourceSkimTool::ConstEnumType;
use Gnome::SourceSkimTool::Doc;

use XML;
use XML::XPath;
use JSON::Fast;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::Code:auth<github:MARTIMM>;

has Gnome::SourceSkimTool::Doc $!grd;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {

  $!grd .= new;
}

#-------------------------------------------------------------------------------
method set-unit ( XML::Element $element --> Str ) {

  my Str $also = '';
  my Str $ctype = $element.attribs<c:type>;
  my Hash $h = self.search-name($ctype);

  # Check for parent class. There are never more than one.
  my Str $parent = $h<parent-raku-name> // '';
  if ?$parent {
    # Misc is deprecated so shortcut to Widget
    $parent = 'Gnome::Gtk3::Widget' if $parent ~~ m/ \:\: Misc $/;
    $*external-modules.push: $parent;
    $also ~= "also is $parent;\n";
  }

  my Bool $is-role = (($h<gir-type> // '' ) eq 'interface') // False;
  my Bool $is-class = (($h<gir-type> // '' ) eq 'class') // False;
  # If the object is a class
  if $is-class {
    # Check for roles to implement
    my Array $roles = $h<implement-roles>//[];
    for @$roles -> $role {
      my Hash $role-h = self.search-name($role);
#note "$?LINE role=$role -> $role-h.gist()";
      $*external-modules.push: $role-h<class-name>;
      $also ~= "also does $role-h<class-name>;\n" if ?$role-h<class-name>;
    }
  }

  my Str $code = qq:to/RAKUMOD/;

    {$!grd.pod-header('Module Imports')}
    __MODULE__IMPORTS__
    use Gnome::Glib::GnomeRoutineCaller:api<2>;

    {$!grd.pod-header(($is-role ?? 'Role' !! 'Class') ~ ' Declaration');}
    unit {$is-role ?? 'role' !! 'class'} $*work-data<raku-class-name>:auth<github:MARTIMM>:api<2>;
    $also
    RAKUMOD

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
    use Gnome::N::TopLevelClassSupport;

    use Gnome::Glib::GnomeRoutineCaller:api<2>;
    RAKUMOD
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

  # Generate constructors
  my Hash $hcs = self.get-constructors( $element, $xpath);
  $code ~= self!generate-constructors($hcs) if ?$hcs;
  note "Generate constructors" if $*verbose and ?$code;

  # Generate methods
  $c = self!generate-methods( $element, $xpath);
  $code ~= $c if ?$c;
  note "Generate methods" if $*verbose and ?$c;

  # Generate functions

  # Get all functions in this class
  my Hash $hfs = self!get-functions( $element, $xpath);
  $code ~= self.generate-functions($hfs);

  note "Generate functions" if $*verbose and ?$c;

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
          Str $n, Bool $_fallback-v2-ok is rw,
          Gnome::Glib::GnomeRoutineCaller $routine-caller, *@arguments
        ) {
          my Str $name = S:g/ '-' /_/ with $n;
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
        method _fallback-v2 ( Str $n, Bool $_fallback-v2-ok is rw, *@arguments ) {
          my Str $name = S:g/ '-' /_/ with $n;
          if $methods{$name}:exists {
            my $native-object = self.get-native-object-no-reffing;
            $_fallback-v2-ok = True;
            return $!routine-caller.call-native-sub(
              $name, @arguments, $methods, :$native-object
            );
          }

          else {
        RAKUMOD

      my Str $ctype = $element.attribs<c:type>;
      my Hash $h = self.search-name($ctype);
      my Array $roles = $h<implement-roles>//[];
      for @$roles -> $role {
        my Hash $role-h = self.search-name($role);
#note "$?LINE role=$role -> $role-h.gist()";

        $c ~= qq:to/RAKUMOD/;
              my \$r = self.{$role}::_fallback-v2-ok\(
                \$name, \$_fallback-v2-ok, \$!routine-caller, \@arguments
              \);
              return \$r if \$_fallback-v2-ok;

          RAKUMOD
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

  my Str $signal-admin = '';
  my Str $role-signals = '';
  my Array $roles = $h<implement-roles> // [];
  for @$roles -> $role {
    my Hash $role-h = self.search-name($role);
#note "$?LINE role=$role -> $role-h.gist()";
    $role-signals ~=
      "    self._add_$role-h<symbol-prefix>signal_types\(\$?CLASS\.^name)\n" ~
      "      if self.^can\('_add_$role-h<symbol-prefix>signal_types');\n";
  }

  $role-signals = "\n    # Signals from interfaces\n" ~ $role-signals
    if ?$role-signals;

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

  my Str $code = qq:to/EOBUILD/;
    {HLSEPARATOR}
    {SEPARATOR('BUILD variables');}
    {HLSEPARATOR}
    # Define helper
    has Gnome::Glib::GnomeRoutineCaller \$\!routine-caller;
    
    {?$signal-admin ?? '# Add signal registration helper' !! ''}
    {?$signal-admin ?? 'my Bool $signals-added = False;' !! ''}

    {HLSEPARATOR}
    {SEPARATOR('BUILD submethod');}
    {HLSEPARATOR}
    # Module initialize
    submethod BUILD ( *\%options ) \{
    $signal-admin
    EOBUILD


  $code ~= qq:to/EOBUILD/;

      # Initialize helper
      \$\!routine-caller .= new\( :library\($*work-data<library>\), :sub-prefix\<$*work-data<sub-prefix>\>);

    EOBUILD

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

  my Str $ifelse = 'if';
  my Hash $hcs = self.get-constructors( $element, $xpath);
  for $hcs.keys.sort -> $function-name {

    my Str $fallback-fst-arg = $function-name;
    my $sub-prefix = $*work-data<sub-prefix>;
    $fallback-fst-arg ~~ s/^ $sub-prefix //;

    my Bool $first = True;
    my $par-list = '';
    my $decl-list = '';
    for @($hcs{$function-name}<parameters>) -> $parameter {
      if $first {
        $par-list ~= ", \$$hcs{$function-name}<option-name>";
        $decl-list ~= [~]  '        my $', $hcs{$function-name}<option-name>,
          ' = %options<', $parameter<name>, '>;', "\n";
      }

      else {
        $par-list ~= ", \$$parameter<name>";
        $decl-list ~= [~]  '        my $', $parameter<name>,
          ' = %options<', $parameter<name>, '>;', "\n";
      }

      $first = False;
    }

    # remove first comma
    $par-list ~~ s/^ . // if @($hcs{$function-name}<parameters>).elems == 1;

    # remove first space when there is only one parameter
    $par-list ~~ s/^ . // if @($hcs{$function-name}<parameters>).elems == 1;

    $code ~= qq:to/EOBUILD/;
            #$ifelse \%options\<$hcs{$function-name}<option-name>\>.defined \{
            #$ifelse \? \%options\<$hcs{$function-name}<option-name>\> \{
            $ifelse \%options\<$hcs{$function-name}<option-name>\>:exists \{
      $decl-list
              # 'my Bool \$x' is needed but value ignored
              \$no = self\._fallback-v2\( '$fallback-fst-arg', my Bool \$x, ... \);
            \}

      EOBUILD

    $ifelse = "elsif";
  }

  if !$h<inheritable> {
    $code ~= q:to/EOBUILD/;
          # check if there are unknown options
          elsif %options.elems {
            die X::Gnome.new(
              :message(
                'Unsupported, undefined, incomplete or wrongly typed options for ' ~
                self.^name ~ ': ' ~ %options.keys.join(', ')
              )
            );
          }

    EOBUILD
  }

  $code ~= q:to/EOBUILD/;
        #`{{ when there are no defaults use this
        # check if there are any options
        elsif %options.elems == 0 {
          die X::Gnome.new(:message('No options specified ' ~ self.^name));
        }
        }}

  EOBUILD

  $code ~= qq:to/EOBUILD/;
        #`\{\{ when there are defaults use this instead
        # create default object
        else \{
          \$no = self\._fallback-v2\( 'new', my Bool \$x, ... \);
        \}
        \}\}

        self\._set-native-object\(\$no);
      \}

  EOBUILD

  # End the BUILD submethod
  $code ~= qq:to/EOBUILD/;
        # only after creating the native-object, the gtype is known
        self._set-class-info\('$*work-data<gnome-name>'\);
      \}
    \}
    EOBUILD

  $code
}

#-------------------------------------------------------------------------------
method get-constructors ( XML::Element $element, XML::XPath $xpath --> Hash ) {
  my Hash $hcs = %();

  my @constructors =
    $xpath.find( 'constructor', :start($element), :to-list);

  for @constructors -> $cn {
    # Skip deprecated constructors
    next if $cn.attribs<deprecated>:exists and $cn.attribs<deprecated> eq '1';

    my ( $function-name, %h) = self!get-constructor-data( $cn, :$xpath);
    $hcs{$function-name} = %h;
  }

  $hcs
}

#-------------------------------------------------------------------------------
method !generate-constructors ( Hash $hcs --> Str ) {

  my Str $sub-prefix = $*work-data<sub-prefix>;
  my Str $pattern = '';
  my Str $temp-inhibit = '';

  my Str $code = qq:to/EOSUB/;

    {SEPARATOR( 'Constructors', 2);}
    EOSUB

  for $hcs.keys.sort -> $function-name {
    my Hash $curr-function := $hcs{$function-name};
    $temp-inhibit = ?$curr-function<missing-type> ?? '#' !! '';

    $pattern = $curr-function<variable-list> ?? ':pattern([' !! '';

    # Get a list of types for the arguments
    my $par-list = '';
    my Str $pattern-starter = '';
    for @($curr-function<parameters>) -> $parameter {
      # Enumerations and bitfields are returned as GEnum:Name and GFlag:Name
      my ( $rnt0, $rnt1) = $parameter<raku-ntype>.split(':');
#      $par-list ~= ", $rnt0";

      if $curr-function<variable-list> {
        # When variable list, the last type is '…', Finish the pattern.
        if $parameter<raku-ntype> eq '…' {
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
        $par-list ~= ", $rnt0";
      }
    }

    # Remove first comma
    $par-list ~~ s/^ . //;
    my Str $parameters = ?$par-list ?? ":parameters\(\[$par-list\]\)," !! '';

    # Remove prefix from routine
    my Str $hash-fname = $function-name;
    $hash-fname ~~ s/^ $sub-prefix //;

    # Enumerations and bitfields are returned as GEnum:Name and GFlag:Name
    my ( $rnt0, $rnt1) = $curr-function<return-raku-ntype>.split(':');
    if ?$rnt1 {
#TM:1:$hash-fname
    $code ~= [~] '  ', $hash-fname, ' => %( :type(Constructor),',
                 ':returns(', $rnt0, '), ',
                 ':type-name(', $rnt1, '), ',
                 $parameters, "),\n";
#`{{
      $code ~= qq:to/EOSUB/;
        $hash-fname =\> \%\(
          :type\(Constructor\),
          :returns\($rnt0\),
          :type-name\($rnt1\),$parameters
        ),

      EOSUB
}}
    }

    else {
#TM:1:$hash-fname
    $code ~= [~] '  ', $temp-inhibit, $hash-fname, ' => %( :type(Constructor),',
                 ':returns(', $rnt0, '), ',
                 $pattern, $parameters, "),\n";

    # drop last comma from arg list
    $code ~~ s/ '),)' /))/;
#`{{
      $code ~= qq:to/EOSUB/;
        $hash-fname =\> \%\(
          :type\(Constructor\),
          :returns\($rnt0\),$parameters
        ),

      EOSUB
}}
    }
  }

  $code
}

#-------------------------------------------------------------------------------
method !generate-methods ( XML::Element $element, XML::XPath $xpath --> Str ) {

#  my Str $ctype = $element.attribs<c:type>;
#  my Hash $h = self.search-name($ctype);
#  my Str $symbol-prefix = $h<symbol-prefix> // $h<c:symbol-prefix> // '';
  my Str $symbol-prefix = $*work-data<sub-prefix>;
  my Str $pattern = '';
  my Str $temp-inhibit = '';

  # Get all methods in this class
  my Hash $hcs = self!get-methods( $element, $xpath);
  return '' unless ?$hcs;

  my Str $code = qq:to/EOSUB/;

    {SEPARATOR( 'Methods', 2);}
    EOSUB

  for $hcs.keys.sort -> $function-name {
#note "\n$?LINE  $function-name";
    my Hash $curr-function := $hcs{$function-name};

    $pattern = $curr-function<variable-list> ?? ':pattern([' !! '';

    # get method name, drop the prefix
    my Str $hash-fname = $function-name;
    $hash-fname ~~ s/^ $symbol-prefix //;

    # get parameter lists
    my Str $par-list = '';
    my Bool $first-param = True;

    my Str $pattern-starter = '';
    for @($curr-function<parameters>) -> $parameter {
#note "  $?LINE $parameter<name> $parameter<raku-ntype>";
      $temp-inhibit = ?$curr-function<missing-type> ?? '#' !! '';

      # Get a list of types for the arguments but skip the first native type
      # This is the instance variable which is inserted automatically in the
      # fallback routines.
      if $first-param {
        $first-param = False;
      }

      else {
        # Enumerations and bitfields are returned as GEnum:Name and GFlag:Name
        # Here we only need the type.
        my ( $rnt0, $rnt1) = $parameter<raku-ntype>.split(':');
#        $par-list ~= ", $rnt0";

        if $curr-function<variable-list> {
          # When variable list, the last type is '…', Finish the pattern.
          if $parameter<raku-ntype> eq '…' {
            # A pattern consists of a character key and some value of an unknown
            # type. This repeats until user data is exhausted.
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
          $par-list ~= ", $rnt0";
        }
      }
    }

    # Remove first comma and space when there is only one parameter
    $par-list ~~ s/^ . //;
    $par-list ~~ s/^ . // unless $par-list ~~ m/ \, /;
    $par-list = ?$par-list ?? [~] ' :parameters([', $par-list, ']),' !! '';

    # Return type
    my $xtype = $curr-function<return-raku-ntype>;
    my Str $returns = '';

    # Enumerations and bitfields are returned as GEnum:Name and GFlag:Name
    my ( $rnt0, $rnt1) = $xtype.split(':');
    if ?$rnt1 {
      $returns = " :returns\($rnt0\), :type-name\($rnt1\),";
    }

    elsif ?$rnt0 and $xtype ne 'void' {
      $returns = " :returns\($rnt0\),";
    }

#note "$?LINE $hash-fname";
#note "$?LINE $returns";
#note "$?LINE $par-list";

    $code ~= [~] '  ', $temp-inhibit, $hash-fname, ' => %(',
             $pattern, $returns, $par-list, "),\n";

    # drop last comma from arg list
    $code ~~ s/ '),)' /))/;
#`{{
#TM:0:$hash-fname
    $code ~= qq:to/EOSUB/;
      $hash-fname =\> \%\($returns$par-list
      ),

    EOSUB
}}
  }

  $code
}

#-------------------------------------------------------------------------------
method !get-methods ( XML::Element $element, XML::XPath $xpath --> Hash ) {
  my Hash $hms = %();

  my @methods = $xpath.find( 'method', :start($element), :to-list);

  for @methods -> $cn {
    # Skip deprecated methods
    next if $cn.attribs<deprecated>:exists and $cn.attribs<deprecated> eq '1';

    my ( $function-name, %h) = self!get-method-data( $cn, :$xpath);
    $hms{$function-name} = %h;
  }

  $hms
}

#-------------------------------------------------------------------------------
method generate-functions ( Hash $hcs --> Str ) {

  return '' unless ?$hcs;

  my Str $symbol-prefix = $*work-data<sub-prefix>;
  my Str $pattern = '';
#  my Str $variable-list = '';
  my Str $temp-inhibit = '';

  # Get all functions from the Hash
  my Str $code = qq:to/EOSUB/;

    {SEPARATOR( 'Functions', 2);}
    EOSUB

  for $hcs.keys.sort -> $function-name {
    my Hash $curr-function := $hcs{$function-name};

     # Get method name, drop the prefix and substitute '_'
    my Str $hash-fname = $function-name;
    $hash-fname ~~ s/^ $symbol-prefix //;
#    # keep this version for later
#    my Str $hash-fname = $method-name;
#    $method-name ~~ s:g/ '_' /-/;

#    my Str $function-doc = $curr-function<function-doc>;
#    $function-doc = "No documentation of function." unless ?$function-doc;

    # Get parameter lists
    my Str (
      $par-list #, $call-list, #$own, $raku-list, $returns-doc, $items-doc, 
    ) =  '';
    my @rv-list = ();

    $pattern = $curr-function<variable-list> ?? ':pattern([' !! '';

    my Str $pattern-starter = '';
    for @($curr-function<parameters>) -> $parameter {
#      self!get-types(
#        $parameter, #$raku-list, 
#        $call-list, #$items-doc,
#        @rv-list #, $returns-doc
#      );

      # Enumerations and bitfields are returned as GEnum:Name and GFlag:Name
      my ( $rnt0, $rnt1) = $parameter<raku-ntype>.split(':');

      if $curr-function<variable-list> {
        # When variable list, the last type is '…', Finish the pattern.
        if $parameter<raku-ntype> eq '…' {
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
        $par-list ~= ", $rnt0";
      }
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
    my Str $returns;
    my $xtype = $curr-function<return-raku-ntype>;
    my ( $rnt0, $rnt1) = $xtype.split(':');
    if ?$rnt1 {
      $returns = " :returns\($rnt0\), :type-name\($rnt1\),";
    }

    elsif ?$rnt0 and $xtype ne 'void' {
      $returns = " :returns\($rnt0\),";
    }

    else {
      $returns = '';
    }

#note "$?LINE $hash-fname, {$returns//'-'}, {$par-list//'-'}";
#TM:0:$hash-fname
    $code ~= [~] '  ', $temp-inhibit, $hash-fname, ' => %( :type(Function), ',
                 $pattern, $returns, $par-list, "),\n";

    # drop last comma from arg list
    $code ~~ s/ '),)' /))/;
  }

  $code
}

#-------------------------------------------------------------------------------
method !get-functions ( XML::Element $element, XML::XPath $xpath --> Hash ) {
  my Hash $hms = %();

  my @methods = $xpath.find( 'function', :start($element), :to-list);

  for @methods -> $cn {
    # Skip deprecated methods
    next if $cn.attribs<deprecated>:exists and $cn.attribs<deprecated> eq '1';

    my ( $function-name, %h) = self!get-method-data( $cn, :$xpath);
    $hms{$function-name} = %h;
  }

  $hms
}

#-------------------------------------------------------------------------------
method get-standalone-functions ( Array $function-names --> Hash ) {
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
    my ( $function-name, %h) = self!get-method-data( $cn, :$xpath);
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
  Str $function-name, Hash $cb-data, Bool :$named-parameter = False --> Str
) {
  return '' unless ?$cb-data;

  my Str $par-list = '';
  for @($cb-data<parameters>) -> $parameter {
    my ( $rnt0, $rnt1) = $parameter<raku-ntype>.split(':');
    $par-list ~= ", $rnt0";
  }

  # Remove first comma and space when there is only one parameter
  $par-list ~~ s/^ . //;

  my Str $returns;
  my $xtype = $cb-data<return-raku-ntype>;
  my ( $rnt0, $rnt1) = $xtype.split(':');
  if ?$rnt0 and $rnt0 eq 'void' {
    $returns = '';
  }

  elsif ?$rnt0 {
    $returns = $rnt0;
  }

  else {
    $returns = '';
  }

  my $code = [~] 'Callable ', ($named-parameter ?? ':$' !! '$'),
                  $function-name, ' (', $par-list,
                  (?$returns ?? " --> $returns \)" !! ' )');

  $code
}

#-------------------------------------------------------------------------------
method generate-enumerations-code ( Array:D $enum-names --> Str ) {

  # Don't look enum names up if array is provided
#  $enum-names = self!get-enumeration-names unless ?$enum-names;

  # Return empty string if no enums found.
  return '' unless ?$enum-names;
#note "$?LINE e names: $enum-names.gist()";

  # Open enumerations file for xpath
  my Str $file = $*work-data<gir-module-path> ~ 'repo-enumeration.gir';
  my XML::XPath $xpath .= new(:$file);

#  my Str $symbol-prefix = $*work-data<sub-prefix>;
  my Str $code = qq:to/EOENUM/;
    {HLSEPARATOR}
    {SEPARATOR('Enumerations');}
    {HLSEPARATOR}
    EOENUM

#`{{
  my Str $doc = qq:to/EOENUM/;
    {HLSEPARATOR}
    {SEPARATOR('Enumerations');}
    {HLSEPARATOR}
    =begin pod
    =head1 Enumerations
    =end pod

    EOENUM
}}

  # For each of the found names
  for $enum-names.sort -> $enum-name {
    my Str $name = $enum-name;
    my Str $package = $*gnome-package.Str;
    $package ~~ s/ \d+ $//;
    $name ~~ s/^ $package //;

    # Get the XML element of the enum data
    my XML::Element $e = $xpath.find(
      '//enumeration[@name="' ~ $name ~ '"]', :!to-list
    );

#TE:0:$enum-name
#      {HLSEPARATOR}
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
    $package ~~ s/ \d+ $//;
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
method generate-structure ( XML::XPath $xpath, XML::Element $element ) {

  my $temp-external-modules = $*external-modules;
  $*external-modules = [<
    NativeCall Gnome::N::NativeLib Gnome::N::N-GObject Gnome::N::GlibToRakuTypes
  >];

  my Str $name = $*work-data<gnome-name>;
  my Hash $h0 = self.search-name($name);
  my Str $structure-name = $h0<structure-name>;

#TL:1:$structure-name:
#TT:1:$structure-name:
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
      unit class $structure-name\:auth<github:MARTIMM>\:api<2> is export is repr\('CStruct');

      EOREC

    for @fields -> $field {
      my $field-name = $field.attribs<name>;
#note "$?LINE $field-name";
      my Str ( $type, $raku-ntype, $raku-rtype) = self!get-type($field);

      $field-name ~~ s:g/ '_' /-/;
      if ?$type {
        # Enumerations and bitfields are returned as GEnum:Name and GFlag:Name
        my Str ( $rnt0, $rnt1) = $raku-ntype.split(':');
#note "\n$?LINE $raku-ntype, $raku-rtype, $rnt0, {$rnt1//'-'}\n$field.attribs()gist()" if $structure-name eq 'N-GClosureNotifyData';
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

        if $raku-ntype eq 'N-GObject' {
          $tweak-pars ~= "$raku-ntype :\$$field-name, ";
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

          $code ~= "has gpointer \$.$field-name;\n";
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

      method COERCE \( \$no --> $structure-name \) \{
        note "Coercing from \{\$no.^name\} to ", self.^name if \$Gnome::N::x-debug;
        nativecast\( $structure-name, \$no\)
      \}
      EOREC

#    $code ~= "\n\n";
    $*external-modules.push: 'Gnome::N::X';
    $code = self.substitute-MODULE-IMPORTS($code);

    # Reset to original and add this structure
    $*external-modules = $temp-external-modules;
    $*external-modules.push: $structure-name;
  }

  else {
    $code ~= qq:to/EOREC/;
      {$!grd.pod-header('Record Structure')}
      # This is an opaque type of which fields are not available.
      unit class $structure-name is export is repr\('CPointer');

      EOREC

    # Reset to original and add this structure
    $*external-modules = $temp-external-modules;
    $*external-modules.push: $structure-name;
  }

  my Str $fname = $h0<structure-filename>;
  $fname.IO.spurt($code);
  note "Save record structure in ", $fname.IO.basename;
}

#-------------------------------------------------------------------------------
# A structure consists of fields. Only then there is a structure
method generate-union ( XML::XPath $xpath, XML::Element $element ) {

  my $temp-external-modules = $*external-modules;
  $*external-modules = [<
    NativeCall Gnome::N::NativeLib Gnome::N::N-GObject Gnome::N::GlibToRakuTypes
  >];

  my @fields = $xpath.find( 'field', :start($element), :to-list);
  return '' unless ?@fields;

  my Str $name = $*work-data<gnome-name>;
  my Hash $h0 = self.search-name($name);
  my Str $structure-name = $h0<structure-name>;

#TL:1:$structure-name:
#TT:1:$structure-name:
  my Str $code = qq:to/RAKUMOD/;
    # Command to generate: $*command-line
    use v6;

    {$!grd.pod-header('Module Imports')}
    __MODULE__IMPORTS__

    {$!grd.pod-header('Union Structure')}
    unit class $structure-name\:auth<github:MARTIMM>\:api<2> is export is repr\('CUnion');

    RAKUMOD

  for @fields -> $field {
    my $field-name = $field.attribs<name>;
    my Str ( $type, $raku-ntype, $raku-rtype) = self!get-type($field);

    $field-name ~~ s:g/ '_' /-/;

    # Enumerations and bitfields are returned as GEnum:Name and GFlag:Name
    my Str ( $rnt0, $rnt1) = $raku-ntype.split(':');
    if ?$rnt1 {
      $code ~= "HAS $rnt0 \$.$field-name;           # $rnt1\n";
    }

    else {
      $code ~= "HAS $rnt0 \$.$field-name;\n";
    }
  }

  $code ~= qq:to/RAKUMOD/;

    method COERCE \( \$no --> $structure-name \) \{
      note "Coercing from \{\$no.^name\} to ", self.^name if \$Gnome::N::x-debug;
      nativecast\( $structure-name, \$no\)
    \}
    
    RAKUMOD

  $*external-modules.push: 'Gnome::N::X';
  $code = self.substitute-MODULE-IMPORTS($code);

  # Reset to original and add this structure
  $*external-modules = $temp-external-modules;
  $*external-modules.push: $structure-name;

  my Str $fname = $h0<structure-filename>;
  $fname.IO.spurt($code);
  note "Save union structure in ", $fname.IO.basename;
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
# Fill in the __MODULE__IMPORTS__ string inserted at the start of the code
# generation. It is the place where the 'use' statements must come.
method substitute-MODULE-IMPORTS ( Str $code is copy --> Str ) {

  note "Set modules to import" if $*verbose;
  my $import = '';
  for @$*external-modules -> $m {
    if $m ~~ m/ [ NativeCall || 'Gnome::N::' ] / {
      $import ~= "use $m;\n";
    }
  }

  $import ~= "\n";

  for @$*external-modules.sort -> $m {
    unless $m ~~ m/ [ NativeCall || 'Gnome::N::' ] / {
      # For the moment only Gtk gets changed for :api<2>
#      if $m ~~ m/ '::' [ Gtk || Gdk ] / {
        $import ~= "use $m\:api\<2\>;\n";
#      }

#      else {
#        # Other modules may need name changes
#        $import ~= "use $m;\n";
#      }
    }
  }

  $code ~~ s/__MODULE__IMPORTS__/$import/;

  $code
}

#-------------------------------------------------------------------------------
method init-xpath ( Str $element-name, Str $gir-filename --> List ) {
  my XML::XPath $xpath .= new(:file($*work-data{$gir-filename}));
  my XML::Element $element = $xpath.find("//$element-name");
  die "//$element-name elements not found in $*work-data{$gir-filename} for $*work-data<raku-class-name>" unless ?$element;

  ( $xpath, $element )
}

#-------------------------------------------------------------------------------
method !get-constructor-data ( XML::Element $e, XML::XPath :$xpath --> List ) {
  my Str ( $function-name, $option-name);
  my Bool $missing-type = False;

  $option-name = $function-name = $e.attribs<c:identifier>;
  my Str $sub-prefix = $*work-data<sub-prefix>;

  # Find suitable option names for the BUILD submethod.
  # Constructors have '_new' in the name. To get a name for the build options
  # remove the subroutine prefix and the 'new_' string from the subroutine
  # name.
  $option-name ~~ s/^ $sub-prefix new '_'? //;

  # Remove any other prefix ending in '_'.
  my Int $last-u = $option-name.rindex('_');
  $option-name .= substr($last-u + 1) if $last-u.defined;

  # When nothing is left, mark the option as a default.
  $option-name = '__DEFAULT__' if $option-name ~~ m/^ \s* $/;

  # Find return value; constructors should return a native N-GObject while
  # the gnome might say e.g. gtkwidget 
  my XML::Element $rvalue = $xpath.find( 'return-value', :start($e));
  my Str ( $rv-type, $return-raku-ntype) = self!get-type($rvalue);
  $missing-type = True unless ?$return-raku-ntype;

  # Get all parameters. Mostly the instance parameters come first
  # but I am not certain.
  my @parameters = ();
  my @prmtrs = $xpath.find(
    'parameters/instance-parameter | parameters/parameter',
    :start($e), :to-list
  );

  my Bool $variable-list = False;
  for @prmtrs -> $p {
    my Str ( $type, $raku-ntype) = self!get-type($p);
    $missing-type = True unless ?$raku-ntype;

    my Hash $attribs = $p.attribs;
    my Str $parameter-name = $attribs<name>;
    $parameter-name ~~ s:g/ '_' /-/;

    # When '...', there will be no type for that parameter. It means that
    # a variable argument list is used ending in a Nil.
    if $parameter-name eq '...' {
      $type = $raku-ntype = '…';
      $variable-list = True;
    }

    my Hash $ph = %( :name($parameter-name), :$type, :$raku-ntype);

    $ph<allow-none> = $attribs<allow-none>.Bool;
    $ph<nullable> = $attribs<nullable>.Bool;
    $ph<is-instance> = False;

    @parameters.push: $ph;
  }

  ( $function-name, %(
      :$option-name, :@parameters, :$variable-list,
      :$rv-type, :$return-raku-ntype, :$missing-type
    )
  );
}

#-------------------------------------------------------------------------------
method !get-method-data ( XML::Element $e, XML::XPath :$xpath --> List ) {
  my Str $function-name = $e.attribs<c:identifier>;
  my Str $sub-prefix = $*work-data<sub-prefix>;
  my Bool $missing-type = False;

  my XML::Element $rvalue = $xpath.find( 'return-value', :start($e));
  #my Str $rv-transfer-ownership = $rvalue.attribs<transfer-ownership>;
#  my Str ( $rv-type, $return-raku-ntype, $return-raku-rtype) =
  my Str ( $rv-type, $return-raku-ntype) = self!get-type($rvalue);
  $missing-type = True unless ?$return-raku-ntype;

  # Get all parameters. Mostly the instance parameters come first
  # but I am not certain.
  my @parameters = ();
  my @prmtrs = $xpath.find(
    'parameters/instance-parameter | parameters/parameter',
    :start($e), :to-list
  );

  my Bool $variable-list = False;
  for @prmtrs -> $p {
#    my Str ( $type, $raku-ntype, $raku-rtype) = self!get-type($p);
    my Str ( $type, $raku-ntype) = self!get-type($p);
    $missing-type = True unless ?$raku-ntype;

    my Hash $attribs = $p.attribs;
    my Str $parameter-name = $attribs<name>;
    $parameter-name ~~ s:g/ '_' /-/;

    # When '...', there will be no type for that parameter. It means that
    # a variable argument list is used ending in a Nil.
    if $parameter-name eq '...' {
#      $type = $raku-ntype = $raku-rtype = '…';
       $type = $raku-ntype = '…';
     $variable-list = True;
    }

    my Hash $ph = %(
      :name($parameter-name), :$type, :$raku-ntype,
#      :transfer-ownership($attribs<transfer-ownership>),
#      :$raku-rtype
    );

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

    @parameters.push: $ph;
  }

  ( $function-name, %(
      :@parameters, :$variable-list, :$rv-type, :$return-raku-ntype,
      :$missing-type
#      :$return-raku-rtype,
#      :$rv-transfer-ownership,
    )
  );
}

#-------------------------------------------------------------------------------
# A simplified method
method !get-callback-data (
  XML::Element $e, XML::XPath :$xpath --> Hash
) {
  my XML::Element $rvalue = $xpath.find( 'return-value', :start($e));
  #my Str $rv-transfer-ownership = $rvalue.attribs<transfer-ownership>;
  my Str ( $rv-type, $return-raku-ntype) = self!get-type($rvalue);

  # Get all parameters. Mostly the instance parameters come first
  # but I am not certain.
  my @parameters = ();
  my @prmtrs = $xpath.find(
    'parameters/instance-parameter | parameters/parameter',
    :start($e), :to-list
  );

  my Bool $variable-list = False;
  for @prmtrs -> $p {

    my Str ( $type, $raku-ntype) = self!get-type($p);
    my Hash $attribs = $p.attribs;
    my Str $parameter-name = $attribs<name>;
    $parameter-name ~~ s:g/ '_' /-/;

    # When '...', there will be no type for that parameter. It means that
    # a variable argument list is used ending in a Nil.
    if $parameter-name eq '...' {
      $type = $raku-ntype = '…';
      $variable-list = True;
    }

    my Hash $ph = %( :name($parameter-name), :$type, :$raku-ntype);

    $ph<allow-none> = $attribs<allow-none>.Bool;
    $ph<nullable> = $attribs<nullable>.Bool;
    $ph<is-instance> = False;

    @parameters.push: $ph;
  }

  %(
    :@parameters, :$variable-list, :$rv-type, :$return-raku-ntype,
  )
}

#-------------------------------------------------------------------------------
method !get-type ( XML::Element $e --> List ) {
#  my Str ( $type, $raku-ntype, $raku-rtype) = '' xx 3;
  my Str ( $type, $raku-ntype) = '' xx 2;
  for $e.nodes -> $n {
    next if $n ~~ XML::Text;
#note "$?LINE $n.name()\n$n.attribs().gist()";
    with $n.name {
      when 'type' {
        $type = $n.attribs<c:type> // $n.attribs<name>;
        $raku-ntype = self.convert-ntype($type);
#        $raku-rtype = self.convert-rtype($type);
      }

      when 'array' {
        # Sometimes there is no 'c:type', assume an array of strings
        $type = $n.attribs<c:type> // 'gchar**';
        $raku-ntype = self.convert-ntype($type);
#        $raku-rtype = self.convert-rtype($type);
      }
    }
  }

#note "$?LINE $type, $raku-ntype, $raku-rtype";
 # ( $type, $raku-ntype, $raku-rtype)
  ( $type, $raku-ntype)
}

#-------------------------------------------------------------------------------
#NOTE not from Prepare: circular deps!
method add-import ( Str $import ) {
  # Add only when $import is not in the array or when $import is not this class
  unless $*external-modules.first($import)
         or $import eq $*work-data<raku-class-name> {

    $*external-modules.push: $import;
  }
}

#-------------------------------------------------------------------------------
method convert-ntype (
  Str $ctype is copy --> Str
#  Str $ctype is copy, Bool :$return-type = False --> Str
) {
  return '' unless ?$ctype;
#note "$?LINE ctype: $ctype";

  # ignore const and spaces
  my Str $orig-ctype = $ctype;
  $ctype ~~ s:g/ const //;
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
    when /g? size '*'/        { $raku-type = 'CArray[gsize]'; }
    when /g? double '*'/      { $raku-type = 'CArray[gdouble]'; }
    when /g? pointer '*'/     { $raku-type = 'CArray[gpointer]'; }
    when /:i g? object '*'/   { $raku-type = 'N-GObject'; }
    when /:i g? pixbuf '*'/   { $raku-type = 'N-GObject'; }
    when /:i g? error '*'/    { $raku-type = 'N-GObject'; }
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

#`{{
    when /GError '*'/ {
      $raku-type = 'CArray[N-GError]';
      $*external-modules.push: 'Gnome::Glib::Error'
        unless $*external-modules.first('Gnome::Glib::Error');
    }
}}


    default {
      # remove any pointer marks
      $ctype ~~ s:g/ '*' //;

      my Hash $h = self.search-name($ctype);
#note "  $?LINE $h<gir-type>";
      given $h<gir-type> // '-' {
        when 'class' {
          $raku-type = 'N-GObject';
        }

        when 'interface' {
          $raku-type = 'N-GObject';
          self.add-import($h<class-name>);
        }

        when 'record' {
#note "$?LINE N-$h<gnome-name>, $h<structure-name>";
#          $raku-type = "N-$h<gnome-name>";
#          self.add-import($h<structure-name>);
          $raku-type = 'N-GObject';
        }

        when 'union' {
#          $raku-type = "N-$h<gnome-name>";
#          self.add-import($h<structure-name>);
          $raku-type = 'N-GObject';
        }

        when 'constant' {
          $raku-type = "$ctype";
        }

        when 'enumeration' {
          $raku-type = "GEnum:$ctype";
#          self.add-import($h<class-name>);
        }

        when 'bitfield' {
          $raku-type = "GFlag:$ctype";
#          self.add-import($h<class-name>);
        }

#        when 'alias' { $raku-type = $h<class-name>; }
        when 'alias' { }

        when 'callback' {
#note "  $?LINE callback";
          my %h = self.get-callback-function($h<callback-name>);
#note "  $?LINE %h.gist()";
          $raku-type = self.generate-callback( $h<callback-name>, %h);
#note "  $?LINE $ctype, $raku-type";
        }

        default {
          note 'Unknown gir type to convert to native raku type \'',
            $h<gir-type> // '-', '\' for ctype \'', $orig-ctype, '\'';
        }
      }
    }
  }

#say "$?LINE: convert to raku native type: '$ctype' -> '$raku-type', return-type = $return-type";

  $raku-type
}

#`{{
#-------------------------------------------------------------------------------
method convert-rtype (
  Str $ctype is copy, Bool :$return-type = False --> Str
) {
  return '' unless ?$ctype;
#note "$?LINE $ctype" if $ctype ~~ /Pixbuf/;

  # ignore const and spaces
  my Str $orig-ctype = $ctype;
  $ctype ~~ s:g/ const //;
  $ctype ~~ s:g/ \s+ //;

  my Str $raku-type = '';
  with $ctype {

#TODO int/num/pointers as '$x is rw'
    when /g? char '**'/         { $raku-type = 'Array[Str]'; }
    when /g? char '*'/          { $raku-type = 'Str'; }
    when /g? int \d* '*'/       { $raku-type = 'Array[Int]'; }
    when /g? uint \d* '*'/      { $raku-type = 'Array[UInt]'; }
    when /g? size '*'/          { $raku-type = 'Array[gsize]'; }
    when /:i g? error '*'/      { $raku-type = 'Array[N-GError]'; }
    #when /:i g? pixbuf '*'/    { $raku-type = 'N-GObject'; }
    #when /:i g? error '*'/     { $raku-type = 'N-GObject'; }
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
          $raku-type = $h<class-name> ~ '()';
        }

        when 'bitfield' {
          $raku-type = 'UInt';
          $raku-type ~= '()' unless $return-type;
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
}}

#-------------------------------------------------------------------------------
method search-name ( Str $name --> Hash ) {

  my Hash $h = %();
  for @*map-search-list -> $map-name {
#    note "Search for $name in map $map-name" if $*verbose;

    # It is possible that not all hashes are loaded
    next unless $*object-maps{$map-name}:exists
            and ( $*object-maps{$map-name}{$name}:exists 
                  or $*object-maps{$map-name}{$map-name ~ $name}:exists
                );

    # Get the Hash from the object maps
    $h = $*object-maps{$map-name}{$name}
         // $*object-maps{$map-name}{$map-name ~ $name};

    # Add package name to this hash
    $h<raku-package> = $*other-work-data{$map-name}<raku-package>;
    last;
  }

#say Backtrace.new.nice if $name eq 'GdkPixbufPixbuf';
#say "$?LINE: search $name -> $h.gist()" if $name eq 'GdkPixbufPixbuf';

  $h
}

#-------------------------------------------------------------------------------
# Search for names of specific type in object maps 
method search-names ( Str $prefix-name, Str $entry-name, Str $value --> Hash ) {

  my Hash $h = %();
  for @*map-search-list -> $map-name {
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
      $h{$name}<raku-package> = $*other-work-data{$map-name}<raku-package>;
    }

    last if ?$h;
  }

#say "$?LINE: search names for $entry-name -> $h.gist()";

  $h
}

#-------------------------------------------------------------------------------
# Search for names of specific type in object maps 
method search-entries ( Str $entry-name, Str $value --> Hash ) {

  my Hash $h = %();
  for @*map-search-list -> $map-name {
    note "Search for entries in map $map-name where field $entry-name ≡? $value"
      if $*verbose;
    # It is possible that not all hashes are loaded
    next unless $*object-maps{$map-name}:exists;

    for $*object-maps{$map-name}.kv -> $name, $value-hash {
      next unless $value-hash{$entry-name}:exists;

      next unless $value-hash{$entry-name} eq $value;
      $h{$name} = $value-hash;

      # Add package name to this hash
      $h{$name}<raku-package> = $*other-work-data{$map-name}<raku-package>;
    }

    last if ?$h;
  }

#say "$?LINE: search entries for $entry-name -> $h.gist()";

  $h
}
