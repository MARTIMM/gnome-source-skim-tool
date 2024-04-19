=comment Package: Gio, C-Source: File
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

#use Gnome::Gio::N-FileAttributeInfoList:api<2>;
use Gnome::Gio::T-Ioenums:api<2>;

#use Gnome::Glib::N-Bytes:api<2>;
use Gnome::Glib::T-error:api<2>;
use Gnome::GObject::Object:api<2>;

use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gio::File:auth<github:MARTIMM>:api<2>;
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
  $!routine-caller .= new(:library(gio-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gio::File' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

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
  new-build-filename => %( :type(Constructor), :is-symbol<g_file_new_build_filename>, :returns(N-Object), :variable-list, :parameters([ Str])),
  new-for-commandline-arg => %( :type(Constructor), :is-symbol<g_file_new_for_commandline_arg>, :returns(N-Object), :parameters([ Str])),
  new-for-commandline-arg-and-cwd => %( :type(Constructor), :is-symbol<g_file_new_for_commandline_arg_and_cwd>, :returns(N-Object), :parameters([ Str, Str])),
  new-for-path => %( :type(Constructor), :is-symbol<g_file_new_for_path>, :returns(N-Object), :parameters([ Str])),
  new-for-uri => %( :type(Constructor), :is-symbol<g_file_new_for_uri>, :returns(N-Object), :parameters([ Str])),
  new-tmp => %( :type(Constructor), :is-symbol<g_file_new_tmp>, :returns(N-Object), :parameters([ Str, CArray[N-Object], CArray[N-Error]])),
  parse-name => %( :type(Constructor), :is-symbol<g_file_parse_name>, :returns(N-Object), :parameters([ Str])),

  #--[Methods]------------------------------------------------------------------
  append-to => %(:is-symbol<g_file_append_to>,  :returns(N-Object), :parameters([GFlag, N-Object, CArray[N-Error]])),
  append-to-async => %(:is-symbol<g_file_append_to_async>,  :parameters([GFlag, gint, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  append-to-finish => %(:is-symbol<g_file_append_to_finish>,  :returns(N-Object), :parameters([N-Object, CArray[N-Error]])),
  build-attribute-list-for-copy => %(:is-symbol<g_file_build_attribute_list_for_copy>,  :returns(Str), :parameters([GFlag, N-Object, CArray[N-Error]])),
  copy => %(:is-symbol<g_file_copy>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, GFlag, N-Object, :(  $current-num-bytes,  $total-num-bytes, gpointer $user-data ), gpointer, CArray[N-Error]])),
  copy-async => %(:is-symbol<g_file_copy_async>,  :parameters([N-Object, GFlag, gint, N-Object, :(  $current-num-bytes,  $total-num-bytes, gpointer $user-data ), gpointer, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  copy-attributes => %(:is-symbol<g_file_copy_attributes>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, GFlag, N-Object, CArray[N-Error]])),
  copy-finish => %(:is-symbol<g_file_copy_finish>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, CArray[N-Error]])),
  create => %(:is-symbol<g_file_create>,  :returns(N-Object), :parameters([GFlag, N-Object, CArray[N-Error]])),
  create-async => %(:is-symbol<g_file_create_async>,  :parameters([GFlag, gint, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  create-finish => %(:is-symbol<g_file_create_finish>,  :returns(N-Object), :parameters([N-Object, CArray[N-Error]])),
  create-readwrite => %(:is-symbol<g_file_create_readwrite>,  :returns(N-Object), :parameters([GFlag, N-Object, CArray[N-Error]])),
  create-readwrite-async => %(:is-symbol<g_file_create_readwrite_async>,  :parameters([GFlag, gint, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  create-readwrite-finish => %(:is-symbol<g_file_create_readwrite_finish>,  :returns(N-Object), :parameters([N-Object, CArray[N-Error]])),
  delete => %(:is-symbol<g_file_delete>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, CArray[N-Error]])),
  delete-async => %(:is-symbol<g_file_delete_async>,  :parameters([gint, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  delete-finish => %(:is-symbol<g_file_delete_finish>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, CArray[N-Error]])),
  dup => %(:is-symbol<g_file_dup>,  :returns(N-Object)),
  eject-mountable-with-operation => %(:is-symbol<g_file_eject_mountable_with_operation>,  :parameters([GFlag, N-Object, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  eject-mountable-with-operation-finish => %(:is-symbol<g_file_eject_mountable_with_operation_finish>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, CArray[N-Error]])),
  enumerate-children => %(:is-symbol<g_file_enumerate_children>,  :returns(N-Object), :parameters([Str, GFlag, N-Object, CArray[N-Error]])),
  enumerate-children-async => %(:is-symbol<g_file_enumerate_children_async>,  :parameters([Str, GFlag, gint, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  enumerate-children-finish => %(:is-symbol<g_file_enumerate_children_finish>,  :returns(N-Object), :parameters([N-Object, CArray[N-Error]])),
  equal => %(:is-symbol<g_file_equal>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  find-enclosing-mount => %(:is-symbol<g_file_find_enclosing_mount>,  :returns(N-Object), :parameters([N-Object, CArray[N-Error]])),
  find-enclosing-mount-async => %(:is-symbol<g_file_find_enclosing_mount_async>,  :parameters([gint, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  find-enclosing-mount-finish => %(:is-symbol<g_file_find_enclosing_mount_finish>,  :returns(N-Object), :parameters([N-Object, CArray[N-Error]])),
  get-basename => %(:is-symbol<g_file_get_basename>,  :returns(Str)),
  get-child => %(:is-symbol<g_file_get_child>,  :returns(N-Object), :parameters([Str])),
  get-child-for-display-name => %(:is-symbol<g_file_get_child_for_display_name>,  :returns(N-Object), :parameters([Str, CArray[N-Error]])),
  get-parent => %(:is-symbol<g_file_get_parent>,  :returns(N-Object)),
  get-parse-name => %(:is-symbol<g_file_get_parse_name>,  :returns(Str)),
  get-path => %(:is-symbol<g_file_get_path>,  :returns(Str)),
  get-relative-path => %(:is-symbol<g_file_get_relative_path>,  :returns(Str), :parameters([N-Object])),
  get-uri => %(:is-symbol<g_file_get_uri>,  :returns(Str)),
  get-uri-scheme => %(:is-symbol<g_file_get_uri_scheme>,  :returns(Str)),
  has-parent => %(:is-symbol<g_file_has_parent>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  has-prefix => %(:is-symbol<g_file_has_prefix>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  has-uri-scheme => %(:is-symbol<g_file_has_uri_scheme>,  :returns(gboolean), :cnv-return(Bool), :parameters([Str])),
  hash => %(:is-symbol<g_file_hash>,  :returns(guint)),
  is-native => %(:is-symbol<g_file_is_native>,  :returns(gboolean), :cnv-return(Bool)),
  #load-bytes => %(:is-symbol<g_file_load_bytes>,  :returns(N-Bytes ), :parameters([N-Object, gchar-pptr, CArray[N-Error]])),
  load-bytes-async => %(:is-symbol<g_file_load_bytes_async>,  :parameters([N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  #load-bytes-finish => %(:is-symbol<g_file_load_bytes_finish>,  :returns(N-Bytes ), :parameters([N-Object, gchar-pptr, CArray[N-Error]])),
  load-contents => %(:is-symbol<g_file_load_contents>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, gchar-pptr, CArray[gsize], gchar-pptr, CArray[N-Error]])),
  load-contents-async => %(:is-symbol<g_file_load_contents_async>,  :parameters([N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  load-contents-finish => %(:is-symbol<g_file_load_contents_finish>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, gchar-pptr, CArray[gsize], gchar-pptr, CArray[N-Error]])),
  load-partial-contents-async => %(:is-symbol<g_file_load_partial_contents_async>,  :parameters([N-Object, :( Str $file-contents,  $file-size, gpointer $user-data --> gboolean ), :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  load-partial-contents-finish => %(:is-symbol<g_file_load_partial_contents_finish>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, gchar-pptr, CArray[gsize], gchar-pptr, CArray[N-Error]])),
  make-directory => %(:is-symbol<g_file_make_directory>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, CArray[N-Error]])),
  make-directory-async => %(:is-symbol<g_file_make_directory_async>,  :parameters([gint, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  make-directory-finish => %(:is-symbol<g_file_make_directory_finish>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, CArray[N-Error]])),
  make-directory-with-parents => %(:is-symbol<g_file_make_directory_with_parents>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, CArray[N-Error]])),
  make-symbolic-link => %(:is-symbol<g_file_make_symbolic_link>,  :returns(gboolean), :cnv-return(Bool), :parameters([Str, N-Object, CArray[N-Error]])),
  measure-disk-usage => %(:is-symbol<g_file_measure_disk_usage>,  :returns(gboolean), :cnv-return(Bool), :parameters([GFlag, N-Object, :( gboolean $reporting, guint64 $current-size, guint64 $num-dirs, guint64 $num-files, gpointer $user-data ), gpointer, CArray[uint64], CArray[uint64], CArray[uint64], CArray[N-Error]])),
  measure-disk-usage-async => %(:is-symbol<g_file_measure_disk_usage_async>,  :parameters([GFlag, gint, N-Object, :( gboolean $reporting, guint64 $current-size, guint64 $num-dirs, guint64 $num-files, gpointer $user-data ), gpointer, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  measure-disk-usage-finish => %(:is-symbol<g_file_measure_disk_usage_finish>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, CArray[uint64], CArray[uint64], CArray[uint64], CArray[N-Error]])),
  monitor => %(:is-symbol<g_file_monitor>,  :returns(N-Object), :parameters([GFlag, N-Object, CArray[N-Error]])),
  monitor-directory => %(:is-symbol<g_file_monitor_directory>,  :returns(N-Object), :parameters([GFlag, N-Object, CArray[N-Error]])),
  monitor-file => %(:is-symbol<g_file_monitor_file>,  :returns(N-Object), :parameters([GFlag, N-Object, CArray[N-Error]])),
  mount-enclosing-volume => %(:is-symbol<g_file_mount_enclosing_volume>,  :parameters([GFlag, N-Object, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  mount-enclosing-volume-finish => %(:is-symbol<g_file_mount_enclosing_volume_finish>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, CArray[N-Error]])),
  mount-mountable => %(:is-symbol<g_file_mount_mountable>,  :parameters([GFlag, N-Object, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  mount-mountable-finish => %(:is-symbol<g_file_mount_mountable_finish>,  :returns(N-Object), :parameters([N-Object, CArray[N-Error]])),
  move => %(:is-symbol<g_file_move>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, GFlag, N-Object, :(  $current-num-bytes,  $total-num-bytes, gpointer $user-data ), gpointer, CArray[N-Error]])),
  move-async => %(:is-symbol<g_file_move_async>,  :parameters([N-Object, GFlag, gint, N-Object, :(  $current-num-bytes,  $total-num-bytes, gpointer $user-data ), gpointer, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  move-finish => %(:is-symbol<g_file_move_finish>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, CArray[N-Error]])),
  open-readwrite => %(:is-symbol<g_file_open_readwrite>,  :returns(N-Object), :parameters([N-Object, CArray[N-Error]])),
  open-readwrite-async => %(:is-symbol<g_file_open_readwrite_async>,  :parameters([gint, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  open-readwrite-finish => %(:is-symbol<g_file_open_readwrite_finish>,  :returns(N-Object), :parameters([N-Object, CArray[N-Error]])),
  peek-path => %(:is-symbol<g_file_peek_path>,  :returns(Str)),
  poll-mountable => %(:is-symbol<g_file_poll_mountable>,  :parameters([N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  poll-mountable-finish => %(:is-symbol<g_file_poll_mountable_finish>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, CArray[N-Error]])),
  query-default-handler => %(:is-symbol<g_file_query_default_handler>,  :returns(N-Object), :parameters([N-Object, CArray[N-Error]])),
  query-default-handler-async => %(:is-symbol<g_file_query_default_handler_async>,  :parameters([gint, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  query-default-handler-finish => %(:is-symbol<g_file_query_default_handler_finish>,  :returns(N-Object), :parameters([N-Object, CArray[N-Error]])),
  query-exists => %(:is-symbol<g_file_query_exists>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  query-file-type => %(:is-symbol<g_file_query_file_type>,  :returns(GEnum), :cnv-return(GFileType), :parameters([GFlag, N-Object])),
  query-filesystem-info => %(:is-symbol<g_file_query_filesystem_info>,  :returns(N-Object), :parameters([Str, N-Object, CArray[N-Error]])),
  query-filesystem-info-async => %(:is-symbol<g_file_query_filesystem_info_async>,  :parameters([Str, gint, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  query-filesystem-info-finish => %(:is-symbol<g_file_query_filesystem_info_finish>,  :returns(N-Object), :parameters([N-Object, CArray[N-Error]])),
  query-info => %(:is-symbol<g_file_query_info>,  :returns(N-Object), :parameters([Str, GFlag, N-Object, CArray[N-Error]])),
  query-info-async => %(:is-symbol<g_file_query_info_async>,  :parameters([Str, GFlag, gint, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  query-info-finish => %(:is-symbol<g_file_query_info_finish>,  :returns(N-Object), :parameters([N-Object, CArray[N-Error]])),
  #query-settable-attributes => %(:is-symbol<g_file_query_settable_attributes>,  :returns(N-FileAttributeInfoList ), :parameters([N-Object, CArray[N-Error]])),
  #query-writable-namespaces => %(:is-symbol<g_file_query_writable_namespaces>,  :returns(N-FileAttributeInfoList ), :parameters([N-Object, CArray[N-Error]])),
  read => %(:is-symbol<g_file_read>,  :returns(N-Object), :parameters([N-Object, CArray[N-Error]])),
  read-async => %(:is-symbol<g_file_read_async>,  :parameters([gint, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  read-finish => %(:is-symbol<g_file_read_finish>,  :returns(N-Object), :parameters([N-Object, CArray[N-Error]])),
  replace => %(:is-symbol<g_file_replace>,  :returns(N-Object), :parameters([Str, gboolean, GFlag, N-Object, CArray[N-Error]])),
  replace-async => %(:is-symbol<g_file_replace_async>,  :parameters([Str, gboolean, GFlag, gint, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  replace-contents => %(:is-symbol<g_file_replace_contents>,  :returns(gboolean), :cnv-return(Bool), :parameters([Str, gsize, Str, gboolean, GFlag, gchar-pptr, N-Object, CArray[N-Error]])),
  replace-contents-async => %(:is-symbol<g_file_replace_contents_async>,  :parameters([Str, gsize, Str, gboolean, GFlag, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  #replace-contents-bytes-async => %(:is-symbol<g_file_replace_contents_bytes_async>,  :parameters([N-Bytes , Str, gboolean, GFlag, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  replace-contents-finish => %(:is-symbol<g_file_replace_contents_finish>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, gchar-pptr, CArray[N-Error]])),
  replace-finish => %(:is-symbol<g_file_replace_finish>,  :returns(N-Object), :parameters([N-Object, CArray[N-Error]])),
  replace-readwrite => %(:is-symbol<g_file_replace_readwrite>,  :returns(N-Object), :parameters([Str, gboolean, GFlag, N-Object, CArray[N-Error]])),
  replace-readwrite-async => %(:is-symbol<g_file_replace_readwrite_async>,  :parameters([Str, gboolean, GFlag, gint, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  replace-readwrite-finish => %(:is-symbol<g_file_replace_readwrite_finish>,  :returns(N-Object), :parameters([N-Object, CArray[N-Error]])),
  resolve-relative-path => %(:is-symbol<g_file_resolve_relative_path>,  :returns(N-Object), :parameters([Str])),
  set-attribute => %(:is-symbol<g_file_set_attribute>,  :returns(gboolean), :cnv-return(Bool), :parameters([Str, GEnum, gpointer, GFlag, N-Object, CArray[N-Error]])),
  set-attribute-byte-string => %(:is-symbol<g_file_set_attribute_byte_string>,  :returns(gboolean), :cnv-return(Bool), :parameters([Str, Str, GFlag, N-Object, CArray[N-Error]])),
  set-attribute-int32 => %(:is-symbol<g_file_set_attribute_int32>,  :returns(gboolean), :cnv-return(Bool), :parameters([Str, gint32, GFlag, N-Object, CArray[N-Error]])),
  set-attribute-int64 => %(:is-symbol<g_file_set_attribute_int64>,  :returns(gboolean), :cnv-return(Bool), :parameters([Str, gint64, GFlag, N-Object, CArray[N-Error]])),
  set-attribute-string => %(:is-symbol<g_file_set_attribute_string>,  :returns(gboolean), :cnv-return(Bool), :parameters([Str, Str, GFlag, N-Object, CArray[N-Error]])),
  set-attribute-uint32 => %(:is-symbol<g_file_set_attribute_uint32>,  :returns(gboolean), :cnv-return(Bool), :parameters([Str, guint32, GFlag, N-Object, CArray[N-Error]])),
  set-attribute-uint64 => %(:is-symbol<g_file_set_attribute_uint64>,  :returns(gboolean), :cnv-return(Bool), :parameters([Str, guint64, GFlag, N-Object, CArray[N-Error]])),
  set-attributes-async => %(:is-symbol<g_file_set_attributes_async>,  :parameters([N-Object, GFlag, gint, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  set-attributes-finish => %(:is-symbol<g_file_set_attributes_finish>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, CArray[N-Object], CArray[N-Error]])),
  set-attributes-from-info => %(:is-symbol<g_file_set_attributes_from_info>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, GFlag, N-Object, CArray[N-Error]])),
  set-display-name => %(:is-symbol<g_file_set_display_name>,  :returns(N-Object), :parameters([Str, N-Object, CArray[N-Error]])),
  set-display-name-async => %(:is-symbol<g_file_set_display_name_async>,  :parameters([Str, gint, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  set-display-name-finish => %(:is-symbol<g_file_set_display_name_finish>,  :returns(N-Object), :parameters([N-Object, CArray[N-Error]])),
  start-mountable => %(:is-symbol<g_file_start_mountable>,  :parameters([GFlag, N-Object, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  start-mountable-finish => %(:is-symbol<g_file_start_mountable_finish>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, CArray[N-Error]])),
  stop-mountable => %(:is-symbol<g_file_stop_mountable>,  :parameters([GFlag, N-Object, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  stop-mountable-finish => %(:is-symbol<g_file_stop_mountable_finish>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, CArray[N-Error]])),
  supports-thread-contexts => %(:is-symbol<g_file_supports_thread_contexts>,  :returns(gboolean), :cnv-return(Bool)),
  trash => %(:is-symbol<g_file_trash>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, CArray[N-Error]])),
  trash-async => %(:is-symbol<g_file_trash_async>,  :parameters([gint, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  trash-finish => %(:is-symbol<g_file_trash_finish>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, CArray[N-Error]])),
  unmount-mountable-with-operation => %(:is-symbol<g_file_unmount_mountable_with_operation>,  :parameters([GFlag, N-Object, N-Object, :( N-Object $source-object, N-Object $res, gpointer $user-data ), gpointer])),
  unmount-mountable-with-operation-finish => %(:is-symbol<g_file_unmount_mountable_with_operation_finish>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, CArray[N-Error]])),
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
