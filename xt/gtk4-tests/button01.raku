

use Gnome::Glib::MainLoop;

use Gnome::Gtk4::Button:api<2>;
use Gnome::Gtk4::Window:api<2>;
#use Gnome::Gtk4::Grid:api<2>;

use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::X:api<2>;
#Gnome::N::debug(:on);


constant \Window = Gnome::Gtk4::Window;
constant \Button = Gnome::Gtk4::Button;


my Gnome::Glib::MainLoop $main-loop .= new;

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

my SH $sh .= new;
with my Button $button .= new-with-label('My First Button') {
  .register-signal( $sh, 'press', 'clicked');
}

with my Window $window .= new-window {
  .register-signal( $sh, 'stopit', 'close-request');
  .set-title('My new window');
  .set-child($button);
  .show;
}

$main-loop.run;
say 'done it';

