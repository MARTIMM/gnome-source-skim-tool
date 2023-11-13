use v6.d;
use Test;

use Gnome::N::N-Object;
use Gnome::Gtk3::Window;
use Gnome::Gdk3::Visual;
use Gnome::N::X;


#-------------------------------------------------------------------------------
my Gnome::Gtk3::Window $w;
with $w .= new {
  .set-title('N-Object coercion');
  .show-all;
}

#Gnome::N::debug(:on);

my N-Object() $no = $w.get-visual-rk;
is $no.^name, 'N-Object', 'TopLevelClassSupport N-Object()';

$no = $w.get-visual-rk.N-Object;
is $no.^name, 'N-Object', 'TopLevelClassSupport N-Object()';


$no = $w;
my Gnome::Gtk3::Window(N-Object) $w2 = $no;
is $w2.get-title, 'N-Object coercion', 'TopLevelClassSupport COERCE()';


is $no(Gnome::Gtk3::Window).get-title, 'N-Object coercion', 'N-Object CALL-ME(gnome type)';

is $no('Gnome::Gtk3::Window').get-title, 'N-Object coercion', 'N-Object CALL-ME(Str)';

is $no().get-title, 'N-Object coercion', 'N-Object CALL-ME()';
#TODO  - needed?: is $no.get-title, 'N-Object coercion', 'N-Object CALL-ME()';


my Gnome::Gdk3::Visual() $visual = $w.get-visual;
is $visual.^name, 'Gnome::Gdk3::Visual', 'assign from no';



#-------------------------------------------------------------------------------
done-testing;
