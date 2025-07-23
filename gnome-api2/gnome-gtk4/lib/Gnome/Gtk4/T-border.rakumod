=comment Package: Gtk4, C-Source: border
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

unit class Gnome::Gtk4::T-border:auth<github:MARTIMM>:api<2>;
#-------------------------------------------------------------------------------
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------

class N-Border:auth<github:MARTIMM>:api<2> is export is repr('CStruct') {

  has gint16 $.left;
  has gint16 $.right;
  has gint16 $.top;
  has gint16 $.bottom;

  submethod BUILD (
    gint16 :$!left, gint16 :$!right, gint16 :$!top, gint16 :$!bottom, 
  ) {
  }

  method COERCE ( $no --> N-Border ) {
    note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
    nativecast( N-Border, $no)
  }
}

