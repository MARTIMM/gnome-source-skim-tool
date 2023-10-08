# Command to generate: generate.raku -v -t -c Gtk4 enums
use v6.d;

#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::T-Enums:auth<github:MARTIMM>:api<2>;

#-------------------------------------------------------------------------------
#--[Enumerations]---------------------------------------------------------------
#-------------------------------------------------------------------------------
enum GtkAccessibleAutocomplete is export <
  GTK_ACCESSIBLE_AUTOCOMPLETE_NONE GTK_ACCESSIBLE_AUTOCOMPLETE_INLINE GTK_ACCESSIBLE_AUTOCOMPLETE_LIST GTK_ACCESSIBLE_AUTOCOMPLETE_BOTH 
>;

enum GtkAccessibleInvalidState is export <
  GTK_ACCESSIBLE_INVALID_FALSE GTK_ACCESSIBLE_INVALID_TRUE GTK_ACCESSIBLE_INVALID_GRAMMAR GTK_ACCESSIBLE_INVALID_SPELLING 
>;

enum GtkAccessibleProperty is export <
  GTK_ACCESSIBLE_PROPERTY_AUTOCOMPLETE GTK_ACCESSIBLE_PROPERTY_DESCRIPTION GTK_ACCESSIBLE_PROPERTY_HAS_POPUP GTK_ACCESSIBLE_PROPERTY_KEY_SHORTCUTS GTK_ACCESSIBLE_PROPERTY_LABEL GTK_ACCESSIBLE_PROPERTY_LEVEL GTK_ACCESSIBLE_PROPERTY_MODAL GTK_ACCESSIBLE_PROPERTY_MULTI_LINE GTK_ACCESSIBLE_PROPERTY_MULTI_SELECTABLE GTK_ACCESSIBLE_PROPERTY_ORIENTATION GTK_ACCESSIBLE_PROPERTY_PLACEHOLDER GTK_ACCESSIBLE_PROPERTY_READ_ONLY GTK_ACCESSIBLE_PROPERTY_REQUIRED GTK_ACCESSIBLE_PROPERTY_ROLE_DESCRIPTION GTK_ACCESSIBLE_PROPERTY_SORT GTK_ACCESSIBLE_PROPERTY_VALUE_MAX GTK_ACCESSIBLE_PROPERTY_VALUE_MIN GTK_ACCESSIBLE_PROPERTY_VALUE_NOW GTK_ACCESSIBLE_PROPERTY_VALUE_TEXT 
>;

enum GtkAccessibleRelation is export <
  GTK_ACCESSIBLE_RELATION_ACTIVE_DESCENDANT GTK_ACCESSIBLE_RELATION_COL_COUNT GTK_ACCESSIBLE_RELATION_COL_INDEX GTK_ACCESSIBLE_RELATION_COL_INDEX_TEXT GTK_ACCESSIBLE_RELATION_COL_SPAN GTK_ACCESSIBLE_RELATION_CONTROLS GTK_ACCESSIBLE_RELATION_DESCRIBED_BY GTK_ACCESSIBLE_RELATION_DETAILS GTK_ACCESSIBLE_RELATION_ERROR_MESSAGE GTK_ACCESSIBLE_RELATION_FLOW_TO GTK_ACCESSIBLE_RELATION_LABELLED_BY GTK_ACCESSIBLE_RELATION_OWNS GTK_ACCESSIBLE_RELATION_POS_IN_SET GTK_ACCESSIBLE_RELATION_ROW_COUNT GTK_ACCESSIBLE_RELATION_ROW_INDEX GTK_ACCESSIBLE_RELATION_ROW_INDEX_TEXT GTK_ACCESSIBLE_RELATION_ROW_SPAN GTK_ACCESSIBLE_RELATION_SET_SIZE 
>;

enum GtkAccessibleRole is export <
  GTK_ACCESSIBLE_ROLE_ALERT GTK_ACCESSIBLE_ROLE_ALERT_DIALOG GTK_ACCESSIBLE_ROLE_BANNER GTK_ACCESSIBLE_ROLE_BUTTON GTK_ACCESSIBLE_ROLE_CAPTION GTK_ACCESSIBLE_ROLE_CELL GTK_ACCESSIBLE_ROLE_CHECKBOX GTK_ACCESSIBLE_ROLE_COLUMN_HEADER GTK_ACCESSIBLE_ROLE_COMBO_BOX GTK_ACCESSIBLE_ROLE_COMMAND GTK_ACCESSIBLE_ROLE_COMPOSITE GTK_ACCESSIBLE_ROLE_DIALOG GTK_ACCESSIBLE_ROLE_DOCUMENT GTK_ACCESSIBLE_ROLE_FEED GTK_ACCESSIBLE_ROLE_FORM GTK_ACCESSIBLE_ROLE_GENERIC GTK_ACCESSIBLE_ROLE_GRID GTK_ACCESSIBLE_ROLE_GRID_CELL GTK_ACCESSIBLE_ROLE_GROUP GTK_ACCESSIBLE_ROLE_HEADING GTK_ACCESSIBLE_ROLE_IMG GTK_ACCESSIBLE_ROLE_INPUT GTK_ACCESSIBLE_ROLE_LABEL GTK_ACCESSIBLE_ROLE_LANDMARK GTK_ACCESSIBLE_ROLE_LEGEND GTK_ACCESSIBLE_ROLE_LINK GTK_ACCESSIBLE_ROLE_LIST GTK_ACCESSIBLE_ROLE_LIST_BOX GTK_ACCESSIBLE_ROLE_LIST_ITEM GTK_ACCESSIBLE_ROLE_LOG GTK_ACCESSIBLE_ROLE_MAIN GTK_ACCESSIBLE_ROLE_MARQUEE GTK_ACCESSIBLE_ROLE_MATH GTK_ACCESSIBLE_ROLE_METER GTK_ACCESSIBLE_ROLE_MENU GTK_ACCESSIBLE_ROLE_MENU_BAR GTK_ACCESSIBLE_ROLE_MENU_ITEM GTK_ACCESSIBLE_ROLE_MENU_ITEM_CHECKBOX GTK_ACCESSIBLE_ROLE_MENU_ITEM_RADIO GTK_ACCESSIBLE_ROLE_NAVIGATION GTK_ACCESSIBLE_ROLE_NONE GTK_ACCESSIBLE_ROLE_NOTE GTK_ACCESSIBLE_ROLE_OPTION GTK_ACCESSIBLE_ROLE_PRESENTATION GTK_ACCESSIBLE_ROLE_PROGRESS_BAR GTK_ACCESSIBLE_ROLE_RADIO GTK_ACCESSIBLE_ROLE_RADIO_GROUP GTK_ACCESSIBLE_ROLE_RANGE GTK_ACCESSIBLE_ROLE_REGION GTK_ACCESSIBLE_ROLE_ROW GTK_ACCESSIBLE_ROLE_ROW_GROUP GTK_ACCESSIBLE_ROLE_ROW_HEADER GTK_ACCESSIBLE_ROLE_SCROLLBAR GTK_ACCESSIBLE_ROLE_SEARCH GTK_ACCESSIBLE_ROLE_SEARCH_BOX GTK_ACCESSIBLE_ROLE_SECTION GTK_ACCESSIBLE_ROLE_SECTION_HEAD GTK_ACCESSIBLE_ROLE_SELECT GTK_ACCESSIBLE_ROLE_SEPARATOR GTK_ACCESSIBLE_ROLE_SLIDER GTK_ACCESSIBLE_ROLE_SPIN_BUTTON GTK_ACCESSIBLE_ROLE_STATUS GTK_ACCESSIBLE_ROLE_STRUCTURE GTK_ACCESSIBLE_ROLE_SWITCH GTK_ACCESSIBLE_ROLE_TAB GTK_ACCESSIBLE_ROLE_TABLE GTK_ACCESSIBLE_ROLE_TAB_LIST GTK_ACCESSIBLE_ROLE_TAB_PANEL GTK_ACCESSIBLE_ROLE_TEXT_BOX GTK_ACCESSIBLE_ROLE_TIME GTK_ACCESSIBLE_ROLE_TIMER GTK_ACCESSIBLE_ROLE_TOOLBAR GTK_ACCESSIBLE_ROLE_TOOLTIP GTK_ACCESSIBLE_ROLE_TREE GTK_ACCESSIBLE_ROLE_TREE_GRID GTK_ACCESSIBLE_ROLE_TREE_ITEM GTK_ACCESSIBLE_ROLE_WIDGET GTK_ACCESSIBLE_ROLE_WINDOW 
>;

enum GtkAccessibleSort is export <
  GTK_ACCESSIBLE_SORT_NONE GTK_ACCESSIBLE_SORT_ASCENDING GTK_ACCESSIBLE_SORT_DESCENDING GTK_ACCESSIBLE_SORT_OTHER 
>;

enum GtkAccessibleState is export <
  GTK_ACCESSIBLE_STATE_BUSY GTK_ACCESSIBLE_STATE_CHECKED GTK_ACCESSIBLE_STATE_DISABLED GTK_ACCESSIBLE_STATE_EXPANDED GTK_ACCESSIBLE_STATE_HIDDEN GTK_ACCESSIBLE_STATE_INVALID GTK_ACCESSIBLE_STATE_PRESSED GTK_ACCESSIBLE_STATE_SELECTED 
>;

enum GtkAccessibleTristate is export <
  GTK_ACCESSIBLE_TRISTATE_FALSE GTK_ACCESSIBLE_TRISTATE_TRUE GTK_ACCESSIBLE_TRISTATE_MIXED 
>;

enum GtkAlign is export <
  GTK_ALIGN_FILL GTK_ALIGN_START GTK_ALIGN_END GTK_ALIGN_CENTER GTK_ALIGN_BASELINE 
>;

enum GtkArrowType is export <
  GTK_ARROW_UP GTK_ARROW_DOWN GTK_ARROW_LEFT GTK_ARROW_RIGHT GTK_ARROW_NONE 
>;

enum GtkBaselinePosition is export <
  GTK_BASELINE_POSITION_TOP GTK_BASELINE_POSITION_CENTER GTK_BASELINE_POSITION_BOTTOM 
>;

enum GtkBorderStyle is export <
  GTK_BORDER_STYLE_NONE GTK_BORDER_STYLE_HIDDEN GTK_BORDER_STYLE_SOLID GTK_BORDER_STYLE_INSET GTK_BORDER_STYLE_OUTSET GTK_BORDER_STYLE_DOTTED GTK_BORDER_STYLE_DASHED GTK_BORDER_STYLE_DOUBLE GTK_BORDER_STYLE_GROOVE GTK_BORDER_STYLE_RIDGE 
>;

enum GtkConstraintAttribute is export <
  GTK_CONSTRAINT_ATTRIBUTE_NONE GTK_CONSTRAINT_ATTRIBUTE_LEFT GTK_CONSTRAINT_ATTRIBUTE_RIGHT GTK_CONSTRAINT_ATTRIBUTE_TOP GTK_CONSTRAINT_ATTRIBUTE_BOTTOM GTK_CONSTRAINT_ATTRIBUTE_START GTK_CONSTRAINT_ATTRIBUTE_END GTK_CONSTRAINT_ATTRIBUTE_WIDTH GTK_CONSTRAINT_ATTRIBUTE_HEIGHT GTK_CONSTRAINT_ATTRIBUTE_CENTER_X GTK_CONSTRAINT_ATTRIBUTE_CENTER_Y GTK_CONSTRAINT_ATTRIBUTE_BASELINE 
>;

enum GtkConstraintRelation is export <
  GTK_CONSTRAINT_RELATION_LE GTK_CONSTRAINT_RELATION_EQ GTK_CONSTRAINT_RELATION_GE 
>;

enum GtkConstraintStrength is export <
  GTK_CONSTRAINT_STRENGTH_REQUIRED GTK_CONSTRAINT_STRENGTH_STRONG GTK_CONSTRAINT_STRENGTH_MEDIUM GTK_CONSTRAINT_STRENGTH_WEAK 
>;

enum GtkConstraintVflParserError is export <
  GTK_CONSTRAINT_VFL_PARSER_ERROR_INVALID_SYMBOL GTK_CONSTRAINT_VFL_PARSER_ERROR_INVALID_ATTRIBUTE GTK_CONSTRAINT_VFL_PARSER_ERROR_INVALID_VIEW GTK_CONSTRAINT_VFL_PARSER_ERROR_INVALID_METRIC GTK_CONSTRAINT_VFL_PARSER_ERROR_INVALID_PRIORITY GTK_CONSTRAINT_VFL_PARSER_ERROR_INVALID_RELATION 
>;

enum GtkDeleteType is export <
  GTK_DELETE_CHARS GTK_DELETE_WORD_ENDS GTK_DELETE_WORDS GTK_DELETE_DISPLAY_LINES GTK_DELETE_DISPLAY_LINE_ENDS GTK_DELETE_PARAGRAPH_ENDS GTK_DELETE_PARAGRAPHS GTK_DELETE_WHITESPACE 
>;

enum GtkDirectionType is export <
  GTK_DIR_TAB_FORWARD GTK_DIR_TAB_BACKWARD GTK_DIR_UP GTK_DIR_DOWN GTK_DIR_LEFT GTK_DIR_RIGHT 
>;

enum GtkEventSequenceState is export <
  GTK_EVENT_SEQUENCE_NONE GTK_EVENT_SEQUENCE_CLAIMED GTK_EVENT_SEQUENCE_DENIED 
>;

enum GtkIconSize is export <
  GTK_ICON_SIZE_INHERIT GTK_ICON_SIZE_NORMAL GTK_ICON_SIZE_LARGE 
>;

enum GtkInputPurpose is export <
  GTK_INPUT_PURPOSE_FREE_FORM GTK_INPUT_PURPOSE_ALPHA GTK_INPUT_PURPOSE_DIGITS GTK_INPUT_PURPOSE_NUMBER GTK_INPUT_PURPOSE_PHONE GTK_INPUT_PURPOSE_URL GTK_INPUT_PURPOSE_EMAIL GTK_INPUT_PURPOSE_NAME GTK_INPUT_PURPOSE_PASSWORD GTK_INPUT_PURPOSE_PIN GTK_INPUT_PURPOSE_TERMINAL 
>;

enum GtkJustification is export <
  GTK_JUSTIFY_LEFT GTK_JUSTIFY_RIGHT GTK_JUSTIFY_CENTER GTK_JUSTIFY_FILL 
>;

enum GtkLevelBarMode is export <
  GTK_LEVEL_BAR_MODE_CONTINUOUS GTK_LEVEL_BAR_MODE_DISCRETE 
>;

enum GtkMessageType is export <
  GTK_MESSAGE_INFO GTK_MESSAGE_WARNING GTK_MESSAGE_QUESTION GTK_MESSAGE_ERROR GTK_MESSAGE_OTHER 
>;

enum GtkMovementStep is export <
  GTK_MOVEMENT_LOGICAL_POSITIONS GTK_MOVEMENT_VISUAL_POSITIONS GTK_MOVEMENT_WORDS GTK_MOVEMENT_DISPLAY_LINES GTK_MOVEMENT_DISPLAY_LINE_ENDS GTK_MOVEMENT_PARAGRAPHS GTK_MOVEMENT_PARAGRAPH_ENDS GTK_MOVEMENT_PAGES GTK_MOVEMENT_BUFFER_ENDS GTK_MOVEMENT_HORIZONTAL_PAGES 
>;

enum GtkNaturalWrapMode is export <
  GTK_NATURAL_WRAP_INHERIT GTK_NATURAL_WRAP_NONE GTK_NATURAL_WRAP_WORD 
>;

enum GtkNumberUpLayout is export <
  GTK_NUMBER_UP_LAYOUT_LEFT_TO_RIGHT_TOP_TO_BOTTOM GTK_NUMBER_UP_LAYOUT_LEFT_TO_RIGHT_BOTTOM_TO_TOP GTK_NUMBER_UP_LAYOUT_RIGHT_TO_LEFT_TOP_TO_BOTTOM GTK_NUMBER_UP_LAYOUT_RIGHT_TO_LEFT_BOTTOM_TO_TOP GTK_NUMBER_UP_LAYOUT_TOP_TO_BOTTOM_LEFT_TO_RIGHT GTK_NUMBER_UP_LAYOUT_TOP_TO_BOTTOM_RIGHT_TO_LEFT GTK_NUMBER_UP_LAYOUT_BOTTOM_TO_TOP_LEFT_TO_RIGHT GTK_NUMBER_UP_LAYOUT_BOTTOM_TO_TOP_RIGHT_TO_LEFT 
>;

enum GtkOrdering is export <
  GTK_ORDERING_SMALLER GTK_ORDERING_EQUAL GTK_ORDERING_LARGER 
>;

enum GtkOrientation is export <
  GTK_ORIENTATION_HORIZONTAL GTK_ORIENTATION_VERTICAL 
>;

enum GtkOverflow is export <
  GTK_OVERFLOW_VISIBLE GTK_OVERFLOW_HIDDEN 
>;

enum GtkPackType is export <
  GTK_PACK_START GTK_PACK_END 
>;

enum GtkPageOrientation is export <
  GTK_PAGE_ORIENTATION_PORTRAIT GTK_PAGE_ORIENTATION_LANDSCAPE GTK_PAGE_ORIENTATION_REVERSE_PORTRAIT GTK_PAGE_ORIENTATION_REVERSE_LANDSCAPE 
>;

enum GtkPageSet is export <
  GTK_PAGE_SET_ALL GTK_PAGE_SET_EVEN GTK_PAGE_SET_ODD 
>;

enum GtkPanDirection is export <
  GTK_PAN_DIRECTION_LEFT GTK_PAN_DIRECTION_RIGHT GTK_PAN_DIRECTION_UP GTK_PAN_DIRECTION_DOWN 
>;

enum GtkPositionType is export <
  GTK_POS_LEFT GTK_POS_RIGHT GTK_POS_TOP GTK_POS_BOTTOM 
>;

enum GtkPrintDuplex is export <
  GTK_PRINT_DUPLEX_SIMPLEX GTK_PRINT_DUPLEX_HORIZONTAL GTK_PRINT_DUPLEX_VERTICAL 
>;

enum GtkPrintPages is export <
  GTK_PRINT_PAGES_ALL GTK_PRINT_PAGES_CURRENT GTK_PRINT_PAGES_RANGES GTK_PRINT_PAGES_SELECTION 
>;

enum GtkPrintQuality is export <
  GTK_PRINT_QUALITY_LOW GTK_PRINT_QUALITY_NORMAL GTK_PRINT_QUALITY_HIGH GTK_PRINT_QUALITY_DRAFT 
>;

enum GtkPropagationLimit is export <
  GTK_LIMIT_NONE GTK_LIMIT_SAME_NATIVE 
>;

enum GtkPropagationPhase is export <
  GTK_PHASE_NONE GTK_PHASE_CAPTURE GTK_PHASE_BUBBLE GTK_PHASE_TARGET 
>;

enum GtkScrollStep is export <
  GTK_SCROLL_STEPS GTK_SCROLL_PAGES GTK_SCROLL_ENDS GTK_SCROLL_HORIZONTAL_STEPS GTK_SCROLL_HORIZONTAL_PAGES GTK_SCROLL_HORIZONTAL_ENDS 
>;

enum GtkScrollType is export <
  GTK_SCROLL_NONE GTK_SCROLL_JUMP GTK_SCROLL_STEP_BACKWARD GTK_SCROLL_STEP_FORWARD GTK_SCROLL_PAGE_BACKWARD GTK_SCROLL_PAGE_FORWARD GTK_SCROLL_STEP_UP GTK_SCROLL_STEP_DOWN GTK_SCROLL_PAGE_UP GTK_SCROLL_PAGE_DOWN GTK_SCROLL_STEP_LEFT GTK_SCROLL_STEP_RIGHT GTK_SCROLL_PAGE_LEFT GTK_SCROLL_PAGE_RIGHT GTK_SCROLL_START GTK_SCROLL_END 
>;

enum GtkScrollablePolicy is export <
  GTK_SCROLL_MINIMUM GTK_SCROLL_NATURAL 
>;

enum GtkSelectionMode is export <
  GTK_SELECTION_NONE GTK_SELECTION_SINGLE GTK_SELECTION_BROWSE GTK_SELECTION_MULTIPLE 
>;

enum GtkSensitivityType is export <
  GTK_SENSITIVITY_AUTO GTK_SENSITIVITY_ON GTK_SENSITIVITY_OFF 
>;

enum GtkShortcutScope is export <
  GTK_SHORTCUT_SCOPE_LOCAL GTK_SHORTCUT_SCOPE_MANAGED GTK_SHORTCUT_SCOPE_GLOBAL 
>;

enum GtkSizeGroupMode is export <
  GTK_SIZE_GROUP_NONE GTK_SIZE_GROUP_HORIZONTAL GTK_SIZE_GROUP_VERTICAL GTK_SIZE_GROUP_BOTH 
>;

enum GtkSizeRequestMode is export <
  GTK_SIZE_REQUEST_HEIGHT_FOR_WIDTH GTK_SIZE_REQUEST_WIDTH_FOR_HEIGHT GTK_SIZE_REQUEST_CONSTANT_SIZE 
>;

enum GtkSortType is export <
  GTK_SORT_ASCENDING GTK_SORT_DESCENDING 
>;

enum GtkSymbolicColor is export <
  GTK_SYMBOLIC_COLOR_FOREGROUND GTK_SYMBOLIC_COLOR_ERROR GTK_SYMBOLIC_COLOR_WARNING GTK_SYMBOLIC_COLOR_SUCCESS 
>;

enum GtkSystemSetting is export <
  GTK_SYSTEM_SETTING_DPI GTK_SYSTEM_SETTING_FONT_NAME GTK_SYSTEM_SETTING_FONT_CONFIG GTK_SYSTEM_SETTING_DISPLAY GTK_SYSTEM_SETTING_ICON_THEME 
>;

enum GtkTextDirection is export <
  GTK_TEXT_DIR_NONE GTK_TEXT_DIR_LTR GTK_TEXT_DIR_RTL 
>;

enum GtkTreeViewGridLines is export <
  GTK_TREE_VIEW_GRID_LINES_NONE GTK_TREE_VIEW_GRID_LINES_HORIZONTAL GTK_TREE_VIEW_GRID_LINES_VERTICAL GTK_TREE_VIEW_GRID_LINES_BOTH 
>;

enum GtkUnit is export <
  GTK_UNIT_NONE GTK_UNIT_POINTS GTK_UNIT_INCH GTK_UNIT_MM 
>;

enum GtkWrapMode is export <
  GTK_WRAP_NONE GTK_WRAP_CHAR GTK_WRAP_WORD GTK_WRAP_WORD_CHAR 
>;

#-------------------------------------------------------------------------------
#--[Constants]------------------------------------------------------------------
#-------------------------------------------------------------------------------
constant GTK_ACCESSIBLE_VALUE_UNDEFINED is export = -1;

#-------------------------------------------------------------------------------
#--[Bitfields]------------------------------------------------------------------
#-------------------------------------------------------------------------------
enum GtkInputHints is export (
  :GTK_INPUT_HINT_NONE(0), :GTK_INPUT_HINT_SPELLCHECK(1), :GTK_INPUT_HINT_NO_SPELLCHECK(2), :GTK_INPUT_HINT_WORD_COMPLETION(4), :GTK_INPUT_HINT_LOWERCASE(8), :GTK_INPUT_HINT_UPPERCASE_CHARS(16), :GTK_INPUT_HINT_UPPERCASE_WORDS(32), :GTK_INPUT_HINT_UPPERCASE_SENTENCES(64), :GTK_INPUT_HINT_INHIBIT_OSK(128), :GTK_INPUT_HINT_VERTICAL_WRITING(256), :GTK_INPUT_HINT_EMOJI(512), :GTK_INPUT_HINT_NO_EMOJI(1024), :GTK_INPUT_HINT_PRIVATE(2048)
);

enum GtkPickFlags is export (
  :GTK_PICK_DEFAULT(0), :GTK_PICK_INSENSITIVE(1), :GTK_PICK_NON_TARGETABLE(2)
);

enum GtkStateFlags is export (
  :GTK_STATE_FLAG_NORMAL(0), :GTK_STATE_FLAG_ACTIVE(1), :GTK_STATE_FLAG_PRELIGHT(2), :GTK_STATE_FLAG_SELECTED(4), :GTK_STATE_FLAG_INSENSITIVE(8), :GTK_STATE_FLAG_INCONSISTENT(16), :GTK_STATE_FLAG_FOCUSED(32), :GTK_STATE_FLAG_BACKDROP(64), :GTK_STATE_FLAG_DIR_LTR(128), :GTK_STATE_FLAG_DIR_RTL(256), :GTK_STATE_FLAG_LINK(512), :GTK_STATE_FLAG_VISITED(1024), :GTK_STATE_FLAG_CHECKED(2048), :GTK_STATE_FLAG_DROP_ACTIVE(4096), :GTK_STATE_FLAG_FOCUS_VISIBLE(8192), :GTK_STATE_FLAG_FOCUS_WITHIN(16384)
);


