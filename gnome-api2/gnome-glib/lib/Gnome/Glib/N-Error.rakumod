# Command to generate: generate.raku -v -c Glib error
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

unit class N-Error:auth<github:MARTIMM>:api<2> is export is repr('CStruct');

has GQuark $.domain;
has gint $.code;
has Str $.message;

submethod BUILD (
  GQuark :$!domain, gint :$!code, Str :$!message, 
) {
}

method COERCE ( $no --> N-Error ) {
  note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
  nativecast( N-Error, $no)
}
