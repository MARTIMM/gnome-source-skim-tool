=comment Package: Gtk4, C-Source: gesture
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


#use Gnome::Gdk4::N-EventSequence:api<2>;
use Gnome::Gdk4::N-Rectangle:api<2>;
#use Gnome::Gdk4::T-events:api<2>;
use Gnome::Gdk4::T-types:api<2>;
use Gnome::Glib::N-List:api<2>;
use Gnome::Glib::T-list:api<2>;
use Gnome::Gtk4::EventController:api<2>;
use Gnome::Gtk4::T-enums:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::Gesture:auth<github:MARTIMM>:api<2>;
also is Gnome::Gtk4::EventController;

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
      :w1<cancel end update begin>,
      :w2<sequence-state-changed>,
    );
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::Gesture' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkGesture');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  get-bounding-box => %(:is-symbol<gtk_gesture_get_bounding_box>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  get-bounding-box-center => %(:is-symbol<gtk_gesture_get_bounding_box_center>,  :returns(gboolean), :cnv-return(Bool), :parameters([CArray[gdouble], CArray[gdouble]])),
  get-device => %(:is-symbol<gtk_gesture_get_device>,  :returns(N-Object)),
  get-group => %(:is-symbol<gtk_gesture_get_group>,  :returns(N-Object)),
  get-last-event => %(:is-symbol<gtk_gesture_get_last_event>,  :returns(N-Object), :parameters([N-Object])),
  get-last-updated-sequence => %(:is-symbol<gtk_gesture_get_last_updated_sequence>,  :returns(N-Object)),
  get-point => %(:is-symbol<gtk_gesture_get_point>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, CArray[gdouble], CArray[gdouble]])),
  get-sequence-state => %(:is-symbol<gtk_gesture_get_sequence_state>,  :returns(GEnum), :cnv-return(GtkEventSequenceState), :parameters([N-Object])),
  get-sequences => %(:is-symbol<gtk_gesture_get_sequences>,  :returns(N-Object)),
  group => %(:is-symbol<gtk_gesture_group>,  :parameters([N-Object])),
  handles-sequence => %(:is-symbol<gtk_gesture_handles_sequence>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  is-active => %(:is-symbol<gtk_gesture_is_active>,  :returns(gboolean), :cnv-return(Bool)),
  is-grouped-with => %(:is-symbol<gtk_gesture_is_grouped_with>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  is-recognized => %(:is-symbol<gtk_gesture_is_recognized>,  :returns(gboolean), :cnv-return(Bool)),
  set-sequence-state => %(:is-symbol<gtk_gesture_set_sequence_state>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, GEnum]),:deprecated, :deprecated-version<4.10.>, ),
  set-state => %(:is-symbol<gtk_gesture_set_state>,  :returns(gboolean), :cnv-return(Bool), :parameters([GEnum])),
  ungroup => %(:is-symbol<gtk_gesture_ungroup>, ),
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
