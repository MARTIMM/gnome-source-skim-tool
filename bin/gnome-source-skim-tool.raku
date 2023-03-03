#!/usr/bin/env rakudo

use Gnome::SourceSkimTool::Prepare;
use Gnome::SourceSkimTool::ConstEnumType;

#-------------------------------------------------------------------------------
constant \Prepare = Gnome::SourceSkimTool::Prepare:auth<github:MARTIMM>;

my SkimSource $*use-doc-source;

# $sub-prefix is the name of gnome class. Sometimes another class is defined
# within the same file. To generate that part, add the $other-prefix.
my Str $*sub-prefix;            # provided sub prefix is the name of gnome class
my Str $*library;               # native lib sub from Gnome::N

my Bool $*verbose;

#my Str $source
my @source-dir-list = ();

#-------------------------------------------------------------------------------
sub MAIN (
  Str:D $sub-prefix, Bool :$verbose = False, Bool :$global = False,
  Bool :$gtkdoc = False, Bool :$help = False, Bool :$raku = False
) {
  if $h {
    USAGE;
    exit(0);
  }

  $*verbose = $verbose;

  # Make a list of C source files if requested and load the list
  my Prepare $gfl .= new;
  $gfl.generate-gtkdoc if $gtkdoc;
}

#-------------------------------------------------------------------------------
sub USAGE ( ) {
note Q:to/EOHELP/;

  Program to generate Raku modules from the Gnome source code using
  the GtkDoc tool also used by Gnome to generate there documentation.

  Usage
    $*PROGRAM-NAME [Options] Arguments

    Options:
      global          Generate global data only. No Raku module
                      is generated. Default False.
      gtkdoc          Generate the gtk doc environment from the source code
                      using the argument. No Raku module is generated.
                      Default False.
      help            Show this info.
      raku            Generate Raku module from argument. Result is put in
                      directory './xt/NewRakuModules' together with a test file.
      verbose         Show some info while stumping. Default False.

    Arguments
      sub-prefix

EOHELP
}
