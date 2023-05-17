
use Gnome::SourceSkimTool::Prepare;
use Gnome::SourceSkimTool::SkimGtkDoc;
use Gnome::SourceSkimTool::ConstEnumType;
use Gnome::SourceSkimTool::SearchAndSubstitute;
use Gnome::SourceSkimTool::GenerateDoc;

use XML;
use XML::XPath;
use JSON::Fast;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::RecordModule:auth<github:MARTIMM>;

has Gnome::SourceSkimTool::SearchAndSubstitute $!sas;

has XML::XPath $!xpath;
has Gnome::SourceSkimTool::GenerateDoc $!grd;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {
#`{{
  $*object-maps = %();
  $*other-work-data = %();

  $!sas .= new; #(:gen-raku-module(self));

  note "Prepare for module generation from record data" if $*verbose;

  # get workdata for other gnome packages
  my Gnome::SourceSkimTool::Prepare $p .= new;

  if $*gnome-package.Str ~~ / '3' $/ {
    $*other-work-data<Gtk> = $p.prepare-work-data(Gtk3);
    $*other-work-data<Gdk> = $p.prepare-work-data(Gdk3);
  }

  # Version 4
  elsif $*gnome-package.Str ~~ / '4' $/ {
    $*other-work-data<Gtk> = $p.prepare-work-data(Gtk4);
    $*other-work-data<Gdk> = $p.prepare-work-data(Gdk4);
    $*other-work-data<Gsk> = $p.prepare-work-data(Gsk4);
  }

  # If it is a high end module, we add these too. They depend on Gtk.
  if $*gnome-package.Str ~~ / '3' || '4' $/ {
    $*other-work-data<Atk> = $p.prepare-work-data(Atk);
    $*other-work-data<Pango> = $p.prepare-work-data(Pango);
    $*other-work-data<Cairo> = $p.prepare-work-data(Cairo);
  }

  # If it is not a high end module, we only need these
  $*other-work-data<Glib> = $p.prepare-work-data(Glib);
  $*other-work-data<Gio> = $p.prepare-work-data(Gio);
  $*other-work-data<GObject> = $p.prepare-work-data(GObject);

  # get object maps
  my Gnome::SourceSkimTool::SkimGtkDoc $s .= new;
  if $*gnome-package.Str ~~ / '3' || '4' $/ {
    $*object-maps<Atk> = $s.load-map($*other-work-data<Atk><gir-module-path>);
    $*object-maps<Gtk> = $s.load-map($*other-work-data<Gtk><gir-module-path>);
    $*object-maps<Gdk> = $s.load-map($*other-work-data<Gdk><gir-module-path>);
    $*object-maps<Gsk> = ?$*other-work-data<Gsk> 
                       ?? $s.load-map($*other-work-data<Gsk><gir-module-path>)
                       !! %();
    $*object-maps<Pango> =
      $s.load-map($*other-work-data<Pango><gir-module-path>);
    $*object-maps<Cairo> =
      $s.load-map($*other-work-data<Cairo><gir-module-path>);
  }

  $*object-maps<Glib> = $s.load-map($*other-work-data<Glib><gir-module-path>);
  $*object-maps<Gio> = $s.load-map($*other-work-data<Gio><gir-module-path>);
  $*object-maps<GObject> =
    $s.load-map($*other-work-data<GObject><gir-module-path>);
}}

  # load data for this module
  note "Load module data from $*work-data<gir-module-path>repo-record.gir";
  $!xpath .= new(:file($*work-data<gir-module-path> ~ $*gnome-class.Str.lc ~ '.gir'));
}

#-------------------------------------------------------------------------------
method generate-raku-record ( ) {

  my XML::Element $element = $!xpath.find('//record');

#  my Str $description-comment = 'Record Description';

  my Str ( $doc, $code);
  my Str $module-code = '';
  my Str $module-doc = qq:to/RAKUMOD/;
    #TL:1:$*work-data<raku-class-name>:
    use v6;

    {$!grd.pod-header('Record Description')}
    RAKUMOD

  note "Generate module description" if $*verbose;  
  $module-doc ~= $!grd.get-description( $element, $!xpath);

  note "Set class unit" if $*verbose;
#  $module-code ~= self!set-unit( $element, $sig-info);

  note "Generate BUILD submethod" if $*verbose;  
#  ( $doc, $code) = self!generate-build( $element, $sig-info);
#  $module-doc ~= $doc;
#  $module-code ~= $code;






  note "Save module";
  $*work-data<raku-module-file>.IO.spurt($module-code);
  note "Save pod doc";
  $*work-data<raku-module-doc-file>.IO.spurt($module-doc);
}

#-------------------------------------------------------------------------------
method generate-raku-record-test ( ) {

}

