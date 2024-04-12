=comment Package: Gtk4, C-Source: iconview
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


#use Gnome::Gdk4::N-ContentFormats:api<2>;
use Gnome::Gdk4::T-types:api<2>;
use Gnome::Gdk4::T-enums:api<2>;

use Gnome::Glib::T-list:api<2>;

use Gnome::Gtk4::N-TreeIter:api<2>;
use Gnome::Gtk4::N-TreePath:api<2>;
use Gnome::Gtk4::R-CellLayout:api<2>;
#use Gnome::Gtk4::R-Scrollable:api<2>;
use Gnome::Gtk4::T-enums:api<2>;
#use Gnome::Gtk4::T-IconView:api<2>;
use Gnome::Gtk4::Widget:api<2>;

use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::IconView:auth<github:MARTIMM>:api<2>;
also is Gnome::Gtk4::Widget;
also does Gnome::Gtk4::R-CellLayout;
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
      :w0<select-cursor-item select-all unselect-all activate-cursor-item selection-changed toggle-cursor-item>,
      :w1<item-activated>,
      :w4<move-cursor>,
    );

    # Signals from interfaces
    self._add_gtk_cell_layout_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_cell_layout_signal_types');
#`{{
    self._add_gtk_scrollable_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_scrollable_signal_types');
}}
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::IconView' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkIconView');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-iconview => %( :type(Constructor), :is-symbol<gtk_icon_view_new>, :returns(N-Object), ),
  new-with-area => %( :type(Constructor), :is-symbol<gtk_icon_view_new_with_area>, :returns(N-Object), :parameters([ N-Object])),
  new-with-model => %( :type(Constructor), :is-symbol<gtk_icon_view_new_with_model>, :returns(N-Object), :parameters([ N-Object])),

  #--[Methods]------------------------------------------------------------------
  create-drag-icon => %(:is-symbol<gtk_icon_view_create_drag_icon>,  :returns(N-Object), :parameters([N-TreePath])),
  #enable-model-drag-dest => %(:is-symbol<gtk_icon_view_enable_model_drag_dest>,  :parameters([N-ContentFormats , GFlag])),
  #enable-model-drag-source => %(:is-symbol<gtk_icon_view_enable_model_drag_source>,  :parameters([GFlag, N-ContentFormats , GFlag])),
  get-activate-on-single-click => %(:is-symbol<gtk_icon_view_get_activate_on_single_click>,  :returns(gboolean), :cnv-return(Bool)),
  get-cell-rect => %(:is-symbol<gtk_icon_view_get_cell_rect>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-TreePath, N-Object, N-Rectangle])),
  get-column-spacing => %(:is-symbol<gtk_icon_view_get_column_spacing>,  :returns(gint)),
  get-columns => %(:is-symbol<gtk_icon_view_get_columns>,  :returns(gint)),
  get-cursor => %(:is-symbol<gtk_icon_view_get_cursor>,  :returns(gboolean), :cnv-return(Bool), :parameters([CArray[N-TreePath], CArray[N-Object]])),
  #get-dest-item-at-pos => %(:is-symbol<gtk_icon_view_get_dest_item_at_pos>,  :returns(gboolean), :cnv-return(Bool), :parameters([gint, gint, CArray[N-TreePath], GEnum])),
  #get-drag-dest-item => %(:is-symbol<gtk_icon_view_get_drag_dest_item>,  :parameters([CArray[N-TreePath], GEnum])),
  get-item-at-pos => %(:is-symbol<gtk_icon_view_get_item_at_pos>,  :returns(gboolean), :cnv-return(Bool), :parameters([gint, gint, CArray[N-TreePath], CArray[N-Object]])),
  get-item-column => %(:is-symbol<gtk_icon_view_get_item_column>,  :returns(gint), :parameters([N-TreePath])),
  get-item-orientation => %(:is-symbol<gtk_icon_view_get_item_orientation>,  :returns(GEnum), :cnv-return(GtkOrientation)),
  get-item-padding => %(:is-symbol<gtk_icon_view_get_item_padding>,  :returns(gint)),
  get-item-row => %(:is-symbol<gtk_icon_view_get_item_row>,  :returns(gint), :parameters([N-TreePath])),
  get-item-width => %(:is-symbol<gtk_icon_view_get_item_width>,  :returns(gint)),
  get-margin => %(:is-symbol<gtk_icon_view_get_margin>,  :returns(gint)),
  get-markup-column => %(:is-symbol<gtk_icon_view_get_markup_column>,  :returns(gint)),
  get-model => %(:is-symbol<gtk_icon_view_get_model>,  :returns(N-Object)),
  get-path-at-pos => %(:is-symbol<gtk_icon_view_get_path_at_pos>,  :returns(N-TreePath), :parameters([gint, gint])),
  get-pixbuf-column => %(:is-symbol<gtk_icon_view_get_pixbuf_column>,  :returns(gint)),
  get-reorderable => %(:is-symbol<gtk_icon_view_get_reorderable>,  :returns(gboolean), :cnv-return(Bool)),
  get-row-spacing => %(:is-symbol<gtk_icon_view_get_row_spacing>,  :returns(gint)),
  get-selected-items => %(:is-symbol<gtk_icon_view_get_selected_items>,  :returns(N-List)),
  get-selection-mode => %(:is-symbol<gtk_icon_view_get_selection_mode>,  :returns(GEnum), :cnv-return(GtkSelectionMode)),
  get-spacing => %(:is-symbol<gtk_icon_view_get_spacing>,  :returns(gint)),
  get-text-column => %(:is-symbol<gtk_icon_view_get_text_column>,  :returns(gint)),
  get-tooltip-column => %(:is-symbol<gtk_icon_view_get_tooltip_column>,  :returns(gint)),
  get-tooltip-context => %(:is-symbol<gtk_icon_view_get_tooltip_context>,  :returns(gboolean), :cnv-return(Bool), :parameters([gint, gint, gboolean, CArray[N-Object], CArray[N-TreePath], N-TreeIter])),
  get-visible-range => %(:is-symbol<gtk_icon_view_get_visible_range>,  :returns(gboolean), :cnv-return(Bool), :parameters([CArray[N-TreePath], CArray[N-TreePath]])),
  item-activated => %(:is-symbol<gtk_icon_view_item_activated>,  :parameters([N-TreePath])),
  path-is-selected => %(:is-symbol<gtk_icon_view_path_is_selected>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-TreePath])),
  scroll-to-path => %(:is-symbol<gtk_icon_view_scroll_to_path>,  :parameters([N-TreePath, gboolean, gfloat, gfloat])),
  select-all => %(:is-symbol<gtk_icon_view_select_all>, ),
  select-path => %(:is-symbol<gtk_icon_view_select_path>,  :parameters([N-TreePath])),
  selected-foreach => %(:is-symbol<gtk_icon_view_selected_foreach>,  :parameters([:( N-Object $icon-view, N-TreePath $path, gpointer $data ), gpointer])),
  set-activate-on-single-click => %(:is-symbol<gtk_icon_view_set_activate_on_single_click>,  :parameters([gboolean])),
  set-column-spacing => %(:is-symbol<gtk_icon_view_set_column_spacing>,  :parameters([gint])),
  set-columns => %(:is-symbol<gtk_icon_view_set_columns>,  :parameters([gint])),
  set-cursor => %(:is-symbol<gtk_icon_view_set_cursor>,  :parameters([N-TreePath, N-Object, gboolean])),
  #set-drag-dest-item => %(:is-symbol<gtk_icon_view_set_drag_dest_item>,  :parameters([N-TreePath, GEnum])),
  set-item-orientation => %(:is-symbol<gtk_icon_view_set_item_orientation>,  :parameters([GEnum])),
  set-item-padding => %(:is-symbol<gtk_icon_view_set_item_padding>,  :parameters([gint])),
  set-item-width => %(:is-symbol<gtk_icon_view_set_item_width>,  :parameters([gint])),
  set-margin => %(:is-symbol<gtk_icon_view_set_margin>,  :parameters([gint])),
  set-markup-column => %(:is-symbol<gtk_icon_view_set_markup_column>,  :parameters([gint])),
  set-model => %(:is-symbol<gtk_icon_view_set_model>,  :parameters([N-Object])),
  set-pixbuf-column => %(:is-symbol<gtk_icon_view_set_pixbuf_column>,  :parameters([gint])),
  set-reorderable => %(:is-symbol<gtk_icon_view_set_reorderable>,  :parameters([gboolean])),
  set-row-spacing => %(:is-symbol<gtk_icon_view_set_row_spacing>,  :parameters([gint])),
  set-selection-mode => %(:is-symbol<gtk_icon_view_set_selection_mode>,  :parameters([GEnum])),
  set-spacing => %(:is-symbol<gtk_icon_view_set_spacing>,  :parameters([gint])),
  set-text-column => %(:is-symbol<gtk_icon_view_set_text_column>,  :parameters([gint])),
  set-tooltip-cell => %(:is-symbol<gtk_icon_view_set_tooltip_cell>,  :parameters([N-Object, N-TreePath, N-Object])),
  set-tooltip-column => %(:is-symbol<gtk_icon_view_set_tooltip_column>,  :parameters([gint])),
  set-tooltip-item => %(:is-symbol<gtk_icon_view_set_tooltip_item>,  :parameters([N-Object, N-TreePath])),
  unselect-all => %(:is-symbol<gtk_icon_view_unselect_all>, ),
  unselect-path => %(:is-symbol<gtk_icon_view_unselect_path>,  :parameters([N-TreePath])),
  unset-model-drag-dest => %(:is-symbol<gtk_icon_view_unset_model_drag_dest>, ),
  unset-model-drag-source => %(:is-symbol<gtk_icon_view_unset_model_drag_source>, ),
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
    $r = self.Gnome::Gtk4::R-CellLayout::_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    );
    return $r if $_fallback-v2-ok;

#`{{
    $r = self.Gnome::Gtk4::R-Scrollable::_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    );
    return $r if $_fallback-v2-ok;

}}
    callsame;
  }
}
