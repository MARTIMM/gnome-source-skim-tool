=comment Package: GIRepo, C-Source: gibaseinfo
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
use Gnome::N::X:api<2>;

#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::GIRepository::T-AttributeIter:auth<github:MARTIMM>:api<2>;
#-------------------------------------------------------------------------------
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------

class N-AttributeIter:auth<github:MARTIMM>:api<2> is export is repr('CStruct') {

  has void-ptr $.data;
  has gchar-pptr $.-dummy;

  submethod BUILD (
    void-ptr :$!data, gchar-pptr :$!-dummy, 
  ) {
  }

  method COERCE ( $no --> N-AttributeIter ) {
    note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
    nativecast( N-AttributeIter, $no)
  }
}

