#!/usr/bin/env -S rakudo -Ilib
# -Ignome-api2/gnome-gtk4/lib 

use v6.d;
#use lib 'lib';
#use lib './gnome-api2/gnome-gtk4/lib';
#use lib './gnome-api2/gnome-native/lib';
#use lib './gnome-api2/gnome-gdk4/lib';

use NativeCall;

use Gnome::Glib::N-MainLoop:api<2>;
use Gnome::Glib::N-Error:api<2>;
use Gnome::Glib::T-error:api<2>;


use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::N-Object:api<2>;
#use Gnome::N::X:api<2>;
#Gnome::N::debug(:on);

use Gnome::Gtk4::Window:api<2>;
use Gnome::Gtk4::Picture:api<2>;
use Gnome::Gtk4::Grid:api<2>;
use Gnome::Gtk4::T-enums:api<2>;
use Gnome::Gtk4::DropTargetAsync:api<2>;

use Gnome::Gdk4::Drag:api<2>;
use Gnome::Gdk4::Drop:api<2>;
#use Gnome::Gdk4::ContentProvider:api<2>;
use Gnome::Gdk4::N-ContentFormats:api<2>;
use Gnome::Gdk4::T-enums:api<2>;

#use Gnome::Gio::File:api<2>;
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
  https://www.reddit.com/r/GTK/comments/w8ai6j/how_to_make_drag_and_drop_in_gtk4/
}}

#my Gnome::Gio::File $f .= new-for-path('abc.txt');
#note "$?LINE File gtype = $f.get-class-gtype()";

#-------------------------------------------------------------------------------
constant DATA_PATH =
  $*HOME ~ '/Languages/Raku/Projects/gnome-source-skim-tool/xt/Other/data/';

my Gnome::Glib::N-MainLoop $main-loop .= new-mainloop( N-Object, True);

#-------------------------------------------------------------------------------
class Helper {
  method exit ( ) {
    $main-loop.quit;
  }

  #-----------------------------------------------------------------------------
  method accept (
    Gnome::Gdk4::Drop() $drop, 
    Gnome::Gtk4::DropTargetAsync() :_native-object($dt),
    --> gboolean
  ) {
    my Bool $accept-ok;
    $accept-ok = self.check-mimetype( 'text/plain', self.get-mimetypes($drop));

    note "accept: $accept-ok";
    $accept-ok
  }

  #-----------------------------------------------------------------------------
  method drop (
    Gnome::Gdk4::Drop() $drop, Rat() $x, Rat() $y,
    Gnome::Gtk4::DropTargetAsync() :_native-object($dt),
    --> gboolean
  ) {
note "\n$?LINE drop: $x, $y";

    my Array $mime-types = self.get-mimetypes($drop);
    if my Bool $drop-ok = self.check-mimetype( 'text/plain', $mime-types) {
      self.show-mimetypes($mime-types);

      my Gnome::Gdk4::Drag() $drag = $drop.get-drag;
      if $drag.is-valid {
        note 'drop: inside job';
        $drop.read-value-async(
          G_TYPE_STRING, 1, gpointer, &get-data-value-async, gpointer
        );

#        $drop.finish(GDK_ACTION_COPY);
      }

      else {
        note 'drop: package from abroad';
#        $drop.read-async(
#          CArray[Str].new(<text/plain text/uri-list>), 0, gpointer, &get-data-async, gpointer
#        );
        $drop.read-value-async(
          G_TYPE_STRING, 1, gpointer, &get-data-value-async, gpointer
        );
      }
    }

    # Select one of the set flags from get-actions()
#    $drop.finish(GDK_ACTION_COPY);
    note "$?LINE 'drop: $drop-ok";

    $drop-ok
  }

  #-----------------------------------------------------------------------------
  method get-mimetypes ( Gnome::Gdk4::Drop $drop --> Array ) {
    my Gnome::Gdk4::N-ContentFormats() $formats = $drop.get-formats;
    my $size = CArray[gsize].new(0);
    my Array $mime-types = $formats.get-mime-types($size);

    $mime-types
  }

  #-----------------------------------------------------------------------------
  method show-mimetypes ( Array $mime-types ) {

    for @$mime-types -> $mime-type {
      note "show-mimetypes: Mime type: $mime-type";
    }
  }

#`{{
  #-----------------------------------------------------------------------------
  method show-actions ( GFlag $actions ) {
    for GDK_ACTION_COPY, GDK_ACTION_MOVE, GDK_ACTION_LINK -> $action {
      note "Action $action found" if $actions &? $action;
    }
  }
}}

  #-----------------------------------------------------------------------------
  method check-mimetype (
    Str $lookfor, Array $mime-types --> Bool
  ) {
    my Bool $ok = False;
    for @$mime-types -> $mime-type {
      if $mime-types ~~ m/ $lookfor / {
        $ok = True;
        last;
      }
    }

    $ok
  }

  #-----------------------------------------------------------------------------
  method enter ( Rat() $x, Rat() $y --> GFlag ) {
    note "Enter at $x, $y";

    GDK_ACTION_COPY;# +| GDK_ACTION_MOVE +| GDK_ACTION_LINK
  }

  #-----------------------------------------------------------------------------
  method leave ( ) {
    note "Left";
  }

  #-----------------------------------------------------------------------------
  method motion ( Rat() $x, Rat() $y --> GFlag ) {
    note "move to $x, $y";
    GDK_ACTION_COPY;# +| GDK_ACTION_MOVE +| GDK_ACTION_LINK
  }

  #-----------------------------------------------------------------------------
  method drag-enter (
    Gnome::Gdk4::Drop() $drop, Rat() $x, Rat() $y --> GFlag
  ) {
    note "Enter at $x, $y";
    GDK_ACTION_COPY;# +| GDK_ACTION_MOVE +| GDK_ACTION_LINK
  }

  #-----------------------------------------------------------------------------
  method drag-leave ( Gnome::Gdk4::Drop() $drop ) {
    note "Left";
  }

  #-----------------------------------------------------------------------------
  method drag-motion (
    Gnome::Gdk4::Drop() $drop, Rat() $x, Rat() $y --> GFlag
  ) {
    note "move to $x, $y";
    GDK_ACTION_COPY;# +| GDK_ACTION_MOVE +| GDK_ACTION_LINK
  }
}

#-------------------------------------------------------------------------------
# Set by read-value-async().
sub get-data-value-async (
  Gnome::Gdk4::Drop() $drop, Gnome::Gio::Task() $result, gpointer $
) {
note "$?LINE $drop.gist(), $result.gist(), $result.get-name()";
  CONTROL { when CX::Warn {  note .gist; #`{{.resume;}} } }
  CATCH { default { .message.note; .backtrace.concise.note } }

note "get-data actions: ", $drop.get-actions.fmt('0x%04x');
#note "get-data is COPY: ", $drop.get-actions.fmt('0x%04x') ?& GDK_ACTION_COPY;

  my $e = CArray[N-Error].new(N-Error);
  my gpointer $p = $result.propagate-pointer($e);
  if ?$p {
    my Gnome::GObject::N-Value $v .= new(
      :native-object(nativecast( N-Object, $p))
    );

note "$?LINE v: $v.gist(), $v.get-native-object.gist()";
note "$?LINE v: $v.get-string()";

note $?LINE;
    $drop.read-value-finish( $result, gpointer);
note $?LINE;
  }

  else {
note "$?LINE Error";
  }
}

#-------------------------------------------------------------------------------
# Set by read-async(). Callback function is typed as AsyncReadyCallback from Gio
# capture is :( N-Object, N-Object, gpointer)
sub get-data-async (
  Gnome::Gdk4::Drop() $drop, Gnome::Gio::Task() $result, gpointer $
) {

note "$?LINE $drop.gist(), $result.gist(), $result.get-name()";
  CONTROL { when CX::Warn { note .gist; } }
  CATCH { default { .message.note; .backtrace.concise.note } }

  my N-Value $v .= new(:g-type(G_TYPE_STRING));
  my Gnome::GObject::N-Value $value .= new(:native-object($v));
  $value.set-string(' ');

  my $e = CArray[N-Error].new(N-Error);
  my Bool $is-ok = $result.propagate-value( $v, $e);
note "$?LINE $is-ok, $e[0].gist()";

  if $is-ok {
note "$?LINE v: $value.gist()";
note "$?LINE v: $value.get-string()";
  }

  else {
note "$?LINE Error: ", $e[0].message if ?$e[0];
  }

  my $used-mimetype = CArray[Str].new;
  $drop.read-finish( $result, $used-mimetype, gpointer);
  note "$?LINE Used mimetype for action is $used-mimetype[0]";
}

#-------------------------------------------------------------------------------
my Helper $helper .= new;
my Gnome::Gtk4::Picture $bullseye = set-drag-target('bullseye.jpg');

with my Gnome::Gtk4::Grid $grid .= new-grid {
  .attach( $bullseye, 0, 1, 3, 3);
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
# Create a bullseye where the data must be dragged to.
sub set-drag-target ( Str $pic-file --> Gnome::Gtk4::Picture ) {

  my Gnome::Gtk4::Picture $pic;
  my Gnome::Gtk4::DropTargetAsync $target;

  # The data may be of the content type
  my Gnome::Gdk4::N-ContentFormats $formats .= new-contentformats(
    CArray[Str].new(<text/plain text/uri-list>), 1
  );

  # The drop target only handles a copy action
  with $target .= new-droptargetasync( $formats, GDK_ACTION_COPY) {
    my Gnome::Gdk4::N-ContentFormats() $formats = .get-formats;
    my $size = CArray[gsize].new(0);
    my Array $mime-types = $formats.get-mime-types($size);
    loop ( my Int $i = 0; $i < $size[0]; $i++ ) {
      note "Mime type: ", $mime-types[$i];
    }

    .register-signal( $helper, 'accept', 'accept');
    .register-signal( $helper, 'drop', 'drop');
    .register-signal( $helper, 'drag-enter', 'drag-enter');
    .register-signal( $helper, 'drag-leave', 'drag-leave');
    .register-signal( $helper, 'drag-motion', 'drag-motion');

    $pic .= new-for-filename(DATA_PATH ~ $pic-file);
    $pic.add-controller($target);
    .clear-object;
  }

  $pic
}
