=comment Package: Gio, C-Source: io
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Gnome::GObject::Object:api<2>;

use Gnome::Gio::T-Ioenums:api<2>;

use Gnome::Glib::T-variant:api<2>;

use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gio::Notification:auth<github:MARTIMM>:api<2>;
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
  $!routine-caller .= new(:library(gio-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gio::Notification' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GNotification');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-notification => %( :type(Constructor), :is-symbol<g_notification_new>, :returns(N-Object), :parameters([ Str])),

  #--[Methods]------------------------------------------------------------------
  add-button => %(:is-symbol<g_notification_add_button>,  :parameters([Str, Str])),
  add-button-with-target => %(:is-symbol<g_notification_add_button_with_target>, :variable-list,  :parameters([Str, Str, Str])),
  add-button-with-target-value => %(:is-symbol<g_notification_add_button_with_target_value>,  :parameters([Str, Str, N-Variant])),
  set-body => %(:is-symbol<g_notification_set_body>,  :parameters([Str])),
  set-category => %(:is-symbol<g_notification_set_category>,  :parameters([Str])),
  set-default-action => %(:is-symbol<g_notification_set_default_action>,  :parameters([Str])),
  set-default-action-and-target => %(:is-symbol<g_notification_set_default_action_and_target>, :variable-list,  :parameters([Str, Str])),
  set-default-action-and-target-value => %(:is-symbol<g_notification_set_default_action_and_target_value>,  :parameters([Str, N-Variant])),
  set-icon => %(:is-symbol<g_notification_set_icon>,  :parameters([N-Object])),
  set-priority => %(:is-symbol<g_notification_set_priority>,  :parameters([GEnum])),
  set-title => %(:is-symbol<g_notification_set_title>,  :parameters([Str])),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    if $methods{$name}<type>:exists and $methods{$name}<type> eq 'Constructor' {
      my Gnome::N::GnomeRoutineCaller $routine-caller .= new(
        :library(gio-lib())
      );

      # Check the function name. 
      return self.bless(
        :native-object(
          $routine-caller.call-native-sub( $name, @arguments, $methods)
        )
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
