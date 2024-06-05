=comment Package: Gtk4, C-Source: cellarea
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::GObject::InitiallyUnowned:api<2>;
use Gnome::GObject::N-Value:api<2>;
use Gnome::GObject::T-value:api<2>;
use Gnome::Gdk4::N-Rectangle:api<2>;
use Gnome::Gdk4::T-types:api<2>;
use Gnome::Glib::N-List:api<2>;
use Gnome::Glib::T-list:api<2>;
use Gnome::Gtk4::N-TreeIter:api<2>;
#use Gnome::Gtk4::T-cellrenderer:api<2>;
use Gnome::Gtk4::T-enums:api<2>;
#use Gnome::Gtk4::T-treemodel:api<2>;
#use Gnome::N:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::CellArea:auth<github:MARTIMM>:api<2>;
also is Gnome::GObject::InitiallyUnowned;

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
    'Gnome::Gtk4::CellArea', ', Str, ',
    '4.10', Str,
    :class, :gnome-lib(gtk4-lib())  
  );

  # Add signal administration info.
  unless $signals-added {
    self.add-signal-types( $?CLASS.^name,
      :w2<focus-changed remove-editable>,
      :w4<add-editable apply-attributes>,
    );
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::CellArea' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkCellArea');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  #activate => %(:is-symbol<gtk_cell_area_activate>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, N-Object, N-Object, GFlag, gboolean]),:deprecated, :deprecated-version<4.10>, ),
  #activate-cell => %(:is-symbol<gtk_cell_area_activate_cell>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, N-Object, N-Object, N-Object, GFlag]),:deprecated, :deprecated-version<4.10>, ),
  add => %(:is-symbol<gtk_cell_area_add>,  :parameters([N-Object]),:deprecated, :deprecated-version<4.10>, ),
  add-focus-sibling => %(:is-symbol<gtk_cell_area_add_focus_sibling>,  :parameters([N-Object, N-Object]),:deprecated, :deprecated-version<4.10>, ),
  add-with-properties => %(:is-symbol<gtk_cell_area_add_with_properties>, :variable-list,  :parameters([N-Object, Str]),:deprecated, :deprecated-version<4.10>, ),
  apply-attributes => %(:is-symbol<gtk_cell_area_apply_attributes>,  :parameters([N-Object, N-Object, gboolean, gboolean]),:deprecated, :deprecated-version<4.10>, ),
  attribute-connect => %(:is-symbol<gtk_cell_area_attribute_connect>,  :parameters([N-Object, Str, gint]),:deprecated, :deprecated-version<4.10>, ),
  attribute-disconnect => %(:is-symbol<gtk_cell_area_attribute_disconnect>,  :parameters([N-Object, Str]),:deprecated, :deprecated-version<4.10>, ),
  attribute-get-column => %(:is-symbol<gtk_cell_area_attribute_get_column>,  :returns(gint), :parameters([N-Object, Str]),:deprecated, :deprecated-version<4.10>, ),
  cell-get => %(:is-symbol<gtk_cell_area_cell_get>, :variable-list,  :parameters([N-Object, Str]),:deprecated, :deprecated-version<4.10>, ),
  cell-get-property => %(:is-symbol<gtk_cell_area_cell_get_property>,  :parameters([N-Object, Str, N-Object]),:deprecated, :deprecated-version<4.10>, ),
  #cell-get-valist => %(:is-symbol<gtk_cell_area_cell_get_valist>,  :parameters([N-Object, Str, ]),:deprecated, :deprecated-version<4.10>, ),
  cell-set => %(:is-symbol<gtk_cell_area_cell_set>, :variable-list,  :parameters([N-Object, Str]),:deprecated, :deprecated-version<4.10>, ),
  cell-set-property => %(:is-symbol<gtk_cell_area_cell_set_property>,  :parameters([N-Object, Str, N-Object]),:deprecated, :deprecated-version<4.10>, ),
  #cell-set-valist => %(:is-symbol<gtk_cell_area_cell_set_valist>,  :parameters([N-Object, Str, ]),:deprecated, :deprecated-version<4.10>, ),
  copy-context => %(:is-symbol<gtk_cell_area_copy_context>,  :returns(N-Object), :parameters([N-Object]),:deprecated, :deprecated-version<4.10>, ),
  create-context => %(:is-symbol<gtk_cell_area_create_context>,  :returns(N-Object),:deprecated, :deprecated-version<4.10>, ),
  #event => %(:is-symbol<gtk_cell_area_event>,  :returns(gint), :parameters([N-Object, N-Object, N-Object, N-Object, GFlag]),:deprecated, :deprecated-version<4.10>, ),
  focus => %(:is-symbol<gtk_cell_area_focus>,  :returns(gboolean), :cnv-return(Bool), :parameters([GEnum]),:deprecated, :deprecated-version<4.10>, ),
  foreach => %(:is-symbol<gtk_cell_area_foreach>,  :parameters([:( N-Object $renderer, gpointer $data --> gboolean ), gpointer]),:deprecated, :deprecated-version<4.10>, ),
  foreach-alloc => %(:is-symbol<gtk_cell_area_foreach_alloc>,  :parameters([N-Object, N-Object, N-Object, N-Object, :( N-Object $renderer, N-Object $cell-area, N-Object $cell-background, gpointer $data --> gboolean ), gpointer])),
  get-cell-allocation => %(:is-symbol<gtk_cell_area_get_cell_allocation>,  :parameters([N-Object, N-Object, N-Object, N-Object, N-Object]),:deprecated, :deprecated-version<4.10>, ),
  get-cell-at-position => %(:is-symbol<gtk_cell_area_get_cell_at_position>,  :returns(N-Object), :parameters([N-Object, N-Object, N-Object, gint, gint, N-Object]),:deprecated, :deprecated-version<4.10>, ),
  get-current-path-string => %(:is-symbol<gtk_cell_area_get_current_path_string>,  :returns(Str)),
  get-edit-widget => %(:is-symbol<gtk_cell_area_get_edit_widget>,  :returns(N-Object),:deprecated, :deprecated-version<4.10>, ),
  get-edited-cell => %(:is-symbol<gtk_cell_area_get_edited_cell>,  :returns(N-Object),:deprecated, :deprecated-version<4.10>, ),
  get-focus-cell => %(:is-symbol<gtk_cell_area_get_focus_cell>,  :returns(N-Object),:deprecated, :deprecated-version<4.10>, ),
  get-focus-from-sibling => %(:is-symbol<gtk_cell_area_get_focus_from_sibling>,  :returns(N-Object), :parameters([N-Object]),:deprecated, :deprecated-version<4.10>, ),
  get-focus-siblings => %(:is-symbol<gtk_cell_area_get_focus_siblings>,  :returns(N-Object), :parameters([N-Object]),:deprecated, :deprecated-version<4.10>, ),
  get-preferred-height => %(:is-symbol<gtk_cell_area_get_preferred_height>,  :parameters([N-Object, N-Object, gint-ptr, gint-ptr]),:deprecated, :deprecated-version<4.10>, ),
  get-preferred-height-for-width => %(:is-symbol<gtk_cell_area_get_preferred_height_for_width>,  :parameters([N-Object, N-Object, gint, gint-ptr, gint-ptr]),:deprecated, :deprecated-version<4.10>, ),
  get-preferred-width => %(:is-symbol<gtk_cell_area_get_preferred_width>,  :parameters([N-Object, N-Object, gint-ptr, gint-ptr]),:deprecated, :deprecated-version<4.10>, ),
  get-preferred-width-for-height => %(:is-symbol<gtk_cell_area_get_preferred_width_for_height>,  :parameters([N-Object, N-Object, gint, gint-ptr, gint-ptr]),:deprecated, :deprecated-version<4.10>, ),
  get-request-mode => %(:is-symbol<gtk_cell_area_get_request_mode>,  :returns(GEnum), :cnv-return(GtkSizeRequestMode)),
  has-renderer => %(:is-symbol<gtk_cell_area_has_renderer>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object]),:deprecated, :deprecated-version<4.10>, ),
  inner-cell-area => %(:is-symbol<gtk_cell_area_inner_cell_area>,  :parameters([N-Object, N-Object, N-Object]),:deprecated, :deprecated-version<4.10>, ),
  is-activatable => %(:is-symbol<gtk_cell_area_is_activatable>,  :returns(gboolean), :cnv-return(Bool),:deprecated, :deprecated-version<4.10>, ),
  is-focus-sibling => %(:is-symbol<gtk_cell_area_is_focus_sibling>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, N-Object]),:deprecated, :deprecated-version<4.10>, ),
  remove => %(:is-symbol<gtk_cell_area_remove>,  :parameters([N-Object]),:deprecated, :deprecated-version<4.10>, ),
  remove-focus-sibling => %(:is-symbol<gtk_cell_area_remove_focus_sibling>,  :parameters([N-Object, N-Object]),:deprecated, :deprecated-version<4.10>, ),
  request-renderer => %(:is-symbol<gtk_cell_area_request_renderer>,  :parameters([N-Object, GEnum, N-Object, gint, gint-ptr, gint-ptr]),:deprecated, :deprecated-version<4.10>, ),
  set-focus-cell => %(:is-symbol<gtk_cell_area_set_focus_cell>,  :parameters([N-Object]),:deprecated, :deprecated-version<4.10>, ),
  #snapshot => %(:is-symbol<gtk_cell_area_snapshot>,  :parameters([N-Object, N-Object, N-Object, N-Object, N-Object, GFlag, gboolean]),:deprecated, :deprecated-version<4.10>, ),
  stop-editing => %(:is-symbol<gtk_cell_area_stop_editing>,  :parameters([gboolean]),:deprecated, :deprecated-version<4.10>, ),
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
