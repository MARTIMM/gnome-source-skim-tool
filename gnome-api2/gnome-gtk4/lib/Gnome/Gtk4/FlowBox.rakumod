=comment Package: Gtk4, C-Source: flowbox
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;




use Gnome::Glib::N-List:api<2>;
use Gnome::Glib::T-list:api<2>;
use Gnome::Gtk4::R-Orientable:api<2>;
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

unit class Gnome::Gtk4::FlowBox:auth<github:MARTIMM>:api<2>;
also is Gnome::Gtk4::Widget;
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
      :w0<unselect-all selected-children-changed select-all activate-cursor-child toggle-cursor-child>,
      :w1<child-activated>,
      :w4<move-cursor>,
    );

    # Signals from interfaces
    self._add_gtk_orientable_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_orientable_signal_types');
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::FlowBox' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkFlowBox');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-flowbox => %( :type(Constructor), :is-symbol<gtk_flow_box_new>, :returns(N-Object), ),

  #--[Methods]------------------------------------------------------------------
  append => %(:is-symbol<gtk_flow_box_append>, :parameters([N-Object]), ),
  bind-model => %(:is-symbol<gtk_flow_box_bind_model>, :parameters([N-Object, :( gpointer $item, gpointer $user-data ), gpointer, :( gpointer $data )]), ),
  get-activate-on-single-click => %(:is-symbol<gtk_flow_box_get_activate_on_single_click>, :returns(gboolean), :cnv-return(Bool), ),
  get-child-at-index => %(:is-symbol<gtk_flow_box_get_child_at_index>, :returns(N-Object), :parameters([gint]), ),
  get-child-at-pos => %(:is-symbol<gtk_flow_box_get_child_at_pos>, :returns(N-Object), :parameters([gint, gint]), ),
  get-column-spacing => %(:is-symbol<gtk_flow_box_get_column_spacing>, :returns(guint), ),
  get-homogeneous => %(:is-symbol<gtk_flow_box_get_homogeneous>, :returns(gboolean), :cnv-return(Bool), ),
  get-max-children-per-line => %(:is-symbol<gtk_flow_box_get_max_children_per_line>, :returns(guint), ),
  get-min-children-per-line => %(:is-symbol<gtk_flow_box_get_min_children_per_line>, :returns(guint), ),
  get-row-spacing => %(:is-symbol<gtk_flow_box_get_row_spacing>, :returns(guint), ),
  get-selected-children => %(:is-symbol<gtk_flow_box_get_selected_children>, :returns(N-Object), ),
  get-selection-mode => %(:is-symbol<gtk_flow_box_get_selection_mode>,  :returns(GEnum), :cnv-return(GtkSelectionMode)),
  insert => %(:is-symbol<gtk_flow_box_insert>, :parameters([N-Object, gint]), ),
  invalidate-filter => %(:is-symbol<gtk_flow_box_invalidate_filter>, ),
  invalidate-sort => %(:is-symbol<gtk_flow_box_invalidate_sort>, ),
  prepend => %(:is-symbol<gtk_flow_box_prepend>, :parameters([N-Object]), ),
  remove => %(:is-symbol<gtk_flow_box_remove>, :parameters([N-Object]), ),
  remove-all => %(:is-symbol<gtk_flow_box_remove_all>, ),
  select-all => %(:is-symbol<gtk_flow_box_select_all>, ),
  select-child => %(:is-symbol<gtk_flow_box_select_child>, :parameters([N-Object]), ),
  selected-foreach => %(:is-symbol<gtk_flow_box_selected_foreach>, :parameters([:( N-Object $box, N-Object $child, gpointer $user-data ), gpointer]), ),
  set-activate-on-single-click => %(:is-symbol<gtk_flow_box_set_activate_on_single_click>, :parameters([gboolean]), ),
  set-column-spacing => %(:is-symbol<gtk_flow_box_set_column_spacing>, :parameters([guint]), ),
  set-filter-func => %(:is-symbol<gtk_flow_box_set_filter_func>, :parameters([:( N-Object $child, gpointer $user-data ), gpointer, :( gpointer $data )]), ),
  set-hadjustment => %(:is-symbol<gtk_flow_box_set_hadjustment>, :parameters([N-Object]), ),
  set-homogeneous => %(:is-symbol<gtk_flow_box_set_homogeneous>, :parameters([gboolean]), ),
  set-max-children-per-line => %(:is-symbol<gtk_flow_box_set_max_children_per_line>, :parameters([guint]), ),
  set-min-children-per-line => %(:is-symbol<gtk_flow_box_set_min_children_per_line>, :parameters([guint]), ),
  set-row-spacing => %(:is-symbol<gtk_flow_box_set_row_spacing>, :parameters([guint]), ),
  set-selection-mode => %(:is-symbol<gtk_flow_box_set_selection_mode>, :parameters([GEnum]), ),
  set-sort-func => %(:is-symbol<gtk_flow_box_set_sort_func>, :parameters([:( N-Object $child1, N-Object $child2, gpointer $user-data ), gpointer, :( gpointer $data )]), ),
  set-vadjustment => %(:is-symbol<gtk_flow_box_set_vadjustment>, :parameters([N-Object]), ),
  unselect-all => %(:is-symbol<gtk_flow_box_unselect_all>, ),
  unselect-child => %(:is-symbol<gtk_flow_box_unselect_child>, :parameters([N-Object]), ),
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
    $r = self._do_gtk_orientable_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    ) if self.^can('_do_gtk_orientable_fallback-v2');
    return $r if $_fallback-v2-ok;

    callsame;
  }
}
