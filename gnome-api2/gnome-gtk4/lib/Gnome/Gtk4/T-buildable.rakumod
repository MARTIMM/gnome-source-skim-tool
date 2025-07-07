=comment Package: Gtk4, C-Source: buildable
use v6.d;
#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Cairo;


#use Gnome::Gtk4::T-buildable:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;

#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::T-buildable:auth<github:MARTIMM>:api<2>;
#-------------------------------------------------------------------------------
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------

class N-BuildableParser:auth<github:MARTIMM>:api<2> is export is repr('CStruct') {

  has $.start-element;
  has $.end-element;
  has $.text;
  has $.error;
  has gchar-pptr $.padding;

  submethod BUILD (
    gchar-pptr :$!padding, 
  ) {
  }

  method COERCE ( $no --> N-BuildableParser ) {
    note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
    nativecast( N-BuildableParser, $no)
  }
}

