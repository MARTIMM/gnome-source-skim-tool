
use v6.d;
use NativeCall;

use Cairo;

use Gnome::Graphene::T-size:api<2>;
use Gnome::Graphene::T-rect:api<2>;
use Gnome::Graphene::T-point:api<2>;

use Gnome::Glib::N-MainLoop:api<2>;

use Gnome::Gdk4::Texture:api<2>;
use Gnome::Gdk4::T-rgba:api<2>;

use Gnome::Gtk4::Snapshot:api<2>;
use Gnome::Gtk4::Image:api<2>;
use Gnome::Gtk4::Window:api<2>;
use Gnome::Gtk4::Frame:api<2>;

use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::X:api<2>;
#Gnome::N::debug(:on);

#-------------------------------------------------------------------------------

constant \Window = Gnome::Gtk4::Window;


my Gnome::Glib::N-MainLoop $main-loop .= new-mainloop( N-Object, True);

#-------------------------------------------------------------------------------
class SH {
  method stopit ( --> gboolean ) {
    say 'close request';
    $main-loop.quit;

    0
  }

  method press ( ) {
    say 'button pressed';
  }

  #-----------------------------------------------------------------------------
  method add-col-rect(
    Gnome::Gtk4::Snapshot $snapshot,
    Num() $x, Num() $y, Num() $w, Num() $h,
    Num() $red, Num() $green, Num() $blue, Num() $alpha
  ) {
#note "\n$?LINE $x, $y, $w, $h";
    my N-Rect() $r .= new(
      :origin(N-Point.new( :$x, :$y)),
      :size( N-Size.new( :width($w), :height($h))),
    );

#note "$?LINE x, y: $r.origin.x(), $r.origin.y()";
#note "$?LINE w, h: $r.size.width(), $r.size.height()";

#    my Gnome::Graphene::N-Rect $r .= alloc;
#    $r.init( $x, $y, $w, $h);
    my N-RGBA $c .= new( :$red, :$green, :$blue, :$alpha);
#note "$?LINE c: $c.red(), $c.green(), $c.blue(), $c.alpha()";
    $snapshot.append-color( $c, $r);
  }
}

my SH $sh .= new;
#-------------------------------------------------------------------------------
my Num() $width = 200;
my Num() $height = 200;
my Num() $w = $width/2;
my Num() $h = $height/2;

#Gnome::N::debug(:on);

my Gnome::Gtk4::Snapshot $snapshot .= new-snapshot;
$sh.add-col-rect( $snapshot, 0,  0,  $w, $h, 0.8, 0.6, 0, 0.9);
$sh.add-col-rect( $snapshot, $w, 0,  $w, $h, 0, 1, 0, 0.7);
$sh.add-col-rect( $snapshot, 0,  $h, $w, $h, 0, 0, 1, 0.5);
$sh.add-col-rect( $snapshot, $w, $h, $w, $h, 1, 1, 0, 0.3);

my Gnome::Graphene::N-Rect $rect-pic .= alloc;
$rect-pic.init( 0, 0, $width, $height);

# Next is one of the examples found in the Cairo distro of Time
constant xc = 100.0;
constant yc = 100.0;
constant radius = 100.0;
constant angle1 = 45.0  * (pi/180.0);   # angles are specified
constant angle2 = 180.0 * (pi/180.0);   # in radians

my Cairo::cairo_t $arc-pic = nativecast(Cairo::cairo_t,$snapshot.append-cairo($rect-pic));

with Cairo::Context.new($arc-pic) {
  .line_width = 10.0;
  .arc( xc, yc, radius, angle1, angle2);
  .stroke;

  # draw helping lines
  .rgba( 1, 0.2, 0.2, 0.6);
  .line_width = 6.0;

  .arc( xc, yc, 10.0, 0, 2*pi);
  .fill;

  .arc( xc, yc, radius, angle1, angle1);
  .line_to( xc, yc);
  .arc( xc, yc, radius, angle2, angle2);
  .line_to( xc, yc);
  .stroke;
}


# Now we are finished drawing and create a texture to be able to set an image. A
# texture has the paintable role.
my N-Size() $n-size .= new( :$width, :$height);
my Gnome::Gdk4::Texture() $texture = $snapshot.to-paintable($n-size);
with my Gnome::Gtk4::Image $image .= new-from-paintable($texture) {
  .set-size-request( $width, $height);
}

with my Gnome::Gtk4::Frame $grid .= new-frame('My Drawing') {
  .set-margin-start(50);
  .set-margin-end(50);
  .set-margin-top(50);
  .set-margin-bottom(50);
  .set-child($image);
}

with my Window $window .= new-window {
  .register-signal( SH.new, 'stopit', 'close-request');
  .set-title('My new window');
  .set-child($grid);
  .set-size-request( 200, 200);

  .present;
}

$main-loop.run;
say 'done it';
