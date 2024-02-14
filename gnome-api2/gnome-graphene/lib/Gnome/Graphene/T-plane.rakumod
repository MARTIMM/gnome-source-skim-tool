=comment Package: Graphene, C-Source: plane
use v6.d;
#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;

#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Graphene::T-plane:auth<github:MARTIMM>:api<2>;
#-------------------------------------------------------------------------------
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------

class N-Plane:auth<github:MARTIMM>:api<2> is export is repr('CStruct') {

  has N-Object $.normal;
  has gfloat $.constant;

  submethod BUILD (
    gfloat :$!constant, 
  ) {
  }

  submethod TWEAK (
    N-Object :$normal, 
  ) {
    $!normal := $normal if ?$normal;
}

  method COERCE ( $no --> N-Plane ) {
    note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
    nativecast( N-Plane, $no)
  }
}

