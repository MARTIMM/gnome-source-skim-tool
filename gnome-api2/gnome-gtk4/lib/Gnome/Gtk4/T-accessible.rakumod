=comment Package: Gtk4, C-Source: accessible
use v6.d;
#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;




use Gnome::GObject::T-value:api<2>;
use Gnome::Gtk4::T-enums:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;

#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::T-accessible:auth<github:MARTIMM>:api<2>;
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
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------
# This is an opaque type of which fields are not available.
class N-AccessibleList:auth<github:MARTIMM>:api<2> is export is repr('CPointer') { }

#-------------------------------------------------------------------------------
#--[Enumerations]---------------------------------------------------------------
#-------------------------------------------------------------------------------
enum GtkAccessiblePlatformState is export <
  GTK_ACCESSIBLE_PLATFORM_STATE_FOCUSABLE GTK_ACCESSIBLE_PLATFORM_STATE_FOCUSED GTK_ACCESSIBLE_PLATFORM_STATE_ACTIVE 
>;

#-------------------------------------------------------------------------------
#--[Standalone functions]-------------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(
  
  #--[Functions]----------------------------------------------------------------
  accessible-property-init-value => %( :type(Function), :is-symbol<gtk_accessible_property_init_value>, :parameters([ GtkAccessibleProperty, N-Object]), ),
  accessible-relation-init-value => %( :type(Function), :is-symbol<gtk_accessible_relation_init_value>, :parameters([ GtkAccessibleRelation, N-Object]), ),
  accessible-state-init-value => %( :type(Function), :is-symbol<gtk_accessible_state_init_value>, :parameters([ GtkAccessibleState, N-Object]), ),

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
