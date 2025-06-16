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

use Gnome::Gtk4::DropTargetAsync:api<2>;
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

  #-----------------------------------------------------------------------------
  method drag-begin (
    Gnome::Gdk4::Drag() $drag,
    Gnome::Gtk4::DragSource() :_native-object($ds),
    Gnome::Gtk4::Picture :$pic,
  ) {
note "$?LINE drag-begin: $drag, $pic.gist()";
    $ds.set-icon( $pic.get-paintable, -20, 20);
  }

  #-----------------------------------------------------------------------------
  method accept1 (
    Gnome::Gdk4::Drop() $drop, 
    Gnome::Gtk4::DropTarget() :_native-object($dt),
    --> gboolean
  ) {
    my Bool $accept-ok = False;
#    $drop.set-gtypes( CArray[GType].new($f.get-class-gtype), 1);

    my Gnome::Gdk4::N-ContentFormats() $formats = $drop.get-formats;
    my $size = CArray[gsize].new(0);
    my Array $mime-types = $formats.get-mime-types($size);
note "\n\n$?LINE accept1: $size.gist(), $mime-types.elems()";
    loop ( my Int $i = 0; $i < $size[0]; $i++ ) {
      note "Mime type: ", $mime-types[$i];
      $accept-ok = True if $mime-types[$i] ~~ m/ text /;
    }

#Gnome::N::debug(:on);
    note "accept1: $accept-ok";
    $dt.set-preload(False);
    $accept-ok
  }

  #-----------------------------------------------------------------------------
  method drop1 (
    N-Value() $n-value, Rat() $x, Rat() $y,
    Gnome::Gtk4::DropTarget() :_native-object($dt),
    --> gboolean
  ) {
note "\n$?LINE drop1: $x, $y";

#Gnome::N::debug(:on);
    my Bool $drop-ok = False;

    my Gnome::Gdk4::Drop() $drop = $dt.get-current-drop;
    my Gnome::Gdk4::N-ContentFormats() $formats = $dt.get-formats;
    my $size = CArray[gsize].new(0);
    my Array $mime-types = $formats.get-mime-types($size);
#note "$?LINE $size.gist(), $mime-types.elems()";
    loop ( my Int $i = 0; $i < $size[0]; $i++ ) {
      note "drop1: Mime type: ", $mime-types[$i];
    }

note "$?LINE $drop.gist()";

    my Gnome::Gdk4::Drag() $drag = $drop.get-drag;
note "$?LINE $drag.gist()";
    if $drag.is-valid {
      note 'drop1: inside job';

note $?LINE, ', ', $n-value.gist();
    my Gnome::GObject::N-Value $value .= new(:native-object($n-value));
note $?LINE, ', ', $value.get-string;

      # Select one of the set flags from get-actions()
#      $drop.finish(GDK_ACTION_COPY);
    }

    else {
      note 'drop1: package from abroad';

note $?LINE, ', ', $n-value.gist();
    my Gnome::GObject::N-Value $value .= new(:native-object($n-value));
note $?LINE, ', ', $value.get-string;

#      $drop.read-async( [|@$mime-types], 0, gpointer, &get-data, gpointer);

      if $formats.contain-mime-type('text/plain') {
        note "text ";
        $drop-ok = True;
      }
    }

    True; #$drop-ok;
  }

  #-----------------------------------------------------------------------------
  method accept2 (
    Gnome::Gdk4::Drop() $drop, 
    Gnome::Gtk4::DropTargetAsync() :_native-object($dt),
    --> gboolean
  ) {
#    my Bool $accept-ok = False;
#    $drop.set-gtypes( CArray[GType].new($f.get-class-gtype), 1);

    my Array $mime-types = self.get-mimetypes($drop);
    if my Bool $accept-ok = self.check-mimetype( 'text/plain', $mime-types) {
      self.show-mimetypes($mime-types);

#    my Gnome::Gdk4::N-ContentFormats() $formats = $drop.get-formats;
#    my $size = CArray[gsize].new(0);
#    my Array $mime-types = $formats.get-mime-types($size);
#note "\n\n$?LINE accept2: $size.gist(), $mime-types.elems()";
#    loop ( my Int $i = 0; $i < $size[0]; $i++ ) {
#      note "accept2: Mime type: ", $mime-types[$i];
#      if $mime-types[$i] ~~ m/ text / {
#        my GFlag $flags = $drop.get-actions;
#        $accept-ok = True if $flags ?& GDK_ACTION_COPY;
#        last;
#      }
    }

#Gnome::N::debug(:on);
    note "accept2: $accept-ok";
#    $dt.set-preload(True);
    $accept-ok
  }

  #-----------------------------------------------------------------------------
  method drop2 (
    Gnome::Gdk4::Drop() $drop, Rat() $x, Rat() $y,
    Gnome::Gtk4::DropTargetAsync() :_native-object($dt),
    --> gboolean
  ) {
note "\n$?LINE drop2: $x, $y";

    my Array $mime-types = self.get-mimetypes($drop);
    if my Bool $drop-ok = self.check-mimetype( 'text/plain', $mime-types) {
      self.show-mimetypes($mime-types);

      my Gnome::Gdk4::Drag() $drag = $drop.get-drag;
note "$?LINE $drag.gist()";
      if $drag.is-valid {
        note 'drop2: inside job';
        $drop.read-value-async(
          G_TYPE_STRING, 1, gpointer, &get-data-value-async, gpointer
        );
      }

      else {
        note 'drop2: package from abroad';
        $drop.read-value-async(
          G_TYPE_STRING, 1, gpointer, &get-data-value-async, gpointer
        );
#        $drop.read-async(
#          CArray[Str].new('text/plain'), 1, gpointer, &get-data-async, gpointer
#        );
      }
    }

    # Select one of the set flags from get-actions()
#    $drop.finish(GDK_ACTION_COPY);
    note "$?LINE 'drop2: $drop-ok";

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

  #-----------------------------------------------------------------------------
  method show-actions ( GFlag $actions ) {
    for GDK_ACTION_COPY, GDK_ACTION_MOVE, GDK_ACTION_LINK -> $action {
      note "Action $action found" if $actions &? $action;
    }
  }

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

##`{{
  #-----------------------------------------------------------------------------
  method enter ( Rat() $x, Rat() $y --> GFlag ) {
    note "Enter at $x, $y";
    GDK_ACTION_COPY +| GDK_ACTION_MOVE +| GDK_ACTION_LINK
  }

  #-----------------------------------------------------------------------------
  method leave ( ) {
    note "Left";
  }

  #-----------------------------------------------------------------------------
  method motion ( Rat() $x, Rat() $y --> GFlag ) {
    note "move to $x, $y";
    GDK_ACTION_COPY +| GDK_ACTION_MOVE +| GDK_ACTION_LINK
  }
#}}

##`{{
  #-----------------------------------------------------------------------------
  method drag-enter (
    Gnome::Gdk4::Drop() $drop, Rat() $x, Rat() $y --> GFlag
  ) {
    note "Enter at $x, $y";
    GDK_ACTION_COPY +| GDK_ACTION_MOVE +| GDK_ACTION_LINK
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
    GDK_ACTION_COPY +| GDK_ACTION_MOVE +| GDK_ACTION_LINK
  }
#}}
}


#-------------------------------------------------------------------------------
sub get-data-value-async (
  Gnome::Gdk4::Drop() $drop, Gnome::Gio::Task() $result, gpointer $
) {
note "$?LINE $drop.gist()";
  CONTROL { when CX::Warn {  note .gist; #`{{.resume;}} } }
  CATCH { default { .message.note; .backtrace.concise.note } }

note "get-data actions: ", $drop.get-actions.fmt('0x%04x');
note "get-data is COPY: ", $drop.get-actions.fmt('0x%04x') ?& GDK_ACTION_COPY;

  my $e = CArray[N-Error].new(N-Error);
#  my $n-v = CArray[N-Value].new(N-Value);
#  my Bool $is-ok = $result.propagate-value( $n-v, $e);
#note "$?LINE $is-ok, $e.gist()";
#note "Error: $e[0].message()" unless $is-ok;
#  my Gnome::GObject::N-Value $v .= new(:native-object($n-v[0]));

  my gpointer $p = $result.propagate-pointer($e);
note "Error: $e[0].message()" unless ?$p;

  my Gnome::GObject::N-Value $v .= new(
    :native-object(nativecast( N-Object, $p))
  );

#note "$?LINE $n-v.gist()";
note "$?LINE v: $v.gist()";
note "$?LINE v: $v.get-string()";
#  $drop.read-value-finish( $result, $e);
note "Error: $e[0].message()" unless ?$p;
}

#-------------------------------------------------------------------------------
sub get-data-async (
  Gnome::Gdk4::Drop() $drop, Gnome::Gio::Task() $result, gpointer $
) {
  CONTROL { when CX::Warn {  note .gist; .resume; } }
  CATCH { default { .message.note; .backtrace.concise.note } }

note "$?LINE $drop.gist()";
note "get-data actions: ", $drop.get-actions.fmt('0x%04x');
note "get-data is COPY: ", $drop.get-actions.fmt('0x%04x') ?& GDK_ACTION_COPY;

  my $e = CArray[N-Error].new(N-Error);
#  my $n-v = CArray[N-Value].new(N-Value);
#  my Bool $is-ok = $result.propagate-value( $n-v, $e);
#note "$?LINE $is-ok, $e.gist()";
#note "Error: $e[0].message()" unless $is-ok;
#  my Gnome::GObject::N-Value $v .= new(:native-object($n-v[0]));

  my gpointer $p = $result.propagate-pointer($e);
note "Error: $e[0].message()" unless ?$p;

  my Gnome::GObject::N-Value $v .= new(
    :native-object(nativecast( N-Object, $p))
  );


#note "$?LINE $n-v.gist()";
note "$?LINE v: $v.gist()";
note "$?LINE v: $v.get-string()";

#  my $rm = CArray[Str];
#  $drop.read-finish( $result, $rm, $e);
#note "Error: $e[0].message()" unless ?$p;
}

#-------------------------------------------------------------------------------
my Helper $helper .= new;
my Gnome::Gtk4::Picture $red = set-drag-source('red-on-256.png');
my Gnome::Gtk4::Picture $amber = set-drag-source('amber-on-256.png');
my Gnome::Gtk4::Picture $green = set-drag-source('green-on-256.png');

#my Gnome::Gtk4::Picture $bullseye = set-drag-target1('bullseye.jpg');
my Gnome::Gtk4::Picture $bullseye = set-drag-target2('bullseye.jpg');

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
  .present;
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
sub set-drag-target1 ( Str $pic-file --> Gnome::Gtk4::Picture ) {

  my Gnome::Gtk4::Picture $pic;
  my Gnome::Gtk4::DropTarget $target;

  my Gnome::Gio::File $file .= new-for-path('./x.txt');
  note "$?LINE File gtype = $file.get-class-gtype()";

  with $target .= new-droptarget(
    G_TYPE_STRING, GDK_ACTION_COPY +| GDK_ACTION_MOVE +| GDK_ACTION_LINK
  ) {
    my $gtypes = CArray[GType].new( G_TYPE_STRING, $file.get-class-gtype);
    .set-gtypes( $gtypes, 2);
note "$?LINE Preload: ", .get-preload;

    my Gnome::Gdk4::N-ContentFormats() $formats = .get-formats;
    my $size = CArray[gsize].new(0);
    my Array $mime-types = $formats.get-mime-types($size);

note "$?LINE $size.gist(), $mime-types.elems()";
    loop ( my Int $i = 0; $i < $size[0]; $i++ ) {
      note "Mime type: ", $mime-types[$i];
    }

    .register-signal( $helper, 'drop1', 'drop');
    .register-signal( $helper, 'accept1', 'accept');
#    .register-signal( $helper, 'enter', 'enter');
#    .register-signal( $helper, 'leave', 'leave');
#    .register-signal( $helper, 'motion', 'motion');

    $pic .= new-for-filename(DATA_PATH ~ $pic-file);
    $pic.add-controller($target);
    .clear-object;
  }

  $pic
}

#-------------------------------------------------------------------------------
sub set-drag-target2 ( Str $pic-file --> Gnome::Gtk4::Picture ) {

  my Gnome::Gtk4::Picture $pic;
  my Gnome::Gtk4::DropTargetAsync $target;

  my Gnome::Gdk4::N-ContentFormats $formats .= new-contentformats(
    CArray[Str].new(<text/plain>,), 1
  );

  with $target .= new-droptargetasync(
    $formats, GDK_ACTION_COPY +| GDK_ACTION_MOVE +| GDK_ACTION_LINK
  ) {

    my Gnome::Gdk4::N-ContentFormats() $formats = .get-formats;
    my $size = CArray[gsize].new(0);
    my Array $mime-types = $formats.get-mime-types($size);
note "$?LINE $size.gist(), $mime-types.elems()";
    loop ( my Int $i = 0; $i < $size[0]; $i++ ) {
      note "Mime type: ", $mime-types[$i];
    }

    .register-signal( $helper, 'drop2', 'drop');
    .register-signal( $helper, 'accept2', 'accept');
#    .register-signal( $helper, 'drag-enter', 'drag-enter');
#    .register-signal( $helper, 'drag-leave', 'drag-leave');
#    .register-signal( $helper, 'drag-motion', 'drag-motion');

    $pic .= new-for-filename(DATA_PATH ~ $pic-file);
    $pic.add-controller($target);
#    .clear-object;
  }

  $pic
}





=finish
https://www.reddit.com/r/GTK/comments/w8ai6j/how_to_make_drag_and_drop_in_gtk4/

--------------------------------------------------------------------------------
#include <gtk/gtk.h>

static gboolean drop(GtkDropTarget *target,
                     const GValue  *value,
                     double         x,
                     double         y,
                     gpointer       data){
    printf("test\n");
    return TRUE;
}

static void
activate (GtkApplication* app,
          gpointer        user_data)
{
    GtkWidget *window;

    window = gtk_application_window_new (app);
    gtk_window_set_title (GTK_WINDOW (window), "Window");
    gtk_window_set_default_size (GTK_WINDOW (window), 200, 200);

    GtkDropTarget* dnd = gtk_drop_target_new(GDK_TYPE_FILE_LIST,GDK_ACTION_COPY);

    g_signal_connect (dnd, "drop", G_CALLBACK (drop), NULL);
    gtk_widget_add_controller(window,GTK_EVENT_CONTROLLER(dnd));

    gtk_widget_show (window);
}

int
main (int    argc,
      char **argv)
{
    GtkApplication *app;
    int status;

    app = gtk_application_new ("org.gtk.example", G_APPLICATION_FLAGS_NONE);
    g_signal_connect (app, "activate", G_CALLBACK (activate), NULL);
    status = g_application_run (G_APPLICATION (app), argc, argv);
    g_object_unref (app);

    return status;
}


--------------------------------------------------------------------------------
