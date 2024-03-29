=comment Package: Gio, C-Source: menumodel
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Gnome::GObject::Object:api<2>;

use Gnome::Glib::N-Variant:api<2>;
use Gnome::Glib::T-variant:api<2>;
use Gnome::Glib::N-VariantType:api<2>;
use Gnome::Glib::T-varianttype:api<2>;

use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gio::MenuModel:auth<github:MARTIMM>:api<2>;
also is Gnome::GObject::Object;

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
      :w3<items-changed>,
    );
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gio-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gio::MenuModel' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GMenuModel');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  get-item-attribute => %(:is-symbol<g_menu_model_get_item_attribute>, :variable-list,  :returns(gboolean), :cnv-return(Bool), :parameters([gint, Str, Str])),
  get-item-attribute-value => %(:is-symbol<g_menu_model_get_item_attribute_value>,  :returns(N-Variant), :parameters([gint, Str, N-VariantType])),
  get-item-link => %(:is-symbol<g_menu_model_get_item_link>,  :returns(N-Object), :parameters([gint, Str])),
  get-n-items => %(:is-symbol<g_menu_model_get_n_items>,  :returns(gint)),
  is-mutable => %(:is-symbol<g_menu_model_is_mutable>,  :returns(gboolean), :cnv-return(Bool)),
  items-changed => %(:is-symbol<g_menu_model_items_changed>,  :parameters([gint, gint, gint])),
  iterate-item-attributes => %(:is-symbol<g_menu_model_iterate_item_attributes>,  :returns(N-Object), :parameters([gint])),
  iterate-item-links => %(:is-symbol<g_menu_model_iterate_item_links>,  :returns(N-Object), :parameters([gint])),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    if $methods{$name}<type>:exists and $methods{$name}<type> eq 'Constructor' {
      my Gnome::N::GnomeRoutineCaller $routine-caller .= new(
        :library(gio-lib())
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
    callsame;
  }
}
