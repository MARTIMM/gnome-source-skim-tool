#!/usr/bin/env raku

use v6;

constant $API2MODS is export = 'gnome-api2';

# SkimSource Gdk3Pixbuf not interesting anymore
my Hash $test-location = %(
  :Atk<gnome-atk>,
  :Cairo<gnome-cairo>,
  :Gdk3<gnome-gdk3>, :Gdk4<gnome-gdk4>,
  :Gio<gnome-gio>, :Glib<gnome-glib>, :GObject<gnome-gobject>,
  :Gtk3<gnome-gtk3>, :Gsk4<gnome-gsk4>, :Gtk4<gnome-gtk4>,
  :Pango<gnome-pango>,
);

#-------------------------------------------------------------------------------
sub MAIN ( Str $l, Str $t ) {

  if $test-location{$l}:exists and
     "$API2MODS/$test-location{$l}/t/$t.rakutest".IO.r
  {
    # Paths to find by Raku
    my Str $gtk-v = ($l ~~ / '3' /) ?? '3' !! '4';
    my @pth = (
      "$API2MODS/gnome-native/lib",
      "$API2MODS/gnome-glib/lib",
      "$API2MODS/gnome-gobject/lib",
      "$API2MODS/gnome-gio/lib",
      "$API2MODS/gnome-pango/lib",
      "$API2MODS/gnome-cairo/lib",
      "$API2MODS/gnome-atk/lib",
      "$API2MODS/gnome-gtk$gtk-v/lib",
      "$API2MODS/gnome-gdk$gtk-v/lib",
    );
    @pth.push: "$API2MODS/gnome-gsk4/lib" if $gtk-v eq '4';
    %*ENV<RAKULIB> = @pth.join(',');

    shell "rakudo '$API2MODS/$test-location{$l}/t/$t.rakutest'";
#    shell "rakudo --ll-exception '$test-location{$l}/t/$t.rakutest'";
  }

  else {
    if $test-location{$l}:!exists {
      note "$l does not select a directory";
    }

    else {
      note "Test file '$test-location{$l}/t/$t.rakutest' is not found";
    }
  }
}