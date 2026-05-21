=comment Package: Gdk4, C-Source: events
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;



use Gnome::Gdk4::Event:api<2>;
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

unit class Gnome::Gdk4::KeyEvent:auth<github:MARTIMM>:api<2>;
also is Gnome::Gdk4::Event;

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
  if self.^name eq 'Gnome::Gdk4::KeyEvent' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GdkKeyEvent');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  get-consumed-modifiers => %(:is-symbol<gdk_key_event_get_consumed_modifiers>,  :returns(GFlag), :cnv-return(GdkModifierType)),
  get-keycode => %(:is-symbol<gdk_key_event_get_keycode>, :returns(guint), ),
  get-keyval => %(:is-symbol<gdk_key_event_get_keyval>, :returns(guint), ),
  get-layout => %(:is-symbol<gdk_key_event_get_layout>, :returns(guint), ),
  get-level => %(:is-symbol<gdk_key_event_get_level>, :returns(guint), ),
  get-match => %(:is-symbol<gdk_key_event_get_match>, :returns(gboolean), :cnv-return(Bool), :parameters([gint-ptr, GFlag]), ),
  is-modifier => %(:is-symbol<gdk_key_event_is_modifier>, :returns(gboolean), :cnv-return(Bool), ),
  matches => %(:is-symbol<gdk_key_event_matches>,  :returns(GEnum), :cnv-return(GdkKeyMatch),:parameters([guint, GFlag]), ),
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
