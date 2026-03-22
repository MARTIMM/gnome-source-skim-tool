#!/usr/bin/env -S rakudo -Ilib

use v6.d;

use YAMLish;

use Gnome::SourceSkimTool::Prepare;
use Gnome::SourceSkimTool::ConstEnumType;

use Gnome::Versions;

my Str $doc = '';

# Setup all version info for packages
my Hash $repolib = %(
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

#  :n<gnome-native>,
);

my Str $gnome-package = @*ARGS[0];

my Gnome::Versions $gnome-versions .= new;
$gnome-versions.set-repopath(
  $*HOME ~ '/Languages/Raku/Projects/gnome-source-skim-tool/gnome-api2'
);

my Str $p = $repolib{$gnome-package};
$gnome-versions.add-repos($gnome-package => $p);

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

#`{{
$doc ~= "Gnome library version: ";
$doc ~= $gnome-versions.gnome-version($gnome-package) ~ "\n";
$doc ~= "Raku distribution version: ";
$doc ~= $gnome-versions.raku-version($gnome-package) ~ "\n";
}}
#`{{
    $doc ~= make-table-start;
    $doc ~= make-table-head( "Information", "");
    $doc ~= make-table-entry(
      "Gnome library version", $gnome-versions.gnome-version($gnome-package)
    );
    $doc ~= make-table-entry(
      "Raku distribution version",
      $gnome-versions.raku-version($gnome-package)
    );
    $doc ~= make-table-entry( "Raku distribution", $*work-data<raku-package>);
    $doc ~= make-table-end;
}}

$doc ~= "|Information||\n|-|-|\n";
$doc ~= "|Raku distribution|$*work-data<raku-package>|\n";
$doc ~= "|Raku distribution version|$gnome-versions.raku-version($gnome-package)|\n";
$doc ~= "|Gnome library version|$gnome-versions.gnome-version($gnome-package)|\n";
#$doc ~= "|||\n";

# Scan file in storage dir
for dir($*work-data<gir-module-path>).sort -> $file {
#  state Bool $run-code = True;

  # Skip repo-object-map and all .gir files.
  next if $file.basename ~~ m/^ repo '-' /;
  next if $file.Str ~~ m/ \. gir $/;

  # Get the data from the yaml file
  my Hash $data = load-yaml($file.slurp);

#  if $run-code {
#    $doc ~= "Gnome namespace: $data[0]<namespace-name>\n";
#    $doc ~= "Gnome release: $data[0]<version>\n";
#
#    $run-code = False;
#  }

  for $data.keys.sort: { $^a.lc leg $^b.lc } -> $obj-name {
    next if $obj-name ~~ any(<namespace-name symbol-prefix version>);

    my Hash $obj-data = $data{$obj-name};
    my Hash $checks = $obj-data<checks>;


    $doc ~= "\n### $obj-data<class-name>\n";
    $doc ~= $checks<modules-generated>
              ?? '![](./checklist-ok.png)'
              !! '![](./checklist-implement.png)'
         ~ " Module is generated\n";

    $doc ~= $checks<handcorrected-docs>
              ?? '![](./checklist-ok.png)'
              !! '![](./checklist-implement.png)'
         ~ " Documentation is corrected\n";

    $doc ~= ?$checks<nbr-tests>
              ?? '![](./checklist-ok.png)'
              !! '![](./checklist-implement.png)',
         ~ " Number of tests: $checks<nbr-tests>\n";

    my Hash $r = $obj-data<routines>;
    if $r<constructors>:exists {
      $doc ~= "\n### Constructors\n";
      $doc ~= '|Routine|G|Deprecated|Version|' ~ "\n";
      $doc ~= '|-------|-|----------|-------|' ~ "\n";
      for $r<constructors>.keys.sort -> $rname {
        $doc ~= make-table-entry( $rname, $r<constructors>{$rname});
      }
    }

    if $r<methods>:exists {
      $doc ~= "\n### Methods\n";
      $doc ~= '|Routine|G|Deprecated|Version|' ~ "\n";
      $doc ~= '|-------|-|----------|-------|' ~ "\n";
      for $r<methods>.keys.sort -> $rname {
        $doc ~= make-table-entry( $rname, $r<methods>{$rname});
      }
    }

    if $r<functions>:exists {
      $doc ~= "\n### Functions\n";
      $doc ~= '|Routine|G|Deprecated|Version|' ~ "\n";
      $doc ~= '|-------|-|----------|-------|' ~ "\n";
      for $r<functions>.keys.sort -> $rname {
        $doc ~= make-table-entry( $rname, $r<functions>{$rname});
      }
    }
  }
last
}

note "\n\n$doc";


sub make-table-entry ( Str $rname, Hash $rdata --> Str ) {
  my Str $doc = '';
  $doc ~= "| $rname |";
  $doc ~= $rdata<generated>
          ?? '![](./checklist-ok.png)'
          !! '![](./checklist-implement.png)';
#  $doc ~= $rdata<missing-type>:exists ?? "1" !! '|';
  $doc ~= $rdata<deprecated-version>:exists
          ?? '![](./checklist-deprecated.png) | ' ~ $rdata<deprecated-version>
          !! '|';
  $doc ~= $rdata<version>:exists ?? "$rdata<version> |" !! '|';
  $doc ~= "\n";

  $doc
}

#`{{
sub make-table-start ( --> Str ) {
  "<table>\n"
}

sub make-table-head ( *@header --> Str ) {
  my Str $h = "<tr>";
  for @header -> $i {
    $h ~= "<th> $i </th>";
  }

  $h ~= "</tr>\n";

  $h
}

sub make-table-entry ( *@header --> Str ) {
  my Str $h = "<tr>";
  for @header -> $i {
    $h ~= "<td> $i </td>";
  }

  $h ~= "</tr>\n";

  $h
}

sub make-table-end ( --> Str ) {
  "</table>\n\n"
}
}}



















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




