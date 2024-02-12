use v6.d;

use NativeCall;

use Cairo;
#class cairo_t is repr('CPointer') {}

use Gnome::Glib::N-MainLoop:api<2>;

use Gnome::Gtk4::DrawingArea:api<2>;
use Gnome::Gtk4::Window:api<2>;

use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::X:api<2>;
#Gnome::N::debug(:on);


#-------------------------------------------------------------------------------
constant \Window = Gnome::Gtk4::Window;
constant \DrawingArea = Gnome::Gtk4::DrawingArea;

my Gnome::Glib::N-MainLoop $main-loop .= new-mainloop;

#-------------------------------------------------------------------------------
class SH {
  method stopit ( --> gboolean ) {
    say 'close request';
    $main-loop.quit;

    0
  }
}

#-------------------------------------------------------------------------------
with my DrawingArea $draw .= new-drawingarea {
Gnome::N::debug(:on);
  .set-draw-func( &drawit, Pointer, &notify-function);
}

with my Window $window .= new-window {
  .register-signal( SH.new, 'stopit', 'close-request');
  .set-title('My Drawing In My Window');
  .set-size-request( 300, 300);
  .set-child($draw);
  .show;
}

$main-loop.run;
say 'done it';

#-------------------------------------------------------------------------------
sub drawit ( N-Object $d, cairo_t $cr is rw, int $w, int $h, Pointer $p ) {
return;
  my Cairo::Image $image .= create(Cairo::FORMAT_ARGB32, 128, 128);

  with my Cairo::Context $context .= new($image) {
    .rgb(0, 0.7, 0.9);
    .rectangle(10, 10, 50, 50);
    .fill :preserve; .rgb(1, 1, 1);
    .stroke
  };

#  $draw
}

#-------------------------------------------------------------------------------
sub notify-function(Pointer $data) {
  return;
}