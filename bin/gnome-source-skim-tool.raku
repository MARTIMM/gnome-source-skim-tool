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

#-------------------------------------------------------------------------------
sub MAIN (
  Str:D $gnome-package, Str $gnome-class?,
  Bool :$v = False, Bool :$y = False, Bool :$c = False, Bool :$r = False,
  Bool :$h = False, Bool :$i = False, Bool :$l = False, Str :$t = ''
) {

  $*verbose = $v;

  if $h {
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

  if $y {
    say "Generate the intermediate gir and yaml files" if $*verbose;
    $*gnome-class = $gnome-class // 'Widget';
    my Gnome::SourceSkimTool::Prepare $prepare .= new;
    my Gnome::SourceSkimTool::SkimGtkDoc $skim-doc .= new;
    $skim-doc.load-gir-file;
    $skim-doc.get-classes-from-gir;
  }

  elsif $l {
    $*verbose = False;
    $*gnome-class = $gnome-class // 'Widget';
    my Gnome::SourceSkimTool::Prepare $prepare .= new;
    require ::('Gnome::SourceSkimTool::ListGirTypes');
    my $lt = ::('Gnome::SourceSkimTool::ListGirTypes').new;
    if ?$t {
      $lt.list-type-objects($t);
    }

    else {
      $lt.list-types
    }
  }

  elsif $c and ?$gnome-class {
    $*gnome-class = $gnome-class;
    my Gnome::SourceSkimTool::Prepare $prepare .= new;

    say "Generate Raku module from class $*work-data<raku-class-name>"
         if $*verbose;
    require ::('Gnome::SourceSkimTool::ClassModule');
    my $raku-module = ::('Gnome::SourceSkimTool::ClassModule').new;
    $raku-module.generate-raku-module;
    $raku-module.generate-raku-module-test;
  }

  elsif $i and ?$gnome-class {
    $*gnome-class = $gnome-class;
    my Gnome::SourceSkimTool::Prepare $prepare .= new;

    say "Generate Raku module from record $*work-data<raku-class-name>"
         if $*verbose;
    require ::('Gnome::SourceSkimTool::InterfacedModule');
    my $raku-interface = ::('Gnome::SourceSkimTool::InterfaceModule').new;
    $raku-interface.generate-raku-interface;
    $raku-interface.generate-raku-interface-test;
  }

  elsif $r and ?$gnome-class {
    $*gnome-class = $gnome-class;
    my Gnome::SourceSkimTool::Prepare $prepare .= new;

    say "Generate Raku module from record $*work-data<raku-class-name>"
         if $*verbose;
    require ::('Gnome::SourceSkimTool::RecordModule');
    my $raku-record = ::('Gnome::SourceSkimTool::RecordModule').new;
    $raku-record.generate-raku-record;
    $raku-record.generate-raku-record-test;
  }
}

#-------------------------------------------------------------------------------
sub USAGE ( ) {

  # Need to call Prepare init to get a few values in the output
  $*verbose = False;
#  my Prepare $gfl .= new;

  say qq:to/EOHELP/;

  Program to generate Raku modules from the Gnome source code using
  the GtkDoc tool also used by Gnome to generate there documentation.

  Usage
    {$*PROGRAM.basename} -h

    {$*PROGRAM.basename} -c [-v] gnome-package gnome-class
    {$*PROGRAM.basename} -i [-v] gnome-package gnome-interface
    {$*PROGRAM.basename} -r [-v] gnome-package gnome-record
    {$*PROGRAM.basename} -y [-v] gnome-package

    {$*PROGRAM.basename} -l [-t=type] [-f=filter] gnome-package

    Options:
      c       Generate a class module. Result is put in directory
              '{RAKUMODS}' together with a test file.
              E.g. AboutDialog or Window defined in Gtk3.
      f       Filter string used with -l and -t to narrow down list.
      h       Show this info.
      i       Generate an interface (role) module. Result is put in directory
              '{RAKUMODS}' together with a test file.
      l       Show types used in the gnome-package.
      r       Generate a record (structures) module from argument. The
              argument is a name.
              of a so called record or stucture. E.g. Error or List in Glib.
      t       Use the type output from the plain -l option. With this option, a
              list of names is output defined as that type.
      y       Generate the intermediate gir and yaml files. The files will be
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
