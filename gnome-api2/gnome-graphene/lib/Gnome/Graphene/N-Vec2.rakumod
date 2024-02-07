=comment Package: Graphene, C-Source: vec
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Graphene::T-vec:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Graphene::N-Vec2:auth<github:MARTIMM>:api<2>;

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
  if self.^name eq 'Gnome::Graphene::Vec2' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('graphene_vec2_t');
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
  alloc => %( :type(Constructor), :is-symbol<graphene_vec2_alloc>, :returns(N-Vec2), ),

  #--[Methods]------------------------------------------------------------------
  add => %(:is-symbol<graphene_vec2_add>,  :parameters([N-Vec2, N-Vec2])),
  divide => %(:is-symbol<graphene_vec2_divide>,  :parameters([N-Vec2, N-Vec2])),
  dot => %(:is-symbol<graphene_vec2_dot>,  :returns(gfloat), :parameters([N-Vec2])),
  equal => %(:is-symbol<graphene_vec2_equal>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Vec2])),
  free => %(:is-symbol<graphene_vec2_free>, ),
  get-x => %(:is-symbol<graphene_vec2_get_x>,  :returns(gfloat)),
  get-y => %(:is-symbol<graphene_vec2_get_y>,  :returns(gfloat)),
  init => %(:is-symbol<graphene_vec2_init>,  :returns(N-Vec2), :parameters([gfloat, gfloat])),
  init-from-float => %(:is-symbol<graphene_vec2_init_from_float>,  :returns(N-Vec2), :parameters([CArray[gfloat]])),
  init-from-vec2 => %(:is-symbol<graphene_vec2_init_from_vec2>,  :returns(N-Vec2), :parameters([N-Vec2])),
  interpolate => %(:is-symbol<graphene_vec2_interpolate>,  :parameters([N-Vec2, gdouble, N-Vec2])),
  length => %(:is-symbol<graphene_vec2_length>,  :returns(gfloat)),
  max => %(:is-symbol<graphene_vec2_max>,  :parameters([N-Vec2, N-Vec2])),
  min => %(:is-symbol<graphene_vec2_min>,  :parameters([N-Vec2, N-Vec2])),
  multiply => %(:is-symbol<graphene_vec2_multiply>,  :parameters([N-Vec2, N-Vec2])),
  near => %(:is-symbol<graphene_vec2_near>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Vec2, gfloat])),
  negate => %(:is-symbol<graphene_vec2_negate>,  :parameters([N-Vec2])),
  normalize => %(:is-symbol<graphene_vec2_normalize>,  :parameters([N-Vec2])),
  scale => %(:is-symbol<graphene_vec2_scale>,  :parameters([gfloat, N-Vec2])),
  subtract => %(:is-symbol<graphene_vec2_subtract>,  :parameters([N-Vec2, N-Vec2])),
  to-float => %(:is-symbol<graphene_vec2_to_float>,  :parameters([CArray[gfloat]])),

  #--[Functions]----------------------------------------------------------------
  one => %( :type(Function), :is-symbol<graphene_vec2_one>,  :returns(N-Vec2)),
  x-axis => %( :type(Function), :is-symbol<graphene_vec2_x_axis>,  :returns(N-Vec2)),
  y-axis => %( :type(Function), :is-symbol<graphene_vec2_y_axis>,  :returns(N-Vec2)),
  zero => %( :type(Function), :is-symbol<graphene_vec2_zero>,  :returns(N-Vec2)),
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
