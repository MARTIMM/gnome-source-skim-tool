# Command to generate: generate.raku -c Glib slist
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class N-SList:auth<github:MARTIMM>:api<2> is export is repr('CStruct');

has gpointer $.data;
has N-SList $.next;

submethod BUILD (
  gpointer :$!data, N-SList :$!next, 
) {
}

method COERCE ( $no --> N-SList ) {
  note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
  nativecast( N-SList, $no)
}
