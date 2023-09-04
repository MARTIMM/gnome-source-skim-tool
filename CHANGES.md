## Change log

<!--
TODO modify markdown links in text or in Raku links when it shows use of url

TODO Add explanations of module documentation layout in the references of the documentation on site.
* Add info about the glib types used and what it means in Raku.
* That properties are mostly not needed because of their getters and setters.
* What does a function, constructor and method mean for gnome and how is translated.
* Referencing, dereferncing and floating references.
* Naming the classes, structures, unions, enumerations and the modules where they are defined.
* C-examples and converting to Raku

TODO add command to generate code/doc/test at the top of the generated files

TODO type changes
  Unknown gir type to convert to native raku type 'record' for ctype 'GtkRecentInfo'
  Unknown gir type to convert to raku type 'record' for ctype 'GtkRecentInfo', '(Any)'
   Unknown gir type to convert to native raku type 'callback' for ctype 'GtkRecentSortFunc'
  Unknown gir type to convert to raku type 'callback' for ctype 'GtkRecentSortFunc', '(Any)'
  Unknown gir type to convert to raku type '-' for ctype 'gpointer', '(Any)'
  Unknown gir type to convert to native raku type 'callback' for ctype 'GDestroyNotify'
  Unknown gir type to convert to raku type 'callback' for ctype 'GDestroyNotify', '(Any)'

TODO better BUILD generation
TODO Process constants and alias
TODO Generate doc. Review for class new for interface, record and union
TODO Test marks in code like '#TM:0:has_toplevel_focus' should go to the test file because 1) after changes it saves compilation and 2) the mark is for testing

TODO Find out if :api<2> is a good enough separation from the old packages
* See https://stackoverflow.com/questions/55671684/how-does-raku-decide-which-version-of-a-module-gets-loaded
* https://docs.raku.org/language/compilation#$*REPO

TODO Prevent overwriting of test files. They may be changed a lot after generation

TODO investigate using constructors directly instead of using BUILD with options
-->

<!-- Testing command with timing -o for dump to file
/usr/bin/time -f "Program: %C\nTotal time: %E\nUser Mode (s) %U\nKernel Mode (s) %S\nCPU: %P" raku Window.rakutest

/usr/bin/time -f "P:%C TT:%E UM:%U KM:%S C:%P MJP:%F MNP:%R MR:%M" -a -o Window.log raku Window.rakutest

kaal '/usr/bin/time raku Window.rakutest'
2.18user 0.17system 0:02.52elapsed 93%CPU (0avgtext+0avgdata 388208maxresident)k
0inputs+0outputs (0major+74336minor)pagefaults 0swaps
-->
* 2023-08-09 0.10.3
  * Many bugs fixed. Seems possible to generate working code without modifying much.
  * Started to generate Pango code.
  * First test files for classes generated.

* 2023-08-05 0.10.2
  * Moved the GnomeRoutineCaller module from `Gnome::Glib` to `Gnome::N`. This is a better location as a supporting module.
  * Another support module is made, called **Gnome::N::GObjectSupport**. This will hold methods like `.register-signal()` which were originally stored in **Gnome::GObject::Object**. It is automatically added to that module as a role. This is convenient now that everything is generated.

* 2023-07-26 0.10.1
  * Moved code from `SearchAndSubstitute()` back to Code module.
  * Add a program to make lists of gnome modules in old and in new packages. This is to be able to set the proper `:api<>` or inhibit `use` statements. For this to work `$*external-modules` needed to change as well as some methods.

* 2023-07-21 0.10.0
  * New modules and old one renamed.
  * Test enumerations, constants and bitfields completed.

* 2023-07-20 0.9.1
  * Options -f, -c, -r, -i, -u are removed to have the default effect of -f. Option -m is renamed to -c

* 2023-06-28 0.9.0
  * Add module **Gnome::SourceSkimTool::Union** to process union structures.
  * Tests with a few generated modules looks promising. The new modules used in the test are: Window, Bin, Comtainer, Widget and Buildable. The modules upon which it still depends are from the older Gtk libraries. Running the same test file `Window.rakutest` (only once) it shows the following;

    | Elapsed time | User time| Kernel time | Cpu % |  Note
    |---------|----------|-------------|--------------|------------------------
    | 0:02.33 |  1.73 | 0.16  |  81 | Old library
    | 0:34.73 | 43.19 | 2.03  | 130 | Old library with removed .precomp
    | 0:37.57 | 46.45 | 2.15  | 129 |
    | 0:33.00 | 41.69 | 1.97  | 132 |
    | 0:02.90 |  2.44 | 0.21  |  91 | New modules
    | 0:03.13 |  2.60 | 0.24  |  90 | New modules with removed .precomp
    | 0:03.37 |  3.18 | 0.25  | 101 |

    The tests show that normal runtimes are not differing much. But when everyhing needs to be recompiled, the newer modules compile much faster.
    I must make a note here. Removing the `.precompile` directories in the old Gtk library, involves more compiling for other modules needed as a side effect instead of only the Window, Bin, Container, Widget and Buildable modules. Its size after running is 16.2 Mb over 66 files and 29 sub folders(~ 245Kb/file). The newer .precomp files are 16.3 Kb over 5 files and 3 sub folders(~3kb/file). That's quite a difference. If I take this difference in files into account, about 66/5, and the increase in time, less than a sec., it would become 10 sec. at most.
    When the project evolves, these tests are repeated to see if this is really true.
  * Record and Union structures are generated in separate files. This means that there are more modules than in the original project. E,g. the original **Gnome::Gdk3::Events** have all event structures gathered in one file. The filenames will be something like `N-Record-name.rakumod` for each `N-Record-name` type. The same goes for unions. In a way this is the same for the `N-GObject` stored in `N-GObject.rakumod` in the **Gnome::N** package.

* 2023-06-19 0.8.3
  * Add module **Gnome::SourceSkimTool::File** to scan through data using a filename defined in field `class-file` in the `repo-object-map.yaml`. This may remove options -c, -i and -r.
  * Add bitfields. Generated as enumerations but are mostly used for masks. The type GFlag is used for those indicating an unsigned integer type.

* 2023-06-14 0.8.2
  * Renamed a few modules and classes.
  * Add records. Starting with Gdk events. All the records are in separate modules like EventButton, EventConfigure etc.

* 2023-06-12 0.8.1
  * Setup with Hash done on one class starting with **Gnome::Gtk3::Window**. The choice to use a hash is because there is no dependency on the gir libs or gir XML files. Focus is on generating code. The api-tag on a module is set to `:api<2>` to prevent looking for the wrong (older) modules. Next implemented modules are in the parent chain of Window, i.e. **Gnome::Gtk3::Bin**, **Gnome::Gtk3::Container** and **Gnome::Gtk3::Widget**. Further up is still on the old libraries. Looks promising.
  * Also roles can be implemented starting with **Gnome::Gtk3::Buildable**. Some trouble are fixed in using FALLBACK in roles. Fallback routine in **Gnome::N::TopLevelSupportClass** needed some changes to behave differently when in a newer class. Old software is tested and is ok.
  * Add enumerations.

* 2023-05-28 0.8.0
  After an interesting discussion on github issue #1 I created a test of a Window module. Suggestions were to use the GIR libraries or the XML files directly so there would not be any native subroutines declared in the module. This will save a lot of time when installing the module.
  This, however, adds a dependency which the user must install on their machines either the libraries or the XML files. Searching throught the XML files take a lot of time so this is not the right way.
  I've come up with an other solution which removes the dependency by generating a hash with all data to call a native function. Parsing should be quicker but the runtime slower because there are more calls to make before finally call the native routine.

* 2023-05-15 0.7.1
  * New module ListGirTypes to get a list of the introspect types and which names have a specified type.
  * Things get too unwieldy. Looking at the huge inventory of records in GLib I decided to split the generation of modules into several parts; classes, records and interfaces. Also documentation of all parts as in, description,  API parameters of methods, functions, callbacks and handlers.
  * ClassModule works again.
  * InterfaceModule works.

* 2023-05-12 0.7.0
  * Look into the lowest level of libs: Glib.
  * Generate modules from records. Records in the gir files are the structures defined in C.

* 2023-05-10 0.6.2
  * Generate functions

* 2023-05-03 0.6.1
  * Add commented fallback routines which are to be deprecated with proper version messages. They are commented out because newer modules must not use it and older routines must be deprecated.

* 2023-04-26 0.6.0
  * Move methods from GenRakuModule to a new module SearchAndSubstitute
  * Generating roles
  * Importing roles

* 2023-04-20 0.5.6
  * Generate different types of methods depending on arguments and return types.
    * Coercion to native types for objects and other Raku types.
    * Return List for pointer variables who get values returned that way.
    * Convert Str Array's to and from native CArray's.

* 2023-04-17 0.5.5
  * Generate methods.

* 2023-04-07 0.5.4
  * Generate BUILD submethod.
  * Add constructor native subs.

* 2023-04-01 0.5.3
  * Generate property information.

* 2023-04-01 0.5.2
  * Generate signal information.

* 2023-03-29 0.5.1
  * Generate class description
  * Generate `use` and `unit` lines
  * Convert signal and property info.
  * Convert Markdown links.
  * Convert code sections.

* 2023-03-11 0.5.0
  * Looking into other repositories such as Glib I've seen that there are problems reading the xml code generated by gtkdoc. For instance, the file error-reporting.xml has symbols used in the docs to emphasize words like `<MODULE>`. That is not properly escaped with `&lt;` and `&gt;`. So those words are seen as an XML element which causes errors. It is imparative that the Raku modules can handle all data in the same way and therefore the gtkdoc is not the proper way to go further. Luckily, there is still another way and that is using the GObject Introspection Repository which consists of a library of routines to get the classes and methods information as well as the signals and properties. The documentation for all this info can be found in so called `.gir` files which are XML files. This also means that, when it works, all locally downloaded source code in the `Gnome` directory can be removed.

* 2023-02-04 0.4.3
  * Need to change the selection based on `$*sub-prefix` because of the 3 packagages Glib, Gio and GObject. The functions prefix all start with `g_` and therefore it cannot decide to which package the prefix belongs.
  * GtkDoc is now working on glib, gobject, gio and gdk version 3 too. Still stuck on gtk version 4.

* 2023-03-02 0.4.2
  * **ApiDoc** Add Hierarchy to objects.yaml.

* 2023-02-27 0.4.1
  * **ModuleDoc** Get enums names, store in module yaml file.
  * **ModuleDoc** Get enum values, store in objects.yaml.

* 2023-02-25 0.4.0
  * **Gnome::SourceSkimTool::SkimGtkDoc::ApiDoc** Get overview of all objects, types and more from `api-index-full.xml`.
  * **ApiDoc** Get deprecated data from `api-index-deprecated.xml`.
  * Store in objects.yaml.

* 2023-02-20 0.3.2
  * **ModuleDoc** Get signals info.
  * **ModuleDoc** Get properties info.
  * Store in module yaml file.

* 2023-02-18 0.3.1
  * **ModuleDoc**; Add function return value and parameters.
  * **ModuleDoc**; Add return value doc.

* 2023-02-17 0.3.0
  * **ModuleDoc**; Add scan of functions from generated module files e.g. `gtkbutton.xml`

* 2023-02-16 0.2.0
  * **Gnome::SourceSkimTool::SkimGtkDoc::ModuleDoc** Add scan of descriptions

* 2023-02-10 0.1.1
  * Got GtkDoc to work, especially the generated program `*-scan.c`.

* 2023-02-06 0.1.0
  * The thought was to rewrite the original code from `gnome-gtk3-source-skim-tool.raku` and its derivatives which I used to generate the Raku code. Now I've found out about GtkDoc. This program scans through the Gnome sources and generates several text and xml files. The result of the scan is available in sections describing code, calls, macros, docs, and more. So that will become the vehicle to generate the Raku code and documentation (if I get it to work).

* 2023-01-01 0.0.1
  * Setup **Gnome::SourceSkimTool**

