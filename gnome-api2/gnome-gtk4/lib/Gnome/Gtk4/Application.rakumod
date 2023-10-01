# Command to generate: generate.raku -v -t -c Gtk4 Application
use v6;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Gnome::Gio::Application;
use Gnome::Gio::Enums;

#use Gnome::Gio::T-Ioenums:api<2>;
#use Gnome::Glib::N-GList:api<2>;

use Gnome::Gtk4::T-Application:api<2>;

use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-GObject:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::Application:auth<github:MARTIMM>:api<2>;
also is Gnome::Gio::Application;

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
      :w0<query-end>,
      :w1<window-added window-removed>,
    );
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new( :library(gtk4-lib()), :sub-prefix<gtk_application_>);

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::Application' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    die X::Gnome.new(:message("Native object not defined"))
      unless self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkApplication');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-application => %( :type(Constructor), :isnew, :returns(N-GObject), :parameters([ Str, GFlag])),

  #--[Methods]------------------------------------------------------------------
  add-window => %( :parameters([N-GObject])),
  get-accels-for-action => %( :returns(gchar-pptr), :parameters([Str])),
  get-actions-for-accel => %( :returns(gchar-pptr), :parameters([Str])),
  get-active-window => %( :returns(N-GObject)),
  get-menu-by-id => %( :returns(N-GObject), :parameters([Str])),
  get-menubar => %( :returns(N-GObject)),
  get-window-by-id => %( :returns(N-GObject), :parameters([guint])),
  #get-windows => %( :returns(N-GList )),
  inhibit => %( :returns(guint), :parameters([N-GObject, GFlag, Str])),
  list-action-descriptions => %( :returns(gchar-pptr)),
  remove-window => %( :parameters([N-GObject])),
  set-accels-for-action => %( :parameters([Str, gchar-pptr])),
  set-menubar => %( :parameters([N-GObject])),
  uninhibit => %( :parameters([guint])),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    if $methods{$name}<type>:exists and $methods{$name}<type> eq 'Constructor' {
      my Gnome::N::GnomeRoutineCaller $routine-caller .= new(
        :library(gtk4-lib()), :sub-prefix<gtk_application_>
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
