#!/usr/bin/env -S raku
use v6.d;

my Hash $versions = %();

$versions<gtk3><sys> = '3.24.43';
$versions<gtk3><name> = 'Gnome::Gtk3';
$versions<gdk4><sys> = '4.16.13';
$versions<gdk4><raku> = '0.1.22';
$versions<gdk4><name> = 'Gnome::Gdk4';
$versions<gio><sys> = '2.82.5';
$versions<gio><raku> = '0.1.27';
$versions<gio><name> = 'Gnome::Gio';
$versions<gobject><sys> = '2.82.5';
$versions<gobject><raku> = '0.1.15';
$versions<gobject><name> = 'Gnome::GObject';
$versions<gdkpixbuf><sys> = '2.42.12';
$versions<gdkpixbuf><raku> = '0.1.5';
$versions<gdkpixbuf><name> = 'Gnome::GdkPixbuf';
$versions<n><raku> = '0.1.51';
$versions<n><name> = 'Gnome::N';
$versions<glib><sys> = '2.82.5';
$versions<glib><raku> = '0.1.14';
$versions<glib><name> = 'Gnome::Glib';
$versions<pango><sys> = '1.56.3';
$versions<pango><raku> = '0.1.14';
$versions<pango><name> = 'Gnome::Pango';
$versions<gtk4><sys> = '4.16.13';
$versions<gtk4><raku> = '0.2.6';
$versions<gtk4><name> = 'Gnome::Gtk4';
$versions<gsk4><sys> = '4.16.13';
$versions<gsk4><raku> = '0.2.1';
$versions<gsk4><name> = 'Gnome::Gsk4';
$versions<graphene><sys> = '1.10.6';
$versions<graphene><raku> = '0.1.13';
$versions<graphene><name> = 'Gnome::Graphene';
$versions<gdk3><sys> = '3.24.43';
$versions<gdk3><name> = 'Gnome::Gdk3';
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

