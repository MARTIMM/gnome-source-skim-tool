# Command to generate: generate.raku -v -d -c GObject value
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::GObject::N-Value:api<2>;
use Gnome::Glib::N-Variant:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::GObject::Value:auth<github:MARTIMM>:api<2>;
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
  $!routine-caller .= new(:library('libgobject-2.0.so.0'));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::GObject::Value' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GValue');
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
  copy => %(:is-symbol<g_value_copy>,  :parameters([N-Value])),
  dup-boxed => %(:is-symbol<g_value_dup_boxed>,  :returns(gpointer)),
  dup-object => %(:is-symbol<g_value_dup_object>,  :returns(gpointer)),
  dup-param => %(:is-symbol<g_value_dup_param>,  :returns(N-Object)),
  dup-string => %(:is-symbol<g_value_dup_string>,  :returns(Str)),
  dup-variant => %(:is-symbol<g_value_dup_variant>,  :returns(N-Variant)),
  fits-pointer => %(:is-symbol<g_value_fits_pointer>,  :returns(gboolean), :cnv-return(Bool)),
  get-boolean => %(:is-symbol<g_value_get_boolean>,  :returns(gboolean), :cnv-return(Bool)),
  get-boxed => %(:is-symbol<g_value_get_boxed>,  :returns(gpointer)),
  get-double => %(:is-symbol<g_value_get_double>,  :returns(gdouble)),
  get-enum => %(:is-symbol<g_value_get_enum>,  :returns(gint)),
  get-flags => %(:is-symbol<g_value_get_flags>,  :returns(guint)),
  get-float => %(:is-symbol<g_value_get_float>,  :returns(gfloat)),
  get-gtype => %(:is-symbol<g_value_get_gtype>,  :returns(GType)),
  get-int => %(:is-symbol<g_value_get_int>,  :returns(gint)),
  get-int64 => %(:is-symbol<g_value_get_int64>,  :returns(gint64)),
  get-long => %(:is-symbol<g_value_get_long>,  :returns(glong)),
  get-object => %(:is-symbol<g_value_get_object>,  :returns(gpointer)),
  get-param => %(:is-symbol<g_value_get_param>,  :returns(N-Object)),
  get-pointer => %(:is-symbol<g_value_get_pointer>,  :returns(gpointer)),
  get-schar => %(:is-symbol<g_value_get_schar>,  :returns(gint8)),
  get-string => %(:is-symbol<g_value_get_string>,  :returns(Str)),
  get-uchar => %(:is-symbol<g_value_get_uchar>,  :returns(guchar)),
  get-uint => %(:is-symbol<g_value_get_uint>,  :returns(guint)),
  get-uint64 => %(:is-symbol<g_value_get_uint64>,  :returns(guint64)),
  get-ulong => %(:is-symbol<g_value_get_ulong>,  :returns(gulong)),
  get-variant => %(:is-symbol<g_value_get_variant>,  :returns(N-Variant)),
  init => %(:is-symbol<g_value_init>,  :returns(N-Value), :parameters([GType])),
  init-from-instance => %(:is-symbol<g_value_init_from_instance>,  :parameters([gpointer])),
  peek-pointer => %(:is-symbol<g_value_peek_pointer>,  :returns(gpointer)),
  reset => %(:is-symbol<g_value_reset>,  :returns(N-Value)),
  set-boolean => %(:is-symbol<g_value_set_boolean>,  :parameters([gboolean])),
  set-boxed => %(:is-symbol<g_value_set_boxed>,  :parameters([gpointer])),
  set-double => %(:is-symbol<g_value_set_double>,  :parameters([gdouble])),
  set-enum => %(:is-symbol<g_value_set_enum>,  :parameters([gint])),
  set-flags => %(:is-symbol<g_value_set_flags>,  :parameters([guint])),
  set-float => %(:is-symbol<g_value_set_float>,  :parameters([gfloat])),
  set-gtype => %(:is-symbol<g_value_set_gtype>,  :parameters([GType])),
  set-instance => %(:is-symbol<g_value_set_instance>,  :parameters([gpointer])),
  set-int => %(:is-symbol<g_value_set_int>,  :parameters([gint])),
  set-int64 => %(:is-symbol<g_value_set_int64>,  :parameters([gint64])),
  set-interned-string => %(:is-symbol<g_value_set_interned_string>,  :parameters([Str])),
  set-long => %(:is-symbol<g_value_set_long>,  :parameters([glong])),
  set-object => %(:is-symbol<g_value_set_object>,  :parameters([gpointer])),
  set-param => %(:is-symbol<g_value_set_param>,  :parameters([N-Object])),
  set-pointer => %(:is-symbol<g_value_set_pointer>,  :parameters([gpointer])),
  set-schar => %(:is-symbol<g_value_set_schar>,  :parameters([gint8])),
  set-static-boxed => %(:is-symbol<g_value_set_static_boxed>,  :parameters([gpointer])),
  set-static-string => %(:is-symbol<g_value_set_static_string>,  :parameters([Str])),
  set-string => %(:is-symbol<g_value_set_string>,  :parameters([Str])),
  set-uchar => %(:is-symbol<g_value_set_uchar>,  :parameters([guchar])),
  set-uint => %(:is-symbol<g_value_set_uint>,  :parameters([guint])),
  set-uint64 => %(:is-symbol<g_value_set_uint64>,  :parameters([guint64])),
  set-ulong => %(:is-symbol<g_value_set_ulong>,  :parameters([gulong])),
  set-variant => %(:is-symbol<g_value_set_variant>,  :parameters([N-Variant])),
  take-boxed => %(:is-symbol<g_value_take_boxed>,  :parameters([gpointer])),
  take-object => %(:is-symbol<g_value_take_object>,  :parameters([gpointer])),
  take-param => %(:is-symbol<g_value_take_param>,  :parameters([N-Object])),
  take-string => %(:is-symbol<g_value_take_string>,  :parameters([Str])),
  take-variant => %(:is-symbol<g_value_take_variant>,  :parameters([N-Variant])),
  transform => %(:is-symbol<g_value_transform>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Value])),
  unset => %(:is-symbol<g_value_unset>, ),

  #--[Functions]----------------------------------------------------------------
  register-transform-func => %( :type(Function), :is-symbol<g_value_register_transform_func>,  :parameters([ GType, GType, :( N-Value $src-value, N-Value $dest-value )])),
  type-compatible => %( :type(Function), :is-symbol<g_value_type_compatible>,  :returns(gboolean), :parameters([ GType, GType])),
  type-transformable => %( :type(Function), :is-symbol<g_value_type_transformable>,  :returns(gboolean), :parameters([ GType, GType])),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    if $methods{$name}<type>:exists and $methods{$name}<type> eq 'Constructor' {
      my Gnome::N::GnomeRoutineCaller $routine-caller .= new(
        :library('libgobject-2.0.so.0')
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
