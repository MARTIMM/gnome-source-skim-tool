=comment Package: Gtk4, C-Source: editable
use v6.d;
#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;




use Gnome::GObject::T-value:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;

#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::T-editable:auth<github:MARTIMM>:api<2>;
also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
#--[BUILD variables]------------------------------------------------------------
#-------------------------------------------------------------------------------

# Define helper
has Gnome::N::GnomeRoutineCaller $!routine-caller;

#-------------------------------------------------------------------------------
#--[BUILD submethod]------------------------------------------------------------
#-------------------------------------------------------------------------------

submethod BUILD ( ) {
  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));
}

#-------------------------------------------------------------------------------
#--[Enumerations]---------------------------------------------------------------
#-------------------------------------------------------------------------------
enum GtkEditableProperties is export <
  GTK_EDITABLE_PROP_TEXT GTK_EDITABLE_PROP_CURSOR_POSITION GTK_EDITABLE_PROP_SELECTION_BOUND GTK_EDITABLE_PROP_EDITABLE GTK_EDITABLE_PROP_WIDTH_CHARS GTK_EDITABLE_PROP_MAX_WIDTH_CHARS GTK_EDITABLE_PROP_XALIGN GTK_EDITABLE_PROP_ENABLE_UNDO GTK_EDITABLE_NUM_PROPERTIES 
>;

#-------------------------------------------------------------------------------
#--[Standalone functions]-------------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(
  
  #--[Functions]----------------------------------------------------------------
  editable-delegate-get-property => %( :type(Function), :is-symbol<gtk_editable_delegate_get_property>, :returns(gboolean), :parameters([ N-Object, guint, N-Object, N-Object]), ),
  editable-delegate-set-property => %( :type(Function), :is-symbol<gtk_editable_delegate_set_property>, :returns(gboolean), :parameters([ N-Object, guint, N-Object, N-Object]), ),
  #editable-install-properties => %( :type(Function), :is-symbol<gtk_editable_install_properties>, :returns(guint), :parameters([ , guint]), ),

);
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    return $!routine-caller.call-native-sub(
      $name, @arguments, $methods
    );
  }

  else {
    callsame;
  }
}
