Project Description
-------------------

  * **Distribution:** Gnome::GObject

  * **Project description:** Modules for package Gnome::GObject:api<2>. The language binding to GNOME's lower level object library

  * **Project version:** 0.1.2

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

![](images/initiallyunowned.png)

Description
===========

A type for objects that have an initially floating reference.

Class initialization
====================

new
---

### :native-object

Create an object using a native object from elsewhere. See also **Gnome::N::TopLevelSupportClass**.

    multi method new ( N-Object :$native-object! )

