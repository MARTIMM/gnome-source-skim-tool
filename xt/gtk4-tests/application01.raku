
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::X:api<2>;
#Gnome::N::debug(:on);

use Gnome::Gio::T-Ioenums:api<2>;

use Gnome::Gtk4::Application:api<2>;
use Gnome::Gtk4::ApplicationWindow:api<2>;
#use Gnome::Gtk4::T-Application:api<2>;

constant \Application = Gnome::Gtk4::Application;
constant \ApplicationWindow = Gnome::Gtk4::ApplicationWindow;

class App {
  method do-work ( Gnome::Gtk4::Application :_widget($app) ) {

    with my ApplicationWindow $win .= new-applicationwindow($app) {
      .set-title('Window');
      .set-default-size( 400, 200);
      .show;
    }
  }
}

with my Application $app .=
     new-application( "org.gtk.example", G_APPLICATION_FLAGS_NONE) {

  .register-signal( App.new, 'do-work', 'activate');
  my List $status = .run( @*ARGS.elems + 1, ( $*PROGRAM.Str, |@*ARGS));

  say "Exit status: $status.gist()";
}



