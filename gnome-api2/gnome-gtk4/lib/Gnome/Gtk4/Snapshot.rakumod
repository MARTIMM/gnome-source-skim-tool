=comment Package: Gtk4, C-Source: snapshot
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


#use Gnome::Cairo::N-Context:api<2>;

use Gnome::GObject::Object:api<2>;

use Gnome::Gdk4::N-RGBA:api<2>;
use Gnome::Gdk4::T-rgba:api<2>;
use Gnome::Gdk4::Snapshot:api<2>;

#use Gnome::Glib::N-Bytes:api<2>;

#use Gnome::Gsk4::N-ColorStop:api<2>;
#use Gnome::Gsk4::N-RoundedRect:api<2>;
#use Gnome::Gsk4::N-Shadow:api<2>;
#use Gnome::Gsk4::N-Transform:api<2>;
#use Gnome::Gsk4::T-Enums:api<2>;

use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;

use Gnome::Pango::T-Direction:api<2>;


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
  #append-border => %(:is-symbol<gtk_snapshot_append_border>,  :parameters([N-RoundedRect , , N-RGBA])),
  #append-cairo => %(:is-symbol<gtk_snapshot_append_cairo>,  :returns(N-_t )),
  append-color => %(:is-symbol<gtk_snapshot_append_color>,  :parameters([N-RGBA, N-Object])),
  #append-conic-gradient => %(:is-symbol<gtk_snapshot_append_conic_gradient>,  :parameters([, , gfloat, N-ColorStop , gsize])),
  #append-inset-shadow => %(:is-symbol<gtk_snapshot_append_inset_shadow>,  :parameters([N-RoundedRect , N-RGBA, gfloat, gfloat, gfloat, gfloat])),
  append-layout => %(:is-symbol<gtk_snapshot_append_layout>,  :parameters([N-Object, N-RGBA])),
  #append-linear-gradient => %(:is-symbol<gtk_snapshot_append_linear_gradient>,  :parameters([, , , N-ColorStop , gsize])),
  append-node => %(:is-symbol<gtk_snapshot_append_node>,  :parameters([N-Object])),
  #append-outset-shadow => %(:is-symbol<gtk_snapshot_append_outset_shadow>,  :parameters([N-RoundedRect , N-RGBA, gfloat, gfloat, gfloat, gfloat])),
  #append-radial-gradient => %(:is-symbol<gtk_snapshot_append_radial_gradient>,  :parameters([, , gfloat, gfloat, gfloat, gfloat, N-ColorStop , gsize])),
  #append-repeating-linear-gradient => %(:is-symbol<gtk_snapshot_append_repeating_linear_gradient>,  :parameters([, , , N-ColorStop , gsize])),
  #append-repeating-radial-gradient => %(:is-symbol<gtk_snapshot_append_repeating_radial_gradient>,  :parameters([, , gfloat, gfloat, gfloat, gfloat, N-ColorStop , gsize])),
  #append-texture => %(:is-symbol<gtk_snapshot_append_texture>,  :parameters([N-Object, ])),
  free-to-node => %(:is-symbol<gtk_snapshot_free_to_node>,  :returns(N-Object)),
  #free-to-paintable => %(:is-symbol<gtk_snapshot_free_to_paintable>,  :returns(N-Object)),
  gl-shader-pop-texture => %(:is-symbol<gtk_snapshot_gl_shader_pop_texture>, ),
  perspective => %(:is-symbol<gtk_snapshot_perspective>,  :parameters([gfloat])),
  pop => %(:is-symbol<gtk_snapshot_pop>, ),
  #push-blend => %(:is-symbol<gtk_snapshot_push_blend>,  :parameters([GEnum])),
  push-blur => %(:is-symbol<gtk_snapshot_push_blur>,  :parameters([gdouble])),
  #push-clip => %(:is-symbol<gtk_snapshot_push_clip>, ),
  #push-color-matrix => %(:is-symbol<gtk_snapshot_push_color_matrix>,  :parameters([, ])),
  push-cross-fade => %(:is-symbol<gtk_snapshot_push_cross_fade>,  :parameters([gdouble])),
  push-debug => %(:is-symbol<gtk_snapshot_push_debug>, :variable-list,  :parameters([Str])),
  #push-gl-shader => %(:is-symbol<gtk_snapshot_push_gl_shader>,  :parameters([N-Object, , N-Bytes ])),
  push-opacity => %(:is-symbol<gtk_snapshot_push_opacity>,  :parameters([gdouble])),
  #push-repeat => %(:is-symbol<gtk_snapshot_push_repeat>,  :parameters([, ])),
  #push-rounded-clip => %(:is-symbol<gtk_snapshot_push_rounded_clip>,  :parameters([N-RoundedRect ])),
  #push-shadow => %(:is-symbol<gtk_snapshot_push_shadow>,  :parameters([N-Shadow , gsize])),
  render-background => %(:is-symbol<gtk_snapshot_render_background>,  :parameters([N-Object, gdouble, gdouble, gdouble, gdouble])),
  render-focus => %(:is-symbol<gtk_snapshot_render_focus>,  :parameters([N-Object, gdouble, gdouble, gdouble, gdouble])),
  render-frame => %(:is-symbol<gtk_snapshot_render_frame>,  :parameters([N-Object, gdouble, gdouble, gdouble, gdouble])),
  render-insertion-cursor => %(:is-symbol<gtk_snapshot_render_insertion_cursor>,  :parameters([N-Object, gdouble, gdouble, N-Object, gint, GEnum])),
  render-layout => %(:is-symbol<gtk_snapshot_render_layout>,  :parameters([N-Object, gdouble, gdouble, N-Object])),
  restore => %(:is-symbol<gtk_snapshot_restore>, ),
  rotate => %(:is-symbol<gtk_snapshot_rotate>,  :parameters([gfloat])),
  #rotate3d => %(:is-symbol<gtk_snapshot_rotate_3d>,  :parameters([gfloat, ])),
  save => %(:is-symbol<gtk_snapshot_save>, ),
  scale => %(:is-symbol<gtk_snapshot_scale>,  :parameters([gfloat, gfloat])),
  scale3d => %(:is-symbol<gtk_snapshot_scale_3d>,  :parameters([gfloat, gfloat, gfloat])),
  to-node => %(:is-symbol<gtk_snapshot_to_node>,  :returns(N-Object)),
  to-paintable => %(:is-symbol<gtk_snapshot_to_paintable>,  :returns(N-Object)  :parameters([N-Object],)),
  #transform => %(:is-symbol<gtk_snapshot_transform>,  :parameters([N-Transform ])),
  #transform-matrix => %(:is-symbol<gtk_snapshot_transform_matrix>, ),
  #translate => %(:is-symbol<gtk_snapshot_translate>, ),
  #translate3d => %(:is-symbol<gtk_snapshot_translate_3d>, ),
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
