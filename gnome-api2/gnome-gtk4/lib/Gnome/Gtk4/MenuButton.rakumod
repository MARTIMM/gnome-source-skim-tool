=comment Package: Gtk4, C-Source: menubutton
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

unit class Gnome::Gtk4::MenuButton:auth<github:MARTIMM>:api<2>;
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
      :w0<activate>,
    );
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::MenuButton' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkMenuButton');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-menubutton => %( :type(Constructor), :is-symbol<gtk_menu_button_new>, :returns(N-Object), ),

  #--[Methods]------------------------------------------------------------------
  get-active => %(:is-symbol<gtk_menu_button_get_active>, :returns(gboolean), :cnv-return(Bool), ),
  get-always-show-arrow => %(:is-symbol<gtk_menu_button_get_always_show_arrow>, :returns(gboolean), :cnv-return(Bool), ),
  get-can-shrink => %(:is-symbol<gtk_menu_button_get_can_shrink>, :returns(gboolean), :cnv-return(Bool), ),
  get-child => %(:is-symbol<gtk_menu_button_get_child>, :returns(N-Object), ),
  get-direction => %(:is-symbol<gtk_menu_button_get_direction>,  :returns(GEnum), :cnv-return(GtkArrowType)),
  get-has-frame => %(:is-symbol<gtk_menu_button_get_has_frame>, :returns(gboolean), :cnv-return(Bool), ),
  get-icon-name => %(:is-symbol<gtk_menu_button_get_icon_name>, :returns(Str), ),
  get-label => %(:is-symbol<gtk_menu_button_get_label>, :returns(Str), ),
  get-menu-model => %(:is-symbol<gtk_menu_button_get_menu_model>, :returns(N-Object), ),
  get-popover => %(:is-symbol<gtk_menu_button_get_popover>, :returns(N-Object), ),
  get-primary => %(:is-symbol<gtk_menu_button_get_primary>, :returns(gboolean), :cnv-return(Bool), ),
  get-use-underline => %(:is-symbol<gtk_menu_button_get_use_underline>, :returns(gboolean), :cnv-return(Bool), ),
  popdown => %(:is-symbol<gtk_menu_button_popdown>, ),
  popup => %(:is-symbol<gtk_menu_button_popup>, ),
  set-active => %(:is-symbol<gtk_menu_button_set_active>, :parameters([gboolean]), ),
  set-always-show-arrow => %(:is-symbol<gtk_menu_button_set_always_show_arrow>, :parameters([gboolean]), ),
  set-can-shrink => %(:is-symbol<gtk_menu_button_set_can_shrink>, :parameters([gboolean]), ),
  set-child => %(:is-symbol<gtk_menu_button_set_child>, :parameters([N-Object]), ),
  set-create-popup-func => %(:is-symbol<gtk_menu_button_set_create_popup_func>, :parameters([:( N-Object $menu-button, gpointer $user-data ), gpointer, :( gpointer $data )]), ),
  set-direction => %(:is-symbol<gtk_menu_button_set_direction>, :parameters([GEnum]), ),
  set-has-frame => %(:is-symbol<gtk_menu_button_set_has_frame>, :parameters([gboolean]), ),
  set-icon-name => %(:is-symbol<gtk_menu_button_set_icon_name>, :parameters([Str]), ),
  set-label => %(:is-symbol<gtk_menu_button_set_label>, :parameters([Str]), ),
  set-menu-model => %(:is-symbol<gtk_menu_button_set_menu_model>, :parameters([N-Object]), ),
  set-popover => %(:is-symbol<gtk_menu_button_set_popover>, :parameters([N-Object]), ),
  set-primary => %(:is-symbol<gtk_menu_button_set_primary>, :parameters([gboolean]), ),
  set-use-underline => %(:is-symbol<gtk_menu_button_set_use_underline>, :parameters([gboolean]), ),
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
