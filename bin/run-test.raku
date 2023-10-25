#!/usr/bin/env raku

use v6.d;

#constant $API1MODS is export = '..';
constant $API2MODS is export = 'gnome-api2';

my Hash $test-location = %(
#  :Atk<gnome-atk>,
#  :Cairo<gnome-cairo>,
#  :Gtk3<gnome-gtk3>, :Gdk3<gnome-gdk3>,
  :Gtk4<gnome-gtk4>,
#  :Gsk4<gnome-gsk4>, :Gdk4<gnome-gdk4>,
  :Pango<gnome-pango>,
  :Gio<gnome-gio>,
  :Glib<gnome-glib>,
  :GObject<gnome-gobject>,
);

#-------------------------------------------------------------------------------
multi sub MAIN ( Str $l, Str $t, Bool :$c = False ) {

  my Str $test-file;
  # --c compile module to see if there are problems when there is no test file
  if $c {
    $test-file = "$API2MODS/$test-location{$l}/lib/Gnome/$l/$t.rakumod";
  }

  else {
    $test-file = "$API2MODS/$test-location{$l}/t/$t.rakutest";
  }

  if $test-location{$l}:exists and $test-file.IO.r {
    my Str $gtk-v = '';
    $gtk-v = '3' if $l ~~ / 3 /;
    $gtk-v = '4' if $l ~~ / 4 /;
    $gtk-v = 'PC' if $l ~~ / Pango || Cairo /;

    # Paths to find by Raku
    my @pth;
    given $gtk-v {
      when '3' {
        @pth = (
          "$API2MODS/gnome-native/lib",
          "$API2MODS/gnome-glib/lib",
          "$API2MODS/gnome-gobject/lib",
          "$API2MODS/gnome-gio/lib",
          "$API2MODS/gnome-pango/lib",
          "$API2MODS/gnome-cairo/lib",
          "$API2MODS/gnome-atk/lib",
          "$API2MODS/gnome-gtk3/lib",
          "$API2MODS/gnome-gdk3/lib",
        );
      }

      when '4' {
        @pth = (
          "$API2MODS/gnome-native/lib",
          "$API2MODS/gnome-glib/lib",
          "$API2MODS/gnome-gobject/lib",
          "$API2MODS/gnome-gio/lib",
          "$API2MODS/gnome-pango/lib",
          "$API2MODS/gnome-cairo/lib",
          "$API2MODS/gnome-atk/lib",
          "$API2MODS/gnome-gtk4/lib",
          "$API2MODS/gnome-gdk4/lib",
          "$API2MODS/gnome-gsk4/lib",
        );
      }

      when 'PC' {
        @pth = (
          "$API2MODS/gnome-native/lib",
          "$API2MODS/gnome-glib/lib",
          "$API2MODS/gnome-gobject/lib",
          "$API2MODS/gnome-gio/lib",
          "$API2MODS/gnome-pango/lib",
          "$API2MODS/gnome-cairo/lib",
        );
      }

      default {
        @pth = (
          "$API2MODS/gnome-native/lib",
          "$API2MODS/gnome-glib/lib",
          "$API2MODS/gnome-gobject/lib",
          "$API2MODS/gnome-gio/lib",
        );
      }
    }

    %*ENV<RAKULIB> = @pth.join(',');

     my Str $cmd = "rakudo '$test-file'";
     my Proc $p = shell $cmd;#, :out, :err;
#    note $p.out.slurp;#: :close;
#    note $p.err.slurp;#: :close;
  }

  else {
    if $test-location{$l}:!exists {
      note "$l does not select a directory";
    }

    else {
      note "Test file '$test-file' is not found";
    }
  }
}

#-------------------------------------------------------------------------------
multi sub MAIN ( Str $xt, Bool :$d = False, Bool :$api1 = False ) {

  # xt holds path name to either Ctk3 or Gtk4 in the xt dir
  my Str $gtk-v = ($xt ~~ / '3' /) ?? '3' !! '4';

  # Paths to find by Raku
  my @pth = ();
  @pth = (
    "$API2MODS/gnome-native/lib",
    "$API2MODS/gnome-glib/lib",
    "$API2MODS/gnome-gobject/lib",
    "$API2MODS/gnome-gio/lib",
#    "$API2MODS/gnome-pango/lib",
#    "$API2MODS/gnome-cairo/lib",
#    "$API2MODS/gnome-atk/lib",
    "$API2MODS/gnome-gtk$gtk-v/lib",
    "$API2MODS/gnome-gdk$gtk-v/lib",
  ) unless $api1;

  %*ENV<RAKULIB> = @pth.join(',');

  @pth.push: "$API2MODS/gnome-gsk4/lib" if $gtk-v eq '4';
  %*ENV<RAKULIB> = @pth.join(',');

  my $log = $xt.IO.basename;
  $log ~~ s/ \. <-[.]>+ $/-log.md/;
  my Str $path = $xt.IO.dirname ~ '/log/';
  mkdir $path, 0o750 unless $path.IO.e;
  $log = $path ~ $log;
#note 'log: ', $log;

  $log.IO.spurt(
    'Elapsed time | User time| Kernel time | Cpu % | Notes' ~
    "\n" ~ '|--|--|--|--|--|' ~ "\n"
  ) unless $log.IO.e;

  my Str $time-cmd = [~] '/usr/bin/time ',
      '-f "%E | %U | %S | %P" ', '-a -o ', $log;

  my Str $cmd;
  if $d {
    $cmd = "$time-cmd raku-debug '$xt'";
  }

  else {
    $cmd = "$time-cmd rakudo '$xt'";
  }

  my Proc $p = shell $cmd;
}