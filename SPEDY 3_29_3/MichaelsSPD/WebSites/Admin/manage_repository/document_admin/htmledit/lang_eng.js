/*
if g_lHeCEnumSysFonts flag is specified when creating the control, only fonts with the matching character set
will be used. Specify the required charset number in g_lHeCharset. This variable controls the font enumeration
only. You have to specify
0 ANSI_CHARSET
1 DEFAULT_CHARSET
2 SYMBOL_CHARSET
128 SHIFTJIS_CHARSET
129 HANGEUL_CHARSET
129 HANGUL_CHARSET
134 GB2312_CHARSET
136 CHINESEBIG5_CHARSET
255 OEM_CHARSET
77 MAC_CHARSET
130 JOHAB_CHARSET
161 GREEK_CHARSET
162 TURKISH_CHARSET
163 VIETNAMESE_CHARSET
177 HEBREW_CHARSET
178 ARABIC_CHARSET
186 BALTIC_CHARSET
204 RUSSIAN_CHARSET
222 THAI_CHARSET
238 EASTEUROPE_CHARSET
*/

var g_lHeCharset = 0

/* list of characters/strings displayed in the "Insert Character" drop down list box. */
var g_arrHeCharacterList = new Array(
    "&cent;", "&pound;", "&yen;", "&copy;" ,
    "&laquo;", "&reg;", "&deg;", "&plusmn;",
    "&micro;", "&para;", "&middot;", "&ordm;",
    "&raquo;", "&frac14;", "&frac12;", "&frac34;");
	
var g_strHeTextParagraphStyle = "-- Paragraph --"
var g_strHeTextFontSize = "-- Size --"
var g_strHeTextForeColor = "Change Foreground Color"
var g_strHeTextBackColor = "Change Background Color"
var g_strHeTextBold = "Bold"
var g_strHeTextItalic = "Italic"
var g_strHeTextUnderline = "Underline"
var g_strHeTextStrikeThru = "Strike Thru"
var g_strHeTextSuperscript = "Superscript"
var g_strHeTextSubscript = "Subscript"
var g_strHeTextHyperlink = "Hyperlink"
var g_strHeTextHTMLSource = "HTML Source"
var g_strHeTextCut = "Cut"
var g_strHeTextCopy = "Copy"
var g_strHeTextPaste = "Paste"
var g_strHeTextDelete = "Delete"
var g_strHeTextSelectAll = "Select All"
var g_strHeTextUndo = "Undo"
var g_strHeTextRedo = "Redo"
var g_strHeTextUnindent = "Unindent"
var g_strHeTextIndent = "Indent"
var g_strHeTextNumList = "Number List"
var g_strHeTextBullList = "Bullet List"
var g_strHeTextLeftAlign = "Left Alignment"
var g_strHeTextRightAlign = "Right Alignment"
var g_strHeTextCenterAlign = "Center Alignment"
var g_strHeTextJustifyAlign = "Justify Alignment"
var g_strHeTextHorzLine = "Insert horizontal line"
var g_strHeTextTable = "Insert Table"
var g_strHeTextImage = "Insert Image"
var g_strHeTextSymbol = "Insert Symbol"
var g_strHeTextChars = " char(s)"
var g_strHeTextInsert = "INS"
var g_strHeTextOverwrite = "OVR"
var g_strHeTextRemoveFormats = "Remove Formats"
var g_strHeTextRemoveLink = "Remove Link"
var g_strHeTextInsColBefore = "Insert column before"
var g_strHeTextInsColAfter = "Insert column after"
var g_strHeTextInsRowAbove = "Insert row above"
var g_strHeTextInsRowBelow = "Insert row below"
var g_strHeTextDelCol = "Delete column"
var g_strHeTextDelRow = "Delete row"
var g_strHeTextTableProp = "Table properties"
var g_strHeTextCellProp = "Cell properties"
var g_strHeTextImageProp = "Image properties"
var g_strHeTextOk = "Ok"
var g_strHeTextCancel = "Cancel"
var g_strHeTextColumns = "Columns: "
var g_strHeTextRows = "Rows: "
var g_strHeTextTableWidth = "Table Width: "
var g_strHeTextBorderWidth = "Border Width: "
var g_strHeTextCellPadding = "Cell Padding: "
var g_strHeTextCellSpacing = "Cell Spacing: "
var g_strHeTextBackgroundColor = "Background Color: "
var g_strHeTextBorderColor = "Border Color"
var g_strHeTextHtmlTable = "HTML Table"
var g_strHeTextEnterValidNum = "Please enter valid number!"
var g_strHeTextEnterRows = "Please specify a value for rows."
var g_strHeTextEnterCols = "Please specify a value for columns."
var g_strHeTextColorDlg = "Color Dialog"
var g_strHeTextSelection = "Selection: "
var g_strHeTextRow = "Row"
var g_strHeTextCell = "Cell"
var g_strHeTextColumn = "Column"
var g_strHeTextCellWidth = "Cell Width: "
var g_strHeTextCellHeight = "Cell Height: "
var g_strHeTextHorzAlign = "Horizontal Alignment: "
var g_strHeTextVertAlign = "Vertical Alignment: "
var g_strHeTextLeft = "Left"
var g_strHeTextCenter = "Center"
var g_strHeTextRight = "Right"
var g_strHeTextTop = "Top"
var g_strHeTextMiddle = "Middle"
var g_strHeTextBottom = "Bottom"
var g_strHeTextImageDlg = "Image"
var g_strHeTextImageURL = "Image URL:"
var g_strHeTextImageAlignment = "Image Alignment:"
var g_strHeTextBorder = "Border:"
var g_strHeTextImageDesc = "Description of image:"
var g_strHeTextEnterImageUrl = 'Please specify the image URL.'
var g_strHeTextBrowse = "Browse"
var g_strHeTextNew = "New"
var g_strHeTextSave = "Save"
var g_strHeTextFind = "Find"
var g_strHeTextHelp = "Help"
var g_strHeTextNewMsg = "Do you want to clear all text?"
var g_strHeTextChooseFont = "-- Font --"
var g_strHeTextSource = "Source"
var g_strHeTextTableBorder = "Display Table Border"
var g_strHeTextStyle = "-- Style --"
var g_strHeTextDeleteTable = "Delete Table"
var g_strHeTextOListProp = "Ordered List Properties"
var g_strHeTextUListProp = "Unordered List Properties"
var g_strHeTextListType = "List Type"
var g_strHeTextAutomatic = "Automatic"
var g_strHeTextMsgValidURL = "Please enter a valid URL."
var g_strHeTextDisc = "Disc"
var g_strHeTextCircle = "Circle"
var g_strHeTextSquare = "Square"
// after 3.00pre4.2
var g_strHeTextStyleParagraph = "Paragraph"
var g_strHeTextStylePreformatted = "Preformatted"
var g_strHeTextStyleHeader1 = "Header 1"
var g_strHeTextStyleHeader2 = "Header 2"
var g_strHeTextStyleHeader3 = "Header 3"
var g_strHeTextStyleHeader4 = "Header 4"
var g_strHeTextStyleHeader5 = "Header 5"
var g_strHeTextStyleHeader6 = "Header 6"
var g_strHeTextPageTitle = "Page Title: "
var g_strHeTextTextColor = "Text Color: "
var g_strHeTextHyperlinkColor = "Hyperlink Color: "
var g_strHeTextActiveLinkColor = "Active Link Color: "
var g_strHeTextVisitedLinkColor = "Visited Link Color: "
var g_strHeTextPageProperties = "Page Properties"
// added for 3.01
var g_strHeTextUrl = "URL: "
var g_strHeTextTarget = "Target: "
// added for 3.08
var g_strHeTextMarginWidth = "Margin Width: "
var g_strHeTextMarginHeight = "Margin Height: "
// added for 3.10
var g_strHeTextRemoveAllFormats = "Remove All Formats"
// added for 3.12
var g_strHeTextIncreaseFontSize="Increase font size"
var g_strHeTextDecreaseFontSize="Decrease font size"
// added for 3.13
var g_strHeTextPastePlainText="Paste Plain Text"
var g_strHeTextPasteFromWord="Paste From Word"
var g_strHePastePlainTextMsg="Use ctrl+V on your keyboard to paste the text into following area:"
var g_strHePasteFromWordMsg="Use ctrl+V on your keyboard to paste the text into following area:"