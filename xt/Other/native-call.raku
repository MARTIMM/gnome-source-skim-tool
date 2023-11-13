# small test to see if small program get segv too

use NativeCall;
use Gnome::N::N-Object;
use Gnome::N::GlibToRakuTypes;
use Gnome::N::NativeLib;

#enum GtkWindowType is export <
#  GTK_WINDOW_TOPLEVEL GTK_WINDOW_POPUP
#>;

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!
gtk_init();
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!

my N-Object $now = window-new(0);
my N-Object $nog = grid-new();

# Get a pointer to the sub, then cast it to a sub with the proper
# signature. after that, the sub can be called, returning a value.
my Callable $f = nativecast(
  :( --> N-Object ), cglobal( 'libgtk-3.so.0', 'gtk_grid_new', Pointer)
);

note "$?LINE $f.gist()";

my N-Object $no = $f();
note $no.gist();

sub gtk_init ( )
  is native(&gtk-lib)
  { * }

sub window-new ( GEnum $type --> N-Object )
  is native(&gtk-lib)
  is symbol('gtk_window_new')
  { * }

sub grid-new ( --> N-Object )
  is native(&gtk-lib)
  is symbol('gtk_grid_new')
  { * }
