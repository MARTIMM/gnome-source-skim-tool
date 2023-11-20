Project Description
-------------------

  * **Distribution:** Gnome::Pango

  * **Project description:** Modules for package Gnome::Pango:api<2>. The language binding to Pango: Internationalized text layout and rendering

  * **Project version:** 0.1.2

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

Enumerations
============

PangoAlignment
--------------

``PangoAlignment enumeration`` describes how to align the lines of a `PangoLayout` within the available space.

If the `PangoLayout` is set to justify using [method `$Pango`.Layout.set_justify], this only affects partial lines.

See [method `$Pango`.Layout.set_auto_dir] for how text direction affects the interpretation of ``PangoAlignment enumeration`` values.=item `PANGO_ALIGN_LEFT`; Put all available space on the right

  * `PANGO_ALIGN_CENTER`; Center the line within the available space

  * `PANGO_ALIGN_RIGHT`; Put all available space on the left

PangoEllipsizeMode
------------------

``PangoEllipsizeMode enumeration`` describes what sort of ellipsization should be applied to text.

In the ellipsization process characters are removed from the text in order to make it fit to a given width and replaced with an ellipsis.=item `PANGO_ELLIPSIZE_NONE`; No ellipsization

  * `PANGO_ELLIPSIZE_START`; Omit characters at the start of the text

  * `PANGO_ELLIPSIZE_MIDDLE`; Omit characters in the middle of the text

  * `PANGO_ELLIPSIZE_END`; Omit characters at the end of the text

PangoLayoutDeserializeError
---------------------------

Errors that can be returned by [func `$Pango`.Layout.deserialize].=item `PANGO_LAYOUT_DESERIALIZE_INVALID`; Unspecified error

  * `PANGO_LAYOUT_DESERIALIZE_INVALID_VALUE`; A JSon value could not be interpreted

  * `PANGO_LAYOUT_DESERIALIZE_MISSING_VALUE`; A required JSon member was not found

PangoWrapMode
-------------

``PangoWrapMode enumeration`` describes how to wrap the lines of a `PangoLayout` to the desired width.

For `$PANGO_WRAP_WORD`, Pango uses break opportunities that are determined by the Unicode line breaking algorithm. For `$PANGO_WRAP_CHAR`, Pango allows breaking at grapheme boundaries that are determined by the Unicode text segmentation algorithm.=item `PANGO_WRAP_WORD`; wrap lines at word boundaries.

  * `PANGO_WRAP_CHAR`; wrap lines at character boundaries.

  * `PANGO_WRAP_WORD_CHAR`; wrap lines at word boundaries, but fall back to character boundaries if there is not enough space for a full word.

Bitfields
=========

PangoLayoutDeserializeFlags
---------------------------

Flags that influence the behavior of [func `$Pango`.Layout.deserialize].

New members may be added to this enumeration over time.

  * `PANGO_LAYOUT_DESERIALIZE_DEFAULT`; Default behavior

  * `PANGO_LAYOUT_DESERIALIZE_CONTEXT`; Apply context information from the serialization to the `PangoContext`

PangoLayoutSerializeFlags
-------------------------

Flags that influence the behavior of [method `$Pango`.Layout.serialize].

New members may be added to this enumeration over time.

  * `PANGO_LAYOUT_SERIALIZE_DEFAULT`; Default behavior

  * `PANGO_LAYOUT_SERIALIZE_CONTEXT`; Include context information

  * `PANGO_LAYOUT_SERIALIZE_OUTPUT`; Include information about the formatted output
