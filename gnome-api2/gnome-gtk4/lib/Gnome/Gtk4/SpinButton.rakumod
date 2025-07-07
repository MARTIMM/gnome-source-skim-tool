=comment Package: Gtk4, C-Source: spinbutton
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Cairo;


#use Gnome::Gtk4::R-AccessibleRange:api<2>;
use Gnome::Gtk4::R-CellEditable:api<2>;
use Gnome::Gtk4::R-Editable:api<2>;
use Gnome::Gtk4::R-Orientable:api<2>;
use Gnome::Gtk4::T-spinbutton:api<2>;
use Gnome::Gtk4::Widget:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::SpinButton:auth<github:MARTIMM>:api<2>;
also is Gnome::Gtk4::Widget;
#also does Gnome::Gtk4::R-AccessibleRange;
also does Gnome::Gtk4::R-CellEditable;
also does Gnome::Gtk4::R-Editable;
also does Gnome::Gtk4::R-Orientable;

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
      :w0<activate value-changed wrapped output>,
      :w1<input change-value>,
    );

    # Signals from interfaces
#`{{
    self._add_gtk_accessible_range_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_accessible_range_signal_types');
}}
    self._add_gtk_cell_editable_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_cell_editable_signal_types');
    self._add_gtk_editable_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_editable_signal_types');
    self._add_gtk_orientable_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_orientable_signal_types');
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::SpinButton' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkSpinButton');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-spinbutton => %( :type(Constructor), :is-symbol<gtk_spin_button_new>, :returns(N-Object), :parameters([ N-Object, gdouble, guint]), ),
  new-with-range => %( :type(Constructor), :is-symbol<gtk_spin_button_new_with_range>, :returns(N-Object), :parameters([ gdouble, gdouble, gdouble]), ),

  #--[Methods]------------------------------------------------------------------
  configure => %(:is-symbol<gtk_spin_button_configure>, :parameters([N-Object, gdouble, guint]), ),
  get-activates-default => %(:is-symbol<gtk_spin_button_get_activates_default>, :returns(gboolean), ),
  get-adjustment => %(:is-symbol<gtk_spin_button_get_adjustment>, :returns(N-Object), ),
  get-climb-rate => %(:is-symbol<gtk_spin_button_get_climb_rate>, :returns(gdouble), ),
  get-digits => %(:is-symbol<gtk_spin_button_get_digits>, :returns(guint), ),
  get-increments => %(:is-symbol<gtk_spin_button_get_increments>, :parameters([CArray[gdouble], CArray[gdouble]]), ),
  get-numeric => %(:is-symbol<gtk_spin_button_get_numeric>, :returns(gboolean), ),
  get-range => %(:is-symbol<gtk_spin_button_get_range>, :parameters([CArray[gdouble], CArray[gdouble]]), ),
  get-snap-to-ticks => %(:is-symbol<gtk_spin_button_get_snap_to_ticks>, :returns(gboolean), ),
  get-update-policy => %(:is-symbol<gtk_spin_button_get_update_policy>,  :returns(GEnum), :cnv-return(GtkSpinButtonUpdatePolicy)),
  get-value => %(:is-symbol<gtk_spin_button_get_value>, :returns(gdouble), ),
  get-value-as-int => %(:is-symbol<gtk_spin_button_get_value_as_int>, :returns(gint), ),
  get-wrap => %(:is-symbol<gtk_spin_button_get_wrap>, :returns(gboolean), ),
  set-activates-default => %(:is-symbol<gtk_spin_button_set_activates_default>, :parameters([gboolean]), ),
  set-adjustment => %(:is-symbol<gtk_spin_button_set_adjustment>, :parameters([N-Object]), ),
  set-climb-rate => %(:is-symbol<gtk_spin_button_set_climb_rate>, :parameters([gdouble]), ),
  set-digits => %(:is-symbol<gtk_spin_button_set_digits>, :parameters([guint]), ),
  set-increments => %(:is-symbol<gtk_spin_button_set_increments>, :parameters([gdouble, gdouble]), ),
  set-numeric => %(:is-symbol<gtk_spin_button_set_numeric>, :parameters([gboolean]), ),
  set-range => %(:is-symbol<gtk_spin_button_set_range>, :parameters([gdouble, gdouble]), ),
  set-snap-to-ticks => %(:is-symbol<gtk_spin_button_set_snap_to_ticks>, :parameters([gboolean]), ),
  set-update-policy => %(:is-symbol<gtk_spin_button_set_update_policy>, :parameters([GEnum]), ),
  set-value => %(:is-symbol<gtk_spin_button_set_value>, :parameters([gdouble]), ),
  set-wrap => %(:is-symbol<gtk_spin_button_set_wrap>, :parameters([gboolean]), ),
  spin => %(:is-symbol<gtk_spin_button_spin>, :parameters([GEnum, gdouble]), ),
  update => %(:is-symbol<gtk_spin_button_update>, ),
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
#`{{
    $r = self._do_gtk_accessible_range_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    ) if self.^can('_do_gtk_accessible_range_fallback-v2');
    return $r if $_fallback-v2-ok;

}}
    $r = self._do_gtk_cell_editable_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    ) if self.^can('_do_gtk_cell_editable_fallback-v2');
    return $r if $_fallback-v2-ok;

    $r = self._do_gtk_editable_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    ) if self.^can('_do_gtk_editable_fallback-v2');
    return $r if $_fallback-v2-ok;

    $r = self._do_gtk_orientable_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    ) if self.^can('_do_gtk_orientable_fallback-v2');
    return $r if $_fallback-v2-ok;

    callsame;
  }
}
