

use Gnome::Glib::MainContext;

use Gnome::Gtk4::Button:api<2>;
use Gnome::Gtk4::Window:api<2>;
#use Gnome::Gtk4::Grid:api<2>;

constant \Window = Gnome::Gtk4::Window;
constant \Button = Gnome::Gtk4::Button;


my Bool $*exit-program = False;

with my Button $button .= new-with-label('My First Button') {
#  .show;
}

with my Window $window .= new-window {
  .set-title('My new window');
  .set-child($button);
  .show;
}

my Gnome::Glib::MainContext $main-context .= new;
while !$*exit-program { $main-context.iteration(True) }
