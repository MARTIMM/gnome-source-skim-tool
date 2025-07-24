=comment Package: Gtk4, C-Source: popovermenu
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Gnome::Gtk4::Popover:api<2>;
use Gnome::Gtk4::T-popovermenu:api<2>;
use Gnome::Gtk4::T-enums:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::PopoverMenu:auth<github:MARTIMM>:api<2>;
also is Gnome::Gtk4::Popover;

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
  if self.^name eq 'Gnome::Gtk4::PopoverMenu' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkPopoverMenu');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-from-model => %( :type(Constructor), :is-symbol<gtk_popover_menu_new_from_model>, :returns(N-Object), :parameters([ N-Object]), ),
  new-from-model-full => %( :type(Constructor), :is-symbol<gtk_popover_menu_new_from_model_full>, :returns(N-Object), :parameters([ N-Object, GFlag]), ),

  #--[Methods]------------------------------------------------------------------
  add-child => %(:is-symbol<gtk_popover_menu_add_child>, :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, Str]), ),
  get-flags => %(:is-symbol<gtk_popover_menu_get_flags>,  :returns(GFlag), :cnv-return(GtkPopoverMenuFlags)),
  get-menu-model => %(:is-symbol<gtk_popover_menu_get_menu_model>, :returns(N-Object), ),
  remove-child => %(:is-symbol<gtk_popover_menu_remove_child>, :returns(gboolean), :cnv-return(Bool), :parameters([N-Object]), ),
  set-flags => %(:is-symbol<gtk_popover_menu_set_flags>, :parameters([GFlag]), ),
  set-menu-model => %(:is-symbol<gtk_popover_menu_set_menu_model>, :parameters([N-Object]), ),
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
