=comment Package: Gio, C-Source: permission
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Glib::T-error:api<2>;
use Gnome::GObject::Object:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
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
  $!routine-caller .= new(:library(gio-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gio::Permission' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GPermission');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  acquire => %(:is-symbol<g_permission_acquire>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, CArray[N-Error]])),
  acquire-async => %(:is-symbol<g_permission_acquire_async>,  :parameters([N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  acquire-finish => %(:is-symbol<g_permission_acquire_finish>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, CArray[N-Error]])),
  get-allowed => %(:is-symbol<g_permission_get_allowed>,  :returns(gboolean), :cnv-return(Bool)),
  get-can-acquire => %(:is-symbol<g_permission_get_can_acquire>,  :returns(gboolean), :cnv-return(Bool)),
  get-can-release => %(:is-symbol<g_permission_get_can_release>,  :returns(gboolean), :cnv-return(Bool)),
  impl-update => %(:is-symbol<g_permission_impl_update>,  :parameters([gboolean, gboolean, gboolean])),
  release => %(:is-symbol<g_permission_release>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, CArray[N-Error]])),
  release-async => %(:is-symbol<g_permission_release_async>,  :parameters([N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  release-finish => %(:is-symbol<g_permission_release_finish>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, CArray[N-Error]])),
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
