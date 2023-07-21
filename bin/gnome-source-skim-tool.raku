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

my Bool $*generate-code;
my Bool $*generate-doc;
my Bool $*generate-test;

my Str $*class-code = '';     # used for classes and interfaces
my Str $*callable-code = '';
my Str $*types-code = '';
my Str $*record-code = '';

my Array $*external-modules;
my @*map-search-list;

my $*command-line = $*PROGRAM-NAME.IO.basename ~ ' ' ~ @*ARGS.join(' ');
my @*gir-type-select;

#-------------------------------------------------------------------------------
sub MAIN (
  Str:D $gnome-package, Str $gnome-class?, *@types,
  Bool :$v = False,
  Bool :$gir = False,
#  Bool :$c = False, Bool :$r = False, Bool :$i = False, Bool :$u = False,
#  Bool :$f = False,
  Bool :$c = False, Bool :$d = False, Bool :$t = False,
  Bool :$help = False,
#  Bool :$list = False, Str :$type = '', Str :$filter
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

#note "$?LINE $f, $*generate-code, $*generate-doc, $*generate-test, $gnome-class";

#  $*external-modules = [<
#    NativeCall Gnome::N::NativeLib Gnome::N::N-GObject Gnome::N::GlibToRakuTypes
#  >];

  if $gir {
    say "Generate the intermediate gir and yaml files" if $*verbose;
#    $*gnome-class = $gnome-class // 'Widget';
    my Gnome::SourceSkimTool::Prepare $prepare .= new(:!load-maps);
    my Gnome::SourceSkimTool::SkimGtkDoc $skim-doc .= new;
    $skim-doc.load-gir-file;
    $skim-doc.get-classes-from-gir;
  }

#`{{
  elsif $list {
    $*verbose = False;
#    $*gnome-class = $gnome-class // 'Widget';
    my Gnome::SourceSkimTool::Prepare $prepare .= new;
    require ::('Gnome::SourceSkimTool::ListGirTypes');
    my $lt = ::('Gnome::SourceSkimTool::ListGirTypes').new;
#TODO add filter from -filter
    if ?$type {
      $lt.list-type-objects($type);
    }

    else {
      $lt.list-types
    }
  }
}}

  # Get data using filename
  #elsif $f and ?$gnome-class {
  else {
    my Str $filename = $gnome-class.lc;
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
    }
#    $raku-module.generate-test if $*generate-test;
#    $raku-module.generate-doc if $*generate-doc;
  }

#`{{
  # Get data using class name
  elsif $c and ?$gnome-class {
    $*gnome-class = $gnome-class;
    my Gnome::SourceSkimTool::Prepare $prepare .= new;

    say "Generate Raku module from class data in $*work-data<raku-class-name>"
         if $*verbose;
    require ::('Gnome::SourceSkimTool::Class');
    my $raku-module = ::('Gnome::SourceSkimTool::Class').new;
    $raku-module.generate-code if $*generate-code;
    $raku-module.generate-test if $*generate-test;
    $raku-module.generate-doc if $*generate-doc;
  }

  # Get data using interface name
  elsif $i and ?$gnome-class {
    $*gnome-class = $gnome-class;
    my Gnome::SourceSkimTool::Prepare $prepare .= new;

    say "Generate Raku module from interface data in $*work-data<raku-class-name>"
         if $*verbose;
    require ::('Gnome::SourceSkimTool::Interface');
    my $raku-interface = ::('Gnome::SourceSkimTool::Interface').new;
    $raku-interface.generate-code if $*generate-code;
    #$raku-module.generate-doc if $*generate-doc;
    #$raku-module.generate-test if $*generate-test;
  }

  # Get data using record name
  elsif $r and ?$gnome-class {
    $*gnome-class = $gnome-class;
    my Gnome::SourceSkimTool::Prepare $prepare .= new;

    say "Generate Raku module from record data in $*work-data<raku-class-name>"
         if $*verbose;
    require ::('Gnome::SourceSkimTool::Record');
    my $raku-record = ::('Gnome::SourceSkimTool::Record').new;
    $raku-record.generate-code if $*generate-code;
    $raku-record.generate-test if $*generate-test;
    #$raku-module.generate-doc if $*generate-doc;
  }

  # Get data using union name
  elsif $u and ?$gnome-class {
    $*gnome-class = $gnome-class;
    my Gnome::SourceSkimTool::Prepare $prepare .= new;

    say "Generate Raku module from union data in $*work-data<raku-class-name>"
         if $*verbose;
    require ::('Gnome::SourceSkimTool::Union');
    my $raku-record = ::('Gnome::SourceSkimTool::Union').new;
    $raku-record.generate-code if $*generate-code;
    $raku-record.generate-test if $*generate-test;
    #$raku-module.generate-doc if $*generate-doc;
  }
}}
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






=finish
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

    {$*PROGRAM.basename} -c  [-m][-t][-d][-v] package class
    {$*PROGRAM.basename} -i  [-m][-t][-d][-v] package interface
    {$*PROGRAM.basename} -r  [-m][-t][-d][-v] package record
    {$*PROGRAM.basename} -f  [-m][-t][-d][-v] package filename

    {$*PROGRAM.basename} -gir [-v] package

    {$*PROGRAM.basename} -l [-type=Str] [-filter=Str] package

    Options:
      c       Select a class module.
      d       Generate a Raku pod documentation file for a class (-c),
              interface (-i) or record (-r). Result is put in directory
              '{RAKUMODS}', e.g. 'AboutDialog.rakudoc' or 'Window.rakudoc'
              defined in Gtk3 or Gtk4.
      f       Use a filename instead of one of -c, -i or -r. This is needed in
              cases that there are enumerations or bitmaps gathered into one
              file whithout having a class, record or interface.
      filter  Filter string used with -list and -type to narrow down list.
      help    Show this info. (or any other non existant option ;-)
      i       Select an interface (role) module.
      list    Show types used in the packages of Gnome.
      m       Generate a Raku code file for a class (-c), interface (-i) or
              record (-r). Result is put in directory '{RAKUMODS}', e.g.
              'File.rakumod' or 'Application.rakumod' defined in Gio.
      r       Select a record (structures) module from argument. The
              argument is a name. Result is put in directory
              '{RAKUMODS}', e.g. Error or List defined in Glib.
      t       Generate a test file for a class (-c), interface (-i) or
              record (-r). E.g. 'List.rakutest' or 'Variant.rakutest' 
              defined in Glib.
      type=Str
              Use the type output from the plain -l option. With this option, a
              list of names is output defined as that type.
      gir     Generate the intermediate gir and yaml files. The files will be
              kept, so they need to be generated only once or when sources are
              updated.
      v       Show some info while stumping. Default False.

    Arguments
      package   The Gnome package name used for the class. Select one
                from this list; Atk Cairo DBus DBusGLib Gdk3 Gdk4
                GdkPixbuf GdkPixdata Gio Glib GObject Gtk3 Gtk4 Gsk4
                Pango PangoCairo GIRepo.
      class     A class name like Button or Application defined in a package
                like Gtk3, Gtk4 or Gio.
      record    A record name like Error or List in Glib
      filename  A filename wherein everything is defined originally.
  EOHELP
}
