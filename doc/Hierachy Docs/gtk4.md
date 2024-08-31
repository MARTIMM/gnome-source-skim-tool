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
│   │   │   │   ╰── GtkPrintUnixDialog          PrintUnixDialog
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
│   │   ├── GtkPopover                          Popover
│   │   │   ├── GtkEmojiChooser                 EmojiChooser
│   │   │   ╰── GtkPopoverMenu                  PopoverMenu
│   │   ├── GtkEntry                            Entry
│   │   ├── GtkExpander                         Expander
│   │   ├── GtkFileChooserWidget                FileChooserWidget
│   │   ├── GtkFixed                            Fixed
│   │   ├── GtkFlowBox                          FlowBox
│   │   ├── GtkFlowBoxChild                     FlowBoxChild
│   │   ├── GtkFontButton                       FontButton
│   │   ├── GtkFontChooserWidget                FontChooserWidget
│   │   ├── GtkFrame                            Frame
│   │   ├── GtkGLArea                           GLArea
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
│   │   ├── GtkMediaControls                    MediaControls
│   │   ├── GtkMenuButton                       MenuButton
│   │   ├── GtkNotebook                         Notebook
│   │   ├── GtkOverlay                          Overlay
│   │   ├── GtkPaned                            Paned
│   │   ├── GtkPasswordEntry                    PasswordEntry
│   │   ├── GtkPicture                          Picture
│   │   ├── GtkPopoverMenuBar                   PopoverMenuBar
│   │   ├── GtkProgressBar                      ProgressBar
│   │   ├── GtkRange                            Range
│   │   │   ╰── GtkScale                        Scale
│   │   ├── GtkRevealer                         Revealer
│   │   ├── GtkScaleButton                      ScaleButton
│   │   │   ╰── GtkVolumeButton                 VolumeButton
│   │   ├── GtkScrollbar                        Scrollbar
│   │   ├── GtkScrolledWindow                   ScrolledWindow
│   │   ├── GtkSearchBar                        SearchBar
│   │   ├── GtkSearchEntry                      SearchEntry
│   │   ├── GtkSeparator                        Separator
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
│   │   ├── GtkVideo                            Video
│   │   ├── GtkViewport                         Viewport
│   │   ├── GtkWindowControls                   WindowControls
│   │   ╰── GtkWindowHandle                     WindowHandle
│   ├── GtkAdjustment                           Adjustment
│   ├── GtkCellArea                             CellArea
│   │   ╰── GtkCellAreaBox                      CellAreaBox
│   ├── GtkCellRenderer                         CellRenderer
│   │   ├── GtkCellRendererText                 CellRendererText
│   │   │   ├── GtkCellRendererAccel            CellRendererAccel
│   │   │   ├── GtkCellRendererCombo            CellRendererCombo
│   │   │   ╰── GtkCellRendererSpin             CellRendererSpin
│   │   ├── GtkCellRendererPixbuf               CellRendererPixbuf
│   │   ├── GtkCellRendererProgress             CellRendererProgress
│   │   ├── GtkCellRendererSpinner              CellRendererSpinner
│   │   ╰── GtkCellRendererToggle               CellRendererToggle
│   ╰── GtkTreeViewColumn                       TreeViewColumn
├── GtkFilter                                   Filter
│   ├── GtkMultiFilter                          MultiFilter
│   │   ├── GtkAnyFilter                        AnyFilter
│   │   ╰── GtkEveryFilter                      EveryFilter
│   ├── GtkBoolFilter                           BoolFilter
│   ├── GtkCustomFilter                         CustomFilter
│   ├── GtkFileFilter                           FileFilter
│   ╰── GtkStringFilter                         StringFilter
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
│   ├── GtkGesture                              Gesture
│   │   ├── GtkGestureSingle                    GestureSingle
│   │   │   ├── GtkDragSource                   DragSource
│   │   │   ├── GtkGestureClick
│   │   │   ├── GtkGestureDrag
│   │   │   │   ╰── GtkGesturePan
│   │   │   ├── GtkGestureLongPress
│   │   │   ├── GtkGestureStylus
│   │   │   ╰── GtkGestureSwipe
│   │   ├── GtkGestureRotate
│   │   ╰── GtkGestureZoom
│   ├── GtkDropControllerMotion                 DropControllerMotion
│   ├── GtkDropTargetAsync                      DropTargetAsync
│   ├── GtkDropTarget                           DropTarget
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

GtkExpression                                   Expression
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
├── T-expression
├── T-filechooser
├── T-fontchooser
├── T-iconpaintable
├── T-iconview
├── T-image
├── T-levelbar
├── T-messagedialog
├── T-native
├── T-notebook
├── T-printoperation
├── T-scrolledwindow
├── T-shortcutaction
├── T-shortcutsshortcut
├── T-show
├── T-sorter
├── T-spinbutton
├── T-stack
├── T-stylecontext
├── T-styleprovider
├── T-textiter
├── T-textview
├── T-treedragdest
├── T-treeiter
├── T-treesortable
├── T-treeview
├── T-treeviewcolumn
├── T-types
```
