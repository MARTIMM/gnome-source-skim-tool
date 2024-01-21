=comment Package: Gsk4, C-Source: types
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


#use Gnome::Glib::N-String:api<2>;
#use Gnome::Gsk4::N-Transform:api<2>;
use Gnome::Gsk4::T-Enums:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gsk4::N-Transform:auth<github:MARTIMM>:api<2>;
also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------

# This is an opaque type of which fields are not available.
class N-Transform:auth<github:MARTIMM>:api<2> is export is repr('CPointer') { }

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
#  self._fallback-v2( 'free', my Bool $x);
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  #new-transform => %( :type(Constructor), :is-symbol<gsk_transform_new>, :returns(N-Transform ), ),

  #--[Methods]------------------------------------------------------------------
  #equal => %(:is-symbol<gsk_transform_equal>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Transform ])),
  #get-category => %(:is-symbol<gsk_transform_get_category>,  :returns(GEnum), :cnv-return(GskTransformCategory)),
  #invert => %(:is-symbol<gsk_transform_invert>,  :returns(N-Transform )),
  #matrix => %(:is-symbol<gsk_transform_matrix>,  :returns(N-Transform )),
  #perspective => %(:is-symbol<gsk_transform_perspective>,  :returns(N-Transform ), :parameters([gfloat])),
  #print => %(:is-symbol<gsk_transform_print>,  :parameters([N-String ])),
  #ref => %(:is-symbol<gsk_transform_ref>,  :returns(N-Transform )),
  #rotate => %(:is-symbol<gsk_transform_rotate>,  :returns(N-Transform ), :parameters([gfloat])),
  #rotate-3d => %(:is-symbol<gsk_transform_rotate_3d>,  :returns(N-Transform ), :parameters([gfloat, ])),
  #scale => %(:is-symbol<gsk_transform_scale>,  :returns(N-Transform ), :parameters([gfloat, gfloat])),
  #scale-3d => %(:is-symbol<gsk_transform_scale_3d>,  :returns(N-Transform ), :parameters([gfloat, gfloat, gfloat])),
  #skew => %(:is-symbol<gsk_transform_skew>,  :returns(N-Transform ), :parameters([gfloat, gfloat])),
  #to-2d => %(:is-symbol<gsk_transform_to_2d>,  :parameters([, , , , , ])),
  #to-2d-components => %(:is-symbol<gsk_transform_to_2d_components>,  :parameters([, , , , , , ])),
  #to-affine => %(:is-symbol<gsk_transform_to_affine>,  :parameters([, , , ])),
  #to-matrix => %(:is-symbol<gsk_transform_to_matrix>, ),
  #to-string => %(:is-symbol<gsk_transform_to_string>,  :returns(Str)),
  #to-translate => %(:is-symbol<gsk_transform_to_translate>,  :parameters([, ])),
  #transform => %(:is-symbol<gsk_transform_transform>,  :returns(N-Transform ), :parameters([N-Transform ])),
  #transform-bounds => %(:is-symbol<gsk_transform_transform_bounds>,  :parameters([, ])),
  #transform-point => %(:is-symbol<gsk_transform_transform_point>,  :parameters([, ])),
  #translate => %(:is-symbol<gsk_transform_translate>,  :returns(N-Transform )),
  #translate-3d => %(:is-symbol<gsk_transform_translate_3d>,  :returns(N-Transform )),
  #unref => %(:is-symbol<gsk_transform_unref>, ),

  #--[Functions]----------------------------------------------------------------
  #parse => %( :type(Function), :is-symbol<gsk_transform_parse>,  :returns(gboolean), :parameters([ Str, CArray[N-Transform] ])),
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
