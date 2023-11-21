# Command to generate: generate.raku -v -d -c Gtk4 dialog
use v6.d;
#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::T-Dialog:auth<github:MARTIMM>:api<2>;
#-------------------------------------------------------------------------------
#--[Enumerations]---------------------------------------------------------------
#-------------------------------------------------------------------------------
enum GtkResponseType is export <
  GTK_RESPONSE_NONE GTK_RESPONSE_REJECT GTK_RESPONSE_ACCEPT GTK_RESPONSE_DELETE_EVENT GTK_RESPONSE_OK GTK_RESPONSE_CANCEL GTK_RESPONSE_CLOSE GTK_RESPONSE_YES GTK_RESPONSE_NO GTK_RESPONSE_APPLY GTK_RESPONSE_HELP 
>;

#-------------------------------------------------------------------------------
#--[Bitfields]------------------------------------------------------------------
#-------------------------------------------------------------------------------
enum GtkDialogFlags is export (
  :GTK_DIALOG_MODAL(1), :GTK_DIALOG_DESTROY_WITH_PARENT(2), :GTK_DIALOG_USE_HEADER_BAR(4)
);

