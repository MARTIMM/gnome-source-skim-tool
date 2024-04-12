=comment Package: Gdk4, C-Source: types
use v6.d;
#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


#use Gnome::Gdk4::T-types:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;

#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gdk4::T-types:auth<github:MARTIMM>:api<2>;
#-------------------------------------------------------------------------------
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------
# This is an opaque type of which fields are not available.
class N-ContentFormats:auth<github:MARTIMM>:api<2> is export is repr('CPointer') { }


class N-KeymapKey:auth<github:MARTIMM>:api<2> is export is repr('CStruct') {

  has guint $.keycode;
  has gint $.group;
  has gint $.level;

  submethod BUILD (
    guint :$!keycode, gint :$!group, gint :$!level, 
  ) {
  }

  method COERCE ( $no --> N-KeymapKey ) {
    note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
    nativecast( N-KeymapKey, $no)
  }
}


class N-Rectangle:auth<github:MARTIMM>:api<2> is export is repr('CStruct') {

  has gint $.x;
  has gint $.y;
  has gint $.width;
  has gint $.height;

  submethod BUILD (
    gint :$!x, gint :$!y, gint :$!width, gint :$!height, 
  ) {
  }

  method COERCE ( $no --> N-Rectangle ) {
    note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
    nativecast( N-Rectangle, $no)
  }
}

#-------------------------------------------------------------------------------
#--[Constants]------------------------------------------------------------------
#-------------------------------------------------------------------------------
constant GDK_CURRENT_TIME is export = 0;

