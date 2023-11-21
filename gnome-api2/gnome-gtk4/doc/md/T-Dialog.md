Project Description
-------------------

  * **Distribution:** Gnome::Gtk4

  * **Project description:** Modules for package Gnome::Gtk4:api<2>. The language binding to GNOME’s user interface toolkit version 4

  * **Project version:** 0.1.9

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

Enumerations
============

GtkResponseType
---------------

Predefined values for use as response ids in gtk_dialog_add_button().

All predefined values are negative; GTK leaves values of 0 or greater for application-defined response ids.=item `GTK_RESPONSE_NONE`; Returned if an action widget has no response id, or if the dialog gets programmatically hidden or destroyed

  * `GTK_RESPONSE_REJECT`; Generic response id, not used by GTK dialogs

  * `GTK_RESPONSE_ACCEPT`; Generic response id, not used by GTK dialogs

  * `GTK_RESPONSE_DELETE_EVENT`; Returned if the dialog is deleted

  * `GTK_RESPONSE_OK`; Returned by OK buttons in GTK dialogs

  * `GTK_RESPONSE_CANCEL`; Returned by Cancel buttons in GTK dialogs

  * `GTK_RESPONSE_CLOSE`; Returned by Close buttons in GTK dialogs

  * `GTK_RESPONSE_YES`; Returned by Yes buttons in GTK dialogs

  * `GTK_RESPONSE_NO`; Returned by No buttons in GTK dialogs

  * `GTK_RESPONSE_APPLY`; Returned by Apply buttons in GTK dialogs

  * `GTK_RESPONSE_HELP`; Returned by Help buttons in GTK dialogs

Bitfields
=========

GtkDialogFlags
--------------

Flags used to influence dialog construction.

  * `GTK_DIALOG_MODAL`; Make the constructed dialog modal

  * `GTK_DIALOG_DESTROY_WITH_PARENT`; Destroy the dialog when its parent is destroyed

  * `GTK_DIALOG_USE_HEADER_BAR`; Create dialog with actions in header bar instead of action area
