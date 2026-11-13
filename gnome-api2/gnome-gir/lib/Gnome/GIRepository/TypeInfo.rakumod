=comment Package: GIRepo, C-Source: gitypeinfo
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;



use Gnome::GIRepository::BaseInfo:api<2>;
use Gnome::GIRepository::N-Argument:api<2>;
#use Gnome::GIRepository::T-Argument:api<2>;
use Gnome::GIRepository::T-types:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::GIRepository::TypeInfo:auth<github:MARTIMM>:api<2>;
also is Gnome::GIRepository::BaseInfo;

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
  if self.^name eq 'Gnome::GIRepository::TypeInfo' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GITypeInfo');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  argument-from-hash-pointer => %(:is-symbol<gi_type_info_argument_from_hash_pointer>, :parameters([void-ptr, N-Object]), ),
  get-array-fixed-size => %(:is-symbol<gi_type_info_get_array_fixed_size>, :returns(gboolean), :cnv-return(Bool), :parameters([gsize-ptr]), ),
  get-array-length-index => %(:is-symbol<gi_type_info_get_array_length_index>, :returns(gboolean), :cnv-return(Bool), :parameters([gint-ptr]), ),
  get-array-type => %(:is-symbol<gi_type_info_get_array_type>,  :returns(GEnum), :cnv-return(GIArrayType)),
  get-interface => %(:is-symbol<gi_type_info_get_interface>, :returns(N-Object), ),
  get-param-type => %(:is-symbol<gi_type_info_get_param_type>, :returns(N-Object), :parameters([guint]), ),
  get-storage-type => %(:is-symbol<gi_type_info_get_storage_type>,  :returns(GEnum), :cnv-return(GITypeTag)),
  get-tag => %(:is-symbol<gi_type_info_get_tag>,  :returns(GEnum), :cnv-return(GITypeTag)),
  hash-pointer-from-argument => %(:is-symbol<gi_type_info_hash_pointer_from_argument>, :returns(void-ptr), :parameters([N-Object]), ),
  is-pointer => %(:is-symbol<gi_type_info_is_pointer>, :returns(gboolean), :cnv-return(Bool), ),
  is-zero-terminated => %(:is-symbol<gi_type_info_is_zero_terminated>, :returns(gboolean), :cnv-return(Bool), ),
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
