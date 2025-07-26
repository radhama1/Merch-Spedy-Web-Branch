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

var g_strHeTextParagraphStyle = "-- Estilo --"
var g_strHeTextFontSize = "Tama&ntilde;o fuente predet."
var g_strHeTextForeColor = "Cambiar color de la fuente"
var g_strHeTextBackColor = "Cambiar color de fondo"
var g_strHeTextBold = "Negrita"
var g_strHeTextItalic = "Cursiva"
var g_strHeTextUnderline = "Subrayado"
var g_strHeTextStrikeThru = "Tachado"
var g_strHeTextSuperscript = "Super&iacute;ndice"
var g_strHeTextSubscript = "Sub&iacute;ndice"
var g_strHeTextHyperlink = "Hiperv&iacute;nculo"
var g_strHeTextHTMLSource = "C&oacute;digo HTML"
var g_strHeTextCut = "Cortar"
var g_strHeTextCopy = "Copiar"
var g_strHeTextPaste = "Pegar"
var g_strHeTextDelete = "Borrar"
var g_strHeTextSelectAll = "Seleccionar todo"
var g_strHeTextUndo = "Deshacer"
var g_strHeTextRedo = "Rehacer"
var g_strHeTextUnindent = "No indentar"
var g_strHeTextIndent = "Indentar"
var g_strHeTextNumList = "Lista ordenada"
var g_strHeTextBullList = "Lista no ordenada"
var g_strHeTextLeftAlign = "Alineado izquierda"
var g_strHeTextRightAlign = "Alineado derecha"
var g_strHeTextCenterAlign = "Alineado centrado"
var g_strHeTextJustifyAlign = "Alineado justificado"
var g_strHeTextHorzLine = "Insertar l&iacute;nea horizontal"
var g_strHeTextTable = "Insertar tabla"
var g_strHeTextImage = "Insertar imagen"
var g_strHeTextSymbol = "Caracteres especiales"
var g_strHeTextChars = " char(s)"
var g_strHeTextInsert = "INS"
var g_strHeTextOverwrite = "SOBREESCRIBIR"
var g_strHeTextRemoveFormats = "Quitar formatos"
var g_strHeTextRemoveLink = "Quitar hiperv&iacute;nculo"
var g_strHeTextInsColBefore = "Insertar columna delante"
var g_strHeTextInsColAfter = "Insertar columna detr&aacute;s"
var g_strHeTextInsRowAbove = "Insertar fila arriba"
var g_strHeTextInsRowBelow = "Insertar fila debajo"
var g_strHeTextDelCol = "Borrar columna"
var g_strHeTextDelRow = "Borrar fila"
var g_strHeTextTableProp = "Propiedades de la tabla"
var g_strHeTextCellProp = "Propiedades de la celda"
var g_strHeTextImageProp = "Propiedades de la imagen"
var g_strHeTextOk = "Aceptar"
var g_strHeTextCancel = "Cancelar"
var g_strHeTextColumns = "Columnas: "
var g_strHeTextRows = "Filas: "
var g_strHeTextTableWidth = "Anchura de tabla: "
var g_strHeTextBorderWidth = "Anchura del borde: "
var g_strHeTextCellPadding = "Acolchado de celda: "
var g_strHeTextCellSpacing = "Espaciado de celda: "
var g_strHeTextBackgroundColor = "Color de fondo:"
var g_strHeTextBorderColor = "Color del borde"
var g_strHeTextHtmlTable = "Tabla HTML"
var g_strHeTextEnterRows = "Por favor, especifique un valor para las filas."
var g_strHeTextEnterCols = "Por favor, especifique un valor para las columnas."
var g_strHeTextColorDlg = "Selector de color"
var g_strHeTextSelection = "Selecci&oacute;n: "
var g_strHeTextRow = "Fila"
var g_strHeTextCell = "Celda"
var g_strHeTextColumn = "Columna"
var g_strHeTextCellWidth = "Anchura de celda: "
var g_strHeTextCellHeight = "Altura de celda: "
var g_strHeTextHorzAlign = "Alineamiento Horizontal: "
var g_strHeTextVertAlign = "Alineamiento Vertical: "
var g_strHeTextLeft = "Izquierda"
var g_strHeTextCenter = "Centro"
var g_strHeTextRight = "Derecha"
var g_strHeTextTop = "Arriba"
var g_strHeTextMiddle = "En medio"
var g_strHeTextBottom = "Al Fondo"
var g_strHeTextImageDlg = "Imagen"
var g_strHeTextImageURL = "URL de la imagen:"
var g_strHeTextImageAlignment = "Alineaci&oacute;n de la imagen:"
var g_strHeTextBorder = "Borde:"
var g_strHeTextImageDesc = "Descripci&oacute;n de imagen:<br><span class=small>Aparecer&aacute; al posicionarse el cursor sobre la imagen.</span>"
var g_strHeTextEnterImageUrl = 'Por favor, especificar la URL de la imagen.'
var g_strHeTextBrowse = "Navegar"
var g_strHeTextNew = "Nuevo"
var g_strHeTextSave = "Guardar"
var g_strHeTextFind = "Buscar"
var g_strHeTextHelp = "Ayuda"
var g_strHeTextChooseFont = "Fuente predet."
var g_strHeTextSource = "C&oacute;digo fuente"
var g_strHeTextTableBorder = "Ver el borde de la tabla"
var g_strHeTextStyle = "-- Estilo --"
var g_strHeTextDeleteTable = "Borrar tabla"
var g_strHeTextOListProp = "Lista ordenada de propiedades"
var g_strHeTextUListProp = "Lista no ordenada de propiedades"
var g_strHeTextListType = "Tipo de lista"
var g_strHeTextAutomatic = "Autom&aacute;tico"
var g_strHeTextMsgValidURL = "Por favor, introduzca una URL v&aacute;lida."
var g_strHeTextDisc = "Disco"
var g_strHeTextCircle = "C&iacute;rculo"
var g_strHeTextSquare = "Cuadrado"
// after 3.00pre4.2
var g_strHeTextStyleParagraph = "P&aacute;rrafo"
var g_strHeTextStylePreformatted = "Preformateado"
var g_strHeTextStyleHeader1 = "Encabezado 1"
var g_strHeTextStyleHeader2 = "Encabezado 2"
var g_strHeTextStyleHeader3 = "Encabezado 3"
var g_strHeTextStyleHeader4 = "Encabezado 4"
var g_strHeTextStyleHeader5 = "Encabezado 5"
var g_strHeTextStyleHeader6 = "Encabezado 6"
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