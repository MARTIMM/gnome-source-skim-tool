
use Gnome::SourceSkimTool::Prepare;
use Gnome::SourceSkimTool::SkimGtkDoc;
use Gnome::SourceSkimTool::ConstEnumType;

use XML;
use XML::XPath;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::GenRakuModule:auth<github:MARTIMM>;

has XML::XPath $!xpath;
has Hash $!object-maps;
has Hash $!other-work-data;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {
#TODO add rules for gdkPixbuf, etc.

  # Because of dependencies it is possible to have less to load when
  # we need to search

  note "Prepare for module generation" if $*verbose;

  # get workdata for other gnome packages
  my Gnome::SourceSkimTool::Prepare $p .= new;
  $!other-work-data = %();

  # Version 3
  if $*gnome-package.Str ~~ / '3' $/ {
    $!other-work-data<Gtk> = $p.prepare-work-data(Gtk3);
    $!other-work-data<Gdk> = $p.prepare-work-data(Gdk3);
  }

  # Version 4
  elsif $*gnome-package.Str ~~ / '3' $/ {
    $!other-work-data<Gtk> = $p.prepare-work-data(Gtk4);
    $!other-work-data<Gdk> = $p.prepare-work-data(Gdk4);
    $!other-work-data<Gsk> = $p.prepare-work-data(Gsk4);
  }

  # If it is a high end module, we add these too
  if $*gnome-package.Str ~~ / '3' || '4' $/ {
    $!other-work-data<Atk> = $p.prepare-work-data(Atk);
    $!other-work-data<Pango> = $p.prepare-work-data(Pango);
    $!other-work-data<Cairo> = $p.prepare-work-data(Cairo);
  }

  # If it is not a high end module, we only need these
  $!other-work-data<Glib> = $p.prepare-work-data(Glib);
  $!other-work-data<Gio> = $p.prepare-work-data(Gio);
  $!other-work-data<GObject> = $p.prepare-work-data(GObject);

  # get object maps
  my Gnome::SourceSkimTool::SkimGtkDoc $s .= new;
  $!object-maps = %();
  if $*gnome-package.Str ~~ / '3' || '4' $/ {
    $!object-maps<Atk> = $s.load-map($!other-work-data<Atk><gir-module-path>);
    $!object-maps<Gtk> = $s.load-map($!other-work-data<Gtk><gir-module-path>);
    $!object-maps<Gdk> = $s.load-map($!other-work-data<Gdk><gir-module-path>);
    $!object-maps<Gsk> = ?$!other-work-data<Gsk> 
                       ?? $s.load-map($!other-work-data<Gsk><gir-module-path>)
                       !! %();
    $!object-maps<Pango> =
      $s.load-map($!other-work-data<Pango><gir-module-path>);
    $!object-maps<Cairo> =
      $s.load-map($!other-work-data<Cairo><gir-module-path>);
  }

  $!object-maps<Glib> = $s.load-map($!other-work-data<Glib><gir-module-path>);
  $!object-maps<Gio> = $s.load-map($!other-work-data<Gio><gir-module-path>);
  $!object-maps<GObject> =
    $s.load-map($!other-work-data<GObject><gir-module-path>);

  # load data for this module
  $!xpath .= new(:file($*work-data<gir-module-file>));
}

#-------------------------------------------------------------------------------
method generate-raku-module ( ) {

  my XML::Element $class-element = $!xpath.find('//class');

  my $module-doc = qq:to/RAKUMOD/;
    #TL:1:$*work-data<raku-class-name>:";
    use v6;
    {HLSEPARATOR}
    RAKUMOD

  note "Generate module description" if $*verbose;  
  $module-doc ~= self!get-description($class-element);

  note "Set class unit" if $*verbose;
  $module-doc ~= self!set-unit($class-element);

  note "Generate BUILD submethod" if $*verbose;  
  $module-doc ~= self!generate-build($class-element);

  note "Generate module methods" if $*verbose;  
#  $module-doc ~= self!generate-methods($class-element);

  note "Generate module signals" if $*verbose;  
  $module-doc ~= self!generate-signals($class-element);

  note "Generate module properties" if $*verbose;  
  $module-doc ~= self!generate-properties($class-element);

  note "Save module";
  $*work-data<raku-module-file>.IO.spurt($module-doc);
}

#-------------------------------------------------------------------------------
method generate-raku-module-test ( ) {
  my $module-test-doc = '';

  note "Save module test";
  $*work-data<raku-module-test-file>.IO.spurt($module-test-doc);
}

#-------------------------------------------------------------------------------
method !get-description ( XML::Element $class-element --> Str ) {
  my Str $doc = "\n=head1 Description\n";

  #$doc ~= self!set-example-image;

  $doc ~= $!xpath.find( 'doc/text()', :start($class-element)).Str;
  $doc = self!modify-text($doc);

  #??$doc ~= self!set-declaration;
  $doc ~= self!set-uml;
  $doc ~= self!set-inherit-example($class-element);
  $doc ~= self!set-example;
  #$doc = self!cleanup($doc);

  qq:to/RAKUMOD/;
    =begin pod
    =head1 $*work-data<raku-class-name>

    $doc
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
method !set-inherit-example ( XML::Element $class-element --> Str ) {

  my Str $doc = '';
  my Str $ctype = $class-element.attribs<c:type>;
  my Hash $h = self.search-name($ctype);

  if $h<inheritable> {
    # Code like {'...'} is inserted here and there to prevent interpretation
    $doc = qq:to/EOINHERIT/;

      =begin comment
      =head2 Inheriting this class

      Inheriting is done in a special way in that it needs a call from new\() to get the native object created by the class you are inheriting from.

        use $*work-data<raku-class-name>;

        unit class MyGuiClass;
        also is $*work-data<raku-class-name>;

        submethod new \( \|c ) \{
          # let the {$*work-data<raku-class-name>} class process the options
          self\.bless\( :{$class-element.attribs<c:type>}, \|c);
        \}

        submethod BUILD \( ... ) \{
          ...
        \}

      =end comment

      EOINHERIT
  }

  $doc
}

#-------------------------------------------------------------------------------
method !set-example ( --> Str ) {
  my Str $doc = q:to/EOEX/;

    =begin comment
    =head2 Example

    =end comment
    EOEX
  $doc
}

#-------------------------------------------------------------------------------
method !set-unit ( XML::Element $class-element --> Str ) {

  my Str $use-enums;

  if $*gnome-package.Str ~~ / '3' $/ {
    $use-enums = "#use Gnome::Gtk3::Enums;\n";
  }

  elsif $*gnome-package.Str ~~ / '4' $/ {
    $use-enums = "#use Gnome::Gtk4::Enums;\n";
  }

  my Str ( $use-parent, $also-is);
  my Str $ctype = $class-element.attribs<c:type>;
  my Hash $h = self.search-name($ctype);

note "$?LINE $ctype, $h.gist()";
  my Str $parent = $h<parent> // '';
  if ?$parent {
    $use-parent = "use $parent;\n";
    $also-is = "also is $parent;\n";
  }

  else {
    $use-parent = $also-is = '';
  }

  my Str $doc = qq:to/RAKUMOD/;

    {HLSEPARATOR}
    use NativeCall;

    use Gnome::N::NativeLib;
    use Gnome::N::N-GObject;
    use Gnome::N::GlibToRakuTypes;

    $use-enums$use-parent

    {HLSEPARATOR}
    unit class {$*work-data<raku-class-name>}:auth<github:MARTIMM>;
    $also-is

    RAKUMOD

  $doc
}

#-------------------------------------------------------------------------------
method !generate-build ( XML::Element $class-element --> Str ) {

  my Str $doc = '';
  my Str $ctype = $class-element.attribs<c:type>;
  my Hash $h = self.search-name($ctype);

  $doc = qq:to/EOBUILD/;

    {HLSEPARATOR}
    =begin pod
    =end pod

    submethod BUILD ( *\%options ) \{

    \}
      
    EOBUILD

#  if $h<inheritable> {
#  self!get-constructors;
#  self!make-build;

  $doc
}

#-------------------------------------------------------------------------------
method !get-constructors ( --> Str ) {
  my Str $doc = '';

  $doc
}

#-------------------------------------------------------------------------------
method !make-build ( --> Str ) {
  my Str $doc = '';

  $doc
}

#-------------------------------------------------------------------------------
method !generate-methods ( XML::Element $class-element --> Str ) {
  my Str $doc = '';

  $doc
}

#-------------------------------------------------------------------------------
method !generate-signals ( XML::Element $class-element --> Str ) {
  my Str $doc = '';

  my @signal-info =
     $!xpath.find( 'glib:signal', :start($class-element), :to-list);

  my Hash $signals = %();
  for @signal-info -> $si {
    my Hash $attribs = $si.attribs;
    next if $attribs<deprecated>:exists and  $attribs<deprecated> == 1;

    # signal documentation
    my Str $sname = $attribs<name>;
    my Str $sdoc = self!modify-text(
      ($!xpath.find( 'doc/text()', :start($si)) // '').Str
    );
    $signals{$sname} = %(:$sdoc,);

    # return value info
    my XML::Element $rvalue = $!xpath.find( 'return-value', :start($si));
    $signals{$sname}<rv-trans-own> = $rvalue.attribs<transfer-ownership>;
    for $rvalue.nodes -> $n {
      next if $n ~~ XML::Text;

      if $n.name eq 'doc' {
        $signals{$sname}<rv-doc> = self!modify-text(
          ($!xpath.find( 'text()', :start($n)) // '').Str
        );
      }

      elsif $n.name eq 'type' {
        $signals{$sname}<rv-ctype> =
          self.convert-type($n.attribs<c:type> // '');
        $signals{$sname}<rv-type> = $n.attribs<name>;
      }
    }

    # parameter info
    $signals{$sname}<parameters> = [];
    my @paramtrs =
        $!xpath.find( 'parameters/parameter', :start($si), :to-list);
    for @paramtrs -> $prmtr {
      my Hash $attribs = $prmtr.attribs;
      my $pname = $attribs<name>;
      my $p-trans-own = $attribs<transfer-ownership>;
      my Str ( $pdoc, $ptype, $pctype);
      for $prmtr.nodes -> $n {
        next if $n ~~ XML::Text;

        if $n.name eq 'doc' {
          $pdoc = self!modify-text(
            ($!xpath.find( 'text()', :start($n)) // '').Str
          );
        }

        elsif $n.name eq 'type' {
          $ptype = $n.attribs<name>;
          $pctype = self.convert-type($n.attribs<c:type> // $ptype // '');
        }
      }

      $signals{$sname}<parameters>.push: %(
        :$pname, :$pdoc, :$ptype, :$pctype, :$p-trans-own
      );
    }
  }

  $doc ~= qq:to/EOSIG/;

    {HLSEPARATOR}
    =begin pod
    =head1 Signals
    EOSIG

  for $signals.keys.sort -> $sname {
    $doc ~= qq:to/EOSIG/;

      {HLPODSEPARATOR}
      =comment #TS:0:$sname:
      =head3 $sname

      $signals{$sname}<sdoc>

      =begin code
      method handler \(
      EOSIG

    for @($signals{$sname}<parameters>) -> $prmtr {
      $doc ~= "  $prmtr<pctype> \$$prmtr<pname>,\n";
    }

    $doc ~= qq:to/EOSIG/;
        Int :\$_handle_id,
        $*work-data<raku-class-name>\(\) :\$_native-object,
        $*work-data<raku-class-name> :\$_widget,
        *\%user-options
      )
      =end code

      EOSIG

    for @($signals{$sname}<parameters>) -> $prmtr {
      $doc ~= "=item $prmtr<pname> \(transfer ownership: $prmtr<p-trans-own>); $prmtr<pdoc>.\n";
    }

    $doc ~= q:to/EOSIG/;

      =item $_handle_id; the registered event handler id.

      =item $_native-object; The native object provided by the caller wrapped in the Raku object.

      =item $_widget; the object which received the signal.

      =item %user-options; A list of named arguments provided at the C<.register-signal() method from Gnome::GObject::Object>.

      EOSIG

    $doc ~= "Return value \(transfer ownership: $signals{$sname}<rv-ctype> \($signals{$sname}<rv-trans-own>); $signals{$sname}<rv-doc>\n"
          if $signals{$sname}<rv-ctype> ne 'void';
  }

  $doc ~= "\n=end pod\n\n";

  $doc
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
    my Str $sname = $attribs<name>;
    my Bool $pwrite = $attribs<writable>.Bool;

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

    my Str $p-trans-own = $attribs<transfer-ownership>;

    my Str ( $sdoc, $ptype, $pctype, $pvtype);
    for $pi.nodes -> $n {
      next if $n ~~ XML::Text;

      if $n.name eq 'doc' {
        $sdoc = self!cleanup(
          self!modify-text(
            ($!xpath.find( 'text()', :start($n)) // '').Str
          )
        );
      }

      elsif $n.name eq 'type' {
        $pctype = self.convert-type($n.attribs<c:type> // '');
        $ptype = $n.attribs<name>;
        $pvtype = self.gobject-value-type($pctype);
      }
    }

    $properties{$sname} = %(
      :$sdoc, :$pwrite, :$ptype, :$pctype, :$pvtype,
      :$pgetter, :$psetter, :$p-trans-own
    );
  }

  $doc ~= qq:to/EOSIG/;

    {HLSEPARATOR}
    =begin pod
    =head1 Properties
    EOSIG

  for $properties.keys.sort -> $sname {
    $doc ~= qq:to/EOSIG/;

      {HLPODSEPARATOR}
      =comment #TP:0:$sname:
      =head3 $sname
      EOSIG

#note "$?LINE props $sname: $properties{$sname}.gist()";

    if $properties{$sname}<sdoc> ~~ m/^ \s* $/ {
      $doc ~= "\nThere is no documentation for this property\n\n";
    }

    else {
      $doc ~= "\n$properties{$sname}<sdoc>\n\n";
    }

    $doc ~= "=item B<Gnome::GObject::Value> for this property is $properties{$sname}<pvtype>.\n";

    $doc ~= "=item The field type is $properties{$sname}<pctype>.\n";

    if $properties{$sname}<pwrite> {
      $doc ~= "=item Property is readable and writable\n";
    }

    else {
      $doc ~= "=item Property is readonly\n";
    }

    $doc ~= "=item Getter method is $properties{$sname}<pgetter>\n"
      if ?$properties{$sname}<pgetter>;

    $doc ~= "=item Setter method is $properties{$sname}<psetter>\n"
      if ?$properties{$sname}<psetter>;
  }

  $doc ~= "\n=end pod\n\n";

  $doc
}

#-------------------------------------------------------------------------------
method gobject-value-type( Str $ctype --> Str ) {

  my $vtype = '';

  with $ctype {
    when 'gboolean' {
      $vtype = 'G_TYPE_BOOLEAN';
    }

    when 'gchar' {
      $vtype = 'G_TYPE_CHAR';
    }

    when 'gdouble' {
      $vtype = 'G_TYPE_DOUBLE';
    }
    
    when 'gfloat' {
      $vtype = 'G_TYPE_FLOAT';
    }
    
    when 'gint' {
      $vtype = 'G_TYPE_INT';
    }
    
#    when 'gint16' {
#      $vtype = '';
#    }
    
#    when 'gint32' {
#      $vtype = '';
#    }
    
    when 'gint64' {
      $vtype = 'G_TYPE_INT64';
    }
    
    when 'gint8' {
      $vtype = 'G_TYPE_CHAR';
    }
    
    when 'glong' {
      $vtype = 'G_TYPE_LONG';
    }
    
    when 'gpointer' {
      $vtype = 'G_TYPE_POINTER';
    }
    
#    when 'gshort' {
#      $vtype = '';
#    }
    
#    when 'gsize' {
#      $vtype = '';
#    }
    
#    when 'gssize' {
#      $vtype = '';
#    }
    
    when 'guchar' {
      $vtype = 'G_TYPE_UCHAR';
    }
    
    when 'guint' {
      $vtype = 'G_TYPE_UINT';
    }
    
#    when 'guint16' {
#      $vtype = '';
#    }
    
#    when 'guint32' {
#      $vtype = '';
#    }
    
    when 'guint64' {
      $vtype = 'G_TYPE_UINT64';
    }
    
    when 'guint8' {
      $vtype = 'G_TYPE_UCHAR';
    }
    
    when 'gulong' {
      $vtype = 'G_TYPE_ULONG';
    }
    
#    when 'gunichar' {
#      $vtype = '';
#    }
    
#    when 'gushort' {
#      $vtype = '';
#    }
    
    default {
    }
  }

note "$?LINE vtype of $ctype is $vtype";

  $vtype
}










#-------------------------------------------------------------------------------
method search-name ( Str $name --> Hash ) {

  my Hash $h = %();
  for <Gtk Gdk Gsk Glib Gio GObject Pango Cairo PangoCairo> -> $map-name {

    # It is possible that not all hashes are loaded
    next unless $!object-maps{$map-name}:exists
            and ( $!object-maps{$map-name}{$name}:exists 
                  or $!object-maps{$map-name}{$map-name ~ $name}:exists
                );

    # Get the Hash from the object maps
    $h = $!object-maps{$map-name}{$name}
         // $!object-maps{$map-name}{$map-name ~ $name};

    # Add package name to this hash
    $h<raku-package> = $!other-work-data{$map-name}<raku-package>;
    last;
  }

say "$?LINE: search $name -> {$h<rname> // $h.gist}";

  $h
}

#-------------------------------------------------------------------------------
method convert-type ( Str $ctype --> Str ) {
  return '' unless ?$ctype;

  my Str $rtype = '';
  with $ctype {
    when any(
        <gboolean gchar gdouble gfloat gint gint16 gint32 gint64 gint8 
        glong gpointer gshort gsize gssize guchar guint guint16
        guint32 guint64 guint8 gulong gunichar gushort
        >
    ) {
      $rtype = $ctype;
    }

    when any(
        <boolean char double float int int16 int32 int64 int8 
        long pointer short size ssize uchar uint uint16
        uint32 uint64 uint8 ulong unichar ushort
        >
    ) {
      $rtype = "g$ctype;";
    }

    when m/char \s* '*'/ { $rtype = 'Str'; }
    when m/char \s* '*' \s* '*'/ { $rtype = 'CArray[Str]'; }
    when 'void' { $rtype = 'void'; }

    default {
      my Hash $h = self.search-name($ctype);
      given $h<gir-type> // '-' {
        when 'class' { $rtype = 'N-GObject'; }
        when 'enumeration' { $rtype = 'GEnum'; }
        when 'bitfield' { $rtype = 'GFlag'; }
#        when 'record' { }
#        when 'callback' { }
#        when 'interface' { }
#        when '' { }

        default { note "Unknown ctype: '$ctype', $h.gist()"; }
      }
    }
  }

say "$?LINE: convert $ctype -> '$rtype'";

  $rtype
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
  $text = self!modify-css($text);
  $text = self!modify-functions($text);
  $text = self!modify-classes($text);
  $text = self!modify-markdown-links($text);
  $text = self!modify-rest($text);

  # Subtitute the examples back into the text before we can finally modify it
  for $examples.keys -> $ex-key {
    $text ~~ s/ $ex-key /$examples{$ex-key}/;
  }

  $text = self!modify-xml($text);
  $text = self!modify-examples($text);

  $text;
}

#-------------------------------------------------------------------------------
# Modify text '::sig-name'
method !modify-signals ( Str $text is copy --> Str ) {

  my Str $section-prefix-name = $*work-data<gnome-name>;
  my Regex $r = / '#'? $<cname> = [\w+]? '::' $<sname> = [<[-\w]>+] /;
  while $text ~~ $r {
    my Str $sname = $<sname>.Str;
    my Str $cname = ($<cname>//'').Str;
    if !$cname or $cname eq $section-prefix-name {
      $text ~~ s:g/ '#'? $cname '::' $sname /I<property $sname>/;
    }

    else {
      $text ~~ s:g/ '#'? $cname'::' $sname /I<property $sname defined in $cname>/;
    }
  }

#`{{
  if $text ~~ m/ '#' $section-prefix-name '::' \w+ / {
    $text ~~ s:g/ '#' $section-prefix-name '::' (<[-\w]>+) /I<signal $0>/;
  }

  elsif $text ~~ m/ '#' \w+ '::' \w+ / {
    $text ~~ s:g/ '#' (\w+) '::' (<[-\w]>+) / I<signal $1 defined in $0>/;
  }

  elsif $text ~~ m/ '#' '::' \w+ / {
    $text ~~ s:g/ '#' '::' (<[-\w]>+) / I<signal $0>/;
  }
}}

  $text;
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

#`{{
  if $text ~~ m/ '#' $section-prefix-name ':' \w+ / {
    $text ~~ s:g/ '#' $section-prefix-name ':' (<[-\w]>+) /I<property $0>/;
  }

  elsif $text ~~ m/ '#' \w+ ':' \w+ / {
    $text ~~ s:g/ '#' (\w+) ':' (<[-\w]>+) /
    $text ~~ s:g/ '#' (\w+) ':' (<[-\w]>+) / I<property $1 defined in $0>/;
  }

  elsif $text ~~ m/ '#' ':' \w+ / {
    $text ~~ s:g/ '#' ':' (<[-\w]>+) / I<property $0>/;
  }
}}

  $text;
}

#-------------------------------------------------------------------------------
method !modify-css ( Str $text is copy --> Str ) {

  $text ~~ s:g/ \s '.' (<[-\w]>+) / C<.$0>/ if $text ~~ m/ \s '.' \w /;
  $text ~~ s:g/ \s '#' (<[-\w]>+) / C<#$0>/ if $text ~~ m/ \s '#' \w /;

  $text;
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
    my Hash $h = self.search-name($function-name);
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

  $text;
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
    my Hash $h = self.search-name($class-name);
    my Str $raku-name = $h<rname> // '';

    if ?$raku-name {
      $text ~~ s:g/ '#'? $class-name /B<\x200B$raku-name>/;
    }

    else {
      $text ~~ s:g/ '#'? $class-name /\x200B$class-name/;
    }
  }

  # After all work remove the zero width space marker
  $text ~~ s:g/ \x200B //;

  $text;
}

#-------------------------------------------------------------------------------
# convert |[ … ]| marks. Must be processed at the end because other
# modifications may depend on those marks
method !modify-examples ( Str $text is copy --> Str ) {

  $text ~~ s:g/^^ '|[' \s* '<!--' \s* 'language="xml"' \s* '-->' 
              /=begin comment\nFollowing text is XML\n=begin code\n/;

  $text ~~ s:g/^^ '|[<!-- language="plain" -->'
              /=begin comment\n=begin code/;

  $text ~~ s:g/^^ '|[' \s* '<!--' \s* 'language="C"' \s* '-->' 
              /=begin comment\n=begin code/;

  $text ~~ s:g/^^ ']|' /=end code\n=end comment\n/;

  $text;
}

#-------------------------------------------------------------------------------
# Modify xml remnants
method !modify-xml ( Str $text is copy --> Str ) {
  
  # xml escapes
  $text ~~ s:g/ '&lt;' /</;
  $text ~~ s:g/ '&gt;' />/;
  $text ~~ s:g/ '&amp;' /\&/;
  $text ~~ s:g/ [ '&#160;' || '&nbsp;' ] / /;

  $text;
}

#-------------------------------------------------------------------------------
method !modify-markdown-links ( Str $text is copy --> Str ) {
  $text ~~ s:g/ \s '[' ( <-[\]]>+ ) '][' <-[\]]>+ ']' / $0/;

  $text;
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

  $text;
}

#-------------------------------------------------------------------------------
method !cleanup ( Str $text is copy, Bool :$trim = False --> Str ) {
#  $text = self!scan-for-unresolved-items($text);

  $text ~~ s:g/ ' '+ / /;
  $text ~~ s:g/ <|w> \n <|w> / /;
  $text ~~ s:g/ \n ** 3..* /\n\n/;

  if $trim {
    $text ~~ s/^ \s+ //;
    $text ~~ s/ \s+ $//;
  }

  $text
}
















=finish

use Gnome::SourceSkimTool::ConstEnumType;
use Gnome::SourceSkimTool::SkimGtkDoc::ModuleDoc;
use Gnome::SourceSkimTool::SkimGtkDoc::ApiIndex;
use Gnome::SourceSkimTool::Prepare;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::GenRakuModule:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
constant \Prepare = Gnome::SourceSkimTool::Prepare;
constant \ModuleDoc = Gnome::SourceSkimTool::SkimGtkDoc::ModuleDoc;
constant \ApiIndex = Gnome::SourceSkimTool::SkimGtkDoc::ApiIndex;

has Prepare $!preparation .= new;
has ModuleDoc $!module-docs handles <
  description functions signals properties types
>;
has ApiIndex $!api-docs handles <objects>;

# holds all content
has Str $!raku-test;

# holds build method only and native new functions
has Str $!build-method;
has Str $!build-doc;

# holds all methods and native functions
has Str $!methods;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {
  die "A Raku module name is missing" unless ?$*gnome-class;
  $!preparation .= new;

  $!module-docs .= new;
  $!module-docs.load-module($*work-data<skim-module-result>);

  $!api-docs .= new;
  $!api-docs.load-objects;
  
  $!raku-test = '';
}

#-------------------------------------------------------------------------------
method generate ( ) {
  self!generate-methods;
}

#-------------------------------------------------------------------------------
method !generate-methods ( ) {
  $!methods = '';
  $!build-method = '';
  $!build-doc = q:to/EOBUILD/;
    #-------------------------------------------------------------------------------
    =begin pod
    =head1 Methods
    =head2 new
    EOBUILD

  my Hash $functions := $!module-docs.functions;
  for $functions.keys.sort -> $fname {
    if $fname ~~ m/ <|w> new <|w> / {
      self!add-new-function( $fname, $functions{$fname});
    }

    else {
      self!add-method( $fname, $functions{$fname});
    }
  }

  $!build-doc ~= q:to/EOBUILD/;
    =end pod

    =head3 :native-object

    Create a RAKU-CLASS-NAME object using a native object from elsewhere. See also B<Gnome::N::TopLevelClassSupport>.

      multi method new ( N-GObject :$native-object! )


    =head3 :build-id

    Create a RAKU-CLASS-NAME object using a native object returned from a builder. See also B<Gnome::GObject::Object>.

      multi method new ( Str :$build-id! )

    =end pod
    EOBUILD
}

#-------------------------------------------------------------------------------
method !add-new-function ( Str $fname, Hash $fdata ) {
  #$!build-method

#  my Str $sub-doc = $fdata<doc><function>;
  my Str $native-sub-name = '_' ~ $fdata<native-name>;
  my Str $args = '';
  my Str $returns = '';
  my Str $pod-args = '';
  my Str $pod-returns = '';
  my Str $pod-doc-items = '';

  # The native subroutine documentation
  if $fname eq 'new' {
    $!build-doc ~= qq:to/EOBUILD/;

      =head3 default, no options

      $fdata<doc><function>

        multi method new ( )
      EOBUILD
  }

  else {
    $!build-doc ~= qq:to/EOBUILD/;

      =head3 :$fname

      $fdata<doc><function>

        multi method new ( :$fname! )

      EOBUILD
  }

  # The native subroutine declaration
  my Str $sub = qq:to/EOSUB/;

    #-------------------------------------------------------------------------------
    #TM:1:$native-sub-name:

    sub $native-sub-name ( $args $returns )
      is native($*work-data<library>)
      is symbol\('$fdata<native-name>')
      \{ * \}
    EOSUB

  $!methods ~= $sub;
}

#-------------------------------------------------------------------------------
method !add-method ( Str $fname, Hash $fdata ) {
}

#-------------------------------------------------------------------------------
method save ( ) {
  my Str $parent = $!preparation.raku-class-name(
    :gnome-name($!api-docs.objects(){$*gnome-class}<parent>),
    :package($*gnome-package)
  );

  # only inheriting on widget classes except GtkWidget
  my Str $inheriting-doc = '';
  my Str $inheriting-code = '';

  my Str $raku-module = qq:to/EOMODULE/;
    #TL:1:$*work-data<raku-class-name>:

    use v6;

    =begin pod
    $!module-docs.description()
    =end pod

    #-------------------------------------------------------------------------------
    use NativeCall;

    use Gnome::N::NativeLib;
    use Gnome::N::N-GObject;
    use Gnome::N::GlibToRakuTypes;

    # !!!this is not always from the same raku package!!!
    use $parent;
    #use Gnome::Gtk3::Enums;

    #-------------------------------------------------------------------------------
    # See /usr/include/gtk-3.0/gtk/gtkbutton.h
    # https://developer.gnome.org/gtk3/stable/GtkButton.html
    unit class $*work-data<raku-class-name>:auth<github:MARTIMM>;
    also is $parent;
    #also does …;

    #-------------------------------------------------------------------------------
    my Bool \$signals-added = False;


    $!build-doc

    $!build-method

    $!methods
    EOMODULE

  note "Save $*work-data<new-raku-modules>$*gnome-class.rakumod" if $*verbose;
  "$*work-data<new-raku-modules>$*gnome-class.rakumod".IO.spurt($raku-module);

  note "Save $*work-data<new-raku-modules>$*gnome-class.rakutest" if $*verbose;
  "$*work-data<new-raku-modules>$*gnome-class.rakutest".IO.spurt($!raku-test);
}