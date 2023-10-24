# Command to generate: generate.raku -c -t Gio file
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


#use :api<2>;
#use Gnome::Gio::N-FileAttributeInfoList:api<2>;
use Gnome::Gio::T-Ioenums:api<2>;
#use Gnome::Glib::N-Bytes:api<2>;

use Gnome::N::TopLevelClassSupport;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-GObject:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gio::File:auth<github:MARTIMM>:api<2>;
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
  $!routine-caller .= new( :library(gio-lib()), :sub-prefix<g_file_>);

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gio::File' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    die X::Gnome.new(:message("Native object not defined"))
      unless self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GFile');
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
  #new-build-filename => %( :type(Constructor), :returns(N-GObject), :variable-list, :parameters([ Str])),
  new-for-commandline-arg => %( :type(Constructor), :returns(N-GObject), :parameters([ Str])),
  new-for-commandline-arg-and-cwd => %( :type(Constructor), :returns(N-GObject), :parameters([ Str, Str])),
  new-for-path => %( :type(Constructor), :returns(N-GObject), :parameters([ Str])),
  new-for-uri => %( :type(Constructor), :returns(N-GObject), :parameters([ Str])),
  new-tmp => %( :type(Constructor), :returns(N-GObject), :parameters([ Str, CArray[N-GObject]])),
  parse-name => %( :type(Constructor), :returns(N-GObject), :parameters([ Str])),

  #--[Methods]------------------------------------------------------------------
  append-to => %( :returns(N-GObject), :parameters([GFlag, N-GObject])),
  append-to-async => %( :parameters([GFlag, gint, N-GObject, :( N-GObject $source-object, N-GObject $res, gpointer $user-data ), gpointer])),
  append-to-finish => %( :returns(N-GObject), :parameters([N-GObject])),
  build-attribute-list-for-copy => %( :returns(Str), :parameters([GFlag, N-GObject])),
  copy => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-GObject, GFlag, N-GObject, :(  $current-num-bytes,  $total-num-bytes, gpointer $user-data ), gpointer])),
  copy-async => %( :parameters([N-GObject, GFlag, gint, N-GObject, :(  $current-num-bytes,  $total-num-bytes, gpointer $user-data ), gpointer, :( N-GObject $source-object, N-GObject $res, gpointer $user-data ), gpointer])),
  copy-attributes => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-GObject, GFlag, N-GObject])),
  copy-finish => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-GObject])),
  create => %( :returns(N-GObject), :parameters([GFlag, N-GObject])),
  create-async => %( :parameters([GFlag, gint, N-GObject, :( N-GObject $source-object, N-GObject $res, gpointer $user-data ), gpointer])),
  create-finish => %( :returns(N-GObject), :parameters([N-GObject])),
  create-readwrite => %( :returns(N-GObject), :parameters([GFlag, N-GObject])),
  create-readwrite-async => %( :parameters([GFlag, gint, N-GObject, :( N-GObject $source-object, N-GObject $res, gpointer $user-data ), gpointer])),
  create-readwrite-finish => %( :returns(N-GObject), :parameters([N-GObject])),
  delete => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-GObject])),
  delete-async => %( :parameters([gint, N-GObject, :( N-GObject $source-object, N-GObject $res, gpointer $user-data ), gpointer])),
  delete-finish => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-GObject])),
  dup => %( :returns(N-GObject)),
  eject-mountable-with-operation => %( :parameters([GFlag, N-GObject, N-GObject, :( N-GObject $source-object, N-GObject $res, gpointer $user-data ), gpointer])),
  eject-mountable-with-operation-finish => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-GObject])),
  enumerate-children => %( :returns(N-GObject), :parameters([Str, GFlag, N-GObject])),
  enumerate-children-async => %( :parameters([Str, GFlag, gint, N-GObject, :( N-GObject $source-object, N-GObject $res, gpointer $user-data ), gpointer])),
  enumerate-children-finish => %( :returns(N-GObject), :parameters([N-GObject])),
  equal => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-GObject])),
  find-enclosing-mount => %( :returns(N-GObject), :parameters([N-GObject])),
  find-enclosing-mount-async => %( :parameters([gint, N-GObject, :( N-GObject $source-object, N-GObject $res, gpointer $user-data ), gpointer])),
  find-enclosing-mount-finish => %( :returns(N-GObject), :parameters([N-GObject])),
  get-basename => %( :returns(Str)),
  get-child => %( :returns(N-GObject), :parameters([Str])),
  get-child-for-display-name => %( :returns(N-GObject), :parameters([Str])),
  get-parent => %( :returns(N-GObject)),
  get-parse-name => %( :returns(Str)),
  get-path => %( :returns(Str)),
  get-relative-path => %( :returns(Str), :parameters([N-GObject])),
  get-uri => %( :returns(Str)),
  get-uri-scheme => %( :returns(Str)),
  has-parent => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-GObject])),
  has-prefix => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-GObject])),
  has-uri-scheme => %( :returns(gboolean), :cnv-return(Bool), :parameters([Str])),
  hash => %( :returns(guint)),
  is-native => %( :returns(gboolean), :cnv-return(Bool)),
  #load-bytes => %( :returns(N-Bytes ), :parameters([N-GObject, gchar-pptr])),
  load-bytes-async => %( :parameters([N-GObject, :( N-GObject $source-object, N-GObject $res, gpointer $user-data ), gpointer])),
  #load-bytes-finish => %( :returns(N-Bytes ), :parameters([N-GObject, gchar-pptr])),
  load-contents => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-GObject, gchar-pptr, CArray[gsize], gchar-pptr])),
  load-contents-async => %( :parameters([N-GObject, :( N-GObject $source-object, N-GObject $res, gpointer $user-data ), gpointer])),
  load-contents-finish => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-GObject, gchar-pptr, CArray[gsize], gchar-pptr])),
  load-partial-contents-async => %( :parameters([N-GObject, :( Str $file-contents,  $file-size, gpointer $callback-data --> gboolean ), :( N-GObject $source-object, N-GObject $res, gpointer $user-data ), gpointer])),
  load-partial-contents-finish => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-GObject, gchar-pptr, CArray[gsize], gchar-pptr])),
  make-directory => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-GObject])),
  make-directory-async => %( :parameters([gint, N-GObject, :( N-GObject $source-object, N-GObject $res, gpointer $user-data ), gpointer])),
  make-directory-finish => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-GObject])),
  make-directory-with-parents => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-GObject])),
  make-symbolic-link => %( :returns(gboolean), :cnv-return(Bool), :parameters([Str, N-GObject])),
  measure-disk-usage => %( :returns(gboolean), :cnv-return(Bool), :parameters([GFlag, N-GObject, :( gboolean $reporting, guint64 $current-size, guint64 $num-dirs, guint64 $num-files, gpointer $user-data ), gpointer, CArray[uint64], CArray[uint64], CArray[uint64]])),
  measure-disk-usage-async => %( :parameters([GFlag, gint, N-GObject, :( gboolean $reporting, guint64 $current-size, guint64 $num-dirs, guint64 $num-files, gpointer $user-data ), gpointer, :( N-GObject $source-object, N-GObject $res, gpointer $user-data ), gpointer])),
  measure-disk-usage-finish => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-GObject, CArray[uint64], CArray[uint64], CArray[uint64]])),
  monitor => %( :returns(N-GObject), :parameters([GFlag, N-GObject])),
  monitor-directory => %( :returns(N-GObject), :parameters([GFlag, N-GObject])),
  monitor-file => %( :returns(N-GObject), :parameters([GFlag, N-GObject])),
  mount-enclosing-volume => %( :parameters([GFlag, N-GObject, N-GObject, :( N-GObject $source-object, N-GObject $res, gpointer $user-data ), gpointer])),
  mount-enclosing-volume-finish => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-GObject])),
  mount-mountable => %( :parameters([GFlag, N-GObject, N-GObject, :( N-GObject $source-object, N-GObject $res, gpointer $user-data ), gpointer])),
  mount-mountable-finish => %( :returns(N-GObject), :parameters([N-GObject])),
  move => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-GObject, GFlag, N-GObject, :(  $current-num-bytes,  $total-num-bytes, gpointer $user-data ), gpointer])),
  move-async => %( :parameters([N-GObject, GFlag, gint, N-GObject, :(  $current-num-bytes,  $total-num-bytes, gpointer $user-data ), gpointer, :( N-GObject $source-object, N-GObject $res, gpointer $user-data ), gpointer])),
  move-finish => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-GObject])),
  open-readwrite => %( :returns(N-GObject), :parameters([N-GObject])),
  open-readwrite-async => %( :parameters([gint, N-GObject, :( N-GObject $source-object, N-GObject $res, gpointer $user-data ), gpointer])),
  open-readwrite-finish => %( :returns(N-GObject), :parameters([N-GObject])),
  peek-path => %( :returns(Str)),
  poll-mountable => %( :parameters([N-GObject, :( N-GObject $source-object, N-GObject $res, gpointer $user-data ), gpointer])),
  poll-mountable-finish => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-GObject])),
  query-default-handler => %( :returns(N-GObject), :parameters([N-GObject])),
  query-default-handler-async => %( :parameters([gint, N-GObject, :( N-GObject $source-object, N-GObject $res, gpointer $user-data ), gpointer])),
  query-default-handler-finish => %( :returns(N-GObject), :parameters([N-GObject])),
  query-exists => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-GObject])),
  query-file-type => %( :returns(GEnum), :cnv-return(GFileType), :parameters([GFlag, N-GObject])),
  query-filesystem-info => %( :returns(N-GObject), :parameters([Str, N-GObject])),
  query-filesystem-info-async => %( :parameters([Str, gint, N-GObject, :( N-GObject $source-object, N-GObject $res, gpointer $user-data ), gpointer])),
  query-filesystem-info-finish => %( :returns(N-GObject), :parameters([N-GObject])),
  query-info => %( :returns(N-GObject), :parameters([Str, GFlag, N-GObject])),
  query-info-async => %( :parameters([Str, GFlag, gint, N-GObject, :( N-GObject $source-object, N-GObject $res, gpointer $user-data ), gpointer])),
  query-info-finish => %( :returns(N-GObject), :parameters([N-GObject])),
  #query-settable-attributes => %( :returns(N-FileAttributeInfoList ), :parameters([N-GObject])),
  #query-writable-namespaces => %( :returns(N-FileAttributeInfoList ), :parameters([N-GObject])),
  read => %( :returns(N-GObject), :parameters([N-GObject])),
  read-async => %( :parameters([gint, N-GObject, :( N-GObject $source-object, N-GObject $res, gpointer $user-data ), gpointer])),
  read-finish => %( :returns(N-GObject), :parameters([N-GObject])),
  replace => %( :returns(N-GObject), :parameters([Str, gboolean, GFlag, N-GObject])),
  replace-async => %( :parameters([Str, gboolean, GFlag, gint, N-GObject, :( N-GObject $source-object, N-GObject $res, gpointer $user-data ), gpointer])),
  replace-contents => %( :returns(gboolean), :cnv-return(Bool), :parameters([Str, gsize, Str, gboolean, GFlag, gchar-pptr, N-GObject])),
  replace-contents-async => %( :parameters([Str, gsize, Str, gboolean, GFlag, N-GObject, :( N-GObject $source-object, N-GObject $res, gpointer $user-data ), gpointer])),
  #replace-contents-bytes-async => %( :parameters([N-Bytes , Str, gboolean, GFlag, N-GObject, :( N-GObject $source-object, N-GObject $res, gpointer $user-data ), gpointer])),
  replace-contents-finish => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-GObject, gchar-pptr])),
  replace-finish => %( :returns(N-GObject), :parameters([N-GObject])),
  replace-readwrite => %( :returns(N-GObject), :parameters([Str, gboolean, GFlag, N-GObject])),
  replace-readwrite-async => %( :parameters([Str, gboolean, GFlag, gint, N-GObject, :( N-GObject $source-object, N-GObject $res, gpointer $user-data ), gpointer])),
  replace-readwrite-finish => %( :returns(N-GObject), :parameters([N-GObject])),
  resolve-relative-path => %( :returns(N-GObject), :parameters([Str])),
  set-attribute => %( :returns(gboolean), :cnv-return(Bool), :parameters([Str, GEnum, gpointer, GFlag, N-GObject])),
  set-attribute-byte-string => %( :returns(gboolean), :cnv-return(Bool), :parameters([Str, Str, GFlag, N-GObject])),
  set-attribute-int32 => %( :returns(gboolean), :cnv-return(Bool), :parameters([Str, gint32, GFlag, N-GObject])),
  set-attribute-int64 => %( :returns(gboolean), :cnv-return(Bool), :parameters([Str, gint64, GFlag, N-GObject])),
  set-attribute-string => %( :returns(gboolean), :cnv-return(Bool), :parameters([Str, Str, GFlag, N-GObject])),
  set-attribute-uint32 => %( :returns(gboolean), :cnv-return(Bool), :parameters([Str, guint32, GFlag, N-GObject])),
  set-attribute-uint64 => %( :returns(gboolean), :cnv-return(Bool), :parameters([Str, guint64, GFlag, N-GObject])),
  set-attributes-async => %( :parameters([N-GObject, GFlag, gint, N-GObject, :( N-GObject $source-object, N-GObject $res, gpointer $user-data ), gpointer])),
  set-attributes-finish => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-GObject, CArray[N-GObject]])),
  set-attributes-from-info => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-GObject, GFlag, N-GObject])),
  set-display-name => %( :returns(N-GObject), :parameters([Str, N-GObject])),
  set-display-name-async => %( :parameters([Str, gint, N-GObject, :( N-GObject $source-object, N-GObject $res, gpointer $user-data ), gpointer])),
  set-display-name-finish => %( :returns(N-GObject), :parameters([N-GObject])),
  start-mountable => %( :parameters([GFlag, N-GObject, N-GObject, :( N-GObject $source-object, N-GObject $res, gpointer $user-data ), gpointer])),
  start-mountable-finish => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-GObject])),
  stop-mountable => %( :parameters([GFlag, N-GObject, N-GObject, :( N-GObject $source-object, N-GObject $res, gpointer $user-data ), gpointer])),
  stop-mountable-finish => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-GObject])),
  supports-thread-contexts => %( :returns(gboolean), :cnv-return(Bool)),
  trash => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-GObject])),
  trash-async => %( :parameters([gint, N-GObject, :( N-GObject $source-object, N-GObject $res, gpointer $user-data ), gpointer])),
  trash-finish => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-GObject])),
  unmount-mountable-with-operation => %( :parameters([GFlag, N-GObject, N-GObject, :( N-GObject $source-object, N-GObject $res, gpointer $user-data ), gpointer])),
  unmount-mountable-with-operation-finish => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-GObject])),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    if $methods{$name}<type>:exists and $methods{$name}<type> eq 'Constructor' {
      my Gnome::N::GnomeRoutineCaller $routine-caller .= new(
        :library(gio-lib()), :sub-prefix<g_file_>
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
