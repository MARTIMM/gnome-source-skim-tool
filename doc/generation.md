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

# Call interface

All routines available in a class, role or as standalone functions are generated in a data structure as a Hash table. A small sample from the **Gnome::Gtk3::Label** class;

```
my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new => %( :type(Constructor),:returns(N-GObject), :parameters([ Str])),
  new-with-mnemonic => %( :type(Constructor),:returns(N-GObject), :parameters([ Str])),

  #--[Methods]------------------------------------------------------------------
  get-angle => %( :returns(gdouble)),
  get-ellipsize => %( :returns(GEnum), :type-name(PangoEllipsizeMode)),
  get-justify => %( :returns(GEnum), :type-name(GtkJustification)),
…
 ```

The key of the `$methods` hash is the name of the function as the developer uses it. It is translated into the real gnome name. E.g. `get-angle` in the above example, becomes `gtk_label_get_angle`. Each value of a key is a hash describing the interface and how to call it.

* **type**; An enumeration and can be one of `Function`, `Method` or `Constructor`. The Method is never used because it is taken as a default. Choosen because there are more methods than constructors or functions. This saves space and compile time. The method always have the classes native object as its first argument. This is not visible in the parameters array and is automatically inserted before calling.
* **parameters**; This is an array of parameter types for each expected argument to the function. The types are defined in module **Gnome::N::GlibToRakuTypes**.
* **returns**; A type of the return value if there is any.
* **type-name**; An enumeration type. When a return type is a `GEnum` (an enumeration) the number is translated into the enum name.
* **variable-list**; A boolean value which says that the argument list is longer than provided in the parameters array. The user must provide the type and value for the rest of the arguments.
  ```
  my Gnome::Glib::T-Error $error .= new;
  my $e = CArray[N-GError].new(N-GError);
  $error.set-error( $e, $domain, $code, $format, [ gint32, 2]);

  ```
