Project Description
-------------------

  * **Distribution:** Gnome::Gtk4

  * **Project description:** Modules for package Gnome::Gtk4:api<2>. The language binding to GNOME’s user interface toolkit version 4

  * **Project version:** 0.1.9

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

![](images/orientable.png)

Description
===========

The **Gnome::Gtk4::Orientable** interface is implemented by all widgets that can be oriented horizontally or vertically.

**Gnome::Gtk4::Orientable** is more flexible in that it allows the orientation to be changed at runtime, allowing the widgets to “flip”.

Methods
=======

get-orientation
---------------

Retrieves the orientation of the `$orientable`.

    method get-orientation (--> GtkOrientation )

Return value; the orientation of the `$orientable`. An enumeration.

set-orientation
---------------

Sets the orientation of the `$orientable`.

    method set-orientation ( GtkOrientation $orientation )

  * $orientation; the orientable’s new orientation. An enumeration.
