Project Description
-------------------

  * **Distribution:** Gnome::Pango

  * **Project description:** Modules for package Gnome::Pango:api<2>. The language binding to Pango: Internationalized text layout and rendering

  * **Project version:** 0.1.2

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

![](images/layout.png)

Description
===========

A **Gnome::Pango::Layout** structure represents an entire paragraph of text.

While complete access to the layout capabilities of Pango is provided using the detailed interfaces for itemization and shaping, using that functionality directly involves writing a fairly large amount of code. **Gnome::Pango::Layout** provides a high-level driver for formatting entire paragraphs of text at once. This includes paragraph-level functionality such as line breaking, justification, alignment and ellipsization.

A **Gnome::Pango::Layout** is initialized with a *PangoContext*, UTF-8 string and set of attributes for that string. Once that is done, the set of formatted lines can be extracted from the object, the layout can be rendered, and conversion between logical character positions within the layout's text, and the physical position of the resulting glyphs can be made.

There are a number of parameters to adjust the formatting of a **Gnome::Pango::Layout**. The following image shows adjustable parameters (on the left) and font metrics (on the right):

<picture> <source srcset="layout-dark.png" media="(prefers-color-scheme: dark)"> <img alt="Pango Layout Parameters" src="layout-light.png"> </picture>

The following images demonstrate the effect of alignment and justification on the layout of text:

| | | | --- | --- | | ![align=left](align-left.png) | ![align=left, justify](align-left-justify.png) | | ![align=center](align-center.png) | ![align=center, justify](align-center-justify.png) | | ![align=right](align-right.png) | ![align=right, justify](align-right-justify.png) |

It is possible, as well, to ignore the 2-D setup, and simply treat the results of a **Gnome::Pango::Layout** as a list of lines.

Class initialization
====================

new
---

### :native-object

Create an object using a native object from elsewhere. See also **Gnome::N::TopLevelSupportClass**.

    multi method new ( N-Object :$native-object! )

new-layout
----------

Create a new **Gnome::Pango::Layout** object with attributes initialized to default values for a particular *PangoContext*.

    method new-layout ( N-Object() $context --> Gnome::Pango::Layout )

  * $context; a *PangoContext*.

Methods
=======

context-changed
---------------

Forces recomputation of any state in the **Gnome::Pango::Layout** that might depend on the layout's context.

This function should be called if you make changes to the context subsequent to creating the layout.

    method context-changed ( )

copy
----

Creates a deep copy-by-value of the layout.

The attribute list, tab array, and text from the original layout are all copied by value.

    method copy (--> N-Object )

Return value; the newly allocated **Gnome::Pango::Layout**. 

get-alignment
-------------

Gets the alignment for the layout: how partial lines are positioned within the horizontal space available.

    method get-alignment (--> PangoAlignment )

Return value; the alignment. An enumeration.

get-attributes
--------------

Gets the attribute list for the layout, if any.

    method get-attributes (--> CArray[N-AttrList]  )

Return value; a *PangoAttrList*. 

get-auto-dir
------------

Gets whether to calculate the base direction for the layout according to its contents.

See `.set-auto-dir()`.

    method get-auto-dir (--> Bool )

Return value; %TRUE if the bidirectional base direction is computed from the layout's contents, %FALSE otherwise. 

get-baseline
------------

Gets the Y position of baseline of the first line in `$layout`.

    method get-baseline (--> Int )

Return value; baseline of first line, from top of `$layout`. 

get-caret-pos
-------------

Given an index within a layout, determines the positions that of the strong and weak cursors if the insertion point is at that index.

This is a variant of `.get-cursor-pos()` that applies font metric information about caret slope and offset to the positions it returns.

<picture> <source srcset="caret-metrics-dark.png" media="(prefers-color-scheme: dark)"> <img alt="Caret metrics" src="caret-metrics-light.png"> </picture>

    method get-caret-pos ( Int() $index, CArray[N-Rectangle]  $strong-pos, CArray[N-Rectangle]  $weak-pos )

  * $index; the byte index of the cursor.

  * $strong-pos; location to store the strong cursor position.

  * $weak-pos; location to store the weak cursor position.

get-character-count
-------------------

Returns the number of Unicode characters in the the text of `$layout`.

    method get-character-count (--> Int )

Return value; the number of Unicode characters in the text of `$layout`. 

get-context
-----------

Retrieves the *PangoContext* used for this layout.

    method get-context (--> N-Object )

Return value; the *PangoContext* for the layout. 

get-cursor-pos
--------------

Given an index within a layout, determines the positions that of the strong and weak cursors if the insertion point is at that index.

The position of each cursor is stored as a zero-width rectangle with the height of the run extents.

<picture> <source srcset="cursor-positions-dark.png" media="(prefers-color-scheme: dark)"> <img alt="Cursor positions" src="cursor-positions-light.png"> </picture>

The strong cursor location is the location where characters of the directionality equal to the base direction of the layout are inserted. The weak cursor location is the location where characters of the directionality opposite to the base direction of the layout are inserted.

The following example shows text with both a strong and a weak cursor.

<picture> <source srcset="split-cursor-dark.png" media="(prefers-color-scheme: dark)"> <img alt="Strong and weak cursors" src="split-cursor-light.png"> </picture>

The strong cursor has a little arrow pointing to the right, the weak cursor to the left. Typing a 'c' in this situation will insert the character after the 'b', and typing another Hebrew character, like 'ג', will insert it at the end.

    method get-cursor-pos ( Int() $index, CArray[N-Rectangle]  $strong-pos, CArray[N-Rectangle]  $weak-pos )

  * $index; the byte index of the cursor.

  * $strong-pos; location to store the strong cursor position.

  * $weak-pos; location to store the weak cursor position.

get-direction
-------------

Gets the text direction at the given character position in `$layout`.

    method get-direction ( Int() $index --> PangoDirection )

  * $index; the byte index of the char.

Return value; the text direction at `$index`. An enumeration.

get-ellipsize
-------------

Gets the type of ellipsization being performed for `$layout`.

See `.set-ellipsize()`.

Use `.is-ellipsized() defined in Layout` to query whether any paragraphs were actually ellipsized.

    method get-ellipsize (--> PangoEllipsizeMode )

Return value; the current ellipsization mode for `$layout`. An enumeration.

get-extents
-----------

Computes the logical and ink extents of `$layout`.

Logical extents are usually what you want for positioning things. Note that both extents may have non-zero x and y. You may want to use those to offset where you render the layout. Not doing that is a very typical bug that shows up as right-to-left layouts not being correctly positioned in a layout with a set width.

The extents are given in layout coordinates and in Pango units; layout coordinates begin at the top left corner of the layout.

    method get-extents ( CArray[N-Rectangle]  $ink-rect, CArray[N-Rectangle]  $logical-rect )

  * $ink-rect; rectangle used to store the extents of the layout as drawn.

  * $logical-rect; rectangle used to store the logical extents of the layout.

get-font-description
--------------------

Gets the font description for the layout, if any.

    method get-font-description (--> CArray[N-FontDescription]  )

Return value; a pointer to the layout's font description, or %NULL if the font description from the layout's context is inherited.. 

get-height
----------

Gets the height of layout used for ellipsization.

See `.set-height()` for details.

    method get-height (--> Int )

Return value; the height, in Pango units if positive, or number of lines if negative.. 

get-indent
----------

Gets the paragraph indent width in Pango units.

A negative value indicates a hanging indentation.

    method get-indent (--> Int )

Return value; the indent in Pango units. 

get-iter
--------

Returns an iterator to iterate over the visual extents of the layout.

    method get-iter (--> CArray[N-LayoutIter] )

Return value; the new **Gnome::Pango::Layout**Iter. 

get-justify
-----------

Gets whether each complete line should be stretched to fill the entire width of the layout.

    method get-justify (--> Bool )

Return value; the justify value. 

get-justify-last-line
---------------------

Gets whether the last line should be stretched to fill the entire width of the layout.

    method get-justify-last-line (--> Bool )

Return value; the justify value. 

get-line
--------

Retrieves a particular line from a **Gnome::Pango::Layout**.

Use the faster `.get-line-readonly()` if you do not plan to modify the contents of the line (glyphs, glyph widths, etc.).

    method get-line ( Int() $line --> CArray[N-LayoutLine] )

  * $line; the index of a line, which must be between 0 and *pango_layout_get_line_count(layout) - 1*, inclusive..

Return value; the requested **Gnome::Pango::Layout**Line, or %NULL if the index is out of range. This layout line can be ref'ed and retained, but will become invalid if changes are made to the **Gnome::Pango::Layout**.. 

get-line-count
--------------

Retrieves the count of lines for the `$layout`.

    method get-line-count (--> Int )

Return value; the line count. 

get-line-readonly
-----------------

Retrieves a particular line from a **Gnome::Pango::Layout**.

This is a faster alternative to `.get-line()`, but the user is not expected to modify the contents of the line (glyphs, glyph widths, etc.).

    method get-line-readonly ( Int() $line --> CArray[N-LayoutLine] )

  * $line; the index of a line, which must be between 0 and *pango_layout_get_line_count(layout) - 1*, inclusive..

Return value; the requested **Gnome::Pango::Layout**Line, or %NULL if the index is out of range. This layout line can be ref'ed and retained, but will become invalid if changes are made to the **Gnome::Pango::Layout**. No changes should be made to the line.. 

get-line-spacing
----------------

Gets the line spacing factor of `$layout`.

See `.set-line-spacing()`.

    method get-line-spacing (--> Num )

Return value; No documentation about its value and use. 

get-lines
---------

Returns the lines of the `$layout` as a list.

Use the faster `.get-lines-readonly()` if you do not plan to modify the contents of the lines (glyphs, glyph widths, etc.).

    method get-lines (--> N-SList )

Return value; a *GSList* containing the lines in the layout. This points to internal data of the **Gnome::Pango::Layout** and must be used with care. It will become invalid on any change to the layout's text or properties.. 

get-lines-readonly
------------------

Returns the lines of the `$layout` as a list.

This is a faster alternative to `.get-lines()`, but the user is not expected to modify the contents of the lines (glyphs, glyph widths, etc.).

    method get-lines-readonly (--> N-SList )

Return value; a *GSList* containing the lines in the layout. This points to internal data of the **Gnome::Pango::Layout** and must be used with care. It will become invalid on any change to the layout's text or properties. No changes should be made to the lines.. 

get-log-attrs
-------------

Retrieves an array of logical attributes for each character in the `$layout`.

    method get-log-attrs ( CArray[N-LogAttr]  $attrs, Array[Int] $n-attrs )

  * $attrs; (transfer ownership: container) location to store a pointer to an array of logical attributes. This value must be freed with g_free()..

  * $n-attrs; (transfer ownership: full) location to store the number of the attributes in the array. (The stored value will be one more than the total number of characters in the layout, since there need to be attributes corresponding to both the position before the first character and the position after the last character.).

get-log-attrs-readonly
----------------------

Retrieves an array of logical attributes for each character in the `$layout`.

This is a faster alternative to `.get-log-attrs()`. The returned array is part of `$layout` and must not be modified. Modifying the layout will invalidate the returned array.

The number of attributes returned in `$n_attrs` will be one more than the total number of characters in the layout, since there need to be attributes corresponding to both the position before the first character and the position after the last character.

    method get-log-attrs-readonly ( Array[Int] $n-attrs --> CArray[N-LogAttr]  )

  * $n-attrs; (transfer ownership: full) location to store the number of the attributes in the array.

Return value; an array of logical attributes. 

get-pixel-extents
-----------------

Computes the logical and ink extents of `$layout` in device units.

This function just calls `.get-extents()` followed by two [func `$extents_to_pixels`] calls, rounding `$ink_rect` and `$logical_rect` such that the rounded rectangles fully contain the unrounded one (that is, passes them as first argument to `.extents-to-pixels()`).

    method get-pixel-extents ( CArray[N-Rectangle]  $ink-rect, CArray[N-Rectangle]  $logical-rect )

  * $ink-rect; rectangle used to store the extents of the layout as drawn.

  * $logical-rect; rectangle used to store the logical extents of the layout.

get-pixel-size
--------------

Determines the logical width and height of a **Gnome::Pango::Layout** in device units.

`.get-size()` returns the width and height scaled by %PANGO_SCALE. This is simply a convenience function around `.get-pixel-extents()`.

    method get-pixel-size ( Array[Int] $width, Array[Int] $height )

  * $width; (transfer ownership: full) location to store the logical width.

  * $height; (transfer ownership: full) location to store the logical height.

get-serial
----------

Returns the current serial number of `$layout`.

The serial number is initialized to an small number larger than zero when a new layout is created and is increased whenever the layout is changed using any of the setter functions, or the *PangoContext* it uses has changed. The serial may wrap, but will never have the value 0. Since it can wrap, never compare it with "less than", always use "not equals".

This can be used to automatically detect changes to a **Gnome::Pango::Layout**, and is useful for example to decide whether a layout needs redrawing. To force the serial to be increased, use `.context-changed()`.

    method get-serial (--> UInt )

Return value; The current serial number of `$layout`.. 

get-single-paragraph-mode
-------------------------

Obtains whether `$layout` is in single paragraph mode.

See `.set-single-paragraph-mode()`.

    method get-single-paragraph-mode (--> Bool )

Return value; %TRUE if the layout does not break paragraphs at paragraph separator characters, %FALSE otherwise. 

get-size
--------

Determines the logical width and height of a **Gnome::Pango::Layout** in Pango units.

This is simply a convenience function around `.get-extents()`.

    method get-size ( Array[Int] $width, Array[Int] $height )

  * $width; (transfer ownership: full) location to store the logical width.

  * $height; (transfer ownership: full) location to store the logical height.

get-spacing
-----------

Gets the amount of spacing between the lines of the layout.

    method get-spacing (--> Int )

Return value; the spacing in Pango units. 

get-tabs
--------

Gets the current *PangoTabArray* used by this layout.

If no *PangoTabArray* has been set, then the default tabs are in use and %NULL is returned. Default tabs are every 8 spaces.

The return value should be freed with `.free() defined in TabArray`.

    method get-tabs (--> CArray[N-TabArray]  )

Return value; a copy of the tabs for this layout. 

get-text
--------

Gets the text in the layout.

The returned text should not be freed or modified.

    method get-text (--> Str )

Return value; the text in the `$layout`. 

get-unknown-glyphs-count
------------------------

Counts the number of unknown glyphs in `$layout`.

This function can be used to determine if there are any fonts available to render all characters in a certain string, or when used in combination with %PANGO_ATTR_FALLBACK, to check if a certain font supports all the characters in the string.

    method get-unknown-glyphs-count (--> Int )

Return value; The number of unknown glyphs in `$layout`. 

get-width
---------

Gets the width to which the lines of the **Gnome::Pango::Layout** should wrap.

    method get-width (--> Int )

Return value; the width in Pango units, or -1 if no width set.. 

get-wrap
--------

Gets the wrap mode for the layout.

Use `.is-wrapped()` to query whether any paragraphs were actually wrapped.

    method get-wrap (--> PangoWrapMode )

Return value; active wrap mode.. An enumeration.

index-to-line-x
---------------

Converts from byte `$index_` within the `$layout` to line and X position.

The X position is measured from the left edge of the line.

    method index-to-line-x ( Int() $index, Bool() $trailing, Array[Int] $line, Array[Int] $x-pos )

  * $index; the byte index of a grapheme within the layout.

  * $trailing; an integer indicating the edge of the grapheme to retrieve the position of. If > 0, the trailing edge of the grapheme, if 0, the leading of the grapheme.

  * $line; (transfer ownership: full) location to store resulting line index. (which will between 0 and pango_layout_get_line_count(layout) - 1).

  * $x-pos; (transfer ownership: full) location to store resulting position within line (%PANGO_SCALE units per device unit).

index-to-pos
------------

Converts from an index within a **Gnome::Pango::Layout** to the onscreen position corresponding to the grapheme at that index.

The returns is represented as rectangle. Note that *pos-*x> is always the leading edge of the grapheme and *pos-*x + pos->width> the trailing edge of the grapheme. If the directionality of the grapheme is right-to-left, then *pos-*width> will be negative.

    method index-to-pos ( Int() $index, CArray[N-Rectangle]  $pos )

  * $index; byte index within `$layout`.

  * $pos; rectangle in which to store the position of the grapheme.

is-ellipsized
-------------

Queries whether the layout had to ellipsize any paragraphs.

This returns %TRUE if the ellipsization mode for `$layout` is not %PANGO_ELLIPSIZE_NONE, a positive width is set on `$layout`, and there are paragraphs exceeding that width that have to be ellipsized.

    method is-ellipsized (--> Bool )

Return value; %TRUE if any paragraphs had to be ellipsized, %FALSE otherwise. 

is-wrapped
----------

Queries whether the layout had to wrap any paragraphs.

This returns %TRUE if a positive width is set on `$layout`, ellipsization mode of `$layout` is set to %PANGO_ELLIPSIZE_NONE, and there are paragraphs exceeding the layout width that have to be wrapped.

    method is-wrapped (--> Bool )

Return value; %TRUE if any paragraphs had to be wrapped, %FALSE otherwise. 

move-cursor-visually
--------------------

Computes a new cursor position from an old position and a direction.

If `$direction` is positive, then the new position will cause the strong or weak cursor to be displayed one position to right of where it was with the old cursor position. If `$direction` is negative, it will be moved to the left.

In the presence of bidirectional text, the correspondence between logical and visual order will depend on the direction of the current run, and there may be jumps when the cursor is moved off of the end of a run.

Motion here is in cursor positions, not in characters, so a single call to this function may move the cursor over multiple characters when multiple characters combine to form a single grapheme.

    method move-cursor-visually ( Bool() $strong, Int() $old-index, Int() $old-trailing, Int() $direction, Array[Int] $new-index, Array[Int] $new-trailing )

  * $strong; whether the moving cursor is the strong cursor or the weak cursor. The strong cursor is the cursor corresponding to text insertion in the base direction for the layout..

  * $old-index; the byte index of the current cursor position.

  * $old-trailing; if 0, the cursor was at the leading edge of the grapheme indicated by `$old_index`, if > 0, the cursor was at the trailing edge..

  * $direction; direction to move cursor. A negative value indicates motion to the left.

  * $new-index; (transfer ownership: full) location to store the new cursor byte index. A value of -1 indicates that the cursor has been moved off the beginning of the layout. A value of %G_MAXINT indicates that the cursor has been moved off the end of the layout..

  * $new-trailing; (transfer ownership: full) number of characters to move forward from the location returned for `$new_index` to get the position where the cursor should be displayed. This allows distinguishing the position at the beginning of one line from the position at the end of the preceding line. `$new_index` is always on the line where the cursor should be displayed..

serialize
---------

Serializes the `$layout` for later deserialization via `.Layout.deserialize()`.

There are no guarantees about the format of the output across different versions of Pango and `.Layout.deserialize()` will reject data that it cannot parse.

The intended use of this function is testing, benchmarking and debugging. The format is not meant as a permanent storage format.

    method serialize ( UInt $flags --> CArray[N-Bytes]  )

  * $flags; **Gnome::Pango::Layout**SerializeFlags. A bitmap.

Return value; a *GBytes* containing the serialized form of `$layout`. 

set-alignment
-------------

Sets the alignment for the layout: how partial lines are positioned within the horizontal space available.

The default alignment is %PANGO_ALIGN_LEFT.

    method set-alignment ( PangoAlignment $alignment )

  * $alignment; the alignment. An enumeration.

set-attributes
--------------

Sets the text attributes for a layout object.

References `$attrs`, so the caller can unref its reference.

    method set-attributes ( CArray[N-AttrList]  $attrs )

  * $attrs; a *PangoAttrList*.

set-auto-dir
------------

Sets whether to calculate the base direction for the layout according to its contents.

When this flag is on (the default), then paragraphs in `$layout` that begin with strong right-to-left characters (Arabic and Hebrew principally), will have right-to-left layout, paragraphs with letters from other scripts will have left-to-right layout. Paragraphs with only neutral characters get their direction from the surrounding paragraphs.

When %FALSE, the choice between left-to-right and right-to-left layout is done according to the base direction of the layout's *PangoContext*. (See `.set-base-dir() defined in Context`).

When the auto-computed direction of a paragraph differs from the base direction of the context, the interpretation of %PANGO_ALIGN_LEFT and %PANGO_ALIGN_RIGHT are swapped.

    method set-auto-dir ( Bool() $auto-dir )

  * $auto-dir; if %TRUE, compute the bidirectional base direction from the layout's contents.

set-ellipsize
-------------

Sets the type of ellipsization being performed for `$layout`.

Depending on the ellipsization mode `$ellipsize` text is removed from the start, middle, or end of text so they fit within the width and height of layout set with `.set-width()` and `.set-height()`.

If the layout contains characters such as newlines that force it to be layed out in multiple paragraphs, then whether each paragraph is ellipsized separately or the entire layout is ellipsized as a whole depends on the set height of the layout.

The default value is %PANGO_ELLIPSIZE_NONE.

See `.set-height()` for details.

    method set-ellipsize ( PangoEllipsizeMode $ellipsize )

  * $ellipsize; the new ellipsization mode for `$layout`. An enumeration.

set-font-description
--------------------

Sets the default font description for the layout.

If no font description is set on the layout, the font description from the layout's context is used.

    method set-font-description ( CArray[N-FontDescription]  $desc )

  * $desc; the new *PangoFontDescription* to unset the current font description.

set-height
----------

Sets the height to which the **Gnome::Pango::Layout** should be ellipsized at.

There are two different behaviors, based on whether `$height` is positive or negative.

If `$height` is positive, it will be the maximum height of the layout. Only lines would be shown that would fit, and if there is any text omitted, an ellipsis added. At least one line is included in each paragraph regardless of how small the height value is. A value of zero will render exactly one line for the entire layout.

If `$height` is negative, it will be the (negative of) maximum number of lines per paragraph. That is, the total number of lines shown may well be more than this value if the layout contains multiple paragraphs of text. The default value of -1 means that the first line of each paragraph is ellipsized. This behavior may be changed in the future to act per layout instead of per paragraph. File a bug against pango at [https://gitlab.gnome.org/gnome/pango](https://gitlab.gnome.org/gnome/pango) if your code relies on this behavior.

Height setting only has effect if a positive width is set on `$layout` and ellipsization mode of `$layout` is not %PANGO_ELLIPSIZE_NONE. The behavior is undefined if a height other than -1 is set and ellipsization mode is set to %PANGO_ELLIPSIZE_NONE, and may change in the future.

    method set-height ( Int() $height )

  * $height; the desired height of the layout in Pango units if positive, or desired number of lines if negative..

set-indent
----------

Sets the width in Pango units to indent each paragraph.

A negative value of `$indent` will produce a hanging indentation. That is, the first line will have the full width, and subsequent lines will be indented by the absolute value of `$indent`.

The indent setting is ignored if layout alignment is set to %PANGO_ALIGN_CENTER.

The default value is 0.

    method set-indent ( Int() $indent )

  * $indent; the amount by which to indent.

set-justify
-----------

Sets whether each complete line should be stretched to fill the entire width of the layout.

Stretching is typically done by adding whitespace, but for some scripts (such as Arabic), the justification may be done in more complex ways, like extending the characters.

Note that this setting is not implemented and so is ignored in Pango older than 1.18.

Note that tabs and justification conflict with each other: Justification will move content away from its tab-aligned positions.

The default value is %FALSE.

Also see `.set-justify-last-line()`.

    method set-justify ( Bool() $justify )

  * $justify; whether the lines in the layout should be justified.

set-justify-last-line
---------------------

Sets whether the last line should be stretched to fill the entire width of the layout.

This only has an effect if `.set-justify()` has been called as well.

The default value is %FALSE.

    method set-justify-last-line ( Bool() $justify )

  * $justify; whether the last line in the layout should be justified.

set-line-spacing
----------------

Sets a factor for line spacing.

Typical values are: 0, 1, 1.5, 2. The default values is 0.

If `$factor` is non-zero, lines are placed so that

    baseline2 = baseline1 + factor * height2

where height2 is the line height of the second line (as determined by the font(s)). In this case, the spacing set with `.set-spacing()` is ignored.

If `$factor` is zero (the default), spacing is applied as before.

Note: for semantics that are closer to the CSS line-height property, see `.attr-line-height-new()`.

    method set-line-spacing ( Num() $factor )

  * $factor; the new line spacing factor.

set-markup
----------

Sets the layout text and attribute list from marked-up text.

See [Pango Markup](pango_markup.html)).

Replaces the current text and attribute list.

This is the same as `.set-markup-with-accel()`, but the markup text isn't scanned for accelerators.

    method set-markup ( Str $markup, Int() $length )

  * $markup; marked-up text.

  * $length; length of marked-up text in bytes, or -1 if `$markup` is *NUL*-terminated.

set-markup-with-accel
---------------------

Sets the layout text and attribute list from marked-up text.

See [Pango Markup](pango_markup.html)).

Replaces the current text and attribute list.

If `$accel_marker` is nonzero, the given character will mark the character following it as an accelerator. For example, `$accel_marker` might be an ampersand or underscore. All characters marked as an accelerator will receive a %PANGO_UNDERLINE_LOW attribute, and the first character so marked will be returned in `$accel_char`. Two `$accel_marker` characters following each other produce a single literal `$accel_marker` character.

    method set-markup-with-accel ( Str $markup, Int() $length, UInt() $accel-marker, Str $accel-char )

  * $markup; marked-up text (see [Pango Markup](pango_markup.html)).

  * $length; length of marked-up text in bytes, or -1 if `$markup` is *NUL*-terminated.

  * $accel-marker; marker for accelerators in the text.

  * $accel-char; (transfer ownership: full) return location for first located accelerator.

set-single-paragraph-mode
-------------------------

Sets the single paragraph mode of `$layout`.

If `$setting` is %TRUE, do not treat newlines and similar characters as paragraph separators; instead, keep all text in a single paragraph, and display a glyph for paragraph separator characters. Used when you want to allow editing of newlines on a single text line.

The default value is %FALSE.

    method set-single-paragraph-mode ( Bool() $setting )

  * $setting; new setting.

set-spacing
-----------

Sets the amount of spacing in Pango units between the lines of the layout.

When placing lines with spacing, Pango arranges things so that

    line2.top = line1.bottom + spacing

The default value is 0.

Note: Since 1.44, Pango is using the line height (as determined by the font) for placing lines when the line spacing factor is set to a non-zero value with `.set-line-spacing()`. In that case, the `$spacing` set with this function is ignored.

Note: for semantics that are closer to the CSS line-height property, see `.attr-line-height-new()`.

    method set-spacing ( Int() $spacing )

  * $spacing; the amount of spacing.

set-tabs
--------

Sets the tabs to use for `$layout`, overriding the default tabs.

**Gnome::Pango::Layout** will place content at the next tab position whenever it meets a Tab character (U+0009).

By default, tabs are every 8 spaces. If `$tabs` is %NULL, the default tabs are reinstated. `$tabs` is copied into the layout; you must free your copy of `$tabs` yourself.

Note that tabs and justification conflict with each other: Justification will move content away from its tab-aligned positions. The same is true for alignments other than %PANGO_ALIGN_LEFT.

    method set-tabs ( CArray[N-TabArray]  $tabs )

  * $tabs; a *PangoTabArray*.

set-text
--------

Sets the text of the layout.

This function validates `$text` and renders invalid UTF-8 with a placeholder glyph.

Note that if you have used `.set-markup()` or `.set-attributes()` on `$layout` before, you may want to call `.set-attributes()` to clear the attributes set on the layout from the markup as this function does not clear attributes.

    method set-text ( Str $text, Int() $length )

  * $text; the text.

  * $length; maximum length of `$text`, in bytes. -1 indicates that the string is nul-terminated and the length should be calculated. The text will also be truncated on encountering a nul-termination even when `$length` is positive..

set-width
---------

Sets the width to which the lines of the **Gnome::Pango::Layout** should wrap or ellipsized.

The default value is -1: no width set.

    method set-width ( Int() $width )

  * $width; the desired width in Pango units, or -1 to indicate that no wrapping or ellipsization should be performed..

set-wrap
--------

Sets the wrap mode.

The wrap mode only has effect if a width is set on the layout with `.set-width()`. To turn off wrapping, set the width to -1.

The default value is %PANGO_WRAP_WORD.

    method set-wrap ( PangoWrapMode $wrap )

  * $wrap; the wrap mode. An enumeration.

write-to-file
-------------

A convenience method to serialize a layout to a file.

It is equivalent to calling `.serialize()` followed by [func `$GLib`.file_set_contents].

See those two functions for details on the arguments.

It is mostly intended for use inside a debugger to quickly dump a layout to a file for later inspection.

    method write-to-file ( UInt $flags, Str $filename --> Bool )

  * $flags; **Gnome::Pango::Layout**SerializeFlags. A bitmap.

  * $filename; the file to save it to.

Return value; %TRUE if saving was successful. 

xy-to-index
-----------

Converts from X and Y position within a layout to the byte index to the character at that logical position.

If the Y position is not inside the layout, the closest position is chosen (the position will be clamped inside the layout). If the X position is not within the layout, then the start or the end of the line is chosen as described for `.x-to-index() defined in LayoutLine`. If either the X or Y positions were not inside the layout, then the function returns %FALSE; on an exact hit, it returns %TRUE.

    method xy-to-index ( Int() $x, Int() $y, Array[Int] $index, Array[Int] $trailing --> Bool )

  * $x; the X offset (in Pango units) from the left edge of the layout.

  * $y; the Y offset (in Pango units) from the top edge of the layout.

  * $index; (transfer ownership: full) location to store calculated byte index.

  * $trailing; (transfer ownership: full) location to store a integer indicating where in the grapheme the user clicked. It will either be zero, or the number of characters in the grapheme. 0 represents the leading edge of the grapheme..

Return value; %TRUE if the coordinates were inside text, %FALSE otherwise. 

Functions
=========

deserialize
-----------

Loads data previously created via `.serialize()`.

For a discussion of the supported format, see that function.

Note: to verify that the returned layout is identical to the one that was serialized, you can compare `$bytes` to the result of serializing the layout again.

    method deserialize ( N-Object() $context, CArray[N-Bytes]  $bytes, UInt $flags --> N-Object )

  * $context; a *PangoContext*.

  * $bytes; the bytes containing the data.

  * $flags; **Gnome::Pango::Layout**DeserializeFlags. A bitmap.

Return value; a new **Gnome::Pango::Layout**. 