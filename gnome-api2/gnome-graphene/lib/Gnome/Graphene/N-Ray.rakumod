=comment Package: Graphene, C-Source: ray
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Graphene::T-box:api<2>;
use Gnome::Graphene::T-plane:api<2>;
use Gnome::Graphene::T-point3d:api<2>;
use Gnome::Graphene::T-ray:api<2>;
use Gnome::Graphene::T-sphere:api<2>;
use Gnome::Graphene::T-triangle:api<2>;
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

unit class Gnome::Graphene::N-Ray:auth<github:MARTIMM>:api<2>;
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
  if self.^name eq 'Gnome::Graphene::Ray' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('graphene_ray_t');
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
  alloc => %( :type(Constructor), :is-symbol<graphene_ray_alloc>, :returns(N-Object), ),

  #--[Methods]------------------------------------------------------------------
  equal => %(:is-symbol<graphene_ray_equal>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  free => %(:is-symbol<graphene_ray_free>, ),
  get-closest-point-to-point => %(:is-symbol<graphene_ray_get_closest_point_to_point>,  :parameters([N-Object, N-Object])),
  get-direction => %(:is-symbol<graphene_ray_get_direction>,  :parameters([N-Object])),
  get-distance-to-plane => %(:is-symbol<graphene_ray_get_distance_to_plane>,  :returns(gfloat), :parameters([N-Object])),
  get-distance-to-point => %(:is-symbol<graphene_ray_get_distance_to_point>,  :returns(gfloat), :parameters([N-Object])),
  get-origin => %(:is-symbol<graphene_ray_get_origin>,  :parameters([N-Object])),
  get-position-at => %(:is-symbol<graphene_ray_get_position_at>,  :parameters([gfloat, N-Object])),
  init => %(:is-symbol<graphene_ray_init>,  :returns(N-Object), :parameters([N-Object, N-Object])),
  init-from-ray => %(:is-symbol<graphene_ray_init_from_ray>,  :returns(N-Object), :parameters([N-Object])),
  init-from-vec3 => %(:is-symbol<graphene_ray_init_from_vec3>,  :returns(N-Object), :parameters([N-Object, N-Object])),
  intersect-box => %(:is-symbol<graphene_ray_intersect_box>,  :returns(GEnum), :cnv-return(graphene_ray_intersection_kind_t), :parameters([N-Object, CArray[gfloat]])),
  intersect-sphere => %(:is-symbol<graphene_ray_intersect_sphere>,  :returns(GEnum), :cnv-return(graphene_ray_intersection_kind_t), :parameters([N-Object, CArray[gfloat]])),
  intersect-triangle => %(:is-symbol<graphene_ray_intersect_triangle>,  :returns(GEnum), :cnv-return(graphene_ray_intersection_kind_t), :parameters([N-Object, CArray[gfloat]])),
  intersects-box => %(:is-symbol<graphene_ray_intersects_box>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  intersects-sphere => %(:is-symbol<graphene_ray_intersects_sphere>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  intersects-triangle => %(:is-symbol<graphene_ray_intersects_triangle>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
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
