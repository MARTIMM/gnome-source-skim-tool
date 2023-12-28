use v6.d;

use Gnome::Gtk4::Label:api<2>;
use Gnome::Gtk4::Box:api<2>;
use Gnome::Gtk4::T-Enums:api<2>;
use Gnome::N::X:api<2>;
#Gnome::N::debug(:on);


class MyLabel is Gnome::Gtk4::Label {
  submethod BUILD ( Bool :$lw = False, Bool :$he = False, Int :$mt = 5 ) {
    with self {
      .set-use-markup(True);
      .set-hexpand($he);
      .set-wrap($lw);
      .set-justify(GTK_JUSTIFY_FILL);
      .set-halign(GTK_ALIGN_START);
      .set-valign(GTK_ALIGN_START);
      .set-margin-top($mt);
      .set-margin-start(2);

#      Gnome::Gtk4::StyleContext.new(
#        :native-object(.get-style-context)
#      ).add-class('QAQuestionLabel');
    }
  }
}


my MyLabel $t1 .= new-label( 'test1', :lw, :he);
note "hexpand: ", $t1.get-hexpand;
note "line-wrap: ", $t1.get-wrap;
note "margin top: ", $t1.get-margin-top;

my MyLabel $t2 .= new-with-mnemonic( '_test2', :10mt);
note "hexpand: ", $t2.get-hexpand;
note "line-wrap: ", $t2.get-wrap;
note "margin top: ", $t2.get-margin-top;


# Inherit a class with a role
class MyBox is Gnome::Gtk4::Box {
  method new ( ) {
    self.new-box( GTK_ORIENTATION_HORIZONTAL, 2);
  }
}

my MyBox $mb .= new;
$mb.set-orientation(GTK_ORIENTATION_VERTICAL);

try {
  $mb.unknown-method();
  CATCH {
    default { note "\n", .message; }
  }
}
