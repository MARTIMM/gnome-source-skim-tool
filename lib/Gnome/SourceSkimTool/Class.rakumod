
use Gnome::SourceSkimTool::ConstEnumType;
use Gnome::SourceSkimTool::Doc;
use Gnome::SourceSkimTool::Code;
use Gnome::SourceSkimTool::Test;
use Gnome::SourceSkimTool::Resolve;

use XML;
use XML::XPath;
use JSON::Fast;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::Class:auth<github:MARTIMM>;

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
  my Str $file = "$*work-data<gir-module-path>C-$*work-data<raku-name>.gir";
  note "Load module data from $file" if $*verbose;
  $!xpath .= new(:$file);
}

#-------------------------------------------------------------------------------
method generate-code ( ) {

  my XML::Element $element = $!xpath.find('//class');
  die "//class not found in $*work-data<gir-class-file> for $*work-data<raku-class-name>" unless ?$element;

  my Str $code = qq:to/RAKUMOD/;
    $*command-line
    use v6.d;
    RAKUMOD

  my $callables = $!mod.generate-callables( $element, $!xpath);
  note "Set class unit" if $*verbose;
  $code ~= $!mod.set-unit( $element, :callables(?$callables));

  # Make a BUILD submethod
  note "Generate BUILD" if $*verbose;
  $code ~= $!mod.make-build-submethod( $element, $!xpath);
  $code ~= $callables;

  $code = $!mod.substitute-MODULE-IMPORTS( $code, $*work-data<raku-class-name>);

  my Hash $h0 = $!solve.search-name($*work-data<gnome-name>);
  my Str $fname = $!solve.set-object-name( $h0, :name-type(FilenameCodeType));
#  my Str $fname = "$*work-data<result-mods>$*work-data<raku-name>.rakumod";
  $!mod.save-file( $fname, $code, "class module");
}

#-------------------------------------------------------------------------------
method generate-doc ( ) {

  $!grd .= new;

  my XML::Element $element = $!xpath.find('//class');
  die "//class not found in $*work-data<gir-class-file> for $*work-data<raku-class-name>" unless ?$element;

#  note "Document init" if $*verbose;
#  my Str $doc = $!grd.start-document;

  note "Document module description" if $*verbose;
  my Str $doc ~= $!grd.get-description( $element, $!xpath);
#note "$?LINE $doc";
#exit;

  note "Document BUILD submethod" if $*verbose;
#  my Hash $hcs =
#    $!grd.get-native-subs( $element, $!xpath, :routine-type<constructor>);
  $doc ~= $!grd.document-build($element);

  note "Document constructors" if $*verbose;
  $doc ~= $!grd.document-constructors( $element, $!xpath);
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
#  my Str $fname = "$*work-data<result-docs>$*work-data<raku-name>.rakudoc";
  $!mod.save-file( $fname, $doc, "class documentation");
}

#-------------------------------------------------------------------------------
method generate-test ( ) {

  $!tst .= new;

  my XML::Element $element = $!xpath.find('//class');
  $!mod.add-import($*work-data<raku-class-name>);

  my Hash $h0 = $!solve.search-name($*work-data<gnome-name>);
  my Str $test-variable = $!solve.set-object-name(
    $h0, :name-type(TestVariableType)
  );


  my Str $code = $!tst.prepare-test($*work-data<raku-class-name>);

#  my Hash $hcs = $!mod.get-constructors( $element, $!xpath, :user-side);
  my Hash $hcs =
    $!mod.get-native-subs( $element, $!xpath, :routine-type<constructor>);
  $code ~= $!tst.generate-init-tests( $test-variable, 'Class init tests', $hcs);

  $code ~= $!tst.generate-test-separator;
  $code ~= $!tst.generate-inheritance-tests( $element, $test-variable);

  $hcs = $!mod.get-native-subs( $element, $!xpath, :routine-type<method>);
  $code ~= $!tst.generate-method-tests( $hcs, $test-variable);

  $hcs = $!mod.get-native-subs(
    $element, $!xpath, :user-side, :routine-type<function>
  );
  $code ~= $!tst.generate-method-tests( $hcs, $test-variable, :!ismethod);

  $code ~= $!tst.generate-test-end;
  $code ~= $!tst.generate-signal-tests($test-variable);
  $code = $!mod.substitute-MODULE-IMPORTS($code);

  my Str $fname = $!solve.set-object-name( $h0, :name-type(FilenameTestType));
#  my Str $fname = "$*work-data<result-tests>$*work-data<raku-name>.rakutest";
  $!mod.save-file( $fname, $code, "class tests");
}
