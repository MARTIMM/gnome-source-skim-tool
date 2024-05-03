=comment Package: Gtk4, C-Source: textview
use v6.d;
#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::T-textview:auth<github:MARTIMM>:api<2>;
#-------------------------------------------------------------------------------
#--[Constants]------------------------------------------------------------------
#-------------------------------------------------------------------------------
constant GTK_TEXT_VIEW_PRIORITY_VALIDATE is export = 125;

#-------------------------------------------------------------------------------
#--[Enumerations]---------------------------------------------------------------
#-------------------------------------------------------------------------------
enum GtkTextExtendSelection is export <
  GTK_TEXT_EXTEND_SELECTION_WORD GTK_TEXT_EXTEND_SELECTION_LINE 
>;

enum GtkTextViewLayer is export <
  GTK_TEXT_VIEW_LAYER_BELOW_TEXT GTK_TEXT_VIEW_LAYER_ABOVE_TEXT 
>;

enum GtkTextWindowType is export <
  GTK_TEXT_WINDOW_WIDGET GTK_TEXT_WINDOW_TEXT GTK_TEXT_WINDOW_LEFT GTK_TEXT_WINDOW_RIGHT GTK_TEXT_WINDOW_TOP GTK_TEXT_WINDOW_BOTTOM 
>;

