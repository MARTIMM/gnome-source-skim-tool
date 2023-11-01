

use Gnome::SourceSkimTool::ConstEnumType;
use Gnome::SourceSkimTool::Code;

use XML;
use XML::XPath;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::Doc:auth<github:MARTIMM>;

has Gnome::SourceSkimTool::Code $!mod;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {

  $!mod .= new;
}

#-------------------------------------------------------------------------------
# Get the description at the start of a class, record or union.
method get-description ( XML::Element $element, XML::XPath $xpath --> Str ) {
  my Str $doc = "=head1 Description\n\n";

  #$doc ~= $xpath.find( 'doc/text()', :start($element)).Str;
  my Str $widget-picture = '';
  my Str $ctype = $element.attribs<c:type>;
  my Hash $h = $!mod.search-name($ctype);
  $widget-picture = "\n!\[\]\(images/{$*gnome-class.lc}.png\)\n\n"
    if $h<inheritable>;

  $doc ~= self!modify-text( $xpath.find( 'doc/text()', :start($element)).Str);

  #??$doc ~= self!set-declaration;
  $doc ~= self!set-uml;
#NOTE still needed?
#  $doc ~= self!set-inherit-example($element);
  $doc ~= self!set-example;

  qq:to/RAKUMOD/;
    =begin pod
    =head1 $*work-data<raku-class-name>

    $widget-picture$doc
    =end pod
    RAKUMOD
}

#-------------------------------------------------------------------------------
method !set-uml ( --> Str ) {
  # Using a markdown link not a Raku pod link
  my Str $doc = q:to/EOEX/;


    =begin comment
    =head2 Uml Diagram
    ![](plantuml/Label.svg)
    =end comment
    EOEX
  $doc
}
#-------------------------------------------------------------------------------
method !set-inherit-example ( XML::Element $element --> Str ) {

  my Str $doc = '';
  my Str $ctype = $element.attribs<c:type>;
  my Hash $h = $!mod.search-name($ctype);

  if $h<inheritable> {
    # Code like {'...'} is inserted here and there to prevent interpretation
    $doc = qq:to/EOINHERIT/;

      =head2 Inheriting this class

      Inheriting is done in a special way in that it needs a call from new\() to get the native object created by the class you are inheriting from.

        use $*work-data<raku-class-name>;

        unit class MyGuiClass;
        also is $*work-data<raku-class-name>;

        submethod new \( \|c ) \{
          # let the {$*work-data<raku-class-name>} class process the options
          self\.bless\( :{$element.attribs<c:type>}, \|c);
        \}

        submethod BUILD \( ... ) \{
          ...
        \}

      EOINHERIT
  }

  $doc
}

#-------------------------------------------------------------------------------
method !set-example ( --> Str ) {
  my Str $doc = q:to/EOEX/;

    =begin comment
    =head2 Example
      … text …
      … example code …
    =end comment
    EOEX
  $doc
}

#-------------------------------------------------------------------------------
method document-build ( XML::Element $element, Hash $hcs --> Str ) {
  my Str $doc = qq:to/EOBUILD/;

    {HLSEPARATOR}
    =begin pod
    =head1 Class initialization

    {pod-header('Class Initialization')}
    #TM:1:new:
    =head2 new
    EOBUILD

  my Str $build-doc;
  for $hcs.keys.sort -> $function-name {
    $build-doc = '';

#`{{
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
}}
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
  my Hash $h = $!mod.search-name($ctype);
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
method document-constructors (
  XML::Element $element, Hash $hcs --> Str
) {
  return '' unless ?$hcs;

  my Str $ctype = $element.attribs<c:type>;
  my Hash $h = $!mod.search-name($ctype);
  my Str $symbol-prefix = $*work-data<sub-prefix>;

  # Get all methods in this class
#  my Hash $hcs = self.get-methods( $element, $xpath);

  my Str $doc = qq:to/EOSUB/;
    {pod-header('Constructors')}
    =begin pod
    =head1 Constructors
    =end pod

    EOSUB

  for $hcs.keys.sort -> $method-name {
    my Hash $curr-function := $hcs{$method-name};
note "$?LINE $method-name, $hcs.gist()";
    my Str $method-doc = $curr-function<function-doc>;
    $method-doc = "No documentation of method.\n" unless ?$method-doc;

    # Get parameter lists
    my Str ( $raku-list, $call-list, $items-doc, $own, $returns-doc) =  '' xx 5;
    my @rv-list = ();

    my Bool $first-param = True;
    for @($curr-function<parameters>) -> $parameter {
      self!get-types(
        $parameter, $raku-list,
        $call-list, $items-doc,
        @rv-list, $returns-doc
      );
    }

    my $xtype = $curr-function<return-raku-rtype>;
    if ?$xtype and $xtype ne 'void' {
      $raku-list ~= " --> $xtype";
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
  }

  $doc
}

#-------------------------------------------------------------------------------
method document-methods ( XML::Element $element, XML::XPath $xpath --> Str ) {

  my Str $ctype = $element.attribs<c:type>;
  my Hash $h = $!mod.search-name($ctype);
  my Str $symbol-prefix = $*work-data<sub-prefix>;

  # Get all methods in this class
  my Hash $hcs = self.get-methods( $element, $xpath);
  return '' unless ?$hcs;

  my Str $doc = qq:to/EOSUB/;
    {pod-header('Methods')}
    =begin pod
    =head1 Methods
    =end pod

    EOSUB

  for $hcs.keys.sort -> $method-name {
    my Hash $curr-function := $hcs{$method-name};

    my Str $method-doc = $curr-function<function-doc>;
    $method-doc = "No documentation of method.\n" unless ?$method-doc;

    # Get parameter lists
    my Str ( $raku-list, $call-list, $items-doc, $own, $returns-doc) =  '' xx 5;
    my @rv-list = ();

    my Bool $first-param = True;
    for @($curr-function<parameters>) -> $parameter {
      self!get-types(
        $parameter, $raku-list,
        $call-list, $items-doc,
        @rv-list, $returns-doc
      );
    }

    my $xtype = $curr-function<return-raku-rtype>;
    if ?$xtype and $xtype ne 'void' {
      $raku-list ~= " --> $xtype";
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
  }

  $doc
}

#-------------------------------------------------------------------------------
method get-methods ( XML::Element $element, XML::XPath $xpath --> Hash ) {
  my Hash $hms = %();

  my @methods = $xpath.find( 'method', :start($element), :to-list);

  for @methods -> $cn {
    # Skip deprecated methods
    next if $cn.attribs<deprecated>:exists and $cn.attribs<deprecated> eq '1';

    my ( $function-name, %h) = self!get-method-data( $cn, :!build, :$xpath);

    # Function names which are returned emptied, are assumably internal
    next unless ?$function-name and ?%h;

    $hms{$function-name} = %h;
  }

  $hms
}

#-------------------------------------------------------------------------------
#TODO copied from ::Code. Make this method search for documentation only
method !get-method-data (
  XML::Element $e, Bool :$build = False, XML::XPath :$xpath
  --> List
) {
  # Get function name. Sometimes it ends in '-1' which is not a raku id.
  # This must be converted.
  my Str $function-name = $!mod.cleanup-id( $e.attribs<name>, :is-function);

  # Skip emptied function names. Assumed that those are for internal use.
  return ( '', %()) unless ?$function-name;

  my Bool $missing-type = False;

#`{{
  my Str $sub-prefix := $*work-data<sub-prefix>;
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
}}

  my Str $edoc = ($xpath.find( 'doc/text()', :start($e)) // '').Str;
  my Str $s = self!modify-text($edoc);
  my Str $function-doc = self!cleanup($s);

  my XML::Element $rvalue = $xpath.find( 'return-value', :start($e));
  my Str $rv-transfer-ownership = $rvalue.attribs<transfer-ownership>;
  my Str ( $rv-doc, $rv-type, $return-raku-type) =
    self.get-doc-type( $rvalue, :$xpath, :user-side);
  $missing-type = True if !$return-raku-type or $return-raku-type ~~ /_UA_ $/;
  $return-raku-type ~~ s/ _UA_ $//;

  # Get all parameters. Mostly the instance parameters come first
  # but I am not certain.
  my @parameters = ();
  my @prmtrs = $xpath.find(
    'parameters/instance-parameter | parameters/parameter',
    :start($e), :to-list
  );

  for @prmtrs -> $p {
    my Str ( $doc, $type, $raku-type) =
      self.get-doc-type( $p, :$xpath, :user-side);
    my Hash $attribs = $p.attribs;
    my Str $parameter-name = $attribs<name>;
#    $parameter-name ~~ s:g/ '_' /-/;

    my Hash $ph = %(
      :name($parameter-name), :transfer-ownership($attribs<transfer-ownership>),
      :$doc, :$type, :$raku-type
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
      :$function-doc, :@parameters,
      :$rv-doc, :$rv-type, :$return-raku-type,
      :$rv-transfer-ownership,
    )
  );
}

#-------------------------------------------------------------------------------
#TODO copied. Make this method search for documentation only
method get-doc-type (
  XML::Element $e,
# Bool :$return-type = False,
#  Bool :$add-gtype = False,
  XML::XPath :$xpath, Bool :$user-side = False
  --> List
) {

  # With variable argument lists, the name is '…'. It would not have a type
  # so return something to prevent it marked as a missing type
  return ('…', '…')
    if $e.attribs<name>:exists and $e.attribs<name> eq '…';

#  my Str ( $doc, $ctype, $raku-ntype, $raku-rtype, $g-type) = '' xx 5;
  my Str ( $doc, $ctype, $raku-type) = '' xx 5;
  for $e.nodes -> $n {
    next if $n ~~ XML::Text;

    with $n.name {
      when 'doc' {
        $doc = self!cleanup(
          self!modify-text(($xpath.find( 'text()', :start($n)) // '').Str)
        );
      }

      when 'type' {
        $ctype = $n.attribs<c:type> // $n.attribs<name>;
        $raku-type = $user-side
                   ?? $!mod.convert-rtype($ctype)
                   !! $!mod.convert-ntype($ctype)
                   ;
      }

      when 'array' {
        # Sometimes there is no 'c:type', assume an array of strings
        $ctype = $n.attribs<c:type> // 'gchar**';
        $raku-type = $user-side
                   ?? $!mod.convert-rtype($ctype)
                   !! $!mod.convert-ntype($ctype)
                   ;
      }

#`{{
      when 'type' {
        my Hash $attribs = $n.attribs<c:type> // $n.attribs;
        $ctype = $attribs<name>;
#note "$?LINE $attribs.gist()" if $ctype ~~ m/Pixbuf/;
#        $ctype ~~ s:g/ '.' //;
        $raku-ntype =
          $!mod.convert-ntype($ctype, :$return-type);
        $raku-rtype =
          $!mod.convert-rtype($ctype, :$return-type);
        $g-type = self.gobject-value-type($raku-ntype) if $add-gtype;
      }

      when 'array' {
        # sometime there is no 'c:type', assume an array of strings
        $ctype = $n.attribs<c:type> // 'gchar**';
        $raku-ntype = $!mod.convert-ntype( $ctype, :$return-type);
        $raku-rtype = $!mod.convert-rtype( $ctype, :$return-type);
        $g-type = self.gobject-value-type($raku-ntype) if $add-gtype;
      }
}}
    }
  }

  ( $doc, $ctype, $raku-type)
#  ( $doc, $ctype, $raku-ntype, $raku-rtype, $g-type)
}

#-------------------------------------------------------------------------------
method document-signals ( XML::Element $element, XML::XPath $xpath --> Hash ) {
  my Hash $sig-info = %();
  my Str $doc = '';

  my @signal-info = $xpath.find( 'glib:signal', :start($element), :to-list);

  my Hash $signals = %();
  for @signal-info -> $si {
    my Hash $attribs = $si.attribs;
    next if $attribs<deprecated>:exists and  $attribs<deprecated> == 1;

    # signal documentation
    my Str $signal-name = $attribs<name>;
    my Str $sdoc = self!cleanup(
      self!modify-text(($xpath.find( 'doc/text()', :start($si)) // '').Str)
    );
    my Hash $curr-signal := $signals{$signal-name} = %(:$sdoc,);
#    $curr-signal = %(:$sdoc,);

    # return value info
    my XML::Element $rvalue = $xpath.find( 'return-value', :start($si));
    $curr-signal<transfer-ownership> = $rvalue.attribs<transfer-ownership>;

    my Str ( $rv-type, $return-ntype) = $!mod.get-type( $rvalue, :!user-side);
    my Str $rv-doc = '';

#    my Str ( $rv-doc, $rv-type, $return-raku-ntype, $return-raku-rtype) =
#      $!mod.get-type( $rvalue, :user-side);
#    $curr-signal<rv-doc> = $rv-doc;
    $curr-signal<rv-type> = $rv-type;
    $curr-signal<return-ntype> = $return-ntype;
#    $curr-signal<return-raku-rtype> = $return-raku-rtype;

    # parameter info
    $curr-signal<parameters> = [];
    my @prmtrs = $xpath.find( 'parameters/parameter', :start($si), :to-list);
    for @prmtrs -> $prmtr {
      my Hash $attribs = $prmtr.attribs;
      my $pname = $attribs<name>;
      my $transfer-ownership = $attribs<transfer-ownership>;
#      my Str ( $type, $raku-ntype) = $!mod.get-type( $prmtr, :!user-side);
#      my Str ( $pdoc, $ptype, $raku-ntype, $raku-rtype) =
#        $!sas.get-doc-type( $prmtr, :$xpath);
      my Str ( $type, $raku-type) =
        self.get-doc-type( $prmtr, :$xpath, :!user-side);
      my Str $pdoc = '';
      $curr-signal<parameters>.push: %(
        :$pname, :$pdoc, #:$ptype,
        :$raku-type, #:$raku-rtype,
        :$transfer-ownership
      );
    }
  }

  # If there are signals, make the docs for it
  if $signals.keys.elems {
    $doc ~= qq:to/EOSIG/;
      {pod-header('Signal Documentation')}
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

      if ?$curr-signal<return-ntype> and
         $curr-signal<return-ntype> ne 'void' {
        my Str $own = '';
        $own = "\(transfer ownership: $curr-signal<transfer-ownership>\) "
          if ?$curr-signal<transfer-ownership> and
             $curr-signal<transfer-ownership> ne 'none';

        $returns-doc = "\nReturn value; $own$curr-signal<rv-doc>\n";
        $rv-method = "\n  --> $curr-signal<return-ntype>";
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
      $doc ~= "Return value \(transfer ownership: $curr-signal<return-ntype> \($curr-signal<transfer-ownership>); $curr-signal<rv-doc>\n"
            if $curr-signal<return-ntype> ne 'void';
}}
    }

    $doc ~= "\n=end pod\n\n";
  }

  $sig-info<doc> = $doc;
  $sig-info<signals> = $signals;

  $sig-info
}

#-------------------------------------------------------------------------------
method document-properties (
  XML::Element $element, XML::XPath $xpath --> Str
) {
  my Str $doc = '';

  my @property-info = $xpath.find( 'property', :start($element), :to-list);

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

    my Str ( $pdoc, $type, $raku-type) =
      self.get-doc-type( $pi, :$xpath, :!user-side);
    my Str $g-type = self.gobject-value-type($raku-type);

    $properties{$property-name} = %(
      :$pdoc, :$writable, :$type, :$raku-type, :$g-type,
      :$pgetter, :$psetter, :$transfer-ownership
    );
  }

  return '' unless $properties.keys.elems;

  $doc ~= qq:to/EOSIG/;

    {pod-header('Property Documentation')}
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

    $doc ~= "=item The native type is $properties{$property-name}<raku-type>.\n";

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
method !modify-text ( Str $text is copy --> Str ) {

  # Do not modify text whithin example code. C code is to be changed
  # later anyway and on other places like in XML examples it must be kept as is.
  my Int $ex-counter = 0;
  my Hash $examples = %();
  while $text ~~ m/ $<example> = [ '|[' .*? ']|' ] / {
    my Str $example = $<example>.Str;
    my Str $ex-key = '____EXAMPLE____' ~ $ex-counter++;
    $examples{$ex-key} = $example;
    $text ~~ s/ $example /$ex-key/;
  }

  $text = self!modify-signals($text);
  $text = self!modify-properties($text);
  $text = self!modify-functions($text);
  $text = self!modify-variables($text);
  $text = self!modify-markdown-links($text);
  $text = self!modify-classes($text);
  $text = self!modify-rest($text);

  # Subtitute the examples back into the text before we can finally modify it
  for $examples.keys -> $ex-key {
    $text ~~ s/ $ex-key /$examples{$ex-key}/;
  }

  $text = self!modify-xml($text);
  $text = self!modify-examples($text);

  $text
}

#-------------------------------------------------------------------------------
# Modify text '::sig-name'
method !modify-signals ( Str $text is copy --> Str ) {

  my Str $section-prefix-name = $*work-data<gnome-name>;
  my Regex $r = / '#'? $<cname> = [\w+]? '::' $<signal-name> = [<[-\w]>+] /;
  while $text ~~ $r {
    my Str $signal-name = $<signal-name>.Str;
    my Str $cname = ($<cname>//'').Str;
    if !$cname or $cname eq $section-prefix-name {
      $text ~~ s:g/ '#'? $cname '::' $signal-name /I<$signal-name>/;
    }

    else {
      $text ~~ s:g/ '#'? $cname'::' $signal-name /I<$signal-name defined in $cname>/;
    }
  }

  $text
}

#-------------------------------------------------------------------------------
method !modify-properties ( Str $text is copy --> Str ) {

  my Str $section-prefix-name = $*work-data<gnome-name>;
  my Regex $r = / '#'? $<cname> = [\w+]? ':' $<pname> = [<[-\w]>+] /;
  while $text ~~ $r {
    my Str $pname = $<pname>.Str;
    my Str $cname = ($<cname>//'').Str;
    if !$cname or $cname eq $section-prefix-name {
      $text ~~ s:g/ '#'? $cname ':' $pname /I<property $pname>/;
    }

    else {
      $text ~~ s:g/ '#'? $cname':' $pname /I<property $pname defined in $cname>/;
    }
  }

  $text
}

#-------------------------------------------------------------------------------
method !modify-variables ( Str $text is copy --> Str ) {

  $text ~~ s:g/ \s? '@' (\w+) / C<\$$0>/;

  $text
}

#-------------------------------------------------------------------------------
method !modify-build-variables (
  Str $text is copy, Hash $variable-map
  --> Str
) {
  # Only map for names in hash, others are done above. This is meant to
  # be used for the BUILD options to variable mapping. The substitutions might
  # already been done via .modify-text() so check on '$' as well.
  for $variable-map.kv -> $orig, $new {
    $text ~~ s:g/ \s? ['$'] $orig / \$$new/;
    $text ~~ s:g/ \s? ['@'] $orig / C<\$$new>/;
  }

  $text
}

#-------------------------------------------------------------------------------
method !modify-functions ( Str $text is copy --> Str ) {

  my Str $sub-prefix = $*work-data<sub-prefix>;

  # When a local function has '_new_' in the text, convert it into an init call
  # E.g. 'gtk_label_new_with_mnemonic()' becomes '.new(:$with-mnemonic)'
  $text ~~ s:g/ $sub-prefix new '_' (\w+) '()'
              /C<.new(:\${ S:g/'_'/-/ with $0 })>/;

  # Other functions local to this module, remove the sub-prefix and place
  # a '.' at front. E.g in module Label and package Gtk3 converting
  # 'gtk_label_set-line-wrap()' becomes '.set-line-wrap()'.
  $text ~~ s:g/ $sub-prefix (\w+) '()' 
              /C<.{S:g/'_'/-/ with $0}\(\)>/;

  # Functions not local to this module
  my Regex $r = / $<function-name> = [
                    <!after "\x200B">
                    [ atk || gtk || gdk || gsk ||
                      pangocairo || pango || cairo || g
                    ]
                    '_' \w*?
                  ] '()'
                /;

  while $text ~~ $r {
    my Str $function-name = $<function-name>.Str;
    my Hash $h = $!mod.search-name($function-name);
    my Str $package-name = $h<raku-package> // '';
    my Str $raku-name = $h<rname> // '';
    
    if ?$raku-name {
      $text ~~ s:g/ $function-name\(\) 
                  /C<\x200B$raku-name\(\) function from $package-name>/;
    }

    else {
      $text ~~ s:g/ $function-name\(\) /\x200B$function-name\(\)/;
    }
  }

  # After all work remove the zero width space marker
  $text ~~ s:g/ \x200B //;

  $text
}

#-------------------------------------------------------------------------------
method !modify-classes ( Str $text is copy --> Str ) {

  # When classnames are found (or not) a zero width space is inserted just
  # before the word to prevent finding this word (or part of it again when not
  # substituted. See also https://invisible-characters.com/.
  my Regex $r = / '#'? $<class-name> = [
                     <!after ["\x200B" || '::']>
                     [ Atk || Gtk || Gdk || Gsk ||
                       PangoCairo || Pango || Cairo || G
                     ]
                     \w+
                  ]
                /;

  while $text ~~ $r {
    my Str $class-name = $<class-name>.Str;
    my Hash $h = $!mod.search-name($class-name);
    my Str $raku-name = $h<rname> // '';

    if ?$h<gir-type> and $h<gir-type> eq 'enumeration' {
      $text ~~ s:g/ '#'? $class-name /C<\x200B$class-name enumeration>/;
    }
    
    elsif ?$h<gir-type> and $h<gir-type> eq 'bitfield' {
      $text ~~ s:g/ '#'? $class-name /C<\x200B$class-name bitfield>/;
    }
    
    elsif ?$raku-name {
      $text ~~ s:g/ '#'? $class-name /B<\x200B$raku-name>/;
    }

    else {
      $text ~~ s:g/ '#'? $class-name /\x200B$class-name/;
    }
  }

  # After all work remove the zero width space marker
  $text ~~ s:g/ \x200B //;

  $text
}

#-------------------------------------------------------------------------------
# convert |[ … ]| marks. Must be processed at the end because other
# modifications may depend on those marks
method !modify-examples ( Str $text is copy --> Str ) {

  $text ~~ s:g/^^ '|[' \s* '<!--' \s* 'language="xml"' \s* '-->' 
              /=begin comment\nFollowing text is XML\n= begin code\n/;

  $text ~~ s:g/^^ '|[<!-- language="plain" -->'
              /=begin comment\n= begin code/;

  $text ~~ s:g/^^ '|[' \s* '<!--' \s* 'language="C"' \s* '-->' 
              /=begin comment\n= begin code/;

  $text ~~ s:g/^^ ']|' /= end code\n=end comment\n/;

  $text
}

#-------------------------------------------------------------------------------
# Modify xml remnants
method !modify-xml ( Str $text is copy --> Str ) {
  
  # xml escapes
  $text ~~ s:g/ '&lt;' /</;
  $text ~~ s:g/ '&gt;' />/;
  $text ~~ s:g/ '&amp;' /\&/;
  $text ~~ s:g/ [ '&#160;' || '&nbsp;' ] / /;

  $text
}

#-------------------------------------------------------------------------------
method !modify-markdown-links ( Str $text is copy --> Str ) {
  $text ~~ s:g/ \s '[' ( <-[\]]>+ ) '][' <-[\]]>+ ']' / $0/;

  $text
}

#-------------------------------------------------------------------------------
# Modify rest
method !modify-rest ( Str $text is copy --> Str ) {

  # variable changes
  $text ~~ s:g/ '%' TRUE /C<True>/;
  $text ~~ s:g/ '%' FALSE /C<False>/;
  $text ~~ s:g/ '%' NULL /C<Nil>/;

  # sections
  $text ~~ s:g/^^ '#' \s+ (\w) /=head2 $0/;

  $text
}

#-------------------------------------------------------------------------------
method !cleanup ( Str $text is copy, Bool :$trim = False --> Str ) {
#  $text = self.scan-for-unresolved-items($text);
  $text ~~ s:g/ ' '+ / /;
  $text ~~ s:g/ <|w> \n <|w> / /;
  $text ~~ s:g/ \n ** 3..* /\n\n/;

  if $trim {
    $text ~~ s/^ \s+ //;
    $text ~~ s/ \s+ $//;
  }

  $text
}

#-------------------------------------------------------------------------------
method !get-types (
  Hash $parameter,
  Str $raku-list is rw, Str $call-list is rw,
  Str $items-doc is rw, @rv-list,
  Str $returns-doc is rw
  --> Hash
) {

  my Str $own = '';
  my Int $a-count = 0;
  my Hash $result = %();

  given my $xtype = $parameter<raku-type> {
    when 'N-GObject' {
      $raku-list ~= ", $parameter<raku-type> \$$parameter<name>";
      $call-list ~= ", \$$parameter<name>";

      $result<raku-list> = ", $parameter<raku-type> \$$parameter<name>";
      $result<call-list> = ", \$$parameter<name>";

      $own = "\(transfer ownership: $parameter<transfer-ownership>\) "
        if ?$parameter<transfer-ownership> and
          $parameter<transfer-ownership> ne 'none';

      $result<items-doc> = "=item \$$parameter<name>; $own$parameter<doc>\n";
    }

    when 'CArray[Str]' {
      $raku-list ~= ", Array[Str] \$$parameter<name>";
      $call-list ~= ", \$ca$a-count";

      $result<raku-list> = ", $parameter<raku-type> \$$parameter<name>";
      $result<call-list> = ", \$$parameter<name>";

      $a-count++;

      $own = "\(transfer ownership: $parameter<transfer-ownership>\) "
        if ?$parameter<transfer-ownership> and
          $parameter<transfer-ownership> ne 'none';
      $items-doc ~= "=item \$$parameter<name>; $own$parameter<doc>\n";

      $result<items-doc> = "=item \$$parameter<name>; $own$parameter<doc>\n";
    }

    when 'CArray[gint]' {
#            $raku-list ~= ", CArray[gint] \$$parameter<name>";
#            my $ntype = 'gint';
      #$ntype ~~ s:g/ [const || \s+ || '*'] //;
      @rv-list.push: "\$$parameter<name>";
      $call-list ~= ", my gint \$$parameter<name>";

      $result<raku-list> = ", $parameter<raku-type> \$$parameter<name>";
      $result<call-list> = ", \$$parameter<name>";
      $result<rv-list> = "\$$parameter<name>";

      $returns-doc ~= "=item \$$parameter<name>; $own$parameter<doc>\n";

      $result<items-doc> = "=item \$$parameter<name>; $own$parameter<doc>\n";
    }

    default {
      $raku-list ~= ", $parameter<raku-type> \$$parameter<name>";
      $call-list ~= ", \$$parameter<name>";

      $own = "\(transfer ownership: $parameter<transfer-ownership>\) "
        if ?$parameter<transfer-ownership> and
          $parameter<transfer-ownership> ne 'none';
      $items-doc ~= "=item \$$parameter<name>; $own$parameter<doc>\n";

      $result<items-doc> = "=item \$$parameter<name>; $own$parameter<doc>\n";
    }
  }

  $result  
}

#-------------------------------------------------------------------------------
method gobject-value-type( Str $ctype --> Str ) {

  my $g-type = '';

  with $ctype {
    when 'gboolean' {
      $g-type = 'G_TYPE_BOOLEAN';
    }

    when 'gchar' {
      $g-type = 'G_TYPE_CHAR';
    }

    when 'gdouble' {
      $g-type = 'G_TYPE_DOUBLE';
    }
    
    when 'gfloat' {
      $g-type = 'G_TYPE_FLOAT';
    }
    
    when 'gint' {
      $g-type = 'G_TYPE_INT';
    }
    
#    when 'gint16' {
#      $g-type = '';
#    }
    
#    when 'gint32' {
#      $g-type = '';
#    }

    when 'gint64' {
      $g-type = 'G_TYPE_INT64';
    }

    when 'gint8' {
      $g-type = 'G_TYPE_CHAR';
    }

    when 'glong' {
      $g-type = 'G_TYPE_LONG';
    }

    when 'gpointer' {
      $g-type = 'G_TYPE_POINTER';
    }
    
#    when 'gshort' {
#      $g-type = '';
#    }
    
#    when 'gsize' {
#      $g-type = '';
#    }
    
#    when 'gssize' {
#      $g-type = '';
#    }
    
    when 'guchar' {
      $g-type = 'G_TYPE_UCHAR';
    }
    
    when 'guint' {
      $g-type = 'G_TYPE_UINT';
    }
    
#    when 'guint16' {
#      $g-type = '';
#    }
    
#    when 'guint32' {
#      $g-type = '';
#    }
    
    when 'guint64' {
      $g-type = 'G_TYPE_UINT64';
    }
    
    when 'guint8' {
      $g-type = 'G_TYPE_UCHAR';
    }
    
    when 'gulong' {
      $g-type = 'G_TYPE_ULONG';
    }
    
#    when 'gunichar' {
#      $g-type = '';
#    }
    
#    when 'gushort' {
#      $g-type = '';
#    }
       
#    when 'gushort' {
#      $g-type = '';
#    }
    
#    when 'gushort' {
#      $g-type = '';
#    }
 
    when 'GEnum' {
      $g-type = 'G_TYPE_ENUM';
    }
 
    when 'GFlag' {
      $g-type = 'G_TYPE_FLAGS';
    }

    default {
      my Hash $h = $!mod.search-name($ctype);
      if ?$h<gir-type> {
        $g-type = 'G_TYPE_ENUM' if $h<gir-type> eq 'enumeration';
        $g-type = 'G_TYPE_FLAGS' if $h<gir-type> eq 'bitfield';
        $g-type = 'G_TYPE_OBJECT' if $h<gir-type> eq 'class';
      }
    }
  }

  $g-type
}




















=finish

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
### from Code

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

#-------------------------------------------------------------------------------
method get-types (
  Hash $parameter,
  Str $raku-list is rw, Str $call-list is rw,
  Str $items-doc is rw, @rv-list,
  Str $returns-doc is rw
  --> Hash
) {

  my Str $own = '';
  my Int $a-count = 0;
  my Hash $result = %();

  given my $xtype = $parameter<raku-ntype> {
    when 'N-GObject' {
      $raku-list ~= ", $parameter<raku-rtype> \$$parameter<name>";
      $call-list ~= ", \$$parameter<name>";

      $result<raku-list> = ", $parameter<raku-rtype> \$$parameter<name>";
      $result<call-list> = ", \$$parameter<name>";

      $own = "\(transfer ownership: $parameter<transfer-ownership>\) "
        if ?$parameter<transfer-ownership> and
          $parameter<transfer-ownership> ne 'none';

      $result<items-doc> = "=item \$$parameter<name>; $own$parameter<doc>\n";
    }

    when 'CArray[Str]' {
      $raku-list ~= ", Array[Str] \$$parameter<name>";
      $call-list ~= ", \$ca$a-count";

      $result<raku-list> = ", $parameter<raku-rtype> \$$parameter<name>";
      $result<call-list> = ", \$$parameter<name>";

      $a-count++;

      $own = "\(transfer ownership: $parameter<transfer-ownership>\) "
        if ?$parameter<transfer-ownership> and
          $parameter<transfer-ownership> ne 'none';
      $items-doc ~= "=item \$$parameter<name>; $own$parameter<doc>\n";

      $result<items-doc> = "=item \$$parameter<name>; $own$parameter<doc>\n";
    }

    when 'CArray[gint]' {
#            $raku-list ~= ", CArray[gint] \$$parameter<name>";
#            my $ntype = 'gint';
      #$ntype ~~ s:g/ [const || \s+ || '*'] //;
      @rv-list.push: "\$$parameter<name>";
      $call-list ~= ", my gint \$$parameter<name>";

      $result<raku-list> = ", $parameter<raku-rtype> \$$parameter<name>";
      $result<call-list> = ", \$$parameter<name>";
      $result<rv-list> = "\$$parameter<name>";

      $returns-doc ~= "=item \$$parameter<name>; $own$parameter<doc>\n";

      $result<items-doc> = "=item \$$parameter<name>; $own$parameter<doc>\n";
    }

    default {
      $raku-list ~= ", $parameter<raku-rtype> \$$parameter<name>";
      $call-list ~= ", \$$parameter<name>";

      $own = "\(transfer ownership: $parameter<transfer-ownership>\) "
        if ?$parameter<transfer-ownership> and
          $parameter<transfer-ownership> ne 'none';
      $items-doc ~= "=item \$$parameter<name>; $own$parameter<doc>\n";

      $result<items-doc> = "=item \$$parameter<name>; $own$parameter<doc>\n";
    }
  }

  $result  
}

#-------------------------------------------------------------------------------
method get-type-doc (
  Hash $parameter,
  Str $raku-list is rw, Str $call-list is rw,
  Str $items-doc is rw, @rv-list,
  Str $returns-doc is rw
  --> Hash
) {

  my Str $own = '';
  my Int $a-count = 0;
  my Hash $result = %();

  given my $xtype = $parameter<raku-ntype> {
    when 'N-GObject' {
      $raku-list ~= ", $parameter<raku-rtype> \$$parameter<name>";
      $call-list ~= ", \$$parameter<name>";

      $result<raku-list> = ", $parameter<raku-rtype> \$$parameter<name>";
      $result<call-list> = ", \$$parameter<name>";

      $own = "\(transfer ownership: $parameter<transfer-ownership>\) "
        if ?$parameter<transfer-ownership> and
          $parameter<transfer-ownership> ne 'none';

      $result<items-doc> = "=item \$$parameter<name>; $own$parameter<doc>\n";
    }

    when 'CArray[Str]' {
      $raku-list ~= ", Array[Str] \$$parameter<name>";
      $call-list ~= ", \$ca$a-count";
      $p-convert =
        "  my \$ca$a-count = CArray\[Str].new\(|\$$parameter<name>);\n";

      $result<raku-list> = ", $parameter<raku-rtype> \$$parameter<name>";
      $result<call-list> = ", \$$parameter<name>";
      $result<p-convert> =
        "  my \$ca$a-count = CArray\[Str].new\(|\$$parameter<name>);\n";

      $a-count++;

      $own = "\(transfer ownership: $parameter<transfer-ownership>\) "
        if ?$parameter<transfer-ownership> and
          $parameter<transfer-ownership> ne 'none';
      $items-doc ~= "=item \$$parameter<name>; $own$parameter<doc>\n";

      $result<items-doc> = "=item \$$parameter<name>; $own$parameter<doc>\n";
    }

    when 'CArray[gint]' {
#            $raku-list ~= ", CArray[gint] \$$parameter<name>";
#            my $ntype = 'gint';
      #$ntype ~~ s:g/ [const || \s+ || '*'] //;
      @rv-list.push: "\$$parameter<name>";
      $call-list ~= ", my gint \$$parameter<name>";

      $result<raku-list> = ", $parameter<raku-rtype> \$$parameter<name>";
      $result<call-list> = ", \$$parameter<name>";
      $result<rv-list> = "\$$parameter<name>";

      $returns-doc ~= "=item \$$parameter<name>; $own$parameter<doc>\n";

      $result<items-doc> = "=item \$$parameter<name>; $own$parameter<doc>\n";
    }

    default {
      $raku-list ~= ", $parameter<raku-rtype> \$$parameter<name>";
      $call-list ~= ", \$$parameter<name>";

      $own = "\(transfer ownership: $parameter<transfer-ownership>\) "
        if ?$parameter<transfer-ownership> and
          $parameter<transfer-ownership> ne 'none';
      $items-doc ~= "=item \$$parameter<name>; $own$parameter<doc>\n";

      $result<items-doc> = "=item \$$parameter<name>; $own$parameter<doc>\n";
    }
  }

  $result  
}

#-------------------------------------------------------------------------------
method get-method-data (
  XML::Element $e, Bool :$build = False, XML::XPath :$xpath
  --> List
) {
  my Str ( $function-name, $option-name, $function-doc);

  $option-name = $function-name = $e.attribs<c:identifier>;
  my Str $sub-prefix := $*work-data<sub-prefix>;

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

  my Str $edoc = ($xpath.find( 'doc/text()', :start($e)) // '').Str;
  my Str $s = self.modify-text($edoc);
  $function-doc = self.cleanup($s);

  my XML::Element $rvalue = $xpath.find( 'return-value', :start($e));
  my Str $rv-transfer-ownership = $rvalue.attribs<transfer-ownership>;
  my Str ( $rv-doc, $rv-type, $return-raku-type) =
    self.get-doc-type( $rvalue, :$xpath, :user-side);

  # Get all parameters. Mostly the instance parameters come first
  # but I am not certain.
  my @parameters = ();
  my @prmtrs = $xpath.find(
    'parameters/instance-parameter | parameters/parameter',
    :start($e), :to-list
  );

  for @prmtrs -> $p {
    my Str ( $doc, $type, $raku-type) =
      self.get-doc-type( $p, :$xpath, :user-side);
    my Hash $attribs = $p.attribs;
    my Str $parameter-name = $attribs<name>;
    $parameter-name ~~ s:g/ '_' /-/;

    my Hash $ph = %(
      :name($parameter-name), :transfer-ownership($attribs<transfer-ownership>),
      :$doc, :$type, :$raku-type
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
      :$option-name, :$function-doc, :@parameters,
      :$rv-doc, :$rv-type, :$return-raku-type,
      :$rv-transfer-ownership,
    )
  );
}

#-------------------------------------------------------------------------------
method get-doc-type (
  XML::Element $e, Bool :$return-type = False,
  Bool :$add-gtype = False, XML::XPath :$xpath
  --> List
) {

  my Str ( $doc, $type, $raku-ntype, $raku-rtype, $g-type) = '' xx 5;
  for $e.nodes -> $n {
    next if $n ~~ XML::Text;
    with $n.name {
      when 'doc' {
        $doc = self.cleanup(
          self.modify-text(($xpath.find( 'text()', :start($n)) // '').Str)
        );
      }

      when 'type' {
        my Hash $attribs = $n.attribs;
        $type = $attribs<name>;
#note "$?LINE $attribs.gist()" if $type ~~ m/Pixbuf/;
#        $type ~~ s:g/ '.' //;
        $raku-ntype =
          $!mod.convert-ntype($attribs<c:type> // $type, :$return-type);
        $raku-rtype =
          $!mod.convert-rtype($attribs<c:type> // $type, :$return-type);
        $g-type = self.gobject-value-type($raku-ntype) if $add-gtype;
      }

      when 'array' {
        # sometime there is no 'c:type', assume an array of strings
        $type = $n.attribs<c:type> // 'gchar**';
        $raku-ntype = $!mod.convert-ntype( $type, :$return-type);
        $raku-rtype = $!mod.convert-rtype( $type, :$return-type);
        $g-type = self.gobject-value-type($raku-ntype) if $add-gtype;
      }
    }
  }

  ( $doc, $type, $raku-ntype, $raku-rtype, $g-type)
}

#-------------------------------------------------------------------------------
method get-doc-type-code ( XML::Element $e --> List ) {

  my Str ( $type, $raku-ntype, $raku-rtype) = '' xx 3;
  for $e.nodes -> $n {
    next if $n ~~ XML::Text;
    with $n.name {
      when 'type' {
        $type = $n.attribs<name>;
#print "$?LINE: $type, na = ", $n.attribs.gist;
#        $type ~~ s:g/ '.' //;
        $raku-ntype =
          $!mod.convert-ntype($n.attribs<c:type> // $type);
        $raku-rtype =
          $!mod.convert-rtype($n.attribs<c:type> // $type);
      }

      when 'array' {
        # sometimes there is no 'c:type', assume an array of strings
        $type = $n.attribs<c:type> // 'gchar**';
        $raku-ntype = $!mod.convert-ntype( $type);
        $raku-rtype = $!mod.convert-rtype( $type);
      }
    }
  }

#note " -> $raku-ntype, $raku-rtype\n";
  ( $type, $raku-ntype, $raku-rtype)
}

#-------------------------------------------------------------------------------
method modify-text ( Str $text is copy --> Str ) {

  # Do not modify text whithin example code. C code is to be changed
  # later anyway and on other places like in XML examples it must be kept as is.
  my Int $ex-counter = 0;
  my Hash $examples = %();
  while $text ~~ m/ $<example> = [ '|[' .*? ']|' ] / {
    my Str $example = $<example>.Str;
    my Str $ex-key = '____EXAMPLE____' ~ $ex-counter++;
    $examples{$ex-key} = $example;
    $text ~~ s/ $example /$ex-key/;
  }

  $text = self.modify-signals($text);
  $text = self.modify-properties($text);
  $text = self.modify-functions($text);
  $text = self.modify-variables($text);
  $text = self.modify-markdown-links($text);
  $text = self.modify-classes($text);
  $text = self.modify-rest($text);

  # Subtitute the examples back into the text before we can finally modify it
  for $examples.keys -> $ex-key {
    $text ~~ s/ $ex-key /$examples{$ex-key}/;
  }

  $text = self.modify-xml($text);
  $text = self.modify-examples($text);

  $text
}

#-------------------------------------------------------------------------------
# Modify text '::sig-name'
method modify-signals ( Str $text is copy --> Str ) {

  my Str $section-prefix-name = $*work-data<gnome-name>;
  my Regex $r = / '#'? $<cname> = [\w+]? '::' $<signal-name> = [<[-\w]>+] /;
  while $text ~~ $r {
    my Str $signal-name = $<signal-name>.Str;
    my Str $cname = ($<cname>//'').Str;
    if !$cname or $cname eq $section-prefix-name {
      $text ~~ s:g/ '#'? $cname '::' $signal-name /I<$signal-name>/;
    }

    else {
      $text ~~ s:g/ '#'? $cname'::' $signal-name /I<$signal-name defined in $cname>/;
    }
  }

  $text
}

#-------------------------------------------------------------------------------
method modify-properties ( Str $text is copy --> Str ) {

  my Str $section-prefix-name = $*work-data<gnome-name>;
  my Regex $r = / '#'? $<cname> = [\w+]? ':' $<pname> = [<[-\w]>+] /;
  while $text ~~ $r {
    my Str $pname = $<pname>.Str;
    my Str $cname = ($<cname>//'').Str;
    if !$cname or $cname eq $section-prefix-name {
      $text ~~ s:g/ '#'? $cname ':' $pname /I<property $pname>/;
    }

    else {
      $text ~~ s:g/ '#'? $cname':' $pname /I<property $pname defined in $cname>/;
    }
  }

  $text
}

#-------------------------------------------------------------------------------
method modify-variables ( Str $text is copy --> Str ) {

  $text ~~ s:g/ \s? '@' (\w+) / C<\$$0>/;

  $text
}

#-------------------------------------------------------------------------------
method modify-build-variables (
  Str $text is copy, Hash $variable-map
  --> Str
) {
  # Only map for names in hash, others are done above. This is meant to
  # be used for the BUILD options to variable mapping. The substitutions might
  # already been done via .modify-text() so check on '$' as well.
  for $variable-map.kv -> $orig, $new {
    $text ~~ s:g/ \s? ['$'] $orig / \$$new/;
    $text ~~ s:g/ \s? ['@'] $orig / C<\$$new>/;
  }

  $text
}

#-------------------------------------------------------------------------------
method modify-functions ( Str $text is copy --> Str ) {

  my Str $sub-prefix = $*work-data<sub-prefix>;

  # When a local function has '_new_' in the text, convert it into an init call
  # E.g. 'gtk_label_new_with_mnemonic()' becomes '.new(:$with-mnemonic)'
  $text ~~ s:g/ $sub-prefix new '_' (\w+) '()'
              /C<.new(:\${ S:g/'_'/-/ with $0 })>/;

  # Other functions local to this module, remove the sub-prefix and place
  # a '.' at front. E.g in module Label and package Gtk3 converting
  # 'gtk_label_set-line-wrap()' becomes '.set-line-wrap()'.
  $text ~~ s:g/ $sub-prefix (\w+) '()' 
              /C<.{S:g/'_'/-/ with $0}\(\)>/;

  # Functions not local to this module
  my Regex $r = / $<function-name> = [
                    <!after "\x200B">
                    [ atk || gtk || gdk || gsk ||
                      pangocairo || pango || cairo || g
                    ]
                    '_' \w*?
                  ] '()'
                /;

  while $text ~~ $r {
    my Str $function-name = $<function-name>.Str;
    my Hash $h = $!mod.search-name($function-name);
    my Str $package-name = $h<raku-package> // '';
    my Str $raku-name = $h<rname> // '';
    
    if ?$raku-name {
      $text ~~ s:g/ $function-name\(\) 
                  /C<\x200B$raku-name\(\) function from $package-name>/;
    }

    else {
      $text ~~ s:g/ $function-name\(\) /\x200B$function-name\(\)/;
    }
  }

  # After all work remove the zero width space marker
  $text ~~ s:g/ \x200B //;

  $text
}

#-------------------------------------------------------------------------------
method modify-classes ( Str $text is copy --> Str ) {

  # When classnames are found (or not) a zero width space is inserted just
  # before the word to prevent finding this word (or part of it again when not
  # substituted. See also https://invisible-characters.com/.
  my Regex $r = / '#'? $<class-name> = [
                     <!after ["\x200B" || '::']>
                     [ Atk || Gtk || Gdk || Gsk ||
                       PangoCairo || Pango || Cairo || G
                     ]
                     \w+
                  ]
                /;

  while $text ~~ $r {
    my Str $class-name = $<class-name>.Str;
    my Hash $h = $!mod.search-name($class-name);
    my Str $raku-name = $h<rname> // '';

    if ?$h<gir-type> and $h<gir-type> eq 'enumeration' {
      $text ~~ s:g/ '#'? $class-name /C<\x200B$class-name enumeration>/;
    }
    
    elsif ?$h<gir-type> and $h<gir-type> eq 'bitfield' {
      $text ~~ s:g/ '#'? $class-name /C<\x200B$class-name bitfield>/;
    }
    
    elsif ?$raku-name {
      $text ~~ s:g/ '#'? $class-name /B<\x200B$raku-name>/;
    }

    else {
      $text ~~ s:g/ '#'? $class-name /\x200B$class-name/;
    }
  }

  # After all work remove the zero width space marker
  $text ~~ s:g/ \x200B //;

  $text
}

#-------------------------------------------------------------------------------
# convert |[ … ]| marks. Must be processed at the end because other
# modifications may depend on those marks
method modify-examples ( Str $text is copy --> Str ) {

  $text ~~ s:g/^^ '|[' \s* '<!--' \s* 'language="xml"' \s* '-->' 
              /=begin comment\nFollowing text is XML\n= begin code\n/;

  $text ~~ s:g/^^ '|[<!-- language="plain" -->'
              /=begin comment\n= begin code/;

  $text ~~ s:g/^^ '|[' \s* '<!--' \s* 'language="C"' \s* '-->' 
              /=begin comment\n= begin code/;

  $text ~~ s:g/^^ ']|' /= end code\n=end comment\n/;

  $text
}

#-------------------------------------------------------------------------------
# Modify xml remnants
method modify-xml ( Str $text is copy --> Str ) {
  
  # xml escapes
  $text ~~ s:g/ '&lt;' /</;
  $text ~~ s:g/ '&gt;' />/;
  $text ~~ s:g/ '&amp;' /\&/;
  $text ~~ s:g/ [ '&#160;' || '&nbsp;' ] / /;

  $text
}

#-------------------------------------------------------------------------------
method modify-markdown-links ( Str $text is copy --> Str ) {
  $text ~~ s:g/ \s '[' ( <-[\]]>+ ) '][' <-[\]]>+ ']' / $0/;

  $text
}

#-------------------------------------------------------------------------------
# Modify rest
method modify-rest ( Str $text is copy --> Str ) {

  # variable changes
  $text ~~ s:g/ '%' TRUE /C<True>/;
  $text ~~ s:g/ '%' FALSE /C<False>/;
  $text ~~ s:g/ '%' NULL /C<Nil>/;

  # sections
  $text ~~ s:g/^^ '#' \s+ (\w) /=head2 $0/;

  $text
}

#-------------------------------------------------------------------------------
method cleanup ( Str $text is copy, Bool :$trim = False --> Str ) {
#  $text = self.scan-for-unresolved-items($text);
  $text ~~ s:g/ ' '+ / /;
  $text ~~ s:g/ <|w> \n <|w> / /;
  $text ~~ s:g/ \n ** 3..* /\n\n/;

  if $trim {
    $text ~~ s/^ \s+ //;
    $text ~~ s/ \s+ $//;
  }

  $text
}
