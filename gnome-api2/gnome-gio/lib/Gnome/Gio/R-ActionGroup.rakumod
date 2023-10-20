# Command to generate: generate.raku -v -c Gio actiongroup
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Glib::N-Variant:api<2>;
use Gnome::Glib::N-VariantType:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-GObject:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;


#-------------------------------------------------------------------------------
#--[Role Declaration]-----------------------------------------------------------
#-------------------------------------------------------------------------------

unit role Gnome::Gio::R-ActionGroup:auth<github:MARTIMM>:api<2>;

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  action-added => %( :parameters([Str])),
  action-enabled-changed => %( :parameters([Str, gboolean])),
  action-removed => %( :parameters([Str])),
  action-state-changed => %( :parameters([Str, N-Variant])),
  activate-action => %( :parameters([Str, N-Variant])),
  change-action-state => %( :parameters([Str, N-Variant])),
  get-action-enabled => %( :returns(gboolean), :cnv-return(Bool), :parameters([Str])),
  get-action-parameter-type => %( :returns(N-VariantType), :parameters([Str])),
  get-action-state => %( :returns(N-Variant), :parameters([Str])),
  get-action-state-hint => %( :returns(N-Variant), :parameters([Str])),
  get-action-state-type => %( :returns(N-VariantType), :parameters([Str])),
  has-action => %( :returns(gboolean), :cnv-return(Bool), :parameters([Str])),
  list-actions => %( :returns(gchar-pptr)),
  #query-action => %( :returns(gboolean), :cnv-return(Bool), :parameters([Str, , CArray[N-VariantType], CArray[N-VariantType], CArray[N-Variant], CArray[N-Variant]])),
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
      $name, @arguments, $methods, $native-object, 'g_action_group_'
    );
  }
}
