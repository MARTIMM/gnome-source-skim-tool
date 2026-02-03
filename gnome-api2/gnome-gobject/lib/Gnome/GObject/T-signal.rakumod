=comment Package: GObject, C-Source: signal
use v6.d;
#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;



#use Gnome::GObject::T-closure:api<2>;
#use Gnome::GObject::T-signal:api<2>;
use Gnome::GObject::T-value:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;
use Gnome::N::X:api<2>;

#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::GObject::T-signal:auth<github:MARTIMM>:api<2>;
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
  $!routine-caller .= new(:library(gobject-lib()));
}

#-------------------------------------------------------------------------------
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------

class N-SignalQuery:auth<github:MARTIMM>:api<2> is export is repr('CStruct') {

  has guint $.signal-id;
  has Str $.signal-name;
  has GType $.itype;
  has GFlag $.signal-flags;           # GSignalFlags _UA_
  has GType $.return-type;
  has guint $.n-params;
  has  $.param-types;

  submethod BUILD (
    guint :$!signal-id, Str :$!signal-name, GType :$!itype, GFlag :$!signal-flags, GType :$!return-type, guint :$!n-params,  :$!param-types, 
  ) {
  }

  method COERCE ( $no --> N-SignalQuery ) {
    note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
    nativecast( N-SignalQuery, $no)
  }
}


class N-SignalInvocationHint:auth<github:MARTIMM>:api<2> is export is repr('CStruct') {

  has guint $.signal-id;
  has GQuark $.detail;
  has GFlag $.run-type;           # GSignalFlags _UA_

  submethod BUILD (
    guint :$!signal-id, GQuark :$!detail, GFlag :$!run-type, 
  ) {
  }

  method COERCE ( $no --> N-SignalInvocationHint ) {
    note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
    nativecast( N-SignalInvocationHint, $no)
  }
}

#-------------------------------------------------------------------------------
#--[Constants]------------------------------------------------------------------
#-------------------------------------------------------------------------------
constant G_SIGNAL_FLAGS_MASK is export = 511;
constant G_SIGNAL_MATCH_MASK is export = 63;

#-------------------------------------------------------------------------------
#--[Bitfields]------------------------------------------------------------------
#-------------------------------------------------------------------------------
enum GConnectFlags is export (
  :G_CONNECT_DEFAULT(0), :G_CONNECT_AFTER(1), :G_CONNECT_SWAPPED(2)
);

enum GSignalFlags is export (
  :G_SIGNAL_RUN_FIRST(1), :G_SIGNAL_RUN_LAST(2), :G_SIGNAL_RUN_CLEANUP(4), :G_SIGNAL_NO_RECURSE(8), :G_SIGNAL_DETAILED(16), :G_SIGNAL_ACTION(32), :G_SIGNAL_NO_HOOKS(64), :G_SIGNAL_MUST_COLLECT(128), :G_SIGNAL_DEPRECATED(256), :G_SIGNAL_ACCUMULATOR_FIRST_RUN(131072)
);

enum GSignalMatchType is export (
  :G_SIGNAL_MATCH_ID(1), :G_SIGNAL_MATCH_DETAIL(2), :G_SIGNAL_MATCH_CLOSURE(4), :G_SIGNAL_MATCH_FUNC(8), :G_SIGNAL_MATCH_DATA(16), :G_SIGNAL_MATCH_UNBLOCKED(32)
);

#-------------------------------------------------------------------------------
#--[Standalone functions]-------------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(
  
  #--[Functions]----------------------------------------------------------------
  #clear-signal-handler => %( :type(Function), :is-symbol<g_clear_signal_handler>, :parameters([ , gpointer]), ),
  signal-accumulator-first-wins => %( :type(Function), :is-symbol<g_signal_accumulator_first_wins>, :returns(gboolean), :parameters([ gint-ptr, N-Object, N-Object, gpointer]), ),
  signal-accumulator-true-handled => %( :type(Function), :is-symbol<g_signal_accumulator_true_handled>, :returns(gboolean), :parameters([ gint-ptr, N-Object, N-Object, gpointer]), ),
  signal-add-emission-hook => %( :type(Function), :is-symbol<g_signal_add_emission_hook>, :returns(gulong), :parameters([ guint, GQuark, :( gint-ptr $ihint, guint $n-param-values, N-Object $param-values, gpointer $data ), gpointer, :( gpointer $data )]), ),
  signal-chain-from-overridden => %( :type(Function), :is-symbol<g_signal_chain_from_overridden>, :parameters([ N-Object, N-Object]), ),
  signal-chain-from-overridden-handler => %( :type(Function), :is-symbol<g_signal_chain_from_overridden_handler>, :variable-list, :parameters([gpointer]), ),
  signal-connect-closure => %( :type(Function), :is-symbol<g_signal_connect_closure>, :returns(gulong), :parameters([ gpointer, Str, N-Object, gboolean]), ),
  signal-connect-closure-by-id => %( :type(Function), :is-symbol<g_signal_connect_closure_by_id>, :returns(gulong), :parameters([ gpointer, guint, GQuark, N-Object, gboolean]), ),
  #signal-connect-data => %( :type(Function), :is-symbol<g_signal_connect_data>, :returns(gulong), :parameters([UInt]), ),
  signal-emit => %( :type(Function), :is-symbol<g_signal_emit>, :variable-list, :parameters([ gpointer, guint, GQuark]), ),
  signal-emit-by-name => %( :type(Function), :is-symbol<g_signal_emit_by_name>, :variable-list, :parameters([ gpointer, Str]), ),
  #signal-emit-valist => %( :type(Function), :is-symbol<g_signal_emit_valist>, :parameters([ gpointer, guint, GQuark, ]), ),
  signal-emitv => %( :type(Function), :is-symbol<g_signal_emitv>, :parameters([ N-Object, guint, GQuark, N-Object]), ),
  signal-get-invocation-hint => %( :type(Function), :is-symbol<g_signal_get_invocation_hint>, :returns(gint-ptr), :parameters([gpointer]), ),
  signal-handler-block => %( :type(Function), :is-symbol<g_signal_handler_block>, :parameters([ gpointer, gulong]), ),
  signal-handler-disconnect => %( :type(Function), :is-symbol<g_signal_handler_disconnect>, :parameters([ gpointer, gulong]), ),
  #signal-handler-find => %( :type(Function), :is-symbol<g_signal_handler_find>, :returns(gulong), :parameters([ UInt, guint, GQuark, N-Object, gpointer, gpointer]), ),
  signal-handler-is-connected => %( :type(Function), :is-symbol<g_signal_handler_is_connected>, :returns(gboolean), :parameters([ gpointer, gulong]), ),
  signal-handler-unblock => %( :type(Function), :is-symbol<g_signal_handler_unblock>, :parameters([ gpointer, gulong]), ),
  #signal-handlers-block-matched => %( :type(Function), :is-symbol<g_signal_handlers_block_matched>, :returns(guint), :parameters([ UInt, guint, GQuark, N-Object, gpointer, gpointer]), ),
  signal-handlers-destroy => %( :type(Function), :is-symbol<g_signal_handlers_destroy>, :parameters([gpointer]), ),
  #signal-handlers-disconnect-matched => %( :type(Function), :is-symbol<g_signal_handlers_disconnect_matched>, :returns(guint), :parameters([ UInt, guint, GQuark, N-Object, gpointer, gpointer]), ),
  #signal-handlers-unblock-matched => %( :type(Function), :is-symbol<g_signal_handlers_unblock_matched>, :returns(guint), :parameters([ UInt, guint, GQuark, N-Object, gpointer, gpointer]), ),
  signal-has-handler-pending => %( :type(Function), :is-symbol<g_signal_has_handler_pending>, :returns(gboolean), :parameters([ gpointer, guint, GQuark, gboolean]), ),
  signal-is-valid-name => %( :type(Function), :is-symbol<g_signal_is_valid_name>, :returns(gboolean), :parameters([Str]), ),
  signal-list-ids => %( :type(Function), :is-symbol<g_signal_list_ids>, :returns(gint-ptr), :parameters([ GType, gint-ptr]), ),
  signal-lookup => %( :type(Function), :is-symbol<g_signal_lookup>, :returns(guint), :parameters([ Str, GType]), ),
  signal-name => %( :type(Function), :is-symbol<g_signal_name>, :returns(Str), :parameters([guint]), ),
  #signal-new => %( :type(Function), :is-symbol<g_signal_new>, :variable-list, :returns(guint), :parameters([ UInt, guint, :( gint-ptr $ihint, N-Object $return-accu, N-Object $handler-return, gpointer $data ), gpointer, , GType, guint]), ),
  #signal-new-class-handler => %( :type(Function), :is-symbol<g_signal_new_class_handler>, :variable-list, :returns(guint), :parameters([ UInt, :( ), :( gint-ptr $ihint, N-Object $return-accu, N-Object $handler-return, gpointer $data ), gpointer, , GType, guint]), ),
  #signal-new-valist => %( :type(Function), :is-symbol<g_signal_new_valist>, :returns(guint), :parameters([ UInt, N-Object, :( gint-ptr $ihint, N-Object $return-accu, N-Object $handler-return, gpointer $data ), gpointer, , GType, guint, ]), ),
  #signal-newv => %( :type(Function), :is-symbol<g_signal_newv>, :returns(guint), :parameters([ UInt, N-Object, :( gint-ptr $ihint, N-Object $return-accu, N-Object $handler-return, gpointer $data ), gpointer, , GType, guint, ]), ),
  signal-override-class-closure => %( :type(Function), :is-symbol<g_signal_override_class_closure>, :parameters([ guint, GType, N-Object]), ),
  signal-override-class-handler => %( :type(Function), :is-symbol<g_signal_override_class_handler>, :parameters([ Str, GType, :( )]), ),
  signal-parse-name => %( :type(Function), :is-symbol<g_signal_parse_name>, :returns(gboolean), :parameters([ Str, GType, gint-ptr, GQuark, gboolean]), ),
  signal-query => %( :type(Function), :is-symbol<g_signal_query>, :parameters([ guint, N-Object]), ),
  signal-remove-emission-hook => %( :type(Function), :is-symbol<g_signal_remove_emission_hook>, :parameters([ guint, gulong]), ),
  #signal-set-va-marshaller => %( :type(Function), :is-symbol<g_signal_set_va_marshaller>, :parameters([ guint, GType, ]), ),
  signal-stop-emission => %( :type(Function), :is-symbol<g_signal_stop_emission>, :parameters([ gpointer, guint, GQuark]), ),
  signal-stop-emission-by-name => %( :type(Function), :is-symbol<g_signal_stop_emission_by_name>, :parameters([ gpointer, Str]), ),

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
