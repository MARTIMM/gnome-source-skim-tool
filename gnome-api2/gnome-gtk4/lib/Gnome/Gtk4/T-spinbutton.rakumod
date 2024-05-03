=comment Package: Gtk4, C-Source: spinbutton
use v6.d;
#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::T-spinbutton:auth<github:MARTIMM>:api<2>;
#-------------------------------------------------------------------------------
#--[Constants]------------------------------------------------------------------
#-------------------------------------------------------------------------------
constant GTK_INPUT_ERROR is export = -1;

#-------------------------------------------------------------------------------
#--[Enumerations]---------------------------------------------------------------
#-------------------------------------------------------------------------------
enum GtkSpinButtonUpdatePolicy is export <
  GTK_UPDATE_ALWAYS GTK_UPDATE_IF_VALID 
>;

enum GtkSpinType is export <
  GTK_SPIN_STEP_FORWARD GTK_SPIN_STEP_BACKWARD GTK_SPIN_PAGE_FORWARD GTK_SPIN_PAGE_BACKWARD GTK_SPIN_HOME GTK_SPIN_END GTK_SPIN_USER_DEFINED 
>;

