


use lib 'gnome-api2/gnome-native/lib', 'gnome-api2/gnome-gobject/lib',
  'gnome-api2/gnome-gtk4/lib';

use NativeCall;
use Gnome::N::N-GObject:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::GObject::Object;

use Gnome::Gtk4::Label:api<2>;


#my Gnome::GObject::Object $o;
Gnome::Gtk4::Label.gtk-initialize;

#exit;

my N-GObject $native-object;
my Gnome::Gtk4::Label $label;

note "$?LINE";
$native-object = new-label('label text');
note $native-object.gist;

note "$?LINE";
my Str $routine-name = 'gtk_label_new';
my Str $library = 'gtk-4';

note "$?LINE";
#my @parameterList = (Parameter.new(type => gchar-ptr));
#my $returns = N-GObject;
#my Signature $signature .= new( :params(|@parameterList), :$returns);
#note "$?LINE $routine-name, $signature.gist()";

my Callable $f = nativecast(
  :( Str --> N-GObject), cglobal( $library, 'gtk_label_new', gpointer)
#  $signature, cglobal( $library, 'gtk_label_new', Pointer)
);
note "$?LINE $f.gist()";

$native-object = $f('label text');
$label .= new(:$native-object);
note $label.gist;


note "$?LINE";


sub new-label ( Str --> N-GObject )
  is native('gtk-4')
  is symbol('gtk_label_new')
  { * }

