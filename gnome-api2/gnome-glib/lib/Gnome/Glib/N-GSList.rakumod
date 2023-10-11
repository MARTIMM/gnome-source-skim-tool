# Command to generate: generate.raku -c Glib slist
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


#use Gnome::Glib::N-GSList:api<2>;
#use Gnome::N::GlibToRakuTypes:api<2>;
#use Gnome::N::N-GObject:api<2>;
#use Gnome::N::NativeLib:api<2>;
#use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class N-GSList:auth<github:MARTIMM>:api<2> is export is repr('CPointer');

#`{{
has gpointer $.data;
has N-GSList _UA_ $.next;

submethod BUILD (
  gpointer :$!data, N-GSList _UA_ :$!next, 
) {
}

method COERCE ( $no --> N-GSList ) {
  note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
  nativecast( N-GSList, $no)
}
}}