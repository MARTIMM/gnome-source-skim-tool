Project Description
-------------------

  * **Distribution:** Gnome::Pango

  * **Project description:** Modules for package Gnome::Pango:api<2>. The language binding to Pango: Internationalized text layout and rendering

  * **Project version:** 0.1.2

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

![](images/layoutiter.png)

Description
===========

A **Gnome::Pango::LayoutIter** can be used to iterate over the visual extents of a *PangoLayout*.

To obtain a **Gnome::Pango::LayoutIter**, use `.get-iter() defined in Layout`.

The **Gnome::Pango::LayoutIter** structure is opaque, and has no user-visible fields.

Class initialization
====================

new
---

### :native-object

Create an object using a native object from elsewhere. See also **Gnome::N::TopLevelSupportClass**.

    multi method new ( N-Object :$native-object! )

Methods
=======

at-last-line
------------

Determines whether `$iter` is on the last line of the layout.

    method at-last-line (--> Bool )

Return value; %TRUE if `$iter` is on the last line. 

copy
----

Copies a **Gnome::Pango::LayoutIter**.

    method copy (--> CArray[N-LayoutIter] )

Return value; the newly allocated **Gnome::Pango::LayoutIter**. 

free
----

Frees an iterator that's no longer in use.

    method free ( )

get-baseline
------------

Gets the Y position of the current line's baseline, in layout coordinates.

Layout coordinates have the origin at the top left of the entire layout.

    method get-baseline (--> Int )

Return value; baseline of current line. 

get-char-extents
----------------

Gets the extents of the current character, in layout coordinates.

Layout coordinates have the origin at the top left of the entire layout.

Only logical extents can sensibly be obtained for characters; ink extents make sense only down to the level of clusters.

    method get-char-extents ( CArray[N-Rectangle]  $logical-rect )

  * $logical-rect; rectangle to fill with logical extents.

get-cluster-extents
-------------------

Gets the extents of the current cluster, in layout coordinates.

Layout coordinates have the origin at the top left of the entire layout.

    method get-cluster-extents ( CArray[N-Rectangle]  $ink-rect, CArray[N-Rectangle]  $logical-rect )

  * $ink-rect; rectangle to fill with ink extents.

  * $logical-rect; rectangle to fill with logical extents.

get-index
---------

Gets the current byte index.

Note that iterating forward by char moves in visual order, not logical order, so indexes may not be sequential. Also, the index may be equal to the length of the text in the layout, if on the %NULL run (see `.get-run()`).

    method get-index (--> Int )

Return value; current byte index. 

get-layout
----------

Gets the layout associated with a **Gnome::Pango::LayoutIter**.

    method get-layout (--> N-Object )

Return value; the layout associated with `$iter`. 

get-layout-extents
------------------

Obtains the extents of the *PangoLayout* being iterated over.

    method get-layout-extents ( CArray[N-Rectangle]  $ink-rect, CArray[N-Rectangle]  $logical-rect )

  * $ink-rect; rectangle to fill with ink extents.

  * $logical-rect; rectangle to fill with logical extents.

get-line
--------

Gets the current line.

Use the faster `.get-line-readonly()` if you do not plan to modify the contents of the line (glyphs, glyph widths, etc.).

    method get-line (--> CArray[N-LayoutLine] )

Return value; the current line. 

get-line-extents
----------------

Obtains the extents of the current line.

Extents are in layout coordinates (origin is the top-left corner of the entire *PangoLayout*). Thus the extents returned by this function will be the same width/height but not at the same x/y as the extents returned from `.get-extents() defined in LayoutLine`.

    method get-line-extents ( CArray[N-Rectangle]  $ink-rect, CArray[N-Rectangle]  $logical-rect )

  * $ink-rect; rectangle to fill with ink extents.

  * $logical-rect; rectangle to fill with logical extents.

get-line-readonly
-----------------

Gets the current line for read-only access.

This is a faster alternative to `.get-line()`, but the user is not expected to modify the contents of the line (glyphs, glyph widths, etc.).

    method get-line-readonly (--> CArray[N-LayoutLine] )

Return value; the current line, that should not be modified. 

get-line-yrange
---------------

Divides the vertical space in the *PangoLayout* being iterated over between the lines in the layout, and returns the space belonging to the current line.

A line's range includes the line's logical extents. plus half of the spacing above and below the line, if `.set-spacing() defined in Layout` has been called to set layout spacing. The Y positions are in layout coordinates (origin at top left of the entire layout).

Note: Since 1.44, Pango uses line heights for placing lines, and there may be gaps between the ranges returned by this function.

    method get-line-yrange ( Array[Int] $y0, Array[Int] $y1 )

  * $y0; (transfer ownership: full) start of line.

  * $y1; (transfer ownership: full) end of line.

get-run
-------

Gets the current run.

When iterating by run, at the end of each line, there's a position with a %NULL run, so this function can return %NULL. The %NULL run at the end of each line ensures that all lines have at least one run, even lines consisting of only a newline.

Use the faster `.get-run-readonly()` if you do not plan to modify the contents of the run (glyphs, glyph widths, etc.).

    method get-run ( )

get-run-baseline
----------------

Gets the Y position of the current run's baseline, in layout coordinates.

Layout coordinates have the origin at the top left of the entire layout.

The run baseline can be different from the line baseline, for example due to superscript or subscript positioning.

    method get-run-baseline (--> Int )

Return value; No documentation about its value and use. 

get-run-extents
---------------

Gets the extents of the current run in layout coordinates.

Layout coordinates have the origin at the top left of the entire layout.

    method get-run-extents ( CArray[N-Rectangle]  $ink-rect, CArray[N-Rectangle]  $logical-rect )

  * $ink-rect; rectangle to fill with ink extents.

  * $logical-rect; rectangle to fill with logical extents.

get-run-readonly
----------------

Gets the current run for read-only access.

When iterating by run, at the end of each line, there's a position with a %NULL run, so this function can return %NULL. The %NULL run at the end of each line ensures that all lines have at least one run, even lines consisting of only a newline.

This is a faster alternative to `.get-run()`, but the user is not expected to modify the contents of the run (glyphs, glyph widths, etc.).

    method get-run-readonly ( )

next-char
---------

Moves `$iter` forward to the next character in visual order.

If `$iter` was already at the end of the layout, returns %FALSE.

    method next-char (--> Bool )

Return value; whether motion was possible. 

next-cluster
------------

Moves `$iter` forward to the next cluster in visual order.

If `$iter` was already at the end of the layout, returns %FALSE.

    method next-cluster (--> Bool )

Return value; whether motion was possible. 

next-line
---------

Moves `$iter` forward to the start of the next line.

If `$iter` is already on the last line, returns %FALSE.

    method next-line (--> Bool )

Return value; whether motion was possible. 

next-run
--------

Moves `$iter` forward to the next run in visual order.

If `$iter` was already at the end of the layout, returns %FALSE.

    method next-run (--> Bool )

Return value; whether motion was possible. 
