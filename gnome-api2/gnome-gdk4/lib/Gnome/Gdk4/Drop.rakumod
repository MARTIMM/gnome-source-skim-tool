=comment Package: Gdk4, C-Source: drop
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::GObject::N-Value:api<2>;
use Gnome::GObject::Object:api<2>;
use Gnome::GObject::T-value:api<2>;
use Gnome::Gdk4::N-ContentFormats:api<2>;
use Gnome::Gdk4::T-enums:api<2>;
use Gnome::Gdk4::T-types:api<2>;
use Gnome::Glib::T-error:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gdk4::Drop:auth<github:MARTIMM>:api<2>;
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
  if self.^name eq 'Gnome::Gdk4::Drop' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GdkDrop');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  finish => %(:is-symbol<gdk_drop_finish>,  :parameters([GFlag])),
  get-actions => %(:is-symbol<gdk_drop_get_actions>,  :returns(GFlag), :cnv-return(GdkDragAction)),
  get-device => %(:is-symbol<gdk_drop_get_device>,  :returns(N-Object)),
  get-display => %(:is-symbol<gdk_drop_get_display>,  :returns(N-Object)),
  get-drag => %(:is-symbol<gdk_drop_get_drag>,  :returns(N-Object)),
  get-formats => %(:is-symbol<gdk_drop_get_formats>,  :returns(N-Object)),
  get-surface => %(:is-symbol<gdk_drop_get_surface>,  :returns(N-Object)),
  #read-async => %(:is-symbol<gdk_drop_read_async>,  :parameters([gchar-pptr, gint, N-Object, , gpointer])),
  read-finish => %(:is-symbol<gdk_drop_read_finish>,  :returns(N-Object), :parameters([N-Object, gchar-pptr, CArray[N-Error]])),
  #read-value-async => %(:is-symbol<gdk_drop_read_value_async>,  :parameters([GType, gint, N-Object, , gpointer])),
  read-value-finish => %(:is-symbol<gdk_drop_read_value_finish>,  :returns(N-Object), :parameters([N-Object, CArray[N-Error]])),
  status => %(:is-symbol<gdk_drop_status>,  :parameters([GFlag, GFlag])),
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
