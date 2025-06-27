[TOC]

# About the project

This project is about the skimming of the `Gnome Introspection Repository` or `GIR` and generation of the Raku code.

# Skimming

There has been a discussion about how to proceed getting and using the info from the `GIR`. For now I decided to go through the XML equivalent and store the necessary data in a YAML file. The generator takes that data and generates the Raku modules in such a way that the info of every constructor, method, or function is stored in a **Hash**. When running the module, the needed calls are bound to the native routines and saved for that run only.

The other angle to take is to directly call methods from the library to bind the the calls to the named routines on the fly. The named routines are only saved while running the program and then forgotten when the program end.

To compare the pros and cons of the two methods is difficult but boiles down to the following;
* The first has everything in a **Hash** and does not have to look up the data from the `GIR`. Its pro is that there is no overhead of accessing the `GIR` libraries to get the info. On the contrary however, modules may have missing calls because it might be generated with older `GIR` XML data. Or, the modules may have calls which aren't yet in the users installed libraries.
* The second has the newest info on that particular system, therefore there are no missing calls or calls not yet available. Though, you have to check the documentation and compare the version with that of the libraries.
  Anyways, this still needs to be investigated. Maybe better solutions come up when the new **RakuAst** is available. It makes it possible to use macros and evaluation of code whithout the dangers of current methods.
* Whatever method is choosen, structures, documentation, and tests need to be generated I believe.
* A third interesting possibility is mentioned. Start out with a package name only. When a module is needed, the package generates one with the necessary code to handle the needed calls. It's a bit of a chicken and egg problem though and needs some deeper thoughts.
  I think it is a hard problem because of the following;
  * Suppose the user wants to run
    ```
    use Gnome::Gtk4;
    use Gnome::Gtk4::Label;

    my Gnome::Gtk4::Label $label .= new-label;
    $label.set-text('text')`.
    ```
    1) `use Gnome::Gtk4;` should make all modules available. The question is where? Possible solution would be at `~/.raku`.
    2) The next import statement would then import the generated `Gnome::Gtk4::Label`. This is already too late! A small test shows that the modules are looked up before it is generated. So at least the (empty with basic code) classes and modules must be delivered and installed.
    3) The `.new-label()` contructor and the method `.set-text()` can be found in the **Label**** class. So that may be easy to find after a few calls. But where to search for when a method is used from another parent class, e.g. `.set-size-request()`, or when it is inherited, e.g. `.set-orientation()` for a **Box**. That search is even more intensive. This is also the case in the 2nd proposal written above.
  
  * No tests can be made for the modules except for the base modules delevered in the package! Because everything from the tests will generate new code and the time you want to save while installing the modules will be taken by the tests.

Thinking it all over, I will keep it like it is now except that there must be a way to see what gnome library version the raku code, tests, and documentation is generated against. E.g. `dnf list atk|grep x86_64`.

## Result files

# Generation
```
> bin/generate.raku options package-name source-name
```
The program takes a name which is originally the C-source filename (`\*.h` and `\*.c`). For example `textview` to get the module, test, or documentation of **Gnome::Gtk4::TextView**. Together with the package name it searches through the `repo-object-map.yaml` file to search for all gir types defined originally in that source.

It will then set out to create code (and/or doc or tests depending on options) for the found gnome types `class`, `interface`, `record` or `union`, and saves each in a separate file. Interfaces (which become Raku roles) are prefixed with `R-` and records and unions with `N-`.

After that, it looks for the simpler types; `constant`, `enumeration`, `bitfield` and `function` not found within a class. These are gathered in a single file having a `T-` prefix. The documentation will also show `docsection` pages and add info about callback routines the use is to specify.

Note that the `R-` and `T-` prefixes aren't used in the older package versions. This is not a problem for the roles because they can not be used directly as a class. The `T-` is new in `:api<2>` and breaks compatibility. E.g. enumerations were mostly provided with the class but not always because there is also a huge enums module. The developer now needs to explicitly import the file if the enumeration is needed.

The developer must also add `:api<2>` to the use statements to prevent mixup with the older versions when they are also installed.

E.g.
```
use Gnome::Gtk4::Window:api<2>;
use Gnome::Gtk4::T-Window:api<2>;
```
---
## Raku Classes

A list of what to expect from the objects defined below

### Class
Types and files for a class like the <ins>Label</ins> class in Gtk version 3
* Class name **Gnome::Gtk3::Label**.
* Class Filename `lib/Gnome/Gtk3/Label.rakumod`.
* Test Filename `t/Label.rakutest`.
* Doc filename `doc/Label.rakudoc`.

### Interface
Types and files for a role like the <ins>Orientable</ins> class in Gtk version 3
* Class name **Gnome::Gtk3::R-Orientable**.
* Class Filename `lib/Gnome/Gtk3/R-Orientable.rakumod`.
* Test Filename `t/R-Orientable.rakutest`.
* Doc filename `doc/R-Orientable.rakudoc`.

### Record
Types and files for a record like used in <ins>List</ins> structure in Glib. The class is exported and therefore usable as `N-List`.
* Class name **Gnome::Glib::List::N-List**.
* Class Filename `lib/Gnome/Glib/List/N-List.rakumod`.
* Test Filename `t/N-List.rakutest`.
* Doc filename `doc/N-List.rakudoc`.

### Union
Types and files for a union like used in <ins>Event</ins> structure in Gdk version 3. The class is exported and therefore usable as `N-Event`.
* Class name **Gnome::Gdk3::Event::N-Event**.
* Class Filename `lib/Gnome/Gdk3/Event/N-Event.rakumod`.
* Test Filename `t/N-Event.rakutest`.
* Doc filename `doc/N-Event.rakudoc`.

### Other types
Other types like enumerations, constants and standalone functions are gathered in one file named after the C source file it is defined in. For example the <ins>Window</ins> class in Gtk version 3 has a few enumerations.
* Class name **Gnome::Gtk3::T-Window**.
* Class Filename `lib/Gnome/Gtk3/T-Window.rakumod`.
* Test Filename `t/T-Window.rakutest`.
* Doc filename `doc/T-Window.rakudoc`.

---
## Call interface

There are two ways to generate the methods;
* First one is to make a Hash where all information is available. This type is now generated.
* In the mean time I've investigated a way to get rid of the FALLBACK method hidden in the **TopLevelClassSupport**. Added routines there, copied from **GnomeRoutineCaller**, and made methods in **Window**, **Button**, and **Grid** to see the effect using a simple program `button02.raku` (originally found in the `GTK::Simple` distribution). At first site, it does not show a big improvement but I need to benchmark the implications of the changes for compile-time versus run-time in comparison with the previous version.
* A third method would be to use RakuAst to generate a method when it is needed.

### Current implementation

All routines available in a class, role or as standalone functions are generated in a data structure as a Hash table. A small sample from the **Gnome::Gtk3::Label** class;

```
my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-label => %( :is-symbol<gtk_label_new>, :type(Constructor), :returns(N-Object), :parameters([ Str])),
  new-with-mnemonic => %( :is-symbol<gtk_label_new_with_mnemonic>, :type(Constructor),:returns(N-Object), :parameters([ Str])),

  #--[Methods]------------------------------------------------------------------
  get-angle => %( :is-symbol<gtk_label_get_angle>, :returns(gdouble)),
  get-ellipsize => %( :is-symbol<gtk_label_get_elipsize>, :returns(GEnum), :cnv-return(PangoEllipsizeMode)),
  get-justify => %( :is-symbol<gtk_label_get_justify>, :returns(GEnum), :cnv-return(GtkJustification)),
…
  set-justify => %( :is-symbol<gtk_label_set_justify>, :parameters([GEnum])),
  set-label => %( :is-symbol<gtk_label_set_label>, :parameters([Str])),
  set-line-wrap => %( :is-symbol<gtk_label_set_line_wrap>, :parameters([gboolean])),
  set-line-wrap-mode => %( :is-symbol<gtk_label_set_line_wrap_mode>, :parameters([GEnum])),
  set-lines => %( :is-symbol<gtk_label_set_lines>, :parameters([gint])),
…
```

The key of the `$methods` hash is the name of the function as the developer uses it. It is translated into the real gnome name. E.g. `get-angle` in the above example, becomes `gtk_label_get_angle`. Each value of a key is a hash describing the interface and how to call it.

* **type**; An enumeration and can be one of `Function`, `Method` or `Constructor`. The Method is never used because it is taken as a default. Choosen because there are more methods than constructors or functions. This saves space and compile time. Methods always have the classes native object as its first argument. This is not visible in the parameters array and is automatically inserted before calling.
* **parameters**; This is an array of parameter types for each expected argument to the function. The types are defined in module **Gnome::N::GlibToRakuTypes**.
* **returns**; A type of the return value if there is any.
* **type-name**; An enumeration type. When a return type is a `GEnum` (an enumeration) the number is translated into the enum name.
* **variable-list**; A boolean value which says that the argument list is longer than provided in the parameters array. The user must provide the type and value for the rest of the arguments.
* **is-symbol**; A string with the native name of a constructor, method or function.


### Types of argument lists
#### Empty argument lists

This is easy to use. For example in the `get-angle` example above, shows only a return value of a `gdouble` which would become a Raku `Num` type.


#### With fixed argument list

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


#### With variable argument lists
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

#### Pointer arguments

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


### New tested version

This version is making a method for each function like in api<1>. The difference is that it calls a routine with about the same number of arguments. This routine gets the address of the function and stores it. Then it will call the function with the arguments provided returning any results. For constructors it needs also a bit of code in the `BUILD()` submethod.

An example from the **Window** class showing a constructor, a method, and a function;
```
method new-window ( *@arguments ) {
  self.bless(
    :new-window(
      @arguments,
      %( :returns(N-Object), :is-symbol<gtk_window_new> )
    )
  );
}

method set-title ( *@arguments ) {
  self.object-call(
    @arguments, %( :parameters([Str]), :is-symbol<gtk_window_set_title>),
  );
}

method get-default-icon-name ( *@arguments ) {
  self.objectless-call(
    @arguments,
    %( :parameters([gboolean]),
       :is-symbol<gtk_window_get_default_icon_name>, :returns(Str)
    )
  );
}
```

The call `self.bless()` will end up in `BUILD()` where a call is made to `objectless-call()`. The other methods call `object-call()` or `objectless-call()` depending on the fact if the routine needs the native object or not.

Also the library name needs to be set beforehand in `BUILD()`. A new field is used here; `is-symbol` named after the native sub declaration where a trait `is symbol(…)` can be used. This saves some time substituting the string getting the same result.

---
# Benchmarks

Program `bench01.raku` is made to test the current implemented method versus a new idea making methods for each entry from the `$methods` Hash.

There are two subs creating a widget, set text, get text and destroy the object
The widget is a button. The method implemented has a different name but ends up calling the same native function.
```
# FALLBACK method for normal routines
sub set1-fallback ( ) {
  with my Gnome::Gtk4::Button $button .= new-button('text') {
    .set-label('t2');
    my Str $txt = .get-label;
    .clear-object;
  }
}

# Methods for renamed routines
sub set2-methods ( ) {
  with my Gnome::Gtk4::Button $button .= M-new-button {
    .M-set-label('label');
    my Str $txt = .M-get-label;
    .clear-object;
  }
}

# Function create, this will not be timed.
set1-fallback;
set2-methods;

my %r = timethese 10000, {
  set1-fallback => &set1-fallback,
  set2-methods => &set2-methods,
}, :statistics;

say ~%r;
```

## Results

test | max | min | mean |
|--|--|--|--|
set1-fallback | 0.008176582 | 0.000369133 | 0.000426
set2-methods  | 0.003227472 | 0.000308849 | 0.000351

The mean difference of one call is only about a tenth of a µsec faster for the methods implementation which is not something to write home about. Also when there are a lot of methods, I can imagine that the compile-time for it would be greater than compiling hashes.

I haven't shown the time needed to map the function to its native counterpart in a library because it is the same for each implementation. However, it takes much time to get that done. Mostly something like a tenth of a second.

## Conclusion
Whatever is implemented, it is clear that moving the creation of functions to run-time has the best impact on user experience. Most of the time a few calls are needed per class to get the things done and therefore many functions do not need to be compiled.

