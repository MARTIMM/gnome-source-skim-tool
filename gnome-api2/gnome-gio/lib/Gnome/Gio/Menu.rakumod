=comment Package: Gio, C-Source: io
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Gio::MenuModel:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gio::Menu:auth<github:MARTIMM>:api<2>;
also is Gnome::Gio::MenuModel;

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
  $!routine-caller .= new(:library(gio-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gio::Menu' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GMenu');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-menu => %( :type(Constructor), :is-symbol<g_menu_new>, :returns(N-Object), ),

  #--[Methods]------------------------------------------------------------------
  append => %(:is-symbol<g_menu_append>,  :parameters([Str, Str])),
  append-item => %(:is-symbol<g_menu_append_item>,  :parameters([N-Object])),
  append-section => %(:is-symbol<g_menu_append_section>,  :parameters([Str, N-Object])),
  append-submenu => %(:is-symbol<g_menu_append_submenu>,  :parameters([Str, N-Object])),
  freeze => %(:is-symbol<g_menu_freeze>, ),
  insert => %(:is-symbol<g_menu_insert>,  :parameters([gint, Str, Str])),
  insert-item => %(:is-symbol<g_menu_insert_item>,  :parameters([gint, N-Object])),
  insert-section => %(:is-symbol<g_menu_insert_section>,  :parameters([gint, Str, N-Object])),
  insert-submenu => %(:is-symbol<g_menu_insert_submenu>,  :parameters([gint, Str, N-Object])),
  prepend => %(:is-symbol<g_menu_prepend>,  :parameters([Str, Str])),
  prepend-item => %(:is-symbol<g_menu_prepend_item>,  :parameters([N-Object])),
  prepend-section => %(:is-symbol<g_menu_prepend_section>,  :parameters([Str, N-Object])),
  prepend-submenu => %(:is-symbol<g_menu_prepend_submenu>,  :parameters([Str, N-Object])),
  remove => %(:is-symbol<g_menu_remove>,  :parameters([gint])),
  remove-all => %(:is-symbol<g_menu_remove_all>, ),
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
    callsame;
  }
}
