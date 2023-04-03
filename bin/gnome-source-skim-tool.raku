#!/usr/bin/env rakudo

use Gnome::SourceSkimTool::ConstEnumType;
use Gnome::SourceSkimTool::Prepare;
use Gnome::SourceSkimTool::SkimGtkDoc;
use Gnome::SourceSkimTool::GenRakuModule;

#-------------------------------------------------------------------------------
my SkimSource $*gnome-package;
my Str $*gnome-class;
my Hash $*work-data;
my Bool $*verbose;

#-------------------------------------------------------------------------------
sub MAIN (
  Str:D $gnome-package, Str $gnome-class?,
  Bool :$v = False, Bool :$y = False, Bool :$r = False, Bool :$h = False,
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
    note "Generate the intermediate gir and yaml files" if $*verbose;
    my Gnome::SourceSkimTool::Prepare $prepare .= new;
    my Gnome::SourceSkimTool::SkimGtkDoc $skim-doc .= new;
    $skim-doc.get-classes-from-gir;
  }

  if $r and ?$gnome-class {
    $*gnome-class = $gnome-class;
    my Gnome::SourceSkimTool::Prepare $prepare .= new;
    note "Generate Raku module $*work-data<raku-class-name>" if $*verbose;
    my Gnome::SourceSkimTool::GenRakuModule $raku-module .= new;
    $raku-module.generate-raku-module;
    $raku-module.generate-raku-module-test;
  }
}

#-------------------------------------------------------------------------------
sub USAGE ( ) {

  # Need to call Prepare init to get a few values in the output
  $*verbose = False;
#  my Prepare $gfl .= new;

  note qq:to/EOHELP/;

  Program to generate Raku modules from the Gnome source code using
  the GtkDoc tool also used by Gnome to generate there documentation.

  Usage
    {$*PROGRAM.basename} -h
    {$*PROGRAM.basename} -y [-v] gnome-package
    {$*PROGRAM.basename} -r [-v] gnome-package gnome-class

    Options:
      h       Show this info.
      r       Generate Raku module from argument. Result is put in directory
              '{RAKUMODS}' together with a test file.
      y       Generate the intermediate gir and yaml files. The files will be
              kept, so they need to be generated only once or when sources are
              updated.
      v       Show some info while stumping. Default False.

    Arguments
      gnome-package   The package name used for the gnome class. Select one
                      from this list; Atk Cairo DBus DBusGLib Gdk3 Gdk4
                      GdkPixbuf GdkPixdata Gio Glib GObject Gtk3 Gtk4 Gsk4
                      Pango PangoCairo GIRepo.
      gnome-class     A gnome class name like GtkButton or GApplication. This is
                      optional when only the GtkDoc results are to be generated.

EOHELP
}












=finish



use Gnome::SourceSkimTool::Prepare;
use Gnome::SourceSkimTool::ConstEnumType;
use Gnome::SourceSkimTool::SkimGtkDoc;
use Gnome::SourceSkimTool::GenRakuModule;

#-------------------------------------------------------------------------------
constant \Prepare = Gnome::SourceSkimTool::Prepare;
constant \SkimGtkDoc = Gnome::SourceSkimTool::SkimGtkDoc;
constant \GenRakuModule = Gnome::SourceSkimTool::GenRakuModule;

# $sub-prefix is the name of gnome class. Sometimes another class is defined
# within the same file. To generate that part, add the $other-prefix.

my SkimSource $*gnome-package;
my Str $*gnome-class;
my Hash $*work-data;

my Bool $*verbose;
my Prepare $prepare;
my GenRakuModule $raku-module;

#my Str $source
my @source-dir-list = ();

#-------------------------------------------------------------------------------
sub MAIN (
  Str:D $gnome-package, Str $gnome-class?,
  Bool :$g = False, Bool :$v = False, Bool :$y = False,
  Bool :$d = False, Bool :$h = False, Bool :$r = False,
) {

  $*verbose = $v;

  if $h {
    USAGE;
    exit(0);
  }

  $*gnome-package = SkimSource(SkimSource.enums{$gnome-package});
  unless $*gnome-package.defined {
    USAGE;
    exit(1);
  }

  # Generate the document results using gtkdoc
  if $d {
    note "\nOption -d; Generate gtkdoc files" if $*verbose;
    $prepare .= new;
    $prepare.generate-gtkdoc
  }

  # Generate the global data results from the gtkdocs generated files
  my SkimGtkDoc $skim-doc .= new;
  if $g {
    note "\nOption -g; Generate global data from gtkdocs generated files"
      if $*verbose;
    $skim-doc.process-apidocs;
  }

  if $y and ?$gnome-class {
    note "\nGenerate yaml file for module $gnome-class from gtkdocs files"
      if $*verbose;
    $*gnome-class = $gnome-class;
    $prepare .= new;
    $skim-doc.process-gtkdocs;
  }

  if $r and ?$gnome-class {
    note "\nOption -r; Generate $gnome-class Raku module from yaml file"
      if $*verbose;
    $*gnome-class = $gnome-class;
# done in GenRakuModule:      $prepare .= new;

    $raku-module .= new;
    $raku-module.generate;
    $raku-module.save;
  }
}

#-------------------------------------------------------------------------------
sub USAGE ( ) {

  # Need to call Prepare init to get a few values in the output
  $*verbose = False;
#  my Prepare $gfl .= new;

  note qq:to/EOHELP/;

  Program to generate Raku modules from the Gnome source code using
  the GtkDoc tool also used by Gnome to generate there documentation.

  Usage
    {$*PROGRAM.basename} [Options] gnome-package [gnome-class]

    Options:
      d       Generate the gtk doc environment from the source code using the
              argument. No Raku module is generated. Default False.
      g       Generate global data only. No Raku module is generated. Default
              False.
      h       Show this info.
      r       Generate Raku module from argument. Result is put in directory
              '{$*work-data<new-raku-modules>}' together with a test file.
      y       Generate the intermediate yaml files. The files will be kept, so
              they need to be generated only once.
      v       Show some info while stumping. Default False.

    Arguments
      gnome-package   The package name used for the gnome class. Select from
                      {SkimSource.keys.sort}. This argument must always be
                      provided.
      gnome-class     A gnome class name like GtkButton or GApplication. This is
                      optional when only the GtkDoc results are to be generated.

EOHELP
}
