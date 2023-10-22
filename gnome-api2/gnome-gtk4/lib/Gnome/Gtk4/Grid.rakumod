# Command to generate: generate.raku -c Gtk4 grid
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


#use Gnome::Gtk4::R-Orientable:api<2>;
use Gnome::Gtk4::T-Enums:api<2>;
use Gnome::Gtk4::Widget:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-GObject:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::Grid:auth<github:MARTIMM>:api<2>;
also is Gnome::Gtk4::Widget;
#also does Gnome::Gtk4::R-Orientable;

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
#`{{
    self._add_gtk_orientable_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_orientable_signal_types');
}}
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new( :library(gtk4-lib()), :sub-prefix<gtk_grid_>);

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::Grid' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    die X::Gnome.new(:message("Native object not defined"))
      unless self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkGrid');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-grid => %( :type(Constructor), :isnew, :returns(N-GObject), ),

  #--[Methods]------------------------------------------------------------------
  attach => %( :parameters([N-GObject, gint, gint, gint, gint])),
  attach-next-to => %( :parameters([N-GObject, N-GObject, GEnum, gint, gint])),
  get-baseline-row => %( :returns(gint)),
  get-child-at => %( :returns(N-GObject), :parameters([gint, gint])),
  get-column-homogeneous => %( :returns(gboolean), :cnv-return(Bool)),
  get-column-spacing => %( :returns(guint)),
  get-row-baseline-position => %( :returns(GEnum), :cnv-return(GtkBaselinePosition), :parameters([gint])),
  get-row-homogeneous => %( :returns(gboolean), :cnv-return(Bool)),
  get-row-spacing => %( :returns(guint)),
  insert-column => %( :parameters([gint])),
  insert-next-to => %( :parameters([N-GObject, GEnum])),
  insert-row => %( :parameters([gint])),
  query-child => %( :parameters([N-GObject, gint-ptr, gint-ptr, gint-ptr, gint-ptr])),
  remove => %( :parameters([N-GObject])),
  remove-column => %( :parameters([gint])),
  remove-row => %( :parameters([gint])),
  set-baseline-row => %( :parameters([gint])),
  set-column-homogeneous => %( :parameters([gboolean])),
  set-column-spacing => %( :parameters([guint])),
  set-row-baseline-position => %( :parameters([gint, GEnum])),
  set-row-homogeneous => %( :parameters([gboolean])),
  set-row-spacing => %( :parameters([guint])),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    if $methods{$name}<type>:exists and $methods{$name}<type> eq 'Constructor' {
      my Gnome::N::GnomeRoutineCaller $routine-caller .= new(
        :library(gtk4-lib()), :sub-prefix<gtk_grid_>
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
    $r = self.Gnome::Gtk4::R-Orientable::_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    );
    return $r if $_fallback-v2-ok;

}}
    callsame;
  }
}
