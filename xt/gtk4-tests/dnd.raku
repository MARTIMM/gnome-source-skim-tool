#!/usr/bin/env -S rakudo -Ilib
# -Ignome-api2/gnome-gtk4/lib 

use v6.d;
#use lib 'lib';
#use lib './gnome-api2/gnome-gtk4/lib';
#use lib './gnome-api2/gnome-native/lib';
#use lib './gnome-api2/gnome-gdk4/lib';

use NativeCall;

use Gnome::Glib::N-MainLoop:api<2>;
use Gnome::Glib::N-Bytes:api<2>;
use Gnome::Glib::N-Error:api<2>;
use Gnome::Glib::T-error:api<2>;

use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::X:api<2>;
#Gnome::N::debug(:on);

#use Gnome::Gtk4::DropTargetAsync:api<2>;
use Gnome::Gtk4::DropTarget:api<2>;
use Gnome::Gtk4::DragSource:api<2>;
use Gnome::Gtk4::Window:api<2>;
use Gnome::Gtk4::Picture:api<2>;
use Gnome::Gtk4::Grid:api<2>;
use Gnome::Gtk4::T-enums:api<2>;

use Gnome::Gdk4::Drag:api<2>;
use Gnome::Gdk4::Drop:api<2>;
use Gnome::Gdk4::ContentProvider:api<2>;
use Gnome::Gdk4::N-ContentFormats:api<2>;
use Gnome::Gdk4::T-enums:api<2>;

use Gnome::Gio::File:api<2>;
#use Gnome::Gio::FileIcon:api<2>;

use Gnome::GObject::T-type:api<2>;
use Gnome::GObject::N-Value:api<2>;
use Gnome::GObject::T-value:api<2>;

use Gnome::Gio::Task:api<2>;

#`{{
  See also:
  https://docs.gtk.org/gtk4/drag-and-drop.html
  https://docs.gtk.org/gdk4/struct.ContentFormats.html
  https://ssalewski.de/gtkprogramming.html#_drag_and_drop_dnd
}}

my Gnome::Gio::File $f .= new-for-path('abc.txt');
note "$?LINE File gtype = $f.get-class-gtype()";

#-------------------------------------------------------------------------------
constant DATA_PATH =
  $*HOME ~ '/Languages/Raku/Projects/gnome-source-skim-tool/xt/Other/data/';

my Gnome::Glib::N-MainLoop $main-loop .= new-mainloop( N-Object, True);

class Helper {
  method exit ( ) {
    $main-loop.quit;
  }

  method prepare (
    Rat() $x, Rat() $y,
    Gnome::Gtk4::DragSource() :_native-object($ds),
    Gnome::Gtk4::Picture :$pic, Str :$color
    --> N-Object
  ) {
    note "$?LINE prepare: $x, $y, $pic.gist()";
#    my Gnome::Gdk4::ContentProvider $t1 .= new-typed($pic.get-class-gtype);
#    my Gnome::Gdk4::ContentProvider $u .= new-union(
#      CArray[N-Object].new($t1.get-native-object-no-reffing,), 1
#    );

#    $u.get-native-object
    my Blob $sa = $color.encode;
    my Gnome::Glib::N-Bytes $bytes .= new-bytes( $sa, $sa.elems);
    my Gnome::Gdk4::ContentProvider $cp .= new-for-bytes(
      "text/plain", $bytes
    );

    $cp.get-native-object-no-reffing
  }

  method drag-begin (
    Gnome::Gdk4::Drag() $drag,
    Gnome::Gtk4::DragSource() :_native-object($ds),
    Gnome::Gtk4::Picture :$pic,
  ) {
    note "$?LINE drag-begin: $drag, $pic.gist()";
    $ds.set-icon( $pic.get-paintable, -20, 20);
  }

  method accept (
    Gnome::Gdk4::Drop() $drop, 
    Gnome::Gtk4::DropTarget() :_native-object($dt),
    --> Bool
  ) {
    my Bool $accept-ok = False;
#    $drop.set-gtypes( CArray[GType].new($f.get-class-gtype), 1);

    my Gnome::Gdk4::N-ContentFormats() $formats = $drop.get-formats;
    my $size = CArray[gsize].new(0);
    my Array $mime-types = $formats.get-mime-types($size);
note "$?LINE $size, $mime-types.elems()";
    loop ( my Int $i = 0; $i < $size[0]; $i++ ) {
      note "Mime type: ", $mime-types[$i];
      $accept-ok = True if $mime-types[$i] ~~ m/ text /;
    }

Gnome::N::debug(:on);
    note "accept: $accept-ok";
    $accept-ok
  }

  method drop (
    N-Value() $n-value, Rat() $x, Rat() $y,
    Gnome::Gtk4::DropTarget() :_native-object($dt),
#    Gnome::Gtk4::Picture :$pic
    --> Bool
  ) {
    note "\n$?LINE drop: $x, $y";

#Gnome::N::debug(:on);
#    my Bool $drop-ok = False;

note $n-value.gist();
    my Gnome::GObject::N-Value $value .= new(:native-object($n-value));
note $value.get-string;;

    my Gnome::Gdk4::Drop() $drop = $dt.get-current-drop;
    my Gnome::Gdk4::Drag() $drag = $drop.get-drag;
    if $drag.is-valid {
      note 'inside job';
    }

    else {
      note 'package from abroad';
    }

#    my Gnome::Gdk4::ContentFormats() $cf = $dt.get-formats;
#    note "$?LINE ", 

    my Gnome::Gdk4::N-ContentFormats() $formats = $drop.get-formats;
    my $size = CArray[gsize].new(0);
    my Array $mime-types = $formats.get-mime-types($size);
note "$?LINE $size, $mime-types.elems()";
    loop ( my Int $i = 0; $i < $size[0]; $i++ ) {
      note "Mime type: ", $mime-types[$i];
    }

#`{{
    sub get-data (
      Gnome::Gdk4::Drop() $source, Gnome::Gio::Task() $result, gpointer $
    ) {
note "$?LINE $source.gist()";
#note "a: ", $source.get-actions.base(2);
      my $e = CArray[N-Error].new(N-Error);
      my $n-v = CArray[N-Value].new(N-Value);
      my Bool $is-ok = $result.propagate-value( $n-v, $e);
note "Error: $e[0].message()" unless $is-ok;
      my Gnome::GObject::N-Value $v .= new(:native-object($n-v[0]));

note "ok: $is-ok, $n-v.gist(), $e.gist()";
note "v: $v.gist()";
note "v: $v.get-string()";
    }

note $?LINE;
#    my $a = CArray[Str].new(| @$mime-types, Str);
#note "$?LINE $a[0], ", $a.WHAT;

    $drop.read-async( [|@$mime-types], 1, N-Object, &get-data, gpointer);
note $?LINE;

    if $formats.contain-mime-type('text/plain') {
      note "text ";
      $drop-ok = True;
    }

    # Select one of the set flags from get-actions()
    $drop.finish(GDK_ACTION_COPY);
#Gnome::N::debug(:off);
}}

    True; #$drop-ok;
  }
}

my Helper $helper .= new;

#-------------------------------------------------------------------------------
my Gnome::Gtk4::Picture $red = set-drag-source('red-on-256.png');
my Gnome::Gtk4::Picture $amber = set-drag-source('amber-on-256.png');
my Gnome::Gtk4::Picture $green = set-drag-source('green-on-256.png');

my Gnome::Gtk4::Picture $bullseye = set-drag-target('bullseye.jpg');

with my Gnome::Gtk4::Grid $grid .= new-grid {
  .attach( $red,      0, 0, 1, 1);
  .attach( $green,    1, 0, 1, 1);
  .attach( $amber,    2, 0, 1, 1);
  .attach( $bullseye, 0, 1, 3, 3);
}

with my Gnome::Gtk4::Window $window .= new-window {
  .set-title('Drag and Drop test');
  .set-child($grid);

  .register-signal( $helper, 'exit', 'close-request');
  .show;
}

#Gnome::N::debug(:on);

$main-loop.run;
say 'done it';

#-------------------------------------------------------------------------------
sub set-drag-source ( Str $pic-file --> Gnome::Gtk4::Picture ) {
  my Gnome::Gtk4::Picture $pic;
  $pic .= new-for-filename(DATA_PATH ~ $pic-file);
  with my Gnome::Gtk4::DragSource $source .= new-dragsource {
    .register-signal( $helper, 'prepare', 'prepare', :$pic, :color($pic-file));
    .register-signal( $helper, 'drag-begin', 'drag-begin', :$pic);
  }

  $pic.add-controller($source);
  $source.clear-object;

  $pic
}

#-------------------------------------------------------------------------------
sub set-drag-target ( Str $pic-file --> Gnome::Gtk4::Picture ) {

#  my Gnome::Gdk4::N-ContentFormats $formats .= new-contentformats(
#    CArray[Str].new(<text/plain>,), 1
#  );

  my Gnome::Gtk4::Picture $pic;
  my Gnome::Gtk4::DropTarget $target;

  with $target .= new-droptarget(
    G_TYPE_STRING, GDK_ACTION_COPY +| GDK_ACTION_MOVE
  ) {
note "Preload: ", .get-preload;

#    my Gnome::Gio::File $f .= new-for-path('abc.txt');
note "$?LINE File gtype = $f.get-class-gtype()";
    .set-gtypes( CArray[GType].new($f.get-class-gtype), 1);

    my Gnome::Gdk4::N-ContentFormats() $formats = .get-formats;
    my $size = CArray[gsize].new(0);
    my Array $mime-types = $formats.get-mime-types($size);
note "$?LINE $size, $mime-types.elems()";
    loop ( my Int $i = 0; $i < $size[0]; $i++ ) {

      note "Mime type: ", $mime-types[$i];
    }

    .set-preload(True);
    .set-propagation-limit(GTK_LIMIT_SAME_NATIVE);
    .register-signal( $helper, 'drop', 'drop');
    .register-signal( $helper, 'accept', 'accept');

    $pic .= new-for-filename(DATA_PATH ~ $pic-file);
    $pic.add-controller($target);
    .clear-object;
  }

  $pic
}

