#!/usr/bin/env -S rakudo -Ilib

use Gnome::SourceSkimTool::ConstEnumType;
#use Gnome::SourceSkimTool::Prepare;
use YAMLish;
use Getopt::Long;

use Gnome::SourceSkimTool::GenerateCode;

#-------------------------------------------------------------------------------
my SkimSource $*gnome-package;
my Str $*gnome-class;
my Hash $*work-data;
my Bool $*verbose;

my Hash $*object-maps = %();
#my Hash $*other-work-data;

my Bool $*generate-code = True;
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
my Capture $options = get-options(<h v>);
my Str $gnome-package = @*ARGS[0];
my Hash $o = $options.Hash;

my Bool ( $v, $h);
$v = ?$o<v>;  # verbose
$h = ?$o<h>;  # help

my Bool $*overwrite = True;     # Automatic (over)write.

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

my Str $repo-object-path = SKIMTOOLDATA ~ "$gnome-package/repo-object-map.yaml";
my Hash $repo-object = load-yaml($repo-object-path.IO.slurp);
for $repo-object.kv -> Str $gnome-name, Hash $gnome-object {
  if $gnome-object<gir-type> ~~ any(<class interface record union>) {
    my Str $class-path = [~] 'gnome-api2/gnome-', $gnome-package.lc, '/lib/';
    $class-path ~= S:g/ '::' /\// with $gnome-object<class-name> ~ '.rakumod';
#     = $gnome-object<class-name>;
#    $class-path ~~ s:g/ '::' /\//;
#    $class-path =
#      [~] 'gnome-api2/gnome-', $gnome-package.lc, '/lib/', $class-path;

    if $class-path.IO ~~ :e {
      my Str $filename = $gnome-object<source-filename>;

      # Must use =comment because '#' is translated in =head2 later on.
      # This line shows up at the top of eache generated file.
      $*command-line = "=comment Package: $*gnome-package.Str(), C-Source: $filename";
      $*verbose = $v;

      @*gir-type-select = ($gnome-object<gir-type>,);

      say '-' x 79, "\nRegenerate code for $gnome-object<class-name>";
      $*generate-code = True;
      my Gnome::SourceSkimTool::GenerateCode $raku-module .= new(:$filename);
      $raku-module.generate-code;
      $*generate-code = False;

      say "\n\nSummary of saved files\n  ", $*saved-file-summary.join("\n  ");
      $*saved-file-summary = [];
    }

    else {
      note "\nSkip $gnome-object<class-name>";
    }
  }
}

exit(0);

#-------------------------------------------------------------------------------
sub USAGE ( ) {

  # Need to call Prepare init to get a few values in the output
#  $*verbose = False;
#  my Prepare $gfl .= new;

  say qq:to/EOHELP/;

  Program to regenerate all Raku modules in a package from the
  XML files of the Gnome Introspection Repository files.

  Usage
    {$*PROGRAM.basename} -h

    {$*PROGRAM.basename} [-c][-d][-t][-v] package filename [gir-types]

    Options:
      h       Show this info. (or any other non existant option ;-)
      v       Show some extra info while stumping. Default False.

    Arguments
      package   The Gnome package name used for the class. Select one
                from this list; Atk Cairo DBus DBusGLib Gdk3 Gdk4
                GdkPixbuf GdkPixdata Gio Glib GObject Gtk3 Gtk4 Gsk4
                Pango PangoCairo GIRepo.
      filenames One or more source filenames wherein everything is defined
                originally (from *.c/*.h files). Several types like classes,
                record etc, may be defined in the file. An example is the
                name from Gtk4, 'aboutdialog' where an independent function 
                'gtk_show_about_dialog', an enumeration 'GtkLicense' and a
                class 'GtkAboutDialog' is found. The results are stored in a
                file 'lib/Gnome/Gtk4/AboutDialog.rakumod' and
                'lib/Gnome/Gtk4/T-aboutdialog.rakumod'. Other names may
                result in more and different files.

  Example
    generate.raku -v Glib main -cd
    generate.raku Gtk4 aboutdialog -t

  EOHELP
}
