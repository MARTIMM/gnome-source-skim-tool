=comment Package: Gtk4, C-Source: window
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Gnome::Glib::N-List:api<2>;
use Gnome::Glib::T-list:api<2>;

use Gnome::Gtk4::R-Native:api<2>;
use Gnome::Gtk4::R-Root:api<2>;
use Gnome::Gtk4::R-ShortcutManager:api<2>;
use Gnome::Gtk4::Widget:api<2>;

use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::Window:auth<github:MARTIMM>:api<2>;
also is Gnome::Gtk4::Widget;
also does Gnome::Gtk4::R-Native;
also does Gnome::Gtk4::R-Root;
also does Gnome::Gtk4::R-ShortcutManager;

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
      :w0<activate-default keys-changed activate-focus close-request>,
      :w1<enable-debugging>,
    );

    # Signals from interfaces
    self._add_gtk_native_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_native_signal_types');
    self._add_gtk_root_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_root_signal_types');
    self._add_gtk_shortcut_manager_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_shortcut_manager_signal_types');
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::Window' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkWindow');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-window => %( :type(Constructor), :is-symbol<gtk_window_new>, :returns(N-Object), ),

  #--[Methods]------------------------------------------------------------------
  close => %(:is-symbol<gtk_window_close>, ),
  destroy => %(:is-symbol<gtk_window_destroy>, ),
  fullscreen => %(:is-symbol<gtk_window_fullscreen>, ),
  fullscreen-on-monitor => %(:is-symbol<gtk_window_fullscreen_on_monitor>,  :parameters([N-Object])),
  get-application => %(:is-symbol<gtk_window_get_application>,  :returns(N-Object)),
  get-child => %(:is-symbol<gtk_window_get_child>,  :returns(N-Object)),
  get-decorated => %(:is-symbol<gtk_window_get_decorated>,  :returns(gboolean), :cnv-return(Bool)),
  get-default-size => %(:is-symbol<gtk_window_get_default_size>,  :parameters([gint-ptr, gint-ptr])),
  get-default-widget => %(:is-symbol<gtk_window_get_default_widget>,  :returns(N-Object)),
  get-deletable => %(:is-symbol<gtk_window_get_deletable>,  :returns(gboolean), :cnv-return(Bool)),
  get-destroy-with-parent => %(:is-symbol<gtk_window_get_destroy_with_parent>,  :returns(gboolean), :cnv-return(Bool)),
  get-focus => %(:is-symbol<gtk_window_get_focus>,  :returns(N-Object)),
  get-focus-visible => %(:is-symbol<gtk_window_get_focus_visible>,  :returns(gboolean), :cnv-return(Bool)),
  get-group => %(:is-symbol<gtk_window_get_group>,  :returns(N-Object)),
  get-handle-menubar-accel => %(:is-symbol<gtk_window_get_handle_menubar_accel>,  :returns(gboolean), :cnv-return(Bool)),
  get-hide-on-close => %(:is-symbol<gtk_window_get_hide_on_close>,  :returns(gboolean), :cnv-return(Bool)),
  get-icon-name => %(:is-symbol<gtk_window_get_icon_name>,  :returns(Str)),
  get-mnemonics-visible => %(:is-symbol<gtk_window_get_mnemonics_visible>,  :returns(gboolean), :cnv-return(Bool)),
  get-modal => %(:is-symbol<gtk_window_get_modal>,  :returns(gboolean), :cnv-return(Bool)),
  get-resizable => %(:is-symbol<gtk_window_get_resizable>,  :returns(gboolean), :cnv-return(Bool)),
  get-title => %(:is-symbol<gtk_window_get_title>,  :returns(Str)),
  get-titlebar => %(:is-symbol<gtk_window_get_titlebar>,  :returns(N-Object)),
  get-transient-for => %(:is-symbol<gtk_window_get_transient_for>,  :returns(N-Object)),
  has-group => %(:is-symbol<gtk_window_has_group>,  :returns(gboolean), :cnv-return(Bool)),
  is-active => %(:is-symbol<gtk_window_is_active>,  :returns(gboolean), :cnv-return(Bool)),
  is-fullscreen => %(:is-symbol<gtk_window_is_fullscreen>,  :returns(gboolean), :cnv-return(Bool)),
  is-maximized => %(:is-symbol<gtk_window_is_maximized>,  :returns(gboolean), :cnv-return(Bool)),
  maximize => %(:is-symbol<gtk_window_maximize>, ),
  minimize => %(:is-symbol<gtk_window_minimize>, ),
  present => %(:is-symbol<gtk_window_present>, ),
  present-with-time => %(:is-symbol<gtk_window_present_with_time>,  :parameters([guint32])),
  set-application => %(:is-symbol<gtk_window_set_application>,  :parameters([N-Object])),
  set-child => %(:is-symbol<gtk_window_set_child>,  :parameters([N-Object])),
  set-decorated => %(:is-symbol<gtk_window_set_decorated>,  :parameters([gboolean])),
  set-default-size => %(:is-symbol<gtk_window_set_default_size>,  :parameters([gint, gint])),
  set-default-widget => %(:is-symbol<gtk_window_set_default_widget>,  :parameters([N-Object])),
  set-deletable => %(:is-symbol<gtk_window_set_deletable>,  :parameters([gboolean])),
  set-destroy-with-parent => %(:is-symbol<gtk_window_set_destroy_with_parent>,  :parameters([gboolean])),
  set-display => %(:is-symbol<gtk_window_set_display>,  :parameters([N-Object])),
  set-focus => %(:is-symbol<gtk_window_set_focus>,  :parameters([N-Object])),
  set-focus-visible => %(:is-symbol<gtk_window_set_focus_visible>,  :parameters([gboolean])),
  set-handle-menubar-accel => %(:is-symbol<gtk_window_set_handle_menubar_accel>,  :parameters([gboolean])),
  set-hide-on-close => %(:is-symbol<gtk_window_set_hide_on_close>,  :parameters([gboolean])),
  set-icon-name => %(:is-symbol<gtk_window_set_icon_name>,  :parameters([Str])),
  set-mnemonics-visible => %(:is-symbol<gtk_window_set_mnemonics_visible>,  :parameters([gboolean])),
  set-modal => %(:is-symbol<gtk_window_set_modal>,  :parameters([gboolean])),
  set-resizable => %(:is-symbol<gtk_window_set_resizable>,  :parameters([gboolean])),
  set-startup-id => %(:is-symbol<gtk_window_set_startup_id>,  :parameters([Str])),
  set-title => %(:is-symbol<gtk_window_set_title>,  :parameters([Str])),
  set-titlebar => %(:is-symbol<gtk_window_set_titlebar>,  :parameters([N-Object])),
  set-transient-for => %(:is-symbol<gtk_window_set_transient_for>,  :parameters([N-Object])),
  unfullscreen => %(:is-symbol<gtk_window_unfullscreen>, ),
  unmaximize => %(:is-symbol<gtk_window_unmaximize>, ),
  unminimize => %(:is-symbol<gtk_window_unminimize>, ),

  #--[Functions]----------------------------------------------------------------
  get-default-icon-name => %( :type(Function), :is-symbol<gtk_window_get_default_icon_name>,  :returns(Str)),
  get-toplevels => %( :type(Function), :is-symbol<gtk_window_get_toplevels>,  :returns(N-Object)),
  list-toplevels => %( :type(Function), :is-symbol<gtk_window_list_toplevels>,  :returns(N-List)),
  set-auto-startup-notification => %( :type(Function), :is-symbol<gtk_window_set_auto_startup_notification>,  :parameters([gboolean])),
  set-default-icon-name => %( :type(Function), :is-symbol<gtk_window_set_default_icon_name>,  :parameters([Str])),
  set-interactive-debugging => %( :type(Function), :is-symbol<gtk_window_set_interactive_debugging>,  :parameters([gboolean])),
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
    my $r;
    my $native-object = self.get-native-object-no-reffing;
    $r = self._do_gtk_native_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    ) if self.^can('_do_gtk_native_fallback-v2');
    return $r if $_fallback-v2-ok;

    $r = self._do_gtk_root_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    ) if self.^can('_do_gtk_root_fallback-v2');
    return $r if $_fallback-v2-ok;

    $r = self._do_gtk_shortcut_manager_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    ) if self.^can('_do_gtk_shortcut_manager_fallback-v2');
    return $r if $_fallback-v2-ok;

    callsame;
  }
}
