=comment Package: Gtk4, C-Source: printoperationpreview
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;



use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;


#-------------------------------------------------------------------------------
#--[Role Declaration]-----------------------------------------------------------
#-------------------------------------------------------------------------------

unit role Gnome::Gtk4::R-PrintOperationPreview:auth<github:MARTIMM>:api<2>;

#TM:1:_add_gtk_print_operation_preview_signal_types:
method _add_gtk_print_operation_preview_signal_types ( Str $class-name ) {
  self.add-signal-types( $class-name,
    :w1<ready>,
    :w2<got-page-size>,
  );
}


#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  end-preview => %(:is-symbol<gtk_print_operation_preview_end_preview>, ),
  is-selected => %(:is-symbol<gtk_print_operation_preview_is_selected>, :returns(gboolean), :cnv-return(Bool), :parameters([gint]), ),
  render-page => %(:is-symbol<gtk_print_operation_preview_render_page>, :parameters([gint]), ),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _do_gtk_print_operation_preview_fallback-v2 (
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
