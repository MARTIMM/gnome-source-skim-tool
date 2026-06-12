#!/usr/bin/env raku

use v6.d;
#use lib '/home/marcel/Languages/Raku/Projects/gnome-source-skim-tool/gnome-api2/gnome-gtk4/lib';
use lib '/home/marcel/Languages/Raku/Projects/GnomeTools/lib';

use GnomeTools::Gtk::Application;

use Gnome::Gtk4::Widget:api<2>;
use Gnome::Gtk4::Frame:api<2>;
use Gnome::Gtk4::ShortcutController:api<2>;
use Gnome::Gtk4::Shortcut:api<2>;
use Gnome::Gtk4::ShortcutTrigger:api<2>;
use Gnome::Gtk4::CallbackAction:api<2>;
use Gnome::Gtk4::T-enums:api<2>;

use Gnome::Gdk4::T-enums:api<2>;

use Gnome::Gio::SimpleAction:api<2>;
use GnomeTools::Gio::Menu;

use Gnome::N::N-Object:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;

constant Widget = Gnome::Gtk4::Widget;
constant Frame = Gnome::Gtk4::Frame;
constant ShortcutController = Gnome::Gtk4::ShortcutController;
constant Shortcut = Gnome::Gtk4::Shortcut;
constant CallbackAction = Gnome::Gtk4::CallbackAction;
constant ShortcutTrigger = Gnome::Gtk4::ShortcutTrigger;
#constant  = Gnome::Gtk4::;

#-------------------------------------------------------------------------------
class Helper {
  method f6trigger ( N-Object $parameter ) {
    note "F6 pressed";
  }
  method f11trigger ( ) {
    note "F11 pressed";
  }
}

#-------------------------------------------------------------------------------
class SCTest {
  constant APP_ID = 'ShortcutTest.myapp';

  has GnomeTools::Gtk::Application $!application;
  has Helper $!helper;

  submethod BUILD ( ) {
    $!helper .= new;

    with $!application .= new(:app-id(APP_ID)) {
      .set-activate( self, 'activate');
#      .set-startup( self, 'startup');
#      .set-shutdown( self, 'shutdown');
#      .process-local-options( self, 'local-options');
#      .process-remote-options( self, 'remote-options');

      .run;
    }
  }
 
  method activate ( ) {
    $!application.set-window-content(
      self.window-content, self.menu, :title("Application Title")
    );
  }

  method menu ( --> GnomeTools::Gio::Menu ) {
    my GnomeTools::Gio::Menu $bar .= new;
    my GnomeTools::Gio::Menu $m1 .= new( :parent-menu($bar), :name<File>);
    $m1.item( 'Quit', self, 'file-quit');

    $bar
  }

  method file-quit ( N-Object $parameter ) {
    note 'File Quit';
    $!application.quit
  }

  method window-content ( --> Widget ) {

    # First method
    my Gnome::Gio::SimpleAction $action;
    $action .= new-simpleaction( "f6trigger", gpointer);
    $action.register-signal( $!helper, 'f6trigger', 'activate');
    $!application.add-action($action);
    $!application.set-accels-for-action( 'app.f6trigger', 'F6');

    # Second method
    my ShortcutTrigger $st .= parse-string('F11');
    my CallbackAction $ca .= new-callbackaction(
      sub ( N-Object $no, N-Object $, gpointer $ ) {
        $!helper.f11trigger
      }, gpointer, gpointer
    );
    my Shortcut $sc .= new-shortcut( $st, $ca);

    with my ShortcutController $scc .= new-shortcutcontroller() {
      .set-scope(GTK_SHORTCUT_SCOPE_GLOBAL);
      .add-shortcut($sc);
    }

    with my Frame $frame .= new-frame('Shortcut key test') {
      .set-size-request( 500, 500);
      .add-controller($scc);
    }

    $frame
  }
}

#-------------------------------------------------------------------------------
my SCTest $app .= new;
#exit($app.run);

say 'done it';









=finish

#-------------------------------------------------------------------------------
I usually use actions for that, but there seems to be another way:

    create a Gtk.ShortcutController
    add the controller to your widget (window?) with Gtk.Widget.add_controller
    create a Gtk.Shortcut.new
        use Gtk.ShortcutTrigger.parse_string to create the trigger from a keyboard shortcut description
        use a Gtk.CallbackAction.new for the shortcutaction (this is where you specify printmsg as callback, but make sure it maches this signature: Gtk.ShortcutFunc)
    add the shortcut to the controller with Gtk.ShortcutController.add_shortcut
