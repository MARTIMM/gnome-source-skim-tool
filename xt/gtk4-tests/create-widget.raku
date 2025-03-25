#!/usr/bin/env -S rakudo
#-------------------------------------------------------------------------------

use NativeCall;

use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::X:api<2>;
#Gnome::N::debug(:on);

use Gnome::Gtk4::Widget:api<2>;
use Gnome::Gtk4::Window:api<2>;
use Gnome::Gtk4::Label:api<2>;
use Gnome::Gtk4::Snapshot:api<2>;
use Gnome::Gtk4::Picture:api<2>;
use Gnome::Gtk4::Box:api<2>;
use Gnome::Gtk4::T-enums:api<2>;

use Gnome::Gsk4::TextNode:api<2>;
use Gnome::Gsk4::N-Transform:api<2>;
use Gnome::Gsk4::TransformNode:api<2>;
use Gnome::Gsk4::RenderNode:api<2>;

use Gnome::Graphene::N-Point:api<2>;
use Gnome::Graphene::T-point:api<2>;
use Gnome::Graphene::T-size:api<2>;
use Gnome::Graphene::N-Rect:api<2>;
use Gnome::Graphene::T-rect:api<2>;

use Gnome::Gdk4::N-RGBA:api<2>;
use Gnome::Gdk4::T-rgba:api<2>;
use Gnome::Gdk4::Texture:api<2>;

#use Gnome::Pango::Context:api<2>;
use Gnome::Pango::Layout:api<2>;
use Gnome::Pango::T-types:api<2>;
#use Gnome::Pango::T-gravity:api<2>;
#use Gnome::Pango::N-Matrix:api<2>;
#use Gnome::Pango::T-matrix:api<2>;

use Gnome::Glib::N-MainLoop:api<2>;

#-------------------------------------------------------------------------------
constant N-MainLoop = Gnome::Glib::N-MainLoop;
constant Widget = Gnome::Gtk4::Widget;
constant Window = Gnome::Gtk4::Window;
constant Label = Gnome::Gtk4::Label;
constant Snapshot = Gnome::Gtk4::Snapshot;
constant Picture = Gnome::Gtk4::Picture;
constant Box = Gnome::Gtk4::Box;

#constant PContext = Gnome::Pango::Context;
constant PLayout = Gnome::Pango::Layout;

constant STextNode = Gnome::Gsk4::TextNode;
constant SNTransform = Gnome::Gsk4::N-Transform;
constant STransformNode = Gnome::Gsk4::TransformNode;
constant SRenderNode = Gnome::Gsk4::RenderNode;

my N-MainLoop $main-loop .= new-mainloop( N-Object, True);

#-------------------------------------------------------------------------------
class Helper {
  method exit ( ) {
    $main-loop.quit;
  }
}

#-------------------------------------------------------------------------------
class RLabel is Picture {
  has Str $!label;
  has Num $!angle;

  submethod BUILD ( Str :$!label, Num() :$!angle ) {

#note "$?LINE $!label";

    my N-RGBA $n-rgba .= new( :red(1), :green(1), :blue(0), :alpha(1));
    my PLayout() $layout = self.create-pango-layout('');
    $layout.set-indent(0);
    $layout.set-text( $!label, $!label.chars);

    # Get size info of string
    my Int ( $x, $y, $w, $h) = self.get-text-info($layout);
    note "o: ($x,$y), w x h: $w, $h";

    # Now we can use the values found above
    my Snapshot $snapshot .= new-snapshot;

    # Translate snapshots coordinate system
    my N-Point $n-point .= new( :x(0), :y($w));
    $snapshot.translate($n-point);

    # Rotate by $!angle egrees clockwise around origin
    $snapshot.rotate($!angle);

    # Now add the string in some color. It is rotated and moved.
    $snapshot.append-layout( $layout, $n-rgba);
    my N-Size() $n-size .= new( :width($h), :height($w));
    my Gnome::Gdk4::Texture() $texture = $snapshot.free-to-paintable($n-size);
#    my Gnome::Gdk4::Texture() $texture = $snapshot.free-to-paintable(N-Size);

    self.set-size-request( $h, $w);
    self.set-paintable($texture);
    self.set-halign(GTK_ALIGN_START);
    self.set-valign(GTK_ALIGN_START);

#note $?LINE;
  }

  #-----------------------------------------------------------------------------
  # Get info of string
  method get-text-info( PLayout $layout --> List ) {
    my N-Rectangle $ink .= new;
    my N-Rectangle $log .= new;
    $layout.get-pixel-extents( $ink, $log);
    note "ink: ", $ink.x, ', ', $ink.y, ', ', $ink.width, ', ', $ink.height;
    note "log: ", $log.x, ', ', $log.y, ', ', $log.width, ', ', $log.height;
    ( $log.x, $log.y, $log.width, $log.height)
#`{{
    my N-RGBA $n-rgba .= new( :red(1), :green(1), :blue(0), :alpha(1));
    my PLayout() $layout = self.create-pango-layout($text);
    my Snapshot $snapshot .= new-snapshot;

    # Add the string to the snapshot. Then convert it to a render node
    $snapshot.append-layout( $layout, $n-rgba);
    my SRenderNode() $render-node = $snapshot.free-to-node;

    # Get the bounds of the node from snapshot.
    my N-Rect() $rect .= new;
    $render-node.get-bounds($rect);
    my N-Point() $orig = $rect.origin;
    my N-Size() $size = $rect.size;

    ( $orig.x, $orig.y, $size.width, $size.height )
}}
  }
}

#-------------------------------------------------------------------------------
my Helper $helper .= new;

with my RLabel $rlabel .= new-picture(:label( 'Big Test Label Text'), :angle(-90)) {
  .set-margin-top(0);
  .set-margin-bottom(0);
  .set-margin-start(0);
  .set-margin-end(0);
}

with my Window $window .= new-window {
  .set-title('
  Rotated text widget');

  # When RLabel is placed directly in the window, the image scales
  # with the window.
  my Box $box .= new-box;
  $box.append($rlabel);
#  $box.set-size-request( 300, 300);
  .set-child($box);
  .present;

  .set-margin-top(0);
  .set-margin-bottom(0);
  .set-margin-start(0);
  .set-margin-end(0);

#  my Int $w = .get-width;
#  my Int $h = .get-height;
#  note "w x h: $w, $h";

  .register-signal( $helper, 'exit', 'close-request');
}

#Gnome::N::debug(:on);

$main-loop.run;
