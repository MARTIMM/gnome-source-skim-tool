=comment Package: Glib, C-Source: error
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Glib::T-error:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Structure Declaration]------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Glib::N-Error:auth<github:MARTIMM>:api<2>;
also is Gnome::N::TopLevelClassSupport;

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
  $!routine-caller .= new(:library(glib-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Glib::Error' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GError');
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

  #--[Constructors]-------------------------------------------------------------
  new-error => %( :type(Constructor), :is-symbol<g_error_new>, :returns(N-Object), :variable-list, :parameters([ GQuark, gint, Str])),
  new-literal => %( :type(Constructor), :is-symbol<g_error_new_literal>, :returns(N-Object), :parameters([ GQuark, gint, Str])),
  #new-valist => %( :type(Constructor), :is-symbol<g_error_new_valist>, :returns(N-Object), :parameters([ GQuark, gint, Str, ])),

  #--[Methods]------------------------------------------------------------------
  copy => %(:is-symbol<g_error_copy>,  :returns(N-Object)),
  free => %(:is-symbol<g_error_free>, ),
  matches => %(:is-symbol<g_error_matches>,  :returns(gboolean), :cnv-return(Bool), :parameters([GQuark, gint])),

  #--[Functions]----------------------------------------------------------------
  domain-register => %( :type(Function), :is-symbol<g_error_domain_register>,  :returns(GQuark), :parameters([ Str, gsize, :( N-Object $error ), :( N-Object $src-error, N-Object $dest-error ), :( N-Object $error )])),
  domain-register-static => %( :type(Function), :is-symbol<g_error_domain_register_static>,  :returns(GQuark), :parameters([ Str, gsize, :( N-Object $error ), :( N-Object $src-error, N-Object $dest-error ), :( N-Object $error )])),
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
        :library(glib-lib())
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
