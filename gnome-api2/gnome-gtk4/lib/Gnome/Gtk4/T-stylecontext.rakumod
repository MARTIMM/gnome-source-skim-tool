=comment Package: Gtk4, C-Source: stylecontext
use v6.d;
#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::T-stylecontext:auth<github:MARTIMM>:api<2>;
#-------------------------------------------------------------------------------
#--[Bitfields]------------------------------------------------------------------
#-------------------------------------------------------------------------------
enum GtkStyleContextPrintFlags is export (
  :GTK_STYLE_CONTEXT_PRINT_NONE(0), :GTK_STYLE_CONTEXT_PRINT_RECURSE(1), :GTK_STYLE_CONTEXT_PRINT_SHOW_STYLE(2), :GTK_STYLE_CONTEXT_PRINT_SHOW_CHANGE(4)
);

