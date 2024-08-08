=comment Package: Gtk4, C-Source: droptarget
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::GObject::N-Value:api<2>;
use Gnome::GObject::T-value:api<2>;
use Gnome::Gdk4::N-ContentFormats:api<2>;
use Gnome::Gdk4::T-enums:api<2>;
use Gnome::Gdk4::T-types:api<2>;
use Gnome::Gtk4::EventController:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::DropTarget:auth<github:MARTIMM>:api<2>;
also is Gnome::Gtk4::EventController;

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
      :w0<leave>,
      :w1<accept>,
      :w2<motion enter>,
      :w3<drop>,
    );
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::DropTarget' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkDropTarget');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-droptarget => %( :type(Constructor), :is-symbol<gtk_drop_target_new>, :returns(N-Object), :parameters([ GType, GFlag])),

  #--[Methods]------------------------------------------------------------------
  get-actions => %(:is-symbol<gtk_drop_target_get_actions>,  :returns(GFlag), :cnv-return(GdkDragAction)),
  get-current-drop => %(:is-symbol<gtk_drop_target_get_current_drop>,  :returns(N-Object)),
  get-drop => %(:is-symbol<gtk_drop_target_get_drop>,  :returns(N-Object),:deprecated, :deprecated-version<4.4>, ),
  get-formats => %(:is-symbol<gtk_drop_target_get_formats>,  :returns(N-Object)),
  #get-gtypes => %(:is-symbol<gtk_drop_target_get_gtypes>,  :parameters([CArray[gsize]])),
  get-preload => %(:is-symbol<gtk_drop_target_get_preload>,  :returns(gboolean), :cnv-return(Bool)),
  get-value => %(:is-symbol<gtk_drop_target_get_value>,  :returns(N-Object)),
  reject => %(:is-symbol<gtk_drop_target_reject>, ),
  set-actions => %(:is-symbol<gtk_drop_target_set_actions>,  :parameters([GFlag])),
  #set-gtypes => %(:is-symbol<gtk_drop_target_set_gtypes>,  :parameters([, gsize])),
  set-preload => %(:is-symbol<gtk_drop_target_set_preload>,  :parameters([gboolean])),
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
