# Command to generate: generate.raku -v -t -c Gtk4 Application
use v6;

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


