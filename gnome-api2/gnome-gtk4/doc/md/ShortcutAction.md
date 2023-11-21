Project Description
-------------------

  * **Distribution:** Gnome::Gtk4

  * **Project description:** Modules for package Gnome::Gtk4:api<2>. The language binding to GNOME’s user interface toolkit version 4

  * **Project version:** 0.1.9

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

![](images/shortcutaction.png)

Description
===========

**Gnome::Gtk4::ShortcutAction** encodes an action that can be triggered by a keyboard shortcut.

**Gnome::Gtk4::ShortcutAction**s contain functions that allow easy presentation to end users as well as being printed for debugging.

All **Gnome::Gtk4::ShortcutAction**s are immutable, you can only specify their properties during construction. If you want to change a action, you have to replace it with a new one. If you need to pass arguments to an action, these are specified by the higher-level *GtkShortcut* object.

To activate a **Gnome::Gtk4::ShortcutAction** manually, `.activate()` can be called.

GTK provides various actions:

    - [class C<$Gtk>.MnemonicAction]: a shortcut action that calls
      gtk_widget_mnemonic_activate()
    - [class C<$Gtk>.CallbackAction]: a shortcut action that invokes
      a given callback
    - [class C<$Gtk>.SignalAction]: a shortcut action that emits a
      given signal
    - [class C<$Gtk>.ActivateAction]: a shortcut action that calls
      gtk_widget_activate()
    - [class C<$Gtk>.NamedAction]: a shortcut action that calls
      gtk_widget_activate_action()
    - [class C<$Gtk>.NothingAction]: a shortcut action that does nothing

Class initialization
====================

new
---

### :native-object

Create an object using a native object from elsewhere. See also **Gnome::N::TopLevelSupportClass**.

    multi method new ( N-Object :$native-object! )

parse-string
------------

Tries to parse the given string into an action.

On success, the parsed action is returned. When parsing failed, undefined is returned.

The accepted strings are:

- *nothing*, for *GtkNothingAction* - *activate*, for *GtkActivateAction* - *mnemonic-activate*, for *GtkMnemonicAction* - *action(NAME)*, for a *GtkNamedAction* for the action named *NAME* - *signal(NAME)*, for a *GtkSignalAction* for the signal *NAME*

    method parse-string ( Str $string --> Gnome::Gtk4::ShortcutAction )

  * $string; the string to parse.

Methods
=======

activate
--------

Activates the action on the `$widget` with the given `$args`.

Note that some actions ignore the passed in `$flags`, `$widget` or `$args`.

Activation of an action can fail for various reasons. If the action is not supported by the `$widget`, if the `$args` don't match the action or if the activation otherwise had no effect, %FALSE will be returned.

    method activate ( UInt $flags, N-Object() $widget, CArray[N-Variant] $args --> Bool )

  * $flags; flags to activate with. A bitmap.

  * $widget; Target of the activation.

  * $args; arguments to pass.

Return value; %TRUE if this action was activated successfully. 

print
-----

Prints the given action into a string for the developer.

This is meant for debugging and logging.

The form of the representation may change at any time and is not guaranteed to stay identical.

    method print ( CArray[N-String]  $string )

  * $string; a *GString* to print into.

to-string
---------

Prints the given action into a human-readable string.

This is a small wrapper around `.print()` to help when debugging.

    method to-string (--> Str )

Return value; a new string. 
