#!/usr/bin/env rakudo

use Gnome::SourceSkimTool::ConstEnumType;
#use Gnome::SourceSkimTool::Prepare;
use YAMLish;
use Getopt::Long;

#-------------------------------------------------------------------------------
my SkimSource $*gnome-package;
my Str $*gnome-class;
my Hash $*work-data;
my Bool $*verbose;

my Hash $*object-maps = %();
#my Hash $*other-work-data;

my Bool $*generate-code = False;
my Bool $*generate-doc = False;
my Bool $*generate-test = False;

my Str $*class-code = '';     # used for classes and interfaces
my Str $*callable-code = '';
my Str $*types-code = '';
my Str $*record-code = '';

my Hash $*external-modules = %();
my @*map-search-list;

my $*command-line;
my @*gir-type-select;

my Hash $*lib-content-list-file = load-yaml(lib-content-list-file.IO.slurp);

my Array $*saved-file-summary = [];

#-------------------------------------------------------------------------------
my Capture $options = get-options(<h v c d t>);
my Str ( $gnome-package, $filename, *@types) = @*ARGS;
my Hash $o = $options.Hash;

my Bool ( $v, $h, $c, $d, $t );
$v = ?$o<v>;
$h = ?$o<h>;
$c = ?$o<c>;
$d = ?$o<d>;
$t = ?$o<t>;


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

# Must use =comment because '#' is translated in =head2 later on
$filename .= lc;
$*command-line = "=comment Package: $*gnome-package.Str(), C-Source: $filename";
$*verbose = $v;

@*gir-type-select = @types // ();

# Generate library code
if $c {
  say "\nGenerate code";
  $*generate-code = True;
  require ::('Gnome::SourceSkimTool::GenerateCode');
  my $raku-module =
      ::('Gnome::SourceSkimTool::GenerateCode').new(:$filename);
  $raku-module.generate-code;
  $*generate-code = False;
}

# Generate documentation
if $d {
  say "\nGenerate documentation";
  $*generate-doc = True;
  require ::('Gnome::SourceSkimTool::GenerateDoc');
  my $raku-module = ::('Gnome::SourceSkimTool::GenerateDoc').new(:$filename);
  $raku-module.generate-doc;
  $*generate-doc = False;
}

# Generate test code
if $t {
  say "\nGenerate tests";
  $*generate-test = True;

  require ::('Gnome::SourceSkimTool::GenerateTest');
  my $raku-module =
      ::('Gnome::SourceSkimTool::GenerateTest').new(:$filename);
  $raku-module.generate-test;

  $*generate-test = False;
}

say "\n\nSummary of saved files\n  ", $*saved-file-summary.join("\n  ");


exit(0);

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

    Options:
      c       Generate a Raku code file for all gir-types found in the
              file. Result is put in directory below '{API2MODS}'. Using the
              file 'types' in package 'Gdk3' it generates files 'N-GdkPoint.
              rakumod', 'N-GdkRectangle.rakumod', 'Rectangle.rakumod' and
              'T-types.rakumod' in the 'gnome-gdk3/lib/Gnome/Gdk3' tree.
      d       Generate a Raku pod documentation file for all gir-types found
              in the file. Result is put in directory below '{API2MODS}'.
              The file 'value' with package 'GObject' generates
              'N-GValue.rakudoc' and 'Value.rakudoc' in the 'gnome-gobject/doc'
              tree to document the modules 'T-value.rakumod' and
              'Value.rakumod' respectively.
      h       Show this info. (or any other non existant option ;-)
      t       Generate a test file for all gir-types found in the
              file. The file 'aboutdialog' in 'Gtk3' generates files
              'AboutDialog.rakutest' and 'T-aboutdialog.rakutest' in the
              'gnome-gtk3/t' tree to test the modules 'AboutDialog.rakumod'
              and 'T-aboutdialog.rakumod'.
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

  Example
    generate.raku -v Glib main -cd
    generate.raku Gtk4 aboutdialog -t

  EOHELP
}
