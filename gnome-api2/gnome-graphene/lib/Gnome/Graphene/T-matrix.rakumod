=comment Package: Graphene, C-Source: matrix
use v6.d;

use NativeCall;

use Gnome::N::GlibToRakuTypes:api<2>;
#use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Graphene::T-matrix:auth<github:MARTIMM>:api<2>;
#-------------------------------------------------------------------------------
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------

class N-Matrix:auth<github:MARTIMM>:api<2> is export is repr('CStruct') {

  has N-Object $.value;

  submethod TWEAK (
    N-Object :$value, 
  ) {
    $!value := $value if ?$value;
}

  method COERCE ( $no --> N-Matrix ) {
    note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
    nativecast( N-Matrix, $no)
  }
}

