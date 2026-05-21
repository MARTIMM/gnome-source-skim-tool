=comment Package: Gdk4, C-Source: events
use v6.d;
#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

#use Gnome::Gdk4::Event:api<2>;

use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;
use Gnome::N::X:api<2>;

#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gdk4::T-events:auth<github:MARTIMM>:api<2>;
also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
#--[BUILD variables]------------------------------------------------------------
#-------------------------------------------------------------------------------

# Define helper
has Gnome::N::GnomeRoutineCaller $!routine-caller;

#-------------------------------------------------------------------------------
#--[BUILD submethod]------------------------------------------------------------
#-------------------------------------------------------------------------------

submethod BUILD ( ) {
  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));
}

#-------------------------------------------------------------------------------
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------
# This is an opaque type of which fields are not available.
class N-EventSequence:auth<github:MARTIMM>:api<2> is export is repr('CPointer') { }

#-------------------------------------------------------------------------------
#--[Constants]------------------------------------------------------------------
#-------------------------------------------------------------------------------
constant GDK_PRIORITY_REDRAW is export = 120;
constant GDK_EVENT_STOP is export = true;
constant GDK_BUTTON_MIDDLE is export = 2;
constant GDK_BUTTON_SECONDARY is export = 3;
constant GDK_EVENT_PROPAGATE is export = false;
constant GDK_BUTTON_PRIMARY is export = 1;

#-------------------------------------------------------------------------------
#--[Enumerations]---------------------------------------------------------------
#-------------------------------------------------------------------------------
enum GdkCrossingMode is export <
  GDK_CROSSING_NORMAL GDK_CROSSING_GRAB GDK_CROSSING_UNGRAB GDK_CROSSING_GTK_GRAB GDK_CROSSING_GTK_UNGRAB GDK_CROSSING_STATE_CHANGED GDK_CROSSING_TOUCH_BEGIN GDK_CROSSING_TOUCH_END GDK_CROSSING_DEVICE_SWITCH 
>;

enum GdkEventType is export <
  GDK_DELETE GDK_MOTION_NOTIFY GDK_BUTTON_PRESS GDK_BUTTON_RELEASE GDK_KEY_PRESS GDK_KEY_RELEASE GDK_ENTER_NOTIFY GDK_LEAVE_NOTIFY GDK_FOCUS_CHANGE GDK_PROXIMITY_IN GDK_PROXIMITY_OUT GDK_DRAG_ENTER GDK_DRAG_LEAVE GDK_DRAG_MOTION GDK_DROP_START GDK_SCROLL GDK_GRAB_BROKEN GDK_TOUCH_BEGIN GDK_TOUCH_UPDATE GDK_TOUCH_END GDK_TOUCH_CANCEL GDK_TOUCHPAD_SWIPE GDK_TOUCHPAD_PINCH GDK_PAD_BUTTON_PRESS GDK_PAD_BUTTON_RELEASE GDK_PAD_RING GDK_PAD_STRIP GDK_PAD_GROUP_MODE GDK_TOUCHPAD_HOLD GDK_EVENT_LAST 
>;

enum GdkKeyMatch is export <
  GDK_KEY_MATCH_NONE GDK_KEY_MATCH_PARTIAL GDK_KEY_MATCH_EXACT 
>;

enum GdkNotifyType is export <
  GDK_NOTIFY_ANCESTOR GDK_NOTIFY_VIRTUAL GDK_NOTIFY_INFERIOR GDK_NOTIFY_NONLINEAR GDK_NOTIFY_NONLINEAR_VIRTUAL GDK_NOTIFY_UNKNOWN 
>;

enum GdkScrollDirection is export <
  GDK_SCROLL_UP GDK_SCROLL_DOWN GDK_SCROLL_LEFT GDK_SCROLL_RIGHT GDK_SCROLL_SMOOTH 
>;

enum GdkScrollUnit is export <
  GDK_SCROLL_UNIT_WHEEL GDK_SCROLL_UNIT_SURFACE 
>;

enum GdkTouchpadGesturePhase is export <
  GDK_TOUCHPAD_GESTURE_PHASE_BEGIN GDK_TOUCHPAD_GESTURE_PHASE_UPDATE GDK_TOUCHPAD_GESTURE_PHASE_END GDK_TOUCHPAD_GESTURE_PHASE_CANCEL 
>;

#-------------------------------------------------------------------------------
#--[Standalone functions]-------------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(
  
  #--[Functions]----------------------------------------------------------------
  events-get-angle => %( :type(Function), :is-symbol<gdk_events_get_angle>, :returns(gboolean), :parameters([ N-Object, N-Object, CArray[gdouble]]), ),
  events-get-center => %( :type(Function), :is-symbol<gdk_events_get_center>, :returns(gboolean), :parameters([ N-Object, N-Object, CArray[gdouble], CArray[gdouble]]), ),
  events-get-distance => %( :type(Function), :is-symbol<gdk_events_get_distance>, :returns(gboolean), :parameters([ N-Object, N-Object, CArray[gdouble]]), ),

);
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    return $!routine-caller.call-native-sub(
      $name, @arguments, $methods
    );
  }

  else {
    callsame;
  }
}
