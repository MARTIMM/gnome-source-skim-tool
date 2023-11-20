# Command to generate: generate.raku -v -d -c GObject object
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


#use :api<2>;
#use Gnome::GObject::N-Closure:api<2>;
use Gnome::GObject::N-Value:api<2>;
#use Gnome::GObject::T-Binding:api<2>;
use Gnome::N::GObjectSupport:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::GObject::Object:auth<github:MARTIMM>:api<2>;
also is Gnome::N::TopLevelClassSupport;
also does Gnome::N::GObjectSupport;

#-------------------------------------------------------------------------------
#--[BUILD variables]------------------------------------------------------------
#-------------------------------------------------------------------------------

# Define callable helper
has Gnome::N::GnomeRoutineCaller $!routine-caller;

# Add signal registration helper
my Bool $signals-added = False;

#-------------------------------------------------------------------------------
#--[BUILD submethod]------------------------------------------------------------
#-------------------------------------------------------------------------------

submethod BUILD ( *%options ) {
  # Add signal administration info.
  unless $signals-added {
    self.add-signal-types( $?CLASS.^name,
      :w1<notify>,
    );
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library('libgobject-2.0.so.0'));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::GObject::Object' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GObject');
  }
}

# Next two methods need checks for proper referencing or cleanup 
method native-object-ref ( $n-native-object ) {
  $n-native-object
}

method native-object-unref ( $n-native-object ) {
#  self._fallback-v2( 'free', my Bool $x);
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-object => %( :type(Constructor), :is-symbol<g_object_new>, :returns(gpointer), :variable-list, :parameters([ GType, Str])),
  #new-valist => %( :type(Constructor), :is-symbol<g_object_new_valist>, :returns(N-Object), :parameters([ GType, Str, ])),
  new-with-properties => %( :type(Constructor), :is-symbol<g_object_new_with_properties>, :returns(N-Object), :parameters([ GType, guint, gchar-pptr, N-Value])),

  #--[Methods]------------------------------------------------------------------
  add-toggle-ref => %(:is-symbol<g_object_add_toggle_ref>,  :parameters([:( gpointer $data, N-Object $object, gboolean $is-last-ref ), gpointer])),
  add-weak-pointer => %(:is-symbol<g_object_add_weak_pointer>,  :parameters([CArray[gpointer]])),
  #bind-property => %(:is-symbol<g_object_bind_property>,  :returns(N-Object), :parameters([Str, gpointer, Str, GFlag])),
  #bind-property-full => %(:is-symbol<g_object_bind_property_full>,  :returns(N-Object), :parameters([Str, gpointer, Str, GFlag, :( N-Object $binding, N-Value $from-value, N-Value $to-value, gpointer $user-data --> gboolean ), :( N-Object $binding, N-Value $from-value, N-Value $to-value, gpointer $user-data --> gboolean ), gpointer, ])),
  #bind-property-with-closures => %(:is-symbol<g_object_bind_property_with_closures>,  :returns(N-Object), :parameters([Str, gpointer, Str, GFlag, N-Closure , N-Closure ])),
  connect => %(:is-symbol<g_object_connect>, :variable-list,  :returns(gpointer), :parameters([Str])),
  disconnect => %(:is-symbol<g_object_disconnect>, :variable-list,  :parameters([Str])),
  #dup-data => %(:is-symbol<g_object_dup_data>,  :returns(gpointer), :parameters([Str, , gpointer])),
  #dup-qdata => %(:is-symbol<g_object_dup_qdata>,  :returns(gpointer), :parameters([GQuark, , gpointer])),
  force-floating => %(:is-symbol<g_object_force_floating>, ),
  freeze-notify => %(:is-symbol<g_object_freeze_notify>, ),
  get => %(:is-symbol<g_object_get>, :variable-list,  :parameters([Str])),
  get-data => %(:is-symbol<g_object_get_data>,  :returns(gpointer), :parameters([Str])),
  get-property => %(:is-symbol<g_object_get_property>,  :parameters([Str, N-Value])),
  get-qdata => %(:is-symbol<g_object_get_qdata>,  :returns(gpointer), :parameters([GQuark])),
  #get-valist => %(:is-symbol<g_object_get_valist>,  :parameters([Str, ])),
  getv => %(:is-symbol<g_object_getv>,  :parameters([guint, gchar-pptr, N-Value])),
  is-floating => %(:is-symbol<g_object_is_floating>,  :returns(gboolean), :cnv-return(Bool)),
  notify => %(:is-symbol<g_object_notify>,  :parameters([Str])),
  notify-by-pspec => %(:is-symbol<g_object_notify_by_pspec>,  :parameters([N-Object])),
  ref => %(:is-symbol<g_object_ref>,  :returns(gpointer)),
  ref-sink => %(:is-symbol<g_object_ref_sink>,  :returns(gpointer)),
  remove-toggle-ref => %(:is-symbol<g_object_remove_toggle_ref>,  :parameters([:( gpointer $data, N-Object $object, gboolean $is-last-ref ), gpointer])),
  remove-weak-pointer => %(:is-symbol<g_object_remove_weak_pointer>,  :parameters([CArray[gpointer]])),
  #replace-data => %(:is-symbol<g_object_replace_data>,  :returns(gboolean), :cnv-return(Bool), :parameters([Str, gpointer, gpointer, , ])),
  #replace-qdata => %(:is-symbol<g_object_replace_qdata>,  :returns(gboolean), :cnv-return(Bool), :parameters([GQuark, gpointer, gpointer, , ])),
  run-dispose => %(:is-symbol<g_object_run_dispose>, ),
  set => %(:is-symbol<g_object_set>, :variable-list,  :parameters([Str])),
  set-data => %(:is-symbol<g_object_set_data>,  :parameters([Str, gpointer])),
  #set-data-full => %(:is-symbol<g_object_set_data_full>,  :parameters([Str, gpointer, ])),
  set-property => %(:is-symbol<g_object_set_property>,  :parameters([Str, N-Value])),
  set-qdata => %(:is-symbol<g_object_set_qdata>,  :parameters([GQuark, gpointer])),
  #set-qdata-full => %(:is-symbol<g_object_set_qdata_full>,  :parameters([GQuark, gpointer, ])),
  #set-valist => %(:is-symbol<g_object_set_valist>,  :parameters([Str, ])),
  setv => %(:is-symbol<g_object_setv>,  :parameters([guint, gchar-pptr, N-Value])),
  steal-data => %(:is-symbol<g_object_steal_data>,  :returns(gpointer), :parameters([Str])),
  steal-qdata => %(:is-symbol<g_object_steal_qdata>,  :returns(gpointer), :parameters([GQuark])),
  take-ref => %(:is-symbol<g_object_take_ref>,  :returns(gpointer)),
  thaw-notify => %(:is-symbol<g_object_thaw_notify>, ),
  unref => %(:is-symbol<g_object_unref>, ),
  #watch-closure => %(:is-symbol<g_object_watch_closure>,  :parameters([N-Closure ])),
  weak-ref => %(:is-symbol<g_object_weak_ref>,  :parameters([:( gpointer $data, N-Object $where-the-object-was ), gpointer])),
  weak-unref => %(:is-symbol<g_object_weak_unref>,  :parameters([:( gpointer $data, N-Object $where-the-object-was ), gpointer])),

  #--[Functions]----------------------------------------------------------------
  compat-control => %( :type(Function), :is-symbol<g_object_compat_control>,  :returns(gsize), :parameters([ gsize, gpointer])),
  interface-find-property => %( :type(Function), :is-symbol<g_object_interface_find_property>,  :returns(N-Object), :parameters([ gpointer, Str])),
  interface-install-property => %( :type(Function), :is-symbol<g_object_interface_install_property>,  :parameters([ gpointer, N-Object])),
  interface-list-properties => %( :type(Function), :is-symbol<g_object_interface_list_properties>,  :returns(CArray[N-Object]), :parameters([ gpointer, gint-ptr])),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    if $methods{$name}<type>:exists and $methods{$name}<type> eq 'Constructor' {
      my Gnome::N::GnomeRoutineCaller $routine-caller .= new(
        :library('libgobject-2.0.so.0')
      );

      # Check the function name. 
      return self.bless(
        :native-object(
          $routine-caller.call-native-sub( $name, @arguments, $methods)
        )
      );
    }

    elsif $methods{$name}<type>:exists and $methods{$name}<type> eq 'Function' {
      return $!routine-caller.call-native-sub( $name, @arguments, $methods);
    }

    else {
      my $native-object = self.get-native-object-no-reffing;
      return $!routine-caller.call-native-sub(
        $name, @arguments, $methods, $native-object
      );
    }
  }

  else {
    callsame;
  }
}
