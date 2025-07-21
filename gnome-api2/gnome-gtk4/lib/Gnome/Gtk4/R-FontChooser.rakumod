=comment Package: Gtk4, C-Source: fontchooser
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Cairo;


use Gnome::Gtk4::T-fontchooser:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
#use Gnome::Pango::N-FontDescription:api<2>;
#use Gnome::Pango::T-font:api<2>;


#-------------------------------------------------------------------------------
#--[Role Declaration]-----------------------------------------------------------
#-------------------------------------------------------------------------------

unit role Gnome::Gtk4::R-FontChooser:auth<github:MARTIMM>:api<2>;


#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  get-font => %(:is-symbol<gtk_font_chooser_get_font>, :returns(Str), :deprecated, :deprecated-version<4.10>, ),
  get-font-desc => %(:is-symbol<gtk_font_chooser_get_font_desc>, :returns(N-Object), :deprecated, :deprecated-version<4.10>, ),
  get-font-face => %(:is-symbol<gtk_font_chooser_get_font_face>, :returns(N-Object), :deprecated, :deprecated-version<4.10>, ),
  get-font-family => %(:is-symbol<gtk_font_chooser_get_font_family>, :returns(N-Object), :deprecated, :deprecated-version<4.10>, ),
  get-font-features => %(:is-symbol<gtk_font_chooser_get_font_features>, :returns(Str), :deprecated, :deprecated-version<4.10>, ),
  get-font-map => %(:is-symbol<gtk_font_chooser_get_font_map>, :returns(N-Object), :deprecated, :deprecated-version<4.10>, ),
  get-font-size => %(:is-symbol<gtk_font_chooser_get_font_size>, :returns(gint), :deprecated, :deprecated-version<4.10>, ),
  get-language => %(:is-symbol<gtk_font_chooser_get_language>, :returns(Str), :deprecated, :deprecated-version<4.10>, ),
  get-level => %(:is-symbol<gtk_font_chooser_get_level>,  :returns(GFlag), :cnv-return(GtkFontChooserLevel),:deprecated, :deprecated-version<4.10>, ),
  get-preview-text => %(:is-symbol<gtk_font_chooser_get_preview_text>, :returns(Str), :deprecated, :deprecated-version<4.10>, ),
  get-show-preview-entry => %(:is-symbol<gtk_font_chooser_get_show_preview_entry>, :returns(gboolean), :deprecated, :deprecated-version<4.10>, ),
  set-filter-func => %(:is-symbol<gtk_font_chooser_set_filter_func>, :parameters([:( N-Object $family, N-Object $face, gpointer $data ), gpointer, :( gpointer $data )]), :deprecated, :deprecated-version<4.10>, ),
  set-font => %(:is-symbol<gtk_font_chooser_set_font>, :parameters([Str]), :deprecated, :deprecated-version<4.10>, ),
  set-font-desc => %(:is-symbol<gtk_font_chooser_set_font_desc>, :parameters([N-Object]), :deprecated, :deprecated-version<4.10>, ),
  set-font-map => %(:is-symbol<gtk_font_chooser_set_font_map>, :parameters([N-Object]), :deprecated, :deprecated-version<4.10>, ),
  set-language => %(:is-symbol<gtk_font_chooser_set_language>, :parameters([Str]), :deprecated, :deprecated-version<4.10>, ),
  set-level => %(:is-symbol<gtk_font_chooser_set_level>, :parameters([GFlag]), :deprecated, :deprecated-version<4.10>, ),
  set-preview-text => %(:is-symbol<gtk_font_chooser_set_preview_text>, :parameters([Str]), :deprecated, :deprecated-version<4.10>, ),
  set-show-preview-entry => %(:is-symbol<gtk_font_chooser_set_show_preview_entry>, :parameters([gboolean]), :deprecated, :deprecated-version<4.10>, ),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _do_gtk_font_chooser_fallback-v2 (
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
