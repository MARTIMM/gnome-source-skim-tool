# Command to generate: gnome-source-skim-tool.raku -t -c -v GObject object class
use v6;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


#use Gnome::GObject::N-GClosure:api<2>;
use Gnome::GObject::N-GValue:api<2>;
#use Gnome::GObject::T-Binding:api<2>;
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

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-object => %( :type(Constructor), :isnew, :returns(gpointer), :variable-list, :parameters([ GType, Str])),
  #new-valist => %( :type(Constructor), :returns(N-GObject), :parameters([ GType, Str, ])),
  new-with-properties => %( :type(Constructor), :returns(N-GObject), :parameters([ GType, guint, gchar-pptr, N-GValue])),

  #--[Methods]------------------------------------------------------------------
  add-toggle-ref => %( :parameters([:( gpointer, N-GObject, gboolean ), gpointer])),
  add-weak-pointer => %( :parameters([CArray[gpointer]])),
  #bind-property => %( :returns(N-GObject), :parameters([Str, gpointer, Str, GFlag])),
  #bind-property-full => %( :returns(N-GObject), :parameters([Str, gpointer, Str, GFlag, :( N-GObject, N-GValue , N-GValue , gpointer --> gboolean ) , :( N-GObject, N-GValue , N-GValue , gpointer --> gboolean ) , gpointer, ])),
  #bind-property-with-closures => %( :returns(N-GObject), :parameters([Str, gpointer, Str, GFlag, N-GClosure , N-GClosure ])),
  connect => %(:variable-list,  :returns(gpointer), :parameters([Str])),
  disconnect => %(:variable-list,  :parameters([Str])),
  #dup-data => %( :returns(gpointer), :parameters([Str, , gpointer])),
  #dup-qdata => %( :returns(gpointer), :parameters([GQuark, , gpointer])),
  force-floating => %(),
  freeze-notify => %(),
  get => %(:variable-list,  :parameters([Str])),
  get-data => %( :returns(gpointer), :parameters([Str])),
  #get-property => %( :parameters([Str, N-GValue ])),
  get-qdata => %( :returns(gpointer), :parameters([GQuark])),
  #get-valist => %( :parameters([Str, ])),
  #getv => %( :parameters([guint, gchar-pptr, N-GValue ])),
  is-floating => %( :returns(gboolean), :cnv-return(Bool)),
  notify => %( :parameters([Str])),
  notify-by-pspec => %( :parameters([N-GObject])),
  ref => %( :returns(gpointer)),
  ref-sink => %( :returns(gpointer)),
  remove-toggle-ref => %( :parameters([:( gpointer, N-GObject, gboolean ), gpointer])),
  remove-weak-pointer => %( :parameters([CArray[gpointer]])),
  #replace-data => %( :returns(gboolean), :cnv-return(Bool), :parameters([Str, gpointer, gpointer, , ])),
  #replace-qdata => %( :returns(gboolean), :cnv-return(Bool), :parameters([GQuark, gpointer, gpointer, , ])),
  run-dispose => %(),
  set => %(:variable-list,  :parameters([Str])),
  set-data => %( :parameters([Str, gpointer])),
  #set-data-full => %( :parameters([Str, gpointer, ])),
  #set-property => %( :parameters([Str, N-GValue ])),
  set-qdata => %( :parameters([GQuark, gpointer])),
  #set-qdata-full => %( :parameters([GQuark, gpointer, ])),
  #set-valist => %( :parameters([Str, ])),
  #setv => %( :parameters([guint, gchar-pptr, N-GValue ])),
  steal-data => %( :returns(gpointer), :parameters([Str])),
  steal-qdata => %( :returns(gpointer), :parameters([GQuark])),
  take-ref => %( :returns(gpointer)),
  thaw-notify => %(),
  unref => %(),
  #watch-closure => %( :parameters([N-GClosure ])),
  weak-ref => %( :parameters([:( gpointer, N-GObject ), gpointer])),
  weak-unref => %( :parameters([:( gpointer, N-GObject ), gpointer])),

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
    if $methods{$name}<type> eq 'Constructor' {
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

    else {
      my $native-object = self.get-native-object-no-reffing;
      return $!routine-caller.call-native-sub(
        $name, @arguments, $methods, :$native-object
      );
    }
  }

  else {
    callsame;
  }
}
