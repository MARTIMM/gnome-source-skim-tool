=comment Package: Graphene, C-Source: box
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Graphene::T-box:api<2>;
use Gnome::Graphene::T-point3d:api<2>;
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

unit class Gnome::Graphene::N-Box:auth<github:MARTIMM>:api<2>;
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
  if self.^name eq 'Gnome::Graphene::Box' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('graphene_box_t');
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
  alloc => %( :type(Constructor), :is-symbol<graphene_box_alloc>, :returns(N-Object), ),

  #--[Methods]------------------------------------------------------------------
  contains-box => %(:is-symbol<graphene_box_contains_box>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  contains-point => %(:is-symbol<graphene_box_contains_point>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  equal => %(:is-symbol<graphene_box_equal>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  expand => %(:is-symbol<graphene_box_expand>,  :parameters([N-Object, N-Object])),
  expand-scalar => %(:is-symbol<graphene_box_expand_scalar>,  :parameters([gfloat, N-Object])),
  expand-vec3 => %(:is-symbol<graphene_box_expand_vec3>,  :parameters([N-Object, N-Object])),
  free => %(:is-symbol<graphene_box_free>, ),
  get-bounding-sphere => %(:is-symbol<graphene_box_get_bounding_sphere>,  :parameters([N-Object])),
  get-center => %(:is-symbol<graphene_box_get_center>,  :parameters([N-Object])),
  get-depth => %(:is-symbol<graphene_box_get_depth>,  :returns(gfloat)),
  get-height => %(:is-symbol<graphene_box_get_height>,  :returns(gfloat)),
  get-max => %(:is-symbol<graphene_box_get_max>,  :parameters([N-Object])),
  get-min => %(:is-symbol<graphene_box_get_min>,  :parameters([N-Object])),
  get-size => %(:is-symbol<graphene_box_get_size>,  :parameters([N-Object])),
  get-vertices => %(:is-symbol<graphene_box_get_vertices>,  :parameters([N-Object])),
  get-width => %(:is-symbol<graphene_box_get_width>,  :returns(gfloat)),
  init => %(:is-symbol<graphene_box_init>,  :returns(N-Object), :parameters([N-Object, N-Object])),
  init-from-box => %(:is-symbol<graphene_box_init_from_box>,  :returns(N-Object), :parameters([N-Object])),
  #init-from-points => %(:is-symbol<graphene_box_init_from_points>,  :returns(N-Object), :parameters([, N-Object])),
  init-from-vec3 => %(:is-symbol<graphene_box_init_from_vec3>,  :returns(N-Object), :parameters([N-Object, N-Object])),
  #init-from-vectors => %(:is-symbol<graphene_box_init_from_vectors>,  :returns(N-Object), :parameters([, N-Object])),
  intersection => %(:is-symbol<graphene_box_intersection>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, N-Object])),
  union => %(:is-symbol<graphene_box_union>,  :parameters([N-Object, N-Object])),

  #--[Functions]----------------------------------------------------------------
  empty => %( :type(Function), :is-symbol<graphene_box_empty>,  :returns(N-Object)),
  infinite => %( :type(Function), :is-symbol<graphene_box_infinite>,  :returns(N-Object)),
  minus-one => %( :type(Function), :is-symbol<graphene_box_minus_one>,  :returns(N-Object)),
  one => %( :type(Function), :is-symbol<graphene_box_one>,  :returns(N-Object)),
  one-minus-one => %( :type(Function), :is-symbol<graphene_box_one_minus_one>,  :returns(N-Object)),
  zero => %( :type(Function), :is-symbol<graphene_box_zero>,  :returns(N-Object)),
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
