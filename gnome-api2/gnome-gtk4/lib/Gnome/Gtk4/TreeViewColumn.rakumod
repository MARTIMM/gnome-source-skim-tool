=comment Package: Gtk4, C-Source: treeviewcolumn
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;




use Gnome::GObject::InitiallyUnowned:api<2>;
use Gnome::Gtk4::R-Buildable:api<2>;
use Gnome::Gtk4::R-CellLayout:api<2>;
use Gnome::Gtk4::T-enums:api<2>;
#use Gnome::Gtk4::T-treemodel:api<2>;
use Gnome::Gtk4::T-treeviewcolumn:api<2>;
#use Gnome::N:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::TreeViewColumn:auth<github:MARTIMM>:api<2>;
also is Gnome::GObject::InitiallyUnowned;
also does Gnome::Gtk4::R-Buildable;
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

  Gnome::N::deprecate(
    'Gnome::Gtk4::TreeViewColumn', ', Str, ',
    '4.10', Str,
    :class, :gnome-lib(gtk4-lib())  
  );

  # Add signal administration info.
  unless $signals-added {
    self.add-signal-types( $?CLASS.^name,
      :w0<clicked>,
    );

    # Signals from interfaces
    self._add_gtk_buildable_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_buildable_signal_types');
    self._add_gtk_cell_layout_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_cell_layout_signal_types');
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::TreeViewColumn' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkTreeViewColumn');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-treeviewcolumn => %( :type(Constructor), :is-symbol<gtk_tree_view_column_new>, :returns(N-Object), :deprecated, :deprecated-version<4.10>, ),
  new-with-area => %( :type(Constructor), :is-symbol<gtk_tree_view_column_new_with_area>, :returns(N-Object), :deprecated, :deprecated-version<4.10>, :parameters([ N-Object]), ),
  new-with-attributes => %( :type(Constructor), :is-symbol<gtk_tree_view_column_new_with_attributes>, :returns(N-Object), :deprecated, :deprecated-version<4.10>, :variable-list, :parameters([ Str, N-Object]), ),

  #--[Methods]------------------------------------------------------------------
  add-attribute => %(:is-symbol<gtk_tree_view_column_add_attribute>, :parameters([N-Object, Str, gint]), :deprecated, :deprecated-version<4.10>, ),
  cell-get-position => %(:is-symbol<gtk_tree_view_column_cell_get_position>, :returns(gboolean), :parameters([N-Object, gint-ptr, gint-ptr]), :deprecated, :deprecated-version<4.10>, ),
  cell-get-size => %(:is-symbol<gtk_tree_view_column_cell_get_size>, :parameters([gint-ptr, gint-ptr, gint-ptr, gint-ptr]), :deprecated, :deprecated-version<4.10>, ),
  cell-is-visible => %(:is-symbol<gtk_tree_view_column_cell_is_visible>, :returns(gboolean), :deprecated, :deprecated-version<4.10>, ),
  cell-set-cell-data => %(:is-symbol<gtk_tree_view_column_cell_set_cell_data>, :parameters([N-Object, N-Object, gboolean, gboolean]), :deprecated, :deprecated-version<4.10>, ),
  clear => %(:is-symbol<gtk_tree_view_column_clear>, :deprecated, :deprecated-version<4.10>, ),
  clear-attributes => %(:is-symbol<gtk_tree_view_column_clear_attributes>, :parameters([N-Object]), :deprecated, :deprecated-version<4.10>, ),
  clicked => %(:is-symbol<gtk_tree_view_column_clicked>, :deprecated, :deprecated-version<4.10>, ),
  focus-cell => %(:is-symbol<gtk_tree_view_column_focus_cell>, :parameters([N-Object]), :deprecated, :deprecated-version<4.10>, ),
  get-alignment => %(:is-symbol<gtk_tree_view_column_get_alignment>, :returns(gfloat), :deprecated, :deprecated-version<4.10>, ),
  get-button => %(:is-symbol<gtk_tree_view_column_get_button>, :returns(N-Object), :deprecated, :deprecated-version<4.10>, ),
  get-clickable => %(:is-symbol<gtk_tree_view_column_get_clickable>, :returns(gboolean), :deprecated, :deprecated-version<4.10>, ),
  get-expand => %(:is-symbol<gtk_tree_view_column_get_expand>, :returns(gboolean), :deprecated, :deprecated-version<4.10>, ),
  get-fixed-width => %(:is-symbol<gtk_tree_view_column_get_fixed_width>, :returns(gint), :deprecated, :deprecated-version<4.10>, ),
  get-max-width => %(:is-symbol<gtk_tree_view_column_get_max_width>, :returns(gint), :deprecated, :deprecated-version<4.10>, ),
  get-min-width => %(:is-symbol<gtk_tree_view_column_get_min_width>, :returns(gint), :deprecated, :deprecated-version<4.10>, ),
  get-reorderable => %(:is-symbol<gtk_tree_view_column_get_reorderable>, :returns(gboolean), :deprecated, :deprecated-version<4.10>, ),
  get-resizable => %(:is-symbol<gtk_tree_view_column_get_resizable>, :returns(gboolean), :deprecated, :deprecated-version<4.10>, ),
  get-sizing => %(:is-symbol<gtk_tree_view_column_get_sizing>,  :returns(GEnum), :cnv-return(GtkTreeViewColumnSizing),:deprecated, :deprecated-version<4.10>, ),
  get-sort-column-id => %(:is-symbol<gtk_tree_view_column_get_sort_column_id>, :returns(gint), :deprecated, :deprecated-version<4.10>, ),
  get-sort-indicator => %(:is-symbol<gtk_tree_view_column_get_sort_indicator>, :returns(gboolean), :deprecated, :deprecated-version<4.10>, ),
  get-sort-order => %(:is-symbol<gtk_tree_view_column_get_sort_order>,  :returns(GEnum), :cnv-return(GtkSortType),:deprecated, :deprecated-version<4.10>, ),
  get-spacing => %(:is-symbol<gtk_tree_view_column_get_spacing>, :returns(gint), :deprecated, :deprecated-version<4.10>, ),
  get-title => %(:is-symbol<gtk_tree_view_column_get_title>, :returns(Str), :deprecated, :deprecated-version<4.10>, ),
  get-tree-view => %(:is-symbol<gtk_tree_view_column_get_tree_view>, :returns(N-Object), :deprecated, :deprecated-version<4.10>, ),
  get-visible => %(:is-symbol<gtk_tree_view_column_get_visible>, :returns(gboolean), :deprecated, :deprecated-version<4.10>, ),
  get-widget => %(:is-symbol<gtk_tree_view_column_get_widget>, :returns(N-Object), :deprecated, :deprecated-version<4.10>, ),
  get-width => %(:is-symbol<gtk_tree_view_column_get_width>, :returns(gint), :deprecated, :deprecated-version<4.10>, ),
  get-x-offset => %(:is-symbol<gtk_tree_view_column_get_x_offset>, :returns(gint), :deprecated, :deprecated-version<4.10>, ),
  pack-end => %(:is-symbol<gtk_tree_view_column_pack_end>, :parameters([N-Object, gboolean]), :deprecated, :deprecated-version<4.10>, ),
  pack-start => %(:is-symbol<gtk_tree_view_column_pack_start>, :parameters([N-Object, gboolean]), :deprecated, :deprecated-version<4.10>, ),
  queue-resize => %(:is-symbol<gtk_tree_view_column_queue_resize>, :deprecated, :deprecated-version<4.10>, ),
  set-alignment => %(:is-symbol<gtk_tree_view_column_set_alignment>, :parameters([gfloat]), :deprecated, :deprecated-version<4.10>, ),
  set-attributes => %(:is-symbol<gtk_tree_view_column_set_attributes>, :variable-list, :parameters([N-Object]), :deprecated, :deprecated-version<4.10>, ),
  set-cell-data-func => %(:is-symbol<gtk_tree_view_column_set_cell_data_func>, :parameters([N-Object, :( N-Object $tree-column, N-Object $cell, N-Object $tree-model, N-Object $iter, gpointer $data ), gpointer, :( gpointer $data )]), :deprecated, :deprecated-version<4.10>, ),
  set-clickable => %(:is-symbol<gtk_tree_view_column_set_clickable>, :parameters([gboolean]), :deprecated, :deprecated-version<4.10>, ),
  set-expand => %(:is-symbol<gtk_tree_view_column_set_expand>, :parameters([gboolean]), :deprecated, :deprecated-version<4.10>, ),
  set-fixed-width => %(:is-symbol<gtk_tree_view_column_set_fixed_width>, :parameters([gint]), :deprecated, :deprecated-version<4.10>, ),
  set-max-width => %(:is-symbol<gtk_tree_view_column_set_max_width>, :parameters([gint]), :deprecated, :deprecated-version<4.10>, ),
  set-min-width => %(:is-symbol<gtk_tree_view_column_set_min_width>, :parameters([gint]), :deprecated, :deprecated-version<4.10>, ),
  set-reorderable => %(:is-symbol<gtk_tree_view_column_set_reorderable>, :parameters([gboolean]), :deprecated, :deprecated-version<4.10>, ),
  set-resizable => %(:is-symbol<gtk_tree_view_column_set_resizable>, :parameters([gboolean]), :deprecated, :deprecated-version<4.10>, ),
  set-sizing => %(:is-symbol<gtk_tree_view_column_set_sizing>, :parameters([GEnum]), :deprecated, :deprecated-version<4.10>, ),
  set-sort-column-id => %(:is-symbol<gtk_tree_view_column_set_sort_column_id>, :parameters([gint]), :deprecated, :deprecated-version<4.10>, ),
  set-sort-indicator => %(:is-symbol<gtk_tree_view_column_set_sort_indicator>, :parameters([gboolean]), :deprecated, :deprecated-version<4.10>, ),
  set-sort-order => %(:is-symbol<gtk_tree_view_column_set_sort_order>, :parameters([GEnum]), :deprecated, :deprecated-version<4.10>, ),
  set-spacing => %(:is-symbol<gtk_tree_view_column_set_spacing>, :parameters([gint]), :deprecated, :deprecated-version<4.10>, ),
  set-title => %(:is-symbol<gtk_tree_view_column_set_title>, :parameters([Str]), :deprecated, :deprecated-version<4.10>, ),
  set-visible => %(:is-symbol<gtk_tree_view_column_set_visible>, :parameters([gboolean]), :deprecated, :deprecated-version<4.10>, ),
  set-widget => %(:is-symbol<gtk_tree_view_column_set_widget>, :parameters([N-Object]), :deprecated, :deprecated-version<4.10>, ),
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
    $r = self._do_gtk_buildable_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    ) if self.^can('_do_gtk_buildable_fallback-v2');
    return $r if $_fallback-v2-ok;

    $r = self._do_gtk_cell_layout_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    ) if self.^can('_do_gtk_cell_layout_fallback-v2');
    return $r if $_fallback-v2-ok;

    callsame;
  }
}
