=comment Package: Glib, C-Source: variant
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Glib::N-Variant:api<2>;
#use Gnome::Glib::N-VariantBuilder:api<2>;
use Gnome::Glib::N-VariantType:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Glib::N-VariantBuilder:auth<github:MARTIMM>:api<2>;
also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------

# This is an opaque type of which fields are not available.
class N-VariantBuilder:auth<github:MARTIMM>:api<2> is export is repr('CPointer') { }

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
  if self.^name eq 'Gnome::Glib::VariantBuilder' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GVariantBuilder');
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
  #new-variantbuilder => %( :type(Constructor), :is-symbol<g_variant_builder_new>, :returns(N-VariantBuilder ), :parameters([ N-VariantType])),

  #--[Methods]------------------------------------------------------------------
  #add => %(:is-symbol<g_variant_builder_add>, :variable-list,  :parameters([Str])),
  #add-parsed => %(:is-symbol<g_variant_builder_add_parsed>, :variable-list,  :parameters([Str])),
  #add-value => %(:is-symbol<g_variant_builder_add_value>,  :parameters([N-Variant])),
  #clear => %(:is-symbol<g_variant_builder_clear>, ),
  #close => %(:is-symbol<g_variant_builder_close>, ),
  #end => %(:is-symbol<g_variant_builder_end>,  :returns(N-Variant)),
  #init => %(:is-symbol<g_variant_builder_init>,  :parameters([N-VariantType])),
  #open => %(:is-symbol<g_variant_builder_open>,  :parameters([N-VariantType])),
  #ref => %(:is-symbol<g_variant_builder_ref>,  :returns(N-VariantBuilder )),
  #unref => %(:is-symbol<g_variant_builder_unref>, ),
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