=comment Package: Gio, C-Source: io
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::GObject::Object:api<2>;
use Gnome::Gio::R-Action:api<2>;
use Gnome::Glib::N-Variant:api<2>;
use Gnome::Glib::N-VariantType:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gio::SimpleAction:auth<github:MARTIMM>:api<2>;
also is Gnome::GObject::Object;
also does Gnome::Gio::R-Action;

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
      :w1<activate change-state>,
    );

    # Signals from interfaces
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gio-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gio::SimpleAction' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GSimpleAction');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-simpleaction => %( :type(Constructor), :is-symbol<g_simple_action_new>, :returns(N-Object), :parameters([ Str, N-VariantType])),
  new-stateful => %( :type(Constructor), :is-symbol<g_simple_action_new_stateful>, :returns(N-Object), :parameters([ Str, N-VariantType, N-Variant])),

  #--[Methods]------------------------------------------------------------------
  set-enabled => %(:is-symbol<g_simple_action_set_enabled>,  :parameters([gboolean])),
  set-state => %(:is-symbol<g_simple_action_set_state>,  :parameters([N-Variant])),
  set-state-hint => %(:is-symbol<g_simple_action_set_state_hint>,  :parameters([N-Variant])),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    if $methods{$name}<type>:exists and $methods{$name}<type> eq 'Constructor' {
      my Gnome::N::GnomeRoutineCaller $routine-caller .= new(
        :library(gio-lib())
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
    $r = self.Gnome::Gio::R-Action::_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    );
    return $r if $_fallback-v2-ok;

    callsame;
  }
}
