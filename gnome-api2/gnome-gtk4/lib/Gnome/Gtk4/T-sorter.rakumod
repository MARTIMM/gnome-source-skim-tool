=comment Package: Gtk4, C-Source: sorter
use v6.d;
#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::T-sorter:auth<github:MARTIMM>:api<2>;
#-------------------------------------------------------------------------------
#--[Enumerations]---------------------------------------------------------------
#-------------------------------------------------------------------------------
enum GtkSorterChange is export <
  GTK_SORTER_CHANGE_DIFFERENT GTK_SORTER_CHANGE_INVERTED GTK_SORTER_CHANGE_LESS_STRICT GTK_SORTER_CHANGE_MORE_STRICT 
>;

enum GtkSorterOrder is export <
  GTK_SORTER_ORDER_PARTIAL GTK_SORTER_ORDER_NONE GTK_SORTER_ORDER_TOTAL 
>;

