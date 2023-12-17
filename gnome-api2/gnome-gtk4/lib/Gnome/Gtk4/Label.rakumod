=comment Package: Gtk4, C-Source: label
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Gtk4::T-Enums:api<2>;
use Gnome::Gtk4::Widget:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;
#use Gnome::Pango::N-AttrList:api<2>;
use Gnome::Pango::T-Layout:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::Label:auth<github:MARTIMM>:api<2>;
also is Gnome::Gtk4::Widget;

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
      :w0<activate-current-link copy-clipboard>,
      :w1<activate-link>,
      :w3<move-cursor>,
    );
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::Label' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkLabel');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-label => %( :type(Constructor), :is-symbol<gtk_label_new>, :returns(N-Object), :parameters([ Str])),
  new-with-mnemonic => %( :type(Constructor), :is-symbol<gtk_label_new_with_mnemonic>, :returns(N-Object), :parameters([ Str])),

  #--[Methods]------------------------------------------------------------------
  #get-attributes => %(:is-symbol<gtk_label_get_attributes>,  :returns(N-AttrList )),
  get-current-uri => %(:is-symbol<gtk_label_get_current_uri>,  :returns(Str)),
  get-ellipsize => %(:is-symbol<gtk_label_get_ellipsize>,  :returns(GEnum), :cnv-return(PangoEllipsizeMode)),
  get-extra-menu => %(:is-symbol<gtk_label_get_extra_menu>,  :returns(N-Object)),
  get-justify => %(:is-symbol<gtk_label_get_justify>,  :returns(GEnum), :cnv-return(GtkJustification)),
  get-label => %(:is-symbol<gtk_label_get_label>,  :returns(Str)),
  get-layout => %(:is-symbol<gtk_label_get_layout>,  :returns(N-Object)),
  get-layout-offsets => %(:is-symbol<gtk_label_get_layout_offsets>,  :parameters([gint-ptr, gint-ptr])),
  get-lines => %(:is-symbol<gtk_label_get_lines>,  :returns(gint)),
  get-max-width-chars => %(:is-symbol<gtk_label_get_max_width_chars>,  :returns(gint)),
  get-mnemonic-keyval => %(:is-symbol<gtk_label_get_mnemonic_keyval>,  :returns(guint)),
  get-mnemonic-widget => %(:is-symbol<gtk_label_get_mnemonic_widget>,  :returns(N-Object)),
  get-natural-wrap-mode => %(:is-symbol<gtk_label_get_natural_wrap_mode>,  :returns(GEnum), :cnv-return(GtkNaturalWrapMode)),
  get-selectable => %(:is-symbol<gtk_label_get_selectable>,  :returns(gboolean), :cnv-return(Bool)),
  get-selection-bounds => %(:is-symbol<gtk_label_get_selection_bounds>,  :returns(gboolean), :cnv-return(Bool), :parameters([gint-ptr, gint-ptr])),
  get-single-line-mode => %(:is-symbol<gtk_label_get_single_line_mode>,  :returns(gboolean), :cnv-return(Bool)),
  get-text => %(:is-symbol<gtk_label_get_text>,  :returns(Str)),
  get-use-markup => %(:is-symbol<gtk_label_get_use_markup>,  :returns(gboolean), :cnv-return(Bool)),
  get-use-underline => %(:is-symbol<gtk_label_get_use_underline>,  :returns(gboolean), :cnv-return(Bool)),
  get-width-chars => %(:is-symbol<gtk_label_get_width_chars>,  :returns(gint)),
  get-wrap => %(:is-symbol<gtk_label_get_wrap>,  :returns(gboolean), :cnv-return(Bool)),
  get-wrap-mode => %(:is-symbol<gtk_label_get_wrap_mode>,  :returns(GEnum), :cnv-return(PangoWrapMode)),
  get-xalign => %(:is-symbol<gtk_label_get_xalign>,  :returns(gfloat)),
  get-yalign => %(:is-symbol<gtk_label_get_yalign>,  :returns(gfloat)),
  select-region => %(:is-symbol<gtk_label_select_region>,  :parameters([gint, gint])),
  #set-attributes => %(:is-symbol<gtk_label_set_attributes>,  :parameters([N-AttrList ])),
  set-ellipsize => %(:is-symbol<gtk_label_set_ellipsize>,  :parameters([GEnum])),
  set-extra-menu => %(:is-symbol<gtk_label_set_extra_menu>,  :parameters([N-Object])),
  set-justify => %(:is-symbol<gtk_label_set_justify>,  :parameters([GEnum])),
  set-label => %(:is-symbol<gtk_label_set_label>,  :parameters([Str])),
  set-lines => %(:is-symbol<gtk_label_set_lines>,  :parameters([gint])),
  set-markup => %(:is-symbol<gtk_label_set_markup>,  :parameters([Str])),
  set-markup-with-mnemonic => %(:is-symbol<gtk_label_set_markup_with_mnemonic>,  :parameters([Str])),
  set-max-width-chars => %(:is-symbol<gtk_label_set_max_width_chars>,  :parameters([gint])),
  set-mnemonic-widget => %(:is-symbol<gtk_label_set_mnemonic_widget>,  :parameters([N-Object])),
  set-natural-wrap-mode => %(:is-symbol<gtk_label_set_natural_wrap_mode>,  :parameters([GEnum])),
  set-selectable => %(:is-symbol<gtk_label_set_selectable>,  :parameters([gboolean])),
  set-single-line-mode => %(:is-symbol<gtk_label_set_single_line_mode>,  :parameters([gboolean])),
  set-text => %(:is-symbol<gtk_label_set_text>,  :parameters([Str])),
  set-text-with-mnemonic => %(:is-symbol<gtk_label_set_text_with_mnemonic>,  :parameters([Str])),
  set-use-markup => %(:is-symbol<gtk_label_set_use_markup>,  :parameters([gboolean])),
  set-use-underline => %(:is-symbol<gtk_label_set_use_underline>,  :parameters([gboolean])),
  set-width-chars => %(:is-symbol<gtk_label_set_width_chars>,  :parameters([gint])),
  set-wrap => %(:is-symbol<gtk_label_set_wrap>,  :parameters([gboolean])),
  set-wrap-mode => %(:is-symbol<gtk_label_set_wrap_mode>,  :parameters([GEnum])),
  set-xalign => %(:is-symbol<gtk_label_set_xalign>,  :parameters([gfloat])),
  set-yalign => %(:is-symbol<gtk_label_set_yalign>,  :parameters([gfloat])),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    if $methods{$name}<type>:exists and $methods{$name}<type> eq 'Constructor' {
      my Gnome::N::GnomeRoutineCaller $routine-caller .= new(
        :library(gtk4-lib())
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
