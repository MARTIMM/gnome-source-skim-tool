
use Gnome::Gtk4::Button:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::N-GObject:api<2>;
use Gnome::N::X:api<2>;

#use trace;

my N-GObject() $no;
my Gnome::Gtk4::Button() ( $b1, $b2);

Gnome::N::debug(:on);
$b1 .= new-button('text');

# works
$no = $b1;
note $no.gist;

# works
note $b2.^can("COERCE").gist();
$b2 .= COERCE($no);

# error: Cannot find method 'is_dispatcher' on object of type BOOTCode
$b2 = $no;