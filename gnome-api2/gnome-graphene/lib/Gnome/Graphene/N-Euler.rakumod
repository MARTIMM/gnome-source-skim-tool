=comment Package: Graphene, C-Source: euler
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Graphene::T-euler:api<2>;
use Gnome::Graphene::T-matrix:api<2>;
#use Gnome::Graphene::T-quaternion:api<2>;
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

unit class Gnome::Graphene::N-Euler:auth<github:MARTIMM>:api<2>;
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
  if self.^name eq 'Gnome::Graphene::Euler' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('graphene_euler_t');
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
  alloc => %( :type(Constructor), :is-symbol<graphene_euler_alloc>, :returns(N-Object), ),

  #--[Methods]------------------------------------------------------------------
  equal => %(:is-symbol<graphene_euler_equal>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  free => %(:is-symbol<graphene_euler_free>, ),
  get-alpha => %(:is-symbol<graphene_euler_get_alpha>,  :returns(gfloat)),
  get-beta => %(:is-symbol<graphene_euler_get_beta>,  :returns(gfloat)),
  get-gamma => %(:is-symbol<graphene_euler_get_gamma>,  :returns(gfloat)),
  get-order => %(:is-symbol<graphene_euler_get_order>,  :returns(GEnum), :cnv-return(graphene_euler_order_t)),
  get-x => %(:is-symbol<graphene_euler_get_x>,  :returns(gfloat)),
  get-y => %(:is-symbol<graphene_euler_get_y>,  :returns(gfloat)),
  get-z => %(:is-symbol<graphene_euler_get_z>,  :returns(gfloat)),
  init => %(:is-symbol<graphene_euler_init>,  :returns(N-Object), :parameters([gfloat, gfloat, gfloat])),
  init-from-euler => %(:is-symbol<graphene_euler_init_from_euler>,  :returns(N-Object), :parameters([N-Object])),
  init-from-matrix => %(:is-symbol<graphene_euler_init_from_matrix>,  :returns(N-Object), :parameters([N-Object, GEnum])),
  init-from-quaternion => %(:is-symbol<graphene_euler_init_from_quaternion>,  :returns(N-Object), :parameters([N-Object, GEnum])),
  init-from-radians => %(:is-symbol<graphene_euler_init_from_radians>,  :returns(N-Object), :parameters([gfloat, gfloat, gfloat, GEnum])),
  init-from-vec3 => %(:is-symbol<graphene_euler_init_from_vec3>,  :returns(N-Object), :parameters([N-Object, GEnum])),
  init-with-order => %(:is-symbol<graphene_euler_init_with_order>,  :returns(N-Object), :parameters([gfloat, gfloat, gfloat, GEnum])),
  reorder => %(:is-symbol<graphene_euler_reorder>,  :parameters([GEnum, N-Object])),
  to-matrix => %(:is-symbol<graphene_euler_to_matrix>,  :parameters([N-Object])),
  to-quaternion => %(:is-symbol<graphene_euler_to_quaternion>,  :parameters([N-Object])),
  to-vec3 => %(:is-symbol<graphene_euler_to_vec3>,  :parameters([N-Object])),
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
