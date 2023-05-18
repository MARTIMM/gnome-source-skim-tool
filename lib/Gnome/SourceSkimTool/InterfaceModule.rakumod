
use Gnome::SourceSkimTool::ConstEnumType;
use Gnome::SourceSkimTool::SearchAndSubstitute;
use Gnome::SourceSkimTool::GenerateDoc;

use XML;
use XML::XPath;
use JSON::Fast;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::InterfaceModule:auth<github:MARTIMM>;

has Gnome::SourceSkimTool::SearchAndSubstitute $!sas;
has Gnome::SourceSkimTool::GenerateDoc $!grd;

has XML::XPath $!xpath;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {

  $!grd .= new;
  $!sas .= new;

  # load data for this module
  note "Load module data from $*work-data<gir-interface-file>";
  $!xpath .= new(:file($*work-data<gir-interface-file>));
}

#-------------------------------------------------------------------------------
method generate-raku-interface ( ) {

  my XML::Element $class-element = $!xpath.find('//interface');
  die "//interface not found in $*work-data<gir-class-file> for $*work-data<raku-class-name>" unless ?$class-element;

  my Str ( $doc, $code);
  my Str $module-code = '';
  my Str $module-doc = qq:to/RAKUMOD/;
    #TL:1:$*work-data<raku-class-name>:
    use v6;

    {HLSEPARATOR}
    {SEPARATOR('Role Description');}
    {HLSEPARATOR}
    RAKUMOD

  note "Generate module description" if $*verbose;  
  $module-doc ~= $!grd.get-description( $class-element, $!xpath);

  note "Generate module signals" if $*verbose;  
  my Hash $sig-info = self!generate-signals($class-element);

  note "Set class unit" if $*verbose;
  $module-code ~= self!set-unit( $class-element, $sig-info);

  # Roles do not have a BUILD
  note "Generate role initialization method" if $*verbose;  
  $module-code ~= self!generate-role-init( $class-element, $sig-info);

  note "Generate module methods" if $*verbose;  
  ( $doc, $code) = self!generate-methods($class-element);

  # if there are methods, add the fallback routine and methods
  if ?$doc {
    $module-code ~= self!add-deprecatable-method($class-element);
    $module-code ~= $code;
    $module-doc ~= $doc;
  }

  note "Generate module functions" if $*verbose;  
  ( $doc, $code) = self!generate-functions($class-element);
  if ?$code {
    $module-doc ~= $doc;
    $module-code ~= $code;
  }

  # Add the signal doc here
  $module-doc ~= $sig-info<doc>;

  note "Generate module properties" if $*verbose;  
  $module-doc ~= self!generate-properties($class-element);

  note "Save module";
  $*work-data<raku-module-file>.IO.spurt($module-code);
  note "Save pod doc";
  $*work-data<raku-module-doc-file>.IO.spurt($module-doc);
}

#-------------------------------------------------------------------------------
method !set-unit ( XML::Element $class-element, Hash $sig-info --> Str ) {

  # Insert a commented import of enums module
  my Str ( $imports, $also) = '' xx 3;
  if $*gnome-package.Str ~~ / '3' $/ {
    $imports = "#use Gnome::Gtk3::Enums;\n";
  }

  elsif $*gnome-package.Str ~~ / '4' $/ {
    $imports = "#use Gnome::Gtk4::Enums;\n";
  }

  my Str $ctype = $class-element.attribs<c:type>;
  my Hash $h = $!sas.search-name($ctype);

  # Check for parent class. There are never more than one.
  my Str $parent = $h<parent-raku-name> // '';
  if ?$parent {
    $imports ~= "use $parent;\n";
    $also ~= "also is $parent;\n";
  }

  # Check for roles to implement
  my Array $roles = $h<implement-roles>//[];
  for @$roles -> $role {
    my Hash $role-h = $!sas.search-name($role);
#note "$?LINE role=$role -> $role-h.gist()";
    $imports ~= "use $role-h<rname>;\n";
    $also ~= "also does $role-h<rname>;\n";
  }


  my Str $code = qq:to/RAKUMOD/;

    {HLSEPARATOR}
    {SEPARATOR('Module Imports');}
    {HLSEPARATOR}
    use NativeCall;

    use Gnome::N::NativeLib;
    use Gnome::N::N-GObject;
    use Gnome::N::GlibToRakuTypes;
    #use Gnome::N::TopLevelClassSupport;
    $imports
    
    #use Gnome::Glib::List;
    #use Gnome::Glib::SList;
    #use Gnome::Glib::Error;

    {HLSEPARATOR}
    {SEPARATOR('Role Declaration');}
    {HLSEPARATOR}
    unit role $*work-data<raku-class-name>:auth<github:MARTIMM>;
    $also
    RAKUMOD

  $code
}

#-------------------------------------------------------------------------------
method !generate-build (
  XML::Element $class-element, Hash $sig-info
  --> List
) {

  my Hash $hcs = self!get-constructors($class-element);
  my Str $doc = self!make-build-doc( $class-element, $hcs);
  my Str $code = self!make-build-submethod( $class-element, $hcs, $sig-info);
  $code ~= self!make-native-constructor-subs($hcs);

  ( $doc, $code)
}

#-------------------------------------------------------------------------------
method !generate-role-init (
  XML::Element $class-element, Hash $sig-info --> Str
) {
  my Str $code ~= self!make-init-method( $class-element, $sig-info);

  $code
}

#-------------------------------------------------------------------------------
method !make-build-doc ( XML::Element $class-element, Hash $hcs --> Str ) {
  my Str $doc = qq:to/EOBUILD/;

    {HLSEPARATOR}
    =begin pod
    =head1 Methods

    {HLSEPARATOR}
    {SEPARATOR('Class Initialization');}
    {HLSEPARATOR}
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
  my Str $ctype = $class-element.attribs<c:type>;
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
  XML::Element $class-element, Hash $hcs, Hash $sig-info --> Str
) {
  my Str $ctype = $class-element.attribs<c:type>;
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

  $role-signals = "# Signals from interfaces\n" ~ $role-signals
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
    {?$signal-admin ?? 'my Bool $signals-added = False;' !! ''}
    submethod BUILD ( *\%options ) \{
    $signal-admin
    EOBUILD


  # Check if inherit code is to be inserted
#  my Str $ctype = $class-element.attribs<c:type>;
#  my Hash $h = $!sas.search-name($ctype);
  if $h<inheritable> {
    $code ~= [~] '  # prevent creating wrong widgets', "\n",
            '  if self.^name eq ', "'$*work-data<raku-class-name>'",
            ' or %options<', $*work-data<gnome-name>, '> {', "\n";
  }

  else {
    $code ~= [~] '  # prevent creating wrong widgets', "\n",
            '  if self.^name eq ', "'$*work-data<raku-class-name>'", ' {', "\n";
  }

  # Add first few tests
  my Str $b-id-str = ?$h<inheritable>
                     ?? "\n" ~ '    elsif %options<build-id>:exists { }' !! '';
  $code ~= qq:to/EOBUILD/;
        if self.is-valid \{ \}

        # check if common options are handled by some parent
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
              \$no = $function-name\($par-list\);
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

  $code ~= q:to/EOBUILD/;
        #`{{ when there are defaults use this instead
        # create default object
        else {
          $no = $*work-data<sub-prefix>new();
        }
        }}

        self._set-native-object($no);
      }

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
method !make-native-constructor-subs ( Hash $hcs --> Str ) {
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
method !make-init-method (
  XML::Element $class-element, Hash $sig-info --> Str
) {
#  my Str $ctype = $class-element.attribs<c:type>;
#  my Hash $h = $!sas.search-name($ctype);

  my Str $code = '';

  # Check if signal admin is needed
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
    $code ~= qq:to/EOBUILD/;
      #TM:1:$role-ini-method-name:
      method $role-ini-method-name ( Str \$class-name ) \{
        self\.add-signal-types\( \$class-name,
      $sig-list  );
      \}

      EOBUILD
  }

  $code
}

#-------------------------------------------------------------------------------
method !generate-methods ( XML::Element $class-element --> List ) {

  my Str $ctype = $class-element.attribs<c:type>;
  my Hash $h = $!sas.search-name($ctype);
  my Bool $is-leaf = $h<leaf> // False;
  my Str $symbol-prefix = $h<symbol-prefix>;

  my Hash $hcs = self!get-methods($class-element);
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
          $parameter, $raku-list, $par-list, $call-list, $items-doc, $p-convert,
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
          "\nReturn value; No diocumentation about its value and use\n";
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
method !generate-functions ( XML::Element $class-element --> List ) {

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
#      ( $raku-list, $par-list, $call-list, $items-doc, $p-convert,
#        @rv-list, $returns-doc
#      ) = $!sas.get-types($parameter);
      $!sas.get-types(
        $parameter, $raku-list, $par-list, $call-list, $items-doc, $p-convert,
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
          "\nReturn value; No diocumentation about its value and use\n";
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
method !generate-signals ( XML::Element $class-element --> Hash ) {
  my Hash $sig-info = %();
  my Str $doc = '';

  my @signal-info =
     $!xpath.find( 'glib:signal', :start($class-element), :to-list);

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
method !generate-properties ( XML::Element $class-element --> Str ) {
  my Str $doc = '';

  my @property-info =
     $!xpath.find( 'property', :start($class-element), :to-list);

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

#-------------------------------------------------------------------------------
method !get-constructors ( XML::Element $class-element --> Hash ) {
  my Hash $hcs = %();

  my @constructors =
    $!xpath.find( 'constructor', :start($class-element), :to-list);

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
method !get-methods ( XML::Element $class-element --> Hash ) {
  my Hash $hms = %();

  my @methods = $!xpath.find( 'method', :start($class-element), :to-list);

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
method !add-deprecatable-method ( XML::Element $class-element --> Str ) {

  my Hash $meta-data = from-json('META6.json'.IO.slurp);
  my Str $version-now = $meta-data<version>;
  my @v = $version-now.split('.');
  @v[1] += 2;
  @v[2] = 0;
  my Str $version-dep = @v.join('.');


  my Str $ctype = $class-element.attribs<c:type>;
  my Hash $h = $!sas.search-name($ctype);
  my Array $roles = $h<implement-roles> // [];
  my $role-fallbacks = '';
  for @$roles -> $role {
    my Hash $role-h = $!sas.search-name($role);

    $role-fallbacks ~=
      "  \$s = self._$role-h<symbol-prefix>interface\(\$native-sub)\n" ~
      "    if !\$s and self.^can\('_$role-h<symbol-prefix>interface');\n";
  }
  $role-fallbacks ~= "\n" if ?$role-fallbacks;

  my Str $doc = '';

  my Str $pfix = $*work-data<sub-prefix>;
  my @pfix-parts = $pfix.split('_');

  my Str $pfix-dash = $*work-data<sub-prefix>;
  $pfix-dash ~~ s:g/ '_' /-/;
  $pfix-dash.chop(1);

  my Str $package = $*gnome-package.Str.lc;
  $package ~~ s/ \d //;

  my Str ( $mname, $set-class-name);
  $mname = "_{$pfix}interface";
  $set-class-name = '';

  $doc ~= q:to/EODEPR/;

    #`{{
      Older modules might still have it and must remove the method after
      deprecation date. New modules must not implement this.

    EODEPR

  $doc ~= "{HLSEPARATOR}\n";
  $doc ~= "method $mname " ~ '( Str $native-sub --> Callable ) {' ~ "\n";
  $doc ~= "  my Str \$pfix = '$*work-data<sub-prefix>';\n";

  $doc ~= q:to/EODEPR/;
      my @pfix-parts = $pfix.split('_');
      my Int $cfix = @pfix-parts.elems + 2;
      my Str $new-patt = $native-sub.subst( '-', '_', :g);

      my Callable $s;

      loop ( my Int $dash-count = 2; $dash-count < $cfix; $dash-count++ ) {
        my Str $tv = @pfix-parts[0 .. * - $dash-count].join('_');
        my Str $match = ?$tv ?? "{$tv}_$new-patt" !! "$tv$new-patt";
        try { $s = &::($match); }
        if ?$s {
          $match ~~ s/ $pfix //;
          $match ~~ s:g/ '_' /-/;
    EODEPR

  $doc ~= [~] '      Gnome::N::deprecate( "$native-sub", $match, ', "'",
              $version-now, "', '", $version-dep, "');\n";

  $doc ~= q:to/EODEPR/;

          last;
        }
      }

    EODEPR

  $doc ~= $role-fallbacks;
  $doc ~= $set-class-name;

  $doc ~= q:to/EODEPR/;

      $s
    }

    }}

    EODEPR

  $doc
}
