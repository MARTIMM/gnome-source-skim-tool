=comment Package: Graphene, C-Source: point3d
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Graphene::T-point3d:api<2>;
use Gnome::Graphene::T-rect:api<2>;
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

unit class Gnome::Graphene::N-Point3D:auth<github:MARTIMM>:api<2>;
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
  if self.^name eq 'Gnome::Graphene::Point3d' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('graphene_point3d_t');
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
  alloc => %( :type(Constructor), :is-symbol<graphene_point3d_alloc>, :returns(N-Object), ),

  #--[Methods]------------------------------------------------------------------
  cross => %(:is-symbol<graphene_point3d_cross>,  :parameters([N-Object, N-Object])),
  distance => %(:is-symbol<graphene_point3d_distance>,  :returns(gfloat), :parameters([N-Object, N-Object])),
  dot => %(:is-symbol<graphene_point3d_dot>,  :returns(gfloat), :parameters([N-Object])),
  equal => %(:is-symbol<graphene_point3d_equal>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  free => %(:is-symbol<graphene_point3d_free>, ),
  init => %(:is-symbol<graphene_point3d_init>,  :returns(N-Object), :parameters([gfloat, gfloat, gfloat])),
  init-from-point => %(:is-symbol<graphene_point3d_init_from_point>,  :returns(N-Object), :parameters([N-Object])),
  init-from-vec3 => %(:is-symbol<graphene_point3d_init_from_vec3>,  :returns(N-Object), :parameters([N-Object])),
  interpolate => %(:is-symbol<graphene_point3d_interpolate>,  :parameters([N-Object, gdouble, N-Object])),
  length => %(:is-symbol<graphene_point3d_length>,  :returns(gfloat)),
  near => %(:is-symbol<graphene_point3d_near>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, gfloat])),
  normalize => %(:is-symbol<graphene_point3d_normalize>,  :parameters([N-Object])),
  normalize-viewport => %(:is-symbol<graphene_point3d_normalize_viewport>,  :parameters([N-Object, gfloat, gfloat, N-Object])),
  scale => %(:is-symbol<graphene_point3d_scale>,  :parameters([gfloat, N-Object])),
  to-vec3 => %(:is-symbol<graphene_point3d_to_vec3>,  :parameters([N-Object])),

  #--[Functions]----------------------------------------------------------------
  zero => %( :type(Function), :is-symbol<graphene_point3d_zero>,  :returns(N-Object)),
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
