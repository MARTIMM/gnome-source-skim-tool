# See also: https://blog.gtk.org/2020/04/24/custom-widgets-in-gtk-4-drawing/

use v6.d;
use NativeCall;

use Gnome::Graphene::T-size:api<2>;
use Gnome::Graphene::T-rect:api<2>;
use Gnome::Graphene::T-point:api<2>;
use Gnome::Graphene::N-Rect:api<2>;

use Gnome::Glib::N-MainLoop:api<2>;

use Gnome::Gdk4::Texture:api<2>;
use Gnome::Gdk4::Texture:api<2>;
use Gnome::Gdk4::T-rgba:api<2>;
use Gnome::Gdk4::N-RGBA:api<2>;

#use Gnome::Gtk4::Native:api<2>;
use Gnome::Gtk4::Snapshot:api<2>;
use Gnome::Gtk4::Image:api<2>;
use Gnome::Gtk4::Picture:api<2>;
use Gnome::Gtk4::Window:api<2>;
use Gnome::Gtk4::Grid:api<2>;

use Gnome::Gsk4::RenderNode:api<2>;

use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::X:api<2>;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
my Gnome::Glib::N-MainLoop $main-loop .= new-mainloop( N-Object, True);

#-------------------------------------------------------------------------------
class SH {
  has Num() $.width = 100;
  has Num() $.height = 100;
  has Num() $.w = $!width/2;
  has Num() $.h = $!height/2;

  #-----------------------------------------------------------------------------
  method stopit ( --> gboolean ) {
    say 'close request';

    $main-loop.quit;

    0
  }
#`{{
  #-----------------------------------------------------------------------------
  method press ( ) {
    say 'button pressed';
  }
}}
  #-----------------------------------------------------------------------------
  method set-image ( Gnome::Gtk4::Image $image ) {

    my Gnome::Gtk4::Snapshot $snapshot .= new-snapshot;
    self.add-col-rect( $snapshot, 0,   0,   $!w, $!h, 1, 0, 1, 0.9);
    self.add-col-rect( $snapshot, $!w, 0,   $!w, $!h, 0, 1, 0, 0.8);
    self.add-col-rect( $snapshot, 0,   $!h, $!w, $!h, 0, 0, 1, 1);
    self.add-col-rect( $snapshot, $!w, $!h, $!w, $!h, 1, 1, 0, 1);

#    $snapshot.save;

    # Now we are finished drawing and create a texture to be able to set
    # an image. A texture has the paintable role.
#    my N-Size() $n-size .= new( :$!width, :$!height);
#    my Gnome::Gdk4::Texture() $texture = $snapshot.to-paintable($n-size);

#    Gnome::N::debug(:on);
    $image.set-from-paintable($snapshot.to-paintable(N-Size));
#    Gnome::N::debug(:off);

#    my Gnome::Gdk4::Texture() $texture = $image.get-paintable;
#    $texture.snapshot( $snapshot, $!width, $!height);


#`{{
    with my Gnome::Gtk4::Image $image .= new-from-paintable($texture) {
      .set-size-request( $!width, $!height);
    }

    $image
}}  }

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

#    my Gnome::Graphene::N-Rect $r .= alloc;
#    $r.init( $x, $y, $w, $h);
    my N-RGBA $c .= new( :$red, :$green, :$blue, :$alpha);
my Gnome::Gdk4::N-RGBA $color .= new(:native-object($c));
note "$?LINE c: $c.red(), $c.green(), $c.blue(), $c.alpha(): $color.to-string()";
    $snapshot.append-color( $c, $r);
  }
}

my SH $sh .= new;

#-------------------------------------------------------------------------------

#`{{
my Gnome::Gsk4::RenderNode() $render-node = $snapshot.free-to-node;
my N-Rect $r .= new;
$render-node.get-bounds($r);

#my N-Point $p = $r.origin;
#note "$?LINE x, y:  $p.x(), $p.y()";
#my N-Size $s = $r.size;
#note "$?LINE w, h: $s.width(), $s.height()";

$render-node.write-to-file( '/tmp/rendered-node', gpointer);
note '/tmp/rendered-node'.IO.slurp;
unlink '/tmp/rendered-node';

$snapshot .= new-snapshot;
$snapshot.append-node($render-node);

}}

# Now we are finished drawing and create a texture to be able to set an image. A
# texture has the paintable role.

#my N-Size() $n-size .= new( :$width, :$height);
#my Gnome::Gdk4::Texture() $texture = $snapshot.free-to-paintable($n-size);
#my Gnome::Gdk4::Texture() $texture = $snapshot.free-to-paintable(N-Size);
#Gnome::N::debug(:on);

#with my Gnome::Gtk4::Image $image .= new-from-paintable($texture) {
#my Gnome::Gtk4::Image $image = $sh.make-image;

with my Gnome::Gtk4::Image $image .= new-image {
  .set-size-request( $sh.width, $sh.height);
}

with my Gnome::Gtk4::Grid $grid .= new-grid {
  .set-margin-start($sh.w);
  .set-margin-end($sh.w);
  .set-margin-top($sh.h);
  .set-margin-bottom($sh.h);
  .attach( $image, 0, 0, 1, 1);
}

with my Gnome::Gtk4::Window $window .= new-window {
  .register-signal( $sh, 'stopit', 'close-request');
  .set-title('My new window');
  .set-child($grid);
  .set-size-request( 200, 200);
  
  $sh.set-image($image);
  
  .present;
}

$main-loop.run;
say 'done it';


