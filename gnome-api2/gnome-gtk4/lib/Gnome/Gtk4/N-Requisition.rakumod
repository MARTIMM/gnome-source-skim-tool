# Command to generate: generate.raku -c Gtk4 widget
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::N-GObject:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class N-Requisition:auth<github:MARTIMM>:api<2> is export is repr('CStruct');

has gint $.width;
has gint $.height;

submethod BUILD (
  gint :$!width, gint :$!height, 
) {
}

method COERCE ( $no --> N-Requisition ) {
  note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
  nativecast( N-Requisition, $no)
}
