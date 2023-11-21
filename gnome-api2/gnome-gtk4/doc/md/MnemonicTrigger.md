Project Description
-------------------

  * **Distribution:** Gnome::Gtk4

  * **Project description:** Modules for package Gnome::Gtk4:api<2>. The language binding to GNOME’s user interface toolkit version 4

  * **Project version:** 0.1.9

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

![](images/mnemonictrigger.png)

Description
===========

A *GtkShortcutTrigger* that triggers when a specific mnemonic is pressed.

Mnemonics require a *mnemonic modifier* (typically <kbd>Alt</kbd>) to be pressed together with the mnemonic key.

Class initialization
====================

new
---

### :native-object

Create an object using a native object from elsewhere. See also **Gnome::N::TopLevelSupportClass**.

    multi method new ( N-Object :$native-object! )

new-mnemonictrigger
-------------------

Creates a *GtkShortcutTrigger* that will trigger whenever the key with the given `$keyval` is pressed and mnemonics have been activated.

Mnemonics are activated by calling code when a key event with the right modifiers is detected.

    method new-mnemonictrigger ( UInt() $keyval --> Gnome::Gtk4::MnemonicTrigger )

  * $keyval; The keyval to trigger for.

Methods
=======

get-keyval
----------

Gets the keyval that must be pressed to succeed triggering `$self`.

    method get-keyval (--> UInt )

Return value; the keyval. 
