Project Description
-------------------

  * **Distribution:** Gnome::Gtk4

  * **Project description:** Modules for package Gnome::Gtk4:api<2>. The language binding to GNOME’s user interface toolkit version 4

  * **Project version:** 0.1.9

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

![](images/applicationwindow.png)

Description
===========

**Gnome::Gtk4::ApplicationWindow** is a *GtkWindow* subclass that integrates with *GtkApplication*.

Notably, **Gnome::Gtk4::ApplicationWindow** can handle an application menubar.

This class implements the *GActionGroup* and *GActionMap* interfaces, to let you add window-specific actions that will be exported by the associated [class `$Gtk`.Application], together with its application-wide actions. Window-specific actions are prefixed with the “win.” prefix and application-wide actions are prefixed with the “app.” prefix. Actions must be addressed with the prefixed name when referring to them from a *GMenuModel*.

Note that widgets that are placed inside a **Gnome::Gtk4::ApplicationWindow** can also activate these actions, if they implement the [iface `$Gtk`.Actionable] interface.

The settings *gtk-shell-shows-app-menu defined in Settings* and *gtk-shell-shows-menubar defined in Settings* tell GTK whether the desktop environment is showing the application menu and menubar models outside the application as part of the desktop shell. For instance, on OS X, both menus will be displayed remotely; on Windows neither will be.

If the desktop environment does not display the menubar, then **Gnome::Gtk4::ApplicationWindow** will automatically show a menubar for it. This behaviour can be overridden with the *show-menubar* property. If the desktop environment does not display the application menu, then it will automatically be included in the menubar or in the windows client-side decorations.

See [class `$Gtk`.PopoverMenu] for information about the XML language used by *GtkBuilder* for menu models.

See also: `.set-menubar() defined in Application`.

A GtkApplicationWindow with a menubar
-------------------------------------

The code sample below shows how to set up a **Gnome::Gtk4::ApplicationWindow** with a menu bar defined on the [class `$Gtk`.Application]:

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

new-applicationwindow
---------------------

Creates a new **Gnome::Gtk4::ApplicationWindow**.

    method new-applicationwindow ( N-Object() $application --> Gnome::Gtk4::ApplicationWindow )

  * $application; a *GtkApplication*.

Methods
=======

get-help-overlay
----------------

Gets the *GtkShortcutsWindow* that is associated with `$window`.

See `.set-help-overlay()`.

    method get-help-overlay (--> N-Object )

Return value; the help overlay associated with `$window`. 

get-id
------

Returns the unique ID of the window.

    If the window has not yet been added to a I<GtkApplication>, returns I<0>.

    method get-id (--> UInt )

Return value; the unique ID for `$window`, or *0* if the window has not yet been added to a *GtkApplication*. 

get-show-menubar
----------------

Returns whether the window will display a menubar for the app menu and menubar as needed.

    method get-show-menubar (--> Bool )

Return value; %TRUE if `$window` will display a menubar when needed. 

set-help-overlay
----------------

Associates a shortcuts window with the application window.

Additionally, sets up an action with the name *win.show-help-overlay* to present it. `$window` takes responsibility for destroying `$help_overlay`.

    method set-help-overlay ( N-Object() $help-overlay )

  * $help-overlay; a *GtkShortcutsWindow*.

set-show-menubar
----------------

Sets whether the window will display a menubar for the app menu and menubar as needed.

    method set-show-menubar ( Bool() $show-menubar )

  * $show-menubar; whether to show a menubar when needed.
