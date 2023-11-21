Project Description
-------------------

  * **Distribution:** Gnome::Gtk4

  * **Project description:** Modules for package Gnome::Gtk4:api<2>. The language binding to GNOME’s user interface toolkit version 4

  * **Project version:** 0.1.9

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

![](images/checkbutton.png)

Description
===========

A **Gnome::Gtk4::CheckButton** places a label next to an indicator.

![Example GtkCheckButtons](check-button.png)

A **Gnome::Gtk4::CheckButton** is created by calling either [ctor `$Gtk`.CheckButton.new] or [ctor `$Gtk`.CheckButton.new_with_label].

The state of a **Gnome::Gtk4::CheckButton** can be set specifically using `.set-active()`, and retrieved using `.get-active()`.

Inconsistent state
==================

In addition to "on" and "off", check buttons can be an "in between" state that is neither on nor off. This can be used e.g. when the user has selected a range of elements (such as some text or spreadsheet cells) that are affected by a check button, and the current values in that range are inconsistent.

To set a **Gnome::Gtk4::CheckButton** to inconsistent state, use `.set-inconsistent()`.

Grouping
========

Check buttons can be grouped together, to form mutually exclusive groups - only one of the buttons can be toggled at a time, and toggling another one will switch the currently toggled one off.

Grouped check buttons use a different indicator, and are commonly referred to as *radio buttons*.

![Example GtkCheckButtons](radio-button.png)

To add a **Gnome::Gtk4::CheckButton** to a group, use `.set-group()`.

CSS nodes
=========

A **Gnome::Gtk4::CheckButton** has a main node with name checkbutton. If the *label* property is set, it contains a label child. The indicator node is named check when no group is set, and radio if the checkbutton is grouped together with other checkbuttons.

Accessibility
=============

**Gnome::Gtk4::CheckButton** uses the %GTK_ACCESSIBLE_ROLE_CHECKBOX role.

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

new-checkbutton
---------------

Creates a new **Gnome::Gtk4::CheckButton**.

    method new-checkbutton ( --> Gnome::Gtk4::CheckButton )

new-with-label
--------------

Creates a new **Gnome::Gtk4::CheckButton** with the given text.

    method new-with-label ( Str $label --> Gnome::Gtk4::CheckButton )

  * $label; the text for the check button..

new-with-mnemonic
-----------------

Creates a new **Gnome::Gtk4::CheckButton** with the given text and a mnemonic.

    method new-with-mnemonic ( Str $label --> Gnome::Gtk4::CheckButton )

  * $label; The text of the button, with an underscore in front of the mnemonic character.

Methods
=======

get-active
----------

Returns whether the check button is active.

    method get-active (--> Bool )

Return value; whether the check button is active. 

get-inconsistent
----------------

Returns whether the check button is in an inconsistent state.

    method get-inconsistent (--> Bool )

Return value; %TRUE if `$check_button` is currently in an inconsistent state. 

get-label
---------

Returns the label of the check button.

    method get-label (--> Str )

Return value; The label `$self` shows next to the indicator. If no label is shown, undefined will be returned.. 

get-use-underline
-----------------

Returns whether underlines in the label indicate mnemonics.

    method get-use-underline (--> Bool )

Return value; The value of the *use-underline* property. See `.set-use-underline()` for details on how to set a new value.. 

set-active
----------

Changes the check buttons active state.

    method set-active ( Bool() $setting )

  * $setting; the new value to set.

set-group
---------

Adds `$self` to the group of `$group`.

In a group of multiple check buttons, only one button can be active at a time. The behavior of a checkbutton in a group is also commonly known as a *radio button*.

Setting the group of a check button also changes the css name of the indicator widget's CSS node to 'radio'.

Setting up groups in a cycle leads to undefined behavior.

Note that the same effect can be achieved via the [iface `$Gtk`.Actionable] API, by using the same action with parameter type and state type 's' for all buttons in the group, and giving each button its own target value.

    method set-group ( N-Object() $group )

  * $group; another **Gnome::Gtk4::CheckButton** to form a group with.

set-inconsistent
----------------

Sets the **Gnome::Gtk4::CheckButton** to inconsistent state.

You shoud turn off the inconsistent state again if the user checks the check button. This has to be done manually.

    method set-inconsistent ( Bool() $inconsistent )

  * $inconsistent; %TRUE if state is inconsistent.

set-label
---------

Sets the text of `$self`.

If *use-underline* is %TRUE, an underscore in `$label` is interpreted as mnemonic indicator, see `.set-use-underline()` for details on this behavior.

    method set-label ( Str $label )

  * $label; The text shown next to the indicator, or undefined to show no text.

set-use-underline
-----------------

Sets whether underlines in the label indicate mnemonics.

If `$setting` is %TRUE, an underscore character in `$self`'s label indicates a mnemonic accelerator key. This behavior is similar to *use-underline defined in Label*.

    method set-use-underline ( Bool() $setting )

  * $setting; the new value to set.

Signals
=======

### activate

Emitted to when the check button is activated.

The *::activate* signal on **Gnome::Gtk4::CheckButton** is an action signal and emitting it causes the button to animate press then release.

Applications should never connect to this signal, but use the *toggled* signal.

    method handler (
      Int :$_handle_id,
      Gnome::Gtk4::CheckButton() :$_native-object,
      Gnome::Gtk4::CheckButton :$_widget,
      *%user-options
    )

  * $_handle_id; The registered event handler id.

  * $_native-object; The native object provided by the Raku object which registered this event.

  * $_widget; The object which registered the signal. User code may have left the object going out of scope.

  * %user-options; A list of named arguments provided at the `.register-signal()` method from **Gnome::GObject::Object**.

### toggled

Emitted when the buttons's *active* property changes.

    method handler (
      Int :$_handle_id,
      Gnome::Gtk4::CheckButton() :$_native-object,
      Gnome::Gtk4::CheckButton :$_widget,
      *%user-options
    )

  * $_handle_id; The registered event handler id.

  * $_native-object; The native object provided by the Raku object which registered this event.

  * $_widget; The object which registered the signal. User code may have left the object going out of scope.

  * %user-options; A list of named arguments provided at the `.register-signal()` method from **Gnome::GObject::Object**.
