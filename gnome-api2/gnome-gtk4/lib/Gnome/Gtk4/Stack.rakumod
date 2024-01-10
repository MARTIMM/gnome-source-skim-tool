=comment Package: Gtk4, C-Source: stack
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Gtk4::T-Stack:api<2>;
use Gnome::Gtk4::Widget:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::Stack:auth<github:MARTIMM>:api<2>;
also is Gnome::Gtk4::Widget;

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
  if self.^name eq 'Gnome::Gtk4::Stack' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkStack');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-stack => %( :type(Constructor), :is-symbol<gtk_stack_new>, :returns(N-Object), ),

  #--[Methods]------------------------------------------------------------------
  add-child => %(:is-symbol<gtk_stack_add_child>,  :returns(N-Object), :parameters([N-Object])),
  add-named => %(:is-symbol<gtk_stack_add_named>,  :returns(N-Object), :parameters([N-Object, Str])),
  add-titled => %(:is-symbol<gtk_stack_add_titled>,  :returns(N-Object), :parameters([N-Object, Str, Str])),
  get-child-by-name => %(:is-symbol<gtk_stack_get_child_by_name>,  :returns(N-Object), :parameters([Str])),
  get-hhomogeneous => %(:is-symbol<gtk_stack_get_hhomogeneous>,  :returns(gboolean), :cnv-return(Bool)),
  get-interpolate-size => %(:is-symbol<gtk_stack_get_interpolate_size>,  :returns(gboolean), :cnv-return(Bool)),
  get-page => %(:is-symbol<gtk_stack_get_page>,  :returns(N-Object), :parameters([N-Object])),
  get-pages => %(:is-symbol<gtk_stack_get_pages>,  :returns(N-Object)),
  get-transition-duration => %(:is-symbol<gtk_stack_get_transition_duration>,  :returns(guint)),
  get-transition-running => %(:is-symbol<gtk_stack_get_transition_running>,  :returns(gboolean), :cnv-return(Bool)),
  get-transition-type => %(:is-symbol<gtk_stack_get_transition_type>,  :returns(GEnum), :cnv-return(GtkStackTransitionType)),
  get-vhomogeneous => %(:is-symbol<gtk_stack_get_vhomogeneous>,  :returns(gboolean), :cnv-return(Bool)),
  get-visible-child => %(:is-symbol<gtk_stack_get_visible_child>,  :returns(N-Object)),
  get-visible-child-name => %(:is-symbol<gtk_stack_get_visible_child_name>,  :returns(Str)),
  remove => %(:is-symbol<gtk_stack_remove>,  :parameters([N-Object])),
  set-hhomogeneous => %(:is-symbol<gtk_stack_set_hhomogeneous>,  :parameters([gboolean])),
  set-interpolate-size => %(:is-symbol<gtk_stack_set_interpolate_size>,  :parameters([gboolean])),
  set-transition-duration => %(:is-symbol<gtk_stack_set_transition_duration>,  :parameters([guint])),
  set-transition-type => %(:is-symbol<gtk_stack_set_transition_type>,  :parameters([GEnum])),
  set-vhomogeneous => %(:is-symbol<gtk_stack_set_vhomogeneous>,  :parameters([gboolean])),
  set-visible-child => %(:is-symbol<gtk_stack_set_visible_child>,  :parameters([N-Object])),
  set-visible-child-full => %(:is-symbol<gtk_stack_set_visible_child_full>,  :parameters([Str, GEnum])),
  set-visible-child-name => %(:is-symbol<gtk_stack_set_visible_child_name>,  :parameters([Str])),
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
