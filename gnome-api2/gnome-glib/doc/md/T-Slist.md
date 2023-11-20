Project Description
-------------------

  * **Distribution:** Gnome::Glib

  * **Project description:** Modules for package Gnome::Glib:api<2>. The language binding to GNOME's lowest level library

  * **Project version:** 0.1.5

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

Gnome::Glib::T-Slist
====================

Class initialization
====================

new
---

Initialization of a type class is simple.

    method new ( )

Standalone Functions
====================

clear-slist
-----------

Clears a pointer to a GSList, freeing it and, optionally, freeing its elements using `$destroy`. `$slist_ptr` must be a valid pointer. If `$slist_ptr` points to a null GSList, this does nothing.

    method clear-slist ( N-SList() $slist-ptr, &destroy )

  * $slist-ptr; a GSList return location.

  * &destroy; the function to pass to `.free-full()` or `Nil` to not free elements. Tthe function must be specified with following signature; `:( gpointer $data )`.
