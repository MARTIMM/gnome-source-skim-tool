Project Description
-------------------

  * **Distribution:** Gnome::Gtk4

  * **Project description:** Modules for package Gnome::Gtk4:api<2>. The language binding to GNOME’s user interface toolkit version 4

  * **Project version:** 0.1.9

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

![](images/colorchooserwidget.png)

Description
===========

The **Gnome::Gtk4::ColorChooserWidget** widget lets the user select a color.

By default, the chooser presents a predefined palette of colors, plus a small number of settable custom colors. It is also possible to select a different color with the single-color editor.

To enter the single-color editing mode, use the context menu of any color of the palette, or use the '+' button to add a new custom color.

The chooser automatically remembers the last selection, as well as custom colors.

To create a **Gnome::Gtk4::ColorChooserWidget**, use [ctor `$Gtk`.ColorChooserWidget.new].

To change the initially selected color, use `.set-rgba() defined in ColorChooser`. To get the selected color use `.get-rgba() defined in ColorChooser`.

The **Gnome::Gtk4::ColorChooserWidget** is used in the [class `$Gtk`.ColorChooserDialog] to provide a dialog for selecting colors.

CSS names
=========

**Gnome::Gtk4::ColorChooserWidget** has a single CSS node with name colorchooser.

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

new-colorchooserwidget
----------------------

Creates a new **Gnome::Gtk4::ColorChooserWidget**.

    method new-colorchooserwidget ( --> Gnome::Gtk4::ColorChooserWidget )
