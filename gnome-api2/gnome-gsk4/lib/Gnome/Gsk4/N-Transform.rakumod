=comment Package: Gsk4, C-Source: types
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


#use Gnome::Glib::T-string:api<2>;

use Gnome::Graphene::T-matrix:api<2>;
use Gnome::Graphene::T-point:api<2>;
use Gnome::Graphene::T-point3d:api<2>;
use Gnome::Graphene::T-rect:api<2>;
use Gnome::Graphene::T-vec:api<2>;

use Gnome::Gsk4::T-enums:api<2>;
use Gnome::Gsk4::T-types:api<2>;

use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Structure Declaration]------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gsk4::N-Transform:auth<github:MARTIMM>:api<2>;
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
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gsk4::Transform' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GskTransform');
  }
}

# Next two methods need checks for proper referencing or cleanup 
method native-object-ref ( $n-native-object ) {
  $n-native-object
}

method native-object-unref ( $n-native-object ) {
  self._fallback-v2( 'unref', my Bool $x);
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-transform => %( :type(Constructor), :is-symbol<gsk_transform_new>, :returns(N-Object), ),

  #--[Methods]------------------------------------------------------------------
  equal => %(:is-symbol<gsk_transform_equal>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  get-category => %(:is-symbol<gsk_transform_get_category>,  :returns(GEnum), :cnv-return(GskTransformCategory )),
  invert => %(:is-symbol<gsk_transform_invert>,  :returns(N-Object)),
  matrix => %(:is-symbol<gsk_transform_matrix>,  :returns(N-Object), :parameters([N-Object])),
  perspective => %(:is-symbol<gsk_transform_perspective>,  :returns(N-Object), :parameters([gfloat])),
  print => %(:is-symbol<gsk_transform_print>,  :parameters([N-Object])),
  ref => %(:is-symbol<gsk_transform_ref>,  :returns(N-Object)),
  rotate => %(:is-symbol<gsk_transform_rotate>,  :returns(N-Object), :parameters([gfloat])),
  rotate3d => %(:is-symbol<gsk_transform_rotate_3d>,  :returns(N-Object), :parameters([gfloat, N-Object])),
  scale => %(:is-symbol<gsk_transform_scale>,  :returns(N-Object), :parameters([gfloat, gfloat])),
  scale3d => %(:is-symbol<gsk_transform_scale_3d>,  :returns(N-Object), :parameters([gfloat, gfloat, gfloat])),
  skew => %(:is-symbol<gsk_transform_skew>,  :returns(N-Object), :parameters([gfloat, gfloat])),
  to2d => %(:is-symbol<gsk_transform_to_2d>,  :parameters([CArray[gfloat], CArray[gfloat], CArray[gfloat], CArray[gfloat], CArray[gfloat], CArray[gfloat]])),
  to2d-components => %(:is-symbol<gsk_transform_to_2d_components>,  :parameters([CArray[gfloat], CArray[gfloat], CArray[gfloat], CArray[gfloat], CArray[gfloat], CArray[gfloat], CArray[gfloat]])),
  to-affine => %(:is-symbol<gsk_transform_to_affine>,  :parameters([CArray[gfloat], CArray[gfloat], CArray[gfloat], CArray[gfloat]])),
  to-matrix => %(:is-symbol<gsk_transform_to_matrix>,  :parameters([N-Object])),
  to-string => %(:is-symbol<gsk_transform_to_string>,  :returns(Str)),
  to-translate => %(:is-symbol<gsk_transform_to_translate>,  :parameters([CArray[gfloat], CArray[gfloat]])),
  transform => %(:is-symbol<gsk_transform_transform>,  :returns(N-Object), :parameters([N-Object])),
  transform-bounds => %(:is-symbol<gsk_transform_transform_bounds>,  :parameters([N-Object, N-Object])),
  transform-point => %(:is-symbol<gsk_transform_transform_point>,  :parameters([N-Object, N-Object])),
  translate => %(:is-symbol<gsk_transform_translate>,  :returns(N-Object), :parameters([N-Object])),
  translate3d => %(:is-symbol<gsk_transform_translate_3d>,  :returns(N-Object), :parameters([N-Object])),
  unref => %(:is-symbol<gsk_transform_unref>, ),

  #--[Functions]----------------------------------------------------------------
  parse => %( :type(Function), :is-symbol<gsk_transform_parse>,  :returns(gboolean), :parameters([ Str, N-Object])),
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
        :library(gtk4-lib())
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
