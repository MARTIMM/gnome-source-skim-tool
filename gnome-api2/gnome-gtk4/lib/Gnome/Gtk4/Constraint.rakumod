=comment Package: Gtk4, C-Source: constraint
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;




use Gnome::GObject::Object:api<2>;
use Gnome::Gtk4::T-enums:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::Constraint:auth<github:MARTIMM>:api<2>;
also is Gnome::GObject::Object;

#-------------------------------------------------------------------------------
#--[BUILD variables]------------------------------------------------------------
#-------------------------------------------------------------------------------

# Define callable helper
has Gnome::N::GnomeRoutineCaller $!routine-caller;

#-------------------------------------------------------------------------------
#--[BUILD submethod]------------------------------------------------------------
#-------------------------------------------------------------------------------

submethod BUILD ( *%options ) {


  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::Constraint' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkConstraint');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-constraint => %( :type(Constructor), :is-symbol<gtk_constraint_new>, :returns(gint-ptr), :parameters([ gpointer, GEnum, GEnum, gpointer, GEnum, gdouble, gdouble, gint]), ),
  new-constant => %( :type(Constructor), :is-symbol<gtk_constraint_new_constant>, :returns(gint-ptr), :parameters([ gpointer, GEnum, GEnum, gdouble, gint]), ),

  #--[Methods]------------------------------------------------------------------
  get-constant => %(:is-symbol<gtk_constraint_get_constant>, :returns(gdouble), ),
  get-multiplier => %(:is-symbol<gtk_constraint_get_multiplier>, :returns(gdouble), ),
  get-relation => %(:is-symbol<gtk_constraint_get_relation>,  :returns(GEnum), :cnv-return(GtkConstraintRelation)),
  get-source => %(:is-symbol<gtk_constraint_get_source>, :returns(N-Object), ),
  get-source-attribute => %(:is-symbol<gtk_constraint_get_source_attribute>,  :returns(GEnum), :cnv-return(GtkConstraintAttribute)),
  get-strength => %(:is-symbol<gtk_constraint_get_strength>, :returns(gint), ),
  get-target => %(:is-symbol<gtk_constraint_get_target>, :returns(N-Object), ),
  get-target-attribute => %(:is-symbol<gtk_constraint_get_target_attribute>,  :returns(GEnum), :cnv-return(GtkConstraintAttribute)),
  is-attached => %(:is-symbol<gtk_constraint_is_attached>, :returns(gboolean), :cnv-return(Bool), ),
  is-constant => %(:is-symbol<gtk_constraint_is_constant>, :returns(gboolean), :cnv-return(Bool), ),
  is-required => %(:is-symbol<gtk_constraint_is_required>, :returns(gboolean), :cnv-return(Bool), ),
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
