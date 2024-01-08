=comment Package: Gtk4, C-Source: paned
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Gtk4::R-Orientable:api<2>;
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

unit class Gnome::Gtk4::Paned:auth<github:MARTIMM>:api<2>;
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
    self.add-signal-types( $?CLASS.^name,
      :w0<accept-position cancel-position toggle-handle-focus>,
      :w1<cycle-child-focus move-handle cycle-handle-focus>,
    );

    # Signals from interfaces
    self._add_gtk_orientable_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_orientable_signal_types');
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::Paned' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkPaned');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-paned => %( :type(Constructor), :is-symbol<gtk_paned_new>, :returns(N-Object), :parameters([ GEnum])),

  #--[Methods]------------------------------------------------------------------
  get-end-child => %(:is-symbol<gtk_paned_get_end_child>,  :returns(N-Object)),
  get-position => %(:is-symbol<gtk_paned_get_position>,  :returns(gint)),
  get-resize-end-child => %(:is-symbol<gtk_paned_get_resize_end_child>,  :returns(gboolean), :cnv-return(Bool)),
  get-resize-start-child => %(:is-symbol<gtk_paned_get_resize_start_child>,  :returns(gboolean), :cnv-return(Bool)),
  get-shrink-end-child => %(:is-symbol<gtk_paned_get_shrink_end_child>,  :returns(gboolean), :cnv-return(Bool)),
  get-shrink-start-child => %(:is-symbol<gtk_paned_get_shrink_start_child>,  :returns(gboolean), :cnv-return(Bool)),
  get-start-child => %(:is-symbol<gtk_paned_get_start_child>,  :returns(N-Object)),
  get-wide-handle => %(:is-symbol<gtk_paned_get_wide_handle>,  :returns(gboolean), :cnv-return(Bool)),
  set-end-child => %(:is-symbol<gtk_paned_set_end_child>,  :parameters([N-Object])),
  set-position => %(:is-symbol<gtk_paned_set_position>,  :parameters([gint])),
  set-resize-end-child => %(:is-symbol<gtk_paned_set_resize_end_child>,  :parameters([gboolean])),
  set-resize-start-child => %(:is-symbol<gtk_paned_set_resize_start_child>,  :parameters([gboolean])),
  set-shrink-end-child => %(:is-symbol<gtk_paned_set_shrink_end_child>,  :parameters([gboolean])),
  set-shrink-start-child => %(:is-symbol<gtk_paned_set_shrink_start_child>,  :parameters([gboolean])),
  set-start-child => %(:is-symbol<gtk_paned_set_start_child>,  :parameters([N-Object])),
  set-wide-handle => %(:is-symbol<gtk_paned_set_wide_handle>,  :parameters([gboolean])),
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
