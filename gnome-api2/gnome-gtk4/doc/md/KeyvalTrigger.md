Project Description
-------------------

  * **Distribution:** Gnome::Gtk4

  * **Project description:** Modules for package Gnome::Gtk4:api<2>. The language binding to GNOME’s user interface toolkit version 4

  * **Project version:** 0.1.9

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

![](images/keyvaltrigger.png)

Description
===========

A *GtkShortcutTrigger* that triggers when a specific keyval and modifiers are pressed.

Class initialization
====================

new
---

### :native-object

Create an object using a native object from elsewhere. See also **Gnome::N::TopLevelSupportClass**.

    multi method new ( N-Object :$native-object! )

new-keyvaltrigger
-----------------

Creates a *GtkShortcutTrigger* that will trigger whenever the key with the given `$keyval` and `$modifiers` is pressed.

    method new-keyvaltrigger ( UInt() $keyval, UInt $modifiers --> Gnome::Gtk4::KeyvalTrigger )

  * $keyval; The keyval to trigger for.

  * $modifiers; the modifiers that need to be present. A bitmap.

Methods
=======

get-keyval
----------

Gets the keyval that must be pressed to succeed triggering `$self`.

    method get-keyval (--> UInt )

Return value; the keyval. 

get-modifiers
-------------

Gets the modifiers that must be present to succeed triggering `$self`.

    method get-modifiers (--> UInt )

Return value; the modifiers. A bitmap.
