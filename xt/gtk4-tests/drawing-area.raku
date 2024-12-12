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
  method stopit () {
    say 'close request';
    $main-loop.quit;
  }
}

#-------------------------------------------------------------------------------
with my DrawingArea $draw .= new-drawingarea {
Gnome::N::debug(:on);
#  .set-draw-func( &drawit, Pointer, &notify-function);
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
sub drawit ( N-Object $d, Cairo::cairo_t $cr, gint $w, gint $h, gpointer $p ) {
  with my Cairo::Context $context .= new($cr) {
    .rgb(0, 0.7, 0.9);
    .rectangle(10, 10, 50, 50);
    .fill :preserve;
    .rgb(1, 1, 1);
    .stroke;

    .rgb(0.5, 0.0, 0.9);
    .rectangle(90, 35, 110, 110);
    .fill :preserve;
    .rgb(1, 1, 1);
    .stroke;

    .rgb(0.8, 0.8, 0);
    .rectangle(20, 70, 120, 170);
    .fill :preserve;
    .rgb(1, 1, 1);
    .stroke;

    .rgb(0, 0.7, 0.0);
    .rectangle(130, 130, 150, 150);
    .fill :preserve;
    .rgb(1, 1, 1);
    .stroke;
  };
}

#-------------------------------------------------------------------------------
# Does not seem to be called when pointer to user data is undefined
sub notify-function(gpointer $data) {
note '===';
}
