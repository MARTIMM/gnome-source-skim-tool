=comment Package: Gsk4, C-Source: glshader
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::GObject::Object:api<2>;
#use Gnome::Glib::N-Bytes:api<2>;
use Gnome::Glib::N-Error:api<2>;
#use Gnome::Glib::T-array:api<2>;
use Gnome::Graphene::N-Vec2:api<2>;
use Gnome::Graphene::N-Vec3:api<2>;
use Gnome::Graphene::N-Vec4:api<2>;
use Gnome::Graphene::T-vec:api<2>;
use Gnome::Gsk4::T-enums:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gsk4::GLShader:auth<github:MARTIMM>:api<2>;
also is Gnome::GObject::Object;

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
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gsk4::GLShader' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GskGLShader');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-from-bytes => %( :type(Constructor), :is-symbol<gsk_g_l_shader_new_from_bytes>, :returns(N-Object), :parameters([ N-Object])),
  new-from-resource => %( :type(Constructor), :is-symbol<gsk_g_l_shader_new_from_resource>, :returns(N-Object), :parameters([ Str])),

  #--[Methods]------------------------------------------------------------------
  compile => %(:is-symbol<gsk_g_l_shader_compile>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, CArray[N-Error]])),
  find-uniform-by-name => %(:is-symbol<gsk_g_l_shader_find_uniform_by_name>,  :returns(gint), :parameters([Str])),
  format-args => %(:is-symbol<gsk_g_l_shader_format_args>, :variable-list,  :returns(N-Object)),
  #format-args-va => %(:is-symbol<gsk_g_l_shader_format_args_va>,  :returns(N-Object)),
  get-arg-bool => %(:is-symbol<gsk_g_l_shader_get_arg_bool>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, gint])),
  get-arg-float => %(:is-symbol<gsk_g_l_shader_get_arg_float>,  :returns(gfloat), :parameters([N-Object, gint])),
  get-arg-int => %(:is-symbol<gsk_g_l_shader_get_arg_int>,  :returns(gint32), :parameters([N-Object, gint])),
  get-arg-uint => %(:is-symbol<gsk_g_l_shader_get_arg_uint>,  :returns(guint32), :parameters([N-Object, gint])),
  get-arg-vec2 => %(:is-symbol<gsk_g_l_shader_get_arg_vec2>,  :parameters([N-Object, gint, N-Object])),
  get-arg-vec3 => %(:is-symbol<gsk_g_l_shader_get_arg_vec3>,  :parameters([N-Object, gint, N-Object])),
  get-arg-vec4 => %(:is-symbol<gsk_g_l_shader_get_arg_vec4>,  :parameters([N-Object, gint, N-Object])),
  get-args-size => %(:is-symbol<gsk_g_l_shader_get_args_size>,  :returns(gsize)),
  get-n-textures => %(:is-symbol<gsk_g_l_shader_get_n_textures>,  :returns(gint)),
  get-n-uniforms => %(:is-symbol<gsk_g_l_shader_get_n_uniforms>,  :returns(gint)),
  get-resource => %(:is-symbol<gsk_g_l_shader_get_resource>,  :returns(Str)),
  get-source => %(:is-symbol<gsk_g_l_shader_get_source>,  :returns(N-Object)),
  get-uniform-name => %(:is-symbol<gsk_g_l_shader_get_uniform_name>,  :returns(Str), :parameters([gint])),
  get-uniform-offset => %(:is-symbol<gsk_g_l_shader_get_uniform_offset>,  :returns(gint), :parameters([gint])),
  get-uniform-type => %(:is-symbol<gsk_g_l_shader_get_uniform_type>,  :returns(GEnum), :cnv-return(GskGLUniformType), :parameters([gint])),
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
        :library(gtk4-lib())
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
