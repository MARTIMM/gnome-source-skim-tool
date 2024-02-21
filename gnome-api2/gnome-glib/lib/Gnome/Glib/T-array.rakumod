=comment Package: Glib, C-Source: array
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

unit class Gnome::Glib::T-array:auth<github:MARTIMM>:api<2>;
also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
#--[BUILD variables]------------------------------------------------------------
#-------------------------------------------------------------------------------

# Define helper
has Gnome::N::GnomeRoutineCaller $!routine-caller;

#-------------------------------------------------------------------------------
#--[BUILD submethod]------------------------------------------------------------
#-------------------------------------------------------------------------------

submethod BUILD ( ) {
  # Initialize helper
  $!routine-caller .= new(:library(glib-lib()));
}

#-------------------------------------------------------------------------------
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------

class N-Array:auth<github:MARTIMM>:api<2> is export is repr('CStruct') {

  has Str $.data;
  has guint $.len;

  submethod BUILD (
    Str :$!data, guint :$!len, 
  ) {
  }

  method COERCE ( $no --> N-Array ) {
    note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
    nativecast( N-Array, $no)
  }
}


class N-PtrArray:auth<github:MARTIMM>:api<2> is export is repr('CStruct') {

  has CArray[gpointer] $.pdata;
  has guint $.len;

  submethod BUILD (
    CArray[gpointer] :$!pdata, guint :$!len, 
  ) {
  }

  method COERCE ( $no --> N-PtrArray ) {
    note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
    nativecast( N-PtrArray, $no)
  }
}


class N-ByteArray:auth<github:MARTIMM>:api<2> is export is repr('CStruct') {

  has CArray[guint8] $.data;
  has guint $.len;

  submethod BUILD (
     :$!data, guint :$!len, 
  ) {
  }

  method COERCE ( $no --> N-ByteArray ) {
    note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
    nativecast( N-ByteArray, $no)
  }
}

#-------------------------------------------------------------------------------
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------

# This is an opaque type of which fields are not available.
class N-Bytes:auth<github:MARTIMM>:api<2> is export is repr('CPointer') { }

#-------------------------------------------------------------------------------
#--[Standalone functions]-------------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(
  
  #--[Functions]----------------------------------------------------------------
  array-new-take => %( :type(Function), :is-symbol<g_array_new_take>,  :returns(N-Object), :parameters([ gpointer, gsize, gboolean, gsize])),
  array-new-take-zero-terminated => %( :type(Function), :is-symbol<g_array_new_take_zero_terminated>,  :returns(N-Object), :parameters([ gpointer, gboolean, gsize])),
  #byte-array-free => %( :type(Function), :is-symbol<g_byte_array_free>,  :parameters([ N-Object, gboolean])),
  byte-array-free-to-bytes => %( :type(Function), :is-symbol<g_byte_array_free_to_bytes>,  :returns(N-Object), :parameters([N-Object])),
  byte-array-new => %( :type(Function), :is-symbol<g_byte_array_new>,  :returns(N-Object)),
  #byte-array-new-take => %( :type(Function), :is-symbol<g_byte_array_new_take>,  :returns(N-Object), :parameters([ , gsize])),
  #byte-array-steal => %( :type(Function), :is-symbol<g_byte_array_steal>,  :parameters([ N-Object, CArray[gsize]])),
  byte-array-unref => %( :type(Function), :is-symbol<g_byte_array_unref>,  :parameters([N-Object])),
  ptr-array-find => %( :type(Function), :is-symbol<g_ptr_array_find>,  :returns(gboolean), :parameters([ N-Object, gpointer, gint-ptr])),
  ptr-array-find-with-equal-func => %( :type(Function), :is-symbol<g_ptr_array_find_with_equal_func>,  :returns(gboolean), :parameters([ N-Object, gpointer, :( gpointer $a, gpointer $b --> gboolean ), gint-ptr])),
  ptr-array-new-from-array => %( :type(Function), :is-symbol<g_ptr_array_new_from_array>,  :returns(N-Object), :parameters([ CArray[gpointer], gsize, :( gpointer $src, gpointer $data --> gpointer ), gpointer, :( gpointer $data )])),
  ptr-array-new-from-null-terminated-array => %( :type(Function), :is-symbol<g_ptr_array_new_from_null_terminated_array>,  :returns(N-Object), :parameters([ CArray[gpointer], :( gpointer $src, gpointer $data --> gpointer ), gpointer, :( gpointer $data )])),
  ptr-array-new-take => %( :type(Function), :is-symbol<g_ptr_array_new_take>,  :returns(N-Object), :parameters([ CArray[gpointer], gsize, :( gpointer $data )])),
  ptr-array-new-take-null-terminated => %( :type(Function), :is-symbol<g_ptr_array_new_take_null_terminated>,  :returns(N-Object), :parameters([ CArray[gpointer], :( gpointer $data )])),

);
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    return $!routine-caller.call-native-sub(
      $name, @arguments, $methods
    );
  }

  else {
    callsame;
  }
}
