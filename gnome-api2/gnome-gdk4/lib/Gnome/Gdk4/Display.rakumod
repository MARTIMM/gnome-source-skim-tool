=comment Package: Gdk4, C-Source: display
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;




use Gnome::GObject::N-Value:api<2>;
use Gnome::GObject::Object:api<2>;
use Gnome::GObject::T-value:api<2>;
#use Gnome::Gdk4::N-KeymapKey:api<2>;
use Gnome::Gdk4::T-enums:api<2>;
use Gnome::Gdk4::T-types:api<2>;
use Gnome::Glib::N-List:api<2>;
use Gnome::Glib::T-error:api<2>;
use Gnome::Glib::T-list:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gdk4::Display:auth<github:MARTIMM>:api<2>;
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
      :w0<opened>,
      :w1<closed seat-removed seat-added setting-changed>,
    );
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gdk4::Display' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GdkDisplay');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  beep => %(:is-symbol<gdk_display_beep>, ),
  close => %(:is-symbol<gdk_display_close>, ),
  create-gl-context => %(:is-symbol<gdk_display_create_gl_context>, :returns(N-Object), :parameters([CArray[N-Error]]), ),
  device-is-grabbed => %(:is-symbol<gdk_display_device_is_grabbed>, :returns(gboolean), :parameters([N-Object]), ),
  flush => %(:is-symbol<gdk_display_flush>, ),
  get-app-launch-context => %(:is-symbol<gdk_display_get_app_launch_context>, :returns(N-Object), ),
  get-clipboard => %(:is-symbol<gdk_display_get_clipboard>, :returns(N-Object), ),
  get-default-seat => %(:is-symbol<gdk_display_get_default_seat>, :returns(N-Object), ),
  get-monitor-at-surface => %(:is-symbol<gdk_display_get_monitor_at_surface>, :returns(N-Object), :parameters([N-Object]), ),
  get-monitors => %(:is-symbol<gdk_display_get_monitors>, :returns(N-Object), ),
  get-name => %(:is-symbol<gdk_display_get_name>, :returns(Str), ),
  get-primary-clipboard => %(:is-symbol<gdk_display_get_primary_clipboard>, :returns(N-Object), ),
  get-setting => %(:is-symbol<gdk_display_get_setting>, :returns(gboolean), :parameters([Str, N-Object]), ),
  get-startup-notification-id => %(:is-symbol<gdk_display_get_startup_notification_id>, :returns(Str), ),
  is-closed => %(:is-symbol<gdk_display_is_closed>, :returns(gboolean), ),
  is-composited => %(:is-symbol<gdk_display_is_composited>, :returns(gboolean), ),
  is-rgba => %(:is-symbol<gdk_display_is_rgba>, :returns(gboolean), ),
  list-seats => %(:is-symbol<gdk_display_list_seats>, :returns(N-Object), ),
  map-keycode => %(:is-symbol<gdk_display_map_keycode>, :returns(gboolean), :parameters([guint, N-Object, gint-ptr, gint-ptr]), ),
  map-keyval => %(:is-symbol<gdk_display_map_keyval>, :returns(gboolean), :parameters([guint, N-Object, gint-ptr]), ),
  notify-startup-complete => %(:is-symbol<gdk_display_notify_startup_complete>, :parameters([Str]), ),
  prepare-gl => %(:is-symbol<gdk_display_prepare_gl>, :returns(gboolean), :parameters([CArray[N-Error]]), ),
  put-event => %(:is-symbol<gdk_display_put_event>, :parameters([N-Object]), ),
  supports-input-shapes => %(:is-symbol<gdk_display_supports_input_shapes>, :returns(gboolean), ),
  sync => %(:is-symbol<gdk_display_sync>, ),
  translate-key => %(:is-symbol<gdk_display_translate_key>, :returns(gboolean), :parameters([guint, GFlag, gint, gint-ptr, gint-ptr, gint-ptr, GFlag]), ),

  #--[Functions]----------------------------------------------------------------
  get-default => %( :type(Function), :is-symbol<gdk_display_get_default>, :returns(N-Object), ),
  open => %( :type(Function), :is-symbol<gdk_display_open>, :returns(N-Object), :parameters([Str]), ),
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
