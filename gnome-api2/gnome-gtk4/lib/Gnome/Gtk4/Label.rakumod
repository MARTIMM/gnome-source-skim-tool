# Command to generate: generate.raku -c Gtk4 label
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Gtk4::T-Enums:api<2>;
use Gnome::Gtk4::Widget:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-GObject:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;
#use Gnome::Pango::N-AttrList:api<2>;
#use Gnome::Pango::T-Layout:api<2>;


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
  $!routine-caller .= new( :library(gtk4-lib()), :sub-prefix<gtk_label_>);

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::Label' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    die X::Gnome.new(:message("Native object not defined"))
      unless self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkLabel');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-label => %( :type(Constructor), :isnew, :returns(N-GObject), :parameters([ Str])),
  new-with-mnemonic => %( :type(Constructor), :returns(N-GObject), :parameters([ Str])),

  #--[Methods]------------------------------------------------------------------
  #get-attributes => %( :returns(N-AttrList )),
  get-current-uri => %( :returns(Str)),
  #get-ellipsize => %( :returns(GEnum), :cnv-return(PangoEllipsizeMode )),
  get-extra-menu => %( :returns(N-GObject)),
  get-justify => %( :returns(GEnum), :cnv-return(GtkJustification)),
  get-label => %( :returns(Str)),
  get-layout => %( :returns(N-GObject)),
  get-layout-offsets => %( :parameters([gint-ptr, gint-ptr])),
  get-lines => %( :returns(gint)),
  get-max-width-chars => %( :returns(gint)),
  get-mnemonic-keyval => %( :returns(guint)),
  get-mnemonic-widget => %( :returns(N-GObject)),
  get-natural-wrap-mode => %( :returns(GEnum), :cnv-return(GtkNaturalWrapMode)),
  get-selectable => %( :returns(gboolean), :cnv-return(Bool)),
  get-selection-bounds => %( :returns(gboolean), :cnv-return(Bool), :parameters([gint-ptr, gint-ptr])),
  get-single-line-mode => %( :returns(gboolean), :cnv-return(Bool)),
  get-text => %( :returns(Str)),
  get-use-markup => %( :returns(gboolean), :cnv-return(Bool)),
  get-use-underline => %( :returns(gboolean), :cnv-return(Bool)),
  get-width-chars => %( :returns(gint)),
  get-wrap => %( :returns(gboolean), :cnv-return(Bool)),
  #get-wrap-mode => %( :returns(GEnum), :cnv-return(PangoWrapMode )),
  get-xalign => %( :returns(gfloat)),
  get-yalign => %( :returns(gfloat)),
  select-region => %( :parameters([gint, gint])),
  #set-attributes => %( :parameters([N-AttrList ])),
  #set-ellipsize => %( :parameters([GEnum])),
  set-extra-menu => %( :parameters([N-GObject])),
  set-justify => %( :parameters([GEnum])),
  set-label => %( :parameters([Str])),
  set-lines => %( :parameters([gint])),
  set-markup => %( :parameters([Str])),
  set-markup-with-mnemonic => %( :parameters([Str])),
  set-max-width-chars => %( :parameters([gint])),
  set-mnemonic-widget => %( :parameters([N-GObject])),
  set-natural-wrap-mode => %( :parameters([GEnum])),
  set-selectable => %( :parameters([gboolean])),
  set-single-line-mode => %( :parameters([gboolean])),
  set-text => %( :parameters([Str])),
  set-text-with-mnemonic => %( :parameters([Str])),
  set-use-markup => %( :parameters([gboolean])),
  set-use-underline => %( :parameters([gboolean])),
  set-width-chars => %( :parameters([gint])),
  set-wrap => %( :parameters([gboolean])),
  #set-wrap-mode => %( :parameters([GEnum])),
  set-xalign => %( :parameters([gfloat])),
  set-yalign => %( :parameters([gfloat])),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    if $methods{$name}<type>:exists and $methods{$name}<type> eq 'Constructor' {
      my Gnome::N::GnomeRoutineCaller $routine-caller .= new(
        :library(gtk4-lib()), :sub-prefix<gtk_label_>
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
