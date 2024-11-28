
# Example from
# https://docs.gtk.org/gtk4/getting_started.html
use v6.d;

#use Gnome::N::GlibToRakuTypes:api<2>;
#use Gnome::N::X:api<2>;
#Gnome::N::debug(:on);

use Gnome::Gio::T-ioenums:api<2>;
use Gnome::Gtk4::Button:api<2>;
use Gnome::Gtk4::Grid:api<2>;
use Gnome::Gtk4::Application:api<2>;
use Gnome::Gtk4::ApplicationWindow:api<2>;
#use Gnome::Gtk4::T-application:api<2>;

constant Application = Gnome::Gtk4::Application;
constant ApplicationWindow = Gnome::Gtk4::ApplicationWindow;
constant Button = Gnome::Gtk4::Button;
constant Grid = Gnome::Gtk4::Grid;

class HelloWorldApp { ... }

with my HelloWorldApp $app .= new(:app-id<org.gtk.example>) {
  my Int $status = .run;#( @*ARGS.elems + 1, ( $*PROGRAM.Str, |@*ARGS));
  say "Exit status: $status";
}

class HelloWorldApp {
  has Application $!app handles <run>;

  submethod BUILD ( Str :$app-id ) {
    with $!app .= new-application( $app-id, G_APPLICATION_FLAGS_NONE) {
      .register-signal( self, 'do-work', 'activate');
      .register-signal( self, 'app-shutdown', 'shutdown');
    }
  }

  method do-work ( ) {
    say 'start the works';
    with my Button $button2 .= new-with-label('Goodbye') {
      .register-signal( self, 'b2-press', 'clicked');
      .set-sensitive(False);
    }

    with my Button $button1 .= new-with-label('Hello World') {
      .register-signal( self, 'b1-press', 'clicked', :$button2);
    }

    with my Grid $grid .= new-grid {
      .set-margin-top(30);
      .set-margin-bottom(30);
      .set-margin-start(30);
      .set-margin-end(30);

      .attach( $button1, 0, 0, 1, 1);
      .attach( $button2, 0, 1, 1, 1);
    }

    with my ApplicationWindow $win .= new-applicationwindow($!app) {
      .set-title('Two Buttons');
      .set-child($grid);
      .show;
    }
  }

  method b1-press ( Button() :_native-object($button1), Button :$button2 ) {
    say 'button1 pressed';
    $button2.set-sensitive(True);
    $button1.set-sensitive(False);
  }

  method b2-press ( ) {
    say 'button2 pressed';
    $!app.quit;
  }

  method stopit ( ) {
    say 'close request';
    $!app.quit;
  }
}



