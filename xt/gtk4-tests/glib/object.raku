use v6.d;

use NativeCall;
use Test;
use lib "gnome-api2/gnome-gobject/lib", "gnome-api2/gnome-native/lib";

use Gnome::GObject::N-Value:api<2>;
use Gnome::GObject::T-type:api<2>;
use Gnome::GObject::T-value:api<2>;

use Gnome::Gtk4::Label:api<2>;

use Gnome::Glib::T-quark:api<2>;

use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::X:api<2>;
#Gnome::N::debug(:on);


#-------------------------------------------------------------------------------
#my Gnome::GObject::T-type() $gt;

my Gnome::GObject::N-Value() $gv1;
my Gnome::GObject::N-Value() $gv2;

my N-Value() $ngv1;
my N-Value() $ngv2;

#-------------------------------------------------------------------------------
subtest 'Test properties of Gnome::Gtk4::Label', {

  with my Gnome::Gtk4::Label $label .= new-label {
    .set-text('abc def');
    is .get-text, 'abc def', 'label text set';

    $gv1 .= new(:type(G_TYPE_STRING));
    .get-property( 'label', $gv1);
    is $gv1.get-string, 'abc def', '.get-property() label property';

    $gv1.set-string('pqr xyz');
    .set-property( 'label', $gv1);
    is .get-text, 'pqr xyz', '.set-property() label property';

    $gv1 .= new(:type(G_TYPE_INT));
    .set-text("pqr xyz\njhgsdf\n");
    .get-property( 'lines', $gv1);
    is $gv1.get-int, -1, '.get-property() lines property';

#`{{
    my $nv1 = CArray[gboolean].new;
    my $nv2 = CArray[gboolean].new;
    .get(
      'wrap', CArray[gboolean], $nv1, Str, 'justify', CArray[gboolean], $nv2
    );
    ok ! $nv1[0], '.get() wrap property';
    ok ! $nv2[0], '.get() justify property';
}}
  }
}

#-------------------------------------------------------------------------------
subtest 'Test storage of data', {
  with my Gnome::Gtk4::Label $label .= new-label {
    $gv1 .= new(:type(G_TYPE_INT));
    $gv1.set-int(12345);
    .set-data( 'my-data', $gv1);

    $gv2 = .get-data('my-data');
    is $gv2.get-int, 12345, '.set-data() / .get-data() stored N-Value';

    my Gnome::Glib::T-quark $tq .= new;
    my GQuark $q = $tq.from-string('my-data2');
    $gv1.set-int(54321);
    .set-qdata( $q, $gv1);
    $gv2 = .get-qdata($q);
    is $gv2.get-int, 54321, '.set-qdata() / .get-qdata() stored N-Value with quark';

  }
}

#`{{
#-------------------------------------------------------------------------------
subtest 'Test referencing', {
  with my Gnome::Gtk4::Label $label .= new-label {
    note "$?LINE ", .is-floating, ' .is-floating() label is floating';
  }
}
}}

#-------------------------------------------------------------------------------
done-testing;

=finish



