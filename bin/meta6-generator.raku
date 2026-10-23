#!/usr/bin/env -S rakudo -Ilib

use v6.d;
use META6;

# TODO use IO::Notification::Recursive
# Also make Gui for it to combine this program and lib-content-lister.
#my @changed = ();
#my @created = ();
my Hash $repodir = %(
  :Gtk4</gnome-gtk4>,
  :Gdk4</gnome-gdk4>,
  :Gsk4</gnome-gsk4>,
  :Graphene</gnome-graphene>,

  :Glib</gnome-glib>,
  :Gio</gnome-gio>,
  :GObject</gnome-gobject>,

  :Pango</gnome-pango>,
  :GdkPixbuf</gnome-gdkpixbuf>,

  :N</gnome-native>,
);

sub MAIN ( Str $repo ) {
  my Str $api2 =
    $*HOME ~ '/Languages/Raku/Projects/gnome-source-skim-tool/gnome-api2';

  check-modules( $repo, $api2 ~ $repodir{$repo});

  #`{{
  check-modules( 'Gtk4',      "$api2/gnome-gtk4/lib");
  check-modules( 'Gdk4',      "$api2/gnome-gdk4/lib");
  check-modules( 'Gsk4',      "$api2/gnome-gsk4/lib");
  check-modules( 'Graphene',  "$api2/gnome-graphene/lib");

  check-modules( 'Glib',      "$api2/gnome-glib/lib");
  check-modules( 'Gio',       "$api2/gnome-gio/lib");
  check-modules( 'GObject',   "$api2/gnome-gobject/lib");

  check-modules( 'Pango',     "$api2/gnome-pango/lib");
  check-modules( 'GdkPixbuf', "$api2/gnome-gdkpixbuf/lib");

  check-modules( 'N',         "$api2/gnome-native/lib");

  check-modules( 'Cairo',     "$api2/gnome-cairo/lib");
  check-modules( "$api2/gnome-gtk3/lib");
  check-modules( "$api2/gnome-gdk3/lib");
  }}
}

#-------------------------------------------------------------------------------
sub check-modules ( Str $repo-name, Str $repo-dir ) {
  my Hash $*provides = %();
  my Instant $*meta-modified;
  my Bool $*update-version = False;

  my Str $base-path = $repo-dir;
#  $base-path ~~ s/ lib $//;

  my Str $dep-pfix = ':auth<github:MARTIMM>:api<2>';

  my Str $meta-file = "$base-path/META6.json";
  say "\nload meta file for $repo-name";
  my META6 $meta;
  if $meta-file.IO.e {
    $*meta-modified = $meta-file.IO.modified;
    $meta .= new(:file($meta-file));
  }

  else {
    $*meta-modified = Instant.from-posix(0);
    $meta .= new;
    given $meta {
      .<name> = "Gnome\::{$repo-name}";
      .<api> = '2';
      .<version> = v0.1.0;
      .<auth> = "cpan:MARTIMM";
      .<tags> = [ 'Gnome', $repo-name];
      .<author> = 'Marcel Timmerman';
      .<authors> = ['Marcel Timmerman'];
      .<raku-version> = '6.d';
      .<raku> = '6.d';
      .<meta-version> = 2;
      .<license> = 'Artistic-2.0';
      .<source-url> = "git://github.com/MARTIMM/gnome-{$repo-name.lc}-api2.git";

      if $repo-name ~~ 'Gtk4' {
        .<description> = "Modules for package Gnome\::Gtk4\:api<2>. The language binding to GNOME’s user interface toolkit version 4";
        .<depends> = [  "Gnome::Gdk4$dep-pfix", "Gnome::Gsk4$dep-pfix",
          "Gnome::Gio$dep-pfix", "Gnome::GObject$dep-pfix",
          "Gnome::Glib$dep-pfix", "Gnome::N$dep-pfix"
        ];
      }

      elsif $repo-name ~~ 'Gsk4' {
        .<description> = "Modules for package Gnome\::Gsk4\:api<2>.";
        .<depends> = [  "Gnome::Graphene$dep-pfix", "Gnome::Gio$dep-pfix",
          "Gnome::GObject$dep-pfix",
          "Gnome::Glib$dep-pfix", "Gnome::N$dep-pfix"
        ];
      }

      elsif $repo-name ~~ 'Graphene' {
        .<description> = "Modules for package Gnome\::Graphene\:api<2>.";
        .<depends> = [  "Gnome::Gio$dep-pfix", "Gnome::GObject$dep-pfix",
          "Gnome::Glib$dep-pfix", "Gnome::N$dep-pfix"
        ];
      }

      elsif $repo-name ~~ 'Gdk4' {
        .<description> = "Modules for package Gnome\::Gdk4\:api<2>.";
        .<depends> = [  "Gnome::Gio$dep-pfix", "Gnome::GObject$dep-pfix",
          "Gnome::Glib$dep-pfix", "Gnome::N$dep-pfix"
        ];
      }

#      elsif $repo-name ~~ 'Gtk3' { }

#      elsif $repo-name ~~ 'Gdk3' { }

      elsif $repo-name ~~ 'GdkPixbuf' {
        .<tags> = [ 'Gnome', $repo-name, 'image', 'animation', 'video'];
        .<description> = "Modules for Gnome::Pixbuf:api<2>. Graphical media loading and manipulation";
        .<depends> = [ "Gnome::GObject$dep-pfix", "Gnome::Glib$dep-pfix",
          "Gnome::Gio$dep-pfix", "Gnome::N$dep-pfix"
        ];
      }

#      elsif $repo-name ~~ 'Atk' { }
#`{{
        elsif $repo-name ~~ 'Cairo' {
        .<tags> = [ 'Gnome', $repo-name, 'drawing'];
        .<description> = "Modules for Gnome::Cairo:api<2>. Drawing on surfaces";
        .<depends> = [ "Gnome::GObject$dep-pfix", "Gnome::Glib$dep-pfix",
          "Gnome::N$dep-pfix"
        ];
      }
}}
      elsif $repo-name ~~ 'Pango' {
        .<tags> = [ 'Gnome', $repo-name, 'text-layout', 'text-rendering'];
        .<description> = "Modules for package Gnome\::Pango\:api<2>. The language binding to Pango: Internationalized text layout and rendering";
        .<depends> = [ "Gnome::GObject$dep-pfix", "Gnome::Glib$dep-pfix",
          "Gnome::N$dep-pfix"
        ];
      }

      elsif $repo-name ~~ 'Gio' {
        .<tags> = [ 'Gnome', $repo-name, 'io'];
        .<description> = "Modules for package Gnome\::Gio\:api<2>. The language binding to GNOME I/O libraries";
        .<depends> = <Gnome::GObject:api<2> Gnome::Glib:api<2> Gnome::N:api<2>>;
      }

      elsif $repo-name ~~ 'GObject' {
        .<description> = "Modules for package Gnome\::GObject\:api<2>. The language binding to GNOME's lower level object library";
        .<depends> = <Gnome::Glib:api<2> Gnome::N:api<2>>;
      }

      elsif $repo-name ~~ 'Glib' {
        .<description> = "Modules for package Gnome\::Glib\:api<2>. The language binding to GNOME's lowest level library";
        .<depends> = ['Gnome::N:api<2>'];
      }

      elsif $repo-name ~~ 'N' {
        .<description> = "Modules for package Gnome\::N\:api<2>. The support library for other Gnome::* libraries";
      }
    }
  }

  # Find modules first to populate the $*provides hash. When changed,
  # the $*update-version boolean is set.
  check-module-files("$repo-dir/lib");

  # Check if other files are changed. Don't need to check if META6
  # must be regenerated.
  check-other-files($base-path) unless $*update-version;

  if $*update-version {
    $meta<provides> = $*provides;

    my @parts = $meta<version>.parts;
    @parts[2]++;
    $meta<version> = Version.new(@parts.join('.'));
    "$base-path/META6.json".IO.spurt($meta.to-json(:sorted-keys));
#note "$?LINE save $base-path/META6.json";

    say "New meta file version $meta<version> for $repo-name saved";
  }
}

#-------------------------------------------------------------------------------
sub check-module-files ( Str $repo-dir ) {

  # Skip all hidden directories like .precomp
  return if $repo-dir ~~ m/^ '.' /;
  return unless $repo-dir.IO.d;

  for dir($repo-dir) -> $f {
    # Recurse into directory
    if $f ~~ :d {
      check-module-files($f.Str);
    }

    else {
      my Str $mpath = $f.Str;

      # Skip all but module files
      next unless $mpath ~~ m/ \. rakumod $/;

      if ($f.modified > $*meta-modified) {
        my Str $m = $f.Str;
        $m ~~ s/ .*? \/ gnome\-api2 \/ gnome\- .*? \/ //;
        $m ~~ s/\.rakumod//;
        $m ~~ s/ lib \/ Gnome \/ //;
        $m ~~ s/ \/ /::/;
        $m = "Gnome::$m";
        note "Module $m is modified";
        $*update-version = True;
      }
      my Str $mclass = $mpath;

      # Remove large part of path, then drop the extension, then make it a class
      $mclass ~~ s/^ .*? '/lib/' //;
      $mclass ~~ s/ \. rakumod $//;
      $mclass ~~ s:g/ '/' /::/;
#      $mclass ~= ':api<2>';

      # Remove large part of path.
      $mpath ~~ s/^ .*? '/lib' /lib/;

      # Add to the provides hash
      $*provides{$mclass} = $mpath;
    }
  }
}

#-------------------------------------------------------------------------------
sub check-other-files ( Str $repo-dir ) {

  # Skip all hidden directories like .precomp, .directory, .git, ., .., etc
  return if $repo-dir ~~ m/ [^ \. | \/ \.] /;
  return unless $repo-dir.IO.d;

  for dir($repo-dir) -> $f {
    # skip check of META6.json
    next if $f.Str ~~ m/ META6\.json $/;

    # skip check of git argive
    next if $f.Str ~~ m/ \.tgz $/;

    # Recurse into directory
    if $f ~~ :d {
      # Skip lib, we did that above
      next if $f.Str ~~ /^ lib $/;

      check-other-files($f.Str);
    }

    else {
      if ($f.modified > $*meta-modified) {
        note "File $f.IO.basename().Str() is modified";
        $*update-version = True;
      }
    }
  }
}

