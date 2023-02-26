# Gnome source code skimmer

## Purpose

The purpose is to get the information out of the source code (`.h` and `.c` files) of packages of Gnome like Glib, (with Gio, GObject), Pango and Cairo (for which Gnome has bindings to), Gtk and Gdk (versions 3 and 4) Atk and a few others.

I have done that myself in the past using a single program and generate Raku modules from the retrieved information. The program is getting a bit awkward to maintain it, because of writing differences found in the code.

Now I've come across a package of Gnome called `GtkDoc`. It is a bit of a beast to get that working. Gnome apologises for that, that it was intended to be used internally only to get their documentation in a neat display.

In this GtkDoc package there are programs which read those source files and generate files in all sorts of formats. The modules and programs in this Raku package can read the generated files (of which we only need a few of them) and generate the Raku modules which can then access the gnome libraries. The Raku modules come with documentation and a test template for initialization, method calls, signal handling and property testing. Markdown or HTML can be generated from the documentation using Raku pod rendering programs.

The generated Raku modules would have some work afterwards to remove problems which can not be handled by the modules of this Raku package.


## Description

This is a description of how to prepare the GtkDoc and Gnome libraries before we are able to get all the information we need.

### Preparations

There are only 3 programs needed. One of them creates a C-program and must be compiled and linked against external libraries. On this computer I have choosen to just compile them but not to install them to prevent any inconsistencies with other programs in the system. So it is important to download the sources of the same versions as those of your libraries.

#### Directory structure
The root of it all is at `$*HOME/.config/io.github.martimm.source-skim-tool`. The directory where Gnome sources are downloaded and unpacked is `Gnome` in this root. The generated files from GtkDoc go to the `GtkDoc` directory.
The files are prefixed with text given to the `--module` option of the programs.
The `Gtkdoc/Gtk3` is also provided to an option. In this case to get info from the Gtk version 3 sources.

```plantuml
@startwbs
* root
** Gnome
** Gtkdoc
*** Gtk3
**** docs
*** …
@endwbs
```

#### Compiling Glib, Gio and GGbject libs

To compile a generated program right, we must do some extra work. See also [Beyond Linux® From Scratch](https://www.linuxfromscratch.org/blfs/view/svn/general/glib2.html).

* Go to the Gnome directory.
* Download glib-2.74.5.tar.xz and a patch glib-2.74.5-skip_warnings-1.patch.
* Then run the following;
  ```
  > tar xvf glib-2.74.5.tar.xz
  > cd glib-2.74.5
  > patch -Np1 -i ../glib-2.74.5-skip_warnings-1.patch
  > mkdir build
  > cd build
  > meson --prefix=/usr --buildtype=release -Dman=true ..
  > ninja
  > setenv LC_ALL C
  > ninja test
  ```

### GtkDoc

The example below shows the commands to get the information from the Gtk version 3 sources.

Go to the Gnome directory and download the Gtk source. in this case for version 3.24.24. Unpack the tar-file and go back to the top directory.
```
> mkdir -p Gtkdoc/Gtk3/docs
> cd Gtkdoc/Gtk3
> gtkdoc-scan --module gtk3 --output-dir . --source-dir ../../Gnome/gtk+-3.24.24/gtk
> gtkdoc-scangobj --module gtk3 --verbose --cflags '\-I../../Gnome/glib-2.74.5/glib -I../../Gnome/glib-2.74.5/gobject -I../../Gnome/glib-2.74.5 -I../../Gnome/glib-2.74.5/build/glib -I../../Gnome/glib-2.74.5/build/' --ldflags '\-L../../Gnome/glib-2.74.5/build/gobject -L../../Gnome/glib-2.74.5/build/glib -L/usr/lib64 -lgobject-2.0 -lglib-2.0 -lgtk-3 -lgobject-2.0 -lglib-2.0 -lgtk-3'
> gtkdoc-mkdb --module gtk3 --source-dir ../../Gnome/gtk+-3.24.24/gtk --output-dir docs --xml-mode
```
However, the compiling and linking of `gtk3-scan.c` has errors. It cannot find all the `*_get_type` references. They seem not to be defined in any of the used dynamic libraries. I found out that the references are all named in the file `Gtkdoc/Gtk3/gtk3.types`. Removing some entries from that file also showed that less linking errors were shown. Therefore we need to filter out those functions from the `gtk3.types` list.

Other errors might be found when compiling for other modules like for example for `Gio`, `Pango`, `Cairo`, etc. This is not yet checked, w'll see what the future will bring.


#### GtkDoc tools diagram

A diagram showing the programs and the generated files.

```plantuml
@startdot
'scale 0.6
digraph gtkdoc {
    /* graph attributes */
    /*rankdir=BT;*/
    
    /* default node attributes */
    node [ shape=box];
    
    /* tools nodes */
    gtkdoc_scan [label="gtkdoc-scan",shape="ellipse" ];
    gtkdoc_scangobj [label="gtkdoc-scangobj",shape="ellipse" ];
    gtkdoc_mkdb [label="gtkdoc-mkdb",shape="ellipse" ];
    gtkdoc_mkhtml [label="gtkdoc-mkhtml",shape="ellipse" ];
    gtkdoc_fixxref [label="gtkdoc-fixxref",shape="ellipse" ];
    gtkdoc_rebase [label="gtkdoc-rebase",shape="ellipse" ];
    gtkdoc_check [label="gtkdoc-check",shape="ellipse" ];

    /* file nodes */
    headers [label="headers\nall headers under DOC_SOURCE_DIR\n+EXTRA_HFILES\n-IGNORE_HFILES"];
    'sources [label="source code\nall files under DOC_SOURCE_DIR\nmatching SUFFIXES or *.{c,h}"];
    sources [label="source code\n*.{c,h}"];
    binary [label="compiled binary"];
    xml [label="docbook xml"];
    html [label="html"];
    module_decl_list [label="*-decl-list.txt" ];
    module_decl [label="*-decl.txt" ];
    module_types [label="*.types" ];
    module_sections [label="*-section.txt" ];
    module_signals [label="*.signals" ];
    module_hierarchy [label="*.hierarchy" ];
    module_interfaces [label="*.interfaces" ];
    module_prerequisites [label="*.prerequisites" ];
    module_args [label="*.args" ];
    module_undeclared [label="*-undeclared.txt" ];
    module_undocumented [label="*-undocumented.txt" ];
    module_unused [label="*-unused.txt" ];
 
    /* tool invocation */
    gtkdoc_scan -> gtkdoc_scangobj -> gtkdoc_mkdb -> gtkdoc_mkhtml -> gtkdoc_fixxref -> gtkdoc_rebase -> gtkdoc_check [style="dotted"];

    /* file usage */
    headers -> gtkdoc_scan;
    gtkdoc_scan -> module_sections [label="--rebuild-sections", style="dashed"];
    gtkdoc_scan -> module_types [label="--rebuild-types", style="dashed"];
    gtkdoc_scan -> module_decl;
    gtkdoc_scan -> module_decl_list;
 
    binary -> gtkdoc_scangobj;
    module_types -> gtkdoc_scangobj;
    gtkdoc_scangobj -> module_signals;
    gtkdoc_scangobj -> module_hierarchy;
    gtkdoc_scangobj -> module_interfaces;
    gtkdoc_scangobj -> module_prerequisites;
    gtkdoc_scangobj -> module_args;

    sources -> gtkdoc_mkdb;
    module_sections -> gtkdoc_mkdb;
    module_decl -> gtkdoc_mkdb;
    module_signals -> gtkdoc_mkdb;
    module_args -> gtkdoc_mkdb;
    module_hierarchy -> gtkdoc_mkdb;
    module_interfaces -> gtkdoc_mkdb;
    module_prerequisites -> gtkdoc_mkdb;
    gtkdoc_mkdb -> xml;
    gtkdoc_mkdb -> module_undeclared;
    gtkdoc_mkdb -> module_undocumented;
    gtkdoc_mkdb -> module_unused;
    
    xml -> gtkdoc_mkhtml -> html;
    
    html -> gtkdoc_fixxref -> html;
    html -> gtkdoc_rebase -> html;
    
    module_undeclared -> gtkdoc_check;
    module_undocumented -> gtkdoc_check;
    module_unused -> gtkdoc_check;
}
@enddot
```

# The Raku modules

The module **Gnome::SourceSkimTool::Prepare** takes care of the GtkDoc generation steps but not of the Glib preparations. **Gnome::SourceSkimTool::SkimGtkDoc** takes care of reading the GtkDoc files to get the information.

## A diagram

A diagram of the work involved and what the Raku modules do. `Download` means everything coming from elsewhere and unpacking it. `mod*.xml` means the module names from some gnome package, e.g. `gtkbutton.xml`.
<!-- `prefixed` is the prefix text such as `gtk3`.-->


```plantuml
@startdot
digraph gtkdoc {

  prepare [label="prepare\nGlib"]
  modx [label="mod*.xml", shape=box, color=blue]
  'pfxsigs [label="prefixed.signals", shape=box, color=blue]
  'pfxargs [label="prefixed.args", shape=box, color=blue]
  depr [label="deprecated\ninfo", shape=box, color=blue]
  docbook [label="docbook files\n*.xml", shape=box, color=blue]
  ResultStore [label="Store\nResults", shape=box, color=blue]
  RakuModule [label="Raku\nmodules", shape=box, color=blue]
  RakuTest [label="Raku module\ntest files", shape=box, color=blue]
  SkimTool [label="GtkDoc Skim Tool", color=blue]
  ph1  [label="phase1\nfiles", shape=box]
  ph2  [label="phase2\nfiles", shape=box]

  'Download and prepare
  download -> prepare [style="dotted"]
  prepare -> gtkdoc_scan [style="dotted"]

  'phase 1
  gtkdoc_scan -> ph1

  'phase 2
  ph1 -> gtkdoc_scangobj
  'gtkdoc_scangobj -> modx
  'gtkdoc_scangobj -> pfxsigs
  'gtkdoc_scangobj -> pfxargs
  gtkdoc_scangobj -> ph2

  'phase 3  
  'pfxsigs -> gtkdoc_mkdb
  'pfxargs -> gtkdoc_mkdb
  'modx -> gtkdoc_mkdb
  ph2 -> gtkdoc_mkdb
  gtkdoc_mkdb -> docbook
  gtkdoc_mkdb -> depr
  gtkdoc_mkdb -> modx
  
  'raku program
  modx -> SkimTool
  'pfxsigs -> SkimTool
  'pfxargs -> SkimTool
  depr -> SkimTool
  docbook -> SkimTool
  SkimTool -> ResultStore
  SkimTool -> RakuModule
  SkimTool -> RakuTest
}

@enddot
```
