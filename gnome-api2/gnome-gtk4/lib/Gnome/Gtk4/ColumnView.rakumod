=comment Package: Gtk4, C-Source: columnview
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


#use Gnome::Gtk4::R-Scrollable:api<2>;
use Gnome::Gtk4::T-Enums:api<2>;
use Gnome::Gtk4::Widget:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::ColumnView:auth<github:MARTIMM>:api<2>;
also is Gnome::Gtk4::Widget;
#also does Gnome::Gtk4::R-Scrollable;

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
      :w1<activate>,
    );

    # Signals from interfaces
#`{{
    self._add_gtk_scrollable_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_scrollable_signal_types');
}}
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::ColumnView' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkColumnView');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-columnview => %( :type(Constructor), :is-symbol<gtk_column_view_new>, :returns(N-Object), :parameters([ N-Object])),

  #--[Methods]------------------------------------------------------------------
  append-column => %(:is-symbol<gtk_column_view_append_column>,  :parameters([N-Object])),
  get-columns => %(:is-symbol<gtk_column_view_get_columns>,  :returns(N-Object)),
  get-enable-rubberband => %(:is-symbol<gtk_column_view_get_enable_rubberband>,  :returns(gboolean), :cnv-return(Bool)),
  get-model => %(:is-symbol<gtk_column_view_get_model>,  :returns(N-Object)),
  get-reorderable => %(:is-symbol<gtk_column_view_get_reorderable>,  :returns(gboolean), :cnv-return(Bool)),
  get-show-column-separators => %(:is-symbol<gtk_column_view_get_show_column_separators>,  :returns(gboolean), :cnv-return(Bool)),
  get-show-row-separators => %(:is-symbol<gtk_column_view_get_show_row_separators>,  :returns(gboolean), :cnv-return(Bool)),
  get-single-click-activate => %(:is-symbol<gtk_column_view_get_single_click_activate>,  :returns(gboolean), :cnv-return(Bool)),
  get-sorter => %(:is-symbol<gtk_column_view_get_sorter>,  :returns(N-Object)),
  insert-column => %(:is-symbol<gtk_column_view_insert_column>,  :parameters([guint, N-Object])),
  remove-column => %(:is-symbol<gtk_column_view_remove_column>,  :parameters([N-Object])),
  set-enable-rubberband => %(:is-symbol<gtk_column_view_set_enable_rubberband>,  :parameters([gboolean])),
  set-model => %(:is-symbol<gtk_column_view_set_model>,  :parameters([N-Object])),
  set-reorderable => %(:is-symbol<gtk_column_view_set_reorderable>,  :parameters([gboolean])),
  set-show-column-separators => %(:is-symbol<gtk_column_view_set_show_column_separators>,  :parameters([gboolean])),
  set-show-row-separators => %(:is-symbol<gtk_column_view_set_show_row_separators>,  :parameters([gboolean])),
  set-single-click-activate => %(:is-symbol<gtk_column_view_set_single_click_activate>,  :parameters([gboolean])),
  sort-by-column => %(:is-symbol<gtk_column_view_sort_by_column>,  :parameters([N-Object, GEnum])),
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
#`{{
    $r = self._do_gtk_scrollable_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    ) if self.^can('_do_gtk_scrollable_fallback-v2');
    return $r if $_fallback-v2-ok;

}}
    callsame;
  }
}
