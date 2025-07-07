=comment Package: Gtk4, C-Source: stack
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Cairo;


use Gnome::GObject::Object:api<2>;
use Gnome::Gtk4::R-Accessible:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::StackPage:auth<github:MARTIMM>:api<2>;
also is Gnome::GObject::Object;
also does Gnome::Gtk4::R-Accessible;

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
    self._add_gtk_accessible_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_accessible_signal_types');
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::StackPage' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkStackPage');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  get-child => %(:is-symbol<gtk_stack_page_get_child>, :returns(N-Object), ),
  get-icon-name => %(:is-symbol<gtk_stack_page_get_icon_name>, :returns(Str), ),
  get-name => %(:is-symbol<gtk_stack_page_get_name>, :returns(Str), ),
  get-needs-attention => %(:is-symbol<gtk_stack_page_get_needs_attention>, :returns(gboolean), ),
  get-title => %(:is-symbol<gtk_stack_page_get_title>, :returns(Str), ),
  get-use-underline => %(:is-symbol<gtk_stack_page_get_use_underline>, :returns(gboolean), ),
  get-visible => %(:is-symbol<gtk_stack_page_get_visible>, :returns(gboolean), ),
  set-icon-name => %(:is-symbol<gtk_stack_page_set_icon_name>, :parameters([Str]), ),
  set-name => %(:is-symbol<gtk_stack_page_set_name>, :parameters([Str]), ),
  set-needs-attention => %(:is-symbol<gtk_stack_page_set_needs_attention>, :parameters([gboolean]), ),
  set-title => %(:is-symbol<gtk_stack_page_set_title>, :parameters([Str]), ),
  set-use-underline => %(:is-symbol<gtk_stack_page_set_use_underline>, :parameters([gboolean]), ),
  set-visible => %(:is-symbol<gtk_stack_page_set_visible>, :parameters([gboolean]), ),
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

    callsame;
  }
}
