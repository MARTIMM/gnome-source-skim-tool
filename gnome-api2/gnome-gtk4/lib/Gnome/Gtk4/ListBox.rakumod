=comment Package: Gtk4, C-Source: listbox
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Glib::T-list:api<2>;

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

unit class Gnome::Gtk4::ListBox:auth<github:MARTIMM>:api<2>;
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
      :w0<toggle-cursor-row activate-cursor-row select-all unselect-all selected-rows-changed>,
      :w1<row-activated row-selected>,
      :w4<move-cursor>,
    );
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::ListBox' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkListBox');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-listbox => %( :type(Constructor), :is-symbol<gtk_list_box_new>, :returns(N-Object), ),

  #--[Methods]------------------------------------------------------------------
  append => %(:is-symbol<gtk_list_box_append>,  :parameters([N-Object])),
  #bind-model => %(:is-symbol<gtk_list_box_bind_model>,  :parameters([N-Object, :( gpointer $item, gpointer $user-data --> N-Object ), gpointer, ])),
  drag-highlight-row => %(:is-symbol<gtk_list_box_drag_highlight_row>,  :parameters([N-Object])),
  drag-unhighlight-row => %(:is-symbol<gtk_list_box_drag_unhighlight_row>, ),
  get-activate-on-single-click => %(:is-symbol<gtk_list_box_get_activate_on_single_click>,  :returns(gboolean), :cnv-return(Bool)),
  get-adjustment => %(:is-symbol<gtk_list_box_get_adjustment>,  :returns(N-Object)),
  get-row-at-index => %(:is-symbol<gtk_list_box_get_row_at_index>,  :returns(N-Object), :parameters([gint])),
  get-row-at-y => %(:is-symbol<gtk_list_box_get_row_at_y>,  :returns(N-Object), :parameters([gint])),
  get-selected-row => %(:is-symbol<gtk_list_box_get_selected_row>,  :returns(N-Object)),
  get-selected-rows => %(:is-symbol<gtk_list_box_get_selected_rows>,  :returns(N-List)),
  get-selection-mode => %(:is-symbol<gtk_list_box_get_selection_mode>,  :returns(GEnum), :cnv-return(GtkSelectionMode)),
  get-show-separators => %(:is-symbol<gtk_list_box_get_show_separators>,  :returns(gboolean), :cnv-return(Bool)),
  insert => %(:is-symbol<gtk_list_box_insert>,  :parameters([N-Object, gint])),
  invalidate-filter => %(:is-symbol<gtk_list_box_invalidate_filter>, ),
  invalidate-headers => %(:is-symbol<gtk_list_box_invalidate_headers>, ),
  invalidate-sort => %(:is-symbol<gtk_list_box_invalidate_sort>, ),
  prepend => %(:is-symbol<gtk_list_box_prepend>,  :parameters([N-Object])),
  remove => %(:is-symbol<gtk_list_box_remove>,  :parameters([N-Object])),
  select-all => %(:is-symbol<gtk_list_box_select_all>, ),
  select-row => %(:is-symbol<gtk_list_box_select_row>,  :parameters([N-Object])),
  selected-foreach => %(:is-symbol<gtk_list_box_selected_foreach>,  :parameters([:( N-Object $box, N-Object $row, gpointer $user-data ), gpointer])),
  set-activate-on-single-click => %(:is-symbol<gtk_list_box_set_activate_on_single_click>,  :parameters([gboolean])),
  set-adjustment => %(:is-symbol<gtk_list_box_set_adjustment>,  :parameters([N-Object])),
  #set-filter-func => %(:is-symbol<gtk_list_box_set_filter_func>,  :parameters([:( N-Object $row, gpointer $user-data --> gboolean ), gpointer, ])),
  #set-header-func => %(:is-symbol<gtk_list_box_set_header_func>,  :parameters([:( N-Object $row, N-Object $before, gpointer $user-data ), gpointer, ])),
  set-placeholder => %(:is-symbol<gtk_list_box_set_placeholder>,  :parameters([N-Object])),
  set-selection-mode => %(:is-symbol<gtk_list_box_set_selection_mode>,  :parameters([GEnum])),
  set-show-separators => %(:is-symbol<gtk_list_box_set_show_separators>,  :parameters([gboolean])),
  #set-sort-func => %(:is-symbol<gtk_list_box_set_sort_func>,  :parameters([:( N-Object $row1, N-Object $row2, gpointer $user-data --> gint ), gpointer, ])),
  unselect-all => %(:is-symbol<gtk_list_box_unselect_all>, ),
  unselect-row => %(:is-symbol<gtk_list_box_unselect_row>,  :parameters([N-Object])),
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
