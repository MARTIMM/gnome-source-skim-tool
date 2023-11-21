Project Description
-------------------

  * **Distribution:** Gnome::Gtk4

  * **Project description:** Modules for package Gnome::Gtk4:api<2>. The language binding to GNOME’s user interface toolkit version 4

  * **Project version:** 0.1.9

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

![](images/signalaction.png)

Description
===========

A *GtkShortcut*Action that emits a signal.

Signals that are used in this way are referred to as keybinding signals, and they are expected to be defined with the %G_SIGNAL_ACTION flag.

Class initialization
====================

new
---

### :native-object

Create an object using a native object from elsewhere. See also **Gnome::N::TopLevelSupportClass**.

    multi method new ( N-Object :$native-object! )

new-signalaction
----------------

Creates an action that when activated, emits the given action signal on the provided widget.

It will also unpack the args into arguments passed to the signal.

    method new-signalaction ( Str $signal-name --> Gnome::Gtk4::SignalAction )

  * $signal-name; name of the signal to emit.

Methods
=======

get-signal-name
---------------

Returns the name of the signal that will be emitted.

    method get-signal-name (--> Str )

Return value; the name of the signal to emit. 
