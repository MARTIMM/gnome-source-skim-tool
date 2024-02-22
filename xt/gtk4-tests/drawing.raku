
use v6.d;
use NativeCall;

use Gnome::Graphene::N-Size:api<2>;

use Gnome::Glib::N-MainLoop:api<2>;
use Gnome::Glib::N-Bytes:api<2>;
use Gnome::Glib::T-array:api<2>;
use Gnome::Glib::N-ByteArray:api<2>;

use Gnome::GdkPixbuf::Pixbuf:api<2>;
use Gnome::GdkPixbuf::T-core:api<2>;

use Gnome::Gdk4::MemoryTexture:api<2>;
use Gnome::Gdk4::Texture:api<2>;
use Gnome::Gdk4::T-enums:api<2>;

use Gnome::Gtk4::Snapshot:api<2>;
use Gnome::Gtk4::Image:api<2>;
use Gnome::Gtk4::Window:api<2>;
#use Gnome::Gtk4::Grid:api<2>;

use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::X:api<2>;
Gnome::N::debug(:on);

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
my SH $sh .= new;

my Int $width = 100;
my Int $height = 100;

my Gnome::Graphene::N-Size $size .= alloc;
$size.init( $width, $height);

my Gnome::Gtk4::Snapshot $snapshot .= new-snapshot;
my N-Object() $n-paintable = $snapshot.to-paintable($size);
my Gnome::Gdk4::Texture $texture .= new(:native-object($n-paintable));

#`{{
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
}}

my Gnome::Gtk4::Image $image .= new-from-paintable($texture);

with my Window $window .= new-window {
  .register-signal( $sh, 'stopit', 'close-request');
  .set-title('My new window');
  .set-child($image);
  .set-size-request( 200, 200);
  .show;
}

$main-loop.run;
say 'done it';

