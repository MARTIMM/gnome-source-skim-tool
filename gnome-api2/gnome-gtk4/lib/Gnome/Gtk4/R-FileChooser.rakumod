# Command to generate: generate.raku -c -t Gtk4 filechooser
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Gtk4::T-Filechooser:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-GObject:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;


#-------------------------------------------------------------------------------
#--[Role Declaration]-----------------------------------------------------------
#-------------------------------------------------------------------------------

unit role Gnome::Gtk4::R-FileChooser:auth<github:MARTIMM>:api<2>;

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  add-choice => %( :parameters([Str, Str, gchar-pptr, gchar-pptr])),
  add-filter => %( :parameters([N-GObject])),
  add-shortcut-folder => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-GObject])),
  get-action => %( :returns(GEnum), :cnv-return(GtkFileChooserAction)),
  get-choice => %( :returns(Str), :parameters([Str])),
  get-create-folders => %( :returns(gboolean), :cnv-return(Bool)),
  get-current-folder => %( :returns(N-GObject)),
  get-current-name => %( :returns(Str)),
  get-file => %( :returns(N-GObject)),
  get-files => %( :returns(N-GObject)),
  get-filter => %( :returns(N-GObject)),
  get-filters => %( :returns(N-GObject)),
  get-select-multiple => %( :returns(gboolean), :cnv-return(Bool)),
  get-shortcut-folders => %( :returns(N-GObject)),
  remove-choice => %( :parameters([Str])),
  remove-filter => %( :parameters([N-GObject])),
  remove-shortcut-folder => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-GObject])),
  set-action => %( :parameters([GEnum])),
  set-choice => %( :parameters([Str, Str])),
  set-create-folders => %( :parameters([gboolean])),
  set-current-folder => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-GObject])),
  set-current-name => %( :parameters([Str])),
  set-file => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-GObject])),
  set-filter => %( :parameters([N-GObject])),
  set-select-multiple => %( :parameters([gboolean])),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 (
  Str $name, Bool $_fallback-v2-ok is rw,
  Gnome::N::GnomeRoutineCaller $routine-caller, @arguments, $native-object
) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    return $routine-caller.call-native-sub(
      $name, @arguments, $methods, $native-object, 'gtk_file_chooser_'
    );
  }
}
