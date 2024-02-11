=comment Package: Graphene, C-Source: rect
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Graphene::T-point:api<2>;
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

unit class Gnome::Graphene::N-Rect:auth<github:MARTIMM>:api<2>;
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
  if self.^name eq 'Gnome::Graphene::Rect' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('graphene_rect_t');
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
  alloc => %( :type(Constructor), :is-symbol<graphene_rect_alloc>,  :returns(N-Object)),

  #--[Methods]------------------------------------------------------------------
  contains-point => %(:is-symbol<graphene_rect_contains_point>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  contains-rect => %(:is-symbol<graphene_rect_contains_rect>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  equal => %(:is-symbol<graphene_rect_equal>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  expand => %(:is-symbol<graphene_rect_expand>,  :parameters([N-Object, N-Object])),
  free => %(:is-symbol<graphene_rect_free>, ),
  get-area => %(:is-symbol<graphene_rect_get_area>,  :returns(gfloat)),
  get-bottom-left => %(:is-symbol<graphene_rect_get_bottom_left>,  :parameters([N-Object])),
  get-bottom-right => %(:is-symbol<graphene_rect_get_bottom_right>,  :parameters([N-Object])),
  get-center => %(:is-symbol<graphene_rect_get_center>,  :parameters([N-Object])),
  get-height => %(:is-symbol<graphene_rect_get_height>,  :returns(gfloat)),
  get-top-left => %(:is-symbol<graphene_rect_get_top_left>,  :parameters([N-Object])),
  get-top-right => %(:is-symbol<graphene_rect_get_top_right>,  :parameters([N-Object])),
  get-vertices => %(:is-symbol<graphene_rect_get_vertices>,  :parameters([N-Object])),
  get-width => %(:is-symbol<graphene_rect_get_width>,  :returns(gfloat)),
  get-x => %(:is-symbol<graphene_rect_get_x>,  :returns(gfloat)),
  get-y => %(:is-symbol<graphene_rect_get_y>,  :returns(gfloat)),
  init => %(:is-symbol<graphene_rect_init>,  :returns(N-Object), :parameters([gfloat, gfloat, gfloat, gfloat])),
  init-from-rect => %(:is-symbol<graphene_rect_init_from_rect>,  :returns(N-Object), :parameters([N-Object])),
  inset => %(:is-symbol<graphene_rect_inset>,  :returns(N-Object), :parameters([gfloat, gfloat])),
  inset-r => %(:is-symbol<graphene_rect_inset_r>,  :parameters([gfloat, gfloat, N-Object])),
  interpolate => %(:is-symbol<graphene_rect_interpolate>,  :parameters([N-Object, gdouble, N-Object])),
  intersection => %(:is-symbol<graphene_rect_intersection>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, N-Object])),
  normalize => %(:is-symbol<graphene_rect_normalize>,  :returns(N-Object)),
  normalize-r => %(:is-symbol<graphene_rect_normalize_r>,  :parameters([N-Object])),
  offset => %(:is-symbol<graphene_rect_offset>,  :returns(N-Object), :parameters([gfloat, gfloat])),
  offset-r => %(:is-symbol<graphene_rect_offset_r>,  :parameters([gfloat, gfloat, N-Object])),
  round-extents => %(:is-symbol<graphene_rect_round_extents>,  :parameters([N-Object])),
  scale => %(:is-symbol<graphene_rect_scale>,  :parameters([gfloat, gfloat, N-Object])),
  union => %(:is-symbol<graphene_rect_union>,  :parameters([N-Object, N-Object])),

  #--[Functions]----------------------------------------------------------------
  zero => %( :type(Function), :is-symbol<graphene_rect_zero>,  :returns(N-Object)),
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
