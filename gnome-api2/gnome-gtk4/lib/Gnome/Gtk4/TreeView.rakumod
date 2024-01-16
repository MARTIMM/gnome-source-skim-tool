=comment Package: Gtk4, C-Source: treeview
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


#use Gnome::Gdk4::N-ContentFormats:api<2>;
use Gnome::Gdk4::N-Rectangle:api<2>;
use Gnome::Gdk4::T-Enums:api<2>;
use Gnome::Glib::N-List:api<2>;
use Gnome::Gtk4::N-TreeIter:api<2>;
use Gnome::Gtk4::N-TreePath:api<2>;
use Gnome::Gtk4::R-Scrollable:api<2>;
use Gnome::Gtk4::T-Enums:api<2>;
use Gnome::Gtk4::T-TreeView:api<2>;
use Gnome::Gtk4::Widget:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::TreeView:auth<github:MARTIMM>:api<2>;
also is Gnome::Gtk4::Widget;
also does Gnome::Gtk4::R-Scrollable;

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
      :w0<select-all unselect-all start-interactive-search cursor-changed select-cursor-parent toggle-cursor-row columns-changed>,
      :w1<select-cursor-row>,
      :w2<row-expanded row-activated row-collapsed test-expand-row test-collapse-row>,
      :w3<expand-collapse-cursor-row>,
      :w4<move-cursor>,
    );

    # Signals from interfaces
    self._add_gtk_scrollable_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_scrollable_signal_types');
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::TreeView' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkTreeView');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-treeview => %( :type(Constructor), :is-symbol<gtk_tree_view_new>, :returns(N-Object), ),
  new-with-model => %( :type(Constructor), :is-symbol<gtk_tree_view_new_with_model>, :returns(N-Object), :parameters([ N-Object])),

  #--[Methods]------------------------------------------------------------------
  append-column => %(:is-symbol<gtk_tree_view_append_column>,  :returns(gint), :parameters([N-Object])),
  collapse-all => %(:is-symbol<gtk_tree_view_collapse_all>, ),
  collapse-row => %(:is-symbol<gtk_tree_view_collapse_row>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-TreePath])),
  columns-autosize => %(:is-symbol<gtk_tree_view_columns_autosize>, ),
  convert-bin-window-to-tree-coords => %(:is-symbol<gtk_tree_view_convert_bin_window_to_tree_coords>,  :parameters([gint, gint, gint-ptr, gint-ptr])),
  convert-bin-window-to-widget-coords => %(:is-symbol<gtk_tree_view_convert_bin_window_to_widget_coords>,  :parameters([gint, gint, gint-ptr, gint-ptr])),
  convert-tree-to-bin-window-coords => %(:is-symbol<gtk_tree_view_convert_tree_to_bin_window_coords>,  :parameters([gint, gint, gint-ptr, gint-ptr])),
  convert-tree-to-widget-coords => %(:is-symbol<gtk_tree_view_convert_tree_to_widget_coords>,  :parameters([gint, gint, gint-ptr, gint-ptr])),
  convert-widget-to-bin-window-coords => %(:is-symbol<gtk_tree_view_convert_widget_to_bin_window_coords>,  :parameters([gint, gint, gint-ptr, gint-ptr])),
  convert-widget-to-tree-coords => %(:is-symbol<gtk_tree_view_convert_widget_to_tree_coords>,  :parameters([gint, gint, gint-ptr, gint-ptr])),
  create-row-drag-icon => %(:is-symbol<gtk_tree_view_create_row_drag_icon>,  :returns(N-Object), :parameters([N-TreePath])),
  #enable-model-drag-dest => %(:is-symbol<gtk_tree_view_enable_model_drag_dest>,  :parameters([N-ContentFormats , GFlag])),
  #enable-model-drag-source => %(:is-symbol<gtk_tree_view_enable_model_drag_source>,  :parameters([GFlag, N-ContentFormats , GFlag])),
  expand-all => %(:is-symbol<gtk_tree_view_expand_all>, ),
  expand-row => %(:is-symbol<gtk_tree_view_expand_row>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-TreePath, gboolean])),
  expand-to-path => %(:is-symbol<gtk_tree_view_expand_to_path>,  :parameters([N-TreePath])),
  get-activate-on-single-click => %(:is-symbol<gtk_tree_view_get_activate_on_single_click>,  :returns(gboolean), :cnv-return(Bool)),
  get-background-area => %(:is-symbol<gtk_tree_view_get_background_area>,  :parameters([N-TreePath, N-Object, N-Rectangle])),
  get-cell-area => %(:is-symbol<gtk_tree_view_get_cell_area>,  :parameters([N-TreePath, N-Object, N-Rectangle])),
  get-column => %(:is-symbol<gtk_tree_view_get_column>,  :returns(N-Object), :parameters([gint])),
  get-columns => %(:is-symbol<gtk_tree_view_get_columns>,  :returns(N-List)),
  get-cursor => %(:is-symbol<gtk_tree_view_get_cursor>,  :parameters([CArray[N-TreePath], CArray[N-Object]])),
  get-dest-row-at-pos => %(:is-symbol<gtk_tree_view_get_dest_row_at_pos>,  :returns(gboolean), :cnv-return(Bool), :parameters([gint, gint, CArray[N-TreePath], GEnum])),
  get-drag-dest-row => %(:is-symbol<gtk_tree_view_get_drag_dest_row>,  :parameters([CArray[N-TreePath], GEnum])),
  get-enable-search => %(:is-symbol<gtk_tree_view_get_enable_search>,  :returns(gboolean), :cnv-return(Bool)),
  get-enable-tree-lines => %(:is-symbol<gtk_tree_view_get_enable_tree_lines>,  :returns(gboolean), :cnv-return(Bool)),
  get-expander-column => %(:is-symbol<gtk_tree_view_get_expander_column>,  :returns(N-Object)),
  get-fixed-height-mode => %(:is-symbol<gtk_tree_view_get_fixed_height_mode>,  :returns(gboolean), :cnv-return(Bool)),
  get-grid-lines => %(:is-symbol<gtk_tree_view_get_grid_lines>,  :returns(GEnum), :cnv-return(GtkTreeViewGridLines)),
  get-headers-clickable => %(:is-symbol<gtk_tree_view_get_headers_clickable>,  :returns(gboolean), :cnv-return(Bool)),
  get-headers-visible => %(:is-symbol<gtk_tree_view_get_headers_visible>,  :returns(gboolean), :cnv-return(Bool)),
  get-hover-expand => %(:is-symbol<gtk_tree_view_get_hover_expand>,  :returns(gboolean), :cnv-return(Bool)),
  get-hover-selection => %(:is-symbol<gtk_tree_view_get_hover_selection>,  :returns(gboolean), :cnv-return(Bool)),
  get-level-indentation => %(:is-symbol<gtk_tree_view_get_level_indentation>,  :returns(gint)),
  get-model => %(:is-symbol<gtk_tree_view_get_model>,  :returns(N-Object)),
  get-n-columns => %(:is-symbol<gtk_tree_view_get_n_columns>,  :returns(guint)),
  get-path-at-pos => %(:is-symbol<gtk_tree_view_get_path_at_pos>,  :returns(gboolean), :cnv-return(Bool), :parameters([gint, gint, CArray[N-TreePath], CArray[N-Object], gint-ptr, gint-ptr])),
  get-reorderable => %(:is-symbol<gtk_tree_view_get_reorderable>,  :returns(gboolean), :cnv-return(Bool)),
#  get-row-separator-func => %(:is-symbol<gtk_tree_view_get_row_separator_func>,  :returns(), :cnv-return(( N-Object $model, N-TreeIter $iter, gpointer $data --> gboolean ))),
  get-rubber-banding => %(:is-symbol<gtk_tree_view_get_rubber_banding>,  :returns(gboolean), :cnv-return(Bool)),
  get-search-column => %(:is-symbol<gtk_tree_view_get_search_column>,  :returns(gint)),
  get-search-entry => %(:is-symbol<gtk_tree_view_get_search_entry>,  :returns(N-Object)),
#  get-search-equal-func => %(:is-symbol<gtk_tree_view_get_search_equal_func>,  :returns(), :cnv-return(( N-Object $model, gint $column, Str $key, N-TreeIter $iter, gpointer $search-data --> gboolean ))),
  get-selection => %(:is-symbol<gtk_tree_view_get_selection>,  :returns(N-Object)),
  get-show-expanders => %(:is-symbol<gtk_tree_view_get_show_expanders>,  :returns(gboolean), :cnv-return(Bool)),
  get-tooltip-column => %(:is-symbol<gtk_tree_view_get_tooltip_column>,  :returns(gint)),
  get-tooltip-context => %(:is-symbol<gtk_tree_view_get_tooltip_context>,  :returns(gboolean), :cnv-return(Bool), :parameters([gint, gint, gboolean, CArray[N-Object], CArray[N-TreePath], N-TreeIter])),
  get-visible-range => %(:is-symbol<gtk_tree_view_get_visible_range>,  :returns(gboolean), :cnv-return(Bool), :parameters([CArray[N-TreePath], CArray[N-TreePath]])),
  get-visible-rect => %(:is-symbol<gtk_tree_view_get_visible_rect>,  :parameters([N-Rectangle])),
  insert-column => %(:is-symbol<gtk_tree_view_insert_column>,  :returns(gint), :parameters([N-Object, gint])),
  insert-column-with-attributes => %(:is-symbol<gtk_tree_view_insert_column_with_attributes>, :variable-list,  :returns(gint), :parameters([gint, Str, N-Object])),
  #insert-column-with-data-func => %(:is-symbol<gtk_tree_view_insert_column_with_data_func>,  :returns(gint), :parameters([gint, Str, N-Object, :( N-Object $tree-column, N-Object $cell, N-Object $tree-model, N-TreeIter $iter, gpointer $data ), gpointer, ])),
  is-blank-at-pos => %(:is-symbol<gtk_tree_view_is_blank_at_pos>,  :returns(gboolean), :cnv-return(Bool), :parameters([gint, gint, CArray[N-TreePath], CArray[N-Object], gint-ptr, gint-ptr])),
  is-rubber-banding-active => %(:is-symbol<gtk_tree_view_is_rubber_banding_active>,  :returns(gboolean), :cnv-return(Bool)),
  map-expanded-rows => %(:is-symbol<gtk_tree_view_map_expanded_rows>,  :parameters([:( N-Object $tree-view, N-TreePath $path, gpointer $user-data ), gpointer])),
  move-column-after => %(:is-symbol<gtk_tree_view_move_column_after>,  :parameters([N-Object, N-Object])),
  remove-column => %(:is-symbol<gtk_tree_view_remove_column>,  :returns(gint), :parameters([N-Object])),
  row-activated => %(:is-symbol<gtk_tree_view_row_activated>,  :parameters([N-TreePath, N-Object])),
  row-expanded => %(:is-symbol<gtk_tree_view_row_expanded>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-TreePath])),
  scroll-to-cell => %(:is-symbol<gtk_tree_view_scroll_to_cell>,  :parameters([N-TreePath, N-Object, gboolean, gfloat, gfloat])),
  scroll-to-point => %(:is-symbol<gtk_tree_view_scroll_to_point>,  :parameters([gint, gint])),
  set-activate-on-single-click => %(:is-symbol<gtk_tree_view_set_activate_on_single_click>,  :parameters([gboolean])),
  #set-column-drag-function => %(:is-symbol<gtk_tree_view_set_column_drag_function>,  :parameters([:( N-Object $tree-view, N-Object $column, N-Object $prev-column, N-Object $next-column, gpointer $data --> gboolean ), gpointer, ])),
  set-cursor => %(:is-symbol<gtk_tree_view_set_cursor>,  :parameters([N-TreePath, N-Object, gboolean])),
  set-cursor-on-cell => %(:is-symbol<gtk_tree_view_set_cursor_on_cell>,  :parameters([N-TreePath, N-Object, N-Object, gboolean])),
  set-drag-dest-row => %(:is-symbol<gtk_tree_view_set_drag_dest_row>,  :parameters([N-TreePath, GEnum])),
  set-enable-search => %(:is-symbol<gtk_tree_view_set_enable_search>,  :parameters([gboolean])),
  set-enable-tree-lines => %(:is-symbol<gtk_tree_view_set_enable_tree_lines>,  :parameters([gboolean])),
  set-expander-column => %(:is-symbol<gtk_tree_view_set_expander_column>,  :parameters([N-Object])),
  set-fixed-height-mode => %(:is-symbol<gtk_tree_view_set_fixed_height_mode>,  :parameters([gboolean])),
  set-grid-lines => %(:is-symbol<gtk_tree_view_set_grid_lines>,  :parameters([GEnum])),
  set-headers-clickable => %(:is-symbol<gtk_tree_view_set_headers_clickable>,  :parameters([gboolean])),
  set-headers-visible => %(:is-symbol<gtk_tree_view_set_headers_visible>,  :parameters([gboolean])),
  set-hover-expand => %(:is-symbol<gtk_tree_view_set_hover_expand>,  :parameters([gboolean])),
  set-hover-selection => %(:is-symbol<gtk_tree_view_set_hover_selection>,  :parameters([gboolean])),
  set-level-indentation => %(:is-symbol<gtk_tree_view_set_level_indentation>,  :parameters([gint])),
  set-model => %(:is-symbol<gtk_tree_view_set_model>,  :parameters([N-Object])),
  set-reorderable => %(:is-symbol<gtk_tree_view_set_reorderable>,  :parameters([gboolean])),
  #set-row-separator-func => %(:is-symbol<gtk_tree_view_set_row_separator_func>,  :parameters([:( N-Object $model, N-TreeIter $iter, gpointer $data --> gboolean ), gpointer, ])),
  set-rubber-banding => %(:is-symbol<gtk_tree_view_set_rubber_banding>,  :parameters([gboolean])),
  set-search-column => %(:is-symbol<gtk_tree_view_set_search_column>,  :parameters([gint])),
  set-search-entry => %(:is-symbol<gtk_tree_view_set_search_entry>,  :parameters([N-Object])),
  #set-search-equal-func => %(:is-symbol<gtk_tree_view_set_search_equal_func>,  :parameters([:( N-Object $model, gint $column, Str $key, N-TreeIter $iter, gpointer $search-data --> gboolean ), gpointer, ])),
  set-show-expanders => %(:is-symbol<gtk_tree_view_set_show_expanders>,  :parameters([gboolean])),
  set-tooltip-cell => %(:is-symbol<gtk_tree_view_set_tooltip_cell>,  :parameters([N-Object, N-TreePath, N-Object, N-Object])),
  set-tooltip-column => %(:is-symbol<gtk_tree_view_set_tooltip_column>,  :parameters([gint])),
  set-tooltip-row => %(:is-symbol<gtk_tree_view_set_tooltip_row>,  :parameters([N-Object, N-TreePath])),
  unset-rows-drag-dest => %(:is-symbol<gtk_tree_view_unset_rows_drag_dest>, ),
  unset-rows-drag-source => %(:is-symbol<gtk_tree_view_unset_rows_drag_source>, ),
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
    $r = self._do_gtk_scrollable_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    ) if self.^can('_do_gtk_scrollable_fallback-v2');
    return $r if $_fallback-v2-ok;

    callsame;
  }
}
