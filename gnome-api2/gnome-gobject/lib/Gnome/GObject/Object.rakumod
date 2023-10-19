# Command to generate: generate.raku -v -c -t GObject object
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


#use Gnome::GObject::N-Closure:api<2>;
use Gnome::GObject::N-Value:api<2>;
#use Gnome::GObject::T-BindingFlags:api<2>;
use Gnome::N::GObjectSupport:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-GObject:api<2>;
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

# Check on native library initialization.
my Bool $gui-initialized = False;
my Bool $may-not-initialize-gui = False;

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
  $!routine-caller .= new( :library(gobject-lib()), :sub-prefix<g_object_>);

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::GObject::Object' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    die X::Gnome.new(:message("Native object not defined"))
      unless self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GObject');
  }
}

#`{{
# Next two methods need checks for proper referencing or cleanup 
method native-object-ref ( $n-native-object ) {
  $n-native-object
}

method native-object-unref ( $n-native-object ) {
#  self._fallback-v2( 'free', my Bool $x);
}
}}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-object => %( :type(Constructor), :isnew, :returns(gpointer), :variable-list, :parameters([ GType, Str])),
  #new-valist => %( :type(Constructor), :returns(N-GObject), :parameters([ GType, Str, ])),
  new-with-properties => %( :type(Constructor), :returns(N-GObject), :parameters([ GType, guint, gchar-pptr, N-Value ])),

  #--[Methods]------------------------------------------------------------------
  add-toggle-ref => %( :parameters([:( gpointer $data, N-GObject $object, gboolean $is-last-ref ), gpointer])),
  add-weak-pointer => %( :parameters([CArray[gpointer]])),
  #bind-property => %( :returns(N-GObject), :parameters([Str, gpointer, Str, GFlag])),
  #bind-property-full => %( :returns(N-GObject), :parameters([Str, gpointer, Str, GFlag, :( N-GObject $binding, N-Value  $from-value, N-Value  $to-value, gpointer $user-data --> gboolean ) , :( N-GObject $binding, N-Value  $from-value, N-Value  $to-value, gpointer $user-data --> gboolean ) , gpointer, ])),
  #bind-property-with-closures => %( :returns(N-GObject), :parameters([Str, gpointer, Str, GFlag, N-Closure , N-Closure ])),
  connect => %(:variable-list,  :returns(gpointer), :parameters([Str])),
  disconnect => %(:variable-list,  :parameters([Str])),
  #dup-data => %( :returns(gpointer), :parameters([Str, , gpointer])),
  #dup-qdata => %( :returns(gpointer), :parameters([GQuark, , gpointer])),
  force-floating => %(),
  freeze-notify => %(),
  get => %(:variable-list,  :parameters([Str])),
  get-data => %( :returns(gpointer), :parameters([Str])),
  get-property => %( :parameters([Str, N-Value ])),
  get-qdata => %( :returns(gpointer), :parameters([GQuark])),
  #get-valist => %( :parameters([Str, ])),
  getv => %( :parameters([guint, gchar-pptr, N-Value ])),
  is-floating => %( :returns(gboolean), :cnv-return(Bool)),
  notify => %( :parameters([Str])),
  notify-by-pspec => %( :parameters([N-GObject])),
  ref => %( :returns(gpointer)),
  ref-sink => %( :returns(gpointer)),
  remove-toggle-ref => %( :parameters([:( gpointer $data, N-GObject $object, gboolean $is-last-ref ), gpointer])),
  remove-weak-pointer => %( :parameters([CArray[gpointer]])),
  #replace-data => %( :returns(gboolean), :cnv-return(Bool), :parameters([Str, gpointer, gpointer, , ])),
  #replace-qdata => %( :returns(gboolean), :cnv-return(Bool), :parameters([GQuark, gpointer, gpointer, , ])),
  run-dispose => %(),
  set => %(:variable-list,  :parameters([Str])),
  set-data => %( :parameters([Str, gpointer])),
  #set-data-full => %( :parameters([Str, gpointer, ])),
  set-property => %( :parameters([Str, N-Value ])),
  set-qdata => %( :parameters([GQuark, gpointer])),
  #set-qdata-full => %( :parameters([GQuark, gpointer, ])),
  #set-valist => %( :parameters([Str, ])),
  setv => %( :parameters([guint, gchar-pptr, N-Value ])),
  steal-data => %( :returns(gpointer), :parameters([Str])),
  steal-qdata => %( :returns(gpointer), :parameters([GQuark])),
  take-ref => %( :returns(gpointer)),
  thaw-notify => %(),
  unref => %(),
  #watch-closure => %( :parameters([N-Closure ])),
  weak-ref => %( :parameters([:( gpointer $data, N-GObject $where-the-object-was ), gpointer])),
  weak-unref => %( :parameters([:( gpointer $data, N-GObject $where-the-object-was ), gpointer])),

  #--[Functions]----------------------------------------------------------------
  compat-control => %( :type(Function),  :returns(gsize), :parameters([ gsize, gpointer])),
  interface-find-property => %( :type(Function),  :returns(N-GObject), :parameters([ gpointer, Str])),
  interface-install-property => %( :type(Function),  :parameters([ gpointer, N-GObject])),
  interface-list-properties => %( :type(Function),  :returns(CArray[N-GObject]), :parameters([ gpointer, gint-ptr])),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    if $methods{$name}<type>:exists and $methods{$name}<type> eq 'Constructor' {
      my Gnome::N::GnomeRoutineCaller $routine-caller .= new(
        :library(gobject-lib()), :sub-prefix<g_object_>
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
