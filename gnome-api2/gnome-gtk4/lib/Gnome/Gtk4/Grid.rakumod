=comment Package: Gtk4, C-Source: grid
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;




use Gnome::Gtk4::R-Orientable:api<2>;
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

unit class Gnome::Gtk4::Grid:auth<github:MARTIMM>:api<2>;
also is Gnome::Gtk4::Widget;
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
    self._add_gtk_orientable_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_orientable_signal_types');
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::Grid' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkGrid');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-grid => %( :type(Constructor), :is-symbol<gtk_grid_new>, :returns(N-Object), ),

  #--[Methods]------------------------------------------------------------------
  attach => %(:is-symbol<gtk_grid_attach>, :parameters([N-Object, gint, gint, gint, gint]), ),
  attach-next-to => %(:is-symbol<gtk_grid_attach_next_to>, :parameters([N-Object, N-Object, GEnum, gint, gint]), ),
  get-baseline-row => %(:is-symbol<gtk_grid_get_baseline_row>, :returns(gint), ),
  get-child-at => %(:is-symbol<gtk_grid_get_child_at>, :returns(N-Object), :parameters([gint, gint]), ),
  get-column-homogeneous => %(:is-symbol<gtk_grid_get_column_homogeneous>, :returns(gboolean), :cnv-return(Bool), ),
  get-column-spacing => %(:is-symbol<gtk_grid_get_column_spacing>, :returns(guint), ),
  get-row-baseline-position => %(:is-symbol<gtk_grid_get_row_baseline_position>,  :returns(GEnum), :cnv-return(GtkBaselinePosition),:parameters([gint]), ),
  get-row-homogeneous => %(:is-symbol<gtk_grid_get_row_homogeneous>, :returns(gboolean), :cnv-return(Bool), ),
  get-row-spacing => %(:is-symbol<gtk_grid_get_row_spacing>, :returns(guint), ),
  insert-column => %(:is-symbol<gtk_grid_insert_column>, :parameters([gint]), ),
  insert-next-to => %(:is-symbol<gtk_grid_insert_next_to>, :parameters([N-Object, GEnum]), ),
  insert-row => %(:is-symbol<gtk_grid_insert_row>, :parameters([gint]), ),
  query-child => %(:is-symbol<gtk_grid_query_child>, :parameters([N-Object, gint-ptr, gint-ptr, gint-ptr, gint-ptr]), ),
  remove => %(:is-symbol<gtk_grid_remove>, :parameters([N-Object]), ),
  remove-column => %(:is-symbol<gtk_grid_remove_column>, :parameters([gint]), ),
  remove-row => %(:is-symbol<gtk_grid_remove_row>, :parameters([gint]), ),
  set-baseline-row => %(:is-symbol<gtk_grid_set_baseline_row>, :parameters([gint]), ),
  set-column-homogeneous => %(:is-symbol<gtk_grid_set_column_homogeneous>, :parameters([gboolean]), ),
  set-column-spacing => %(:is-symbol<gtk_grid_set_column_spacing>, :parameters([guint]), ),
  set-row-baseline-position => %(:is-symbol<gtk_grid_set_row_baseline_position>, :parameters([gint, GEnum]), ),
  set-row-homogeneous => %(:is-symbol<gtk_grid_set_row_homogeneous>, :parameters([gboolean]), ),
  set-row-spacing => %(:is-symbol<gtk_grid_set_row_spacing>, :parameters([guint]), ),
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
    $r = self._do_gtk_orientable_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    ) if self.^can('_do_gtk_orientable_fallback-v2');
    return $r if $_fallback-v2-ok;

    callsame;
  }
}
