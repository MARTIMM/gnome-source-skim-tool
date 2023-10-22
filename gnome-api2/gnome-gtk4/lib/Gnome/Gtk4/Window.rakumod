# Command to generate: generate.raku -c -t Gtk4 window
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Glib::N-List:api<2>;
#use Gnome::Gtk4::R-Native:api<2>;
#use Gnome::Gtk4::R-Root:api<2>;
#use Gnome::Gtk4::R-ShortcutManager:api<2>;
use Gnome::Gtk4::Widget:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-GObject:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::Window:auth<github:MARTIMM>:api<2>;
also is Gnome::Gtk4::Widget;
#also does Gnome::Gtk4::R-Native;
#also does Gnome::Gtk4::R-Root;
#also does Gnome::Gtk4::R-ShortcutManager;

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
      :w0<close-request activate-default keys-changed activate-focus>,
      :w1<enable-debugging>,
    );

    # Signals from interfaces
#`{{
    self._add_gtk_native_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_native_signal_types');
}}
#`{{
    self._add_gtk_root_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_root_signal_types');
}}
#`{{
    self._add_gtk_shortcut_manager_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_shortcut_manager_signal_types');
}}
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new( :library(gtk4-lib()), :sub-prefix<gtk_window_>);

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::Window' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    die X::Gnome.new(:message("Native object not defined"))
      unless self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkWindow');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-window => %( :type(Constructor), :isnew, :returns(N-GObject), ),

  #--[Methods]------------------------------------------------------------------
  close => %(),
  destroy => %(),
  fullscreen => %(),
  fullscreen-on-monitor => %( :parameters([N-GObject])),
  get-application => %( :returns(N-GObject)),
  get-child => %( :returns(N-GObject)),
  get-decorated => %( :returns(gboolean), :cnv-return(Bool)),
  get-default-size => %( :parameters([gint-ptr, gint-ptr])),
  get-default-widget => %( :returns(N-GObject)),
  get-deletable => %( :returns(gboolean), :cnv-return(Bool)),
  get-destroy-with-parent => %( :returns(gboolean), :cnv-return(Bool)),
  get-focus => %( :returns(N-GObject)),
  get-focus-visible => %( :returns(gboolean), :cnv-return(Bool)),
  get-group => %( :returns(N-GObject)),
  get-handle-menubar-accel => %( :returns(gboolean), :cnv-return(Bool)),
  get-hide-on-close => %( :returns(gboolean), :cnv-return(Bool)),
  get-icon-name => %( :returns(Str)),
  get-mnemonics-visible => %( :returns(gboolean), :cnv-return(Bool)),
  get-modal => %( :returns(gboolean), :cnv-return(Bool)),
  get-resizable => %( :returns(gboolean), :cnv-return(Bool)),
  get-title => %( :returns(Str)),
  get-titlebar => %( :returns(N-GObject)),
  get-transient-for => %( :returns(N-GObject)),
  has-group => %( :returns(gboolean), :cnv-return(Bool)),
  is-active => %( :returns(gboolean), :cnv-return(Bool)),
  is-fullscreen => %( :returns(gboolean), :cnv-return(Bool)),
  is-maximized => %( :returns(gboolean), :cnv-return(Bool)),
  maximize => %(),
  minimize => %(),
  present => %(),
  present-with-time => %( :parameters([guint32])),
  set-application => %( :parameters([N-GObject])),
  set-child => %( :parameters([N-GObject])),
  set-decorated => %( :parameters([gboolean])),
  set-default-size => %( :parameters([gint, gint])),
  set-default-widget => %( :parameters([N-GObject])),
  set-deletable => %( :parameters([gboolean])),
  set-destroy-with-parent => %( :parameters([gboolean])),
  set-display => %( :parameters([N-GObject])),
  set-focus => %( :parameters([N-GObject])),
  set-focus-visible => %( :parameters([gboolean])),
  set-handle-menubar-accel => %( :parameters([gboolean])),
  set-hide-on-close => %( :parameters([gboolean])),
  set-icon-name => %( :parameters([Str])),
  set-mnemonics-visible => %( :parameters([gboolean])),
  set-modal => %( :parameters([gboolean])),
  set-resizable => %( :parameters([gboolean])),
  set-startup-id => %( :parameters([Str])),
  set-title => %( :parameters([Str])),
  set-titlebar => %( :parameters([N-GObject])),
  set-transient-for => %( :parameters([N-GObject])),
  unfullscreen => %(),
  unmaximize => %(),
  unminimize => %(),

  #--[Functions]----------------------------------------------------------------
  get-default-icon-name => %( :type(Function),  :returns(Str)),
  get-toplevels => %( :type(Function),  :returns(N-GObject)),
  list-toplevels => %( :type(Function),  :returns(N-List)),
  set-auto-startup-notification => %( :type(Function),  :parameters([gboolean])),
  set-default-icon-name => %( :type(Function),  :parameters([Str])),
  set-interactive-debugging => %( :type(Function),  :parameters([gboolean])),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    if $methods{$name}<type>:exists and $methods{$name}<type> eq 'Constructor' {
      my Gnome::N::GnomeRoutineCaller $routine-caller .= new(
        :library(gtk4-lib()), :sub-prefix<gtk_window_>
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
#`{{
    $r = self.Gnome::Gtk4::R-Native::_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    );
    return $r if $_fallback-v2-ok;

}}
#`{{
    $r = self.Gnome::Gtk4::R-Root::_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    );
    return $r if $_fallback-v2-ok;

}}
#`{{
    $r = self.Gnome::Gtk4::R-ShortcutManager::_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    );
    return $r if $_fallback-v2-ok;

}}
    callsame;
  }
}
