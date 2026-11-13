=comment Package: GIRepo, C-Source: giinterfaceinfo
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;



use Gnome::GIRepository::RegisteredTypeInfo:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::GIRepository::InterfaceInfo:auth<github:MARTIMM>:api<2>;
also is Gnome::GIRepository::RegisteredTypeInfo;

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
  $!routine-caller .= new(:library(girepository-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::GIRepository::InterfaceInfo' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GIInterfaceInfo');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  find-method => %(:is-symbol<gi_interface_info_find_method>, :returns(N-Object), :parameters([Str]), ),
  find-signal => %(:is-symbol<gi_interface_info_find_signal>, :returns(N-Object), :parameters([Str]), ),
  find-vfunc => %(:is-symbol<gi_interface_info_find_vfunc>, :returns(N-Object), :parameters([Str]), ),
  get-constant => %(:is-symbol<gi_interface_info_get_constant>, :returns(N-Object), :parameters([guint]), ),
  get-iface-struct => %(:is-symbol<gi_interface_info_get_iface_struct>, :returns(N-Object), ),
  get-method => %(:is-symbol<gi_interface_info_get_method>, :returns(N-Object), :parameters([guint]), ),
  get-n-constants => %(:is-symbol<gi_interface_info_get_n_constants>, :returns(guint), ),
  get-n-methods => %(:is-symbol<gi_interface_info_get_n_methods>, :returns(guint), ),
  get-n-prerequisites => %(:is-symbol<gi_interface_info_get_n_prerequisites>, :returns(guint), ),
  get-n-properties => %(:is-symbol<gi_interface_info_get_n_properties>, :returns(guint), ),
  get-n-signals => %(:is-symbol<gi_interface_info_get_n_signals>, :returns(guint), ),
  get-n-vfuncs => %(:is-symbol<gi_interface_info_get_n_vfuncs>, :returns(guint), ),
  get-prerequisite => %(:is-symbol<gi_interface_info_get_prerequisite>, :returns(N-Object), :parameters([guint]), ),
  get-property => %(:is-symbol<gi_interface_info_get_property>, :returns(N-Object), :parameters([guint]), ),
  get-signal => %(:is-symbol<gi_interface_info_get_signal>, :returns(N-Object), :parameters([guint]), ),
  get-vfunc => %(:is-symbol<gi_interface_info_get_vfunc>, :returns(N-Object), :parameters([guint]), ),
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
        :library(girepository-lib())
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
