=comment Package: Pango, C-Source: layout
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

unit class Gnome::Pango::T-layout:auth<github:MARTIMM>:api<2>;
#-------------------------------------------------------------------------------
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------
# This is an opaque type of which fields are not available.
class N-LayoutIter:auth<github:MARTIMM>:api<2> is export is repr('CPointer') { }


class N-LayoutLine:auth<github:MARTIMM>:api<2> is export is repr('CStruct') {

  has N-Object $.layout;
  has gint $.start-index;
  has gint $.length;
  has N-Object $.runs;
  has guint $.is-paragraph-start;
  has guint $.resolved-dir;

  submethod BUILD (
    gint :$!start-index, gint :$!length, guint :$!is-paragraph-start, guint :$!resolved-dir, 
  ) {
  }

  submethod TWEAK (
    N-Object :$layout, N-Object :$runs, 
  ) {
    $!layout := $layout if ?$layout;
  $!runs := $runs if ?$runs;
}

  method COERCE ( $no --> N-LayoutLine ) {
    note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
    nativecast( N-LayoutLine, $no)
  }
}

#-------------------------------------------------------------------------------
#--[Enumerations]---------------------------------------------------------------
#-------------------------------------------------------------------------------
enum PangoAlignment is export <
  PANGO_ALIGN_LEFT PANGO_ALIGN_CENTER PANGO_ALIGN_RIGHT 
>;

enum PangoEllipsizeMode is export <
  PANGO_ELLIPSIZE_NONE PANGO_ELLIPSIZE_START PANGO_ELLIPSIZE_MIDDLE PANGO_ELLIPSIZE_END 
>;

enum PangoLayoutDeserializeError is export <
  PANGO_LAYOUT_DESERIALIZE_INVALID PANGO_LAYOUT_DESERIALIZE_INVALID_VALUE PANGO_LAYOUT_DESERIALIZE_MISSING_VALUE 
>;

enum PangoWrapMode is export <
  PANGO_WRAP_WORD PANGO_WRAP_CHAR PANGO_WRAP_WORD_CHAR 
>;

#-------------------------------------------------------------------------------
#--[Bitfields]------------------------------------------------------------------
#-------------------------------------------------------------------------------
enum PangoLayoutDeserializeFlags is export (
  :PANGO_LAYOUT_DESERIALIZE_DEFAULT(0), :PANGO_LAYOUT_DESERIALIZE_CONTEXT(1)
);

enum PangoLayoutSerializeFlags is export (
  :PANGO_LAYOUT_SERIALIZE_DEFAULT(0), :PANGO_LAYOUT_SERIALIZE_CONTEXT(1), :PANGO_LAYOUT_SERIALIZE_OUTPUT(2)
);

