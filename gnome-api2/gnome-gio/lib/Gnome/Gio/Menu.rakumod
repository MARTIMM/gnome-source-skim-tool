# Command to generate: generate.raku -v -c Gio io
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Gio::MenuModel:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-GObject:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gio::Menu:auth<github:MARTIMM>:api<2>;
#also is Gnome::Gio::MenuModel;

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
  $!routine-caller .= new( :library(gio-lib()), :sub-prefix<g_menu_>);

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gio::Menu' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    die X::Gnome.new(:message("Native object not defined"))
      unless self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GMenu');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-menu => %( :type(Constructor), :isnew, :returns(N-GObject), ),

  #--[Methods]------------------------------------------------------------------
  append => %( :parameters([Str, Str])),
  append-item => %( :parameters([N-GObject])),
  append-section => %( :parameters([Str, N-GObject])),
  append-submenu => %( :parameters([Str, N-GObject])),
  freeze => %(),
  insert => %( :parameters([gint, Str, Str])),
  insert-item => %( :parameters([gint, N-GObject])),
  insert-section => %( :parameters([gint, Str, N-GObject])),
  insert-submenu => %( :parameters([gint, Str, N-GObject])),
  prepend => %( :parameters([Str, Str])),
  prepend-item => %( :parameters([N-GObject])),
  prepend-section => %( :parameters([Str, N-GObject])),
  prepend-submenu => %( :parameters([Str, N-GObject])),
  remove => %( :parameters([gint])),
  remove-all => %(),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    if $methods{$name}<type>:exists and $methods{$name}<type> eq 'Constructor' {
      my Gnome::N::GnomeRoutineCaller $routine-caller .= new(
        :library(gio-lib()), :sub-prefix<g_menu_>
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
