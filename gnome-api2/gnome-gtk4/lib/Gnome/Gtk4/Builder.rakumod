=comment Package: Gtk4, C-Source: builder
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


#use Gnome::GObject::N-Closure:api<2>;
use Gnome::GObject::N-Value:api<2>;
use Gnome::GObject::Object:api<2>;
#use Gnome::GObject::T-closure:api<2>;
#use Gnome::GObject::T-value:api<2>;
use Gnome::Glib::T-error:api<2>;
use Gnome::Glib::N-SList:api<2>;
use Gnome::Glib::T-slist:api<2>;
#use Gnome::Gtk4::T-builderscope:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::Builder:auth<github:MARTIMM>:api<2>;
also is Gnome::GObject::Object;

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
  if self.^name eq 'Gnome::Gtk4::Builder' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkBuilder');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-builder => %( :type(Constructor), :is-symbol<gtk_builder_new>, :returns(N-Object), ),
  new-from-file => %( :type(Constructor), :is-symbol<gtk_builder_new_from_file>, :returns(N-Object), :parameters([ Str])),
  new-from-resource => %( :type(Constructor), :is-symbol<gtk_builder_new_from_resource>, :returns(N-Object), :parameters([ Str])),
  new-from-string => %( :type(Constructor), :is-symbol<gtk_builder_new_from_string>, :returns(N-Object), :parameters([ Str, gssize])),

  #--[Methods]------------------------------------------------------------------
  add-from-file => %(:is-symbol<gtk_builder_add_from_file>,  :returns(gboolean), :cnv-return(Bool), :parameters([Str, CArray[N-Error]])),
  add-from-resource => %(:is-symbol<gtk_builder_add_from_resource>,  :returns(gboolean), :cnv-return(Bool), :parameters([Str, CArray[N-Error]])),
  add-from-string => %(:is-symbol<gtk_builder_add_from_string>,  :returns(gboolean), :cnv-return(Bool), :parameters([Str, gssize, CArray[N-Error]])),
  add-objects-from-file => %(:is-symbol<gtk_builder_add_objects_from_file>,  :returns(gboolean), :cnv-return(Bool), :parameters([Str, gchar-pptr, CArray[N-Error]])),
  add-objects-from-resource => %(:is-symbol<gtk_builder_add_objects_from_resource>,  :returns(gboolean), :cnv-return(Bool), :parameters([Str, gchar-pptr, CArray[N-Error]])),
  add-objects-from-string => %(:is-symbol<gtk_builder_add_objects_from_string>,  :returns(gboolean), :cnv-return(Bool), :parameters([Str, gssize, gchar-pptr, CArray[N-Error]])),
  #create-closure => %(:is-symbol<gtk_builder_create_closure>,  :returns(N-Object), :parameters([Str, GFlag, N-Object, CArray[N-Error]])),
  expose-object => %(:is-symbol<gtk_builder_expose_object>,  :parameters([Str, N-Object])),
  extend-with-template => %(:is-symbol<gtk_builder_extend_with_template>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, GType, Str, gssize, CArray[N-Error]])),
  get-current-object => %(:is-symbol<gtk_builder_get_current_object>,  :returns(N-Object)),
  get-object => %(:is-symbol<gtk_builder_get_object>,  :returns(N-Object), :parameters([Str])),
  get-objects => %(:is-symbol<gtk_builder_get_objects>,  :returns(N-Object)),
  get-scope => %(:is-symbol<gtk_builder_get_scope>,  :returns(N-Object)),
  get-translation-domain => %(:is-symbol<gtk_builder_get_translation_domain>,  :returns(Str)),
  get-type-from-name => %(:is-symbol<gtk_builder_get_type_from_name>,  :returns(GType), :parameters([Str])),
  set-current-object => %(:is-symbol<gtk_builder_set_current_object>,  :parameters([N-Object])),
  set-scope => %(:is-symbol<gtk_builder_set_scope>,  :parameters([N-Object])),
  set-translation-domain => %(:is-symbol<gtk_builder_set_translation_domain>,  :parameters([Str])),
  value-from-string => %(:is-symbol<gtk_builder_value_from_string>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, Str, N-Object, CArray[N-Error]])),
  value-from-string-type => %(:is-symbol<gtk_builder_value_from_string_type>,  :returns(gboolean), :cnv-return(Bool), :parameters([GType, Str, N-Object, CArray[N-Error]])),
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

      # Changed from generated code. Purpose is to store builder object in
      # an array in the TopLevelClassSupport. Later the module Object can
      # process the :build-id using these objects.
      my $builder = self.bless(
        :native-object(
          $routine-caller.call-native-sub( $name, @arguments, $methods)
        ),
        |%options
      );

#      self._set-builder($builder);

      return $builder
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
