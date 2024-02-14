=comment Package: Graphene, C-Source: euler
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

unit class Gnome::Graphene::T-euler:auth<github:MARTIMM>:api<2>;
#-------------------------------------------------------------------------------
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------

class N-Euler:auth<github:MARTIMM>:api<2> is export is repr('CStruct') {

  has N-Object $.angles;
  has GEnum $.order;           # graphene_euler_order_t

  submethod BUILD (
    GEnum :$order, 
  ) {
    $!order = $order.value if ?$order;
}

  submethod TWEAK (
    N-Object :$angles, 
  ) {
    $!angles := $angles if ?$angles;
}

  method COERCE ( $no --> N-Euler ) {
    note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
    nativecast( N-Euler, $no)
  }
}

#-------------------------------------------------------------------------------
#--[Enumerations]---------------------------------------------------------------
#-------------------------------------------------------------------------------
enum graphene_euler_order_t is export <
  
>;

