=comment Package: Gtk4, C-Source: messagedialog
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;




use Gnome::Gtk4::Dialog:api<2>;
use Gnome::Gtk4::T-dialog:api<2>;
use Gnome::Gtk4::T-enums:api<2>;
use Gnome::Gtk4::T-messagedialog:api<2>;
#use Gnome::N:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::MessageDialog:auth<github:MARTIMM>:api<2>;
also is Gnome::Gtk4::Dialog;

#-------------------------------------------------------------------------------
#--[BUILD variables]------------------------------------------------------------
#-------------------------------------------------------------------------------

# Define callable helper
has Gnome::N::GnomeRoutineCaller $!routine-caller;

#-------------------------------------------------------------------------------
#--[BUILD submethod]------------------------------------------------------------
#-------------------------------------------------------------------------------

submethod BUILD ( *%options ) {

  Gnome::N::deprecate(
    'Gnome::Gtk4::MessageDialog', ', Str, ',
    '4.10', Str,
    :class, :gnome-lib(gtk4-lib())  
  );


  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::MessageDialog' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkMessageDialog');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-messagedialog => %( :type(Constructor), :is-symbol<gtk_message_dialog_new>, :returns(N-Object), :deprecated, :deprecated-version<4.10>, :variable-list, :parameters([ N-Object, GFlag, GEnum, GEnum, Str]), ),
  new-with-markup => %( :type(Constructor), :is-symbol<gtk_message_dialog_new_with_markup>, :returns(N-Object), :deprecated, :deprecated-version<4.10>, :variable-list, :parameters([ N-Object, GFlag, GEnum, GEnum, Str]), ),

  #--[Methods]------------------------------------------------------------------
  format-secondary-markup => %(:is-symbol<gtk_message_dialog_format_secondary_markup>, :variable-list, :parameters([Str]), :deprecated, :deprecated-version<4.10>, ),
  format-secondary-text => %(:is-symbol<gtk_message_dialog_format_secondary_text>, :variable-list, :parameters([Str]), :deprecated, :deprecated-version<4.10>, ),
  get-message-area => %(:is-symbol<gtk_message_dialog_get_message_area>, :returns(N-Object), :deprecated, :deprecated-version<4.10>, ),
  set-markup => %(:is-symbol<gtk_message_dialog_set_markup>, :parameters([Str]), :deprecated, :deprecated-version<4.10>, ),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 (
  Str $name, Bool $_fallback-v2-ok is rw, *@arguments, *%options
) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    if $methods{$name}<type>:exists and $methods{$name}<type> eq 'Constructor' {
      my Gnome::N::GnomeRoutineCaller $routine-caller .= new(
        :library(gtk4-lib())
      );

      return self.bless(
        :native-object(
          $routine-caller.call-native-sub( $name, @arguments, $methods)
        ),
        |%options
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
