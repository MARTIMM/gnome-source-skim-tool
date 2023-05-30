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
  Bool :$v = False, Bool :$y = False, Bool :$c = False, Bool :$ct = False,
  Bool :$r = False, Bool :$rt = False, Bool :$i = False,
  Bool :$h = False, Bool :$l = False, Str :$t = ''
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

  elsif ($c or $ct) and ?$gnome-class {
    $*gnome-class = $gnome-class;
    my Gnome::SourceSkimTool::Prepare $prepare .= new;

    say "Generate Raku module from class data in $*work-data<raku-class-name>"
         if $*verbose;
    require ::('Gnome::SourceSkimTool::ClassModule');
    my $raku-module = ::('Gnome::SourceSkimTool::ClassModule').new;
    $raku-module.generate-raku-module;
    $raku-module.generate-raku-module-test if $ct;
  }

  elsif $i and ?$gnome-class {
    $*gnome-class = $gnome-class;
    my Gnome::SourceSkimTool::Prepare $prepare .= new;

    say "Generate Raku module from interface data in $*work-data<raku-class-name>"
         if $*verbose;
    require ::('Gnome::SourceSkimTool::InterfaceModule');
    my $raku-interface = ::('Gnome::SourceSkimTool::InterfaceModule').new;
    $raku-interface.generate-raku-interface;

    # no test file for interfaces
  }

  elsif ($r or $rt) and ?$gnome-class {
    $*gnome-class = $gnome-class;
    my Gnome::SourceSkimTool::Prepare $prepare .= new;

    say "Generate Raku module from record data in $*work-data<raku-class-name>"
         if $*verbose;
    require ::('Gnome::SourceSkimTool::RecordModule');
    my $raku-record = ::('Gnome::SourceSkimTool::RecordModule').new;
    $raku-record.generate-raku-record;
    $raku-record.generate-raku-record-test if $rt;
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

    {$*PROGRAM.basename} -c  [-v] gnome-package gnome-class
    {$*PROGRAM.basename} -ct [-v] gnome-package gnome-class
    {$*PROGRAM.basename} -i  [-v] gnome-package gnome-interface
    {$*PROGRAM.basename} -r  [-v] gnome-package gnome-record
    {$*PROGRAM.basename} -rt [-v] gnome-package gnome-record

    {$*PROGRAM.basename} -y [-v] gnome-package

    {$*PROGRAM.basename} -l [-t=type] [-f=filter] gnome-package

    Options:
      c       Generate a class module. Result is put in directory
              '{RAKUMODS}'. E.g. AboutDialog or Window defined in Gtk3 or Gtk4.
      ct      Also generate test file for the class.
      f       Filter string used with -l and -t to narrow down list.
      h       Show this info.
      i       Generate an interface (role) module. Result is put in directory
              '{RAKUMODS}'. For role modules no test file is generated. Test
              should be done for classes inheriting the role.
      l       Show types used in the gnome-package.
      r       Generate a record (structures) module from argument. The
              argument is a name. E.g. Error or List defined in Glib.
      rt      Also generate test file for the module.
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
