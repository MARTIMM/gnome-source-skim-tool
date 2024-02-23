=comment Package: Gtk4, C-Source: stylecontext
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::GObject::Object:api<2>;
use Gnome::Gdk4::N-RGBA:api<2>;
use Gnome::Gdk4::T-rgba:api<2>;

use Gnome::Gtk4::N-Border:api<2>;
use Gnome::Gtk4::T-Enums:api<2>;
use Gnome::Gtk4::T-StyleContext:api<2>;

use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::StyleContext:auth<github:MARTIMM>:api<2>;
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
  if self.^name eq 'Gnome::Gtk4::StyleContext' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkStyleContext');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  add-class => %(:is-symbol<gtk_style_context_add_class>,  :parameters([Str])),
  add-provider => %(:is-symbol<gtk_style_context_add_provider>,  :parameters([N-Object, guint])),
  get-border => %(:is-symbol<gtk_style_context_get_border>,  :parameters([N-Border])),
  get-color => %(:is-symbol<gtk_style_context_get_color>,  :parameters([N-RGBA])),
  get-display => %(:is-symbol<gtk_style_context_get_display>,  :returns(N-Object)),
  get-margin => %(:is-symbol<gtk_style_context_get_margin>,  :parameters([N-Border])),
  get-padding => %(:is-symbol<gtk_style_context_get_padding>,  :parameters([N-Border])),
  get-scale => %(:is-symbol<gtk_style_context_get_scale>,  :returns(gint)),
  get-state => %(:is-symbol<gtk_style_context_get_state>,  :returns(GFlag), :cnv-return(GtkStateFlags)),
  has-class => %(:is-symbol<gtk_style_context_has_class>,  :returns(gboolean), :cnv-return(Bool), :parameters([Str])),
  lookup-color => %(:is-symbol<gtk_style_context_lookup_color>,  :returns(gboolean), :cnv-return(Bool), :parameters([Str, N-RGBA])),
  remove-class => %(:is-symbol<gtk_style_context_remove_class>,  :parameters([Str])),
  remove-provider => %(:is-symbol<gtk_style_context_remove_provider>,  :parameters([N-Object])),
  restore => %(:is-symbol<gtk_style_context_restore>, ),
  save => %(:is-symbol<gtk_style_context_save>, ),
  set-display => %(:is-symbol<gtk_style_context_set_display>,  :parameters([N-Object])),
  set-scale => %(:is-symbol<gtk_style_context_set_scale>,  :parameters([gint])),
  set-state => %(:is-symbol<gtk_style_context_set_state>,  :parameters([GFlag])),
  to-string => %(:is-symbol<gtk_style_context_to_string>,  :returns(Str), :parameters([GFlag])),

  #--[Functions]----------------------------------------------------------------
  add-provider-for-display => %( :type(Function), :is-symbol<gtk_style_context_add_provider_for_display>,  :parameters([ N-Object, N-Object, guint])),
  remove-provider-for-display => %( :type(Function), :is-symbol<gtk_style_context_remove_provider_for_display>,  :parameters([ N-Object, N-Object])),
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
