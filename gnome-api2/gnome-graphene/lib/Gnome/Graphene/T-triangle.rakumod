=comment Package: Graphene, C-Source: triangle
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

unit class Gnome::Graphene::T-triangle:auth<github:MARTIMM>:api<2>;
#-------------------------------------------------------------------------------
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------

class N-Triangle:auth<github:MARTIMM>:api<2> is export is repr('CStruct') {

  has N-Object $.a;
  has N-Object $.b;
  has N-Object $.c;

  submethod TWEAK (
    N-Object :$a, N-Object :$b, N-Object :$c, 
  ) {
    $!a := $a if ?$a;
  $!b := $b if ?$b;
  $!c := $c if ?$c;
}

  method COERCE ( $no --> N-Triangle ) {
    note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
    nativecast( N-Triangle, $no)
  }
}

