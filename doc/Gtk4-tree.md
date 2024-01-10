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
│   │   ├── GtkProgressBar
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
│   │   ├── GtkSpinButton
│   │   ├── GtkSpinner
│   │   ├── GtkStack                            Stack
│   │   ├── GtkStackSidebar                     StackSidebar
│   │   ├── GtkStackSwitcher                    StackSwitcher
│   │   ├── GtkStatusbar                        Statusbar
│   │   ├── GtkSwitch
│   │   ├── GtkLevelBar
│   │   ├── GtkText                             Text
│   │   ├── GtkTextView                         TextView
│   │   ├── GtkTreeExpander
│   │   ├── GtkTreeView
│   │   ├── GtkVideo
│   │   ├── GtkViewport
│   │   ├── GtkWindowControls
│   │   ╰── GtkWindowHandle
│   ├── GtkAdjustment
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
│   ╰── GtkTreeViewColumn
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
├── GtkLayoutManager
│   ├── GtkBinLayout
│   ├── GtkBoxLayout
│   ├── GtkCenterLayout
│   ├── GtkConstraintLayout
│   ├── GtkCustomLayout
│   ├── GtkFixedLayout
│   ├── GtkGridLayout
│   ╰── GtkOverlayLayout
├── GtkBookmarkList
├── GtkBuilderCScope
├── GtkBuilder
├── GtkListItemFactory                          ListItemFactory
│   ├── GtkBuilderListItemFactory               BuilderListItemFactory
│   ╰── GtkSignalListItemFactory                SignalListItemFactory
├── GtkCellAreaContext
├── GtkColumnViewColumn
├── GtkConstraint                               Constraint
├── GtkConstraintGuide
├── GtkCssProvider                              CssProvider
├── GtkSorter
│   ├── GtkCustomSorter
│   ├── GtkMultiSorter
│   ├── GtkNumericSorter
│   ├── GtkStringSorter
│   ╰── GtkTreeListRowSorter
├── GtkDirectoryList
├── GtkEventController
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
├── GtkLayoutChild
│   ├── GtkGridLayoutChild
│   ├── GtkOverlayLayoutChild
│   ├── GtkConstraintLayoutChild
│   ╰── GtkFixedLayoutChild
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
├── GdkSnapshot
│   ╰── GtkSnapshot
├── GtkSortListModel
├── GtkStackPage                                StackPage
├── GtkStringList                               StringList
├── GtkStringObject                             StringObject
├── GtkStyleContext                             StyleContext
├── GtkTextBuffer
├── GtkTextChildAnchor
├── GtkTextMark
├── GtkTextTag
├── GtkTextTagTable
├── GtkTreeListModel
├── GtkTreeListRow
├── GtkTreeModelFilter
├── GtkTreeModelSort
├── GtkTreeSelection
├── GtkTreeStore
├── GtkWidgetPaintable
├── GtkWindowGroup
├── GtkTooltip
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

GInterface
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

GBoxed
├── GtkBitset
├── GtkPaperSize
├── GtkTextIter
├── GtkTreeIter                                 TreeIter
├── GtkCssSection
╰── GtkTreePath

GtkExpression

Types, constants, standalone functions, etc. generated from gnome sources
Gnome::Gtk4::*

T-AboutDialog
T-Accessible
T-ActivateAction
T-Application
T-Assistant
T-Dialog
T-Editable
T-Entry
T-Enums
T-IconPaintable
T-IconView
T-Image
T-FileChooser
T-FontChooser
T-MessageDialog
T-Native
T-Notebook
T-PrintOperation
T-ScrolledWindow
T-ShortcutsShortcut
T-Show
T-ShortcutAction
T-SpinButton
T-StyleContext
T-StyleProvider
T-TextView
T-TreeDragDest
T-TreeIter
T-TreeSortable

```