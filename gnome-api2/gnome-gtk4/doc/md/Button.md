Project Description
-------------------

  * **Distribution:** Gnome::Gtk4

  * **Project description:** Modules for package Gnome::Gtk4:api<2>. The language binding to GNOME’s user interface toolkit version 4

  * **Project version:** 0.1.9

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

![](images/button.png)

Description
===========

The **Gnome::Gtk4::Button** widget is generally used to trigger a callback function that is called when the button is pressed.

![An example GtkButton](button.png)

The **Gnome::Gtk4::Button** widget can hold any valid child widget. That is, it can hold almost any other standard *GtkWidget*. The most commonly used child is the *GtkLabel*.

CSS nodes
=========

**Gnome::Gtk4::Button** has a single CSS node with name button. The node will get the style classes .image-button or .text-button, if the content is just an image or label, respectively. It may also receive the .flat style class. When activating a button via the keyboard, the button will temporarily gain the .keyboard-activating style class.

Other style classes that are commonly used with **Gnome::Gtk4::Button** include .suggested-action and .destructive-action. In special cases, buttons can be made round by adding the .circular style class.

Button-like widgets like [class `$Gtk`.ToggleButton], [class `$Gtk`.MenuButton], [class `$Gtk`.VolumeButton], [class `$Gtk`.LockButton], [class `$Gtk`.ColorButton] or [class `$Gtk`.FontButton] use style classes such as .toggle, .popup, .scale, .lock, .color on the button node to differentiate themselves from a plain **Gnome::Gtk4::Button**.

Accessibility
=============

**Gnome::Gtk4::Button** uses the %GTK_ACCESSIBLE_ROLE_BUTTON role.

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

new-button
----------

Creates a new **Gnome::Gtk4::Button** widget.

To add a child widget to the button, use `.set-child()`.

    method new-button ( --> Gnome::Gtk4::Button )

new-from-icon-name
------------------

Creates a new button containing an icon from the current icon theme.

If the icon name isn’t known, a “broken image” icon will be displayed instead. If the current icon theme is changed, the icon will be updated appropriately.

    method new-from-icon-name ( Str $icon-name --> Gnome::Gtk4::Button )

  * $icon-name; an icon name.

new-with-label
--------------

Creates a **Gnome::Gtk4::Button** widget with a *GtkLabel* child.

    method new-with-label ( Str $label --> Gnome::Gtk4::Button )

  * $label; The text you want the *GtkLabel* to hold.

new-with-mnemonic
-----------------

Creates a new **Gnome::Gtk4::Button** containing a label.

If characters in `$label` are preceded by an underscore, they are underlined. If you need a literal underscore character in a label, use “__” (two underscores). The first underlined character represents a keyboard accelerator called a mnemonic. Pressing Alt and that key activates the button.

    method new-with-mnemonic ( Str $label --> Gnome::Gtk4::Button )

  * $label; The text of the button, with an underscore in front of the mnemonic character.

Methods
=======

get-child
---------

Gets the child widget of `$button`.

    method get-child (--> N-Object )

Return value; the child widget of `$button`. 

get-has-frame
-------------

Returns whether the button has a frame.

    method get-has-frame (--> Bool )

Return value; %TRUE if the button has a frame. 

get-icon-name
-------------

Returns the icon name of the button.

If the icon name has not been set with `.set-icon-name()` the return value will be undefined. This will be the case if you create an empty button with [ctor `$Gtk`.Button.new] to use as a container.

    method get-icon-name (--> Str )

Return value; The icon name set via `.set-icon-name()`. 

get-label
---------

Fetches the text from the label of the button.

If the label text has not been set with `.set-label()` the return value will be undefined. This will be the case if you create an empty button with [ctor `$Gtk`.Button.new] to use as a container.

    method get-label (--> Str )

Return value; The text of the label widget. This string is owned by the widget and must not be modified or freed.. 

get-use-underline
-----------------

gets whether underlines are interpreted as mnemonics.

See `.set-use-underline()`.

    method get-use-underline (--> Bool )

Return value; %TRUE if an embedded underline in the button label indicates the mnemonic accelerator keys.. 

set-child
---------

Sets the child widget of `$button`.

Note that by using this API, you take full responsibility for setting up the proper accessibility label and description information for `$button`. Most likely, you'll either set the accessibility label or description for `$button` explicitly, or you'll set a labelled-by or described-by relations from `$child` to `$button`.

    method set-child ( N-Object() $child )

  * $child; the child widget.

set-has-frame
-------------

Sets the style of the button.

Buttons can has a flat appearance or have a frame drawn around them.

    method set-has-frame ( Bool() $has-frame )

  * $has-frame; whether the button should have a visible frame.

set-icon-name
-------------

Adds a *GtkImage* with the given icon name as a child.

If `$button` already contains a child widget, that child widget will be removed and replaced with the image.

    method set-icon-name ( Str $icon-name )

  * $icon-name; An icon name.

set-label
---------

Sets the text of the label of the button to `$label`.

This will also clear any previously set labels.

    method set-label ( Str $label )

  * $label; a string.

set-use-underline
-----------------

Sets whether to use underlines as mnemonics.

If true, an underline in the text of the button label indicates the next character should be used for the mnemonic accelerator key.

    method set-use-underline ( Bool() $use-underline )

  * $use-underline; %TRUE if underlines in the text indicate mnemonics.

Signals
=======

### activate

Emitted to animate press then release.

This is an action signal. Applications should never connect to this signal, but use the *clicked* signal.

    method handler (
      Int :$_handle_id,
      Gnome::Gtk4::Button() :$_native-object,
      Gnome::Gtk4::Button :$_widget,
      *%user-options
    )

  * $_handle_id; The registered event handler id.

  * $_native-object; The native object provided by the Raku object which registered this event.

  * $_widget; The object which registered the signal. User code may have left the object going out of scope.

  * %user-options; A list of named arguments provided at the `.register-signal()` method from **Gnome::GObject::Object**.

### clicked

Emitted when the button has been activated (pressed and released).

    method handler (
      Int :$_handle_id,
      Gnome::Gtk4::Button() :$_native-object,
      Gnome::Gtk4::Button :$_widget,
      *%user-options
    )

  * $_handle_id; The registered event handler id.

  * $_native-object; The native object provided by the Raku object which registered this event.

  * $_widget; The object which registered the signal. User code may have left the object going out of scope.

  * %user-options; A list of named arguments provided at the `.register-signal()` method from **Gnome::GObject::Object**.
