=comment Package: Gdk4, C-Source: events
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

#use Gnome::Gdk4::N-EventSequence:api<2>;
#use Gnome::Gdk4::N-TimeCoord:api<2>;
#use Gnome::Gdk4::T-device:api<2>;

use Gnome::Gdk4::T-enums:api<2>;
use Gnome::Gdk4::T-events:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gdk4::Event:auth<github:MARTIMM>:api<2>;
#also is ;

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
  if self.^name eq 'Gnome::Gdk4::Event' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GdkEvent');
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

  #--[Methods]------------------------------------------------------------------
  # NOTE get-angle and others are prefixed like _get_angle. Not possible here!
  get-angle => %(:is-symbol<gdk_event__get_angle>, :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, CArray[gdouble]]), ),
  get-center => %(:is-symbol<gdk_event__get_center>, :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, CArray[gdouble], CArray[gdouble]]), ),
  get-distance => %(:is-symbol<gdk_event__get_distance>, :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, CArray[gdouble]]), ),
  get-axes => %(:is-symbol<gdk_event_get_axes>, :returns(gboolean), :cnv-return(Bool), :parameters([CArray[gdouble], gint-ptr]), ),
  get-axis => %(:is-symbol<gdk_event_get_axis>, :returns(gboolean), :cnv-return(Bool), :parameters([GEnum, CArray[gdouble]]), ),
  get-device => %(:is-symbol<gdk_event_get_device>, :returns(N-Object), ),
  get-device-tool => %(:is-symbol<gdk_event_get_device_tool>, :returns(N-Object), ),
  get-display => %(:is-symbol<gdk_event_get_display>, :returns(N-Object), ),
  get-event-sequence => %(:is-symbol<gdk_event_get_event_sequence>, :returns(N-Object), ),
  get-event-type => %(:is-symbol<gdk_event_get_event_type>,  :returns(GEnum), :cnv-return(GdkEventType)),
  get-history => %(:is-symbol<gdk_event_get_history>, :returns(N-Object), :parameters([gint-ptr]), ),
  get-modifier-state => %(:is-symbol<gdk_event_get_modifier_state>,  :returns(GFlag), :cnv-return(GdkModifierType)),
  get-pointer-emulated => %(:is-symbol<gdk_event_get_pointer_emulated>, :returns(gboolean), :cnv-return(Bool), ),
  get-position => %(:is-symbol<gdk_event_get_position>, :returns(gboolean), :cnv-return(Bool), :parameters([CArray[gdouble], CArray[gdouble]]), ),
  get-seat => %(:is-symbol<gdk_event_get_seat>, :returns(N-Object), ),
  get-surface => %(:is-symbol<gdk_event_get_surface>, :returns(N-Object), ),
  get-time => %(:is-symbol<gdk_event_get_time>, :returns(guint32), ),
  ref => %(:is-symbol<gdk_event_ref>, :returns(N-Object), ),
  triggers-context-menu => %(:is-symbol<gdk_event_triggers_context_menu>, :returns(gboolean), :cnv-return(Bool), ),
  unref => %(:is-symbol<gdk_event_unref>, ),
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
