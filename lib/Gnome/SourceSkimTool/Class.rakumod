
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
    use v6;
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

  $code = $!mod.substitute-MODULE-IMPORTS($code);

  my Str $fname = "$*work-data<result-path>$*gnome-class.rakumod";
  note "Save class module in ", $fname.IO.basename;
  $fname.IO.spurt($code);
}

#-------------------------------------------------------------------------------
method generate-doc ( ) {
#`{{
  $!grd .= new;

  my XML::Element $element = $!xpath.find('//class');
  die "//class not found in $*work-data<gir-class-file> for $*work-data<raku-class-name>" unless ?$element;

  my Str $doc = qq:to/RAKUMOD/;
    #TL:1:pod doc of $*work-data<raku-class-name>:
    use v6;

    {$!grd.pod-header('Class Description')}
    RAKUMOD

  note "Document module" if $*verbose;
  $doc ~= $!grd.get-description( $element, $!xpath);

  note "Document enumerations and bitmasks";
  #$doc ~= $!mod.generate-enumerations-doc;

  note "Document BUILD submethod" if $*verbose;
  my Hash $hcs = $!mod.get-constructors( $element, $!xpath);
  $doc ~= $!grd.make-build-doc( $element, $hcs);

  note "Document methods" if $*verbose;
  $doc ~= $!grd.document-methods( $element, $!xpath);

  note "Document signals" if $*verbose;
  my Hash $sig-info = $!grd.document-signals( $element, $!xpath);
  $doc ~= $sig-info<doc>;

  note "Generate module properties doc" if $*verbose;  
  $doc ~= $!grd.document-properties( $element, $!xpath);

  note "Save pod doc";
  $*work-data<raku-module-doc-file>.IO.spurt($doc);
}}
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

  my Str $fname = $*work-data<result-path>;
  $fname ~~ s@ '/lib/' @/t/@;
  mkdir $fname, 0o750 unless $fname.IO ~~ :e;
  $fname ~= $*gnome-class ~ '.rakutest';
  note "Save tests in ", $fname.IO.basename;
  $fname.IO.spurt($code);
}
