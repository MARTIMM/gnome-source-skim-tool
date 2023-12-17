=comment Package: Gtk4, C-Source: filechooser
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Gtk4::T-FileChooser:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;


#-------------------------------------------------------------------------------
#--[Role Declaration]-----------------------------------------------------------
#-------------------------------------------------------------------------------

unit role Gnome::Gtk4::R-FileChooser:auth<github:MARTIMM>:api<2>;

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  add-choice => %(:is-symbol<gtk_file_chooser_add_choice>,  :parameters([Str, Str, gchar-pptr, gchar-pptr])),
  add-filter => %(:is-symbol<gtk_file_chooser_add_filter>,  :parameters([N-Object])),
  add-shortcut-folder => %(:is-symbol<gtk_file_chooser_add_shortcut_folder>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  get-action => %(:is-symbol<gtk_file_chooser_get_action>,  :returns(GEnum), :cnv-return(GtkFileChooserAction)),
  get-choice => %(:is-symbol<gtk_file_chooser_get_choice>,  :returns(Str), :parameters([Str])),
  get-create-folders => %(:is-symbol<gtk_file_chooser_get_create_folders>,  :returns(gboolean), :cnv-return(Bool)),
  get-current-folder => %(:is-symbol<gtk_file_chooser_get_current_folder>,  :returns(N-Object)),
  get-current-name => %(:is-symbol<gtk_file_chooser_get_current_name>,  :returns(Str)),
  get-file => %(:is-symbol<gtk_file_chooser_get_file>,  :returns(N-Object)),
  get-files => %(:is-symbol<gtk_file_chooser_get_files>,  :returns(N-Object)),
  get-filter => %(:is-symbol<gtk_file_chooser_get_filter>,  :returns(N-Object)),
  get-filters => %(:is-symbol<gtk_file_chooser_get_filters>,  :returns(N-Object)),
  get-select-multiple => %(:is-symbol<gtk_file_chooser_get_select_multiple>,  :returns(gboolean), :cnv-return(Bool)),
  get-shortcut-folders => %(:is-symbol<gtk_file_chooser_get_shortcut_folders>,  :returns(N-Object)),
  remove-choice => %(:is-symbol<gtk_file_chooser_remove_choice>,  :parameters([Str])),
  remove-filter => %(:is-symbol<gtk_file_chooser_remove_filter>,  :parameters([N-Object])),
  remove-shortcut-folder => %(:is-symbol<gtk_file_chooser_remove_shortcut_folder>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  set-action => %(:is-symbol<gtk_file_chooser_set_action>,  :parameters([GEnum])),
  set-choice => %(:is-symbol<gtk_file_chooser_set_choice>,  :parameters([Str, Str])),
  set-create-folders => %(:is-symbol<gtk_file_chooser_set_create_folders>,  :parameters([gboolean])),
  set-current-folder => %(:is-symbol<gtk_file_chooser_set_current_folder>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  set-current-name => %(:is-symbol<gtk_file_chooser_set_current_name>,  :parameters([Str])),
  set-file => %(:is-symbol<gtk_file_chooser_set_file>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  set-filter => %(:is-symbol<gtk_file_chooser_set_filter>,  :parameters([N-Object])),
  set-select-multiple => %(:is-symbol<gtk_file_chooser_set_select_multiple>,  :parameters([gboolean])),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 (
  Str $name, Bool $_fallback-v2-ok is rw,
  Gnome::N::GnomeRoutineCaller $routine-caller, @arguments, $native-object
) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    return $routine-caller.call-native-sub(
      $name, @arguments, $methods, $native-object, 'gtk_file_chooser_'
    );
  }
}
