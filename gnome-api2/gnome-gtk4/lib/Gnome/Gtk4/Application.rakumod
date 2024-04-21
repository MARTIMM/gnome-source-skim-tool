=comment Package: Gtk4, C-Source: application
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Gnome::Gio::Application:api<2>;
use Gnome::Gio::T-ioenums:api<2>;

use Gnome::Glib::N-List:api<2>;
use Gnome::Glib::T-list:api<2>;

use Gnome::Gtk4::T-application:api<2>;

use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::Application:auth<github:MARTIMM>:api<2>;
also is Gnome::Gio::Application;

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
      :w0<query-end>,
      :w1<window-removed window-added>,
    );
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::Application' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkApplication');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-application => %( :type(Constructor), :is-symbol<gtk_application_new>, :returns(N-Object), :parameters([ Str, GFlag])),

  #--[Methods]------------------------------------------------------------------
  add-window => %(:is-symbol<gtk_application_add_window>,  :parameters([N-Object])),
  get-accels-for-action => %(:is-symbol<gtk_application_get_accels_for_action>,  :returns(gchar-pptr), :parameters([Str])),
  get-actions-for-accel => %(:is-symbol<gtk_application_get_actions_for_accel>,  :returns(gchar-pptr), :parameters([Str])),
  get-active-window => %(:is-symbol<gtk_application_get_active_window>,  :returns(N-Object)),
  get-menu-by-id => %(:is-symbol<gtk_application_get_menu_by_id>,  :returns(N-Object), :parameters([Str])),
  get-menubar => %(:is-symbol<gtk_application_get_menubar>,  :returns(N-Object)),
  get-window-by-id => %(:is-symbol<gtk_application_get_window_by_id>,  :returns(N-Object), :parameters([guint])),
  get-windows => %(:is-symbol<gtk_application_get_windows>,  :returns(N-List)),
  inhibit => %(:is-symbol<gtk_application_inhibit>,  :returns(guint), :parameters([N-Object, GFlag, Str])),
  list-action-descriptions => %(:is-symbol<gtk_application_list_action_descriptions>,  :returns(gchar-pptr)),
  remove-window => %(:is-symbol<gtk_application_remove_window>,  :parameters([N-Object])),
  set-accels-for-action => %(:is-symbol<gtk_application_set_accels_for_action>,  :parameters([Str, gchar-pptr])),
  set-menubar => %(:is-symbol<gtk_application_set_menubar>,  :parameters([N-Object])),
  uninhibit => %(:is-symbol<gtk_application_uninhibit>,  :parameters([guint])),
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

      # Check the function name. 
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
