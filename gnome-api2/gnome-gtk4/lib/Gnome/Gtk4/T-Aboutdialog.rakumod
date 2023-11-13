# Command to generate: generate.raku -v -c Gtk4 aboutdialog function enumeration
use v6.d;
#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;

#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::T-Aboutdialog:auth<github:MARTIMM>:api<2>;

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
  $!routine-caller .= new( :library(gtk4-lib()), :sub-prefix("gtk_"));
}

#-------------------------------------------------------------------------------
#--[Enumerations]---------------------------------------------------------------
#-------------------------------------------------------------------------------
enum GtkLicense is export <
  GTK_LICENSE_UNKNOWN GTK_LICENSE_CUSTOM GTK_LICENSE_GPL_2_0 GTK_LICENSE_GPL_3_0 GTK_LICENSE_LGPL_2_1 GTK_LICENSE_LGPL_3_0 GTK_LICENSE_BSD GTK_LICENSE_MIT_X11 GTK_LICENSE_ARTISTIC GTK_LICENSE_GPL_2_0_ONLY GTK_LICENSE_GPL_3_0_ONLY GTK_LICENSE_LGPL_2_1_ONLY GTK_LICENSE_LGPL_3_0_ONLY GTK_LICENSE_AGPL_3_0 GTK_LICENSE_AGPL_3_0_ONLY GTK_LICENSE_BSD_3 GTK_LICENSE_APACHE_2_0 GTK_LICENSE_MPL_2_0 
>;

#-------------------------------------------------------------------------------
#--[Standalone functions]-------------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(
  
  #--[Functions]----------------------------------------------------------------
  show-about-dialog => %( :type(Function), :variable-list,  :parameters([ N-Object, Str])),

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
