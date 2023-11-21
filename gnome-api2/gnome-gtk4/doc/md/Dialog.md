Project Description
-------------------

  * **Distribution:** Gnome::Gtk4

  * **Project description:** Modules for package Gnome::Gtk4:api<2>. The language binding to GNOME’s user interface toolkit version 4

  * **Project version:** 0.1.9

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

![](images/dialog.png)

Description
===========

Dialogs are a convenient way to prompt the user for a small amount of input.

![An example GtkDialog](dialog.png)

Typical uses are to display a message, ask a question, or anything else that does not require extensive effort on the user’s part.

The main area of a **Gnome::Gtk4::Dialog** is called the "content area", and is yours to populate with widgets such a *GtkLabel* or *GtkEntry*, to present your information, questions, or tasks to the user.

In addition, dialogs allow you to add "action widgets". Most commonly, action widgets are buttons. Depending on the platform, action widgets may be presented in the header bar at the top of the window, or at the bottom of the window. To add action widgets, create your **Gnome::Gtk4::Dialog** using [ctor `$Gtk`.Dialog.new_with_buttons], or use `.add-button()`, `.add-action-widget()`, or `.add-action-widget() defined in Dialog`.

**Gnome::Gtk4::Dialog**s uses some heuristics to decide whether to add a close button to the window decorations. If any of the action buttons use the response ID %GTK_RESPONSE_CLOSE or %GTK_RESPONSE_CANCEL, the close button is omitted.

Clicking a button that was added as an action widget will emit the *response* signal with a response ID that you specified. GTK will never assign a meaning to positive response IDs; these are entirely user-defined. But for convenience, you can use the response IDs in the `GtkResponseType` enumeration enumeration (these all have values less than zero). If a dialog receives a delete event, the *response* signal will be emitted with the %GTK_RESPONSE_DELETE_EVENT response ID.

Dialogs are created with a call to [ctor `$Gtk`.Dialog.new] or [ctor `$Gtk`.Dialog.new_with_buttons]. The latter is recommended; it allows you to set the dialog title, some convenient flags, and add buttons.

A “modal” dialog (that is, one which freezes the rest of the application from user input), can be created by calling `.set-modal() defined in Window` on the dialog. When using [ctor `$Gtk`.Dialog.new_with_buttons], you can also pass the %GTK_DIALOG_MODAL flag to make a dialog modal.

For the simple dialog in the following example, a [class `$Gtk`.MessageDialog] would save some effort. But you’d need to create the dialog contents manually if you had more than a simple message in the dialog.

An example for simple **Gnome::Gtk4::Dialog** usage:

GtkDialog as GtkBuildable
=========================

The **Gnome::Gtk4::Dialog** implementation of the *GtkBuildable* interface exposes the `$content_area` as an internal child with the name “content_area”.

**Gnome::Gtk4::Dialog** supports a custom _action-widgets_ element, which can contain multiple _action-widget_ elements. The “response” attribute specifies a numeric response, and the content of the element is the id of widget (which should be a child of the dialogs `$action_area`). To mark a response as default, set the “default” attribute of the _action-widget_ element to true.

**Gnome::Gtk4::Dialog** supports adding action widgets by specifying “action” as the “type” attribute of a _child_ element. The widget will be added either to the action area or the headerbar of the dialog, depending on the “use-header-bar” property. The response id has to be associated with the action widget using the _action-widgets_ element.

An example of a **Gnome::Gtk4::Dialog** UI definition fragment:

Accessibility
=============

**Gnome::Gtk4::Dialog** uses the %GTK_ACCESSIBLE_ROLE_DIALOG role.

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

new-dialog
----------

Creates a new dialog box.

Widgets should not be packed into the *GtkWindow* directly, but into the `$content_area` and `$action_area`, as described above.

    method new-dialog ( --> Gnome::Gtk4::Dialog )

new-with-buttons
----------------

Creates a new **Gnome::Gtk4::Dialog** with the given title and transient parent.

The `$flags` argument can be used to make the dialog modal, have it destroyed along with its transient parent, or make it use a headerbar.

Button text/response ID pairs should be listed in pairs, with a undefined pointer ending the list. Button text can be arbitrary text. A response ID can be any positive number, or one of the values in the `GtkResponseType` enumeration enumeration. If the user clicks one of these buttons, **Gnome::Gtk4::Dialog** will emit the *response* signal with the corresponding response ID.

If a **Gnome::Gtk4::Dialog** receives a delete event, it will emit ::response with a response ID of %GTK_RESPONSE_DELETE_EVENT.

However, destroying a dialog does not emit the ::response signal; so be careful relying on ::response when using the %GTK_DIALOG_DESTROY_WITH_PARENT flag.

Here’s a simple example:

    method new-with-buttons ( Str $title, N-Object() $parent, UInt $flags, Str $first-button-text, … --> Gnome::Gtk4::Dialog )

  * $title; Title of the dialog.

  * $parent; Transient parent of the dialog.

  * $flags; from **Gnome::Gtk4::Dialog**Flags. A bitmap.

  * $first-button-text; text to go in first button.

  * …; response ID for first button, then additional buttons, ending with undefined. Note that each argument must be specified as a type followed by its value!

Methods
=======

add-action-widget
-----------------

Adds an activatable widget to the action area of a **Gnome::Gtk4::Dialog**.

GTK connects a signal handler that will emit the *response* signal on the dialog when the widget is activated. The widget is appended to the end of the dialog’s action area.

If you want to add a non-activatable widget, simply pack it into the `$action_area` field of the **Gnome::Gtk4::Dialog** struct.

    method add-action-widget ( N-Object() $child, Int() $response-id )

  * $child; an activatable widget.

  * $response-id; response ID for `$child`.

add-button
----------

Adds a button with the given text.

GTK arranges things so that clicking the button will emit the *response* signal with the given `$response_id`. The button is appended to the end of the dialog’s action area. The button widget is returned, but usually you don’t need it.

    method add-button ( Str $button-text, Int() $response-id --> N-Object )

  * $button-text; text of button.

  * $response-id; response ID for the button.

Return value; the *GtkButton* widget that was added. 

add-buttons
-----------

Adds multiple buttons.

This is the same as calling `.add-button()` repeatedly. The variable argument list should be undefined-terminated as with [ctor `$Gtk`.Dialog.new_with_buttons]. Each button must have both text and response ID.

    method add-buttons ( Str $first-button-text, … )

  * $first-button-text; button text.

  * …; response ID for first button, then more text-response_id pairs. Note that each argument must be specified as a type followed by its value!

get-content-area
----------------

Returns the content area of `$dialog`.

    method get-content-area (--> N-Object )

Return value; the content area *GtkBox*.. 

get-header-bar
--------------

Returns the header bar of `$dialog`.

Note that the headerbar is only used by the dialog if the *use-header-bar* property is %TRUE.

    method get-header-bar (--> N-Object )

Return value; the header bar. 

get-response-for-widget
-----------------------

Gets the response id of a widget in the action area of a dialog.

    method get-response-for-widget ( N-Object() $widget --> Int )

  * $widget; a widget in the action area of `$dialog`.

Return value; the response id of `$widget`, or %GTK_RESPONSE_NONE if `$widget` doesn’t have a response id set.. 

get-widget-for-response
-----------------------

Gets the widget button that uses the given response ID in the action area of a dialog.

    method get-widget-for-response ( Int() $response-id --> N-Object )

  * $response-id; the response ID used by the `$dialog` widget.

Return value; the `$widget` button that uses the given `$response_id`. 

response
--------

Emits the ::response signal with the given response ID.

Used to indicate that the user has responded to the dialog in some way.

    method response ( Int() $response-id )

  * $response-id; response ID.

set-default-response
--------------------

Sets the default widget for the dialog based on the response ID.

Pressing “Enter” normally activates the default widget.

    method set-default-response ( Int() $response-id )

  * $response-id; a response ID.

set-response-sensitive
----------------------

A convenient way to sensitize/desensitize dialog buttons.

Calls *gtk_widget_set_sensitive (widget, `$setting`)* for each widget in the dialog’s action area with the given `$response_id`.

    method set-response-sensitive ( Int() $response-id, Bool() $setting )

  * $response-id; a response ID.

  * $setting; %TRUE for sensitive.

Signals
=======

### close

Emitted when the user uses a keybinding to close the dialog.

This is a [keybinding signal](class.SignalAction.html).

The default binding for this signal is the Escape key.

    method handler (
      Int :$_handle_id,
      Gnome::Gtk4::Dialog() :$_native-object,
      Gnome::Gtk4::Dialog :$_widget,
      *%user-options
    )

  * $_handle_id; The registered event handler id.

  * $_native-object; The native object provided by the Raku object which registered this event.

  * $_widget; The object which registered the signal. User code may have left the object going out of scope.

  * %user-options; A list of named arguments provided at the `.register-signal()` method from **Gnome::GObject::Object**.

### response

Emitted when an action widget is clicked.

The signal is also emitted when the dialog receives a delete event, and when `.response()` is called. On a delete event, the response ID is %GTK_RESPONSE_DELETE_EVENT. Otherwise, it depends on which action widget was clicked.

    method handler (
      gint $response-id,
      Int :$_handle_id,
      Gnome::Gtk4::Dialog() :$_native-object,
      Gnome::Gtk4::Dialog :$_widget,
      *%user-options
    )

  * $response-id; the response ID.

  * $_handle_id; The registered event handler id.

  * $_native-object; The native object provided by the Raku object which registered this event.

  * $_widget; The object which registered the signal. User code may have left the object going out of scope.

  * %user-options; A list of named arguments provided at the `.register-signal()` method from **Gnome::GObject::Object**.
