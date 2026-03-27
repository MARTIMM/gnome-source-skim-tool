#!/usr/bin/env -S rakudo -Ilib

use v6.d;

use YAMLish;

use Gnome::SourceSkimTool::Prepare;
use Gnome::SourceSkimTool::ConstEnumType;

use Gnome::Versions;

my Str $doc = '';

#my Str $gnome-package = @*ARGS[0];

#sub MAIN ( Str $gnome-package ) {
sub MAIN ( $gnome-package! ) {

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

  #my Str $p = $repolib{$gnome-package};
  #$gnome-versions.add-repos($gnome-package => $p);

  my $*gnome-package = SkimSource(SkimSource.enums{$gnome-package});
  my $*generate-code = False;
  my $*generate-test = False;
  my $*external-modules = %();
  my $*verbose = False;
  my @*map-search-list = ();
  my $*gnome-class = '';
  my $*work-data;

  my Gnome::SourceSkimTool::Prepare $prepare .= new;
  $*work-data<finit>( $*work-data, :label<work-data>);

  $doc ~= set-style;

  $doc ~= "\n# Library and distribution information\n\n";
  $doc ~= "\n|Distribution|Raku version|Gnome library version|\n|-|-|-|\n";
  for <Gtk4 Gdk4 Gsk4 Graphene Glib Gio GObject Pango GdkPixbuf> -> $package {
    $doc ~= "|Gnome::$package|"
          ~ $gnome-versions.raku-version($package) ~ "|"
          ~ $gnome-versions.gnome-version($package) ~ "|\n";
  }

  $doc ~= set-legend;

  # Scan file in storage dir
  for dir($*work-data<gir-module-path>).sort -> $file {
#    state Bool $run-code = True;

    # Skip repo-object-map.yaml and all .gir files.
    next if $file.basename ~~ m/ [^ repo '-' object || \. gir $] /;

    # Get the data from the yaml file
    my Hash $data = load-yaml($file.slurp);

#    if $run-code {
#      $run-code = False;
#    }

    for $data.keys.sort: { $^a.lc leg $^b.lc } -> $obj-name {
      next if $obj-name ~~ any(<namespace-name symbol-prefix version>);

      $doc ~= set-module-info( $data, $obj-name);

  my Hash $obj-data = $data{$obj-name};
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
    }
  last
  }

note "\n\n$doc";
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

#-------------------------------------------------------------------------------
sub set-style ( --> Str ) {
  Q:q:to/EOSTYLE/;
      ---
      title: Gnome api 2
      layout: sidebar
      nav_menu: api2-nav
      sidebar_menu: api2-checklist-sidebar
      ---

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
    
    # Legend for the tables

    |Symbol|Meaning|
    |-|-|
    |{md-image('checklist-ok')}|Code and documentation is generated|
    |{md-image('checklist-implement')}|Must be written|
    |{md-image('checklist-deprecated')}|Removed in next Gnome library release|
    |{md-image('checklist-missing')}|Not generated, there are missing types|
    EOLEGEND
}
 
#-------------------------------------------------------------------------------
sub set-module-info ( Hash $data, Str $obj-name --> Str ) {
  my Hash $obj-data = $data{$obj-name};
  my Hash $checks = $obj-data<checks>;

  $doc ~= "\n# Module Information\n\n";
  $doc ~= "||State|Name|Tests|\n|-|-|-|-|\n";
  $doc ~= "|Class name||$obj-data<class-name>||\n";
  $doc ~= "|Module generated|"
        ~ ($checks<modules-generated>
            ?? md-image('checklist-ok')
            !! md-image('checklist-implement')
          ) ~ "|$obj-name.rakumod\n";
  $doc ~= "|Documentation corrected|"
        ~ ($checks<handcorrected-docs>
            ?? md-image('checklist-ok')
            !! md-image('checklist-implement')
          ) ~ "|$obj-name.rakudoc\n";
  $doc ~= "|Tests completed|"
        ~ (?$checks<nbr-tests>
            ?? md-image('checklist-ok')
            !! md-image('checklist-implement')
          ) ~ "|$obj-name.rakutest|$checks<nbr-tests> tests|\n";

}

#-------------------------------------------------------------------------------
#NOTE: the $asset-path is a path on the documentation site of MARTIMM.github.io
sub md-image ( Str $name --> Str ) {
  my $asset-path = '/content-docs/asset_files/images/';
  [~] '![](', $asset-path, $name, '.png)';
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




