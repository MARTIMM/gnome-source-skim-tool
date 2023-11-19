Project Description
-------------------

  * **Distribution:** Gnome::Glib

  * **Project description:** Modules for package Gnome::Glib:api<2>. The language binding to GNOME's lowest level library

  * **Project version:** 0.1.5

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

![](images/mainloop.png)

Description
===========

The `GMainLoop` struct is an opaque data type representing the main event loop of a GLib or GTK+ application.

Class initialization
====================

new
---

### :native-object

Create an object using a native object from elsewhere. See also **Gnome::N::TopLevelSupportClass**.

    multi method new ( N-Object :$native-object! )

new-mainloop
------------

Creates a new GMainLoop structure.

    method new-mainloop ( --> Gnome::Glib::MainLoop)

Methods
=======

get-context
-----------

Returns the GMainContext of `$loop`.

    method get-context (--> CArray[N-MainContext] )

Return value; the GMainContext of `$loop`. 

is-running
----------

Checks to see if the main loop is currently being run via `.run()`.

    method is-running (--> Bool )

Return value; `True` if the mainloop is currently being run.. 

quit
----

Stops a GMainLoop from running. Any calls to `.run()` for the loop will return.

Note that sources that have already been dispatched when `.quit()` is called will still be executed.

    method quit ( )

ref
---

Increases the reference count on a GMainLoop object by one.

    method ref (--> CArray[N-MainLoop] )

Return value; `$loop`. 

run
---

Runs a main loop until `.quit()` is called on the loop. If this is called for the thread of the loop's GMainContext, it will process events from the loop, otherwise it will simply wait.

    method run ( )

unref
-----

Decreases the reference count on a GMainLoop object by one. If the result is zero, free the loop and free all associated memory.

    method unref ( )
