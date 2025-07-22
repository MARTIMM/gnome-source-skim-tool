=comment Package: Gtk4, C-Source: cellrenderer
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Cairo;


use Gnome::GObject::InitiallyUnowned:api<2>;
use Gnome::Gdk4::N-Rectangle:api<2>;
use Gnome::Gdk4::T-types:api<2>;
use Gnome::Gtk4::N-Requisition:api<2>;
use Gnome::Gtk4::T-cellrenderer:api<2>;
use Gnome::Gtk4::T-enums:api<2>;
use Gnome::Gtk4::T-widget:api<2>;
#use Gnome::N:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::CellRenderer:auth<github:MARTIMM>:api<2>;
also is Gnome::GObject::InitiallyUnowned;

#-------------------------------------------------------------------------------
#--[BUILD variables]------------------------------------------------------------
#-------------------------------------------------------------------------------

# Define callable helper
has Gnome::N::GnomeRoutineCaller $!routine-caller;

# Add signal registration helper
my Bool $signals-added = False;

#-------------------------------------------------------------------------------
#--[BUILD submethod]------------------------------------------------------------
#-------------------------------------------------------------------------------

submethod BUILD ( *%options ) {

  Gnome::N::deprecate(
    'Gnome::Gtk4::CellRenderer', ', Str, ',
    '4.10', Str,
    :class, :gnome-lib(gtk4-lib())  
  );

  # Add signal administration info.
  unless $signals-added {
    self.add-signal-types( $?CLASS.^name,
      :w0<editing-canceled>,
      :w2<editing-started>,
    );
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::CellRenderer' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkCellRenderer');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  activate => %(:is-symbol<gtk_cell_renderer_activate>, :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, N-Object, Str, N-Object, N-Object, GFlag]), :deprecated, :deprecated-version<4.10>, ),
  get-aligned-area => %(:is-symbol<gtk_cell_renderer_get_aligned_area>, :parameters([N-Object, GFlag, N-Object, N-Object]), :deprecated, :deprecated-version<4.10>, ),
  get-alignment => %(:is-symbol<gtk_cell_renderer_get_alignment>, :parameters([CArray[gfloat], CArray[gfloat]]), :deprecated, :deprecated-version<4.10>, ),
  get-fixed-size => %(:is-symbol<gtk_cell_renderer_get_fixed_size>, :parameters([gint-ptr, gint-ptr]), :deprecated, :deprecated-version<4.10>, ),
  get-is-expanded => %(:is-symbol<gtk_cell_renderer_get_is_expanded>, :returns(gboolean), :cnv-return(Bool), :deprecated, :deprecated-version<4.10>, ),
  get-is-expander => %(:is-symbol<gtk_cell_renderer_get_is_expander>, :returns(gboolean), :cnv-return(Bool), :deprecated, :deprecated-version<4.10>, ),
  get-padding => %(:is-symbol<gtk_cell_renderer_get_padding>, :parameters([gint-ptr, gint-ptr]), :deprecated, :deprecated-version<4.10>, ),
  get-preferred-height => %(:is-symbol<gtk_cell_renderer_get_preferred_height>, :parameters([N-Object, gint-ptr, gint-ptr]), :deprecated, :deprecated-version<4.10>, ),
  get-preferred-height-for-width => %(:is-symbol<gtk_cell_renderer_get_preferred_height_for_width>, :parameters([N-Object, gint, gint-ptr, gint-ptr]), :deprecated, :deprecated-version<4.10>, ),
  get-preferred-size => %(:is-symbol<gtk_cell_renderer_get_preferred_size>, :parameters([N-Object, N-Object, N-Object]), :deprecated, :deprecated-version<4.10>, ),
  get-preferred-width => %(:is-symbol<gtk_cell_renderer_get_preferred_width>, :parameters([N-Object, gint-ptr, gint-ptr]), :deprecated, :deprecated-version<4.10>, ),
  get-preferred-width-for-height => %(:is-symbol<gtk_cell_renderer_get_preferred_width_for_height>, :parameters([N-Object, gint, gint-ptr, gint-ptr]), :deprecated, :deprecated-version<4.10>, ),
  get-request-mode => %(:is-symbol<gtk_cell_renderer_get_request_mode>,  :returns(GEnum), :cnv-return(GtkSizeRequestMode),:deprecated, :deprecated-version<4.10>, ),
  get-sensitive => %(:is-symbol<gtk_cell_renderer_get_sensitive>, :returns(gboolean), :cnv-return(Bool), :deprecated, :deprecated-version<4.10>, ),
  get-state => %(:is-symbol<gtk_cell_renderer_get_state>,  :returns(GFlag), :cnv-return(GtkStateFlags),:parameters([N-Object, GFlag]), :deprecated, :deprecated-version<4.10>, ),
  get-visible => %(:is-symbol<gtk_cell_renderer_get_visible>, :returns(gboolean), :cnv-return(Bool), :deprecated, :deprecated-version<4.10>, ),
  is-activatable => %(:is-symbol<gtk_cell_renderer_is_activatable>, :returns(gboolean), :cnv-return(Bool), :deprecated, :deprecated-version<4.10>, ),
  set-alignment => %(:is-symbol<gtk_cell_renderer_set_alignment>, :parameters([gfloat, gfloat]), :deprecated, :deprecated-version<4.10>, ),
  set-fixed-size => %(:is-symbol<gtk_cell_renderer_set_fixed_size>, :parameters([gint, gint]), :deprecated, :deprecated-version<4.10>, ),
  set-is-expanded => %(:is-symbol<gtk_cell_renderer_set_is_expanded>, :parameters([gboolean]), :deprecated, :deprecated-version<4.10>, ),
  set-is-expander => %(:is-symbol<gtk_cell_renderer_set_is_expander>, :parameters([gboolean]), :deprecated, :deprecated-version<4.10>, ),
  set-padding => %(:is-symbol<gtk_cell_renderer_set_padding>, :parameters([gint, gint]), :deprecated, :deprecated-version<4.10>, ),
  set-sensitive => %(:is-symbol<gtk_cell_renderer_set_sensitive>, :parameters([gboolean]), :deprecated, :deprecated-version<4.10>, ),
  set-visible => %(:is-symbol<gtk_cell_renderer_set_visible>, :parameters([gboolean]), :deprecated, :deprecated-version<4.10>, ),
  snapshot => %(:is-symbol<gtk_cell_renderer_snapshot>, :parameters([N-Object, N-Object, N-Object, N-Object, GFlag]), :deprecated, :deprecated-version<4.10>, ),
  start-editing => %(:is-symbol<gtk_cell_renderer_start_editing>, :returns(N-Object), :parameters([N-Object, N-Object, Str, N-Object, N-Object, GFlag]), :deprecated, :deprecated-version<4.10>, ),
  stop-editing => %(:is-symbol<gtk_cell_renderer_stop_editing>, :parameters([gboolean]), :deprecated, :deprecated-version<4.10>, ),
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
