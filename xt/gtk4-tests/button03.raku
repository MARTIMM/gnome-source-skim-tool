
#my $t0 = now;

use Gnome::Glib::N-MainLoop:api<2>;

#use Gnome::Gtk4::Button:api<2>;
use Gnome::Gtk4::ToggleButton:api<2>;
use Gnome::Gtk4::Window:api<2>;
use Gnome::Gtk4::Frame:api<2>;
use Gnome::Gtk4::Box:api<2>;
use Gnome::Gtk4::Label:api<2>;
use Gnome::Gtk4::Image:api<2>;
use Gnome::Gtk4::T-enums:api<2>;

use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::N-Object:api<2>;
#use Gnome::N::X:api<2>;
#Gnome::N::debug(:on);


constant Window = Gnome::Gtk4::Window;
constant ToggleButton = Gnome::Gtk4::ToggleButton;
constant Frame = Gnome::Gtk4::Frame;
constant HBox = Gnome::Gtk4::Box;
constant Image = Gnome::Gtk4::Image;
constant Label = Gnome::Gtk4::Label;

class ToggleDisplay {
  has Gnome::Glib::N-MainLoop $!main-loop;

  submethod BUILD ( ) {
    $!main-loop .= new-mainloop( N-Object, True);

    with my ToggleButton $toggle-button .= new-togglebutton {
      .set-child(self.make-led-text-widget( 'Busy', True));
      .register-signal( self, 'toggle', 'toggled');
      .set-active(True);
    }

    with my Frame $frame .= new-frame {
      .set-margin-top(30);
      .set-margin-bottom(30);
      .set-margin-start(30);
      .set-margin-end(30);

      .set-child($toggle-button);
    }

    with my Window $window .= new-window {
      .register-signal( self, 'stopit', 'close-request');
      .set-title('Toggle Display!');
      .set-child($frame);

      .present;
    }

    $!main-loop.run;
  }

  method make-led-text-widget (
    Str:D $purpose, Bool:D $state --> Gnome::Gtk4::Box
  ) {
    my Gnome::Gtk4::Box $hbox .= new-box( GTK_ORIENTATION_HORIZONTAL, 1);

    my Str $icons = '/home/marcel/Graphics/IconsArchive/Icons/32n/ledIcon/';
    my Image $led-image .= new-image;
    my Str $image = $state ?? 'green-on-32.png' !! 'green-off-32.png';
    $led-image.set-from-file($icons ~ $image);
    $hbox.append($led-image);

    my Label $text .= new-label($purpose);
    $hbox.append($text);

    $hbox
  }

  method stopit ( --> gboolean ) {
    $!main-loop.quit;

    0
  }

  method toggle ( ToggleButton() :_native-object($toggle-button) ) {
    my Bool $state = $toggle-button.get-active;
    my Gnome::Gtk4::Box $widget = self.make-led-text-widget( 'Busy', $state);
    $toggle-button.set-child($widget);
  }
}

ToggleDisplay.new;

