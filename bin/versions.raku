#!/usr/bin/env -S raku

use v6.d;
use META6;

# gdk3, gtk3 is stored in gtk3
# gdk4, gsk4, gtk4 is stored in gtk4
# gio, glib, gobject is stored in glib

my Hash $h = %();

my Hash $repolib = %(
  :gtk4</gnome-gtk4>,
  :gdk4</gnome-gdk4>,
  :gsk4</gnome-gsk4>,
  :graphene</gnome-graphene>,

  :gtk3</gnome-gtk3>,
  :gdk3</gnome-gdk3>,

  :glib</gnome-glib>,
  :gio</gnome-gio>,
  :gobject</gnome-gobject>,

  :pango</gnome-pango>,
  :gdkpixbuf</gnome-gdkpixbuf>,

  :n</gnome-native>,
);

my META6 $meta;
my Str $api2root =
   $*HOME ~ '/Languages/Raku/Projects/gnome-source-skim-tool/gnome-api2/';
for $repolib.keys -> $repo {
  my Str $meta-file = "$api2root/{$repolib{$repo}}/META6.json";
  if $meta-file.IO.e {
#    say "\nload meta file for $repo";
    $meta .= new(:file($meta-file));
    $h{$repo}<raku> = $meta<version>;
  }
}


for <gtk3 gtk4 gdk-pixbuf2 glib2 graphene pango> -> $package {
  # Get the library version using Fedora dnf package manager
  my Proc $p = shell "dnf list $package | grep x86_64", :out, :err;
  for $p.out.lines -> $l {
    next if $l ~~ m/ Updating | Repositories /;
    my Str ( $, $v) = $l.split(' ');
    $v ~~ s/ '-' .* $//;
#    note "$package $v";
    given $package {
      when m/ gtk3 / {
        $h<gtk3><sys> = $v;
        $h<gtk3><name> = 'Gnome::Gtk3';
        $h<gdk3><sys> = $v;
        $h<gdk3><name> = 'Gnome::Gdk3';
      }

      when m/ gtk4 / {
        $h<gtk4><sys> = $v;
        $h<gtk4><name> = 'Gnome::Gtk4';
        $h<gdk4><sys> = $v;
        $h<gdk4><name> = 'Gnome::Gdk4';
        $h<gsk4><sys> = $v;
        $h<gsk4><name> = 'Gnome::Gsk4';
      }

      when m/ gdk\-pixbuf2 / {
        $h<gdkpixbuf><sys> = $v;
        $h<gdkpixbuf><name> = 'Gnome::GdkPixbuf';
      }

      when m/ graphene / {
        $h<graphene><sys> = $v;
        $h<graphene><name> = 'Gnome::Graphene';
      }

      when m/ pango / {
        $h<pango><sys> = $v;
        $h<pango><name> = 'Gnome::Pango';
      }

      when m/ glib / {
        $h<glib><sys> = $v;
        $h<glib><name> = 'Gnome::Glib';
        $h<gobject><sys> = $v;
        $h<gobject><name> = 'Gnome::GObject';
        $h<gio><sys> = $v;
        $h<gio><name> = 'Gnome::Gio';
      }
#`{{
      when m/ atk / {
        $h<sys><sys> = $v;
      }

      when m/ cairo / {
        $h<sys><sys> = $v;
      }
}}
    }
  }

  $h<n><name> = 'Gnome::N';

  $p.out.close;
  $p.err.close;
}

#say save-yaml($h);


my Str $code = Q:q:to/EORAKU/;
  #!/usr/bin/env -S raku
  use v6.d;

  my Hash $versions = %();

  EORAKU

  for $h.keys -> $repo-name {
    $code ~= [~] '$versions<', $repo-name, '><sys> = \'', $h{$repo-name}<sys>,
      "';\n" if $h{$repo-name}<sys>.defined;
    $code ~= [~] '$versions<', $repo-name, '><raku> = \'', $h{$repo-name}<raku>,
      "';\n" if $h{$repo-name}<raku>.defined;
    $code ~= [~] '$versions<', $repo-name, '><name> = \'', $h{$repo-name}<name>,
      "';\n" if $h{$repo-name}<name>.defined;
  }

$code ~= Q:q:to/EORAKU/;
  sub MAIN ( Str $p?, Bool :$all = False ) {
    if $all {
      finit($versions);
    }

    elsif ?$p {
      if ?$versions{$p}<raku> {
        if $versions{$p}<sys>:exists {
          say "Gnome system library version of $p at time of generation is: $versions{$p}<sys>";
        }

        else {
          say "Raku module $versions{$p}<name> does not need a system library";
        }

        say "Raku version of $versions{$p}<name> library at time of generation is: $versions{$p}<raku>";
      }

      elsif ?$versions{$p}<sys> {
        say "Gnome version of $p library at time of generation is: $versions{$p}<sys>";
        say "Raku library not (yet) supported";
      }

      else {
        say "System library and raku package are not found. The following library keys are available:";
        my @l = gather
          for $versions.kv -> $k, $n {
            if $versions{$k}<name>:exists {
              take $k;
            }
          };

        say @l.join(', ');
      }
    }

    else {
      note "Usage:\n  version-of.raku --all\n  version-of.raku <p>";
    }
  }

  sub finit ( $info ) {
    my Int $indent-level = 0;
    say '';

    fhelper( $indent-level, $info);
  }

  sub fhelper ( Int $indent-level is copy, Hash $info ) {
    for $info.keys.sort -> $k {
      if $info{$k} ~~ Hash {
        say '  ' x $indent-level, $k, ':';
        $indent-level++;
        fhelper( $indent-level, $info{$k});
        $indent-level--;
      }

      elsif $info{$k} ~~ Array {
        say '  ' x $indent-level, $k, ': [ ', $info{$k}.join(', '), ']';
      }

      else {
        say '  ' x $indent-level, $k, ': ', $info{$k}.gist;
      }
    }
  }

  EORAKU

#note $code;

say "write 'bin/version-of.raku'";
'bin/version-of.raku'.IO.spurt($code);

say "write 'gnome-api2/gnome-gtk4/bin/version-of.raku'";
'gnome-api2/gnome-gtk4/bin/version-of.raku'.IO.spurt($code);

say "write 'gnome-api2/gnome-gtk3/bin/version-of.raku'";
'gnome-api2/gnome-gtk3/bin/version-of.raku'.IO.spurt($code);
