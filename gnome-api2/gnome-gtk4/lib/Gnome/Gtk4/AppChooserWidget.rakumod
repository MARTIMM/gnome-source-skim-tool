=comment Package: Gtk4, C-Source: appchooserwidget
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Cairo;


use Gnome::Gtk4::R-AppChooser:api<2>;
use Gnome::Gtk4::Widget:api<2>;
#use Gnome::N:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::AppChooserWidget:auth<github:MARTIMM>:api<2>;
also is Gnome::Gtk4::Widget;
also does Gnome::Gtk4::R-AppChooser;

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

  Gnome::N::deprecate(
    'Gnome::Gtk4::AppChooserWidget', ', Str, ',
    '4.10', Str,
    :class, :gnome-lib(gtk4-lib())  
  );

  # Add signal administration info.
  unless $signals-added {
    self.add-signal-types( $?CLASS.^name,
      :w1<application-activated application-selected>,
    );

    # Signals from interfaces
    self._add_gtk_app_chooser_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_app_chooser_signal_types');
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::AppChooserWidget' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkAppChooserWidget');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-appchooserwidget => %( :type(Constructor), :is-symbol<gtk_app_chooser_widget_new>, :returns(N-Object), :deprecated, :deprecated-version<4.10>, :parameters([ Str]), ),

  #--[Methods]------------------------------------------------------------------
  get-default-text => %(:is-symbol<gtk_app_chooser_widget_get_default_text>, :returns(Str), :deprecated, :deprecated-version<4.10>, ),
  get-show-all => %(:is-symbol<gtk_app_chooser_widget_get_show_all>, :returns(gboolean), :cnv-return(Bool), :deprecated, :deprecated-version<4.10>, ),
  get-show-default => %(:is-symbol<gtk_app_chooser_widget_get_show_default>, :returns(gboolean), :cnv-return(Bool), :deprecated, :deprecated-version<4.10>, ),
  get-show-fallback => %(:is-symbol<gtk_app_chooser_widget_get_show_fallback>, :returns(gboolean), :cnv-return(Bool), :deprecated, :deprecated-version<4.10>, ),
  get-show-other => %(:is-symbol<gtk_app_chooser_widget_get_show_other>, :returns(gboolean), :cnv-return(Bool), :deprecated, :deprecated-version<4.10>, ),
  get-show-recommended => %(:is-symbol<gtk_app_chooser_widget_get_show_recommended>, :returns(gboolean), :cnv-return(Bool), :deprecated, :deprecated-version<4.10>, ),
  set-default-text => %(:is-symbol<gtk_app_chooser_widget_set_default_text>, :parameters([Str]), :deprecated, :deprecated-version<4.10>, ),
  set-show-all => %(:is-symbol<gtk_app_chooser_widget_set_show_all>, :parameters([gboolean]), :deprecated, :deprecated-version<4.10>, ),
  set-show-default => %(:is-symbol<gtk_app_chooser_widget_set_show_default>, :parameters([gboolean]), :deprecated, :deprecated-version<4.10>, ),
  set-show-fallback => %(:is-symbol<gtk_app_chooser_widget_set_show_fallback>, :parameters([gboolean]), :deprecated, :deprecated-version<4.10>, ),
  set-show-other => %(:is-symbol<gtk_app_chooser_widget_set_show_other>, :parameters([gboolean]), :deprecated, :deprecated-version<4.10>, ),
  set-show-recommended => %(:is-symbol<gtk_app_chooser_widget_set_show_recommended>, :parameters([gboolean]), :deprecated, :deprecated-version<4.10>, ),
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
    $r = self._do_gtk_app_chooser_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    ) if self.^can('_do_gtk_app_chooser_fallback-v2');
    return $r if $_fallback-v2-ok;

    callsame;
  }
}
