# Command to generate: generate.raku -c -t Gtk4 fontchooser
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Gtk4::T-Fontchooser:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;
#use Gnome::Pango::N-FontDescription:api<2>;


#-------------------------------------------------------------------------------
#--[Role Declaration]-----------------------------------------------------------
#-------------------------------------------------------------------------------

unit role Gnome::Gtk4::R-FontChooser:auth<github:MARTIMM>:api<2>;

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  get-font => %( :returns(Str)),
  #get-font-desc => %( :returns(N-FontDescription )),
  get-font-face => %( :returns(N-Object)),
  get-font-family => %( :returns(N-Object)),
  get-font-features => %( :returns(Str)),
  get-font-map => %( :returns(N-Object)),
  get-font-size => %( :returns(gint)),
  get-language => %( :returns(Str)),
  get-level => %( :returns(GFlag), :cnv-return(GtkFontChooserLevel)),
  get-preview-text => %( :returns(Str)),
  get-show-preview-entry => %( :returns(gboolean), :cnv-return(Bool)),
  #set-filter-func => %( :parameters([:( N-Object $family, N-Object $face, gpointer $data --> gboolean ), gpointer, ])),
  set-font => %( :parameters([Str])),
  #set-font-desc => %( :parameters([N-FontDescription ])),
  set-font-map => %( :parameters([N-Object])),
  set-language => %( :parameters([Str])),
  set-level => %( :parameters([GFlag])),
  set-preview-text => %( :parameters([Str])),
  set-show-preview-entry => %( :parameters([gboolean])),
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
      $name, @arguments, $methods, $native-object, 'gtk_font_chooser_'
    );
  }
}
