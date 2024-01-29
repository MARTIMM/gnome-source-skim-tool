=comment Package: Graphene, C-Source: graphene-vec
use v6.d;
#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Graphene::N-Vec2:api<2>;
use Gnome::Graphene::N-Vec3:api<2>;
use Gnome::Graphene::N-Vec4:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;

#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Graphene::T-Vec2:auth<github:MARTIMM>:api<2>;
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
  $!routine-caller .= new(:library(graphene-lib()));
}

#-------------------------------------------------------------------------------
#--[Standalone functions]-------------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(
  
  #--[Functions]----------------------------------------------------------------
  vec2-one => %( :type(Function), :is-symbol<_vec2_one>,  :returns(N-Vec2)),
  vec2-x-axis => %( :type(Function), :is-symbol<_vec2_x_axis>,  :returns(N-Vec2)),
  vec2-y-axis => %( :type(Function), :is-symbol<_vec2_y_axis>,  :returns(N-Vec2)),
  vec2-zero => %( :type(Function), :is-symbol<_vec2_zero>,  :returns(N-Vec2)),
  vec3-one => %( :type(Function), :is-symbol<_vec3_one>,  :returns(N-Vec3)),
  vec3-x-axis => %( :type(Function), :is-symbol<_vec3_x_axis>,  :returns(N-Vec3)),
  vec3-y-axis => %( :type(Function), :is-symbol<_vec3_y_axis>,  :returns(N-Vec3)),
  vec3-z-axis => %( :type(Function), :is-symbol<_vec3_z_axis>,  :returns(N-Vec3)),
  vec3-zero => %( :type(Function), :is-symbol<_vec3_zero>,  :returns(N-Vec3)),
  vec4-one => %( :type(Function), :is-symbol<_vec4_one>,  :returns(N-Vec4)),
  vec4-w-axis => %( :type(Function), :is-symbol<_vec4_w_axis>,  :returns(N-Vec4)),
  vec4-x-axis => %( :type(Function), :is-symbol<_vec4_x_axis>,  :returns(N-Vec4)),
  vec4-y-axis => %( :type(Function), :is-symbol<_vec4_y_axis>,  :returns(N-Vec4)),
  vec4-z-axis => %( :type(Function), :is-symbol<_vec4_z_axis>,  :returns(N-Vec4)),
  vec4-zero => %( :type(Function), :is-symbol<_vec4_zero>,  :returns(N-Vec4)),

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
