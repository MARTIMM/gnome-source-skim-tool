Project Description
-------------------

  * **Distribution:** Gnome::Gtk4

  * **Project description:** Modules for package Gnome::Gtk4:api<2>. The language binding to GNOME’s user interface toolkit version 4

  * **Project version:** 0.1.9

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

![](images/assistant.png)

Description
===========

**Gnome::Gtk4::Assistant** is used to represent a complex as a series of steps.

![An example GtkAssistant](assistant.png)

Each step consists of one or more pages. **Gnome::Gtk4::Assistant** guides the user through the pages, and controls the page flow to collect the data needed for the operation.

**Gnome::Gtk4::Assistant** handles which buttons to show and to make sensitive based on page sequence knowledge and the `GtkAssistantPageType` enumeration of each page in addition to state information like the *completed* and *committed* page statuses.

If you have a case that doesn’t quite fit in **Gnome::Gtk4::Assistant**s way of handling buttons, you can use the %GTK_ASSISTANT_PAGE_CUSTOM page type and handle buttons yourself.

**Gnome::Gtk4::Assistant** maintains a **Gnome::Gtk4::Assistant**Page object for each added child, which holds additional per-child properties. You obtain the **Gnome::Gtk4::Assistant**Page for a child with `.get-page()`.

GtkAssistant as GtkBuildable
============================

The **Gnome::Gtk4::Assistant** implementation of the *GtkBuildable* interface exposes the `$action_area` as internal children with the name “action_area”.

To add pages to an assistant in *GtkBuilder*, simply add it as a child to the **Gnome::Gtk4::Assistant** object. If you need to set per-object properties, create a **Gnome::Gtk4::Assistant**Page object explicitly, and set the child widget as a property on it.

CSS nodes
=========

**Gnome::Gtk4::Assistant** has a single CSS node with the name window and style class .assistant.

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

new-assistant
-------------

Creates a new **Gnome::Gtk4::Assistant**.

    method new-assistant ( --> Gnome::Gtk4::Assistant )

Methods
=======

add-action-widget
-----------------

Adds a widget to the action area of a **Gnome::Gtk4::Assistant**.

    method add-action-widget ( N-Object() $child )

  * $child; a *GtkWidget*.

append-page
-----------

Appends a page to the `$assistant`.

    method append-page ( N-Object() $page --> Int )

  * $page; a *GtkWidget*.

Return value; the index (starting at 0) of the inserted page. 

commit
------

Erases the visited page history.

GTK will then hide the back button on the current page, and removes the cancel button from subsequent pages.

Use this when the information provided up to the current page is hereafter deemed permanent and cannot be modified or undone. For example, showing a progress page to track a long-running, unreversible operation after the user has clicked apply on a confirmation page.

    method commit ( )

get-current-page
----------------

Returns the page number of the current page.

    method get-current-page (--> Int )

Return value; The index (starting from 0) of the current page in the `$assistant`, or -1 if the `$assistant` has no pages, or no current page. 

get-n-pages
-----------

Returns the number of pages in the `$assistant`

    method get-n-pages (--> Int )

Return value; the number of pages in the `$assistant`. 

get-nth-page
------------

Returns the child widget contained in page number `$page_num`.

    method get-nth-page ( Int() $page-num --> N-Object )

  * $page-num; the index of a page in the `$assistant`, or -1 to get the last page.

Return value; the child widget, or undefined if `$page_num` is out of bounds. 

get-page
--------

Returns the **Gnome::Gtk4::Assistant**Page object for `$child`.

    method get-page ( N-Object() $child --> N-Object )

  * $child; a child of `$assistant`.

Return value; the **Gnome::Gtk4::Assistant**Page for `$child`. 

get-page-complete
-----------------

Gets whether `$page` is complete.

    method get-page-complete ( N-Object() $page --> Bool )

  * $page; a page of `$assistant`.

Return value; %TRUE if `$page` is complete.. 

get-page-title
--------------

Gets the title for `$page`.

    method get-page-title ( N-Object() $page --> Str )

  * $page; a page of `$assistant`.

Return value; the title for `$page`. 

get-page-type
-------------

Gets the page type of `$page`.

    method get-page-type ( N-Object() $page --> GtkAssistantPageType )

  * $page; a page of `$assistant`.

Return value; the page type of `$page`. An enumeration.

get-pages
---------

Gets a list model of the assistant pages.

    method get-pages (--> N-List )

Return value; A list model of the pages.. 

insert-page
-----------

Inserts a page in the `$assistant` at a given position.

    method insert-page ( N-Object() $page, Int() $position --> Int )

  * $page; a *GtkWidget*.

  * $position; the index (starting at 0) at which to insert the page, or -1 to append the page to the `$assistant`.

Return value; the index (starting from 0) of the inserted page. 

next-page
---------

Navigate to the next page.

It is a programming error to call this function when there is no next page.

This function is for use when creating pages of the %GTK_ASSISTANT_PAGE_CUSTOM type.

    method next-page ( )

prepend-page
------------

Prepends a page to the `$assistant`.

    method prepend-page ( N-Object() $page --> Int )

  * $page; a *GtkWidget*.

Return value; the index (starting at 0) of the inserted page. 

previous-page
-------------

Navigate to the previous visited page.

It is a programming error to call this function when no previous page is available.

This function is for use when creating pages of the %GTK_ASSISTANT_PAGE_CUSTOM type.

    method previous-page ( )

remove-action-widget
--------------------

Removes a widget from the action area of a **Gnome::Gtk4::Assistant**.

    method remove-action-widget ( N-Object() $child )

  * $child; a *GtkWidget*.

remove-page
-----------

Removes the `$page_num`’s page from `$assistant`.

    method remove-page ( Int() $page-num )

  * $page-num; the index of a page in the `$assistant`, or -1 to remove the last page.

set-current-page
----------------

Switches the page to `$page_num`.

Note that this will only be necessary in custom buttons, as the `$assistant` flow can be set with gtk_assistant_set_forward_page_func().

    method set-current-page ( Int() $page-num )

  * $page-num; index of the page to switch to, starting from 0. If negative, the last page will be used. If greater than the number of pages in the `$assistant`, nothing will be done..

set-forward-page-func
---------------------

Sets the page forwarding function to be `$page_func`.

This function will be used to determine what will be the next page when the user presses the forward button. Setting `$page_func` to undefined will make the assistant to use the default forward function, which just goes to the next visible page.

    method set-forward-page-func ( &page-func, gpointer $data, … )

  * &page-func; the `GtkAssistantPageFunc`, or undefined to use the default one. Tthe function must be specified with following signature; `:( gint $current-page, gpointer $data --` gint )>.

  * $data; user data for `$page_func`.

  * destroy; destroy notifier for `$data`. Note that each argument must be specified as a type followed by its value!

set-page-complete
-----------------

Sets whether `$page` contents are complete.

This will make `$assistant` update the buttons state to be able to continue the task.

    method set-page-complete ( N-Object() $page, Bool() $complete )

  * $page; a page of `$assistant`.

  * $complete; the completeness status of the page.

set-page-title
--------------

Sets a title for `$page`.

The title is displayed in the header area of the assistant when `$page` is the current page.

    method set-page-title ( N-Object() $page, Str $title )

  * $page; a page of `$assistant`.

  * $title; the new title for `$page`.

set-page-type
-------------

Sets the page type for `$page`.

The page type determines the page behavior in the `$assistant`.

    method set-page-type ( N-Object() $page, GtkAssistantPageType $type )

  * $page; a page of `$assistant`.

  * $type; the new type for `$page`. An enumeration.

update-buttons-state
--------------------

Forces `$assistant` to recompute the buttons state.

GTK automatically takes care of this in most situations, e.g. when the user goes to a different page, or when the visibility or completeness of a page changes.

One situation where it can be necessary to call this function is when changing a value on the current page affects the future page flow of the assistant.

    method update-buttons-state ( )

Signals
=======

### apply

Emitted when the apply button is clicked.

The default behavior of the **Gnome::Gtk4::Assistant** is to switch to the page after the current page, unless the current page is the last one.

A handler for the ::apply signal should carry out the actions for which the wizard has collected data. If the action takes a long time to complete, you might consider putting a page of type %GTK_ASSISTANT_PAGE_PROGRESS after the confirmation page and handle this operation within the *prepare* signal of the progress page.

    method handler (
      Int :$_handle_id,
      Gnome::Gtk4::Assistant() :$_native-object,
      Gnome::Gtk4::Assistant :$_widget,
      *%user-options
    )

  * $_handle_id; The registered event handler id.

  * $_native-object; The native object provided by the Raku object which registered this event.

  * $_widget; The object which registered the signal. User code may have left the object going out of scope.

  * %user-options; A list of named arguments provided at the `.register-signal()` method from **Gnome::GObject::Object**.

### cancel

Emitted when then the cancel button is clicked.

    method handler (
      Int :$_handle_id,
      Gnome::Gtk4::Assistant() :$_native-object,
      Gnome::Gtk4::Assistant :$_widget,
      *%user-options
    )

  * $_handle_id; The registered event handler id.

  * $_native-object; The native object provided by the Raku object which registered this event.

  * $_widget; The object which registered the signal. User code may have left the object going out of scope.

  * %user-options; A list of named arguments provided at the `.register-signal()` method from **Gnome::GObject::Object**.

### close

Emitted either when the close button of a summary page is clicked, or when the apply button in the last page in the flow (of type %GTK_ASSISTANT_PAGE_CONFIRM) is clicked.

    method handler (
      Int :$_handle_id,
      Gnome::Gtk4::Assistant() :$_native-object,
      Gnome::Gtk4::Assistant :$_widget,
      *%user-options
    )

  * $_handle_id; The registered event handler id.

  * $_native-object; The native object provided by the Raku object which registered this event.

  * $_widget; The object which registered the signal. User code may have left the object going out of scope.

  * %user-options; A list of named arguments provided at the `.register-signal()` method from **Gnome::GObject::Object**.

### escape

The action signal for the Escape binding.

    method handler (
      Int :$_handle_id,
      Gnome::Gtk4::Assistant() :$_native-object,
      Gnome::Gtk4::Assistant :$_widget,
      *%user-options
    )

  * $_handle_id; The registered event handler id.

  * $_native-object; The native object provided by the Raku object which registered this event.

  * $_widget; The object which registered the signal. User code may have left the object going out of scope.

  * %user-options; A list of named arguments provided at the `.register-signal()` method from **Gnome::GObject::Object**.

### prepare

Emitted when a new page is set as the assistant's current page, before making the new page visible.

A handler for this signal can do any preparations which are necessary before showing `$page`.

    method handler (
      N-Object $page,
      Int :$_handle_id,
      Gnome::Gtk4::Assistant() :$_native-object,
      Gnome::Gtk4::Assistant :$_widget,
      *%user-options
    )

  * $page; the current page.

  * $_handle_id; The registered event handler id.

  * $_native-object; The native object provided by the Raku object which registered this event.

  * $_widget; The object which registered the signal. User code may have left the object going out of scope.

  * %user-options; A list of named arguments provided at the `.register-signal()` method from **Gnome::GObject::Object**.
