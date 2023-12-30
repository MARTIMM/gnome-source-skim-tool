=comment Package: Gtk4, C-Source: icontheme
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::GObject::Object:api<2>;
use Gnome::Gtk4::T-Enums:api<2>;
use Gnome::Gtk4::T-IconPaintable:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::IconTheme:auth<github:MARTIMM>:api<2>;
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
      :w0<changed>,
    );
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::IconTheme' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkIconTheme');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-icontheme => %( :type(Constructor), :is-symbol<gtk_icon_theme_new>, :returns(N-Object), ),

  #--[Methods]------------------------------------------------------------------
  add-resource-path => %(:is-symbol<gtk_icon_theme_add_resource_path>,  :parameters([Str])),
  add-search-path => %(:is-symbol<gtk_icon_theme_add_search_path>,  :parameters([Str])),
  get-display => %(:is-symbol<gtk_icon_theme_get_display>,  :returns(N-Object)),
  get-icon-names => %(:is-symbol<gtk_icon_theme_get_icon_names>,  :returns(gchar-pptr)),
  get-icon-sizes => %(:is-symbol<gtk_icon_theme_get_icon_sizes>,  :returns(gint-ptr), :parameters([Str])),
  get-resource-path => %(:is-symbol<gtk_icon_theme_get_resource_path>,  :returns(gchar-pptr)),
  get-search-path => %(:is-symbol<gtk_icon_theme_get_search_path>,  :returns(gchar-pptr)),
  get-theme-name => %(:is-symbol<gtk_icon_theme_get_theme_name>,  :returns(Str)),
  has-gicon => %(:is-symbol<gtk_icon_theme_has_gicon>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  has-icon => %(:is-symbol<gtk_icon_theme_has_icon>,  :returns(gboolean), :cnv-return(Bool), :parameters([Str])),
  lookup-by-gicon => %(:is-symbol<gtk_icon_theme_lookup_by_gicon>,  :returns(N-Object), :parameters([N-Object, gint, gint, GEnum, GFlag])),
  lookup-icon => %(:is-symbol<gtk_icon_theme_lookup_icon>,  :returns(N-Object), :parameters([Str, gchar-pptr, gint, gint, GEnum, GFlag])),
  set-resource-path => %(:is-symbol<gtk_icon_theme_set_resource_path>,  :parameters([gchar-pptr])),
  set-search-path => %(:is-symbol<gtk_icon_theme_set_search_path>,  :parameters([gchar-pptr])),
  set-theme-name => %(:is-symbol<gtk_icon_theme_set_theme_name>,  :parameters([Str])),

  #--[Functions]----------------------------------------------------------------
  get-for-display => %( :type(Function), :is-symbol<gtk_icon_theme_get_for_display>,  :returns(N-Object), :parameters([N-Object])),
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
