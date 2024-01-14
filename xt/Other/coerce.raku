
use Gnome::Gtk4::Button:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::X:api<2>;

my N-Object(Mu) $no;
my Gnome::Gtk4::Button() ( $b1, $b2, $b3);

#Gnome::N::debug(:on);

$b1 .= new-with-label('text');
note "$?LINE, ", 'Button label b1: ', $b1.get-label;

# works
$no = $b1;
note "$?LINE, ", $no.gist;

# works
note "$?LINE, ", $b2.^can("COERCE").gist();
$b2 .= COERCE($no);
note "$?LINE, ", 'Button label b2: ', $b2.get-label;

# error in older raku:
#   Cannot find method 'is_dispatcher' on object of type BOOTCode

# Seems to be repaired since
#    Welcome to Rakudo™ v2023.12-41-gbafa5ad46.
#    Implementing the Raku® Programming Language v6.d.
#    Built on MoarVM version 2023.12-14-gc3fea4f58.

$b3 = $no;
note "$?LINE, ", 'Button label b3: ', $b3.get-label;
