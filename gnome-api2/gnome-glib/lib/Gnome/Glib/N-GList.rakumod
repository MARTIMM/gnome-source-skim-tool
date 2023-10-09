# Command to generate: generate.raku -v -c -t Glib list record
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

unit class N-GList:auth<github:MARTIMM>:api<2> is export is repr('CPointer');

#has gpointer $.data;
#has N-GList $.next;
#has N-GList $.prev;

#`{{
method COERCE ( $no --> N-GList ) {
  note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
  nativecast( N-GList, $no)
}
}}