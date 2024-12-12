use v6.d;

use Gnome::Gtk4::T-enums:api<2>;
use Gnome::Gtk4::Window:api<2>;
use Gnome::Gtk4::Grid:api<2>;
use Gnome::Gtk4::Button:api<2>;
use Gnome::Gtk4::Box:api<2>;
use Gnome::Gtk4::Label:api<2>;

use Gnome::Glib::N-MainLoop:api<2>;

use Gnome::N::N-Object:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;

#-------------------------------------------------------------------------------
class Dialog is Gnome::Gtk4::Window {
  has Gnome::Gtk4::Grid $!content;
  has Int $!content-count;

  has Gnome::Gtk4::Box $!button-row;
  has Gnome::Glib::N-MainLoop $!main-loop;

  #-----------------------------------------------------------------------------
  method new ( |c ) {
    self.new-window(|c);
  }

  #-----------------------------------------------------------------------------
  submethod BUILD ( Str :$dialog-title = '', :$transient-window ) {
    $!main-loop .= new-mainloop( N-Object, True);

    $!content-count = 0;
    with $!content .= new-grid {
      .set-margin-top(20);
      .set-margin-bottom(20);
      .set-margin-start(30);
      .set-margin-end(30);
      .set-row-spacing(10);
      .set-column-spacing(10);
    }

    $!button-row .= new-box( GTK_ORIENTATION_HORIZONTAL, 4);

    # Make a label which wil push all buttons to the left. These are
    # added using add-button()
    with my Gnome::Gtk4::Label $button-row-strut .= new-label {
      .set-text(' ');
      .set-halign(GTK_ALIGN_FILL);
      .set-hexpand(True);
      .set-wrap(False);
      .set-visible(True);
      .set-margin-top(10);
      .set-margin-bottom(10);
    }
    $!button-row.append($button-row-strut);

    with my Gnome::Gtk4::Box $box .= new-box( GTK_ORIENTATION_VERTICAL, 0) {
      .append($!content);
      .append($!button-row);
    }

    with self {
      .set-transient-for($transient-window);
      .set-destroy-with-parent(True);
      .set-modal(True);
      .set-size-request( 400, 100);
      .set-title($dialog-title);
      .set-child($box);
      .register-signal( self, 'close-dialog', 'destroy');
    }
  }

  #-----------------------------------------------------------------------------
  method add-content ( Str $text, Mu $widget ) {
    with my Gnome::Gtk4::Label $label .= new-label {
      .set-text($text);
      .set-hexpand(True);
      .set-halign(GTK_ALIGN_START);
      .set-margin-end(5);
    }

    $!content.attach( $label, 0, $!content-count, 1, 1);
    $!content.attach( $widget, 1, $!content-count, 1, 1);
    $!content-count++;
  }

  #-----------------------------------------------------------------------------
  method add-button ( Mu $object, Str $method, Str $button-label, *%options ) {
    my Gnome::Gtk4::Button $button .= new-button;
    $button.set-label($button-label);
    $button.register-signal( $object, $method, 'clicked', |%options);
    $!button-row.append($button);
  }

  #-----------------------------------------------------------------------------
  method show-dialog ( ) {
    self.set-visible(True);
    $!main-loop.run;
  }

  #-----------------------------------------------------------------------------
  method destroy-dialog ( ) {
    $!main-loop.quit;
    self.destroy;
    self.clear-object;
  }
}



#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
class MyApp::MessageDialog is Dialog {

  #-----------------------------------------------------------------------------
  submethod BUILD ( Str :$message ) {
    self.add-content( $message, Gnome::Gtk4::Label.new-label);
    self.set-title('Message Dialog');

    self.add-button( self, 'destroy-dialog', 'Ok');
    self.show-dialog;
  }
}



#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
my Gnome::Glib::N-MainLoop $my-main-loop .= new-mainloop;
class SH {
  #-----------------------------------------------------------------------------
  method stopit ( ) {
    say 'close request';
    $my-main-loop.quit;
  }

  #-----------------------------------------------------------------------------
  method show-msg ( ) {
    my MyApp::MessageDialog $msgd .= new(:message(Q:to/EOMSG/));
        Something terrible just happended.
        Could not find anything you asked for!
        Mea Culpa, I will retreat in my cellar
        and will commit the remains of my
        sorry digital live as a binary hermit
        EOMSG
  }
}


my SH $sh .= new;

with my Gnome::Gtk4::Button $b .= new-button {
  .set-margin-top(30);
  .set-margin-bottom(30);
  .set-margin-start(30);
  .set-margin-end(30);
  .set-label('show message');
#  .grab-focus(True);
  .register-signal( $sh, 'show-msg', 'clicked');
}

with my Gnome::Gtk4::Window $window .= new-window {

  .register-signal( $sh, 'stopit', 'close-request');
  .set-title('Message dialog replacement test');
  .set-size-request( 200, 200);
  .set-child($b);
#  .set-focus-child($b);
  .show;
}

$my-main-loop.run;
say 'done it';
