=comment Package: Gtk4, C-Source: listitem
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;




use Gnome::GObject::Object:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::ListItem:auth<github:MARTIMM>:api<2>;
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
  if self.^name eq 'Gnome::Gtk4::ListItem' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkListItem');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  get-accessible-description => %(:is-symbol<gtk_list_item_get_accessible_description>, :returns(Str), ),
  get-accessible-label => %(:is-symbol<gtk_list_item_get_accessible_label>, :returns(Str), ),
  get-activatable => %(:is-symbol<gtk_list_item_get_activatable>, :returns(gboolean), :cnv-return(Bool), ),
  get-child => %(:is-symbol<gtk_list_item_get_child>, :returns(N-Object), ),
  get-focusable => %(:is-symbol<gtk_list_item_get_focusable>, :returns(gboolean), :cnv-return(Bool), ),
  get-item => %(:is-symbol<gtk_list_item_get_item>, :returns(gpointer), ),
  get-position => %(:is-symbol<gtk_list_item_get_position>, :returns(guint), ),
  get-selectable => %(:is-symbol<gtk_list_item_get_selectable>, :returns(gboolean), :cnv-return(Bool), ),
  get-selected => %(:is-symbol<gtk_list_item_get_selected>, :returns(gboolean), :cnv-return(Bool), ),
  set-accessible-description => %(:is-symbol<gtk_list_item_set_accessible_description>, :parameters([Str]), ),
  set-accessible-label => %(:is-symbol<gtk_list_item_set_accessible_label>, :parameters([Str]), ),
  set-activatable => %(:is-symbol<gtk_list_item_set_activatable>, :parameters([gboolean]), ),
  set-child => %(:is-symbol<gtk_list_item_set_child>, :parameters([N-Object]), ),
  set-focusable => %(:is-symbol<gtk_list_item_set_focusable>, :parameters([gboolean]), ),
  set-selectable => %(:is-symbol<gtk_list_item_set_selectable>, :parameters([gboolean]), ),
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
