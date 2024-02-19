=comment Package: Gsk4, C-Source: rendernodeimpl
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Gdk4::N-RGBA:api<2>;
#use Gnome::Gdk4::T-rgba:api<2>;
#use Gnome::Gsk4::N-RoundedRect:api<2>;
use Gnome::Gsk4::RenderNode:api<2>;
#use Gnome::Gsk4::T-roundedrect:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gsk4::InsetShadowNode:auth<github:MARTIMM>:api<2>;
also is Gnome::Gsk4::RenderNode;

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
  if self.^name eq 'Gnome::Gsk4::InsetShadowNode' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GskInsetShadowNode');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-insetshadownode => %( :type(Constructor), :is-symbol<gsk_inset_shadow_node_new>, :returns(N-Object), :parameters([ N-Object, N-Object, gfloat, gfloat, gfloat, gfloat])),

  #--[Methods]------------------------------------------------------------------
  get-blur-radius => %(:is-symbol<gsk_inset_shadow_node_get_blur_radius>,  :returns(gfloat)),
  get-color => %(:is-symbol<gsk_inset_shadow_node_get_color>,  :returns(N-Object)),
  get-dx => %(:is-symbol<gsk_inset_shadow_node_get_dx>,  :returns(gfloat)),
  get-dy => %(:is-symbol<gsk_inset_shadow_node_get_dy>,  :returns(gfloat)),
  get-outline => %(:is-symbol<gsk_inset_shadow_node_get_outline>,  :returns(N-Object)),
  get-spread => %(:is-symbol<gsk_inset_shadow_node_get_spread>,  :returns(gfloat)),
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
