#TL:1:Gnome::GObject::T-Type:

use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------
use NativeCall;

#use Gnome::N::X;
use Gnome::N::NativeLib;
use Gnome::N::N-Object;
use Gnome::N::GlibToRakuTypes;

#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------
unit class Gnome::GObject::T-Type:auth<github:MARTIMM>;


#-------------------------------------------------------------------------------
constant G_TYPE_FUNDAMENTAL_SHIFT = 2;
constant G_TYPE_MAKE_FUNDAMENTAL_MAX is export =
         255 +< G_TYPE_FUNDAMENTAL_SHIFT;

constant G_TYPE_INVALID is export = 0 +< G_TYPE_FUNDAMENTAL_SHIFT;
constant G_TYPE_NONE is export = 1 +< G_TYPE_FUNDAMENTAL_SHIFT;
constant G_TYPE_INTERFACE is export = 2 +< G_TYPE_FUNDAMENTAL_SHIFT;

constant G_TYPE_CHAR is export = 3 +< G_TYPE_FUNDAMENTAL_SHIFT;
constant G_TYPE_UCHAR is export = 4 +< G_TYPE_FUNDAMENTAL_SHIFT;
constant G_TYPE_BOOLEAN is export = 5 +< G_TYPE_FUNDAMENTAL_SHIFT;
constant G_TYPE_INT is export = 6 +< G_TYPE_FUNDAMENTAL_SHIFT;
constant G_TYPE_UINT is export = 7 +< G_TYPE_FUNDAMENTAL_SHIFT;
constant G_TYPE_LONG is export = 8 +< G_TYPE_FUNDAMENTAL_SHIFT;
constant G_TYPE_ULONG is export = 9 +< G_TYPE_FUNDAMENTAL_SHIFT;
constant G_TYPE_INT64 is export = 10 +< G_TYPE_FUNDAMENTAL_SHIFT;
constant G_TYPE_UINT64 is export = 11 +< G_TYPE_FUNDAMENTAL_SHIFT;
constant G_TYPE_ENUM is export = 12 +< G_TYPE_FUNDAMENTAL_SHIFT;
constant G_TYPE_FLAGS is export = 13 +< G_TYPE_FUNDAMENTAL_SHIFT;
constant G_TYPE_FLOAT is export = 14 +< G_TYPE_FUNDAMENTAL_SHIFT;
constant G_TYPE_DOUBLE is export = 15 +< G_TYPE_FUNDAMENTAL_SHIFT;
constant G_TYPE_STRING is export = 16 +< G_TYPE_FUNDAMENTAL_SHIFT;
constant G_TYPE_POINTER is export = 17 +< G_TYPE_FUNDAMENTAL_SHIFT;
constant G_TYPE_BOXED is export = 18 +< G_TYPE_FUNDAMENTAL_SHIFT;
constant G_TYPE_PARAM is export = 19 +< G_TYPE_FUNDAMENTAL_SHIFT;
constant G_TYPE_OBJECT is export = 20 +< G_TYPE_FUNDAMENTAL_SHIFT;
constant G_TYPE_VARIANT is export = 21 +< G_TYPE_FUNDAMENTAL_SHIFT;

















=finish

#-------------------------------------------------------------------------------
method FALLBACK ( $native-sub is copy, |c ) {

  CATCH { .note; die; }

#`{{
  $native-sub ~~ s:g/ '-' /_/ if $native-sub.index('-');
  die X::Gnome.new(:message(
    "Native sub name '$native-sub' made too short. Keep at least one '-' or '_'."
    )
  ) unless $native-sub.index('_') >= 0;
}}

  my Str $new-patt = $native-sub.subst( '_', '-', :g);

  my Callable $s;
  try { $s = &::("g_type_$native-sub"); };
  if ?$s {
    Gnome::N::deprecate(
      "g_type_$native-sub", $new-patt, '0.19.11', '0.20.0'
    );
  }

  else {
    try { $s = &::("g_$native-sub") } unless ?$s;
    if ?$s {
      Gnome::N::deprecate(
        "g_$native-sub", $new-patt.subst('type-'),
        '0.19.11', '0.20.0'
      );
    }

    else {
      try { $s = &::($native-sub); } if !$s and $native-sub ~~ m/^ 'g_' /;
      if ?$s {
        Gnome::N::deprecate(
          "$native-sub", $new-patt.subst('g-type-'),
          '0.19.11', '0.20.0'
        );
      }
    }
  }

  $s(|c)
}

#-------------------------------------------------------------------------------
# conveniance method to convert a type to a Raku parameter
#TM:4:get-parameter:Gnome::Gtk3::ListStore
method get-parameter( UInt $type, :$otype --> Parameter ) {

  # tests showed elsewhere that types can come in negative. this should be
  # trapped at the generated spot but it could be anywhere so here it
  # should be converted in any case. It is caused by returned types with
  # 32th bit set which is seen as negative. remedy is to take a two's
  # complement of the negative value.
  #$type = ^+ $type if $type < 0;

  my Parameter $p;
  given $type {
    when G_TYPE_CHAR    { $p .= new(type => gchar); }
    when G_TYPE_UCHAR   { $p .= new(type => guchar); }
    when G_TYPE_BOOLEAN { $p .= new(type => gboolean); }
    when G_TYPE_INT     { $p .= new(type => gint); }
    when G_TYPE_UINT    { $p .= new(type => guint); }
    when G_TYPE_LONG    { $p .= new(type => glong); }
    when G_TYPE_ULONG   { $p .= new(type => gulong); }
    when G_TYPE_INT64   { $p .= new(type => gint64); }
    when G_TYPE_UINT64  { $p .= new(type => guint64); }
    when G_TYPE_ENUM    { $p .= new(type => gint); }
    when G_TYPE_FLAGS   { $p .= new(type => gint); }
    when G_TYPE_FLOAT   { $p .= new(type => gfloat); }
    when G_TYPE_DOUBLE  { $p .= new(type => gdouble); }
    when G_TYPE_STRING  { $p .= new(type => gchar-ptr); }

#    when G_TYPE_OBJECT | G_TYPE_BOXED {
#      die X::Gnome.new(:message('Object in named argument :o not defined'))
#          unless ?$otype;
#      $p .= new(type => $otype.get-class-gtype);
#      $p .= new(:$type);
#    }

#    when G_TYPE_POINTER { $p .= new(type => ); }
#    when G_TYPE_PARAM { $p .= new(type => ); }
#    when G_TYPE_VARIANT {$p .= new(type => ); }
#    when N-Object {
#      $p .= new(type => G_TYPE_OBJECT);
#    }

    default {
      # if type is larger than the max of fundamental types (like G_TYPE_INT) it
      # is a type which is set when a GTK+ object is created. In Raku the
      # object type is stored in the class as $!class-gtype in
      # Gnome::N::TopLevelSupport and retrievable with .get-class-gtype()
      if $type > G_TYPE_MAKE_FUNDAMENTAL_MAX {
        $p .= new(:$type);
      }

      elsif ?$otype {
        $p .= new(type => $otype.get-class-gtype);
      }

      else {
        die X::Gnome.new(
          :message("Unknown basic type $type and \$otype is undefined")
        );
      }
    }
  }

  $p
}


#`{{
#-------------------------------------------------------------------------------
# TM:0:add-class-cache-func:
=begin pod
=head2 add-class-cache-func

Adds a B<Gnome::GObject::TypeClassCacheFunc> to be called before the reference count of a class goes from one to zero. This can be used to prevent premature class destruction. All installed B<Gnome::GObject::TypeClassCacheFunc> functions will be chained until one of them returns C<True>. The functions have to check the class id passed in to figure whether they actually want to cache the class of this type, since all classes are routed through the same B<Gnome::GObject::TypeClassCacheFunc> chain.

  method add-class-cache-func ( Pointer $cache_data, GTypeClassCacheFunc $cache_func )

=item Pointer $cache_data; data to be passed to I<cache-func>
=item GTypeClassCacheFunc $cache_func; a B<Gnome::GObject::TypeClassCacheFunc>
=end pod

method add-class-cache-func ( Pointer $cache_data, GTypeClassCacheFunc $cache_func ) {

  g_type_add_class_cache_func(
    self._get-native-object-no-reffing, $cache_data, $cache_func
  );
}

sub g_type_add_class_cache_func (
  gpointer $cache_data, GTypeClassCacheFunc $cache_func
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:add-class-private:
=begin pod
=head2 add-class-private

Registers a private class structure for a classed type; when the class is allocated, the private structures for the class and all of its parent types are allocated sequentially in the same memory block as the public structures, and are zero-filled.

This function should be called in the type's C<get-type()> function after the type is registered. The private structure can be retrieved using the C<G-TYPE-CLASS-GET-PRIVATE()> macro.

  method add-class-private ( UInt $private_size )

=item UInt $private_size; size of private structure
=end pod

method add-class-private ( UInt $private_size ) {

  g_type_add_class_private(
    self._get-native-object-no-reffing, $private_size
  );
}

sub g_type_add_class_private (
  N-Object $class_type, gsize $private_size
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:add-instance-private:
=begin pod
=head2 add-instance-private



  method add-instance-private ( UInt $private_size --> Int )

=item UInt $private_size;
=end pod

method add-instance-private ( UInt $private_size --> Int ) {

  g_type_add_instance_private(
    self._get-native-object-no-reffing, $private_size
  )
}

sub g_type_add_instance_private (
  N-Object $class_type, gsize $private_size --> gint
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:add-interface-check:
=begin pod
=head2 add-interface-check

Adds a function to be called after an interface vtable is initialized for any class (i.e. after the I<interface-init> member of B<Gnome::GObject::InterfaceInfo> has been called).

This function is useful when you want to check an invariant that depends on the interfaces of a class. For instance, the implementation of B<Gnome::GObject::Object> uses this facility to check that an object implements all of the properties that are defined on its interfaces.

  method add-interface-check ( Pointer $check_data, GTypeInterfaceCheckFunc $check_func )

=item Pointer $check_data; data to pass to I<check-func>
=item GTypeInterfaceCheckFunc $check_func; function to be called after each interface is initialized
=end pod

method add-interface-check ( Pointer $check_data, GTypeInterfaceCheckFunc $check_func ) {

  g_type_add_interface_check(
    self._get-native-object-no-reffing, $check_data, $check_func
  );
}

sub g_type_add_interface_check (
  gpointer $check_data, GTypeInterfaceCheckFunc $check_func
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:add-interface-dynamic:
=begin pod
=head2 add-interface-dynamic

Adds the dynamic I<interface-type> to I<instantiable-type>. The information contained in the B<Gnome::GObject::TypePlugin> structure pointed to by I<plugin> is used to manage the relationship.

  method add-interface-dynamic ( N-Object $interface_type, N-Object $plugin )

=item N-Object $interface_type; B<Gnome::GObject::Type> value of an interface type
=item N-Object $plugin; B<Gnome::GObject::TypePlugin> structure to retrieve the B<Gnome::GObject::InterfaceInfo> from
=end pod

method add-interface-dynamic ( $interface_type is copy, $plugin is copy ) {
  $interface_type .= _get-native-object-no-reffing unless $interface_type ~~ N-Object;
  $plugin .= _get-native-object-no-reffing unless $plugin ~~ N-Object;

  g_type_add_interface_dynamic(
    self._get-native-object-no-reffing, $interface_type, $plugin
  );
}

sub g_type_add_interface_dynamic (
  N-Object $instance_type, N-Object $interface_type, N-Object $plugin
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:add-interface-static:
=begin pod
=head2 add-interface-static

Adds the static I<interface-type> to I<instantiable-type>. The information contained in the B<Gnome::GObject::InterfaceInfo> structure pointed to by I<info> is used to manage the relationship.

  method add-interface-static ( N-Object $interface_type, GInterfaceInfo $info )

=item N-Object $interface_type; B<Gnome::GObject::Type> value of an interface type
=item GInterfaceInfo $info; B<Gnome::GObject::InterfaceInfo> structure for this (I<instance-type>, I<interface-type>) combination
=end pod

method add-interface-static ( $interface_type is copy, GInterfaceInfo $info ) {
  $interface_type .= _get-native-object-no-reffing unless $interface_type ~~ N-Object;

  g_type_add_interface_static(
    self._get-native-object-no-reffing, $interface_type, $info
  );
}

sub g_type_add_interface_static (
  N-Object $instance_type, N-Object $interface_type, GInterfaceInfo $info
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:check-class-cast:
=begin pod
=head2 check-class-cast



  method check-class-cast ( GTypeClass $g_class, N-Object $is_a_type --> GTypeClass )

=item GTypeClass $g_class;
=item N-Object $is_a_type;
=end pod

method check-class-cast ( GTypeClass $g_class, $is_a_type is copy --> GTypeClass ) {
  $is_a_type .= _get-native-object-no-reffing unless $is_a_type ~~ N-Object;

  g_type_check_class_cast(
    self._get-native-object-no-reffing, $g_class, $is_a_type
  )
}

sub g_type_check_class_cast (
  GTypeClass $g_class, N-Object $is_a_type --> GTypeClass
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:check-class-is-a:
=begin pod
=head2 check-class-is-a



  method check-class-is-a ( GTypeClass $g_class, N-Object $is_a_type --> Bool )

=item GTypeClass $g_class;
=item N-Object $is_a_type;
=end pod

method check-class-is-a ( GTypeClass $g_class, $is_a_type is copy --> Bool ) {
  $is_a_type .= _get-native-object-no-reffing unless $is_a_type ~~ N-Object;

  g_type_check_class_is_a(
    self._get-native-object-no-reffing, $g_class, $is_a_type
  ).Bool
}

sub g_type_check_class_is_a (
  GTypeClass $g_class, N-Object $is_a_type --> gboolean
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:check-instance:
=begin pod
=head2 check-instance

Private helper function to aid implementation of the C<G-TYPE-CHECK-INSTANCE()> macro.

Returns: C<True> if I<instance> is valid, C<False> otherwise

  method check-instance ( GTypeInstance $instance --> Bool )

=item GTypeInstance $instance; a valid B<Gnome::GObject::TypeInstance> structure
=end pod

method check-instance ( GTypeInstance $instance --> Bool ) {

  g_type_check_instance(
    self._get-native-object-no-reffing, $instance
  ).Bool
}

sub g_type_check_instance (
  GTypeInstance $instance --> gboolean
) is native(&gobject-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:2:check-instance-cast:
=begin pod
=head2 check-instance-cast

Checks that instance is an instance of the type identified by g_type and issues a warning if this is not the case. Returns instance casted to a pointer to c_type.

No warning will be issued if instance is NULL, and NULL will be returned.

  method check-instance-cast (
    N-Object $instance, UInt $iface_type --> N-Object
  )

=item N-Object $instance;
=item UInt $iface_type;
=end pod

method check-instance-cast (
  $instance is copy, UInt $iface_gtype --> N-Object
) {
  $instance .= _get-native-object-no-reffing unless $instance ~~ N-Object;
  g_type_check_instance_cast( $instance, $iface_gtype)
}

sub g_type_check_instance_cast (
  N-Object $instance, GType $iface_type --> N-Object
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:2:check-instance-is-a:
=begin pod
=head2 check-instance-is-a

Check if an instance is of type C<$iface-gtype>. Returns True if it is.

  method check-instance-is-a (
    N-Object $instance, UInt $iface_gtype --> Bool
  )

=item N-Object $instance;
=item UInt $iface_type;
=end pod

method check-instance-is-a (
  $instance is copy, UInt $iface_gtype --> Bool
) {
  $instance .= _get-native-object-no-reffing unless $instance ~~ N-Object;
  g_type_check_instance_is_a( $instance, $iface_gtype).Bool
}

sub g_type_check_instance_is_a (
  N-Object $instance, GType $iface_gtype --> gboolean
) is native(&gobject-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
# TM:0:check-instance-is-fundamentally-a:
=begin pod
=head2 check-instance-is-fundamentally-a



  method check-instance-is-fundamentally-a ( GTypeInstance $instance, N-Object $fundamental_type --> Bool )

=item GTypeInstance $instance;
=item N-Object $fundamental_type;
=end pod

method check-instance-is-fundamentally-a ( GTypeInstance $instance, $fundamental_type is copy --> Bool ) {
  $fundamental_type .= _get-native-object-no-reffing unless $fundamental_type ~~ N-Object;

  g_type_check_instance_is_fundamentally_a(
    self._get-native-object-no-reffing, $instance, $fundamental_type
  ).Bool
}

sub g_type_check_instance_is_fundamentally_a (
  GTypeInstance $instance, N-Object $fundamental_type --> gboolean
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:check-value:
=begin pod
=head2 check-value



  method check-value ( N-Object $value --> Bool )

=item N-Object $value;
=end pod

method check-value ( $value is copy --> Bool ) {
  $value .= _get-native-object-no-reffing unless $value ~~ N-Object;

  g_type_check_value(
    self._get-native-object-no-reffing, $value
  ).Bool
}

sub g_type_check_value (
  N-Object $value --> gboolean
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:check-value-holds:
=begin pod
=head2 check-value-holds



  method check-value-holds ( N-Object $value, N-Object $type --> Bool )

=item N-Object $value;
=item N-Object $type;
=end pod

method check-value-holds ( $value is copy, $type is copy --> Bool ) {
  $value .= _get-native-object-no-reffing unless $value ~~ N-Object;
  $type .= _get-native-object-no-reffing unless $type ~~ N-Object;

  g_type_check_value_holds(
    self._get-native-object-no-reffing, $value, $type
  ).Bool
}

sub g_type_check_value_holds (
  N-Object $value, N-Object $type --> gboolean
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:children:
=begin pod
=head2 children

Return a newly allocated and 0-terminated array of type IDs, listing the child types of I<type>.

Returns: (array length=n-children) : Newly allocated and 0-terminated array of child types, free with C<g-free()>

  method children ( guInt-ptr $n_children --> N-Object )

=item guInt-ptr $n_children; location to store the length of the returned array, or C<undefined>
=end pod

method children ( guInt-ptr $n_children --> N-Object ) {

  g_type_children(
    self._get-native-object-no-reffing, $n_children
  )
}

sub g_type_children (
  N-Object $type, gugint-ptr $n_children --> N-Object
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:class-adjust-private-offset:
=begin pod
=head2 class-adjust-private-offset



  method class-adjust-private-offset ( Pointer $g_class )

=item Pointer $g_class;
=item Int $private_size_or_offset;
=end pod

method class-adjust-private-offset ( Pointer $g_class ) {

  g_type_class_adjust_private_offset(
    self._get-native-object-no-reffing, $g_class, my gint $private_size_or_offset
  );
}

sub g_type_class_adjust_private_offset (
  gpointer $g_class, gint $private_size_or_offset is rw
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:class-get-instance-private-offset:
=begin pod
=head2 class-get-instance-private-offset

Gets the offset of the private data for instances of I<g-class>.

This is how many bytes you should add to the instance pointer of a class in order to get the private data for the type represented by I<g-class>.

You can only call this function after you have registered a private data area for I<g-class> using C<class-add-private()>.

Returns: the offset, in bytes

  method class-get-instance-private-offset ( Pointer $g_class --> Int )

=item Pointer $g_class; (type GObject.TypeClass): a B<Gnome::GObject::TypeClass>
=end pod

method class-get-instance-private-offset ( Pointer $g_class --> Int ) {

  g_type_class_get_instance_private_offset(
    self._get-native-object-no-reffing, $g_class
  )
}

sub g_type_class_get_instance_private_offset (
  gpointer $g_class --> gint
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:class-get-private:
=begin pod
=head2 class-get-private



  method class-get-private ( GTypeClass $klass, N-Object $private_type --> Pointer )

=item GTypeClass $klass;
=item N-Object $private_type;
=end pod

method class-get-private ( GTypeClass $klass, $private_type is copy --> Pointer ) {
  $private_type .= _get-native-object-no-reffing unless $private_type ~~ N-Object;

  g_type_class_get_private(
    self._get-native-object-no-reffing, $klass, $private_type
  )
}

sub g_type_class_get_private (
  GTypeClass $klass, N-Object $private_type --> gpointer
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:class-peek:
=begin pod
=head2 class-peek

This function is essentially the same as C<class-ref()>, except that the classes reference count isn't incremented. As a consequence, this function may return C<undefined> if the class of the type passed in does not currently exist (hasn't been referenced before).

Returns: (type GObject.TypeClass) : the B<Gnome::GObject::TypeClass> structure for the given type ID or C<undefined> if the class does not currently exist

  method class-peek ( --> Pointer )

=end pod

method class-peek ( --> Pointer ) {

  g_type_class_peek(
    self._get-native-object-no-reffing,
  )
}

sub g_type_class_peek (
  N-Object $type --> gpointer
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:class-peek-parent:
=begin pod
=head2 class-peek-parent

This is a convenience function often needed in class initializers. It returns the class structure of the immediate parent type of the class passed in. Since derived classes hold a reference count on their parent classes as long as they are instantiated, the returned class will always exist.

This function is essentially equivalent to: class-peek (g-type-parent (G-TYPE-FROM-CLASS (g-class)))

Returns: (type GObject.TypeClass) : the parent class of I<g-class>

  method class-peek-parent ( Pointer $g_class --> Pointer )

=item Pointer $g_class; (type GObject.TypeClass): the B<Gnome::GObject::TypeClass> structure to retrieve the parent class for
=end pod

method class-peek-parent ( Pointer $g_class --> Pointer ) {

  g_type_class_peek_parent(
    self._get-native-object-no-reffing, $g_class
  )
}

sub g_type_class_peek_parent (
  gpointer $g_class --> gpointer
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:class-peek-static:
=begin pod
=head2 class-peek-static

A more efficient version of C<class-peek()> which works only for static types.

Returns: (type GObject.TypeClass) : the B<Gnome::GObject::TypeClass> structure for the given type ID or C<undefined> if the class does not currently exist or is dynamically loaded

  method class-peek-static ( --> Pointer )

=end pod

method class-peek-static ( --> Pointer ) {

  g_type_class_peek_static(
    self._get-native-object-no-reffing,
  )
}

sub g_type_class_peek_static (
  N-Object $type --> gpointer
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:class-ref:
=begin pod
=head2 class-ref

Increments the reference count of the class structure belonging to I<type>. This function will demand-create the class if it doesn't exist already.

Returns: (type GObject.TypeClass) : the B<Gnome::GObject::TypeClass> structure for the given type ID

  method class-ref ( --> Pointer )

=end pod

method class-ref ( --> Pointer ) {

  g_type_class_ref(
    self._get-native-object-no-reffing,
  )
}

sub g_type_class_ref (
  N-Object $type --> gpointer
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:class-unref:
=begin pod
=head2 class-unref

Decrements the reference count of the class structure being passed in. Once the last reference count of a class has been released, classes may be finalized by the type system, so further dereferencing of a class pointer after C<class-unref()> are invalid.

  method class-unref ( Pointer $g_class )

=item Pointer $g_class; (type GObject.TypeClass): a B<Gnome::GObject::TypeClass> structure to unref
=end pod

method class-unref ( Pointer $g_class ) {

  g_type_class_unref(
    self._get-native-object-no-reffing, $g_class
  );
}

sub g_type_class_unref (
  gpointer $g_class
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:class-unref-uncached:
=begin pod
=head2 class-unref-uncached

A variant of C<class-unref()> for use in B<Gnome::GObject::TypeClassCacheFunc> implementations. It unreferences a class without consulting the chain of B<Gnome::GObject::TypeClassCacheFuncs>, avoiding the recursion which would occur otherwise.

  method class-unref-uncached ( Pointer $g_class )

=item Pointer $g_class; (type GObject.TypeClass): a B<Gnome::GObject::TypeClass> structure to unref
=end pod

method class-unref-uncached ( Pointer $g_class ) {

  g_type_class_unref_uncached(
    self._get-native-object-no-reffing, $g_class
  );
}

sub g_type_class_unref_uncached (
  gpointer $g_class
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:create-instance:
=begin pod
=head2 create-instance

Creates and initializes an instance of I<type> if I<type> is valid and can be instantiated. The type system only performs basic allocation and structure setups for instances: actual instance creation should happen through functions supplied by the type's fundamental type implementation. So use of C<create-instance()> is reserved for implementators of fundamental types only. E.g. instances of the B<Gnome::GObject::Object> hierarchy should be created via C<g-object-new()> and never directly through C<g-type-create-instance()> which doesn't handle things like singleton objects or object construction.

The extended members of the returned instance are guaranteed to be filled with zeros.

Note: Do not use this function, unless you're implementing a fundamental type. Also language bindings should not use this function, but C<g-object-new()> instead.

Returns: an allocated and initialized instance, subject to further treatment by the fundamental type implementation

  method create-instance ( --> GTypeInstance )

=end pod

method create-instance ( --> GTypeInstance ) {

  g_type_create_instance(
    self._get-native-object-no-reffing,
  )
}

sub g_type_create_instance (
  N-Object $type --> GTypeInstance
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:default-interface-peek:
=begin pod
=head2 default-interface-peek

If the interface type I<g-type> is currently in use, returns its default interface vtable.

Returns: (type GObject.TypeInterface) : the default vtable for the interface, or C<undefined> if the type is not currently in use

  method default-interface-peek ( --> Pointer )

=end pod

method default-interface-peek ( --> Pointer ) {

  g_type_default_interface_peek(
    self._get-native-object-no-reffing,
  )
}

sub g_type_default_interface_peek (
  N-Object $g_type --> gpointer
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:default-interface-ref:
=begin pod
=head2 default-interface-ref

Increments the reference count for the interface type I<g-type>, and returns the default interface vtable for the type.

If the type is not currently in use, then the default vtable for the type will be created and initalized by calling the base interface init and default vtable init functions for the type (the I<base-init> and I<class-init> members of B<Gnome::GObject::TypeInfo>). Calling C<default-interface-ref()> is useful when you want to make sure that signals and properties for an interface have been installed.

Returns: (type GObject.TypeInterface) : the default vtable for the interface; call C<g-type-default-interface-unref()> when you are done using the interface.

  method default-interface-ref ( --> Pointer )

=end pod

method default-interface-ref ( --> Pointer ) {

  g_type_default_interface_ref(
    self._get-native-object-no-reffing,
  )
}

sub g_type_default_interface_ref (
  N-Object $g_type --> gpointer
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:default-interface-unref:
=begin pod
=head2 default-interface-unref

Decrements the reference count for the type corresponding to the interface default vtable I<g-iface>. If the type is dynamic, then when no one is using the interface and all references have been released, the finalize function for the interface's default vtable (the I<class-finalize> member of B<Gnome::GObject::TypeInfo>) will be called.

  method default-interface-unref ( Pointer $g_iface )

=item Pointer $g_iface; (type GObject.TypeInterface): the default vtable structure for a interface, as returned by C<default-interface-ref()>
=end pod

method default-interface-unref ( Pointer $g_iface ) {

  g_type_default_interface_unref(
    self._get-native-object-no-reffing, $g_iface
  );
}

sub g_type_default_interface_unref (
  gpointer $g_iface
) is native(&gobject-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:2:depth:
=begin pod
=head2 depth

Returns the length of the ancestry of the passed in type. This includes the type itself, so that e.g. a fundamental type has depth 1.

Returns: the depth of I<$gtype>

  method depth ( UInt $gtype --> UInt )

=end pod

method depth ( UInt $gtype --> UInt ) {
  g_type_depth($gtype)
}

sub g_type_depth (
  GType $type --> guint
) is native(&gobject-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
# TM:0:ensure:
=begin pod
=head2 ensure

Ensures that the indicated I<type> has been registered with the type system, and its C<-class-init()> method has been run.

In theory, simply calling the type's C<-get-type()> method (or using the corresponding macro) is supposed take care of this. However, C<-get-type()> methods are often marked C<G-GNUC-CONST> for performance reasons, even though this is technically incorrect (since C<G-GNUC-CONST> requires that the function not have side effects, which C<-get-type()> methods do on the first call). As a result, if you write a bare call to a C<-get-type()> macro, it may get optimized out by the compiler. Using C<ensure()> guarantees that the type's C<-get-type()> method is called.

  method ensure ( )

=end pod

method ensure ( ) {

  g_type_ensure(
    self._get-native-object-no-reffing,
  );
}

sub g_type_ensure (
  N-Object $type
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:free-instance:
=begin pod
=head2 free-instance

Frees an instance of a type, returning it to the instance pool for the type, if there is one.

Like C<create-instance()>, this function is reserved for implementors of fundamental types.

  method free-instance ( GTypeInstance $instance )

=item GTypeInstance $instance; an instance of a type
=end pod

method free-instance ( GTypeInstance $instance ) {

  g_type_free_instance(
    self._get-native-object-no-reffing, $instance
  );
}

sub g_type_free_instance (
  GTypeInstance $instance
) is native(&gobject-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:2:from-name:
=begin pod
=head2 from-name

Lookup the type ID from a given type name, returning 0 if no type has been registered under this name (this is the preferred method to find out by name whether a specific type has been registered yet).

Returns: corresponding type ID or 0

  method from-name ( Str $name --> UInt )

=item Str $name; type name to lookup
=end pod

method from-name ( Str $name --> UInt ) {
  g_type_from_name($name)
}

sub g_type_from_name (
  gchar-ptr $name --> GType
) is native(&gobject-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
# TM:0:fundamental:
=begin pod
=head2 fundamental

Internal function, used to extract the fundamental type ID portion. Use C<G-TYPE-FUNDAMENTAL()> instead.

Returns: fundamental type ID

  method fundamental ( --> N-Object )

=end pod

method fundamental ( --> N-Object ) {

  g_type_fundamental(
    self._get-native-object-no-reffing,
  )
}

sub g_type_fundamental (
  N-Object $type_id --> N-Object
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:fundamental-next:
=begin pod
=head2 fundamental-next

Returns the next free fundamental type id which can be used to register a new fundamental type with C<register-fundamental()>. The returned type ID represents the highest currently registered fundamental type identifier.

Returns: the next available fundamental type ID to be registered, or 0 if the type system ran out of fundamental type IDs

  method fundamental-next ( --> N-Object )

=end pod

method fundamental-next ( --> N-Object ) {

  g_type_fundamental_next(
    self._get-native-object-no-reffing,
  )
}

sub g_type_fundamental_next (
   --> N-Object
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:get-instance-count:
=begin pod
=head2 get-instance-count

Returns the number of instances allocated of the particular type; this is only available if GLib is built with debugging support and the instance-count debug flag is set (by setting the GOBJECT-DEBUG variable to include instance-count).

Returns: the number of instances allocated of the given type; if instance counts are not available, returns 0.

  method get-instance-count ( --> Int )

=end pod

method get-instance-count ( --> Int ) {

  g_type_get_instance_count(
    self._get-native-object-no-reffing,
  )
}

sub g_type_get_instance_count (
  N-Object $type --> int
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:get-plugin:
=begin pod
=head2 get-plugin

Returns the B<Gnome::GObject::TypePlugin> structure for I<type>.

Returns: the corresponding plugin if I<type> is a dynamic type, C<undefined> otherwise

  method get-plugin ( --> N-Object )

=end pod

method get-plugin ( --> N-Object ) {

  g_type_get_plugin(
    self._get-native-object-no-reffing,
  )
}

sub g_type_get_plugin (
  N-Object $type --> N-Object
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:get-qdata:
=begin pod
=head2 get-qdata

Obtains data which has previously been attached to I<type> with C<set-qdata()>.

Note that this does not take subtyping into account; data attached to one type with C<g-type-set-qdata()> cannot be retrieved from a subtype using C<g-type-get-qdata()>.

Returns: the data, or C<undefined> if no data was found

  method get-qdata ( UInt $quark --> Pointer )

=item UInt $quark; a B<Gnome::GObject::Quark> id to identify the data
=end pod

method get-qdata ( UInt $quark --> Pointer ) {

  g_type_get_qdata(
    self._get-native-object-no-reffing, $quark
  )
}

sub g_type_get_qdata (
  N-Object $type, GQuark $quark --> gpointer
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:get-type-registration-serial:
=begin pod
=head2 get-type-registration-serial

Returns an opaque serial number that represents the state of the set of registered types. Any time a type is registered this serial changes, which means you can cache information based on type lookups (such as C<from-name()>) and know if the cache is still valid at a later time by comparing the current serial with the one at the type lookup.

Returns: An unsigned int, representing the state of type registrations

  method get-type-registration-serial ( --> UInt )

=end pod

method get-type-registration-serial ( --> UInt ) {

  g_type_get_type_registration_serial(
    self._get-native-object-no-reffing,
  )
}

sub g_type_get_type_registration_serial (
   --> guint
) is native(&gobject-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:2:gtype-get-type:t/Value.t
=begin pod
=head2 gtype-get-type

Get dynamic type for a GTyped value. In C there is this name G_TYPE_GTYPE.

  method gtype_get_type ( --> UInt )

=end pod

method gtype-get-type ( --> UInt ) {
  g_gtype_get_type
}

sub g_gtype_get_type (  --> GType )
  is native(&gobject-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
# TM:0:instance-get-private:
=begin pod
=head2 instance-get-private



  method instance-get-private ( GTypeInstance $instance, N-Object $private_type --> Pointer )

=item GTypeInstance $instance;
=item N-Object $private_type;
=end pod

method instance-get-private ( GTypeInstance $instance, $private_type is copy --> Pointer ) {
  $private_type .= _get-native-object-no-reffing unless $private_type ~~ N-Object;

  g_type_instance_get_private(
    self._get-native-object-no-reffing, $instance, $private_type
  )
}

sub g_type_instance_get_private (
  GTypeInstance $instance, N-Object $private_type --> gpointer
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:interface-add-prerequisite:
=begin pod
=head2 interface-add-prerequisite

Adds I<prerequisite-type> to the list of prerequisites of I<interface-type>. This means that any type implementing I<interface-type> must also implement I<prerequisite-type>. Prerequisites can be thought of as an alternative to interface derivation (which GType doesn't support). An interface can have at most one instantiatable prerequisite type.

  method interface-add-prerequisite ( N-Object $prerequisite_type )

=item N-Object $prerequisite_type; B<Gnome::GObject::Type> value of an interface or instantiatable type
=end pod

method interface-add-prerequisite ( $prerequisite_type is copy ) {
  $prerequisite_type .= _get-native-object-no-reffing unless $prerequisite_type ~~ N-Object;

  g_type_interface_add_prerequisite(
    self._get-native-object-no-reffing, $prerequisite_type
  );
}

sub g_type_interface_add_prerequisite (
  N-Object $interface_type, N-Object $prerequisite_type
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:interface-get-plugin:
=begin pod
=head2 interface-get-plugin

Returns the B<Gnome::GObject::TypePlugin> structure for the dynamic interface I<interface-type> which has been added to I<instance-type>, or C<undefined> if I<interface-type> has not been added to I<instance-type> or does not have a B<Gnome::GObject::TypePlugin> structure. See C<add-interface-dynamic()>.

Returns: the B<Gnome::GObject::TypePlugin> for the dynamic interface I<interface-type> of I<instance-type>

  method interface-get-plugin ( N-Object $interface_type --> N-Object )

=item N-Object $interface_type; B<Gnome::GObject::Type> of an interface type
=end pod

method interface-get-plugin ( $interface_type is copy --> N-Object ) {
  $interface_type .= _get-native-object-no-reffing unless $interface_type ~~ N-Object;

  g_type_interface_get_plugin(
    self._get-native-object-no-reffing, $interface_type
  )
}

sub g_type_interface_get_plugin (
  N-Object $instance_type, N-Object $interface_type --> N-Object
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:interface-peek:
=begin pod
=head2 interface-peek

Returns the B<Gnome::GObject::TypeInterface> structure of an interface to which the passed in class conforms.

Returns: (type GObject.TypeInterface) : the B<Gnome::GObject::TypeInterface> structure of I<iface-type> if implemented by I<instance-class>, C<undefined> otherwise

  method interface-peek ( Pointer $instance_class, N-Object $iface_type --> Pointer )

=item Pointer $instance_class; (type GObject.TypeClass): a B<Gnome::GObject::TypeClass> structure
=item N-Object $iface_type; an interface ID which this class conforms to
=end pod

method interface-peek ( Pointer $instance_class, $iface_type is copy --> Pointer ) {
  $iface_type .= _get-native-object-no-reffing unless $iface_type ~~ N-Object;

  g_type_interface_peek(
    self._get-native-object-no-reffing, $instance_class, $iface_type
  )
}

sub g_type_interface_peek (
  gpointer $instance_class, N-Object $iface_type --> gpointer
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:interface-peek-parent:
=begin pod
=head2 interface-peek-parent

Returns the corresponding B<Gnome::GObject::TypeInterface> structure of the parent type of the instance type to which I<g-iface> belongs. This is useful when deriving the implementation of an interface from the parent type and then possibly overriding some methods.

Returns:  (type GObject.TypeInterface): the corresponding B<Gnome::GObject::TypeInterface> structure of the parent type of the instance type to which I<g-iface> belongs, or C<undefined> if the parent type doesn't conform to the interface

  method interface-peek-parent ( Pointer $g_iface --> Pointer )

=item Pointer $g_iface; (type GObject.TypeInterface): a B<Gnome::GObject::TypeInterface> structure
=end pod

method interface-peek-parent ( Pointer $g_iface --> Pointer ) {

  g_type_interface_peek_parent(
    self._get-native-object-no-reffing, $g_iface
  )
}

sub g_type_interface_peek_parent (
  gpointer $g_iface --> gpointer
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:interface-prerequisites:
=begin pod
=head2 interface-prerequisites

Returns the prerequisites of an interfaces type.

Returns: (array length=n-prerequisites) : a newly-allocated zero-terminated array of B<Gnome::GObject::Type> containing the prerequisites of I<interface-type>

  method interface-prerequisites ( guInt-ptr $n_prerequisites --> N-Object )

=item guInt-ptr $n_prerequisites; location to return the number of prerequisites, or C<undefined>
=end pod

method interface-prerequisites ( guInt-ptr $n_prerequisites --> N-Object ) {

  g_type_interface_prerequisites(
    self._get-native-object-no-reffing, $n_prerequisites
  )
}

sub g_type_interface_prerequisites (
  N-Object $interface_type, gugint-ptr $n_prerequisites --> N-Object
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:interfaces:
=begin pod
=head2 interfaces

Return a newly allocated and 0-terminated array of type IDs, listing the interface types that I<type> conforms to.

Returns: (array length=n-interfaces) : Newly allocated and 0-terminated array of interface types, free with C<g-free()>

  method interfaces ( guInt-ptr $n_interfaces --> N-Object )

=item guInt-ptr $n_interfaces; location to store the length of the returned array, or C<undefined>
=end pod

method interfaces ( guInt-ptr $n_interfaces --> N-Object ) {

  g_type_interfaces(
    self._get-native-object-no-reffing, $n_interfaces
  )
}

sub g_type_interfaces (
  N-Object $type, gugint-ptr $n_interfaces --> N-Object
) is native(&gobject-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:2:is-a:
=begin pod
=head2 is-a

If I<$is-a-gtype> is a derivable type, check whether I<$gtype> is a descendant of I<$is-a-gtype>. If I<$is-a-gtype> is an interface, check whether I<$gtype> conforms to it.

Returns: C<True> if I<$gtype> is a I<$is-a-gtype>

  method is-a ( UInt $gtype, UInt $is_a_gtype --> Bool )

=item UInt $is_a_gtype; possible anchestor of I<$gtype> or interface that I<$gtype> could conform to
=end pod

method is-a ( UInt $gtype, $is_a_type --> Bool ) {
  g_type_is_a( $gtype, $is_a_type).Bool
}

sub g_type_is_a (
  GType $type, GType $is_a_type --> gboolean
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:2:name:
=begin pod
=head2 name

Get the unique name that is assigned to a type ID. Note that this function (like all other GType API) cannot cope with invalid type IDs. C<G-TYPE-INVALID> may be passed to this function, as may be any other validly registered type ID, but randomized type IDs should not be passed in and will most likely lead to a crash.

Returns: static type name or C<undefined>

  method name ( UInt $gtype --> Str )

=end pod

method name ( UInt $gtype --> Str ) {
  g_type_name($gtype)
}

sub g_type_name (
  GType $type --> gchar-ptr
) is native(&gobject-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
# TM:0:name-from-class:
=begin pod
=head2 name-from-class



  method name-from-class ( GTypeClass $g_class --> Str )

=item GTypeClass $g_class;
=end pod

method name-from-class ( GTypeClass $g_class --> Str ) {

  g_type_name_from_class(
    self._get-native-object-no-reffing, $g_class
  )
}

sub g_type_name_from_class (
  GTypeClass $g_class --> gchar-ptr
) is native(&gobject-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:2:name-from-instance:
=begin pod
=head2 name-from-instance

Get name of type from the instance.

  method name-from-instance ( N-Object $instance --> Str )

=item N-Object $instance;
=end pod

method name-from-instance ( N-Object $instance --> Str ) {
  g_type_name_from_instance($instance)
}

sub g_type_name_from_instance (
  N-Object $instance --> gchar-ptr
) is native(&gobject-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
# TM:0:next-base:
=begin pod
=head2 next-base

Given a I<leaf-type> and a I<root-type> which is contained in its anchestry, return the type that I<root-type> is the immediate parent of. In other words, this function determines the type that is derived directly from I<root-type> which is also a base class of I<leaf-type>. Given a root type and a leaf type, this function can be used to determine the types and order in which the leaf type is descended from the root type.

Returns: immediate child of I<root-type> and anchestor of I<leaf-type>

  method next-base ( N-Object $root_type --> N-Object )

=item N-Object $root_type; immediate parent of the returned type
=end pod

method next-base ( $root_type is copy --> N-Object ) {
  $root_type .= _get-native-object-no-reffing unless $root_type ~~ N-Object;

  g_type_next_base(
    self._get-native-object-no-reffing, $root_type
  )
}

sub g_type_next_base (
  N-Object $leaf_type, N-Object $root_type --> N-Object
) is native(&gobject-lib)
  { * }
}}

#-------------------------------------------------------------------------------
#TM:2:parent:
=begin pod
=head2 parent

Return the direct parent type of the passed in type. If the passed in type has no parent, i.e. is a fundamental type, 0 is returned.

Returns: the parent type

  method parent ( UInt $parent-gtype --> UInt )

=end pod

method parent ( UInt $parent-gtype --> UInt ) {
  g_type_parent($parent-gtype)
}

sub g_type_parent (
  GType $type --> GType
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:2:qname:
=begin pod
=head2 qname

Get the corresponding quark of the type IDs name.

Returns: the type names quark or 0

  method qname ( UInt $gtype --> UInt )

=end pod

method qname ( UInt $gtype --> UInt ) {
  g_type_qname($gtype)
}

sub g_type_qname (
  GType $type --> GQuark
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:2:query:
=begin pod
=head2 query

Queries the type system for information about a specific type. This function will fill in a user-provided structure to hold type-specific information. If an invalid B<Gnome::GObject::Type> is passed in, the I<$type> member of the B<N-GTypeQuery> is 0. All members filled into the B<N-GTypeQuery> structure should be considered constant and have to be left untouched.

  method query ( UInt $gtype --> N-GTypeQuery )

=end pod

method query ( UInt $gtype --> N-GTypeQuery ) {
  my N-GTypeQuery $query .= new;
  g_type_query( $gtype, $query);

  $query
}

sub g_type_query (
  GType $gtype, N-GTypeQuery $query
) is native(&gobject-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
# TM:0:register-dynamic:
=begin pod
=head2 register-dynamic

Registers I<type-name> as the name of a new dynamic type derived from I<parent-type>. The type system uses the information contained in the B<Gnome::GObject::TypePlugin> structure pointed to by I<plugin> to manage the type and its instances (if not abstract). The value of I<flags> determines the nature (e.g. abstract or not) of the type.

Returns: the new type identifier or B<Gnome::GObject::-TYPE-INVALID> if registration failed

  method register-dynamic ( Str $type_name, N-Object $plugin, GTypeFlags $flags --> N-Object )

=item Str $type_name; 0-terminated string used as the name of the new type
=item N-Object $plugin; B<Gnome::GObject::TypePlugin> structure to retrieve the B<Gnome::GObject::TypeInfo> from
=item GTypeFlags $flags; bitwise combination of B<Gnome::GObject::TypeFlags> values
=end pod

method register-dynamic ( Str $type_name, $plugin is copy, GTypeFlags $flags --> N-Object ) {
  $plugin .= _get-native-object-no-reffing unless $plugin ~~ N-Object;

  g_type_register_dynamic(
    self._get-native-object-no-reffing, $type_name, $plugin, $flags
  )
}

sub g_type_register_dynamic (
  N-Object $parent_type, gchar-ptr $type_name, N-Object $plugin, GTypeFlags $flags --> N-Object
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:register-fundamental:
=begin pod
=head2 register-fundamental

Registers I<type-id> as the predefined identifier and I<type-name> as the name of a fundamental type. If I<type-id> is already registered, or a type named I<type-name> is already registered, the behaviour is undefined. The type system uses the information contained in the B<Gnome::GObject::TypeInfo> structure pointed to by I<info> and the B<Gnome::GObject::TypeFundamentalInfo> structure pointed to by I<finfo> to manage the type and its instances. The value of I<flags> determines additional characteristics of the fundamental type.

Returns: the predefined type identifier

  method register-fundamental ( Str $type_name, GTypeInfo $info, GTypeFundamentalInfo $finfo, GTypeFlags $flags --> N-Object )

=item Str $type_name; 0-terminated string used as the name of the new type
=item GTypeInfo $info; B<Gnome::GObject::TypeInfo> structure for this type
=item GTypeFundamentalInfo $finfo; B<Gnome::GObject::TypeFundamentalInfo> structure for this type
=item GTypeFlags $flags; bitwise combination of B<Gnome::GObject::TypeFlags> values
=end pod

method register-fundamental ( Str $type_name, GTypeInfo $info, GTypeFundamentalInfo $finfo, GTypeFlags $flags --> N-Object ) {

  g_type_register_fundamental(
    self._get-native-object-no-reffing, $type_name, $info, $finfo, $flags
  )
}

sub g_type_register_fundamental (
  N-Object $type_id, gchar-ptr $type_name, GTypeInfo $info, GTypeFundamentalInfo $finfo, GTypeFlags $flags --> N-Object
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:register-static:
=begin pod
=head2 register-static

Registers I<type-name> as the name of a new static type derived from I<parent-type>. The type system uses the information contained in the B<Gnome::GObject::TypeInfo> structure pointed to by I<info> to manage the type and its instances (if not abstract). The value of I<flags> determines the nature (e.g. abstract or not) of the type.

Returns: the new type identifier

  method register-static ( Str $type_name, GTypeInfo $info, GTypeFlags $flags --> N-Object )

=item Str $type_name; 0-terminated string used as the name of the new type
=item GTypeInfo $info; B<Gnome::GObject::TypeInfo> structure for this type
=item GTypeFlags $flags; bitwise combination of B<Gnome::GObject::TypeFlags> values
=end pod

method register-static ( Str $type_name, GTypeInfo $info, GTypeFlags $flags --> N-Object ) {

  g_type_register_static(
    self._get-native-object-no-reffing, $type_name, $info, $flags
  )
}

sub g_type_register_static (
  N-Object $parent_type, gchar-ptr $type_name, GTypeInfo $info, GTypeFlags $flags --> N-Object
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:register-static-simple:
=begin pod
=head2 register-static-simple

Registers I<type-name> as the name of a new static type derived from I<parent-type>. The value of I<flags> determines the nature (e.g. abstract or not) of the type. It works by filling a B<Gnome::GObject::TypeInfo> struct and calling C<register-static()>.

Returns: the new type identifier

  method register-static-simple ( Str $type_name, UInt $class_size, GClassInitFunc $class_init, UInt $instance_size, GInstanceInitFunc $instance_init, GTypeFlags $flags --> N-Object )

=item Str $type_name; 0-terminated string used as the name of the new type
=item UInt $class_size; size of the class structure (see B<Gnome::GObject::TypeInfo>)
=item GClassInitFunc $class_init; location of the class initialization function (see B<Gnome::GObject::TypeInfo>)
=item UInt $instance_size; size of the instance structure (see B<Gnome::GObject::TypeInfo>)
=item GInstanceInitFunc $instance_init; location of the instance initialization function (see B<Gnome::GObject::TypeInfo>)
=item GTypeFlags $flags; bitwise combination of B<Gnome::GObject::TypeFlags> values
=end pod

method register-static-simple ( Str $type_name, UInt $class_size, GClassInitFunc $class_init, UInt $instance_size, GInstanceInitFunc $instance_init, GTypeFlags $flags --> N-Object ) {

  g_type_register_static_simple(
    self._get-native-object-no-reffing, $type_name, $class_size, $class_init, $instance_size, $instance_init, $flags
  )
}

sub g_type_register_static_simple (
  N-Object $parent_type, gchar-ptr $type_name, guint $class_size, GClassInitFunc $class_init, guint $instance_size, GInstanceInitFunc $instance_init, GTypeFlags $flags --> N-Object
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:remove-class-cache-func:
=begin pod
=head2 remove-class-cache-func

Removes a previously installed B<Gnome::GObject::TypeClassCacheFunc>. The cache maintained by I<cache-func> has to be empty when calling C<remove-class-cache-func()> to avoid leaks.

  method remove-class-cache-func ( Pointer $cache_data, GTypeClassCacheFunc $cache_func )

=item Pointer $cache_data; data that was given when adding I<cache-func>
=item GTypeClassCacheFunc $cache_func; a B<Gnome::GObject::TypeClassCacheFunc>
=end pod

method remove-class-cache-func ( Pointer $cache_data, GTypeClassCacheFunc $cache_func ) {

  g_type_remove_class_cache_func(
    self._get-native-object-no-reffing, $cache_data, $cache_func
  );
}

sub g_type_remove_class_cache_func (
  gpointer $cache_data, GTypeClassCacheFunc $cache_func
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:remove-interface-check:
=begin pod
=head2 remove-interface-check

Removes an interface check function added with C<add-interface-check()>.

  method remove-interface-check ( Pointer $check_data, GTypeInterfaceCheckFunc $check_func )

=item Pointer $check_data; callback data passed to C<add-interface-check()>
=item GTypeInterfaceCheckFunc $check_func; callback function passed to C<add-interface-check()>
=end pod

method remove-interface-check ( Pointer $check_data, GTypeInterfaceCheckFunc $check_func ) {

  g_type_remove_interface_check(
    self._get-native-object-no-reffing, $check_data, $check_func
  );
}

sub g_type_remove_interface_check (
  gpointer $check_data, GTypeInterfaceCheckFunc $check_func
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:set-qdata:
=begin pod
=head2 set-qdata

Attaches arbitrary data to a type.

  method set-qdata ( UInt $quark, Pointer $data )

=item UInt $quark; a B<Gnome::GObject::Quark> id to identify the data
=item Pointer $data; the data
=end pod

method set-qdata ( UInt $quark, Pointer $data ) {

  g_type_set_qdata(
    self._get-native-object-no-reffing, $quark, $data
  );
}

sub g_type_set_qdata (
  N-Object $type, GQuark $quark, gpointer $data
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:value-table-peek:
=begin pod
=head2 value-table-peek

Returns the location of the B<Gnome::GObject::TypeValueTable> associated with I<type>.

Note that this function should only be used from source code that implements or has internal knowledge of the implementation of I<type>.

Returns: location of the B<Gnome::GObject::TypeValueTable> associated with I<type> or C<undefined> if there is no B<Gnome::GObject::TypeValueTable> associated with I<type>

  method value-table-peek ( --> GTypeValueTable )

=end pod

method value-table-peek ( --> GTypeValueTable ) {

  g_type_value_table_peek(
    self._get-native-object-no-reffing,
  )
}

sub g_type_value_table_peek (
  N-Object $type --> GTypeValueTable
) is native(&gobject-lib)
  { * }
}}












































=finish
#-------------------------------------------------------------------------------
#TM:2:g_type_name:xt/Type.t
=begin pod
=head2 [g_] type_name

Get the unique name that is assigned to a type ID. Note that this function (like all other GType API) cannot cope with invalid type IDs. C<G_TYPE_INVALID> may be passed to this function, as may be any other validly registered type ID, but randomized type IDs should not be passed in and will most likely lead to a crash.

Returns: static type name or undefined

  method g_type_name ( UInt $gtype --> Str )

=end pod

sub g_type_name ( GType $type --> Str )
  is native(&gobject-lib)
  { * }

#`{{
}}
#-------------------------------------------------------------------------------
#TM:2:g_type_qname:xt/Type.t
=begin pod
=head2 [g_] type_qname

Get the corresponding quark of the type IDs name.

Returns: the type names quark or 0

  method g_type_qname ( UInt $gtype --> UInt  )

=end pod

sub g_type_qname ( GType $type --> GQuark )
  is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:2:g_type_from_name:xt/Type.t
=begin pod
=head2 [[g_] type_] from_name

Lookup the type ID from a given type name, returning 0 if no type has been registered under this name (this is the preferred method to find out by name whether a specific type has been registered yet).

Returns: corresponding type ID or 0

  method g_type_from_name ( Str $name --> UInt )

=item Str $name; type name to lookup

=end pod

sub g_type_from_name ( Str $name --> GType )
  is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:2:g_type_parent:xt/Type.t
=begin pod
=head2 [g_] type_parent

Return the direct parent type of the passed in type. If the passed in type has no parent, i.e. is a fundamental type, 0 is returned.

Returns: the parent type

  method g_type_parent ( UInt $parent-type --> UInt )

=end pod

sub g_type_parent ( GType $type --> GType )
  is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:2:g_type_depth:xt/Type.t
=begin pod
=head2 [g_] type_depth

Returns the length of the ancestry of the passed in type. This includes the type itself, so that e.g. a fundamental type has depth 1.

Returns: the depth of I<$type>

  method g_type_depth ( UInt $type --> UInt  )


=end pod

sub g_type_depth ( GType $type --> guint )
  is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:2:g_type_is_a:xt/Type.t
=begin pod
=head2 [[g_] type_] is_a

If I<$is_a_type> is a derivable type, check whether I<$type> is a descendant of I<$is_a_type>. If I<$is_a_type> is an interface, check whether I<$type> conforms to it.

Returns: C<1> if I<$type> is a I<$is_a_type>.

  method g_type_is_a ( UInt $type, UInt $is_a_type --> Int )

=item UInt $is_a_type; possible anchestor of I<$type> or interface that I<$type> could conform to.

=end pod

sub g_type_is_a ( GType $type, GType $is_a_type --> gboolean )
  is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:2:g_type_query:xt/Type.t
=begin pod
=head2 [g_] type_query

Queries the type system for information about a specific type. This function will fill in a user-provided structure to hold type-specific information. If an invalid I<GType> is passed in, the I<$type> member of the I<N-GTypeQuery> is 0. All members filled into the I<N-GTypeQuery> structure should be considered constant and have to be left untouched.

  method g_type_query ( int32 $type --> N-GTypeQuery )

=item N-GTypeQuery $query; a structure that is filled in with constant values upon success

=end pod

sub g_type_query ( GType $type --> N-GTypeQuery ) {
  my N-GTypeQuery $query .= new;
  _g_type_query( $type, $query);

  $query
}

sub _g_type_query ( GType $type, N-GTypeQuery $query is rw )
  is native(&gobject-lib)
  is symbol('g_type_query')
  { * }

#-------------------------------------------------------------------------------
#TM:2:g_type_check_instance_cast:xt/Type.t
=begin pod
=head2 [[g_] type_] check_instance_cast

Checks that instance is an instance of the type identified by g_type and issues a warning if this is not the case. Returns instance casted to a pointer to c_type.

No warning will be issued if instance is NULL, and NULL will be returned.

This macro should only be used in type implementations.

  method g_type_check_instance_cast (
    N-Object $instance, UInt $iface_type
    --> N-Object
  )

=item N-Object $instance;
=item UInt $iface_type;

=end pod

sub g_type_check_instance_cast ( N-Object $instance, GType $iface_type --> N-Object )
  is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:2:g_type_check_instance_is_a:xt/Type.t
=begin pod
=head2 [[g_] type_] check_instance_is_a

  method g_type_check_instance_is_a (
    N-Object $instance, UInt $iface_type --> Int
  )

=item N-Object $instance; the native object to check.
=item UInt $iface_type; the gtype the instance is inheriting from.

=end pod

sub g_type_check_instance_is_a (
  N-Object $instance, GType $iface_type --> int32
) is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
#TM:6:g_type_name_from_instance:Gnome::Gtk3::Builder
=begin pod
=head2 [[g_] type_] name_from_instance

Get name of type from the instance.

  method g_type_name_from_instance ( N-Object $instance --> Str  )

=item int32 $instance;

Returns the name of the instance.

=end pod

sub g_type_name_from_instance ( N-Object $instance --> Str )
  is native(&gobject-lib)
  { * }


#-------------------------------------------------------------------------------
#TM:2:g_gtype_get_type:t/Value.t
=begin pod
=head2 [g_] gtype_get_type

Get dynamic type for a GTyped value. In C there is this name G_TYPE_GTYPE.

  method g_gtype_get_type ( --> UInt  )

=end pod

sub g_gtype_get_type (  --> GType )
  is native(&gobject-lib)
  { * }





=finish

#-------------------------------------------------------------------------------
#--[ Unused code of subs ]------------------------------------------------------
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# TM:0:g_type_name_from_class:
=begin pod
=head2 [[g_] type_] name_from_class



  method g_type_name_from_class ( int32 $g_class --> Str  )

=item int32 $g_class;

=end pod

sub g_type_name_from_class ( int32 $g_class --> Str )
  is native(&gobject-lib)
  { * }

#`{{
#-------------------------------------------------------------------------------
# TM:0:g_type_check_instance_is_fundamentally_a:
=begin pod
=head2 [[g_] type_] check_instance_is_fundamentally_a



  method g_type_check_instance_is_fundamentally_a ( int32 $instance, int32 $fundamental_type --> Int  )

=item int32 $instance;
=item int32 $fundamental_type;

=end pod

sub g_type_check_instance_is_fundamentally_a ( int32 $instance, int32 $fundamental_type --> int32 )
  is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:g_type_check_class_cast:
=begin pod
=head2 [[g_] type_] check_class_cast



  method g_type_check_class_cast ( int32 $g_class, int32 $is_a_type --> int32  )

=item int32 $g_class;
=item int32 $is_a_type;

=end pod

sub g_type_check_class_cast ( int32 $g_class, int32 $is_a_type --> int32 )
  is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:g_type_check_class_is_a:
=begin pod
=head2 [[g_] type_] check_class_is_a



  method g_type_check_class_is_a ( int32 $g_class, int32 $is_a_type --> Int  )

=item int32 $g_class;
=item int32 $is_a_type;

=end pod

sub g_type_check_class_is_a ( int32 $g_class, int32 $is_a_type --> int32 )
  is native(&gobject-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:g_type_check_value:
=begin pod
=head2 [[g_] type_] check_value

Checks if value has been initialized to hold values of type g_type.

  method g_type_check_value ( N-Object $value --> Int  )

=item N-Object $value;

=end pod

sub g_type_check_value ( N-Object $value --> int32 )
  is native(&gobject-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:g_type_check_value_holds:
=begin pod
=head2 [[g_] type_] check_value_holds



  method g_type_check_value_holds ( N-Object $value, int32 $type --> Int  )

=item N-Object $value;
=item int32 $type;

=end pod

sub g_type_check_value_holds ( N-Object $value, int32 $type --> int32 )
  is native(&gobject-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:g_type_get_instance_count:
=begin pod
=head2 [[g_] type_] get_instance_count

Returns the number of instances allocated of the particular type;
this is only available if GLib is built with debugging support and
the instance_count debug flag is set (by setting the GOBJECT_DEBUG
variable to include instance-count).

Returns: the number of instances allocated of the given type;
if instance counts are not available, returns 0.

  method g_type_get_instance_count ( --> int32  )


=end pod

sub g_type_get_instance_count ( int32 $type --> int32 )
  is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:g_type_register_static:
=begin pod
=head2 [[g_] type_] register_static

Registers I<type_name> as the name of a new static type derived from
I<parent_type>. The type system uses the information contained in the
I<GTypeInfo> structure pointed to by I<info> to manage the type and its
instances (if not abstract). The value of I<flags> determines the nature
(e.g. abstract or not) of the type.

Returns: the new type identifier

  method g_type_register_static ( Str $type_name, int32 $info, int32 $flags --> int32  )

=item Str $type_name; 0-terminated string used as the name of the new type
=item int32 $info; I<GTypeInfo> structure for this type
=item int32 $flags; bitwise combination of I<GTypeFlags> values

=end pod

sub g_type_register_static ( int32 $parent_type, Str $type_name, int32 $info, int32 $flags --> int32 )
  is native(&gobject-lib)
  { * }
}}
#`{{
#-------------------------------------------------------------------------------
# TM:0:g_type_register_static_simple:
=begin pod
=head2 [[g_] type_] register_static_simple

Registers I<type_name> as the name of a new static type derived from
I<parent_type>.  The value of I<flags> determines the nature (e.g.
abstract or not) of the type. It works by filling a I<GTypeInfo>
struct and calling C<g_type_register_static()>.

Returns: the new type identifier

  method g_type_register_static_simple ( Str $type_name, UInt $class_size, GClassInitFunc $class_init, UInt $instance_size, GInstanceInitFunc $instance_init, int32 $flags --> int32  )

=item Str $type_name; 0-terminated string used as the name of the new type
=item UInt $class_size; size of the class structure (see I<GTypeInfo>)
=item GClassInitFunc $class_init; location of the class initialization function (see I<GTypeInfo>)
=item UInt $instance_size; size of the instance structure (see I<GTypeInfo>)
=item GInstanceInitFunc $instance_init; location of the instance initialization function (see I<GTypeInfo>)
=item int32 $flags; bitwise combination of I<GTypeFlags> values

=end pod

sub g_type_register_static_simple ( int32 $parent_type, Str $type_name, uint32 $class_size, GClassInitFunc $class_init, uint32 $instance_size, GInstanceInitFunc $instance_init, int32 $flags --> int32 )
  is native(&gobject-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:g_type_register_dynamic:
=begin pod
=head2 [[g_] type_] register_dynamic

Registers I<type_name> as the name of a new dynamic type derived from
I<parent_type>.  The type system uses the information contained in the
I<GTypePlugin> structure pointed to by I<plugin> to manage the type and its
instances (if not abstract).  The value of I<flags> determines the nature
(e.g. abstract or not) of the type.

Returns: the new type identifier or I<G_TYPE_INVALID> if registration failed

  method g_type_register_dynamic ( Str $type_name, int32 $plugin, int32 $flags --> int32  )

=item Str $type_name; 0-terminated string used as the name of the new type
=item int32 $plugin; I<GTypePlugin> structure to retrieve the I<GTypeInfo> from
=item int32 $flags; bitwise combination of I<GTypeFlags> values

=end pod

sub g_type_register_dynamic ( int32 $parent_type, Str $type_name, int32 $plugin, int32 $flags --> int32 )
  is native(&gobject-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:g_type_register_fundamental:
=begin pod
=head2 [[g_] type_] register_fundamental

Registers I<type_id> as the predefined identifier and I<type_name> as the
name of a fundamental type. If I<type_id> is already registered, or a
type named I<type_name> is already registered, the behaviour is undefined.
The type system uses the information contained in the I<GTypeInfo> structure
pointed to by I<info> and the I<GTypeFundamentalInfo> structure pointed to by
I<finfo> to manage the type and its instances. The value of I<flags> determines
additional characteristics of the fundamental type.

Returns: the predefined type identifier

  method g_type_register_fundamental ( Str $type_name, int32 $info, int32 $finfo, int32 $flags --> int32  )

=item Str $type_name; 0-terminated string used as the name of the new type
=item int32 $info; I<GTypeInfo> structure for this type
=item int32 $finfo; I<GTypeFundamentalInfo> structure for this type
=item int32 $flags; bitwise combination of I<GTypeFlags> values

=end pod

sub g_type_register_fundamental ( int32 $type_id, Str $type_name, int32 $info, int32 $finfo, int32 $flags --> int32 )
  is native(&gobject-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:g_type_add_interface_static:
=begin pod
=head2 [[g_] type_] add_interface_static

Adds the static I<interface_type> to I<instantiable_type>.
The information contained in the I<N-GInterfaceInfo> structure
pointed to by I<info> is used to manage the relationship.

  method g_type_add_interface_static ( int32 $interface_type, N-GInterfaceInfo $info )

=item int32 $interface_type; I<GType> value of an interface type
=item N-GInterfaceInfo $info; I<N-GInterfaceInfo> structure for this (I<instance_type>, I<interface_type>) combination

=end pod

sub g_type_add_interface_static ( int32 $instance_type, int32 $interface_type, N-GInterfaceInfo $info )
  is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:g_type_add_interface_dynamic:
=begin pod
=head2 [[g_] type_] add_interface_dynamic

Adds the dynamic I<interface_type> to I<instantiable_type>. The information
contained in the I<GTypePlugin> structure pointed to by I<plugin>
is used to manage the relationship.

  method g_type_add_interface_dynamic ( int32 $interface_type, int32 $plugin )

=item int32 $interface_type; I<GType> value of an interface type
=item int32 $plugin; I<GTypePlugin> structure to retrieve the I<N-GInterfaceInfo> from

=end pod

sub g_type_add_interface_dynamic ( int32 $instance_type, int32 $interface_type, int32 $plugin )
  is native(&gobject-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:g_type_interface_add_prerequisite:
=begin pod
=head2 [[g_] type_] interface_add_prerequisite

Adds I<prerequisite_type> to the list of prerequisites of I<interface_type>.
This means that any type implementing I<interface_type> must also implement
I<prerequisite_type>. Prerequisites can be thought of as an alternative to
interface derivation (which GType doesn't support). An interface can have
at most one instantiatable prerequisite type.

  method g_type_interface_add_prerequisite ( int32 $prerequisite_type )

=item int32 $prerequisite_type; I<GType> value of an interface or instantiatable type

=end pod

sub g_type_interface_add_prerequisite ( int32 $interface_type, int32 $prerequisite_type )
  is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:g_type_interface_prerequisites:
=begin pod
=head2 [[g_] type_] interface_prerequisites

Returns the prerequisites of an interfaces type.

Returns: (array length=n_prerequisites) (transfer full): a
newly-allocated zero-terminated array of I<GType> containing
the prerequisites of I<interface_type>

  method g_type_interface_prerequisites ( UInt $n_prerequisites --> int32  )

=item UInt $n_prerequisites; (out) (optional): location to return the number of prerequisites, or C<Any>

=end pod

sub g_type_interface_prerequisites ( int32 $interface_type, uint32 $n_prerequisites --> int32 )
  is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:g_type_add_instance_private:
=begin pod
=head2 [[g_] type_] add_instance_private



  method g_type_add_instance_private ( UInt $private_size --> Int  )

=item UInt $private_size;

=end pod

sub g_type_add_instance_private ( int32 $class_type, uint64 $private_size --> int32 )
  is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:g_type_instance_get_private:
=begin pod
=head2 [[g_] type_] instance_get_private



  method g_type_instance_get_private ( int32 $instance, int32 $private_type --> Pointer  )

=item int32 $instance;
=item int32 $private_type;

=end pod

sub g_type_instance_get_private ( int32 $instance, int32 $private_type --> Pointer )
  is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:g_type_class_adjust_private_offset:
=begin pod
=head2 [[g_] type_] class_adjust_private_offset



  method g_type_class_adjust_private_offset ( Pointer $g_class, Int $private_size_or_offset )

=item Pointer $g_class;
=item Int $private_size_or_offset;

=end pod

sub g_type_class_adjust_private_offset ( Pointer $g_class, int32 $private_size_or_offset )
  is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:g_type_add_class_private:
=begin pod
=head2 [[g_] type_] add_class_private

Registers a private class structure for a classed type;
when the class is allocated, the private structures for
the class and all of its parent types are allocated
sequentially in the same memory block as the public
structures, and are zero-filled.

This function should be called in the
type's C<get_type()> function after the type is registered.
The private structure can be retrieved using the
C<G_TYPE_CLASS_GET_PRIVATE()> macro.

  method g_type_add_class_private ( UInt $private_size )

=item UInt $private_size; size of private structure

=end pod

sub g_type_add_class_private ( int32 $class_type, uint64 $private_size )
  is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:g_type_class_get_private:
=begin pod
=head2 [[g_] type_] class_get_private



  method g_type_class_get_private ( int32 $klass, int32 $private_type --> Pointer  )

=item int32 $klass;
=item int32 $private_type;

=end pod

sub g_type_class_get_private ( int32 $klass, int32 $private_type --> Pointer )
  is native(&gobject-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:g_type_class_get_instance_private_offset:
=begin pod
=head2 [[g_] type_] class_get_instance_private_offset

Gets the offset of the private data for instances of I<g_class>.

This is how many bytes you should add to the instance pointer of a
class in order to get the private data for the type represented by
I<g_class>.

You can only call this function after you have registered a private
data area for I<g_class> using C<g_type_class_add_private()>.

Returns: the offset, in bytes

  method g_type_class_get_instance_private_offset ( Pointer $g_class --> Int  )

=item Pointer $g_class; (type GObject.TypeClass): a I<N-GTypeClass>

=end pod

sub g_type_class_get_instance_private_offset ( Pointer $g_class --> int32 )
  is native(&gobject-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:g_type_ensure:
=begin pod
=head2 [g_] type_ensure

Ensures that the indicated I<type> has been registered with the
type system, and its C<_class_init()> method has been run.

In theory, simply calling the type's C<_get_type()> method (or using
the corresponding macro) is supposed take care of this. However,
C<_get_type()> methods are often marked C<G_GNUC_CONST> for performance
reasons, even though this is technically incorrect (since
C<G_GNUC_CONST> requires that the function not have side effects,
which C<_get_type()> methods do on the first call). As a result, if
you write a bare call to a C<_get_type()> macro, it may get optimized
out by the compiler. Using C<g_type_ensure()> guarantees that the
type's C<_get_type()> method is called.

  method g_type_ensure ( )


=end pod

sub g_type_ensure ( int32 $type )
  is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:g_type_get_type_registration_serial:
=begin pod
=head2 [[g_] type_] get_type_registration_serial

Returns an opaque serial number that represents the state of the set
of registered types. Any time a type is registered this serial changes,
which means you can cache information based on type lookups (such as
C<g_type_from_name()>) and know if the cache is still valid at a later
time by comparing the current serial with the one at the type lookup.

Returns: An unsigned int, representing the state of type registrations

  method g_type_get_type_registration_serial ( --> UInt  )


=end pod

sub g_type_get_type_registration_serial (  --> uint32 )
  is native(&gobject-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:g_type_get_plugin:
=begin pod
=head2 [[g_] type_] get_plugin

Returns the I<GTypePlugin> structure for I<type>.

Returns: (transfer none): the corresponding plugin
if I<type> is a dynamic type, C<Any> otherwise

  method g_type_get_plugin ( --> int32  )


=end pod

sub g_type_get_plugin ( int32 $type --> int32 )
  is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:g_type_interface_get_plugin:
=begin pod
=head2 [[g_] type_] interface_get_plugin

Returns the I<GTypePlugin> structure for the dynamic interface
I<interface_type> which has been added to I<instance_type>, or C<Any>
if I<interface_type> has not been added to I<instance_type> or does
not have a I<GTypePlugin> structure. See C<g_type_add_interface_dynamic()>.

Returns: (transfer none): the I<GTypePlugin> for the dynamic
interface I<interface_type> of I<instance_type>

  method g_type_interface_get_plugin ( int32 $interface_type --> int32  )

=item int32 $interface_type; I<GType> of an interface type

=end pod

sub g_type_interface_get_plugin ( int32 $instance_type, int32 $interface_type --> int32 )
  is native(&gobject-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:g_type_fundamental_next:
=begin pod
=head2 [[g_] type_] fundamental_next

Returns the next free fundamental type id which can be used to
register a new fundamental type with C<g_type_register_fundamental()>.
The returned type ID represents the highest currently registered
fundamental type identifier.

Returns: the next available fundamental type ID to be registered,
or 0 if the type system ran out of fundamental type IDs

  method g_type_fundamental_next ( --> int32  )


=end pod

sub g_type_fundamental_next (  --> int32 )
  is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:g_type_fundamental:
=begin pod
=head2 [g_] type_fundamental

Internal function, used to extract the fundamental type ID portion.
Use C<G_TYPE_FUNDAMENTAL()> instead.

Returns: fundamental type ID

  method g_type_fundamental ( --> int32  )


=end pod

sub g_type_fundamental ( int32 $type_id --> int32 )
  is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:g_type_create_instance:
=begin pod
=head2 [[g_] type_] create_instance

Creates and initializes an instance of I<type> if I<type> is valid and
can be instantiated. The type system only performs basic allocation
and structure setups for instances: actual instance creation should
happen through functions supplied by the type's fundamental type
implementation.  So use of C<g_type_create_instance()> is reserved for
implementators of fundamental types only. E.g. instances of the
I<GObject> hierarchy should be created via C<g_object_new()> and never
directly through C<g_type_create_instance()> which doesn't handle things
like singleton objects or object construction.

The extended members of the returned instance are guaranteed to be filled
with zeros.

Note: Do not use this function, unless you're implementing a
fundamental type. Also language bindings should not use this
function, but C<g_object_new()> instead.

Returns: an allocated and initialized instance, subject to further
treatment by the fundamental type implementation

  method g_type_create_instance ( --> int32  )


=end pod

sub g_type_create_instance ( int32 $type --> int32 )
  is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:g_type_free_instance:
=begin pod
=head2 [[g_] type_] free_instance

Frees an instance of a type, returning it to the instance pool for
the type, if there is one.

Like C<g_type_create_instance()>, this function is reserved for
implementors of fundamental types.

  method g_type_free_instance ( int32 $instance )

=item int32 $instance; an instance of a type

=end pod

sub g_type_free_instance ( int32 $instance )
  is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:g_type_add_class_cache_func:
=begin pod
=head2 [[g_] type_] add_class_cache_func

Adds a I<GTypeClassCacheFunc> to be called before the reference count of a
class goes from one to zero. This can be used to prevent premature class
destruction. All installed I<GTypeClassCacheFunc> functions will be chained
until one of them returns C<1>. The functions have to check the class id
passed in to figure whether they actually want to cache the class of this
type, since all classes are routed through the same I<GTypeClassCacheFunc>
chain.

  method g_type_add_class_cache_func ( Pointer $cache_data, int32 $cache_func )

=item Pointer $cache_data; data to be passed to I<cache_func>
=item int32 $cache_func; a I<GTypeClassCacheFunc>

=end pod

sub g_type_add_class_cache_func ( Pointer $cache_data, int32 $cache_func )
  is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:g_type_remove_class_cache_func:
=begin pod
=head2 [[g_] type_] remove_class_cache_func

Removes a previously installed I<GTypeClassCacheFunc>. The cache
maintained by I<cache_func> has to be empty when calling
C<g_type_remove_class_cache_func()> to avoid leaks.

  method g_type_remove_class_cache_func ( Pointer $cache_data, int32 $cache_func )

=item Pointer $cache_data; data that was given when adding I<cache_func>
=item int32 $cache_func; a I<GTypeClassCacheFunc>

=end pod

sub g_type_remove_class_cache_func ( Pointer $cache_data, int32 $cache_func )
  is native(&gobject-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:g_type_class_unref_uncached:
=begin pod
=head2 [[g_] type_] class_unref_uncached

A variant of C<g_type_class_unref()> for use in I<GTypeClassCacheFunc>
implementations. It unreferences a class without consulting the chain
of I<GTypeClassCacheFuncs>, avoiding the recursion which would occur
otherwise.

  method g_type_class_unref_uncached ( Pointer $g_class )

=item Pointer $g_class; (type GObject.TypeClass): a I<N-GTypeClass> structure to unref

=end pod

sub g_type_class_unref_uncached ( Pointer $g_class )
  is native(&gobject-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:g_type_add_interface_check:
=begin pod
=head2 [[g_] type_] add_interface_check

Adds a function to be called after an interface vtable is
initialized for any class (i.e. after the I<interface_init>
member of I<GInterfaceInfo> has been called).

This function is useful when you want to check an invariant
that depends on the interfaces of a class. For instance, the
implementation of I<GObject> uses this facility to check that an
object implements all of the properties that are defined on its
interfaces.

  method g_type_add_interface_check ( Pointer $check_data, int32 $check_func )

=item Pointer $check_data; data to pass to I<check_func>
=item int32 $check_func; function to be called after each interface is initialized

=end pod

sub g_type_add_interface_check ( Pointer $check_data, int32 $check_func )
  is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:g_type_remove_interface_check:
=begin pod
=head2 [[g_] type_] remove_interface_check

Removes an interface check function added with
C<g_type_add_interface_check()>.

  method g_type_remove_interface_check ( Pointer $check_data, int32 $check_func )

=item Pointer $check_data; callback data passed to C<g_type_add_interface_check()>
=item int32 $check_func; callback function passed to C<g_type_add_interface_check()>

=end pod

sub g_type_remove_interface_check ( Pointer $check_data, int32 $check_func )
  is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:g_type_value_table_peek:
=begin pod
=head2 [[g_] type_] value_table_peek

Returns the location of the I<GTypeValueTable> associated with I<type>.

Note that this function should only be used from source code
that implements or has internal knowledge of the implementation of
I<type>.

Returns: location of the I<GTypeValueTable> associated with I<type> or
C<Any> if there is no I<GTypeValueTable> associated with I<type>

  method g_type_value_table_peek ( --> int32  )


=end pod

sub g_type_value_table_peek ( int32 $type --> int32 )
  is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:g_type_check_instance:
=begin pod
=head2 [[g_] type_] check_instance

Private helper function to aid implementation of the
C<G_TYPE_CHECK_INSTANCE()> macro.

Returns: C<1> if I<instance> is valid, C<0> otherwise

  method g_type_check_instance ( N-GTypeInstance $instance --> Int  )

=item N-GTypeInstance $instance; a valid I<GN-TypeInstance> structure

=end pod

sub g_type_check_instance ( N-GTypeInstance $instance --> int32 )
  is native(&gobject-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:g_type_class_ref:
=begin pod
=head2 [[g_] type_] class_ref

Increments the reference count of the class structure belonging to
I<type>. This function will demand-create the class if it doesn't
exist already.

Returns: (type GObject.TypeClass) (transfer none): the I<N-GTypeClass>
structure for the given type ID

  method g_type_class_ref ( --> Pointer  )


=end pod

sub g_type_class_ref ( int32 $type --> Pointer )
  is native(&gobject-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:g_type_class_peek:
=begin pod
=head2 [[g_] type_] class_peek

This function is essentially the same as C<g_type_class_ref()>,
except that the classes reference count isn't incremented.
As a consequence, this function may return C<Any> if the class
of the type passed in does not currently exist (hasn't been
referenced before).

Returns: (type GObject.TypeClass) (transfer none): the I<N-GTypeClass>
structure for the given type ID or C<Any> if the class does not
currently exist

  method g_type_class_peek ( --> Pointer  )


=end pod

sub g_type_class_peek ( int32 $type --> Pointer )
  is native(&gobject-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:g_type_class_peek_static:
=begin pod
=head2 [[g_] type_] class_peek_static

A more efficient version of C<g_type_class_peek()> which works only for
static types.

Returns: (type GObject.TypeClass) (transfer none): the I<N-GTypeClass>
structure for the given type ID or C<Any> if the class does not
currently exist or is dynamically loaded

  method g_type_class_peek_static ( --> Pointer  )


=end pod

sub g_type_class_peek_static ( int32 $type --> Pointer )
  is native(&gobject-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:g_type_class_unref:
=begin pod
=head2 [[g_] type_] class_unref

Decrements the reference count of the class structure being passed in.
Once the last reference count of a class has been released, classes
may be finalized by the type system, so further dereferencing of a
class pointer after C<g_type_class_unref()> are invalid.

  method g_type_class_unref ( Pointer $g_class )

=item Pointer $g_class; (type GObject.TypeClass): a I<N-GTypeClass> structure to unref

=end pod

sub g_type_class_unref ( Pointer $g_class )
  is native(&gobject-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:g_type_class_peek_parent:
=begin pod
=head2 [[g_] type_] class_peek_parent

This is a convenience function often needed in class initializers.
It returns the class structure of the immediate parent type of the
class passed in.  Since derived classes hold a reference count on
their parent classes as long as they are instantiated, the returned
class will always exist.

This function is essentially equivalent to:
g_type_class_peek (g_type_parent (G_TYPE_FROM_CLASS (g_class)))

Returns: (type GObject.TypeClass) (transfer none): the parent class
of I<g_class>

  method g_type_class_peek_parent ( Pointer $g_class --> Pointer  )

=item Pointer $g_class; (type GObject.TypeClass): the I<N-GTypeClass> structure to retrieve the parent class for

=end pod

sub g_type_class_peek_parent ( Pointer $g_class --> Pointer )
  is native(&gobject-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:g_type_interface_peek:
=begin pod
=head2 [[g_] type_] interface_peek

Returns the I<GTypeInterface> structure of an interface to which the
passed in class conforms.

Returns: (type GObject.TypeInterface) (transfer none): the I<GTypeInterface>
structure of I<iface_type> if implemented by I<instance_class>, C<Any>
otherwise

  method g_type_interface_peek ( Pointer $instance_class, int32 $iface_type --> Pointer  )

=item Pointer $instance_class; (type GObject.TypeClass): a I<N-GTypeClass> structure
=item int32 $iface_type; an interface ID which this class conforms to

=end pod

sub g_type_interface_peek ( Pointer $instance_class, int32 $iface_type --> Pointer )
  is native(&gobject-lib)
  { * }
}}

#`{{
#-------------------------------------------------------------------------------
# TM:0:g_type_interface_peek_parent:
=begin pod
=head2 [[g_] type_] interface_peek_parent

Returns the corresponding I<GTypeInterface> structure of the parent type
of the instance type to which I<g_iface> belongs. This is useful when
deriving the implementation of an interface from the parent type and
then possibly overriding some methods.

Returns: (transfer none) (type GObject.TypeInterface): the
corresponding I<GTypeInterface> structure of the parent type of the
instance type to which I<g_iface> belongs, or C<Any> if the parent
type doesn't conform to the interface

  method g_type_interface_peek_parent ( Pointer $g_iface --> Pointer  )

=item Pointer $g_iface; (type GObject.TypeInterface): a I<GTypeInterface> structure

=end pod

sub g_type_interface_peek_parent ( Pointer $g_iface --> Pointer )
  is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:g_type_default_interface_ref:
=begin pod
=head2 [[g_] type_] default_interface_ref

Increments the reference count for the interface type I<g_type>,
and returns the default interface vtable for the type.

If the type is not currently in use, then the default vtable
for the type will be created and initalized by calling
the base interface init and default vtable init functions for
the type (the I<base_init> and I<class_init> members of I<GTypeInfo>).
Calling C<g_type_default_interface_ref()> is useful when you
want to make sure that signals and properties for an interface
have been installed.

Returns: (type GObject.TypeInterface) (transfer none): the default
vtable for the interface; call C<g_type_default_interface_unref()>
when you are done using the interface.

  method g_type_default_interface_ref ( --> Pointer  )


=end pod

sub g_type_default_interface_ref ( int32 $g_type --> Pointer )
  is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:g_type_default_interface_peek:
=begin pod
=head2 [[g_] type_] default_interface_peek

If the interface type I<g_type> is currently in use, returns its
default interface vtable.

Returns: (type GObject.TypeInterface) (transfer none): the default
vtable for the interface, or C<Any> if the type is not currently
in use

  method g_type_default_interface_peek ( --> Pointer  )


=end pod

sub g_type_default_interface_peek ( int32 $g_type --> Pointer )
  is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:g_type_default_interface_unref:
=begin pod
=head2 [[g_] type_] default_interface_unref

Decrements the reference count for the type corresponding to the
interface default vtable I<g_iface>. If the type is dynamic, then
when no one is using the interface and all references have
been released, the finalize function for the interface's default
vtable (the I<class_finalize> member of I<GTypeInfo>) will be called.

  method g_type_default_interface_unref ( Pointer $g_iface )

=item Pointer $g_iface; (type GObject.TypeInterface): the default vtable structure for a interface, as returned by C<g_type_default_interface_ref()>

=end pod

sub g_type_default_interface_unref ( Pointer $g_iface )
  is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:g_type_children:
=begin pod
=head2 [g_] type_children

Return a newly allocated and 0-terminated array of type IDs, listing
the child types of I<type>.

Returns: (array length=n_children) (transfer full): Newly allocated
and 0-terminated array of child types, free with C<g_free()>

  method g_type_children ( UInt $n_children --> int32  )

=item UInt $n_children; (out) (optional): location to store the length of the returned array, or C<Any>

=end pod

sub g_type_children ( int32 $type, uint32 $n_children --> int32 )
  is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:g_type_interfaces:
=begin pod
=head2 [g_] type_interfaces

Return a newly allocated and 0-terminated array of type IDs, listing
the interface types that I<type> conforms to.

Returns: (array length=n_interfaces) (transfer full): Newly allocated
and 0-terminated array of interface types, free with C<g_free()>

  method g_type_interfaces ( UInt $n_interfaces --> int32  )

=item UInt $n_interfaces; (out) (optional): location to store the length of the returned array, or C<Any>

=end pod

sub g_type_interfaces ( int32 $type, uint32 $n_interfaces --> int32 )
  is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:g_type_set_qdata:
=begin pod
=head2 [[g_] type_] set_qdata

Attaches arbitrary data to a type.

  method g_type_set_qdata ( int32 $quark, Pointer $data )

=item int32 $quark; a I<GQuark> id to identify the data
=item Pointer $data; the data

=end pod

sub g_type_set_qdata ( int32 $type, int32 $quark, Pointer $data )
  is native(&gobject-lib)
  { * }

#-------------------------------------------------------------------------------
# TM:0:g_type_get_qdata:
=begin pod
=head2 [[g_] type_] get_qdata

Obtains data which has previously been attached to I<type>
with C<g_type_set_qdata()>.

Note that this does not take subtyping into account; data
attached to one type with C<g_type_set_qdata()> cannot
be retrieved from a subtype using C<g_type_get_qdata()>.

Returns: (transfer none): the data, or C<Any> if no data was found

  method g_type_get_qdata ( int32 $quark --> Pointer  )

=item int32 $quark; a I<GQuark> id to identify the data

=end pod

sub g_type_get_qdata ( int32 $type, int32 $quark --> Pointer )
  is native(&gobject-lib)
  { * }
}}


#`{{
#-------------------------------------------------------------------------------
# TM:0:g_type_next_base:
=begin pod
=head2 [[g_] type_] next_base

Given a I<$leaf_type> and a I<$root_type> which is contained in its anchestry, return the type that I<$root_type> is the immediate parent of. In other words, this function determines the type that is derived directly from I<$root_type> which is also a base class of I<$leaf_type>. Given a root type and a leaf type, this function can be used to determine the types and order in which the leaf type is descended from the root type.

Returns: immediate child of I<$root_type> and anchestor of I<$leaf_type>

  method g_type_next_base ( Int $root_type --> UInt )

=item int32 $root_type; immediate parent of the returned type

=end pod

sub g_type_next_base ( ulong $leaf_type, ulong $root_type --> ulong )
  is native(&gobject-lib)
  { * }
}}
