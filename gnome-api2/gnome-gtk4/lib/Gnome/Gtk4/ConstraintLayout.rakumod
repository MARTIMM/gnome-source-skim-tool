=comment Package: Gtk4, C-Source: constraintlayout
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;




use Gnome::Glib::N-Error:api<2>;
#use Gnome::Glib::N-HashTable:api<2>;
use Gnome::Glib::N-List:api<2>;
use Gnome::Glib::T-error:api<2>;
#use Gnome::Glib::T-hash:api<2>;
use Gnome::Glib::T-list:api<2>;
use Gnome::Gtk4::LayoutManager:api<2>;
use Gnome::Gtk4::R-Buildable:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::ConstraintLayout:auth<github:MARTIMM>:api<2>;
also is Gnome::Gtk4::LayoutManager;
also does Gnome::Gtk4::R-Buildable;

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
    self._add_gtk_buildable_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_buildable_signal_types');
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::ConstraintLayout' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkConstraintLayout');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-constraintlayout => %( :type(Constructor), :is-symbol<gtk_constraint_layout_new>, :returns(N-Object), ),

  #--[Methods]------------------------------------------------------------------
  add-constraint => %(:is-symbol<gtk_constraint_layout_add_constraint>, :parameters([gint-ptr]), ),
  add-constraints-from-description => %(:is-symbol<gtk_constraint_layout_add_constraints_from_description>, :variable-list, :returns(N-Object), :parameters([gchar-pptr, gsize, gint, gint, N-Object, Str]), ),
  add-constraints-from-descriptionv => %(:is-symbol<gtk_constraint_layout_add_constraints_from_descriptionv>, :returns(N-Object), :parameters([gchar-pptr, gsize, gint, gint, N-Object, CArray[N-Error]]), ),
  add-guide => %(:is-symbol<gtk_constraint_layout_add_guide>, :parameters([N-Object]), ),
  observe-constraints => %(:is-symbol<gtk_constraint_layout_observe_constraints>, :returns(N-Object), ),
  observe-guides => %(:is-symbol<gtk_constraint_layout_observe_guides>, :returns(N-Object), ),
  remove-all-constraints => %(:is-symbol<gtk_constraint_layout_remove_all_constraints>, ),
  remove-constraint => %(:is-symbol<gtk_constraint_layout_remove_constraint>, :parameters([gint-ptr]), ),
  remove-guide => %(:is-symbol<gtk_constraint_layout_remove_guide>, :parameters([N-Object]), ),
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
    $r = self._do_gtk_buildable_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    ) if self.^can('_do_gtk_buildable_fallback-v2');
    return $r if $_fallback-v2-ok;

    callsame;
  }
}
