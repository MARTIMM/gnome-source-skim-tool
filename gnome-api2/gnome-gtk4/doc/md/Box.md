Project Description
-------------------

  * **Distribution:** Gnome::Gtk4

  * **Project description:** Modules for package Gnome::Gtk4:api<2>. The language binding to GNOME’s user interface toolkit version 4

  * **Project version:** 0.1.9

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

![](images/box.png)

Description
===========

The **Gnome::Gtk4::Box** widget arranges child widgets into a single row or column.

![An example GtkBox](box.png)

Whether it is a row or column depends on the value of its *orientation defined in Orientable* property. Within the other dimension, all children are allocated the same size. Of course, the *halign defined in Widget* and *valign defined in Widget* properties can be used on the children to influence their allocation.

Use repeated calls to `.append()` to pack widgets into a **Gnome::Gtk4::Box** from start to end. Use `.remove()` to remove widgets from the **Gnome::Gtk4::Box**. `.insert-child-after()` can be used to add a child at a particular position.

Use `.set-homogeneous()` to specify whether or not all children of the **Gnome::Gtk4::Box** are forced to get the same amount of space.

Use `.set-spacing()` to determine how much space will be minimally placed between all children in the **Gnome::Gtk4::Box**. Note that spacing is added *between* the children.

Use `.reorder-child-after()` to move a child to a different place in the box.

CSS nodes
=========

**Gnome::Gtk4::Box** uses a single CSS node with name box.

Accessibility
=============

**Gnome::Gtk4::Box** uses the %GTK_ACCESSIBLE_ROLE_GROUP role.

Class initialization
====================

new
---

### :native-object

Create an object using a native object from elsewhere. See also **Gnome::N::TopLevelSupportClass**.

    multi method new ( N-Object :$native-object! )

### :build-id

Create an object using a native object from a builder. See also **Gnome::GObject::Object**.

    multi method new ( Str :$build-id! )

new-box
-------

Creates a new **Gnome::Gtk4::Box**.

    method new-box ( GtkOrientation $orientation, Int() $spacing --> Gnome::Gtk4::Box )

  * $orientation; the box’s orientation. An enumeration.

  * $spacing; the number of pixels to place by default between children.

Methods
=======

append
------

Adds `$child` as the last child to `$box`.

    method append ( N-Object() $child )

  * $child; the *GtkWidget* to append.

get-baseline-position
---------------------

Gets the value set by gtk_box_set_baseline_position().

    method get-baseline-position (--> GtkBaselinePosition )

Return value; the baseline position. An enumeration.

get-homogeneous
---------------

Returns whether the box is homogeneous (all children are the same size).

    method get-homogeneous (--> Bool )

Return value; %TRUE if the box is homogeneous.. 

get-spacing
-----------

Gets the value set by gtk_box_set_spacing().

    method get-spacing (--> Int )

Return value; spacing between children. 

insert-child-after
------------------

Inserts `$child` in the position after `$sibling` in the list of `$box` children.

If `$sibling` is undefined, insert `$child` at the first position.

    method insert-child-after ( N-Object() $child, N-Object() $sibling )

  * $child; the *GtkWidget* to insert.

  * $sibling; the sibling after which to insert `$child`.

prepend
-------

Adds `$child` as the first child to `$box`.

    method prepend ( N-Object() $child )

  * $child; the *GtkWidget* to prepend.

remove
------

Removes a child widget from `$box`.

The child must have been added before with `.append()`, `.insert-child-after()`, or `.insert-child-after()`.

    method remove ( N-Object() $child )

  * $child; the child to remove.

reorder-child-after
-------------------

Moves `$child` to the position after `$sibling` in the list of `$box` children.

If `$sibling` is undefined, move `$child` to the first position.

    method reorder-child-after ( N-Object() $child, N-Object() $sibling )

  * $child; the *GtkWidget* to move, must be a child of `$box`.

  * $sibling; the sibling to move `$child` after.

set-baseline-position
---------------------

Sets the baseline position of a box.

This affects only horizontal boxes with at least one baseline aligned child. If there is more vertical space available than requested, and the baseline is not allocated by the parent then `$position` is used to allocate the baseline with respect to the extra space available.

    method set-baseline-position ( GtkBaselinePosition $position )

  * $position; a *GtkBaselinePosition*. An enumeration.

set-homogeneous
---------------

Sets whether or not all children of `$box` are given equal space in the box.

    method set-homogeneous ( Bool() $homogeneous )

  * $homogeneous; a boolean value, %TRUE to create equal allotments, %FALSE for variable allotments.

set-spacing
-----------

Sets the number of pixels to place between children of `$box`.

    method set-spacing ( Int() $spacing )

  * $spacing; the number of pixels to put between children.
