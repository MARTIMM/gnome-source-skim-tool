=comment Package: Gtk4, C-Source: cellview
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Gtk4::N-TreePath:api<2>;
use Gnome::Gtk4::R-CellLayout:api<2>;
use Gnome::Gtk4::R-Orientable:api<2>;
use Gnome::Gtk4::Widget:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::CellView:auth<github:MARTIMM>:api<2>;
also is Gnome::Gtk4::Widget;
also does Gnome::Gtk4::R-CellLayout;
also does Gnome::Gtk4::R-Orientable;

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
    self._add_gtk_cell_layout_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_cell_layout_signal_types');
    self._add_gtk_orientable_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_orientable_signal_types');
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::CellView' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkCellView');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-cellview => %( :type(Constructor), :is-symbol<gtk_cell_view_new>, :returns(N-Object), ),
  new-with-context => %( :type(Constructor), :is-symbol<gtk_cell_view_new_with_context>, :returns(N-Object), :parameters([ N-Object, N-Object])),
  new-with-markup => %( :type(Constructor), :is-symbol<gtk_cell_view_new_with_markup>, :returns(N-Object), :parameters([ Str])),
  new-with-text => %( :type(Constructor), :is-symbol<gtk_cell_view_new_with_text>, :returns(N-Object), :parameters([ Str])),
  new-with-texture => %( :type(Constructor), :is-symbol<gtk_cell_view_new_with_texture>, :returns(N-Object), :parameters([ N-Object])),

  #--[Methods]------------------------------------------------------------------
  get-displayed-row => %(:is-symbol<gtk_cell_view_get_displayed_row>,  :returns(N-TreePath)),
  get-draw-sensitive => %(:is-symbol<gtk_cell_view_get_draw_sensitive>,  :returns(gboolean), :cnv-return(Bool)),
  get-fit-model => %(:is-symbol<gtk_cell_view_get_fit_model>,  :returns(gboolean), :cnv-return(Bool)),
  get-model => %(:is-symbol<gtk_cell_view_get_model>,  :returns(N-Object)),
  set-displayed-row => %(:is-symbol<gtk_cell_view_set_displayed_row>,  :parameters([N-TreePath])),
  set-draw-sensitive => %(:is-symbol<gtk_cell_view_set_draw_sensitive>,  :parameters([gboolean])),
  set-fit-model => %(:is-symbol<gtk_cell_view_set_fit_model>,  :parameters([gboolean])),
  set-model => %(:is-symbol<gtk_cell_view_set_model>,  :parameters([N-Object])),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    if $methods{$name}<type>:exists and $methods{$name}<type> eq 'Constructor' {
      my Gnome::N::GnomeRoutineCaller $routine-caller .= new(
        :library(gtk4-lib())
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
    $r = self.Gnome::Gtk4::R-CellLayout::_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    );
    return $r if $_fallback-v2-ok;

    $r = self.Gnome::Gtk4::R-Orientable::_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    );
    return $r if $_fallback-v2-ok;

    callsame;
  }
}
