=comment Package: Gtk4, C-Source: box
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

unit class Gnome::Gtk4::Box:auth<github:MARTIMM>:api<2>;
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
  if self.^name eq 'Gnome::Gtk4::Box' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkBox');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-box => %( :type(Constructor), :is-symbol<gtk_box_new>, :returns(N-Object), :parameters([ GEnum, gint]), ),

  #--[Methods]------------------------------------------------------------------
  append => %(:is-symbol<gtk_box_append>, :parameters([N-Object]), ),
  get-baseline-child => %(:is-symbol<gtk_box_get_baseline_child>, :returns(gint), ),
  get-baseline-position => %(:is-symbol<gtk_box_get_baseline_position>,  :returns(GEnum), :cnv-return(GtkBaselinePosition)),
  get-homogeneous => %(:is-symbol<gtk_box_get_homogeneous>, :returns(gboolean), :cnv-return(Bool), ),
  get-spacing => %(:is-symbol<gtk_box_get_spacing>, :returns(gint), ),
  insert-child-after => %(:is-symbol<gtk_box_insert_child_after>, :parameters([N-Object, N-Object]), ),
  prepend => %(:is-symbol<gtk_box_prepend>, :parameters([N-Object]), ),
  remove => %(:is-symbol<gtk_box_remove>, :parameters([N-Object]), ),
  reorder-child-after => %(:is-symbol<gtk_box_reorder_child_after>, :parameters([N-Object, N-Object]), ),
  set-baseline-child => %(:is-symbol<gtk_box_set_baseline_child>, :parameters([gint]), ),
  set-baseline-position => %(:is-symbol<gtk_box_set_baseline_position>, :parameters([GEnum]), ),
  set-homogeneous => %(:is-symbol<gtk_box_set_homogeneous>, :parameters([gboolean]), ),
  set-spacing => %(:is-symbol<gtk_box_set_spacing>, :parameters([gint]), ),
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
