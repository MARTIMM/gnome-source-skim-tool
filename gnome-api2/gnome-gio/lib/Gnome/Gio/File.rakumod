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
use Gnome::N::N-Object:api<2>;
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
  #new-build-filename => %( :type(Constructor), :returns(N-Object), :variable-list, :parameters([ Str])),
  new-for-commandline-arg => %( :type(Constructor), :returns(N-Object), :parameters([ Str])),
  new-for-commandline-arg-and-cwd => %( :type(Constructor), :returns(N-Object), :parameters([ Str, Str])),
  new-for-path => %( :type(Constructor), :returns(N-Object), :parameters([ Str])),
  new-for-uri => %( :type(Constructor), :returns(N-Object), :parameters([ Str])),
  new-tmp => %( :type(Constructor), :returns(N-Object), :parameters([ Str, CArray[N-Object]])),
  parse-name => %( :type(Constructor), :returns(N-Object), :parameters([ Str])),

  #--[Methods]------------------------------------------------------------------
  append-to => %( :returns(N-Object), :parameters([GFlag, N-Object])),
  append-to-async => %( :parameters([GFlag, gint, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  append-to-finish => %( :returns(N-Object), :parameters([N-Object])),
  build-attribute-list-for-copy => %( :returns(Str), :parameters([GFlag, N-Object])),
  copy => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, GFlag, N-Object, :(  $current-num-bytes,  $total-num-bytes, gpointer $user-data ), gpointer])),
  copy-async => %( :parameters([N-Object, GFlag, gint, N-Object, :(  $current-num-bytes,  $total-num-bytes, gpointer $user-data ), gpointer, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  copy-attributes => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, GFlag, N-Object])),
  copy-finish => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  create => %( :returns(N-Object), :parameters([GFlag, N-Object])),
  create-async => %( :parameters([GFlag, gint, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  create-finish => %( :returns(N-Object), :parameters([N-Object])),
  create-readwrite => %( :returns(N-Object), :parameters([GFlag, N-Object])),
  create-readwrite-async => %( :parameters([GFlag, gint, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  create-readwrite-finish => %( :returns(N-Object), :parameters([N-Object])),
  delete => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  delete-async => %( :parameters([gint, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  delete-finish => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  dup => %( :returns(N-Object)),
  eject-mountable-with-operation => %( :parameters([GFlag, N-Object, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  eject-mountable-with-operation-finish => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  enumerate-children => %( :returns(N-Object), :parameters([Str, GFlag, N-Object])),
  enumerate-children-async => %( :parameters([Str, GFlag, gint, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  enumerate-children-finish => %( :returns(N-Object), :parameters([N-Object])),
  equal => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  find-enclosing-mount => %( :returns(N-Object), :parameters([N-Object])),
  find-enclosing-mount-async => %( :parameters([gint, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  find-enclosing-mount-finish => %( :returns(N-Object), :parameters([N-Object])),
  get-basename => %( :returns(Str)),
  get-child => %( :returns(N-Object), :parameters([Str])),
  get-child-for-display-name => %( :returns(N-Object), :parameters([Str])),
  get-parent => %( :returns(N-Object)),
  get-parse-name => %( :returns(Str)),
  get-path => %( :returns(Str)),
  get-relative-path => %( :returns(Str), :parameters([N-Object])),
  get-uri => %( :returns(Str)),
  get-uri-scheme => %( :returns(Str)),
  has-parent => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  has-prefix => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  has-uri-scheme => %( :returns(gboolean), :cnv-return(Bool), :parameters([Str])),
  hash => %( :returns(guint)),
  is-native => %( :returns(gboolean), :cnv-return(Bool)),
  #load-bytes => %( :returns(N-Bytes ), :parameters([N-Object, gchar-pptr])),
  load-bytes-async => %( :parameters([N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  #load-bytes-finish => %( :returns(N-Bytes ), :parameters([N-Object, gchar-pptr])),
  load-contents => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, gchar-pptr, CArray[gsize], gchar-pptr])),
  load-contents-async => %( :parameters([N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  load-contents-finish => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, gchar-pptr, CArray[gsize], gchar-pptr])),
  load-partial-contents-async => %( :parameters([N-Object, :( Str $file-contents,  $file-size, gpointer $callback-data --> gboolean ), :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  load-partial-contents-finish => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, gchar-pptr, CArray[gsize], gchar-pptr])),
  make-directory => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  make-directory-async => %( :parameters([gint, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  make-directory-finish => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  make-directory-with-parents => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  make-symbolic-link => %( :returns(gboolean), :cnv-return(Bool), :parameters([Str, N-Object])),
  measure-disk-usage => %( :returns(gboolean), :cnv-return(Bool), :parameters([GFlag, N-Object, :( gboolean $reporting, guint64 $current-size, guint64 $num-dirs, guint64 $num-files, gpointer $user-data ), gpointer, CArray[uint64], CArray[uint64], CArray[uint64]])),
  measure-disk-usage-async => %( :parameters([GFlag, gint, N-Object, :( gboolean $reporting, guint64 $current-size, guint64 $num-dirs, guint64 $num-files, gpointer $user-data ), gpointer, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  measure-disk-usage-finish => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, CArray[uint64], CArray[uint64], CArray[uint64]])),
  monitor => %( :returns(N-Object), :parameters([GFlag, N-Object])),
  monitor-directory => %( :returns(N-Object), :parameters([GFlag, N-Object])),
  monitor-file => %( :returns(N-Object), :parameters([GFlag, N-Object])),
  mount-enclosing-volume => %( :parameters([GFlag, N-Object, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  mount-enclosing-volume-finish => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  mount-mountable => %( :parameters([GFlag, N-Object, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  mount-mountable-finish => %( :returns(N-Object), :parameters([N-Object])),
  move => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, GFlag, N-Object, :(  $current-num-bytes,  $total-num-bytes, gpointer $user-data ), gpointer])),
  move-async => %( :parameters([N-Object, GFlag, gint, N-Object, :(  $current-num-bytes,  $total-num-bytes, gpointer $user-data ), gpointer, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  move-finish => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  open-readwrite => %( :returns(N-Object), :parameters([N-Object])),
  open-readwrite-async => %( :parameters([gint, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  open-readwrite-finish => %( :returns(N-Object), :parameters([N-Object])),
  peek-path => %( :returns(Str)),
  poll-mountable => %( :parameters([N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  poll-mountable-finish => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  query-default-handler => %( :returns(N-Object), :parameters([N-Object])),
  query-default-handler-async => %( :parameters([gint, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  query-default-handler-finish => %( :returns(N-Object), :parameters([N-Object])),
  query-exists => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  query-file-type => %( :returns(GEnum), :cnv-return(GFileType), :parameters([GFlag, N-Object])),
  query-filesystem-info => %( :returns(N-Object), :parameters([Str, N-Object])),
  query-filesystem-info-async => %( :parameters([Str, gint, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  query-filesystem-info-finish => %( :returns(N-Object), :parameters([N-Object])),
  query-info => %( :returns(N-Object), :parameters([Str, GFlag, N-Object])),
  query-info-async => %( :parameters([Str, GFlag, gint, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  query-info-finish => %( :returns(N-Object), :parameters([N-Object])),
  #query-settable-attributes => %( :returns(N-FileAttributeInfoList ), :parameters([N-Object])),
  #query-writable-namespaces => %( :returns(N-FileAttributeInfoList ), :parameters([N-Object])),
  read => %( :returns(N-Object), :parameters([N-Object])),
  read-async => %( :parameters([gint, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  read-finish => %( :returns(N-Object), :parameters([N-Object])),
  replace => %( :returns(N-Object), :parameters([Str, gboolean, GFlag, N-Object])),
  replace-async => %( :parameters([Str, gboolean, GFlag, gint, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  replace-contents => %( :returns(gboolean), :cnv-return(Bool), :parameters([Str, gsize, Str, gboolean, GFlag, gchar-pptr, N-Object])),
  replace-contents-async => %( :parameters([Str, gsize, Str, gboolean, GFlag, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  #replace-contents-bytes-async => %( :parameters([N-Bytes , Str, gboolean, GFlag, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  replace-contents-finish => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, gchar-pptr])),
  replace-finish => %( :returns(N-Object), :parameters([N-Object])),
  replace-readwrite => %( :returns(N-Object), :parameters([Str, gboolean, GFlag, N-Object])),
  replace-readwrite-async => %( :parameters([Str, gboolean, GFlag, gint, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  replace-readwrite-finish => %( :returns(N-Object), :parameters([N-Object])),
  resolve-relative-path => %( :returns(N-Object), :parameters([Str])),
  set-attribute => %( :returns(gboolean), :cnv-return(Bool), :parameters([Str, GEnum, gpointer, GFlag, N-Object])),
  set-attribute-byte-string => %( :returns(gboolean), :cnv-return(Bool), :parameters([Str, Str, GFlag, N-Object])),
  set-attribute-int32 => %( :returns(gboolean), :cnv-return(Bool), :parameters([Str, gint32, GFlag, N-Object])),
  set-attribute-int64 => %( :returns(gboolean), :cnv-return(Bool), :parameters([Str, gint64, GFlag, N-Object])),
  set-attribute-string => %( :returns(gboolean), :cnv-return(Bool), :parameters([Str, Str, GFlag, N-Object])),
  set-attribute-uint32 => %( :returns(gboolean), :cnv-return(Bool), :parameters([Str, guint32, GFlag, N-Object])),
  set-attribute-uint64 => %( :returns(gboolean), :cnv-return(Bool), :parameters([Str, guint64, GFlag, N-Object])),
  set-attributes-async => %( :parameters([N-Object, GFlag, gint, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  set-attributes-finish => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, CArray[N-Object]])),
  set-attributes-from-info => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, GFlag, N-Object])),
  set-display-name => %( :returns(N-Object), :parameters([Str, N-Object])),
  set-display-name-async => %( :parameters([Str, gint, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  set-display-name-finish => %( :returns(N-Object), :parameters([N-Object])),
  start-mountable => %( :parameters([GFlag, N-Object, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  start-mountable-finish => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  stop-mountable => %( :parameters([GFlag, N-Object, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  stop-mountable-finish => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  supports-thread-contexts => %( :returns(gboolean), :cnv-return(Bool)),
  trash => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  trash-async => %( :parameters([gint, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  trash-finish => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  unmount-mountable-with-operation => %( :parameters([GFlag, N-Object, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  unmount-mountable-with-operation-finish => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
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
