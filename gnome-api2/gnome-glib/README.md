![Gtk+ Raku logo][logo]

# Gnome Glib - C-based object and type system

![Artistic License 2.0][license-svg]


# Description

GLib is the low-level core library that forms the basis for projects such as GTK and GNOME. It provides data structure handling for C, portability wrappers, and interfaces for such runtime functionality as an event loop, threads, dynamic loading, and an object system. Note, however, that not everything is implemented.

## Documentation
* [ 🔗 Website, entry point for all documents and blogs](https://martimm.github.io/)
* [ 🔗 License document][license-lnk]
* [ 🔗 Release notes of all the packages in `:api<2>`][changes]
* [ 🔗 Issues of all the packages in `:api<2>`][issues]


# Installation
Do not install this package on its own. Instead install `Gnome::Gtk4` newest api.

`zef install Gnome::Gtk4:api<2>`


# Author

Name: **Marcel Timmerman**
Github account name: **MARTIMM**


# Issues

There are always some problems! If you find one please help by filing an issue at [my github project][issues].


# Attribution

* The inventors of Raku, formerly known as Perl 6, of course and the writers of the documentation which helped me out every time again and again.
* The builders of all the Gnome libraries and the documentation.
* Other helpful modules for their insight and use.


[//]: # (---- [refs] ----------------------------------------------------------)
[changes]: https://github.com/MARTIMM/gnome-source-skim-tool/blob/main/CHANGES.md
[issues]:  https://github.com/MARTIMM/gnome-source-skim-tool/issues

[Zlogo]:   https://github.com/MARTIMM/martimm.github.io/blob/main/label/gtk-raku.png
[Ylogo]:    https://martimm.github.io/content-docs/images/gtk-raku.png
[logo]:   https://martimm.github.io/gnome-gtk3/content-docs/images/gtk-perl6.png
[license-svg]:  https://martimm.github.io/label/License-label.svg
[license-lnk]:  https://www.perlfoundation.org/artistic_license_2_0



[//]: # (https://nbviewer.jupyter.org/github/MARTIMM/gtk-v3/blob/master/doc/GObject.pdf)
[//]: # (Pod documentation rendered with)
[//]: # (pod-render.pl6 --pdf --g=MARTIMM/gtk-v3 lib)
