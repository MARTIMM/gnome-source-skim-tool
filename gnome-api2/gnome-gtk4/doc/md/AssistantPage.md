Project Description
-------------------

  * **Distribution:** Gnome::Gtk4

  * **Project description:** Modules for package Gnome::Gtk4:api<2>. The language binding to GNOME’s user interface toolkit version 4

  * **Project version:** 0.1.9

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

![](images/assistantpage.png)

Description
===========

**Gnome::Gtk4::AssistantPage** is an auxiliary object used by `GtkAssistant.

Class initialization
====================

new
---

### :native-object

Create an object using a native object from elsewhere. See also **Gnome::N::TopLevelSupportClass**.

    multi method new ( N-Object :$native-object! )

Methods
=======

get-child
---------

Returns the child to which `$page` belongs.

    method get-child (--> N-Object )

Return value; the child to which `$page` belongs. 
