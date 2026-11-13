=comment Package: GIRepo, C-Source: gistructinfo
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

unit class Gnome::GIRepository::StructInfo:auth<github:MARTIMM>:api<2>;
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
  if self.^name eq 'Gnome::GIRepository::StructInfo' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GIStructInfo');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  find-field => %(:is-symbol<gi_struct_info_find_field>, :returns(N-Object), :parameters([Str]), ),
  find-method => %(:is-symbol<gi_struct_info_find_method>, :returns(N-Object), :parameters([Str]), ),
  get-alignment => %(:is-symbol<gi_struct_info_get_alignment>, :returns(gsize), ),
  get-copy-function-name => %(:is-symbol<gi_struct_info_get_copy_function_name>, :returns(Str), ),
  get-field => %(:is-symbol<gi_struct_info_get_field>, :returns(N-Object), :parameters([guint]), ),
  get-free-function-name => %(:is-symbol<gi_struct_info_get_free_function_name>, :returns(Str), ),
  get-method => %(:is-symbol<gi_struct_info_get_method>, :returns(N-Object), :parameters([guint]), ),
  get-n-fields => %(:is-symbol<gi_struct_info_get_n_fields>, :returns(guint), ),
  get-n-methods => %(:is-symbol<gi_struct_info_get_n_methods>, :returns(guint), ),
  get-size => %(:is-symbol<gi_struct_info_get_size>, :returns(gsize), ),
  is-foreign => %(:is-symbol<gi_struct_info_is_foreign>, :returns(gboolean), :cnv-return(Bool), ),
  is-gtype-struct => %(:is-symbol<gi_struct_info_is_gtype_struct>, :returns(gboolean), :cnv-return(Bool), ),
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
