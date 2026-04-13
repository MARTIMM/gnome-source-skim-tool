#!/usr/bin/env -S rakudo -Ilib

use v6.d;

use YAMLish;

use Gnome::SourceSkimTool::Prepare;
use Gnome::SourceSkimTool::ConstEnumType;

use Gnome::Versions;

#-------------------------------------------------------------------------------
multi sub MAIN ( ) {

  with my Gnome::Versions $gnome-versions .= new {
    .set-repopath(
      $*HOME ~ '/Languages/Raku/Projects/gnome-source-skim-tool/gnome-api2'
    );

    .add-repos(
      :Gtk4<gnome-gtk4>,
      :Gdk4<gnome-gdk4>,
      :Gsk4<gnome-gsk4>,
      :Graphene<gnome-graphene>,

      :Gtk3<gnome-gtk3>,
      :Gdk3<gnome-gdk3>,

      :Glib<gnome-glib>,
      :Gio<gnome-gio>,
      :GObject<gnome-gobject>,

      :Pango<gnome-pango>,
      :GdkPixbuf<gnome-gdkpixbuf>,
    );
  }

  my Str $doc = Q:qq:to/EOHEADER/;
    {set-preamble}
    {set-style}

    # Library and distribution information

    Below there is a table of versions. It shows the current Raku distributions and the Gnome library versions on my computer. It may give you an indication of what is provided by the Raku distributions compared to the [Gnome documentation](https://docs.gtk.org/). There are also tables for each module in a distribution showing what is supported or need to be defined.

    |Distribution|Raku version|Gnome library version|
    |-|-|-|
    EOHEADER

  for <Gtk4 Gdk4 Gsk4 Graphene Glib Gio GObject Pango GdkPixbuf> -> $package {
    $doc ~= "|Gnome::$package|"
          ~ $gnome-versions.raku-version($package) ~ "|"
          ~ $gnome-versions.gnome-version($package) ~ "|\n";
  }

  note "Save lib-versions.md";
  'doc/checklists/lib-versions.md'.IO.spurt($doc);
}

#-------------------------------------------------------------------------------
multi sub MAIN ( SkimSource $gnome-package!, Str $module = '' ) {

  my $*gnome-package = SkimSource(SkimSource.enums{$gnome-package});
  my $*generate-code = False;
  my $*generate-test = False;
  my $*external-modules = %();
  my $*verbose = False;
  my @*map-search-list = ();
  my $*gnome-class = '';
  my $*work-data;

  my Gnome::SourceSkimTool::Prepare $prepare .= new;
#  $*work-data<finit>( $*work-data, :label<work-data>);

  my Str $list-root = 'doc/checklists/' ~ $gnome-package.Str;
  mkdir $list-root, 0o750 unless $list-root.IO ~~ :r;

  # Scan files in storage dir. If $module is defined, select only that file.
  # Files are prefixed with 'C-'. 'I-' or 'R-'.
  my @files;
  if ?$module {
    my Str $gmp = $*work-data<gir-module-path>;
    for <C- I- R-> -> $prefix {
      if "$gmp$prefix$module.yaml".IO ~~ :r {
        @files.push: "$gmp$prefix$module.yaml".IO;
        last;
      }
    }
  }

  else {
    @files = dir($*work-data<gir-module-path>).sort: { $^a.lc leg $^b.lc };
  }

  for @files -> $file {
    my Str $doc = '';
    $doc ~= set-preamble(:$gnome-package);
    $doc ~= set-style;

    # Skip repo-object-map.yaml and all .gir files.
    next if $file.basename ~~ m/ [^ repo '-' object || \. gir $] /;

    # Get the data from the yaml file
    my Hash $data = load-yaml($file.slurp);

    for $data.keys.sort: { $^a.lc leg $^b.lc } -> $obj-name {
      # Skip non module keys
      next if $obj-name ~~ any(<namespace-name symbol-prefix version>);

      # Get module data
      my Hash $obj-data = $data{$obj-name};

      my Str $md-file = $file.basename;
      $md-file ~~ s/ \.yaml $/.md/;
      $md-file ~~ s/^ 'R-' /N-/;
      $md-file ~~ s/^ 'I-' /R-/;
      $md-file ~~ s/^ 'C-' //;
      $md-file = "$list-root/$md-file";

      # Check if a module must be ignored
      if ?$obj-data<checks><no-implement> {
        if $md-file.IO ~~ :e {
          unlink $md-file;
          note "$md-file removed";
        }
      }

      else {
        $doc ~= set-module-info( $obj-data, $md-file);
        $doc ~= set-routine-info( $obj-data, $obj-name);

        $doc ~= set-legend;

        note "save $md-file";
        $md-file.IO.spurt($doc);
      }
    }

  }
}

#-------------------------------------------------------------------------------
sub set-preamble ( Str() :$gnome-package --> Str ) {
  Q:qq:to/EOPREAMBLE/;
    ---
    title: Gnome api 2
    layout: sidebar
    nav_menu: api2-nav
    sidebar_menu: api2-{?$gnome-package ?? $gnome-package.lc ~ '-' !! ''}checklist-sidebar
    ---
    EOPREAMBLE
}

#-------------------------------------------------------------------------------
sub set-style ( --> Str ) {
  Q:q:to/EOSTYLE/;
    <style>
    html body table {
      border: 2px solid rgb(47, 0, 47);
      width: 95%;
      margin: 0px auto;
      display: block table;
    }

    td:nth-child(1) {  
      width: 35%;
    }
    </style>
    EOSTYLE
}

#-------------------------------------------------------------------------------
sub set-legend ( --> Str ) {
  Q:qq:to/EOLEGEND/;

    ## Legend for the tables

    |Symbol|Meaning|
    |-|-|
    |{md-image('checklist-ok')}|Code and documentation is generated|
    |{md-image('checklist-implement')}|Must be written|
    |{md-image('checklist-deprecated')}|Removed in next Gnome library release|
    |{md-image('checklist-missing')}|Not generated, there are missing types|
    |{md-image('checklist-no-implement')}|Will not be generated|
    EOLEGEND
}

#-------------------------------------------------------------------------------
sub set-module-info ( Hash $obj-data, Str $md-file is copy --> Str ) {
#  my Hash $obj-data = $data{$obj-name};
  my Hash $checks = $obj-data<checks>;

  $md-file = $md-file.IO.basename;
  $md-file ~~ s/ \. md $//;

  my Str $doc = Q:qq:to/EOINFO/;
    # Module Checklist

    Checklist for module $obj-data<class-name> to show the progress of deveopment or wheher it is deprecated. Most of the modules are generated but documentation needs to be checked for typos ad mistakes. Also examples may be added. Not much will be done for deprecated modules. You might be interested in the [GnomeTools distribution](/content-docs/GnomeTools/index.html) where some of the deprecated modules are rewritten.

    Furthermore there is a list of the current versions of [Gnome libraries]() installed on my machine versus the Raku distribution versions.

    ## $obj-data<class-name>

    ||State|Name|Tests|
    |-|-|-|-|
    EOINFO

  $doc ~= "|Module generated|"
        ~ ($checks<modules-generated>
            ?? md-image('checklist-ok')
            !! md-image('checklist-implement')
          ) ~ "|$md-file.rakumod\n";
  $doc ~= "|Documentation corrected|"
        ~ ($checks<handcorrected-docs>
            ?? md-image('checklist-ok')
            !! md-image('checklist-implement')
          ) ~ "|$md-file.rakudoc\n";
  $doc ~= "|Tests completed|"
        ~ (?$checks<nbr-tests>
            ?? md-image('checklist-ok')
            !! md-image('checklist-implement')
          ) ~ "|$md-file.rakutest|$checks<nbr-tests> tests|\n";

  $doc
}

#-------------------------------------------------------------------------------
sub set-routine-info ( Hash $obj-data, Str $obj-name --> Str ) {
#      my Hash $obj-data = $data{$obj-name};
  my $doc = '';
  my Hash $r = $obj-data<routines>;
  if $r<constructors>:exists {
    $doc ~= "\n### Constructors\n\n";
    $doc ~= '|Routine|State¹|Version²|Deprecated³|' ~ "\n";
    $doc ~= '|-------|-|----------|-------|' ~ "\n";
    for $r<constructors>.keys.sort -> $rname {
      $doc ~= make-table-entry( $rname, $r<constructors>{$rname});
    }
  }

  $doc ~= "\n1. Status, generated, missing values, deprecated, etc\n";
  $doc ~= "2. Version of introduction, otherwise it is the release version\n";
  $doc ~= "3. Version of deprecation and is removed in next release\n";

  if $r<methods>:exists {
    $doc ~= "\n### Methods\n\n";
    $doc ~= '|Routine|State|Version|Deprecated|' ~ "\n";
    $doc ~= '|-------|-|----------|-------|' ~ "\n";
    for $r<methods>.keys.sort -> $rname {
      $doc ~= make-table-entry( $rname, $r<methods>{$rname});
    }
  }

  if $r<functions>:exists {
    $doc ~= "\n### Functions\n\n";
    $doc ~= '|Routine|State|Version|Deprecated|' ~ "\n";
    $doc ~= '|-------|-|----------|-------|' ~ "\n";
    for $r<functions>.keys.sort -> $rname {
      $doc ~= make-table-entry( $rname, $r<functions>{$rname});
    }
  }

  $doc
}

#-------------------------------------------------------------------------------
#NOTE: the $asset-path is a path on the documentation site of MARTIMM.github.io
sub md-image ( Str $name --> Str ) {
  my $asset-path = '/content-docs/asset_files/images/';
  [~] '![](', $asset-path, $name, '.png)';
}

#-------------------------------------------------------------------------------
sub make-table-entry ( Str $rname, Hash $rdata --> Str ) {
  my Str $doc = '';
  $doc ~= "| $rname |";
  $doc ~= $rdata<generated>
          ?? md-image('checklist-ok') !! md-image('checklist-implement');
  $doc ~= $rdata<missing-type>:exists ?? md-image('checklist-missing') !! '';
  $doc ~= $rdata<deprecated-version>:exists
          ?? md-image('checklist-deprecated') !! '';
  $doc ~= $rdata<version>:exists ?? "| $rdata<version> |" !! '||';
  $doc ~= $rdata<deprecated-version>:exists
          ?? "$rdata<deprecated-version> |" !! '|';
  $doc ~= "\n";

  $doc
}










=finish

my Gnome::SourceSkimTool::Prepare $prepare .= new;
$*work-data<finit>( $*work-data, :label<work-data>);

my Str $check-list = Q:qq:to/EOFCL/;
  # Documentation checklist for $*work-data<raku-package>

  EOFCL

my Proc $p = shell "ls -c1 $*work-data<result-mods>", :out;
for $p.out.lines.sort -> $l {
  $check-list ~= "* [ ] $l\n";
}

$p.out.close;

"doc/Doc Check Lists/{$gnome-package.lc}.md".IO.spurt($check-list);




