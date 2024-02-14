=comment Package: Graphene, C-Source: sphere
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Gnome::Graphene::T-box:api<2>;
use Gnome::Graphene::T-point3d:api<2>;
use Gnome::Graphene::T-sphere:api<2>;
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

unit class Gnome::Graphene::N-Sphere:auth<github:MARTIMM>:api<2>;
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
  if self.^name eq 'Gnome::Graphene::Sphere' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('graphene_sphere_t');
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
  alloc => %( :type(Constructor), :is-symbol<graphene_sphere_alloc>, :returns(N-Object), ),

  #--[Methods]------------------------------------------------------------------
  contains-point => %(:is-symbol<graphene_sphere_contains_point>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  distance => %(:is-symbol<graphene_sphere_distance>,  :returns(gfloat), :parameters([N-Object])),
  equal => %(:is-symbol<graphene_sphere_equal>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  free => %(:is-symbol<graphene_sphere_free>, ),
  get-bounding-box => %(:is-symbol<graphene_sphere_get_bounding_box>,  :parameters([N-Object])),
  get-center => %(:is-symbol<graphene_sphere_get_center>,  :parameters([N-Object])),
  get-radius => %(:is-symbol<graphene_sphere_get_radius>,  :returns(gfloat)),
  init => %(:is-symbol<graphene_sphere_init>,  :returns(N-Object), :parameters([N-Object, gfloat])),
  #init-from-points => %(:is-symbol<graphene_sphere_init_from_points>,  :returns(N-Object), :parameters([, N-Object, N-Object])),
  #init-from-vectors => %(:is-symbol<graphene_sphere_init_from_vectors>,  :returns(N-Object), :parameters([, N-Object, N-Object])),
  is-empty => %(:is-symbol<graphene_sphere_is_empty>,  :returns(gboolean), :cnv-return(Bool)),
  translate => %(:is-symbol<graphene_sphere_translate>,  :parameters([N-Object, N-Object])),
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
