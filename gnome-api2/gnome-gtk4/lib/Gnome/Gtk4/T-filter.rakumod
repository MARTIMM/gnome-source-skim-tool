=comment Package: Gtk4, C-Source: filter
use v6.d;
#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::T-filter:auth<github:MARTIMM>:api<2>;
#-------------------------------------------------------------------------------
#--[Enumerations]---------------------------------------------------------------
#-------------------------------------------------------------------------------
enum GtkFilterChange is export <
  GTK_FILTER_CHANGE_DIFFERENT GTK_FILTER_CHANGE_LESS_STRICT GTK_FILTER_CHANGE_MORE_STRICT 
>;

enum GtkFilterMatch is export <
  GTK_FILTER_MATCH_SOME GTK_FILTER_MATCH_NONE GTK_FILTER_MATCH_ALL 
>;

