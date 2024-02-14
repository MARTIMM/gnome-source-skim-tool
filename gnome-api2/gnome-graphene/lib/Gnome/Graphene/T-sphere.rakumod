=comment Package: Graphene, C-Source: sphere
use v6.d;

use NativeCall;

use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::N-Object:api<2>;

#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------
unit class Gnome::Graphene::T-sphere:auth<github:MARTIMM>:api<2>;
#-------------------------------------------------------------------------------
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------

class N-Sphere:auth<github:MARTIMM>:api<2> is export is repr('CStruct') {

  has N-Object $.center;
  has gfloat $.radius;

  submethod BUILD (
    gfloat :$!radius, 
  ) {
  }

  submethod TWEAK (
    N-Object :$center, 
  ) {
    $!center := $center if ?$center;
}

  method COERCE ( $no --> N-Sphere ) {
    note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
    nativecast( N-Sphere, $no)
  }
}

