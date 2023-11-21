Project Description
-------------------

  * **Distribution:** Gnome::Gtk4

  * **Project description:** Modules for package Gnome::Gtk4:api<2>. The language binding to GNOME’s user interface toolkit version 4

  * **Project version:** 0.1.9

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

![](images/filechooserwidget.png)

Description
===========

**Gnome::Gtk4::FileChooserWidget** is a widget for choosing files.

It exposes the [iface `$Gtk`.FileChooser] interface, and you should use the methods of this interface to interact with the widget.

CSS nodes
=========

**Gnome::Gtk4::FileChooserWidget** has a single CSS node with name filechooser.

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

new-filechooserwidget
---------------------

Creates a new **Gnome::Gtk4::FileChooserWidget**.

This is a file chooser widget that can be embedded in custom windows, and it is the same widget that is used by *GtkFileChooserDialog*.

    method new-filechooserwidget ( GtkFileChooserAction $action --> Gnome::Gtk4::FileChooserWidget )

  * $action; Open or save mode for the widget. An enumeration.

Signals
=======

### desktop-folder

Emitted when the user asks for it.

This is a [keybinding signal](class.SignalAction.html).

This is used to make the file chooser show the user's Desktop folder in the file list.

The default binding for this signal is <kbd>Alt</kbd>-<kbd>/kbd.

    method handler (
      Int :$_handle_id,
      Gnome::Gtk4::FileChooserWidget() :$_native-object,
      Gnome::Gtk4::FileChooserWidget :$_widget,
      *%user-options
    )

  * $_handle_id; The registered event handler id.

  * $_native-object; The native object provided by the Raku object which registered this event.

  * $_widget; The object which registered the signal. User code may have left the object going out of scope.

  * %user-options; A list of named arguments provided at the `.register-signal()` method from **Gnome::GObject::Object**.

### down-folder

Emitted when the user asks for it.

This is a [keybinding signal](class.SignalAction.html).

This is used to make the file chooser go to a child of the current folder in the file hierarchy. The subfolder that will be used is displayed in the path bar widget of the file chooser. For example, if the path bar is showing "/foo/bar/baz", with bar currently displayed, then this will cause the file chooser to switch to the "baz" subfolder.

The default binding for this signal is <kbd>Alt</kbd>-<kbd>Down</kbd>.

    method handler (
      Int :$_handle_id,
      Gnome::Gtk4::FileChooserWidget() :$_native-object,
      Gnome::Gtk4::FileChooserWidget :$_widget,
      *%user-options
    )

  * $_handle_id; The registered event handler id.

  * $_native-object; The native object provided by the Raku object which registered this event.

  * $_widget; The object which registered the signal. User code may have left the object going out of scope.

  * %user-options; A list of named arguments provided at the `.register-signal()` method from **Gnome::GObject::Object**.

### home-folder

Emitted when the user asks for it.

This is a [keybinding signal](class.SignalAction.html).

This is used to make the file chooser show the user's home folder in the file list.

The default binding for this signal is <kbd>Alt</kbd>-<kbd>Home</kbd>.

    method handler (
      Int :$_handle_id,
      Gnome::Gtk4::FileChooserWidget() :$_native-object,
      Gnome::Gtk4::FileChooserWidget :$_widget,
      *%user-options
    )

  * $_handle_id; The registered event handler id.

  * $_native-object; The native object provided by the Raku object which registered this event.

  * $_widget; The object which registered the signal. User code may have left the object going out of scope.

  * %user-options; A list of named arguments provided at the `.register-signal()` method from **Gnome::GObject::Object**.

### location-popup

Emitted when the user asks for it.

This is a [keybinding signal](class.SignalAction.html).

This is used to make the file chooser show a "Location" prompt which the user can use to manually type the name of the file he wishes to select.

The default bindings for this signal are <kbd>Control</kbd>-<kbd>[/kbd](/kbd) with a `$path` string of "" (the empty string). It is also bound to <kbd>/</kbd> with a `$path` string of "*/*" (a slash): this lets you type */* and immediately type a path name. On Unix systems, this is bound to <kbd>~</kbd> (tilde) with a `$path` string of "~" itself for access to home directories.

    method handler (
      Str $path,
      Int :$_handle_id,
      Gnome::Gtk4::FileChooserWidget() :$_native-object,
      Gnome::Gtk4::FileChooserWidget :$_widget,
      *%user-options
    )

  * $path; a string that gets put in the text entry for the file name.

  * $_handle_id; The registered event handler id.

  * $_native-object; The native object provided by the Raku object which registered this event.

  * $_widget; The object which registered the signal. User code may have left the object going out of scope.

  * %user-options; A list of named arguments provided at the `.register-signal()` method from **Gnome::GObject::Object**.

### location-popup-on-paste

Emitted when the user asks for it.

This is a [keybinding signal](class.SignalAction.html).

This is used to make the file chooser show a "Location" prompt when the user pastes into a **Gnome::Gtk4::FileChooserWidget**.

The default binding for this signal is <kbd>Control</kbd>-<kbd>/kbd.

    method handler (
      Int :$_handle_id,
      Gnome::Gtk4::FileChooserWidget() :$_native-object,
      Gnome::Gtk4::FileChooserWidget :$_widget,
      *%user-options
    )

  * $_handle_id; The registered event handler id.

  * $_native-object; The native object provided by the Raku object which registered this event.

  * $_widget; The object which registered the signal. User code may have left the object going out of scope.

  * %user-options; A list of named arguments provided at the `.register-signal()` method from **Gnome::GObject::Object**.

### location-toggle-popup

Emitted when the user asks for it.

This is a [keybinding signal](class.SignalAction.html).

This is used to toggle the visibility of a "Location" prompt which the user can use to manually type the name of the file he wishes to select.

The default binding for this signal is <kbd>Control</kbd>-<kbd>[/kbd](/kbd).

    method handler (
      Int :$_handle_id,
      Gnome::Gtk4::FileChooserWidget() :$_native-object,
      Gnome::Gtk4::FileChooserWidget :$_widget,
      *%user-options
    )

  * $_handle_id; The registered event handler id.

  * $_native-object; The native object provided by the Raku object which registered this event.

  * $_widget; The object which registered the signal. User code may have left the object going out of scope.

  * %user-options; A list of named arguments provided at the `.register-signal()` method from **Gnome::GObject::Object**.

### places-shortcut

Emitted when the user asks for it.

This is a [keybinding signal](class.SignalAction.html).

This is used to move the focus to the places sidebar.

The default binding for this signal is <kbd>Alt</kbd>-<kbd>/kbd.

    method handler (
      Int :$_handle_id,
      Gnome::Gtk4::FileChooserWidget() :$_native-object,
      Gnome::Gtk4::FileChooserWidget :$_widget,
      *%user-options
    )

  * $_handle_id; The registered event handler id.

  * $_native-object; The native object provided by the Raku object which registered this event.

  * $_widget; The object which registered the signal. User code may have left the object going out of scope.

  * %user-options; A list of named arguments provided at the `.register-signal()` method from **Gnome::GObject::Object**.

### quick-bookmark

Emitted when the user asks for it.

This is a [keybinding signal](class.SignalAction.html).

This is used to make the file chooser switch to the bookmark specified in the `$bookmark_index` parameter. For example, if you have three bookmarks, you can pass 0, 1, 2 to this signal to switch to each of them, respectively.

The default binding for this signal is <kbd>Alt</kbd>-<kbd>1</kbd>, <kbd>Alt</kbd>-<kbd>2</kbd>, etc. until <kbd>Alt</kbd>-<kbd>0</kbd>. Note that in the default binding, that <kbd>Alt</kbd>-<kbd>1</kbd> is actually defined to switch to the bookmark at index 0, and so on successively.

    method handler (
      gint $bookmark-index,
      Int :$_handle_id,
      Gnome::Gtk4::FileChooserWidget() :$_native-object,
      Gnome::Gtk4::FileChooserWidget :$_widget,
      *%user-options
    )

  * $bookmark-index; the number of the bookmark to switch to.

  * $_handle_id; The registered event handler id.

  * $_native-object; The native object provided by the Raku object which registered this event.

  * $_widget; The object which registered the signal. User code may have left the object going out of scope.

  * %user-options; A list of named arguments provided at the `.register-signal()` method from **Gnome::GObject::Object**.

### recent-shortcut

Emitted when the user asks for it.

This is a [keybinding signal](class.SignalAction.html).

This is used to make the file chooser show the Recent location.

The default binding for this signal is <kbd>Alt</kbd>-<kbd><var>/kbd</var>.

    method handler (
      Int :$_handle_id,
      Gnome::Gtk4::FileChooserWidget() :$_native-object,
      Gnome::Gtk4::FileChooserWidget :$_widget,
      *%user-options
    )

  * $_handle_id; The registered event handler id.

  * $_native-object; The native object provided by the Raku object which registered this event.

  * $_widget; The object which registered the signal. User code may have left the object going out of scope.

  * %user-options; A list of named arguments provided at the `.register-signal()` method from **Gnome::GObject::Object**.

### search-shortcut

Emitted when the user asks for it.

This is a [keybinding signal](class.SignalAction.html).

This is used to make the file chooser show the search entry.

The default binding for this signal is <kbd>Alt</kbd>-<kbd>/kbd.

    method handler (
      Int :$_handle_id,
      Gnome::Gtk4::FileChooserWidget() :$_native-object,
      Gnome::Gtk4::FileChooserWidget :$_widget,
      *%user-options
    )

  * $_handle_id; The registered event handler id.

  * $_native-object; The native object provided by the Raku object which registered this event.

  * $_widget; The object which registered the signal. User code may have left the object going out of scope.

  * %user-options; A list of named arguments provided at the `.register-signal()` method from **Gnome::GObject::Object**.

### show-hidden

Emitted when the user asks for it.

This is a [keybinding signal](class.SignalAction.html).

This is used to make the file chooser display hidden files.

The default binding for this signal is <kbd>Control</kbd>-<kbd>/kbd.

    method handler (
      Int :$_handle_id,
      Gnome::Gtk4::FileChooserWidget() :$_native-object,
      Gnome::Gtk4::FileChooserWidget :$_widget,
      *%user-options
    )

  * $_handle_id; The registered event handler id.

  * $_native-object; The native object provided by the Raku object which registered this event.

  * $_widget; The object which registered the signal. User code may have left the object going out of scope.

  * %user-options; A list of named arguments provided at the `.register-signal()` method from **Gnome::GObject::Object**.

### up-folder

Emitted when the user asks for it.

This is a [keybinding signal](class.SignalAction.html).

This is used to make the file chooser go to the parent of the current folder in the file hierarchy.

The default binding for this signal is <kbd>Alt</kbd>-<kbd>Up</kbd>.

    method handler (
      Int :$_handle_id,
      Gnome::Gtk4::FileChooserWidget() :$_native-object,
      Gnome::Gtk4::FileChooserWidget :$_widget,
      *%user-options
    )

  * $_handle_id; The registered event handler id.

  * $_native-object; The native object provided by the Raku object which registered this event.

  * $_widget; The object which registered the signal. User code may have left the object going out of scope.

  * %user-options; A list of named arguments provided at the `.register-signal()` method from **Gnome::GObject::Object**.
