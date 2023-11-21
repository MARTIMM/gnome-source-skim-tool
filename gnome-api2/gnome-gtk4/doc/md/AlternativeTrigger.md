Project Description
-------------------

  * **Distribution:** Gnome::Gtk4

  * **Project description:** Modules for package Gnome::Gtk4:api<2>. The language binding to GNOME’s user interface toolkit version 4

  * **Project version:** 0.1.9

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

![](images/alternativetrigger.png)

Description
===========

A *GtkShortcutTrigger* that combines two triggers.

The **Gnome::Gtk4::AlternativeTrigger** triggers when either of two trigger.

This can be cascaded to combine more than two triggers.

Class initialization
====================

new
---

### :native-object

Create an object using a native object from elsewhere. See also **Gnome::N::TopLevelSupportClass**.

    multi method new ( N-Object :$native-object! )

new-alternativetrigger
----------------------

Creates a *GtkShortcutTrigger* that will trigger whenever either of the two given triggers gets triggered.

Note that nesting is allowed, so if you want more than two alternative, create a new alternative trigger for each option.

    method new-alternativetrigger ( N-Object() $first, N-Object() $second --> Gnome::Gtk4::AlternativeTrigger )

  * $first; (transfer ownership: full) The first trigger that may trigger.

  * $second; (transfer ownership: full) The second trigger that may trigger.

Methods
=======

get-first
---------

Gets the first of the two alternative triggers that may trigger `$self`.

`.get-second()` will return the other one.

    method get-first (--> N-Object )

Return value; the first alternative trigger. 

get-second
----------

Gets the second of the two alternative triggers that may trigger `$self`.

`.get-first()` will return the other one.

    method get-second (--> N-Object )

Return value; the second alternative trigger. 
