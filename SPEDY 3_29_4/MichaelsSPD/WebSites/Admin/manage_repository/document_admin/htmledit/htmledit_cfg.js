// theme file name
var g_strHtmlEditThemeUrl = "theme_crystal.js"

// url of image browser script.
// please use the correct version for your web server
//var g_strHtmlEditImgUrl = "upload/browseimages2.php"
var g_strHtmlEditImgUrl = "upload/browseimages2.asp"

var g_strHtmlEditLangFile = "lang_eng.js"

// timeout value for loading the blank page in seconds.
// the editor is actually an iframe and it may load a blank page
var g_lTimeOutBlank=5

// timeout value for loading remote HTML page
var g_lTimeOutPage=30

// timeout value for loading external stylesheet
var g_lTimeOutCss=5

// whether using the new combined dialog for insert image dialog box
// old code may want to set this parameter to false
var g_bMergedImageDialog = true

// deprecated variable
var g_lSymbolMenuWidth=50

// styles used by the editing area
var g_arrHtmlEditStyles={
	// default styles of editing area
	basicHtml:["body","font-family:arial, helvetica, sans-serif;font-size: 10pt;"],
	// default styles when editing HTML source
	basicSource:[
   		["body","font-family:lucida console, courier, monospace;font-size: 9pt;"],
		["p","padding: 0px; margin: 0px;"]
		],
	// used to display TABLE guideline
	tableBorder:[
		["table","border:1px dotted black;"],
		["td","border:1px dotted black;"],
		["th","border:1px dotted black;"]
		]
	}
