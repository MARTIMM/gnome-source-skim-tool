=comment Package: GIRepo, C-Source: gitypes
use v6.d;


#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;



use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


unit class N-Argument:auth<github:MARTIMM>:api<2> is export is repr('CUnion');

HAS gboolean $.v-boolean;
HAS  $.v-int8;
HAS  $.v-uint8;
HAS  $.v-int16;
HAS  $.v-uint16;
HAS  $.v-int32;
HAS  $.v-uint32;
HAS gint64 $.v-int64;
HAS gint64 $.v-uint64;
HAS gfloat $.v-float;
HAS gdouble $.v-double;
HAS gshort $.v-short;
HAS  $.v-ushort;
HAS gint $.v-int;
HAS guint-ptr $.v-uint;
HAS glong $.v-long;
HAS  $.v-ulong;
HAS gssize $.v-ssize;
HAS gsize $.v-size;
HAS Str $.v-string;
HAS void-ptr $.v-pointer;

submethod BUILD (
  gboolean :$!v-boolean,  :$!v-int8,  :$!v-uint8,  :$!v-int16,  :$!v-uint16,  :$!v-int32,  :$!v-uint32, gint64 :$!v-int64, gint64 :$!v-uint64, gfloat :$!v-float, gdouble :$!v-double, gshort :$!v-short,  :$!v-ushort, gint :$!v-int, guint-ptr :$!v-uint, glong :$!v-long,  :$!v-ulong, gssize :$!v-ssize, gsize :$!v-size, Str :$!v-string, void-ptr :$!v-pointer, 
) {
}

method COERCE ( $no --> N-Argument ) {
  note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
  nativecast( N-Argument, $no)
}

