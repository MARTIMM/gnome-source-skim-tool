Project Description
-------------------

  * **Distribution:** Gnome::Gtk4

  * **Project description:** Modules for package Gnome::Gtk4:api<2>. The language binding to GNOME’s user interface toolkit version 4

  * **Project version:** 0.1.9

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

![](images/nevertrigger.png)

Description
===========

A *GtkShortcutTrigger* that never triggers.

Class initialization
====================

new
---

### :native-object

Create an object using a native object from elsewhere. See also **Gnome::N::TopLevelSupportClass**.

    multi method new ( N-Object :$native-object! )

Functions
=========

get
---

Gets the never trigger.

This is a singleton for a trigger that never triggers. Use this trigger instead of undefined because it implements all virtual functions.

    method get (--> N-Object )

Return value; The never trigger. 
