=comment Package: Graphene, C-Source: vec
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Graphene::T-vec:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Structure Declaration]------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Graphene::N-Vec3:auth<github:MARTIMM>:api<2>;
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
  if self.^name eq 'Gnome::Graphene::Vec3' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('graphene_vec3_t');
  }
}

# Next two methods need checks for proper referencing or cleanup 
method native-object-ref ( $n-native-object ) {
  $n-native-object
}

method native-object-unref ( $n-native-object ) {
  self._fallback-v2( 'free', my Bool $x);
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  alloc => %( :type(Constructor), :is-symbol<graphene_vec3_alloc>, :returns(N-Object), ),

  #--[Methods]------------------------------------------------------------------
  add => %(:is-symbol<graphene_vec3_add>,  :parameters([N-Object, N-Object])),
  cross => %(:is-symbol<graphene_vec3_cross>,  :parameters([N-Object, N-Object])),
  divide => %(:is-symbol<graphene_vec3_divide>,  :parameters([N-Object, N-Object])),
  dot => %(:is-symbol<graphene_vec3_dot>,  :returns(gfloat), :parameters([N-Object])),
  equal => %(:is-symbol<graphene_vec3_equal>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  free => %(:is-symbol<graphene_vec3_free>, ),
  get-x => %(:is-symbol<graphene_vec3_get_x>,  :returns(gfloat)),
  get-xy => %(:is-symbol<graphene_vec3_get_xy>,  :parameters([N-Object])),
  get-xy0 => %(:is-symbol<graphene_vec3_get_xy0>,  :parameters([N-Object])),
  get-xyz0 => %(:is-symbol<graphene_vec3_get_xyz0>,  :parameters([N-Object])),
  get-xyz1 => %(:is-symbol<graphene_vec3_get_xyz1>,  :parameters([N-Object])),
  get-xyzw => %(:is-symbol<graphene_vec3_get_xyzw>,  :parameters([gfloat, N-Object])),
  get-y => %(:is-symbol<graphene_vec3_get_y>,  :returns(gfloat)),
  get-z => %(:is-symbol<graphene_vec3_get_z>,  :returns(gfloat)),
  init => %(:is-symbol<graphene_vec3_init>,  :returns(N-Object), :parameters([gfloat, gfloat, gfloat])),
  init-from-float => %(:is-symbol<graphene_vec3_init_from_float>,  :returns(N-Object), :parameters([CArray[gfloat]])),
  init-from-vec3 => %(:is-symbol<graphene_vec3_init_from_vec3>,  :returns(N-Object), :parameters([N-Object])),
  interpolate => %(:is-symbol<graphene_vec3_interpolate>,  :parameters([N-Object, gdouble, N-Object])),
  length => %(:is-symbol<graphene_vec3_length>,  :returns(gfloat)),
  max => %(:is-symbol<graphene_vec3_max>,  :parameters([N-Object, N-Object])),
  min => %(:is-symbol<graphene_vec3_min>,  :parameters([N-Object, N-Object])),
  multiply => %(:is-symbol<graphene_vec3_multiply>,  :parameters([N-Object, N-Object])),
  near => %(:is-symbol<graphene_vec3_near>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, gfloat])),
  negate => %(:is-symbol<graphene_vec3_negate>,  :parameters([N-Object])),
  normalize => %(:is-symbol<graphene_vec3_normalize>,  :parameters([N-Object])),
  scale => %(:is-symbol<graphene_vec3_scale>,  :parameters([gfloat, N-Object])),
  subtract => %(:is-symbol<graphene_vec3_subtract>,  :parameters([N-Object, N-Object])),
  to-float => %(:is-symbol<graphene_vec3_to_float>,  :parameters([CArray[gfloat]])),

  #--[Functions]----------------------------------------------------------------
  one => %( :type(Function), :is-symbol<graphene_vec3_one>,  :returns(N-Object)),
  x-axis => %( :type(Function), :is-symbol<graphene_vec3_x_axis>,  :returns(N-Object)),
  y-axis => %( :type(Function), :is-symbol<graphene_vec3_y_axis>,  :returns(N-Object)),
  z-axis => %( :type(Function), :is-symbol<graphene_vec3_z_axis>,  :returns(N-Object)),
  zero => %( :type(Function), :is-symbol<graphene_vec3_zero>,  :returns(N-Object)),
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
