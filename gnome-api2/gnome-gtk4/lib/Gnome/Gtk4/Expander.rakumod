=comment Package: Gtk4, C-Source: expander
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Cairo;


use Gnome::Gtk4::Widget:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::Expander:auth<github:MARTIMM>:api<2>;
also is Gnome::Gtk4::Widget;

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
      :w0<activate>,
    );
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::Expander' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkExpander');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-expander => %( :type(Constructor), :is-symbol<gtk_expander_new>, :returns(N-Object), :parameters([ Str]), ),
  new-with-mnemonic => %( :type(Constructor), :is-symbol<gtk_expander_new_with_mnemonic>, :returns(N-Object), :parameters([ Str]), ),

  #--[Methods]------------------------------------------------------------------
  get-child => %(:is-symbol<gtk_expander_get_child>, :returns(N-Object), ),
  get-expanded => %(:is-symbol<gtk_expander_get_expanded>, :returns(gboolean), :cnv-return(Bool), ),
  get-label => %(:is-symbol<gtk_expander_get_label>, :returns(Str), ),
  get-label-widget => %(:is-symbol<gtk_expander_get_label_widget>, :returns(N-Object), ),
  get-resize-toplevel => %(:is-symbol<gtk_expander_get_resize_toplevel>, :returns(gboolean), :cnv-return(Bool), ),
  get-use-markup => %(:is-symbol<gtk_expander_get_use_markup>, :returns(gboolean), :cnv-return(Bool), ),
  get-use-underline => %(:is-symbol<gtk_expander_get_use_underline>, :returns(gboolean), :cnv-return(Bool), ),
  set-child => %(:is-symbol<gtk_expander_set_child>, :parameters([N-Object]), ),
  set-expanded => %(:is-symbol<gtk_expander_set_expanded>, :parameters([gboolean]), ),
  set-label => %(:is-symbol<gtk_expander_set_label>, :parameters([Str]), ),
  set-label-widget => %(:is-symbol<gtk_expander_set_label_widget>, :parameters([N-Object]), ),
  set-resize-toplevel => %(:is-symbol<gtk_expander_set_resize_toplevel>, :parameters([gboolean]), ),
  set-use-markup => %(:is-symbol<gtk_expander_set_use_markup>, :parameters([gboolean]), ),
  set-use-underline => %(:is-symbol<gtk_expander_set_use_underline>, :parameters([gboolean]), ),
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
