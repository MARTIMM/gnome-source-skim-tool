
use Gnome::SourceSkimTool::ConstEnumType;
use Gnome::SourceSkimTool::Doc;
use Gnome::SourceSkimTool::Code;
use Gnome::SourceSkimTool::Test;

use XML;
use XML::XPath;
use JSON::Fast;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::Interface:auth<github:MARTIMM>;

has Gnome::SourceSkimTool::Doc $!grd;
has Gnome::SourceSkimTool::Code $!mod;
has Gnome::SourceSkimTool::Test $!tst;

has XML::XPath $!xpath;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {

  $!grd .= new;

  # load data for this module
  note "Load module data from $*work-data<gir-interface-file>" if $*verbose;
  $!xpath .= new(:file($*work-data<gir-interface-file>));

  $!mod .= new; #(:$!xpath);
}

#-------------------------------------------------------------------------------
method generate-code ( ) {

  my XML::Element $element = $!xpath.find('//interface');
  die "//interface not found in $*work-data<gir-interface-file> for $*work-data<raku-class-name>" unless ?$element;

  my Str $code = qq:to/RAKUMOD/;
    # Command to generate: $*command-line
    use v6;
    RAKUMOD

  my $callables = $!mod.generate-callables( $element, $!xpath, :is-interface);

  note "Set role unit" if $*verbose;
  $code ~= $!mod.set-unit( $element, :callables(?$callables));

  if ?$callables {
    # Roles do not have a BUILD
    note "Generate role initialization method" if $*verbose;  
    $code ~= $!mod.generate-role-init( $element, $!xpath);
    $code ~= $callables;
  }

  $code = $!mod.substitute-MODULE-IMPORTS($code);

  my Str $fname = "$*work-data<result-path>R-$*gnome-class.rakumod";
  note "Save interface module in ", $fname.IO.basename;
  $fname.IO.spurt($code);
}

#-------------------------------------------------------------------------------
method generate-doc ( ) {

}

#-------------------------------------------------------------------------------
method generate-test ( ) {

  $!tst .= new;

  my XML::Element $element = $!xpath.find('//interface');
  my Str $test-variable = '$' ~ $*gnome-class.lc;
  $!mod.add-import($*work-data<raku-class-name>);

  my Str $ctype = $element.attribs<c:type>;
  my Hash $h = self.search-name($ctype);
  my Str $code = $!tst.set-unit($h<class-name>);

#  my Hash $hcs = $!mod.get-constructors( $element, $!xpath, :user-side);
#  $code ~= $!tst.generate-init-tests( $test-variable, 'Class init tests', $hcs);

  $code ~= $!tst.generate-test-separator;
  $code ~= $!tst.generate-inheritance-tests( $element, $test-variable);

  my Hash $hcs = $!mod.get-methods( $element, $!xpath, :user-side);
  $code ~= $!tst.generate-method-tests( $hcs, $test-variable);
  $code ~= $!tst.generate-test-end;
  $code ~= $!tst.generate-signal-tests($test-variable);
  $code = $!mod.substitute-MODULE-IMPORTS($code);

  my Str $fname = $*work-data<result-path>;
  $fname ~~ s@ '/lib/' @/t/@;
  mkdir $fname, 0o750 unless $fname.IO ~~ :e;
  $fname ~= 'R-' ~ $*gnome-class ~ '.rakutest';
  note "Save tests in ", $fname.IO.basename;
  $fname.IO.spurt($code);
}
