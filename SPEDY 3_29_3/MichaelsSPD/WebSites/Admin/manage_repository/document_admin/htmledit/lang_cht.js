/*
if g_lHeCEnumSysFonts flag is specified when creating the control, only fonts with the matching character set
will be used. Specify the required charset number in g_lHeCharset.

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
204 RUSSIAN_CHARSET 222 THAI_CHARSET 
238 EASTEUROPE_CHARSET 
*/
var g_lHeCharset = 136

/* list of characters/strings displayed in the "Insert Character" drop down list box. */
var g_arrHeCharacterList = new Array(
    "&cent;", "&pound;", "&yen;", "&copy;" ,
    "&laquo;", "&reg;", "&deg;", "&plusmn;",
    "&micro;", "&para;", "&middot;", "&ordm;",
    "&raquo;", "&frac14;", "&frac12;", "&frac34;");

// followings are the text used in the editor. change them to suit your need.
var g_strHeTextParagraphStyle = "-- 字型 --"
var g_strHeTextFontSize = "-- 尺碼 --"
var g_strHeTextForeColor = "字體顏色"
var g_strHeTextBackColor = "背景顏色"
var g_strHeTextBold = "粗體"
var g_strHeTextItalic = "斜體"
var g_strHeTextUnderline = "下劃線"
var g_strHeTextStrikeThru = "橫線"
var g_strHeTextSuperscript = "上小字"
var g_strHeTextSubscript = "下小字"
var g_strHeTextHyperlink = "連結"
var g_strHeTextHTMLSource = "HTML 原案"
var g_strHeTextCut = "剪切"
var g_strHeTextCopy = "複製"
var g_strHeTextPaste = "貼上"
var g_strHeTextDelete = "清除"
var g_strHeTextSelectAll = "全部選擇"
var g_strHeTextUndo = "復原"
var g_strHeTextRedo = "重造"
var g_strHeTextUnindent = "左邊沿距"
var g_strHeTextIndent = "右邊沿距"
var g_strHeTextNumList = "數字表"
var g_strHeTextBullList = "列表"
var g_strHeTextLeftAlign = "左對齊"
var g_strHeTextRightAlign = "右對齊"
var g_strHeTextCenterAlign = "中心對齊"
var g_strHeTextJustifyAlign = "左右對齊"
var g_strHeTextHorzLine = "增加橫線"
var g_strHeTextTable = "增加表格"
var g_strHeTextImage = "增加圖片"
var g_strHeTextSymbol = "增加圖案"

var g_strHeTextChars = " 字母數目"
var g_strHeTextInsert = "插入"
var g_strHeTextOverwrite = "蓋過"

var g_strHeTextRemoveFormats = "甽除編緝"
var g_strHeTextRemoveLink = "刪除連結"

var g_strHeTextInsColBefore = "增加直行(之前)"
var g_strHeTextInsColAfter = "增加直行(之後)"
var g_strHeTextInsRowAbove = "增加橫行(之上)"
var g_strHeTextInsRowBelow = "增加橫行(之下)"
var g_strHeTextDelCol = "刪除直行"
var g_strHeTextDelRow = "刪除橫行"
var g_strHeTextTableProp = "圖表選看"
var g_strHeTextCellProp = "方格選看"
var g_strHeTextImageProp = "圖片選看"

var g_strHeTextOk = "確定"
var g_strHeTextCancel = "取消"
var g_strHeTextColumns = "直行： "
var g_strHeTextRows = "橫行： "
var g_strHeTextTableWidth = "圖表闊度： "
var g_strHeTextBorderWidth = "邊框闊度： "
var g_strHeTextCellPadding = "方格虛位： "
var g_strHeTextCellSpacing = "方格距離： "
var g_strHeTextBackgroundColor = "方格背景顏色："
var g_strHeTextBorderColor = "邊框顏色"
var g_strHeTextHtmlTable = "HTML表格"

var g_strHeTextEnterValidNum = "請輸入正確的號碼!"
var g_strHeTextEnterRows = "請輸入正確的橫行數目."
var g_strHeTextEnterCols = "請輸入正確的直行數目."

var g_strHeTextColorDlg = "顏色表格"
var g_strHeTextSelection = "選項： "
var g_strHeTextRow = "一橫行"
var g_strHeTextCell = "一方格"
var g_strHeTextColumn = "一直行"
var g_strHeTextCellWidth = "方格闊度："
var g_strHeTextCellHeight = "方格高度："
var g_strHeTextHorzAlign = "橫向排列："
var g_strHeTextVertAlign = "直向排列："
var g_strHeTextLeft = "左"
var g_strHeTextCenter = "中"
var g_strHeTextRight = "右"
var g_strHeTextTop = "上"
var g_strHeTextMiddle = "中"
var g_strHeTextBottom = "下"

var g_strHeTextImageDlg = "圖片"
var g_strHeTextImageURL = "圖片綱址："
var g_strHeTextImageAlignment = "圖片排列："
var g_strHeTextBorder = "遑框："
var g_strHeTextImageDesc = "圖片介詔：<br><span class=small>當過鼠蓋過圖片的時候,這些文字將會出現.</span>"

var g_strHeTextEnterImageUrl = "請輸入正確的圖片綱址."
var g_strHeTextBrowse = "瀏灠"

var g_strHeTextNew = "清除內容"
var g_strHeTextSave = "儲存"
var g_strHeTextFind = "Find"
var g_strHeTextHelp = "Help"
var g_strHeTextNewMsg = "你是否決定清除所有內容？"
var g_strHeTextChooseFont = "-- 選擇字形 --"
var g_strHeTextSource = "Source"

var g_strHeTextTableBorder = "顯示表格遑框"
var g_strHeTextStyle = "-- 格式 --"
var g_strHeTextDeleteTable = "清除表格"
var g_strHeTextOListProp = "數字表選看"
var g_strHeTextUListProp = "列表選看"
var g_strHeTextListType = "列表種類"
var g_strHeTextAutomatic = "自動"
var g_strHeTextMsgValidURL = "請輸入正確的URL。"
var g_strHeTextDisc = "圓碟"
var g_strHeTextCircle = "圓孔"
var g_strHeTextSquare = "正方形"

// after 3.00pre4.2
var g_strHeTextStyleParagraph = "Paragraph"
var g_strHeTextStylePreformatted = "Preformatted"
var g_strHeTextStyleHeader1 = "Header 1"
var g_strHeTextStyleHeader2 = "Header 2"
var g_strHeTextStyleHeader3 = "Header 3"
var g_strHeTextStyleHeader4 = "Header 4"
var g_strHeTextStyleHeader5 = "Header 5"
var g_strHeTextStyleHeader6 = "Header 6"

var g_strHeTextPageTitle = "版面名稱： "
var g_strHeTextTextColor = "文本顏色： "
var g_strHeTextHyperlinkColor = "連結顏色： "
var g_strHeTextActiveLinkColor = "活躍連結顏色： "
var g_strHeTextVisitedLinkColor = "瀏覽連結顏色： "
var g_strHeTextPageProperties = "版面資訊"

// added for 3.01
var g_strHeTextUrl = "URL： "
var g_strHeTextTarget = "目標： "

// added for 3.08
var g_strHeTextMarginWidth = "邊際寬度： "
var g_strHeTextMarginHeight = "邊際高度： "

// added for 3.10
var g_strHeTextRemoveAllFormats = "去除所有格式"

// added for 3.12
var g_strHeTextIncreaseFontSize="增加字體大小"
var g_strHeTextDecreaseFontSize="減少字體大小"

// added for 3.13
var g_strHeTextPastePlainText="貼上純文本"
var g_strHeTextPasteFromWord="從Word貼上"
var g_strHePastePlainTextMsg="使用您的鍵盤 ctrl+V 貼上文本入以下區域："
var g_strHePasteFromWordMsg="使用您的鍵盤 ctrl+V 貼上文本入以下區域："