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
var g_lHeCharset = 134

/* list of characters/strings displayed in the "Insert Character" drop down list box. */
var g_arrHeCharacterList = new Array(
    "&cent;", "&pound;", "&yen;", "&copy;" ,
    "&laquo;", "&reg;", "&deg;", "&plusmn;",
    "&micro;", "&para;", "&middot;", "&ordm;",
    "&raquo;", "&frac14;", "&frac12;", "&frac34;");

// followings are the text used in the editor. change them to suit your need.
var g_strHeTextParagraphStyle = "-- 字型 --"
var g_strHeTextFontSize = "-- 尺码 --"
var g_strHeTextForeColor = "字体颜色"
var g_strHeTextBackColor = "背景颜色"
var g_strHeTextBold = "粗体"
var g_strHeTextItalic = "斜体"
var g_strHeTextUnderline = "下划线"
var g_strHeTextStrikeThru = "横线"
var g_strHeTextSuperscript = "上小字"
var g_strHeTextSubscript = "下小字"
var g_strHeTextHyperlink = "连结"
var g_strHeTextHTMLSource = "HTML 原案"
var g_strHeTextCut = "剪切"
var g_strHeTextCopy = "复制"
var g_strHeTextPaste = "贴上"
var g_strHeTextDelete = "清除"
var g_strHeTextSelectAll = "全部选择"
var g_strHeTextUndo = "复原"
var g_strHeTextRedo = "重造"
var g_strHeTextUnindent = "左边沿距"
var g_strHeTextIndent = "右边沿距"
var g_strHeTextNumList = "数字表"
var g_strHeTextBullList = "列表"
var g_strHeTextLeftAlign = "左对齐"
var g_strHeTextRightAlign = "右对齐"
var g_strHeTextCenterAlign = "中心对齐"
var g_strHeTextJustifyAlign = "左右对齐"
var g_strHeTextHorzLine = "增加横线"
var g_strHeTextTable = "增加表格"
var g_strHeTextImage = "增加图片"
var g_strHeTextSymbol = "增加图案"

var g_strHeTextChars = " 字母数目"
var g_strHeTextInsert = "插入"
var g_strHeTextOverwrite = "盖过"

var g_strHeTextRemoveFormats = "□除编缉"
var g_strHeTextRemoveLink = "删除连结"

var g_strHeTextInsColBefore = "增加直行(之前)"
var g_strHeTextInsColAfter = "增加直行(之后)"
var g_strHeTextInsRowAbove = "增加横行(之上)"
var g_strHeTextInsRowBelow = "增加横行(之下)"
var g_strHeTextDelCol = "删除直行"
var g_strHeTextDelRow = "删除横行"
var g_strHeTextTableProp = "图表选看"
var g_strHeTextCellProp = "方格选看"
var g_strHeTextImageProp = "图片选看"

var g_strHeTextOk = "确定"
var g_strHeTextCancel = "取消"
var g_strHeTextColumns = "直行: "
var g_strHeTextRows = "横行: "
var g_strHeTextTableWidth = "图表阔度: "
var g_strHeTextBorderWidth = "边框阔度: "
var g_strHeTextCellPadding = "方格虚位: "
var g_strHeTextCellSpacing = "方格距离: "
var g_strHeTextBackgroundColor = "方格背景颜色:"
var g_strHeTextBorderColor = "边框颜色"
var g_strHeTextHtmlTable = "HTML表格"

var g_strHeTextEnterValidNum = "请输入正确的号码!"
var g_strHeTextEnterRows = "请输入正确的横行数目."
var g_strHeTextEnterCols = "请输入正确的直行数目."

var g_strHeTextColorDlg = "颜色表格"
var g_strHeTextSelection = "选项: "
var g_strHeTextRow = "一横行"
var g_strHeTextCell = "一方格"
var g_strHeTextColumn = "一直行"
var g_strHeTextCellWidth = "方格阔度: "
var g_strHeTextCellHeight = "方格高度: "
var g_strHeTextHorzAlign = "横向排列: "
var g_strHeTextVertAlign = "直向排列: "
var g_strHeTextLeft = "左"
var g_strHeTextCenter = "中"
var g_strHeTextRight = "右"
var g_strHeTextTop = "上"
var g_strHeTextMiddle = "中"
var g_strHeTextBottom = "下"

var g_strHeTextImageDlg = "图片"
var g_strHeTextImageURL = "图片纲址:"
var g_strHeTextImageAlignment = "图片排列:"
var g_strHeTextBorder = "遑框:"
var g_strHeTextImageDesc = "图片介诏:<br><span class=small>当过鼠盖过图片的时候,这些文字将会出现.</span>"

var g_strHeTextEnterImageUrl = "请输入正确的图片纲址."
var g_strHeTextBrowse = "浏览"

var g_strHeTextNew = "清除内容"
var g_strHeTextSave = "储存"
var g_strHeTextFind = "Find"
var g_strHeTextHelp = "Help"
var g_strHeTextNewMsg = "你是否决定清除所有内容？"
var g_strHeTextChooseFont = "-- 选择字形 --"
var g_strHeTextSource = "Source"

var g_strHeTextTableBorder = "显示表格遑框"
var g_strHeTextStyle = "-- 格式 --"
var g_strHeTextDeleteTable = "清除表格"
var g_strHeTextOListProp = "数字表选看"
var g_strHeTextUListProp = "列表选看"
var g_strHeTextListType = "列表种类"
var g_strHeTextAutomatic = "自动"
var g_strHeTextMsgValidURL = "请输入正确的URL。"
var g_strHeTextDisc = "圆碟"
var g_strHeTextCircle = "圆孔"
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

var g_strHeTextPageTitle = "版面名称： "  
var g_strHeTextTextColor = "文本颜色： "  
var g_strHeTextHyperlinkColor = "连结颜色： "  
var g_strHeTextActiveLinkColor = "活跃连结颜色： "  
var g_strHeTextVisitedLinkColor = "浏览连结颜色： "  
var g_strHeTextPageProperties = "版面资讯"  
  
// added for 3.01  
var g_strHeTextUrl = "URL： "  
var g_strHeTextTarget = "目标： "  
  
// added for 3.08  
var g_strHeTextMarginWidth = "边际宽度： "  
var g_strHeTextMarginHeight = "边际高度： "  
 
// added for 3.10 
var g_strHeTextRemoveAllFormats = "去除所有格式"

// added for 3.12
var g_strHeTextIncreaseFontSize="增加字体大小"
var g_strHeTextDecreaseFontSize="减少字体大小"

// added for 3.13
var g_strHeTextPastePlainText="贴上纯文本"
var g_strHeTextPasteFromWord="从Word贴上"
var g_strHePastePlainTextMsg="使用您的键盘 ctrl+V 贴上文本入以下区域："
var g_strHePasteFromWordMsg="使用您的键盘 ctrl+V 贴上文本入以下区域："
