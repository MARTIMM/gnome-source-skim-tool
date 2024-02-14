=comment Package: Graphene, C-Source: quaternion
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

unit class Gnome::Graphene::T-quaternion:auth<github:MARTIMM>:api<2>;
#-------------------------------------------------------------------------------
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------

class N-Quaternion:auth<github:MARTIMM>:api<2> is export is repr('CStruct') {

  has gfloat $.x;
  has gfloat $.y;
  has gfloat $.z;
  has gfloat $.w;

  submethod BUILD (
    gfloat :$!x, gfloat :$!y, gfloat :$!z, gfloat :$!w, 
  ) {
  }

  method COERCE ( $no --> N-Quaternion ) {
    note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
    nativecast( N-Quaternion, $no)
  }
}

