# Skim process

## Phase one

## Phase two


# Gnome gir types

## Structures
### class

### interface

### record

### union


## Simple types
### constant

### enumeration

### bitfield

### function



<!--
=head2 Find the data

Code and documentation is retrieved indirectly from C source files (originally in *.h and *.c). The data found is stored in a C<repo-object-map.yaml>. It tests for every key where a sub-key matches the given filename. Then the found data is stored in a Hash C<$!filedata> with the top key its type of each found key.

Gnome has a notion of several types of which the larger ones are C<classes>, C<interfaces>, C<records> and C<unions>. Written in the C-language, a class or interface does not exist. It is by clever programming that the Gnome team have introduced those by defining structures in a consistent way and added a set of subroutines to initialize and use the structures. They are called constructors and methods. A constructor returns an initialized structure and the methods use that structure.
There may also be subroutines, which are called functions, defined in a class or interface. They do not use the initialized structure but are added as a convenience routine.
The record is a C-stucture and the union is, well …, a union.


=head2 Generating code, doc or testfiles

When processing the C<$!filedata> Hash, the types C<class> and C<interface>, are stored in separate files and the rest is gathered in a single file.

This breaks compatibility with older packages. This is an improvement because the data is better categorized into files and for the developer it is possible to select the proper files more specificly.

The C<class> code becomes a Raku class and an C<interface> code becomes a Raku role.

The C<record> and C<union> code is stored in one or two files depending if there are subroutines defined to manipulate the structures. The C<record> becomes a Raku C<repr('CStruct')> and the C<union> a Raku C<repr('CUnion')>.

=item classes; The key of the sub-hash is used to create the class module. E.g a filename of C<aboutdialog> shows several types. The class type carries this key; C<GtkAboutDialog>. The class may be from Gtk3 and so the class name becomes B<Gnome::Gtk3::AboutDialog> and the files C<AboutDialog.*> (code, doc and tests are in separate files).

=item interfaces; These are the roles for Raku. The name is set the same way as for classes. The result modules have no use to the developer directly. They are used as a role by the classes. So it will be usefull to mark the role by prefixing them with I<R->. The name will then standout better. E.g. the file C<buildable> has an interface C<GtkBuildable> and delivers the module B<Gnome::Gtk3::R-Buildable> in files C<R-Buildable.*>. This is different from the older packages but would not be noticable.

=item records; Records are the C-structures which are the native Raku CStruct types. The name for that will be record name with I<N-> attached to it. E.g. The file C<events> has several records specified like C<GdkEventButton>. The results of that record becomes a class B<Gnome::Gdk3::N-EventButton> in files C<N-EventButton.*>.

=item union; Unions are also C-structures which are the Raku native CUnion types. The name for that will also be union name with I<N-> attached to it. E.g. The file C<events> has also a union specified like C<GdkEvent>. The results of that union becomes a class B<Gnome::Gdk3::N-Event> in files C<N-Event.*>.

=begin item
The other types are stored together in a separate file. The types can be enumerations, bitfields, constants, functions, etc. The name of the file will become the filename with its first letter uppercased and prefixed with I<T->.
E.g. the filename C<enums> has a lot of enumerations. The class name to store this data is B<Gnome::Gtk3::T-Enums> in file C<T-Enums.*>.
The file C<events> has also some enumerations and bitfields. Those are stored in files C<T-Events.*> with class B<Gnome::Gdk3::T-Events>.
This breaks also the compatebility with older packages in two ways because of its name and secondly, when a definition is needed the file must be imported explicitly where they were together in a class. However, the import (C<use>) is the only thing to change because 1) the class name is never used directly and 2) all declarations in the file are unchanged.
=end item
-->