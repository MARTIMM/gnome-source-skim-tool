Project Description
-------------------

  * **Distribution:** Gnome::Gtk4

  * **Project description:** Modules for package Gnome::Gtk4:api<2>. The language binding to GNOME’s user interface toolkit version 4

  * **Project version:** 0.1.9

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

![](images/shortcuttrigger.png)

Description
===========

**Gnome::Gtk4::ShortcutTrigger** tracks how a *GtkShortcut* should be activated.

To find out if a **Gnome::Gtk4::ShortcutTrigger** triggers, you can call `.trigger()` on a *GdkEvent*.

**Gnome::Gtk4::ShortcutTrigger**s contain functions that allow easy presentation to end users as well as being printed for debugging.

All **Gnome::Gtk4::ShortcutTrigger**s are immutable, you can only specify their properties during construction. If you want to change a trigger, you have to replace it with a new one.

Class initialization
====================

new
---

### :native-object

Create an object using a native object from elsewhere. See also **Gnome::N::TopLevelSupportClass**.

    multi method new ( N-Object :$native-object! )

parse-string
------------

Tries to parse the given string into a trigger.

On success, the parsed trigger is returned. When parsing failed, undefined is returned.

The accepted strings are:

    - I<never>, for I<GtkNeverTrigger>
    - a string parsed by gtk_accelerator_parse(), for a I<GtkKeyvalTrigger>, e.g. U<Control>C
    - underscore, followed by a single character, for I<GtkMnemonicTrigger>, e.g. I<_l>
    - two valid trigger strings, separated by a I<|> character, for a
    I<GtkAlternativeTrigger>: U<Control>q|<Control>w

Note that you will have to escape the *> and **> characters when specifying triggers in XML files, such as GtkBuilder ui files. Use *&lt;* instead of *> and *&gt;* instead of **>. **

    method parse-string ( Str $string --> Gnome::Gtk4::ShortcutTrigger )

  * $string; the string to parse.

Methods
=======

compare
-------

The types of `$trigger1` and `$trigger2` are *gconstpointer* only to allow use of this function as a *GCompareFunc*.

They must each be a **Gnome::Gtk4::ShortcutTrigger**.

    method compare ( gpointer $trigger2 --> Int )

  * $trigger2; a **Gnome::Gtk4::ShortcutTrigger**.

Return value; An integer less than, equal to, or greater than zero if `$trigger1` is found, respectively, to be less than, to match, or be greater than `$trigger2`.. 

equal
-----

Checks if `$trigger1` and `$trigger2` trigger under the same conditions.

The types of `$one` and `$two` are *gconstpointer* only to allow use of this function with *GHashTable*. They must each be a **Gnome::Gtk4::ShortcutTrigger**.

    method equal ( gpointer $trigger2 --> Bool )

  * $trigger2; a **Gnome::Gtk4::ShortcutTrigger**.

Return value; %TRUE if `$trigger1` and `$trigger2` are equal. 

hash
----

Generates a hash value for a **Gnome::Gtk4::ShortcutTrigger**.

The output of this function is guaranteed to be the same for a given value only per-process. It may change between different processor architectures or even different versions of GTK. Do not use this function as a basis for building protocols or file formats.

The types of `$trigger` is *gconstpointer* only to allow use of this function with *GHashTable*. They must each be a **Gnome::Gtk4::ShortcutTrigger**.

    method hash (--> UInt )

Return value; a hash value corresponding to `$trigger`. 

print
-----

Prints the given trigger into a string for the developer. This is meant for debugging and logging.

The form of the representation may change at any time and is not guaranteed to stay identical.

    method print ( CArray[N-String]  $string )

  * $string; a *GString* to print into.

print-label
-----------

Prints the given trigger into a string.

This function is returning a translated string for presentation to end users for example in menu items or in help texts.

The `$display` in use may influence the resulting string in various forms, such as resolving hardware keycodes or by causing display-specific modifier names.

The form of the representation may change at any time and is not guaranteed to stay identical.

    method print-label ( N-Object() $display, CArray[N-String]  $string --> Bool )

  * $display; *GdkDisplay* to print for.

  * $string; a *GString* to print into.

Return value; %TRUE if something was printed or %FALSE if the trigger did not have a textual representation suitable for end users.. 

to-label
--------

Gets textual representation for the given trigger.

This function is returning a translated string for presentation to end users for example in menu items or in help texts.

The `$display` in use may influence the resulting string in various forms, such as resolving hardware keycodes or by causing display-specific modifier names.

The form of the representation may change at any time and is not guaranteed to stay identical.

    method to-label ( N-Object() $display --> Str )

  * $display; *GdkDisplay* to print for.

Return value; a new string. 

to-string
---------

Prints the given trigger into a human-readable string.

This is a small wrapper around `.print()` to help when debugging.

    method to-string (--> Str )

Return value; a new string. 

trigger
-------

Checks if the given `$event` triggers `$self`.

    method trigger ( N-Object() $event, Bool() $enable-mnemonics --> GdkKeyMatch  )

  * $event; the event to check.

  * $enable-mnemonics; %TRUE if mnemonics should trigger. Usually the value of this property is determined by checking that the passed in `$event` is a Key event and has the right modifiers set..

Return value; Whether the event triggered the shortcut. An enumeration.
