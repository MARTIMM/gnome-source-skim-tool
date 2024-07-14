=comment Package: GObject, C-Source: value
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

unit class Gnome::GObject::T-value:auth<github:MARTIMM>:api<2>;
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
  $!routine-caller .= new(:library(gobject-lib()));
}

#-------------------------------------------------------------------------------
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------

class N-Value:auth<github:MARTIMM>:api<2> is export is repr('CStruct') {

  has GType $.g-type is rw;
  has gchar-pptr $.data;

  submethod BUILD ( GType :$!g-type ) {
  }

  submethod TWEAK ( gchar-pptr :$data ) {
    $!data := $data if ? $data;
  }

  method COERCE ( $no --> N-Value ) {
    note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
    nativecast( N-Value, $no)
  }
}

#-------------------------------------------------------------------------------
#--[Constants]------------------------------------------------------------------
#-------------------------------------------------------------------------------
constant G_VALUE_INTERNED_STRING is export = 268435456;
constant G_VALUE_NOCOPY_CONTENTS is export = 134217728;

#-------------------------------------------------------------------------------
#--[Standalone functions]-------------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(
  
  #--[Functions]----------------------------------------------------------------
  value-register-transform-func => %( :type(Function), :is-symbol<g_value_register_transform_func>,  :parameters([ GType, GType, :( N-Object $src-value, N-Object $dest-value )])),
  value-type-compatible => %( :type(Function), :is-symbol<g_value_type_compatible>,  :returns(gboolean), :parameters([ GType, GType])),
  value-type-transformable => %( :type(Function), :is-symbol<g_value_type_transformable>,  :returns(gboolean), :parameters([ GType, GType])),

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
