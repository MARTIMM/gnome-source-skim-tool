Project Description
-------------------

  * **Distribution:** Gnome::Glib

  * **Project description:** Modules for package Gnome::Glib:api<2>. The language binding to GNOME's lowest level library

  * **Project version:** 0.1.5

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

![](images/variantdict.png)

Description
===========

GVariantDict is a mutable interface to GVariant dictionaries.

It can be used for doing a sequence of dictionary lookups in an efficient way on an existing GVariant dictionary or it can be used to construct new dictionaries with a hashtable-like interface. It can also be used for taking existing dictionaries and modifying them in order to create new ones.

GVariantDict can only be used with %G_VARIANT_TYPE_VARDICT dictionaries.

It is possible to use GVariantDict allocated on the stack or on the heap. When using a stack-allocated GVariantDict, you begin with a call to `.init()` and free the resources with a call to `.clear()`.

Heap-allocated GVariantDict follows normal refcounting rules: you allocate it with `.new-variantdict()` and use `.ref()` and `.unref()`.

`.end()` is used to convert the GVariantDict back into a dictionary-type GVariant. When used with stack-allocated instances, this also implicitly frees all associated memory, but for heap-allocated instances, you must still call `.unref()` afterwards.

You will typically want to use a heap-allocated GVariantDict when you expose it as part of an API. For most other uses, the stack-allocated form will be more convenient.

Consider the following two examples that do the same thing in each style: take an existing dictionary and look up the "count" uint32 key, adding 1 to it if it is found, or returning an error if the key is not found. Each returns the new dictionary as a floating GVariant.

## Using a stack-allocated GVariantDict

## Using heap-allocated GVariantDict

Class initialization
====================

new
---

### :native-object

Create an object using a native object from elsewhere. See also **Gnome::N::TopLevelSupportClass**.

    multi method new ( N-Object :$native-object! )

new-variantdict
---------------

Allocates and initialises a new GVariantDict.

You should call `.unref()` on the return value when it is no longer needed. The memory will not be automatically freed by any other call.

In some cases it may be easier to place a GVariantDict directly on the stack of the calling function and initialise it with `.init()`. This is particularly useful when you are using GVariantDict to construct a GVariant.

    method new-variantdict ( --> Gnome::Glib::VariantDict)

Methods
=======

clear
-----

Releases all memory associated with a GVariantDict without freeing the GVariantDict structure itself.

It typically only makes sense to do this on a stack-allocated GVariantDict if you want to abort building the value part-way through. This function need not be called if you call `.end()` and it also doesn't need to be called on dicts allocated with g_variant_dict_new (see `.unref()` for that).

It is valid to call this function on either an initialised GVariantDict or one that was previously cleared by an earlier call to `.clear()` but it is not valid to call this function on uninitialised memory.

    method clear ( )

contains
--------

Checks if `$key` exists in `$dict`.

    method contains ( Str $key --> Bool )

  * $key; the key to look up in the dictionary.

Return value; `True` if `$key` is in `$dict`. 

end
---

Returns the current value of `$dict` as a GVariant of type %G_VARIANT_TYPE_VARDICT, clearing it in the process.

It is not permissible to use `$dict` in any way after this call except for reference counting operations (in the case of a heap-allocated GVariantDict) or by reinitialising it with `.init()` (in the case of stack-allocated).

    method end (--> CArray[N-Variant] )

Return value; a new, floating, GVariant. 

init
----

Initialises a GVariantDict structure.

If `$from_asv` is given, it is used to initialise the dictionary.

This function completely ignores the previous contents of `$dict`. On one hand this means that it is valid to pass in completely uninitialised memory. On the other hand, this means that if you are initialising over top of an existing GVariantDict you need to first call `.clear()` in order to avoid leaking memory.

You must not call `.ref()` or `.unref()` on a GVariantDict that was initialised with this function. If you ever pass a reference to a GVariantDict outside of the control of your own code then you should assume that the person receiving that reference may try to use reference counting; you should use `.new-variantdict()` instead of this function.

    method init ( CArray[N-Variant] $from-asv )

  * $from-asv; the initial value for `$dict`.

insert
------

Inserts a value into a GVariantDict.

This call is a convenience wrapper that is exactly equivalent to calling g_variant_new() followed by `.insert-value()`.

    method insert ( Str $key, Str $format-string, … )

  * $key; the key to insert a value for.

  * $format-string; a GVariant varargs format string.

  * …; arguments, as per `$format_string`. Note that each argument must be specified as a type followed by its value!

insert-value
------------

Inserts (or replaces) a key in a GVariantDict. `$value` is consumed if it is floating.

    method insert-value ( Str $key, CArray[N-Variant] $value )

  * $key; the key to insert a value for.

  * $value; the value to insert.

lookup
------

Looks up a value in a GVariantDict.

This function is a wrapper around `.lookup-value()` and g_variant_get(). In the case that `Nil` would have been returned, this function returns `False`. Otherwise, it unpacks the returned value and returns `True`. `$format_string` determines the C types that are used for unpacking the values and also determines if the values are copied or borrowed, see the section on GVariant format strings.

    method lookup ( Str $key, Str $format-string, … --> Bool )

  * $key; the key to look up in the dictionary.

  * $format-string; a GVariant format string.

  * …; the arguments to unpack the value into. Note that each argument must be specified as a type followed by its value!

Return value; `True` if a value was unpacked. 

lookup-value
------------

Looks up a value in a GVariantDict.

If `$key` is not found in `$dictionary`, `Nil` is returned.

The `$expected_type` string specifies what type of value is expected. If the value associated with `$key` has a different type then `Nil` is returned.

If the key is found and the value has the correct type, it is returned. If `$expected_type` was specified then any non-`Nil` return value will have this type.

    method lookup-value ( Str $key, CArray[N-VariantType] $expected-type --> CArray[N-Variant] )

  * $key; the key to look up in the dictionary.

  * $expected-type; a GVariantType, or `Nil`.

Return value; the value of the dictionary key, or `Nil`. 

ref
---

Increases the reference count on `$dict`.

Don't call this on stack-allocated GVariantDict instances or bad things will happen.

    method ref (--> CArray[N-VariantDict] )

Return value; a new reference to `$dict`. 

remove
------

Removes a key and its associated value from a GVariantDict.

    method remove ( Str $key --> Bool )

  * $key; the key to remove.

Return value; `True` if the key was found and removed. 

unref
-----

Decreases the reference count on `$dict`.

In the event that there are no more references, releases all memory associated with the GVariantDict.

Don't call this on stack-allocated GVariantDict instances or bad things will happen.

    method unref ( )
