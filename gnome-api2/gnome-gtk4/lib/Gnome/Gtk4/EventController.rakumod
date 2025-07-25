=comment Package: Gtk4, C-Source: eventcontroller
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;




use Gnome::GObject::Object:api<2>;
use Gnome::Gdk4::T-enums:api<2>;
use Gnome::Gtk4::T-enums:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::EventController:auth<github:MARTIMM>:api<2>;
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
  if self.^name eq 'Gnome::Gtk4::EventController' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkEventController');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  get-current-event => %(:is-symbol<gtk_event_controller_get_current_event>, :returns(N-Object), ),
  get-current-event-device => %(:is-symbol<gtk_event_controller_get_current_event_device>, :returns(N-Object), ),
  get-current-event-state => %(:is-symbol<gtk_event_controller_get_current_event_state>,  :returns(GFlag), :cnv-return(GdkModifierType)),
  get-current-event-time => %(:is-symbol<gtk_event_controller_get_current_event_time>, :returns(guint32), ),
  get-name => %(:is-symbol<gtk_event_controller_get_name>, :returns(Str), ),
  get-propagation-limit => %(:is-symbol<gtk_event_controller_get_propagation_limit>,  :returns(GEnum), :cnv-return(GtkPropagationLimit)),
  get-propagation-phase => %(:is-symbol<gtk_event_controller_get_propagation_phase>,  :returns(GEnum), :cnv-return(GtkPropagationPhase)),
  get-widget => %(:is-symbol<gtk_event_controller_get_widget>, :returns(N-Object), ),
  reset => %(:is-symbol<gtk_event_controller_reset>, ),
  set-name => %(:is-symbol<gtk_event_controller_set_name>, :parameters([Str]), ),
  set-propagation-limit => %(:is-symbol<gtk_event_controller_set_propagation_limit>, :parameters([GEnum]), ),
  set-propagation-phase => %(:is-symbol<gtk_event_controller_set_propagation_phase>, :parameters([GEnum]), ),
  set-static-name => %(:is-symbol<gtk_event_controller_set_static_name>, :parameters([Str]), ),
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
