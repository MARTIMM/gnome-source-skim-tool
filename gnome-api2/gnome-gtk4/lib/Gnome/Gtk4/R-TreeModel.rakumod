=comment Package: Gtk4, C-Source: treemodel
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;



use Gnome::GObject::N-Value:api<2>;
use Gnome::GObject::T-value:api<2>;
use Gnome::Gtk4::N-TreeIter:api<2>;
use Gnome::Gtk4::N-TreePath:api<2>;
use Gnome::Gtk4::T-treemodel:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;


#-------------------------------------------------------------------------------
#--[Role Declaration]-----------------------------------------------------------
#-------------------------------------------------------------------------------

unit role Gnome::Gtk4::R-TreeModel:auth<github:MARTIMM>:api<2>;


#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  filter-new => %(:is-symbol<gtk_tree_model_filter_new>, :returns(N-Object), :parameters([N-Object]), :deprecated, :deprecated-version<4.10>, ),
  foreach => %(:is-symbol<gtk_tree_model_foreach>, :parameters([:( N-Object $model, N-Object $path, N-Object $iter, gpointer $data ), gpointer]), :deprecated, :deprecated-version<4.10>, ),
  get => %(:is-symbol<gtk_tree_model_get>, :variable-list, :parameters([N-Object]), :deprecated, :deprecated-version<4.10>, ),
  get-column-type => %(:is-symbol<gtk_tree_model_get_column_type>, :returns(GType), :parameters([gint]), :deprecated, :deprecated-version<4.10>, ),
  get-flags => %(:is-symbol<gtk_tree_model_get_flags>,  :returns(GFlag), :cnv-return(GtkTreeModelFlags),:deprecated, :deprecated-version<4.10>, ),
  get-iter => %(:is-symbol<gtk_tree_model_get_iter>, :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, N-Object]), :deprecated, :deprecated-version<4.10>, ),
  get-iter-first => %(:is-symbol<gtk_tree_model_get_iter_first>, :returns(gboolean), :cnv-return(Bool), :parameters([N-Object]), :deprecated, :deprecated-version<4.10>, ),
  get-iter-from-string => %(:is-symbol<gtk_tree_model_get_iter_from_string>, :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, Str]), :deprecated, :deprecated-version<4.10>, ),
  get-n-columns => %(:is-symbol<gtk_tree_model_get_n_columns>, :returns(gint), :deprecated, :deprecated-version<4.10>, ),
  get-path => %(:is-symbol<gtk_tree_model_get_path>, :returns(N-Object), :parameters([N-Object]), :deprecated, :deprecated-version<4.10>, ),
  get-string-from-iter => %(:is-symbol<gtk_tree_model_get_string_from_iter>, :returns(Str), :parameters([N-Object]), :deprecated, :deprecated-version<4.10>, ),
  #get-valist => %(:is-symbol<gtk_tree_model_get_valist>, :parameters([N-Object, ]), :deprecated, :deprecated-version<4.10>, ),
  get-value => %(:is-symbol<gtk_tree_model_get_value>, :parameters([N-Object, gint, N-Object]), :deprecated, :deprecated-version<4.10>, ),
  iter-children => %(:is-symbol<gtk_tree_model_iter_children>, :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, N-Object]), :deprecated, :deprecated-version<4.10>, ),
  iter-has-child => %(:is-symbol<gtk_tree_model_iter_has_child>, :returns(gboolean), :cnv-return(Bool), :parameters([N-Object]), :deprecated, :deprecated-version<4.10>, ),
  iter-n-children => %(:is-symbol<gtk_tree_model_iter_n_children>, :returns(gint), :parameters([N-Object]), :deprecated, :deprecated-version<4.10>, ),
  iter-next => %(:is-symbol<gtk_tree_model_iter_next>, :returns(gboolean), :cnv-return(Bool), :parameters([N-Object]), :deprecated, :deprecated-version<4.10>, ),
  iter-nth-child => %(:is-symbol<gtk_tree_model_iter_nth_child>, :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, N-Object, gint]), :deprecated, :deprecated-version<4.10>, ),
  iter-parent => %(:is-symbol<gtk_tree_model_iter_parent>, :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, N-Object]), :deprecated, :deprecated-version<4.10>, ),
  iter-previous => %(:is-symbol<gtk_tree_model_iter_previous>, :returns(gboolean), :cnv-return(Bool), :parameters([N-Object]), :deprecated, :deprecated-version<4.10>, ),
  ref-node => %(:is-symbol<gtk_tree_model_ref_node>, :parameters([N-Object]), :deprecated, :deprecated-version<4.10>, ),
  row-changed => %(:is-symbol<gtk_tree_model_row_changed>, :parameters([N-Object, N-Object]), :deprecated, :deprecated-version<4.10>, ),
  row-deleted => %(:is-symbol<gtk_tree_model_row_deleted>, :parameters([N-Object]), :deprecated, :deprecated-version<4.10>, ),
  row-has-child-toggled => %(:is-symbol<gtk_tree_model_row_has_child_toggled>, :parameters([N-Object, N-Object]), :deprecated, :deprecated-version<4.10>, ),
  row-inserted => %(:is-symbol<gtk_tree_model_row_inserted>, :parameters([N-Object, N-Object]), :deprecated, :deprecated-version<4.10>, ),
  rows-reordered => %(:is-symbol<gtk_tree_model_rows_reordered>, :parameters([N-Object, N-Object, gint-ptr]), :deprecated, :deprecated-version<4.10>, ),
  rows-reordered-with-length => %(:is-symbol<gtk_tree_model_rows_reordered_with_length>, :parameters([N-Object, N-Object, gint-ptr, gint]), :deprecated, :deprecated-version<4.10>, ),
  unref-node => %(:is-symbol<gtk_tree_model_unref_node>, :parameters([N-Object]), :deprecated, :deprecated-version<4.10>, ),
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
