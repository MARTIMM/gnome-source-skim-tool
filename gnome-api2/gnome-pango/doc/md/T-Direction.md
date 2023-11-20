Project Description
-------------------

  * **Distribution:** Gnome::Pango

  * **Project description:** Modules for package Gnome::Pango:api<2>. The language binding to Pango: Internationalized text layout and rendering

  * **Project version:** 0.1.2

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

Enumerations
============

PangoDirection
--------------

``PangoDirection enumeration`` represents a direction in the Unicode bidirectional algorithm.

Not every value in this enumeration makes sense for every usage of ``PangoDirection enumeration``; for example, the return value of [func `$unichar_direction`] and [func `$find_base_dir`] cannot be `PANGO_DIRECTION_WEAK_LTR` or `PANGO_DIRECTION_WEAK_RTL`, since every character is either neutral or has a strong direction; on the other hand `PANGO_DIRECTION_NEUTRAL` doesn't make sense to pass to [func `$itemize_with_base_dir`].

The `PANGO_DIRECTION_TTB_LTR`, `PANGO_DIRECTION_TTB_RTL` values come from an earlier interpretation of this enumeration as the writing direction of a block of text and are no longer used. See ``PangoC<Gravity enumeration> enumeration`` for how vertical text is handled in Pango.

If you are interested in text direction, you should really use fribidi directly. ``PangoDirection enumeration`` is only retained because it is used in some public apis.=item `PANGO_DIRECTION_LTR`; A strong left-to-right direction

  * `PANGO_DIRECTION_RTL`; A strong right-to-left direction

  * `PANGO_DIRECTION_TTB_LTR`; Deprecated value; treated the same as `PANGO_DIRECTION_RTL`.

  * `PANGO_DIRECTION_TTB_RTL`; Deprecated value; treated the same as `PANGO_DIRECTION_LTR`

  * `PANGO_DIRECTION_WEAK_LTR`; A weak left-to-right direction

  * `PANGO_DIRECTION_WEAK_RTL`; A weak right-to-left direction

  * `PANGO_DIRECTION_NEUTRAL`; No direction specified
