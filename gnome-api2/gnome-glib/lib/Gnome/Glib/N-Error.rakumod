# Command to generate: generate.raku -v -c Glib error
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Glib::N-Error:auth<github:MARTIMM>:api<2>;
also is Gnome::N::TopLevelClassSupport;


#-------------------------------------------------------------------------------
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------

class N-Error:auth<github:MARTIMM>:api<2> is export is repr('CStruct') {

  has GQuark $.domain;
  has gint $.code;
  has Str $.message;

  submethod BUILD (
    GQuark :$!domain, gint :$!code, Str :$!message, 
  ) {
  }

  method COERCE ( $no --> N-Error ) {
    note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
    nativecast( N-Error, $no)
  }
}

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
  new-error => %( :type(Constructor), :is-symbol<g_error_new>, :returns(N-Error), :variable-list, :parameters([ GQuark, gint, Str])),
  new-literal => %( :type(Constructor), :is-symbol<g_error_new_literal>, :returns(N-Error), :parameters([ GQuark, gint, Str])),
  #new-valist => %( :type(Constructor), :is-symbol<g_error_new_valist>, :returns(N-Error), :parameters([ GQuark, gint, Str, ])),

  #--[Methods]------------------------------------------------------------------
  copy => %(:is-symbol<g_error_copy>,  :returns(N-Error)),
  free => %(:is-symbol<g_error_free>, ),
  matches => %(:is-symbol<g_error_matches>,  :returns(gboolean), :cnv-return(Bool), :parameters([GQuark, gint])),

  #--[Functions]----------------------------------------------------------------
  domain-register => %( :type(Function), :is-symbol<g_error_domain_register>,  :returns(GQuark), :parameters([ Str, gsize, :( N-Error $error ), :( N-Error $src-error, N-Error $dest-error ), :( N-Error $error )])),
  domain-register-static => %( :type(Function), :is-symbol<g_error_domain_register_static>,  :returns(GQuark), :parameters([ Str, gsize, :( N-Error $error ), :( N-Error $src-error, N-Error $dest-error ), :( N-Error $error )])),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    if $methods{$name}<type>:exists and $methods{$name}<type> eq 'Constructor' {
      my Gnome::N::GnomeRoutineCaller $routine-caller .= new(
        :library(glib-lib())
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
