# Command to generate: gnome-source-skim-tool.raku -c -t -v Glib error
use v6;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Glib::N-GError:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-GObject:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Glib::Error:auth<github:MARTIMM>:api<2>;
also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
#--[BUILD variables]------------------------------------------------------------
#-------------------------------------------------------------------------------

# Define callable helper
has Gnome::N::GnomeRoutineCaller $!routine-caller;

#-------------------------------------------------------------------------------
#--[BUILD submethod]------------------------------------------------------------
#-------------------------------------------------------------------------------

#>> test to use new sec <<
method new( GQuark $domain, gint $code, Str $message, *@arguments ) {
  note "$?LINE, @arguments.gist()";
  my $native-object = self._fallback-v2(
    'new', my Bool $x, $domain, $code, $message, @arguments
  );
  self.bless(:$native-object);
}

submethod BUILD ( *%options ) {

  # Initialize helper
  $!routine-caller .= new( :library(glib-lib()), :sub-prefix<g_error_>);

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Glib::Error' {

    # If already initialized in some parent, the object is valid
    if self.is-valid { }

    # Check if common options are handled by some parent
    elsif %options<native-object>:exists { }

    # only after creating the native-object, the gtype is known
    self._set-class-info('GError');
  }
}

method native-object-ref ( $n-native-object ) { $n-native-object }

method native-object-unref ( $n-native-object ) {
  self._fallback-v2( 'free', my Bool $x);
}



#`{{
submethod BUILD ( *%options ) {

  # Initialize helper
  $!routine-caller .= new( :library(glib-lib()), :sub-prefix<g_error_>);

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Glib::Error' {

    # If already initialized in some parent, the object is valid
    if self.is-valid { }

    # Check if common options are handled by some parent
    elsif %options<native-object>:exists { }

    else {
      my N-GObject() $no;
      if %options<>:exists {
        #my $domain = %options<>;
        #my $code = %options<code>;
        #my $format = %options<format>;
        #my $... = %options<...>;

        # 'my Bool $x' is needed but value ignored
        #$no = self._fallback-v2( 'new', my Bool $x, $domain, $code, $format, $...);
      }

      elsif %options<literal>:exists {
        my $domain = %options<literal>;
        my $code = %options<code>;
        my $message = %options<message>;

        # 'my Bool $x' is needed but value ignored
        $no = self._fallback-v2( 'new-literal', my Bool $x, $domain, $code, $message);
      }

      elsif %options<valist>:exists {
        #my $domain = %options<valist>;
        #my $code = %options<code>;
        #my $format = %options<format>;
        #my $args = %options<args>;

        # 'my Bool $x' is needed but value ignored
        #$no = self._fallback-v2( 'new-valist', my Bool $x, $domain, $code, $format, $args);
      }

      # check if there are unknown options
      elsif %options.elems {
        die X::Gnome.new(
          :message(
            'Unsupported, undefined, incomplete or wrongly typed options for ' ~
            self.^name ~ ': ' ~ %options.keys.join(', ')
          )
        );
      }

      if ?$no {
        self._set-native-object($no);
      }

      else {
        die X::Gnome.new(:message('Native object for class Gnome::Glib::Error not created'));
      }
    }

    # only after creating the native-object, the gtype is known
    self._set-class-info('GError');
  }
}
}}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new => %( :type(Constructor),:returns(N-GError), :variable-list, :parameters([ GQuark, gint, Str])),
  new-literal => %( :type(Constructor),:returns(N-GError), :parameters([ GQuark, gint, Str])),
  #new-valist => %( :type(Constructor),:returns(N-GError), :parameters([ GQuark, gint, Str, ])),

  #--[Methods]------------------------------------------------------------------
  copy => %( :returns(N-GError)),
  free => %(),
  matches => %( :returns(gboolean), :parameters([GQuark, gint])),

  #--[Functions]----------------------------------------------------------------
#  domain-register => %( :type(Function),  :returns(GQuark), :parameters([ Str, gsize, , , ])),
#  domain-register-static => %( :type(Function),  :returns(GQuark), :parameters([ Str, gsize, , , ])),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    if $methods{$name}<type> eq 'Constructor' {
      my Gnome::N::GnomeRoutineCaller $routine-caller .= new(
        :library(glib-lib()), :sub-prefix<g_error_>
      );

      return self.bless(
        :native-object(
          $routine-caller.call-native-sub( $name, @arguments, $methods)
        )
      );
    }

    else {

      my $native-object = self.get-native-object-no-reffing;
      return $!routine-caller.call-native-sub(
        $name, @arguments, $methods, :$native-object
      );
    }
  }

  else {
    callsame;
  }
}
