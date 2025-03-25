=comment Package: Gsk4, C-Source: roundedrect
use v6.d;
#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Cairo;


use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;

#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gsk4::T-roundedrect:auth<github:MARTIMM>:api<2>;
#-------------------------------------------------------------------------------
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------

class N-RoundedRect:auth<github:MARTIMM>:api<2> is export is repr('CStruct') {

  has N-Object $.bounds;
  has gchar-pptr $.corner;

  submethod BUILD (
    gchar-pptr :$!corner, 
  ) {
  }

  submethod TWEAK (
    N-Object :$bounds, 
  ) {
    $!bounds := $bounds if ?$bounds;
}

  method COERCE ( $no --> N-RoundedRect ) {
    note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
    nativecast( N-RoundedRect, $no)
  }
}

