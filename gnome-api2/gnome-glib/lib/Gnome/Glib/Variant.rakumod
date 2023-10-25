# Command to generate: generate.raku -v -c -t Glib variant
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


#use Gnome::Glib::N-Bytes:api<2>;
use Gnome::Glib::N-Error:api<2>;
#use Gnome::Glib::N-String:api<2>;
use Gnome::Glib::N-Variant:api<2>;
#use Gnome::Glib::N-VariantIter:api<2>;
use Gnome::Glib::N-VariantType:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-GObject:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Glib::Variant:auth<github:MARTIMM>:api<2>;
also is Gnome::N::TopLevelClassSupport;

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
  $!routine-caller .= new( :library(glib-lib()), :sub-prefix<g_variant_>);

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Glib::Variant' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    die X::Gnome.new(:message("Native object not defined"))
      unless self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GVariant');
  }
}

# Next two methods need checks for proper referencing or cleanup 
method native-object-ref ( $n-native-object ) {
  $n-native-object
}

method native-object-unref ( $n-native-object ) {
#  self._fallback-v2( 'free', my Bool $x);
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-variant => %( :type(Constructor), :isnew, :returns(N-Variant), :variable-list, :parameters([ Str])),
  #new-array => %( :type(Constructor), :returns(N-Variant), :parameters([ N-VariantType , CArray[N-Variant], gsize])),
  new-boolean => %( :type(Constructor), :returns(N-Variant), :parameters([ gboolean])),
  new-byte => %( :type(Constructor), :returns(N-Variant), :parameters([ guint8])),
  new-bytestring => %( :type(Constructor), :returns(N-Variant), :parameters([ Str])),
  new-bytestring-array => %( :type(Constructor), :returns(N-Variant), :parameters([ gchar-pptr, gssize])),
  new-dict-entry => %( :type(Constructor), :returns(N-Variant), :parameters([ N-Variant, N-Variant])),
  new-double => %( :type(Constructor), :returns(N-Variant), :parameters([ gdouble])),
  #new-fixed-array => %( :type(Constructor), :returns(N-Variant), :parameters([ N-VariantType , gpointer, gsize, gsize])),
  #new-from-bytes => %( :type(Constructor), :returns(N-Variant), :parameters([ N-VariantType , N-Bytes , gboolean])),
  #new-from-data => %( :type(Constructor), :returns(N-Variant), :parameters([ N-VariantType , gpointer, gsize, gboolean, , gpointer])),
  new-handle => %( :type(Constructor), :returns(N-Variant), :parameters([ gint32])),
  new-int16 => %( :type(Constructor), :returns(N-Variant), :parameters([ gint16])),
  new-int32 => %( :type(Constructor), :returns(N-Variant), :parameters([ gint32])),
  new-int64 => %( :type(Constructor), :returns(N-Variant), :parameters([ gint64])),
  #new-maybe => %( :type(Constructor), :returns(N-Variant), :parameters([ N-VariantType , N-Variant])),
  new-object-path => %( :type(Constructor), :returns(N-Variant), :parameters([ Str])),
  new-objv => %( :type(Constructor), :returns(N-Variant), :parameters([ gchar-pptr, gssize])),
  new-parsed => %( :type(Constructor), :returns(N-Variant), :variable-list, :parameters([ Str])),
  #new-parsed-va => %( :type(Constructor), :returns(N-Variant), :parameters([ Str, ])),
  new-printf => %( :type(Constructor), :returns(N-Variant), :variable-list, :parameters([ Str])),
  new-signature => %( :type(Constructor), :returns(N-Variant), :parameters([ Str])),
  new-string => %( :type(Constructor), :returns(N-Variant), :parameters([ Str])),
  new-strv => %( :type(Constructor), :returns(N-Variant), :parameters([ gchar-pptr, gssize])),
  new-take-string => %( :type(Constructor), :returns(N-Variant), :parameters([ Str])),
  new-tuple => %( :type(Constructor), :returns(N-Variant), :parameters([ CArray[N-Variant], gsize])),
  new-uint16 => %( :type(Constructor), :returns(N-Variant), :parameters([ guint16])),
  new-uint32 => %( :type(Constructor), :returns(N-Variant), :parameters([ guint32])),
  new-uint64 => %( :type(Constructor), :returns(N-Variant), :parameters([ guint64])),
  #new-va => %( :type(Constructor), :returns(N-Variant), :parameters([ Str, gchar-pptr, ])),
  new-variant-with-variant => %( :type(Constructor), :realname('new-variant'), :returns(N-Variant), :parameters([ N-Variant])),

  #--[Methods]------------------------------------------------------------------
  byteswap => %( :returns(N-Variant)),
  check-format-string => %( :returns(gboolean), :cnv-return(Bool), :parameters([Str, gboolean])),
  #classify => %(),
  compare => %( :returns(gint), :parameters([gpointer])),
  dup-bytestring => %( :returns(Str), :parameters([CArray[gsize]])),
  dup-bytestring-array => %( :returns(gchar-pptr), :parameters([CArray[gsize]])),
  dup-objv => %( :returns(gchar-pptr), :parameters([CArray[gsize]])),
  dup-string => %( :returns(Str), :parameters([CArray[gsize]])),
  dup-strv => %( :returns(gchar-pptr), :parameters([CArray[gsize]])),
  equal => %( :returns(gboolean), :cnv-return(Bool), :parameters([gpointer])),
  get => %(:variable-list,  :parameters([Str])),
  get-boolean => %( :returns(gboolean), :cnv-return(Bool)),
  get-byte => %( :returns(guint8)),
  get-bytestring => %( :returns(Str)),
  get-bytestring-array => %( :returns(gchar-pptr), :parameters([CArray[gsize]])),
  get-child => %(:variable-list,  :parameters([gsize, Str])),
  get-child-value => %( :returns(N-Variant), :parameters([gsize])),
  get-data => %( :returns(gpointer)),
  #get-data-as-bytes => %( :returns(N-Bytes )),
  get-double => %( :returns(gdouble)),
  get-fixed-array => %( :returns(gpointer), :parameters([CArray[gsize], gsize])),
  get-handle => %( :returns(gint32)),
  get-int16 => %( :returns(gint16)),
  get-int32 => %( :returns(gint32)),
  get-int64 => %( :returns(gint64)),
  get-maybe => %( :returns(N-Variant)),
  get-normal-form => %( :returns(N-Variant)),
  get-objv => %( :returns(gchar-pptr), :parameters([CArray[gsize]])),
  get-size => %( :returns(gsize)),
  get-string => %( :returns(Str), :parameters([CArray[gsize]])),
  get-strv => %( :returns(gchar-pptr), :parameters([CArray[gsize]])),
  #get-type => %( :returns(N-VariantType )),
  get-type-string => %( :returns(Str)),
  get-uint16 => %( :returns(guint16)),
  get-uint32 => %( :returns(guint32)),
  get-uint64 => %( :returns(guint64)),
  #get-va => %( :parameters([Str, gchar-pptr, ])),
  get-variant => %( :returns(N-Variant)),
  hash => %( :returns(guint)),
  is-container => %( :returns(gboolean), :cnv-return(Bool)),
  is-floating => %( :returns(gboolean), :cnv-return(Bool)),
  is-normal-form => %( :returns(gboolean), :cnv-return(Bool)),
  #is-of-type => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-VariantType ])),
  #iter-new => %( :returns(N-VariantIter )),
  lookup => %(:variable-list,  :returns(gboolean), :cnv-return(Bool), :parameters([Str, Str])),
  #lookup-value => %( :returns(N-Variant), :parameters([Str, N-VariantType ])),
  n-children => %( :returns(gsize)),
  print => %( :returns(Str), :parameters([gboolean])),
  #print-string => %( :returns(N-String ), :parameters([N-String , gboolean])),
  ref => %( :returns(N-Variant)),
  ref-sink => %( :returns(N-Variant)),
  store => %( :parameters([gpointer])),
  take-ref => %( :returns(N-Variant)),
  unref => %(),

  #--[Functions]----------------------------------------------------------------
  is-object-path => %( :type(Function),  :returns(gboolean), :parameters([Str])),
  is-signature => %( :type(Function),  :returns(gboolean), :parameters([Str])),
  #parse => %( :type(Function),  :returns(N-Variant), :parameters([ N-VariantType , Str, Str, gchar-pptr])),
  parse-error-print-context => %( :type(Function),  :returns(Str), :parameters([ N-Error, Str])),
  parse-error-quark => %( :type(Function),  :returns(GQuark)),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    if $methods{$name}<type>:exists and $methods{$name}<type> eq 'Constructor' {
      my Gnome::N::GnomeRoutineCaller $routine-caller .= new(
        :library(glib-lib()), :sub-prefix<g_variant_>
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
