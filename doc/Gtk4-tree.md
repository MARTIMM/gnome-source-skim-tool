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
│   │   ├── GtkFixed
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
│   │   ├── GtkInfoBar
│   │   ├── GtkLabel                            Label
│   │   ├── GtkListBox
│   │   ├── GtkListBoxRow
│   │   ├── GtkMediaControls
│   │   ├── GtkMenuButton
│   │   ├── GtkNotebook
│   │   ├── GtkOverlay
│   │   ├── GtkPaned
│   │   ├── GtkPasswordEntry
│   │   ├── GtkPicture                          Picture
│   │   ├── GtkPopoverMenuBar
│   │   ├── GtkProgressBar
│   │   ├── GtkRange
│   │   │   ╰── GtkScale
│   │   ├── GtkRevealer
│   │   ├── GtkScaleButton
│   │   │   ╰── GtkVolumeButton
│   │   ├── GtkScrollbar
│   │   ├── GtkScrolledWindow
│   │   ├── GtkSearchBar
│   │   ├── GtkSearchEntry
│   │   ├── GtkSeparator
│   │   ├── GtkShortcutLabel                    ShortcutLabel
│   │   ├── GtkShortcutsShortcut                ShortcutsShortcut
│   │   ├── GtkSpinButton
│   │   ├── GtkSpinner
│   │   ├── GtkStack
│   │   ├── GtkStackSidebar
│   │   ├── GtkStackSwitcher
│   │   ├── GtkStatusbar
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
├── GtkEntryBuffer
├── GtkEntryCompletion
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
├── GtkListItem
├── GtkListStore
├── GtkMapListModel
├── GtkMediaStream
│   ╰── GtkMediaFile
├── GMountOperation
│   ╰── GtkMountOperation
├── GtkMultiSelection                           MultiSelection
├── GtkNoSelection                              NoSelection
├── GtkNotebookPage
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
├── GtkStackPage
├── GtkStringList
├── GtkStringObject
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

```