#!/usr/bin/env -S raku

use v6.d;

# gdk3, gtk3 is stored in gtk3
# gdk4, gsk4, gtk4 is stored in gtk4
# gio, glib, gobject is stored in glib

use YAMLish;

my Hash $h = %();

for <atk cairo gtk3 gtk4 glib graphene pango> -> $package {
  my Proc $p = shell "dnf list $package | grep x86_64", :out, :err;
  for $p.out.lines -> $l {
    next if $l ~~ m/ Updating | Repositories /;
    my Str ( $, $v) = $l.split(' ');
    $v ~~ s/ '-' .* $//;
    note "$package $v";
    given $package {
      when m/ gtk3 / {
        $h<gtk3-lib> = $v;
        $h<gdk3-lib> = $v;
      }

      when m/ gtk4 / {
        $h<gtk4-lib> = $v;
        $h<gdk4-lib> = $v;
        $h<gsk4-lib> = $v;
      }

      when m/ glib / {
        $h<glib-lib> = $v;
        $h<gobject-lib> = $v;
        $h<gio-lib> = $v;
      }

      when m/ atk / {
        $h<atk-lib> = $v;
      }

      when m/ cairo / {
        $h<cairo-lib> = $v;
      }

      when m/ graphene / {
        $h<graphene-lib> = $v;
      }

      when m/ pango / {
        $h<pango-lib> = $v;
      }
    }
  }


  $p.out.close;
  $p.err.close;
}

save-yaml($h).say;
