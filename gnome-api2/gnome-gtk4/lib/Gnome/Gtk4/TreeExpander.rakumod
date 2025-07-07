=comment Package: Gtk4, C-Source: treeexpander
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

unit class Gnome::Gtk4::TreeExpander:auth<github:MARTIMM>:api<2>;
also is Gnome::Gtk4::Widget;

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
  if self.^name eq 'Gnome::Gtk4::TreeExpander' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkTreeExpander');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-treeexpander => %( :type(Constructor), :is-symbol<gtk_tree_expander_new>, :returns(N-Object), ),

  #--[Methods]------------------------------------------------------------------
  get-child => %(:is-symbol<gtk_tree_expander_get_child>, :returns(N-Object), ),
  get-hide-expander => %(:is-symbol<gtk_tree_expander_get_hide_expander>, :returns(gboolean), ),
  get-indent-for-depth => %(:is-symbol<gtk_tree_expander_get_indent_for_depth>, :returns(gboolean), ),
  get-indent-for-icon => %(:is-symbol<gtk_tree_expander_get_indent_for_icon>, :returns(gboolean), ),
  get-item => %(:is-symbol<gtk_tree_expander_get_item>, :returns(gpointer), ),
  get-list-row => %(:is-symbol<gtk_tree_expander_get_list_row>, :returns(N-Object), ),
  set-child => %(:is-symbol<gtk_tree_expander_set_child>, :parameters([N-Object]), ),
  set-hide-expander => %(:is-symbol<gtk_tree_expander_set_hide_expander>, :parameters([gboolean]), ),
  set-indent-for-depth => %(:is-symbol<gtk_tree_expander_set_indent_for_depth>, :parameters([gboolean]), ),
  set-indent-for-icon => %(:is-symbol<gtk_tree_expander_set_indent_for_icon>, :parameters([gboolean]), ),
  set-list-row => %(:is-symbol<gtk_tree_expander_set_list_row>, :parameters([N-Object]), ),
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
