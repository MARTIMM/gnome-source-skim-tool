=comment Package: Glib, C-Source: varianttype
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Glib::T-varianttype:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Structure Declaration]------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Glib::N-VariantType:auth<github:MARTIMM>:api<2>;
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
  new-varianttype => %( :type(Constructor), :is-symbol<g_variant_type_new>, :returns(N-Object), :parameters([ Str])),
  new-array => %( :type(Constructor), :is-symbol<g_variant_type_new_array>, :returns(N-Object), :parameters([ N-Object])),
  new-dict-entry => %( :type(Constructor), :is-symbol<g_variant_type_new_dict_entry>, :returns(N-Object), :parameters([ N-Object, N-Object])),
  new-maybe => %( :type(Constructor), :is-symbol<g_variant_type_new_maybe>, :returns(N-Object), :parameters([ N-Object])),
  new-tuple => %( :type(Constructor), :is-symbol<g_variant_type_new_tuple>, :returns(N-Object), :parameters([ N-Object, gint])),

  #--[Methods]------------------------------------------------------------------
  copy => %(:is-symbol<g_variant_type_copy>,  :returns(N-Object)),
  dup-string => %(:is-symbol<g_variant_type_dup_string>,  :returns(Str)),
  element => %(:is-symbol<g_variant_type_element>,  :returns(N-Object)),
  equal => %(:is-symbol<g_variant_type_equal>,  :returns(gboolean), :cnv-return(Bool), :parameters([gpointer])),
  first => %(:is-symbol<g_variant_type_first>,  :returns(N-Object)),
  free => %(:is-symbol<g_variant_type_free>, ),
  get-string-length => %(:is-symbol<g_variant_type_get_string_length>,  :returns(gsize)),
  hash => %(:is-symbol<g_variant_type_hash>,  :returns(guint)),
  is-array => %(:is-symbol<g_variant_type_is_array>,  :returns(gboolean), :cnv-return(Bool)),
  is-basic => %(:is-symbol<g_variant_type_is_basic>,  :returns(gboolean), :cnv-return(Bool)),
  is-container => %(:is-symbol<g_variant_type_is_container>,  :returns(gboolean), :cnv-return(Bool)),
  is-definite => %(:is-symbol<g_variant_type_is_definite>,  :returns(gboolean), :cnv-return(Bool)),
  is-dict-entry => %(:is-symbol<g_variant_type_is_dict_entry>,  :returns(gboolean), :cnv-return(Bool)),
  is-maybe => %(:is-symbol<g_variant_type_is_maybe>,  :returns(gboolean), :cnv-return(Bool)),
  is-subtype-of => %(:is-symbol<g_variant_type_is_subtype_of>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  is-tuple => %(:is-symbol<g_variant_type_is_tuple>,  :returns(gboolean), :cnv-return(Bool)),
  is-variant => %(:is-symbol<g_variant_type_is_variant>,  :returns(gboolean), :cnv-return(Bool)),
  key => %(:is-symbol<g_variant_type_key>,  :returns(N-Object)),
  n-items => %(:is-symbol<g_variant_type_n_items>,  :returns(gsize)),
  next => %(:is-symbol<g_variant_type_next>,  :returns(N-Object)),
  peek-string => %(:is-symbol<g_variant_type_peek_string>,  :returns(Str)),
  value => %(:is-symbol<g_variant_type_value>,  :returns(N-Object)),

  #--[Functions]----------------------------------------------------------------
  string-is-valid => %( :type(Function), :is-symbol<g_variant_type_string_is_valid>,  :returns(gboolean), :parameters([Str])),
  string-scan => %( :type(Function), :is-symbol<g_variant_type_string_scan>,  :returns(gboolean), :parameters([ Str, Str, gchar-pptr])),
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
