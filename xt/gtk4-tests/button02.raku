
my $t0 = now;

use Gnome::Glib::MainLoop;

use Gnome::Gtk4::Button:api<2>;
use Gnome::Gtk4::Window:api<2>;
use Gnome::Gtk4::Grid:api<2>;

use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::X:api<2>;
#Gnome::N::debug(:on);


constant \Window = Gnome::Gtk4::Window;
constant \Button = Gnome::Gtk4::Button;
constant \Grid = Gnome::Gtk4::Grid;


my Gnome::Glib::MainLoop $main-loop .= new;

class SH {
  method stopit ( --> gboolean ) {
    say 'close request';
    $main-loop.quit;

    0
  }

  method b1-press ( Button :_widget($button1), Button :$button2 ) {
    say 'button1 pressed';
    $button2.set-sensitive(True);
    $button1.set-sensitive(False);
  }

  method b2-press ( ) {
    say 'button2 pressed';
    $main-loop.quit;
  }
}

my SH $sh .= new;
with my Button $button2 .= new-with-label('Goodbye') {
  .register-signal( $sh, 'b2-press', 'clicked');
  .set-sensitive(False);
}

with my Button $button1 .= new-with-label('Hello World') {
  .register-signal( $sh, 'b1-press', 'clicked', :$button2);
}

with my Grid $grid .= new-grid {
  .attach( $button1, 0, 0, 1, 1);
  .attach( $button2, 0, 1, 1, 1);
}

with my Window $window .= new-window {
  .register-signal( $sh, 'stopit', 'close-request');
  .set-title('Hello GTK!');
  .set-child($grid);
  .show;
}

note "Set up time: ", now - $t0;          # 0.27102656
$main-loop.run;
say 'done it';

