=comment Package: Gtk4, C-Source: appchooserdialog
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;




use Gnome::Gtk4::Dialog:api<2>;
use Gnome::Gtk4::R-AppChooser:api<2>;
use Gnome::Gtk4::T-dialog:api<2>;
#use Gnome::N:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::AppChooserDialog:auth<github:MARTIMM>:api<2>;
also is Gnome::Gtk4::Dialog;
also does Gnome::Gtk4::R-AppChooser;

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

  Gnome::N::deprecate(
    'Gnome::Gtk4::AppChooserDialog', ', Str, ',
    '4.10', Str,
    :class, :gnome-lib(gtk4-lib())  
  );

  # Add signal administration info.
  unless $signals-added {
    
    # Signals from interfaces
    self._add_gtk_app_chooser_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_app_chooser_signal_types');
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::AppChooserDialog' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkAppChooserDialog');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-appchooserdialog => %( :type(Constructor), :is-symbol<gtk_app_chooser_dialog_new>, :returns(N-Object), :deprecated, :deprecated-version<4.10>, :parameters([ N-Object, GFlag, N-Object]), ),
  new-for-content-type => %( :type(Constructor), :is-symbol<gtk_app_chooser_dialog_new_for_content_type>, :returns(N-Object), :deprecated, :deprecated-version<4.10>, :parameters([ N-Object, GFlag, Str]), ),

  #--[Methods]------------------------------------------------------------------
  get-heading => %(:is-symbol<gtk_app_chooser_dialog_get_heading>, :returns(Str), :deprecated, :deprecated-version<4.10>, ),
  get-widget => %(:is-symbol<gtk_app_chooser_dialog_get_widget>, :returns(N-Object), :deprecated, :deprecated-version<4.10>, ),
  set-heading => %(:is-symbol<gtk_app_chooser_dialog_set_heading>, :parameters([Str]), :deprecated, :deprecated-version<4.10>, ),
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
    my $r;
    my $native-object = self.get-native-object-no-reffing;
    $r = self._do_gtk_app_chooser_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    ) if self.^can('_do_gtk_app_chooser_fallback-v2');
    return $r if $_fallback-v2-ok;

    callsame;
  }
}
