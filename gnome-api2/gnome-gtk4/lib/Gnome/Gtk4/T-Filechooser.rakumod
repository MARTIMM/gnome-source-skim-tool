# Command to generate: generate.raku -c -t Gtk4 filechooser
use v6.d;

#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::T-Filechooser:auth<github:MARTIMM>:api<2>;

#-------------------------------------------------------------------------------
#--[Enumerations]---------------------------------------------------------------
#-------------------------------------------------------------------------------
enum GtkFileChooserAction is export <
  GTK_FILE_CHOOSER_ACTION_OPEN GTK_FILE_CHOOSER_ACTION_SAVE GTK_FILE_CHOOSER_ACTION_SELECT_FOLDER 
>;

enum GtkFileChooserError is export <
  GTK_FILE_CHOOSER_ERROR_NONEXISTENT GTK_FILE_CHOOSER_ERROR_BAD_FILENAME GTK_FILE_CHOOSER_ERROR_ALREADY_EXISTS GTK_FILE_CHOOSER_ERROR_INCOMPLETE_HOSTNAME 
>;


