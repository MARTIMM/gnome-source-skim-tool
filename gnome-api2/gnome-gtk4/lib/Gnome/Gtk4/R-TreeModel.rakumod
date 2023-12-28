=comment Package: Gtk4, C-Source: treemodel
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::GObject::N-Value:api<2>;
use Gnome::Gtk4::N-TreeIter:api<2>;
use Gnome::Gtk4::N-TreePath:api<2>;
use Gnome::Gtk4::T-TreeIter:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;


#-------------------------------------------------------------------------------
#--[Role Declaration]-----------------------------------------------------------
#-------------------------------------------------------------------------------

unit role Gnome::Gtk4::R-TreeModel:auth<github:MARTIMM>:api<2>;

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  filter-new => %(:is-symbol<gtk_tree_model_filter_new>,  :returns(N-Object), :parameters([N-TreePath])),
  foreach => %(:is-symbol<gtk_tree_model_foreach>,  :parameters([:( N-Object $model, N-TreePath $path, N-TreeIter $iter, gpointer $data --> gboolean ), gpointer])),
  get => %(:is-symbol<gtk_tree_model_get>, :variable-list,  :parameters([N-TreeIter])),
  get-column-type => %(:is-symbol<gtk_tree_model_get_column_type>,  :returns(GType), :parameters([gint])),
  get-flags => %(:is-symbol<gtk_tree_model_get_flags>,  :returns(GFlag), :cnv-return(GtkTreeModelFlags)),
  get-iter => %(:is-symbol<gtk_tree_model_get_iter>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-TreeIter, N-TreePath])),
  get-iter-first => %(:is-symbol<gtk_tree_model_get_iter_first>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-TreeIter])),
  get-iter-from-string => %(:is-symbol<gtk_tree_model_get_iter_from_string>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-TreeIter, Str])),
  get-n-columns => %(:is-symbol<gtk_tree_model_get_n_columns>,  :returns(gint)),
  get-path => %(:is-symbol<gtk_tree_model_get_path>,  :returns(N-TreePath), :parameters([N-TreeIter])),
  get-string-from-iter => %(:is-symbol<gtk_tree_model_get_string_from_iter>,  :returns(Str), :parameters([N-TreeIter])),
  #get-valist => %(:is-symbol<gtk_tree_model_get_valist>,  :parameters([N-TreeIter, ])),
  get-value => %(:is-symbol<gtk_tree_model_get_value>,  :parameters([N-TreeIter, gint, N-Value])),
  iter-children => %(:is-symbol<gtk_tree_model_iter_children>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-TreeIter, N-TreeIter])),
  iter-has-child => %(:is-symbol<gtk_tree_model_iter_has_child>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-TreeIter])),
  iter-n-children => %(:is-symbol<gtk_tree_model_iter_n_children>,  :returns(gint), :parameters([N-TreeIter])),
  iter-next => %(:is-symbol<gtk_tree_model_iter_next>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-TreeIter])),
  iter-nth-child => %(:is-symbol<gtk_tree_model_iter_nth_child>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-TreeIter, N-TreeIter, gint])),
  iter-parent => %(:is-symbol<gtk_tree_model_iter_parent>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-TreeIter, N-TreeIter])),
  iter-previous => %(:is-symbol<gtk_tree_model_iter_previous>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-TreeIter])),
  ref-node => %(:is-symbol<gtk_tree_model_ref_node>,  :parameters([N-TreeIter])),
  row-changed => %(:is-symbol<gtk_tree_model_row_changed>,  :parameters([N-TreePath, N-TreeIter])),
  row-deleted => %(:is-symbol<gtk_tree_model_row_deleted>,  :parameters([N-TreePath])),
  row-has-child-toggled => %(:is-symbol<gtk_tree_model_row_has_child_toggled>,  :parameters([N-TreePath, N-TreeIter])),
  row-inserted => %(:is-symbol<gtk_tree_model_row_inserted>,  :parameters([N-TreePath, N-TreeIter])),
  rows-reordered => %(:is-symbol<gtk_tree_model_rows_reordered>,  :parameters([N-TreePath, N-TreeIter, gint-ptr])),
  rows-reordered-with-length => %(:is-symbol<gtk_tree_model_rows_reordered_with_length>,  :parameters([N-TreePath, N-TreeIter, gint-ptr, gint])),
  unref-node => %(:is-symbol<gtk_tree_model_unref_node>,  :parameters([N-TreeIter])),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _do_gtk_tree_model_fallback-v2 (
  Str $name, Bool $_fallback-v2-ok is rw,
  Gnome::N::GnomeRoutineCaller $routine-caller, @arguments, $native-object
) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    return $routine-caller.call-native-sub(
      $name, @arguments, $methods, $native-object
    );
  }
}
