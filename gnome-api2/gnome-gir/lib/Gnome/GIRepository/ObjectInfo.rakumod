=comment Package: GIRepo, C-Source: giobjectinfo
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

unit class Gnome::GIRepository::ObjectInfo:auth<github:MARTIMM>:api<2>;
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
  if self.^name eq 'Gnome::GIRepository::ObjectInfo' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GIObjectInfo');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  find-method => %(:is-symbol<gi_repository_find_method>, :returns(N-Object), :parameters([Str]), ),
  find-method-using-interfaces => %(:is-symbol<gi_repository_find_method_using_interfaces>, :returns(N-Object), :parameters([Str, CArray[N-Object]]), ),
  find-signal => %(:is-symbol<gi_repository_find_signal>, :returns(N-Object), :parameters([Str]), ),
  find-vfunc => %(:is-symbol<gi_repository_find_vfunc>, :returns(N-Object), :parameters([Str]), ),
  find-vfunc-using-interfaces => %(:is-symbol<gi_repository_find_vfunc_using_interfaces>, :returns(N-Object), :parameters([Str, CArray[N-Object]]), ),
  get-abstract => %(:is-symbol<gi_repository_get_abstract>, :returns(gboolean), :cnv-return(Bool), ),
  get-class-struct => %(:is-symbol<gi_repository_get_class_struct>, :returns(N-Object), ),
  get-constant => %(:is-symbol<gi_repository_get_constant>, :returns(N-Object), :parameters([guint-ptr]), ),
  get-field => %(:is-symbol<gi_repository_get_field>, :returns(N-Object), :parameters([guint-ptr]), ),
  get-final => %(:is-symbol<gi_repository_get_final>, :returns(gboolean), :cnv-return(Bool), ),
  get-fundamental => %(:is-symbol<gi_repository_get_fundamental>, :returns(gboolean), :cnv-return(Bool), ),
  get-get-value-function-name => %(:is-symbol<gi_repository_get_get_value_function_name>, :returns(Str), ),
  #get-get-value-function-pointer => %(:is-symbol<gi_repository_get_get_value_function_pointer>, ),
  get-interface => %(:is-symbol<gi_repository_get_interface>, :returns(N-Object), :parameters([guint-ptr]), ),
  get-method => %(:is-symbol<gi_repository_get_method>, :returns(N-Object), :parameters([guint-ptr]), ),
  get-n-constants => %(:is-symbol<gi_repository_get_n_constants>, :returns(guint-ptr), ),
  get-n-fields => %(:is-symbol<gi_repository_get_n_fields>, :returns(guint-ptr), ),
  get-n-interfaces => %(:is-symbol<gi_repository_get_n_interfaces>, :returns(guint-ptr), ),
  get-n-methods => %(:is-symbol<gi_repository_get_n_methods>, :returns(guint-ptr), ),
  get-n-properties => %(:is-symbol<gi_repository_get_n_properties>, :returns(guint-ptr), ),
  get-n-signals => %(:is-symbol<gi_repository_get_n_signals>, :returns(guint-ptr), ),
  get-n-vfuncs => %(:is-symbol<gi_repository_get_n_vfuncs>, :returns(guint-ptr), ),
  get-parent => %(:is-symbol<gi_repository_get_parent>, :returns(N-Object), ),
  get-property => %(:is-symbol<gi_repository_get_property>, :returns(N-Object), :parameters([guint-ptr]), ),
  get-ref-function-name => %(:is-symbol<gi_repository_get_ref_function_name>, :returns(Str), ),
  #get-ref-function-pointer => %(:is-symbol<gi_repository_get_ref_function_pointer>, ),
  get-set-value-function-name => %(:is-symbol<gi_repository_get_set_value_function_name>, :returns(Str), ),
  #get-set-value-function-pointer => %(:is-symbol<gi_repository_get_set_value_function_pointer>, ),
  get-signal => %(:is-symbol<gi_repository_get_signal>, :returns(N-Object), :parameters([guint-ptr]), ),
  get-type-init-function-name => %(:is-symbol<gi_repository_get_type_init_function_name>, :returns(Str), ),
  get-type-name => %(:is-symbol<gi_repository_get_type_name>, :returns(Str), ),
  get-unref-function-name => %(:is-symbol<gi_repository_get_unref_function_name>, :returns(Str), ),
  #get-unref-function-pointer => %(:is-symbol<gi_repository_get_unref_function_pointer>, ),
  get-vfunc => %(:is-symbol<gi_repository_get_vfunc>, :returns(N-Object), :parameters([guint-ptr]), ),
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
