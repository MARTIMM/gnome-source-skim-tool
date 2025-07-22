=comment Package: Gtk4, C-Source: gesturesingle
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Cairo;


#use Gnome::Gdk4::N-EventSequence:api<2>;
#use Gnome::Gdk4::T-events:api<2>;
use Gnome::Gtk4::Gesture:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::GestureSingle:auth<github:MARTIMM>:api<2>;
also is Gnome::Gtk4::Gesture;

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
  if self.^name eq 'Gnome::Gtk4::GestureSingle' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkGestureSingle');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  get-button => %(:is-symbol<gtk_gesture_single_get_button>, :returns(guint), ),
  get-current-button => %(:is-symbol<gtk_gesture_single_get_current_button>, :returns(guint), ),
  get-current-sequence => %(:is-symbol<gtk_gesture_single_get_current_sequence>, :returns(N-Object), ),
  get-exclusive => %(:is-symbol<gtk_gesture_single_get_exclusive>, :returns(gboolean), :cnv-return(Bool), ),
  get-touch-only => %(:is-symbol<gtk_gesture_single_get_touch_only>, :returns(gboolean), :cnv-return(Bool), ),
  set-button => %(:is-symbol<gtk_gesture_single_set_button>, :parameters([guint]), ),
  set-exclusive => %(:is-symbol<gtk_gesture_single_set_exclusive>, :parameters([gboolean]), ),
  set-touch-only => %(:is-symbol<gtk_gesture_single_set_touch_only>, :parameters([gboolean]), ),
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
