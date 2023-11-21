Project Description
-------------------

  * **Distribution:** Gnome::Gtk4

  * **Project description:** Modules for package Gnome::Gtk4:api<2>. The language binding to GNOME’s user interface toolkit version 4

  * **Project version:** 0.1.9

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

![](images/mnemonicaction.png)

Description
===========

A *GtkShortcutAction* that calls gtk_widget_mnemonic_activate().

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

Gets the mnemonic action.

This is an action that calls gtk_widget_mnemonic_activate() on the given widget upon activation.

    method get (--> N-Object )

Return value; The mnemonic action. 
