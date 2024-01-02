=comment Package: Gdk4, C-Source: texture
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::GObject::Object:api<2>;
#use Gnome::Gdk4::R-Paintable:api<2>;
#use Gnome::Glib::N-Bytes:api<2>;
use Gnome::Glib::N-Error:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gdk4::Texture:auth<github:MARTIMM>:api<2>;
also is Gnome::GObject::Object;
#also does Gnome::Gdk4::R-Paintable;

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
    
    # Signals from interfaces
#`{{
    self._add_gdk_paintable_signal_types($?CLASS.^name)
      if self.^can('_add_gdk_paintable_signal_types');
}}
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gdk4::Texture' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GdkTexture');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-for-pixbuf => %( :type(Constructor), :is-symbol<gdk_texture_new_for_pixbuf>, :returns(N-Object), :parameters([ N-Object])),
  #new-from-bytes => %( :type(Constructor), :is-symbol<gdk_texture_new_from_bytes>, :returns(N-Object), :parameters([ N-Bytes , CArray[N-Error]])),
  new-from-file => %( :type(Constructor), :is-symbol<gdk_texture_new_from_file>, :returns(N-Object), :parameters([ N-Object, CArray[N-Error]])),
  new-from-filename => %( :type(Constructor), :is-symbol<gdk_texture_new_from_filename>, :returns(N-Object), :parameters([ Str, CArray[N-Error]])),
  new-from-resource => %( :type(Constructor), :is-symbol<gdk_texture_new_from_resource>, :returns(N-Object), :parameters([ Str])),

  #--[Methods]------------------------------------------------------------------
  download => %(:is-symbol<gdk_texture_download>,  :parameters([Str, gsize])),
  get-height => %(:is-symbol<gdk_texture_get_height>,  :returns(gint)),
  get-width => %(:is-symbol<gdk_texture_get_width>,  :returns(gint)),
  save-to-png => %(:is-symbol<gdk_texture_save_to_png>,  :returns(gboolean), :cnv-return(Bool), :parameters([Str])),
  #save-to-png-bytes => %(:is-symbol<gdk_texture_save_to_png_bytes>,  :returns(N-Bytes )),
  save-to-tiff => %(:is-symbol<gdk_texture_save_to_tiff>,  :returns(gboolean), :cnv-return(Bool), :parameters([Str])),
  #save-to-tiff-bytes => %(:is-symbol<gdk_texture_save_to_tiff_bytes>,  :returns(N-Bytes )),
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
    my $r;
    my $native-object = self.get-native-object-no-reffing;
#`{{
    $r = self._do_gdk_paintable_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    ) if self.^can('_do_gdk_paintable_fallback-v2');
    return $r if $_fallback-v2-ok;

}}
    callsame;
  }
}
