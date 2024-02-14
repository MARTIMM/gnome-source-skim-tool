=comment Package: Graphene, C-Source: quaternion
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Graphene::T-euler:api<2>;
use Gnome::Graphene::T-matrix:api<2>;
use Gnome::Graphene::T-quaternion:api<2>;
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

unit class Gnome::Graphene::N-Quaternion:auth<github:MARTIMM>:api<2>;
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
  if self.^name eq 'Gnome::Graphene::Quaternion' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('graphene_quaternion_t');
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
  alloc => %( :type(Constructor), :is-symbol<graphene_quaternion_alloc>, :returns(N-Object), ),

  #--[Methods]------------------------------------------------------------------
  add => %(:is-symbol<graphene_quaternion_add>,  :parameters([N-Object, N-Object])),
  dot => %(:is-symbol<graphene_quaternion_dot>,  :returns(gfloat), :parameters([N-Object])),
  equal => %(:is-symbol<graphene_quaternion_equal>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  free => %(:is-symbol<graphene_quaternion_free>, ),
  init => %(:is-symbol<graphene_quaternion_init>,  :returns(N-Object), :parameters([gfloat, gfloat, gfloat, gfloat])),
  init-from-angle-vec3 => %(:is-symbol<graphene_quaternion_init_from_angle_vec3>,  :returns(N-Object), :parameters([gfloat, N-Object])),
  init-from-angles => %(:is-symbol<graphene_quaternion_init_from_angles>,  :returns(N-Object), :parameters([gfloat, gfloat, gfloat])),
  init-from-euler => %(:is-symbol<graphene_quaternion_init_from_euler>,  :returns(N-Object), :parameters([N-Object])),
  init-from-matrix => %(:is-symbol<graphene_quaternion_init_from_matrix>,  :returns(N-Object), :parameters([N-Object])),
  init-from-quaternion => %(:is-symbol<graphene_quaternion_init_from_quaternion>,  :returns(N-Object), :parameters([N-Object])),
  init-from-radians => %(:is-symbol<graphene_quaternion_init_from_radians>,  :returns(N-Object), :parameters([gfloat, gfloat, gfloat])),
  init-from-vec4 => %(:is-symbol<graphene_quaternion_init_from_vec4>,  :returns(N-Object), :parameters([N-Object])),
  init-identity => %(:is-symbol<graphene_quaternion_init_identity>,  :returns(N-Object)),
  invert => %(:is-symbol<graphene_quaternion_invert>,  :parameters([N-Object])),
  multiply => %(:is-symbol<graphene_quaternion_multiply>,  :parameters([N-Object, N-Object])),
  normalize => %(:is-symbol<graphene_quaternion_normalize>,  :parameters([N-Object])),
  scale => %(:is-symbol<graphene_quaternion_scale>,  :parameters([gfloat, N-Object])),
  slerp => %(:is-symbol<graphene_quaternion_slerp>,  :parameters([N-Object, gfloat, N-Object])),
  to-angle-vec3 => %(:is-symbol<graphene_quaternion_to_angle_vec3>,  :parameters([CArray[gfloat], N-Object])),
  to-angles => %(:is-symbol<graphene_quaternion_to_angles>,  :parameters([CArray[gfloat], CArray[gfloat], CArray[gfloat]])),
  to-matrix => %(:is-symbol<graphene_quaternion_to_matrix>,  :parameters([N-Object])),
  to-radians => %(:is-symbol<graphene_quaternion_to_radians>,  :parameters([CArray[gfloat], CArray[gfloat], CArray[gfloat]])),
  to-vec4 => %(:is-symbol<graphene_quaternion_to_vec4>,  :parameters([N-Object])),
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
