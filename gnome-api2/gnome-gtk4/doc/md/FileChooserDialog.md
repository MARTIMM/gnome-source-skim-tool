Project Description
-------------------

  * **Distribution:** Gnome::Gtk4

  * **Project description:** Modules for package Gnome::Gtk4:api<2>. The language binding to GNOME’s user interface toolkit version 4

  * **Project version:** 0.1.9

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

![](images/filechooserdialog.png)

Description
===========

**Gnome::Gtk4::FileChooserDialog** is a dialog suitable for use with “File Open” or “File Save” commands.

![An example GtkFileChooserDialog](filechooser.png)

This widget works by putting a [class `$Gtk`.FileChooserWidget] inside a [class `$Gtk`.Dialog]. It exposes the [iface `$Gtk`.FileChooser] interface, so you can use all of the [iface `$Gtk`.FileChooser] functions on the file chooser dialog as well as those for [class `$Gtk`.Dialog].

Note that **Gnome::Gtk4::FileChooserDialog** does not have any methods of its own. Instead, you should use the functions that work on a [iface `$Gtk`.FileChooser].

If you want to integrate well with the platform you should use the [class `$Gtk`.FileChooserNative] API, which will use a platform-specific dialog if available and fall back to **Gnome::Gtk4::FileChooserDialog** otherwise.

Typical usage
-------------

In the simplest of cases, you can the following code to use **Gnome::Gtk4::FileChooserDialog** to select a file for opening:

To use a dialog for saving, you can use this:

Setting up a file chooser dialog
--------------------------------

There are various cases in which you may need to use a **Gnome::Gtk4::FileChooserDialog**:

- To select a file for opening, use %GTK_FILE_CHOOSER_ACTION_OPEN.

- To save a file for the first time, use %GTK_FILE_CHOOSER_ACTION_SAVE, and suggest a name such as “Untitled” with `.set-current-name() defined in FileChooser`.

- To save a file under a different name, use %GTK_FILE_CHOOSER_ACTION_SAVE, and set the existing file with `.set-file() defined in FileChooser`.

- To choose a folder instead of a filem use %GTK_FILE_CHOOSER_ACTION_SELECT_FOLDER.

In general, you should only cause the file chooser to show a specific folder when it is appropriate to use `.set-file() defined in FileChooser`, i.e. when you are doing a “Save As” command and you already have a file saved somewhere.

Response Codes
--------------

**Gnome::Gtk4::FileChooserDialog** inherits from [class `$Gtk`.Dialog], so buttons that go in its action area have response codes such as %GTK_RESPONSE_ACCEPT and %GTK_RESPONSE_CANCEL. For example, you could call [ctor `$Gtk`.FileChooserDialog.new] as follows:

This will create buttons for “Cancel” and “Open” that use predefined response identifiers from `GtkResponseType` enumeration. For most dialog boxes you can use your own custom response codes rather than the ones in `GtkResponseType` enumeration, but **Gnome::Gtk4::FileChooserDialog** assumes that its “accept”-type action, e.g. an “Open” or “Save” button, will have one of the following response codes:

- %GTK_RESPONSE_ACCEPT - %GTK_RESPONSE_OK - %GTK_RESPONSE_YES - %GTK_RESPONSE_APPLY

This is because **Gnome::Gtk4::FileChooserDialog** must intercept responses and switch to folders if appropriate, rather than letting the dialog terminate — the implementation uses these known response codes to know which responses can be blocked if appropriate.

To summarize, make sure you use a predefined response code when you use **Gnome::Gtk4::FileChooserDialog** to ensure proper operation.

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

new-filechooserdialog
---------------------

Creates a new **Gnome::Gtk4::FileChooserDialog**.

This function is analogous to [ctor `$Gtk`.Dialog.new_with_buttons].

    method new-filechooserdialog ( Str $title, N-Object() $parent, GtkFileChooserAction $action, Str $first-button-text, … --> Gnome::Gtk4::FileChooserDialog )

  * $title; Title of the dialog.

  * $parent; Transient parent of the dialog.

  * $action; Open or save mode for the dialog. An enumeration.

  * $first-button-text; text to go in the first button.

  * …; response ID for the first button, then additional (button, id) pairs, ending with undefined. Note that each argument must be specified as a type followed by its value!
