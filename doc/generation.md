[TOC]

# Result files

The program takes a name which is originally the C-source filename (`\*.h` and `\*.c`). Together with the package name it searches through the `repo-object-map.yaml` file to search for all gir types defined originally in that source.

It will then set out to create code (and/or doc or tests depending on options) for the found gnome types `class`, `interface`, `record` or `union`, and saves each in a separate file. Interfaces (which become Raku roles) are prefixed with a `R-` and records and unions with a `N-`.

After that, it looks for the simpler types; `constant`, `enumeration`, `bitfield` and `function` not found within a class. These are gathered in a single file having a `T-` prefix.

Note that the `R-` and `T-` prefixes aren't used in the older package versions. This is not a problem for the roles because they can not be used directly as a class. The `T-` is new in `:api<2>` and breaks compatibility. E.g. enumerations were mostly provided with the class but not always because there is also a huge enums module. The developer now needs to explicitly import the file if the enumeration is needed.

The developer must also add `:api<2>` to the use statements to prevent mixup with the older versions when they are also installed.

E.g.
```
use Gnome::Gtk3::Window:api<2>;
use Gnome::Gtk3::T-Window:api<2>;
```

# Raku Classes

A list of what to expect from the objects defined below
## Class
Types and files for a class like the <ins>Label</ins> class in Gtk version 3
* Class name **Gnome::Gtk3::Label**.
* Class Filename `lib/Gnome/Gtk3/Label.rakumod`.
* Test Filename `t/Label.rakutest`.
* Doc filename `doc/Label.rakudoc`.

## Interface
Types and files for a role like the <ins>Orientable</ins> class in Gtk version 3
* Class name **Gnome::Gtk3::R-Orientable**.
* Class Filename `lib/Gnome/Gtk3/R-Orientable.rakumod`.
* Test Filename `t/R-Orientable.rakutest`.
* Doc filename `doc/R-Orientable.rakudoc`.

## Record
Types and files for a record like used in <ins>List</ins> structure in Glib. The class is exported and therefore usable as `N-List`.
* Class name **Gnome::Glib::List::N-List**.
* Class Filename `lib/Gnome/Glib/List/N-List.rakumod`.
* Test Filename `t/N-List.rakutest`.
* Doc filename `doc/N-List.rakudoc`.

## Union
Types and files for a union like used in <ins>Event</ins> structure in Gdk version 3. The class is exported and therefore usable as `N-Event`.
* Class name **Gnome::Gdk3::Event::N-Event**.
* Class Filename `lib/Gnome/Gdk3/Event/N-Event.rakumod`.
* Test Filename `t/N-Event.rakutest`.
* Doc filename `doc/N-Event.rakudoc`.

## Other types
Other types like enumerations, constants and standalone functions are gathered in one file named after the C source file it is defined in. For example the <ins>Window</ins> class in Gtk version 3 has a few enumerations.
* Class name **Gnome::Gtk3::T-Window**.
* Class Filename `lib/Gnome/Gtk3/T-Window.rakumod`.
* Test Filename `t/T-Window.rakutest`.
* Doc filename `doc/T-Window.rakudoc`.

# Call interface

All routines available in a class, role or as standalone functions are generated in a data structure as a Hash table. A small sample from the **Gnome::Gtk3::Label** class;

```
my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-label => %( :type(Constructor), :isnew, :returns(N-GObject), :parameters([ Str])),
  new-with-mnemonic => %( :type(Constructor),:returns(N-GObject), :parameters([ Str])),

  #--[Methods]------------------------------------------------------------------
  get-angle => %( :returns(gdouble)),
  get-ellipsize => %( :returns(GEnum), :cnv-return(PangoEllipsizeMode)),
  get-justify => %( :returns(GEnum), :cnv-return(GtkJustification)),
…
  set-justify => %( :parameters([GEnum])),
  set-label => %( :parameters([Str])),
  set-line-wrap => %( :parameters([gboolean])),
  set-line-wrap-mode => %( :parameters([GEnum])),
  set-lines => %( :parameters([gint])),
…
```

The key of the `$methods` hash is the name of the function as the developer uses it. It is translated into the real gnome name. E.g. `get-angle` in the above example, becomes `gtk_label_get_angle`. Each value of a key is a hash describing the interface and how to call it.

* **type**; An enumeration and can be one of `Function`, `Method` or `Constructor`. The Method is never used because it is taken as a default. Choosen because there are more methods than constructors or functions. This saves space and compile time. Methods always have the classes native object as its first argument. This is not visible in the parameters array and is automatically inserted before calling.
* **parameters**; This is an array of parameter types for each expected argument to the function. The types are defined in module **Gnome::N::GlibToRakuTypes**.
* **returns**; A type of the return value if there is any.
* **type-name**; An enumeration type. When a return type is a `GEnum` (an enumeration) the number is translated into the enum name.
* **variable-list**; A boolean value which says that the argument list is longer than provided in the parameters array. The user must provide the type and value for the rest of the arguments.
* **isnew**; A boolean value to show that the real name is `new`.
* **realname**; A string with the realname of a constructor, method or function. The field will probably replace `isnew` because it has the same kind of use.


# Types of argument lists
## Empty argument lists

This is easy to use. For example in the `get-angle` example above, shows only a return value of a `gdouble` which would become a Raku `Num` type.


## With fixed argument list

The `set-label` has one argument, a string. 
```
use Gnome::Gtk3::T-Enums:api<2>;
use Gnome::Gtk3::Label:api<2>;

with my Gnome::Gtk3::Label $label .= new(:text('my new label')) {
  .set-justify(GTK_JUSTIFY_LEFT);
  .set-angle(10e01);
  say .get-angle;         # 10e01
  say .get-justification  # GTK_JUSTIFY_LEFT
}
```


## With variable argument lists
An entry from the **Gnome::Glib::T-Error** module shows
```
  set-error => %(
    :type(Function), :variable-list,
    :parameters([ CArray[N-GError], GQuark, gint, Str])
  ),
```

The key `:variable-list` is set which means that the user can add additional arguments to the list in the form of an array of two elements for each argument, a type and its value.

```
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::Glib::T-Error:api<2>;
use Gnome::Glib::N-GError:api<2>;

my GQuark $domain = 87654;
my gint $code = 7987;
my Str $format = 'my %dnd error';

my Gnome::Glib::T-Error $error .= new;
my $e = CArray[N-GError].new(N-GError);
$error.set-error( $e, $domain, $code, $format, [ gint32, 2]);
say $e[0].domain;         # 87654
say $e[0].message;        # 'my 2nd error'
```

## Pointer arguments

Arguments which are pointers to locations are mostly used to store information. In the above example from **Gnome::Glib::T-Error**, there is this `CArray[N-GError]` where the created **Gnome::Glib::N-GError** will be stored.
The returned value of the pointer arguments are also returned in a List so that the values can be read directly.
```
my List $l = $error.set-error( $e, $domain, $code, $format, [ gint32, 2]);
say $l[0].domain;         # 87654
```
TODO
Later versions should be able to create the locations internally so that the developer does not have to create that location. An example showing this comes from **Gnome::Gtk3::Window**. The entries for the example are defined as
```
  get_default_size => %( :parameters([gint-ptr, gint-ptr])),
…
  set-default-size => %( :parameters([gint, gint])),
…
```

```
my Gnome::Gtk3::Window $w .= new;
$w.set-default-size( 123, 356);
my Int ( $ww, $wh) = $w.get-default-size;
say "$ww, $wh";     # 123, 356
```
