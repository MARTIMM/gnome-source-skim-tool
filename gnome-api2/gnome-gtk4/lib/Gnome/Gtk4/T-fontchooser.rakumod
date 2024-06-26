=comment Package: Gtk4, C-Source: fontchooser
use v6.d;
#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::T-fontchooser:auth<github:MARTIMM>:api<2>;
#-------------------------------------------------------------------------------
#--[Bitfields]------------------------------------------------------------------
#-------------------------------------------------------------------------------
enum GtkFontChooserLevel is export (
  :GTK_FONT_CHOOSER_LEVEL_FAMILY(0), :GTK_FONT_CHOOSER_LEVEL_STYLE(1), :GTK_FONT_CHOOSER_LEVEL_SIZE(2), :GTK_FONT_CHOOSER_LEVEL_VARIATIONS(4), :GTK_FONT_CHOOSER_LEVEL_FEATURES(8)
);

