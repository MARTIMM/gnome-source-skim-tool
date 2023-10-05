# Command to generate: generate.raku -v -c Gtk4 Widget class
use v6;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


#use Gnome::Cairo::N-cairo_font_options_t:api<2>;
use Gnome::GObject::InitiallyUnowned:api<2>;
#use Gnome::Glib::N-GList:api<2>;
#use Gnome::Glib::N-GVariant:api<2>;
#use Gnome::Gsk4::N-GskTransform:api<2>;
use Gnome::Gtk4::N-GtkRequisition:api<2>;
#use Gnome::Gtk4::R-Accessible:api<2>;
use Gnome::Gtk4::R-Buildable:api<2>;
#use Gnome::Gtk4::R-ConstraintTarget:api<2>;
use Gnome::Gtk4::T-Enums:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-GObject:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::Widget:auth<github:MARTIMM>:api<2>;
also is Gnome::GObject::InitiallyUnowned;
#also does Gnome::Gtk4::R-Accessible;
also does Gnome::Gtk4::R-Buildable;
#also does Gnome::Gtk4::R-ConstraintTarget;

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
      :w0<show unmap realize destroy map unrealize hide>,
      :w1<state-flags-changed move-focus direction-changed mnemonic-activate keynav-failed>,
      :w4<query-tooltip>,
    );

    # Signals from interfaces
#`{{
    self._add_gtk_accessible_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_accessible_signal_types');
}}
    self._add_gtk_buildable_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_buildable_signal_types');
#`{{
    self._add_gtk_constraint_target_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_constraint_target_signal_types');
}}
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new( :library(gtk4-lib()), :sub-prefix<gtk_widget_>);

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::Widget' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    die X::Gnome.new(:message("Native object not defined"))
      unless self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkWidget');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  action-set-enabled => %( :parameters([Str, gboolean])),
  activate => %( :returns(gboolean), :cnv-return(Bool)),
  activate-action => %(:variable-list,  :returns(gboolean), :cnv-return(Bool), :parameters([Str, Str])),
  #activate-action-variant => %( :returns(gboolean), :cnv-return(Bool), :parameters([Str, N-GVariant ])),
  activate-default => %(),
  add-controller => %( :parameters([N-GObject])),
  add-css-class => %( :parameters([Str])),
  add-mnemonic-label => %( :parameters([N-GObject])),
  #add-tick-callback => %( :returns(guint), :parameters([:( N-GObject, N-GObject, gpointer --> gboolean ), gpointer, ])),
  #allocate => %( :parameters([gint, gint, gint, N-GskTransform ])),
  child-focus => %( :returns(gboolean), :cnv-return(Bool), :parameters([GEnum])),
  #compute-bounds => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-GObject, ])),
  compute-expand => %( :returns(gboolean), :cnv-return(Bool), :parameters([GEnum])),
  #compute-point => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-GObject, , ])),
  #compute-transform => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-GObject, ])),
  contains => %( :returns(gboolean), :cnv-return(Bool), :parameters([gdouble, gdouble])),
  create-pango-context => %( :returns(N-GObject)),
  create-pango-layout => %( :returns(N-GObject), :parameters([Str])),
  drag-check-threshold => %( :returns(gboolean), :cnv-return(Bool), :parameters([gint, gint, gint, gint])),
  error-bell => %(),
  get-allocated-baseline => %( :returns(gint)),
  get-allocated-height => %( :returns(gint)),
  get-allocated-width => %( :returns(gint)),
  #get-allocation => %(),
  get-ancestor => %( :returns(N-GObject), :parameters([GType])),
  get-can-focus => %( :returns(gboolean), :cnv-return(Bool)),
  get-can-target => %( :returns(gboolean), :cnv-return(Bool)),
  get-child-visible => %( :returns(gboolean), :cnv-return(Bool)),
  get-clipboard => %( :returns(N-GObject)),
  get-css-classes => %( :returns(gchar-pptr)),
  get-css-name => %( :returns(Str)),
  get-cursor => %( :returns(N-GObject)),
  get-direction => %( :returns(GEnum), :cnv-return(GtkTextDirection)),
  get-display => %( :returns(N-GObject)),
  get-first-child => %( :returns(N-GObject)),
  get-focus-child => %( :returns(N-GObject)),
  get-focus-on-click => %( :returns(gboolean), :cnv-return(Bool)),
  get-focusable => %( :returns(gboolean), :cnv-return(Bool)),
  get-font-map => %( :returns(N-GObject)),
  #get-font-options => %( :returns(N-cairo_font_options_t )),
  get-frame-clock => %( :returns(N-GObject)),
  get-halign => %( :returns(GEnum), :cnv-return(GtkAlign)),
  get-has-tooltip => %( :returns(gboolean), :cnv-return(Bool)),
  get-height => %( :returns(gint)),
  get-hexpand => %( :returns(gboolean), :cnv-return(Bool)),
  get-hexpand-set => %( :returns(gboolean), :cnv-return(Bool)),
  get-last-child => %( :returns(N-GObject)),
  get-layout-manager => %( :returns(N-GObject)),
  get-mapped => %( :returns(gboolean), :cnv-return(Bool)),
  get-margin-bottom => %( :returns(gint)),
  get-margin-end => %( :returns(gint)),
  get-margin-start => %( :returns(gint)),
  get-margin-top => %( :returns(gint)),
  get-name => %( :returns(Str)),
  get-native => %( :returns(N-GObject)),
  get-next-sibling => %( :returns(N-GObject)),
  get-opacity => %( :returns(gdouble)),
  get-overflow => %( :returns(GEnum), :cnv-return(GtkOverflow)),
  get-pango-context => %( :returns(N-GObject)),
  get-parent => %( :returns(N-GObject)),
  get-preferred-size => %( :parameters([N-GtkRequisition, N-GtkRequisition])),
  get-prev-sibling => %( :returns(N-GObject)),
  get-primary-clipboard => %( :returns(N-GObject)),
  get-realized => %( :returns(gboolean), :cnv-return(Bool)),
  get-receives-default => %( :returns(gboolean), :cnv-return(Bool)),
  get-request-mode => %( :returns(GEnum), :cnv-return(GtkSizeRequestMode)),
  get-root => %( :returns(N-GObject)),
  get-scale-factor => %( :returns(gint)),
  get-sensitive => %( :returns(gboolean), :cnv-return(Bool)),
  get-settings => %( :returns(N-GObject)),
  get-size => %( :returns(gint), :parameters([GEnum])),
  get-size-request => %( :parameters([gint-ptr, gint-ptr])),
  get-state-flags => %( :returns(GFlag), :cnv-return(GtkStateFlags)),
  get-style-context => %( :returns(N-GObject)),
  get-template-child => %( :returns(N-GObject), :parameters([GType, Str])),
  get-tooltip-markup => %( :returns(Str)),
  get-tooltip-text => %( :returns(Str)),
  get-valign => %( :returns(GEnum), :cnv-return(GtkAlign)),
  get-vexpand => %( :returns(gboolean), :cnv-return(Bool)),
  get-vexpand-set => %( :returns(gboolean), :cnv-return(Bool)),
  get-visible => %( :returns(gboolean), :cnv-return(Bool)),
  get-width => %( :returns(gint)),
  grab-focus => %( :returns(gboolean), :cnv-return(Bool)),
  has-css-class => %( :returns(gboolean), :cnv-return(Bool), :parameters([Str])),
  has-default => %( :returns(gboolean), :cnv-return(Bool)),
  has-focus => %( :returns(gboolean), :cnv-return(Bool)),
  has-visible-focus => %( :returns(gboolean), :cnv-return(Bool)),
  hide => %(),
  in-destruction => %( :returns(gboolean), :cnv-return(Bool)),
  init-template => %(),
  insert-action-group => %( :parameters([Str, N-GObject])),
  insert-after => %( :parameters([N-GObject, N-GObject])),
  insert-before => %( :parameters([N-GObject, N-GObject])),
  is-ancestor => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-GObject])),
  is-drawable => %( :returns(gboolean), :cnv-return(Bool)),
  is-focus => %( :returns(gboolean), :cnv-return(Bool)),
  is-sensitive => %( :returns(gboolean), :cnv-return(Bool)),
  is-visible => %( :returns(gboolean), :cnv-return(Bool)),
  keynav-failed => %( :returns(gboolean), :cnv-return(Bool), :parameters([GEnum])),
  #list-mnemonic-labels => %( :returns(N-GList )),
  map => %(),
  measure => %( :parameters([GEnum, gint, gint-ptr, gint-ptr, gint-ptr, gint-ptr])),
  mnemonic-activate => %( :returns(gboolean), :cnv-return(Bool), :parameters([gboolean])),
  observe-children => %( :returns(N-GObject)),
  observe-controllers => %( :returns(N-GObject)),
  pick => %( :returns(N-GObject), :parameters([gdouble, gdouble, GFlag])),
  queue-allocate => %(),
  queue-draw => %(),
  queue-resize => %(),
  realize => %(),
  remove-controller => %( :parameters([N-GObject])),
  remove-css-class => %( :parameters([Str])),
  remove-mnemonic-label => %( :parameters([N-GObject])),
  remove-tick-callback => %( :parameters([guint])),
  set-can-focus => %( :parameters([gboolean])),
  set-can-target => %( :parameters([gboolean])),
  set-child-visible => %( :parameters([gboolean])),
  set-css-classes => %( :parameters([gchar-pptr])),
  set-cursor => %( :parameters([N-GObject])),
  set-cursor-from-name => %( :parameters([Str])),
  set-direction => %( :parameters([GEnum])),
  set-focus-child => %( :parameters([N-GObject])),
  set-focus-on-click => %( :parameters([gboolean])),
  set-focusable => %( :parameters([gboolean])),
  set-font-map => %( :parameters([N-GObject])),
  #set-font-options => %( :parameters([N-cairo_font_options_t ])),
  set-halign => %( :parameters([GEnum])),
  set-has-tooltip => %( :parameters([gboolean])),
  set-hexpand => %( :parameters([gboolean])),
  set-hexpand-set => %( :parameters([gboolean])),
  set-layout-manager => %( :parameters([N-GObject])),
  set-margin-bottom => %( :parameters([gint])),
  set-margin-end => %( :parameters([gint])),
  set-margin-start => %( :parameters([gint])),
  set-margin-top => %( :parameters([gint])),
  set-name => %( :parameters([Str])),
  set-opacity => %( :parameters([gdouble])),
  set-overflow => %( :parameters([GEnum])),
  set-parent => %( :parameters([N-GObject])),
  set-receives-default => %( :parameters([gboolean])),
  set-sensitive => %( :parameters([gboolean])),
  set-size-request => %( :parameters([gint, gint])),
  set-state-flags => %( :parameters([GFlag, gboolean])),
  set-tooltip-markup => %( :parameters([Str])),
  set-tooltip-text => %( :parameters([Str])),
  set-valign => %( :parameters([GEnum])),
  set-vexpand => %( :parameters([gboolean])),
  set-vexpand-set => %( :parameters([gboolean])),
  set-visible => %( :parameters([gboolean])),
  should-layout => %( :returns(gboolean), :cnv-return(Bool)),
  show => %(),
  #size-allocate => %( :parameters([, gint])),
  snapshot-child => %( :parameters([N-GObject, N-GObject])),
  translate-coordinates => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-GObject, gdouble, gdouble, CArray[gdouble], CArray[gdouble]])),
  trigger-tooltip-query => %(),
  unmap => %(),
  unparent => %(),
  unrealize => %(),
  unset-state-flags => %( :parameters([GFlag])),

  #--[Functions]----------------------------------------------------------------
  get-default-direction => %( :type(Function),  :returns(GEnum)),
  set-default-direction => %( :type(Function),  :parameters([GEnum])),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    if $methods{$name}<type>:exists and $methods{$name}<type> eq 'Constructor' {
      my Gnome::N::GnomeRoutineCaller $routine-caller .= new(
        :library(gtk4-lib()), :sub-prefix<gtk_widget_>
      );

      # Check the function name. 
      return self.bless(
        :native-object(
          $routine-caller.call-native-sub( $name, @arguments, $methods)
        )
      );
    }

    else {
      my $native-object = self.get-native-object-no-reffing;
      return $!routine-caller.call-native-sub(
        $name, @arguments, $methods, :$native-object
      );
    }
  }

  else {
    my $r;
#`{{
    $r = self.Gnome::Gtk4::R-Accessible::_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments
    );
    return $r if $_fallback-v2-ok;

}}
    $r = self.Gnome::Gtk4::R-Buildable::_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments
    );
    return $r if $_fallback-v2-ok;

#`{{
    $r = self.Gnome::Gtk4::R-ConstraintTarget::_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments
    );
    return $r if $_fallback-v2-ok;

}}
    callsame;
  }
}