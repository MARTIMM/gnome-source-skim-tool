=comment Package: Gtk4, C-Source: dragicon
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;




use Gnome::GObject::N-Value:api<2>;
use Gnome::GObject::T-value:api<2>;
use Gnome::Gtk4::R-Native:api<2>;
use Gnome::Gtk4::R-Root:api<2>;
use Gnome::Gtk4::Widget:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::DragIcon:auth<github:MARTIMM>:api<2>;
also is Gnome::Gtk4::Widget;
also does Gnome::Gtk4::R-Native;
also does Gnome::Gtk4::R-Root;

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
    self._add_gtk_native_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_native_signal_types');
    self._add_gtk_root_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_root_signal_types');
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::DragIcon' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkDragIcon');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  get-child => %(:is-symbol<gtk_drag_icon_get_child>, :returns(N-Object), ),
  set-child => %(:is-symbol<gtk_drag_icon_set_child>, :parameters([N-Object]), ),

  #--[Functions]----------------------------------------------------------------
  create-widget-for-value => %( :type(Function), :is-symbol<gtk_drag_icon_create_widget_for_value>, :returns(N-Object), :parameters([N-Object]), ),
  get-for-drag => %( :type(Function), :is-symbol<gtk_drag_icon_get_for_drag>, :returns(N-Object), :parameters([N-Object]), ),
  set-from-paintable => %( :type(Function), :is-symbol<gtk_drag_icon_set_from_paintable>, :parameters([ N-Object, N-Object, gint, gint]), ),
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
    $r = self._do_gtk_native_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    ) if self.^can('_do_gtk_native_fallback-v2');
    return $r if $_fallback-v2-ok;

    $r = self._do_gtk_root_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    ) if self.^can('_do_gtk_root_fallback-v2');
    return $r if $_fallback-v2-ok;

    callsame;
  }
}
