=comment Package: Gtk4, C-Source: cellrenderer
use v6.d;
#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::T-cellrenderer:auth<github:MARTIMM>:api<2>;
#-------------------------------------------------------------------------------
#--[Enumerations]---------------------------------------------------------------
#-------------------------------------------------------------------------------
enum GtkCellRendererMode is export <
  GTK_CELL_RENDERER_MODE_INERT GTK_CELL_RENDERER_MODE_ACTIVATABLE GTK_CELL_RENDERER_MODE_EDITABLE 
>;

#-------------------------------------------------------------------------------
#--[Bitfields]------------------------------------------------------------------
#-------------------------------------------------------------------------------
enum GtkCellRendererState is export (
  :GTK_CELL_RENDERER_SELECTED(1), :GTK_CELL_RENDERER_PRELIT(2), :GTK_CELL_RENDERER_INSENSITIVE(4), :GTK_CELL_RENDERER_SORTED(8), :GTK_CELL_RENDERER_FOCUSED(16), :GTK_CELL_RENDERER_EXPANDABLE(32), :GTK_CELL_RENDERER_EXPANDED(64)
);

