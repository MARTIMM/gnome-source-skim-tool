
use v6.d;
use NativeCall;

use Gnome::Graphene::T-size:api<2>;
use Gnome::Graphene::N-Rect:api<2>;

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

my Gnome::Graphene::N-Rect $rect1 .= alloc;
$rect1.init( 0, 0, $w, $h);
my Gnome::Graphene::N-Rect $rect2 .= alloc;
$rect2.init( $w, 0, $w, $h);
my Gnome::Graphene::N-Rect $rect3 .= alloc;
$rect3.init( 0, $h, $w, $h);
my Gnome::Graphene::N-Rect $rect4 .= alloc;
$rect4.init( $w, $h, $w, $h);

my N-RGBA ( $r, $g, $b, $y);
$r .= new( :red(1e0), :green(0e0), :blue(0e0), :alpha(1e0));
$g .= new( :red(0e0), :green(1e0), :blue(0e0), :alpha(1e0));
$b .= new( :red(0e0), :green(0e0), :blue(1e0), :alpha(1e0));
$y .= new( :red(1e0), :green(1e0), :blue(0e0), :alpha(1e0));

my Gnome::Gtk4::Snapshot $snapshot .= new-snapshot;
$snapshot.append-color( $r, $rect1);
$snapshot.append-color( $g, $rect2);
$snapshot.append-color( $b, $rect3);
$snapshot.append-color( $y, $rect4);



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

with my Gnome::Gtk4::Window $window .= new-window {
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
#use Gnome::Graphene::T-rect:api<2>;
#use Gnome::Graphene::T-point:api<2>;
#use Gnome::Glib::N-Bytes:api<2>;
#use Gnome::Glib::T-array:api<2>;
#use Gnome::Glib::N-ByteArray:api<2>;
#use Gnome::GdkPixbuf::Pixbuf:api<2>;
#use Gnome::GdkPixbuf::T-core:api<2>;
#use Gnome::Gdk4::T-enums:api<2>;
#use Gnome::Gdk4::MemoryTexture:api<2>;
#use Gnome::Gdk4::N-RGBA:api<2>;

my N-Rect() $n-rect1 .= new(
  :origin(N-Point.new( :x(0e0), :y(0e0))),
  :size( N-Size.new( :width($w), :height($h)))
);

note "$?LINE $n-rect1.gist()";



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
