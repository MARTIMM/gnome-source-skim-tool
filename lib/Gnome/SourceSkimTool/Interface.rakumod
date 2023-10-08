
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

  $!mod .= new;

  # load data for this module
  my Str $file = "$*work-data<gir-module-path>I-$*gnome-class.gir";
  note "Load module data from $file" if $*verbose;
  $!xpath .= new(:$file);
}

#-------------------------------------------------------------------------------
method generate-code ( ) {

  my XML::Element $element = $!xpath.find('//interface');
  die "//interface not found in gir-interface-file for $*work-data<raku-class-name>" unless ?$element;

  my Str $code = qq:to/RAKUMOD/;
    # Command to generate: $*command-line
    use v6.d;
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

  $code = $!mod.substitute-MODULE-IMPORTS( $code, $*work-data<raku-class-name>);

  my Str $fname = "$*work-data<result-mods>R-$*gnome-class.rakumod";
  $!mod.save-file( $fname, $code, "interface module");
}

#-------------------------------------------------------------------------------
method generate-doc ( ) {

#  $!grd .= new;
}

#-------------------------------------------------------------------------------
method generate-test ( ) {
  my Str $fname = "$*work-data<result-tests>R-$*gnome-class.rakutest";

  $!tst .= new;

  my XML::Element $element = $!xpath.find('//interface');
  my Str $test-variable = '$' ~ $*gnome-class.lc;
  $!mod.add-import($*work-data<raku-class-name>);

  my Str $ctype = $element.attribs<c:type>;
  my Hash $h = $!mod.search-name($ctype);
  my Str $code = $!tst.prepare-test($h<class-name>);

#TODO generate a variable in a class using this interface

  $code ~= $!tst.generate-test-separator;

  my Hash $hcs = $!mod.get-methods( $element, $!xpath, :user-side);
  $code ~= $!tst.generate-method-tests( $hcs, $test-variable);
  $code ~= $!tst.generate-test-end;
  $code ~= $!tst.generate-signal-tests($test-variable);
  $code = $!mod.substitute-MODULE-IMPORTS($code);

  $!mod.save-file( $fname, $code, "interface tests");
}
