=comment Package: Graphene, C-Source: quad
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Gnome::N::GlibToRakuTypes:api<2>;

#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Graphene::T-quad:auth<github:MARTIMM>:api<2>;
#-------------------------------------------------------------------------------
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------

class N-Quad:auth<github:MARTIMM>:api<2> is export is repr('CStruct') {

  has gchar-pptr $.points;

  submethod BUILD (
    gchar-pptr :$!points, 
  ) {
  }

  method COERCE ( $no --> N-Quad ) {
    note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
    nativecast( N-Quad, $no)
  }
}

