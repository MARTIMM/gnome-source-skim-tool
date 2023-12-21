
use v6.d;

use Gnome::SourceSkimTool::ConstEnumType;
use Gnome::SourceSkimTool::Code;
use Gnome::SourceSkimTool::Resolve;
use Gnome::SourceSkimTool::DocText;

use XML;
use XML::XPath;
use META6;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::Doc:auth<github:MARTIMM>;

has Gnome::SourceSkimTool::Code $!mod;
has Gnome::SourceSkimTool::Resolve $!solve;
has Gnome::SourceSkimTool::DocText $!dtxt;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {

  $!mod .= new;
  $!solve .= new;
  $!dtxt .= new;
}

#-------------------------------------------------------------------------------
# Get the description at the start of a class, record or union.
method get-description ( XML::Element $element, XML::XPath $xpath --> Str ) {
  my Str $ctype = $element.attribs<c:type>;
  my Hash $h = $!solve.search-name($ctype);
  my Str $class-name = $!solve.set-object-name($h);

  my Str $doc = $xpath.find( 'doc/text()', :start($element)).Str // '';
#    $!dtxt.modify-text();

  my Str $widget-picture = '';
  $widget-picture = "\n!\[\]\(images/{$*gnome-class.lc}.png\)\n\n"
    if $*gnome-package ~~ any( Gtk3, Gtk4);


#  $doc ~= self!set-declaration;
#  $doc ~= self!set-uml;
#NOTE still needed?
#  $doc ~= self!set-inherit-example($element);
#  $doc ~= self!set-example;

  Q:s:h:c:to/RAKUDOC/;
    $*command-line
    use v6.d;

    {pod-header('Class Description')}
    =begin pod
    =head1 $class-name
    $widget-picture
    =head1 Description

    $doc

    {self!set-uml if $*gnome-package ~~ any( Gtk3, Gtk4, Gio)}
    {self!set-example}

    =end pod
    RAKUDOC
}

#-------------------------------------------------------------------------------
method !set-uml ( --> Str ) {
  return '' unless $*gnome-package ~~ any( Gtk3, Gtk4, Gio);

  # Using a markdown link not a Raku pod link. Old pod does not know about image
  # New pod does but is not yet ready.
  # add-example-code() returns a key and is text to be returned
  $!dtxt.add-example-code(q:to/EOEX/);

    =head2 Uml Diagram
    ![](plantuml/….svg)
    EOEX
}

#-------------------------------------------------------------------------------
method !set-example ( --> Str ) {
  # add-example-code() returns a key and is text to be returned
  $!dtxt.add-example-code(Q:s:h:to/EOEX/);

    =head2 Example
    # Example use of module $*work-data<raku-class-name>
    EOEX
}

#-------------------------------------------------------------------------------
method document-build ( XML::Element $element --> Str ) {
  my Str $doc = Q:c:to/EOBUILD/;

    {pod-header('Class Initialization')}
    =begin pod
    =head1 Class initialization

    =head2 new
    EOBUILD

  # Finish with standard options
  $doc ~= Q:q:to/EOBUILD/;

    =head3 :native-object

    Create an object using a native object from elsewhere. See also B<Gnome::N::TopLevelSupportClass>.

      multi method new ( N-Object :$native-object! )

    EOBUILD

  # Build id only used for widgets. We can test for inheritable because
  # it intices the same set of objects
  my Str $ctype = $element.attribs<c:type>;
  my Hash $h = $!solve.search-name($ctype);
  if $h<inheritable> {
    $doc ~= Q:q:to/EOBUILD/;

      =head3 :build-id

      Create an object using a native object from a builder. See also B<Gnome::GObject::Object>.

        multi method new ( Str :$build-id! )
      EOBUILD
  }

  $doc ~= "\n=end pod\n\n";
  $doc
}

#-------------------------------------------------------------------------------
method document-constructors (
  XML::Element $element, XML::XPath $xpath --> Str
) {

  my Str $ctype = $element.attribs<c:type>;
  my Hash $h = $!solve.search-name($ctype);

  # Get all methods in this class
  my Hash $hcs =
    self.get-native-subs( $element, $xpath, :routine-type<constructor>);
  return '' unless ?$hcs;

  my Str $doc = '';

  for $hcs.keys.sort -> $method-name is copy {
    my Hash $curr-function := $hcs{$method-name};

    $method-name = $!mod.cleanup-id($method-name);
#note "$?LINE $method-name, $hcs.gist()";

    my Str $method-doc = $curr-function<function-doc>;
    $method-doc = "No documentation of method $method-name.\n"
      unless ?$method-doc;

    # Get parameter lists
    my Str ( $raku-list, $items-doc) =  '' xx 5;

    my Hash $result;
    for @($curr-function<parameters>) -> $parameter {
      $result = self!get-types( $parameter, @);
      $raku-list ~= $result<raku-list> // '';
      $items-doc ~= $result<items-doc> // '';
    }

    # Change constructor name if it is only 'new'
    if $method-name eq 'new' {
      my Str $gname = $*work-data<gnome-name>;
      my Str $prefix = $*work-data<name-prefix>;
      $gname ~~ s:i/^ $prefix //;
      $method-name ~= '-' ~ $gname.lc;
    }

    # remove first comma
    $raku-list ~~ s/^ . //;

    # add-example-code() returns a key
    my Str $ex-key = $!dtxt.add-example-code(Q:s:to/EOEX/);

      =head2 Example
      # Example for $method-name
      EOEX

    $doc ~= Q:c:s:h:to/EOSUB/;
      {HLSEPARATOR}
      =begin pod
      =head2 $method-name
      {$curr-function<missing-type> ?? "This function is not yet available"
                                    !! ''
      }

      $method-doc

      =begin code
      method $method-name ($raku-list --> $*work-data<raku-class-name> \)
      =end code

      $items-doc

      $ex-key
      =end pod

      EOSUB
  }

  $doc
}

#-------------------------------------------------------------------------------
method document-native-subs (
  XML::Element $element, XML::XPath $xpath, Str :$routine-type = 'method' 
  --> Str ) {

  my Str $ctype = $element.attribs<c:type>;

  # Get all subs of $routine-type in this class
  my Hash $hcs = self.get-native-subs( $element, $xpath, :$routine-type);
  return '' unless ?$hcs;

  my Str $subs-header = $routine-type.tc ~ 's';
  my Str $doc = qq:to/EOSUB/;
    {pod-header($subs-header)}
    =begin pod
    =head1 $subs-header
    =end pod

    EOSUB

  $doc ~= self._document-native-subs( $hcs, :$routine-type);

  $doc
}

#-------------------------------------------------------------------------------
method _document-native-subs ( Hash $hcs, Str :$routine-type --> Str ) {
  my Str $doc = '';
  
  for $hcs.keys.sort -> $native-sub is copy {
    my Hash $curr-function := $hcs{$native-sub};

#    $native-sub = $!mod.cleanup-id($native-sub);

#note "\n$?LINE $native-sub, $curr-function.gist()";

    my Str $native-sub-doc = $curr-function<function-doc>;
    $native-sub-doc = "No documentation of method.\n" unless ?$native-sub-doc;

    # Get parameter lists
    my Str ( $raku-list, $items-doc, $own, $returns-doc) =  '' xx 5;
    my @rv-list = ();

    my Hash $result;
    my Bool $first-param = True;
    for @($curr-function<parameters>) -> $parameter {
      # Skip first parameter if $routine-type ~~ 'method'. That one is
      # retrieved from the current object, called 'instance-parameter'.
      if $routine-type eq 'method' and $first-param {
        $first-param = False;
        next;
      }

      $result = self!get-types( $parameter, @rv-list);
#note "$?LINE \n$parameter.gist()\n$result.gist()" if $native-sub eq 'domain-register';
      $raku-list ~= $result<raku-list> // '';
      $items-doc ~= $result<items-doc> // '';
      $returns-doc ~= $result<returns-doc> // '';
    }

    my $xtype = $curr-function<return-raku-type>;
    if ?$xtype and $xtype ne 'void' {

      my Str ( $l, $d ) = self.check-special( $xtype, '', '');
      # Drop coercion mark from return value
      $l ~~ s/ '()' //;

      $raku-list ~= " --> $l";
      $own = '';
      $own = "\(transfer ownership: $curr-function<transfer-ownership>\) "
        if ?$curr-function<transfer-ownership> and
            $curr-function<transfer-ownership> ne 'none';

      # Check if there is info about the return value
      if ?$curr-function<rv-doc> {
        $returns-doc = "\nReturn value; $own$curr-function<rv-doc>. $d\n";
      }

      elsif $raku-list ~~ / '-->' / {
        $returns-doc =
          "\nReturn value; No documentation about its value and use. $d\n";
      }
    }

    # Assumed that there are no multiple methods to return values. I.e not
    # returning an array and pointer arguments to receive values in those vars.
    elsif ?@rv-list {
      $returns-doc = "Returns a List holding the values\n$returns-doc";
      #$return-list = [~] '  (', @rv-list.join(', '), ")\n";
      $raku-list ~= " --> List";
    }

    # remove first comma
    $raku-list ~~ s/^ . //;

#note "$?LINE $curr-function<missing-type>, {$curr-function<missing-type> ?? "\n#`\{\{\n" !! ''}";
    # add-example-code() returns a key
    my Str $ex-key = $!dtxt.add-example-code(qq:to/EOEX/);

      =head2 Example
      # Example for $native-sub
      EOEX

    $doc ~= qq:to/EOSUB/;
      {HLSEPARATOR}
      =begin pod
      =head2 $native-sub
      {$curr-function<missing-type> ?? "This function is not yet available" !! ''}


      $native-sub-doc

      =begin code
      method $native-sub \($raku-list )
      =end code

      $items-doc$returns-doc

      $ex-key
      =end pod

      EOSUB
  }

  $doc
}

#-------------------------------------------------------------------------------
method document-structure (
  XML::Element $element, XML::XPath $xpath --> Str
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
#  my Str $class-name = $h0<class-name>;
  my Str $class-name = $!solve.set-object-name( $h0, :name-type(ClassnameType));
  my Str $record-class = $h0<record-class>;

  my Str $doc = '';

  my @fields = $xpath.find( 'field', :start($element), :to-list);
  if ?@fields {
    my Str $item-doc = '';

    $doc ~= qq:to/EOREC/;

      {pod-header('Record Structure Documentation')}
      =begin pod
      =head1 Record $record-class

        class $record-class\:auth<github:MARTIMM>\:api<2> is export is repr\('CStruct') \{

      EOREC

    for @fields -> $field {
      my $field-name = $!mod.cleanup-id($field.attribs<name>);
      my Str ( $type, $raku-type) = $!mod.get-type( $field, :!user-side);

      if ?$type {
        # Enumerations and bitfields are returned as GEnum:Name and GFlag:Name
        my Str ( $rnt0, $rnt1) = $raku-type.split(':');
        if ?$rnt1 {
          $doc ~= "    has $rnt0 \$.$field-name;           # $rnt1\n";
        }

        #NOTE raku cannot handle this in native structures.
        # Must become a pointer
        elsif $rnt0 ~~ m/ Callable / {
          $doc ~= "    has gpointer \$.$field-name;\n";
        }

        else {
          $doc ~= "    has $rnt0 \$.$field-name;\n";
        }
      }

      else {
        $doc ~= "    has \$.$field-name;\n";
      }

      my Str ( $d-item, $, $) =
        self.get-doc-type( $field, $xpath, :!user-side);
#      $missing-type = True if !$raku-type or $raku-type ~~ /_UA_ $/;
#      $raku-type ~~ s/ _UA_ $//;
      $item-doc ~= "=item $field-name; $d-item";
      my Str ( $rnt0, $rnt1) = $raku-type.split(':');
      if ?$rnt1 {
        $item-doc ~= ". Enumeration of type $rnt1.\n";
      }

      else {
        $item-doc ~= "\n";
      }
    }

    $doc ~= "  }\n\n$item-doc\n=end pod\n\n";
  }

  else {
    # Generate structure as a pointer when no fields are documented
    $doc ~= qq:to/EOREC/;
      {pod-header('Record Structure')}
      =begin pod
      =head1 Record $record-class

      This is an opaque type of which fields are not available.

        class $record-class\:auth<github:MARTIMM>\:api<2> is export is repr\('CStruct') \{ \}

      =end pod

      EOREC
  }

  $doc
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
    # Skip deprecated methods
    next if $native-sub.attribs<deprecated>:exists and
            $native-sub.attribs<deprecated> eq '1';

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
#TODO copied from ::Code. Make this method search for documentation only
method !get-method-data ( XML::Element $e, XML::XPath :$xpath --> List ) {

  # Get function name. Sometimes it ends in '-1' which is not a raku id.
  # This must be converted.
  my Str $function-name = $!mod.cleanup-id( $e.attribs<name>, :is-function);

  # Skip emptied function names. Assumed that those are for internal use.
  return ( '', %()) unless ?$function-name;

  my Bool $missing-type = False;

  my Str $function-doc = $xpath.find( 'doc/text()', :start($e)).Str // '';

  my XML::Element $rvalue = $xpath.find( 'return-value', :start($e));
  my Str $rv-transfer-ownership = $rvalue.attribs<transfer-ownership>//'';
  my Str ( $rv-doc, $rv-type, $return-raku-type) =
    self.get-doc-type( $rvalue, $xpath, :user-side);
  $missing-type = True if !$return-raku-type or $return-raku-type ~~ /_UA_ $/;
  $return-raku-type ~~ s/ _UA_ $//;
  $return-raku-type ~~ s/ '()' //;

  # Get all parameters. Mostly the instance parameters come first
  # but I am not certain.
  my @parameters = ();
  my @prmtrs = $xpath.find(
    'parameters/instance-parameter | parameters/parameter',
    :start($e), :to-list
  );

  for @prmtrs -> $p {
    my Str ( $doc, $type, $raku-type) =
      self.get-doc-type( $p, $xpath, :user-side);
    $missing-type = True if !$raku-type or $raku-type ~~ /_UA_ $/;
    $raku-type //= '';
    $raku-type ~~ s/ _UA_ $//;

    my Hash $attribs = $p.attribs;
    my Str $parameter-name = $!mod.cleanup-id($attribs<name>);
#    next unless ?$parameter-name;

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

  # It is possible that there is a 'throws' option which, when 1, needs
  # an extra argument to store an error object.
  if $e.attribs<throws>:exists and $e.attribs<throws> eq '1' {
    my Str $doc = q:to/EOERR/;
      Error object. When defined, an error can be returned when there is one.
      Use C<Pointer> when you want to ignore the error.
      EOERR

    @parameters.push: %(
      :name<err>, :type<CArray[N-Error]>, :raku-type<CArray[N-Error]>, :$doc
    );
  }

#note "$?LINE $function-name, $missing-type";
  ( $function-name, %(
      :$function-doc, :@parameters, :$missing-type,
      :$rv-doc, :$rv-type, :$return-raku-type,
      :$rv-transfer-ownership,
    )
  );
}

#-------------------------------------------------------------------------------
# Check on GEnum, GFlag, or callback and change doc
method check-special ( Str $type, Str $name, Str $doc is copy --> List ) {
  my Str $list = '';
  return ( $list, $doc) unless ?$type;
  
  # Test for callback signature to not get it be seen as a GEnum or GFlag.
  if $type ~~ m/^ ':(' / {

  }

  # Test for enumerations or bitmaps
  elsif $type ~~ m/ ':' / {
    my ( $t0, $t1) = $type.split(':');
    if $t0 eq 'GEnum' {
      $list = ?$name ?? ", $t1 \$$name" !! $t1;
#      $doc ~= " An enumeration.\n"; 
    }

    else { # GFlag
      $list = ?$name ?? ', UInt $' ~ $name !! 'UInt';
#      $doc ~= " A bitmap.\n"; 
    }
  }

  else {
    $list = ?$name ?? ", $type \$$name" !! $type;
#    $doc ~= "\n"; 
  }

  ( $list, $doc)
}

#-------------------------------------------------------------------------------
#TODO copied. Make this method search for documentation only
method get-doc-type (
  XML::Element $e, XML::XPath $xpath, Bool :$user-side = False
  --> List
) {

  # With variable argument lists, the name is '…'. It would not have a type
  # so return something to prevent it marked as a missing type
  return ('…', '…') if $e.attribs<name>:exists and $e.attribs<name> eq '...';

  my Str ( $doc, $ctype, $raku-type) = '' xx 5;
  for $e.nodes -> $n {
    next if $n ~~ XML::Text;

    with $n.name {
      when 'doc' {
        $doc = $xpath.find( 'text()', :start($n)).Str // '';
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
    }
  }

  ( $doc, $ctype, $raku-type)
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

    # Signal documentation
    my Str $signal-name = $attribs<name>;
    my Str $sdoc = $xpath.find( 'doc/text()', :start($si)).Str // '';

    my Hash $curr-signal := $signals{$signal-name} = %(:$sdoc,);

    # Return value info
    my XML::Element $rvalue = $xpath.find( 'return-value', :start($si));
    $curr-signal<transfer-ownership> = $rvalue.attribs<transfer-ownership>;

    my Str ( $rv-doc, $rv-type, $return-ntype) =
       self.get-doc-type( $rvalue, $xpath, :!user-side);
    $curr-signal<rv-doc> = $rv-doc;
    $curr-signal<rv-type> = $rv-type;
    $curr-signal<return-ntype> = $return-ntype;

    # Signal parameter info
    $curr-signal<parameters> = [];
    my @prmtrs = $xpath.find( 'parameters/parameter', :start($si), :to-list);
    for @prmtrs -> $parameter {
      my Hash $attribs = $parameter.attribs;
      my $pname = $!mod.cleanup-id($attribs<name>);
      my $transfer-ownership = $attribs<transfer-ownership>;
      my Str ( $pdoc, $type, $raku-type) =
        self.get-doc-type( $parameter, $xpath, :!user-side);
      $curr-signal<parameters>.push: %(
        :$pname, :$pdoc, :$type, :$raku-type, :$transfer-ownership
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

      # add-example-code() returns a key
      my Str $ex-key = $!dtxt.add-example-code(qq:to/EOEX/);

        =head2 Example
        # Example for signal $signal-name
        EOEX

      $doc ~= qq:to/EOSIG/;

        {HLPODSEPARATOR}
        =head3 $signal-name

        $curr-signal<sdoc>

        =begin code
        method handler \(
        EOSIG

      for @($curr-signal<parameters>) -> $parameter {
        my $raku-type = $parameter<raku-type>;
        if $raku-type ~~ m/ GEnum / {
          $raku-type = Int();
        }

        elsif $raku-type ~~ m/ GFlag / {
          $raku-type = UInt();
        }

        $doc ~= "  $raku-type \$$parameter<pname>,\n";
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

#$*work-data<raku-class-name>\(\) :\$_native-object,
      $doc ~= qq:to/EOSIG/;
          Int :\$_handle_id,
          N-GObject :\$_native-object,
          $*work-data<raku-class-name> :\$_widget,
          *\%user-options$rv-method
        )
        =end code

        EOSIG

      for @($curr-signal<parameters>) -> $parameter {
        my Str $own = ( ?$parameter<transfer-ownership> and
                        $parameter<transfer-ownership> ne 'none'
                      ) ?? "\(transfer ownership: $parameter<transfer-ownership>)"
                        !! '';
        $doc ~= "=item \$$parameter<pname>; $own$parameter<pdoc>.\n";
      }

      $doc ~= qq:to/EOSIG/;
        =item \$_handle_id; The registered event handler id.
        =item \$_native-object; The native object provided by the Raku object which registered this event. This a native B<$*work-data<raku-class-name>> object.
        =item \$_widget; The object which registered the signal. User code may have left the object going out of scope.
        =item \%user-options; A list of named arguments provided at the C<.register-signal\()> method from B<Gnome::GObject::Object>.
        EOSIG
      $doc ~= $returns-doc;
      $doc ~= "\n$ex-key\n";

#`{{
      $doc ~= "Return value \(transfer ownership: $curr-signal<return-ntype> \($curr-signal<transfer-ownership>); $curr-signal<rv-doc>\n"
            if $curr-signal<return-ntype> ne 'void';
}}
    }

    $doc ~= "=end pod\n\n";
  }

  $sig-info<doc> = $doc;
  $sig-info<signals> = $signals;

  $sig-info
}

#-------------------------------------------------------------------------------
method document-constants ( @constants --> Str ) {

  # Return empty string if no constants found.
  return '' unless ?@constants;

  # Open constants file for xpath
  my Str $file = $*work-data<gir-module-path> ~ 'repo-constant.gir';
  my XML::XPath $xpath .= new(:$file);

  my Str $doc = qq:to/EOENUM/;

    {pod-header('Constants')}
    =begin pod
    =head1 Constants
    EOENUM

  # For each of the found names
  for @constants.sort -> $constant {
    $doc ~= qq:to/EOENUM/;

    =head2 $constant

    EOENUM

    # Must have a name to search using the @name attribute on an element
    my Str $prefix = $*work-data<name-prefix>.uc;
    my Str $name = $constant;
    $name ~~ s/^ $prefix '_' //;

    # Get the XML element of the constant data
    my XML::Element $e = $xpath.find(
      '//constant[@name="' ~ $name ~ '"]', :!to-list
    );

    $doc ~= $xpath.find( 'doc/text()', :start($e), :!to-list).Str // '';
    $doc ~= "\n";
  }

  $doc ~= "=end pod\n\n";

  $doc
}

#-------------------------------------------------------------------------------
method document-enumerations ( @enum-names --> Str ) {

  # Return empty string if no enums found.
  return '' unless ?@enum-names;

  # Open enumerations file for xpath
  my Str $file = $*work-data<gir-module-path> ~ 'repo-enumeration.gir';
  my XML::XPath $xpath .= new(:$file);

  my Str $doc = qq:to/EOENUM/;
    {pod-header('Enumerations')}
    =begin pod
    =head1 Enumerations

    EOENUM

  # For each of the found names
  for @enum-names.sort -> $enum-name {
    $doc ~= qq:to/EOENUM/;

    =head2 $enum-name

    EOENUM

    # Must have a name to search using the @name attribute on an element
    my Str $prefix = $*work-data<name-prefix>.uc;
    my Str $name = $enum-name;
    $name ~~ s:i/^ $prefix //;
#note "$?LINE $prefix, $name";

    # Get the XML element of the enum data
    my XML::Element $e = $xpath.find(
      '//enumeration[@name="' ~ $name ~ '"]', :!to-list
    );

    $doc ~= $xpath.find( 'doc/text()', :start($e), :!to-list).Str // '';
    $doc ~= "\n";

    my @members = $xpath.find( 'member', :start($e), :to-list);
    for @members -> $m {
      $doc ~= '=item C<' ~ $m.attribs<c:identifier> ~ '>; ';
      $doc ~= $xpath.find( 'doc/text()', :start($m), :!to-list).Str // '';
      $doc ~= "\n";
    }
  }

  $doc ~= "=end pod\n\n";

  $doc
}

#-------------------------------------------------------------------------------
method document-bitfield ( @bitfield-names --> Str ) {

  # Return empty string if no bitfields found.
  return '' unless ?@bitfield-names;

  # Open bitfields file for xpath
  my Str $file = $*work-data<gir-module-path> ~ 'repo-bitfield.gir';
  my XML::XPath $xpath .= new(:$file);

  my Str $doc = qq:to/EOBITF/;
    {pod-header('Bitfields')}
    =begin pod
    =head1 Bitfields

    EOBITF

  # For each of the found names
  for @bitfield-names.sort -> $bitfield-name {
    $doc ~= qq:to/EOBITF/;

    =head2 $bitfield-name

    EOBITF

    # Must have a name to search using the @name attribute on an element
    my Str $prefix = $*work-data<name-prefix>.uc;
    my Str $name = $bitfield-name;
    $name ~~ s:i/^ $prefix //;
 
    # Get the XML element of the bitfield data
    my XML::Element $e = $xpath.find(
      '//bitfield[@name="' ~ $name ~ '"]', :!to-list
    );

    my Str $bitfield-doc =
      $xpath.find( 'doc/text()', :start($e), :!to-list).Str // '';
    $doc ~= $bitfield-doc ~ "\n";
    $doc ~= "\n";

    my @members = $xpath.find( 'member', :start($e), :to-list);
    for @members -> $m {
      $doc ~= '=item C<' ~ $m.attribs<c:identifier> ~ '>; ';
      $doc ~= $xpath.find( 'doc/text()', :start($m), :!to-list).Str // '';
      $doc ~= "\n";
    }
  }

  $doc ~= "=end pod\n\n";

  $doc
}

#-------------------------------------------------------------------------------
method document-standalone-functions ( @function-names --> Str ) {
  my Hash $hcs = %();

  # Get the function information from an XML file of functions
  my Str $file = $*work-data<gir-module-path> ~ 'repo-function.gir';
  my XML::XPath $xpath .= new(:$file);

  # Get the XML::Element's in @subs of the provided @function-names
  my @subs = ();
  for @function-names -> $name {
    my XML::Element $element =
      $xpath.find( '//function[@name="' ~ $name ~ '"]', :!to-list);

    # Skip empty elements
    next unless ?$element;
#    next if $element.attribs<deprecated>:exists and
#            $element.attribs<deprecated> eq '1';

    @subs.push: $element
  }

  for @subs -> $element {
    my ( $function-name, %h) = self!get-method-data( $element, :$xpath);

    # Function names which are returned emptied, are assumably internal
    next unless ?$function-name and ?%h;

    # Add to hash with functionname as its
    $hcs{$function-name} = %h;
  }

  return '' unless ?$hcs;

  my Str $doc = qq:to/EOSUB/;
    {pod-header('Standalone Functions')}
    =begin pod
    =head1 Standalone Functions
    =end pod

    EOSUB


  $doc ~= self._document-native-subs( $hcs, :routine-type<function>);

  $doc
}


#-------------------------------------------------------------------------------
# Get a callback function pattern. This is used as a type in function arguments
# and other places
method document-callback ( @callbacks --> Str ) {
  my Str $doc = qq:to/EOCB/;
    {pod-header('Callback Functions')}
    =begin pod
    =head1 Callback Functions
    EOCB

  for @callbacks -> $callback-name is copy {
    my $prefix = $*work-data<name-prefix>;
    $callback-name ~~ s:i/^ $prefix //;

    my Str $file = $*work-data<gir-module-path> ~ 'repo-callback.gir';
    my XML::XPath $xpath .= new(:$file);
    my XML::Element $element =
      $xpath.find( '//callback[@name="' ~ $callback-name ~ '"]', :!to-list);

    # Skip empty elements
    next unless ?$element;

    $doc ~= self!document-cb(
      $callback-name,
      self!get-callback-data( $element, :$xpath)
    );
  }

  $doc ~= "=end pod\n";

  $doc
}

#-------------------------------------------------------------------------------
# A simplified method
method !get-callback-data (
  XML::Element $e, XML::XPath :$xpath --> Hash
) {
#  my XML::Element $rvalue = $xpath.find( 'return-value', :start($e));
  #my Str $rv-transfer-ownership = $rvalue.attribs<transfer-ownership>;
  my Str ( $rv-doc, $rv-type, $return-raku-type)
    = self.get-doc-type( $e, $xpath, :user-side);

  # Get all parameters. Mostly the instance parameters come first
  # but I am not certain.
  my @parameters = ();
  my @prmtrs = $xpath.find( 'parameters/parameter', :start($e), :to-list);

#  my Bool $variable-list = False;
  for @prmtrs -> $p {
    my Str ( $pdoc, $type, $raku-type) =
      self.get-doc-type( $p, $xpath, :user-side);
    my Hash $attribs = $p.attribs;
    my Str $parameter-name = $!mod.cleanup-id($attribs<name>);

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
    $ph<pdoc> = $pdoc;

    @parameters.push: $ph;
  }

#  %( :@parameters, :$variable-list, :$rv-type, :$return-raku-type)
  %( :@parameters, $rv-doc, :$rv-type, :$return-raku-type)
}

#-------------------------------------------------------------------------------
method !document-cb ( Str $callback-name, Hash $cb-data --> Str ) {
  return '' unless ?$cb-data;

  my Str $items = '';

  my Str $doc = qq:to/EOCB/;
    =head2 $callback-name

    EOCB

#  my Bool $available = True;
  my Str $par-list = '';
  for @($cb-data<parameters>) -> $parameter {
    my ( $rnt0, $rnt1) = $parameter<raku-type>.split(':');
#`{{
    if $rnt0 ~~ / _UA_ $/ {
      $available = False;
      $rnt0 ~~ s/ _UA_ $//;
    }
}}
    my Str $parameter-name = $parameter<name>;
    $parameter-name ~~ s/ '-' $//;
    $par-list ~= ", $rnt0 \$$parameter-name";

    $items ~= "=item $parameter-name; $parameter<pdoc>\n";
  }

  # Remove first comma and space when there is only one parameter
  $par-list ~~ s/^ . //;

  my Str $returns = '';
  my $xtype = $cb-data<return-raku-type>;
  my ( $rnt0, $rnt1) = $xtype.split(':');
  if ?$rnt0 and $rnt0 ne 'void' {
#`{{
    if $rnt0 ~~ / _UA_ $/ {
      $available = False;
      $rnt0 ~~ s/ _UA_ $//;
    }
}}
    $returns = $rnt0;
  }

  $doc ~= qq:to/EOCB/;
    =head3 Signature
    =begin code
    :\( $par-list {?$returns ?? " --> $returns \)" !! ' )'}
    =end code

    $items
    EOCB

  $doc
}


#-------------------------------------------------------------------------------
method !get-types ( Hash $parameter, @rv-list --> Hash ) {

  my Str $own = '';
#  my Int $a-count = 0;
  my Hash $result = %();

  given my $xtype = $parameter<raku-type> {
    when 'N-Object' {
      $result<raku-list> = ", $xtype \$$parameter<name>";

      $own = "\(transfer ownership: $parameter<transfer-ownership>\) "
        if ?$parameter<transfer-ownership> and
          $parameter<transfer-ownership> ne 'none';

      $result<items-doc> =  "=item \$$parameter<name>; $own$parameter<doc>\n";
    }

    when 'CArray[Str]' {
      $result<raku-list> = ", $xtype \$$parameter<name>";

  #    $a-count++;

      $own = "\(transfer ownership: $parameter<transfer-ownership>\) "
        if ?$parameter<transfer-ownership> and
          $parameter<transfer-ownership> ne 'none';

      $result<items-doc> = "=item \$$parameter<name>; $own$parameter<doc>\n";
    }

    when 'CArray[gint]' {
      @rv-list.push: "\$$parameter<name>";
      $result<raku-list> = ", $xtype \$$parameter<name>";
      $result<rv-list> = "\$$parameter<name>";

      $own = "\(transfer ownership: $parameter<transfer-ownership>\) "
        if ?$parameter<transfer-ownership> and
          $parameter<transfer-ownership> ne 'none';

      $result<returns-doc> = "=item \$$parameter<name>; $own$parameter<doc>\n";
      $result<items-doc> = "=item \$$parameter<name>; $own$parameter<doc>\n";
    }

    # Callback function spec
    when / ':(' / {
      my $doc = $parameter<doc>;

#      # Get function name and remove from string
#      $xtype ~~ m/ $<func-name> = <[\w-]>+ '=:(' /;
#      my Str $func-name = $/<func-name>.Str;
#      $xtype ~~ s/ $func-name '=' //;

      $doc ~= '. Tthe function must be specified with following signature; C<' ~ $xtype ~ '>.';
      $result<raku-list> = ", \&$parameter<name>";
      $result<items-doc> = "=item \&$parameter<name>; $doc\n";
    }

    # Variable argument lists
    when '' and $parameter<name> ~~ / \… / {
      my $doc = $parameter<doc>;
      $doc ~~ s/ ','? \s* 'undefined-terminated' //;
      $doc ~= '. Note that each argument must be specified as a type followed by its value!';
      $result<raku-list> = ", …";
      $result<items-doc> = "=item $parameter<name>; $doc\n";
    }

    default {
      $own = "\(transfer ownership: $parameter<transfer-ownership>\) "
        if ?$parameter<transfer-ownership> and
          $parameter<transfer-ownership> ne 'none';

      my Str ( $l, $d ) = self.check-special(
        $xtype, $parameter<name>,
        "=item \$$parameter<name>; $own$parameter<doc>.\n"
      );
      $result<raku-list> = $l;
      $result<items-doc> = $d;
    }
  }

  $result
}
















=finish


#-------------------------------------------------------------------------------
method start-document ( Str $type-letter = '' --> Str ) {
#`{{
  my Str $name = '';
  my Str $author = '';
  my Version $version = v0.1.0;
  my Str $title = '';
  my Str $subtitle = '';
  my Str $raku-version = "$*RAKU.version(), $*RAKU.compiler.version()";

  my META6 $meta;
  my Str $meta-file = [~] './gnome-api2/gnome-', $*gnome-package.Str.lc,
                          '/META6.json';
  if $meta-file.IO.e {
    $meta .= new(:file($meta-file));

    $name = $meta<name>;
    $author = $meta<author>;
    $version = $meta<version>;
    $title = $*work-data<raku-class-name>;
    $subtitle = $meta<description>;
  }

  qq:to/RAKUDOC/;
    use v6.d;

    =begin pod
    =head2 Project Description
    =item B<Distribution:> $name
    =item B<Project description:> $subtitle
    =item B<Project version:> $version.Str()
    =item B<Rakudo version:> $raku-version
    =item B<Author:> $author
    =end pod

    RAKUDOC
}}

  my Str $class-name = $!solve.set-object-name(
    %( :$type-letter, :type-name($*work-data<raku-name>))
  );
  "$*command-line\nuse v6.d;\n\n=begin pod\n=head1 $class-name\n=end pod\n"
}

#-------------------------------------------------------------------------------
method !set-inherit-example ( XML::Element $element --> Str ) {

  my Str $doc = '';
  my Str $ctype = $element.attribs<c:type>;
  my Hash $h = $!solve.search-name($ctype);

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
# NOTE For now, skip property documentation

method document-properties (
  XML::Element $element, XML::XPath $xpath --> Str
) {
  my Str $doc = '';

  my @property-info = $xpath.find( 'property', :start($element), :to-list);

  my Hash $properties = %();
  for @property-info -> $pi {
    my Hash $attribs = $pi.attribs;
    next if $attribs<deprecated>:exists and  $attribs<deprecated> == 1;

    # Property documentation
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
      self.get-doc-type( $pi, $xpath, :!user-side);
    my Str $g-type = self.gobject-value-type($raku-type);
note "$?LINE $property-name, $type, $raku-type, $g-type";
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
    my Hash $curr-property := $properties{$property-name};
#      =comment #TP:0:$property-name:
    $doc ~= qq:to/EOSIG/;

      {HLPODSEPARATOR}
      =head3 $property-name
      EOSIG

#say "$?LINE props $property-name: $curr-property.gist()";

    if $curr-property<pdoc> ~~ m/^ \s* $/ {
      $doc ~= "\nThere is no documentation for this property\n\n";
    }

    else {
      $doc ~= "\n$curr-property<pdoc>\n\n";
    }

    $doc ~= "=item B<Gnome::GObject::Value> for this property is $curr-property<g-type>.\n";

    $doc ~= "=item The native type is $curr-property<raku-type>.\n";

    if $curr-property<writable> {
      $doc ~= "=item Property is readable and writable\n";
    }

    else {
      $doc ~= "=item Property is readonly\n";
    }

    $doc ~= "=item Getter method is $curr-property<pgetter>\n"
      if ?$curr-property<pgetter>;

    $doc ~= "=item Setter method is $curr-property<psetter>\n"
      if ?$curr-property<psetter>;
  }

  $doc ~= "\n=end pod\n\n";

  $doc
}


NOTE For now, skip property documentation

#-------------------------------------------------------------------------------
method gobject-value-type ( Str $ctype is copy --> Str ) {

  my $g-type = '';

  $ctype ~~ s:g/ '*' //;
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
 
    when / GEnum ':' / {
      $g-type = 'G_TYPE_ENUM';
    }
 
    when / GFlag ':' / {
      $g-type = 'G_TYPE_FLAGS';
    }

    default {
      my Hash $h = $!solve.search-name($ctype);
      if ?$h<gir-type> {
        $g-type = 'G_TYPE_ENUM' if $h<gir-type> eq 'enumeration';
        $g-type = 'G_TYPE_FLAGS' if $h<gir-type> eq 'bitfield';
        $g-type = 'G_TYPE_OBJECT' if $h<gir-type> eq 'class';
      }
    }
  }

  $g-type
}


