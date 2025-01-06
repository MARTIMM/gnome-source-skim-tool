=comment Package: Gdk4, C-Source: rgba
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

unit class Gnome::Gdk4::T-rgba:auth<github:MARTIMM>:api<2>;
#-------------------------------------------------------------------------------
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------

class N-RGBA:auth<github:MARTIMM>:api<2> is export is repr('CStruct') {

  has gfloat $.red;
  has gfloat $.green;
  has gfloat $.blue;
  has gfloat $.alpha;

  submethod BUILD (
    Num()  :$!red, Num()  :$!green, Num()  :$!blue, Num()  :$!alpha, 
  ) {
  }

  method COERCE ( $no --> N-RGBA ) {
    note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
    nativecast( N-RGBA, $no)
  }
}

