#!/usr/bin/env rakudo

use Gnome::SourceSkimTool::Prepare;
use Gnome::SourceSkimTool::ConstEnumType;
use Gnome::SourceSkimTool::SkimGtkDoc;

#-------------------------------------------------------------------------------
constant \Prepare = Gnome::SourceSkimTool::Prepare;
constant \SkimGtkDoc = Gnome::SourceSkimTool::SkimGtkDoc;

# $sub-prefix is the name of gnome class. Sometimes another class is defined
# within the same file. To generate that part, add the $other-prefix.

my SkimSource $*gnome-package;
my Str $*gnome-class;
my Hash $*work-data;

my Bool $*verbose;

#my Str $source
my @source-dir-list = ();

#-------------------------------------------------------------------------------
sub MAIN (
  Str:D $gnome-package, Str $gnome-class? = '',
  Bool :$g = False, Bool :$v = False,
  Bool :$d = False, Bool :$h = False, Bool :$r = False,
) {

  $*verbose = $v;

  $*gnome-package = SkimSource(SkimSource.enums{$gnome-package});
  if ! $*gnome-package.defined {
    USAGE;
    exit(1);
  }

  if $h {
    USAGE;
    exit(0);
  }

  # Generate the document results using gtkdoc
  my Prepare $prepare .= new;
  $prepare.generate-gtkdoc if $d;

  # Generate the global data results from the gtkdocs generated files
  if $g {
    my SkimGtkDoc $skim-doc .= new;
    $skim-doc.process-apidocs;
  }
}

#-------------------------------------------------------------------------------
sub USAGE ( ) {

  # Need to call Prepare init to get a few values in the output
  $*verbose = False;
  my Prepare $gfl .= new;

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
      v       Show some info while stumping. Default False.

    Arguments
      gnome-package   The package name used for the gnome class. Select from
                      {SkimSource.keys.sort}. This argument must always be
                      provided.
      gnome-class     A gnome class name like GtkButton or GApplication. This is
                      optional when only the GtkDoc results are to be generated.

EOHELP
}
