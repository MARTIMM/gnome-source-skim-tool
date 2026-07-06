#!/usr/bin/env raku

use v6.d;

use Gnome::Glib::N-MainLoop;

use Gnome::Gtk4::GestureClick:api<2>;
use Gnome::Gtk4::Window:api<2>;

use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::X:api<2>;
#Gnome::N::debug(:on);


#-------------------------------------------------------------------------------
constant Window = Gnome::Gtk4::Window;
constant GestureClick = Gnome::Gtk4::GestureClick;

#-------------------------------------------------------------------------------
my Gnome::Glib::N-MainLoop $main-loop .= new-mainloop( N-Object, True);

#-------------------------------------------------------------------------------
class SH {
  has Int $!click-count = 0;

  method stopit ( --> gboolean ) {
    say 'close request';
    $main-loop.quit;

    0
  }

  method stopped ( ) {
    say "button is pressed $!click-count times";
    $!click-count = 0;
  }

  method press (
    Int $nbr-buttons, Rat() $x, Rat() $y,
    GestureClick() :_native-object($gc)
  ) {
#    say "$nbr-buttons button\(s) pressed";
    $!click-count = $nbr-buttons;
    say "$gc.get-current-button() mouse button is pressed";
  }
}

#-------------------------------------------------------------------------------
my SH $sh .= new;

with my GestureClick $click-gesture .= new-gestureclick {
  $click-gesture.set-button(0);
  .register-signal( $sh, 'press', 'pressed');
  .register-signal( $sh, 'stopped', 'stopped');
}

with my Window $window .= new-window {
  .register-signal( $sh, 'stopit', 'close-request');
  .add-controller($click-gesture);

  .set-title('My mouse buttons test window');
  .present;
}

$main-loop.run;
say 'done it';

