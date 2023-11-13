# Command to generate: generate.raku -v -c Gio action
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Glib::N-Variant:api<2>;
use Gnome::Glib::N-VariantType:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;


#-------------------------------------------------------------------------------
#--[Role Declaration]-----------------------------------------------------------
#-------------------------------------------------------------------------------

unit role Gnome::Gio::R-Action:auth<github:MARTIMM>:api<2>;

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  activate => %( :parameters([N-Variant])),
  change-state => %( :parameters([N-Variant])),
  get-enabled => %( :returns(gboolean), :cnv-return(Bool)),
  get-name => %( :returns(Str)),
  get-parameter-type => %( :returns(N-VariantType)),
  get-state => %( :returns(N-Variant)),
  get-state-hint => %( :returns(N-Variant)),
  get-state-type => %( :returns(N-VariantType)),

  #--[Functions]----------------------------------------------------------------
  name-is-valid => %( :type(Function),  :returns(gboolean), :parameters([Str])),
  parse-detailed-name => %( :type(Function),  :returns(gboolean), :parameters([ Str, gchar-pptr, CArray[N-Variant]])),
  print-detailed-name => %( :type(Function),  :returns(Str), :parameters([ Str, N-Variant])),
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
      $name, @arguments, $methods, $native-object, 'g_action_'
    );
  }
}
