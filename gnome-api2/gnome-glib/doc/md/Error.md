Project Description
-------------------

  * **Distribution:** Gnome::Glib

  * **Project description:** Modules for package Gnome::Glib:api<2>. The language binding to GNOME's lowest level library

  * **Project version:** 0.1.5

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

![](images/error.png)

Description
===========

The `GError` structure contains information about an error that has occurred.

Class initialization
====================

new
---

### :native-object

Create an object using a native object from elsewhere. See also **Gnome::N::TopLevelSupportClass**.

    multi method new ( N-Object :$native-object! )

new-error
---------

Creates a new GError with the given `$domain` and `$code`, and a message formatted with `$format`.

    method new-error ( --> Gnome::Glib::Error)

new-literal
-----------

Creates a new GError; unlike `.new-error()`, `$message` is not a printf()-style format string. Use this function if `$message` contains text you don't have control over, that could include printf() escape sequences.

    method new-literal ( --> Gnome::Glib::Error)

new-valist
----------

Creates a new GError with the given `$domain` and `$code`, and a message formatted with `$format`.

    method new-valist ( --> Gnome::Glib::Error)

Methods
=======

copy
----

Makes a copy of `$error`.

    method copy (--> CArray[N-Error] )

Return value; a new GError. 

free
----

Frees a GError and associated resources.

    method free ( )

matches
-------

Returns `True` if `$error` matches `$domain` and `$code`, `False` otherwise. In particular, when `$error` is `Nil`, `False` will be returned.

If `$domain` contains a `FAILED` (or otherwise generic) error code, you should generally not check for it explicitly, but should instead treat any not-explicitly-recognized error code as being equivalent to the `FAILED` code. This way, if the domain is extended in the future to provide a more specific error code for a certain case, your code will still work.

    method matches ( UInt $domain, Int() $code --> Bool() )

  * $domain; an error domain.

  * $code; an error code.

Return value; whether `$error` has `$domain` and `$code`. 

Functions
=========

domain-register
---------------

This function registers an extended GError domain. `$error_type_name` will be duplicated. Otherwise does the same as `.domain-register-static()`.

    method domain-register ( Str $error-type-name, Int() $error-type-private-size --> UInt )

  * $error-type-name; string to create a GQuark from.

  * $error-type-private-size; size of the private error data in bytes.

  * $error-type-init; function initializing fields of the private error data.=item $error-type-copy; function copying fields of the private error data.=item $error-type-clear; function freeing fields of the private error data. Return value; GQuark representing the error domain. 

domain-register-static
----------------------

This function registers an extended GError domain. `$error_type_name` should not be freed. `$error_type_private_size` must be greater than 0. `$error_type_init` receives an initialized GError and should then initialize the private data. `$error_type_copy` is a function that receives both original and a copy GError and should copy the fields of the private error data. The standard GError fields are already handled. `$error_type_clear` receives the pointer to the error, and it should free the fields of the private error data. It should not free the struct itself though.

Normally, it is better to use G_DEFINE_EXTENDED_ERROR(), as it already takes care of passing valid information to this function.

    method domain-register-static ( Str $error-type-name, Int() $error-type-private-size --> UInt )

  * $error-type-name; static string to create a GQuark from.

  * $error-type-private-size; size of the private error data in bytes.

  * $error-type-init; function initializing fields of the private error data.=item $error-type-copy; function copying fields of the private error data.=item $error-type-clear; function freeing fields of the private error data. Return value; GQuark representing the error domain. 
