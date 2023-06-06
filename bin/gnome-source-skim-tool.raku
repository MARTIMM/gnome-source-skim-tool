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

#-------------------------------------------------------------------------------
sub MAIN (
  Str:D $gnome-package, Str $gnome-class?,
  Bool :$v = False,
  Bool :$gir = False,
  Bool :$c = False, Bool :$r = False, Bool :$i = False,
  Bool :$m = True, Bool :$t = False, Bool :$d = False,
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
  $*external-modules = [<
    NativeCall Gnome::N::NativeLib Gnome::N::N-GObject Gnome::N::GlibToRakuTypes
  >];

  if $gir {
    say "Generate the intermediate gir and yaml files" if $*verbose;
    $*gnome-class = $gnome-class // 'Widget';
    my Gnome::SourceSkimTool::Prepare $prepare .= new(:!load-maps);
    my Gnome::SourceSkimTool::SkimGtkDoc $skim-doc .= new;
    $skim-doc.load-gir-file;
    $skim-doc.get-classes-from-gir;
  }

  elsif $list {
    $*verbose = False;
    $*gnome-class = $gnome-class // 'Widget';
    my Gnome::SourceSkimTool::Prepare $prepare .= new;
    require ::('Gnome::SourceSkimTool::ListGirTypes');
    my $lt = ::('Gnome::SourceSkimTool::ListGirTypes').new;
#TODO add filter from -f
    if ?$type {
      $lt.list-type-objects($type);
    }

    else {
      $lt.list-types
    }
  }

  elsif $c and ?$gnome-class {
    $*gnome-class = $gnome-class;
    my Gnome::SourceSkimTool::Prepare $prepare .= new;

    say "Generate Raku module from class data in $*work-data<raku-class-name>"
         if $*verbose;
    require ::('Gnome::SourceSkimTool::ClassModule');
    my $raku-module = ::('Gnome::SourceSkimTool::ClassModule').new;
    $raku-module.generate-raku-module if $*generate-code;
    $raku-module.generate-raku-module-test if $*generate-test;
    #$raku-module.generate-raku-module-doc if $*generate-doc;
  }

  elsif $i and ?$gnome-class {
    $*gnome-class = $gnome-class;
    my Gnome::SourceSkimTool::Prepare $prepare .= new;

    say "Generate Raku module from interface data in $*work-data<raku-class-name>"
         if $*verbose;
    require ::('Gnome::SourceSkimTool::InterfaceModule');
    my $raku-interface = ::('Gnome::SourceSkimTool::InterfaceModule').new;
    $raku-interface.generate-raku-interface if $*generate-code;
    #$raku-module.generate-raku-interface-test if $*generate-test;
    #$raku-module.generate-raku-interface-doc if $*generate-doc;
  }

  elsif $r and ?$gnome-class {
    $*gnome-class = $gnome-class;
    my Gnome::SourceSkimTool::Prepare $prepare .= new;

    say "Generate Raku module from record data in $*work-data<raku-class-name>"
         if $*verbose;
    require ::('Gnome::SourceSkimTool::RecordModule');
    my $raku-record = ::('Gnome::SourceSkimTool::RecordModule').new;
    $raku-record.generate-raku-record if $*generate-code;
    $raku-record.generate-raku-record-test if $*generate-test;
    #$raku-module.generate-raku-record-doc if $*generate-doc;
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

    {$*PROGRAM.basename} -c  [-m][-t][-d][-v] gnome-package gnome-class
    {$*PROGRAM.basename} -i  [-m][-t][-d][-v] gnome-package gnome-interface
    {$*PROGRAM.basename} -r  [-m][-t][-d][-v] gnome-package gnome-record

    {$*PROGRAM.basename} -gir [-v] gnome-package

    {$*PROGRAM.basename} -l [-t=type] [-f=filter] gnome-package

    Options:
      c       Select a class module.
      d       Generate a Raku pod documentation file for a class (-c),
              interface (-i) or record (-r). Result is put in directory
              '{RAKUMODS}'. E.g. 'AboutDialog.rakudoc' or 'Window.rakudoc'
              defined in Gtk3 or Gtk4.
      f       Filter string used with -list and -type to narrow down list.
      help    Show this info. (or any other non existant option ;-)
      i       Select an interface (role) module.
      list    Show types used in the gnome-package.
      m       Generate a Raku code file for a class (-c), interface (-i) or
              record (-r). By default enabled. To disable use '-/m'. E.g.
              'File.rakumod' or 'Application.rakumod' defined in Gio.
      r       Select a record (structures) module from argument. The
              argument is a name. E.g. Error or List defined in Glib.
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
      gnome-package   The package name used for the gnome class. Select one
                      from this list; Atk Cairo DBus DBusGLib Gdk3 Gdk4
                      GdkPixbuf GdkPixdata Gio Glib GObject Gtk3 Gtk4 Gsk4
                      Pango PangoCairo GIRepo.
      gnome-class     A class name like Button or Application defined in Gtk3
                      or Gtk4.
      gnome-record    A record name like Error or List in Glib
  EOHELP
}
