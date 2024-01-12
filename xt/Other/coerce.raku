
use Gnome::Gtk4::Button:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::X:api<2>;

my N-Object(Mu) $no;
my Gnome::Gtk4::Button() ( $b1, $b2);

Gnome::N::debug(:on);

$b1 .= new-with-label('text');
note "$?LINE, ", 'Button label b1: ', $b1.get-label;

# works
$no = $b1;
note "$?LINE, ", $no.gist;

# works
note "$?LINE, ", $b2.^can("COERCE").gist();
$b2 .= COERCE($no);
note "$?LINE, ", 'Button label b2: ', $b2.get-label;

# error: Cannot find method 'is_dispatcher' on object of type BOOTCode
note "$?LINE, ", $b2.^can('is_dispatcher');
note "$?LINE, ", Any.new.^can('is_dispatcher');

$b2 = $no;
note "$?LINE, ", 'Button label b2: ', $b2.get-label;
