#!/usr/bin/env -S raku

use v6.d;

# gdk3, gtk3 is stored in gtk3
# gdk4, gsk4, gtk4 is stored in gtk4
# gio, glib, gobject is stored in glib

#use YAMLish;

my Hash $h = %();

for <atk cairo gtk3 gtk4 glib2 graphene pango> -> $package {
  my Proc $p = shell "dnf list $package | grep x86_64", :out, :err;
  for $p.out.lines -> $l {
    next if $l ~~ m/ Updating | Repositories /;
    my Str ( $, $v) = $l.split(' ');
    $v ~~ s/ '-' .* $//;
#    note "$package $v";
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

#say save-yaml($h);


my Str $code = Q:q:to/EORAKU/;
  #!/usr/bin/env -S raku
  use v6.d;

  my Hash $versions = %(;
  EORAKU

  for $h.kv -> $lib-name, $version {
    $code ~= [~] '  :', $lib-name, '<', $version, ">,\n";
  }

$code ~= Q:q:to/EORAKU/;
  );

  sub MAIN ( Str $package ) {
    my Str $p = $package ~ '-lib';

    if ?$versions{$p} {
      say "Gnome version of $package library at time of generation is: $versions{$p}";
    }

    else {
      say "version of $package library not found. The following libraries are available: ", $versions.keys.join(', ');
    }
  }
  EORAKU

say $code;
'bin/version-of.raku'.IO.spurt($code);