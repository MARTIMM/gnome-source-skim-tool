
use Gnome::SourceSkimTool::ConstEnumType;
use Gnome::SourceSkimTool::Doc;
use Gnome::SourceSkimTool::Code;
use Gnome::SourceSkimTool::Test;

use XML;
use XML::XPath;
use JSON::Fast;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::Class:auth<github:MARTIMM>;

has Gnome::SourceSkimTool::Doc $!grd;
has Gnome::SourceSkimTool::Code $!mod;
has Gnome::SourceSkimTool::Test $!tst;

has XML::XPath $!xpath;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {

  $!mod .= new;

  # load data for this module
  my Str $file = "$*work-data<gir-module-path>C-$*gnome-class.gir";
  note "Load module data from $file" if $*verbose;
  $!xpath .= new(:$file);
}

#-------------------------------------------------------------------------------
method generate-code ( ) {

  my XML::Element $element = $!xpath.find('//class');
  die "//class not found in $*work-data<gir-class-file> for $*work-data<raku-class-name>" unless ?$element;

  my Str $code = qq:to/RAKUMOD/;
    # Command to generate: $*command-line
    use v6.d;
    RAKUMOD

  my $callables = $!mod.generate-callables( $element, $!xpath);
  note "Set class unit" if $*verbose;
  $code ~= $!mod.set-unit( $element, :callables(?$callables));

  if ?$callables {
    # Make a BUILD submethod
    note "Generate BUILD" if $*verbose;
    $code ~= $!mod.make-build-submethod( $element, $!xpath);
    $code ~= $callables;
  }

  $code = $!mod.substitute-MODULE-IMPORTS( $code, $*work-data<raku-class-name>);

  my Str $fname = "$*work-data<result-mods>$*gnome-class.rakumod";
  $!mod.save-file( $fname, $code, "class module");
}

#-------------------------------------------------------------------------------
method generate-doc ( ) {

  $!grd .= new;

  my XML::Element $element = $!xpath.find('//class');
  die "//class not found in $*work-data<gir-class-file> for $*work-data<raku-class-name>" unless ?$element;

  note "Document init" if $*verbose;
  my Str $doc = $!grd.start-document;

  note "Document module description" if $*verbose;
  $doc ~= $!grd.get-description( $element, $!xpath);

  note "Document BUILD submethod" if $*verbose;
  my Hash $hcs = $!mod.get-constructors( $element, $!xpath);
  $doc ~= $!grd.document-build( $element, $hcs);
  $doc ~= $!grd.document-constructors( $element, $!xpath);

  note "Document methods" if $*verbose;
  $doc ~= $!grd.document-methods( $element, $!xpath);

  #note "Document functions" if $*verbose;
  #$doc ~= $!grd.document-functions( $element, $!xpath);

  note "Document signals" if $*verbose;
  my Hash $sig-info = $!grd.document-signals( $element, $!xpath);
  $doc ~= $sig-info<doc>;

#NOTE For now, skip property documentation
#  note "Generate module properties doc" if $*verbose;  
#  $doc ~= $!grd.document-properties( $element, $!xpath);

#  note "Save pod doc";
  my Str $fname = $*work-data<result-docs> ~ $*gnome-class ~ '.rakudoc';
  $!mod.save-file( $fname, $doc, "class documentation");
}

#-------------------------------------------------------------------------------
method generate-test ( ) {

  $!tst .= new;

  my XML::Element $element = $!xpath.find('//class');
  my Str $test-variable = '$' ~ $*gnome-class.lc;
  $!mod.add-import($*work-data<raku-class-name>);

  my Str $code = $!tst.prepare-test($*work-data<raku-class-name>);

  my Hash $hcs = $!mod.get-constructors( $element, $!xpath, :user-side);
  $code ~= $!tst.generate-init-tests( $test-variable, 'Class init tests', $hcs);

  $code ~= $!tst.generate-test-separator;
  $code ~= $!tst.generate-inheritance-tests( $element, $test-variable);

  $hcs = $!mod.get-methods( $element, $!xpath, :user-side);
  $code ~= $!tst.generate-method-tests( $hcs, $test-variable);
  $code ~= $!tst.generate-test-end;
  $code ~= $!tst.generate-signal-tests($test-variable);
  $code = $!mod.substitute-MODULE-IMPORTS($code);

  my Str $fname = $*work-data<result-tests> ~ $*gnome-class ~ '.rakutest';
  $!mod.save-file( $fname, $code, "class tests");
}
