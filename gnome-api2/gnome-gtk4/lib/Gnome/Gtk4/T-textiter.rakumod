=comment Package: Gtk4, C-Source: textiter
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

unit class Gnome::Gtk4::T-textiter:auth<github:MARTIMM>:api<2>;
#-------------------------------------------------------------------------------
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------

class N-TextIter:auth<github:MARTIMM>:api<2> is export is repr('CStruct') {

  has gpointer $.dummy1;
  has gpointer $.dummy2;
  has gint $.dummy3;
  has gint $.dummy4;
  has gint $.dummy5;
  has gint $.dummy6;
  has gint $.dummy7;
  has gint $.dummy8;
  has gpointer $.dummy9;
  has gpointer $.dummy10;
  has gint $.dummy11;
  has gint $.dummy12;
  has gint $.dummy13;
  has gpointer $.dummy14;

  submethod BUILD (
    gpointer :$!dummy1, gpointer :$!dummy2, gint :$!dummy3, gint :$!dummy4, gint :$!dummy5, gint :$!dummy6, gint :$!dummy7, gint :$!dummy8, gpointer :$!dummy9, gpointer :$!dummy10, gint :$!dummy11, gint :$!dummy12, gint :$!dummy13, gpointer :$!dummy14, 
  ) {
  }

  method COERCE ( $no --> N-TextIter ) {
    note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
    nativecast( N-TextIter, $no)
  }
}

#-------------------------------------------------------------------------------
#--[Bitfields]------------------------------------------------------------------
#-------------------------------------------------------------------------------
enum GtkTextSearchFlags is export (
  :GTK_TEXT_SEARCH_VISIBLE_ONLY(1), :GTK_TEXT_SEARCH_TEXT_ONLY(2), :GTK_TEXT_SEARCH_CASE_INSENSITIVE(4)
);

