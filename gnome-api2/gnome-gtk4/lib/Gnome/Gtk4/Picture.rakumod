=comment Package: Gtk4, C-Source: picture
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Gtk4::T-enums:api<2>;
use Gnome::Gtk4::Widget:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::Picture:auth<github:MARTIMM>:api<2>;
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
  if self.^name eq 'Gnome::Gtk4::Picture' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkPicture');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-picture => %( :type(Constructor), :is-symbol<gtk_picture_new>, :returns(N-Object), ),
  new-for-file => %( :type(Constructor), :is-symbol<gtk_picture_new_for_file>, :returns(N-Object), :parameters([ N-Object])),
  new-for-filename => %( :type(Constructor), :is-symbol<gtk_picture_new_for_filename>, :returns(N-Object), :parameters([ Str])),
  new-for-paintable => %( :type(Constructor), :is-symbol<gtk_picture_new_for_paintable>, :returns(N-Object), :parameters([ N-Object])),
  new-for-pixbuf => %( :type(Constructor), :is-symbol<gtk_picture_new_for_pixbuf>, :returns(N-Object), :deprecated, :deprecated-version<4.12>, :parameters([ N-Object])),
  new-for-resource => %( :type(Constructor), :is-symbol<gtk_picture_new_for_resource>, :returns(N-Object), :parameters([ Str])),

  #--[Methods]------------------------------------------------------------------
  get-alternative-text => %(:is-symbol<gtk_picture_get_alternative_text>,  :returns(Str)),
  get-can-shrink => %(:is-symbol<gtk_picture_get_can_shrink>,  :returns(gboolean), :cnv-return(Bool)),
  get-content-fit => %(:is-symbol<gtk_picture_get_content_fit>,  :returns(GEnum), :cnv-return(GtkContentFit)),
  get-file => %(:is-symbol<gtk_picture_get_file>,  :returns(N-Object)),
  get-keep-aspect-ratio => %(:is-symbol<gtk_picture_get_keep_aspect_ratio>,  :returns(gboolean), :cnv-return(Bool),:deprecated, :deprecated-version<4.8>, ),
  get-paintable => %(:is-symbol<gtk_picture_get_paintable>,  :returns(N-Object)),
  set-alternative-text => %(:is-symbol<gtk_picture_set_alternative_text>,  :parameters([Str])),
  set-can-shrink => %(:is-symbol<gtk_picture_set_can_shrink>,  :parameters([gboolean])),
  set-content-fit => %(:is-symbol<gtk_picture_set_content_fit>,  :parameters([GEnum])),
  set-file => %(:is-symbol<gtk_picture_set_file>,  :parameters([N-Object])),
  set-filename => %(:is-symbol<gtk_picture_set_filename>,  :parameters([Str])),
  set-keep-aspect-ratio => %(:is-symbol<gtk_picture_set_keep_aspect_ratio>,  :parameters([gboolean]),:deprecated, :deprecated-version<4.8>, ),
  set-paintable => %(:is-symbol<gtk_picture_set_paintable>,  :parameters([N-Object])),
  set-pixbuf => %(:is-symbol<gtk_picture_set_pixbuf>,  :parameters([N-Object]),:deprecated, :deprecated-version<4.12>, ),
  set-resource => %(:is-symbol<gtk_picture_set_resource>,  :parameters([Str])),
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
