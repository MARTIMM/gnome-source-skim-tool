use v6.d;
use NativeCall;

use Gnome::N::NativeLib;
use Gnome::N::N-Object;
use Gnome::N::X;
Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
sub gtk_button_new_with_label ( Str $label --> N-Object )
  is native(&gtk-lib) is export { * }

sub gtk_button_get_label ( N-Object $button --> Str )
  is native(&gtk-lib) is export { * }

#-------------------------------------------------------------------------------
my Callable $s;

my N-Object $o = call-native-sub( 'gtk_button_new_with_label', Any);
#my N-Object $o = &gtk_button_new_with_label("abc");
note "D: ", $o.defined, ', ', $o.perl;
note "L: ", &gtk_button_get_label($o);


sub call-native-sub ( Str $name, N-Object, $o, |c --> Any ) {

  CATCH { test-catch-exception( $_, $name); }

  $s = {try &::($name);}
  note "S: ", $s.perl, ', ', $s.signature;

  test-call( $s, Any, |c)
}
