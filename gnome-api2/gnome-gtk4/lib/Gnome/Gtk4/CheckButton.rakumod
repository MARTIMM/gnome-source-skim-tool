# Command to generate: generate.raku -v -c Gtk4 checkbutton
use v6;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Gtk4::R-Actionable:api<2>;
use Gnome::Gtk4::Widget:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-GObject:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::CheckButton:auth<github:MARTIMM>:api<2>;
also is Gnome::Gtk4::Widget;
also does Gnome::Gtk4::R-Actionable;

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
      :w0<activate toggled>,
    );

    # Signals from interfaces
    self._add_gtk_actionable_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_actionable_signal_types');
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new( :library(gtk4-lib()), :sub-prefix<gtk_check_button_>);

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::CheckButton' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    die X::Gnome.new(:message("Native object not defined"))
      unless self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkCheckButton');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-checkbutton => %( :type(Constructor), :isnew, :returns(N-GObject), ),
  new-with-label => %( :type(Constructor), :returns(N-GObject), :parameters([ Str])),
  new-with-mnemonic => %( :type(Constructor), :returns(N-GObject), :parameters([ Str])),

  #--[Methods]------------------------------------------------------------------
  get-active => %( :returns(gboolean), :cnv-return(Bool)),
  get-inconsistent => %( :returns(gboolean), :cnv-return(Bool)),
  get-label => %( :returns(Str)),
  get-use-underline => %( :returns(gboolean), :cnv-return(Bool)),
  set-active => %( :parameters([gboolean])),
  set-group => %( :parameters([N-GObject])),
  set-inconsistent => %( :parameters([gboolean])),
  set-label => %( :parameters([Str])),
  set-use-underline => %( :parameters([gboolean])),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    if $methods{$name}<type>:exists and $methods{$name}<type> eq 'Constructor' {
      my Gnome::N::GnomeRoutineCaller $routine-caller .= new(
        :library(gtk4-lib()), :sub-prefix<gtk_check_button_>
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
    my $r;
    $r = self.Gnome::Gtk4::R-Actionable::_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments
    );
    return $r if $_fallback-v2-ok;

    callsame;
  }
}
