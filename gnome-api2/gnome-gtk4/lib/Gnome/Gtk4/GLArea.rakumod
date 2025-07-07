=comment Package: Gtk4, C-Source: glarea
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Cairo;


#use Gnome::Gdk4::T-glcontext:api<2>;
use Gnome::Glib::N-Error:api<2>;
use Gnome::Glib::T-error:api<2>;
use Gnome::Gtk4::Widget:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::GLArea:auth<github:MARTIMM>:api<2>;
also is Gnome::Gtk4::Widget;

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
      :w0<create-context>,
      :w1<render>,
      :w2<resize>,
    );
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::GLArea' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkGLArea');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-glarea => %( :type(Constructor), :is-symbol<gtk_g_l_area_new>, :returns(N-Object), ),

  #--[Methods]------------------------------------------------------------------
  attach-buffers => %(:is-symbol<gtk_g_l_area_attach_buffers>, ),
  #get-allowed-apis => %(:is-symbol<gtk_g_l_area_get_allowed_apis>,  :returns(GFlag), :cnv-return(GdkGLAPI )),
  #get-api => %(:is-symbol<gtk_g_l_area_get_api>,  :returns(GFlag), :cnv-return(GdkGLAPI )),
  get-auto-render => %(:is-symbol<gtk_g_l_area_get_auto_render>, :returns(gboolean), ),
  get-context => %(:is-symbol<gtk_g_l_area_get_context>, :returns(N-Object), ),
  get-error => %(:is-symbol<gtk_g_l_area_get_error>, :returns(N-Object), ),
  get-has-depth-buffer => %(:is-symbol<gtk_g_l_area_get_has_depth_buffer>, :returns(gboolean), ),
  get-has-stencil-buffer => %(:is-symbol<gtk_g_l_area_get_has_stencil_buffer>, :returns(gboolean), ),
  get-required-version => %(:is-symbol<gtk_g_l_area_get_required_version>, :parameters([gint-ptr, gint-ptr]), ),
  get-use-es => %(:is-symbol<gtk_g_l_area_get_use_es>, :returns(gboolean), :deprecated, :deprecated-version<4.12>, ),
  make-current => %(:is-symbol<gtk_g_l_area_make_current>, ),
  queue-render => %(:is-symbol<gtk_g_l_area_queue_render>, ),
  #set-allowed-apis => %(:is-symbol<gtk_g_l_area_set_allowed_apis>, :parameters([GFlag]), ),
  set-auto-render => %(:is-symbol<gtk_g_l_area_set_auto_render>, :parameters([gboolean]), ),
  set-error => %(:is-symbol<gtk_g_l_area_set_error>, :parameters([N-Object]), ),
  set-has-depth-buffer => %(:is-symbol<gtk_g_l_area_set_has_depth_buffer>, :parameters([gboolean]), ),
  set-has-stencil-buffer => %(:is-symbol<gtk_g_l_area_set_has_stencil_buffer>, :parameters([gboolean]), ),
  set-required-version => %(:is-symbol<gtk_g_l_area_set_required_version>, :parameters([gint, gint]), ),
  set-use-es => %(:is-symbol<gtk_g_l_area_set_use_es>, :parameters([gboolean]), :deprecated, :deprecated-version<4.12>, ),
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
