Project Description
-------------------

  * **Distribution:** Gnome::Pango

  * **Project description:** Modules for package Gnome::Pango:api<2>. The language binding to Pango: Internationalized text layout and rendering

  * **Project version:** 0.1.2

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

![](images/context.png)

Description
===========

A `PangoContext` stores global information used to control the itemization process.

The information stored by `PangoContext` includes the fontmap used to look up fonts, and default values such as the default language, default gravity, or default font.

To obtain a `PangoContext`, use [method `$Pango`.FontMap.create_context].

Class initialization
====================

new
---

### :native-object

Create an object using a native object from elsewhere. See also **Gnome::N::TopLevelSupportClass**.

    multi method new ( N-Object :$native-object! )

new-context
-----------

Creates a new `PangoContext` initialized to default values.

This function is not particularly useful as it should always be followed by a [method `$Pango`.Context.set_font_map] call, and the function [method `$Pango`.FontMap.create_context] does these two steps together and hence users are recommended to use that.

If you are using Pango as part of a higher-level system, that system may have it's own way of create a `PangoContext`. For instance, the GTK toolkit has, among others, `gtk_widget_get_pango_context()`. Use those instead.

    method new-context ( --> Gnome::Pango::Context )

Methods
=======

changed
-------

Forces a change in the context, which will cause any `PangoLayout` using this context to re-layout.

This function is only useful when implementing a new backend for Pango, something applications won't do. Backends should call this function if they have attached extra data to the context and such data is changed.

    method changed ( )

get-base-dir
------------

Retrieves the base direction for the context.

See [method `$Pango`.Context.set_base_dir].

    method get-base-dir (--> PangoDirection )

Return value; the base direction for the context.. An enumeration.

get-base-gravity
----------------

Retrieves the base gravity for the context.

See [method `$Pango`.Context.set_base_gravity].

    method get-base-gravity (--> PangoGravity )

Return value; the base gravity for the context.. An enumeration.

get-font-description
--------------------

Retrieve the default font description for the context.

    method get-font-description (--> CArray[N-FontDescription]  )

Return value; a pointer to the context's default font description. This value must not be modified or freed.. 

get-font-map
------------

Gets the `PangoFontMap` used to look up fonts for this context.

    method get-font-map (--> N-Object )

Return value; the font map for the. `PangoContext` This value is owned by Pango and should not be unreferenced.. 

get-gravity
-----------

Retrieves the gravity for the context.

This is similar to [method `$Pango`.Context.get_base_gravity], except for when the base gravity is %PANGO_GRAVITY_AUTO for which [func `$Pango`.`Gravity enumeration`.get_for_matrix] is used to return the gravity from the current context matrix.

    method get-gravity (--> PangoGravity )

Return value; the resolved gravity for the context.. An enumeration.

get-gravity-hint
----------------

Retrieves the gravity hint for the context.

See [method `$Pango`.Context.set_gravity_hint] for details.

    method get-gravity-hint (--> PangoGravityHint )

Return value; the gravity hint for the context.. An enumeration.

get-language
------------

Retrieves the global language tag for the context.

    method get-language (--> CArray[N-Language]  )

Return value; the global language tag.. 

get-matrix
----------

Gets the transformation matrix that will be applied when rendering with this context.

See [method `$Pango`.Context.set_matrix].

    method get-matrix (--> CArray[N-Matrix]  )

Return value; the matrix, or `Nil` if no matrix has been set (which is the same as the identity matrix). The returned matrix is owned by Pango and must not be modified or freed.. 

get-metrics
-----------

Get overall metric information for a particular font description.

Since the metrics may be substantially different for different scripts, a language tag can be provided to indicate that the metrics should be retrieved that correspond to the script(s) used by that language.

The `PangoFontDescription` is interpreted in the same way as by [func `$itemize`], and the family name may be a comma separated list of names. If characters from multiple of these families would be used to render the string, then the returned fonts would be a composite of the metrics for the fonts loaded for the individual families.

    method get-metrics ( CArray[N-FontDescription]  $desc, CArray[N-Language]  $language --> CArray[N-FontMetrics]  )

  * $desc; a `PangoFontDescription` structure. `Nil` means that the font description from the context will be used..

  * $language; language tag used to determine which script to get the metrics for. `Nil` means that the language tag from the context will be used. If no language tag is set on the context, metrics for the default language (as determined by [func `$Pango`.Language.get_default] will be returned..

Return value; a `PangoFontMetrics` object. The caller must call [method `$Pango`.FontMetrics.unref] when finished using the object.. 

get-round-glyph-positions
-------------------------

Returns whether font rendering with this context should round glyph positions and widths.

    method get-round-glyph-positions (--> Bool )

Return value; No documentation about its value and use. 

get-serial
----------

Returns the current serial number of `$context`.

The serial number is initialized to an small number larger than zero when a new context is created and is increased whenever the context is changed using any of the setter functions, or the `PangoFontMap` it uses to find fonts has changed. The serial may wrap, but will never have the value 0. Since it can wrap, never compare it with "less than", always use "not equals".

This can be used to automatically detect changes to a `PangoContext`, and is only useful when implementing objects that need update when their `PangoContext` changes, like `PangoLayout`.

    method get-serial (--> UInt )

Return value; The current serial number of `$context`.. 

list-families
-------------

List all families for a context.

    method list-families ( N-Object() $families, Array[Int] $n-families )

  * $families; (transfer ownership: container) location to store a pointer to an array of `PangoFontFamily`. This array should be freed with g_free()..

  * $n-families; (transfer ownership: full) location to store the number of elements in `$descs`.

load-font
---------

Loads the font in one of the fontmaps in the context that is the closest match for `$desc`.

    method load-font ( CArray[N-FontDescription]  $desc --> N-Object )

  * $desc; a `PangoFontDescription` describing the font to load.

Return value; the newly allocated `PangoFont` that was loaded, or `Nil` if no font matched.. 

load-fontset
------------

Load a set of fonts in the context that can be used to render a font matching `$desc`.

    method load-fontset ( CArray[N-FontDescription]  $desc, CArray[N-Language]  $language --> N-Object )

  * $desc; a `PangoFontDescription` describing the fonts to load.

  * $language; a `PangoLanguage` the fonts will be used for.

Return value; the newly allocated `PangoFontset` loaded, or `Nil` if no font matched.. 

set-base-dir
------------

Sets the base direction for the context.

The base direction is used in applying the Unicode bidirectional algorithm; if the `$direction` is %PANGO_DIRECTION_LTR or %PANGO_DIRECTION_RTL, then the value will be used as the paragraph direction in the Unicode bidirectional algorithm. A value of %PANGO_DIRECTION_WEAK_LTR or %PANGO_DIRECTION_WEAK_RTL is used only for paragraphs that do not contain any strong characters themselves.

    method set-base-dir ( PangoDirection $direction )

  * $direction; the new base direction. An enumeration.

set-base-gravity
----------------

Sets the base gravity for the context.

The base gravity is used in laying vertical text out.

    method set-base-gravity ( PangoGravity $gravity )

  * $gravity; the new base gravity. An enumeration.

set-font-description
--------------------

Set the default font description for the context

    method set-font-description ( CArray[N-FontDescription]  $desc )

  * $desc; the new pango font description.

set-font-map
------------

Sets the font map to be searched when fonts are looked-up in this context.

This is only for internal use by Pango backends, a `PangoContext` obtained via one of the recommended methods should already have a suitable font map.

    method set-font-map ( N-Object() $font-map )

  * $font-map; the `PangoFontMap` to set..

set-gravity-hint
----------------

Sets the gravity hint for the context.

The gravity hint is used in laying vertical text out, and is only relevant if gravity of the context as returned by [method `$Pango`.Context.get_gravity] is set to %PANGO_GRAVITY_EAST or %PANGO_GRAVITY_WEST.

    method set-gravity-hint ( PangoGravityHint $hint )

  * $hint; the new gravity hint. An enumeration.

set-language
------------

Sets the global language tag for the context.

The default language for the locale of the running process can be found using [func `$Pango`.Language.get_default].

    method set-language ( CArray[N-Language]  $language )

  * $language; the new language tag..

set-matrix
----------

Sets the transformation matrix that will be applied when rendering with this context.

Note that reported metrics are in the user space coordinates before the application of the matrix, not device-space coordinates after the application of the matrix. So, they don't scale with the matrix, though they may change slightly for different matrices, depending on how the text is fit to the pixel grid.

    method set-matrix ( CArray[N-Matrix]  $matrix )

  * $matrix; a `PangoMatrix`, or `Nil` to unset any existing matrix. (No matrix set is the same as setting the identity matrix.).

set-round-glyph-positions
-------------------------

Sets whether font rendering with this context should round glyph positions and widths to integral positions, in device units.

This is useful when the renderer can't handle subpixel positioning of glyphs.

The default value is to round glyph positions, to remain compatible with previous Pango behavior.

    method set-round-glyph-positions ( Bool() $round-positions )

  * $round-positions; whether to round glyph positions.
