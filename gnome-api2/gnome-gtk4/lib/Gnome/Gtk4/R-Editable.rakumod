=comment Package: Gtk4, C-Source: editable
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Cairo;


use Gnome::GObject::N-Value:api<2>;
use Gnome::GObject::T-value:api<2>;
use Gnome::Gtk4::T-accessible:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;


#-------------------------------------------------------------------------------
#--[Role Declaration]-----------------------------------------------------------
#-------------------------------------------------------------------------------

unit role Gnome::Gtk4::R-Editable:auth<github:MARTIMM>:api<2>;


#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  delegate-get-accessible-platform-state => %(:is-symbol<gtk_editable_delegate_get_accessible_platform_state>, :returns(gboolean), :parameters([GEnum]), ),
  delete-selection => %(:is-symbol<gtk_editable_delete_selection>, ),
  delete-text => %(:is-symbol<gtk_editable_delete_text>, :parameters([gint, gint]), ),
  finish-delegate => %(:is-symbol<gtk_editable_finish_delegate>, ),
  get-alignment => %(:is-symbol<gtk_editable_get_alignment>, :returns(gfloat), ),
  get-chars => %(:is-symbol<gtk_editable_get_chars>, :returns(Str), :parameters([gint, gint]), ),
  get-delegate => %(:is-symbol<gtk_editable_get_delegate>, :returns(N-Object), ),
  get-editable => %(:is-symbol<gtk_editable_get_editable>, :returns(gboolean), ),
  get-enable-undo => %(:is-symbol<gtk_editable_get_enable_undo>, :returns(gboolean), ),
  get-max-width-chars => %(:is-symbol<gtk_editable_get_max_width_chars>, :returns(gint), ),
  get-position => %(:is-symbol<gtk_editable_get_position>, :returns(gint), ),
  get-selection-bounds => %(:is-symbol<gtk_editable_get_selection_bounds>, :returns(gboolean), :parameters([gint-ptr, gint-ptr]), ),
  get-text => %(:is-symbol<gtk_editable_get_text>, :returns(Str), ),
  get-width-chars => %(:is-symbol<gtk_editable_get_width_chars>, :returns(gint), ),
  init-delegate => %(:is-symbol<gtk_editable_init_delegate>, ),
  insert-text => %(:is-symbol<gtk_editable_insert_text>, :parameters([Str, gint, gint-ptr]), ),
  select-region => %(:is-symbol<gtk_editable_select_region>, :parameters([gint, gint]), ),
  set-alignment => %(:is-symbol<gtk_editable_set_alignment>, :parameters([gfloat]), ),
  set-editable => %(:is-symbol<gtk_editable_set_editable>, :parameters([gboolean]), ),
  set-enable-undo => %(:is-symbol<gtk_editable_set_enable_undo>, :parameters([gboolean]), ),
  set-max-width-chars => %(:is-symbol<gtk_editable_set_max_width_chars>, :parameters([gint]), ),
  set-position => %(:is-symbol<gtk_editable_set_position>, :parameters([gint]), ),
  set-text => %(:is-symbol<gtk_editable_set_text>, :parameters([Str]), ),
  set-width-chars => %(:is-symbol<gtk_editable_set_width_chars>, :parameters([gint]), ),

  #--[Functions]----------------------------------------------------------------
  delegate-get-property => %( :type(Function), :is-symbol<gtk_editable_delegate_get_property>, :returns(gboolean), :parameters([ N-Object, guint, N-Object, N-Object]), ),
  delegate-set-property => %( :type(Function), :is-symbol<gtk_editable_delegate_set_property>, :returns(gboolean), :parameters([ N-Object, guint, N-Object, N-Object]), ),
  #install-properties => %( :type(Function), :is-symbol<gtk_editable_install_properties>, :returns(guint), :parameters([ , guint]), ),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _do_gtk_editable_fallback-v2 (
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
