=comment Package: Gsk4, C-Source: rendernodeimpl
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Graphene::N-Point:api<2>;
use Gnome::Graphene::N-Rect:api<2>;
use Gnome::Graphene::T-point:api<2>;
use Gnome::Graphene::T-rect:api<2>;
#use Gnome::Gsk4::N-ColorStop:api<2>;
use Gnome::Gsk4::RenderNode:api<2>;
use Gnome::Gsk4::T-rendernode:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gsk4::LinearGradientNode:auth<github:MARTIMM>:api<2>;
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
  if self.^name eq 'Gnome::Gsk4::LinearGradientNode' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GskLinearGradientNode');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-lineargradientnode => %( :type(Constructor), :is-symbol<gsk_linear_gradient_node_new>, :returns(N-Object), :parameters([ N-Object, N-Object, N-Object, N-Object, gsize])),

  #--[Methods]------------------------------------------------------------------
  get-color-stops => %(:is-symbol<gsk_linear_gradient_node_get_color_stops>,  :returns(N-Object), :parameters([CArray[gsize]])),
  get-end => %(:is-symbol<gsk_linear_gradient_node_get_end>,  :returns(N-Object)),
  get-n-color-stops => %(:is-symbol<gsk_linear_gradient_node_get_n_color_stops>,  :returns(gsize)),
  get-start => %(:is-symbol<gsk_linear_gradient_node_get_start>,  :returns(N-Object)),
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
