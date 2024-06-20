=comment Package: Gtk4, C-Source: combobox
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Gtk4::N-TreeIter:api<2>;
use Gnome::Gtk4::T-enums:api<2>;
#use Gnome::Gtk4::T-treemodel:api<2>;
use Gnome::Gtk4::Widget:api<2>;
#use Gnome::N:api<2>;
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

  Gnome::N::deprecate(
    'Gnome::Gtk4::ComboBox', ', Str, ',
    '4.10', Str,
    :class, :gnome-lib(gtk4-lib())  
  );

  # Add signal administration info.
  unless $signals-added {
    self.add-signal-types( $?CLASS.^name,
      :w0<popdown activate changed popup>,
      :w1<format-entry-text move-active>,
    );
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
  new-combobox => %( :type(Constructor), :is-symbol<gtk_combo_box_new>, :returns(N-Object), :deprecated, :deprecated-version<4.10>, ),
  new-with-entry => %( :type(Constructor), :is-symbol<gtk_combo_box_new_with_entry>, :returns(N-Object), :deprecated, :deprecated-version<4.10>, ),
  new-with-model => %( :type(Constructor), :is-symbol<gtk_combo_box_new_with_model>, :returns(N-Object), :deprecated, :deprecated-version<4.10>, :parameters([ N-Object])),
  new-with-model-and-entry => %( :type(Constructor), :is-symbol<gtk_combo_box_new_with_model_and_entry>, :returns(N-Object), :deprecated, :deprecated-version<4.10>, :parameters([ N-Object])),

  #--[Methods]------------------------------------------------------------------
  get-active => %(:is-symbol<gtk_combo_box_get_active>,  :returns(gint),:deprecated, :deprecated-version<4.10>, ),
  get-active-id => %(:is-symbol<gtk_combo_box_get_active_id>,  :returns(Str),:deprecated, :deprecated-version<4.10>, ),
  get-active-iter => %(:is-symbol<gtk_combo_box_get_active_iter>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object]),:deprecated, :deprecated-version<4.10>, ),
  get-button-sensitivity => %(:is-symbol<gtk_combo_box_get_button_sensitivity>,  :returns(GEnum), :cnv-return(GtkSensitivityType),:deprecated, :deprecated-version<4.10>, ),
  get-child => %(:is-symbol<gtk_combo_box_get_child>,  :returns(N-Object),:deprecated, :deprecated-version<4.10>, ),
  get-entry-text-column => %(:is-symbol<gtk_combo_box_get_entry_text_column>,  :returns(gint),:deprecated, :deprecated-version<4.10>, ),
  get-has-entry => %(:is-symbol<gtk_combo_box_get_has_entry>,  :returns(gboolean), :cnv-return(Bool),:deprecated, :deprecated-version<4.10>, ),
  get-id-column => %(:is-symbol<gtk_combo_box_get_id_column>,  :returns(gint),:deprecated, :deprecated-version<4.10>, ),
  get-model => %(:is-symbol<gtk_combo_box_get_model>,  :returns(N-Object),:deprecated, :deprecated-version<4.10>, ),
  get-popup-fixed-width => %(:is-symbol<gtk_combo_box_get_popup_fixed_width>,  :returns(gboolean), :cnv-return(Bool),:deprecated, :deprecated-version<4.10>, ),
#  get-row-separator-func => %(:is-symbol<gtk_combo_box_get_row_separator_func>,  :returns(), :cnv-return(( N-Object $model, N-Object $iter, gpointer $data --> gboolean )),:deprecated, :deprecated-version<4.10>, ),
  popdown => %(:is-symbol<gtk_combo_box_popdown>, :deprecated, :deprecated-version<4.10>, ),
  popup => %(:is-symbol<gtk_combo_box_popup>, :deprecated, :deprecated-version<4.10>, ),
  popup-for-device => %(:is-symbol<gtk_combo_box_popup_for_device>,  :parameters([N-Object]),:deprecated, :deprecated-version<4.10>, ),
  set-active => %(:is-symbol<gtk_combo_box_set_active>,  :parameters([gint]),:deprecated, :deprecated-version<4.10>, ),
  set-active-id => %(:is-symbol<gtk_combo_box_set_active_id>,  :returns(gboolean), :cnv-return(Bool), :parameters([Str]),:deprecated, :deprecated-version<4.10>, ),
  set-active-iter => %(:is-symbol<gtk_combo_box_set_active_iter>,  :parameters([N-Object]),:deprecated, :deprecated-version<4.10>, ),
  set-button-sensitivity => %(:is-symbol<gtk_combo_box_set_button_sensitivity>,  :parameters([GEnum]),:deprecated, :deprecated-version<4.10>, ),
  set-child => %(:is-symbol<gtk_combo_box_set_child>,  :parameters([N-Object]),:deprecated, :deprecated-version<4.10>, ),
  set-entry-text-column => %(:is-symbol<gtk_combo_box_set_entry_text_column>,  :parameters([gint]),:deprecated, :deprecated-version<4.10>, ),
  set-id-column => %(:is-symbol<gtk_combo_box_set_id_column>,  :parameters([gint]),:deprecated, :deprecated-version<4.10>, ),
  set-model => %(:is-symbol<gtk_combo_box_set_model>,  :parameters([N-Object]),:deprecated, :deprecated-version<4.10>, ),
  set-popup-fixed-width => %(:is-symbol<gtk_combo_box_set_popup_fixed_width>,  :parameters([gboolean]),:deprecated, :deprecated-version<4.10>, ),
  #set-row-separator-func => %(:is-symbol<gtk_combo_box_set_row_separator_func>,  :parameters([:( N-Object $model, N-Object $iter, gpointer $data --> gboolean ), gpointer, ]),:deprecated, :deprecated-version<4.10>, ),
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
