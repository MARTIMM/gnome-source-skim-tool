#!/usr/bin/env -S rakudo -Ilib

use v6.d;

use Gnome::SourceSkimTool::ConstEnumType;
use Gnome::SourceSkimTool::Prepare;
use Gnome::SourceSkimTool::SkimGirSource;
use YAMLish;

#-------------------------------------------------------------------------------
my SkimSource $*gnome-package;
my Str $*gnome-class;
my Hash $*work-data;
my Bool $*verbose;

my Hash $*object-maps = %();
#my Hash $*other-work-data;

my Str $*class-code = '';     # used for classes and interfaces
my Str $*callable-code = '';
my Str $*types-code = '';
my Str $*record-code = '';

my Hash $*external-modules = %();
my @*map-search-list;

my Hash $*lib-content-list-file = load-yaml(lib-content-list-file.IO.slurp);

my Array $*saved-file-summary = [];

my Str $*lib-version;
my Str $*namespace-name;
my Str $*symbol-prefix;

my Str $*api2root =
   $*HOME ~ '/Languages/Raku/Projects/gnome-source-skim-tool/gnome-api2/';

#-------------------------------------------------------------------------------
sub MAIN ( *@gnome-packages, Bool :$v = False, Bool :$help = False ) {

  if $help {
    USAGE;
    exit(0);
  }

  $*verbose = $v;

  for @gnome-packages -> $gnome-package {
    try {
      $*gnome-package = SkimSource(SkimSource.enums{$gnome-package});
      CATCH {
        default {
          USAGE;
          exit(1);
        }
      }
    }

    say "\nGenerate the intermediate gir and yaml files for package $gnome-package" if $*verbose;
    my Gnome::SourceSkimTool::Prepare $prepare .= new;
    my Gnome::SourceSkimTool::SkimGirSource $skim-doc .= new;

    $skim-doc.load-gir-file;
    $skim-doc.load-map;
    $skim-doc.make-subgirs-from-gir;
    $skim-doc.save-map;
    $skim-doc.make-yaml-from-subgirs;
  }
}

#-------------------------------------------------------------------------------
sub USAGE ( ) {

  say qq:to/EOHELP/;

  Generate the intermediate gir and yaml files. The files will be
  kept, so they need to be generated only once or when sources are
  updated.

  Usage
    {$*PROGRAM.basename} -h

    {$*PROGRAM.basename} [-v] package …

    Options:
      help    Show this info.
      v       Show some extra info while stumping. Default False.

    Arguments
      package   The Gnome package name used for the class. Select one
                from this list; Gtk4 Gdk4 Gsk4
                GdkPixbuf Pango Grapheme Gio Glib GObject.
  EOHELP
}

#NOTE package tested against SkimSource enums defined in Gnome::SourceSkimTool::ConstEnumType
#NOTE skip Gtk3 Gdk3 and others for the moment