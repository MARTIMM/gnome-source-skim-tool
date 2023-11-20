Project Description
-------------------

  * **Distribution:** Gnome::Glib

  * **Project description:** Modules for package Gnome::Glib:api<2>. The language binding to GNOME's lowest level library

  * **Project version:** 0.1.5

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

Gnome::Glib::T-Quark
====================

Class initialization
====================

new
---

Initialization of a type class is simple.

    method new ( )

Standalone Functions
====================

intern-static-string
--------------------

Returns a canonical representation for `$string`. Interned strings can be compared for equality by comparing the pointers, instead of using strcmp(). g_intern_static_string() does not copy the string, therefore `$string` must not be freed or modified.

This function must not be used before library constructors have finished running. In particular, this means it cannot be used to initialize global variables in C++.

    method intern-static-string ( Str $string --> Str )

  * $string; a static string.

Return value; a canonical representation for the string. 

intern-string
-------------

Returns a canonical representation for `$string`. Interned strings can be compared for equality by comparing the pointers, instead of using strcmp().

This function must not be used before library constructors have finished running. In particular, this means it cannot be used to initialize global variables in C++.

    method intern-string ( Str $string --> Str )

  * $string; a string.

Return value; a canonical representation for the string. 

quark-from-static-string
------------------------

Gets the GQuark identifying the given (static) string. If the string does not currently have an associated GQuark, a new GQuark is created, linked to the given string.

Note that this function is identical to `.from-string()` except that if a new GQuark is created the string itself is used rather than a copy. This saves memory, but can only be used if the string will continue to exist until the program terminates. It can be used with statically allocated strings in the main program, but not with statically allocated memory in dynamically loaded modules, if you expect to ever unload the module again (e.g. do not use this function in GTK+ theme engines).

This function must not be used before library constructors have finished running. In particular, this means it cannot be used to initialize global variables in C++.

    method quark-from-static-string ( Str $string --> UInt )

  * $string; a string.

Return value; the GQuark identifying the string, or 0 if `$string` is `Nil`. 

quark-from-string
-----------------

Gets the GQuark identifying the given string. If the string does not currently have an associated GQuark, a new GQuark is created, using a copy of the string.

This function must not be used before library constructors have finished running. In particular, this means it cannot be used to initialize global variables in C++.

    method quark-from-string ( Str $string --> UInt )

  * $string; a string.

Return value; the GQuark identifying the string, or 0 if `$string` is `Nil`. 

quark-to-string
---------------

Gets the string associated with the given GQuark.

    method quark-to-string ( UInt $quark --> Str )

  * $quark; a GQuark..

Return value; the string associated with the GQuark. 

quark-try-string
----------------

Gets the GQuark associated with the given string, or 0 if string is `Nil` or it has no associated GQuark.

If you want the GQuark to be created if it doesn't already exist, use `.from-string()` or `.from-static-string()`.

This function must not be used before library constructors have finished running.

    method quark-try-string ( Str $string --> UInt )

  * $string; a string.

Return value; the GQuark associated with the string, or 0 if `$string` is `Nil` or there is no GQuark associated with it. 
