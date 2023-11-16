Project Description
-------------------

  * **Distribution:** Gnome::Glib

  * **Project description:** Modules for package Gnome::Glib:api<2>. The language binding to GNOME's lowest level library

  * **Project version:** 0.1.5

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

If `$err` is undefined, the function does nothing. Otherwise, calls `.free()` on `$err[0]` and sets `$err[0]` to `Nil`.

    method clear-error ( CArray[N-Error] $err )

  * $err; (transfer ownership: full) pointer to N-Error.

prefix-error
------------

Formats a string according to `$format` and prefix it to an existing error message. If `$err` is `Nil` (ie: no error variable) then do nothing.

If * `$err` is `Nil` (ie: an error variable is present but there is no error condition) then also do nothing.

    method prefix-error ( CArray[N-Error] $err, Str $format, … )

  * $err; (transfer ownership: full) a return location for a GError.

  * $format; printf()-style format string.

  * …; arguments to `$format`. Note that each argument must be specified as a type followed by its value!

### Example code;

    my Gnome::Glib::T-Error $t-error .= new;
    my $e = CArray[N-Error].new(N-Error);
    my $domain = 87600;
    my $code = 7;
    my $format = 'your %dnd error';
    $l = $t-error.set-error( $e, $domain, $code, ", I did warn ye!");
    $l = $t-error.prefix-error( $e, $format, gint32, 2);
    note $l[0].message;   # "your 2nd error, I did warn ye!"

Note the use of the extra argument for the format specified as a type `gint32` and a value `2`.

Note that formatted strings are available in Raku and that above example can be done simpler with the `sprinf()` function of Raku.

    $l = $t-error.prefix-error( $e, sprinf( $format, 2));

prefix-error-literal
--------------------

Prefixes `$prefix` to an existing error message. If `$err` or * `$err` is `Nil` (i.e.: no error variable) then do nothing.

    method prefix-error-literal ( CArray[N-Error] $err, Str $prefix )

  * $err; a return location for a GError, or `Nil`.

  * $prefix; string to prefix `$err` with.

propagate-error
---------------

If `$dest` is `Nil`, free `$src`; otherwise, moves `$src` into * `$dest`. The error variable `$dest` points to must be `Nil`. `$src` must be non-`Nil`.

Note that `$src` is no longer valid after this call. If you want to keep using the same GError*, you need to set it to `Nil` after calling this function on it.

    method propagate-error ( CArray[N-Error] $dest, CArray[N-Error] $src )

  * $dest; (transfer ownership: full) error return location.

  * $src; (transfer ownership: full) error to move into the return location.

propagate-prefixed-error
------------------------

If `$dest` is `Nil`, free `$src`; otherwise, moves `$src` into * `$dest`. * `$dest` must be `Nil`. After the move, add a prefix as with g_prefix_error().

    method propagate-prefixed-error (
      CArray[N-Error] $dest, CArray[N-Error] $src, Str $format, …
    )

  * $dest; error return location.

  * $src; error to move into the return location.

  * $format; printf()-style format string.

  * …; arguments to `$format`. Note that each argument must be specified as a type followed by its value!

set-error
---------

Does nothing if `$err` is `Nil`; if `$err` is non-`Nil`, then * `$err` must be `Nil`. A new GError is created and assigned to * `$err`.

    method set-error (
      CArray[N-Error] $err, UInt $domain, Int() $code, Str $format, …
    )

  * $err; (transfer ownership: full) a return location for a GError.

  * $domain; error domain.

  * $code; error code.

  * $format; printf()-style format.

  * …; args for `$format`. Note that each argument must be specified as a type followed by its value!

set-error-literal
-----------------

Does nothing if `$err` is `Nil`; if `$err` is non-`Nil`, then * `$err` must be `Nil`. A new GError is created and assigned to * `$err`. Unlike g_set_error(), `$message` is not a printf()-style format string. Use this function if `$message` contains text you don't have control over, that could include printf() escape sequences.

    method set-error-literal (
      CArray[N-Error] $err, UInt $domain, Int() $code, Str $message
    )

  * $err; (transfer ownership: full) a return location for a GError.

  * $domain; error domain.

  * $code; error code.

  * $message; error message.

