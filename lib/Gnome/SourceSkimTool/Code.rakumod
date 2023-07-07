
use Gnome::SourceSkimTool::ConstEnumType;
use Gnome::SourceSkimTool::SearchAndSubstitute;
use Gnome::SourceSkimTool::Doc;

use XML;
use XML::XPath;
use JSON::Fast;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::Code:auth<github:MARTIMM>;

has Gnome::SourceSkimTool::SearchAndSubstitute $!sas;
has Gnome::SourceSkimTool::Doc $!grd;

has XML::XPath $!xpath;

#-------------------------------------------------------------------------------
submethod BUILD ( XML::XPath :$!xpath ) {

  $!grd .= new;
  $!sas .= new;
}

#-------------------------------------------------------------------------------
method set-unit ( XML::Element $element --> Str ) {

  my Str $also = '';
  my Str $ctype = $element.attribs<c:type>;
  my Hash $h = $!sas.search-name($ctype);

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
      my Hash $role-h = $!sas.search-name($role);
#note "$?LINE role=$role -> $role-h.gist()";
      $*external-modules.push: $role-h<rname>;
      $also ~= "also does $role-h<rname>;\n" if ?$role-h<rname>;
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
method set-unit-for-file ( --> Str ) {
  qq:to/RAKUMOD/;

    {$!grd.pod-header('Module Imports')}
    __MODULE__IMPORTS__
    use Gnome::Glib::GnomeRoutineCaller:api<2>;

    {$!grd.pod-header('Class Declaration');}
    unit class $*work-data<raku-class-name>:auth<github:MARTIMM>:api<2>;
    RAKUMOD
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
  $c = self!generate-methods($element);
  $code ~= $c if ?$c;
  note "Generate methods" if $*verbose and ?$c;

  # Generate functions
  $c = self!generate-functions($element);
  $code ~= $c if ?$c;
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
  }

  #
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
    my Hash $h = $!sas.search-name($ctype);
    my Array $roles = $h<implement-roles>//[];
    for @$roles -> $role {
      my Hash $role-h = $!sas.search-name($role);
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

  $code = $c;

  $code
}

#-------------------------------------------------------------------------------
method make-build-submethod (
  XML::Element $element, XML::XPath $xpath --> Str
) {
  my Str $ctype = $element.attribs<c:type>;
  my Hash $h = $!sas.search-name($ctype);

  my Str $signal-admin = '';
  my Str $role-signals = '';
  my Array $roles = $h<implement-roles> // [];
  for @$roles -> $role {
    my Hash $role-h = $!sas.search-name($role);
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
#  my Hash $h = $!sas.search-name($ctype);
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
  my Hash $hcs = self.get-constructors( $element, $!xpath);
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
    $!xpath.find( 'constructor', :start($element), :to-list);

  for @constructors -> $cn {
    # Skip deprecated constructors
    next if $cn.attribs<deprecated>:exists and $cn.attribs<deprecated> eq '1';

    my ( $function-name, %h) = self!get-method-data( $cn, :build, :$xpath);
    $hcs{$function-name} = %h;
  }

  $hcs
}

#-------------------------------------------------------------------------------
method !generate-constructors ( Hash $hcs --> Str ) {

  my Str $sub-prefix = $*work-data<sub-prefix>;
  my Str $code = qq:to/EOSUB/;

    {SEPARATOR( 'Constructors', 2);}
    EOSUB

  for $hcs.keys.sort -> $function-name {
    # Get a list of types for the arguments
    my $par-list = '';
    for @($hcs{$function-name}<parameters>) -> $parameter {
      # Enumerations and bitfields are returned as GEnum:Name and GFlag:Name
      my ( $rnt0, $rnt1) = $parameter<raku-ntype>.split(':');
      $par-list ~= ", $rnt0";
    }

    # Remove first comma
    $par-list ~~ s/^ . //;
    my Str $parameters = ?$par-list ?? ":parameters\(\[$par-list\]\)," !! '';

    # Remove prefix from routine
    my Str $hash-fname = $function-name;
    $hash-fname ~~ s/^ $sub-prefix //;

    # Enumerations and bitfields are returned as GEnum:Name and GFlag:Name
    my ( $rnt0, $rnt1) = $hcs{$function-name}<return-raku-ntype>.split(':');
    if ?$rnt1 {
#TM:1:$hash-fname
    $code ~= [~] '  ', $hash-fname, ' => %( :type(Constructor),',
                 ':returns(', $rnt0, '), ',
                 ':type-name(', $rnt1, '), ',
                 $parameters, ")\n";
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
    $code ~= [~] '  ', $hash-fname, ' => %( :type(Constructor),',
                 ':returns(', $rnt0, '), ',
                 $parameters, ")\n";
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
method !generate-methods ( XML::Element $element --> Str ) {

#  my Str $ctype = $element.attribs<c:type>;
#  my Hash $h = $!sas.search-name($ctype);
#  my Str $symbol-prefix = $h<symbol-prefix> // $h<c:symbol-prefix> // '';
  my Str $symbol-prefix = $*work-data<sub-prefix>;

  # Get all methods in this class
  my Hash $hcs = self!get-methods($element);
  return '' unless ?$hcs;

  my Str $code = qq:to/EOSUB/;

    {SEPARATOR( 'Methods', 2);}
    EOSUB

  for $hcs.keys.sort -> $function-name {
    my Hash $curr-function := $hcs{$function-name};

    # get method name, drop the prefix
    my Str $hash-fname = $function-name;
    $hash-fname ~~ s/^ $symbol-prefix //;

    # get parameter lists
    my Str $par-list = '';
    my Bool $first-param = True;

    for @($curr-function<parameters>) -> $parameter {

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
        $par-list ~= ", $rnt0";
      }
    }

    # Remove first comma and space when there is only one parameter
    $par-list ~~ s/^ . //;
    $par-list ~~ s/^ . // unless $par-list ~~ m/ \, /;
    $par-list = ?$par-list ?? [~] ' :parameters([', $par-list, ']),' !! '';

    # Return type
    my $xtype = $curr-function<return-raku-rtype>;
    my Str $returns = '';

    # Enumerations and bitfields are returned as GEnum:Name and GFlag:Name
    my ( $rnt0, $rnt1) = $hcs{$function-name}<return-raku-ntype>.split(':');
    if ?$rnt1 {
      $returns = " :returns\($rnt0\), :type-name\($rnt1\),";
    }

    elsif ?$rnt0 and $xtype ne 'void' {
      $returns = " :returns\($rnt0\),";
    }

#note "$?LINE $hash-fname";
#note "$?LINE $returns";
#note "$?LINE $par-list";

    $code ~= [~] '  ', $hash-fname, ' => %(', $returns, $par-list, ")\n";
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
method !get-methods ( XML::Element $element --> Hash ) {
  my Hash $hms = %();

  my @methods = $!xpath.find( 'method', :start($element), :to-list);

  for @methods -> $cn {
    # Skip deprecated methods
    next if $cn.attribs<deprecated>:exists and $cn.attribs<deprecated> eq '1';

    my ( $function-name, %h) =
      self!get-method-data( $cn, :!build, :xpath($!xpath));
    $hms{$function-name} = %h;
  }

  $hms
}

#-------------------------------------------------------------------------------
method !generate-functions ( XML::Element $element --> Str ) {

  my Str $symbol-prefix = $*work-data<sub-prefix>;

  # Get all functions in this class
  my Hash $hcs = self!get-functions($element);
  return '' unless ?$hcs;

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

    for @($curr-function<parameters>) -> $parameter {
#      self!get-types(
#        $parameter, #$raku-list, 
#        $call-list, #$items-doc,
#        @rv-list #, $returns-doc
#      );

      # Get a list of types for the arguments
      $par-list ~= ", $parameter<raku-ntype>";
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
    $code ~=
      [~] '  ', $hash-fname, ' => %( :type(Function),', $returns, $par-list, ")\n";
  }

  $code
}

#-------------------------------------------------------------------------------
method !get-functions ( XML::Element $element --> Hash ) {
  my Hash $hms = %();

  my @methods = $!xpath.find( 'function', :start($element), :to-list);

  for @methods -> $cn {
    # Skip deprecated methods
    next if $cn.attribs<deprecated>:exists and $cn.attribs<deprecated> eq '1';

    my ( $function-name, %h) =
      self!get-method-data( $cn, :!build, :xpath($!xpath));
    $hms{$function-name} = %h;
  }

  $hms
}

#-------------------------------------------------------------------------------
method generate-enumerations-code ( Array :$enum-names is copy = [] --> Str ) {

  # Don't look enum names up if array is provided
  $enum-names = self!get-enumeration-names unless ?$enum-names;

  # Return empty string if no enums found.
  return '' unless ?$enum-names;
#note "$?LINE e names: $enum-names.gist()";

  # Open enumerations file for xpath
  my Str $file = $*work-data<gir-module-path> ~ 'repo-enumeration.gir';
  my XML::XPath $e-xpath .= new(:$file);

#  my Str $symbol-prefix = $*work-data<sub-prefix>;
  my Str $code = qq:to/EOENUM/;
    {HLSEPARATOR}
    {SEPARATOR('Enumerations');}
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
    my XML::Element $e = $e-xpath.find(
      '//enumeration[@name="' ~ $name ~ '"]', :!to-list
    );

    $code ~= qq:to/EOENUM/;
      {HLSEPARATOR}
      #TE:0:$enum-name
      enum $enum-name is export \<
      EOENUM

#    my Str $edoc =
#      ($e-xpath.find( 'doc/text()', :start($e), :!to-list) // '').Str;
#    my Str $s = self.modify-text($edoc);
#    $doc = self.cleanup($s);

    my Str $member-name-list = '';
    my @members = $e-xpath.find( 'member', :start($e), :to-list);
    for @members -> $m {
      $member-name-list ~= ' ' ~ $m.attribs<c:identifier>;
    }

    $code ~= qq:to/EOENUM/;
        $member-name-list
      \>;

      EOENUM
  }
#note "$?LINE $code";
#exit;
  $code
}

#-------------------------------------------------------------------------------
# When in a class the enumerations are found in separate files. To find the
# correct file, look them up using the filename of the current class. Then use
# that name to find the enumeration names having the same filename. The filename
# is set in the field 'class-file'.
method !get-enumeration-names ( --> Array ) {

  # Get all enumerations for this class
  my $name = $*work-data<gnome-name>;

  # First get the name of the file of this class
  my Hash $h0 = $!sas.search-name($name);
  return [] unless ?$h0;

  my Str $class-file = $h0<class-file>;

  # Now get all other types defined in this class file
  my Hash $h1 = $!sas.search-entries( 'class-file', $class-file);

  # Keep all enumeration names
  my Array $enum-names = [];
  for $h1.kv -> $k, $v {
#note $?LINE $k, $v<gir-type>";
    $enum-names.push: $k if $v<gir-type> eq 'enumeration';
  }

  $enum-names
}

#-------------------------------------------------------------------------------
method generate-bitfield-code ( Array :$bitfield-names is copy = [] --> Str ) {

  # Don't look enum names up if array is provided
  $bitfield-names = self!get-bitfield-names unless ?$bitfield-names;

  # Return empty string if no enums found.
  return '' unless ?$bitfield-names;
#note "$?LINE e names: $bitfield-names.gist()";

  # Open bitfields file for xpath
  my Str $file = $*work-data<gir-module-path> ~ 'repo-bitfield.gir';
  my XML::XPath $e-xpath .= new(:$file);

#  my Str $symbol-prefix = $*work-data<sub-prefix>;
  my Str $code = qq:to/EOENUM/;
    {HLSEPARATOR}
    {SEPARATOR('Bitfields');}
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

    # Get the XML element of the bitfield data
    my XML::Element $e = $e-xpath.find(
      '//bitfield[@name="' ~ $name ~ '"]', :!to-list
    );

    $code ~= qq:to/EOENUM/;
      {HLSEPARATOR}
      #TE:0:$bitfield-name
      enum $bitfield-name is export \(
      EOENUM

#    my Str $edoc =
#      ($e-xpath.find( 'doc/text()', :start($e), :!to-list) // '').Str;
#    my Str $s = self.modify-text($edoc);
#    $doc = self.cleanup($s);

    my Str $member-name-list = '';
    my @members = $e-xpath.find( 'member', :start($e), :to-list);
    my @l = ();
    for @members -> $m {
      @l.push: [~] ':', $m.attribs<c:identifier>, '(', $m.attribs<value>, ')';
    }

    $code ~= @l.join(', ') ~ "\n\);\n";
  }
#note "$?LINE $code";
#exit;
  $code
}

#-------------------------------------------------------------------------------
method !get-bitfield-names ( --> Array ) {

  # Get all bitfields for this class
  my $name = $*work-data<gnome-name>;

  # First get the name of the file of this class
  my Hash $h0 = $!sas.search-name($name);
  return [] unless ?$h0;

  my Str $class-file = $h0<class-file>;

  # Now get all other types defined in this class file
  my Hash $h1 = $!sas.search-entries( 'class-file', $class-file);

  # Keep all bitfield names
  my Array $bitfield-names = [];
  for $h1.kv -> $k, $v {
#note $?LINE $k, $v<gir-type>";
    $bitfield-names.push: $k if $v<gir-type> eq 'bitfield';
  }

  $bitfield-names
}

#-------------------------------------------------------------------------------
method generate-structure ( XML::Element $element, XML::XPath $xpath ) {

  my Str $name = $*work-data<gnome-name>;
  my Hash $h0 = $!sas.search-name($name);
  my Str $struct-name = $h0<sname>;

#TL:1:$struct-name:
#TT:1:$struct-name:
  my Str $code = qq:to/RAKUMOD/;
    use v6;
    RAKUMOD

  my @fields = $xpath.find( 'field', :start($element), :to-list);
  if ?@fields {
    my Str ( $tweak-pars, $build-pars, $tweak-ass, $build-ass) = '' xx 4;

    $code ~= qq:to/EOREC/;

      {$!grd.pod-header('Module Imports')}
      __MODULE__IMPORTS__

      {$!grd.pod-header('Record Structure')}
      unit class $struct-name is export is repr\('CStruct'):api<2>;

      EOREC

    for @fields -> $field {
      my $field-name = $field.attribs<name>;
      my Str ( $type, $raku-ntype, $raku-rtype) = self!get-type($field);

      # Enumerations and bitfields are returned as GEnum:Name and GFlag:Name
      my Str ( $rnt0, $rnt1) = $raku-ntype.split(':');
      if ?$rnt1 {
        $code ~= "has $rnt0 \$.$field-name;           # $rnt1\n";
      }

      else {
        $code ~= "has $rnt0 \$.$field-name;\n";
      }

      if $raku-ntype eq 'N-GObject' {
        $tweak-pars ~= "$raku-ntype :\$$field-name, ";
        $tweak-ass ~= "  \$!$field-name := \$$field-name if ?\$$field-name;\n";
      }

      else {
        $build-pars ~= "$rnt0 :\$$field-name, ";
        if $rnt0 eq 'GEnum' {
          $build-ass ~=
            "  \$!$field-name = \$$field-name.value if ?\$$field-name;\n";
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

        method COERCE \( \$no --> $struct-name \) \{
          note "Coercing from \{\$no.^name\} to ", self.^name if \$Gnome::N::x-debug;
          nativecast\( $struct-name, \$no\)
        \}
        EOREC
    }

#    $code ~= "\n\n";
    $*external-modules.push: 'Gnome::N::X';
    $code = self.substitute-MODULE-IMPORTS($code);
  }

  else {
    $code ~= qq:to/EOREC/;
      {$!grd.pod-header('Record Structure')}
      # This is an opaque type of which fields are not available.
      unit class $struct-name is export is repr\('CPointer');

      EOREC
  }

  note "Save record structure in $struct-name";
  my Str $path = $*work-data<raku-module-file>.IO.dirname.Str;
  "$path/$struct-name.rakumod".IO.spurt($code);
  
  $*external-modules.push: $struct-name;
}

#-------------------------------------------------------------------------------
# A structure consists of fields. Only then there is a structure
method generate-union ( XML::Element $element, XML::XPath $xpath ) {
  my @fields = $xpath.find( 'field', :start($element), :to-list);
  return '' unless ?@fields;

  my Str $name = $*work-data<gnome-name>;
  my Hash $h0 = $!sas.search-name($name);
  my Str $struct-name = $h0<sname>;

#TL:1:$struct-name:
#TT:1:$struct-name:
  my Str $code = qq:to/RAKUMOD/;
    use v6;

    {$!grd.pod-header('Module Imports')}
    __MODULE__IMPORTS__

    {$!grd.pod-header('Union Structure')}
    unit class $struct-name is export is repr\('CUnion'):api<2>;

    RAKUMOD

  for @fields -> $field {
    my $field-name = $field.attribs<name>;
    my Str ( $type, $raku-ntype, $raku-rtype) = self!get-type($field);

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

    method COERCE \( \$no --> $struct-name \) \{
      note "Coercing from \{\$no.^name\} to ", self.^name if \$Gnome::N::x-debug;
      nativecast\( $struct-name, \$no\)
    \}
    
    RAKUMOD

  $*external-modules.push: 'Gnome::N::X';
  $code = self.substitute-MODULE-IMPORTS($code);

  note "Save union structure in $struct-name";
  my Str $path = $*work-data<raku-module-file>.IO.dirname.Str;
  "$path/$struct-name.rakumod".IO.spurt($code);
  
  $*external-modules.push: $struct-name;
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
#  my Hash $h = $!sas.search-name($ctype);

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
      if $m ~~ m/ '::' [ Gtk || Gdk ] / {
        $import ~= "use $m\:api\<2\>;\n";
      }

      else {
        # Other modules may need name changes
        $import ~= "use $m;\n";
      }
    }
  }

  $code ~~ s/__MODULE__IMPORTS__/$import/;

  $code
}

#-------------------------------------------------------------------------------
method !get-method-data (
  XML::Element $e, Bool :$build = False, XML::XPath :$xpath
  --> List
) {
  my Str ( $function-name, $option-name);

  $option-name = $function-name = $e.attribs<c:identifier>;
  my Str $sub-prefix = $*work-data<sub-prefix>;

  # Option names are used in BUILD only
  if $build {
    # Constructors have '_new' in the name. To get a name for the build options
    # remove the subroutine prefix and the 'new_' string from the subroutine
    # name.
    $option-name ~~ s/^ $sub-prefix new '_'? //;

    # Remove any other prefix ending in '_'.
    my Int $last-u = $option-name.rindex('_');
    $option-name .= substr($last-u + 1) if $last-u.defined;

    # When nothing is left, mark the option as a default.
    $option-name = '__DEFAULT__' if $option-name ~~ m/^ \s* $/;
  }

  my XML::Element $rvalue = $xpath.find( 'return-value', :start($e));
  my Str $rv-transfer-ownership = $rvalue.attribs<transfer-ownership>;
  my Str ( $rv-type, $return-raku-ntype, $return-raku-rtype) =
      self!get-type($rvalue);

  # Get all parameters. Mostly the instance parameters come first
  # but I am not certain.
  my @parameters = ();
  my @prmtrs = $xpath.find(
    'parameters/instance-parameter | parameters/parameter',
    :start($e), :to-list
  );

  for @prmtrs -> $p {
    my Str ( $type, $raku-ntype, $raku-rtype) = self!get-type($p);
    my Hash $attribs = $p.attribs;
    my Str $parameter-name = $attribs<name>;
    $parameter-name ~~ s:g/ '_' /-/;

    my Hash $ph = %(
      :name($parameter-name), :transfer-ownership($attribs<transfer-ownership>),
      :$type, :$raku-ntype, :$raku-rtype
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
      :$option-name, :@parameters,
      :$rv-type, :$return-raku-ntype, :$return-raku-rtype,
      :$rv-transfer-ownership,
    )
  );
}

#-------------------------------------------------------------------------------
method !get-type ( XML::Element $e --> List ) {
  my Str ( $type, $raku-ntype, $raku-rtype) = '' xx 3;
  for $e.nodes -> $n {
    next if $n ~~ XML::Text;
    with $n.name {
      when 'type' {
        $type = $n.attribs<c:type> // $n.attribs<name>;
        $raku-ntype = $!sas.convert-ntype($type);
        $raku-rtype = $!sas.convert-rtype($type);
      }

      when 'array' {
        # Sometimes there is no 'c:type', assume an array of strings
        $type = $n.attribs<c:type> // 'gchar**';
        $raku-ntype = $!sas.convert-ntype($type);
        $raku-rtype = $!sas.convert-rtype($type);
      }
    }
  }

  ( $type, $raku-ntype, $raku-rtype)
}

#`{{
#-------------------------------------------------------------------------------
method !get-types (
  Hash $parameter,
#  Str $raku-list,
   Str $call-list,
#  Str $items-doc is rw,
   @rv-list,
#  Str $returns-doc is rw
  --> Hash
) {

#  my Str $own = '';
  my Int $a-count = 0;
  my Hash $result = %();

  given my $xtype = $parameter<raku-ntype> {
    when 'N-GObject' {
#      $raku-list ~= ", $parameter<raku-rtype> \$$parameter<name>";
#      $call-list ~= ", \$$parameter<name>";

#      $result<raku-list> = ", $parameter<raku-rtype> \$$parameter<name>";
      $result<call-list> = ", \$$parameter<name>";

#      $own = "\(transfer ownership: $parameter<transfer-ownership>\) "
#        if ?$parameter<transfer-ownership> and
#          $parameter<transfer-ownership> ne 'none';

#      $result<items-doc> = "=item \$$parameter<name>; $own$parameter<doc>\n";
    }

    when 'CArray[Str]' {
#      $raku-list ~= ", Array[Str] \$$parameter<name>";
#      $call-list ~= ", \$ca$a-count";

#      $result<raku-list> = ", $parameter<raku-rtype> \$$parameter<name>";
      $result<call-list> = ", \$$parameter<name>";

      $a-count++;

#      $own = "\(transfer ownership: $parameter<transfer-ownership>\) "
#        if ?$parameter<transfer-ownership> and
#          $parameter<transfer-ownership> ne 'none';
#      $items-doc ~= "=item \$$parameter<name>; $own$parameter<doc>\n";

#      $result<items-doc> = "=item \$$parameter<name>; $own$parameter<doc>\n";
    }

    when 'CArray[gint]' {
#            $raku-list ~= ", CArray[gint] \$$parameter<name>";
#            my $ntype = 'gint';
#      $ntype ~~ s:g/ [const || \s+ || '*'] //;
      @rv-list.push: "\$$parameter<name>";
#      $call-list ~= ", my gint \$$parameter<name>";

#      $result<raku-list> = ", $parameter<raku-rtype> \$$parameter<name>";
      $result<call-list> = ", \$$parameter<name>";
      $result<rv-list> = "\$$parameter<name>";

#      $returns-doc ~= "=item \$$parameter<name>; $own$parameter<doc>\n";

#      $result<items-doc> = "=item \$$parameter<name>; $own$parameter<doc>\n";
    }

    default {
#      $raku-list ~= ", $parameter<raku-rtype> \$$parameter<name>";
#      $call-list ~= ", \$$parameter<name>";

#      $result<raku-list> = ", $parameter<raku-rtype> \$$parameter<name>";
      $result<call-list> = ", \$$parameter<name>";

#      $own = "\(transfer ownership: $parameter<transfer-ownership>\) "
#        if ?$parameter<transfer-ownership> and
#          $parameter<transfer-ownership> ne 'none';
#      $items-doc ~= "=item \$$parameter<name>; $own$parameter<doc>\n";

#      $result<items-doc> = "=item \$$parameter<name>; $own$parameter<doc>\n";
    }
  }

  $result  
}
}}