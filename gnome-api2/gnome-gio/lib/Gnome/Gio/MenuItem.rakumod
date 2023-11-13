# Command to generate: generate.raku -v -c Gio io
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::GObject::Object:api<2>;
use Gnome::Glib::N-Variant:api<2>;
use Gnome::Glib::N-VariantType:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gio::MenuItem:auth<github:MARTIMM>:api<2>;
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
  $!routine-caller .= new( :library(gio-lib()), :sub-prefix<g_menu_item_>);

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gio::MenuItem' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    die X::Gnome.new(:message("Native object not defined"))
      unless self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GMenuItem');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-menuitem => %( :type(Constructor), :isnew, :returns(N-Object), :parameters([ Str, Str])),
  new-from-model => %( :type(Constructor), :returns(N-Object), :parameters([ N-Object, gint])),
  new-section => %( :type(Constructor), :returns(N-Object), :parameters([ Str, N-Object])),
  new-submenu => %( :type(Constructor), :returns(N-Object), :parameters([ Str, N-Object])),

  #--[Methods]------------------------------------------------------------------
  #get-attribute => %(:variable-list,  :returns(gboolean), :cnv-return(Bool), :parameters([Str, Str])),
  get-attribute-value => %( :returns(N-Variant), :parameters([Str, N-VariantType])),
  get-link => %( :returns(N-Object), :parameters([Str])),
  #set-action-and-target => %(:variable-list,  :parameters([Str, Str])),
  set-action-and-target-value => %( :parameters([Str, N-Variant])),
  #set-attribute => %(:variable-list,  :parameters([Str, Str])),
  set-attribute-value => %( :parameters([Str, N-Variant])),
  set-detailed-action => %( :parameters([Str])),
  set-icon => %( :parameters([N-Object])),
  set-label => %( :parameters([Str])),
  set-link => %( :parameters([Str, N-Object])),
  set-section => %( :parameters([N-Object])),
  set-submenu => %( :parameters([N-Object])),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    if $methods{$name}<type>:exists and $methods{$name}<type> eq 'Constructor' {
      my Gnome::N::GnomeRoutineCaller $routine-caller .= new(
        :library(gio-lib()), :sub-prefix<g_menu_item_>
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
