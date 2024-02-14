=comment Package: Graphene, C-Source: plane
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Graphene::T-matrix:api<2>;
use Gnome::Graphene::T-plane:api<2>;
use Gnome::Graphene::T-point3d:api<2>;
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

unit class Gnome::Graphene::N-Plane:auth<github:MARTIMM>:api<2>;
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
  if self.^name eq 'Gnome::Graphene::Plane' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('graphene_plane_t');
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
  alloc => %( :type(Constructor), :is-symbol<graphene_plane_alloc>, :returns(N-Object), ),

  #--[Methods]------------------------------------------------------------------
  distance => %(:is-symbol<graphene_plane_distance>,  :returns(gfloat), :parameters([N-Object])),
  equal => %(:is-symbol<graphene_plane_equal>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  free => %(:is-symbol<graphene_plane_free>, ),
  get-constant => %(:is-symbol<graphene_plane_get_constant>,  :returns(gfloat)),
  get-normal => %(:is-symbol<graphene_plane_get_normal>,  :parameters([N-Object])),
  init => %(:is-symbol<graphene_plane_init>,  :returns(N-Object), :parameters([N-Object, gfloat])),
  init-from-plane => %(:is-symbol<graphene_plane_init_from_plane>,  :returns(N-Object), :parameters([N-Object])),
  init-from-point => %(:is-symbol<graphene_plane_init_from_point>,  :returns(N-Object), :parameters([N-Object, N-Object])),
  init-from-points => %(:is-symbol<graphene_plane_init_from_points>,  :returns(N-Object), :parameters([N-Object, N-Object, N-Object])),
  init-from-vec4 => %(:is-symbol<graphene_plane_init_from_vec4>,  :returns(N-Object), :parameters([N-Object])),
  negate => %(:is-symbol<graphene_plane_negate>,  :parameters([N-Object])),
  normalize => %(:is-symbol<graphene_plane_normalize>,  :parameters([N-Object])),
  transform => %(:is-symbol<graphene_plane_transform>,  :parameters([N-Object, N-Object, N-Object])),
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
