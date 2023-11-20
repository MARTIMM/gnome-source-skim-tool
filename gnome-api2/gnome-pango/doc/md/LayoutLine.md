Project Description
-------------------

  * **Distribution:** Gnome::Pango

  * **Project description:** Modules for package Gnome::Pango:api<2>. The language binding to Pango: Internationalized text layout and rendering

  * **Project version:** 0.1.2

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

![](images/layoutline.png)

Description
===========

A **Gnome::Pango::LayoutLine** represents one of the lines resulting from laying out a paragraph via *PangoLayout*.

**Gnome::Pango::LayoutLine** structures are obtained by calling `.get-line() defined in Layout` and are only valid until the text, attributes, or settings of the parent *PangoLayout* are modified.

Class initialization
====================

new
---

### :native-object

Create an object using a native object from elsewhere. See also **Gnome::N::TopLevelSupportClass**.

    multi method new ( N-Object :$native-object! )

Methods
=======

get-extents
-----------

Computes the logical and ink extents of a layout line.

See `.get-glyph-extents() defined in Font` for details about the interpretation of the rectangles.

    method get-extents ( CArray[N-Rectangle]  $ink-rect, CArray[N-Rectangle]  $logical-rect )

  * $ink-rect; rectangle used to store the extents of the glyph string as drawn.

  * $logical-rect; rectangle used to store the logical extents of the glyph string.

get-height
----------

Computes the height of the line, as the maximum of the heights of fonts used in this line.

Note that the actual baseline-to-baseline distance between lines of text is influenced by other factors, such as `.set-spacing() defined in Layout` and `.set-line-spacing() defined in Layout`.

    method get-height ( Array[Int] $height )

  * $height; (transfer ownership: full) return location for the line height.

get-length
----------

Returns the length of the line, in bytes.

    method get-length (--> Int )

Return value; the length of the line. 

get-pixel-extents
-----------------

Computes the logical and ink extents of `$layout_line` in device units.

This function just calls `.get-extents()` followed by two [func `$extents_to_pixels`] calls, rounding `$ink_rect` and `$logical_rect` such that the rounded rectangles fully contain the unrounded one (that is, passes them as first argument to [func `$extents_to_pixels`]).

    method get-pixel-extents ( CArray[N-Rectangle]  $ink-rect, CArray[N-Rectangle]  $logical-rect )

  * $ink-rect; rectangle used to store the extents of the glyph string as drawn.

  * $logical-rect; rectangle used to store the logical extents of the glyph string.

get-resolved-direction
----------------------

Returns the resolved direction of the line.

    method get-resolved-direction (--> PangoDirection )

Return value; the resolved direction of the line. An enumeration.

get-start-index
---------------

Returns the start index of the line, as byte index into the text of the layout.

    method get-start-index (--> Int )

Return value; the start index of the line. 

get-x-ranges
------------

Gets a list of visual ranges corresponding to a given logical range.

This list is not necessarily minimal - there may be consecutive ranges which are adjacent. The ranges will be sorted from left to right. The ranges are with respect to the left edge of the entire layout, not with respect to the line.

    method get-x-ranges ( Int() $start-index, Int() $end-index, Array[Int] $ranges, Array[Int] $n-ranges )

  * $start-index; Start byte index of the logical range. If this value is less than the start index for the line, then the first range will extend all the way to the leading edge of the layout. Otherwise, it will start at the leading edge of the first character..

  * $end-index; Ending byte index of the logical range. If this value is greater than the end index for the line, then the last range will extend all the way to the trailing edge of the layout. Otherwise, it will end at the trailing edge of the last character..

  * $ranges; (transfer ownership: full) location to store a pointer to an array of ranges. The array will be of length *2*n_ranges*, with each range starting at *(*ranges)[2*n]* and of width *(*ranges)[2*n + 1] - (*ranges)[2*n]*. This array must be freed with g_free(). The coordinates are relative to the layout and are in Pango units..

  * $n-ranges; (transfer ownership: full) The number of ranges stored in `$ranges`.

index-to-x
----------

Converts an index within a line to a X position.

    method index-to-x ( Int() $index, Bool() $trailing, Array[Int] $x-pos )

  * $index; byte offset of a grapheme within the layout.

  * $trailing; an integer indicating the edge of the grapheme to retrieve the position of. If > 0, the trailing edge of the grapheme, if 0, the leading of the grapheme.

  * $x-pos; (transfer ownership: full) location to store the x_offset (in Pango units).

is-paragraph-start
------------------

Returns whether this is the first line of the paragraph.

    method is-paragraph-start (--> Bool )

Return value; %TRUE if this is the first line. 

ref
---

Increase the reference count of a **Gnome::Pango::LayoutLine** by one.

    method ref (--> CArray[N-LayoutLine] )

Return value; the line passed in.. 

unref
-----

Decrease the reference count of a **Gnome::Pango::LayoutLine** by one.

If the result is zero, the line and all associated memory will be freed.

    method unref ( )

x-to-index
----------

Converts from x offset to the byte index of the corresponding character within the text of the layout.

If `$x_pos` is outside the line, `$index_` and `$trailing` will point to the very first or very last position in the line. This determination is based on the resolved direction of the paragraph; for example, if the resolved direction is right-to-left, then an X position to the right of the line (after it) results in 0 being stored in `$index_` and `$trailing`. An X position to the left of the line results in `$index_` pointing to the (logical) last grapheme in the line and `$trailing` being set to the number of characters in that grapheme. The reverse is true for a left-to-right line.

    method x-to-index ( Int() $x-pos, Array[Int] $index, Array[Int] $trailing --> Bool )

  * $x-pos; the X offset (in Pango units) from the left edge of the line..

  * $index; (transfer ownership: full) location to store calculated byte index for the grapheme in which the user clicked.

  * $trailing; (transfer ownership: full) location to store an integer indicating where in the grapheme the user clicked. It will either be zero, or the number of characters in the grapheme. 0 represents the leading edge of the grapheme..

Return value; %FALSE if `$x_pos` was outside the line, %TRUE if inside. 
