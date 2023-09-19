# Command to generate: gnome-source-skim-tool.raku -v -c GObject value record
use v6;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::GObject::N-GValue:api<2>;
#use Gnome::Glib::N-GVariant:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-GObject:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::GObject::Value:auth<github:MARTIMM>:api<2>;
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
  $!routine-caller .= new( :library(gobject-lib()), :sub-prefix<g_value_>);

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::GObject::Value' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    die X::Gnome.new(:message("Native object not defined"))
      unless self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GValue');
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

  #--[Methods]------------------------------------------------------------------
  copy => %( :parameters([N-GValue])),
  dup-boxed => %( :returns(gpointer)),
  dup-object => %( :returns(gpointer)),
  dup-param => %( :returns(N-GObject)),
  dup-string => %( :returns(Str)),
  #dup-variant => %( :returns(N-GVariant )),
  fits-pointer => %( :returns(gboolean)),
  get-boolean => %( :returns(gboolean)),
  get-boxed => %( :returns(gpointer)),
  get-double => %( :returns(gdouble)),
  get-enum => %( :returns(gint)),
  get-flags => %( :returns(guint)),
  get-float => %( :returns(gfloat)),
  get-gtype => %( :returns(GType)),
  get-int => %( :returns(gint)),
  get-int64 => %( :returns(gint64)),
  get-long => %( :returns(glong)),
  get-object => %( :returns(gpointer)),
  get-param => %( :returns(N-GObject)),
  get-pointer => %( :returns(gpointer)),
  get-schar => %( :returns(gint8)),
  get-string => %( :returns(Str)),
  get-uchar => %( :returns(guchar)),
  get-uint => %( :returns(guint)),
  get-uint64 => %( :returns(guint64)),
  get-ulong => %( :returns(gulong)),
  #get-variant => %( :returns(N-GVariant )),
  init => %( :returns(N-GValue), :parameters([GType])),
  init-from-instance => %( :parameters([gpointer])),
  peek-pointer => %( :returns(gpointer)),
  reset => %( :returns(N-GValue)),
  set-boolean => %( :parameters([gboolean])),
  set-boxed => %( :parameters([gpointer])),
  set-double => %( :parameters([gdouble])),
  set-enum => %( :parameters([gint])),
  set-flags => %( :parameters([guint])),
  set-float => %( :parameters([gfloat])),
  set-gtype => %( :parameters([GType])),
  set-instance => %( :parameters([gpointer])),
  set-int => %( :parameters([gint])),
  set-int64 => %( :parameters([gint64])),
  set-interned-string => %( :parameters([Str])),
  set-long => %( :parameters([glong])),
  set-object => %( :parameters([gpointer])),
  set-param => %( :parameters([N-GObject])),
  set-pointer => %( :parameters([gpointer])),
  set-schar => %( :parameters([gint8])),
  set-static-boxed => %( :parameters([gpointer])),
  set-static-string => %( :parameters([Str])),
  set-string => %( :parameters([Str])),
  set-uchar => %( :parameters([guchar])),
  set-uint => %( :parameters([guint])),
  set-uint64 => %( :parameters([guint64])),
  set-ulong => %( :parameters([gulong])),
  #set-variant => %( :parameters([N-GVariant ])),
  take-boxed => %( :parameters([gpointer])),
  take-object => %( :parameters([gpointer])),
  take-param => %( :parameters([N-GObject])),
  take-string => %( :parameters([Str])),
  #take-variant => %( :parameters([N-GVariant ])),
  transform => %( :returns(gboolean), :parameters([N-GValue])),
  unset => %(),

  #--[Functions]----------------------------------------------------------------
  register-transform-func => %( :type(Function),  :parameters([ GType, GType, ])),
  type-compatible => %( :type(Function),  :returns(gboolean), :parameters([ GType, GType])),
  type-transformable => %( :type(Function),  :returns(gboolean), :parameters([ GType, GType])),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    if $methods{$name}<type>:exists and $methods{$name}<type> eq 'Constructor' {
      my Gnome::N::GnomeRoutineCaller $routine-caller .= new(
        :library(gobject-lib()), :sub-prefix<g_value_>
      );

      # Check the function name. 
      return self.bless(
        :native-object(
          $routine-caller.call-native-sub( $name, @arguments, $methods)
        )
      );
    }

    else {
      my $native-object = self.get-native-object-no-reffing;
      return $!routine-caller.call-native-sub(
        $name, @arguments, $methods, :$native-object
      );
    }
  }

  else {
    callsame;
  }
}
