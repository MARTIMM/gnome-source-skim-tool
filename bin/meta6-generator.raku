#!/usr/bin/env rakudo

use v6.d;
use META6;



my Str $api2 = $*HOME ~ '/Languages/Raku/Projects/gnome-source-skim-tool/gnome-api2/';

check-modules( 'Gtk4', "$api2/gnome-gtk4/lib");

check-modules( 'Glib', "$api2/gnome-glib/lib");
check-modules( 'Gio', "$api2/gnome-gio/lib");
check-modules( 'GObject', "$api2/gnome-gobject/lib");

check-modules( 'N', "$api2/gnome-native/lib");

#`{{
check-modules( "$api2/gnome-cairo/lib");

check-modules( "$api2/gnome-gtk3/lib");
check-modules( "$api2/gnome-gdk3/lib");

check-modules( "$api2/gnome-gdk4/lib");
check-modules( "$api2/gnome-gsk4/lib");

check-modules( "$api2/gnome-atk/lib");
check-modules( "$api2/gnome-pango/lib");
}}

#-------------------------------------------------------------------------------
sub check-modules ( Str $name, Str $cdir ) {
  my Hash $*provides = %();
  my Instant $*meta-modified;
  my Bool $*update-version = False;

  my Str $base-path = $cdir;
  $base-path ~~ s/ lib $//;

  my Str $meta-file = "{$base-path}/META6.json";
  say "load meta file: $meta-file";
  my META6 $meta;
  if $meta-file.IO.e {
    $meta .= new(:file($meta-file));
    $*meta-modified = $meta-file.IO.modified;
  }

  else {
    $*meta-modified = Instant.from-posix(0);
    $meta .= new();
    given $meta {
      .<name> = "Gnome\::{$name}";
      .<api> = '2';
      .<version> = v0.1.0;
      .<auth> = "cpan:MARTIMM";
      .<tags> = [ 'Gnome', $name];
      .<author> = 'Marcel Timmerman';
#      .<authors> = ['Marcel Timmerman'];
      .<raku-version> = '6.d';
#      .<raku> = '6.d';
      .<meta-version> = 2;
      .<license> = 'Artistic-2.0';
      .<source-url> = "git://github.com/MARTIMM/gnome-{$name.lc}-api2.git";

      if $name ~~ 'Gtk4' {
         # Gnome::Gdk4:api<2> Gnome::Gsk4:api<2>
        .<description> = "Modules for package Gnome\::Gtk4\:api<2>. The language binding to GNOME’s user interface toolkit version 4";
        .<depends> = <
          Gnome::Gio:api<2> Gnome::GObject:api<2> Gnome::Glib Gnome::N:api<2>
        >;
      }

#      elsif $name ~~ 'Gsk4' { }
#      elsif $name ~~ 'Gdk4' { }

#      elsif $name ~~ 'Gtk3' { }
#      elsif $name ~~ 'Gdk3' { }
#      elsif $name ~~ 'Pango' { }
#      elsif $name ~~ 'Cairo' { }

      elsif $name ~~ 'Gio' {
        .<description> = "Modules for package Gnome\::Gio\:api<2>. The language binding to GNOME I/O libraries";
        .<depends> = <Gnome::GObject:api<2> Gnome::Glib Gnome::N:api<2>>;
      }

      elsif $name ~~ 'GObject' {
        .<description> = "Modules for package Gnome\::GObject\:api<2>. The language binding to GNOME's lower level object library";
        .<depends> = <Gnome::Glib:api<2> Gnome::N:api<2>>;
      }

      elsif $name ~~ 'Glib' {
        .<description> = "Modules for package Gnome\::Glib\:api<2>. The language binding to GNOME's lowest level library";
        .<depends> = ['Gnome::N:api<2>'];
      }

      elsif $name ~~ 'N' {
        .<description> = "Modules for package Gnome\::N\:api<2>. The support library for other Gnome::* libraries";
      }
    }
  }

  # Find the provides hash
  check-module-files($cdir);

  # Check if other files are changed. Don't need to check if META6
  # must be regenerated.
  check-other-files($base-path) unless $*update-version;

  if $*update-version {
    $meta<provides> = $*provides;

    my @parts = $meta<version>.parts;
    @parts[2]++;
    $meta<version> = Version.new(@parts.join('.'));
    "$base-path/META6.json".IO.spurt($meta.to-json);
  }
}

#-------------------------------------------------------------------------------
sub check-module-files ( Str $cdir ) {

  # Skip all hidden directories like .precomp
  return if $cdir ~~ m/^ '.' /;
  return unless $cdir.IO.d;

  for dir($cdir) -> $f {
    # Recurse into directory
    if $f ~~ :d {
      check-module-files($f.Str);
    }

    else {
      my Str $mpath = $f.Str;

      # Skip all but module files
      next unless $mpath ~~ m/ \. rakumod $/;

      $*update-version = ($*update-version or ($f.modified > $*meta-modified));

      my Str $mclass = $mpath;

      # Remove large part of path, then drop the extension, then make it a class
      $mclass ~~ s/^ .*? '/lib/' //;
      $mclass ~~ s/ \. rakumod $//;
      $mclass ~~ s:g/ '/' /::/;

      # Remove large part of path.
      $mpath ~~ s/^ .*? '/lib' /lib/;

      # Add to the provides hash
      $*provides{$mclass} = $mpath;
    }
  }
}

#-------------------------------------------------------------------------------
sub check-other-files ( Str $cdir ) {

  # We're done if update is needed
  return if $*update-version;

  # Skip all hidden directories like .precomp
  return if $cdir ~~ m/^ '.' /;
  return unless $cdir.IO.d;

  for dir($cdir) -> $f {
    # Recurse into directory
    if $f ~~ :d {
      # Skip lib, we did that above
      next if $f.Str ~~ / lib /;

      check-module-files($f.Str);
    }

    else {
      $*update-version = ($*update-version or ($f.modified > $*meta-modified));
    }
  }
}
