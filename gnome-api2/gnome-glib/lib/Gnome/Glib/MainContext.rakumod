# Command to generate: generate.raku -c Glib main record
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Glib::N-GMainContext:api<2>;
#use Gnome::Glib::N-GPollFD:api<2>;
#use Gnome::Glib::N-GSource:api<2>;
#use Gnome::Glib::N-GSourceFuncs:api<2>;
#use Gnome::Glib::T-GMainContext:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-GObject:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Glib::MainContext:auth<github:MARTIMM>:api<2>;
also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
#--[BUILD variables]------------------------------------------------------------
#-------------------------------------------------------------------------------

# Define callable helper
has Gnome::N::GnomeRoutineCaller $!routine-caller;

#-------------------------------------------------------------------------------
#--[BUILD submethod]------------------------------------------------------------
#-------------------------------------------------------------------------------

submethod BUILD ( *%options ) {

  # Initialize helper
  $!routine-caller .= new( :library(glib-lib()), :sub-prefix<g_main_context_>);

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Glib::MainContext' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    die X::Gnome.new(:message("Native object not defined"))
      unless self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GMainContext');
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
  new-maincontext => %( :type(Constructor), :isnew, :returns(N-GMainContext), ),
  #new-with-flags => %( :type(Constructor), :returns(N-GMainContext), :parameters([ GFlag])),

  #--[Methods]------------------------------------------------------------------
  acquire => %( :returns(gboolean), :cnv-return(Bool)),
  #add-poll => %( :parameters([N-GPollFD , gint])),
  #check => %( :returns(gboolean), :cnv-return(Bool), :parameters([gint, N-GPollFD , gint])),
  dispatch => %(),
  #find-source-by-funcs-user-data => %( :returns(N-GSource ), :parameters([N-GSourceFuncs , gpointer])),
  #find-source-by-id => %( :returns(N-GSource ), :parameters([guint])),
  #find-source-by-user-data => %( :returns(N-GSource ), :parameters([gpointer])),
  #get-poll-func => %( :returns(), :cnv-return(( N-GPollFD , guint, gint --> gint ) )),
  invoke => %( :parameters([:( gpointer --> gboolean ), gpointer])),
  invoke-full => %( :parameters([gint, :( gpointer --> gboolean ), gpointer, :( gpointer )])),
  is-owner => %( :returns(gboolean), :cnv-return(Bool)),
  iteration => %( :returns(gboolean), :cnv-return(Bool), :parameters([gboolean])),
  pending => %( :returns(gboolean), :cnv-return(Bool)),
  pop-thread-default => %(),
  prepare => %( :returns(gboolean), :cnv-return(Bool), :parameters([gint-ptr])),
  push-thread-default => %(),
  #query => %( :returns(gint), :parameters([gint, gint-ptr, N-GPollFD , gint])),
  ref => %( :returns(N-GMainContext)),
  release => %(),
  #remove-poll => %( :parameters([N-GPollFD ])),
  #set-poll-func => %( :parameters([:( N-GPollFD , guint, gint --> gint ) ])),
  unref => %(),
  wakeup => %(),

  #--[Functions]----------------------------------------------------------------
  default => %( :type(Function),  :returns(N-GMainContext)),
  get-thread-default => %( :type(Function),  :returns(N-GMainContext)),
  ref-thread-default => %( :type(Function),  :returns(N-GMainContext)),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    if $methods{$name}<type>:exists and $methods{$name}<type> eq 'Constructor' {
      my Gnome::N::GnomeRoutineCaller $routine-caller .= new(
        :library(glib-lib()), :sub-prefix<g_main_context_>
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
