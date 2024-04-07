
use Gnome::SourceSkimTool::ConstEnumType;
use Gnome::SourceSkimTool::Doc;
use Gnome::SourceSkimTool::Code;
use Gnome::SourceSkimTool::Test;
use Gnome::SourceSkimTool::Resolve;

use XML;
use XML::XPath;
use JSON::Fast;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::Interface:auth<github:MARTIMM>;

has Gnome::SourceSkimTool::Doc $!grd;
has Gnome::SourceSkimTool::Code $!mod;
has Gnome::SourceSkimTool::Test $!tst;
has Gnome::SourceSkimTool::Resolve $!solve;

has XML::XPath $!xpath;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {

  $!mod .= new;
  $!solve .= new;

  # load data for this module
  my Str $file = "$*work-data<gir-module-path>I-$*work-data<raku-name>.gir";
  note "Load module data from $file" if $*verbose;
  $!xpath .= new(:$file);
}

#-------------------------------------------------------------------------------
method generate-code ( ) {

  my XML::Element $element = $!xpath.find('//interface');
  die "//interface not found in gir-interface-file for $*work-data<raku-class-name>" unless ?$element;

  my Str $code = qq:to/RAKUMOD/;
    $*command-line
    use v6.d;
    RAKUMOD

  my $callables = $!mod.generate-callables( $element, $!xpath, :is-interface);

  note "Set role unit" if $*verbose;
  $code ~= $!mod.set-unit( $element, :callables(?$callables));

  # Roles do not have a BUILD
  note "Generate role initialization method" if $*verbose;  
  $code ~= $!mod.generate-role-init( $element, $!xpath);
  $code ~= $callables;

  $code = $!mod.substitute-MODULE-IMPORTS( $code, $*work-data<raku-class-name>);

  my Hash $h0 = $!solve.search-name($*work-data<gnome-name>);
  my Str $fname = $!solve.set-object-name( $h0, :name-type(FilenameCodeType));
#  my Str $fname = "$*work-data<result-mods>R-$*gnome-class.rakumod";
  $!mod.save-file( $fname, $code, "interface module");
}

#-------------------------------------------------------------------------------
method generate-doc ( ) {

  $!grd .= new;

  my XML::Element $element = $!xpath.find('//interface');
  die "//class not found in $*work-data<gir-interface-file> for $*work-data<raku-class-name>" unless ?$element;

#  note "Document init" if $*verbose;
#  my Str $doc = $!grd.start-document;

  note "Document module description" if $*verbose;
  my Str $doc ~= $!grd.get-description( $element, $!xpath);

#  note "Document BUILD submethod" if $*verbose;
#  my Hash $hcs =
#    $!grd.get-native-subs( $element, $!xpath, :routine-type<constructor>);
#  $doc ~= $!grd.document-build($element);

#  note "Document constructors" if $*verbose;
#  $doc ~= $!grd.document-constructors( $element, $!xpath);
#  $doc ~= $!grd.document-native-subs(
#    $element, $!xpath, :routine-type<constructor>
#  );

  note "Document methods" if $*verbose;
  $doc ~= $!grd.document-native-subs( $element, $!xpath, :routine-type<method>);

  note "Document functions" if $*verbose;
  $doc ~= $!grd.document-native-subs(
    $element, $!xpath, :routine-type<function>
  );

  note "Document signals" if $*verbose;
  my Hash $sig-info = $!grd.document-signals( $element, $!xpath);
  $doc ~= $sig-info<doc>;

#NOTE For now, skip property documentation
#  note "Generate module properties doc" if $*verbose;  
#  $doc ~= $!grd.document-properties( $element, $!xpath);

#  note "Save pod doc";

  my Hash $h0 = $!solve.search-name($*work-data<gnome-name>);
  my Str $fname = $!solve.set-object-name( $h0, :name-type(FilenameDocType));
#  my Str $fname = $*work-data<result-docs> ~ $*gnome-class ~ '.rakudoc';
  $!mod.save-file( $fname, $doc, "interface documentation");
}

#-------------------------------------------------------------------------------
method generate-test ( ) {

  $!tst .= new;

  my XML::Element $element = $!xpath.find('//interface');
  $!mod.add-import($*work-data<raku-class-name>);

  my Hash $h0 = $!solve.search-name($*work-data<gnome-name>);
  my Str $test-variable = $!solve.set-object-name(
    $h0, :name-type(TestVariableType)
  );

  my Str $ctype = $element.attribs<c:type>;
  my Hash $h = $!solve.search-name($ctype);
  my Str $code = $!tst.prepare-test($h<class-name>);

  $code ~= $!tst.generate-test-separator;

  my Hash $hcs = $!mod.get-native-subs(
    $element, $!xpath, :routine-type<method>
  );
  $code ~= $!tst.generate-method-tests( $hcs, $test-variable);
  $code ~= $!tst.generate-test-end;
  $code ~= $!tst.generate-signal-tests($test-variable);
  $code = $!mod.substitute-MODULE-IMPORTS($code);

  my Str $fname = $!solve.set-object-name( $h0, :name-type(FilenameTestType));
  $!mod.save-file( $fname, $code, "interface tests");
}
