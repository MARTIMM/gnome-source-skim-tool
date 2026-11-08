=comment Package: GIRepo, C-Source: gitypes
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;



#use :api<2>;
#use Gnome::GIRepository::N-AttributeIter:api<2>;
#use Gnome::GIRepository::N-Typelib:api<2>;
#use Gnome::GIRepository::T-gibaseinfo:api<2>;
#use Gnome::GIRepository::T-gitypelib:api<2>;

use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::GIRepository::BaseInfo:auth<github:MARTIMM>:api<2>;
#also is ;

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
  if self.^name eq 'Gnome::GIRepository::BaseInfo' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GIBaseInfo');
  }
}

# Next two methods need checks for proper referencing or cleanup 
method native-object-ref ( $n-native-object ) {
  $n-native-object
}

method native-object-unref ( $n-native-object ) {
#  self._fallback-v2( 'free', my Bool $x);
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  clear => %(:is-symbol<gi_repository_clear>, ),
  equal => %(:is-symbol<gi_repository_equal>, :returns(gboolean), :cnv-return(Bool), :parameters([N-Object]), ),
  get-attribute => %(:is-symbol<gi_repository_get_attribute>, :returns(Str), :parameters([Str]), ),
  get-container => %(:is-symbol<gi_repository_get_container>, :returns(N-Object), ),
  get-name => %(:is-symbol<gi_repository_get_name>, :returns(Str), ),
  get-namespace => %(:is-symbol<gi_repository_get_namespace>, :returns(Str), ),
  get-typelib => %(:is-symbol<gi_repository_get_typelib>, :returns(N-Object), ),
  is-deprecated => %(:is-symbol<gi_repository_is_deprecated>, :returns(gboolean), :cnv-return(Bool), ),
  iterate-attributes => %(:is-symbol<gi_repository_iterate_attributes>, :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, gchar-pptr, gchar-pptr]), ),
  ref => %(:is-symbol<gi_repository_ref>, :returns(N-Object), ),
  unref => %(:is-symbol<gi_repository_unref>, ),
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
