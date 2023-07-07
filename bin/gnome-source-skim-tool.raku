#!/usr/bin/env rakudo

use Gnome::SourceSkimTool::SkimGtkDoc;
use Gnome::SourceSkimTool::ConstEnumType;
use Gnome::SourceSkimTool::Prepare;

#-------------------------------------------------------------------------------
my SkimSource $*gnome-package;
my Str $*gnome-class;
my Hash $*work-data;
my Bool $*verbose;

my Hash $*object-maps;
my Hash $*other-work-data;

my Bool $*generate-code;
my Bool $*generate-doc;
my Bool $*generate-test;

my Array $*external-modules;
my @*map-search-list;

#-------------------------------------------------------------------------------
sub MAIN (
  Str:D $gnome-package, Str $gnome-class?,
  Bool :$v = False,
  Bool :$gir = False,
  Bool :$c = False, Bool :$r = False, Bool :$i = False, Bool :$u = False,
  Bool :$f = False,
  Bool :$m = False, Bool :$t = False, Bool :$d = False,
  Bool :$help = False,
  Bool :$list = False, Str :$type = '', Str :$filter
) {

  if $help {
    USAGE;
    exit(0);
  }

  try {
    $*gnome-package = SkimSource(SkimSource.enums{$gnome-package});
    CATCH {
      default {
        USAGE;
        exit(1);
      }
    }
  }

  $*verbose = $v;

  $*generate-code = $m;
  $*generate-doc = $d;
  $*generate-test = $t;

#note "$?LINE $f, $*generate-code, $*generate-doc, $*generate-test, $gnome-class";

  $*external-modules = [<
    NativeCall Gnome::N::NativeLib Gnome::N::N-GObject Gnome::N::GlibToRakuTypes
  >];

  if $gir {
    say "Generate the intermediate gir and yaml files" if $*verbose;
#    $*gnome-class = $gnome-class // 'Widget';
    my Gnome::SourceSkimTool::Prepare $prepare .= new(:!load-maps);
    my Gnome::SourceSkimTool::SkimGtkDoc $skim-doc .= new;
    $skim-doc.load-gir-file;
    $skim-doc.get-classes-from-gir;
  }

  elsif $list {
    $*verbose = False;
#    $*gnome-class = $gnome-class // 'Widget';
    my Gnome::SourceSkimTool::Prepare $prepare .= new;
    require ::('Gnome::SourceSkimTool::ListGirTypes');
    my $lt = ::('Gnome::SourceSkimTool::ListGirTypes').new;
#TODO add filter from -filter
    if ?$type {
      $lt.list-type-objects($type);
    }

    else {
      $lt.list-types
    }
  }

  # Get data using filename
  elsif $f and ?$gnome-class {
    $*verbose = False;
    my Str $filename = $gnome-class.lc;
    my Gnome::SourceSkimTool::Prepare $prepare .= new;
    require ::('Gnome::SourceSkimTool::File');
    my $raku-module = ::('Gnome::SourceSkimTool::File').new(:$filename);
    $*verbose = True;
    $raku-module.generate-code if $*generate-code;
    $raku-module.generate-test if $*generate-test;
    $raku-module.generate-doc if $*generate-doc;
  }

  # Get data using class name
  elsif $c and ?$gnome-class {
    $*gnome-class = $gnome-class;
    my Gnome::SourceSkimTool::Prepare $prepare .= new;

    say "Generate Raku module from class data in $*work-data<raku-class-name>"
         if $*verbose;
    require ::('Gnome::SourceSkimTool::Class');
    my $raku-module = ::('Gnome::SourceSkimTool::Class').new;
    $raku-module.generate-code if $*generate-code;
    $raku-module.generate-test if $*generate-test;
    $raku-module.generate-doc if $*generate-doc;
  }

  # Get data using interface name
  elsif $i and ?$gnome-class {
    $*gnome-class = $gnome-class;
    my Gnome::SourceSkimTool::Prepare $prepare .= new;

    say "Generate Raku module from interface data in $*work-data<raku-class-name>"
         if $*verbose;
    require ::('Gnome::SourceSkimTool::Interface');
    my $raku-interface = ::('Gnome::SourceSkimTool::Interface').new;
    $raku-interface.generate-code if $*generate-code;
    #$raku-module.generate-doc if $*generate-doc;
    #$raku-module.generate-test if $*generate-test;
  }

  # Get data using record name
  elsif $r and ?$gnome-class {
    $*gnome-class = $gnome-class;
    my Gnome::SourceSkimTool::Prepare $prepare .= new;

    say "Generate Raku module from record data in $*work-data<raku-class-name>"
         if $*verbose;
    require ::('Gnome::SourceSkimTool::Record');
    my $raku-record = ::('Gnome::SourceSkimTool::Record').new;
    $raku-record.generate-code if $*generate-code;
    $raku-record.generate-test if $*generate-test;
    #$raku-module.generate-doc if $*generate-doc;
  }

  # Get data using union name
  elsif $u and ?$gnome-class {
    $*gnome-class = $gnome-class;
    my Gnome::SourceSkimTool::Prepare $prepare .= new;

    say "Generate Raku module from union data in $*work-data<raku-class-name>"
         if $*verbose;
    require ::('Gnome::SourceSkimTool::Union');
    my $raku-record = ::('Gnome::SourceSkimTool::Union').new;
    $raku-record.generate-code if $*generate-code;
    $raku-record.generate-test if $*generate-test;
    #$raku-module.generate-doc if $*generate-doc;
  }
}

#-------------------------------------------------------------------------------
sub USAGE ( ) {

  # Need to call Prepare init to get a few values in the output
#  $*verbose = False;
#  my Prepare $gfl .= new;

  say qq:to/EOHELP/;

  Program to generate Raku modules from the Gnome source code using
  the GtkDoc tool also used by Gnome to generate there documentation.

  Usage
    {$*PROGRAM.basename} -h

    {$*PROGRAM.basename} -c  [-m][-t][-d][-v] package class
    {$*PROGRAM.basename} -i  [-m][-t][-d][-v] package interface
    {$*PROGRAM.basename} -r  [-m][-t][-d][-v] package record
    {$*PROGRAM.basename} -f  [-m][-t][-d][-v] package filename

    {$*PROGRAM.basename} -gir [-v] package

    {$*PROGRAM.basename} -l [-type=Str] [-filter=Str] package

    Options:
      c       Select a class module.
      d       Generate a Raku pod documentation file for a class (-c),
              interface (-i) or record (-r). Result is put in directory
              '{RAKUMODS}', e.g. 'AboutDialog.rakudoc' or 'Window.rakudoc'
              defined in Gtk3 or Gtk4.
      f       Use a filename instead of one of -c, -i or -r. This is needed in
              cases that there are enumerations or bitmaps gathered into one
              file whithout having a class, record or interface.
      filter  Filter string used with -list and -type to narrow down list.
      help    Show this info. (or any other non existant option ;-)
      i       Select an interface (role) module.
      list    Show types used in the packages of Gnome.
      m       Generate a Raku code file for a class (-c), interface (-i) or
              record (-r). Result is put in directory '{RAKUMODS}', e.g.
              'File.rakumod' or 'Application.rakumod' defined in Gio.
      r       Select a record (structures) module from argument. The
              argument is a name. Result is put in directory
              '{RAKUMODS}', e.g. Error or List defined in Glib.
      t       Generate a test file for a class (-c), interface (-i) or
              record (-r). E.g. 'List.rakutest' or 'Variant.rakutest' 
              defined in Glib.
      type=Str
              Use the type output from the plain -l option. With this option, a
              list of names is output defined as that type.
      gir     Generate the intermediate gir and yaml files. The files will be
              kept, so they need to be generated only once or when sources are
              updated.
      v       Show some info while stumping. Default False.

    Arguments
      package   The Gnome package name used for the class. Select one
                from this list; Atk Cairo DBus DBusGLib Gdk3 Gdk4
                GdkPixbuf GdkPixdata Gio Glib GObject Gtk3 Gtk4 Gsk4
                Pango PangoCairo GIRepo.
      class     A class name like Button or Application defined in a package
                like Gtk3, Gtk4 or Gio.
      record    A record name like Error or List in Glib
      filename  A filename wherein everything is defined originally.
  EOHELP
}
