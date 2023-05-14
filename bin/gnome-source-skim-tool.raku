#!/usr/bin/env rakudo

use Gnome::SourceSkimTool::ConstEnumType;
use Gnome::SourceSkimTool::Prepare;
use Gnome::SourceSkimTool::SkimGtkDoc;
#use Gnome::SourceSkimTool::GenRakuModule;

#-------------------------------------------------------------------------------
my SkimSource $*gnome-package;
my Str $*gnome-class;
my Hash $*work-data;
my Bool $*verbose;

#-------------------------------------------------------------------------------
sub MAIN (
  Str:D $gnome-package, Str $gnome-class?,
  Bool :$v = False, Bool :$y = False, Bool :$c = False, Bool :$r = False,
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
    $skim-doc.get-classes-from-gir;
  }

  elsif $c and ?$gnome-class {
    $*gnome-class = $gnome-class;
    my Gnome::SourceSkimTool::Prepare $prepare .= new;

    say "Generate Raku module from class $*work-data<raku-class-name>"
         if $*verbose;
    require ::('Gnome::SourceSkimTool::GenRakuModule');
    my $raku-module = ::('Gnome::SourceSkimTool::GenRakuModule').new;
    $raku-module.generate-raku-module;
    $raku-module.generate-raku-module-test;
  }

  elsif $r and ?$gnome-class {
    $*gnome-class = $gnome-class;
    my Gnome::SourceSkimTool::Prepare $prepare .= new;

    say "Generate Raku module from record $*work-data<raku-class-name>"
         if $*verbose;
    require ::('Gnome::SourceSkimTool::GenRakuRecord');
    my $raku-record = ::('Gnome::SourceSkimTool::GenRakuRecord').new;
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
    {$*PROGRAM.basename} -r [-v] gnome-package gnome-record
    {$*PROGRAM.basename} -y [-v] gnome-package

    {$*PROGRAM.basename} -l [-t=type] gnome-package

    Options:
      c       Generate Raku module from argument. Result is put in directory
              '{RAKUMODS}' together with a test file.
              E.g. AboutDialog or Window defined in Gtk3.
      h       Show this info.
      l       Show types used in the gnome-package.
      r       Generate Raku module from argument. The argument is a name
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
