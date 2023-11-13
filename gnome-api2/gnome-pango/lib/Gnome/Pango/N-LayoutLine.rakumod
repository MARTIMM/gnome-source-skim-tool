# Command to generate: generate.raku -c -t Pango Layout
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Glib::N-SList:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class N-LayoutLine:auth<github:MARTIMM>:api<2> is export is repr('CStruct');

has N-Object $.layout;
has gint $.start-index;
has gint $.length;
has N-SList $.runs;
has guint $.is-paragraph-start;
has guint $.resolved-dir;

submethod BUILD (
  gint :$!start-index, gint :$!length, N-SList :$!runs, guint :$!is-paragraph-start, guint :$!resolved-dir, 
) {
}

submethod TWEAK (
  N-Object :$layout, 
) {
  $!layout := $layout if ?$layout;
}

method COERCE ( $no --> N-LayoutLine ) {
  note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
  nativecast( N-LayoutLine, $no)
}
