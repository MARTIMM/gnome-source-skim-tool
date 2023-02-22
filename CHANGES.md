## Change log

 * 2023-02-20 0.4.1
 * Skip deprecated functions

* 2023-02-20 0.4.0
  * **Gnome::SourceSkimTool::SkimGtkDoc::PropDoc** Get properties info

* 2023-02-18 0.3.1
  * **ModuleDoc**; Add function return value and parameters
  * **ModuleDoc**; Add return value doc

* 2023-02-17 0.3.0
  * **ModuleDoc**; Add scan of functions

* 2023-02-16 0.2.0
  * **Gnome::SourceSkimTool::SkimGtkDoc::ModuleDoc** Add scan of descriptions

* 2023-02-10 0.1.1
  * Got GtkDoc to work, especially the generated program `*-scan.c`.

* 2023-02-06 0.1.0
  * The thought was to rewrite the original code from `gnome-gtk3-source-skim-tool.raku` and its derivatives which I used to generate the Raku code. Now I've found out about GtkDoc. This program scans through the Gnome sources and generates several text and xml files. The result of the scan is available in sections describing code, calls, macros, docs, and more. So that will become the vehicle to generate the Raku code and documentation (if I get it to work).

* 2023-01-01 0.0.1
  * Setup **Gnome::SourceSkimTool**

