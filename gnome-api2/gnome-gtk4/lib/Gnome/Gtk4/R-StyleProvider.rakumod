=comment Package: Gtk4, C-Source: styleprovider
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;



use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;


#-------------------------------------------------------------------------------
#--[Role Declaration]-----------------------------------------------------------
#-------------------------------------------------------------------------------

unit role Gnome::Gtk4::R-StyleProvider:auth<github:MARTIMM>:api<2>;

#TM:1:_add_gtk_style_provider_signal_types:
method _add_gtk_style_provider_signal_types ( Str $class-name ) {
  self.add-signal-types( $class-name,
    :w0<gtk-private-changed>,
  );
}

