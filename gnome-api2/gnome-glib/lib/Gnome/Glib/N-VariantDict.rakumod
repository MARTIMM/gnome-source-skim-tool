=comment Package: Glib, C-Source: variant
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Glib::T-variant:api<2>;
#use Gnome::Glib::T-varianttype:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Structure Declaration]------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Glib::N-VariantDict:auth<github:MARTIMM>:api<2>;
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
  if self.^name eq 'Gnome::Glib::VariantDict' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GVariantDict');
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
  new-variantdict => %( :type(Constructor), :is-symbol<g_variant_dict_new>, :returns(N-Object), :parameters([ N-Object])),

  #--[Methods]------------------------------------------------------------------
  clear => %(:is-symbol<g_variant_dict_clear>, ),
  contains => %(:is-symbol<g_variant_dict_contains>,  :returns(gboolean), :cnv-return(Bool), :parameters([Str])),
  end => %(:is-symbol<g_variant_dict_end>,  :returns(N-Object)),
  init => %(:is-symbol<g_variant_dict_init>,  :parameters([N-Object])),
  insert => %(:is-symbol<g_variant_dict_insert>, :variable-list,  :parameters([Str, Str])),
  insert-value => %(:is-symbol<g_variant_dict_insert_value>,  :parameters([Str, N-Object])),
  lookup => %(:is-symbol<g_variant_dict_lookup>, :variable-list,  :returns(gboolean), :cnv-return(Bool), :parameters([Str, Str])),
  lookup-value => %(:is-symbol<g_variant_dict_lookup_value>,  :returns(N-Object), :parameters([Str, N-Object])),
  ref => %(:is-symbol<g_variant_dict_ref>,  :returns(N-Object)),
  remove => %(:is-symbol<g_variant_dict_remove>,  :returns(gboolean), :cnv-return(Bool), :parameters([Str])),
  unref => %(:is-symbol<g_variant_dict_unref>, ),
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
