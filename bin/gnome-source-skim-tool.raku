#!/usr/bin/env rakudo

use Gnome::SourceSkimTool::ConstEnumType;
use Gnome::SourceSkimTool::Prepare;
use YAMLish;

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

my Str $*class-code = '';     # used for classes and interfaces
my Str $*callable-code = '';
my Str $*types-code = '';
my Str $*record-code = '';

my Hash $*external-modules = %();
my @*map-search-list;

my $*command-line = $*PROGRAM-NAME.IO.basename ~ ' ' ~ @*ARGS.join(' ');
my @*gir-type-select;

my Hash $*lib-content-list-file = load-yaml(lib-content-list-file.IO.slurp);

#-------------------------------------------------------------------------------
sub MAIN (
  Str:D $gnome-package, Str $filename? is copy, *@types,
  Bool :$v = False,
  Bool :$gir = False,
  Bool :$c = False, Bool :$d = False, Bool :$t = False,
  Bool :$help = False,
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

  $*generate-code = $c;
  $*generate-doc = $d;
  $*generate-test = $t;

  @*gir-type-select = @types // ();

  if $gir {
    say "Generate the intermediate gir and yaml files" if $*verbose;
    my Gnome::SourceSkimTool::Prepare $prepare .= new(:!load-maps);
    require ::('Gnome::SourceSkimTool::SkimGtkDoc');
    my $skim-doc = ::('Gnome::SourceSkimTool::SkimGtkDoc').new;
    $skim-doc.load-gir-file;
    $skim-doc.get-classes-from-gir;
  }

  # Get data using filename
  else {
    $filename .= lc;
    my Gnome::SourceSkimTool::Prepare $prepare .= new;

    if $*generate-code {
      require ::('Gnome::SourceSkimTool::GenerateCode');
      my $raku-module =
         ::('Gnome::SourceSkimTool::GenerateCode').new(:$filename);
      $raku-module.generate-code;
    }

    if $*generate-doc {
    }

    if $*generate-test {
      require ::('Gnome::SourceSkimTool::GenerateTest');
      my $raku-module =
         ::('Gnome::SourceSkimTool::GenerateTest').new(:$filename);
      $raku-module.generate-test;
    }
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

    {$*PROGRAM.basename} [-c][-d][-t][-v] package filename [gir-types]

    {$*PROGRAM.basename} -gir [-v] package

    Options:
      c       Generate a Raku code file for all gir-types found in the
              file. Result is put in directory '{RAKUMODS}'. Using the file
              'types' in package 'Gdk3' generates files 'N-GdkPoint.rakumod',
              'N-GdkRectangle.rakumod', 'Rectangle.rakumod' and
              'T-Types.rakumod'.
      d       Generate a Raku pod documentation file for  all gir-types found
              in the file. Result is put in directory '{RAKUMODS}'. The file
              'value' with package 'GObject' generates 'N-GValue.rakudoc' and
              'Value.rakudoc' to document the modules 'T-Value.rakumod' and
              'Value.rakumod' respectively.
      help    Show this info. (or any other non existant option ;-)
      t       Generate a test file for all gir-types found in the
              file. The file 'aboutdialog' in 'Gtk3' generates files
              'AboutDialog.rakutest' and 'T-AboutDialog.rakutest' to test for
              the modules 'AboutDialog.rakumod' and 'T-Aboutdialog.rakumod'.
      gir     Generate the intermediate gir and yaml files. The files will be
              kept, so they need to be generated only once or when sources are
              updated.
      v       Show some extra info while stumping. Default False.

    Arguments
      package   The Gnome package name used for the class. Select one
                from this list; Atk Cairo DBus DBusGLib Gdk3 Gdk4
                GdkPixbuf GdkPixdata Gio Glib GObject Gtk3 Gtk4 Gsk4
                Pango PangoCairo GIRepo.
      filename  A source filename wherein everything is defined originally
                (from *.c/*.h files). Several types like classes, record etc,
                may be defined in the file. An example is the name from Gtk3,
                'aboutdialog' where an independent function 
                'gtk_show_about_dialog', an enumeration 'GtkLicense' and a
                class 'GtkAboutDialog' is found. The results are stored in a
                single file 'lib/Gnome/Gtk3/AboutDialog.rakumod'.
                Other names may result in more files.
                separately.
      gir-types Types to process. The main types are 'class', 'interface',
                'record', 'union', 'enumeration', 'bitfield' and 'constant'.
                There are a few more but not yet processed. Name those you want
                to process. This is only needed for testing because in some
                cases you may miss out info in certain cases.
  EOHELP
}
