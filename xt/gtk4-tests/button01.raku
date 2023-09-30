

use Gnome::Gtk4::Button:api<2>;
use Gnome::Gtk4::Window:api<2>;
#use Gnome::Gtk4::Grid:api<2>;

constant \Window = Gnome::Gtk4::Window;
constant \Button = Gnome::Gtk4::Button;

my Button $button .= new-with-label('My First Button');
with my Window $window .= new-window {
  .set-child($button);
  .show;
}


sleep(3);