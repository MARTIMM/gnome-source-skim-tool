# Administration of Gtk version 4

Class **Gnome::GObject::Object** is inheriting from class **Gnome::N::TopLevelClassSupport**

## Class modules
```
GObject                                         Gnome::GObject::Object
├── GInitiallyUnowned                           Gnome::GObject::InitiallyUnowned
|   |                                           Gnome::Gtk4::*
│   ├── GtkWidget                               Widget
│   │   ├── GtkWindow                           Window
│   │   │   ├── GtkAboutDialog                  AboutDialog
│   │   │   ├── GtkDialog                       Dialog
│   │   │   │   ├── GtkAppChooserDialog         AppChooserDialog
│   │   │   │   ├── GtkColorChooserDialog       ColorChooserDialog
│   │   │   │   ├── GtkFileChooserDialog        FileChooserDialog
│   │   │   │   ├── GtkFontChooserDialog        FontChooserDialog
│   │   │   │   ├── GtkMessageDialog            MessageDialog
│   │   │   │   ├── GtkPageSetupUnixDialog      PageSetupUnixDialog
│   │   │   │   ╰── GtkPrintUnixDialog
│   │   │   ├── GtkApplicationWindow            ApplicationWindow
│   │   │   ├── GtkAssistant                    Assistant
│   │   │   ╰── GtkShortcutsWindow              ShortcutsWindow
│   │   ├── GtkActionBar                        ActionBar
│   │   ├── GtkAppChooserButton                 AppChooserButton
│   │   ├── GtkAppChooserWidget                 AppChooserWidget
│   │   ├── GtkAspectFrame                      AspectFrame
│   │   ├── GtkBox                              Box
│   │   │   ├── GtkShortcutsSection             ShortcutsSection
│   │   │   ╰── GtkShortcutsGroup               ShortcutsGroup
│   │   ├── GtkButton                           Button
│   │   │   ├── GtkLinkButton                   LinkButton
│   │   │   ├── GtkLockButton                   LockButton
│   │   │   ╰── GtkToggleButton                 ToggleButton
│   │   ├── GtkCalendar                         Calendar
│   │   ├── GtkCellView                         CellView
│   │   ├── GtkCenterBox                        CenterBox
│   │   ├── GtkCheckButton                      CheckButton
│   │   ├── GtkColorButton                      ColorButton
│   │   ├── GtkColorChooserWidget               ColorChooserWidget
│   │   ├── GtkColumnView                       ColumnView
│   │   ├── GtkComboBox                         ComboBox
│   │   │   ╰── GtkComboBoxText                 ComboBoxText
│   │   ├── GtkDragIcon                         DragIcon
│   │   ├── GtkDrawingArea                      DrawingArea
│   │   ├── GtkDropDown                         DropDown
│   │   ├── GtkEditableLabel                    EditableLabel
│   │   ├── GtkPopover
│   │   │   ├── GtkEmojiChooser
│   │   │   ╰── GtkPopoverMenu
│   │   ├── GtkEntry                            Entry
│   │   ├── GtkExpander
│   │   ├── GtkFileChooserWidget                FileChooserWidget
│   │   ├── GtkFixed                            Fixed
│   │   ├── GtkFlowBox
│   │   ├── GtkFlowBoxChild
│   │   ├── GtkFontButton
│   │   ├── GtkFontChooserWidget                FontChooserWidget
│   │   ├── GtkFrame                            Frame
│   │   ├── GtkGLArea
│   │   ├── GtkGrid                             Grid
│   │   ├── GtkListBase                         ListBase
│   │   │   ├── GtkGridView                     GridView
│   │   │   ╰── GtkListView                     ListView
│   │   ├── GtkHeaderBar                        HeaderBar
│   │   ├── GtkIconView                         IconView
│   │   ├── GtkImage                            Image
│   │   ├── GtkInfoBar                          InfoBar
│   │   ├── GtkLabel                            Label
│   │   ├── GtkListBox                          ListBox
│   │   ├── GtkListBoxRow                       ListBoxRow
│   │   ├── GtkMediaControls
│   │   ├── GtkMenuButton
│   │   ├── GtkNotebook                         Notebook
│   │   ├── GtkOverlay
│   │   ├── GtkPaned                            Paned
│   │   ├── GtkPasswordEntry                    PasswordEntry
│   │   ├── GtkPicture                          Picture
│   │   ├── GtkPopoverMenuBar
│   │   ├── GtkProgressBar                      ProgressBar
│   │   ├── GtkRange                            Range
│   │   │   ╰── GtkScale                        Scale
│   │   ├── GtkRevealer
│   │   ├── GtkScaleButton
│   │   │   ╰── GtkVolumeButton
│   │   ├── GtkScrollbar                        Scrollbar
│   │   ├── GtkScrolledWindow                   ScrolledWindow
│   │   ├── GtkSearchBar                        SearchBar
│   │   ├── GtkSearchEntry                      SearchEntry
│   │   ├── GtkSeparator
│   │   ├── GtkShortcutLabel                    ShortcutLabel
│   │   ├── GtkShortcutsShortcut                ShortcutsShortcut
│   │   ├── GtkSpinButton                       SpinButton
│   │   ├── GtkSpinner                          Spinner
│   │   ├── GtkStack                            Stack
│   │   ├── GtkStackSidebar                     StackSidebar
│   │   ├── GtkStackSwitcher                    StackSwitcher
│   │   ├── GtkStatusbar                        Statusbar
│   │   ├── GtkSwitch                           Switch
│   │   ├── GtkLevelBar                         LevelBar
│   │   ├── GtkText                             Text
│   │   ├── GtkTextView                         TextView
│   │   ├── GtkTreeExpander                     TreeExpander
│   │   ├── GtkTreeView                         TreeView
│   │   ├── GtkVideo
│   │   ├── GtkViewport
│   │   ├── GtkWindowControls
│   │   ╰── GtkWindowHandle
│   ├── GtkAdjustment                           Adjustment
│   ├── GtkCellArea
│   │   ╰── GtkCellAreaBox
│   ├── GtkCellRenderer
│   │   ├── GtkCellRendererText
│   │   │   ├── GtkCellRendererAccel
│   │   │   ├── GtkCellRendererCombo
│   │   │   ╰── GtkCellRendererSpin
│   │   ├── GtkCellRendererPixbuf
│   │   ├── GtkCellRendererProgress
│   │   ├── GtkCellRendererSpinner
│   │   ╰── GtkCellRendererToggle
│   ╰── GtkTreeViewColumn                       TreeViewColumn
├── GtkFilter
│   ├── GtkMultiFilter
│   │   ├── GtkAnyFilter
│   │   ╰── GtkEveryFilter
│   ├── GtkBoolFilter
│   ├── GtkCustomFilter
│   ├── GtkFileFilter
│   ╰── GtkStringFilter
├── GApplication                                Application in Gnome::Gio
│   ╰── GtkApplication                          Application
├── GtkAssistantPage                            AssistantPage
├── GtkATContext
├── GtkLayoutManager                            LayoutManager
│   ├── GtkBinLayout                            BinLayout
│   ├── GtkBoxLayout                            BoxLayout
│   ├── GtkCenterLayout                         CenterLayout
│   ├── GtkConstraintLayout                     ConstraintLayout
│   ├── GtkCustomLayout                         CustomLayout
│   ├── GtkFixedLayout                          FixedLayout
│   ├── GtkGridLayout                           GridLayout
│   ╰── GtkOverlayLayout                        OverlayLayout
├── GtkBookmarkList
├── GtkBuilderCScope
├── GtkBuilder                                  Builder
├── GtkListItemFactory                          ListItemFactory
│   ├── GtkBuilderListItemFactory               BuilderListItemFactory
│   ╰── GtkSignalListItemFactory                SignalListItemFactory
├── GtkCellAreaContext
├── GtkColumnViewColumn
├── GtkConstraint                               Constraint
├── GtkConstraintGuide
├── GtkCssProvider                              CssProvider
├── GtkSorter                                   Sorter
│   ├── GtkCustomSorter                         CustomSorter
│   ├── GtkMultiSorter                          MultiSorter
│   ├── GtkNumericSorter                        NumericSorter
│   ├── GtkStringSorter                         StringSorter
│   ╰── GtkTreeListRowSorter                    TreeListRowSorter
├── GtkDirectoryList
├── GtktEvenController                          EvenController
│   ├── GtkGesture
│   │   ├── GtkGestureSingle
│   │   │   ├── GtkDragSource
│   │   │   ├── GtkGestureClick
│   │   │   ├── GtkGestureDrag
│   │   │   │   ╰── GtkGesturePan
│   │   │   ├── GtkGestureLongPress
│   │   │   ├── GtkGestureStylus
│   │   │   ╰── GtkGestureSwipe
│   │   ├── GtkGestureRotate
│   │   ╰── GtkGestureZoom
│   ├── GtkDropControllerMotion
│   ├── GtkDropTargetAsync
│   ├── GtkDropTarget
│   ├── GtkEventControllerKey
│   ├── GtkEventControllerFocus
│   ├── GtkEventControllerLegacy
│   ├── GtkEventControllerMotion
│   ├── GtkEventControllerScroll
│   ├── GtkPadController
│   ╰── GtkShortcutController
├── GtkEntryBuffer                              EntryBuffer
├── GtkEntryCompletion                          EntryCompletion
├── GtkNativeDialog
│   ╰── GtkFileChooserNative
├── GtkFilterListModel
├── GtkFlattenListModel
├── GtkLayoutChild                              LayoutChild
│   ├── GtkGridLayoutChild                      GridLayoutChild
│   ├── GtkOverlayLayoutChild                   OverlayLayoutChild
│   ├── GtkConstraintLayoutChild                ConstraintLayoutChild
│   ╰── GtkFixedLayoutChild                     FixedLayoutChild
├── GtkIconTheme                                IconTheme
├── GtkIMContext
│   ├── GtkIMContextSimple
│   ╰── GtkIMMulticontext
├── GtkListItem                                 ListItem
├── GtkListStore                                ListStore
├── GtkMapListModel
├── GtkMediaStream
│   ╰── GtkMediaFile
├── GMountOperation
│   ╰── GtkMountOperation
├── GtkMultiSelection                           MultiSelection
├── GtkNoSelection                              NoSelection
├── GtkNotebookPage                             NotebookPage
├── GtkPageSetup
├── GtkPrinter
├── GtkPrintContext
├── GtkPrintJob
├── GtkPrintOperation                           PrintOperation
├── GtkPrintSettings
├── GtkRecentManager
├── GtkSelectionFilterModel
├── GtkSettings
├── GtkShortcut                                 Shortcut
├── GtkSingleSelection                          SingleSelection
├── GtkSizeGroup
├── GtkSliceListModel
├── GdkSnapshot                                 Snapshot in Gnome::Gdk4
│   ╰── GtkSnapshot                             Snapshot
├── GtkSortListModel
├── GtkStackPage                                StackPage
├── GtkStringList                               StringList
├── GtkStringObject                             StringObject
├── GtkStyleContext                             StyleContext
├── GtkTextBuffer                               TextBuffer
├── GtkTextChildAnchor                          TextChildAnchor
├── GtkTextMark                                 TextMark
├── GtkTextTag                                  TextTag
├── GtkTextTagTable                             TextTagTable
├── GtkTreeListModel                            TreeListModel
├── GtkTreeListRow                              TreeListRow
├── GtkTreeModelFilter                          TreeModelFilter
├── GtkTreeModelSort                            TreeModelSort
├── GtkTreeSelection                            TreeSelection
├── GtkTreeStore                                TreeStore
├── GtkWidgetPaintable
├── GtkWindowGroup
├── GtkTooltip                                  Tooltip
├── GtkShortcutAction                           ShortcutAction
│   ├── GtkSignalAction                         SignalAction
│   ├── GtkNothingAction                        NothingAction
│   ├── GtkNamedAction                          NamedAction
│   ╰── GtkCallbackAction                       CallbackAction
├── GtkShortcutTrigger                          ShortcutTrigger
│   ├── GtkKeyvalTrigger                        KeyvalTrigger
│   ├── GtkNeverTrigger                         NeverTrigger
│   ╰── GtkAlternativeTrigger                   AlternativeTrigger
╰── GtkPrintBackend
```

## Role modules

```
GInterface
|                                               Gnome::Gtk4::*
├── GtkAccessible                               R-Accessible
├── GtkBuildable                                R-Buildable
├── GtkConstraintTarget                         R-ConstraintTarget
├── GtkNative                                   R-Native
├── GtkShortcutManager                          R-ShortcutManager
├── GtkRoot                                     R-Root
├── GtkActionable                               R-Actionable
├── GtkAppChooser                               R-AppChooser
├── GtkOrientable                               R-Orientable
├── GtkBuilderScope
├── GtkCellLayout                               R-CellLayout
├── GtkCellEditable                             R-CellEditable
├── GtkColorChooser                             R-ColorChooser
├── GtkScrollable                               R-Scrollable
├── GtkStyleProvider                            R-StyleProvider
├── GtkEditable                                 R-Editable
├── GtkFileChooser                              R-FileChooser
├── GtkFontChooser                              R-FontChooser
├── GtkTreeModel                                R-TreeModel
├── GtkTreeDragSource                           R-TreeDragSource
├── GtkTreeDragDest                             R-TreeDragDest
├── GtkTreeSortable                             R-TreeSortable
├── GtkSelectionModel                           R-SelectionModel
╰── GtkPrintOperationPreview                    R-PrintOperationPreview
```

## Other type classes
These modules are generally inheriting directly from **Gnome::N::TopLevelClassSupport**

```
GBoxed
|                                               Gnome::Gtk4::*
├── GtkBitset                                   N-Bitset
├── GtkCssSection
├── GtkPaperSize
├── GtkTextIter                                 N-TextIter
├── GtkTreeIter                                 N-TreeIter
╰── GtkTreePath                                 N-TreePath

Gnome::N::TopLevelClassSupport
|   Gnome::Gtk4::*
├── N-BitsetIter
├── N-Border
├── N-Requisition
├── N-TreeRowReference
├── 

GtkExpression
```

## Type modules

Types, constants, standalone functions, etc. generated from gnome sources
`Gnome::Gtk4::\*`

```
Gnome::N::TopLevelClassSupport
|   Gnome::Gtk4::*
├── T-aboutdialog
├── T-accessible
├── T-activateaction
├── T-application
├── T-assistant
├── T-bitset
├── T-builder
├── T-dialog
├── T-editable
├── T-entry
├── T-enums
├── T-filechooser
├── T-FontChooser
├── T-IconPaintable
├── T-IconView
├── T-Image
├── T-LevelBar
├── T-MessageDialog
├── T-native
├── T-Notebook
├── T-printoperation
├── T-ScrolledWindow
├── T-ShortcutAction
├── T-ShortcutsShortcut
├── T-show
├── T-Sorter
├── T-SpinButton
├── T-Stack
├── T-StyleContext
├── T-StyleProvider
├── T-TextIter
├── T-TextView
├── T-treedragdest
├── T-TreeIter
├── T-TreeSortable
├── T-TreeView
├── T-TreeViewColumn
├── T-types
```

---

# ADministration of Gdk version 4
## Class modules

```
GObject                                         Gnome::GObject::Object
|                                               Gnome::Gdk4::*
├── Gio.AppLaunchContext
|   ├── AppLaunchContext
├── DrawContext
|   ├── CairoContext
|   ├── GLContext
|   ├── VulkanContext
├── Clipboard
├── ContentDeserializer
├── ContentProvider
├── ContentSerializer
├── Cursor
├── Device
├── DeviceTool
├── Display
├── DisplayManager
├── Texture                                     Texture
|   ├── DmabufTexture
|   ├── GLTexture
|   ╰── MemoryTexture                           MemoryTexture
├── DmabufTextureBuilder
├── Drag
├── Drop
├── FrameClock
├── GLTextureBuilder
├── Monitor
├── Seat
├── Snapshot                                    Snapshot
├── Surface


GObject.TypeInstance
├── Event
|   ├── ButtonEvent
|   ├── CrossingEvent
|   ├── DNDEvent
|   ├── DeleteEvent
|   ├── FocusEvent
|   ├── GrabBrokenEvent
|   ├── KeyEvent
|   ├── MotionEvent
|   ├── PadEvent
|   ├── ProximityEvent
|   ├── ScrollEvent
|   ├── TouchEvent
|   ├── TouchpadEvent

```

## Role modules

```
GInterface
|                                            Gnome::Gdk4::*
├── DevicePad
├── DragSurface
├── Paintable                                R-Paintable
├── Popup
├── Toplevel
```

## Other type classes
These modules are generally inheriting directly from **Gnome::N::TopLevelClassSupport**. Most of them are just structures with sometimes an API.
<!--https://docs.gtk.org/gdk4/index.html-->
```
GBoxed
|                                            Gnome::Gdk4::*
├──                                          N-ContentFormats
├── GdkRectangle                             N-Rectangle
├── GdkRGBA                                  N-RGBA

```

## Type modules

Types, constants, standalone functions, etc. generated from gnome sources
`Gnome::Gdk4::\*`

```
Gnome::N::TopLevelClassSupport
|   Gnome::Gsk4::*
├── T-enums
├── T-keysyms
├── T-paintable
├── T-rgba
├── T-texture
├── T-types


```

---

# Administration of Gio

## Class modules

```
GObject                                         Gnome::GObject::Object
|                                               Gnome::Gio::*
├── GApplication                                Application
├── GApplicationCommandLine                     ApplicationCommandLine
├── GFile                                       File
├── GListStore                                  ListStore
├── GMenu                                       Menu
├── GMenuAttribute                              MenuAttribute
├── GMenuItem                                   MenuItem
├── GMenuLinkIter                               MenuLinkIter
├── GMenuModel                                  MenuModel
├── GNotification                               Notification
├── GPermission                                 Permission
├── GSimpleAction                               SimpleAction
├── GSimpleActionGroup                          SimpleActionGroup
├── GSimplePermission                           SimplePermission
├──
├──
```

## Role modules

```
GInterface
|                                               Gnome::Gio::*
├── GAction                                     R-Action
├── GActionGroup                                R-ActionGroup
├── GActionMap                                  R-ActionMap
├── GListModel                                  R-ListModel
├── 
├──
├──

```

## Type modules

Types, constants, standalone functions, etc. generated from gnome sources
`Gnome::Gtk4::\*`

```
Gnome::N::TopLevelClassSupport
|   Gnome::Gio::*
├── T-action
├── T-file
├── T-ioenums
├── T-menuattributeiter
├── T-menumodel
```

---
# Administration of Gsk types and classes

Class **Gnome::GObject::Object** is inheriting from class **Gnome::N::TopLevelClassSupport**

## Class modules

```
GObject                                         Gnome::GObject::Object
|                                               Gnome::Gsk::*
├── GskRenderer                                 Renderer
│   ├── GskCairoRenderer                        CairoRenderer
│   ├── GskGLRenderer                           GLRenderer
│   ├── GskNglRenderer
│   ├── GskVulkanRenderer
├── GskGLShader                                 GLShader

GObjectTypeInstance
|                                               Gnome::Gsk::*
├── GskRenderNode                               RenderNode
│   ├── GskBlendNode                            BlendNode
│   ├── GskBlurNode                             BlurNode
│   ├── GskBorderNode                           BorderNode
│   ├── GskCairoNode                            CairoNode
│   ├── GskClipNode                             ClipNode
│   ├── GskColorMatrixNode                      ColorMatrixNode
│   ├── GskColorNode                            ColorNode
│   ├── GskConicGradientNode                    ConicGradientNode
│   ├── GskContainerNode                        ContainerNode
│   ├── GskCrossFadeNode                        CrossFadeNode
│   ├── GskDebugNode                            DebugNode
│   ├── GskFillNode
│   ├── GskGLShaderNode                         GLShaderNode
│   ├── GskInsetShadowNode                      InsetShadowNode
│   ├── GskLinearGradientNode                   LinearGradientNode
│   ├── GskMaskNode                             MaskNode
│   ├── GskOpacityNode                          OpacityNode
│   ├── GskOutsetShadowNode                     OutsetShadowNode
│   ├── GskRadialGradientNode                   RadialGradientNode
│   ├── GskRepeatNode                           RepeatNode
│   ├── GskRepeatingLinearGradientNode          RepeatingLinearGradientNode
│   ├── GskRepeatingRadialGradientNode          RepeatingRadialGradientNode
│   ├── GskRoundedClipNode                      RoundedClipNode
│   ├── GskShadowNode                           ShadowNode
│   ├── GskStrokeNode
│   ├── GskSubsurfaceNode
│   ├── GskTextNode                             TextNode
│   ├── GskTextureNode                          TextureNode
│   ├── GskTextureScaleNode                     TextureScaleNode
│   ├── GskTransformNode                        TransformNode

```
Some classes are very new. Not yet found on my system and not in GIR data.Examples: GskFillNode, GskStrokeNode, GskSubsurfaceNode, skVulkanRenderer.

GskNglRenderer seems to be deprecated.

```
GBoxed
|
├── N-ShaderArgsBuilder
├── N-Transform
```

```
Gnome::N::TopLevelClassSupport
|   Gnome::Gsk4::*
├── T-enums
├── T-glshader
├── T-rendernode
├── T-Transform
├── T-types

```

---
# Administration of Graphene types and classes

Class **Gnome::GObject::Object** is inheriting from class **Gnome::N::TopLevelClassSupport**

## Class modules

```
GBoxed
|                                               Gnome::Graphene::*
├── Box                                         N-Box
├── Euler                                       N-Euler
├── Frustum                                     N-Frustum
├── Matrix                                      N-Matrix
├── Plain                                       N-Plane
├── Point3D                                     N-Point3D
├── Point                                       N-Point
├── Quad                                        N-Quad
├── Quaternion                                  N-Quaternion
├── Ray                                         N-Ray
├── Rect                                        N-Rect
├── Size                                        N-Size
├── Sphere                                      N-Sphere
├── Triangle                                    N-Triangle
├── Vec2                                        N-Vec2
├── Vec3                                        N-Vec3
├── Vec4                                        N-Vec4
```

## Type modules

Types, constants, standalone functions, etc.

```
Gnome::N::TopLevelClassSupport
|   Gnome::Graphene::*
├── T-box
├── T-config
├── T-euler
├── T-frustum
├── T-matrix
├── T-plane
├── T-point3d
├── T-point
├── T-quad
├── T-quaternion
├── T-ray
├── T-rect
├── T-size
├── T-sphere
├── T-triangle
├── T-vec
```

