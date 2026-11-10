=comment Package: GIRepo, C-Source: gitypes
use v6.d;
#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;



use Gnome::GObject::T-type:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;
use Gnome::N::X:api<2>;

#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::GIRepository::T-types:auth<github:MARTIMM>:api<2>;
#-------------------------------------------------------------------------------
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------

class N-BaseInfoStack:auth<github:MARTIMM>:api<2> is export is repr('CStruct') {

  has N-Object $.parent-instance;
  has gint $.dummy0;
  has gchar-pptr $.dummy1;
  has gchar-pptr $.dummy2;
  has gchar-pptr $.dummy3;

  submethod BUILD (
    gint :$!dummy0, gchar-pptr :$!dummy1, gchar-pptr :$!dummy2, gchar-pptr :$!dummy3, 
  ) {
  }

  submethod TWEAK (
    N-Object :$parent-instance, 
  ) {
    $!parent-instance := $parent-instance if ?$parent-instance;
}

  method COERCE ( $no --> N-BaseInfoStack ) {
    note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
    nativecast( N-BaseInfoStack, $no)
  }
}

#-------------------------------------------------------------------------------
#--[Union Structure]------------------------------------------------------------
#-------------------------------------------------------------------------------
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

#`{{
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
}}
#-------------------------------------------------------------------------------
#--[Constants]------------------------------------------------------------------
#-------------------------------------------------------------------------------
constant GI_TYPE_TAG_N_TYPES is export = 22;

#-------------------------------------------------------------------------------
#--[Enumerations]---------------------------------------------------------------
#-------------------------------------------------------------------------------
enum GIArrayType is export <
  GI_ARRAY_TYPE_C GI_ARRAY_TYPE_ARRAY GI_ARRAY_TYPE_PTR_ARRAY GI_ARRAY_TYPE_BYTE_ARRAY 
>;

enum GIDirection is export <
  GI_DIRECTION_IN GI_DIRECTION_OUT GI_DIRECTION_INOUT 
>;

enum GIScopeType is export <
  GI_SCOPE_TYPE_INVALID GI_SCOPE_TYPE_CALL GI_SCOPE_TYPE_ASYNC GI_SCOPE_TYPE_NOTIFIED GI_SCOPE_TYPE_FOREVER 
>;

enum GITransfer is export <
  GI_TRANSFER_NOTHING GI_TRANSFER_CONTAINER GI_TRANSFER_EVERYTHING 
>;

enum GITypeTag is export <
  GI_TYPE_TAG_VOID GI_TYPE_TAG_BOOLEAN GI_TYPE_TAG_INT8 GI_TYPE_TAG_UINT8 GI_TYPE_TAG_INT16 GI_TYPE_TAG_UINT16 GI_TYPE_TAG_INT32 GI_TYPE_TAG_UINT32 GI_TYPE_TAG_INT64 GI_TYPE_TAG_UINT64 GI_TYPE_TAG_FLOAT GI_TYPE_TAG_DOUBLE GI_TYPE_TAG_GTYPE GI_TYPE_TAG_UTF8 GI_TYPE_TAG_FILENAME GI_TYPE_TAG_ARRAY GI_TYPE_TAG_INTERFACE GI_TYPE_TAG_GLIST GI_TYPE_TAG_GSLIST GI_TYPE_TAG_GHASH GI_TYPE_TAG_ERROR GI_TYPE_TAG_UNICHAR 
>;

#-------------------------------------------------------------------------------
#--[Bitfields]------------------------------------------------------------------
#-------------------------------------------------------------------------------
enum GIFieldInfoFlags is export (
  :GI_FIELD_INFO_FLAGS_NONE(0), :GI_FIELD_IS_READABLE(1), :GI_FIELD_IS_WRITABLE(2)
);

enum GIFunctionInfoFlags is export (
  :GI_FUNCTION_INFO_FLAGS_NONE(0), :GI_FUNCTION_IS_METHOD(1), :GI_FUNCTION_IS_CONSTRUCTOR(2), :GI_FUNCTION_IS_GETTER(4), :GI_FUNCTION_IS_SETTER(8), :GI_FUNCTION_WRAPS_VFUNC(16), :GI_FUNCTION_IS_ASYNC(32)
);

enum GIVFuncInfoFlags is export (
  :GI_VFUNC_INFO_FLAGS_NONE(0), :GI_VFUNC_MUST_CHAIN_UP(1), :GI_VFUNC_MUST_OVERRIDE(2), :GI_VFUNC_MUST_NOT_OVERRIDE(4)
);

