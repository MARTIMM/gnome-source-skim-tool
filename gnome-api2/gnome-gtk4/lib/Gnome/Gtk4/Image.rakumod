=comment Package: Gtk4, C-Source: image
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;




use Gnome::Gtk4::T-enums:api<2>;
use Gnome::Gtk4::T-image:api<2>;
use Gnome::Gtk4::Widget:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::Image:auth<github:MARTIMM>:api<2>;
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
  if self.^name eq 'Gnome::Gtk4::Image' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkImage');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-image => %( :type(Constructor), :is-symbol<gtk_image_new>, :returns(N-Object), ),
  new-from-file => %( :type(Constructor), :is-symbol<gtk_image_new_from_file>, :returns(N-Object), :parameters([ Str]), ),
  new-from-gicon => %( :type(Constructor), :is-symbol<gtk_image_new_from_gicon>, :returns(N-Object), :parameters([ N-Object]), ),
  new-from-icon-name => %( :type(Constructor), :is-symbol<gtk_image_new_from_icon_name>, :returns(N-Object), :parameters([ Str]), ),
  new-from-paintable => %( :type(Constructor), :is-symbol<gtk_image_new_from_paintable>, :returns(N-Object), :parameters([ N-Object]), ),
  new-from-pixbuf => %( :type(Constructor), :is-symbol<gtk_image_new_from_pixbuf>, :returns(N-Object), :deprecated, :deprecated-version<4.12>, :parameters([ N-Object]), ),
  new-from-resource => %( :type(Constructor), :is-symbol<gtk_image_new_from_resource>, :returns(N-Object), :parameters([ Str]), ),

  #--[Methods]------------------------------------------------------------------
  clear => %(:is-symbol<gtk_image_clear>, ),
  get-gicon => %(:is-symbol<gtk_image_get_gicon>, :returns(N-Object), ),
  get-icon-name => %(:is-symbol<gtk_image_get_icon_name>, :returns(Str), ),
  get-icon-size => %(:is-symbol<gtk_image_get_icon_size>,  :returns(GEnum), :cnv-return(GtkIconSize)),
  get-paintable => %(:is-symbol<gtk_image_get_paintable>, :returns(N-Object), ),
  get-pixel-size => %(:is-symbol<gtk_image_get_pixel_size>, :returns(gint), ),
  get-storage-type => %(:is-symbol<gtk_image_get_storage_type>,  :returns(GEnum), :cnv-return(GtkImageType)),
  set-from-file => %(:is-symbol<gtk_image_set_from_file>, :parameters([Str]), ),
  set-from-gicon => %(:is-symbol<gtk_image_set_from_gicon>, :parameters([N-Object]), ),
  set-from-icon-name => %(:is-symbol<gtk_image_set_from_icon_name>, :parameters([Str]), ),
  set-from-paintable => %(:is-symbol<gtk_image_set_from_paintable>, :parameters([N-Object]), ),
  set-from-pixbuf => %(:is-symbol<gtk_image_set_from_pixbuf>, :parameters([N-Object]), :deprecated, :deprecated-version<4.12>, ),
  set-from-resource => %(:is-symbol<gtk_image_set_from_resource>, :parameters([Str]), ),
  set-icon-size => %(:is-symbol<gtk_image_set_icon_size>, :parameters([GEnum]), ),
  set-pixel-size => %(:is-symbol<gtk_image_set_pixel_size>, :parameters([gint]), ),
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
