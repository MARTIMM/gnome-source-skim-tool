=comment Package: Gtk4, C-Source: scrolledwindow
use v6.d;
#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::T-ScrolledWindow:auth<github:MARTIMM>:api<2>;
#-------------------------------------------------------------------------------
#--[Enumerations]---------------------------------------------------------------
#-------------------------------------------------------------------------------
enum GtkCornerType is export <
  GTK_CORNER_TOP_LEFT GTK_CORNER_BOTTOM_LEFT GTK_CORNER_TOP_RIGHT GTK_CORNER_BOTTOM_RIGHT 
>;

enum GtkPolicyType is export <
  GTK_POLICY_ALWAYS GTK_POLICY_AUTOMATIC GTK_POLICY_NEVER GTK_POLICY_EXTERNAL 
>;

