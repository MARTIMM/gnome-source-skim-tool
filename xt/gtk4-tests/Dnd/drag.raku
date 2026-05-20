#!/usr/bin/env -S rakudo -Ilib

use v6.d;

#use lib '/home/marcel/Languages/Raku/Projects/gnome-source-skim-tool/gnome-api2/gnome-native/lib';

use NativeCall;

use Gnome::Glib::N-MainLoop:api<2>;
use Gnome::Glib::N-Bytes:api<2>;
use Gnome::Glib::N-Error:api<2>;
use Gnome::Glib::T-error:api<2>;


use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::X:api<2>;
#Gnome::N::debug(:on);

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
use Gnome::Gdk4::T-contentformats:api<2>;
use Gnome::Gdk4::N-FileList:api<2>;
use Gnome::Gdk4::T-enums:api<2>;
use Gnome::Gdk4::T-drag:api<2>;

use Gnome::Gio::File:api<2>;
#use Gnome::Gio::FileIcon:api<2>;
use Gnome::Gio::Task:api<2>;

use Gnome::GObject::T-type:api<2>;
use Gnome::GObject::N-Value:api<2>;
use Gnome::GObject::T-value:api<2>;

#`{{
  See also:
  https://docs.gtk.org/gtk4/drag-and-drop.html
  https://docs.gtk.org/gdk4/struct.ContentFormats.html
  https://ssalewski.de/gtkprogramming.html#_drag_and_drop_dnd

  https://developer.gnome.org/documentation/tutorials/drag-and-drop.html
}}


#-------------------------------------------------------------------------------
constant DATA_PATH =
  $*HOME ~ '/Languages/Raku/Projects/gnome-source-skim-tool/xt/Other/data/';

my Gnome::Glib::N-MainLoop $main-loop .= new-mainloop( N-Object, True);

#-------------------------------------------------------------------------------
class Helper {
  method exit ( ) {
    $main-loop.quit;
  }

#`{{
# commented because data content type is set below
  #-----------------------------------------------------------------------------
  method prepare (
    Rat() $x, Rat() $y,
    Gnome::Gtk4::DragSource() :_native-object($ds),
    Gnome::Gtk4::Picture :$pic, Str :$color
    --> N-Object
  ) {
    note "$?LINE prepare: $x, $y, $pic.gist()";

     my Gnome::Gdk4::ContentProvider $cp .= new-typed(
      G_TYPE_STRING, gchar-ptr, $color
    );

    # Must return native content provider object
    $cp.get-native-object-no-reffing
  }
}}

  #-----------------------------------------------------------------------------
  method drag-begin (
    Gnome::Gdk4::Drag() $drag,
    Gnome::Gtk4::DragSource() :_native-object($ds),
    Gnome::Gtk4::Picture :$pic,
  ) {
    note "\ndrag-begin";
    $ds.set-icon( $pic.get-paintable, -20, 20);
  }

  #-----------------------------------------------------------------------------
  method drag-end ( Gnome::Gdk4::Drag() $drag, Bool() $delete-data ) {
    note "drag-end: delete data $delete-data";
  }

  #-----------------------------------------------------------------------------
  method drag-cancel ( Gnome::Gdk4::Drag() $drag, UInt $reason ) {
    note "drag-cancel: $reason";
  }

  #-----------------------------------------------------------------------------
  method show-actions ( GFlag $actions ) {
    for GDK_ACTION_COPY, GDK_ACTION_MOVE, GDK_ACTION_LINK -> $action {
      note "Action $action found" if $actions &? $action;
    }
  }
}

#-------------------------------------------------------------------------------
my Helper $helper .= new;
my Gnome::Gtk4::Picture $red = set-drag-source('red-on-256.png');
my Gnome::Gtk4::Picture $amber = set-drag-source('amber-on-256.png');
my Gnome::Gtk4::Picture $green = set-drag-source('green-on-256.png');

with my Gnome::Gtk4::Grid $grid .= new-grid {
  .attach( $red,      0, 0, 1, 1);
  .attach( $green,    1, 0, 1, 1);
  .attach( $amber,    2, 0, 1, 1);
}

with my Gnome::Gtk4::Window $window .= new-window {
  .set-title('Drag and Drop test');
  .set-child($grid);

  .register-signal( $helper, 'exit', 'close-request');
  .present;
}


$main-loop.run;
say 'done it';

#-------------------------------------------------------------------------------
sub set-drag-source ( Str $pic-file --> Gnome::Gtk4::Picture ) {
  my Gnome::Gtk4::Picture $pic;
  $pic .= new-for-filename(DATA_PATH ~ $pic-file);
  $pic.set-size-request( 100, 100);
  with my Gnome::Gtk4::DragSource $source .= new-dragsource {
    # Possible to set content provider in 'prepare()' or below.
    #.register-signal( $helper, 'prepare', 'prepare', :$pic, :color($pic-file));
    .register-signal( $helper, 'drag-begin', 'drag-begin', :$pic);
    .register-signal( $helper, 'drag-end', 'drag-end');
    .register-signal( $helper, 'drag-cancel', 'drag-cancel');
  }

  # Set content. Can use multiple strings. Interface has variable list solved
  # by providing pairs of type/value. Inthis case gchar-ptr/$pic-file
  my Gnome::Gdk4::ContentProvider $cp .= new-typed(
    G_TYPE_STRING, gchar-ptr, $pic-file
  );
  $source.set-content($cp);

  $pic.add-controller($source);
  $source.clear-object;

  $pic
}
