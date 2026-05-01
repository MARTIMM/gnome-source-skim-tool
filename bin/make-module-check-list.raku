#!/usr/bin/env -S rakudo -Ilib

=begin comment

Create a markdown file in the ./doc/checklists/<package> directory using the yaml source in ./data/SkimToolData/<package>.

Before use, run skim-gir.raku to update the yaml file with test results and some other handwritten additions. Then run this program to generate the markdown file. Copy the markdown file in the github pages environment in MARTIMM.github.io/content-docs/api2/check-lists

=end comment

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
  my $*release;

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

    $*release = $data<version>;

    for $data.keys.sort: { $^a.lc leg $^b.lc } -> $obj-name {
      # Skip non module keys
      next if $obj-name ~~ any(<namespace-name symbol-prefix version>);

      # Get module data
      my Hash $obj-data = $data{$obj-name};

      # Gnome files: R- = record/union, I- = interface, C- = class
      # Rakudo files: N- = record/union, R- = interface, no prefix for class
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

    /* Keep most tables first 2 columns the same. Less disturbing display */
    td:nth-child(1) {
      width: 35%;
    }

    td:nth-child(2) {
      width: 11%;
    }

    /* Legend table must have different column sizes */
    .legend td:nth-child(1) {
      width: 1%;
    }

    .legend td:nth-child(2) {
      width: 99%;
    }
    </style>
    EOSTYLE
}

#-------------------------------------------------------------------------------
sub set-legend ( --> Str ) {
  Q:qq:to/EOLEGEND/;

    ## Legend for the tables

    <table class="legend"><tr><th>Symbol</th><th>Meaning</th></tr>

    <tr><td>{md-image( 'checklist-ok', :img)}</td>
    <td>Code and documentation is generated</td></tr>

    <tr><td>{md-image( 'checklist-implement', :img)}</td>
    <td>Must be written</td></tr>

    <tr><td>{md-image( 'checklist-deprecated', :img)}</td>
    <td>Removed in next Gnome library release</td></tr>

    <tr><td>{md-image( 'checklist-missing', :img)}</td>
    <td>Not generated, there are missing types</td></tr>

    <tr><td>{md-image( 'checklist-no-implement', :img)}</td>
    <td>Is removed or will not be implemented</td></tr>

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

    Checklist for module $obj-data<class-name> to show the progress of deveopment or whether it is deprecated. Most of the modules are generated but documentation needs to be checked for typos and mistakes. Also examples may be added. Not much will be done for deprecated modules. You might be interested in the [GnomeTools distribution](/content-docs/GnomeTools/index.html) where some of the deprecated modules are rewritten.

    Furthermore there is a list of the current versions of [Gnome libraries and Raku distibutions](/content-docs/api2/check-lists/lib-versions) installed on my machine versus the Raku distribution versions.

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

  $doc ~= "\n<br/><strong>Note:</strong> $checks<note>\n" if ?$checks<note>;

  $doc
}

#-------------------------------------------------------------------------------
sub set-routine-info ( Hash $obj-data, Str $obj-name --> Str ) {
#      my Hash $obj-data = $data{$obj-name};
  my Str $doc = '';
  my Hash $r = $obj-data<routines>;
  if $r<constructors>:exists {
    my Str $notes = '';
    $doc ~= "\n### Constructors\n\n";
    $doc ~= '|Routine|State¹|Version²|Deprecated³|' ~ "\n";
    $doc ~= '|-------|-|----------|-------|' ~ "\n";
    for $r<constructors>.keys.sort -> $rname {
      $doc ~= make-table-entry( $rname, $r<constructors>{$rname});
      $notes ~= [~] 'constructor **', $rname, '**: ',
                    $r<constructors>{$rname}<note>, "\n"
             if ?$r<constructors>{$rname}<note>;
    }

    $doc ~= "\n<br/>$notes\n";
  }

  if $r<methods>:exists {
    my Str $notes = '';
    $doc ~= "\n### Methods\n\n";
    $doc ~= '|Routine|State¹|Version²|Deprecated³|' ~ "\n";
    $doc ~= '|-------|-|----------|-------|' ~ "\n";
    for $r<methods>.keys.sort -> $rname {
      $doc ~= make-table-entry( $rname, $r<methods>{$rname});
      $notes ~= [~] 'method **', $rname, '**: ', $r<methods>{$rname}<note>, "\n"
        if ?$r<methods>{$rname}<note>;
    }

    $doc ~= "\n<br/>$notes\n";
  }

  if $r<functions>:exists {
    my Str $notes = '';
    $doc ~= "\n### Functions\n\n";
    $doc ~= '|Routine|State¹|Version²|Deprecated³|' ~ "\n";
    $doc ~= '|-------|-|----------|-------|' ~ "\n";
    for $r<functions>.keys.sort -> $rname {
      $doc ~= make-table-entry( $rname, $r<functions>{$rname});
      $notes ~= [~] 'function **', $rname, '**: ', $r<functions>{$rname}<note>, "\n"
        if ?$r<functions>{$rname}<note>;
    }

    $doc ~= "\n<br/>$notes\n";
  }

#note "$?LINE $obj-data.gist()";

  $doc ~= "\n1. Status, generated, missing values, deprecated, etc\n";
  $doc ~= "2. Version of introduction, otherwise it is the release version ($*release)\n";
  $doc ~= "3. Version of deprecation and is removed in next release\n";

  $doc
}

#-------------------------------------------------------------------------------
#NOTE: the $asset-path is a path on the documentation site of MARTIMM.github.io
sub md-image ( Str $name, Bool :$img = False --> Str ) {
  my $asset-path = '/content-docs/asset_files/images/';
  my Str $t;

  if $img {
    $t = [~] '<img src="', $asset-path, $name, '.png" />';
  }

  else {
    $t = [~] '![](', $asset-path, $name, '.png)';
  }

  $t
}

#-------------------------------------------------------------------------------
sub make-table-entry ( Str $rname, Hash $rdata --> Str ) {
  my Str $doc = '';
  $doc ~= "| $rname |";
  
  # If field 'no-implement' exists, no 'generated' field is set. In that case
  # 'no-implement' is always 1.
  if ?$rdata<no-implement> {
    $doc ~= md-image('checklist-no-implement');
  }

  else {
    $doc ~= $rdata<generated>
          ?? md-image('checklist-ok') !! md-image('checklist-implement');
  }

  $doc ~= $rdata<missing-type>:exists ?? md-image('checklist-missing') !! '';
  $doc ~= $rdata<deprecated-version>:exists
          ?? md-image('checklist-deprecated') !! '';

  $doc ~= $rdata<version>:exists ?? "| $rdata<version> |" !! '||';
  $doc ~= $rdata<deprecated-version>:exists
          ?? "$rdata<deprecated-version> |" !! '|';
  $doc ~= "\n";

  $doc
}

