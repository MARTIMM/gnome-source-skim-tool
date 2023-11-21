# Command to generate: generate.raku -v -d -c Gtk4 shortcutaction
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::GObject::Object:api<2>;
#use Gnome::Glib::N-String:api<2>;
use Gnome::Glib::N-Variant:api<2>;
use Gnome::Gtk4::T-Shortcutaction:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::ShortcutAction:auth<github:MARTIMM>:api<2>;
also is Gnome::GObject::Object;

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
  $!routine-caller .= new(:library('libgtk-4.so.1'));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::ShortcutAction' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkShortcutAction');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  parse-string => %( :type(Constructor), :is-symbol<gtk_shortcut_action_parse_string>, :returns(N-Object), :parameters([ Str])),

  #--[Methods]------------------------------------------------------------------
  activate => %(:is-symbol<gtk_shortcut_action_activate>,  :returns(gboolean), :cnv-return(Bool), :parameters([GFlag, N-Object, N-Variant])),
  #print => %(:is-symbol<gtk_shortcut_action_print>,  :parameters([N-String ])),
  to-string => %(:is-symbol<gtk_shortcut_action_to_string>,  :returns(Str)),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    if $methods{$name}<type>:exists and $methods{$name}<type> eq 'Constructor' {
      my Gnome::N::GnomeRoutineCaller $routine-caller .= new(
        :library('libgtk-4.so.1')
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
