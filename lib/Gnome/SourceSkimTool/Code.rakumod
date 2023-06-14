
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
method set-unit-code ( XML::Element $element --> Str ) {

  my Str $also = '';
  my Str $ctype = $element.attribs<c:type>;
  my Hash $h = $!sas.search-name($ctype);

  # Check for parent class. There are never more than one.
  my Str $parent = $h<parent-raku-name> // '';
  if ?$parent {
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
    use Gnome::Glib::GnomeRoutineCaller:api('gir');

    {HLSEPARATOR}
    {SEPARATOR(($is-role ?? 'Role' !! 'Class') ~ ' Declaration');}
    {HLSEPARATOR}
    unit {$is-role ?? 'role' !! 'class'} $*work-data<raku-class-name>:auth<github:MARTIMM>:api('gir');
    $also
    RAKUMOD

  $code
}

#-------------------------------------------------------------------------------
method generate-build (
  XML::Element $element, Hash $sig-info
  --> List
) {

#  my Str $ctype = $element.attribs<c:type>;
#  my Hash $h = $!sas.search-name($ctype);

  my Hash $hcs = self!get-constructors($element);
  my Str $doc = self!make-build-doc( $element, $hcs);
  my Str $code = self!make-build-submethod( $element, $hcs, $sig-info);
#`{{
  $code ~= qq:to/RAKUMOD/;

    {HLSEPARATOR}
    {SEPARATOR('Native Routine Definitions');}
    {HLSEPARATOR}
    my Hash \$methods = \%\(
    RAKUMOD

  $code ~= self!generate-constructor-code($hcs) if ?$hcs;
}}
  ( $doc, $code)
}

#-------------------------------------------------------------------------------
method generate-callables-code ( XML::Element $element --> Str ) {
  
  my Str $code = '';
  
  note "Generate constructors" if $*verbose;  
  my Hash $hcs = self!get-constructors($element);
  $code ~= self!generate-constructor-code($hcs) if ?$hcs;
note "$?LINE constr code? ", ?$code;

  note "Generate methods" if $*verbose;  
  $code ~= self.generate-methods-code($element);
note "$?LINE meth code? ", ?$code;

  note "Generate functions" if $*verbose;  
  $code ~= self.generate-functions-code($element);
note "$?LINE func code? ", ?$code;

  # if there are constructors, methods or functions, add the structure and
  # the fallback routine
  if ?$code {
    $code = qq:to/RAKUMOD/;

      {HLSEPARATOR}
      {SEPARATOR('Native Routine Definitions');}
      {HLSEPARATOR}
      my Hash \$methods = \%\(
      $code
      );

      {HLSEPARATOR}
      RAKUMOD
  
    $code ~= q:to/RAKUMOD/;
      # This method is recognized in class Gnome::N::TopLevelClassSupport.
      method _fallback-v2 (
        Str $n, Bool $_fallback-v2-ok is rw, *@arguments
      ) {
        my Str $name = S:g/ '-' /_/ with $n;
        if $methods{$name}:exists {
          my $native-object = self.get-native-object-no-reffing;
          $_fallback-v2-ok = True;
          return $!routine-caller.call-native-sub(
            $name, @arguments, $methods, :$native-object
          );
        }

        else {
          callsame;
        }
      }

      RAKUMOD
  }

  $code
}

#-------------------------------------------------------------------------------
method !make-build-doc ( XML::Element $element, Hash $hcs --> Str ) {
  my Str $doc = qq:to/EOBUILD/;

    {HLSEPARATOR}
    =begin pod
    =head1 Methods

    {$!grd.pod-header('Class Initialization')}
    #TM:1:new:
    =head2 new
    EOBUILD

  my Str $build-doc;
  for $hcs.keys.sort -> $function-name {
    $build-doc = '';

    my Str $option-name = $hcs{$function-name}<option-name>;
    
    # If $option-name is a dash, the new C-function has no special name.
    # It can have parameters. If so, take that name as an option name instead.
    # It will help to replace the text in the documentation noted as '@var'.
    if $option-name eq '-' {
      if $hcs{$function-name}<parameters>.elems {
        $option-name = $hcs{$function-name}<parameters>[0]<name>;
        $hcs{$function-name}<option-name> = $option-name;
      }
    }

    $build-doc ~= "\n=head3 :$option-name\n\n";
    $build-doc ~= "____FUNCTIONDOC___\n\n";
    $build-doc ~= "  multi method new (";

    my Hash $variable-map = %();
    if $hcs{$function-name}<parameters>.elems {
      my Bool $first = True;
      for @($hcs{$function-name}<parameters>) -> $parameter {
        if $first {
          $build-doc ~= " $parameter<raku-rtype> :\$$option-name!";
          $variable-map{$parameter<name>} = $option-name;
          $first = False;
        }

        else {
          $build-doc ~=  ", $parameter<raku-rtype> :\$$parameter<name>";
        }
      }

      $build-doc.chop(1);
      $build-doc ~= " )\n\n";

      $first = True;
      for @($hcs{$function-name}<parameters>) -> $parameter {
        if $first {
          $build-doc ~= "=item :\$$option-name; $parameter<doc>\n";
          $first = False;
        }

        else {
          $build-doc ~= "=item :\$$parameter<name>; $parameter<doc>\n";
        }
      }
    }

    else {
      $build-doc ~= qq:to/EOPOD/;

        =head3 default, no options
        
        $hcs{$function-name}<function-doc>
        
          multi method new ( )
        EOPOD
    }

#    # Add variable map to function data
#    $hcs{$function-name}<variable-map> = $variable-map;

    # Modify variable names in the build doc and replace ____FUNCTIONDOC___
    my Str $d = $!sas.modify-build-variables(
      $hcs{$function-name}<function-doc>, $variable-map
    );
    $build-doc ~~ s/ '____FUNCTIONDOC___' /$d/;
    $doc ~= $build-doc;
  }


  # Finish with standard options
  $doc ~= qq:to/EOBUILD/;

    =head3 :native-object

    Create an object using a native object from elsewhere. See also B<Gnome::N::TopLevelSupportClass>.

      multi method new \( N-GObject :\$native-object! )

    EOBUILD

  # Build id only used for widgets. We can test for inheritable because
  # it intices the same set of objects
  my Str $ctype = $element.attribs<c:type>;
  my Hash $h = $!sas.search-name($ctype);
  if $h<inheritable> {
    $doc ~= qq:to/EOBUILD/;

      =head3 :build-id

      Create an object using a native object from a builder. See also B<Gnome::GObject::Object>.

        multi method new \( Str :\$build-id! )
      
      =end pod

      EOBUILD
  }

  $doc
}

#-------------------------------------------------------------------------------
method !make-build-submethod (
  XML::Element $element, Hash $hcs, Hash $sig-info --> Str
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
  if ? $role-signals or ? $sig-info<doc> {
    my Str $sig-list = '';
    if ? $sig-info<doc> {
      my Hash $signal-levels = %();
      for $sig-info<signals>.keys -> $signal-name {
        my Str $level = $sig-info<signals>{$signal-name}<parameters>.elems.Str;
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
  for $hcs.keys.sort -> $function-name {
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
              \$no = self\._fallback-v2\( 'new', my Bool \$x, ... \);
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
method !get-constructors ( XML::Element $element --> Hash ) {
  my Hash $hcs = %();

  my @constructors =
    $!xpath.find( 'constructor', :start($element), :to-list);

  for @constructors -> $cn {
    # Skip deprecated constructors
    next if $cn.attribs<deprecated>:exists and $cn.attribs<deprecated> eq '1';

    my ( $function-name, %h) =
      $!sas.get-method-data( $cn, :build, :xpath($!xpath));
    $hcs{$function-name} = %h;
  }

  $hcs
}


#-------------------------------------------------------------------------------
method !generate-constructor-code ( Hash $hcs --> Str ) {

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
    my Str $parameters = "\n  :parameters\(\[$par-list\]\)," if ?$par-list;

    # Remove prefix from routine
    my Str $hash-fname = $function-name;
    $hash-fname ~~ s/^ $sub-prefix //;

    # Enumerations and bitfields are returned as GEnum:Name and GFlag:Name
    my ( $rnt0, $rnt1) = $hcs{$function-name}<return-raku-ntype>.split(':');
    if ?$rnt1 {
      $code ~= qq:to/EOSUB/;
        #TM:1:$hash-fname
        $hash-fname =\> \%\(
          :type\(Constructor\),
          :returns\($rnt0\),
          :type-name\($rnt1\),$parameters
        ),

      EOSUB
    }

    else {
      $code ~= qq:to/EOSUB/;
        #TM:1:$hash-fname
        $hash-fname =\> \%\(
          :type\(Constructor\),
          :returns\($rnt0\),$parameters
        ),

      EOSUB
    }
  }

  $code
}

#-------------------------------------------------------------------------------
method generate-methods-code ( XML::Element $element --> Str ) {

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
    $par-list = ?$par-list
              ?? [~] "\n", '    :parameters([', $par-list, ']),'
              !! '';

    # Return type
    my $xtype = $curr-function<return-raku-rtype>;
    my Str $returns = '';

    # Enumerations and bitfields are returned as GEnum:Name and GFlag:Name
    my ( $rnt0, $rnt1) = $hcs{$function-name}<return-raku-ntype>.split(':');
    if ?$rnt1 {
      $returns = "\n    :returns\($rnt0\),\n    :type-name\($rnt1\),";
    }

    elsif ?$rnt0 and $xtype ne 'void' {
      $returns = "\n    :returns\($rnt0\),";
    }

#note "$?LINE $hash-fname";
#note "$?LINE $returns";
#note "$?LINE $par-list";

    $code ~= qq:to/EOSUB/;
      #TM:0:$hash-fname
      $hash-fname =\> \%\($returns$par-list
      ),

    EOSUB
  }

  $code
}

#-------------------------------------------------------------------------------
method generate-methods ( XML::Element $element --> List ) {

  my Str $ctype = $element.attribs<c:type>;
  my Hash $h = $!sas.search-name($ctype);
  my Bool $is-leaf = $h<leaf> // False;
#  my Str $symbol-prefix = $h<symbol-prefix> // $h<c:symbol-prefix> // '';
  my Str $symbol-prefix = $*work-data<sub-prefix>;

  # Get all methods in this class
  my Hash $hcs = self!get-methods($element);
  return ('','') unless ?$hcs;

  my Str $code = qq:to/EOSUB/;
    {SEPARATOR( 'Methods', 2);}
    EOSUB

  my Str $doc = qq:to/EOSUB/;
    {HLSEPARATOR}
    {SEPARATOR('Methods');}
    {HLSEPARATOR}
    =begin pod
    =head1 Methods
    =end pod

    EOSUB

  for $hcs.keys.sort -> $function-name {
    my Hash $curr-function := $hcs{$function-name};

    # get method name, drop the prefix and substitute '_'
    my Str $method-name = $function-name;
    $method-name ~~ s/^ $symbol-prefix //;
    # keep this version for later
    my Str $hash-fname = $method-name;
    $method-name ~~ s:g/ '_' /-/;

    my Str $method-doc = $curr-function<function-doc>;
    $method-doc = "No documentation of method.\n" unless ?$method-doc;

    # get parameter lists
    my Str (
      $par-list, $raku-list, $call-list, $items-doc, 
      $own, $returns-doc, 
    ) =  '' xx 6;
    my @rv-list = ();

    my Bool $first-param = True;
    for @($curr-function<parameters>) -> $parameter {
      $!sas.get-types(
        $parameter, $raku-list,
        $call-list, $items-doc,
        @rv-list, $returns-doc
      );

      # Get a list of types for the arguments but skip the first native type
      if $first-param {
        $first-param = False;
      }

      else {
        # Enumerations and bitfields are returned as GEnum:Name and GFlag:Name
        my ( $rnt0, $rnt1) = $parameter<raku-ntype>.split(':');
        $par-list ~= ", $rnt0";
      }
    }

    # Remove first comma and space when there is only one parameter
    $par-list ~~ s/^ . //;
    $par-list ~~ s/^ . // unless $par-list ~~ m/ \, /;
    $par-list = ?$par-list
              ?? [~] "\n", '    :parameters([', $par-list, ']),'
              !! '';

    my $xtype = $curr-function<return-raku-rtype>;
    if ?$xtype and $xtype ne 'void' {
      $raku-list ~= "  --> $xtype";
      $own = '';
      $own = "\(transfer ownership: $curr-function<transfer-ownership>\) "
        if ?$curr-function<transfer-ownership> and
            $curr-function<transfer-ownership> ne 'none';

      # Check if there is info about the return value
      if ?$curr-function<rv-doc> {
        $returns-doc = "\nReturn value; $own$curr-function<rv-doc>\n";
      }

      elsif $raku-list ~~ / '-->' / {
        $returns-doc =
          "\nReturn value; No documentation about its value and use\n";
      }
    }

    # Assumed that there are no multiple methods to return values. I.e not
    # returning an array and pointer arguments to receive values in those vars.
    elsif ?@rv-list {
      $returns-doc = "Returns a List holding the values\n$returns-doc";
      #$return-list = [~] '  (', @rv-list.join(', '), ")\n";
      $raku-list ~= "  --> List";
    }

    # remove first comma
    $raku-list ~~ s/^ . //;
#`{{
    my Str $nobject-retrieve;
    if $is-leaf {
      $nobject-retrieve = 'self._get-native-object-no-reffing';
    }

    else {
      $nobject-retrieve = "self._f\('$*work-data<gnome-name>'\)";
    }
}}
    $doc ~= qq:to/EOSUB/;
      {HLSEPARATOR}
      =begin pod
      =head2 $method-name

      $method-doc

      =begin code
      method $method-name \(
       $raku-list
      \)
      =end code

      $items-doc
      $returns-doc
      =end pod
      EOSUB


    # Return type
    # Enumerations and bitfields are returned as GEnum:Name and GFlag:Name
    my Str $returns;
    my ( $rnt0, $rnt1) = $hcs{$function-name}<return-raku-ntype>.split(':');
    if ?$rnt1 {
      $returns = "\n    :returns\($rnt0\),\n    :type-name\($rnt1\),";
    }

    elsif ?$rnt0 and $xtype ne 'void' {
      $returns = "\n    :returns\($rnt0\),";
    }

#`{{
    $xtype = $curr-function<return-raku-ntype>;
    my Str $returns = (?$xtype and $xtype ne 'void' ) 
                    ?? [~] "\n", '    :returns(',
                           $hcs{$function-name}<return-raku-ntype>,
                           '),'
                    !! '';
}}

    $code ~= qq:to/EOSUB/;
      #TM:0:$hash-fname
      $hash-fname =\> \%\($returns$par-list
      ),

    EOSUB
  }

  ( $doc, $code)
}

#-------------------------------------------------------------------------------
method !get-methods ( XML::Element $element --> Hash ) {
  my Hash $hms = %();

  my @methods = $!xpath.find( 'method', :start($element), :to-list);

  for @methods -> $cn {
    # Skip deprecated methods
    next if $cn.attribs<deprecated>:exists and $cn.attribs<deprecated> eq '1';

    my ( $function-name, %h) =
      $!sas.get-method-data( $cn, :!build, :xpath($!xpath));
    $hms{$function-name} = %h;
  }

  $hms
}

#-------------------------------------------------------------------------------
method generate-functions-code ( XML::Element $element --> Str ) {

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
      $par-list, $raku-list, $call-list, $items-doc, $own, $returns-doc, 
    ) =  '' xx 6;
    my @rv-list = ();

    for @($curr-function<parameters>) -> $parameter {
      $!sas.get-types(
        $parameter, $raku-list, 
        $call-list, $items-doc,
        @rv-list, $returns-doc
      );

      # Get a list of types for the arguments
      $par-list ~= ", $parameter<raku-ntype>";
    }

    # Remove first comma and space when there is only one parameter
    $par-list ~~ s/^ . //;
    $par-list ~~ s/^ . // unless $par-list ~~ m/ \, /;
    $par-list = ?$par-list
              ?? [~] "\n", '    :parameters([', $par-list, ']),'
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
    my ( $rnt0, $rnt1) = $hcs{$function-name}<return-raku-ntype>.split(':');
    if ?$rnt1 {
      $returns = "\n    :returns\($rnt0\),\n    :type-name\($rnt1\),";
    }

    elsif ?$rnt0 and $xtype ne 'void' {
      $returns = "\n    :returns\($rnt0\),";
    }

    $code ~= qq:to/EOSUB/;
      #TM:0:$hash-fname
      $hash-fname =\> \%\(
        :type(Function),$returns$par-list
      ),

    EOSUB
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
      $!sas.get-method-data( $cn, :!build, :xpath($!xpath));
    $hms{$function-name} = %h;
  }

  $hms
}

#-------------------------------------------------------------------------------
method generate-enumerations-code ( --> Str ) {

  my Array $enum-names = self!get-enumeration-names;
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
method !get-enumeration-names ( --> Array ) {

  # Get all enumerations for this class
  my $name = $*work-data<gnome-name>;

  # First get the name of the file of this class
  my Hash $h0 = $!sas.search-name($name);
  my Str $class-file = $h0<class-file>;
#note "$?LINE classfile of $name = $class-file";

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
# A structure consists of fields. Only then there is a structure
method generate-structure ( XML::Element $element --> Str ) {
  my @fields = $!xpath.find( 'field', :start($element), :to-list);
  return '' unless ?@fields;

  my Str $name = $*work-data<gnome-name>;
  my Hash $h0 = $!sas.search-name($name);
  my Str $struct-name = $h0<sname>;
  my Str ( $tweak-pars, $build-pars, $tweak-ass, $build-ass) = '' xx 4;

  my Str $code = qq:to/EOREC/;
    {HLSEPARATOR}
    {SEPARATOR('Record Structure');}
    {HLSEPARATOR}
    #TT:1:$struct-name:
    class $struct-name is export is repr\('CStruct') \{
    EOREC

  for @fields -> $field {
    my $field-name = $field.attribs<name>;
    my Str ( $type, $raku-ntype, $raku-rtype) = $!sas.get-doc-type-code($field);

    # Enumerations and bitfields are returned as GEnum:Name and GFlag:Name
    my Str ( $rnt0, $rnt1) = $raku-ntype.split(':');
    if ?$rnt1 {
      $code ~= "  has $rnt0 \$.$field-name;           # $rnt1\n";
    }

    else {
      $code ~= "  has $rnt0 \$.$field-name;\n";
    }

    if $raku-ntype eq 'N-GObject' {
      $tweak-pars ~= "$raku-rtype :\$$field-name, ";
      $tweak-ass ~= "    \$!$field-name := \$$field-name if ?\$$field-name;\n";
    }

    else {
      if $rnt0 eq 'GEnum' {
        $build-pars ~= "$raku-rtype :\$$field-name, ";
        $build-ass ~= "    \$!$field-name = \$$field-name.value if ?\$$field-name;\n";
      }

      else {
        $build-pars ~= "$raku-rtype :\$\!$field-name, ";
      }
    }
  }

  if ?$build-pars {
    $code ~= qq:to/EOREC/;

        submethod BUILD \(
          $build-pars
        \) \{
      $build-ass  \}
      EOREC
  }

  if ?$tweak-pars {
    $code ~= qq:to/EOREC/;

        submethod TWEAK \(
          $tweak-pars
        \) \{
      $tweak-ass  \}

        method COERCE \( \$no --> $struct-name \) \{
          note "Coercing from \{\$no.^name\} to ", self.^name if \$Gnome::N::x-debug;
          nativecast\( $struct-name, \$no\)
        \}
      EOREC
  }

  $code ~= "\}\n\n";

  $code
}

#-------------------------------------------------------------------------------
method generate-signals ( XML::Element $element --> Hash ) {
  my Hash $sig-info = %();
  my Str $doc = '';

  my @signal-info =
     $!xpath.find( 'glib:signal', :start($element), :to-list);

  my Hash $signals = %();
  for @signal-info -> $si {
    my Hash $attribs = $si.attribs;
    next if $attribs<deprecated>:exists and  $attribs<deprecated> == 1;

    # signal documentation
    my Str $signal-name = $attribs<name>;
    my Str $sdoc = $!sas.cleanup(
      $!sas.modify-text(($!xpath.find( 'doc/text()', :start($si)) // '').Str)
    );
    my Hash $curr-signal := $signals{$signal-name} = %(:$sdoc,);
#    $curr-signal = %(:$sdoc,);

    # return value info
    my XML::Element $rvalue = $!xpath.find( 'return-value', :start($si));
    $curr-signal<transfer-ownership> = $rvalue.attribs<transfer-ownership>;

    my Str ( $rv-doc, $rv-type, $return-raku-ntype, $return-raku-rtype) =
      $!sas.get-doc-type( $rvalue, :return-type, :xpath($!xpath));
    $curr-signal<rv-doc> = $rv-doc;
    $curr-signal<rv-type> = $rv-type;
    $curr-signal<return-raku-ntype> = $return-raku-ntype;
    $curr-signal<return-raku-rtype> = $return-raku-rtype;

    # parameter info
    $curr-signal<parameters> = [];
    my @prmtrs =
        $!xpath.find( 'parameters/parameter', :start($si), :to-list);
    for @prmtrs -> $prmtr {
      my Hash $attribs = $prmtr.attribs;
      my $pname = $attribs<name>;
      my $transfer-ownership = $attribs<transfer-ownership>;
      my Str ( $pdoc, $ptype, $raku-ntype, $raku-rtype) =
        $!sas.get-doc-type( $prmtr, :xpath($!xpath));

      $curr-signal<parameters>.push: %(
        :$pname, :$pdoc, :$ptype,
        :$raku-ntype, :$raku-rtype,
        :$transfer-ownership
      );
    }
  }

  # If there are signals, make the docs for it
  if $signals.keys.elems {
    $doc ~= qq:to/EOSIG/;
      {HLSEPARATOR}
      {SEPARATOR('Signal Documentation');}
      {HLSEPARATOR}
      =begin pod
      =head1 Signals
      EOSIG

    for $signals.keys.sort -> $signal-name {
      my Hash $curr-signal := $signals{$signal-name};
      $doc ~= qq:to/EOSIG/;

        {HLPODSEPARATOR}
        =comment #TS:0:$signal-name:
        =head3 $signal-name

        $curr-signal<sdoc>

        =begin code
        method handler \(
        EOSIG

      for @($curr-signal<parameters>) -> $prmtr {
        $doc ~= "  $prmtr<raku-rtype> \$$prmtr<pname>,\n";
      }

      # return value info
      my Str ( $rv-method, $returns-doc ) = ( '', '');

      if ?$curr-signal<return-raku-ntype> and
         $curr-signal<return-raku-ntype> ne 'void' {
        my Str $own = '';
        $own = "\(transfer ownership: $curr-signal<transfer-ownership>\) "
          if ?$curr-signal<transfer-ownership> and
             $curr-signal<transfer-ownership> ne 'none';

        $returns-doc = "\nReturn value; $own$curr-signal<rv-doc>\n";
        $rv-method = "\n  --> $curr-signal<return-raku-ntype>";
      }

      $doc ~= qq:to/EOSIG/;
          Int :\$_handle_id,
          $*work-data<raku-class-name>\(\) :\$_native-object,
          $*work-data<raku-class-name> :\$_widget,
          *\%user-options$rv-method
        )
        =end code

        EOSIG

      for @($curr-signal<parameters>) -> $prmtr {
        my Str $own = ( ?$prmtr<transfer-ownership> and
                        $prmtr<transfer-ownership> ne 'none'
                      ) ?? "\(transfer ownership: $prmtr<transfer-ownership>)"
                        !! '';
        $doc ~= "=item \$$prmtr<pname>; $own$prmtr<pdoc>.\n";
      }

      $doc ~= q:to/EOSIG/;
        =item $_handle_id; the registered event handler id.
        =item $_native-object; The native object provided by the caller wrapped in the Raku object.
        =item $_widget; the object which received the signal.
        =item %user-options; A list of named arguments provided at the C<.register-signal() method from Gnome::GObject::Object>.
        EOSIG
      $doc ~= $returns-doc;

#`{{
      $doc ~= "Return value \(transfer ownership: $curr-signal<return-raku-ntype> \($curr-signal<transfer-ownership>); $curr-signal<rv-doc>\n"
            if $curr-signal<return-raku-ntype> ne 'void';
}}
    }

    $doc ~= "\n=end pod\n\n";
  }

  $sig-info<doc> = $doc;
  $sig-info<signals> = $signals;

  $sig-info
}

#-------------------------------------------------------------------------------
method generate-properties ( XML::Element $element --> Str ) {
  my Str $doc = '';

  my @property-info =
     $!xpath.find( 'property', :start($element), :to-list);

  my Hash $properties = %();
  for @property-info -> $pi {
    my Hash $attribs = $pi.attribs;
    next if $attribs<deprecated>:exists and  $attribs<deprecated> == 1;

    # signal documentation
    my Str $property-name = $attribs<name>;
    my Bool $writable = $attribs<writable>.Bool;

    my Str ( $pgetter, $psetter);
    if $attribs<getter>:exists {
      $pgetter = $attribs<getter>;
      $pgetter ~~ s:g/ '_' /-/;
      $pgetter = "C<.$pgetter\()>";
    }
    if $attribs<setter>:exists {
      $psetter = $attribs<setter>;
      $psetter ~~ s:g/ '_' /-/;
      $psetter = "C<.$psetter\()>";
    }

    my Str $transfer-ownership = $attribs<transfer-ownership>;

    my Str ( $pdoc, $type, $raku-ntype, $raku-rtype, $g-type) =
      $!sas.get-doc-type( $pi, :add-gtype, :xpath($!xpath));

    $properties{$property-name} = %(
      :$pdoc, :$writable, :$type, :$raku-ntype, :$g-type,
      :$pgetter, :$psetter, :$transfer-ownership
    );
  }

  return '' unless $properties.keys.elems;

  $doc ~= qq:to/EOSIG/;

    {HLSEPARATOR}
    {SEPARATOR('Property Documentation');}
    {HLSEPARATOR}
    =begin pod
    =head1 Properties

    Please note that this information is not really necessary to use or know
    about because there are routines to get or set its value for many of
    those properties.
    EOSIG

  for $properties.keys.sort -> $property-name {
    $doc ~= qq:to/EOSIG/;

      {HLPODSEPARATOR}
      =comment #TP:0:$property-name:
      =head3 $property-name
      EOSIG

#say "$?LINE props $property-name: $properties{$property-name}.gist()";

    if $properties{$property-name}<pdoc> ~~ m/^ \s* $/ {
      $doc ~= "\nThere is no documentation for this property\n\n";
    }

    else {
      $doc ~= "\n$properties{$property-name}<pdoc>\n\n";
    }

    $doc ~= "=item B<Gnome::GObject::Value> for this property is $properties{$property-name}<g-type>.\n";

    $doc ~= "=item The native type is $properties{$property-name}<raku-ntype>.\n";

    if $properties{$property-name}<writable> {
      $doc ~= "=item Property is readable and writable\n";
    }

    else {
      $doc ~= "=item Property is readonly\n";
    }

    $doc ~= "=item Getter method is $properties{$property-name}<pgetter>\n"
      if ?$properties{$property-name}<pgetter>;

    $doc ~= "=item Setter method is $properties{$property-name}<psetter>\n"
      if ?$properties{$property-name}<psetter>;
  }

  $doc ~= "\n=end pod\n\n";

  $doc
}

















=finish
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# Old methods
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
method !generate-constructor-code ( Hash $hcs --> Str ) {
  my Str $code = qq:to/EOSUB/;

      {HLSEPARATOR}
      {SEPARATOR('Constructors');}
      EOSUB

  for $hcs.keys.sort -> $function-name {
    my $par-list = '';

    for @($hcs{$function-name}<parameters>) -> $parameter {
      $par-list ~= [~] ', ', $parameter<raku-ntype>, ' $', $parameter<name>;
    }

    # remove first comma
    $par-list ~~ s/^ . //;

    $code ~= qq:to/EOSUB/;
      {HLSEPARATOR}
      #TM:1:$function-name:
      sub $function-name \(
       $par-list --> $hcs{$function-name}<return-raku-ntype>
      \) is native\($*work-data<library>\)
        \{ * \}

      EOSUB
  }

  $code
}

#-------------------------------------------------------------------------------
method generate-method-doc ( XML::Element $element --> List ) {

  my Str $ctype = $element.attribs<c:type>;
  my Hash $h = $!sas.search-name($ctype);
  my Bool $is-leaf = $h<leaf> // False;
#  my Str $symbol-prefix = $h<symbol-prefix> // $h<c:symbol-prefix> // '';
  my Str $symbol-prefix = $*work-data<sub-prefix>;

  # Get all methods in this class
  my Hash $hcs = self!get-methods($element);
  return ('','') unless ?$hcs;

  my Str $code = qq:to/EOSUB/;
    {SEPARATOR( 'Methods', 2);}
    EOSUB

  my Str $doc = qq:to/EOSUB/;
    {HLSEPARATOR}
    {SEPARATOR('Methods');}
    {HLSEPARATOR}
    =begin pod
    =head1 Methods
    =end pod

    EOSUB

  for $hcs.keys.sort -> $function-name {
    my Hash $curr-function := $hcs{$function-name};

    # get method name, drop the prefix and substitute '_'
    my Str $method-name = $function-name;
    $method-name ~~ s/^ $symbol-prefix //;
    # keep this version for later
    my Str $hash-fname = $method-name;
    $method-name ~~ s:g/ '_' /-/;

    my Str $method-doc = $curr-function<function-doc>;
    $method-doc = "No documentation of method.\n" unless ?$method-doc;

    # get parameter lists
    my Str (
      $par-list, $raku-list, $call-list, $items-doc, 
      $own, $returns-doc, 
    ) =  '' xx 6;
    my @rv-list = ();

    my Bool $first-param = True;
    for @($curr-function<parameters>) -> $parameter {
      $!sas.get-types(
        $parameter, $raku-list,
        $call-list, $items-doc,
        @rv-list, $returns-doc
      );

      # Get a list of types for the arguments but skip the first native type
      if $first-param {
        $first-param = False;
      }

      else {
        $par-list ~= ", $parameter<raku-ntype>";
      }
    }

    # Remove first comma and space when there is only one parameter
    $par-list ~~ s/^ . //;
    $par-list ~~ s/^ . // unless $par-list ~~ m/ \, /;
    $par-list = ?$par-list
              ?? [~] "\n", '    :parameters([', $par-list, ']),'
              !! '';

    my $xtype = $curr-function<return-raku-rtype>;
    if ?$xtype and $xtype ne 'void' {
      $raku-list ~= "  --> $xtype";
      $own = '';
      $own = "\(transfer ownership: $curr-function<transfer-ownership>\) "
        if ?$curr-function<transfer-ownership> and
            $curr-function<transfer-ownership> ne 'none';

      # Check if there is info about the return value
      if ?$curr-function<rv-doc> {
        $returns-doc = "\nReturn value; $own$curr-function<rv-doc>\n";
      }

      elsif $raku-list ~~ / '-->' / {
        $returns-doc =
          "\nReturn value; No documentation about its value and use\n";
      }
    }

    # Assumed that there are no multiple methods to return values. I.e not
    # returning an array and pointer arguments to receive values in those vars.
    elsif ?@rv-list {
      $returns-doc = "Returns a List holding the values\n$returns-doc";
      #$return-list = [~] '  (', @rv-list.join(', '), ")\n";
      $raku-list ~= "  --> List";
    }

    # remove first comma
    $raku-list ~~ s/^ . //;
#`{{
    my Str $nobject-retrieve;
    if $is-leaf {
      $nobject-retrieve = 'self._get-native-object-no-reffing';
    }

    else {
      $nobject-retrieve = "self._f\('$*work-data<gnome-name>'\)";
    }
}}
    $doc ~= qq:to/EOSUB/;
      {HLSEPARATOR}
      =begin pod
      =head2 $method-name

      $method-doc

      =begin code
      method $method-name \(
       $raku-list
      \)
      =end code

      $items-doc
      $returns-doc
      =end pod
      EOSUB


    # Return type
    $xtype = $curr-function<return-raku-ntype>;
    my Str $returns = (?$xtype and $xtype ne 'void' ) 
                    ?? [~] "\n", '    :returns(',
                           $hcs{$function-name}<return-raku-ntype>,
                           '),'
                    !! '';

    $code ~= qq:to/EOSUB/;
      #TM:0:$hash-fname
      $hash-fname =\> \%\($returns$par-list
      ),

    EOSUB
  }

  ( $doc, $code)
}

#TODO use this method to get functions from level packages like Glib
#-------------------------------------------------------------------------------
method generate-functions ( XML::Element $element --> List ) {

  # Get all functions for this module
  my Hash $h = $!sas.search-names(
    $*work-data<sub-prefix>, 'gir-type', 'function'
  );
  return ('','') unless ?$h;

  my Str $symbol-prefix = $*work-data<sub-prefix>;
  my Str $code = qq:to/EOSUB/;
    {HLSEPARATOR}
    {SEPARATOR('Functions');}
    {HLSEPARATOR}

    EOSUB

  my Str $doc = qq:to/EOSUB/;
    {HLSEPARATOR}
    {SEPARATOR('Functions');}
    {HLSEPARATOR}
    =begin pod
    =head1 Functions
    =end pod

    EOSUB

  # Open functions file for xpath
  my Str $file = $*work-data<gir-module-path> ~ 'repo-function.gir';
  my XML::XPath $f-xpath .= new(:$file);

  # For each found function, search for info in the XML functions repo
  for $h.keys.sort -> $function-name {
    my Str $name = $function-name;
    my Str $package = $*gnome-package.Str.lc;
    $package ~~ s/ \d+ $//;
    $name ~~ s/^ $package '_' //;
    my Str $xp-search = '//function[@name="' ~ $name ~ '"]';
    my XML::Element $function-element = $f-xpath.find($xp-search);

    # Skip deprecated functions
    next if $function-element.attribs<deprecated>:exists and
            $function-element.attribs<deprecated> eq '1';

    # Skip moved functions
#    next if $function-element.attribs<moved-to>:exists and
#            $function-element.attribs<moved-to> eq '1';

    # Get function info
    my Hash $curr-function;
    ( $, $curr-function) =
      $!sas.get-method-data( $function-element, :xpath($f-xpath));

    # Get method name, drop the prefix and substitute '_'
    my Str $method-name = $function-name;
    $method-name ~~ s/^ $symbol-prefix //;
    $method-name ~~ s:g/ '_' /-/;

    my Str $function-doc = $curr-function<function-doc>;
    $function-doc = "No documentation of function." unless ?$function-doc;

    # Get parameter lists
    my Str (
      $par-list, $raku-list, $call-list, $items-doc, $p-convert,
      $return-list, $own, $returns-doc, $return-array-convert,
      $return-carray,
    ) =  '' xx 10;
    my @rv-list = ();

    for @($curr-function<parameters>) -> $parameter {
      $!sas.get-types(
        $parameter, $raku-list, $call-list, $items-doc,
        @rv-list, $returns-doc
      );
    }

    my $xtype = $curr-function<return-raku-ntype>;
    if ?$xtype and $xtype ne 'void' {
      $par-list ~= "  --> $xtype";
    }

    $xtype = $curr-function<return-raku-rtype>;
    if ?$xtype and $xtype ne 'void' {
      $raku-list ~= "  --> $xtype";
      my Str $own = '';
      $own = "\(transfer ownership: $curr-function<transfer-ownership>\) "
        if ?$curr-function<transfer-ownership> and
            $curr-function<transfer-ownership> ne 'none';

      # Check if there is info about the return value
      if ?$curr-function<rv-doc> {
        $returns-doc = "\nReturn value; $own$curr-function<rv-doc>\n";
      }

      elsif $raku-list ~~ / '-->' / {
        $returns-doc =
          "\nReturn value; No documentation about its value and use\n";
      }

      if $xtype eq 'Array[Str]' {
        $return-array-convert = q:to/EOCNV/;

          my Int $i = 0;
          my @a = ();
          while $ca[$i].defined {
            @a.push: $ca[$i++];
          }

          @a
        EOCNV

        $return-carray = '  my CArray[Str] $ca =';
      }
    }

    # Assumed that there are no multiple methods to return values. I.e not
    # returning an array and pointer arguments to receive values in those vars.
    elsif ?@rv-list {
      $returns-doc = "Returns a List holding the values\n$returns-doc";
      $return-list = [~] '  (', @rv-list.join(', '), ")\n";
      $raku-list ~= "  --> List";
    }

    # remove first comma and substitute underscores
    $par-list ~~ s/^ . //;
    $raku-list ~~ s/^ . //;

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

    $code ~= qq:to/EOSUB/;
      {HLSEPARATOR}
      #TM:0:$method-name:
      method $method-name \(
       $raku-list
      \) \{
      EOSUB

    $code ~= $p-convert if ?$p-convert;
    $code ~= $return-carray if ?$return-carray;
    $code ~= "  $function-name\( $call-list\)\n";
    $code ~= $return-array-convert if ?$return-array-convert;
    $code ~= $return-list if ?$return-list;

    $code ~= qq:to/EOSUB/;
      \}

      sub $function-name \(
       $par-list
      \) is native\($*work-data<library>\)
        \{ * \}

      EOSUB
  }

  ( $doc, $code)
}

#-------------------------------------------------------------------------------
method generate-methods ( XML::Element $element --> List ) {

  my Str $ctype = $element.attribs<c:type>;
  my Hash $h = $!sas.search-name($ctype);
  my Bool $is-leaf = $h<leaf> // False;
  my Str $symbol-prefix = $h<symbol-prefix> // $h<c:symbol-prefix> // '';

  my Hash $hcs = self!get-methods($element);
  return ('','') unless $hcs.keys.elems;

  my Str $code = qq:to/EOSUB/;
    {HLSEPARATOR}
    {SEPARATOR('Methods');}
    {HLSEPARATOR}

    EOSUB

  my Str $doc = qq:to/EOSUB/;
    {HLSEPARATOR}
    {SEPARATOR('Methods');}
    {HLSEPARATOR}
    =begin pod
    =head1 Methods
    =end pod

    EOSUB

  for $hcs.keys.sort -> $function-name {
    my Hash $curr-function := $hcs{$function-name};

    # get method name
    my Str $method-name = $function-name;
    $method-name ~~ s/^ $symbol-prefix //;
    $method-name ~~ s:g/ '_' /-/;

    my Str $method-doc = $curr-function<function-doc>;
    $method-doc = "No documentation of method." unless ?$method-doc;

    # get parameter lists
    my Str (
      $par-list, $raku-list, $call-list, $items-doc, $p-convert,
      $return-list, $own, $returns-doc, $return-array-convert,
      $return-carray,
    ) =  '' xx 10;
    my @rv-list = ();

    for @($curr-function<parameters>) -> $parameter {
#      $own = '';
      my Int $a-count = 0;
#      if ! $parameter<is-instance> {
        $!sas.get-types(
          $parameter, $raku-list, $call-list, $items-doc,
          @rv-list, $returns-doc
        );
#      }
    }

    my $xtype = $curr-function<return-raku-ntype>;
    if ?$xtype and $xtype ne 'void' {
      $par-list ~= "  --> $xtype";
    }

    $xtype = $curr-function<return-raku-rtype>;
    if ?$xtype and $xtype ne 'void' {
      $raku-list ~= "  --> $xtype";
      $own = '';
      $own = "\(transfer ownership: $curr-function<transfer-ownership>\) "
        if ?$curr-function<transfer-ownership> and
            $curr-function<transfer-ownership> ne 'none';

      # Check if there is info about the return value
      if ?$curr-function<rv-doc> {
        $returns-doc = "\nReturn value; $own$curr-function<rv-doc>\n";
      }

      elsif $raku-list ~~ / '-->' / {
        $returns-doc =
          "\nReturn value; No documentation about its value and use\n";
      }

      if $xtype eq 'Array[Str]' {
        $return-array-convert = q:to/EOCNV/;

          my Int $i = 0;
          my @a = ();
          while $ca[$i].defined {
            @a.push: $ca[$i++];
          }

          @a
        EOCNV

        $return-carray = '  my CArray[Str] $ca =';
      }
    }

    # Assumed that there are no multiple methods to return values. I.e not
    # returning an array and pointer arguments to receive values in those vars.
    elsif ?@rv-list {
      $returns-doc = "Returns a List holding the values\n$returns-doc";
      $return-list = [~] '  (', @rv-list.join(', '), ")\n";
      $raku-list ~= "  --> List";
    }

    # remove first comma
    $par-list ~~ s/^ . //;
    $raku-list ~~ s/^ . //;

    my Str $nobject-retrieve;
    if $is-leaf {
      $nobject-retrieve = 'self._get-native-object-no-reffing';
    }

    else {
      $nobject-retrieve = "self._f\('$*work-data<gnome-name>'\)";
    }

    $doc ~= qq:to/EOSUB/;
      {HLSEPARATOR}
      =begin pod
      =head2 $method-name

      $method-doc

      =begin code
      method $method-name \(
       $raku-list
      \)
      =end code

      $items-doc
      $returns-doc
      =end pod
      EOSUB

    $code ~= qq:to/EOSUB/;
      {HLSEPARATOR}
      #TM:0:$method-name:
      method $method-name \(
       $raku-list
      \) \{
      EOSUB

    $code ~= $p-convert if ?$p-convert;
    $code ~= $return-carray if ?$return-carray;
    $code ~= "  $function-name\( $nobject-retrieve$call-list\)\n";
    $code ~= $return-array-convert if ?$return-array-convert;
    $code ~= $return-list if ?$return-list;

    $code ~= qq:to/EOSUB/;
      \}

      sub $function-name \(
       $par-list
      \) is native\($*work-data<library>\)
        \{ * \}

      EOSUB
  }

  ( $doc, $code)
}

#-------------------------------------------------------------------------------
method generate-functions ( XML::Element $element --> List ) {

  my Str $symbol-prefix = $*work-data<sub-prefix>;

  # Get all functions in this class
  my Hash $hcs = self!get-functions($element);
  return ('','') unless ?$hcs;

  my Str $code = qq:to/EOSUB/;
    {SEPARATOR( 'Functions', 2);}
    EOSUB

  my Str $doc = qq:to/EOSUB/;
    {HLSEPARATOR}
    {SEPARATOR('Functions');}
    {HLSEPARATOR}
    =begin pod
    =head1 Functions
    =end pod

    EOSUB

  for $hcs.keys.sort -> $function-name {
    my Hash $curr-function := $hcs{$function-name};

     # Get method name, drop the prefix and substitute '_'
    my Str $method-name = $function-name;
    $method-name ~~ s/^ $symbol-prefix //;
    # keep this version for later
    my Str $hash-fname = $method-name;
    $method-name ~~ s:g/ '_' /-/;

    my Str $function-doc = $curr-function<function-doc>;
    $function-doc = "No documentation of function." unless ?$function-doc;

    # Get parameter lists
    my Str (
      $par-list, $raku-list, $call-list, $items-doc,
      $own, $returns-doc, 
    ) =  '' xx 10;
    my @rv-list = ();

    for @($curr-function<parameters>) -> $parameter {
      $!sas.get-types(
        $parameter, $raku-list, 
        $call-list, $items-doc,
        @rv-list, $returns-doc
      );

      # Get a list of types for the arguments
      $par-list ~= ", $parameter<raku-ntype>";
    }

    # Remove first comma and space when there is only one parameter
    $par-list ~~ s/^ . //;
    $par-list ~~ s/^ . // unless $par-list ~~ m/ \, /;
    $par-list = ?$par-list
              ?? [~] "\n", '    :parameters([', $par-list, ']),'
              !! '';

    my $xtype = $curr-function<return-raku-rtype>;
    if ?$xtype and $xtype ne 'void' {
      $raku-list ~= "  --> $xtype";
      $own = '';
      $own = "\(transfer ownership: $curr-function<transfer-ownership>\) "
        if ?$curr-function<transfer-ownership> and
            $curr-function<transfer-ownership> ne 'none';

      # Check if there is info about the return value
      if ?$curr-function<rv-doc> {
        $returns-doc = "\nReturn value; $own$curr-function<rv-doc>\n";
      }

      elsif $raku-list ~~ / '-->' / {
        $returns-doc =
          "\nReturn value; No documentation about its value and use\n";
      }
    }

    # Assumed that there are no multiple methods to return values. I.e not
    # returning an array and pointer arguments to receive values in those vars.
    elsif ?@rv-list {
      $returns-doc = "Returns a List holding the values\n$returns-doc";
      #$return-list = [~] '  (', @rv-list.join(', '), ")\n";
      $raku-list ~= "  --> List";
    }

    # remove first comma
    $raku-list ~~ s/^ . //;

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

    # Return type
    $xtype = $curr-function<return-raku-ntype>;
    my Str $returns = (?$xtype and $xtype ne 'void' ) 
                    ?? [~] "\n", '    :returns(',
                           $curr-function<return-raku-ntype>,
                           '),'
                    !! '';

    $code ~= qq:to/EOSUB/;
      #TM:0:$hash-fname
      $hash-fname =\> \%\(
        :type(Function),$returns$par-list
      ),

    EOSUB
  }

  ( $doc, $code)
}
