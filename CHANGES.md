## Change log

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

