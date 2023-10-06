# Command to generate: generate.raku -c Gio application
use v6;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::GObject::Object:api<2>;
#use Gnome::Gio::R-ActionGroup:api<2>;
#use Gnome::Gio::R-ActionMap:api<2>;
use Gnome::Gio::T-Ioenums:api<2>;
#use Gnome::Glib::N-GOptionEntry:api<2>;
#use Gnome::Glib::N-GOptionGroup:api<2>;
#use Gnome::Glib::T-GOptionEntry:api<2>;
#use Gnome::Glib::T-Option:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-GObject:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gio::Application:auth<github:MARTIMM>:api<2>;
also is Gnome::GObject::Object;
#also does Gnome::Gio::R-ActionGroup;
#also does Gnome::Gio::R-ActionMap;

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
      :w0<startup name-lost shutdown activate>,
      :w1<handle-local-options command-line>,
      :w3<open>,
    );

    # Signals from interfaces
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new( :library(gio-lib()), :sub-prefix<g_application_>);

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gio::Application' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    die X::Gnome.new(:message("Native object not defined"))
      unless self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GApplication');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-application => %( :type(Constructor), :isnew, :returns(N-GObject), :parameters([ Str, GFlag])),

  #--[Methods]------------------------------------------------------------------
  activate => %(),
  #add-main-option => %( :parameters([Str, gchar, GFlag, GEnum, Str, Str])),
  #add-main-option-entries => %( :parameters([N-GOptionEntry ])),
  #add-option-group => %( :parameters([N-GOptionGroup ])),
  bind-busy-property => %( :parameters([gpointer, Str])),
  get-application-id => %( :returns(Str)),
  get-dbus-connection => %( :returns(N-GObject)),
  get-dbus-object-path => %( :returns(Str)),
  get-flags => %( :returns(GFlag), :cnv-return(GApplicationFlags)),
  get-inactivity-timeout => %( :returns(guint)),
  get-is-busy => %( :returns(gboolean), :cnv-return(Bool)),
  get-is-registered => %( :returns(gboolean), :cnv-return(Bool)),
  get-is-remote => %( :returns(gboolean), :cnv-return(Bool)),
  get-resource-base-path => %( :returns(Str)),
  hold => %(),
  mark-busy => %(),
  open => %( :parameters([CArray[N-GObject], gint, Str])),
  quit => %(),
  register => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-GObject])),
  release => %(),
  run => %( :returns(gint), :parameters([gint, gchar-pptr])),
  send-notification => %( :parameters([Str, N-GObject])),
  set-application-id => %( :parameters([Str])),
  set-default => %(),
  set-flags => %( :parameters([GFlag])),
  set-inactivity-timeout => %( :parameters([guint])),
  set-option-context-description => %( :parameters([Str])),
  set-option-context-parameter-string => %( :parameters([Str])),
  set-option-context-summary => %( :parameters([Str])),
  set-resource-base-path => %( :parameters([Str])),
  unbind-busy-property => %( :parameters([gpointer, Str])),
  unmark-busy => %(),
  withdraw-notification => %( :parameters([Str])),

  #--[Functions]----------------------------------------------------------------
  get-default => %( :type(Function),  :returns(N-GObject)),
  id-is-valid => %( :type(Function),  :returns(gboolean), :parameters([Str])),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    if $methods{$name}<type>:exists and $methods{$name}<type> eq 'Constructor' {
      my Gnome::N::GnomeRoutineCaller $routine-caller .= new(
        :library(gio-lib()), :sub-prefix<g_application_>
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
        $name, @arguments, $methods, $native-object
      );
    }
  }

  else {
    my $r;
    my $native-object = self.get-native-object-no-reffing;
#`{{
    $r = self.Gnome::Gio::R-ActionGroup::_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    );
    return $r if $_fallback-v2-ok;

}}
#`{{
    $r = self.Gnome::Gio::R-ActionMap::_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    );
    return $r if $_fallback-v2-ok;

}}
    callsame;
  }
}
