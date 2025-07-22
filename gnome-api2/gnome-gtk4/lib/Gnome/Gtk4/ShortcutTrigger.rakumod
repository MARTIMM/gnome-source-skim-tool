=comment Package: Gtk4, C-Source: shortcuttrigger
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Cairo;


use Gnome::GObject::Object:api<2>;
#use Gnome::Gdk4::T-events:api<2>;
#use Gnome::Glib::N-String:api<2>;
#use Gnome::Glib::T-string:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::ShortcutTrigger:auth<github:MARTIMM>:api<2>;
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
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::ShortcutTrigger' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkShortcutTrigger');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  parse-string => %( :type(Constructor), :is-symbol<gtk_shortcut_trigger_parse_string>, :returns(N-Object), :parameters([ Str]), ),

  #--[Methods]------------------------------------------------------------------
  compare => %(:is-symbol<gtk_shortcut_trigger_compare>, :returns(gint), :parameters([gpointer]), ),
  equal => %(:is-symbol<gtk_shortcut_trigger_equal>, :returns(gboolean), :cnv-return(Bool), :parameters([gpointer]), ),
  hash => %(:is-symbol<gtk_shortcut_trigger_hash>, :returns(guint), ),
  print => %(:is-symbol<gtk_shortcut_trigger_print>, :parameters([N-Object]), ),
  print-label => %(:is-symbol<gtk_shortcut_trigger_print_label>, :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, N-Object]), ),
  to-label => %(:is-symbol<gtk_shortcut_trigger_to_label>, :returns(Str), :parameters([N-Object]), ),
  to-string => %(:is-symbol<gtk_shortcut_trigger_to_string>, :returns(Str), ),
  #trigger => %(:is-symbol<gtk_shortcut_trigger_trigger>,  :returns(GEnum), :cnv-return(GdkKeyMatch ),:parameters([N-Object, gboolean]), ),
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
