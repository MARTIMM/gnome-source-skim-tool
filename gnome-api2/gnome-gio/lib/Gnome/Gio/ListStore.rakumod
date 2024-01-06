=comment Package: Gio, C-Source: liststore
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::GObject::Object:api<2>;
use Gnome::Gio::R-ListModel:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gio::ListStore:auth<github:MARTIMM>:api<2>;
also is Gnome::GObject::Object;
also does Gnome::Gio::R-ListModel;

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
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gio-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gio::ListStore' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GListStore');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-liststore => %( :type(Constructor), :is-symbol<g_list_store_new>, :returns(N-Object), :parameters([ GType])),

  #--[Methods]------------------------------------------------------------------
  append => %(:is-symbol<g_list_store_append>,  :parameters([gpointer])),
  find => %(:is-symbol<g_list_store_find>,  :returns(gboolean), :cnv-return(Bool), :parameters([gpointer, gint-ptr])),
  #find-with-equal-func => %(:is-symbol<g_list_store_find_with_equal_func>,  :returns(gboolean), :cnv-return(Bool), :parameters([gpointer, , gint-ptr])),
  insert => %(:is-symbol<g_list_store_insert>,  :parameters([guint, gpointer])),
  #insert-sorted => %(:is-symbol<g_list_store_insert_sorted>,  :returns(guint), :parameters([gpointer, , gpointer])),
  remove => %(:is-symbol<g_list_store_remove>,  :parameters([guint])),
  remove-all => %(:is-symbol<g_list_store_remove_all>, ),
  #sort => %(:is-symbol<g_list_store_sort>,  :parameters([, gpointer])),
  splice => %(:is-symbol<g_list_store_splice>,  :parameters([guint, guint, CArray[gpointer], guint])),
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
        :library(gio-lib())
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
    $r = self._do_g_list_model_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    ) if self.^can('_do_g_list_model_fallback-v2');
    return $r if $_fallback-v2-ok;

    callsame;
  }
}
