
use Gnome::Gtk4::Button:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::X:api<2>;

my N-Object(Mu) $no;
my Gnome::Gtk4::Button(Mu) ( $b1, $b2);

#Gnome::N::debug(:on);

$b1 .= new-with-label('text');
note 'Button label b1: ', $b1.get-label;

# works
$no = $b1;
note $no.gist;

# works
note $b2.^can("COERCE").gist();
$b2 .= COERCE($no);
note 'Button label b2: ', $b2.get-label;

# error: Cannot find method 'is_dispatcher' on object of type BOOTCode
$b2 = $no;