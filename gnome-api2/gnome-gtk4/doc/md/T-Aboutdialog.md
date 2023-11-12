Project Description
-------------------

  * **Distribution:** Gnome::Gtk4

  * **Project description:** Modules for package Gnome::Gtk4:api<2>. The language binding to GNOME’s user interface toolkit version 4

  * **Project version:** 0.1.7

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

Gnome::Gtk4::T-Aboutdialog
==========================

Enumerations
============

GtkLicense
----------

The type of license for an application.

This enumeration can be expanded at later date.=item `GTK_LICENSE_UNKNOWN`; No license specified

  * `GTK_LICENSE_CUSTOM`; A license text is going to be specified by the developer

  * `GTK_LICENSE_GPL_2_0`; The GNU General Public License, version 2.0 or later

  * `GTK_LICENSE_GPL_3_0`; The GNU General Public License, version 3.0 or later

  * `GTK_LICENSE_LGPL_2_1`; The GNU Lesser General Public License, version 2.1 or later

  * `GTK_LICENSE_LGPL_3_0`; The GNU Lesser General Public License, version 3.0 or later

  * `GTK_LICENSE_BSD`; The BSD standard license

  * `GTK_LICENSE_MIT_X11`; The MIT/X11 standard license

  * `GTK_LICENSE_ARTISTIC`; The Artistic License, version 2.0

  * `GTK_LICENSE_GPL_2_0_ONLY`; The GNU General Public License, version 2.0 only

  * `GTK_LICENSE_GPL_3_0_ONLY`; The GNU General Public License, version 3.0 only

  * `GTK_LICENSE_LGPL_2_1_ONLY`; The GNU Lesser General Public License, version 2.1 only

  * `GTK_LICENSE_LGPL_3_0_ONLY`; The GNU Lesser General Public License, version 3.0 only

  * `GTK_LICENSE_AGPL_3_0`; The GNU Affero General Public License, version 3.0 or later

  * `GTK_LICENSE_AGPL_3_0_ONLY`; The GNU Affero General Public License, version 3.0 only

  * `GTK_LICENSE_BSD_3`; The 3-clause BSD licence

  * `GTK_LICENSE_APACHE_2_0`; The Apache License, version 2.0

  * `GTK_LICENSE_MPL_2_0`; The Mozilla Public License, version 2.0

Standalone Functions
====================

show-about-dialog
-----------------

A convenience function for showing an application’s about dialog.

The constructed dialog is associated with the parent window and reused for future invocations of this function.

    method show-about-dialog (  N-GObject() $parent, Str $first-property-name, … )

  * $parent; the parent top-level window.

  * $first-property-name; the name of the first property.

  * …; value of first property, followed by more pairs of property name and value. Note that each argument must be specified as a pair of a type and its value!
