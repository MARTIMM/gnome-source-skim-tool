=comment Package: Graphene, C-Source: matrix
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


#use Gnome::Graphene::T-box:api<2>;
#use Gnome::Graphene::T-euler:api<2>;
use Gnome::Graphene::T-matrix:api<2>;
use Gnome::Graphene::T-point:api<2>;
use Gnome::Graphene::T-point3d:api<2>;
use Gnome::Graphene::T-quad:api<2>;
#use Gnome::Graphene::T-quaternion:api<2>;
#use Gnome::Graphene::T-ray:api<2>;
use Gnome::Graphene::T-rect:api<2>;
#use Gnome::Graphene::T-sphere:api<2>;
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

unit class Gnome::Graphene::N-Matrix:auth<github:MARTIMM>:api<2>;
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
  if self.^name eq 'Gnome::Graphene::Matrix' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('graphene_matrix_t');
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
  alloc => %( :type(Constructor), :is-symbol<graphene_matrix_alloc>, :returns(N-Object), ),

  #--[Methods]------------------------------------------------------------------
  decompose => %(:is-symbol<graphene_matrix_decompose>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, N-Object, N-Object, N-Object, N-Object])),
  determinant => %(:is-symbol<graphene_matrix_determinant>,  :returns(gfloat)),
  equal => %(:is-symbol<graphene_matrix_equal>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  equal-fast => %(:is-symbol<graphene_matrix_equal_fast>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  free => %(:is-symbol<graphene_matrix_free>, ),
  #get-row => %(:is-symbol<graphene_matrix_get_row>,  :parameters([, N-Object])),
  #get-value => %(:is-symbol<graphene_matrix_get_value>,  :returns(gfloat), :parameters([, ])),
  get-x-scale => %(:is-symbol<graphene_matrix_get_x_scale>,  :returns(gfloat)),
  get-x-translation => %(:is-symbol<graphene_matrix_get_x_translation>,  :returns(gfloat)),
  get-y-scale => %(:is-symbol<graphene_matrix_get_y_scale>,  :returns(gfloat)),
  get-y-translation => %(:is-symbol<graphene_matrix_get_y_translation>,  :returns(gfloat)),
  get-z-scale => %(:is-symbol<graphene_matrix_get_z_scale>,  :returns(gfloat)),
  get-z-translation => %(:is-symbol<graphene_matrix_get_z_translation>,  :returns(gfloat)),
  init-from2d => %(:is-symbol<graphene_matrix_init_from_2d>,  :returns(N-Object), :parameters([gdouble, gdouble, gdouble, gdouble, gdouble, gdouble])),
  init-from-float => %(:is-symbol<graphene_matrix_init_from_float>,  :returns(N-Object), :parameters([CArray[gfloat]])),
  init-from-matrix => %(:is-symbol<graphene_matrix_init_from_matrix>,  :returns(N-Object), :parameters([N-Object])),
  init-from-vec4 => %(:is-symbol<graphene_matrix_init_from_vec4>,  :returns(N-Object), :parameters([N-Object, N-Object, N-Object, N-Object])),
  init-frustum => %(:is-symbol<graphene_matrix_init_frustum>,  :returns(N-Object), :parameters([gfloat, gfloat, gfloat, gfloat, gfloat, gfloat])),
  init-identity => %(:is-symbol<graphene_matrix_init_identity>,  :returns(N-Object)),
  init-look-at => %(:is-symbol<graphene_matrix_init_look_at>,  :returns(N-Object), :parameters([N-Object, N-Object, N-Object])),
  init-ortho => %(:is-symbol<graphene_matrix_init_ortho>,  :returns(N-Object), :parameters([gfloat, gfloat, gfloat, gfloat, gfloat, gfloat])),
  init-perspective => %(:is-symbol<graphene_matrix_init_perspective>,  :returns(N-Object), :parameters([gfloat, gfloat, gfloat, gfloat])),
  init-rotate => %(:is-symbol<graphene_matrix_init_rotate>,  :returns(N-Object), :parameters([gfloat, N-Object])),
  init-scale => %(:is-symbol<graphene_matrix_init_scale>,  :returns(N-Object), :parameters([gfloat, gfloat, gfloat])),
  init-skew => %(:is-symbol<graphene_matrix_init_skew>,  :returns(N-Object), :parameters([gfloat, gfloat])),
  init-translate => %(:is-symbol<graphene_matrix_init_translate>,  :returns(N-Object), :parameters([N-Object])),
  interpolate => %(:is-symbol<graphene_matrix_interpolate>,  :parameters([N-Object, gdouble, N-Object])),
  inverse => %(:is-symbol<graphene_matrix_inverse>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  is2d => %(:is-symbol<graphene_matrix_is_2d>,  :returns(gboolean), :cnv-return(Bool)),
  is-backface-visible => %(:is-symbol<graphene_matrix_is_backface_visible>,  :returns(gboolean), :cnv-return(Bool)),
  is-identity => %(:is-symbol<graphene_matrix_is_identity>,  :returns(gboolean), :cnv-return(Bool)),
  is-singular => %(:is-symbol<graphene_matrix_is_singular>,  :returns(gboolean), :cnv-return(Bool)),
  multiply => %(:is-symbol<graphene_matrix_multiply>,  :parameters([N-Object, N-Object])),
  near => %(:is-symbol<graphene_matrix_near>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, gfloat])),
  normalize => %(:is-symbol<graphene_matrix_normalize>,  :parameters([N-Object])),
  perspective => %(:is-symbol<graphene_matrix_perspective>,  :parameters([gfloat, N-Object])),
  print => %(:is-symbol<graphene_matrix_print>, ),
  project-point => %(:is-symbol<graphene_matrix_project_point>,  :parameters([N-Object, N-Object])),
  project-rect => %(:is-symbol<graphene_matrix_project_rect>,  :parameters([N-Object, N-Object])),
  project-rect-bounds => %(:is-symbol<graphene_matrix_project_rect_bounds>,  :parameters([N-Object, N-Object])),
  rotate => %(:is-symbol<graphene_matrix_rotate>,  :parameters([gfloat, N-Object])),
  rotate-euler => %(:is-symbol<graphene_matrix_rotate_euler>,  :parameters([N-Object])),
  rotate-quaternion => %(:is-symbol<graphene_matrix_rotate_quaternion>,  :parameters([N-Object])),
  rotate-x => %(:is-symbol<graphene_matrix_rotate_x>,  :parameters([gfloat])),
  rotate-y => %(:is-symbol<graphene_matrix_rotate_y>,  :parameters([gfloat])),
  rotate-z => %(:is-symbol<graphene_matrix_rotate_z>,  :parameters([gfloat])),
  scale => %(:is-symbol<graphene_matrix_scale>,  :parameters([gfloat, gfloat, gfloat])),
  skew-xy => %(:is-symbol<graphene_matrix_skew_xy>,  :parameters([gfloat])),
  skew-xz => %(:is-symbol<graphene_matrix_skew_xz>,  :parameters([gfloat])),
  skew-yz => %(:is-symbol<graphene_matrix_skew_yz>,  :parameters([gfloat])),
  to2d => %(:is-symbol<graphene_matrix_to_2d>,  :returns(gboolean), :cnv-return(Bool), :parameters([CArray[gdouble], CArray[gdouble], CArray[gdouble], CArray[gdouble], CArray[gdouble], CArray[gdouble]])),
  to-float => %(:is-symbol<graphene_matrix_to_float>,  :parameters([CArray[gfloat]])),
  transform-bounds => %(:is-symbol<graphene_matrix_transform_bounds>,  :parameters([N-Object, N-Object])),
  transform-box => %(:is-symbol<graphene_matrix_transform_box>,  :parameters([N-Object, N-Object])),
  transform-point => %(:is-symbol<graphene_matrix_transform_point>,  :parameters([N-Object, N-Object])),
  transform-point3d => %(:is-symbol<graphene_matrix_transform_point3d>,  :parameters([N-Object, N-Object])),
  transform-ray => %(:is-symbol<graphene_matrix_transform_ray>,  :parameters([N-Object, N-Object])),
  transform-rect => %(:is-symbol<graphene_matrix_transform_rect>,  :parameters([N-Object, N-Object])),
  transform-sphere => %(:is-symbol<graphene_matrix_transform_sphere>,  :parameters([N-Object, N-Object])),
  transform-vec3 => %(:is-symbol<graphene_matrix_transform_vec3>,  :parameters([N-Object, N-Object])),
  transform-vec4 => %(:is-symbol<graphene_matrix_transform_vec4>,  :parameters([N-Object, N-Object])),
  translate => %(:is-symbol<graphene_matrix_translate>,  :parameters([N-Object])),
  transpose => %(:is-symbol<graphene_matrix_transpose>,  :parameters([N-Object])),
  unproject-point3d => %(:is-symbol<graphene_matrix_unproject_point3d>,  :parameters([N-Object, N-Object, N-Object])),
  untransform-bounds => %(:is-symbol<graphene_matrix_untransform_bounds>,  :parameters([N-Object, N-Object, N-Object])),
  untransform-point => %(:is-symbol<graphene_matrix_untransform_point>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, N-Object, N-Object])),
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
