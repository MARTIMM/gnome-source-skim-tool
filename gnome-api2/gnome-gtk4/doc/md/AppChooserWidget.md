Project Description
-------------------

  * **Distribution:** Gnome::Gtk4

  * **Project description:** Modules for package Gnome::Gtk4:api<2>. The language binding to GNOME’s user interface toolkit version 4

  * **Project version:** 0.1.9

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

![](images/appchooserwidget.png)

Description
===========

**Gnome::Gtk4::AppChooserWidget** is a widget for selecting applications.

It is the main building block for [class `$Gtk`.AppChooserDialog]. Most applications only need to use the latter; but you can use this widget as part of a larger widget if you have special needs.

**Gnome::Gtk4::AppChooserWidget** offers detailed control over what applications are shown, using the *show-default*, *show-recommended*, *show-fallback*, *show-other* and *show-all* properties. See the [iface `$Gtk`.AppChooser] documentation for more information about these groups of applications.

To keep track of the selected application, use the *application-selected* and *application-activated* signals.

CSS nodes
=========

**Gnome::Gtk4::AppChooserWidget** has a single CSS node with name appchooser.

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

new-appchooserwidget
--------------------

Creates a new **Gnome::Gtk4::AppChooserWidget** for applications that can handle content of the given type.

    method new-appchooserwidget ( Str $content-type --> Gnome::Gtk4::AppChooserWidget )

  * $content-type; the content type to show applications for.

Methods
=======

get-default-text
----------------

Returns the text that is shown if there are not applications that can handle the content type.

    method get-default-text (--> Str )

Return value; the value of *default-text*. 

get-show-all
------------

Gets whether the app chooser should show all applications in a flat list.

    method get-show-all (--> Bool )

Return value; the value of *show-all*. 

get-show-default
----------------

Gets whether the app chooser should show the default handler for the content type in a separate section.

    method get-show-default (--> Bool )

Return value; the value of *show-default*. 

get-show-fallback
-----------------

Gets whether the app chooser should show related applications for the content type in a separate section.

    method get-show-fallback (--> Bool )

Return value; the value of *show-fallback*. 

get-show-other
--------------

Gets whether the app chooser should show applications which are unrelated to the content type.

    method get-show-other (--> Bool )

Return value; the value of *show-other*. 

get-show-recommended
--------------------

Gets whether the app chooser should show recommended applications for the content type in a separate section.

    method get-show-recommended (--> Bool )

Return value; the value of *show-recommended*. 

set-default-text
----------------

Sets the text that is shown if there are not applications that can handle the content type.

    method set-default-text ( Str $text )

  * $text; the new value for *default-text*.

set-show-all
------------

Sets whether the app chooser should show all applications in a flat list.

    method set-show-all ( Bool() $setting )

  * $setting; the new value for *show-all*.

set-show-default
----------------

Sets whether the app chooser should show the default handler for the content type in a separate section.

    method set-show-default ( Bool() $setting )

  * $setting; the new value for *show-default*.

set-show-fallback
-----------------

Sets whether the app chooser should show related applications for the content type in a separate section.

    method set-show-fallback ( Bool() $setting )

  * $setting; the new value for *show-fallback*.

set-show-other
--------------

Sets whether the app chooser should show applications which are unrelated to the content type.

    method set-show-other ( Bool() $setting )

  * $setting; the new value for *show-other*.

set-show-recommended
--------------------

Sets whether the app chooser should show recommended applications for the content type in a separate section.

    method set-show-recommended ( Bool() $setting )

  * $setting; the new value for *show-recommended*.

Signals
=======

### application-activated

Emitted when an application item is activated from the widget's list.

This usually happens when the user double clicks an item, or an item is selected and the user presses one of the keys Space, Shift+Space, Return or Enter.

    method handler (
       $application,
      Int :$_handle_id,
      Gnome::Gtk4::AppChooserWidget() :$_native-object,
      Gnome::Gtk4::AppChooserWidget :$_widget,
      *%user-options
    )

  * $application; the activated *GAppInfo*.

  * $_handle_id; The registered event handler id.

  * $_native-object; The native object provided by the Raku object which registered this event.

  * $_widget; The object which registered the signal. User code may have left the object going out of scope.

  * %user-options; A list of named arguments provided at the `.register-signal()` method from **Gnome::GObject::Object**.

### application-selected

Emitted when an application item is selected from the widget's list.

    method handler (
       $application,
      Int :$_handle_id,
      Gnome::Gtk4::AppChooserWidget() :$_native-object,
      Gnome::Gtk4::AppChooserWidget :$_widget,
      *%user-options
    )

  * $application; the selected *GAppInfo*.

  * $_handle_id; The registered event handler id.

  * $_native-object; The native object provided by the Raku object which registered this event.

  * $_widget; The object which registered the signal. User code may have left the object going out of scope.

  * %user-options; A list of named arguments provided at the `.register-signal()` method from **Gnome::GObject::Object**.
