=comment Package: Graphene, C-Source: vec
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

unit class Gnome::Graphene::T-vec:auth<github:MARTIMM>:api<2>;
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
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------

class N-Vec4:auth<github:MARTIMM>:api<2> is export is repr('CStruct') {

  has N-Object $.value;

  submethod TWEAK (
    N-Object :$value, 
  ) {
    $!value := $value if ?$value;
}

  method COERCE ( $no --> N-Vec4 ) {
    note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
    nativecast( N-Vec4, $no)
  }
}


class N-Vec2:auth<github:MARTIMM>:api<2> is export is repr('CStruct') {

  has N-Object $.value;

  submethod TWEAK (
    N-Object :$value, 
  ) {
    $!value := $value if ?$value;
}

  method COERCE ( $no --> N-Vec2 ) {
    note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
    nativecast( N-Vec2, $no)
  }
}


class N-Vec3:auth<github:MARTIMM>:api<2> is export is repr('CStruct') {

  has N-Object $.value;

  submethod TWEAK (
    N-Object :$value, 
  ) {
    $!value := $value if ?$value;
}

  method COERCE ( $no --> N-Vec3 ) {
    note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
    nativecast( N-Vec3, $no)
  }
}

#-------------------------------------------------------------------------------
#--[Standalone functions]-------------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(
  
  #--[Functions]----------------------------------------------------------------
  vec2-one => %( :type(Function), :is-symbol<graphene_vec2_one>,  :returns(N-Object)),
  vec2-x-axis => %( :type(Function), :is-symbol<graphene_vec2_x_axis>,  :returns(N-Object)),
  vec2-y-axis => %( :type(Function), :is-symbol<graphene_vec2_y_axis>,  :returns(N-Object)),
  vec2-zero => %( :type(Function), :is-symbol<graphene_vec2_zero>,  :returns(N-Object)),
  vec3-one => %( :type(Function), :is-symbol<graphene_vec3_one>,  :returns(N-Object)),
  vec3-x-axis => %( :type(Function), :is-symbol<graphene_vec3_x_axis>,  :returns(N-Object)),
  vec3-y-axis => %( :type(Function), :is-symbol<graphene_vec3_y_axis>,  :returns(N-Object)),
  vec3-z-axis => %( :type(Function), :is-symbol<graphene_vec3_z_axis>,  :returns(N-Object)),
  vec3-zero => %( :type(Function), :is-symbol<graphene_vec3_zero>,  :returns(N-Object)),
  vec4-one => %( :type(Function), :is-symbol<graphene_vec4_one>,  :returns(N-Object)),
  vec4-w-axis => %( :type(Function), :is-symbol<graphene_vec4_w_axis>,  :returns(N-Object)),
  vec4-x-axis => %( :type(Function), :is-symbol<graphene_vec4_x_axis>,  :returns(N-Object)),
  vec4-y-axis => %( :type(Function), :is-symbol<graphene_vec4_y_axis>,  :returns(N-Object)),
  vec4-z-axis => %( :type(Function), :is-symbol<graphene_vec4_z_axis>,  :returns(N-Object)),
  vec4-zero => %( :type(Function), :is-symbol<graphene_vec4_zero>,  :returns(N-Object)),

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
