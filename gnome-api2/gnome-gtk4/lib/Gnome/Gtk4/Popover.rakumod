=comment Package: Gtk4, C-Source: popover
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Cairo;


use Gnome::Gdk4::N-Rectangle:api<2>;
use Gnome::Gdk4::T-types:api<2>;
use Gnome::Gtk4::R-Native:api<2>;
use Gnome::Gtk4::R-ShortcutManager:api<2>;
use Gnome::Gtk4::T-enums:api<2>;
use Gnome::Gtk4::Widget:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::Popover:auth<github:MARTIMM>:api<2>;
also is Gnome::Gtk4::Widget;
also does Gnome::Gtk4::R-Native;
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
      :w0<closed activate-default>,
    );

    # Signals from interfaces
    self._add_gtk_native_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_native_signal_types');
    self._add_gtk_shortcut_manager_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_shortcut_manager_signal_types');
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::Popover' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkPopover');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-popover => %( :type(Constructor), :is-symbol<gtk_popover_new>, :returns(N-Object), ),

  #--[Methods]------------------------------------------------------------------
  get-autohide => %(:is-symbol<gtk_popover_get_autohide>, :returns(gboolean), :cnv-return(Bool), ),
  get-cascade-popdown => %(:is-symbol<gtk_popover_get_cascade_popdown>, :returns(gboolean), :cnv-return(Bool), ),
  get-child => %(:is-symbol<gtk_popover_get_child>, :returns(N-Object), ),
  get-has-arrow => %(:is-symbol<gtk_popover_get_has_arrow>, :returns(gboolean), :cnv-return(Bool), ),
  get-mnemonics-visible => %(:is-symbol<gtk_popover_get_mnemonics_visible>, :returns(gboolean), :cnv-return(Bool), ),
  get-offset => %(:is-symbol<gtk_popover_get_offset>, :parameters([gint-ptr, gint-ptr]), ),
  get-pointing-to => %(:is-symbol<gtk_popover_get_pointing_to>, :returns(gboolean), :cnv-return(Bool), :parameters([N-Object]), ),
  get-position => %(:is-symbol<gtk_popover_get_position>,  :returns(GEnum), :cnv-return(GtkPositionType)),
  popdown => %(:is-symbol<gtk_popover_popdown>, ),
  popup => %(:is-symbol<gtk_popover_popup>, ),
  present => %(:is-symbol<gtk_popover_present>, ),
  set-autohide => %(:is-symbol<gtk_popover_set_autohide>, :parameters([gboolean]), ),
  set-cascade-popdown => %(:is-symbol<gtk_popover_set_cascade_popdown>, :parameters([gboolean]), ),
  set-child => %(:is-symbol<gtk_popover_set_child>, :parameters([N-Object]), ),
  set-default-widget => %(:is-symbol<gtk_popover_set_default_widget>, :parameters([N-Object]), ),
  set-has-arrow => %(:is-symbol<gtk_popover_set_has_arrow>, :parameters([gboolean]), ),
  set-mnemonics-visible => %(:is-symbol<gtk_popover_set_mnemonics_visible>, :parameters([gboolean]), ),
  set-offset => %(:is-symbol<gtk_popover_set_offset>, :parameters([gint, gint]), ),
  set-pointing-to => %(:is-symbol<gtk_popover_set_pointing_to>, :parameters([N-Object]), ),
  set-position => %(:is-symbol<gtk_popover_set_position>, :parameters([GEnum]), ),
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

    $r = self._do_gtk_shortcut_manager_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    ) if self.^can('_do_gtk_shortcut_manager_fallback-v2');
    return $r if $_fallback-v2-ok;

    callsame;
  }
}
