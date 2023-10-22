#!/usr/bin/env rakudo

use v6.d;
use META6;



my Str $api2 = '/Languages/Raku/Projects/gnome-source-skim-tool/gnome-api2/';

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
  my META6 $meta .= new(:file($meta-file));
  if $meta-file.IO.e {
    $*meta-modified = $meta-file.IO.modified;
  }

  else {
    $*meta-modified = Instant.from-posix(0);
    given $meta {
      .<description> = "Modules for package Gnome\::{$name}\:api<2>";
      .<name> = "Gnome\::{$name}";
      .<api> = '2';
      .<version> = v0.1.0;
      .<auth> = "cpan:MARTIMM";
      .<tags> = [ 'Gnome', $name];
      .<author> = 'Marcel Timmerman';
      .<raku-version> = '6.d';
      .<raku> = '6.d';
      .<license> = 'Artistic-2.0';
      .<source-url> = "git://github.com/MARTIMM/gnome-{$name.lc}-api2.git";

      if $name ~~ 'Gtk4' {
         # Gnome::Gdk4 Gnome::Gsk4
        .<depends> = <
          Gnome::Gio Gnome::GObject Gnome::Glib Gnome::N
        >;
      }

#      elsif $name ~~ 'Gsk4' { }
#      elsif $name ~~ 'Gdk4' { }

#      elsif $name ~~ 'Gtk3' { }
#      elsif $name ~~ 'Gdk3' { }
#      elsif $name ~~ 'Pango' { }
#      elsif $name ~~ 'Cairo' { }

      elsif $name ~~ 'Gio' {
        .<depends> = <Gnome::GObject Gnome::Glib Gnome::N>;
      }

      elsif $name ~~ 'GObject' {
        .<depends> = <Gnome::Glib Gnome::N>;
      }

      elsif $name ~~ 'Glib' {
        .<depends> = <Gnome::N>;
      }

#      .<authors>:delete;
#      .<resources>:delete;
#      .<meta-version>:delete;
    }
  }

  check-module-files($cdir);

  $meta<provides> = $*provides;
  if $*update-version {
    my @parts = $meta<version>.parts;
    @parts[2]++;
    $meta<version> = Version.new(@parts.join('.'));
  }

  print $meta.to-json;
  exit
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

      my Str $mclass = $mpath;

      # Remove large part of path, then drop the extension, then make it a class
      $mclass ~~ s/^ .*? '/lib/' //;
      $mclass ~~ s/ \. rakumod $//;
      $mclass ~~ s:g/ '/' /::/;

      $mpath ~~ s/^ .*? '/lib' /lib/;
      $*update-version = ($*update-version or
                          ($mpath.IO.modified > $*meta-modified)
                         );
note "$mclass => $mpath";
      $*provides{$mclass} = $mpath;
    }
  }
}

