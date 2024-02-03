=comment Package: Graphene, C-Source: graphene-vec
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Graphene::T-Vec2:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Graphene::N-Vec4:auth<github:MARTIMM>:api<2>;
also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
#--[BUILD variables]------------------------------------------------------------
#-------------------------------------------------------------------------------

# Define callable helper
has Gnome::N::GnomeRoutineCaller $!routine-caller;

#-------------------------------------------------------------------------------
#--[BUILD submethod]------------------------------------------------------------
#-------------------------------------------------------------------------------

submethod BUILD ( *%options ) {

  # Initialize helper
  $!routine-caller .= new(:library(graphene-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Graphene::Vec4' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('graphene_vec4_t');
  }
}

# Next two methods need checks for proper referencing or cleanup 
method native-object-ref ( $n-native-object ) {
  $n-native-object
}

method native-object-unref ( $n-native-object ) {
#  self._fallback-v2( 'free', my Bool $x);
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  alloc => %( :type(Constructor), :is-symbol<graphene_vec4_alloc>, :returns(N-Vec4), ),

  #--[Methods]------------------------------------------------------------------
  add => %(:is-symbol<graphene_vec4_add>,  :parameters([N-Vec4, N-Vec4])),
  divide => %(:is-symbol<graphene_vec4_divide>,  :parameters([N-Vec4, N-Vec4])),
  dot => %(:is-symbol<graphene_vec4_dot>,  :returns(gfloat), :parameters([N-Vec4])),
  equal => %(:is-symbol<graphene_vec4_equal>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Vec4])),
  free => %(:is-symbol<graphene_vec4_free>, ),
  get-w => %(:is-symbol<graphene_vec4_get_w>,  :returns(gfloat)),
  get-x => %(:is-symbol<graphene_vec4_get_x>,  :returns(gfloat)),
  get-xy => %(:is-symbol<graphene_vec4_get_xy>,  :parameters([N-Vec2])),
  get-xyz => %(:is-symbol<graphene_vec4_get_xyz>,  :parameters([N-Vec3])),
  get-y => %(:is-symbol<graphene_vec4_get_y>,  :returns(gfloat)),
  get-z => %(:is-symbol<graphene_vec4_get_z>,  :returns(gfloat)),
  init => %(:is-symbol<graphene_vec4_init>,  :returns(N-Vec4), :parameters([gfloat, gfloat, gfloat, gfloat])),
  init-from-float => %(:is-symbol<graphene_vec4_init_from_float>,  :returns(N-Vec4), :parameters([CArray[gfloat]])),
  init-from-vec2 => %(:is-symbol<graphene_vec4_init_from_vec2>,  :returns(N-Vec4), :parameters([N-Vec2, gfloat, gfloat])),
  init-from-vec3 => %(:is-symbol<graphene_vec4_init_from_vec3>,  :returns(N-Vec4), :parameters([N-Vec3, gfloat])),
  init-from-vec4 => %(:is-symbol<graphene_vec4_init_from_vec4>,  :returns(N-Vec4), :parameters([N-Vec4])),
  interpolate => %(:is-symbol<graphene_vec4_interpolate>,  :parameters([N-Vec4, gdouble, N-Vec4])),
  length => %(:is-symbol<graphene_vec4_length>,  :returns(gfloat)),
  max => %(:is-symbol<graphene_vec4_max>,  :parameters([N-Vec4, N-Vec4])),
  min => %(:is-symbol<graphene_vec4_min>,  :parameters([N-Vec4, N-Vec4])),
  multiply => %(:is-symbol<graphene_vec4_multiply>,  :parameters([N-Vec4, N-Vec4])),
  near => %(:is-symbol<graphene_vec4_near>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Vec4, gfloat])),
  negate => %(:is-symbol<graphene_vec4_negate>,  :parameters([N-Vec4])),
  normalize => %(:is-symbol<graphene_vec4_normalize>,  :parameters([N-Vec4])),
  scale => %(:is-symbol<graphene_vec4_scale>,  :parameters([gfloat, N-Vec4])),
  subtract => %(:is-symbol<graphene_vec4_subtract>,  :parameters([N-Vec4, N-Vec4])),
  to-float => %(:is-symbol<graphene_vec4_to_float>,  :parameters([CArray[gfloat]])),

  #--[Functions]----------------------------------------------------------------
  one => %( :type(Function), :is-symbol<graphene_vec4_one>,  :returns(N-Vec4)),
  w-axis => %( :type(Function), :is-symbol<graphene_vec4_w_axis>,  :returns(N-Vec4)),
  x-axis => %( :type(Function), :is-symbol<graphene_vec4_x_axis>,  :returns(N-Vec4)),
  y-axis => %( :type(Function), :is-symbol<graphene_vec4_y_axis>,  :returns(N-Vec4)),
  z-axis => %( :type(Function), :is-symbol<graphene_vec4_z_axis>,  :returns(N-Vec4)),
  zero => %( :type(Function), :is-symbol<graphene_vec4_zero>,  :returns(N-Vec4)),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 (
  Str $name, Bool $_fallback-v2-ok is rw, *@arguments, *%options
) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    if $methods{$name}<type>:exists and $methods{$name}<type> eq 'Constructor' {
      my Gnome::N::GnomeRoutineCaller $routine-caller .= new(
        :library(graphene-lib())
      );

      return self.bless(
        :native-object(
          $routine-caller.call-native-sub( $name, @arguments, $methods)
        ),
        |%options
      );
    }

    elsif $methods{$name}<type>:exists and $methods{$name}<type> eq 'Function' {
      return $!routine-caller.call-native-sub( $name, @arguments, $methods);
    }

    else {
      my $native-object = self.get-native-object-no-reffing;
      return $!routine-caller.call-native-sub(
        $name, @arguments, $methods, $native-object
      );
    }
  }

  else {
    callsame;
  }
}
