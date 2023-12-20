# Package: Glib, C-Source: variant
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


#use Gnome::Glib::N-Bytes:api<2>;
use Gnome::Glib::N-Error:api<2>;
#use Gnome::Glib::N-String:api<2>;
use Gnome::Glib::N-VariantIter:api<2>;
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

unit class Gnome::Glib::N-Variant:auth<github:MARTIMM>:api<2>;
also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------

# This is an opaque type of which fields are not available.
class N-Variant:auth<github:MARTIMM>:api<2> is export is repr('CPointer') { }

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
  if self.^name eq 'Gnome::Glib::Variant' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GVariant');
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
  new-variant => %( :type(Constructor), :is-symbol<g_variant_new>, :returns(N-Variant), :variable-list, :parameters([ Str])),
  new-array => %( :type(Constructor), :is-symbol<g_variant_new_array>, :returns(N-Variant), :parameters([ N-VariantType, CArray[N-Variant], gsize])),
  new-boolean => %( :type(Constructor), :is-symbol<g_variant_new_boolean>, :returns(N-Variant), :parameters([ gboolean])),
  new-byte => %( :type(Constructor), :is-symbol<g_variant_new_byte>, :returns(N-Variant), :parameters([ guint8])),
  new-bytestring => %( :type(Constructor), :is-symbol<g_variant_new_bytestring>, :returns(N-Variant), :parameters([ Str])),
  new-bytestring-array => %( :type(Constructor), :is-symbol<g_variant_new_bytestring_array>, :returns(N-Variant), :parameters([ gchar-pptr, gssize])),
  new-dict-entry => %( :type(Constructor), :is-symbol<g_variant_new_dict_entry>, :returns(N-Variant), :parameters([ N-Variant, N-Variant])),
  new-double => %( :type(Constructor), :is-symbol<g_variant_new_double>, :returns(N-Variant), :parameters([ gdouble])),
  new-fixed-array => %( :type(Constructor), :is-symbol<g_variant_new_fixed_array>, :returns(N-Variant), :parameters([ N-VariantType, gpointer, gsize, gsize])),
  #new-from-bytes => %( :type(Constructor), :is-symbol<g_variant_new_from_bytes>, :returns(N-Variant), :parameters([ N-VariantType, N-Bytes , gboolean])),
#  new-from-data => %( :type(Constructor), :is-symbol<g_variant_new_from_data>, :returns(N-Variant), :parameters([ N-VariantType, gpointer, gsize, gboolean, , gpointer])),
  new-handle => %( :type(Constructor), :is-symbol<g_variant_new_handle>, :returns(N-Variant), :parameters([ gint32])),
  new-int16 => %( :type(Constructor), :is-symbol<g_variant_new_int16>, :returns(N-Variant), :parameters([ gint16])),
  new-int32 => %( :type(Constructor), :is-symbol<g_variant_new_int32>, :returns(N-Variant), :parameters([ gint32])),
  new-int64 => %( :type(Constructor), :is-symbol<g_variant_new_int64>, :returns(N-Variant), :parameters([ gint64])),
  new-maybe => %( :type(Constructor), :is-symbol<g_variant_new_maybe>, :returns(N-Variant), :parameters([ N-VariantType, N-Variant])),
  new-object-path => %( :type(Constructor), :is-symbol<g_variant_new_object_path>, :returns(N-Variant), :parameters([ Str])),
  new-objv => %( :type(Constructor), :is-symbol<g_variant_new_objv>, :returns(N-Variant), :parameters([ gchar-pptr, gssize])),
  new-parsed => %( :type(Constructor), :is-symbol<g_variant_new_parsed>, :returns(N-Variant), :variable-list, :parameters([ Str])),
  #new-parsed-va => %( :type(Constructor), :is-symbol<g_variant_new_parsed_va>, :returns(N-Variant), :parameters([ Str, ])),
  new-printf => %( :type(Constructor), :is-symbol<g_variant_new_printf>, :returns(N-Variant), :variable-list, :parameters([ Str])),
  new-signature => %( :type(Constructor), :is-symbol<g_variant_new_signature>, :returns(N-Variant), :parameters([ Str])),
  new-string => %( :type(Constructor), :is-symbol<g_variant_new_string>, :returns(N-Variant), :parameters([ Str])),
  new-strv => %( :type(Constructor), :is-symbol<g_variant_new_strv>, :returns(N-Variant), :parameters([ gchar-pptr, gssize])),
  new-take-string => %( :type(Constructor), :is-symbol<g_variant_new_take_string>, :returns(N-Variant), :parameters([ Str])),
  new-tuple => %( :type(Constructor), :is-symbol<g_variant_new_tuple>, :returns(N-Variant), :parameters([ CArray[N-Variant], gsize])),
  new-uint16 => %( :type(Constructor), :is-symbol<g_variant_new_uint16>, :returns(N-Variant), :parameters([ guint16])),
  new-uint32 => %( :type(Constructor), :is-symbol<g_variant_new_uint32>, :returns(N-Variant), :parameters([ guint32])),
  new-uint64 => %( :type(Constructor), :is-symbol<g_variant_new_uint64>, :returns(N-Variant), :parameters([ guint64])),
  #new-va => %( :type(Constructor), :is-symbol<g_variant_new_va>, :returns(N-Variant), :parameters([ Str, gchar-pptr, ])),
  new-variant-with-variant => %( :type(Constructor), :is-symbol<g_variant_new_variant>, :returns(N-Variant), :parameters([ N-Variant])),

  #--[Methods]------------------------------------------------------------------
  byteswap => %(:is-symbol<g_variant_byteswap>,  :returns(N-Variant)),
  check-format-string => %(:is-symbol<g_variant_check_format_string>,  :returns(gboolean), :cnv-return(Bool), :parameters([Str, gboolean])),
  #classify => %(:is-symbol<g_variant_classify>, ),
  compare => %(:is-symbol<g_variant_compare>,  :returns(gint), :parameters([gpointer])),
  dup-bytestring => %(:is-symbol<g_variant_dup_bytestring>,  :returns(Str), :parameters([CArray[gsize]])),
  dup-bytestring-array => %(:is-symbol<g_variant_dup_bytestring_array>,  :returns(gchar-pptr), :parameters([CArray[gsize]])),
  dup-objv => %(:is-symbol<g_variant_dup_objv>,  :returns(gchar-pptr), :parameters([CArray[gsize]])),
  dup-string => %(:is-symbol<g_variant_dup_string>,  :returns(Str), :parameters([CArray[gsize]])),
  dup-strv => %(:is-symbol<g_variant_dup_strv>,  :returns(gchar-pptr), :parameters([CArray[gsize]])),
  equal => %(:is-symbol<g_variant_equal>,  :returns(gboolean), :cnv-return(Bool), :parameters([gpointer])),
  get => %(:is-symbol<g_variant_get>, :variable-list,  :parameters([Str])),
  get-boolean => %(:is-symbol<g_variant_get_boolean>,  :returns(gboolean), :cnv-return(Bool)),
  get-byte => %(:is-symbol<g_variant_get_byte>,  :returns(guint8)),
  get-bytestring => %(:is-symbol<g_variant_get_bytestring>,  :returns(Str)),
  get-bytestring-array => %(:is-symbol<g_variant_get_bytestring_array>,  :returns(gchar-pptr), :parameters([CArray[gsize]])),
  get-child => %(:is-symbol<g_variant_get_child>, :variable-list,  :parameters([gsize, Str])),
  get-child-value => %(:is-symbol<g_variant_get_child_value>,  :returns(N-Variant), :parameters([gsize])),
  get-data => %(:is-symbol<g_variant_get_data>,  :returns(gpointer)),
  #get-data-as-bytes => %(:is-symbol<g_variant_get_data_as_bytes>,  :returns(N-Bytes )),
  get-double => %(:is-symbol<g_variant_get_double>,  :returns(gdouble)),
  get-fixed-array => %(:is-symbol<g_variant_get_fixed_array>,  :returns(gpointer), :parameters([CArray[gsize], gsize])),
  get-handle => %(:is-symbol<g_variant_get_handle>,  :returns(gint32)),
  get-int16 => %(:is-symbol<g_variant_get_int16>,  :returns(gint16)),
  get-int32 => %(:is-symbol<g_variant_get_int32>,  :returns(gint32)),
  get-int64 => %(:is-symbol<g_variant_get_int64>,  :returns(gint64)),
  get-maybe => %(:is-symbol<g_variant_get_maybe>,  :returns(N-Variant)),
  get-normal-form => %(:is-symbol<g_variant_get_normal_form>,  :returns(N-Variant)),
  get-objv => %(:is-symbol<g_variant_get_objv>,  :returns(gchar-pptr), :parameters([CArray[gsize]])),
  get-size => %(:is-symbol<g_variant_get_size>,  :returns(gsize)),
  get-string => %(:is-symbol<g_variant_get_string>,  :returns(Str), :parameters([CArray[gsize]])),
  get-strv => %(:is-symbol<g_variant_get_strv>,  :returns(gchar-pptr), :parameters([CArray[gsize]])),
  get-type => %(:is-symbol<g_variant_get_type>,  :returns(N-VariantType)),
  get-type-string => %(:is-symbol<g_variant_get_type_string>,  :returns(Str)),
  get-uint16 => %(:is-symbol<g_variant_get_uint16>,  :returns(guint16)),
  get-uint32 => %(:is-symbol<g_variant_get_uint32>,  :returns(guint32)),
  get-uint64 => %(:is-symbol<g_variant_get_uint64>,  :returns(guint64)),
  #get-va => %(:is-symbol<g_variant_get_va>,  :parameters([Str, gchar-pptr, ])),
  get-variant => %(:is-symbol<g_variant_get_variant>,  :returns(N-Variant)),
  hash => %(:is-symbol<g_variant_hash>,  :returns(guint)),
  is-container => %(:is-symbol<g_variant_is_container>,  :returns(gboolean), :cnv-return(Bool)),
  is-floating => %(:is-symbol<g_variant_is_floating>,  :returns(gboolean), :cnv-return(Bool)),
  is-normal-form => %(:is-symbol<g_variant_is_normal_form>,  :returns(gboolean), :cnv-return(Bool)),
  is-of-type => %(:is-symbol<g_variant_is_of_type>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-VariantType])),
  iter-new => %(:is-symbol<g_variant_iter_new>,  :returns(N-VariantIter )),
  lookup => %(:is-symbol<g_variant_lookup>, :variable-list,  :returns(gboolean), :cnv-return(Bool), :parameters([Str, Str])),
  lookup-value => %(:is-symbol<g_variant_lookup_value>,  :returns(N-Variant), :parameters([Str, N-VariantType])),
  n-children => %(:is-symbol<g_variant_n_children>,  :returns(gsize)),
  print => %(:is-symbol<g_variant_print>,  :returns(Str), :parameters([gboolean])),
  #print-string => %(:is-symbol<g_variant_print_string>,  :returns(N-String ), :parameters([N-String , gboolean])),
  ref => %(:is-symbol<g_variant_ref>,  :returns(N-Variant)),
  ref-sink => %(:is-symbol<g_variant_ref_sink>,  :returns(N-Variant)),
  store => %(:is-symbol<g_variant_store>,  :parameters([gpointer])),
  take-ref => %(:is-symbol<g_variant_take_ref>,  :returns(N-Variant)),
  unref => %(:is-symbol<g_variant_unref>, ),

  #--[Functions]----------------------------------------------------------------
  is-object-path => %( :type(Function), :is-symbol<g_variant_is_object_path>,  :returns(gboolean), :parameters([Str])),
  is-signature => %( :type(Function), :is-symbol<g_variant_is_signature>,  :returns(gboolean), :parameters([Str])),
  parse => %( :type(Function), :is-symbol<g_variant_parse>,  :returns(N-Variant), :parameters([ N-VariantType, Str, Str, gchar-pptr, CArray[N-Error]])),
  parse-error-print-context => %( :type(Function), :is-symbol<g_variant_parse_error_print_context>,  :returns(Str), :parameters([ N-Error, Str])),
  parse-error-quark => %( :type(Function), :is-symbol<g_variant_parse_error_quark>,  :returns(GQuark)),
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
