
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
use Gnome::Gtk4::Grid:api<2>;

use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::N-Object:api<2>;
#use Gnome::N::X:api<2>;
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
}

#-------------------------------------------------------------------------------
my Num() $width = 100;
my Num() $height = 100;
my Num() $w = $width/2;
my Num() $h = $height/2;

# Doing rectangles more low level
my N-Rect() $n-rect1 .= new(
  :origin(N-Point.new( :x(0), :y(0))),
  :size( N-Size.new( :width($w), :height($h)))
);

my N-Rect() $n-rect2 .= new(
  :origin(N-Point.new( :x($w), :y(0))),
  :size( N-Size.new( :width($w), :height($h)))
);

my N-Rect() $n-rect3 .= new(
  :origin(N-Point.new( :x(0), :y($h))),
  :size( N-Size.new( :width($w), :height($h)))
);

my N-Rect() $n-rect4 .= new(
  :origin(N-Point.new( :x($w), :y($h))),
  :size( N-Size.new( :width($w), :height($h)))
);

my N-RGBA ( $r, $g, $b, $y);
$r .= new( :red(1e0), :green(0e0), :blue(0e0), :alpha(0.2e0));
$g .= new( :red(0e0), :green(1e0), :blue(0e0), :alpha(0.2e0));
$b .= new( :red(0e0), :green(0e0), :blue(1e0), :alpha(0.2e0));
$y .= new( :red(1e0), :green(1e0), :blue(0e0), :alpha(0.2e0));

my Gnome::Gtk4::Snapshot $snapshot .= new-snapshot;
$snapshot.append-color( $r, $n-rect1);
$snapshot.append-color( $g, $n-rect2);
$snapshot.append-color( $b, $n-rect3);
$snapshot.append-color( $y, $n-rect4);

my Gnome::Graphene::N-Rect $rect-pic .= alloc;
$rect-pic.init( 0, 0, $width, $height);

# Next is one of the examples found in the Cairo distro of Time
constant xc = 50.0;
constant yc = 50.0;
constant radius = 50.0;
constant angle1 = 45.0  * (pi/180.0);   # angles are specified
constant angle2 = 180.0 * (pi/180.0);   # in radians

my Cairo::cairo_t $arc-pic = nativecast(
  Cairo::cairo_t, $snapshot.append-cairo($rect-pic)
);

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

with my Gnome::Gtk4::Grid $grid .= new-grid {
  .set-margin-start($w);
  .set-margin-top($h);
  .attach( $image, 0, 0, 1, 1);
}

with my Window $window .= new-window {
  .register-signal( SH.new, 'stopit', 'close-request');
  .set-title('My new window');
  .set-child($grid);
  .set-size-request( 200, 200);
  .show;
}

$main-loop.run;
say 'done it';











=finish

#use Gnome::Graphene::N-Size:api<2>;
#use Gnome::Graphene::N-Rect:api<2>;
#use Gnome::Glib::N-Bytes:api<2>;
#use Gnome::Glib::T-array:api<2>;
#use Gnome::Glib::N-ByteArray:api<2>;
#use Gnome::GdkPixbuf::Pixbuf:api<2>;
#use Gnome::GdkPixbuf::T-core:api<2>;

#use Gnome::Gdk4::MemoryTexture:api<2>;
#use Gnome::Gdk4::T-enums:api<2>;
#use Gnome::Gdk4::N-RGBA:api<2>;



my N-Rect() $n-rect1 .= new(
  :origin(N-Point.new( :x(0e0), :y(0e0))),
  :size( N-Size.new( :width($w), :height($h)))
);





my Int $row-stride = Gnome::GdkPixbuf::Pixbuf.new.calculate-rowstride(
  GDK_COLORSPACE_RGB,
  True,                     # has alpha
  8,                        # 8 bits
  $width, $height
);

die 'rowstride not calculated' if $row-stride == -1;

my Buf $data .= new( 0 xx ($row-stride * $height));
my Gnome::Glib::N-Bytes $b .= new-bytes(
  nativecast( Pointer, $data),
  $row-stride * $height
);

my Gnome::Gdk4::Texture $texture .= new(
  :native-object(
    Gnome::Gdk4::MemoryTexture.new-memorytexture(
      $width, $height, GDK_MEMORY_R8G8B8A8,
      $b, $row-stride
    )
  )
);
