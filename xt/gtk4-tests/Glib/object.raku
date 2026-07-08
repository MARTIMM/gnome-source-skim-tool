use v6.d;

use NativeCall;
use Test;
use lib "gnome-api2/gnome-gobject/lib", "gnome-api2/gnome-native/lib";

use Gnome::GObject::N-Value:api<2>;
use Gnome::GObject::T-type:api<2>;
use Gnome::GObject::T-value:api<2>;

use Gnome::Gtk4::Label:api<2>;

use Gnome::N::X:api<2>;
#Gnome::N::debug(:on);


#-------------------------------------------------------------------------------
my Gnome::GObject::T-type() $gt;
my Gnome::GObject::N-Value() $gv;

my N-Value() $ngv1;
my N-Value() $ngv2;

#-------------------------------------------------------------------------------
subtest 'Test properties of Gnome::Gtk4::Label', {

  with my Gnome::Gtk4::Label $label .= new-label {
    .set-text('abc def');
    is .get-text, 'abc def', 'label text set';

    $ngv1 .= new;
    .get-property( 'label', $ngv1);
    $gv = $ngv1;
    is $gv.get-string, 'abc def', '.get-property() label property';

    $gv.set-string('pqr xyz');
    .set-property( 'label', $gv);
    is .get-text, 'pqr xyz', '.set-property() label property';

    $ngv1 .= new;
    .set-text("pqr xyz\njhgsdf\n");
    .get-property( 'lines', $ngv1);
    $gv = $ngv1;
    is $gv.get-int, -1, '.get-property() lines property';


    $ngv1 .= new;
    $ngv2 .= new;
Gnome::N::debug(:on);
    .get( 'wrap', $ngv1, 'justify', $ngv2);
    $gv = $ngv1;
    ok ! $gv.get-boolean, '.get() wrap property';
    $gv = $ngv2;
    ok ! $gv.get-boolean, '.get() justify property';
  }
}

#-------------------------------------------------------------------------------
done-testing;

=finish



