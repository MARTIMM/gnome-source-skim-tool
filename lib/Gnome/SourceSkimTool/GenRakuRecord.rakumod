
use Gnome::SourceSkimTool::Prepare;
use Gnome::SourceSkimTool::SkimGtkDoc;
use Gnome::SourceSkimTool::ConstEnumType;
use Gnome::SourceSkimTool::SearchAndSubstitute;

use XML;
use XML::XPath;
use JSON::Fast;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::GenRakuRecord:auth<github:MARTIMM>;

has Gnome::SourceSkimTool::SearchAndSubstitute $!sas;

has XML::XPath $!xpath;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {
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

  # load data for this module
  note "Load module data from $*work-data<gir-module-path>repo-record.gir";
  $!xpath .= new(:file($*work-data<gir-module-path> ~ 'repo-record.gir'));
}

#-------------------------------------------------------------------------------
method generate-raku-record ( ) {

}

#-------------------------------------------------------------------------------
method generate-raku-record-test ( ) {

}

