Project Description
-------------------

  * **Distribution:** Gnome::Gtk4

  * **Project description:** Modules for package Gnome::Gtk4:api<2>. The language binding to GNOME’s user interface toolkit version 4

  * **Project version:** 0.1.9

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

![](images/callbackaction.png)

Description
===========

A *GtkShortcutAction* that invokes a callback.

Class initialization
====================

new
---

### :native-object

Create an object using a native object from elsewhere. See also **Gnome::N::TopLevelSupportClass**.

    multi method new ( N-Object :$native-object! )

new-callbackaction
------------------

Create a custom action that calls the given `$callback` when activated.

    method new-callbackaction ( &callback, gpointer $data, … --> Gnome::Gtk4::CallbackAction )

  * &callback; the callback to call. Tthe function must be specified with following signature; `:( N-Object $widget, N-Variant $args, gpointer $user-data --` gboolean )>.

  * $data; the data to be passed to `$callback`.

  * destroy; the function to be called when the callback action is finalized. Note that each argument must be specified as a type followed by its value!
