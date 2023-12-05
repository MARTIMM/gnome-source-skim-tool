# Package: Gtk4, C-Source: application
use v6.d;
#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::T-Application:auth<github:MARTIMM>:api<2>;
#-------------------------------------------------------------------------------
#--[Bitfields]------------------------------------------------------------------
#-------------------------------------------------------------------------------
enum GtkApplicationInhibitFlags is export (
  :GTK_APPLICATION_INHIBIT_LOGOUT(1), :GTK_APPLICATION_INHIBIT_SWITCH(2), :GTK_APPLICATION_INHIBIT_SUSPEND(4), :GTK_APPLICATION_INHIBIT_IDLE(8)
);

