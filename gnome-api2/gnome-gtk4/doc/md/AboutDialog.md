Project Description
-------------------

  * **Distribution:** Gnome::Gtk4

  * **Project description:** Modules for package Gnome::Gtk4:api<2>. The language binding to GNOME’s user interface toolkit version 4

  * **Project version:** 0.1.7

  * **Rakudo version:** Raku.version, Raku.compiler.version

  * **Author:** Marcel Timmerman

![](images/aboutdialog.png)

Description
===========

The **Gnome::Gtk4::AboutDialog** offers a simple way to display information about a program.

The shown information includes the programs' logo, name, copyright, website and license. It is also possible to give credits to the authors, documenters, translators and artists who have worked on the program.

An about dialog is typically opened when the user selects the *About* option from the *Help* menu. All parts of the dialog are optional.

About dialogs often contain links and email addresses. **Gnome::Gtk4::AboutDialog** displays these as clickable links. By default, it calls `show-uri()` defined in **Gnome::Gtk4::Show** when a user clicks one. The behaviour can be overridden with the *activate-link* signal.

To specify a person with an email address, use a string like *Edgar Allan Poe <edgar@poe.com>*. To specify a website with a title, use a string like *GTK team https://www.gtk.org*.

To make constructing a **Gnome::Gtk4::AboutDialog** as convenient as possible, you can use the function `show-about-dialog()` defined in **Gnome::Gtk4::T-AboutDialog** which constructs and shows a dialog and keeps it around so that it can be shown again.

Note that GTK sets a default title of *_("About %s")* on the dialog window (where *%s* is replaced by the name of the application, but in order to ensure proper translation of the title, applications should set the title property explicitly when constructing a **Gnome::Gtk4::AboutDialog**, as shown in the following example:

    use Gnome::Glib::Error:api<2>;
    use Gnome::Gio::File:api<2>;
    use Gnome::Gtk4::T-AboutDialog:api<2>;
    use Gnome::Gtk4::Window:api<2>;
    use Gnome::Gdk4::Texture:api<2>;

    my Gnome::Gtk4::Window $some-main-window .= new;

    my Gnome::Gio::File $logo-file .= new-for-path("./logo.png");
    my Gnome::Gdk4::Texture $example-logo = new-from-file( logo_file, GError);
    $logo-file.clear-object;

    my Gnome::Gtk4::T-AboutDialog $t-dialog .= new;
    $t-dialog.show-about-dialog (
      $some-main-window, "program-name",
      Str, "ExampleCode",
      Str, "logo", Gnome::Gdk4::Texture, $example-logo,
      Str, "title", Str, "About ExampleCode",
    );

CSS nodes
---------

**Gnome::Gtk4::AboutDialog** has a single CSS node with the name *window* and style class *.aboutdialog*.

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

new-aboutdialog
---------------

Creates a new **Gnome::Gtk4::AboutDialog**.

    method new-aboutdialog (
      --> Gnome::Gtk4::AboutDialog
    )

Methods
=======

add-credit-section
------------------

Creates a new section in the "Credits" page.

    method add-credit-section (  Str $section-name, Array[Str] $people )

  * $section-name; The name of the section.

  * $people; The people who belong to that section.

get-artists
-----------

Returns the names of the artists which are displayed in the credits page.

    method get-artists ( --> Array[Str] )

Return value; A string array containing the artists. 

get-authors
-----------

Returns the names of the authors which are displayed in the credits page.

    method get-authors ( --> Array[Str] )

Return value; A string array containing the authors. 

get-comments
------------

Returns the comments string.

    method get-comments ( --> Str )

Return value; The comments. 

get-copyright
-------------

Returns the copyright string.

    method get-copyright ( --> Str )

Return value; The copyright string. 

get-documenters
---------------

Returns the name of the documenters which are displayed in the credits page.

    method get-documenters ( --> Array[Str] )

Return value; A string array containing the documenters. 

get-license
-----------

Returns the license information.

    method get-license ( --> Str )

Return value; The license information. 

get-license-type
----------------

Retrieves the license type.

    method get-license-type ( --> GtkLicense )

Return value; a `GtkLicense` enumeration value. An enumeration.

get-logo
--------

Returns the paintable displayed as logo in the about dialog.

    method get-logo ( --> N-GObject() )

Return value; the paintable displayed as logo or undefined if the logo is unset or has been set via `.set_logo_icon_name()`. 

get-logo-icon-name
------------------

Returns the icon name displayed as logo in the about dialog.

    method get-logo-icon-name ( --> Str )

Return value; the icon name displayed as logo, or undefined if the logo has been set via `.set_logo()`. 

get-program-name
----------------

Returns the program name displayed in the about dialog.

    method get-program-name ( --> Str )

Return value; The program name. 

get-system-information
----------------------

Returns the system information that is shown in the about dialog.

    method get-system-information ( --> Str )

Return value; the system information. 

get-translator-credits
----------------------

Returns the translator credits string which is displayed in the credits page.

    method get-translator-credits ( --> Str )

Return value; The translator credits string. 

get-version
-----------

Returns the version string.

    method get-version ( --> Str )

Return value; The version string. 

get-website
-----------

Returns the website URL.

    method get-website ( --> Str )

Return value; The website URL. 

get-website-label
-----------------

Returns the label used for the website link.

    method get-website-label ( --> Str )

Return value; The label used for the website link. 

get-wrap-license
----------------

Returns whether the license text in the about dialog is automatically wrapped.

    method get-wrap-license ( --> Bool() )

Return value; `True` if the license text is wrapped. 

set-artists
-----------

Sets the names of the artists to be displayed in the "Credits" page.

    method set-artists (  Array[Str] $artists )

  * $artists; the authors of the artwork of the application.

set-authors
-----------

Sets the names of the authors which are displayed in the "Credits" page of the about dialog.

    method set-authors (  Array[Str] $authors )

  * $authors; the authors of the application.

set-comments
------------

Sets the comments string to display in the about dialog.

This should be a short string of one or two lines.

    method set-comments (  Str $comments )

  * $comments; a comments string.

set-copyright
-------------

Sets the copyright string to display in the about dialog.

This should be a short string of one or two lines.

    method set-copyright (  Str $copyright )

  * $copyright; the copyright string.

set-documenters
---------------

Sets the names of the documenters which are displayed in the "Credits" page.

    method set-documenters (  Array[Str] $documenters )

  * $documenters; the authors of the documentation of the application.

set-license
-----------

Sets the license information to be displayed in the about dialog.

If `license` is undefined, the license page is hidden.

    method set-license (  Str $license )

  * $license; the license information.

set-license-type
----------------

Sets the license of the application showing the about dialog from a list of known licenses.

This function overrides the license set using `.set_license()`.

    method set-license-type (  GtkLicense $license-type )

  * $license-type; the type of license. An enumeration.

set-logo
--------

Sets the logo in the about dialog.

    method set-logo (  N-GObject() $logo )

  * $logo; a *GdkPaintable*.

set-logo-icon-name
------------------

Sets the icon name to be displayed as logo in the about dialog.

    method set-logo-icon-name (  Str $icon-name )

  * $icon-name; an icon name.

set-program-name
----------------

Sets the name to display in the about dialog.

If *name* is not set, the string returned by `g_get_application_name()` is used.

    method set-program-name (  Str $name )

  * $name; the program name.

set-system-information
----------------------

Sets the system information to be displayed in the about dialog.

If `system_information` is undefined, the system information page is hidden.

See *system-information*.

    method set-system-information (  Str $system-information )

  * $system-information; system information.

set-translator-credits
----------------------

Sets the translator credits string which is displayed in the credits page.

The intended use for this string is to display the translator of the language which is currently used in the user interface. Using `gettext()`, a simple way to achieve that is to mark the string for translation:

It is a good idea to use the customary *msgid* “translator-credits” for this purpose, since translators will already know the purpose of that *msgid*, and since **Gnome::Gtk4::AboutDialog** will detect if “translator-credits” is untranslated and omit translator credits.

    method set-translator-credits (  Str $translator-credits )

  * $translator-credits; the translator credits.

set-version
-----------

Sets the version string to display in the about dialog.

    method set-version (  Str $version )

  * $version; the version string.

set-website
-----------

Sets the URL to use for the website link.

    method set-website (  Str $website )

  * $website; a URL string starting with *http://*.

set-website-label
-----------------

Sets the label to be used for the website link.

    method set-website-label (  Str $website-label )

  * $website-label; the label used for the website link.

set-wrap-license
----------------

Sets whether the license text in the about dialog should be automatically wrapped.

    method set-wrap-license (  Bool() $wrap-license )

  * $wrap-license; whether to wrap the license.

Signals
=======

### activate-link

Emitted every time a URL is activated.

Applications may connect to it to override the default behaviour, which is to call `show-uri()`.

    method handler (
      Str $uri,
      Int :$_handle_id,
      Gnome::Gtk4::AboutDialog() :$_native-object,
      Gnome::Gtk4::AboutDialog :$_widget,
      *%user-options
      --> gboolean
    )

  * $uri; the URI that is activated.

  * $_handle_id; The registered event handler id.

  * $_native-object; The native object provided by the Raku object which registered this event.

  * $_widget; The object which registered the signal. User code may have left the object going out of scope.

  * %user-options; A list of named arguments provided at the `.register-signal()` method from **Gnome::GObject::Object**.

Return value; `True` if the link has been activated

