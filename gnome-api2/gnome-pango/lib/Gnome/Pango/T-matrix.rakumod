=comment Package: Pango, C-Source: matrix
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

unit class Gnome::Pango::T-matrix:auth<github:MARTIMM>:api<2>;
#-------------------------------------------------------------------------------
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------

class N-Matrix:auth<github:MARTIMM>:api<2> is export is repr('CStruct') {

  has gdouble $.xx;
  has gdouble $.xy;
  has gdouble $.yx;
  has gdouble $.yy;
  has gdouble $.x0;
  has gdouble $.y0;

  submethod BUILD (
    gdouble :$!xx, gdouble :$!xy, gdouble :$!yx, gdouble :$!yy, gdouble :$!x0, gdouble :$!y0, 
  ) {
  }

  method COERCE ( $no --> N-Matrix ) {
    note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
    nativecast( N-Matrix, $no)
  }
}

