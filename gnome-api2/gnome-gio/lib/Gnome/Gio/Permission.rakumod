# Command to generate: generate.raku -v -c -t Gio permission
use v6;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Gnome::Glib::Error;

use Gnome::GObject::Object:api<2>;

use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-GObject:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gio::Permission:auth<github:MARTIMM>:api<2>;
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
  $!routine-caller .= new( :library(gio-lib()), :sub-prefix<g_permission_>);

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gio::Permission' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    die X::Gnome.new(:message("Native object not defined"))
      unless self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GPermission');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  acquire => %( :returns(gboolean), :cnv-return(Bool), :parameters([ N-GObject, CArray[N-GError]])),
  #acquire-async => %( :parameters([N-GObject, :( N-GObject, N-GObject, gpointer ), gpointer])),
  acquire-finish => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-GObject])),
  get-allowed => %( :returns(gboolean), :cnv-return(Bool)),
  get-can-acquire => %( :returns(gboolean), :cnv-return(Bool)),
  get-can-release => %( :returns(gboolean), :cnv-return(Bool)),
  impl-update => %( :parameters([gboolean, gboolean, gboolean])),
  release => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-GObject, CArray[N-GError]])),
  #release-async => %( :parameters([N-GObject, :( N-GObject, N-GObject, gpointer ), gpointer])),
  release-finish => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-GObject])),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    if $methods{$name}<type>:exists and $methods{$name}<type> eq 'Constructor' {
      my Gnome::N::GnomeRoutineCaller $routine-caller .= new(
        :library(gio-lib()), :sub-prefix<g_permission_>
      );

      # Check the function name. 
      return self.bless(
        :native-object(
          $routine-caller.call-native-sub( $name, @arguments, $methods)
        )
      );
    }

    else {
      my $native-object = self.get-native-object-no-reffing;
      return $!routine-caller.call-native-sub(
        $name, @arguments, $methods, :$native-object
      );
    }
  }

  else {
    callsame;
  }
}
