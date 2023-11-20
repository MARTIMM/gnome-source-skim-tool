Project Description
-------------------

  * **Distribution:** Gnome::Pango

  * **Project description:** Modules for package Gnome::Pango:api<2>. The language binding to Pango: Internationalized text layout and rendering

  * **Project version:** 0.1.2

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

Gnome::Pango::T-Gravity
=======================

Class initialization
====================

new
---

Initialization of a type class is simple.

    method new ( )

Enumerations
============

PangoGravity
------------

``PangoC<Gravity enumeration> enumeration`` represents the orientation of glyphs in a segment of text.

This is useful when rendering vertical text layouts. In those situations, the layout is rotated using a non-identity [struct `$Pango`.Matrix], and then glyph orientation is controlled using ``PangoC<Gravity enumeration> enumeration``.

Not every value in this enumeration makes sense for every usage of ``PangoC<Gravity enumeration> enumeration``; for example, %PANGO_GRAVITY_AUTO only can be passed to [method `$Pango`.Context.set_base_gravity] and can only be returned by [method `$Pango`.Context.get_base_gravity].

See also: [enum `$Pango`.`Gravity enumeration`Hint]=item `PANGO_GRAVITY_SOUTH`; Glyphs stand upright (default) <img align="right" valign="center" src="m-south.png">

  * `PANGO_GRAVITY_EAST`; Glyphs are rotated 90 degrees counter-clockwise. <img align="right" valign="center" src="m-east.png">

  * `PANGO_GRAVITY_NORTH`; Glyphs are upside-down. <img align="right" valign="cener" src="m-north.png">

  * `PANGO_GRAVITY_WEST`; Glyphs are rotated 90 degrees clockwise. <img align="right" valign="center" src="m-west.png">

  * `PANGO_GRAVITY_AUTO`; `Gravity enumeration` is resolved from the context matrix

PangoGravityHint
----------------

``PangoC<C<Gravity enumeration>Hint enumeration> enumeration`` defines how horizontal scripts should behave in a vertical context.

That is, English excerpts in a vertical paragraph for example.

See also [enum `$Pango`.`Gravity enumeration`]=item `PANGO_GRAVITY_HINT_NATURAL`; scripts will take their natural gravity based on the base gravity and the script. This is the default.

  * `PANGO_GRAVITY_HINT_STRONG`; always use the base gravity set, regardless of the script.

  * `PANGO_GRAVITY_HINT_LINE`; for scripts not in their natural direction (eg. Latin in East gravity), choose per-script gravity such that every script respects the line progression. This means, Latin and Arabic will take opposite gravities and both flow top-to-bottom for example.

Standalone Functions
====================

gravity-get-for-matrix
----------------------

Finds the gravity that best matches the rotation component in a `PangoMatrix`.

    method gravity-get-for-matrix ( CArray[N-Matrix]  $matrix --> PangoGravity )

  * $matrix; a `PangoMatrix`.

Return value; the gravity of `$matrix`, which will never be %PANGO_GRAVITY_AUTO, or %PANGO_GRAVITY_SOUTH if `$matrix` is `Nil`. An enumeration.

gravity-get-for-script
----------------------

Returns the gravity to use in laying out a `PangoItem`.

The gravity is determined based on the script, base gravity, and hint.

If `$base_gravity` is %PANGO_GRAVITY_AUTO, it is first replaced with the preferred gravity of `$script`. To get the preferred gravity of a script, pass %PANGO_GRAVITY_AUTO and %PANGO_GRAVITY_HINT_STRONG in.

    method gravity-get-for-script ( PangoScript  $script, PangoGravity $base-gravity, PangoGravityHint $hint --> PangoGravity )

  * $script; ``PangoScript enumeration`` to query. An enumeration.

  * $base-gravity; base gravity of the paragraph. An enumeration.

  * $hint; orientation hint. An enumeration.

Return value; resolved gravity suitable to use for a run of text with `$script`. An enumeration.

gravity-get-for-script-and-width
--------------------------------

Returns the gravity to use in laying out a single character or `PangoItem`.

The gravity is determined based on the script, East Asian width, base gravity, and hint,

This function is similar to [func `$Pango`.`Gravity enumeration`.get_for_script] except that this function makes a distinction between narrow/half-width and wide/full-width characters also. Wide/full-width characters always stand *upright*, that is, they always take the base gravity, whereas narrow/full-width characters are always rotated in vertical context.

If `$base_gravity` is %PANGO_GRAVITY_AUTO, it is first replaced with the preferred gravity of `$script`.

    method gravity-get-for-script-and-width ( PangoScript  $script, Bool() $wide, PangoGravity $base-gravity, PangoGravityHint $hint --> PangoGravity )

  * $script; ``PangoScript enumeration`` to query. An enumeration.

  * $wide; `True` for wide characters as returned by g_unichar_iswide().

  * $base-gravity; base gravity of the paragraph. An enumeration.

  * $hint; orientation hint. An enumeration.

Return value; resolved gravity suitable to use for a run of text with `$script` and `$wide`.. An enumeration.

gravity-to-rotation
-------------------

Converts a ``PangoC<Gravity enumeration> enumeration`` value to its natural rotation in radians.

Note that [method `$Pango`.Matrix.rotate] takes angle in degrees, not radians. So, to call [method `$Pango`.Matrix,rotate] with the output of this function you should multiply it by (180. / G_PI).

    method gravity-to-rotation ( PangoGravity $gravity --> Num )

  * $gravity; gravity to query, should not be %PANGO_GRAVITY_AUTO. An enumeration.

Return value; the rotation value corresponding to `$gravity`.. 
