
The answer to the following question;
`Gnome. GdkPixbuf is not deprecated but many image viewers are deprecating pixbuf setters`

is very interesting, here it is...

# The answer
Correct. GdkPixbuf itself is not deprecated, but its direct integration with GTK widget setters (like `gtk_image_set_from_pixbuf` in older versions) has changed significantly.

In GTK 4, the framework moved toward a modern, hardware-accelerated rendering pipeline. As a result, widgets now prefer GdkTexture or GskRenderNode instead of the older CPU-bound GdkPixbuf.

## The Shift in GTK 4 Image Viewers
If you are developing or updating a GNOME image viewer, the shift away from Pixbuf setters comes down to architecture:

* GdkPixbuf stores pixel data in CPU memory (RAM) as a simple client-side buffer.
* GdkTexture represents an image that can be directly uploaded to the GPU (VRAM) for efficient rendering and scaling.

Because of this, GtkImage in GTK 4 no longer relies on GdkPixbuf as its native format. Instead, it uses GdkTexture.

### The Modern Way to Set Images
You can still use GdkPixbuf to load and manipulate images (e.g., scaling, rotating, or loading from exotic formats via gdk-pixbuf-loader). However, when it is time to display it in a widget, you must wrap or convert it:

In C:
```c
// Instead of the deprecated GTK 3 style:
// gtk_image_set_from_pixbuf(GTK_IMAGE(image_widget), pixbuf);

// Use the GTK 4 texture-based approach:
GdkTexture *texture = gdk_texture_new_for_pixbuf(pixbuf);
gtk_image_set_from_paintable(GTK_IMAGE(image_widget), GDK_PAINTABLE(texture));
g_object_unref(texture);
```

In Raku
```raku
my $e = CArray[N-Error].new(N-Error);
my Gnome::Gdk4::Pixbuf $pixbuf .= new-from-file( $path-to-picture, $e);
if $e[0].defined {
  die $e[0].message;
} else {
  my Gnome::Gdk4::Texture $texture .= new-for-pixbuf($pixbuf);
  my Gnome::Gtk4::Image $image .= new-from-paintable($texture);
  $texture.clear-object;
}
```

## Direct Texture Loading (Recommended)
If you do not need to do manual pixel manipulation, the best practice in modern GNOME apps is to bypass GdkPixbuf entirely and load files straight into a texture:

In C:
```c
// Load directly to GPU-friendly texture
GdkTexture *texture = gdk_texture_new_from_file(file, &error);
gtk_image_set_from_paintable(GTK_IMAGE(image_widget), GDK_PAINTABLE(texture));
```
In Raku:
```raku
my $e = CArray[N-Error].new(N-Error);
my Gnome::Gdk4::Texture $texture .= new-from-filename( $path-to-picture, $e);
if $e[0].defined {
  die $e[0].message;
} else {
  my Gnome::Gtk4::Image $image .= new-from-paintable($texture);
  $texture.clear-object;
}
```

This transition reduces memory copying between the CPU and GPU, leading to much smoother performance in modern image viewers.
