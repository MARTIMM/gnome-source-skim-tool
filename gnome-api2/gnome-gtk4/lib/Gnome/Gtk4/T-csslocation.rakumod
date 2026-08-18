=comment Package: Gtk4, C-Source: csslocation
use v6.d;
#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;



#use Gnome::Gtk4::T-csslocation:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;
use Gnome::N::X:api<2>;

#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::T-csslocation:auth<github:MARTIMM>:api<2>;
#-------------------------------------------------------------------------------
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------

class N-CssLocation:auth<github:MARTIMM>:api<2> is export is repr('CStruct') {

  has gsize $.bytes;
  has gsize $.chars;
  has gsize $.lines;
  has gsize $.line-bytes;
  has gsize $.line-chars;

  submethod BUILD (
    gsize :$!bytes, gsize :$!chars, gsize :$!lines,
    gsize :$!line-bytes, gsize :$!line-chars, 
  ) {
  }

  method COERCE ( $no --> N-CssLocation ) {
    note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
    nativecast( N-CssLocation, $no)
  }
}

