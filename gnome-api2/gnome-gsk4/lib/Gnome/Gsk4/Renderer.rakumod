=comment Package: Gsk4, C-Source: renderer
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

#use Gnome::Cairo::N-Context:api<2>;
#use Gnome::Cairo::T-undefined-module-name:api<2>;

use Gnome::GObject::Object:api<2>;

use Gnome::Glib::T-error:api<2>;

use Gnome::Graphene::N-Rect:api<2>;
use Gnome::Graphene::T-rect:api<2>;

use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gsk4::Renderer:auth<github:MARTIMM>:api<2>;
also is Gnome::GObject::Object;

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
  if self.^name eq 'Gnome::Gsk4::Renderer' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GskRenderer');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-for-surface => %( :type(Constructor), :is-symbol<gsk_renderer_new_for_surface>, :returns(N-Object), :parameters([ N-Object])),

  #--[Methods]------------------------------------------------------------------
  get-surface => %(:is-symbol<gsk_renderer_get_surface>,  :returns(N-Object)),
  is-realized => %(:is-symbol<gsk_renderer_is_realized>,  :returns(gboolean), :cnv-return(Bool)),
  realize => %(:is-symbol<gsk_renderer_realize>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, CArray[N-Error]])),
  render => %(:is-symbol<gsk_renderer_render>,  :parameters([N-Object, N-Object])),
  render-texture => %(:is-symbol<gsk_renderer_render_texture>,  :returns(N-Object), :parameters([N-Object, N-Object])),
  unrealize => %(:is-symbol<gsk_renderer_unrealize>, ),
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
