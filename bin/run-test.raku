#!/usr/bin/env -S raku -Ilib

use v6.d;
use YAMLish;
use Gnome::SourceSkimTool::Prepare;

#-------------------------------------------------------------------------------
constant $API2MODS is export = '/home/marcel/Languages/Raku/Projects/gnome-source-skim-tool/gnome-api2';

my Hash $test-location = %(
#  :Atk<gnome-atk>,
  :Cairo<gnome-cairo>,
  :Gtk3<gnome-gtk3>, :Gdk3<gnome-gdk3>,
  :Gtk4<gnome-gtk4>, :Gsk4<gnome-gsk4>, :Gdk4<gnome-gdk4>,
  :GdkPixbuf<gnome-gdkpixbuf>, :Pango<gnome-pango>,
  :Gio<gnome-gio>,
  :Glib<gnome-glib>,
  :GObject<gnome-gobject>,
  :Graphene<gnome-graphene>,
);

#-------------------------------------------------------------------------------
# Test testfile found in standard locations */t
multi sub MAIN (
  Str $distro, Str $t, Bool :v($verbose) = False, Bool :t($timer) = True
) {
  my Str $test-file;
  $test-file = "$API2MODS/$test-location{$distro}/t/$t.rakutest";

  run-test( $distro, $test-file, :$verbose, :$timer);
}

#-------------------------------------------------------------------------------
# --y Load documentation example yaml file to see if it can be loaded correctly
multi sub MAIN ( Str $distro, Str $t, Bool :$y! ) {
  my Str $test-file;
  $test-file = "$API2MODS/$test-location{$distro}/doc/code-sections/$t.yaml";
  my Hash $h = load-yaml($test-file.IO.slurp);
  Gnome::SourceSkimTool::Prepare.display-hash(
    $h, :label<List of example data>
  );
}

#-------------------------------------------------------------------------------
# --c Compile module to see if there are problems when there is no test file
multi sub MAIN ( Str $distro, Str $t, Bool :$c! ) {
  my Str $test-file;
  $test-file = "$API2MODS/$test-location{$distro}/lib/Gnome/$distro/$t.rakumod";
  run-test( $distro, $test-file, :show-stats);
}

#-------------------------------------------------------------------------------
# --p Test all files in test directory with prove
multi sub MAIN (
  Str $distro, Bool :$p!, Bool :v($verbose) = False, Bool :t($timer) = True
) {
  my Str $test-dir = "$API2MODS/$test-location{$distro}/t";
  run-test( $distro, $test-dir, :$verbose, :$timer);
}

#-------------------------------------------------------------------------------
# Test program using a path only.
# --i is used to note relative paths (from $program-path) to include
# directories. It is a list separated by commas. E.g --i=../lib
multi sub MAIN ( Str $program-path, Bool :$d = False, Str :$i = '' ) {

  # Explicit test for Gtk4 only
  my Str $distro = 'Gtk4';
  set-paths($distro);

  my $path-dir = $program-path.IO.parent;
  if ?$i {
    my $env = %*ENV<RAKULIB>;

    my @ep = $i.split(',');
    for @ep -> $p {
      $env ~= ',' ~ ($path-dir ~ '/' ~ $p).IO.absolute;
    }

    %*ENV<RAKULIB> = $env;
  }

  # Programs are timed and stored in log files
  my $log = $program-path.IO.basename;
  $log ~~ s/ \. <-[.]>+ $/-log.md/;
  my Str $path = $program-path.IO.dirname ~ '/log/';
  mkdir $path, 0o750 unless $path.IO.e;
  $log = ($path ~ $log).IO.absolute;

  $log.IO.spurt(
    'Elapsed time | User time| Kernel time | Cpu % | Notes' ~
    "\n" ~ '|--|--|--|--|--|' ~ "\n"
  ) unless $log.IO.e;

  my Str $time-cmd = [~] '/usr/bin/time ',
      '-f "%E | %U | %S | %P" ', '-a -o ', $log;

  my Str $cmd;
  if $d {
    $cmd = "$time-cmd raku-debug '$program-path.IO().basename()'";
  }

  else {
    $cmd = "$time-cmd rakudo '$program-path.IO().basename()'";
  }

  chdir($path-dir);
  my Proc $p = shell $cmd;
}

#-------------------------------------------------------------------------------
sub run-test (
  Str $distro, Str $test-file is copy,
  Bool :$show-stats = False, Bool :$verbose = False, Bool :$timer = True
) {
  # Test for test directory. run all files with prove6
  if $test-location{$distro}:exists and $test-file.IO.d {
    set-paths($distro);
    my Str $test-dir = $test-file;
    my Str $prog = 'prove6';
    $prog ~= ' -v' if $verbose;
    $prog ~= ' --timer' if $timer;
    $test-file = 't/';
    chdir($test-dir.IO.parent);

    my Str $cmd = "$prog --ignore-exit '$test-file'";
    note "\nRun command '$cmd' in directory $*CWD.Str()";

    for dir($test-file).sort -> $f {
      next unless $f.Str ~~ m/ rakutest $/;

      try {
        my Proc $p = shell "$prog --ignore-exit --trap '$f'", :out, :err;
        for $p.out.lines -> $l {
          note $l unless $l ~~ m/^ 'Result: ' | 'All tests ' | 'Files=' /;
        }
        for $p.err.lines -> $l {
          note $l;
        }

        $p.out.close;
        $p.err.close;
      }
    }
  }

  elsif $test-location{$distro}:exists and $test-file.IO.r {
    set-paths($distro);
    my Str $test-dir = $test-file.IO.parent.Str;
    my Str $stsopt = '';
    my Str $prog;

    # If ending in a t-directory call program with prove
    if $test-dir ~~ m/ '/t' $/ {
      $prog = 'prove6';
      $prog ~= ' -v' if $verbose;
      $prog ~= ' --timer' if $timer;
      $test-file = 't/' ~ $test-file.IO().basename;
      chdir($test-dir.IO.parent);
    }

    else {
      $stsopt = '--stagestats' if $show-stats;
      $prog = "rakudo $stsopt";
      $test-file = $test-file.IO().basename;
      chdir($test-dir);
    }

    my Str $cmd = "$prog --ignore-exit --trap '$test-file'";
    note "\nRun command '$cmd' in directory $*CWD.Str()";
    my Proc $p = shell $cmd;   #, :out, :err;
#    note $p.out.slurp;#: :close;
#    note $p.err.slurp;#: :close;
  }
}

#-------------------------------------------------------------------------------
sub set-paths ( Str $distro ) {
  # Paths to find by Raku
  my @pth = (
    "$API2MODS/gnome-native/lib",
    "$API2MODS/gnome-glib/lib",
    "$API2MODS/gnome-gobject/lib",
    "$API2MODS/gnome-gio/lib",
    "$API2MODS/gnome-gdkpixbuf/lib",
    "$API2MODS/gnome-pango/lib",
    "$API2MODS/gnome-cairo/lib",
    "$API2MODS/gnome-atk/lib",
    "$API2MODS/gnome-gtk3/lib",
    "$API2MODS/gnome-gdk3/lib",
    "$API2MODS/gnome-graphene/lib",
    "$API2MODS/gnome-gtk4/lib",
    "$API2MODS/gnome-gdk4/lib",
    "$API2MODS/gnome-gsk4/lib",
  );
  %*ENV<RAKULIB> = @pth.join(',');

#`{{
  my Str $gtk-v = '';
  $gtk-v = '3' if $distro ~~ / 3 /;
  $gtk-v = '4' if $distro ~~ / 4 /;
  $gtk-v = 'PC' if $distro ~~ / Pango || Cairo || Pixbuf /;

  # Paths to find by Raku
  my @pth;
  given $gtk-v {
    when '3' {
      @pth = (
        "$API2MODS/gnome-native/lib",
        "$API2MODS/gnome-glib/lib",
        "$API2MODS/gnome-gobject/lib",
        "$API2MODS/gnome-gio/lib",
        "$API2MODS/gnome-gdkpixbuf/lib",
        "$API2MODS/gnome-pango/lib",
        "$API2MODS/gnome-cairo/lib",
        "$API2MODS/gnome-atk/lib",
        "$API2MODS/gnome-gtk3/lib",
        "$API2MODS/gnome-gdk3/lib",
        "$API2MODS/gnome-graphene/lib",
      );
    }

    when '4' {
      @pth = (
        "$API2MODS/gnome-native/lib",
        "$API2MODS/gnome-glib/lib",
        "$API2MODS/gnome-gobject/lib",
        "$API2MODS/gnome-gio/lib",
        "$API2MODS/gnome-gdkpixbuf/lib",
        "$API2MODS/gnome-pango/lib",
        "$API2MODS/gnome-cairo/lib",
        "$API2MODS/gnome-atk/lib",
        "$API2MODS/gnome-gtk4/lib",
        "$API2MODS/gnome-gdk4/lib",
        "$API2MODS/gnome-gsk4/lib",
        "$API2MODS/gnome-graphene/lib",
      );
    }

    when 'PC' {
      @pth = (
        "$API2MODS/gnome-native/lib",
        "$API2MODS/gnome-glib/lib",
        "$API2MODS/gnome-gobject/lib",
        "$API2MODS/gnome-gio/lib",
        "$API2MODS/gnome-gdkpixbuf/lib",
        "$API2MODS/gnome-pango/lib",
        "$API2MODS/gnome-cairo/lib",
        "$API2MODS/gnome-graphene/lib",
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
}}
}