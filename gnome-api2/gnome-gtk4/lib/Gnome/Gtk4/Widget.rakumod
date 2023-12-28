=comment Package: Gtk4, C-Source: widget
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


#use Gnome::Cairo::N-Context:api<2>;
use Gnome::GObject::InitiallyUnowned:api<2>;
use Gnome::Glib::N-List:api<2>;
use Gnome::Glib::N-Variant:api<2>;
#use Gnome::Gsk4::N-Transform:api<2>;
use Gnome::Gtk4::N-Requisition:api<2>;
use Gnome::Gtk4::R-Accessible:api<2>;
use Gnome::Gtk4::R-Buildable:api<2>;
use Gnome::Gtk4::R-ConstraintTarget:api<2>;
use Gnome::Gtk4::T-Enums:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::Widget:auth<github:MARTIMM>:api<2>;
also is Gnome::GObject::InitiallyUnowned;
also does Gnome::Gtk4::R-Accessible;
also does Gnome::Gtk4::R-Buildable;
also does Gnome::Gtk4::R-ConstraintTarget;

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
      :w0<hide realize unrealize map unmap destroy show>,
      :w1<move-focus keynav-failed state-flags-changed mnemonic-activate direction-changed>,
      :w4<query-tooltip>,
    );

    # Signals from interfaces
    self._add_gtk_accessible_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_accessible_signal_types');
    self._add_gtk_buildable_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_buildable_signal_types');
    self._add_gtk_constraint_target_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_constraint_target_signal_types');
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::Widget' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkWidget');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  action-set-enabled => %(:is-symbol<gtk_widget_action_set_enabled>,  :parameters([Str, gboolean])),
  activate => %(:is-symbol<gtk_widget_activate>,  :returns(gboolean), :cnv-return(Bool)),
  activate-action => %(:is-symbol<gtk_widget_activate_action>, :variable-list,  :returns(gboolean), :cnv-return(Bool), :parameters([Str, Str])),
  activate-action-variant => %(:is-symbol<gtk_widget_activate_action_variant>,  :returns(gboolean), :cnv-return(Bool), :parameters([Str, N-Variant])),
  activate-default => %(:is-symbol<gtk_widget_activate_default>, ),
  add-controller => %(:is-symbol<gtk_widget_add_controller>,  :parameters([N-Object])),
  add-css-class => %(:is-symbol<gtk_widget_add_css_class>,  :parameters([Str])),
  add-mnemonic-label => %(:is-symbol<gtk_widget_add_mnemonic_label>,  :parameters([N-Object])),
  #add-tick-callback => %(:is-symbol<gtk_widget_add_tick_callback>,  :returns(guint), :parameters([:( N-Object $widget, N-Object $frame-clock, gpointer $user-data --> gboolean ), gpointer, ])),
  #allocate => %(:is-symbol<gtk_widget_allocate>,  :parameters([gint, gint, gint, N-Transform ])),
  child-focus => %(:is-symbol<gtk_widget_child_focus>,  :returns(gboolean), :cnv-return(Bool), :parameters([GEnum])),
  #compute-bounds => %(:is-symbol<gtk_widget_compute_bounds>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, ])),
  compute-expand => %(:is-symbol<gtk_widget_compute_expand>,  :returns(gboolean), :cnv-return(Bool), :parameters([GEnum])),
  #compute-point => %(:is-symbol<gtk_widget_compute_point>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, , ])),
  #compute-transform => %(:is-symbol<gtk_widget_compute_transform>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, ])),
  contains => %(:is-symbol<gtk_widget_contains>,  :returns(gboolean), :cnv-return(Bool), :parameters([gdouble, gdouble])),
  create-pango-context => %(:is-symbol<gtk_widget_create_pango_context>,  :returns(N-Object)),
  create-pango-layout => %(:is-symbol<gtk_widget_create_pango_layout>,  :returns(N-Object), :parameters([Str])),
  drag-check-threshold => %(:is-symbol<gtk_widget_drag_check_threshold>,  :returns(gboolean), :cnv-return(Bool), :parameters([gint, gint, gint, gint])),
  error-bell => %(:is-symbol<gtk_widget_error_bell>, ),
  get-allocated-baseline => %(:is-symbol<gtk_widget_get_allocated_baseline>,  :returns(gint)),
  get-allocated-height => %(:is-symbol<gtk_widget_get_allocated_height>,  :returns(gint)),
  get-allocated-width => %(:is-symbol<gtk_widget_get_allocated_width>,  :returns(gint)),
  #get-allocation => %(:is-symbol<gtk_widget_get_allocation>, ),
  get-ancestor => %(:is-symbol<gtk_widget_get_ancestor>,  :returns(N-Object), :parameters([GType])),
  get-can-focus => %(:is-symbol<gtk_widget_get_can_focus>,  :returns(gboolean), :cnv-return(Bool)),
  get-can-target => %(:is-symbol<gtk_widget_get_can_target>,  :returns(gboolean), :cnv-return(Bool)),
  get-child-visible => %(:is-symbol<gtk_widget_get_child_visible>,  :returns(gboolean), :cnv-return(Bool)),
  get-clipboard => %(:is-symbol<gtk_widget_get_clipboard>,  :returns(N-Object)),
  get-css-classes => %(:is-symbol<gtk_widget_get_css_classes>,  :returns(gchar-pptr)),
  get-css-name => %(:is-symbol<gtk_widget_get_css_name>,  :returns(Str)),
  get-cursor => %(:is-symbol<gtk_widget_get_cursor>,  :returns(N-Object)),
  get-direction => %(:is-symbol<gtk_widget_get_direction>,  :returns(GEnum), :cnv-return(GtkTextDirection)),
  get-display => %(:is-symbol<gtk_widget_get_display>,  :returns(N-Object)),
  get-first-child => %(:is-symbol<gtk_widget_get_first_child>,  :returns(N-Object)),
  get-focus-child => %(:is-symbol<gtk_widget_get_focus_child>,  :returns(N-Object)),
  get-focus-on-click => %(:is-symbol<gtk_widget_get_focus_on_click>,  :returns(gboolean), :cnv-return(Bool)),
  get-focusable => %(:is-symbol<gtk_widget_get_focusable>,  :returns(gboolean), :cnv-return(Bool)),
  get-font-map => %(:is-symbol<gtk_widget_get_font_map>,  :returns(N-Object)),
  #get-font-options => %(:is-symbol<gtk_widget_get_font_options>,  :returns(N-_font_options_t )),
  get-frame-clock => %(:is-symbol<gtk_widget_get_frame_clock>,  :returns(N-Object)),
  get-halign => %(:is-symbol<gtk_widget_get_halign>,  :returns(GEnum), :cnv-return(GtkAlign)),
  get-has-tooltip => %(:is-symbol<gtk_widget_get_has_tooltip>,  :returns(gboolean), :cnv-return(Bool)),
  get-height => %(:is-symbol<gtk_widget_get_height>,  :returns(gint)),
  get-hexpand => %(:is-symbol<gtk_widget_get_hexpand>,  :returns(gboolean), :cnv-return(Bool)),
  get-hexpand-set => %(:is-symbol<gtk_widget_get_hexpand_set>,  :returns(gboolean), :cnv-return(Bool)),
  get-last-child => %(:is-symbol<gtk_widget_get_last_child>,  :returns(N-Object)),
  get-layout-manager => %(:is-symbol<gtk_widget_get_layout_manager>,  :returns(N-Object)),
  get-mapped => %(:is-symbol<gtk_widget_get_mapped>,  :returns(gboolean), :cnv-return(Bool)),
  get-margin-bottom => %(:is-symbol<gtk_widget_get_margin_bottom>,  :returns(gint)),
  get-margin-end => %(:is-symbol<gtk_widget_get_margin_end>,  :returns(gint)),
  get-margin-start => %(:is-symbol<gtk_widget_get_margin_start>,  :returns(gint)),
  get-margin-top => %(:is-symbol<gtk_widget_get_margin_top>,  :returns(gint)),
  get-name => %(:is-symbol<gtk_widget_get_name>,  :returns(Str)),
  get-native => %(:is-symbol<gtk_widget_get_native>,  :returns(N-Object)),
  get-next-sibling => %(:is-symbol<gtk_widget_get_next_sibling>,  :returns(N-Object)),
  get-opacity => %(:is-symbol<gtk_widget_get_opacity>,  :returns(gdouble)),
  get-overflow => %(:is-symbol<gtk_widget_get_overflow>,  :returns(GEnum), :cnv-return(GtkOverflow)),
  get-pango-context => %(:is-symbol<gtk_widget_get_pango_context>,  :returns(N-Object)),
  get-parent => %(:is-symbol<gtk_widget_get_parent>,  :returns(N-Object)),
  get-preferred-size => %(:is-symbol<gtk_widget_get_preferred_size>,  :parameters([N-Requisition, N-Requisition])),
  get-prev-sibling => %(:is-symbol<gtk_widget_get_prev_sibling>,  :returns(N-Object)),
  get-primary-clipboard => %(:is-symbol<gtk_widget_get_primary_clipboard>,  :returns(N-Object)),
  get-realized => %(:is-symbol<gtk_widget_get_realized>,  :returns(gboolean), :cnv-return(Bool)),
  get-receives-default => %(:is-symbol<gtk_widget_get_receives_default>,  :returns(gboolean), :cnv-return(Bool)),
  get-request-mode => %(:is-symbol<gtk_widget_get_request_mode>,  :returns(GEnum), :cnv-return(GtkSizeRequestMode)),
  get-root => %(:is-symbol<gtk_widget_get_root>,  :returns(N-Object)),
  get-scale-factor => %(:is-symbol<gtk_widget_get_scale_factor>,  :returns(gint)),
  get-sensitive => %(:is-symbol<gtk_widget_get_sensitive>,  :returns(gboolean), :cnv-return(Bool)),
  get-settings => %(:is-symbol<gtk_widget_get_settings>,  :returns(N-Object)),
  get-size => %(:is-symbol<gtk_widget_get_size>,  :returns(gint), :parameters([GEnum])),
  get-size-request => %(:is-symbol<gtk_widget_get_size_request>,  :parameters([gint-ptr, gint-ptr])),
  get-state-flags => %(:is-symbol<gtk_widget_get_state_flags>,  :returns(GFlag), :cnv-return(GtkStateFlags)),
  get-style-context => %(:is-symbol<gtk_widget_get_style_context>,  :returns(N-Object)),
  get-template-child => %(:is-symbol<gtk_widget_get_template_child>,  :returns(N-Object), :parameters([GType, Str])),
  get-tooltip-markup => %(:is-symbol<gtk_widget_get_tooltip_markup>,  :returns(Str)),
  get-tooltip-text => %(:is-symbol<gtk_widget_get_tooltip_text>,  :returns(Str)),
  get-valign => %(:is-symbol<gtk_widget_get_valign>,  :returns(GEnum), :cnv-return(GtkAlign)),
  get-vexpand => %(:is-symbol<gtk_widget_get_vexpand>,  :returns(gboolean), :cnv-return(Bool)),
  get-vexpand-set => %(:is-symbol<gtk_widget_get_vexpand_set>,  :returns(gboolean), :cnv-return(Bool)),
  get-visible => %(:is-symbol<gtk_widget_get_visible>,  :returns(gboolean), :cnv-return(Bool)),
  get-width => %(:is-symbol<gtk_widget_get_width>,  :returns(gint)),
  grab-focus => %(:is-symbol<gtk_widget_grab_focus>,  :returns(gboolean), :cnv-return(Bool)),
  has-css-class => %(:is-symbol<gtk_widget_has_css_class>,  :returns(gboolean), :cnv-return(Bool), :parameters([Str])),
  has-default => %(:is-symbol<gtk_widget_has_default>,  :returns(gboolean), :cnv-return(Bool)),
  has-focus => %(:is-symbol<gtk_widget_has_focus>,  :returns(gboolean), :cnv-return(Bool)),
  has-visible-focus => %(:is-symbol<gtk_widget_has_visible_focus>,  :returns(gboolean), :cnv-return(Bool)),
  hide => %(:is-symbol<gtk_widget_hide>, ),
  in-destruction => %(:is-symbol<gtk_widget_in_destruction>,  :returns(gboolean), :cnv-return(Bool)),
  init-template => %(:is-symbol<gtk_widget_init_template>, ),
  insert-action-group => %(:is-symbol<gtk_widget_insert_action_group>,  :parameters([Str, N-Object])),
  insert-after => %(:is-symbol<gtk_widget_insert_after>,  :parameters([N-Object, N-Object])),
  insert-before => %(:is-symbol<gtk_widget_insert_before>,  :parameters([N-Object, N-Object])),
  is-ancestor => %(:is-symbol<gtk_widget_is_ancestor>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  is-drawable => %(:is-symbol<gtk_widget_is_drawable>,  :returns(gboolean), :cnv-return(Bool)),
  is-focus => %(:is-symbol<gtk_widget_is_focus>,  :returns(gboolean), :cnv-return(Bool)),
  is-sensitive => %(:is-symbol<gtk_widget_is_sensitive>,  :returns(gboolean), :cnv-return(Bool)),
  is-visible => %(:is-symbol<gtk_widget_is_visible>,  :returns(gboolean), :cnv-return(Bool)),
  keynav-failed => %(:is-symbol<gtk_widget_keynav_failed>,  :returns(gboolean), :cnv-return(Bool), :parameters([GEnum])),
  list-mnemonic-labels => %(:is-symbol<gtk_widget_list_mnemonic_labels>,  :returns(N-List)),
  map => %(:is-symbol<gtk_widget_map>, ),
  measure => %(:is-symbol<gtk_widget_measure>,  :parameters([GEnum, gint, gint-ptr, gint-ptr, gint-ptr, gint-ptr])),
  mnemonic-activate => %(:is-symbol<gtk_widget_mnemonic_activate>,  :returns(gboolean), :cnv-return(Bool), :parameters([gboolean])),
  observe-children => %(:is-symbol<gtk_widget_observe_children>,  :returns(N-Object)),
  observe-controllers => %(:is-symbol<gtk_widget_observe_controllers>,  :returns(N-Object)),
  pick => %(:is-symbol<gtk_widget_pick>,  :returns(N-Object), :parameters([gdouble, gdouble, GFlag])),
  queue-allocate => %(:is-symbol<gtk_widget_queue_allocate>, ),
  queue-draw => %(:is-symbol<gtk_widget_queue_draw>, ),
  queue-resize => %(:is-symbol<gtk_widget_queue_resize>, ),
  realize => %(:is-symbol<gtk_widget_realize>, ),
  remove-controller => %(:is-symbol<gtk_widget_remove_controller>,  :parameters([N-Object])),
  remove-css-class => %(:is-symbol<gtk_widget_remove_css_class>,  :parameters([Str])),
  remove-mnemonic-label => %(:is-symbol<gtk_widget_remove_mnemonic_label>,  :parameters([N-Object])),
  remove-tick-callback => %(:is-symbol<gtk_widget_remove_tick_callback>,  :parameters([guint])),
  set-can-focus => %(:is-symbol<gtk_widget_set_can_focus>,  :parameters([gboolean])),
  set-can-target => %(:is-symbol<gtk_widget_set_can_target>,  :parameters([gboolean])),
  set-child-visible => %(:is-symbol<gtk_widget_set_child_visible>,  :parameters([gboolean])),
  set-css-classes => %(:is-symbol<gtk_widget_set_css_classes>,  :parameters([gchar-pptr])),
  set-cursor => %(:is-symbol<gtk_widget_set_cursor>,  :parameters([N-Object])),
  set-cursor-from-name => %(:is-symbol<gtk_widget_set_cursor_from_name>,  :parameters([Str])),
  set-direction => %(:is-symbol<gtk_widget_set_direction>,  :parameters([GEnum])),
  set-focus-child => %(:is-symbol<gtk_widget_set_focus_child>,  :parameters([N-Object])),
  set-focus-on-click => %(:is-symbol<gtk_widget_set_focus_on_click>,  :parameters([gboolean])),
  set-focusable => %(:is-symbol<gtk_widget_set_focusable>,  :parameters([gboolean])),
  set-font-map => %(:is-symbol<gtk_widget_set_font_map>,  :parameters([N-Object])),
  #set-font-options => %(:is-symbol<gtk_widget_set_font_options>,  :parameters([N-_font_options_t ])),
  set-halign => %(:is-symbol<gtk_widget_set_halign>,  :parameters([GEnum])),
  set-has-tooltip => %(:is-symbol<gtk_widget_set_has_tooltip>,  :parameters([gboolean])),
  set-hexpand => %(:is-symbol<gtk_widget_set_hexpand>,  :parameters([gboolean])),
  set-hexpand-set => %(:is-symbol<gtk_widget_set_hexpand_set>,  :parameters([gboolean])),
  set-layout-manager => %(:is-symbol<gtk_widget_set_layout_manager>,  :parameters([N-Object])),
  set-margin-bottom => %(:is-symbol<gtk_widget_set_margin_bottom>,  :parameters([gint])),
  set-margin-end => %(:is-symbol<gtk_widget_set_margin_end>,  :parameters([gint])),
  set-margin-start => %(:is-symbol<gtk_widget_set_margin_start>,  :parameters([gint])),
  set-margin-top => %(:is-symbol<gtk_widget_set_margin_top>,  :parameters([gint])),
  set-name => %(:is-symbol<gtk_widget_set_name>,  :parameters([Str])),
  set-opacity => %(:is-symbol<gtk_widget_set_opacity>,  :parameters([gdouble])),
  set-overflow => %(:is-symbol<gtk_widget_set_overflow>,  :parameters([GEnum])),
  set-parent => %(:is-symbol<gtk_widget_set_parent>,  :parameters([N-Object])),
  set-receives-default => %(:is-symbol<gtk_widget_set_receives_default>,  :parameters([gboolean])),
  set-sensitive => %(:is-symbol<gtk_widget_set_sensitive>,  :parameters([gboolean])),
  set-size-request => %(:is-symbol<gtk_widget_set_size_request>,  :parameters([gint, gint])),
  set-state-flags => %(:is-symbol<gtk_widget_set_state_flags>,  :parameters([GFlag, gboolean])),
  set-tooltip-markup => %(:is-symbol<gtk_widget_set_tooltip_markup>,  :parameters([Str])),
  set-tooltip-text => %(:is-symbol<gtk_widget_set_tooltip_text>,  :parameters([Str])),
  set-valign => %(:is-symbol<gtk_widget_set_valign>,  :parameters([GEnum])),
  set-vexpand => %(:is-symbol<gtk_widget_set_vexpand>,  :parameters([gboolean])),
  set-vexpand-set => %(:is-symbol<gtk_widget_set_vexpand_set>,  :parameters([gboolean])),
  set-visible => %(:is-symbol<gtk_widget_set_visible>,  :parameters([gboolean])),
  should-layout => %(:is-symbol<gtk_widget_should_layout>,  :returns(gboolean), :cnv-return(Bool)),
  show => %(:is-symbol<gtk_widget_show>, ),
  #size-allocate => %(:is-symbol<gtk_widget_size_allocate>,  :parameters([, gint])),
  snapshot-child => %(:is-symbol<gtk_widget_snapshot_child>,  :parameters([N-Object, N-Object])),
  translate-coordinates => %(:is-symbol<gtk_widget_translate_coordinates>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, gdouble, gdouble, CArray[gdouble], CArray[gdouble]])),
  trigger-tooltip-query => %(:is-symbol<gtk_widget_trigger_tooltip_query>, ),
  unmap => %(:is-symbol<gtk_widget_unmap>, ),
  unparent => %(:is-symbol<gtk_widget_unparent>, ),
  unrealize => %(:is-symbol<gtk_widget_unrealize>, ),
  unset-state-flags => %(:is-symbol<gtk_widget_unset_state_flags>,  :parameters([GFlag])),

  #--[Functions]----------------------------------------------------------------
  get-default-direction => %( :type(Function), :is-symbol<gtk_widget_get_default_direction>,  :returns(GEnum)),
  set-default-direction => %( :type(Function), :is-symbol<gtk_widget_set_default_direction>,  :parameters([GtkTextDirection])),
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
    $r = self._do_gtk_accessible_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    ) if self.^can('_do_gtk_accessible_fallback-v2');
    return $r if $_fallback-v2-ok;

    $r = self._do_gtk_buildable_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    ) if self.^can('_do_gtk_buildable_fallback-v2');
    return $r if $_fallback-v2-ok;

    $r = self._do_gtk_constraint_target_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    ) if self.^can('_do_gtk_constraint_target_fallback-v2');
    return $r if $_fallback-v2-ok;

    callsame;
  }
}
