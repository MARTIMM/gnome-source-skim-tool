# Command to generate: generate.raku -c -t Gtk4 widget class
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


#use Gnome::Cairo::N-_font_options_t:api<2>;
use Gnome::GObject::InitiallyUnowned:api<2>;
use Gnome::Glib::N-List:api<2>;
use Gnome::Glib::N-Variant:api<2>;
#use Gnome::Gsk4::N-Transform:api<2>;
use Gnome::Gtk4::N-Requisition:api<2>;
#use Gnome::Gtk4::R-Accessible:api<2>;
use Gnome::Gtk4::R-Buildable:api<2>;
#use Gnome::Gtk4::R-ConstraintTarget:api<2>;
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
      :w0<destroy unmap realize show map hide unrealize>,
      :w1<mnemonic-activate direction-changed state-flags-changed move-focus keynav-failed>,
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
#  self.set-library(gtk4-lib());
  $!routine-caller .= new( :library(gtk4-lib()), :sub-prefix<gtk_widget_>);

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
  action-set-enabled => %( :parameters([Str, gboolean])),
  activate => %( :returns(gboolean), :cnv-return(Bool)),
  #activate-action => %(:variable-list,  :returns(gboolean), :cnv-return(Bool), :parameters([Str, Str])),
  activate-action-variant => %( :returns(gboolean), :cnv-return(Bool), :parameters([Str, N-Variant])),
  activate-default => %(),
  add-controller => %( :parameters([N-Object])),
  add-css-class => %( :parameters([Str])),
  add-mnemonic-label => %( :parameters([N-Object])),
  #add-tick-callback => %( :returns(guint), :parameters([:( N-Object $widget, N-Object $frame-clock, gpointer $user-data --> gboolean ), gpointer, ])),
  #allocate => %( :parameters([gint, gint, gint, N-Transform ])),
  child-focus => %( :returns(gboolean), :cnv-return(Bool), :parameters([GEnum])),
  #compute-bounds => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, ])),
  compute-expand => %( :returns(gboolean), :cnv-return(Bool), :parameters([GEnum])),
  #compute-point => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, , ])),
  #compute-transform => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, ])),
  contains => %( :returns(gboolean), :cnv-return(Bool), :parameters([gdouble, gdouble])),
  create-pango-context => %( :returns(N-Object)),
  create-pango-layout => %( :returns(N-Object), :parameters([Str])),
  drag-check-threshold => %( :returns(gboolean), :cnv-return(Bool), :parameters([gint, gint, gint, gint])),
  error-bell => %(),
  get-allocated-baseline => %( :returns(gint)),
  get-allocated-height => %( :returns(gint)),
  get-allocated-width => %( :returns(gint)),
  #get-allocation => %(),
  get-ancestor => %( :returns(N-Object), :parameters([GType])),
  get-can-focus => %( :returns(gboolean), :cnv-return(Bool)),
  get-can-target => %( :returns(gboolean), :cnv-return(Bool)),
  get-child-visible => %( :returns(gboolean), :cnv-return(Bool)),
  get-clipboard => %( :returns(N-Object)),
  get-css-classes => %( :returns(gchar-pptr)),
  get-css-name => %( :returns(Str)),
  get-cursor => %( :returns(N-Object)),
  get-direction => %( :returns(GEnum), :cnv-return(GtkTextDirection)),
  get-display => %( :returns(N-Object)),
  get-first-child => %( :returns(N-Object)),
  get-focus-child => %( :returns(N-Object)),
  get-focus-on-click => %( :returns(gboolean), :cnv-return(Bool)),
  get-focusable => %( :returns(gboolean), :cnv-return(Bool)),
  get-font-map => %( :returns(N-Object)),
  #get-font-options => %( :returns(N-_font_options_t )),
  get-frame-clock => %( :returns(N-Object)),
  get-halign => %( :returns(GEnum), :cnv-return(GtkAlign)),
  get-has-tooltip => %( :returns(gboolean), :cnv-return(Bool)),
  get-height => %( :returns(gint)),
  get-hexpand => %( :returns(gboolean), :cnv-return(Bool)),
  get-hexpand-set => %( :returns(gboolean), :cnv-return(Bool)),
  get-last-child => %( :returns(N-Object)),
  get-layout-manager => %( :returns(N-Object)),
  get-mapped => %( :returns(gboolean), :cnv-return(Bool)),
  get-margin-bottom => %( :returns(gint)),
  get-margin-end => %( :returns(gint)),
  get-margin-start => %( :returns(gint)),
  get-margin-top => %( :returns(gint)),
  get-name => %( :returns(Str)),
  get-native => %( :returns(N-Object)),
  get-next-sibling => %( :returns(N-Object)),
  get-opacity => %( :returns(gdouble)),
  get-overflow => %( :returns(GEnum), :cnv-return(GtkOverflow)),
  get-pango-context => %( :returns(N-Object)),
  get-parent => %( :returns(N-Object)),
  get-preferred-size => %( :parameters([N-Requisition, N-Requisition])),
  get-prev-sibling => %( :returns(N-Object)),
  get-primary-clipboard => %( :returns(N-Object)),
  get-realized => %( :returns(gboolean), :cnv-return(Bool)),
  get-receives-default => %( :returns(gboolean), :cnv-return(Bool)),
  get-request-mode => %( :returns(GEnum), :cnv-return(GtkSizeRequestMode)),
  get-root => %( :returns(N-Object)),
  get-scale-factor => %( :returns(gint)),
  get-sensitive => %( :returns(gboolean), :cnv-return(Bool)),
  get-settings => %( :returns(N-Object)),
  get-size => %( :returns(gint), :parameters([GEnum])),
  get-size-request => %( :parameters([gint-ptr, gint-ptr])),
  get-state-flags => %( :returns(GFlag), :cnv-return(GtkStateFlags)),
  get-style-context => %( :returns(N-Object)),
  get-template-child => %( :returns(N-Object), :parameters([GType, Str])),
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
  insert-action-group => %( :parameters([Str, N-Object])),
  insert-after => %( :parameters([N-Object, N-Object])),
  insert-before => %( :parameters([N-Object, N-Object])),
  is-ancestor => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  is-drawable => %( :returns(gboolean), :cnv-return(Bool)),
  is-focus => %( :returns(gboolean), :cnv-return(Bool)),
  is-sensitive => %( :returns(gboolean), :cnv-return(Bool)),
  is-visible => %( :returns(gboolean), :cnv-return(Bool)),
  keynav-failed => %( :returns(gboolean), :cnv-return(Bool), :parameters([GEnum])),
  list-mnemonic-labels => %( :returns(N-List)),
  map => %(),
  measure => %( :parameters([GEnum, gint, gint-ptr, gint-ptr, gint-ptr, gint-ptr])),
  mnemonic-activate => %( :returns(gboolean), :cnv-return(Bool), :parameters([gboolean])),
  observe-children => %( :returns(N-Object)),
  observe-controllers => %( :returns(N-Object)),
  pick => %( :returns(N-Object), :parameters([gdouble, gdouble, GFlag])),
  queue-allocate => %(),
  queue-draw => %(),
  queue-resize => %(),
  realize => %(),
  remove-controller => %( :parameters([N-Object])),
  remove-css-class => %( :parameters([Str])),
  remove-mnemonic-label => %( :parameters([N-Object])),
  remove-tick-callback => %( :parameters([guint])),
  set-can-focus => %( :parameters([gboolean])),
  set-can-target => %( :parameters([gboolean])),
  set-child-visible => %( :parameters([gboolean])),
  set-css-classes => %( :parameters([gchar-pptr])),
  set-cursor => %( :parameters([N-Object])),
  set-cursor-from-name => %( :parameters([Str])),
  set-direction => %( :parameters([GEnum])),
  set-focus-child => %( :parameters([N-Object])),
  set-focus-on-click => %( :parameters([gboolean])),
  set-focusable => %( :parameters([gboolean])),
  set-font-map => %( :parameters([N-Object])),
  #set-font-options => %( :parameters([N-_font_options_t ])),
  set-halign => %( :parameters([GEnum])),
  set-has-tooltip => %( :parameters([gboolean])),
  set-hexpand => %( :parameters([gboolean])),
  set-hexpand-set => %( :parameters([gboolean])),
  set-layout-manager => %( :parameters([N-Object])),
  set-margin-bottom => %( :parameters([gint])),
  set-margin-end => %( :parameters([gint])),
  set-margin-start => %( :parameters([gint])),
  set-margin-top => %( :parameters([gint])),
  set-name => %( :parameters([Str])),
  set-opacity => %( :parameters([gdouble])),
  set-overflow => %( :parameters([GEnum])),
  set-parent => %( :parameters([N-Object])),
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
  snapshot-child => %( :parameters([N-Object, N-Object])),
  translate-coordinates => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, gdouble, gdouble, CArray[gdouble], CArray[gdouble]])),
  trigger-tooltip-query => %(),
  unmap => %(),
  unparent => %(),
  unrealize => %(),
  unset-state-flags => %( :parameters([GFlag])),

  #--[Functions]----------------------------------------------------------------
  get-default-direction => %( :type(Function),  :returns(GEnum)),
  set-default-direction => %( :type(Function),  :parameters([GtkTextDirection])),
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
    $r = self.Gnome::Gtk4::R-Accessible::_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    );
    return $r if $_fallback-v2-ok;

}}
    $r = self.Gnome::Gtk4::R-Buildable::_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    );
    return $r if $_fallback-v2-ok;

#`{{
    $r = self.Gnome::Gtk4::R-ConstraintTarget::_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    );
    return $r if $_fallback-v2-ok;

}}
    callsame;
  }
}

=finish
#-------------------------------------------------------------------------------
method set-margin-bottom ( *@arguments ) {
  self.object-call(
     @arguments, %( :parameters([gint]), :is-symbol<gtk_widget_set_margin_bottom>)
  );
}

#-------------------------------------------------------------------------------
method set-margin-end ( *@arguments ) {
  self.object-call(
    @arguments, %( :parameters([gint]), :is-symbol<gtk_widget_set_margin_end>)
  );
}

#-------------------------------------------------------------------------------
method set-margin-start ( *@arguments ) {
  self.object-call(
    @arguments, %( :parameters([gint]), :is-symbol<gtk_widget_set_margin_start>)
  );
}

#-------------------------------------------------------------------------------
method set-margin-top ( *@arguments ) {
  self.object-call(
    @arguments, %( :parameters([gint]), :is-symbol<gtk_widget_set_margin_top>)
  );
}

#-------------------------------------------------------------------------------
method set-sensitive ( *@arguments ) {
  self.object-call(
    @arguments,
    %(
      :parameters([gboolean]),
      :is-symbol<gtk_widget_set_sensitive>
    )
  );
}
