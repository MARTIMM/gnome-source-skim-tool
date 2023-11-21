Project Description
-------------------

  * **Distribution:** Gnome::Gtk4

  * **Project description:** Modules for package Gnome::Gtk4:api<2>. The language binding to GNOME’s user interface toolkit version 4

  * **Project version:** 0.1.9

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

![](images/namedaction.png)

Description
===========

A *GtkShortcutAction* that activates an action by name.

Class initialization
====================

new
---

### :native-object

Create an object using a native object from elsewhere. See also **Gnome::N::TopLevelSupportClass**.

    multi method new ( N-Object :$native-object! )

new-namedaction
---------------

Creates an action that when activated, activates the named action on the widget.

It also passes the given arguments to it.

See `.insert-action-group() defined in Widget` for how to add actions to widgets.

    method new-namedaction ( Str $name --> Gnome::Gtk4::NamedAction )

  * $name; the detailed name of the action.

Methods
=======

get-action-name
---------------

Returns the name of the action that will be activated.

    method get-action-name (--> Str )

Return value; the name of the action to activate. 
