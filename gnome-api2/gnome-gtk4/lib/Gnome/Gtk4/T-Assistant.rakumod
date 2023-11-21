# Command to generate: generate.raku -v -d -c Gtk4 assistant
use v6.d;
#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::T-Assistant:auth<github:MARTIMM>:api<2>;
#-------------------------------------------------------------------------------
#--[Enumerations]---------------------------------------------------------------
#-------------------------------------------------------------------------------
enum GtkAssistantPageType is export <
  GTK_ASSISTANT_PAGE_CONTENT GTK_ASSISTANT_PAGE_INTRO GTK_ASSISTANT_PAGE_CONFIRM GTK_ASSISTANT_PAGE_SUMMARY GTK_ASSISTANT_PAGE_PROGRESS GTK_ASSISTANT_PAGE_CUSTOM 
>;

