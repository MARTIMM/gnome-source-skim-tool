# Package: Gtk4, C-Source: button
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Gtk4::R-Actionable:api<2>;
use Gnome::Gtk4::Widget:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::Button:auth<github:MARTIMM>:api<2>;
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
      :w0<activate clicked>,
    );

    # Signals from interfaces
    self._add_gtk_actionable_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_actionable_signal_types');
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::Button' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkButton');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-button => %( :type(Constructor), :is-symbol<gtk_button_new>, :returns(N-Object), ),
  new-from-icon-name => %( :type(Constructor), :is-symbol<gtk_button_new_from_icon_name>, :returns(N-Object), :parameters([ Str])),
  new-with-label => %( :type(Constructor), :is-symbol<gtk_button_new_with_label>, :returns(N-Object), :parameters([ Str])),
  new-with-mnemonic => %( :type(Constructor), :is-symbol<gtk_button_new_with_mnemonic>, :returns(N-Object), :parameters([ Str])),

  #--[Methods]------------------------------------------------------------------
  get-child => %(:is-symbol<gtk_button_get_child>,  :returns(N-Object)),
  get-has-frame => %(:is-symbol<gtk_button_get_has_frame>,  :returns(gboolean), :cnv-return(Bool)),
  get-icon-name => %(:is-symbol<gtk_button_get_icon_name>,  :returns(Str)),
  get-label => %(:is-symbol<gtk_button_get_label>,  :returns(Str)),
  get-use-underline => %(:is-symbol<gtk_button_get_use_underline>,  :returns(gboolean), :cnv-return(Bool)),
  set-child => %(:is-symbol<gtk_button_set_child>,  :parameters([N-Object])),
  set-has-frame => %(:is-symbol<gtk_button_set_has_frame>,  :parameters([gboolean])),
  set-icon-name => %(:is-symbol<gtk_button_set_icon_name>,  :parameters([Str])),
  set-label => %(:is-symbol<gtk_button_set_label>,  :parameters([Str])),
  set-use-underline => %(:is-symbol<gtk_button_set_use_underline>,  :parameters([gboolean])),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    if $methods{$name}<type>:exists and $methods{$name}<type> eq 'Constructor' {
      my Gnome::N::GnomeRoutineCaller $routine-caller .= new(
        :library(gtk4-lib())
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
    my $r;
    my $native-object = self.get-native-object-no-reffing;
    $r = self.Gnome::Gtk4::R-Actionable::_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    );
    return $r if $_fallback-v2-ok;

    callsame;
  }
}
