#!/usr/bin/env -S raku
use v6.d;

my Hash $versions = %(;
  :gtk3-lib<3.24.43>,
  :gio-lib<2.82.5>,
  :gtk4-lib<4.16.13>,
  :glib-lib<2.82.5>,
  :atk-lib<2.54.1>,
  :cairo-lib<1.18.2>,
  :gobject-lib<2.82.5>,
  :gdk3-lib<3.24.43>,
  :gsk4-lib<4.16.13>,
  :pango-lib<1.56.3>,
  :graphene-lib<1.10.6>,
  :gdk4-lib<4.16.13>,
);

sub MAIN ( Str $package ) {
  my Str $p = $package ~ '-lib';

  if ?$versions{$p} {
    say "Gnome version of $package library at time of generation is: $versions{$p}";
  }

  else {
    say "version of $package library not found.";
    say "The following libraries are available:";
    say [$versions.keys].map({$_ ~~ s/\-lib $//; $_}).join(', ');
  }
}
