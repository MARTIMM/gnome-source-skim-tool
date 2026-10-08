# Core Library Naming Conventions

|Library Role	|Linux (.so)	|Windows (.dll)	|macOS / Apple (.dylib)|
|-|-|-|-|
GTK (UI elements)	|libgtk-4.so libgtk-3.so|libgtk-4-0.dll libgtk-3-0.dll|libgtk-4.1.dylib libgtk-3.0.dylib
GDK (Windowing abstraction)|libgdk-4.so libgdk-3.so|libgdk-4-0.dll libgdk-3-0.dll|libgdk-4.1.dylib libgdk-3.0.dylib
GLib (Data types & loops)|libglib-2.0.so|libglib-2.0-0.dll|libglib-2.0.dylib
GObject (Type & object system)|libgobject-2.0.so|libgobject-2.0-0.dll|libgobject-2.0.dylib
GIO (VFS, networking & I/O)|libgio-2.0.so|libgio-2.0-0.dll|libgio-2.0.dylib
Pango (Text layout rendering)|libpango-1.0.so|libpango-1.0-0.dll|libpango-1.0.dylib
Cairo (2D graphics engine)|libcairo.so|libcairo-2.dll|libcairo.2.dylib
gdk-pixbuf (Image loading)|libgdk_pixbuf-2.0.so|libgdk_pixbuf-2.0-0.dll|libgdk_pixbuf-2.0.dylib
libadwaita (Modern GNOME UI)|libadwaita-1.so|libadwaita-1-0.dll|libadwaita-1.dylib
|||||
Sandboxed and extendable image loading|libglycin-2.so|libglycin-2-0.dll|libglycin-2.dylib

Key Platform Differences

* Linux: Uses the standard lib[name].so convention. Major API versions are typically appended directly to the filename (e.g., -4 for GTK4, -2.0 for GLib 2). 
* Windows: Uses the .dll extension. Compiled packages (such as those from MSYS2 or MinGW) append -0 or another ABI suffix to the end of the base name to signify binary compatibility layout. 
* macOS: Uses the .dylib format. Filenames include the internal library versioning before the extension (e.g., .4.dylib or .2.0.dylib) depending on how they are built via frameworks like Homebrew or GTK-OSX. 

# Location of libraries

|Linux|Windows|macOS/Apple|
|-|-|-|
/usr/lib/ |  C:\Windows\System32\ | /usr/lib/
/usr/lib64/| C:\Windows\SysWOW64\ |
