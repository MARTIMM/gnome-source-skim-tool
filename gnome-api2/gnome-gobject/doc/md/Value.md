Project Description
-------------------

  * **Distribution:** Gnome::GObject

  * **Project description:** Modules for package Gnome::GObject:api<2>. The language binding to GNOME's lower level object library

  * **Project version:** 0.1.2

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

![](images/value.png)

Description
===========

An opaque structure used to hold different types of values.

The data within the structure has protected scope: it is accessible only to functions within a GTypeValueTable structure, or implementations of the g_value_*() API. That is, code portions which implement new fundamental types.

GValue users cannot make any assumptions about how data is stored within the 2 element `$data` union, and the `$g_type` member should only be accessed through the G_VALUE_TYPE() macro.

Class initialization
====================

new
---

### :native-object

Create an object using a native object from elsewhere. See also **Gnome::N::TopLevelSupportClass**.

    multi method new ( N-Object :$native-object! )

Methods
=======

copy
----

Copies the value of `$src_value` into `$dest_value`.

    method copy ( CArray[N-Value] $dest-value )

  * $dest-value; An initialized GValue structure of the same type as `$src_value`..

dup-boxed
---------

Get the contents of a %G_TYPE_BOXED derived GValue. Upon getting, the boxed value is duplicated and needs to be later freed with g_boxed_free(), e.g. like: g_boxed_free (G_VALUE_TYPE ( `$value`), return_value);

    method dup-boxed (--> gpointer )

Return value; boxed contents of `$value`. 

dup-object
----------

Get the contents of a %G_TYPE_OBJECT derived GValue, increasing its reference count. If the contents of the GValue are `Nil`, then `Nil` will be returned.

    method dup-object (--> gpointer )

Return value; object content of `$value`, should be unreferenced when no longer needed.. 

dup-param
---------

Get the contents of a %G_TYPE_PARAM GValue, increasing its reference count.

    method dup-param (--> N-Object )

Return value; GParamSpec content of `$value`, should be unreferenced when no longer needed.. 

dup-string
----------

Get a copy the contents of a %G_TYPE_STRING GValue.

    method dup-string (--> Str )

Return value; a newly allocated copy of the string content of `$value`. 

dup-variant
-----------

Get the contents of a variant GValue, increasing its refcount. The returned GVariant is never floating.

    method dup-variant (--> CArray[N-Variant] )

Return value; variant contents of `$value` (may be `Nil`); should be unreffed using g_variant_unref() when no longer needed. 

fits-pointer
------------

Determines if `$value` will fit inside the size of a pointer value. This is an internal function introduced mainly for C marshallers.

    method fits-pointer (--> Bool )

Return value; `True` if `$value` will fit inside a pointer value.. 

get-boolean
-----------

Get the contents of a %G_TYPE_BOOLEAN GValue.

    method get-boolean (--> Bool )

Return value; boolean contents of `$value`. 

get-boxed
---------

Get the contents of a %G_TYPE_BOXED derived GValue.

    method get-boxed (--> gpointer )

Return value; boxed contents of `$value`. 

get-double
----------

Get the contents of a %G_TYPE_DOUBLE GValue.

    method get-double (--> Num )

Return value; double contents of `$value`. 

get-enum
--------

Get the contents of a %G_TYPE_ENUM GValue.

    method get-enum (--> Int )

Return value; enum contents of `$value`. 

get-flags
---------

Get the contents of a %G_TYPE_FLAGS GValue.

    method get-flags (--> UInt )

Return value; flags contents of `$value`. 

get-float
---------

Get the contents of a %G_TYPE_FLOAT GValue.

    method get-float (--> Num )

Return value; float contents of `$value`. 

get-gtype
---------

Get the contents of a %G_TYPE_GTYPE GValue.

    method get-gtype (--> GType )

Return value; the GType stored in `$value`. 

get-int
-------

Get the contents of a %G_TYPE_INT GValue.

    method get-int (--> Int )

Return value; integer contents of `$value`. 

get-int64
---------

Get the contents of a %G_TYPE_INT64 GValue.

    method get-int64 (--> Int )

Return value; 64bit integer contents of `$value`. 

get-long
--------

Get the contents of a %G_TYPE_LONG GValue.

    method get-long (--> Int )

Return value; long integer contents of `$value`. 

get-object
----------

Get the contents of a %G_TYPE_OBJECT derived GValue.

    method get-object (--> gpointer )

Return value; object contents of `$value`. 

get-param
---------

Get the contents of a %G_TYPE_PARAM GValue.

    method get-param (--> N-Object )

Return value; GParamSpec content of `$value`. 

get-pointer
-----------

Get the contents of a pointer GValue.

    method get-pointer (--> gpointer )

Return value; pointer contents of `$value`. 

get-schar
---------

Get the contents of a %G_TYPE_CHAR GValue.

    method get-schar (--> Int )

Return value; signed 8 bit integer contents of `$value`. 

get-string
----------

Get the contents of a %G_TYPE_STRING GValue.

    method get-string (--> Str )

Return value; string content of `$value`. 

get-uchar
---------

Get the contents of a %G_TYPE_UCHAR GValue.

    method get-uchar (--> UInt )

Return value; unsigned character contents of `$value`. 

get-uint
--------

Get the contents of a %G_TYPE_UINT GValue.

    method get-uint (--> UInt )

Return value; unsigned integer contents of `$value`. 

get-uint64
----------

Get the contents of a %G_TYPE_UINT64 GValue.

    method get-uint64 (--> UInt )

Return value; unsigned 64bit integer contents of `$value`. 

get-ulong
---------

Get the contents of a %G_TYPE_ULONG GValue.

    method get-ulong (--> UInt )

Return value; unsigned long integer contents of `$value`. 

get-variant
-----------

Get the contents of a variant GValue.

    method get-variant (--> CArray[N-Variant] )

Return value; variant contents of `$value` (may be `Nil`). 

init
----

Initializes `$value` with the default value of `$type`.

    method init ( GType $g-type --> CArray[N-Value] )

  * $g-type; Type the GValue should hold values of..

Return value; the GValue structure that has been passed in. 

init-from-instance
------------------

Initializes and sets `$value` from an instantiatable type via the value_table's collect_value() function.

Note: The `$value` will be initialised with the exact type of `$instance`. If you wish to set the `$value`'s type to a different GType (such as a parent class GType), you need to manually call `.init()` and `.set-instance()`.

    method init-from-instance ( gpointer $instance )

  * $instance; the instance.

peek-pointer
------------

Returns the value contents as pointer. This function asserts that `.fits-pointer()` returned `True` for the passed in value. This is an internal function introduced mainly for C marshallers.

    method peek-pointer (--> gpointer )

Return value; the value contents as pointer. 

reset
-----

Clears the current value in `$value` and resets it to the default value (as if the value had just been initialized).

    method reset (--> CArray[N-Value] )

Return value; the GValue structure that has been passed in. 

set-boolean
-----------

Set the contents of a %G_TYPE_BOOLEAN GValue to `$v_boolean`.

    method set-boolean ( Bool() $v-boolean )

  * $v-boolean; boolean value to be set.

set-boxed
---------

Set the contents of a %G_TYPE_BOXED derived GValue to `$v_boxed`.

    method set-boxed ( gpointer $v-boxed )

  * $v-boxed; boxed value to be set.

set-double
----------

Set the contents of a %G_TYPE_DOUBLE GValue to `$v_double`.

    method set-double ( Num() $v-double )

  * $v-double; double value to be set.

set-enum
--------

Set the contents of a %G_TYPE_ENUM GValue to `$v_enum`.

    method set-enum ( Int() $v-enum )

  * $v-enum; enum value to be set.

set-flags
---------

Set the contents of a %G_TYPE_FLAGS GValue to `$v_flags`.

    method set-flags ( UInt() $v-flags )

  * $v-flags; flags value to be set.

set-float
---------

Set the contents of a %G_TYPE_FLOAT GValue to `$v_float`.

    method set-float ( Num() $v-float )

  * $v-float; float value to be set.

set-gtype
---------

Set the contents of a %G_TYPE_GTYPE GValue to `$v_gtype`.

    method set-gtype ( GType $v-gtype )

  * $v-gtype; GType to be set.

set-instance
------------

Sets `$value` from an instantiatable type via the value_table's collect_value() function.

    method set-instance ( gpointer $instance )

  * $instance; the instance.

set-int
-------

Set the contents of a %G_TYPE_INT GValue to `$v_int`.

    method set-int ( Int() $v-int )

  * $v-int; integer value to be set.

set-int64
---------

Set the contents of a %G_TYPE_INT64 GValue to `$v_int64`.

    method set-int64 ( Int() $v-int64 )

  * $v-int64; 64bit integer value to be set.

set-interned-string
-------------------

Set the contents of a %G_TYPE_STRING GValue to `$v_string`. The string is assumed to be static and interned (canonical, for example from g_intern_string()), and is thus not duplicated when setting the GValue.

    method set-interned-string ( Str $v-string )

  * $v-string; static string to be set.

set-long
--------

Set the contents of a %G_TYPE_LONG GValue to `$v_long`.

    method set-long ( Int() $v-long )

  * $v-long; long integer value to be set.

set-object
----------

Set the contents of a %G_TYPE_OBJECT derived GValue to `$v_object`.

`.set-object()` increases the reference count of `$v_object` (the GValue holds a reference to `$v_object`). If you do not wish to increase the reference count of the object (i.e. you wish to pass your current reference to the GValue because you no longer need it), use `.take-object()` instead.

It is important that your GValue holds a reference to `$v_object` (either its own, or one it has taken) to ensure that the object won't be destroyed while the GValue still exists).

    method set-object ( gpointer $v-object )

  * $v-object; object value to be set.

set-param
---------

Set the contents of a %G_TYPE_PARAM GValue to `$param`.

    method set-param ( N-Object() $param )

  * $param; the GParamSpec to be set.

set-pointer
-----------

Set the contents of a pointer GValue to `$v_pointer`.

    method set-pointer ( gpointer $v-pointer )

  * $v-pointer; pointer value to be set.

set-schar
---------

Set the contents of a %G_TYPE_CHAR GValue to `$v_char`.

    method set-schar ( Int() $v-char )

  * $v-char; signed 8 bit integer to be set.

set-static-boxed
----------------

Set the contents of a %G_TYPE_BOXED derived GValue to `$v_boxed`.

The boxed value is assumed to be static, and is thus not duplicated when setting the GValue.

    method set-static-boxed ( gpointer $v-boxed )

  * $v-boxed; static boxed value to be set.

set-static-string
-----------------

Set the contents of a %G_TYPE_STRING GValue to `$v_string`. The string is assumed to be static, and is thus not duplicated when setting the GValue.

If the the string is a canonical string, using `.set-interned-string()` is more appropriate.

    method set-static-string ( Str $v-string )

  * $v-string; static string to be set.

set-string
----------

Set the contents of a %G_TYPE_STRING GValue to a copy of `$v_string`.

    method set-string ( Str $v-string )

  * $v-string; caller-owned string to be duplicated for the GValue.

set-uchar
---------

Set the contents of a %G_TYPE_UCHAR GValue to `$v_uchar`.

    method set-uchar ( UInt() $v-uchar )

  * $v-uchar; unsigned character value to be set.

set-uint
--------

Set the contents of a %G_TYPE_UINT GValue to `$v_uint`.

    method set-uint ( UInt() $v-uint )

  * $v-uint; unsigned integer value to be set.

set-uint64
----------

Set the contents of a %G_TYPE_UINT64 GValue to `$v_uint64`.

    method set-uint64 ( UInt() $v-uint64 )

  * $v-uint64; unsigned 64bit integer value to be set.

set-ulong
---------

Set the contents of a %G_TYPE_ULONG GValue to `$v_ulong`.

    method set-ulong ( UInt() $v-ulong )

  * $v-ulong; unsigned long integer value to be set.

set-variant
-----------

Set the contents of a variant GValue to `$variant`. If the variant is floating, it is consumed.

    method set-variant ( CArray[N-Variant] $variant )

  * $variant; a GVariant, or `Nil`.

take-boxed
----------

Sets the contents of a %G_TYPE_BOXED derived GValue to `$v_boxed` and takes over the ownership of the caller’s reference to `$v_boxed`; the caller doesn’t have to unref it any more.

    method take-boxed ( gpointer $v-boxed )

  * $v-boxed; duplicated unowned boxed value to be set.

take-object
-----------

Sets the contents of a %G_TYPE_OBJECT derived GValue to `$v_object` and takes over the ownership of the caller’s reference to `$v_object`; the caller doesn’t have to unref it any more (i.e. the reference count of the object is not increased).

If you want the GValue to hold its own reference to `$v_object`, use `.set-object()` instead.

    method take-object ( gpointer $v-object )

  * $v-object; object value to be set.

take-param
----------

Sets the contents of a %G_TYPE_PARAM GValue to `$param` and takes over the ownership of the caller’s reference to `$param`; the caller doesn’t have to unref it any more.

    method take-param ( N-Object() $param )

  * $param; the GParamSpec to be set.

take-string
-----------

Sets the contents of a %G_TYPE_STRING GValue to `$v_string`.

    method take-string ( Str $v-string )

  * $v-string; string to take ownership of.

take-variant
------------

Set the contents of a variant GValue to `$variant`, and takes over the ownership of the caller's reference to `$variant`; the caller doesn't have to unref it any more (i.e. the reference count of the variant is not increased).

If `$variant` was floating then its floating reference is converted to a hard reference.

If you want the GValue to hold its own reference to `$variant`, use `.set-variant()` instead.

This is an internal function introduced mainly for C marshallers.

    method take-variant ( CArray[N-Variant] $variant )

  * $variant; (transfer ownership: full) a GVariant, or `Nil`.

transform
---------

Tries to cast the contents of `$src_value` into a type appropriate to store in `$dest_value`, e.g. to transform a %G_TYPE_INT value into a %G_TYPE_FLOAT value. Performing transformations between value types might incur precision lossage. Especially transformations into strings might reveal seemingly arbitrary results and shouldn't be relied upon for production code (such as rcfile value or object property serialization).

    method transform ( CArray[N-Value] $dest-value --> Bool )

  * $dest-value; Target value..

Return value; Whether a transformation rule was found and could be applied. Upon failing transformations, `$dest_value` is left untouched.. 

unset
-----

Clears the current value in `$value` (if any) and "unsets" the type, this releases all resources associated with this GValue. An unset value is the same as an uninitialized (zero-filled) GValue structure.

    method unset ( )

Functions
=========

register-transform-func
-----------------------

Registers a value transformation function for use in `.transform()`. A previously registered transformation function for `$src_type` and `$dest_type` will be replaced.

    method register-transform-func ( GType $src-type, GType $dest-type, &transform-func )

  * $src-type; Source type..

  * $dest-type; Target type..

  * &transform-func; a function which transforms values of type `$src_type` into value of type `$dest_type`. Tthe function must be specified with following signature; `:( N-Value $src-value, N-Value $dest-value )`.

type-compatible
---------------

Returns whether a GValue of type `$src_type` can be copied into a GValue of type `$dest_type`.

    method type-compatible ( GType $src-type, GType $dest-type --> Bool )

  * $src-type; source type to be copied..

  * $dest-type; destination type for copying..

Return value; `True` if `.copy()` is possible with `$src_type` and `$dest_type`.. 

type-transformable
------------------

Check whether `.transform()` is able to transform values of type `$src_type` into values of type `$dest_type`. Note that for the types to be transformable, they must be compatible or a transformation function must be registered.

    method type-transformable ( GType $src-type, GType $dest-type --> Bool )

  * $src-type; Source type..

  * $dest-type; Target type..

Return value; `True` if the transformation is possible, `False` otherwise.. 
