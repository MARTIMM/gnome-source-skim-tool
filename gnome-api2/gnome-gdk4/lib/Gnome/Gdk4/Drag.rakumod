=comment Package: Gdk4, C-Source: drag
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::GObject::Object:api<2>;
use Gnome::Gdk4::N-ContentFormats:api<2>;
use Gnome::Gdk4::T-enums:api<2>;
use Gnome::Gdk4::T-types:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gdk4::Drag:auth<github:MARTIMM>:api<2>;
also is Gnome::GObject::Object;

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

  # Add signal administration info.
  unless $signals-added {
    self.add-signal-types( $?CLASS.^name,
      :w0<dnd-finished drop-performed>,
      :w1<cancel>,
    );
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gdk4::Drag' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GdkDrag');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  drop-done => %(:is-symbol<gdk_drag_drop_done>,  :parameters([gboolean])),
  get-actions => %(:is-symbol<gdk_drag_get_actions>,  :returns(GFlag), :cnv-return(GdkDragAction)),
  get-content => %(:is-symbol<gdk_drag_get_content>,  :returns(N-Object)),
  get-device => %(:is-symbol<gdk_drag_get_device>,  :returns(N-Object)),
  get-display => %(:is-symbol<gdk_drag_get_display>,  :returns(N-Object)),
  get-drag-surface => %(:is-symbol<gdk_drag_get_drag_surface>,  :returns(N-Object)),
  get-formats => %(:is-symbol<gdk_drag_get_formats>,  :returns(N-Object)),
  get-selected-action => %(:is-symbol<gdk_drag_get_selected_action>,  :returns(GFlag), :cnv-return(GdkDragAction)),
  get-surface => %(:is-symbol<gdk_drag_get_surface>,  :returns(N-Object)),
  set-hotspot => %(:is-symbol<gdk_drag_set_hotspot>,  :parameters([gint, gint])),

  #--[Functions]----------------------------------------------------------------
  begin => %( :type(Function), :is-symbol<gdk_drag_begin>,  :returns(N-Object), :parameters([ UInt, gdouble, gdouble])),
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
