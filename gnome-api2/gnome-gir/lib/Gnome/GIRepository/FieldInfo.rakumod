=comment Package: GIRepo, C-Source: gifieldinfo
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;



use Gnome::GIRepository::BaseInfo:api<2>;
#use Gnome::GIRepository::N-Argument:api<2>;
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

unit class Gnome::GIRepository::FieldInfo:auth<github:MARTIMM>:api<2>;
also is Gnome::GIRepo::BaseInfo;

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
  $!routine-caller .= new(:library(girepository-2.0));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::GIRepository::FieldInfo' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GIFieldInfo');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  get-field => %(:is-symbol<gi_repository_get_field>, :returns(gboolean), :cnv-return(Bool), :parameters([void-ptr, N-Object]), ),
  get-flags => %(:is-symbol<gi_repository_get_flags>,  :returns(GFlag), :cnv-return(GIFieldInfoFlags )),
  get-offset => %(:is-symbol<gi_repository_get_offset>, :returns(gsize), ),
  get-size => %(:is-symbol<gi_repository_get_size>, :returns(gsize), ),
  get-type-info => %(:is-symbol<gi_repository_get_type_info>, :returns(N-Object), ),
  set-field => %(:is-symbol<gi_repository_set_field>, :returns(gboolean), :cnv-return(Bool), :parameters([void-ptr, N-Object]), ),
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
        :library(girepository-2.0)
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
