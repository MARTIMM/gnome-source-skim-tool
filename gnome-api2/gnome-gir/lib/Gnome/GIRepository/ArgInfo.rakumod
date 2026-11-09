=comment Package: GIRepo, C-Source: giarginfo
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;



use Gnome::GIRepository::BaseInfo:api<2>;
use Gnome::GIRepository::T-types:api<2>;

use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::GIRepository::ArgInfo:auth<github:MARTIMM>:api<2>;
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
  if self.^name eq 'Gnome::GIRepository::ArgInfo' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GIArgInfo');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  get-closure-index => %(:is-symbol<gi_repository_get_closure_index>, :returns(gboolean), :cnv-return(Bool), :parameters([gint-ptr]), ),
  get-destroy-index => %(:is-symbol<gi_repository_get_destroy_index>, :returns(gboolean), :cnv-return(Bool), :parameters([gint-ptr]), ),
  get-direction => %(:is-symbol<gi_repository_get_direction>,  :returns(GEnum), :cnv-return(GIDirection )),
  get-ownership-transfer => %(:is-symbol<gi_repository_get_ownership_transfer>,  :returns(GEnum), :cnv-return(GITransfer )),
  get-scope => %(:is-symbol<gi_repository_get_scope>,  :returns(GEnum), :cnv-return(GIScopeType )),
  get-type-info => %(:is-symbol<gi_repository_get_type_info>, :returns(N-Object), ),
  is-caller-allocates => %(:is-symbol<gi_repository_is_caller_allocates>, :returns(gboolean), :cnv-return(Bool), ),
  is-optional => %(:is-symbol<gi_repository_is_optional>, :returns(gboolean), :cnv-return(Bool), ),
  is-return-value => %(:is-symbol<gi_repository_is_return_value>, :returns(gboolean), :cnv-return(Bool), ),
  is-skip => %(:is-symbol<gi_repository_is_skip>, :returns(gboolean), :cnv-return(Bool), ),
  load-type-info => %(:is-symbol<gi_repository_load_type_info>, :parameters([N-Object]), ),
  may-be-null => %(:is-symbol<gi_repository_may_be_null>, :returns(gboolean), :cnv-return(Bool), ),
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
