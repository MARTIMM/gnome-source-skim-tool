Project Description
-------------------

  * **Distribution:** Gnome::GObject

  * **Project description:** Modules for package Gnome::GObject:api<2>. The language binding to GNOME's lower level object library

  * **Project version:** 0.1.2

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

![](images/object.png)

Description
===========

The base object type.

Class initialization
====================

new
---

### :native-object

Create an object using a native object from elsewhere. See also **Gnome::N::TopLevelSupportClass**.

    multi method new ( N-Object :$native-object! )

new-object
----------

Creates a new instance of a GObject subtype and sets its properties.

Construction parameters (see %G_PARAM_CONSTRUCT, %G_PARAM_CONSTRUCT_ONLY) which are not explicitly specified are set to their default values. Any private data for the object is guaranteed to be initialized with zeros, as per g_type_create_instance().

Note that in C, small integer types in variable argument lists are promoted up to `gint` or `guint` as appropriate, and read back accordingly. `gint` is 32 bits on every platform on which GLib is currently supported. This means that you can use C expressions of type `gint` with `.new-object()` and properties of type `gint` or `guint` or smaller. Specifically, you can use integer literals with these property types.

When using property types of `gint64` or `guint64`, you must ensure that the value that you provide is 64 bit. This means that you should use a cast or make use of the %G_GINT64_CONSTANT or %G_GUINT64_CONSTANT macros.

Similarly, `gfloat` is promoted to `gdouble`, so you must ensure that the value you provide is a `gdouble`, even for a property of type `gfloat`.

Since GLib 2.72, all GObjects are guaranteed to be aligned to at least the alignment of the largest basic GLib type (typically this is `guint64` or `gdouble`). If you need larger alignment for an element in a GObject, you should allocate it on the heap (aligned), or arrange for your GObject to be appropriately padded.

    method new-object ( GType $object-type, Str $first-property-name, … --> Gnome::GObject::Object )

  * $object-type; the type id of the GObject subtype to instantiate.

  * $first-property-name; the name of the first property.

  * …; the value of the first property, followed optionally by more name/value pairs, followed by `Nil`. Note that each argument must be specified as a type followed by its value!

new-valist
----------

Creates a new instance of a GObject subtype and sets its properties.

Construction parameters (see %G_PARAM_CONSTRUCT, %G_PARAM_CONSTRUCT_ONLY) which are not explicitly specified are set to their default values.

    method new-valist ( GType $object-type, Str $first-property-name, … --> Gnome::GObject::Object )

  * $object-type; the type id of the GObject subtype to instantiate.

  * $first-property-name; the name of the first property.

  * var-args; the value of the first property, followed optionally by more name/value pairs, followed by `Nil`. Note that each argument must be specified as a type followed by its value!

new-with-properties
-------------------

Creates a new instance of a GObject subtype and sets its properties using the provided arrays. Both arrays must have exactly `$n_properties` elements, and the names and values correspond by index.

Construction parameters (see %G_PARAM_CONSTRUCT, %G_PARAM_CONSTRUCT_ONLY) which are not explicitly specified are set to their default values.

    method new-with-properties ( GType $object-type, UInt() $n-properties, Array[Str] $names, CArray[N-Value] $values --> Gnome::GObject::Object )

  * $object-type; the object type to instantiate.

  * $n-properties; the number of properties.

  * $names; the names of each property to be set.

  * $values; the values of each property to be set.

Methods
=======

add-toggle-ref
--------------

Increases the reference count of the object by one and sets a callback to be called when all other references to the object are dropped, or when this is already the last reference to the object and another reference is established.

This functionality is intended for binding `$object` to a proxy object managed by another memory manager. This is done with two paired references: the strong reference added by `.add-toggle-ref()` and a reverse reference to the proxy object which is either a strong reference or weak reference.

The setup is that when there are no other references to `$object`, only a weak reference is held in the reverse direction from `$object` to the proxy object, but when there are other references held to `$object`, a strong reference is held. The `$notify` callback is called when the reference from `$object` to the proxy object should be "toggled" from strong to weak ( `$is_last_ref` true) or weak to strong ( `$is_last_ref` false).

Since a (normal) reference must be held to the object before calling `.add-toggle-ref()`, the initial state of the reverse link is always strong.

Multiple toggle references may be added to the same gobject, however if there are multiple toggle references to an object, none of them will ever be notified until all but one are removed. For this reason, you should only ever use a toggle reference if there is important state in the proxy object.

    method add-toggle-ref ( &notify, gpointer $data )

  * &notify; a function to call when this reference is the last reference to the object, or is no longer the last reference.. Tthe function must be specified with following signature; `:( gpointer $data, N-Object $object, gboolean $is-last-ref )`.

  * $data; data to pass to `$notify`.

add-weak-pointer
----------------

Adds a weak reference from weak_pointer to `$object` to indicate that the pointer located at `$weak_pointer_location` is only valid during the lifetime of `$object`. When the `$object` is finalized, `$weak_pointer` will be set to `Nil`.

Note that as with `.weak-ref()`, the weak references created by this method are not thread-safe: they cannot safely be used in one thread if the object's last `.unref()` might happen in another thread. Use GWeakRef if thread-safety is required.

    method add-weak-pointer ( Array $weak-pointer-location )

  * $weak-pointer-location; (transfer ownership: full) The memory address of a pointer..

bind-property
-------------

Creates a binding between `$source_property` on `$source` and `$target_property` on `$target`.

Whenever the `$source_property` is changed the `$target_property` is updated using the same value. For instance:

Will result in the "sensitive" property of the widget GObject instance to be updated with the same value of the "active" property of the action GObject instance.

If `$flags` contains %G_BINDING_BIDIRECTIONAL then the binding will be mutual: if `$target_property` on `$target` changes then the `$source_property` on `$source` will be updated as well.

The binding will automatically be removed when either the `$source` or the `$target` instances are finalized. To remove the binding without affecting the `$source` and the `$target` you can just call `.unref()` on the returned GBinding instance.

Removing the binding by calling `.unref()` on it must only be done if the binding, `$source` and `$target` are only used from a single thread and it is clear that both `$source` and `$target` outlive the binding. Especially it is not safe to rely on this if the binding, `$source` or `$target` can be finalized from different threads. Keep another reference to the binding and use g_binding_unbind() instead to be on the safe side.

A GObject can have multiple bindings.

    method bind-property ( Str $source-property, gpointer $target, Str $target-property, UInt $flags --> N-Object )

  * $source-property; the property on `$source` to bind.

  * $target; the target GObject.

  * $target-property; the property on `$target` to bind.

  * $flags; flags to pass to GBinding. A bitmap.

Return value; the GBinding instance representing the binding between the two GObject instances. The binding is released whenever the GBinding reference count reaches zero.. 

bind-property-full
------------------

Complete version of `.bind-property()`.

Creates a binding between `$source_property` on `$source` and `$target_property` on `$target`, allowing you to set the transformation functions to be used by the binding.

If `$flags` contains %G_BINDING_BIDIRECTIONAL then the binding will be mutual: if `$target_property` on `$target` changes then the `$source_property` on `$source` will be updated as well. The `$transform_from` function is only used in case of bidirectional bindings, otherwise it will be ignored

The binding will automatically be removed when either the `$source` or the `$target` instances are finalized. This will release the reference that is being held on the GBinding instance; if you want to hold on to the GBinding instance, you will need to hold a reference to it.

To remove the binding, call g_binding_unbind().

A GObject can have multiple bindings.

The same `$user_data` parameter will be used for both `$transform_to` and `$transform_from` transformation functions; the `$notify` function will be called once, when the binding is removed. If you need different data for each transformation function, please use `.bind-property-with-closures()` instead.

    method bind-property-full ( Str $source-property, gpointer $target, Str $target-property, UInt $flags, &transform-to, &transform-from, gpointer $user-data, … --> N-Object )

  * $source-property; the property on `$source` to bind.

  * $target; the target GObject.

  * $target-property; the property on `$target` to bind.

  * $flags; flags to pass to GBinding. A bitmap.

  * &transform-to; the transformation function from the `$source` to the `$target`, or `Nil` to use the default. Tthe function must be specified with following signature; `:( N-Object $binding, N-Value $from-value, N-Value $to-value, gpointer $user-data --` gboolean )>.

  * &transform-from; the transformation function from the `$target` to the `$source`, or `Nil` to use the default. Tthe function must be specified with following signature; `:( N-Object $binding, N-Value $from-value, N-Value $to-value, gpointer $user-data --` gboolean )>.

  * $user-data; custom data to be passed to the transformation functions, or `Nil`.

  * notify; a function to call when disposing the binding, to free resources used by the transformation functions, or `Nil` if not required. Note that each argument must be specified as a type followed by its value!

Return value; the GBinding instance representing the binding between the two GObject instances. The binding is released whenever the GBinding reference count reaches zero.. 

bind-property-with-closures
---------------------------

Creates a binding between `$source_property` on `$source` and `$target_property` on `$target`, allowing you to set the transformation functions to be used by the binding.

This function is the language bindings friendly version of `.bind-property-full()`, using GClosures instead of function pointers.

    method bind-property-with-closures ( Str $source-property, gpointer $target, Str $target-property, UInt $flags, CArray[N-Closure]  $transform-to, CArray[N-Closure]  $transform-from --> N-Object )

  * $source-property; the property on `$source` to bind.

  * $target; the target GObject.

  * $target-property; the property on `$target` to bind.

  * $flags; flags to pass to GBinding. A bitmap.

  * $transform-to; a GClosure wrapping the transformation function from the `$source` to the `$target`, or `Nil` to use the default.

  * $transform-from; a GClosure wrapping the transformation function from the `$target` to the `$source`, or `Nil` to use the default.

Return value; the GBinding instance representing the binding between the two GObject instances. The binding is released whenever the GBinding reference count reaches zero.. 

connect
-------

A convenience function to connect multiple signals at once.

The signal specs expected by this function have the form "*signal_name defined in modifier*", where modifier can be one of the following: - signal: equivalent to g_signal_connect_data (..., NULL, 0) - object-signal, object_signal: equivalent to g_signal_connect_object (..., 0) - swapped-signal, swapped_signal: equivalent to g_signal_connect_data (..., NULL, G_CONNECT_SWAPPED) - swapped_object_signal, swapped-object-signal: equivalent to g_signal_connect_object (..., G_CONNECT_SWAPPED) - signal_after, signal-after: equivalent to g_signal_connect_data (..., NULL, G_CONNECT_AFTER) - object_signal_after, object-signal-after: equivalent to g_signal_connect_object (..., G_CONNECT_AFTER) - swapped_signal_after, swapped-signal-after: equivalent to g_signal_connect_data (..., NULL, G_CONNECT_SWAPPED | G_CONNECT_AFTER) - swapped_object_signal_after, swapped-object-signal-after: equivalent to g_signal_connect_object (..., G_CONNECT_SWAPPED | G_CONNECT_AFTER)

    method connect ( Str $signal-spec, … --> gpointer )

  * $signal-spec; the spec for the first signal.

  * …; GCallback for the first signal, followed by data for the first signal, followed optionally by more signal spec/callback/data triples, followed by `Nil`. Note that each argument must be specified as a type followed by its value!

Return value; `$object`. 

disconnect
----------

A convenience function to disconnect multiple signals at once.

The signal specs expected by this function have the form "any_signal", which means to disconnect any signal with matching callback and data, or "*signal_name defined in any_signal*", which only disconnects the signal named "signal_name".

    method disconnect ( Str $signal-spec, … )

  * $signal-spec; the spec for the first signal.

  * …; GCallback for the first signal, followed by data for the first signal, followed optionally by more signal spec/callback/data triples, followed by `Nil`. Note that each argument must be specified as a type followed by its value!

dup-data
--------

This is a variant of `.get-data()` which returns a 'duplicate' of the value. `$dup_func` defines the meaning of 'duplicate' in this context, it could e.g. take a reference on a ref-counted object.

If the `$key` is not set on the object then `$dup_func` will be called with a `Nil` argument.

Note that `$dup_func` is called while user data of `$object` is locked.

This function can be useful to avoid races when multiple threads are using object data on the same key on the same object.

    method dup-data ( Str $key, …, gpointer $user-data --> gpointer )

  * $key; a string, naming the user data pointer.

  * dup-func; function to dup the value. Note that each argument must be specified as a type followed by its value!

  * $user-data; passed as user_data to `$dup_func`.

Return value; the result of calling `$dup_func` on the value associated with `$key` on `$object`, or `Nil` if not set. If `$dup_func` is `Nil`, the value is returned unmodified.. 

dup-qdata
---------

This is a variant of `.get-qdata()` which returns a 'duplicate' of the value. `$dup_func` defines the meaning of 'duplicate' in this context, it could e.g. take a reference on a ref-counted object.

If the `$quark` is not set on the object then `$dup_func` will be called with a `Nil` argument.

Note that `$dup_func` is called while user data of `$object` is locked.

This function can be useful to avoid races when multiple threads are using object data on the same key on the same object.

    method dup-qdata ( UInt $quark, …, gpointer $user-data --> gpointer )

  * $quark; a GQuark, naming the user data pointer.

  * dup-func; function to dup the value. Note that each argument must be specified as a type followed by its value!

  * $user-data; passed as user_data to `$dup_func`.

Return value; the result of calling `$dup_func` on the value associated with `$quark` on `$object`, or `Nil` if not set. If `$dup_func` is `Nil`, the value is returned unmodified.. 

force-floating
--------------

This function is intended for GObject implementations to re-enforce a floating object reference. Doing this is seldom required: all GInitiallyUnowneds are created with a floating reference which usually just needs to be sunken by calling `.ref-sink()`.

    method force-floating ( )

freeze-notify
-------------

Increases the freeze count on `$object`. If the freeze count is non-zero, the emission of "notify" signals on `$object` is stopped. The signals are queued until the freeze count is decreased to zero. Duplicate notifications are squashed so that at most one *notify* signal is emitted for each property modified while the object is frozen.

This is necessary for accessors that modify multiple properties to prevent premature notification while the object is still being modified.

    method freeze-notify ( )

get
---

Gets properties of an object.

In general, a copy is made of the property contents and the caller is responsible for freeing the memory in the appropriate manner for the type, for instance by calling g_free() or `.unref()`.

Here is an example of using `.get()` to get the contents of three properties: an integer, a string and an object:

    method get ( Str $first-property-name, … )

  * $first-property-name; name of the first property to get.

  * …; return location for the first property, followed optionally by more name/return location pairs, followed by `Nil`. Note that each argument must be specified as a type followed by its value!

get-data
--------

Gets a named field from the objects table of associations (see `.set-data()`).

    method get-data ( Str $key --> gpointer )

  * $key; name of the key for that association.

Return value; the data if found, or `Nil` if no such data exists.. 

get-property
------------

Gets a property of an object.

The `$value` can be:

    - an empty GValue initialized by %G_VALUE_INIT, which will be
    automatically initialized with the expected type of the property
    (since GLib 2.60)
    - a GValue initialized with the expected type of the property
    - a GValue initialized with a type to which the expected type
    of the property can be transformed

In general, a copy is made of the property contents and the caller is responsible for freeing the memory by calling g_value_unset().

Note that `.get-property()` is really intended for language bindings, `.get()` is much more convenient for C programming.

    method get-property ( Str $property-name, CArray[N-Value] $value )

  * $property-name; the name of the property to get.

  * $value; return location for the property value.

get-qdata
---------

This function gets back user data pointers stored via `.set-qdata()`.

    method get-qdata ( UInt $quark --> gpointer )

  * $quark; A GQuark, naming the user data pointer.

Return value; The user data pointer set, or `Nil`. 

get-valist
----------

Gets properties of an object.

In general, a copy is made of the property contents and the caller is responsible for freeing the memory in the appropriate manner for the type, for instance by calling g_free() or `.unref()`.

See `.get()`.

    method get-valist ( Str $first-property-name, … )

  * $first-property-name; name of the first property to get.

  * var-args; return location for the first property, followed optionally by more name/return location pairs, followed by `Nil`. Note that each argument must be specified as a type followed by its value!

getv
----

Gets `$n_properties` properties for an `$object`. Obtained properties will be set to `$values`. All properties must be valid. Warnings will be emitted and undefined behaviour may result if invalid properties are passed in.

    method getv ( UInt() $n-properties, Array[Str] $names, CArray[N-Value] $values )

  * $n-properties; the number of properties.

  * $names; the names of each property to get.

  * $values; the values of each property to get.

is-floating
-----------

Checks whether `$object` has a floating reference.

    method is-floating (--> Bool )

Return value; `True` if `$object` has a floating reference. 

notify
------

Emits a "notify" signal for the property `$property_name` on `$object`.

When possible, eg. when signaling a property change from within the class that registered the property, you should use `.notify-by-pspec()` instead.

Note that emission of the notify signal may be blocked with `.freeze-notify()`. In this case, the signal emissions are queued and will be emitted (in reverse order) when `.thaw-notify()` is called.

    method notify ( Str $property-name )

  * $property-name; the name of a property installed on the class of `$object`..

notify-by-pspec
---------------

Emits a "notify" signal for the property specified by `$pspec` on `$object`.

This function omits the property name lookup, hence it is faster than `.notify()`.

One way to avoid using `.notify()` from within the class that registered the properties, and using `.notify-by-pspec()` instead, is to store the GParamSpec used with `.class-install-property()` inside a static array, e.g.:

and then notify a change on the "foo" property with:

    method notify-by-pspec ( N-Object() $pspec )

  * $pspec; the GParamSpec of a property installed on the class of `$object`..

ref
---

Increases the reference count of `$object`.

Since GLib 2.56, if `GLIB_VERSION_MAX_ALLOWED` is 2.56 or greater, the type of `$object` will be propagated to the return type (using the GCC typeof() extension), so any casting the caller needs to do on the return type must be explicit.

    method ref (--> gpointer )

Return value; the same `$object`. 

ref-sink
--------

Increase the reference count of `$object`, and possibly remove the floating reference, if `$object` has a floating reference.

In other words, if the object is floating, then this call "assumes ownership" of the floating reference, converting it to a normal reference by clearing the floating flag while leaving the reference count unchanged. If the object is not floating, then this call adds a new normal reference increasing the reference count by one.

Since GLib 2.56, the type of `$object` will be propagated to the return type under the same conditions as for `.ref()`.

    method ref-sink (--> gpointer )

Return value; `$object`. 

remove-toggle-ref
-----------------

Removes a reference added with `.add-toggle-ref()`. The reference count of the object is decreased by one.

    method remove-toggle-ref ( &notify, gpointer $data )

  * &notify; a function to call when this reference is the last reference to the object, or is no longer the last reference.. Tthe function must be specified with following signature; `:( gpointer $data, N-Object $object, gboolean $is-last-ref )`.

  * $data; data to pass to `$notify`, or `Nil` to match any toggle refs with the `$notify` argument..

remove-weak-pointer
-------------------

Removes a weak reference from `$object` that was previously added using `.add-weak-pointer()`. The `$weak_pointer_location` has to match the one used with `.add-weak-pointer()`.

    method remove-weak-pointer ( Array $weak-pointer-location )

  * $weak-pointer-location; (transfer ownership: full) The memory address of a pointer..

replace-data
------------

Compares the user data for the key `$key` on `$object` with `$oldval`, and if they are the same, replaces `$oldval` with `$newval`.

This is like a typical atomic compare-and-exchange operation, for user data on an object.

If the previous value was replaced then ownership of the old value ( `$oldval`) is passed to the caller, including the registered destroy notify for it (passed out in `$old_destroy`). It’s up to the caller to free this as needed, which may or may not include using `$old_destroy` as sometimes replacement should not destroy the object in the normal way.

See `.set-data()` for guidance on using a small, bounded set of values for `$key`.

    method replace-data ( Str $key, gpointer $oldval, gpointer $newval, …, … --> Bool )

  * $key; a string, naming the user data pointer.

  * $oldval; the old value to compare against.

  * $newval; the new value.

  * destroy; a destroy notify for the new value. Note that each argument must be specified as a type followed by its value!

  * old-destroy; destroy notify for the existing value. Note that each argument must be specified as a type followed by its value!

Return value; `True` if the existing value for `$key` was replaced by `$newval`, `False` otherwise.. 

replace-qdata
-------------

Compares the user data for the key `$quark` on `$object` with `$oldval`, and if they are the same, replaces `$oldval` with `$newval`.

This is like a typical atomic compare-and-exchange operation, for user data on an object.

If the previous value was replaced then ownership of the old value ( `$oldval`) is passed to the caller, including the registered destroy notify for it (passed out in `$old_destroy`). It’s up to the caller to free this as needed, which may or may not include using `$old_destroy` as sometimes replacement should not destroy the object in the normal way.

    method replace-qdata ( UInt $quark, gpointer $oldval, gpointer $newval, …, … --> Bool )

  * $quark; a GQuark, naming the user data pointer.

  * $oldval; the old value to compare against.

  * $newval; the new value.

  * destroy; a destroy notify for the new value. Note that each argument must be specified as a type followed by its value!

  * old-destroy; destroy notify for the existing value. Note that each argument must be specified as a type followed by its value!

Return value; `True` if the existing value for `$quark` was replaced by `$newval`, `False` otherwise.. 

run-dispose
-----------

Releases all references to other objects. This can be used to break reference cycles.

This function should only be called from object system implementations.

    method run-dispose ( )

set
---

Sets properties on an object.

The same caveats about passing integer literals as varargs apply as with `.new-object()`. In particular, any integer literals set as the values for properties of type `gint64` or `guint64` must be 64 bits wide, using the %G_GINT64_CONSTANT or %G_GUINT64_CONSTANT macros.

Note that the "notify" signals are queued and only emitted (in reverse order) after all properties have been set. See `.freeze-notify()`.

    method set ( Str $first-property-name, … )

  * $first-property-name; name of the first property to set.

  * …; value for the first property, followed optionally by more name/value pairs, followed by `Nil`. Note that each argument must be specified as a type followed by its value!

set-data
--------

Each object carries around a table of associations from strings to pointers. This function lets you set an association.

If the object already had an association with that name, the old association will be destroyed.

Internally, the `$key` is converted to a GQuark using g_quark_from_string(). This means a copy of `$key` is kept permanently (even after `$object` has been finalized) — so it is recommended to only use a small, bounded set of values for `$key` in your program, to avoid the GQuark storage growing unbounded.

    method set-data ( Str $key, gpointer $data )

  * $key; name of the key.

  * $data; data to associate with that key.

set-data-full
-------------

Like `.set-data()` except it adds notification for when the association is destroyed, either by setting it to a different value or when the object is destroyed.

Note that the `$destroy` callback is not called if `$data` is `Nil`.

    method set-data-full ( Str $key, gpointer $data, … )

  * $key; name of the key.

  * $data; data to associate with that key.

  * destroy; function to call when the association is destroyed. Note that each argument must be specified as a type followed by its value!

set-property
------------

Sets a property on an object.

    method set-property ( Str $property-name, CArray[N-Value] $value )

  * $property-name; the name of the property to set.

  * $value; the value.

set-qdata
---------

This sets an opaque, named pointer on an object. The name is specified through a GQuark (retrieved e.g. via g_quark_from_static_string()), and the pointer can be gotten back from the `$object` with `.get-qdata()` until the `$object` is finalized. Setting a previously set user data pointer, overrides (frees) the old pointer set, using `NULL` as pointer essentially removes the data stored.

    method set-qdata ( UInt $quark, gpointer $data )

  * $quark; A GQuark, naming the user data pointer.

  * $data; An opaque user data pointer.

set-qdata-full
--------------

This function works like `.set-qdata()`, but in addition, a void (*destroy) (gpointer) function may be specified which is called with `$data` as argument when the `$object` is finalized, or the data is being overwritten by a call to `.set-qdata()` with the same `$quark`.

    method set-qdata-full ( UInt $quark, gpointer $data, … )

  * $quark; A GQuark, naming the user data pointer.

  * $data; An opaque user data pointer.

  * destroy; Function to invoke with `$data` as argument, when `$data` needs to be freed. Note that each argument must be specified as a type followed by its value!

set-valist
----------

Sets properties on an object.

    method set-valist ( Str $first-property-name, … )

  * $first-property-name; name of the first property to set.

  * var-args; value for the first property, followed optionally by more name/value pairs, followed by `Nil`. Note that each argument must be specified as a type followed by its value!

setv
----

Sets `$n_properties` properties for an `$object`. Properties to be set will be taken from `$values`. All properties must be valid. Warnings will be emitted and undefined behaviour may result if invalid properties are passed in.

    method setv ( UInt() $n-properties, Array[Str] $names, CArray[N-Value] $values )

  * $n-properties; the number of properties.

  * $names; the names of each property to be set.

  * $values; the values of each property to be set.

steal-data
----------

Remove a specified datum from the object's data associations, without invoking the association's destroy handler.

    method steal-data ( Str $key --> gpointer )

  * $key; name of the key.

Return value; the data if found, or `Nil` if no such data exists.. 

steal-qdata
-----------

This function gets back user data pointers stored via `.set-qdata()` and removes the `$data` from object without invoking its destroy() function (if any was set). Usually, calling this function is only required to update user data pointers with a destroy notifier, for example:

Using `.get-qdata()` in the above example, instead of `.steal-qdata()` would have left the destroy function set, and thus the partial string list would have been freed upon `.set-qdata-full()`.

    method steal-qdata ( UInt $quark --> gpointer )

  * $quark; A GQuark, naming the user data pointer.

Return value; The user data pointer set, or `Nil`. 

take-ref
--------

If `$object` is floating, sink it. Otherwise, do nothing.

In other words, this function will convert a floating reference (if present) into a full reference.

Typically you want to use `.ref-sink()` in order to automatically do the correct thing with respect to floating or non-floating references, but there is one specific scenario where this function is helpful.

The situation where this function is helpful is when creating an API that allows the user to provide a callback function that returns a GObject. We certainly want to allow the user the flexibility to return a non-floating reference from this callback (for the case where the object that is being returned already exists).

At the same time, the API style of some popular GObject-based libraries (such as Gtk) make it likely that for newly-created GObject instances, the user can be saved some typing if they are allowed to return a floating reference.

Using this function on the return value of the user's callback allows the user to do whichever is more convenient for them. The caller will alway receives exactly one full reference to the value: either the one that was returned in the first place, or a floating reference that has been converted to a full reference.

This function has an odd interaction when combined with `.ref-sink()` running at the same time in another thread on the same GObject instance. If `.ref-sink()` runs first then the result will be that the floating reference is converted to a hard reference. If `.take-ref()` runs first then the result will be that the floating reference is converted to a hard reference and an additional reference on top of that one is added. It is best to avoid this situation.

    method take-ref (--> gpointer )

Return value; `$object`. 

thaw-notify
-----------

Reverts the effect of a previous call to `.freeze-notify()`. The freeze count is decreased on `$object` and when it reaches zero, queued "notify" signals are emitted.

Duplicate notifications for each property are squashed so that at most one *notify* signal is emitted for each property, in the reverse order in which they have been queued.

It is an error to call this function when the freeze count is zero.

    method thaw-notify ( )

unref
-----

Decreases the reference count of `$object`. When its reference count drops to 0, the object is finalized (i.e. its memory is freed).

If the pointer to the GObject may be reused in future (for example, if it is an instance variable of another object), it is recommended to clear the pointer to `Nil` rather than retain a dangling pointer to a potentially invalid GObject instance. Use g_clear_object() for this.

    method unref ( )

watch-closure
-------------

This function essentially limits the life time of the `$closure` to the life time of the object. That is, when the object is finalized, the `$closure` is invalidated by calling g_closure_invalidate() on it, in order to prevent invocations of the closure with a finalized (nonexisting) object. Also, `.ref()` and `.unref()` are added as marshal guards to the `$closure`, to ensure that an extra reference count is held on `$object` during invocation of the `$closure`. Usually, this function will be called on closures that use this `$object` as closure data.

    method watch-closure ( CArray[N-Closure]  $closure )

  * $closure; GClosure to watch.

weak-ref
--------

Adds a weak reference callback to an object. Weak references are used for notification when an object is disposed. They are called "weak references" because they allow you to safely hold a pointer to an object without calling `.ref()` (`.ref()` adds a strong reference, that is, forces the object to stay alive).

Note that the weak references created by this method are not thread-safe: they cannot safely be used in one thread if the object's last `.unref()` might happen in another thread. Use GWeakRef if thread-safety is required.

    method weak-ref ( &notify, gpointer $data )

  * &notify; callback to invoke before the object is freed. Tthe function must be specified with following signature; `:( gpointer $data, N-Object $where-the-object-was )`.

  * $data; extra data to pass to notify.

weak-unref
----------

Removes a weak reference callback to an object.

    method weak-unref ( &notify, gpointer $data )

  * &notify; callback to search for. Tthe function must be specified with following signature; `:( gpointer $data, N-Object $where-the-object-was )`.

  * $data; data to search for.

Functions
=========

compat-control
--------------

No documentation of method.

    method compat-control ( Int() $what, gpointer $data --> Int )

  * $what; .

  * $data; .

Return value; No documentation about its value and use. 

interface-find-property
-----------------------

Find the GParamSpec with the given name for an interface. Generally, the interface vtable passed in as `$g_iface` will be the default vtable from g_type_default_interface_ref(), or, if you know the interface has already been loaded, g_type_default_interface_peek().

    method interface-find-property ( gpointer $g-iface, Str $property-name --> N-Object )

  * $g-iface; any interface vtable for the interface, or the default vtable for the interface.

  * $property-name; name of a property to look up..

Return value; the GParamSpec for the property of the interface with the name `$property_name`, or `Nil` if no such property exists.. 

interface-install-property
--------------------------

Add a property to an interface; this is only useful for interfaces that are added to GObject-derived types. Adding a property to an interface forces all objects classes with that interface to have a compatible property. The compatible property could be a newly created GParamSpec, but normally `.class-override-property()` will be used so that the object class only needs to provide an implementation and inherits the property description, default value, bounds, and so forth from the interface property.

This function is meant to be called from the interface's default vtable initialization function (the `$class_init` member of GTypeInfo.) It must not be called after after `$class_init` has been called for any object types implementing this interface.

If `$pspec` is a floating reference, it will be consumed.

    method interface-install-property ( gpointer $g-iface, N-Object() $pspec )

  * $g-iface; any interface vtable for the interface, or the default vtable for the interface..

  * $pspec; the GParamSpec for the new property.

interface-list-properties
-------------------------

Lists the properties of an interface.Generally, the interface vtable passed in as `$g_iface` will be the default vtable from g_type_default_interface_ref(), or, if you know the interface has already been loaded, g_type_default_interface_peek().

    method interface-list-properties ( gpointer $g-iface, Array[Int] $n-properties-p --> N-Object )

  * $g-iface; any interface vtable for the interface, or the default vtable for the interface.

  * $n-properties-p; (transfer ownership: full) location to store number of properties returned..

Return value; a pointer to an array of pointers to GParamSpec structures. The paramspecs are owned by GLib, but the array should be freed with g_free() when you are done with it.. 

Signals
=======

### notify

The notify signal is emitted on an object when one of its properties has its value set through `.set-property()`, `.set()`, et al.

Note that getting this signal doesn’t itself guarantee that the value of the property has actually changed. When it is emitted is determined by the derived GObject class. If the implementor did not create the property with %G_PARAM_EXPLICIT_NOTIFY, then any call to `.set-property()` results in *notify* being emitted, even if the new value is the same as the old. If they did pass %G_PARAM_EXPLICIT_NOTIFY, then this signal is emitted only when they explicitly call `.notify()` or `.notify-by-pspec()`, and common practice is to do that only when the value has actually changed.

This signal is typically used to obtain change notification for a single property, by specifying the property name as a detail in the g_signal_connect() call, like this:

It is important to note that you must use canonical parameter names as detail strings for the notify signal.

    method handler (
       $pspec,
      Int :$_handle_id,
      Gnome::GObject::Object() :$_native-object,
      Gnome::GObject::Object :$_widget,
      *%user-options
    )

  * $pspec; the GParamSpec of the property which changed..

  * $_handle_id; The registered event handler id.

  * $_native-object; The native object provided by the Raku object which registered this event.

  * $_widget; The object which registered the signal. User code may have left the object going out of scope.

  * %user-options; A list of named arguments provided at the `.register-signal()` method from **Gnome::GObject::Object**.

