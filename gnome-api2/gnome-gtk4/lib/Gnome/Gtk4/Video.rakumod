=comment Package: Gtk4, C-Source: video
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;




#use Gnome::Gtk4::T-graphicsoffload:api<2>;
use Gnome::Gtk4::Widget:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::Video:auth<github:MARTIMM>:api<2>;
also is Gnome::Gtk4::Widget;

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
  if self.^name eq 'Gnome::Gtk4::Video' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkVideo');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-video => %( :type(Constructor), :is-symbol<gtk_video_new>, :returns(N-Object), ),
  new-for-file => %( :type(Constructor), :is-symbol<gtk_video_new_for_file>, :returns(N-Object), :parameters([ N-Object]), ),
  new-for-filename => %( :type(Constructor), :is-symbol<gtk_video_new_for_filename>, :returns(N-Object), :parameters([ Str]), ),
  new-for-media-stream => %( :type(Constructor), :is-symbol<gtk_video_new_for_media_stream>, :returns(N-Object), :parameters([ N-Object]), ),
  new-for-resource => %( :type(Constructor), :is-symbol<gtk_video_new_for_resource>, :returns(N-Object), :parameters([ Str]), ),

  #--[Methods]------------------------------------------------------------------
  get-autoplay => %(:is-symbol<gtk_video_get_autoplay>, :returns(gboolean), ),
  get-file => %(:is-symbol<gtk_video_get_file>, :returns(N-Object), ),
  #get-graphics-offload => %(:is-symbol<gtk_video_get_graphics_offload>,  :returns(GEnum), :cnv-return(GtkGraphicsOffloadEnabled )),
  get-loop => %(:is-symbol<gtk_video_get_loop>, :returns(gboolean), ),
  get-media-stream => %(:is-symbol<gtk_video_get_media_stream>, :returns(N-Object), ),
  set-autoplay => %(:is-symbol<gtk_video_set_autoplay>, :parameters([gboolean]), ),
  set-file => %(:is-symbol<gtk_video_set_file>, :parameters([N-Object]), ),
  set-filename => %(:is-symbol<gtk_video_set_filename>, :parameters([Str]), ),
  #set-graphics-offload => %(:is-symbol<gtk_video_set_graphics_offload>, :parameters([GEnum]), ),
  set-loop => %(:is-symbol<gtk_video_set_loop>, :parameters([gboolean]), ),
  set-media-stream => %(:is-symbol<gtk_video_set_media_stream>, :parameters([N-Object]), ),
  set-resource => %(:is-symbol<gtk_video_set_resource>, :parameters([Str]), ),
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
