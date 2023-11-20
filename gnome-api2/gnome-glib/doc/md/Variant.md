Project Description
-------------------

  * **Distribution:** Gnome::Glib

  * **Project description:** Modules for package Gnome::Glib:api<2>. The language binding to GNOME's lowest level library

  * **Project version:** 0.1.5

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

![](images/variant.png)

Description
===========

GVariant is a variant datatype; it can contain one or more values along with information about the type of the values.

A GVariant may contain simple types, like an integer, or a boolean value; or complex types, like an array of two strings, or a dictionary of key value pairs. A GVariant is also immutable: once it's been created neither its type nor its content can be modified further.

GVariant is useful whenever data needs to be serialized, for example when sending method parameters in D-Bus, or when saving settings using GSettings.

When creating a new GVariant, you pass the data you want to store in it along with a string representing the type of data you wish to pass to it.

For instance, if you want to create a GVariant holding an integer value you can use:

The string "u" in the first argument tells GVariant that the data passed to the constructor (40) is going to be an unsigned integer.

More advanced examples of GVariant in use can be found in documentation for GVariant format strings.

The range of possible values is determined by the type.

The type system used by GVariant is GVariantType.

GVariant instances always have a type and a value (which are given at construction time). The type and value of a GVariant instance can never change other than by the GVariant itself being destroyed. A GVariant cannot contain a pointer.

GVariant is reference counted using `.ref()` and `.unref()`. GVariant also has floating reference counts -- see `.ref-sink()`.

GVariant is completely threadsafe. A GVariant instance can be concurrently accessed in any way from any number of threads without problems.

GVariant is heavily optimised for dealing with data in serialized form. It works particularly well with data located in memory-mapped files. It can perform nearly all deserialization operations in a small constant time, usually touching only a single memory page. Serialized GVariant data can also be sent over the network.

GVariant is largely compatible with D-Bus. Almost all types of GVariant instances can be sent over D-Bus. See GVariantType for exceptions. (However, GVariant's serialization format is not the same as the serialization format of a D-Bus message body: use GDBusMessage, in the gio library, for those.)

For space-efficiency, the GVariant serialization format does not automatically include the variant's length, type or endianness, which must either be implied from context (such as knowledge that a particular file format always contains a little-endian %G_VARIANT_TYPE_VARIANT which occupies the whole length of the file) or supplied out-of-band (for instance, a length, type and/or endianness indicator could be placed at the beginning of a file, network message or network stream).

A GVariant's size is limited mainly by any lower level operating system constraints, such as the number of bits in #gsize. For example, it is reasonable to have a 2GB file mapped into memory with GMappedFile, and call `.new-from-data()` on it.

For convenience to C programmers, GVariant features powerful varargs-based value construction and destruction. This feature is designed to be embedded in other libraries.

There is a Python-inspired text language for describing GVariant values. GVariant includes a printer for this language and a parser with type inferencing.

## Memory Use

GVariant tries to be quite efficient with respect to memory use. This section gives a rough idea of how much memory is used by the current implementation. The information here is subject to change in the future.

The memory allocated by GVariant can be grouped into 4 broad purposes: memory for serialized data, memory for the type information cache, buffer management memory and memory for the GVariant structure itself.

## Serialized Data Memory

This is the memory that is used for storing GVariant data in serialized form. This is what would be sent over the network or what would end up on disk, not counting any indicator of the endianness, or of the length or type of the top-level variant.

The amount of memory required to store a boolean is 1 byte. 16, 32 and 64 bit integers and double precision floating point numbers use their "natural" size. Strings (including object path and signature strings) are stored with a nul terminator, and as such use the length of the string plus 1 byte.

Maybe types use no space at all to represent the null value and use the same amount of space (sometimes plus one byte) as the equivalent non-maybe-typed value to represent the non-null case.

Arrays use the amount of space required to store each of their members, concatenated. Additionally, if the items stored in an array are not of a fixed-size (ie: strings, other arrays, etc) then an additional framing offset is stored for each item. The size of this offset is either 1, 2 or 4 bytes depending on the overall size of the container. Additionally, extra padding bytes are added as required for alignment of child values.

Tuples (including dictionary entries) use the amount of space required to store each of their members, concatenated, plus one framing offset (as per arrays) for each non-fixed-sized item in the tuple, except for the last one. Additionally, extra padding bytes are added as required for alignment of child values.

Variants use the same amount of space as the item inside of the variant, plus 1 byte, plus the length of the type string for the item inside the variant.

As an example, consider a dictionary mapping strings to variants. In the case that the dictionary is empty, 0 bytes are required for the serialization.

If we add an item "width" that maps to the int32 value of 500 then we will use 4 byte to store the int32 (so 6 for the variant containing it) and 6 bytes for the string. The variant must be aligned to 8 after the 6 bytes of the string, so that's 2 extra bytes. 6 (string) + 2 (padding) + 6 (variant) is 14 bytes used for the dictionary entry. An additional 1 byte is added to the array as a framing offset making a total of 15 bytes.

If we add another entry, "title" that maps to a nullable string that happens to have a value of null, then we use 0 bytes for the null value (and 3 bytes for the variant to contain it along with its type string) plus 6 bytes for the string. Again, we need 2 padding bytes. That makes a total of 6 + 2 + 3 = 11 bytes.

We now require extra padding between the two items in the array. After the 14 bytes of the first item, that's 2 bytes required. We now require 2 framing offsets for an extra two bytes. 14 + 2 + 11 + 2 = 29 bytes to encode the entire two-item dictionary.

## Type Information Cache

For each GVariant type that currently exists in the program a type information structure is kept in the type information cache. The type information structure is required for rapid deserialization.

Continuing with the above example, if a GVariant exists with the type "a{sv}" then a type information struct will exist for "a{sv}", "{sv}", "s", and "v". Multiple uses of the same type will share the same type information. Additionally, all single-digit types are stored in read-only static memory and do not contribute to the writable memory footprint of a program using GVariant.

Aside from the type information structures stored in read-only memory, there are two forms of type information. One is used for container types where there is a single element type: arrays and maybe types. The other is used for container types where there are multiple element types: tuples and dictionary entries.

Array type info structures are 6 * sizeof (void *), plus the memory required to store the type string itself. This means that on 32-bit systems, the cache entry for "a{sv}" would require 30 bytes of memory (plus malloc overhead).

Tuple type info structures are 6 * sizeof (void *), plus 4 * sizeof (void *) for each item in the tuple, plus the memory required to store the type string itself. A 2-item tuple, for example, would have a type information structure that consumed writable memory in the size of 14 * sizeof (void *) (plus type string) This means that on 32-bit systems, the cache entry for "{sv}" would require 61 bytes of memory (plus malloc overhead).

This means that in total, for our "a{sv}" example, 91 bytes of type information would be allocated.

The type information cache, additionally, uses a GHashTable to store and look up the cached items and stores a pointer to this hash table in static storage. The hash table is freed when there are zero items in the type cache.

Although these sizes may seem large it is important to remember that a program will probably only have a very small number of different types of values in it and that only one type information structure is required for many different values of the same type.

## Buffer Management Memory

GVariant uses an internal buffer management structure to deal with the various different possible sources of serialized data that it uses. The buffer is responsible for ensuring that the correct call is made when the data is no longer in use by GVariant. This may involve a g_free() or a g_slice_free() or even g_mapped_file_unref().

One buffer management structure is used for each chunk of serialized data. The size of the buffer management structure is 4 * (void *). On 32-bit systems, that's 16 bytes.

## GVariant structure

The size of a GVariant structure is 6 * (void *). On 32-bit systems, that's 24 bytes.

GVariant structures only exist if they are explicitly created with API calls. For example, if a GVariant is constructed out of serialized data for the example given above (with the dictionary) then although there are 9 individual values that comprise the entire dictionary (two keys, two values, two variants containing the values, two dictionary entries, plus the dictionary itself), only 1 GVariant instance exists -- the one referring to the dictionary.

If calls are made to start accessing the other values then GVariant instances will exist for those values only for as long as they are in use (ie: until you call `.unref()`). The type information is shared. The serialized data and the buffer management structure for that serialized data is shared by the child.

## Summary

To put the entire example together, for our dictionary mapping strings to variants (with two entries, as given above), we are using 91 bytes of memory for type information, 29 bytes of memory for the serialized data, 16 bytes for buffer management and 24 bytes for the GVariant instance, or a total of 160 bytes, plus malloc overhead. If we were to use `.get-child-value()` to access the two dictionary entries, we would use an additional 48 bytes. If we were to have other dictionaries of the same type, we would use more memory for the serialized data and buffer management for those dictionaries, but the type information would be shared.

Class initialization
====================

new
---

### :native-object

Create an object using a native object from elsewhere. See also **Gnome::N::TopLevelSupportClass**.

    multi method new ( N-Object :$native-object! )

new-variant
-----------

Creates a new GVariant instance.

Think of this function as an analogue to g_strdup_printf().

The type of the created instance and the arguments that are expected by this function are determined by `$format_string`. See the section on GVariant format strings. Please note that the syntax of the format string is very likely to be extended in the future.

The first character of the format string must not be '*' '?' '@' or 'r'; in essence, a new GVariant must always be constructed by this function (and not merely passed through it unmodified).

Note that the arguments must be of the correct width for their types specified in `$format_string`. This can be achieved by casting them. See the GVariant varargs documentation.

    method new-variant ( Str $format-string, … --> Gnome::Glib::Variant)

  * $format-string; a GVariant format string.

  * …; arguments, as per `$format_string`. Note that each argument must be specified as a type followed by its value!

new-array
---------

Creates a new GVariant array from `$children`. `$child_type` must be non-`Nil` if `$n_children` is zero. Otherwise, the child type is determined by inspecting the first element of the `$children` array. If `$child_type` is non-`Nil` then it must be a definite type.

The items of the array are taken from the `$children` array. No entry in the `$children` array may be `Nil`.

All items in the array must have the same type, which must be the same as `$child_type`, if given.

If the `$children` are floating references (see `.ref-sink()`), the new instance takes ownership of them as if via `.ref-sink()`.

    method new-array ( CArray[N-VariantType] $child-type, CArray[N-Variant] $children, Int() $n-children --> Gnome::Glib::Variant)

  * $child-type; the element type of the new array.

  * $children; an array of GVariant pointers, the children.

  * $n-children; the length of `$children`.

new-boolean
-----------

Creates a new boolean GVariant instance -- either `True` or `False`.

    method new-boolean ( Bool() $value --> Gnome::Glib::Variant)

  * $value; a `gboolean` value.

new-byte
--------

Creates a new byte GVariant instance.

    method new-byte ( UInt() $value --> Gnome::Glib::Variant)

  * $value; a `guint8` value.

new-bytestring
--------------

Creates an array-of-bytes GVariant with the contents of `$string`. This function is just like `.new-string()` except that the string need not be valid UTF-8.

The nul terminator character at the end of the string is stored in the array.

    method new-bytestring ( Str $string --> Gnome::Glib::Variant)

  * $string; a normal nul-terminated string in no particular encoding.

new-bytestring-array
--------------------

Constructs an array of bytestring GVariant from the given array of strings.

If `$length` is -1 then `$strv` is `Nil`-terminated.

    method new-bytestring-array (
      Array[Str] $strv, Int() $length
      --> Gnome::Glib::Variant
    )

  * $strv; an array of strings.

  * $length; the length of `$strv`, or -1.

new-dict-entry
--------------

Creates a new dictionary entry GVariant. `$key` and `$value` must be non-`Nil`. `$key` must be a value of a basic type (ie: not a container).

If the `$key` or `$value` are floating references (see `.ref-sink()`), the new instance takes ownership of them as if via `.ref-sink()`.

    method new-dict-entry (
      CArray[N-Variant] $key, CArray[N-Variant] $value
      --> Gnome::Glib::Variant
    )

  * $key; a basic GVariant, the key.

  * $value; a GVariant, the value.

new-double
----------

Creates a new double GVariant instance.

    method new-double ( Num() $value --> Gnome::Glib::Variant)

  * $value; a `gdouble` floating point value.

new-fixed-array
---------------

Constructs a new array GVariant instance, where the elements are of `$element_type` type. `$elements` must be an array with fixed-sized elements. Numeric types are fixed-size as are tuples containing only other fixed-sized types. `$element_size` must be the size of a single element in the array. For example, if calling this function for an array of 32-bit integers, you might say sizeof(gint32). This value isn't used except for the purpose of a double-check that the form of the serialized data matches the caller's expectation. `$n_elements` must be the length of the `$elements` array.

    method new-fixed-array (
      CArray[N-VariantType] $element-type,
      gpointer $elements, Int() $n-elements,
      Int() $element-size
      --> Gnome::Glib::Variant
    )

  * $element-type; the GVariantType of each element.

  * $elements; a pointer to the fixed array of contiguous elements.

  * $n-elements; the number of elements.

  * $element-size; the size of each element.

new-from-bytes
--------------

Constructs a new serialized-mode GVariant instance. This is the inner interface for creation of new serialized values that gets called from various functions in gvariant.c.

A reference is taken on `$bytes`.

The data in `$bytes` must be aligned appropriately for the `$type` being loaded. Otherwise this function will internally create a copy of the memory (since GLib 2.60) or (in older versions) fail and exit the process.

    method new-from-bytes (
      CArray[N-VariantType] $type,
      CArray[N-Bytes] $bytes, Bool() $trusted
      --> Gnome::Glib::Variant
    )

  * $type; a GVariantType.

  * $bytes; a GBytes.

  * $trusted; if the contents of `$bytes` are trusted.

new-from-data
-------------

Creates a new GVariant instance from serialized data. `$type` is the type of GVariant instance that will be constructed. The interpretation of `$data` depends on knowing the type. `$data` is not modified by this function and must remain valid with an unchanging value until such a time as `$notify` is called with `$user_data`. If the contents of `$data` change before that time then the result is undefined.

If `$data` is trusted to be serialized data in normal form then `$trusted` should be `True`. This applies to serialized data created within this process or read from a trusted location on the disk (such as a file installed in /usr/lib alongside your application). You should set trusted to `False` if `$data` is read from the network, a file in the user's home directory, etc.

If `$data` was not stored in this machine's native endianness, any multi-byte numeric values in the returned variant will also be in non-native endianness. `.byteswap()` can be used to recover the original values. `$notify` will be called with `$user_data` when `$data` is no longer needed. The exact time of this call is unspecified and might even be before this function returns.

Note: `$data` must be backed by memory that is aligned appropriately for the `$type` being loaded. Otherwise this function will internally create a copy of the memory (since GLib 2.60) or (in older versions) fail and exit the process.

    method new-from-data (
      CArray[N-VariantType] $type, gpointer $data,
      Int() $size, Bool() $trusted, &notify,
      gpointer $user-data
      --> Gnome::Glib::Variant
    )

  * $type; a definite GVariantType.

  * $data; the serialized data.

  * $size; the size of `$data`.

  * $trusted; `True` if `$data` is definitely in normal form.

  * &notify; function to call when `$data` is no longer needed. Tthe function must be specified with following signature; `:( gpointer $data )`.

  * $user-data; data for `$notify`.

new-handle
----------

Creates a new handle GVariant instance.

By convention, handles are indexes into an array of file descriptors that are sent alongside a D-Bus message. If you're not interacting with D-Bus, you probably don't need them.

    method new-handle ( Int() $value --> Gnome::Glib::Variant)

  * $value; a `gint32` value.

new-int16
---------

Creates a new int16 GVariant instance.

    method new-int16 ( Int() $value --> Gnome::Glib::Variant)

  * $value; a `gint16` value.

new-int32
---------

Creates a new int32 GVariant instance.

    method new-int32 ( Int() $value --> Gnome::Glib::Variant)

  * $value; a `gint32` value.

new-int64
---------

Creates a new int64 GVariant instance.

    method new-int64 ( Int() $value --> Gnome::Glib::Variant)

  * $value; a `gint64` value.

new-maybe
---------

Depending on if `$child` is `Nil`, either wraps `$child` inside of a maybe container or creates a Nothing instance for the given `$type`.

At least one of `$child_type` and `$child` must be non-`Nil`. If `$child_type` is non-`Nil` then it must be a definite type. If they are both non-`Nil` then `$child_type` must be the type of `$child`.

If `$child` is a floating reference (see `.ref-sink()`), the new instance takes ownership of `$child`.

    method new-maybe (
      CArray[N-VariantType] $child-type,
      CArray[N-Variant] $child
      --> Gnome::Glib::Variant
    )

  * $child-type; the GVariantType of the child, or `Nil`.

  * $child; the child value, or `Nil`.

new-object-path
---------------

Creates a D-Bus object path GVariant with the contents of `$string`. `$string` must be a valid D-Bus object path. Use `.is-object-path()` if you're not sure.

    method new-object-path ( Str $object-path --> Gnome::Glib::Variant)

  * $object-path; a normal C nul-terminated string.

new-parsed
----------

Parses `$format` and returns the result. `$format` must be a text format GVariant with one extension: at any point that a value may appear in the text, a '%' character followed by a GVariant format string (as per `.new-variant()`) may appear. In that case, the same arguments are collected from the argument list as `.new-variant()` would have collected.

Note that the arguments must be of the correct width for their types specified in `$format`. This can be achieved by casting them. See the GVariant varargs documentation.

This function is intended only to be used with `$format` as a string literal. Any parse error is fatal to the calling process. If you want to parse data from untrusted sources, use `.parse()`.

You may not use this function to return, unmodified, a single GVariant pointer from the argument list. ie: `$format` may not solely be anything along the lines of "%*", "%?", "\%r", or anything starting with "%@".

    method new-parsed ( Str $format, … --> Gnome::Glib::Variant)

  * $format; a text format GVariant.

  * …; arguments as per `$format`. Note that each argument must be specified as a type followed by its value!

new-parsed-va
-------------

Parses `$format` and returns the result.

This is the version of `.new-parsed()` intended to be used from libraries.

The return value will be floating if it was a newly created GVariant instance. In the case that `$format` simply specified the collection of a GVariant pointer (eg: `$format` was "%*") then the collected GVariant pointer will be returned unmodified, without adding any additional references.

Note that the arguments in `$app` must be of the correct width for their types specified in `$format` when collected into the #va_list. See the GVariant varargs documentation.

In order to behave correctly in all cases it is necessary for the calling function to `.ref-sink()` the return result before returning control to the user that originally provided the pointer. At this point, the caller will have their own full reference to the result. This can also be done by adding the result to a container, or by passing it to another `.new-variant()` call.

    method new-parsed-va ( Str $format, … --> Gnome::Glib::Variant)

  * $format; a text format GVariant.

  * app; a pointer to a `va_list`. Note that each argument must be specified as a type followed by its value!

new-printf
----------

Creates a string-type GVariant using printf formatting.

This is similar to calling g_strdup_printf() and then `.new-string()` but it saves a temporary variable and an unnecessary copy.

    method new-printf ( Str $format-string, … --> Gnome::Glib::Variant)

  * $format-string; a printf-style format string.

  * …; arguments for `$format_string`. Note that each argument must be specified as a type followed by its value!

new-signature
-------------

Creates a D-Bus type signature GVariant with the contents of `$string`. `$string` must be a valid D-Bus type signature. Use `.is-signature()` if you're not sure.

    method new-signature ( Str $signature --> Gnome::Glib::Variant)

  * $signature; a normal C nul-terminated string.

new-string
----------

Creates a string GVariant with the contents of `$string`. `$string` must be valid UTF-8, and must not be `Nil`. To encode potentially-`Nil` strings, use `.new-variant()` with `ms` as the format string.

    method new-string ( Str $string --> Gnome::Glib::Variant)

  * $string; a normal UTF-8 nul-terminated string.

new-strv
--------

Constructs an array of strings GVariant from the given array of strings.

If `$length` is -1 then `$strv` is `Nil`-terminated.

    method new-strv ( Array[Str] $strv, Int() $length --> Gnome::Glib::Variant)

  * $strv; an array of strings.

  * $length; the length of `$strv`, or -1.

new-take-string
---------------

Creates a string GVariant with the contents of `$string`. `$string` must be valid UTF-8, and must not be `Nil`. To encode potentially-`Nil` strings, use this with `.new-maybe()`.

This function consumes `$string`. g_free() will be called on `$string` when it is no longer required.

You must not modify or access `$string` in any other way after passing it to this function. It is even possible that `$string` is immediately freed.

    method new-take-string ( Str $string --> Gnome::Glib::Variant)

  * $string; a normal UTF-8 nul-terminated string.

new-tuple
---------

Creates a new tuple GVariant out of the items in `$children`. The type is determined from the types of `$children`. No entry in the `$children` array may be `Nil`.

If `$n_children` is 0 then the unit tuple is constructed.

If the `$children` are floating references (see `.ref-sink()`), the new instance takes ownership of them as if via `.ref-sink()`.

    method new-tuple (
      CArray[N-Variant] $children, Int() $n-children
      --> Gnome::Glib::Variant
    )

  * $children; the items to make the tuple out of.

  * $n-children; the length of `$children`.

new-uint16
----------

Creates a new uint16 GVariant instance.

    method new-uint16 ( UInt() $value --> Gnome::Glib::Variant)

  * $value; a `guint16` value.

new-uint32
----------

Creates a new uint32 GVariant instance.

    method new-uint32 ( UInt() $value --> Gnome::Glib::Variant)

  * $value; a `guint32` value.

new-uint64
----------

Creates a new uint64 GVariant instance.

    method new-uint64 ( UInt() $value --> Gnome::Glib::Variant)

  * $value; a `guint64` value.

new-variant-with-variant
------------------------

Boxes `$value`. The result is a GVariant instance representing a variant containing the original value.

If `$child` is a floating reference (see `.ref-sink()`), the new instance takes ownership of `$child`.

    method new-variant-with-variant (
      CArray[N-Variant] $value --> Gnome::Glib::Variant
    )

  * $value; a GVariant instance.

Methods
=======

byteswap
--------

Performs a byteswapping operation on the contents of `$value`. The result is that all multi-byte numeric data contained in `$value` is byteswapped. That includes 16, 32, and 64bit signed and unsigned integers as well as file handles and double precision floating point values.

This function is an identity mapping on any value that does not contain multi-byte numeric data. That include strings, booleans, bytes and containers containing only these things (recursively).

The returned value is always in normal form and is marked as trusted.

    method byteswap (--> CArray[N-Variant] )

Return value; the byteswapped form of `$value`. 

check-format-string
-------------------

Checks if calling `.get()` with `$format_string` on `$value` would be valid from a type-compatibility standpoint. `$format_string` is assumed to be a valid format string (from a syntactic standpoint).

If `$copy_only` is `True` then this function additionally checks that it would be safe to call `.unref()` on `$value` immediately after the call to `.get()` without invalidating the result. This is only possible if deep copies are made (ie: there are no pointers to the data inside of the soon-to-be-freed GVariant instance). If this check fails then a g_critical() is printed and `False` is returned.

This function is meant to be used by functions that wish to provide varargs accessors to GVariant values of uncertain values (eg: `.lookup()` or g_menu_model_get_item_attribute()).

    method check-format-string (
      Str $format-string, Bool() $copy-only --> Bool
    )

  * $format-string; a valid GVariant format string.

  * $copy-only; `True` to ensure the format string makes deep copies.

Return value; `True` if `$format_string` is safe to use. 

classify
--------

Classifies `$value` according to its top-level type.

    method classify ( )

compare
-------

Compares `$one` and `$two`.

The types of `$one` and `$two` are #gconstpointer only to allow use of this function with GTree, GPtrArray, etc. They must each be a GVariant.

Comparison is only defined for basic types (ie: booleans, numbers, strings). For booleans, `False` is less than `True`. Numbers are ordered in the usual way. Strings are in ASCII lexographical order.

It is a programmer error to attempt to compare container values or two values that have types that are not exactly equal. For example, you cannot compare a 32-bit signed integer with a 32-bit unsigned integer. Also note that this function is not particularly well-behaved when it comes to comparison of doubles; in particular, the handling of incomparable values (ie: NaN) is undefined.

If you only require an equality comparison, `.equal()` is more general.

    method compare ( gpointer $two --> Int )

  * $two; a GVariant instance of the same type.

Return value; negative value if a < b; zero if a = b; positive value if a > b.. 

dup-bytestring
--------------

Similar to `.get-bytestring()` except that instead of returning a constant string, the string is duplicated.

The return value must be freed using g_free().

    method dup-bytestring ( Array[gsize] $length --> Str )

  * $length; (transfer ownership: full) a pointer to a #gsize, to store the length (not including the nul terminator).

Return value; a newly allocated string. 

dup-bytestring-array
--------------------

Gets the contents of an array of array of bytes GVariant. This call makes a deep copy; the return result should be released with g_strfreev().

If `$length` is non-`Nil` then the number of elements in the result is stored there. In any case, the resulting array will be `Nil`-terminated.

For an empty array, `$length` will be set to 0 and a pointer to a `Nil` pointer will be returned.

    method dup-bytestring-array (
      Array[gsize] $length --> Array[Str]
    )

  * $length; (transfer ownership: full) the length of the result, or `Nil`.

Return value; an array of strings. 

dup-objv
--------

Gets the contents of an array of object paths GVariant. This call makes a deep copy; the return result should be released with g_strfreev().

If `$length` is non-`Nil` then the number of elements in the result is stored there. In any case, the resulting array will be `Nil`-terminated.

For an empty array, `$length` will be set to 0 and a pointer to a `Nil` pointer will be returned.

    method dup-objv ( Array[gsize] $length --> Array[Str] )

  * $length; (transfer ownership: full) the length of the result, or `Nil`.

Return value; an array of strings. 

dup-string
----------

Similar to `.get-string()` except that instead of returning a constant string, the string is duplicated.

The string will always be UTF-8 encoded.

The return value must be freed using g_free().

    method dup-string ( Array[gsize] $length --> Str )

  * $length; (transfer ownership: full) a pointer to a #gsize, to store the length.

Return value; a newly allocated string, UTF-8 encoded. 

dup-strv
--------

Gets the contents of an array of strings GVariant. This call makes a deep copy; the return result should be released with g_strfreev().

If `$length` is non-`Nil` then the number of elements in the result is stored there. In any case, the resulting array will be `Nil`-terminated.

For an empty array, `$length` will be set to 0 and a pointer to a `Nil` pointer will be returned.

    method dup-strv ( Array[gsize] $length --> Array[Str] )

  * $length; (transfer ownership: full) the length of the result, or `Nil`.

Return value; an array of strings. 

equal
-----

Checks if `$one` and `$two` have the same type and value.

The types of `$one` and `$two` are #gconstpointer only to allow use of this function with GHashTable. They must each be a GVariant.

    method equal ( gpointer $two --> Bool )

  * $two; a GVariant instance.

Return value; `True` if `$one` and `$two` are equal. 

get
---

Deconstructs a GVariant instance.

Think of this function as an analogue to scanf().

The arguments that are expected by this function are entirely determined by `$format_string`. `$format_string` also restricts the permissible types of `$value`. It is an error to give a value with an incompatible type. See the section on GVariant format strings. Please note that the syntax of the format string is very likely to be extended in the future. `$format_string` determines the C types that are used for unpacking the values and also determines if the values are copied or borrowed, see the section on GVariant format strings.

    method get ( Str $format-string, … )

  * $format-string; a GVariant format string.

  * …; arguments, as per `$format_string`. Note that each argument must be specified as a type followed by its value!

get-boolean
-----------

Returns the boolean value of `$value`.

It is an error to call this function with a `$value` of any type other than %G_VARIANT_TYPE_BOOLEAN.

    method get-boolean (--> Bool )

Return value; `True` or `False`. 

get-byte
--------

Returns the byte value of `$value`.

It is an error to call this function with a `$value` of any type other than %G_VARIANT_TYPE_BYTE.

    method get-byte (--> UInt )

Return value; a #guint8. 

get-bytestring
--------------

Returns the string value of a GVariant instance with an array-of-bytes type. The string has no particular encoding.

If the array does not end with a nul terminator character, the empty string is returned. For this reason, you can always trust that a non-`Nil` nul-terminated string will be returned by this function.

If the array contains a nul terminator character somewhere other than the last byte then the returned string is the string, up to the first such nul character.

`.get-fixed-array()` should be used instead if the array contains arbitrary data that could not be nul-terminated or could contain nul bytes.

It is an error to call this function with a `$value` that is not an array of bytes.

The return value remains valid as long as `$value` exists.

    method get-bytestring (--> Str )

Return value; the constant string. 

get-bytestring-array
--------------------

Gets the contents of an array of array of bytes GVariant. This call makes a shallow copy; the return result should be released with g_free(), but the individual strings must not be modified.

If `$length` is non-`Nil` then the number of elements in the result is stored there. In any case, the resulting array will be `Nil`-terminated.

For an empty array, `$length` will be set to 0 and a pointer to a `Nil` pointer will be returned.

    method get-bytestring-array (
      Array[gsize] $length --> Array[Str]
    )

  * $length; (transfer ownership: full) the length of the result, or `Nil`.

Return value; an array of constant strings. 

get-child
---------

Reads a child item out of a container GVariant instance and deconstructs it according to `$format_string`. This call is essentially a combination of `.get-child-value()` and `.get()`. `$format_string` determines the C types that are used for unpacking the values and also determines if the values are copied or borrowed, see the section on GVariant format strings.

    method get-child ( Int() $index, Str $format-string, … )

  * $index; the index of the child to deconstruct.

  * $format-string; a GVariant format string.

  * …; arguments, as per `$format_string`. Note that each argument must be specified as a type followed by its value!

get-child-value
---------------

Reads a child item out of a container GVariant instance. This includes variants, maybes, arrays, tuples and dictionary entries. It is an error to call this function on any other type of GVariant.

It is an error if `$index_` is greater than the number of child items in the container. See `.n-children()`.

The returned value is never floating. You should free it with `.unref()` when you're done with it.

Note that values borrowed from the returned child are not guaranteed to still be valid after the child is freed even if you still hold a reference to `$value`, if `$value` has not been serialized at the time this function is called. To avoid this, you can serialize `$value` by calling `.get-data()` and optionally ignoring the return value.

There may be implementation specific restrictions on deeply nested values, which would result in the unit tuple being returned as the child value, instead of further nested children. GVariant is guaranteed to handle nesting up to at least 64 levels.

This function is O(1).

    method get-child-value ( Int() $index --> CArray[N-Variant] )

  * $index; the index of the child to fetch.

Return value; the child at the specified index. 

get-data
--------

Returns a pointer to the serialized form of a GVariant instance. The returned data may not be in fully-normalised form if read from an untrusted source. The returned data must not be freed; it remains valid for as long as `$value` exists.

If `$value` is a fixed-sized value that was deserialized from a corrupted serialized container then `Nil` may be returned. In this case, the proper thing to do is typically to use the appropriate number of nul bytes in place of `$value`. If `$value` is not fixed-sized then `Nil` is never returned.

In the case that `$value` is already in serialized form, this function is O(1). If the value is not already in serialized form, serialization occurs implicitly and is approximately O(n) in the size of the result.

To deserialize the data returned by this function, in addition to the serialized data, you must know the type of the GVariant, and (if the machine might be different) the endianness of the machine that stored it. As a result, file formats or network messages that incorporate serialized GVariants must include this information either implicitly (for instance "the file always contains a %G_VARIANT_TYPE_VARIANT and it is always in little-endian order") or explicitly (by storing the type and/or endianness in addition to the serialized data).

    method get-data (--> gpointer )

Return value; the serialized form of `$value`, or `Nil`. 

get-data-as-bytes
-----------------

Returns a pointer to the serialized form of a GVariant instance. The semantics of this function are exactly the same as `.get-data()`, except that the returned GBytes holds a reference to the variant data.

    method get-data-as-bytes (--> CArray[N-Bytes]  )

Return value; A new GBytes representing the variant data. 

get-double
----------

Returns the double precision floating point value of `$value`.

It is an error to call this function with a `$value` of any type other than %G_VARIANT_TYPE_DOUBLE.

    method get-double (--> Num )

Return value; a #gdouble. 

get-handle
----------

Returns the 32-bit signed integer value of `$value`.

It is an error to call this function with a `$value` of any type other than %G_VARIANT_TYPE_HANDLE.

By convention, handles are indexes into an array of file descriptors that are sent alongside a D-Bus message. If you're not interacting with D-Bus, you probably don't need them.

    method get-handle (--> Int )

Return value; a #gint32. 

get-int16
---------

Returns the 16-bit signed integer value of `$value`.

It is an error to call this function with a `$value` of any type other than %G_VARIANT_TYPE_INT16.

    method get-int16 (--> Int )

Return value; a #gint16. 

get-int32
---------

Returns the 32-bit signed integer value of `$value`.

It is an error to call this function with a `$value` of any type other than %G_VARIANT_TYPE_INT32.

    method get-int32 (--> Int )

Return value; a #gint32. 

get-int64
---------

Returns the 64-bit signed integer value of `$value`.

It is an error to call this function with a `$value` of any type other than %G_VARIANT_TYPE_INT64.

    method get-int64 (--> Int )

Return value; a #gint64. 

get-maybe
---------

Given a maybe-typed GVariant instance, extract its value. If the value is Nothing, then this function returns `Nil`.

    method get-maybe (--> CArray[N-Variant] )

Return value; the contents of `$value`, or `Nil`. 

get-normal-form
---------------

Gets a GVariant instance that has the same value as `$value` and is trusted to be in normal form.

If `$value` is already trusted to be in normal form then a new reference to `$value` is returned.

If `$value` is not already trusted, then it is scanned to check if it is in normal form. If it is found to be in normal form then it is marked as trusted and a new reference to it is returned.

If `$value` is found not to be in normal form then a new trusted GVariant is created with the same value as `$value`.

It makes sense to call this function if you've received GVariant data from untrusted sources and you want to ensure your serialized output is definitely in normal form.

If `$value` is already in normal form, a new reference will be returned (which will be floating if `$value` is floating). If it is not in normal form, the newly created GVariant will be returned with a single non-floating reference. Typically, `.take-ref()` should be called on the return value from this function to guarantee ownership of a single non-floating reference to it.

    method get-normal-form (--> CArray[N-Variant] )

Return value; a trusted GVariant. 

get-objv
--------

Gets the contents of an array of object paths GVariant. This call makes a shallow copy; the return result should be released with g_free(), but the individual strings must not be modified.

If `$length` is non-`Nil` then the number of elements in the result is stored there. In any case, the resulting array will be `Nil`-terminated.

For an empty array, `$length` will be set to 0 and a pointer to a `Nil` pointer will be returned.

    method get-objv ( Array[gsize] $length --> Array[Str] )

  * $length; (transfer ownership: full) the length of the result, or `Nil`.

Return value; an array of constant strings. 

get-size
--------

Determines the number of bytes that would be required to store `$value` with `.store()`.

If `$value` has a fixed-sized type then this function always returned that fixed size.

In the case that `$value` is already in serialized form or the size has already been calculated (ie: this function has been called before) then this function is O(1). Otherwise, the size is calculated, an operation which is approximately O(n) in the number of values involved.

    method get-size (--> Int )

Return value; the serialized size of `$value`. 

get-string
----------

Returns the string value of a GVariant instance with a string type. This includes the types %G_VARIANT_TYPE_STRING, %G_VARIANT_TYPE_OBJECT_PATH and %G_VARIANT_TYPE_SIGNATURE.

The string will always be UTF-8 encoded, will never be `Nil`, and will never contain nul bytes.

If `$length` is non-`Nil` then the length of the string (in bytes) is returned there. For trusted values, this information is already known. Untrusted values will be validated and, if valid, a strlen() will be performed. If invalid, a default value will be returned — for %G_VARIANT_TYPE_OBJECT_PATH, this is `"/"`, and for other types it is the empty string.

It is an error to call this function with a `$value` of any type other than those three.

The return value remains valid as long as `$value` exists.

    method get-string ( Array[gsize] $length --> Str )

  * $length; (transfer ownership: full) a pointer to a #gsize, to store the length.

Return value; the constant string, UTF-8 encoded. 

get-strv
--------

Gets the contents of an array of strings GVariant. This call makes a shallow copy; the return result should be released with g_free(), but the individual strings must not be modified.

If `$length` is non-`Nil` then the number of elements in the result is stored there. In any case, the resulting array will be `Nil`-terminated.

For an empty array, `$length` will be set to 0 and a pointer to a `Nil` pointer will be returned.

    method get-strv ( Array[gsize] $length --> Array[Str] )

  * $length; (transfer ownership: full) the length of the result, or `Nil`.

Return value; an array of constant strings. 

get-type
--------

Determines the type of `$value`.

The return value is valid for the lifetime of `$value` and must not be freed.

    method get-type (--> CArray[N-VariantType] )

Return value; a GVariantType. 

get-type-string
---------------

Returns the type string of `$value`. Unlike the result of calling `.type-peek-string()`, this string is nul-terminated. This string belongs to GVariant and must not be freed.

    method get-type-string (--> Str )

Return value; the type string for the type of `$value`. 

get-uint16
----------

Returns the 16-bit unsigned integer value of `$value`.

It is an error to call this function with a `$value` of any type other than %G_VARIANT_TYPE_UINT16.

    method get-uint16 (--> UInt )

Return value; a #guint16. 

get-uint32
----------

Returns the 32-bit unsigned integer value of `$value`.

It is an error to call this function with a `$value` of any type other than %G_VARIANT_TYPE_UINT32.

    method get-uint32 (--> UInt )

Return value; a #guint32. 

get-uint64
----------

Returns the 64-bit unsigned integer value of `$value`.

It is an error to call this function with a `$value` of any type other than %G_VARIANT_TYPE_UINT64.

    method get-uint64 (--> UInt )

Return value; a #guint64. 

get-va
------

This function is intended to be used by libraries based on GVariant that want to provide `.get()`-like functionality to their users.

The API is more general than `.get()` to allow a wider range of possible uses. `$format_string` must still point to a valid format string, but it only need to be nul-terminated if `$endptr` is `Nil`. If `$endptr` is non-`Nil` then it is updated to point to the first character past the end of the format string. `$app` is a pointer to a #va_list. The arguments, according to `$format_string`, are collected from this #va_list and the list is left pointing to the argument following the last.

These two generalisations allow mixing of multiple calls to `.new-va()` and `.get-va()` within a single actual varargs call by the user. `$format_string` determines the C types that are used for unpacking the values and also determines if the values are copied or borrowed, see the section on GVariant format strings.

    method get-va ( Str $format-string, Array[Str] $endptr, … )

  * $format-string; a string that is prefixed with a format string.

  * $endptr; location to store the end pointer, or `Nil`.

  * app; a pointer to a #va_list. Note that each argument must be specified as a type followed by its value!

get-variant
-----------

Unboxes `$value`. The result is the GVariant instance that was contained in `$value`.

    method get-variant (--> CArray[N-Variant] )

Return value; the item contained in the variant. 

hash
----

Generates a hash value for a GVariant instance.

The output of this function is guaranteed to be the same for a given value only per-process. It may change between different processor architectures or even different versions of GLib. Do not use this function as a basis for building protocols or file formats.

The type of `$value` is #gconstpointer only to allow use of this function with GHashTable. `$value` must be a GVariant.

    method hash (--> UInt )

Return value; a hash value corresponding to `$value`. 

is-container
------------

Checks if `$value` is a container.

    method is-container (--> Bool )

Return value; `True` if `$value` is a container. 

is-floating
-----------

Checks whether `$value` has a floating reference count.

This function should only ever be used to assert that a given variant is or is not floating, or for debug purposes. To acquire a reference to a variant that might be floating, always use `.ref-sink()` or `.take-ref()`.

See `.ref-sink()` for more information about floating reference counts.

    method is-floating (--> Bool )

Return value; whether `$value` is floating. 

is-normal-form
--------------

Checks if `$value` is in normal form.

The main reason to do this is to detect if a given chunk of serialized data is in normal form: load the data into a GVariant using `.new-from-data()` and then use this function to check.

If `$value` is found to be in normal form then it will be marked as being trusted. If the value was already marked as being trusted then this function will immediately return `True`.

There may be implementation specific restrictions on deeply nested values. GVariant is guaranteed to handle nesting up to at least 64 levels.

    method is-normal-form (--> Bool )

Return value; `True` if `$value` is in normal form. 

is-of-type
----------

Checks if a value has a type matching the provided type.

    method is-of-type ( CArray[N-VariantType] $type --> Bool )

  * $type; a GVariantType.

Return value; `True` if the type of `$value` matches `$type`. 

iter-new
--------

Creates a heap-allocated GVariantIter for iterating over the items in `$value`.

Use `.iter-free()` to free the return value when you no longer need it.

A reference is taken to `$value` and will be released only when `.iter-free()` is called.

    method iter-new (--> CArray[N-VariantIter]  )

Return value; a new heap-allocated GVariantIter. 

lookup
------

Looks up a value in a dictionary GVariant.

This function is a wrapper around `.lookup-value()` and `.get()`. In the case that `Nil` would have been returned, this function returns `False`. Otherwise, it unpacks the returned value and returns `True`. `$format_string` determines the C types that are used for unpacking the values and also determines if the values are copied or borrowed, see the section on GVariant format strings.

This function is currently implemented with a linear scan. If you plan to do many lookups then GVariantDict may be more efficient.

    method lookup ( Str $key, Str $format-string, … --> Bool )

  * $key; the key to look up in the dictionary.

  * $format-string; a GVariant format string.

  * …; the arguments to unpack the value into. Note that each argument must be specified as a type followed by its value!

Return value; `True` if a value was unpacked. 

lookup-value
------------

Looks up a value in a dictionary GVariant.

This function works with dictionaries of the type a{s*} (and equally well with type a{o*}, but we only further discuss the string case for sake of clarity).

In the event that `$dictionary` has the type a{sv}, the `$expected_type` string specifies what type of value is expected to be inside of the variant. If the value inside the variant has a different type then `Nil` is returned. In the event that `$dictionary` has a value type other than v then `$expected_type` must directly match the value type and it is used to unpack the value directly or an error occurs.

In either case, if `$key` is not found in `$dictionary`, `Nil` is returned.

If the key is found and the value has the correct type, it is returned. If `$expected_type` was specified then any non-`Nil` return value will have this type.

This function is currently implemented with a linear scan. If you plan to do many lookups then GVariantDict may be more efficient.

    method lookup-value (
      Str $key, N-VariantType $expected-type
      --> N-Variant
    )

  * $key; the key to look up in the dictionary.

  * $expected-type; a GVariantType, or `Nil`.

Return value; the value of the dictionary key, or `Nil`. 

n-children
----------

Determines the number of children in a container GVariant instance. This includes variants, maybes, arrays, tuples and dictionary entries. It is an error to call this function on any other type of GVariant.

For variants, the return value is always 1. For values with maybe types, it is always zero or one. For arrays, it is the length of the array. For tuples it is the number of tuple items (which depends only on the type). For dictionary entries, it is always 2

This function is O(1).

    method n-children (--> Int )

Return value; the number of children in the container. 

print
-----

Pretty-prints `$value` in the format understood by `.parse()`.

The format is described here.

If `$type_annotate` is `True`, then type information is included in the output.

    method print ( Bool() $type-annotate --> Str )

  * $type-annotate; `True` if type information should be included in the output.

Return value; a newly-allocated string holding the result.. 

ref
---

Increases the reference count of `$value`.

    method ref (--> CArray[N-Variant] )

Return value; the same `$value`. 

ref-sink
--------

GVariant uses a floating reference count system. All functions with names starting with `g_variant_new_` return floating references.

Calling `.ref-sink()` on a GVariant with a floating reference will convert the floating reference into a full reference. Calling `.ref-sink()` on a non-floating GVariant results in an additional normal reference being added.

In other words, if the `$value` is floating, then this call "assumes ownership" of the floating reference, converting it to a normal reference. If the `$value` is not floating, then this call adds a new normal reference increasing the reference count by one.

All calls that result in a GVariant instance being inserted into a container will call `.ref-sink()` on the instance. This means that if the value was just created (and has only its floating reference) then the container will assume sole ownership of the value at that point and the caller will not need to unreference it. This makes certain common styles of programming much easier while still maintaining normal refcounting semantics in situations where values are not floating.

    method ref-sink (--> CArray[N-Variant] )

Return value; the same `$value`. 

store
-----

Stores the serialized form of `$value` at `$data`. `$data` should be large enough. See `.get-size()`.

The stored data is in machine native byte order but may not be in fully-normalised form if read from an untrusted source. See `.get-normal-form()` for a solution.

As with `.get-data()`, to be able to deserialize the serialized variant successfully, its type and (if the destination machine might be different) its endianness must also be available.

This function is approximately O(n) in the size of `$data`.

    method store ( gpointer $data )

  * $data; the location to store the serialized data at.

take-ref
--------

If `$value` is floating, sink it. Otherwise, do nothing.

Typically you want to use `.ref-sink()` in order to automatically do the correct thing with respect to floating or non-floating references, but there is one specific scenario where this function is helpful.

The situation where this function is helpful is when creating an API that allows the user to provide a callback function that returns a GVariant. We certainly want to allow the user the flexibility to return a non-floating reference from this callback (for the case where the value that is being returned already exists).

At the same time, the style of the GVariant API makes it likely that for newly-created GVariant instances, the user can be saved some typing if they are allowed to return a GVariant with a floating reference.

Using this function on the return value of the user's callback allows the user to do whichever is more convenient for them. The caller will always receives exactly one full reference to the value: either the one that was returned in the first place, or a floating reference that has been converted to a full reference.

This function has an odd interaction when combined with `.ref-sink()` running at the same time in another thread on the same GVariant instance. If `.ref-sink()` runs first then the result will be that the floating reference is converted to a hard reference. If `.take-ref()` runs first then the result will be that the floating reference is converted to a hard reference and an additional reference on top of that one is added. It is best to avoid this situation.

    method take-ref (--> CArray[N-Variant] )

Return value; the same `$value`. 

unref
-----

Decreases the reference count of `$value`. When its reference count drops to 0, the memory used by the variant is freed.

    method unref ( )

Functions
=========

is-object-path
--------------

Determines if a given string is a valid D-Bus object path. You should ensure that a string is a valid D-Bus object path before passing it to `.new-object-path()`.

A valid object path starts with `/` followed by zero or more sequences of characters separated by `/` characters. Each sequence must contain only the characters `[A-Z][a-z][0-9]_`. No sequence (including the one following the final `/` character) may be empty.

    method is-object-path ( Str $string --> Bool )

  * $string; a normal C nul-terminated string.

Return value; `True` if `$string` is a D-Bus object path. 

is-signature
------------

Determines if a given string is a valid D-Bus type signature. You should ensure that a string is a valid D-Bus type signature before passing it to `.new-signature()`.

D-Bus type signatures consist of zero or more definite GVariantType strings in sequence.

    method is-signature ( Str $string --> Bool )

  * $string; a normal C nul-terminated string.

Return value; `True` if `$string` is a D-Bus type signature. 

parse
-----

Parses a GVariant from a text representation.

A single GVariant is parsed from the content of `$text`.

The format is described here.

The memory at `$limit` will never be accessed and the parser behaves as if the character at `$limit` is the nul terminator. This has the effect of bounding `$text`.

If `$endptr` is non-`Nil` then `$text` is permitted to contain data following the value that this function parses and `$endptr` will be updated to point to the first character past the end of the text parsed by this function. If `$endptr` is `Nil` and there is extra data then an error is returned.

If `$type` is non-`Nil` then the value will be parsed to have that type. This may result in additional parse errors (in the case that the parsed value doesn't fit the type) but may also result in fewer errors (in the case that the type would have been ambiguous, such as with empty arrays).

In the event that the parsing is successful, the resulting GVariant is returned. It is never floating, and must be freed with `.unref()`.

In case of any error, `Nil` will be returned. If `$error` is non-`Nil` then it will be set to reflect the error that occurred.

Officially, the language understood by the parser is "any string produced by `.print()`".

There may be implementation specific restrictions on deeply nested values, which would result in a %G_VARIANT_PARSE_ERROR_RECURSION error. GVariant is guaranteed to handle nesting up to at least 64 levels.

Example;

    my Gnome::Glib::VariantType $varianttype .= new-varianttype('u');
    my Gnome::Glib::Variant $v .= new(
      :native-object(.parse( $varianttype, '10', Str, Pointer))
    );
    note $v.get-uint32;               # 10

    method parse (
      CArray[N-VariantType] $type, Str $text,
      Pointer[Str] $limit, Pointer[Str] $endptr
      --> N-Variant
      )

  * $type; a GVariantType, or `Nil`.

  * $text; a string containing a GVariant in text form.

  * $limit; a pointer to the end of `$text`, or `Nil`.

  * $endptr; a location to store the end pointer, or `Nil`.

Return value; a non-floating reference to a GVariant, or `Nil`. 

parse-error-print-context
-------------------------

Pretty-prints a message showing the context of a GVariant parse error within the string for which parsing was attempted.

The resulting string is suitable for output to the console or other monospace media where newlines are treated in the usual way.

The message will typically look something like one of the following:

    unterminated string constant:
    (1, 2, 3, 'abc
    ^^^^

or

    unable to find a common type:
    [1, 2, 3, 'str']
    ^ ^^^^^

The format of the message may change in a future version. `$error` must have come from a failed attempt to `.parse()` and `$source_str` must be exactly the same string that caused the error. If `$source_str` was not nul-terminated when you passed it to `.parse()` then you must add nul termination before using this function.

    method parse-error-print-context (
      CArray[N-Error] $error, Str $source-str --> Str
    )

  * $error; a GError from the `GVariantParseError enumeration` domain.

  * $source-str; the string that was given to the parser.

Return value; the printed message. 

parse-error-quark
-----------------

No documentation of method.

    method parse-error-quark (--> UInt )

Return value; No documentation about its value and use. 

