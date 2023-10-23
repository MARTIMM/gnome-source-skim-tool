# Command to generate: generate.raku -c -t Gtk4 appchooserwidget
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Gtk4::R-AppChooser:api<2>;
use Gnome::Gtk4::Widget:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-GObject:api<2>;
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
  # Add signal administration info.
  unless $signals-added {
    self.add-signal-types( $?CLASS.^name,
      :w1<application-selected application-activated>,
    );

    # Signals from interfaces
    self._add_gtk_app_chooser_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_app_chooser_signal_types');
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new( :library(gtk4-lib()), :sub-prefix<gtk_app_chooser_widget_>);

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::AppChooserWidget' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    die X::Gnome.new(:message("Native object not defined"))
      unless self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkAppChooserWidget');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-appchooserwidget => %( :type(Constructor), :isnew, :returns(N-GObject), :parameters([ Str])),

  #--[Methods]------------------------------------------------------------------
  get-default-text => %( :returns(Str)),
  get-show-all => %( :returns(gboolean), :cnv-return(Bool)),
  get-show-default => %( :returns(gboolean), :cnv-return(Bool)),
  get-show-fallback => %( :returns(gboolean), :cnv-return(Bool)),
  get-show-other => %( :returns(gboolean), :cnv-return(Bool)),
  get-show-recommended => %( :returns(gboolean), :cnv-return(Bool)),
  set-default-text => %( :parameters([Str])),
  set-show-all => %( :parameters([gboolean])),
  set-show-default => %( :parameters([gboolean])),
  set-show-fallback => %( :parameters([gboolean])),
  set-show-other => %( :parameters([gboolean])),
  set-show-recommended => %( :parameters([gboolean])),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    if $methods{$name}<type>:exists and $methods{$name}<type> eq 'Constructor' {
      my Gnome::N::GnomeRoutineCaller $routine-caller .= new(
        :library(gtk4-lib()), :sub-prefix<gtk_app_chooser_widget_>
      );

      # Check the function name. 
      return self.bless(
        :native-object(
          $routine-caller.call-native-sub( $name, @arguments, $methods)
        )
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
    $r = self.Gnome::Gtk4::R-AppChooser::_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    );
    return $r if $_fallback-v2-ok;

    callsame;
  }
}