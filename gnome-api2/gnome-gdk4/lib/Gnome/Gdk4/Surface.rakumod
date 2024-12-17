=comment Package: Gdk4, C-Source: surface
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Cairo;


use Gnome::GObject::Object:api<2>;
use Gnome::Gdk4::T-enums:api<2>;
use Gnome::Glib::T-error:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gdk4::Surface:auth<github:MARTIMM>:api<2>;
also is Gnome::GObject::Object;

#-------------------------------------------------------------------------------
#--[BUILD variables]------------------------------------------------------------
#-------------------------------------------------------------------------------

# Define callable helper
has Gnome::N::GnomeRoutineCaller $!routine-caller;

# Add signal registration helper
my Bool $signals-added = False;

#-------------------------------------------------------------------------------
#--[BUILD submethod]------------------------------------------------------------
#-------------------------------------------------------------------------------

submethod BUILD ( *%options ) {

  # Add signal administration info.
  unless $signals-added {
    self.add-signal-types( $?CLASS.^name,
      :w1<render event enter-monitor leave-monitor>,
      :w2<layout>,
    );
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gdk4::Surface' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GdkSurface');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-popup => %( :type(Constructor), :is-symbol<gdk_surface_new_popup>, :returns(N-Object), :parameters([ N-Object, gboolean])),
  new-toplevel => %( :type(Constructor), :is-symbol<gdk_surface_new_toplevel>, :returns(N-Object), :parameters([ N-Object])),

  #--[Methods]------------------------------------------------------------------
  beep => %(:is-symbol<gdk_surface_beep>, :returns(void)),
  create-cairo-context => %(:is-symbol<gdk_surface_create_cairo_context>, :returns(N-Object)),
  create-gl-context => %(:is-symbol<gdk_surface_create_gl_context>, :returns(N-Object) :parameters([CArray[N-Error]])),
  create-similar-surface => %(:is-symbol<gdk_surface_create_similar_surface>, :returns(Cairo::cairo_surface_t) :parameters([UInt, gint, gint])),
  create-vulkan-context => %(:is-symbol<gdk_surface_create_vulkan_context>, :returns(N-Object) :parameters([CArray[N-Error]])),
  destroy => %(:is-symbol<gdk_surface_destroy>, :returns(void)),
  get-cursor => %(:is-symbol<gdk_surface_get_cursor>, :returns(N-Object)),
  get-device-cursor => %(:is-symbol<gdk_surface_get_device_cursor>, :returns(N-Object) :parameters([N-Object])),
  get-device-position => %(:is-symbol<gdk_surface_get_device_position>, :returns(gboolean) :parameters([N-Object, CArray[gdouble], CArray[gdouble], GFlag])),
  get-display => %(:is-symbol<gdk_surface_get_display>, :returns(N-Object)),
  get-frame-clock => %(:is-symbol<gdk_surface_get_frame_clock>, :returns(N-Object)),
  get-height => %(:is-symbol<gdk_surface_get_height>, :returns(gint)),
  get-mapped => %(:is-symbol<gdk_surface_get_mapped>, :returns(gboolean)),
  get-scale-factor => %(:is-symbol<gdk_surface_get_scale_factor>, :returns(gint)),
  get-width => %(:is-symbol<gdk_surface_get_width>, :returns(gint)),
  hide => %(:is-symbol<gdk_surface_hide>, :returns(void)),
  is-destroyed => %(:is-symbol<gdk_surface_is_destroyed>, :returns(gboolean)),
  queue-render => %(:is-symbol<gdk_surface_queue_render>, :returns(void)),
  request-layout => %(:is-symbol<gdk_surface_request_layout>, :returns(void)),
  set-cursor => %(:is-symbol<gdk_surface_set_cursor>, :returns(void) :parameters([N-Object])),
  set-device-cursor => %(:is-symbol<gdk_surface_set_device_cursor>, :returns(void) :parameters([N-Object, N-Object])),
  set-input-region => %(:is-symbol<gdk_surface_set_input_region>, :returns(void) :parameters([Cairo])),
  set-opaque-region => %(:is-symbol<gdk_surface_set_opaque_region>, :returns(void) :parameters([Cairo])),
  translate-coordinates => %(:is-symbol<gdk_surface_translate_coordinates>, :returns(gboolean) :parameters([N-Object, CArray[gdouble], CArray[gdouble]])),
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
