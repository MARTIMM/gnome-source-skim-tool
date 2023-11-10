Project Description
-------------------

  * **Distribution:** Gnome::Gtk4

  * **Project description:** Modules for package Gnome::Gtk4:api<2>. The language binding to GNOME’s user interface toolkit version 4

  * **Project version:** 0.1.7

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

![](images/window.png)

Description
===========

A **Gnome::Gtk4::Window** is a toplevel window which can contain other widgets.

![An example GtkWindow](window.png)

Windows normally have decorations that are under the control of the windowing system and allow the user to manipulate the window (resize it, move it, close it,...).

GtkWindow as GtkBuildable
=========================

The **Gnome::Gtk4::Window** implementation of the [iface `$Gtk`.Buildable] interface supports setting a child as the titlebar by specifying “titlebar” as the “type” attribute of a <child> element.

CSS nodes
=========

**Gnome::Gtk4::Window** has a main CSS node with name window and style class .background.

Style classes that are typically used with the main CSS node are .csd (when client-side decorations are in use), .solid-csd (for client-side decorations without invisible borders), .ssd (used by mutter when rendering server-side decorations). GtkWindow also represents window states with the following style classes on the main node: .maximized, .fullscreen, .tiled (when supported, also .tiled-top, .tiled-left, .tiled-right, .tiled-bottom).

**Gnome::Gtk4::Window** subclasses often add their own discriminating style classes, such as .dialog, .popup or .tooltip.

Generally, some CSS properties don't make sense on the toplevel window node, such as margins or padding. When client-side decorations without invisible borders are in use (i.e. the .solid-csd style class is added to the main window node), the CSS border of the toplevel window is used for resize drags. In the .csd case, the shadow area outside of the window can be used to resize it.

**Gnome::Gtk4::Window** adds the .titlebar and .default-decoration style classes to the widget that is added as a titlebar child.

Accessibility
=============

**Gnome::Gtk4::Window** uses the %GTK_ACCESSIBLE_ROLE_WINDOW role.

Actions
=======

**Gnome::Gtk4::Window** defines a set of built-in actions: - *default.activate*: Activate the default widget. - *window.minimize*: Minimize the window. - *window.toggle-maximized*: Maximize or restore the window. - *window.close*: Close the window.

Class initialization
====================

new
---

### :native-object

Create an object using a native object from elsewhere. See also **Gnome::N::TopLevelSupportClass**.

    multi method new ( N-GObject :$native-object! )

### :build-id

Create an object using a native object from a builder. See also **Gnome::GObject::Object**.

    multi method new ( Str :$build-id! )

Constructors
============

new
---

Creates a new **Gnome::Gtk4::Window**.

To get an undecorated window (no window borders), use `.set-decorated()`.

All top-level windows created by gtk_window_new() are stored in an internal top-level window list. This list can be obtained from `.Window.list-toplevels()`. Due to GTK keeping a reference to the window internally, gtk_window_new() does not return a reference to the caller.

To delete a **Gnome::Gtk4::Window**, call `.destroy()`.

    method new ( --> N-GObject() )

Return value; a new **Gnome::Gtk4::Window**.. 

Methods
=======

close
-----

Requests that the window is closed.

This is similar to what happens when a window manager close button is clicked.

This function can be used with close buttons in custom titlebars.

    method close (  )

destroy
-------

Drop the internal reference GTK holds on toplevel windows.

    method destroy (  )

fullscreen
----------

Asks to place `$window` in the fullscreen state.

Note that you shouldn’t assume the window is definitely fullscreen afterward, because other entities (e.g. the user or window manager unfullscreen it again, and not all window managers honor requests to fullscreen windows.

You can track the result of this operation via the [property `$Gdk`.Toplevel:state] property, or by listening to notifications of the *fullscreened* property.

    method fullscreen (  )

fullscreen-on-monitor
---------------------

Asks to place `$window` in the fullscreen state on the given `$monitor`.

Note that you shouldn't assume the window is definitely fullscreen afterward, or that the windowing system allows fullscreen windows on any given monitor.

You can track the result of this operation via the [property `$Gdk`.Toplevel:state] property, or by listening to notifications of the *fullscreened* property.

    method fullscreen-on-monitor (  N-GObject() $monitor )

  * $monitor; which monitor to go fullscreen on.

get-application
---------------

Gets the *GtkApplication* associated with the window.

    method get-application ( --> N-GObject() )

Return value; a *GtkApplication*. 

get-child
---------

Gets the child widget of `$window`.

    method get-child ( --> N-GObject() )

Return value; the child widget of `$window`. 

get-decorated
-------------

Returns whether the window has been set to have decorations.

    method get-decorated ( --> Bool() )

Return value; %TRUE if the window has been set to have decorations. 

get-default-size
----------------

Gets the default size of the window.

A value of 0 for the width or height indicates that a default size has not been explicitly set for that dimension, so the “natural” size of the window will be used.

    method get-default-size (  Array[Int] $width, Array[Int] $height )

  * $width; (transfer ownership: full) location to store the default width.

  * $height; (transfer ownership: full) location to store the default height.

get-default-widget
------------------

Returns the default widget for `$window`.

    method get-default-widget ( --> N-GObject() )

Return value; the default widget. 

get-deletable
-------------

Returns whether the window has been set to have a close button.

    method get-deletable ( --> Bool() )

Return value; %TRUE if the window has been set to have a close button. 

get-destroy-with-parent
-----------------------

Returns whether the window will be destroyed with its transient parent.

    method get-destroy-with-parent ( --> Bool() )

Return value; %TRUE if the window will be destroyed with its transient parent.. 

get-focus
---------

Retrieves the current focused widget within the window.

Note that this is the widget that would have the focus if the toplevel window focused; if the toplevel window is not focused then *gtk_widget_has_focus (widget)* will not be %TRUE for the widget.

    method get-focus ( --> N-GObject() )

Return value; the currently focused widget. 

get-focus-visible
-----------------

Gets whether “focus rectangles” are supposed to be visible.

    method get-focus-visible ( --> Bool() )

Return value; %TRUE if “focus rectangles” are supposed to be visible in this window.. 

get-group
---------

Returns the group for `$window`.

If the window has no group, then the default group is returned.

    method get-group ( --> N-GObject() )

Return value; the **Gnome::Gtk4::Window**Group for a window or the default group. 

get-handle-menubar-accel
------------------------

Returns whether this window reacts to F10 key presses by activating a menubar it contains.

    method get-handle-menubar-accel ( --> Bool() )

Return value; %TRUE if the window handles F10. 

get-hide-on-close
-----------------

Returns whether the window will be hidden when the close button is clicked.

    method get-hide-on-close ( --> Bool() )

Return value; %TRUE if the window will be hidden. 

get-icon-name
-------------

Returns the name of the themed icon for the window.

    method get-icon-name ( --> Str )

Return value; the icon name. 

get-mnemonics-visible
---------------------

Gets whether mnemonics are supposed to be visible.

    method get-mnemonics-visible ( --> Bool() )

Return value; %TRUE if mnemonics are supposed to be visible in this window.. 

get-modal
---------

Returns whether the window is modal.

    method get-modal ( --> Bool() )

Return value; %TRUE if the window is set to be modal and establishes a grab when shown. 

get-resizable
-------------

Gets the value set by gtk_window_set_resizable().

    method get-resizable ( --> Bool() )

Return value; %TRUE if the user can resize the window. 

get-title
---------

Retrieves the title of the window.

    method get-title ( --> Str )

Return value; the title of the window. 

get-titlebar
------------

Returns the custom titlebar that has been set with gtk_window_set_titlebar().

    method get-titlebar ( --> N-GObject() )

Return value; the custom titlebar. 

get-transient-for
-----------------

Fetches the transient parent for this window.

    method get-transient-for ( --> N-GObject() )

Return value; the transient parent for this window. 

has-group
---------

Returns whether `$window` has an explicit window group.

    method has-group ( --> Bool() )

Return value; %TRUE if `$window` has an explicit window group.. 

is-active
---------

Returns whether the window is part of the current active toplevel.

The active toplevel is the window receiving keystrokes.

The return value is %TRUE if the window is active toplevel itself. You might use this function if you wanted to draw a widget differently in an active window from a widget in an inactive window.

    method is-active ( --> Bool() )

Return value; %TRUE if the window part of the current active window.. 

is-fullscreen
-------------

Retrieves the current fullscreen state of `$window`.

Note that since fullscreening is ultimately handled by the window manager and happens asynchronously to an application request, you shouldn’t assume the return value of this function changing immediately (or at all), as an effect of calling `.fullscreen()` or `.unfullscreen() defined in Window`.

If the window isn't yet mapped, the value returned will whether the initial requested state is fullscreen.

    method is-fullscreen ( --> Bool() )

Return value; whether the window has a fullscreen state.. 

is-maximized
------------

Retrieves the current maximized state of `$window`.

Note that since maximization is ultimately handled by the window manager and happens asynchronously to an application request, you shouldn’t assume the return value of this function changing immediately (or at all), as an effect of calling `.maximize()` or `.unmaximize() defined in Window`.

If the window isn't yet mapped, the value returned will whether the initial requested state is maximized.

    method is-maximized ( --> Bool() )

Return value; whether the window has a maximized state.. 

maximize
--------

Asks to maximize `$window`, so that it fills the screen.

Note that you shouldn’t assume the window is definitely maximized afterward, because other entities (e.g. the user or window manager could unmaximize it again, and not all window managers support maximization.

It’s permitted to call this function before showing a window, in which case the window will be maximized when it appears onscreen initially.

You can track the result of this operation via the [property `$Gdk`.Toplevel:state] property, or by listening to notifications on the *maximized* property.

    method maximize (  )

minimize
--------

Asks to minimize the specified `$window`.

Note that you shouldn’t assume the window is definitely minimized afterward, because the windowing system might not support this functionality; other entities (e.g. the user or the window manager could unminimize it again, or there may not be a window manager in which case minimization isn’t possible, etc.

It’s permitted to call this function before showing a window, in which case the window will be minimized before it ever appears onscreen.

You can track result of this operation via the [property `$Gdk`.Toplevel:state] property.

    method minimize (  )

present
-------

Presents a window to the user.

This function should not be used as when it is called, it is too late to gather a valid timestamp to allow focus stealing prevention to work correctly.

    method present (  )

present-with-time
-----------------

Presents a window to the user.

This may mean raising the window in the stacking order, unminimizing it, moving it to the current desktop, and/or giving it the keyboard focus, possibly dependent on the user’s platform, window manager, and preferences.

If `$window` is hidden, this function calls `.show() defined in Widget` as well.

This function should be used when the user tries to open a window that’s already open. Say for example the preferences dialog is currently open, and the user chooses Preferences from the menu a second time; use `.present()` to move the already-open dialog where the user can see it.

Presents a window to the user in response to a user interaction. The timestamp should be gathered when the window was requested to be shown (when clicking a link for example), rather than once the window is ready to be shown.

    method present-with-time (  UInt() $timestamp )

  * $timestamp; the timestamp of the user interaction (typically a button or key press event) which triggered this call.

set-application
---------------

Sets or unsets the *GtkApplication* associated with the window.

The application will be kept alive for at least as long as it has any windows associated with it (see g_application_hold() for a way to keep it alive without windows).

Normally, the connection between the application and the window will remain until the window is destroyed, but you can explicitly remove it by setting the `$application` to %NULL.

This is equivalent to calling `.remove-window() defined in Application` and/or `.add-window() defined in Application` on the old/new applications as relevant.

    method set-application (  N-GObject() $application )

  * $application; a *GtkApplication*, or %NULL to unset.

set-child
---------

Sets the child widget of `$window`.

    method set-child (  N-GObject() $child )

  * $child; the child widget.

set-decorated
-------------

Sets whether the window should be decorated.

By default, windows are decorated with a title bar, resize controls, etc. Some window managers allow GTK to disable these decorations, creating a borderless window. If you set the decorated property to %FALSE using this function, GTK will do its best to convince the window manager not to decorate the window. Depending on the system, this function may not have any effect when called on a window that is already visible, so you should call it before calling `.show() defined in Widget`.

On Windows, this function always works, since there’s no window manager policy involved.

    method set-decorated (  Bool() $setting )

  * $setting; %TRUE to decorate the window.

set-default-size
----------------

Sets the default size of a window.

If the window’s “natural” size (its size request) is larger than the default, the default will be ignored.

Unlike `.set-size-request() defined in Widget`, which sets a size request for a widget and thus would keep users from shrinking the window, this function only sets the initial size, just as if the user had resized the window themselves. Users can still shrink the window again as they normally would. Setting a default size of -1 means to use the “natural” default size (the size request of the window).

The default size of a window only affects the first time a window is shown; if a window is hidden and re-shown, it will remember the size it had prior to hiding, rather than using the default size.

Windows can’t actually be 0x0 in size, they must be at least 1x1, but passing 0 for `$width` and `$height` is OK, resulting in a 1x1 default size.

If you use this function to reestablish a previously saved window size, note that the appropriate size to save is the one returned by `.get-default-size()`. Using the window allocation directly will not work in all circumstances and can lead to growing or shrinking windows.

    method set-default-size (  Int() $width, Int() $height )

  * $width; width in pixels, or -1 to unset the default width.

  * $height; height in pixels, or -1 to unset the default height.

set-default-widget
------------------

Sets the default widget.

The default widget is the widget that is activated when the user presses Enter in a dialog (for example).

    method set-default-widget (  N-GObject() $default-widget )

  * $default-widget; widget to be the default to unset the default widget for the toplevel.

set-deletable
-------------

Sets whether the window should be deletable.

By default, windows have a close button in the window frame. Some window managers allow GTK to disable this button. If you set the deletable property to %FALSE using this function, GTK will do its best to convince the window manager not to show a close button. Depending on the system, this function may not have any effect when called on a window that is already visible, so you should call it before calling `.show() defined in Widget`.

On Windows, this function always works, since there’s no window manager policy involved.

    method set-deletable (  Bool() $setting )

  * $setting; %TRUE to decorate the window as deletable.

set-destroy-with-parent
-----------------------

If `$setting` is %TRUE, then destroying the transient parent of `$window` will also destroy `$window` itself.

This is useful for dialogs that shouldn’t persist beyond the lifetime of the main window they are associated with, for example.

    method set-destroy-with-parent (  Bool() $setting )

  * $setting; whether to destroy `$window` with its transient parent.

set-display
-----------

Sets the *GdkDisplay* where the `$window` is displayed.

If the window is already mapped, it will be unmapped, and then remapped on the new display.

    method set-display (  N-GObject() $display )

  * $display; a *GdkDisplay*.

set-focus
---------

Sets the focus widget.

If `$focus` is not the current focus widget, and is focusable, sets it as the focus widget for the window. If `$focus` is %NULL, unsets the focus widget for this window. To set the focus to a particular widget in the toplevel, it is usually more convenient to use `.grab-focus() defined in Widget` instead of this function.

    method set-focus (  N-GObject() $focus )

  * $focus; widget to be the new focus widget, or %NULL to unset any focus widget for the toplevel window..

set-focus-visible
-----------------

Sets whether “focus rectangles” are supposed to be visible.

    method set-focus-visible (  Bool() $setting )

  * $setting; the new value.

set-handle-menubar-accel
------------------------

Sets whether this window should react to F10 key presses by activating a menubar it contains.

    method set-handle-menubar-accel (  Bool() $handle-menubar-accel )

  * $handle-menubar-accel; %TRUE to make `$window` handle F10.

set-hide-on-close
-----------------

If `$setting` is %TRUE, then clicking the close button on the window will not destroy it, but only hide it.

    method set-hide-on-close (  Bool() $setting )

  * $setting; whether to hide the window when it is closed.

set-icon-name
-------------

Sets the icon for the window from a named themed icon.

See the docs for [class `$Gtk`.IconTheme] for more details. On some platforms, the window icon is not used at all.

Note that this has nothing to do with the WM_ICON_NAME property which is mentioned in the ICCCM.

    method set-icon-name (  Str $name )

  * $name; the name of the themed icon.

set-mnemonics-visible
---------------------

Sets whether mnemonics are supposed to be visible.

    method set-mnemonics-visible (  Bool() $setting )

  * $setting; the new value.

set-modal
---------

Sets a window modal or non-modal.

Modal windows prevent interaction with other windows in the same application. To keep modal dialogs on top of main application windows, use `.set-transient-for()` to make the dialog transient for the parent; most window managers will then disallow lowering the dialog below the parent.

    method set-modal (  Bool() $modal )

  * $modal; whether the window is modal.

set-resizable
-------------

Sets whether the user can resize a window.

Windows are user resizable by default.

    method set-resizable (  Bool() $resizable )

  * $resizable; %TRUE if the user can resize this window.

set-startup-id
--------------

Sets the startup notification ID.

Startup notification identifiers are used by desktop environment to track application startup, to provide user feedback and other features. This function changes the corresponding property on the underlying *GdkSurface*.

Normally, startup identifier is managed automatically and you should only use this function in special cases like transferring focus from other processes. You should use this function before calling `.present()` or any equivalent function generating a window map event.

This function is only useful on X11, not with other GTK targets.

    method set-startup-id (  Str $startup-id )

  * $startup-id; a string with startup-notification identifier.

set-title
---------

Sets the title of the **Gnome::Gtk4::Window**.

The title of a window will be displayed in its title bar; on the X Window System, the title bar is rendered by the window manager so exactly how the title appears to users may vary according to a user’s exact configuration. The title should help a user distinguish this window from other windows they may have open. A good title might include the application name and current document filename, for example.

Passing %NULL does the same as setting the title to an empty string.

    method set-title (  Str $title )

  * $title; title of the window.

set-titlebar
------------

Sets a custom titlebar for `$window`.

A typical widget used here is [class `$Gtk`.HeaderBar], as it provides various features expected of a titlebar while allowing the addition of child widgets to it.

If you set a custom titlebar, GTK will do its best to convince the window manager not to put its own titlebar on the window. Depending on the system, this function may not work for a window that is already visible, so you set the titlebar before calling `.show() defined in Widget`.

    method set-titlebar (  N-GObject() $titlebar )

  * $titlebar; the widget to use as titlebar.

set-transient-for
-----------------

Dialog windows should be set transient for the main application window they were spawned from. This allows window managers to e.g. keep the dialog on top of the main window, or center the dialog over the main window. [ctor `$Gtk`.Dialog.new_with_buttons] and other convenience functions in GTK will sometimes call gtk_window_set_transient_for() on your behalf.

Passing %NULL for `$parent` unsets the current transient window.

On Windows, this function puts the child window on top of the parent, much as the window manager would have done on X.

    method set-transient-for (  N-GObject() $parent )

  * $parent; parent window.

unfullscreen
------------

Asks to remove the fullscreen state for `$window`, and return to its previous state.

Note that you shouldn’t assume the window is definitely not fullscreen afterward, because other entities (e.g. the user or window manager could fullscreen it again, and not all window managers honor requests to unfullscreen windows; normally the window will end up restored to its normal state. Just don’t write code that crashes if not.

You can track the result of this operation via the [property `$Gdk`.Toplevel:state] property, or by listening to notifications of the *fullscreened* property.

    method unfullscreen (  )

unmaximize
----------

Asks to unmaximize `$window`.

Note that you shouldn’t assume the window is definitely unmaximized afterward, because other entities (e.g. the user or window manager maximize it again, and not all window managers honor requests to unmaximize.

You can track the result of this operation via the [property `$Gdk`.Toplevel:state] property, or by listening to notifications on the *maximized* property.

    method unmaximize (  )

unminimize
----------

Asks to unminimize the specified `$window`.

Note that you shouldn’t assume the window is definitely unminimized afterward, because the windowing system might not support this functionality; other entities (e.g. the user or the window manager could minimize it again, or there may not be a window manager in which case minimization isn’t possible, etc.

You can track result of this operation via the [property `$Gdk`.Toplevel:state] property.

    method unminimize (  )

Functions
=========

get-default-icon-name
---------------------

Returns the fallback icon name for windows.

The returned string is owned by GTK and should not be modified. It is only valid until the next call to `.Window.set-default-icon-name()`.

    method get-default-icon-name ( --> Str )

Return value; the fallback icon name for windows. 

get-toplevels
-------------

Returns a list of all existing toplevel windows.

If you want to iterate through the list and perform actions involving callbacks that might destroy the widgets or add new ones, be aware that the list of toplevels will change and emit the "items-changed" signal.

    method get-toplevels ( --> N-List() )

Return value; the list of toplevel widgets. 

list-toplevels
--------------

Returns a list of all existing toplevel windows.

The widgets in the list are not individually referenced. If you want to iterate through the list and perform actions involving callbacks that might destroy the widgets, you must call *g_list_foreach (result, (GFunc)g_object_ref, NULL)* first, and then unref all the widgets afterwards.

    method list-toplevels ( --> N-List() )

Return value; list of toplevel widgets. 

set-auto-startup-notification
-----------------------------

Sets whether the window should request startup notification.

By default, after showing the first **Gnome::Gtk4::Window**, GTK calls [method `$Gdk`.Display.notify_startup_complete]. Call this function to disable the automatic startup notification. You might do this if your first window is a splash screen, and you want to delay notification until after your real main window has been shown, for example.

In that example, you would disable startup notification temporarily, show your splash screen, then re-enable it so that showing the main window would automatically result in notification.

    method set-auto-startup-notification (  Bool() $setting )

  * $setting; %TRUE to automatically do startup notification.

set-default-icon-name
---------------------

Sets an icon to be used as fallback.

The fallback icon is used for windows that haven't had `.set-icon-name()` called on them.

    method set-default-icon-name (  Str $name )

  * $name; the name of the themed icon.

set-interactive-debugging
-------------------------

Opens or closes the [interactive debugger](running.html#interactive-debugging).

The debugger offers access to the widget hierarchy of the application and to useful debugging tools.

    method set-interactive-debugging (  Bool() $enable )

  * $enable; %TRUE to enable interactive debugging.

Signals
=======

### activate-default

Emitted when the user activates the default widget of `$window`.

This is a [keybinding signal](class.SignalAction.html).

    method handler (
      Int :$_handle_id,
      Gnome::Gtk4::Window() :$_native-object,
      Gnome::Gtk4::Window :$_widget,
      *%user-options
    )

  * $_handle_id; The registered event handler id.

  * $_native-object; The native object provided by the Raku object which registered this event.

  * $_widget; The object which registered the signal. User code may have left the object going out of scope.

  * %user-options; A list of named arguments provided at the `.register-signal()` method from **Gnome::GObject::Object**.

### activate-focus

Emitted when the user activates the currently focused widget of `$window`.

This is a [keybinding signal](class.SignalAction.html).

    method handler (
      Int :$_handle_id,
      Gnome::Gtk4::Window() :$_native-object,
      Gnome::Gtk4::Window :$_widget,
      *%user-options
    )

  * $_handle_id; The registered event handler id.

  * $_native-object; The native object provided by the Raku object which registered this event.

  * $_widget; The object which registered the signal. User code may have left the object going out of scope.

  * %user-options; A list of named arguments provided at the `.register-signal()` method from **Gnome::GObject::Object**.

### close-request

Emitted when the user clicks on the close button of the window.

    method handler (
      Int :$_handle_id,
      Gnome::Gtk4::Window() :$_native-object,
      Gnome::Gtk4::Window :$_widget,
      *%user-options
      --> gboolean
    )

  * $_handle_id; The registered event handler id.

  * $_native-object; The native object provided by the Raku object which registered this event.

  * $_widget; The object which registered the signal. User code may have left the object going out of scope.

  * %user-options; A list of named arguments provided at the `.register-signal()` method from **Gnome::GObject::Object**.

Return value; %TRUE to stop other handlers from being invoked for the signal

### enable-debugging

Emitted when the user enables or disables interactive debugging.

When `$toggle` is %TRUE, interactive debugging is toggled on or off, when it is %FALSE, the debugger will be pointed at the widget under the pointer.

This is a [keybinding signal](class.SignalAction.html).

The default bindings for this signal are Ctrl-Shift-I and Ctrl-Shift-D.

    method handler (
      gboolean $toggle,
      Int :$_handle_id,
      Gnome::Gtk4::Window() :$_native-object,
      Gnome::Gtk4::Window :$_widget,
      *%user-options
      --> gboolean
    )

  * $toggle; toggle the debugger.

  * $_handle_id; The registered event handler id.

  * $_native-object; The native object provided by the Raku object which registered this event.

  * $_widget; The object which registered the signal. User code may have left the object going out of scope.

  * %user-options; A list of named arguments provided at the `.register-signal()` method from **Gnome::GObject::Object**.

Return value; %TRUE if the key binding was handled

### keys-changed

emitted when the set of accelerators or mnemonics that are associated with `$window` changes.

    method handler (
      Int :$_handle_id,
      Gnome::Gtk4::Window() :$_native-object,
      Gnome::Gtk4::Window :$_widget,
      *%user-options
    )

  * $_handle_id; The registered event handler id.

  * $_native-object; The native object provided by the Raku object which registered this event.

  * $_widget; The object which registered the signal. User code may have left the object going out of scope.

  * %user-options; A list of named arguments provided at the `.register-signal()` method from **Gnome::GObject::Object**.
