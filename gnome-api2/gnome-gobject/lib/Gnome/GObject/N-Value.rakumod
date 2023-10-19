# Command to generate: gnome-source-skim-tool.raku -v -c GObject value
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

unit class N-Value:auth<github:MARTIMM>:api<2> is export is repr('CStruct');

# Data is a union. We do not use it but GTK does, so here it is
# only set to a type with 64 bits for the longest field in the union.

has GType $.g-type is rw;
has gint64 $!g-data;

submethod TWEAK {
  $!g-type = 0;
  $!g-data = 0;
}

method COERCE ( $no --> N-Value ) {
  note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
  nativecast( N-Value, $no)
}
