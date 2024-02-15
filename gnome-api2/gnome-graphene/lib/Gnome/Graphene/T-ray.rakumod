=comment Package: Graphene, C-Source: ray
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

unit class Gnome::Graphene::T-ray:auth<github:MARTIMM>:api<2>;
#-------------------------------------------------------------------------------
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------

class N-Ray:auth<github:MARTIMM>:api<2> is export is repr('CStruct') {

  has N-Object $.origin;
  has N-Object $.direction;

  submethod TWEAK (
    N-Object :$origin, N-Object :$direction, 
  ) {
    $!origin := $origin if ?$origin;
  $!direction := $direction if ?$direction;
}

  method COERCE ( $no --> N-Ray ) {
    note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
    nativecast( N-Ray, $no)
  }
}

#-------------------------------------------------------------------------------
#--[Enumerations]---------------------------------------------------------------
#-------------------------------------------------------------------------------
enum graphene_ray_intersection_kind_t is export <
  
>;

