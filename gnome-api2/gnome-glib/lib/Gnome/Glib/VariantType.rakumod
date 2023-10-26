# Command to generate: generate.raku -v -c Glib varianttype
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Glib::N-VariantType:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-GObject:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Glib::VariantType:auth<github:MARTIMM>:api<2>;
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
  $!routine-caller .= new( :library(glib-lib()), :sub-prefix<g_variant_type_>);

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Glib::VariantType' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GVariantType');
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
  new-varianttype => %( :type(Constructor), :isnew, :returns(N-VariantType), :parameters([ Str])),
  new-array => %( :type(Constructor), :returns(N-VariantType), :parameters([ N-VariantType])),
  new-dict-entry => %( :type(Constructor), :returns(N-VariantType), :parameters([ N-VariantType, N-VariantType])),
  new-maybe => %( :type(Constructor), :returns(N-VariantType), :parameters([ N-VariantType])),
  new-tuple => %( :type(Constructor), :returns(N-VariantType), :parameters([ CArray[N-VariantType], gint])),

  #--[Methods]------------------------------------------------------------------
  copy => %( :returns(N-VariantType)),
  dup-string => %( :returns(Str)),
  element => %( :returns(N-VariantType)),
  equal => %( :returns(gboolean), :cnv-return(Bool), :parameters([gpointer])),
  first => %( :returns(N-VariantType)),
  free => %(),
  get-string-length => %( :returns(gsize)),
  hash => %( :returns(guint)),
  is-array => %( :returns(gboolean), :cnv-return(Bool)),
  is-basic => %( :returns(gboolean), :cnv-return(Bool)),
  is-container => %( :returns(gboolean), :cnv-return(Bool)),
  is-definite => %( :returns(gboolean), :cnv-return(Bool)),
  is-dict-entry => %( :returns(gboolean), :cnv-return(Bool)),
  is-maybe => %( :returns(gboolean), :cnv-return(Bool)),
  is-subtype-of => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-VariantType])),
  is-tuple => %( :returns(gboolean), :cnv-return(Bool)),
  is-variant => %( :returns(gboolean), :cnv-return(Bool)),
  key => %( :returns(N-VariantType)),
  n-items => %( :returns(gsize)),
  next => %( :returns(N-VariantType)),
  peek-string => %( :returns(Str)),
  value => %( :returns(N-VariantType)),

  #--[Functions]----------------------------------------------------------------
  string-is-valid => %( :type(Function),  :returns(gboolean), :parameters([Str])),
  string-scan => %( :type(Function),  :returns(gboolean), :parameters([ Str, Str, gchar-pptr])),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    if $methods{$name}<type>:exists and $methods{$name}<type> eq 'Constructor' {
      my Gnome::N::GnomeRoutineCaller $routine-caller .= new(
        :library(glib-lib()), :sub-prefix<g_variant_type_>
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
