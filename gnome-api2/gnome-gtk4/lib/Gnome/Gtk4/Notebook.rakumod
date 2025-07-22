=comment Package: Gtk4, C-Source: notebook
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

unit class Gnome::Gtk4::Notebook:auth<github:MARTIMM>:api<2>;
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
      :w1<focus-tab create-window move-focus-out select-page change-current-page>,
      :w2<page-added switch-page page-removed page-reordered reorder-tab>,
    );
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::Notebook' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkNotebook');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-notebook => %( :type(Constructor), :is-symbol<gtk_notebook_new>, :returns(N-Object), ),

  #--[Methods]------------------------------------------------------------------
  append-page => %(:is-symbol<gtk_notebook_append_page>, :returns(gint), :parameters([N-Object, N-Object]), ),
  append-page-menu => %(:is-symbol<gtk_notebook_append_page_menu>, :returns(gint), :parameters([N-Object, N-Object, N-Object]), ),
  detach-tab => %(:is-symbol<gtk_notebook_detach_tab>, :parameters([N-Object]), ),
  get-action-widget => %(:is-symbol<gtk_notebook_get_action_widget>, :returns(N-Object), :parameters([GEnum]), ),
  get-current-page => %(:is-symbol<gtk_notebook_get_current_page>, :returns(gint), ),
  get-group-name => %(:is-symbol<gtk_notebook_get_group_name>, :returns(Str), ),
  get-menu-label => %(:is-symbol<gtk_notebook_get_menu_label>, :returns(N-Object), :parameters([N-Object]), ),
  get-menu-label-text => %(:is-symbol<gtk_notebook_get_menu_label_text>, :returns(Str), :parameters([N-Object]), ),
  get-n-pages => %(:is-symbol<gtk_notebook_get_n_pages>, :returns(gint), ),
  get-nth-page => %(:is-symbol<gtk_notebook_get_nth_page>, :returns(N-Object), :parameters([gint]), ),
  get-page => %(:is-symbol<gtk_notebook_get_page>, :returns(N-Object), :parameters([N-Object]), ),
  get-pages => %(:is-symbol<gtk_notebook_get_pages>, :returns(N-Object), ),
  get-scrollable => %(:is-symbol<gtk_notebook_get_scrollable>, :returns(gboolean), :cnv-return(Bool), ),
  get-show-border => %(:is-symbol<gtk_notebook_get_show_border>, :returns(gboolean), :cnv-return(Bool), ),
  get-show-tabs => %(:is-symbol<gtk_notebook_get_show_tabs>, :returns(gboolean), :cnv-return(Bool), ),
  get-tab-detachable => %(:is-symbol<gtk_notebook_get_tab_detachable>, :returns(gboolean), :cnv-return(Bool), :parameters([N-Object]), ),
  get-tab-label => %(:is-symbol<gtk_notebook_get_tab_label>, :returns(N-Object), :parameters([N-Object]), ),
  get-tab-label-text => %(:is-symbol<gtk_notebook_get_tab_label_text>, :returns(Str), :parameters([N-Object]), ),
  get-tab-pos => %(:is-symbol<gtk_notebook_get_tab_pos>,  :returns(GEnum), :cnv-return(GtkPositionType)),
  get-tab-reorderable => %(:is-symbol<gtk_notebook_get_tab_reorderable>, :returns(gboolean), :cnv-return(Bool), :parameters([N-Object]), ),
  insert-page => %(:is-symbol<gtk_notebook_insert_page>, :returns(gint), :parameters([N-Object, N-Object, gint]), ),
  insert-page-menu => %(:is-symbol<gtk_notebook_insert_page_menu>, :returns(gint), :parameters([N-Object, N-Object, N-Object, gint]), ),
  next-page => %(:is-symbol<gtk_notebook_next_page>, ),
  page-num => %(:is-symbol<gtk_notebook_page_num>, :returns(gint), :parameters([N-Object]), ),
  popup-disable => %(:is-symbol<gtk_notebook_popup_disable>, ),
  popup-enable => %(:is-symbol<gtk_notebook_popup_enable>, ),
  prepend-page => %(:is-symbol<gtk_notebook_prepend_page>, :returns(gint), :parameters([N-Object, N-Object]), ),
  prepend-page-menu => %(:is-symbol<gtk_notebook_prepend_page_menu>, :returns(gint), :parameters([N-Object, N-Object, N-Object]), ),
  prev-page => %(:is-symbol<gtk_notebook_prev_page>, ),
  remove-page => %(:is-symbol<gtk_notebook_remove_page>, :parameters([gint]), ),
  reorder-child => %(:is-symbol<gtk_notebook_reorder_child>, :parameters([N-Object, gint]), ),
  set-action-widget => %(:is-symbol<gtk_notebook_set_action_widget>, :parameters([N-Object, GEnum]), ),
  set-current-page => %(:is-symbol<gtk_notebook_set_current_page>, :parameters([gint]), ),
  set-group-name => %(:is-symbol<gtk_notebook_set_group_name>, :parameters([Str]), ),
  set-menu-label => %(:is-symbol<gtk_notebook_set_menu_label>, :parameters([N-Object, N-Object]), ),
  set-menu-label-text => %(:is-symbol<gtk_notebook_set_menu_label_text>, :parameters([N-Object, Str]), ),
  set-scrollable => %(:is-symbol<gtk_notebook_set_scrollable>, :parameters([gboolean]), ),
  set-show-border => %(:is-symbol<gtk_notebook_set_show_border>, :parameters([gboolean]), ),
  set-show-tabs => %(:is-symbol<gtk_notebook_set_show_tabs>, :parameters([gboolean]), ),
  set-tab-detachable => %(:is-symbol<gtk_notebook_set_tab_detachable>, :parameters([N-Object, gboolean]), ),
  set-tab-label => %(:is-symbol<gtk_notebook_set_tab_label>, :parameters([N-Object, N-Object]), ),
  set-tab-label-text => %(:is-symbol<gtk_notebook_set_tab_label_text>, :parameters([N-Object, Str]), ),
  set-tab-pos => %(:is-symbol<gtk_notebook_set_tab_pos>, :parameters([GEnum]), ),
  set-tab-reorderable => %(:is-symbol<gtk_notebook_set_tab_reorderable>, :parameters([N-Object, gboolean]), ),
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
