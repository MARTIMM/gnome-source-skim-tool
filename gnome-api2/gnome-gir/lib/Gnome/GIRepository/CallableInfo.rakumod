=comment Package: GIRepo, C-Source: gicallableinfo
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Gnome::GIRepository::BaseInfo:api<2>;
#use Gnome::GIRepository::N-Argument:api<2>;
#use Gnome::GIRepository::N-AttributeIter:api<2>;
#use Gnome::GIRepository::T-Argument:api<2>;
#use Gnome::GIRepository::T-gibaseinfo:api<2>;
use Gnome::GIRepository::T-types:api<2>;

use Gnome::Glib::T-error:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::GIRepository::CallableInfo:auth<github:MARTIMM>:api<2>;
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
  if self.^name eq 'Gnome::GIRepository::CallableInfo' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GICallableInfo');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  can-throw-gerror => %(:is-symbol<gi_repository_can_throw_gerror>, :returns(gboolean), :cnv-return(Bool), ),
  get-arg => %(:is-symbol<gi_repository_get_arg>, :returns(N-Object), :parameters([guint-ptr]), ),
  get-async-function => %(:is-symbol<gi_repository_get_async_function>, :returns(N-Object), ),
  get-caller-owns => %(:is-symbol<gi_repository_get_caller_owns>,  :returns(GEnum), :cnv-return(GITransfer )),
  get-finish-function => %(:is-symbol<gi_repository_get_finish_function>, :returns(N-Object), ),
  get-instance-ownership-transfer => %(:is-symbol<gi_repository_get_instance_ownership_transfer>,  :returns(GEnum), :cnv-return(GITransfer )),
  get-n-args => %(:is-symbol<gi_repository_get_n_args>, :returns(guint-ptr), ),
  get-return-attribute => %(:is-symbol<gi_repository_get_return_attribute>, :returns(Str), :parameters([Str]), ),
  get-return-type => %(:is-symbol<gi_repository_get_return_type>, :returns(N-Object), ),
  get-sync-function => %(:is-symbol<gi_repository_get_sync_function>, :returns(N-Object), ),
  invoke => %(:is-symbol<gi_repository_invoke>, :returns(gboolean), :cnv-return(Bool), :parameters([void-ptr, N-Object, gsize, N-Object, gsize, N-Object, CArray[N-Error]]), ),
  is-async => %(:is-symbol<gi_repository_is_async>, :returns(gboolean), :cnv-return(Bool), ),
  is-method => %(:is-symbol<gi_repository_is_method>, :returns(gboolean), :cnv-return(Bool), ),
  iterate-return-attributes => %(:is-symbol<gi_repository_iterate_return_attributes>, :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, gchar-pptr, gchar-pptr]), ),
  load-arg => %(:is-symbol<gi_repository_load_arg>, :parameters([guint-ptr, N-Object]), ),
  load-return-type => %(:is-symbol<gi_repository_load_return_type>, :parameters([N-Object]), ),
  may-return-null => %(:is-symbol<gi_repository_may_return_null>, :returns(gboolean), :cnv-return(Bool), ),
  skip-return => %(:is-symbol<gi_repository_skip_return>, :returns(gboolean), :cnv-return(Bool), ),
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
