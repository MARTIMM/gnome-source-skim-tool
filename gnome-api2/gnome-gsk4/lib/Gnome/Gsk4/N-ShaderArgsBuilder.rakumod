=comment Package: Gsk4, C-Source: glshader
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


#use Gnome::Glib::T-array:api<2>;
use Gnome::Graphene::T-vec:api<2>;
use Gnome::Gsk4::T-glshader:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Structure Declaration]------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gsk4::N-ShaderArgsBuilder:auth<github:MARTIMM>:api<2>;
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
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gsk4::ShaderArgsBuilder' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GskShaderArgsBuilder');
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
  new-shaderargsbuilder => %( :type(Constructor), :is-symbol<gsk_shader_args_builder_new>, :returns(N-Object), :parameters([ N-Object, N-Object])),

  #--[Methods]------------------------------------------------------------------
  free-to-args => %(:is-symbol<gsk_shader_args_builder_free_to_args>,  :returns(N-Object)),
  ref => %(:is-symbol<gsk_shader_args_builder_ref>,  :returns(N-Object)),
  set-bool => %(:is-symbol<gsk_shader_args_builder_set_bool>,  :parameters([gint, gboolean])),
  set-float => %(:is-symbol<gsk_shader_args_builder_set_float>,  :parameters([gint, gfloat])),
  set-int => %(:is-symbol<gsk_shader_args_builder_set_int>,  :parameters([gint, gint32])),
  set-uint => %(:is-symbol<gsk_shader_args_builder_set_uint>,  :parameters([gint, guint32])),
  set-vec2 => %(:is-symbol<gsk_shader_args_builder_set_vec2>,  :parameters([gint, N-Object])),
  set-vec3 => %(:is-symbol<gsk_shader_args_builder_set_vec3>,  :parameters([gint, N-Object])),
  set-vec4 => %(:is-symbol<gsk_shader_args_builder_set_vec4>,  :parameters([gint, N-Object])),
  to-args => %(:is-symbol<gsk_shader_args_builder_to_args>,  :returns(N-Object)),
  unref => %(:is-symbol<gsk_shader_args_builder_unref>, ),
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
