#!/usr/bin/env -S rakudo -Ilib
# -Ignome-api2/gnome-gtk4/lib 

use v6.d;
#use lib 'lib';
#use lib './gnome-api2/gnome-gtk4/lib';
use lib './gnome-api2/gnome-native/lib';

use NativeCall;

use Gnome::Glib::N-MainLoop:api<2>;

use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::X:api<2>;
#Gnome::N::debug(:on);

use Gnome::Gtk4::DropTarget:api<2>;
use Gnome::Gtk4::DragSource:api<2>;
use Gnome::Gtk4::Window:api<2>;
use Gnome::Gtk4::Picture:api<2>;
#use Gnome::Gtk4::Image:api<2>;
use Gnome::Gtk4::Grid:api<2>;

use Gnome::Gdk4::Drag:api<2>;
use Gnome::Gdk4::ContentProvider:api<2>;
#use Gnome::Gdk4::ContentFormats;
use Gnome::Gdk4::T-enums:api<2>;

#use Gnome::Gio::File:api<2>;
#use Gnome::Gio::FileIcon:api<2>;

use Gnome::GObject::T-type:api<2>;
use Gnome::GObject::T-value:api<2>;


#`{{
  See also:
  https://docs.gtk.org/gtk4/drag-and-drop.html
  https://docs.gtk.org/gdk4/struct.ContentFormats.html
}}

#-------------------------------------------------------------------------------
constant DATA_PATH =
  $*HOME ~ '/Languages/Raku/Projects/gnome-api2/xt/Other/data/';

my Gnome::Glib::N-MainLoop $main-loop .= new-mainloop( N-Object, True);

class Helper {
  method exit ( ) {
    $main-loop.quit;
  }

  method prepare (
    Rat() $x, Rat() $y,
    Gnome::Gtk4::DragSource() :_native-object($ds),
    Gnome::Gtk4::Picture :$pic,
    --> N-Object
  ) {
    note "$?LINE prepare: $x, $y, $pic.gist()";
    my Gnome::Gdk4::ContentProvider $t1 .= new-typed($pic.get-class-gtype);
    my Gnome::Gdk4::ContentProvider $u .= new-union(
      CArray[N-Object].new($t1.get-native-object-no-reffing,), 1
    );

    $u.get-native-object
  }

  method drag-begin (
    Gnome::Gdk4::Drag() $drag,
    Gnome::Gtk4::DragSource() :_native-object($ds),
    Gnome::Gtk4::Picture :$pic,
  ) {
    note "$?LINE drag-begin: $drag, $pic.gist()";
    $ds.set-icon( $pic.get-paintable, -20, 20);
  }

  method drop (
    N-Value() $v, Rat() $x, Rat() $y,
    Gnome::Gtk4::DropTarget() :_native-object($dt),
    Gnome::Gtk4::Picture :$pic
    --> Bool
  ) {
#Gnome::N::debug(:on);
    note "$?LINE drop: $v.gist(), $x, $y";
    my Bool $drop-ok = False;

#    my Gnome::Gdk4::ContentFormats() $cf = $dt.get-formats;
#    note "$?LINE ", 

    if $v.g-type == $pic.get-class-gtype {
 #     my CArray[Str] $s = $v.data;
      note "pic transported";
      $drop-ok = True;
    }

#Gnome::N::debug(:off);
    $drop-ok;
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

Gnome::N::debug(:on);

$main-loop.run;
say 'done it';

#-------------------------------------------------------------------------------
sub set-drag-source ( Str $pic-file --> Gnome::Gtk4::Picture ) {
  my Gnome::Gtk4::Picture $pic;
  $pic .= new-for-filename(DATA_PATH ~ $pic-file);
  with my Gnome::Gtk4::DragSource $source .= new-dragsource {
    .register-signal( $helper, 'prepare', 'prepare', :$pic);
    .register-signal( $helper, 'drag-begin', 'drag-begin', :$pic);
  }

  $pic.add-controller($source);
  $source.clear-object;

  $pic
}

#-------------------------------------------------------------------------------
sub set-drag-target ( Str $pic-file --> Gnome::Gtk4::Picture ) {
  my Gnome::Gtk4::Picture $pic;
  $pic .= new-for-filename(DATA_PATH ~ $pic-file);
  my Gnome::Gtk4::DropTarget $target;
  with $target .= new-droptarget( G_TYPE_INVALID, GDK_ACTION_COPY) {
    .set-gtypes( CArray[GType].new($pic.get-class-gtype), 1);
    .register-signal( $helper, 'drop', 'drop', :$pic);
  }

  $pic.add-controller($target);
  $target.clear-object;

  $pic
}

