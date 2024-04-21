=comment Package: Gio, C-Source: application
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Gnome::GObject::Object:api<2>;

use Gnome::Gio::R-ActionGroup:api<2>;
use Gnome::Gio::R-ActionMap:api<2>;
use Gnome::Gio::T-ioenums:api<2>;

use Gnome::Glib::N-Error:api<2>;
use Gnome::Glib::T-error:api<2>;
#use Gnome::Glib::N-OptionEntry:api<2>;
#use Gnome::Glib::N-OptionGroup:api<2>;
#use Gnome::Glib::T-OptionEntry:api<2>;

use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gio::Application:auth<github:MARTIMM>:api<2>;
also is Gnome::GObject::Object;
also does Gnome::Gio::R-ActionGroup;
also does Gnome::Gio::R-ActionMap;

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
      :w0<name-lost activate shutdown startup>,
      :w1<handle-local-options command-line>,
      :w3<open>,
    );

    # Signals from interfaces
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gio-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gio::Application' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GApplication');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-application => %( :type(Constructor), :is-symbol<g_application_new>, :returns(N-Object), :parameters([ Str, GFlag])),

  #--[Methods]------------------------------------------------------------------
  activate => %(:is-symbol<g_application_activate>, ),
  #add-main-option => %(:is-symbol<g_application_add_main_option>,  :parameters([Str, gchar, GFlag, GEnum, Str, Str])),
  #add-main-option-entries => %(:is-symbol<g_application_add_main_option_entries>,  :parameters([N-OptionEntry ])),
  #add-option-group => %(:is-symbol<g_application_add_option_group>,  :parameters([N-OptionGroup ])),
  bind-busy-property => %(:is-symbol<g_application_bind_busy_property>,  :parameters([gpointer, Str])),
  get-application-id => %(:is-symbol<g_application_get_application_id>,  :returns(Str)),
  get-dbus-connection => %(:is-symbol<g_application_get_dbus_connection>,  :returns(N-Object)),
  get-dbus-object-path => %(:is-symbol<g_application_get_dbus_object_path>,  :returns(Str)),
  get-flags => %(:is-symbol<g_application_get_flags>,  :returns(GFlag), :cnv-return(GApplicationFlags)),
  get-inactivity-timeout => %(:is-symbol<g_application_get_inactivity_timeout>,  :returns(guint)),
  get-is-busy => %(:is-symbol<g_application_get_is_busy>,  :returns(gboolean), :cnv-return(Bool)),
  get-is-registered => %(:is-symbol<g_application_get_is_registered>,  :returns(gboolean), :cnv-return(Bool)),
  get-is-remote => %(:is-symbol<g_application_get_is_remote>,  :returns(gboolean), :cnv-return(Bool)),
  get-resource-base-path => %(:is-symbol<g_application_get_resource_base_path>,  :returns(Str)),
  hold => %(:is-symbol<g_application_hold>, ),
  mark-busy => %(:is-symbol<g_application_mark_busy>, ),
  open => %(:is-symbol<g_application_open>,  :parameters([CArray[N-Object], gint, Str])),
  quit => %(:is-symbol<g_application_quit>, ),
  register => %(:is-symbol<g_application_register>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, CArray[N-Error]])),
  release => %(:is-symbol<g_application_release>, ),
  run => %(:is-symbol<g_application_run>,  :returns(gint), :parameters([gint, gchar-pptr])),
  send-notification => %(:is-symbol<g_application_send_notification>,  :parameters([Str, N-Object])),
  set-application-id => %(:is-symbol<g_application_set_application_id>,  :parameters([Str])),
  set-default => %(:is-symbol<g_application_set_default>, ),
  set-flags => %(:is-symbol<g_application_set_flags>,  :parameters([GFlag])),
  set-inactivity-timeout => %(:is-symbol<g_application_set_inactivity_timeout>,  :parameters([guint])),
  set-option-context-description => %(:is-symbol<g_application_set_option_context_description>,  :parameters([Str])),
  set-option-context-parameter-string => %(:is-symbol<g_application_set_option_context_parameter_string>,  :parameters([Str])),
  set-option-context-summary => %(:is-symbol<g_application_set_option_context_summary>,  :parameters([Str])),
  set-resource-base-path => %(:is-symbol<g_application_set_resource_base_path>,  :parameters([Str])),
  unbind-busy-property => %(:is-symbol<g_application_unbind_busy_property>,  :parameters([gpointer, Str])),
  unmark-busy => %(:is-symbol<g_application_unmark_busy>, ),
  withdraw-notification => %(:is-symbol<g_application_withdraw_notification>,  :parameters([Str])),

  #--[Functions]----------------------------------------------------------------
  get-default => %( :type(Function), :is-symbol<g_application_get_default>,  :returns(N-Object)),
  id-is-valid => %( :type(Function), :is-symbol<g_application_id_is_valid>,  :returns(gboolean), :parameters([Str])),
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
    my $r;
    my $native-object = self.get-native-object-no-reffing;
    $r = self.Gnome::Gio::R-ActionGroup::_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    );
    return $r if $_fallback-v2-ok;

    $r = self.Gnome::Gio::R-ActionMap::_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    );
    return $r if $_fallback-v2-ok;

    callsame;
  }
}
