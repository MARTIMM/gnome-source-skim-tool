use v6.d;

use NativeCall;
use Test;
#use lib "gnome-api2/gnome-gobject/lib";#, "gnome-api2/gnome-native/lib";

use Gnome::GObject::N-Value:api<2>;
use Gnome::GObject::T-type:api<2>;
use Gnome::GObject::T-value:api<2>;

use Gnome::Gtk4::Label:api<2>;

use Gnome::N::X:api<2>;
#Gnome::N::debug(:on);


#-------------------------------------------------------------------------------
my Gnome::GObject::T-type() $gt;
my Gnome::GObject::N-Value() $gv;

my N-Value() $ngv .= new;

#-------------------------------------------------------------------------------
subtest 'test properties of Gnome::Gtk4::Label', {

  with my Gnome::Gtk4::Label $label .= new-label {
    .set-text('abc def');
    is .get-text, 'abc def', 'label text set';

    .get-property( 'label', $ngv);
    $gv = $ngv;
    is $gv.get-string, 'abc def', 'label property matches with text';

    $gv.set-string('pqr xyz');
    .set-property( 'label', $gv);
    is .get-text, 'pqr xyz', 'label text modified using property ';

    $ngv .= new;
    .set-text("pqr xyz\njhgsdf\n");
    .get-property( 'lines', $ngv);
    $gv = $ngv;
    is $gv.get-int, -1, 'default lines property set to -1';
  }
}

#-------------------------------------------------------------------------------
done-testing;

=finish



