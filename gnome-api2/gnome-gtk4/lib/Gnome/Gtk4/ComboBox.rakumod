=comment Package: Gtk4, C-Source: combobox
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Gtk4::N-TreeIter:api<2>;
use Gnome::Gtk4::R-CellEditable:api<2>;
use Gnome::Gtk4::R-CellLayout:api<2>;
use Gnome::Gtk4::T-Enums:api<2>;
use Gnome::Gtk4::Widget:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::ComboBox:auth<github:MARTIMM>:api<2>;
also is Gnome::Gtk4::Widget;
also does Gnome::Gtk4::R-CellEditable;
also does Gnome::Gtk4::R-CellLayout;

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
      :w0<activate changed popdown popup>,
      :w1<move-active format-entry-text>,
    );

    # Signals from interfaces
    self._add_gtk_cell_editable_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_cell_editable_signal_types');
    self._add_gtk_cell_layout_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_cell_layout_signal_types');
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::ComboBox' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkComboBox');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-combobox => %( :type(Constructor), :is-symbol<gtk_combo_box_new>, :returns(N-Object), ),
  new-with-entry => %( :type(Constructor), :is-symbol<gtk_combo_box_new_with_entry>, :returns(N-Object), ),
  new-with-model => %( :type(Constructor), :is-symbol<gtk_combo_box_new_with_model>, :returns(N-Object), :parameters([ N-Object])),
  new-with-model-and-entry => %( :type(Constructor), :is-symbol<gtk_combo_box_new_with_model_and_entry>, :returns(N-Object), :parameters([ N-Object])),

  #--[Methods]------------------------------------------------------------------
  get-active => %(:is-symbol<gtk_combo_box_get_active>,  :returns(gint)),
  get-active-id => %(:is-symbol<gtk_combo_box_get_active_id>,  :returns(Str)),
  get-active-iter => %(:is-symbol<gtk_combo_box_get_active_iter>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-TreeIter])),
  get-button-sensitivity => %(:is-symbol<gtk_combo_box_get_button_sensitivity>,  :returns(GEnum), :cnv-return(GtkSensitivityType)),
  get-child => %(:is-symbol<gtk_combo_box_get_child>,  :returns(N-Object)),
  get-entry-text-column => %(:is-symbol<gtk_combo_box_get_entry_text_column>,  :returns(gint)),
  get-has-entry => %(:is-symbol<gtk_combo_box_get_has_entry>,  :returns(gboolean), :cnv-return(Bool)),
  get-id-column => %(:is-symbol<gtk_combo_box_get_id_column>,  :returns(gint)),
  get-model => %(:is-symbol<gtk_combo_box_get_model>,  :returns(N-Object)),
  get-popup-fixed-width => %(:is-symbol<gtk_combo_box_get_popup_fixed_width>,  :returns(gboolean), :cnv-return(Bool)),
#  get-row-separator-func => %(:is-symbol<gtk_combo_box_get_row_separator_func>,  :returns(), :cnv-return(( N-Object $model, N-TreeIter $iter, gpointer $data --> gboolean ))),
  popdown => %(:is-symbol<gtk_combo_box_popdown>, ),
  popup => %(:is-symbol<gtk_combo_box_popup>, ),
  popup-for-device => %(:is-symbol<gtk_combo_box_popup_for_device>,  :parameters([N-Object])),
  set-active => %(:is-symbol<gtk_combo_box_set_active>,  :parameters([gint])),
  set-active-id => %(:is-symbol<gtk_combo_box_set_active_id>,  :returns(gboolean), :cnv-return(Bool), :parameters([Str])),
  set-active-iter => %(:is-symbol<gtk_combo_box_set_active_iter>,  :parameters([N-TreeIter])),
  set-button-sensitivity => %(:is-symbol<gtk_combo_box_set_button_sensitivity>,  :parameters([GEnum])),
  set-child => %(:is-symbol<gtk_combo_box_set_child>,  :parameters([N-Object])),
  set-entry-text-column => %(:is-symbol<gtk_combo_box_set_entry_text_column>,  :parameters([gint])),
  set-id-column => %(:is-symbol<gtk_combo_box_set_id_column>,  :parameters([gint])),
  set-model => %(:is-symbol<gtk_combo_box_set_model>,  :parameters([N-Object])),
  set-popup-fixed-width => %(:is-symbol<gtk_combo_box_set_popup_fixed_width>,  :parameters([gboolean])),
  #set-row-separator-func => %(:is-symbol<gtk_combo_box_set_row_separator_func>,  :parameters([:( N-Object $model, N-TreeIter $iter, gpointer $data --> gboolean ), gpointer, ])),
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
    $r = self._do_gtk_cell_editable_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    ) if self.^can('_do_gtk_cell_editable_fallback-v2');
    return $r if $_fallback-v2-ok;

    $r = self._do_gtk_cell_layout_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    ) if self.^can('_do_gtk_cell_layout_fallback-v2');
    return $r if $_fallback-v2-ok;

    callsame;
  }
}
