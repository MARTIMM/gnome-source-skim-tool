# See also: https://blog.gtk.org/2020/04/24/custom-widgets-in-gtk-4-drawing/

use v6.d;

use Gnome::Graphene::T-size:api<2>;
use Gnome::Graphene::T-rect:api<2>;
use Gnome::Graphene::T-point:api<2>;

use Gnome::Glib::N-MainLoop:api<2>;

use Gnome::Gdk4::T-rgba:api<2>;

use Gnome::Gtk4::Snapshot:api<2>;
use Gnome::Gtk4::Image:api<2>;
use Gnome::Gtk4::Window:api<2>;
use Gnome::Gtk4::Frame:api<2>;

use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::N-Object:api<2>;

#-------------------------------------------------------------------------------
class DrawingColors {
  has Gnome::Glib::N-MainLoop $!main-loop;

  has Num() $!width;
  has Num() $!height;
  has Num() $!w;
  has Num() $!h;

  submethod BUILD ( ) {
    $!main-loop .= new-mainloop( N-Object, True);
    $!width = 200;
    $!height = 200;
    $!w = $!width/2;
    $!h = $!height/2;

    #---------------------------------------------------------------------------
    my Gnome::Gtk4::Image $image .= new-image;
    $image.set-size-request( $!width, $!height);
  
    with my Gnome::Gtk4::Frame $frame .= new-frame('My Drawing') {
      .set-margin-start(50);
      .set-margin-end(50);
      .set-margin-top(50);
      .set-margin-bottom(50);
      .set-child($image);
    }

    with my Gnome::Gtk4::Window $window .= new-window {
      .register-signal( self, 'stopit', 'close-request');
      .set-title('My new window');
      .set-child($frame);

      self.set-image($image);

      .present;
    }

    $!main-loop.run;
  }

  #-----------------------------------------------------------------------------
  method stopit ( --> gboolean ) {
    say 'close request';

    $!main-loop.quit;

    0
  }

  #-----------------------------------------------------------------------------
  method set-image ( Gnome::Gtk4::Image $image ) {

    my Gnome::Gtk4::Snapshot $snapshot .= new-snapshot;
    self.add-col-rect( $snapshot, 0,   0,   $!w, $!h, 1, 0, 1, 0.9);
    self.add-col-rect( $snapshot, $!w, 0,   $!w, $!h, 0, 1, 0, 0.8);
    self.add-col-rect( $snapshot, 0,   $!h, $!w, $!h, 0, 0, 1, 1);
    self.add-col-rect( $snapshot, $!w, $!h, $!w, $!h, 1, 1, 0, 1);

    $image.set-from-paintable($snapshot.free-to-paintable(N-Size));
  }

  #-----------------------------------------------------------------------------
  method add-col-rect(
    Gnome::Gtk4::Snapshot $snapshot,
    Num() $x, Num() $y, Num() $w, Num() $h,
    Num() $red, Num() $green, Num() $blue, Num() $alpha
  ) {
    my N-Rect() $r .= new(
      :origin(N-Point.new( :$x, :$y)),
      :size( N-Size.new( :width($w), :height($h))),
    );

    my N-RGBA $c .= new( :$red, :$green, :$blue, :$alpha);
    $snapshot.append-color( $c, $r);
  }
}

DrawingColors.new;
