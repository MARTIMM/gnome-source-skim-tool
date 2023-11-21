Project Description
-------------------

  * **Distribution:** Gnome::Gtk4

  * **Project description:** Modules for package Gnome::Gtk4:api<2>. The language binding to GNOME’s user interface toolkit version 4

  * **Project version:** 0.1.9

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

![](images/colorchooserdialog.png)

Description
===========

A dialog for choosing a color.

![An example GtkColorChooserDialog](colorchooser.png)

**Gnome::Gtk4::ColorChooserDialog** implements the [iface `$Gtk`.ColorChooser] interface and does not provide much API of its own.

To create a **Gnome::Gtk4::ColorChooserDialog**, use [ctor `$Gtk`.ColorChooserDialog.new].

To change the initially selected color, use `.set-rgba() defined in ColorChooser`. To get the selected color use `.get-rgba() defined in ColorChooser`.

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

new-colorchooserdialog
----------------------

Creates a new **Gnome::Gtk4::ColorChooserDialog**.

    method new-colorchooserdialog ( Str $title, N-Object() $parent --> Gnome::Gtk4::ColorChooserDialog )

  * $title; Title of the dialog.

  * $parent; Transient parent of the dialog.
