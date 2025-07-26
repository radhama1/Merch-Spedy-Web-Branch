/*
// default style of the editor defined in htmledit.js
// uncomment this code to change the default layout
g_arrHeEditorStyles["default"]={
		// content of font drop down list box
		fontList:[
			"Arial", "Tahoma", "Verdana", "Times New Roman", 
			"Georgia", "Courier New", "Courier", 
			"Serif", "Sans-Serif", "Monospace"
		],
		// content of symbol drop down list box
		symbolList:[
			"&cent;", "&pound;", "&yen;", "&copy;" ,
			"&laquo;", "&reg;", "&deg;", "&plusmn;",
			"&micro;", "&para;", "&middot;", "&ordm;",
			"&raquo;", "&frac14;", "&frac12;", "&frac34;"
		],
		// content of paragraph drop down list box
		// you can specify the class attribute for a paragraph by:
		// 	{tag:"P",className:"bold",title:"Paragraph (Bold)"},
		paragraphList:[
		    {tag:"P",title:g_strHeTextStyleParagraph},
		    {tag:"PRE",title:g_strHeTextStylePreformatted},
		    {tag:"H1",title:g_strHeTextStyleHeader1},
		    {tag:"H2",title:g_strHeTextStyleHeader2},
		    {tag:"H3",title:g_strHeTextStyleHeader3},
		    {tag:"H4",title:g_strHeTextStyleHeader4},
		    {tag:"H5",title:g_strHeTextStyleHeader5},
		    {tag:"H6",title:g_strHeTextStyleHeader6}
	    ],
		// toolbar buttons. It is an array of arrays. Each subarray contains strings
		// that represent which button or drop down list box to display. Each subarray
		// represents a subtoolbar and editor will not break it into two lines during
		// layouting.
		toolbarBtns:[
			["New","Save","Sep","Copy","Cut","Paste","PastePlainText","PasteFromWord","Undo","Redo"],
			["TextColor","HighlightColor","Bold","Italic","Underline","Strike","Superscript","Subscript","Small","Big"],
			["Outdent","Indent","NumberList","BulletList", "LeftAlign","CenterAlign","RightAlign","JustifyAlign"],
			["Hyperlink","HorizontalLine","InsertTable","ShowHideBorder","InsertImage","InsertSymbol","ShowHideSource"],
			["CustomBtn0","CustomBtn1","CustomBtn2","CustomBtn3","CustomBtn4"],
			["ParagraphBox","SizeBox","FontBox","StyleBox"]
		],
		lFlags:g_lHeCModeFormElement | g_lHeCDisableStatusBar | g_lHeCBorder | g_lHeCToTextIfFail,
		strWidth:'100%',
		strHeight:'100px',
		lMarginWidth:5,
		lMarginHeight:5,
		strBaseHref:""
	}
*/

// definition for a simple editor
g_arrHeEditorStyles["simple"]={
		fontList:[
			"Arial", "Tahoma", "Verdana", "Times New Roman", 
			"Georgia", "Courier New", "Courier", 
			"Serif", "Sans-Serif", "Monospace"
		],
		paragraphList:[
		    {tag:"P",title:g_strHeTextStyleParagraph},
		    {tag:"PRE",title:g_strHeTextStylePreformatted},
		    {tag:"H1",title:g_strHeTextStyleHeader1},
		    {tag:"H2",title:g_strHeTextStyleHeader2},
		    {tag:"H3",title:g_strHeTextStyleHeader3},
		    {tag:"H4",title:g_strHeTextStyleHeader4},
		    {tag:"H5",title:g_strHeTextStyleHeader5},
		    {tag:"H6",title:g_strHeTextStyleHeader6}
	    ],
		toolbarBtns:[
			["New","Save"],
			["TextColor","HighlightColor","Bold","Italic","Underline"],
			["Outdent","Indent","NumberList","BulletList"],
			["LeftAlign","CenterAlign","RightAlign","JustifyAlign"],
			["Hyperlink","HorizontalLine","InsertImage","InsertSymbol","ShowHideSource"],
			["CustomBtn0","CustomBtn1","CustomBtn2","CustomBtn3","CustomBtn4"]
		],
		lFlags:g_lHeCModeFormElement | g_lHeCDisableStatusBar | g_lHeCBorder | g_lHeCToTextIfFail,
		strWidth:'100%',
		strHeight:'100px',
		lMarginWidth:5,
		lMarginHeight:5,
		strBaseHref:""
	}

// sample class demonstrates how to override fontList and paragraphList
// you can delete the following section if you do not need it

function HtmlEditDemoCustom1(eventObj) {
	alert("This is a sample custom button")
	HtmlEditFocus(eventObj.editorId)
}

g_arrHeEditorStyles["example"]={
		fontList:[
			"Arial", "Times New Roman", "Courier New"
		],
		paragraphList:[
		    {tag:"P",title:g_strHeTextStyleParagraph},
			{tag:"P",className:"bold",title:"Paragraph (Bold)"},
		    {tag:"PRE",title:g_strHeTextStylePreformatted},
		    {tag:"H1",title:g_strHeTextStyleHeader1},
		    {tag:"H2",title:g_strHeTextStyleHeader2},
		    {tag:"H3",title:g_strHeTextStyleHeader3},
		    {tag:"H4",title:g_strHeTextStyleHeader4},
		    {tag:"H5",title:g_strHeTextStyleHeader5},
		    {tag:"H6",title:g_strHeTextStyleHeader6}
	    ],
		toolbarBtns:[
			["New","Save","Sep","Copy","Cut","Paste","Undo","Redo"],
			["ParagraphBox","SizeBox","FontBox","StyleBox"],
			["TextColor","HighlightColor","Bold","Italic","Underline","Strike","Superscript","Subscript","Small","Big"],
			["Outdent","Indent","NumberList","BulletList"],
			["LeftAlign","CenterAlign","RightAlign","JustifyAlign"],
			["Hyperlink","HorizontalLine","InsertTable","ShowHideBorder","InsertImage","InsertSymbol","ShowHideSource"],
			["CustomBtn0","CustomBtn1","CustomBtn2","CustomBtn3","CustomBtn4"]
		],
		lFlags:g_lHeCModeFormElement | g_lHeCDisableStatusBar | g_lHeCBorder | g_lHeCToTextIfFail,
		strWidth:'100%',
		strHeight:'100px',
		lMarginWidth:5,
		lMarginHeight:5,
		strBaseHref:"",
		strCssStyle:"../style.css",
		customBtns:[
			{
			title:"Custom Button",
			funcname:"HtmlEditDemoCustom1",
			imgname:"10101.gif"}
			]
	}
	