Project Description
-------------------

  * **Distribution:** Gnome::Glib

  * **Project description:** Modules for package Gnome::Glib:api<2>. The language binding to GNOME's lowest level library

  * **Project version:** 0.1.3

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

Gnome::Glib::T-Error
====================

Class initialization
====================

new
---

Initialization of a type class is simple.

    method new ( )

Standalone Functions
====================

clear-error
-----------

If `$err` or * `$err` is `Nil`, does nothing. Otherwise, calls `.free()` on * `$err` and sets * `$err` to `Nil`.

    method clear-error (  )

prefix-error
------------

Formats a string according to `$format` and prefix it to an existing error message. If `$err` is `Nil` (ie: no error variable) then do nothing.

If * `$err` is `Nil` (ie: an error variable is present but there is no error condition) then also do nothing.

    method prefix-error (  N-Object $err, Str $format, … )

  * $err; (transfer ownership: full) a return location for a GError

  * $format; printf()-style format string.

  * …; arguments to `$format`. Note that each argument must be specified as a pair of a type and its value!

prefix-error-literal
--------------------

Prefixes `$prefix` to an existing error message. If `$err` or * `$err` is `Nil` (i.e.: no error variable) then do nothing.

    method prefix-error-literal (  N-Object $err, Str $prefix )

  * $err; a return location for a GError, or `Nil`

  * $prefix; string to prefix `$err` with.

propagate-error
---------------

If `$dest` is `Nil`, free `$src`; otherwise, moves `$src` into * `$dest`. The error variable `$dest` points to must be `Nil`. `$src` must be non-`Nil`.

Note that `$src` is no longer valid after this call. If you want to keep using the same GError*, you need to set it to `Nil` after calling this function on it.

    method propagate-error (  N-Object $dest, N-Object $src )

  * $dest; (transfer ownership: full) error return location

  * $src; (transfer ownership: full) error to move into the return location

propagate-prefixed-error
------------------------

If `$dest` is `Nil`, free `$src`; otherwise, moves `$src` into * `$dest`. * `$dest` must be `Nil`. After the move, add a prefix as with g_prefix_error().

    method propagate-prefixed-error (  N-Object $dest, N-Object $src, Str $format, … )

  * $dest; error return location

  * $src; error to move into the return location

  * $format; printf()-style format string.

  * …; arguments to `$format`. Note that each argument must be specified as a pair of a type and its value!

set-error
---------

Does nothing if `$err` is `Nil`; if `$err` is non-`Nil`, then * `$err` must be `Nil`. A new GError is created and assigned to * `$err`.

    method set-error (  N-Object $err, UInt $domain, Int() $code, Str $format, … )

  * $err; (transfer ownership: full) a return location for a GError

  * $domain; error domain.

  * $code; error code.

  * $format; printf()-style format.

  * …; args for `$format`. Note that each argument must be specified as a pair of a type and its value!

set-error-literal
-----------------

Does nothing if `$err` is `Nil`; if `$err` is non-`Nil`, then * `$err` must be `Nil`. A new GError is created and assigned to * `$err`. Unlike g_set_error(), `$message` is not a printf()-style format string. Use this function if `$message` contains text you don't have control over, that could include printf() escape sequences.

    method set-error-literal (  N-Object $err, UInt $domain, Int() $code, Str $message )

  * $err; (transfer ownership: full) a return location for a GError

  * $domain; error domain.

  * $code; error code.

  * $message; error message.
