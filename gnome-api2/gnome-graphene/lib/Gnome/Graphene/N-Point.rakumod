=comment Package: Graphene, C-Source: point
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Graphene::N-Vec2:api<2>;
use Gnome::Graphene::T-point:api<2>;
use Gnome::Graphene::T-vec:api<2>;

use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Graphene::N-Point:auth<github:MARTIMM>:api<2>;
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
  if self.^name eq 'Gnome::Graphene::Point' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('graphene_point_t');
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
  alloc => %( :type(Constructor), :is-symbol<graphene_point_alloc>, :returns(N-Point), ),

  #--[Methods]------------------------------------------------------------------
  distance => %(:is-symbol<graphene_point_distance>,  :returns(gfloat), :parameters([N-Point, CArray[gfloat], CArray[gfloat]])),
  equal => %(:is-symbol<graphene_point_equal>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Point])),
  free => %(:is-symbol<graphene_point_free>, ),
  init => %(:is-symbol<graphene_point_init>,  :returns(N-Point), :parameters([gfloat, gfloat])),
  init-from-point => %(:is-symbol<graphene_point_init_from_point>,  :returns(N-Point), :parameters([N-Point])),
  init-from-vec2 => %(:is-symbol<graphene_point_init_from_vec2>,  :returns(N-Point), :parameters([N-Vec2])),
  interpolate => %(:is-symbol<graphene_point_interpolate>,  :parameters([N-Point, gdouble, N-Point])),
  near => %(:is-symbol<graphene_point_near>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Point, gfloat])),
  to-vec2 => %(:is-symbol<graphene_point_to_vec2>,  :parameters([N-Vec2])),

  #--[Functions]----------------------------------------------------------------
  zero => %( :type(Function), :is-symbol<graphene_point_zero>,  :returns(N-Point)),
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
