=comment Package: Gdk4, C-Source: paintable
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Gdk4::T-Paintable:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;


#-------------------------------------------------------------------------------
#--[Role Declaration]-----------------------------------------------------------
#-------------------------------------------------------------------------------

unit role Gnome::Gdk4::R-Paintable:auth<github:MARTIMM>:api<2>;

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  compute-concrete-size => %(:is-symbol<gdk_paintable_compute_concrete_size>,  :parameters([gdouble, gdouble, gdouble, gdouble, CArray[gdouble], CArray[gdouble]])),
  get-current-image => %(:is-symbol<gdk_paintable_get_current_image>,  :returns(N-Object)),
  get-flags => %(:is-symbol<gdk_paintable_get_flags>,  :returns(GFlag), :cnv-return(GdkPaintableFlags)),
  get-intrinsic-aspect-ratio => %(:is-symbol<gdk_paintable_get_intrinsic_aspect_ratio>,  :returns(gdouble)),
  get-intrinsic-height => %(:is-symbol<gdk_paintable_get_intrinsic_height>,  :returns(gint)),
  get-intrinsic-width => %(:is-symbol<gdk_paintable_get_intrinsic_width>,  :returns(gint)),
  invalidate-contents => %(:is-symbol<gdk_paintable_invalidate_contents>, ),
  invalidate-size => %(:is-symbol<gdk_paintable_invalidate_size>, ),
  snapshot => %(:is-symbol<gdk_paintable_snapshot>,  :parameters([N-Object, gdouble, gdouble])),

  #--[Functions]----------------------------------------------------------------
  new-empty => %( :type(Function), :is-symbol<gdk_paintable_new_empty>,  :returns(N-Object), :parameters([ gint, gint])),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _do_gdk_paintable_fallback-v2 (
  Str $name, Bool $_fallback-v2-ok is rw,
  Gnome::N::GnomeRoutineCaller $routine-caller, @arguments, $native-object
) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    return $routine-caller.call-native-sub(
      $name, @arguments, $methods, $native-object
    );
  }
}
