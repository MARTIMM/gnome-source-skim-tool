=comment Package: Gtk4, C-Source: listbox
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

unit class Gnome::Gtk4::ListBoxRow:auth<github:MARTIMM>:api<2>;
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
      :w0<activate>,
    );

    # Signals from interfaces
    self._add_gtk_actionable_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_actionable_signal_types');
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::ListBoxRow' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkListBoxRow');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-listboxrow => %( :type(Constructor), :is-symbol<gtk_list_box_row_new>, :returns(N-Object), ),

  #--[Methods]------------------------------------------------------------------
  changed => %(:is-symbol<gtk_list_box_row_changed>, ),
  get-activatable => %(:is-symbol<gtk_list_box_row_get_activatable>,  :returns(gboolean), :cnv-return(Bool)),
  get-child => %(:is-symbol<gtk_list_box_row_get_child>,  :returns(N-Object)),
  get-header => %(:is-symbol<gtk_list_box_row_get_header>,  :returns(N-Object)),
  get-index => %(:is-symbol<gtk_list_box_row_get_index>,  :returns(gint)),
  get-selectable => %(:is-symbol<gtk_list_box_row_get_selectable>,  :returns(gboolean), :cnv-return(Bool)),
  is-selected => %(:is-symbol<gtk_list_box_row_is_selected>,  :returns(gboolean), :cnv-return(Bool)),
  set-activatable => %(:is-symbol<gtk_list_box_row_set_activatable>,  :parameters([gboolean])),
  set-child => %(:is-symbol<gtk_list_box_row_set_child>,  :parameters([N-Object])),
  set-header => %(:is-symbol<gtk_list_box_row_set_header>,  :parameters([N-Object])),
  set-selectable => %(:is-symbol<gtk_list_box_row_set_selectable>,  :parameters([gboolean])),
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
    $r = self._do_gtk_actionable_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    ) if self.^can('_do_gtk_actionable_fallback-v2');
    return $r if $_fallback-v2-ok;

    callsame;
  }
}
