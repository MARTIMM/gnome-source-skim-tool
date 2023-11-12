Project Description
-------------------

  * **Distribution:** Gnome::Gtk4

  * **Project description:** Modules for package Gnome::Gtk4:api<2>. The language binding to GNOME’s user interface toolkit version 4

  * **Project version:** 0.1.7

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

![](images/application.png)

Description
===========

**Gnome::Gtk4::Application** is a high-level API for writing applications.

It supports many aspects of writing a GTK application in a convenient fashion, without enforcing a one-size-fits-all model.

Currently, **Gnome::Gtk4::Application** handles GTK initialization, application uniqueness, session management, provides some basic scriptability and desktop shell integration by exporting actions and menus and manages a list of toplevel windows whose life-cycle is automatically tied to the life-cycle of your application.

While **Gnome::Gtk4::Application** works fine with plain [class `$Gtk`.Window]s, it is recommended to use it together with [class `$Gtk`.ApplicationWindow].

Automatic resources
-------------------

**Gnome::Gtk4::Application** will automatically load menus from the *GtkBuilder* resource located at "gtk/menus.ui", relative to the application's resource base path (see [method `$Gio`.Application.set_resource_base_path]). The menu with the ID "menubar" is taken as the application's menubar. Additional menus (most interesting submenus) can be named and accessed via `.get-menu-by-id()` which allows for dynamic population of a part of the menu structure.

It is also possible to provide the menubar manually using `.set-menubar()`.

**Gnome::Gtk4::Application** will also automatically setup an icon search path for the default icon theme by appending "icons" to the resource base path. This allows your application to easily store its icons as resources. See `.add-resource-path() defined in IconTheme` for more information.

If there is a resource located at *gtk/help-overlay.ui* which defines a [class `$Gtk`.ShortcutsWindow] with ID *help_overlay* then **Gnome::Gtk4::Application** associates an instance of this shortcuts window with each [class `$Gtk`.ApplicationWindow] and sets up the keyboard accelerator <kbd>Control</kbd>+<kbd>?</kbd> to open it. To create a menu item that displays the shortcuts window, associate the item with the action *win.show-help-overlay*.

A simple application
--------------------

[A simple example](https://gitlab.gnome.org/GNOME/gtk/tree/main/examples/bp/bloatpad.c) is available in the GTK source code repository

**Gnome::Gtk4::Application** optionally registers with a session manager of the users session (if you set the *register-session* property) and offers various functionality related to the session life-cycle.

An application can block various ways to end the session with the `.inhibit()` function. Typical use cases for this kind of inhibiting are long-running, uninterruptible operations, such as burning a CD or performing a disk backup. The session manager may not honor the inhibitor, but it can be expected to inform the user about the negative consequences of ending the session while inhibitors are present.

See Also
--------

[HowDoI: Using GtkApplication](https://wiki.gnome.org/HowDoI/GtkApplication), [Getting Started with GTK: Basics](getting_started.html#basics)

Class initialization
====================

new
---

### :native-object

Create an object using a native object from elsewhere. See also **Gnome::N::TopLevelSupportClass**.

    multi method new ( N-GObject :$native-object! )

new-application
---------------

Creates a new **Gnome::Gtk4::Application** instance.

When using **Gnome::Gtk4::Application**, it is not necessary to call `.init()` manually. It is called as soon as the application gets registered as the primary instance.

Concretely, `.init()` is called in the default handler for the *GApplication::startup* signal. Therefore, **Gnome::Gtk4::Application** subclasses should always chain up in their *GApplication::startup* handler before using any GTK API.

Note that commandline arguments are not passed to `.init()`.

If *application_id* is not %NULL, then it must be valid. See `g_application_id_is_valid()`.

If no application ID is given then some features (most notably application uniqueness) will be disabled.

    method new-application (
      --> Gnome::Gtk4::Application
    )

Methods
=======

add-window
----------

Adds a window to *application*.

This call can only happen after the *application* has started; typically, you should add new application windows in response to the emission of the *GApplication::activate* signal.

This call is equivalent to setting the *application defined in Window* property of *window* to *application*.

Normally, the connection between the application and the window will remain until the window is destroyed, but you can explicitly remove it with `.remove-window()`.

GTK will keep the *application* running as long as it has any windows.

    method add-window (  N-GObject() $window )

  * $window; a *GtkWindow*.

get-accels-for-action
---------------------

Gets the accelerators that are currently associated with the given action.

    method get-accels-for-action (  Str $detailed-action-name --> Array[Str] )

  * $detailed-action-name; a detailed action name, specifying an action and target to obtain accelerators for.

Return value; accelerators for *detailed_action_name*. 

get-actions-for-accel
---------------------

Returns the list of actions (possibly empty) that `accel` maps to.

Each item in the list is a detailed action name in the usual form.

This might be useful to discover if an accel already exists in order to prevent installation of a conflicting accelerator (from an accelerator editor or a plugin system, for example). Note that having more than one action per accelerator may not be a bad thing and might make sense in cases where the actions never appear in the same context.

In case there are no actions for a given accelerator, an empty array is returned. undefined is never returned.

It is a programmer error to pass an invalid accelerator string.

If you are unsure, check it with `.accelerator-parse()` first.

    method get-actions-for-accel (  Str $accel --> Array[Str] )

  * $accel; an accelerator that can be parsed by `.accelerator-parse()`.

Return value; a %NULL-terminated array of actions for *accel*. 

get-active-window
-----------------

Gets the “active” window for the application.

The active window is the one that was most recently focused (within the application). This window may not have the focus at the moment if another application has it — this is just the most recently-focused window within this application.

    method get-active-window ( --> N-GObject() )

Return value; the active window. 

get-menu-by-id
--------------

Gets a menu from automatically loaded resources.

See [the section on Automatic resources](class.Application.html#automatic-resources) for more information.

    method get-menu-by-id (  Str $id --> N-GObject() )

  * $id; the id of the menu to look up.

Return value; Gets the menu with the given id from the automatically loaded resources. 

get-menubar
-----------

Returns the menu model that has been set with `.set-menubar()`.

    method get-menubar ( --> N-GObject() )

Return value; the menubar for windows of *application*. 

get-window-by-id
----------------

Returns the [class `$Gtk`.ApplicationWindow] with the given ID.

The ID of a **Gnome::Gtk4::Application**Window can be retrieved with `.get-id() defined in ApplicationWindow`.

    method get-window-by-id (  UInt() $id --> N-GObject() )

  * $id; an identifier number.

Return value; the window for the given *id*. 

get-windows
-----------

Gets a list of the [class `$Gtk`.Window] instances associated with *application*.

The list is sorted by most recently focused window, such that the first element is the currently focused window. (Useful for choosing a parent for a transient window.)

The list that is returned should not be modified in any way. It will only remain valid until the next focus change or window creation or deletion.

    method get-windows ( --> N-List() )

Return value; a *GList* of *GtkWindow* instances. 

inhibit
-------

Inform the session manager that certain types of actions should be inhibited.

This is not guaranteed to work on all platforms and for all types of actions.

Applications should invoke this method when they begin an operation that should not be interrupted, such as creating a CD or DVD. The types of actions that may be blocked are specified by the *flags* parameter. When the application completes the operation it should call `.uninhibit()` to remove the inhibitor. Note that an application can have multiple inhibitors, and all of them must be individually removed. Inhibitors are also cleared when the application exits.

Applications should not expect that they will always be able to block the action. In most cases, users will be given the option to force the action to take place.

The *reason* message should be short and to the point.

If *window* is given, the session manager may point the user to this window to find out more about why the action is inhibited.

    method inhibit (  N-GObject() $window, UInt $flags, Str $reason --> UInt() )

  * $window; a *GtkWindow*.

  * $flags; what types of actions should be inhibited. A bitmap.

  * $reason; a short, human-readable string that explains why these operations are inhibited.

Return value; A non-zero cookie that is used to uniquely identify this request. It should be used as an argument to `.uninhibit()` in order to remove the request. If the platform does not support inhibiting or the request failed for some reason, 0 is returned.. 

list-action-descriptions
------------------------

Lists the detailed action names which have associated accelerators.

See `.set-accels-for-action()`.

    method list-action-descriptions ( --> Array[Str] )

Return value; the detailed action names. 

remove-window
-------------

Remove a window from *window*.

If *window* belongs to *application* then this call is equivalent to setting the *application defined in Window* property of *window* to undefined.

The application may stop running as a result of a call to this function, if *window* was the last window of the *application*.

    method remove-window (  N-GObject() $window )

  * $window; a *GtkWindow*.

set-accels-for-action
---------------------

Sets zero or more keyboard accelerators that will trigger the given action.

The first item in *accels* will be the primary accelerator, which may be displayed in the UI.

To remove all accelerators for an action, use an empty, zero-terminated array for *accels*.

For the *detailed_action_name*, see `g_action_parse_detailed_name()` and `g_action_print_detailed_name()`.

    method set-accels-for-action (  Str $detailed-action-name, Array[Str] $accels )

  * $detailed-action-name; a detailed action name, specifying an action and target to associate accelerators with.

  * $accels; a list of accelerators in the format understood by `.accelerator-parse()`.

set-menubar
-----------

Sets or unsets the menubar for windows of *application*.

This is a menubar in the traditional sense.

This can only be done in the primary instance of the application, after it has been registered. *GApplication::startup* is a good place to call this.

Depending on the desktop environment, this may appear at the top of each window, or at the top of the screen. In some environments, if both the application menu and the menubar are set, the application menu will be presented as if it were the first item of the menubar. Other environments treat the two as completely separate — for example, the application menu may be rendered by the desktop shell while the menubar (if set) remains in each individual window.

Use the base *GActionMap* interface to add actions, to respond to the user selecting these menu items.

    method set-menubar (  N-GObject() $menubar )

  * $menubar; a *GMenuModel*.

uninhibit
---------

Removes an inhibitor that has been previously established.

See `.inhibit()`.

Inhibitors are also cleared when the application exits.

    method uninhibit (  UInt() $cookie )

  * $cookie; a cookie that was returned by `.inhibit()`.

Signals
=======

### query-end

Emitted when the session manager is about to end the session.

This signal is only emitted if *register-session* is `True`. Applications can connect to this signal and call `.inhibit()` with *GTK_APPLICATION_INHIBIT_LOGOUT* to delay the end of the session until state has been saved.

    method handler (
      Int :$_handle_id,
      Gnome::Gtk4::Application() :$_native-object,
      Gnome::Gtk4::Application :$_widget,
      *%user-options
    )

  * $_handle_id; The registered event handler id.

  * $_native-object; The native object provided by the Raku object which registered this event.

  * $_widget; The object which registered the signal. User code may have left the object going out of scope.

  * %user-options; A list of named arguments provided at the `.register-signal()` method from **Gnome::GObject::Object**.

### window-added

Emitted when a [class `$Gtk`.Window] is added to *application* through `.add-window()`.

    method handler (
      N-GObject $window,
      Int :$_handle_id,
      Gnome::Gtk4::Application() :$_native-object,
      Gnome::Gtk4::Application :$_widget,
      *%user-options
    )

  * $window; the newly-added [class `$Gtk`.Window].

  * $_handle_id; The registered event handler id.

  * $_native-object; The native object provided by the Raku object which registered this event.

  * $_widget; The object which registered the signal. User code may have left the object going out of scope.

  * %user-options; A list of named arguments provided at the `.register-signal()` method from **Gnome::GObject::Object**.

### window-removed

Emitted when a [class `$Gtk`.Window] is removed from *application*.

This can happen as a side-effect of the window being destroyed or explicitly through `.remove-window()`.

    method handler (
      N-GObject $window,
      Int :$_handle_id,
      Gnome::Gtk4::Application() :$_native-object,
      Gnome::Gtk4::Application :$_widget,
      *%user-options
    )

  * $window; the [class `$Gtk`.Window] that is being removed.

  * $_handle_id; The registered event handler id.

  * $_native-object; The native object provided by the Raku object which registered this event.

  * $_widget; The object which registered the signal. User code may have left the object going out of scope.

  * %user-options; A list of named arguments provided at the `.register-signal()` method from **Gnome::GObject::Object**.
