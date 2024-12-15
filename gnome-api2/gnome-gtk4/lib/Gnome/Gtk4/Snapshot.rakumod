=comment Package: Gtk4, C-Source: snapshot
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;
use Cairo;


use Gnome::Gdk4::N-RGBA:api<2>;
use Gnome::Gdk4::Snapshot:api<2>;
use Gnome::Gdk4::T-rgba:api<2>;
use Gnome::Glib::N-Bytes:api<2>;
use Gnome::Glib::T-array:api<2>;
use Gnome::Graphene::N-Matrix:api<2>;
use Gnome::Graphene::N-Point:api<2>;
use Gnome::Graphene::N-Point3D:api<2>;
use Gnome::Graphene::N-Rect:api<2>;
use Gnome::Graphene::N-Size:api<2>;
use Gnome::Graphene::N-Vec3:api<2>;
use Gnome::Graphene::N-Vec4:api<2>;
use Gnome::Graphene::T-matrix:api<2>;
use Gnome::Graphene::T-point:api<2>;
use Gnome::Graphene::T-point3d:api<2>;
use Gnome::Graphene::T-rect:api<2>;
use Gnome::Graphene::T-size:api<2>;
use Gnome::Graphene::T-vec:api<2>;
#use Gnome::Gsk4::N-ColorStop:api<2>;
#use Gnome::Gsk4::N-Path:api<2>;
#use Gnome::Gsk4::N-RoundedRect:api<2>;
#use Gnome::Gsk4::N-Shadow:api<2>;
#use Gnome::Gsk4::N-Stroke:api<2>;
use Gnome::Gsk4::N-Transform:api<2>;
use Gnome::Gsk4::T-enums:api<2>;
use Gnome::Gsk4::T-rendernode:api<2>;
#use Gnome::Gsk4::T-roundedrect:api<2>;
use Gnome::Gsk4::T-types:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;
use Gnome::Pango::T-direction:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::Snapshot:auth<github:MARTIMM>:api<2>;
also is Gnome::Gdk4::Snapshot;

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
  if self.^name eq 'Gnome::Gtk4::Snapshot' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkSnapshot');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-snapshot => %( :type(Constructor), :is-symbol<gtk_snapshot_new>, :returns(N-Object), ),

  #--[Methods]------------------------------------------------------------------
  append-border => %(:is-symbol<gtk_snapshot_append_border>, :returns(void) :parameters([N-Object, CArray[gfloat], N-Object])),
  append-cairo => %(:is-symbol<gtk_snapshot_append_cairo>, :returns(Cairo::cairo_t) :parameters([N-Object])),
  append-color => %(:is-symbol<gtk_snapshot_append_color>, :returns(void) :parameters([N-Object, N-Object])),
  append-conic-gradient => %(:is-symbol<gtk_snapshot_append_conic_gradient>, :returns(void) :parameters([N-Object, N-Object, gfloat, N-Object, gsize])),
  append-fill => %(:is-symbol<gtk_snapshot_append_fill>, :returns(void) :parameters([N-Object, GEnum, N-Object])),
  append-inset-shadow => %(:is-symbol<gtk_snapshot_append_inset_shadow>, :returns(void) :parameters([N-Object, N-Object, gfloat, gfloat, gfloat, gfloat])),
  append-layout => %(:is-symbol<gtk_snapshot_append_layout>, :returns(void) :parameters([N-Object, N-Object])),
  append-linear-gradient => %(:is-symbol<gtk_snapshot_append_linear_gradient>, :returns(void) :parameters([N-Object, N-Object, N-Object, N-Object, gsize])),
  append-node => %(:is-symbol<gtk_snapshot_append_node>, :returns(void) :parameters([N-Object])),
  append-outset-shadow => %(:is-symbol<gtk_snapshot_append_outset_shadow>, :returns(void) :parameters([N-Object, N-Object, gfloat, gfloat, gfloat, gfloat])),
  append-radial-gradient => %(:is-symbol<gtk_snapshot_append_radial_gradient>, :returns(void) :parameters([N-Object, N-Object, gfloat, gfloat, gfloat, gfloat, N-Object, gsize])),
  append-repeating-linear-gradient => %(:is-symbol<gtk_snapshot_append_repeating_linear_gradient>, :returns(void) :parameters([N-Object, N-Object, N-Object, N-Object, gsize])),
  append-repeating-radial-gradient => %(:is-symbol<gtk_snapshot_append_repeating_radial_gradient>, :returns(void) :parameters([N-Object, N-Object, gfloat, gfloat, gfloat, gfloat, N-Object, gsize])),
  append-scaled-texture => %(:is-symbol<gtk_snapshot_append_scaled_texture>, :returns(void) :parameters([N-Object, GEnum, N-Object])),
  append-stroke => %(:is-symbol<gtk_snapshot_append_stroke>, :returns(void) :parameters([N-Object, N-Object, N-Object])),
  append-texture => %(:is-symbol<gtk_snapshot_append_texture>, :returns(void) :parameters([N-Object, N-Object])),
  free-to-node => %(:is-symbol<gtk_snapshot_free_to_node>, :returns(N-Object)),
  free-to-paintable => %(:is-symbol<gtk_snapshot_free_to_paintable>, :returns(N-Object) :parameters([N-Object])),
  gl-shader-pop-texture => %(:is-symbol<gtk_snapshot_gl_shader_pop_texture>, :returns(void)),
  perspective => %(:is-symbol<gtk_snapshot_perspective>, :returns(void) :parameters([gfloat])),
  pop => %(:is-symbol<gtk_snapshot_pop>, :returns(void)),
  push-blend => %(:is-symbol<gtk_snapshot_push_blend>, :returns(void) :parameters([GEnum])),
  push-blur => %(:is-symbol<gtk_snapshot_push_blur>, :returns(void) :parameters([gdouble])),
  push-clip => %(:is-symbol<gtk_snapshot_push_clip>, :returns(void) :parameters([N-Object])),
  push-color-matrix => %(:is-symbol<gtk_snapshot_push_color_matrix>, :returns(void) :parameters([N-Object, N-Object])),
  push-cross-fade => %(:is-symbol<gtk_snapshot_push_cross_fade>, :returns(void) :parameters([gdouble])),
  push-debug => %(:is-symbol<gtk_snapshot_push_debug>, :variable-list, :returns(void) :parameters([Str])),
  push-fill => %(:is-symbol<gtk_snapshot_push_fill>, :returns(void) :parameters([N-Object, GEnum])),
  push-gl-shader => %(:is-symbol<gtk_snapshot_push_gl_shader>, :returns(void) :parameters([N-Object, N-Object, N-Object])),
  push-mask => %(:is-symbol<gtk_snapshot_push_mask>, :returns(void) :parameters([GEnum])),
  push-opacity => %(:is-symbol<gtk_snapshot_push_opacity>, :returns(void) :parameters([gdouble])),
  push-repeat => %(:is-symbol<gtk_snapshot_push_repeat>, :returns(void) :parameters([N-Object, N-Object])),
  push-rounded-clip => %(:is-symbol<gtk_snapshot_push_rounded_clip>, :returns(void) :parameters([N-Object])),
  push-shadow => %(:is-symbol<gtk_snapshot_push_shadow>, :returns(void) :parameters([N-Object, gsize])),
  push-stroke => %(:is-symbol<gtk_snapshot_push_stroke>, :returns(void) :parameters([N-Object, N-Object])),
  render-background => %(:is-symbol<gtk_snapshot_render_background>, :returns(void) :parameters([N-Object, gdouble, gdouble, gdouble, gdouble]),:deprecated, :deprecated-version<4.10>, ),
  render-focus => %(:is-symbol<gtk_snapshot_render_focus>, :returns(void) :parameters([N-Object, gdouble, gdouble, gdouble, gdouble]),:deprecated, :deprecated-version<4.10>, ),
  render-frame => %(:is-symbol<gtk_snapshot_render_frame>, :returns(void) :parameters([N-Object, gdouble, gdouble, gdouble, gdouble]),:deprecated, :deprecated-version<4.10>, ),
  render-insertion-cursor => %(:is-symbol<gtk_snapshot_render_insertion_cursor>, :returns(void) :parameters([N-Object, gdouble, gdouble, N-Object, gint, GEnum]),:deprecated, :deprecated-version<4.10>, ),
  render-layout => %(:is-symbol<gtk_snapshot_render_layout>, :returns(void) :parameters([N-Object, gdouble, gdouble, N-Object]),:deprecated, :deprecated-version<4.10>, ),
  restore => %(:is-symbol<gtk_snapshot_restore>, :returns(void)),
  rotate => %(:is-symbol<gtk_snapshot_rotate>, :returns(void) :parameters([gfloat])),
  rotate3d => %(:is-symbol<gtk_snapshot_rotate_3d>, :returns(void) :parameters([gfloat, N-Object])),
  save => %(:is-symbol<gtk_snapshot_save>, :returns(void)),
  scale => %(:is-symbol<gtk_snapshot_scale>, :returns(void) :parameters([gfloat, gfloat])),
  scale3d => %(:is-symbol<gtk_snapshot_scale_3d>, :returns(void) :parameters([gfloat, gfloat, gfloat])),
  to-node => %(:is-symbol<gtk_snapshot_to_node>, :returns(N-Object)),
  to-paintable => %(:is-symbol<gtk_snapshot_to_paintable>, :returns(N-Object) :parameters([N-Object])),
  transform => %(:is-symbol<gtk_snapshot_transform>, :returns(void) :parameters([N-Object])),
  transform-matrix => %(:is-symbol<gtk_snapshot_transform_matrix>, :returns(void) :parameters([N-Object])),
  translate => %(:is-symbol<gtk_snapshot_translate>, :returns(void) :parameters([N-Object])),
  translate3d => %(:is-symbol<gtk_snapshot_translate_3d>, :returns(void) :parameters([N-Object])),
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
