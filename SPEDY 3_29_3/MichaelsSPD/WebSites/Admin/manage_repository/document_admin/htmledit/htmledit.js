// File:            htmledit.js
// Description:     For QWebEditor
//
// Copyright (c) Q-Surf Computing Solutions, 2003-05. All rights reserved.
// http://www.qwebeditor.com

var g_strHeVersion="3.13c"
var g_lHeCModeMask=3
var g_lHeCModeFormElement=0
var g_lHeCModeStandaloneForm=1
var g_lHeCModeStandaloneDialog=2
var g_lHeCResizeToWindow=4
var g_lHeCDisableParagraph=8
var g_lHeCDisableFontSize=16
var g_lHeCDisableFontName=32
var g_lHeCDisableNewBtn=64
var g_lHeCDisableCutCopyPasteBtn=128
var g_lHeCDisableUndoRedoBtn=256
var g_lHeCDisableSourceBtn=512
var g_lHeCDisableForeColor=1024
var g_lHeCDisableBackColor=2048
var g_lHeCDisableAlignBtn=4096
var g_lHeCDisableTableBtn=8192
var g_lHeCDisableImageBtn=16384
var g_lHeCDisableStyleBox=262144
var g_lHeCEnumSysFonts=32768
var g_lHeCBorder=65536
var g_lHeCDetectPlainText=131072
var g_lHeCDisableStatusBar=524288
var g_lHeCToTextIfFail=1048576
var g_lHeCEditPage=2097152
var g_lHeCDisableFormattingBtns1=4194304
var g_lHeCDisableFormattingBtns2=8388608
var g_lHeCDisableFormattingBtns3=16777216
var g_lHeCDisableLinkBtn=33554432
var g_lHeCDisableHorizontalRuleBtn=67108864
var g_lHeCDisableSymbolBtn=134217728
var g_lHeCXHTMLSource=268435456
var g_lHeCUseDivForIE=536870912
var g_lHeCEnableSafeHtml=1073741824
var g_lHeCDisableIncDecFontSizeBtns=2147483648

if(typeof(g_strHeCssWindowText)=="undefined")g_strHeCssWindowText="windowtext"
if(typeof(g_strHeCssWindow)=="undefined")g_strHeCssWindow="window"
if(typeof(g_strHeCssThreedFace)=="undefined")g_strHeCssThreedFace="threedface"
if(typeof(g_strHeCssThreedHighlight)=="undefined")g_strHeCssThreedHighlight="threedhighlight"
if(typeof(g_strHeCssThreedShadow)=="undefined")g_strHeCssThreedShadow="threedshadow"
if(typeof(g_strHeCssBtnFaceU)=="undefined")g_strHeCssBtnFaceU="threedface"
if(typeof(g_strHeCssBtnFaceD)=="undefined")g_strHeCssBtnFaceD="threedface"
if(typeof(g_strHeCssBtnFaceO)=="undefined")g_strHeCssBtnFaceO=g_strHeCssBtnFaceD
if(typeof(g_strHeCssBtnHighlight)=="undefined")g_strHeCssBtnHighlight="threedhighlight"
if(typeof(g_strHeCssBtnShadow)=="undefined")g_strHeCssBtnShadow="threedshadow"
if(typeof(g_strHeCssMenuText)=="undefined")g_strHeCssMenuText="windowtext"
if(typeof(g_strHeCssMenuBack)=="undefined")g_strHeCssMenuBack="threedface"
if(typeof(g_strHeCssMenuGrayText)=="undefined")g_strHeCssMenuGrayText="graytext"
if(typeof(g_strHeCssMenuSeparatorTop)=="undefined")g_strHeCssMenuSeparatorTop="threedshadow"
if(typeof(g_strHeCssMenuSeparatorBottom)=="undefined")g_strHeCssMenuSeparatorBottom="threedhighlight"
if(typeof(g_strHeCssMenuTopLeft)=="undefined")g_strHeCssMenuTopLeft="threedhighlight"
if(typeof(g_strHeCssMenuBottomRight)=="undefined")g_strHeCssMenuBottomRight="threedshadow"
if(typeof(g_strHeCssMenuUText)=="undefined")g_strHeCssMenuUText="highlighttext"
if(typeof(g_strHeCssMenuUBack)=="undefined")g_strHeCssMenuUBack="highlight"
if(typeof(g_strHeCssMenuUTopLeft)=="undefined")g_strHeCssMenuUTopLeft="highlight"
if(typeof(g_strHeCssMenuUBottomRight)=="undefined")g_strHeCssMenuUBottomRight="highlight"
if(typeof(g_strHeCssMenuBorderWidth)=="undefined")g_strHeCssMenuBorderWidth=2
if(typeof(g_strHeCssEditorBorderColor)=="undefined")g_strHeCssEditorBorderColor="black"
if(typeof(g_strHeCssBtnHeight)=="undefined")g_strHeCssBtnHeight=22

if(typeof(g_bMergedImageDialog)=="undefined")g_bMergedImageDialog=false
if(typeof(g_lSymbolMenuWidth)=="undefined")g_lSymbolMenuWidth=50

if(typeof(g_lTimeOutBlank)=="undefined")g_lTimeOutBlank=5
if(typeof(g_lTimeOutPage)=="undefined")g_lTimeOutPage=30
if(typeof(g_lTimeOutCss)=="undefined")g_lTimeOutCss=5

var g_arrHeEditorStyles = new Object()

// default class
g_arrHeEditorStyles["default"]={
		fontList:[
			"Arial", "Tahoma", "Verdana", "Times New Roman", 
			"Georgia", "Courier New", "Courier", 
			"Serif", "Sans-Serif", "Monospace"
		],
		symbolList:[
			"&cent;", "&pound;", "&yen;", "&copy;" ,
			"&laquo;", "&reg;", "&deg;", "&plusmn;",
			"&micro;", "&para;", "&middot;", "&ordm;",
			"&raquo;", "&frac14;", "&frac12;", "&frac34;"
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

if(typeof(g_strHeCssToolBarBack)=="undefined")g_strHeCssToolBarBack="position:relative;left:0px;top:0px;padding:1px;background-color:"+g_strHeCssThreedFace+";border:1px solid " + g_strHeCssThreedShadow + "; border-top-color:" + g_strHeCssThreedHighlight + "; border-left-color:" + g_strHeCssThreedHighlight + ";overflow:hidden;text-align:left"
if(typeof(g_strHeCssToolBar)=="undefined")g_strHeCssToolBar="height: 22px; padding-right: 4px"
if(typeof(g_strHeCssBtn)=="undefined")g_strHeCssBtn="cursor:pointer;padding:0px;border:solid;border-width:1px;background-color:"+g_strHeCssThreedFace+";Border-Top-Color:"+g_strHeCssThreedFace + "; Border-Left-Color:" + g_strHeCssThreedFace + "; Border-Bottom-Color:" + g_strHeCssThreedFace + "; Border-Right-Color:" + g_strHeCssThreedFace
if(typeof(g_strHeCssBtnOver)=="undefined")g_strHeCssBtnOver="cursor:pointer;padding:0px;border:solid;border-width:1px;background-color:"+g_strHeCssBtnFaceD+";Border-Top-Color:"+g_strHeCssBtnHighlight+"; Border-Left-Color:"+g_strHeCssBtnHighlight+";Border-Bottom-Color:"+g_strHeCssBtnShadow+";Border-Right-Color:"+g_strHeCssBtnShadow
if(typeof(g_strHeCssBtnDown)=="undefined")g_strHeCssBtnDown="cursor:pointer;padding:0px;border:solid;border-width:1px;background-color:"+g_strHeCssBtnFaceO+";Border-Top-Color:"+g_strHeCssBtnShadow + "; Border-Left-Color:" + g_strHeCssBtnShadow + "; Border-Bottom-Color:" + g_strHeCssBtnHighlight + "; Border-Right-Color:"+g_strHeCssBtnHighlight
if(typeof(g_strHeCssBtnDownOver)=="undefined")g_strHeCssBtnDownOver="cursor:pointer;padding:0px;border:solid;border-width:1px;background-color:"+g_strHeCssBtnFaceD+";Border-Top-Color:"+g_strHeCssBtnHighlight+"; Border-Left-Color:"+g_strHeCssBtnHighlight+";Border-Bottom-Color:"+g_strHeCssBtnShadow+";Border-Right-Color:"+g_strHeCssBtnShadow
if(typeof(g_strHeCssBtnDisabledIE)=="undefined")g_strHeCssBtnDisabledIE="cursor:pointer;padding:0px;border:solid;border-width:1px;background-color:"+g_strHeCssThreedFace+";Border-Top-Color:"+g_strHeCssThreedFace + "; Border-Left-Color:" + g_strHeCssThreedFace + "; Border-Bottom-Color:" + g_strHeCssThreedFace + "; Border-Right-Color:" + g_strHeCssThreedFace + "; filter: Chroma(Color=red) Alpha(Opacity=25); backgroundColor: red"
if(typeof(g_strHeCssBtnDisabled)=="undefined")g_strHeCssBtnDisabled="cursor:pointer;padding:0px;border:solid;border-width:1px;background-color:"+g_strHeCssThreedFace+";Border-Top-Color:"+g_strHeCssThreedFace + "; Border-Left-Color:" + g_strHeCssThreedFace + "; Border-Bottom-Color:" + g_strHeCssThreedFace + "; Border-Right-Color:" + g_strHeCssThreedFace + "; visibility: hidden"
if(typeof(g_strHeCssText)=="undefined")g_strHeCssText="cursor:default;font-family:tahoma,sans-serif;font-size:8pt;color:"+g_strHeCssWindowText
if(typeof(g_strHeCssSelect)=="undefined")g_strHeCssSelect="cursor:default;font-family:tahoma,sans-serif;font-size:8pt;background-color:"+g_strHeCssWindow+";color:"+g_strHeCssWindowText
if(typeof(g_strHeCssStatusBar)=="undefined")g_strHeCssStatusBar="position:relative;left:0px;top:0px;padding:1px;background-color:"+g_strHeCssThreedFace+";border:1px solid " + g_strHeCssThreedShadow + "; border-top-color:" + g_strHeCssThreedHighlight + "; border-left-color:" + g_strHeCssThreedHighlight + ";overflow:hidden;text-align:left"
if(typeof(g_strHeCssStatusBox)=="undefined")g_strHeCssStatusBox="cursor:default;font-family:tahoma,sans-serif;color:"+g_strHeCssWindowText+";background-color:"+g_strHeCssThreedFace+";font-size:8pt; border-width:1px; border-style:solid; border-color:" + g_strHeCssThreedShadow + "; border-right-color:" + g_strHeCssThreedHighlight + "; border-bottom-color:"+g_strHeCssThreedHighlight+";text-align:center;padding-left:15px;padding-right:10px"

document.write("<style type=\"text/css\">\n"
+".htmleditstatusbar{"+g_strHeCssStatusBar+"}\n"
+".htmleditstatusbox{"+g_strHeCssStatusBox+"}\n"
+".htmledittoolbarback{"+g_strHeCssToolBarBack+"}\n"
+".htmledittoolbar{"+g_strHeCssToolBar+"}\n"
+".htmleditbtn{"+g_strHeCssBtn+"}\n"
+"</style>")
// unknown ie problem requires to separate stylesheet into two
document.write("<style type=\"text/css\">\n"
+".htmleditbtnover{"+g_strHeCssBtnOver+"}\n"
+".htmleditbtndown{"+g_strHeCssBtnDown+"}\n"
+".htmleditbtndownover{"+g_strHeCssBtnDownOver+"}\n"
+".htmleditselect{"+g_strHeCssSelect+"}\n"
+".htmleditbtndisabled{"+(is_ie?g_strHeCssBtnDisabledIE:g_strHeCssBtnDisabled)+"}\n"
+".htmledittext{"+g_strHeCssText+"}\n"
+"</style>\n")

var g_lHeNumDefaultStyles=3
var g_lHeNumStyleSheets=0

// deprecated function
function HtmlEditOpenEditor(strId,strTitle,strCharset,strThemeFile,lFlags){
	var o=new Object()
	o.strId=strId
	o.strCharset=(strCharset?strCharset:"iso-8859-1")
	o.strTitle=(strTitle?strTitle:"")
	o.strHtmlEditPath=g_strHtmlEditPath
	o.strHtmlEditImgUrl=g_strHtmlEditImgUrl
	o.strHtmlEditLangFile=g_strHtmlEditLangFile
	o.bMergedImageDialog=g_bMergedImageDialog
	o.strThemeFile=strThemeFile
	o.strContent=((document.getElementById)?document.getElementById(strId).innerHTML:'')
	o.lFlags=lFlags?lFlags:0
	HtmlEditOpenEditorFromObj(o)
}

function HtmlEditOpenEditorReturn(strId){
	var result=dialogWin.returnedValue
	var obj=dialogWin.args
	if(result!=null&&document.getElementById)document.getElementById(strId).innerHTML=dialogWin.returnedValue
	if(obj.onChanged)obj.onChanged()
}

function HtmlEditOpenEditorFromObj(o) {
	MyDlgOpen(
	g_strHtmlEditPath+"htmleditpopup.html",
	(o.width?o.width:620),
	(o.height?o.height:420),
	new Function("HtmlEditOpenEditorReturn('"+o.strId+"')"),
	o,null,true)
}

function HtmlEditGetState2(id){
	var pos=id.indexOf('_')
	if(id.substring(0,5)=="hebtn"&&pos>0){
		var cmd=id.substr(pos+1,id.length-pos-1)
		var strId=id.substr(5,pos-5)
		switch(cmd){
		case 'src':return HtmlEditIsEditSrc(strId)
		case 'tableborder':return HtmlEditDisplayTableBorder(strId)
		default:return HtmlEditGetState(id)
		}
	}
}

function HtmlEditDrawBtn(obj,state){
	if(!obj||!obj.style)return
	var os=obj.style
	var className
	if(!obj.disabled){
		switch(state){
		case "Over":
			if(HtmlEditGetState2(obj.id)) className="htmleditbtndownover"
			else className="htmleditbtnover"
			break
		case "Down":className="htmleditbtndown";break
		default:
			if(HtmlEditGetState2(obj.id))className="htmleditbtndown"
			else className="htmleditbtn"
		    break
		}
	}
	else className="htmleditbtndisabled"
	if(is_ie)obj.className=className
	else obj.setAttribute('class',className)
}

function HtmlEditCmd(strId,strCmd){
	HtmlEditExecCmd(strId,strCmd,false,'')
	if(strCmd=="JustifyLeft"||strCmd=="JustifyCenter"||strCmd=="JustifyRight"||strCmd=="JustifyFull"){
		HtmlEditDrawBtn(document.getElementById("hebtn"+strId+"_i_JustifyLeft",""))
		HtmlEditDrawBtn(document.getElementById("hebtn"+strId+"_i_JustifyCenter",""))
		HtmlEditDrawBtn(document.getElementById("hebtn"+strId+"_i_JustifyRight",""))
		HtmlEditDrawBtn(document.getElementById("hebtn"+strId+"_i_JustifyFull",""))
	}
}

// e for mozilla,window.event for IE
function HtmlEditBtnOver(e){if(e&&typeof(e.preventDefault)!="undefined")e.preventDefault();if(typeof(HtmlEditDrawBtn)!="undefined")HtmlEditDrawBtn((e)?e.target:window.event.srcElement,"Over");return false;}
function HtmlEditBtnOut(e){if(e&&typeof(e.preventDefault)!="undefined")e.preventDefault();if(typeof(HtmlEditDrawBtn)!="undefined")HtmlEditDrawBtn((e)?e.target:window.event.srcElement,"Out");return false}
function HtmlEditBtnDown(e){if(e&&typeof(e.preventDefault)!="undefined")e.preventDefault();if(typeof(HtmlEditDrawBtn)!="undefined")HtmlEditDrawBtn((e)?e.target:window.event.srcElement,"Down");return false}
function HtmlEditBtnUp(e){/*HtmlEditDrawBtn((e)?e.target:window.event.srcElement,"Up")*/}
function HtmlEditHideAllPopup(){PopupHide(g_heAbout);PopupHide(g_heColor);PopupHide(g_hePopup)}

function HtmlEditFormatBlock(strId, obj){
	var val=obj.options[obj.selectedIndex].value
	if(val){
		var arr=val.split(".")
		var tag=arr[0]
		var className=arr[1]?arr[1]:""
		HtmlEditExecCmd(strId,'FormatBlock',false,'<'+arr[0]+'>')
		var rng=RangeGetCurrent(HtmlEditGetDocParent(strId))
		if(!rng)return
		var node=RangeGetParentNode(rng)
		node=GetParentObjectByType(node,['P','DIV','PRE','H1','H2','H3','H4','H5','H6'],['td','th'])
		var name=is_ie?'className':'class'
		SetRemoveAttr(node,name,className)
	}
}

function HtmlEditChangeSize(strId, obj){var val=obj.options[obj.selectedIndex].value;if(val)HtmlEditExecCmd(strId,'FontSize',false,val);}

function HtmlEditFontName(strId, obj){HtmlEditExecCmd(strId, 'FontName', false, obj.options[obj.selectedIndex].value) }
var g_heColorObj=new Object()

function HtmlEditColor(strId, strType, obj){
	HtmlEditHideAllPopup()
	g_heColorObj.strId=strId
	g_heColorObj.strType=strType
	PopupShow(g_heColor, 
		0,24, 
		(is_ie?104+g_strHeCssMenuBorderWidth*2-4:104), 
		(is_ie?84+g_strHeCssMenuBorderWidth*2-4:84), 
		obj)
}

function HtmlEditColorReturn(result) {
	if (g_heColorObj.strType=="HiliteColor") {
	    HtmlEditExecCmd(g_heColorObj.strId,"useCSS",false,false)
		HtmlEditExecCmd(g_heColorObj.strId,g_heColorObj.strType,false,result)
	    HtmlEditExecCmd(g_heColorObj.strId,"useCSS",false,true)
	}
	else {
		HtmlEditExecCmd(g_heColorObj.strId,g_heColorObj.strType,false,result)
	}
}

function HtmlEditSrcShowHideBtns(strId,obj,bShow){
	if(obj.id&&(obj.tagName=="IMG"||obj.tagName=="SELECT")){
		var name="hebtn"+strId
		name=obj.id.substr(name.length,obj.id.length-name.length)
		switch(name){
		case "_src":
		case "_new":
		case "_save":
		case "_copy":
		case "_cut":
		case "_paste":
		case "_undo":
		case "_redo":
		case "_help":
		    break;
		default:
			// disabled property caused firefox .9 to relayout to a bit bigger size
			obj.disabled=!bShow
		}
	}
	// go through all child objects in the toolbar
	if(obj.tagName=="DIV"||obj.tagName=="NOBR"){
		if(obj.childNodes && obj.childNodes.length){
			var len=obj.childNodes.length
			var childNodes=obj.childNodes
			for(var i=0; i<len; i++)HtmlEditSrcShowHideBtns(strId,childNodes.item(i),bShow)
		}
	}
}

function HtmlEditIsEditSrc(strId){return g_arrHtmlEdit[strId].bEditSource}

// stylesheet.disabled not working for safari
// so we reset the whole stylesheet to enable/disable feature
function HtmlEditSetStyleSheet(ss,arrDef){
	StyleSheetRemoveAllRules(ss)
	if(arrDef){
		for(var i=0;i<arrDef.length;i++){
			StyleSheetAddRule(ss,arrDef[i][0],arrDef[i][1])		
		}
	}
}

function HtmlEditSrc(strId){
	HtmlEditFocus(strId)
	HtmlEditHideAllPopup()
	
	var str=HtmlEditGetContent(strId)
	var doc=HtmlEditGetDoc(strId)
	g_arrHtmlEdit[strId].bEditSource=!g_arrHtmlEdit[strId].bEditSource

	if (g_arrHtmlEdit[strId].bEditSource) {
		g_arrHtmlEdit[strId].styleSheetBasic.disabled=true
		g_arrHtmlEdit[strId].styleSheetSource.disabled=false
		for (var j=0;j<g_arrHtmlEdit[strId].styleSheetMain.length;j++){
			g_arrHtmlEdit[strId].styleSheetMain[j].disabled=true
		}
		g_arrHtmlEdit[strId].cssTextBody=ObjGetCssText(doc.body)
		ObjSetCssText(doc.body,g_arrHtmlEditStyles.basicSource[0][1])
		g_arrHtmlEdit[strId].body.text=doc.body.getAttribute("text")
		g_arrHtmlEdit[strId].body.bgColor=doc.body.getAttribute("bgColor")
		SetRemoveAttr(doc.body,"text","")
		SetRemoveAttr(doc.body,"bgColor","")
	}
	else {
		g_arrHtmlEdit[strId].styleSheetBasic.disabled=false
		g_arrHtmlEdit[strId].styleSheetSource.disabled=true
		for (var j=0;j<g_arrHtmlEdit[strId].styleSheetMain.length;j++){
			g_arrHtmlEdit[strId].styleSheetMain[j].disabled=false
		}
		ObjSetCssText(doc.body, g_arrHtmlEdit[strId].cssTextBody)
		SetRemoveAttr(doc.body,"text",g_arrHtmlEdit[strId].body.text)
		SetRemoveAttr(doc.body,"bgColor",g_arrHtmlEdit[strId].body.bgColor)
	}

	HtmlEditSrcShowHideBtns(strId,document.getElementById("hetoolbar_"+strId),!g_arrHtmlEdit[strId].bEditSource)
	HtmlEditSetContent(strId, str)
	HtmlEditPrepareUpdate(strId)
}

function HtmlEditDisplayTableBorder(strId){return g_arrHtmlEdit[strId].bTableBorder}

function HtmlEditTableBorder(strId){
	HtmlEditHideAllPopup()
	g_arrHtmlEdit[strId].bTableBorder=!g_arrHtmlEdit[strId].bTableBorder
	g_arrHtmlEdit[strId].styleSheetTable.disabled=!g_arrHtmlEdit[strId].bTableBorder
	HtmlEditPrepareUpdate(strId)
}

function HtmlEditTable(strId){
	HtmlEditHideAllPopup()
	MyDlgOpen(
		g_strHtmlEditPath + "htmledittabledlg.html",
		460, 220,
		HtmlEditTableReturn,
		null,
		new Array(strId))
}

function HtmlEditTableReturn(){
	var result=dialogWin.returnedValue
	var strId=dialogWin.callerdata[0]
	var tblcontent, tblattr
	if(result != null){
		var doc = HtmlEditGetDoc(strId)
		if (is_safari) {		
			tblattr=""
			if(result.ewidth.length)tblattr+="width=\""+result.ewidth+"\""
			if(result.eborderwidth.length)tblattr+="border=\""+result.eborderwidth+"\""
			if(result.ecellpadding.length)tblattr+="cellpadding=\""+result.ecellpadding+"\""
			if(result.ecellspacing.length)tblattr+="cellspacing=\"" + result.ecellspacing + "\""
			if(result.ebgcolor.length)tblattr+="bgcolor=\"" + result.ebgcolor + "\""
			if(result.ebordercolor.length)tblattr+="bordercolor=\"" + result.ebordercolor + "\""
			if(result.ehalign.length)tblattr+="align=\"" + result.ehalign + "\""
			tblcontent=""
			for(j=0; j < result.erows; j ++){
				tblcontent+="<tr>"
				for(i=0; i < result.ecolumns; i ++)
					tblcontent+=((is_ie && (g_arrHtmlEdit[strId].lFlags & g_lHeCUseDivForIE)) ? "<td><div>&nbsp;</div></td>" : "<td>&nbsp;</td>")
				tblcontent+="</tr>"
			}
			HtmlEditInsertCode(strId, "<table " + tblattr + ">" + tblcontent + "</table>")
		}
		else {
			var rng=RangeGetCurrent(HtmlEditGetDocParent(strId))
			var element=RangeGetParentNode(rng)
			var obj=GetParentObjectByType(element, ["P","H1","H2","H3","h4","H5","H6","PRE","UL","OL"])
			var bDummy=false
			if(!obj) {
				HtmlEditInsertCode(strId, "<br id=htmledit_insert />");
				var obj = doc.getElementById("htmledit_insert")
				bDummy=true
			}
			var table = doc.createElement("table")
			if(result.ewidth.length)table.setAttribute("width",result.ewidth)
			if(result.eborderwidth.length)table.setAttribute("border",result.eborderwidth)
			if(result.ecellpadding.length)table.setAttribute("cellpadding",result.ecellpadding)
			if(result.ecellspacing.length)table.setAttribute("cellspacing",result.ecellspacing)
			if(result.ebgcolor.length)table.setAttribute("bgcolor",result.ebgcolor)
			if(result.ebordercolor.length)table.setAttribute("bordercolor",result.ebordercolor)
			if(result.ehalign.length)table.setAttribute("align",result.ehalign)
			for(j=0; j < result.erows; j ++){
				var newrow=table.insertRow(-1)
				for(var i=0;i<result.ecolumns;i++){
					var cell=newrow.insertCell(-1)
					if(is_ie&&(g_arrHtmlEdit[strId].lFlags & g_lHeCUseDivForIE)) 
						cell.innerHTML="<div>&nbsp;</div>"
					else
						cell.innerHTML="&nbsp;"
				}
			}		
			obj.parentNode.insertBefore(table, obj)
			if (bDummy) {
				obj.parentNode.removeChild(obj)
			}
		}
	}
}

function HtmlEditLink(strId){
	HtmlEditHideAllPopup()
	var obj=new Object()
	obj.link=new String()
	obj.target=new String()
	var element=g_heElement
	var e
	
	if(!element){
		// not from right click
		var rng=RangeGetCurrent(HtmlEditGetDocParent(strId))
		element=RangeGetParentNode(rng)
	}
	// right click wont return exact <a> tag occasionally
	if(element){
		e=GetParentObjectByType(element, new Array("A"))
		if(e){
		    obj.href=e.href
		    obj.target=e.target
		}
	}
	MyDlgOpen(
		g_strHtmlEditPath + "htmleditlinkdlg.html",
		400, 120,
		HtmlEditLinkReturn,
		obj,
		new Array(strId, e))
}

function HtmlEditLinkReturn(){
	var result=dialogWin.returnedValue
	var strId=dialogWin.callerdata[0]
	var element=dialogWin.callerdata[1]
	
	if(result != null){
		var linkattr=new String()
		if(result.href.substring(0,4)=="www.")result.href="http://" + result.href
		if(result.target=="_self")result.target=""
		if(element){
			SetRemoveAttr(element,"target",result.target)
			SetRemoveAttr(element,"href",result.href)
		}
		else if(result.href) {
			// cant set right away
			var str=new String(result.href)
			if((str.indexOf("/") < 0 || str.indexOf(":") < 0)&& g_arrHtmlEdit[strId].strBaseHref){
				str=g_arrHtmlEdit[strId].strBaseHref + str
			}
			window.setTimeout("HtmlEditLinkSub('"+strId+"', '"+str+"', '"+result.target+"')",1)
		}
	}
}
 
function HtmlEditLinkSub(strId, href, target){
	if (is_safari) {
		var doc=HtmlEditGetDoc(strId)
		var win=HtmlEditGetDocParent(strId)
		var content=win.getSelection()+""
		HtmlEditExecCmd(strId, "delete", false, null)
		HtmlEditInsertCode(strId, "<a href=\""+HtmlSpecialChars(href)+"\""+(target?" target=\""+HtmlSpecialChars(target)+"\"":"")+">"+HtmlSpecialChars(content)+"</a>")
	}
	else if(!HtmlEditExecCmd(strId, "CreateLink", false, href))
		alert(g_strHeTextMsgValidURL)
	else {
		var rng=RangeGetCurrent(HtmlEditGetDocParent(strId))
		var element=RangeGetParentNode(rng)
		if(element){
			var e=GetParentObjectByType(element, new Array("A"))
			// firefox range is point to the text node in front of selection after CreateLink
			if(!e)e=element.nextSibling
			if(e)SetRemoveAttr(e,"target",target)
		}
	}
}

function HtmlEditImg(strId){
	g_heElement=null
	var rng=RangeGetCurrent(HtmlEditGetDocParent(strId))
	var element=RangeGetParentNode(rng)
	if(element){
		if(element.tagName!="IMG") {
			element=GetParentObjectByType(element, new Array("IMG"))
		}
		if(element&&element.tagName=="IMG"){
			g_heElement=element
		}
	}

	if(g_heElement){
		HtmlEditImageProperties(strId)
	}
	else{
		if(g_bMergedImageDialog){
			MyDlgOpen(
				g_strHtmlEditImgUrl,
				580, 460,
				HtmlEditImgReturn,
				null,
				new Array(strId),
				true, true)
		}
		else{
			MyDlgOpen(
				g_strHtmlEditPath + "htmleditimage.html",
				400, 190,
				HtmlEditImgReturn,
				null,
				new Array(strId),
				true, true)
		}
	}
	HtmlEditHideAllPopup()
}

function HtmlEditImgReturn(){
	var result=dialogWin.returnedValue
	var strId=dialogWin.callerdata[0]
	if(result != null && result.src.length > 0){
		switch (result.type) {
		case "flash":
			var str=new String()
			str += "<EMBED src=\"" + result.src + "\" quality=\"high\" bgcolor=\"#FFFFFF\" WIDTH=\"" 
			 + result.width + "\" HEIGHT=\"" + result.height + "\" "
			 + "TYPE=\"application/x-shockwave-flash\" "
			 + "PLUGINSPAGE=\"http://www.macromedia.com/go/getflashplayer\"></EMBED>"
			HtmlEditInsertCode(strId, str)
			break
		case "other":
			HtmlEditInsertCode(strId, "<a href=\"" + HtmlSpecialChars(result.src) + "\">" + HtmlSpecialChars(result.src) + "</a>")
			break
		default:
			var imgattr=new String()
			if(result.src.length){
				if(result.align.length)imgattr+=" align=\""+result.align+"\""
				if(result.border.length)imgattr+=" border=\""+result.border+"\""
				if(result.alt.length)imgattr+=" alt=\""+HtmlSpecialChars(result.alt)+"\""
				if(result.width&&result.width.length)imgattr+=" width=\""+result.width+"\""
				if(result.height&&result.height.length)imgattr+=" height=\""+result.height+"\""
			}
			var str=new String(result.src)
			if(str.indexOf("/") < 0 && g_arrHtmlEdit[strId].strBaseHref){
				str=g_arrHtmlEdit[strId].strBaseHref + str
			}        
			HtmlEditInsertCode(strId, "<img src=\"" + str + "\" " + imgattr + " />")
			break
		}
		
	}
}

function HtmlEditImageProperties(strId){
	if(g_heElement.tagName=="IMG"){
		var obj=new Object()
		obj.src=new String(g_heElement.src)
		obj.align=new String(g_heElement.align)
		obj.border=new String(g_heElement.border)
		obj.alt=new String(g_heElement.alt)
		obj.width=new String(g_heElement.width)
		obj.height=new String(g_heElement.height)
		
		if(g_bMergedImageDialog){
			MyDlgOpen(
				g_strHtmlEditImgUrl,
				580, 460,
				HtmlEditImagePropertiesReturn,
				obj,
				new Array(strId),
				true, true)
		}
		else{
			MyDlgOpen(
				g_strHtmlEditPath + "htmleditimage.html",
				400, 190,
				HtmlEditImagePropertiesReturn,
				obj,
				new Array(strId),
				true, true)
		}
		HtmlEditHideAllPopup()
	}
}

function HtmlEditImagePropertiesReturn(){
	var r=dialogWin.returnedValue
	var strId=dialogWin.callerdata[0]
	if(r!=null){
		g_heElement.src=r.src
		g_heElement.align=r.align
		g_heElement.border=r.border
		g_heElement.alt=r.alt
		if (r.width.length) g_heElement.width=r.width
		if (r.height.length) g_heElement.height=r.height
	}
}

function HtmlEditPastePlainText(strId){
	if(is_ie){
		HtmlEditInsertCode(strId,PlainTextToHtml(window.clipboardData.getData('Text')))
	}
	else{
		MyDlgOpen(
			g_strHtmlEditPath + "htmleditpasteplaintext.html",
			500, 400,
			HtmlEditPastePlainTextReturn,
			null,
			new Array(strId))
	}
    HtmlEditHideAllPopup()
}

function HtmlEditPastePlainTextReturn(e,r){
	var r=dialogWin.returnedValue
	var strId=dialogWin.callerdata[0]
	HtmlEditInsertCode(strId,PlainTextToHtml(r[0]))
}

function HtmlEditPasteFromWord(strId){
	MyDlgOpen(
		g_strHtmlEditPath + "htmleditpastefromword.html",
		500, 400,
		HtmlEditPasteFromWordReturn,
		null,
		new Array(strId))
    HtmlEditHideAllPopup()
}

function HtmlEditPasteFromWordReturn(e,r){
	var r=dialogWin.returnedValue
	var strId=dialogWin.callerdata[0]
	HtmlEditInsertCode(strId,r[0])
}

function HtmlEditCellProperties(strId){
	var e=GetParentObjectByType(g_heElement, new Array("TD", "TH"))
	if(e&&(e.tagName=="TD"||e.tagName=="TH")){
		MyDlgOpen(
			g_strHtmlEditPath + "htmleditcelldlg.html",
			460, 200,
			HtmlEditCellPropertiesReturn,
			new Array(e.width, e.height, e.align, e.vAlign, e.bgColor),
			new Array(strId))
	    HtmlEditHideAllPopup()
	}
}

function HtmlEditCellPropertiesReturnSub(e,r){
	SetRemoveAttr(e,"width", r[1])
	SetRemoveAttr(e,"height", r[2])
	SetRemoveAttr(e,"align", r[3])
	SetRemoveAttr(e,"vAlign", r[4])
	SetRemoveAttr(e,"bgColor", r[5])
}

function HtmlEditCellPropertiesReturn(){
	var i
	var e=GetParentObjectByType(g_heElement, new Array("TD", "TH"))
	if(e && (e.tagName=="TD" || e.tagName=="TH")){
	    var result=dialogWin.returnedValue
	    var strId=dialogWin.callerdata[0]
	    if(result != null){
	        switch(result[0]){
	        case 0:
	            HtmlEditCellPropertiesReturnSub(e, result)
	            break
	        case 1:
				HtmlEditTableRowOp(strId, "cell_properties", result)
	            break
	        case 2:
				HtmlEditTableColumnOp(strId, "cell_properties", result)
	            break
	        }
	    }
	}
}

function HtmlEditTableProperties(strId){
	var e=GetParentObjectByType(g_heElement, new Array("TABLE"))
	if(e && e.tagName=="TABLE"){
		var obj=new Object()
		obj.ewidth=e.width
		obj.eborderwidth=e.border
		obj.ecellpadding=e.cellPadding
		obj.ecellspacing=e.cellSpacing
		obj.ebgcolor=e.bgColor
		obj.ebordercolor=e.borderColor
		obj.ehalign=e.align
		MyDlgOpen(g_strHtmlEditPath + "htmledittabledlg.html",
		    460, 220,
		    HtmlEditTablePropertiesReturn,
		    obj, new Array(strId))
		HtmlEditHideAllPopup()
	}
}

function HtmlEditTablePropertiesReturn(){
	var e=GetParentObjectByType(g_heElement,new Array('TABLE'))
	if(e&&e.tagName=="TABLE"){
		var res=dialogWin.returnedValue
		var strId=dialogWin.callerdata[0]
		if(res!=null){
			SetRemoveAttr(e,'width',res.ewidth)
			SetRemoveAttr(e,'border',res.eborderwidth)
			SetRemoveAttr(e,'cellPadding',res.ecellpadding)
			SetRemoveAttr(e,'cellSpacing',res.ecellspacing)
			SetRemoveAttr(e,'bgColor',res.ebgcolor)
			SetRemoveAttr(e,'borderColor',res.ebordercolor)
			SetRemoveAttr(e,'align',res.ehalign)
		}
	}
}

function HtmlEditPageProperties(strId){
	var obj=new Object()
	var doc=HtmlEditGetDoc(strId)
	obj.title=doc.title
	obj.text=doc.body.getAttribute("text")
	obj.bgColor=doc.body.getAttribute("bgcolor")
	obj.background=doc.body.getAttribute("background")
	obj.marginWidth=is_ie ? doc.body.getAttribute("leftmargin") : doc.body.getAttribute("marginwidth")
	obj.marginHeight=is_ie ? doc.body.getAttribute("topmargin") : doc.body.getAttribute("marginheight")
	obj.link=doc.body.getAttribute("link")
	obj.alink=doc.body.getAttribute("aLink")
	obj.vlink=doc.body.getAttribute("vLink")
	MyDlgOpen(g_strHtmlEditPath + "htmleditpageprop.html",
		460, 220,
		HtmlEditPagePropertiesReturn,
		obj, new Array(strId))
	HtmlEditHideAllPopup()
}

function HtmlEditPagePropertiesReturn(){
	var result=dialogWin.returnedValue
	var strId=dialogWin.callerdata[0]
	var doc=HtmlEditGetDoc(strId)
	if(result != null){
		doc.title=result.title
		SetRemoveAttr(doc.body,'text', result.text)
		SetRemoveAttr(doc.body,'bgColor', result.bgColor)
		SetRemoveAttr(doc.body,'link', result.link)
		SetRemoveAttr(doc.body,'aLink', result.alink)
		SetRemoveAttr(doc.body,'vLink', result.vlink)
		SetRemoveAttr(doc.body,'topMargin', result.marginHeight)
		SetRemoveAttr(doc.body,'marginHeight', result.marginHeight)
		SetRemoveAttr(doc.body,'leftMargin', result.marginWidth)
		SetRemoveAttr(doc.body,'marginWidth', result.marginWidth)
	}
}

function HtmlEditOListProperties(){
	var e=GetParentObjectByType(g_heElement, new Array("OL"), new Array("TD", "TH", "TABLE", "UL"))
	if(e){
		MyDlgOpen(g_strHtmlEditPath + "htmleditolpropdlg.html",
			320, 110,
			HtmlEditOListPropertiesReturn,
			new Array(e.type),
			null)
		HtmlEditHideAllPopup()
	}
}

function HtmlEditOListPropertiesReturn(){
	var e=GetParentObjectByType(g_heElement, new Array("OL"), new Array("TD", "TH", "TABLE", "UL"))
	var result=dialogWin.returnedValue
	if(e)SetRemoveAttr(e,'type', result[0])
}

function HtmlEditUListProperties(){
	var e=GetParentObjectByType(g_heElement, new Array("UL"), new Array("TD", "TH", "TABLE", "UL"))
	if(e){
		MyDlgOpen(g_strHtmlEditPath + "htmleditulpropdlg.html",
			320, 110,
			HtmlEditUListPropertiesReturn,
			new Array(e.type),
			null)
		HtmlEditHideAllPopup()
	}
}

function HtmlEditUListPropertiesReturn(){
	var e=GetParentObjectByType(g_heElement, new Array("UL"), new Array("TD", "TH", "TABLE", "UL"))
	result=dialogWin.returnedValue
	if(e)SetRemoveAttr(e,'type', result[0])
}

function HtmlEditUpdateTextarea(strId){
	var strValue=HtmlEditGetDefContent(strId)
	if(g_arrHtmlEdit[strId].strTextareaId && document.getElementById(g_arrHtmlEdit[strId].strTextareaId))
		document.getElementById(g_arrHtmlEdit[strId].strTextareaId).value=strValue
}

function HtmlEditSubmit(strId, strElementName){
	var strValue=HtmlEditGetDefContent(strId)
	// replace windows only charset to corresponding iso characters
	strValue=CleanWindowsCharset(strValue)
	document.getElementById(strId+"_"+strElementName).value=strValue
	document.getElementById(strId+"_"+strElementName).form.submit()
}

function HtmlEditSave(strId){MyDlgHandleOK(HtmlEditGetDefContent(strId))}

function HtmlEditApplyStyle(strId, selobj){
	HtmlEditFocus(strId)
	var rng=RangeGetCurrent(HtmlEditGetDocParent(strId))
	if(!rng||selobj.value.length==0) return
	var str=RangeGetHtmlText(rng)
	if(str.length>0)HtmlEditCmd(strId, "Delete")
	var str="<span class=\"" + selobj.value + "\">" + str + "</span>"
	HtmlEditInsertCode(strId,str)
}

function HtmlEditIncreaseFontSize(strId) {
	if(is_gecko)HtmlEditCmd(strId,"increasefontsize")
	else{
		HtmlEditFocus(strId)
		var rng=RangeGetCurrent(HtmlEditGetDocParent(strId))
		if(!rng)return
		var str=RangeGetHtmlText(rng)
		if(str.length>0)HtmlEditCmd(strId,"Delete")
		str="<big>"+str+"</big>"
		HtmlEditInsertCode(strId, str)
	}
}

function HtmlEditDecreaseFontSize(strId) {
	if(is_gecko)HtmlEditCmd(strId,"decreasefontsize")
	else{
		HtmlEditFocus(strId)
		var rng=RangeGetCurrent(HtmlEditGetDocParent(strId))
		if(!rng)return
		var str=RangeGetHtmlText(rng)
		if(str.length>0)HtmlEditCmd(strId,"Delete")
		str="<small>"+str+"</small>"
		HtmlEditInsertCode(strId, str)
	}
}

// this function is for IE only for fixing up <div> tag
function HtmlEditProcessKeyPressed(strId){
	if(is_ie && HtmlEditGetDocParent(strId).event.keyCode==13){
		HtmlEditCheckParagraph(strId)
	}
}

function HtmlEditCheckParagraph(strId){
	if(is_ie && (g_arrHtmlEdit[strId].lFlags & g_lHeCUseDivForIE)){
	var doc=HtmlEditGetDoc(strId)
		switch(doc.queryCommandValue('FormatBlock')){
		case "Normal": // IE name for p and div tag
		case "": // Midas div tag
		case "p": // Midas name
			if(is_ie) HtmlEditExecCmd(strId, 'FormatBlock', false, '<div>')
			break;
		}
	}
}

function HtmlEditGetCmdBtnSub(strId, name, cmd, img, tip){
	return("<img align=absmiddle class=\"htmleditbtn\" id=\"hebtn" + strId + name + "\" onclick=\"javascript: HtmlEditExecCmd('" + strId + "', '" + cmd + "', false, null)\" src=\"" + g_strHtmlEditPath + "htmleditimg/" + img + "\" alt=\"" + tip + "\" title=\"" + tip + "\" width=\"20\" height=\"20\" />")
}

function HtmlEditGetBtnSub(strId, name, cmd, img, tip){
	return("<img align=absmiddle class=\"htmleditbtn\" id=\"hebtn" + strId + name + "\" onclick=\"" + cmd + "\" src=\"" + g_strHtmlEditPath + "htmleditimg/" + img + "\" alt=\"" + tip + "\" title=\"" + tip + "\" width=\"20\" height=\"20\" />")
}

function HtmlEditGetBtnCode(obj,name){
	var strId=obj.strId
	var lFlags=obj.lFlags
	switch(name){
	case "New":
		if((lFlags & g_lHeCDisableNewBtn)==0){
			return HtmlEditGetBtnSub(strId,"_new","javascript: HtmlEditNew('"+strId+"')","new.gif",g_strHeTextNew)
		}
		break
	case "Save":
		if((lFlags & g_lHeCModeMask)==g_lHeCModeStandaloneForm){
			return HtmlEditGetBtnSub(strId,"_save","javascript: HtmlEditSubmit('"+strId+"', '"+obj.strElementName+"')","save.gif",g_strHeTextSave)
		}
		else if((lFlags & g_lHeCModeMask)==g_lHeCModeStandaloneDialog){
			return HtmlEditGetBtnSub(strId,"_save","javascript: HtmlEditSave('"+strId+"')","save.gif",g_strHeTextSave)
		}		
		break
	case "Sep":
		return "<img src=\""+g_strHtmlEditPath+"/htmleditimg/spacer.gif\" align=\"absmiddle\" width=\"8\" height=\""+g_strHeCssBtnHeight+"\" alt=\"\" />"
	case "Copy":
		if((lFlags & g_lHeCDisableCutCopyPasteBtn)==0 && is_ie){
			return HtmlEditGetCmdBtnSub(strId,"_copy","Copy","copy.gif",g_strHeTextCopy)
		}
		break
	case "Cut":
		if((lFlags & g_lHeCDisableCutCopyPasteBtn)==0 && is_ie){
			return HtmlEditGetCmdBtnSub(strId,"_cut","Cut","cut.gif",g_strHeTextCut)
		}
		break
	case "Paste":
		if((lFlags&g_lHeCDisableCutCopyPasteBtn)==0 && is_ie){
			return HtmlEditGetCmdBtnSub(strId,"_paste","Paste","paste.gif",g_strHeTextPaste)
		}
		break
	case "PastePlainText":
		if((lFlags&g_lHeCDisableCutCopyPasteBtn)==0){
			return HtmlEditGetBtnSub(strId,"_pasteplaintext","javascript: HtmlEditPastePlainText('"+strId+"')","paste_plaintext.gif",g_strHeTextPastePlainText)
		}
		break
	case "PasteFromWord":
		if((lFlags&g_lHeCDisableCutCopyPasteBtn)==0){
			return HtmlEditGetBtnSub(strId,"_pastefromword","javascript: HtmlEditPasteFromWord('"+strId+"')","paste_fromword.gif",g_strHeTextPasteFromWord)
		}
		break
	case "Undo":
		if((lFlags & g_lHeCDisableUndoRedoBtn)==0){
			return HtmlEditGetCmdBtnSub(strId,"_undo","Undo","undo.gif",g_strHeTextUndo)
		}
		break
	case "Redo":
		if((lFlags & g_lHeCDisableUndoRedoBtn)==0){
			return HtmlEditGetCmdBtnSub(strId,"_redo","Redo","redo.gif",g_strHeTextRedo)
		}
		break
	case "ParagraphBox":
		var str=new String()
		if(!(lFlags & g_lHeCDisableParagraph)&&!is_safari){
			str="<select class=htmleditselect name=\"hedropdown" + strId + "_FormatBlock" + "\" id=\"hedropdown" + strId + "_FormatBlock" + "\" "
				+"onclick=\"this.selectedIndex=0\" onchange=\"javascript: HtmlEditFormatBlock('" + strId + "', this)\">"
				+"<option value=\"\">" + g_strHeTextParagraphStyle + "</option>"
			var paragraphList=g_arrHeEditorStyles[obj.className].paragraphList
			for (var i=0;i<paragraphList.length;i++) {
				var tag=paragraphList[i]['tag']
				var title=paragraphList[i]['title']
				if(is_ie && (lFlags & g_lHeCUseDivForIE&&tag=="p"))tag="div"
				if("className" in paragraphList[i])tag+="."+paragraphList[i]['className']
				str+="<option value=\""+tag+"\">"+title+"</option>"
			}
			str+="</select>"
			return str
		}
		break
	case "SizeBox":
		if(!(lFlags & g_lHeCDisableFontSize)&&!is_safari){
			 return "<select class=\"htmleditselect\" name=\"hedropdown" + strId + "_FormatSize" + "\" id=\"hedropdown" + strId + "_FormatSize" + "\" "+
				"onchange=\"javascript: HtmlEditChangeSize('" + strId + "', this)\">"+
				"<option value=\"\">" + g_strHeTextFontSize + "</option>"+
				"<option value=\"7\">7 (36pt)</option>"+
				"<option value=\"6\">6 (24pt)</option>"+
				"<option value=\"5\">5 (18pt)</option>"+
				"<option value=\"4\">4 (14pt)</option>"+
				"<option value=\"3\">3 (12pt)</option>"+
				"<option value=\"2\">2 (10pt)</option>"+
				"<option value=\"1\">1 (8pt)</option></select>"
		}	
		break
	case "FontBox":
		var str
		if(!(lFlags & g_lHeCDisableFontName)){
			str="<select class=\"htmleditselect\" style=\"width: 120px\" name=\"hedropdown" + strId + "_FormatFont" + "\" id=\"hedropdown" + strId + "_FormatFont" + "\" "
				+ "onchange=\"javascript: HtmlEditFontName('" + strId + "', this)\">"
			str+="<option value=\"\" selected>"+g_strHeTextChooseFont+"</option>"
			if(!is_ie||(g_arrHtmlEdit[strId].lFlags & g_lHeCEnumSysFonts)==0){
				arr=g_arrHeEditorStyles[obj.className].fontList
				arr.sort()
				for(var i=0;i<arr.length;i++){
					var name=HtmlSpecialChars(arr[i])
					str+="<option value=\""+name+"\">"+name+"</option>"
				}
			}
			str+="</select>"
			return str
		}
		break
	case "StyleBox":
		if(!(lFlags&g_lHeCDisableStyleBox)&&!is_safari){
			return"<select class=htmleditselect style=\"width: 120px\" name=\"hedropdown" + strId + "_ApplyStyle" + "\" id=\"hedropdown" + strId + "_ApplyStyle" + "\" "
				+"onchange=\"javascript: HtmlEditApplyStyle('" + strId + "', this)\">"
				+"<option value=\"\">" + g_strHeTextStyle + "</option></select>"
		}
		break
	case "TextColor":
		if(!(lFlags & g_lHeCDisableForeColor)){
			return "<img align=absmiddle class=\"htmleditbtn\" id=\"hebtn" + strId + "_ForeColor\" "
				+"onclick=\"javascript: HtmlEditColor('" + strId + "', 'ForeColor', this)\"  src=\"" + g_strHtmlEditPath + "htmleditimg/forecolor.gif\" "
				+"alt=\"" + g_strHeTextForeColor + "\" title=\"" + g_strHeTextForeColor + "\" width=\"20\" height=\"20\" />"
		}
		break
	case "HighlightColor":
		if(!(lFlags & g_lHeCDisableBackColor))	{
			var str=is_ie||is_safari ? "BackColor" : "HiliteColor"
			return "<img align=absmiddle class=\"htmleditbtn\" id=\"hebtn" + strId + "_BackColor\" "
				+"onclick=\"javascript: HtmlEditColor('" + strId + "', '"+str+"', this)\"  src=\"" + g_strHtmlEditPath + "htmleditimg/backcolor.gif\" "
				+"alt=\"" + g_strHeTextBackColor + "\" title=\"" + g_strHeTextBackColor + "\" width=\"20\" height=\"20\" />"
		}
		break
	case "Bold":
		if(!(lFlags & g_lHeCDisableFormattingBtns1)){
			return HtmlEditGetCmdBtnSub(strId,"_i_bold","Bold","bold.gif",g_strHeTextBold)
		}
		break
	case "Italic":
		if(!(lFlags & g_lHeCDisableFormattingBtns1))return HtmlEditGetCmdBtnSub(strId,"_i_Italic","Italic","italic.gif",g_strHeTextItalic)
		break
	case "Underline":
		if(!(lFlags & g_lHeCDisableFormattingBtns1))return HtmlEditGetCmdBtnSub(strId,"_i_Underline","Underline","under.gif",g_strHeTextUnderline)
		break
	case "Strike":
		if(!(lFlags & g_lHeCDisableFormattingBtns2)&&!is_safari)return HtmlEditGetCmdBtnSub(strId,"_i_StrikeThrough","StrikeThrough","strike.gif",g_strHeTextStrikeThru)
		break
	case "Superscript": 
		if(!(lFlags & g_lHeCDisableFormattingBtns2))return HtmlEditGetCmdBtnSub(strId,"_i_Superscript","Superscript","super.gif",g_strHeTextSuperscript)
		break
	case "Subscript":
		if(!(lFlags & g_lHeCDisableFormattingBtns2))return HtmlEditGetCmdBtnSub(strId,"_i_Subscript","Subscript","sub.gif",g_strHeTextSubscript)
		break
	case "Small":
		if(!(lFlags & g_lHeCDisableIncDecFontSizeBtns)&&!is_safari)return HtmlEditGetBtnSub(strId,"_i_DecreaseFontSize","javascript: HtmlEditDecreaseFontSize('" + strId + "'); HtmlEditCheckParagraph('" + strId + "')","decreasefontsize.gif",g_strHeTextDecreaseFontSize)
		break
	case "Big":
		if(!(lFlags & g_lHeCDisableIncDecFontSizeBtns)&&!is_safari)return HtmlEditGetBtnSub(strId,"_i_IncreaseFontSize","javascript: HtmlEditIncreaseFontSize('" + strId + "'); HtmlEditCheckParagraph('" + strId + "')","increasefontsize.gif",g_strHeTextIncreaseFontSize)
		break
	case "Outdent":
		if(!(lFlags & g_lHeCDisableFormattingBtns3)&&!is_safari)return HtmlEditGetCmdBtnSub(strId,"_outindent","Outdent","deindent.gif",g_strHeTextUnindent)
		break
	case "Indent":
		if(!(lFlags & g_lHeCDisableFormattingBtns3)&&!is_safari)return HtmlEditGetCmdBtnSub(strId,"_inindent","Indent","inindent.gif",g_strHeTextIndent)
		break
	case "NumberList":
		if(!(lFlags & g_lHeCDisableFormattingBtns3)&&!is_safari){
			return HtmlEditGetBtnSub(strId,"_i_InsertOrderedList",
				"javascript: HtmlEditExecCmd('" + strId + "', 'InsertOrderedList', false, null);HtmlEditCheckParagraph('" + strId + "')",
				"numlist.gif",g_strHeTextNumList)
		}
		break
	case "BulletList":
		if(!(lFlags & g_lHeCDisableFormattingBtns3)&&!is_safari){
			return HtmlEditGetBtnSub(strId,"_i_InsertUnorderedList",
				"javascript: HtmlEditExecCmd('" + strId + "', 'InsertUnorderedList', false, null);HtmlEditCheckParagraph('" + strId + "')",
				"bullist.gif",g_strHeTextBullList)
		}
		break
	case "LeftAlign":
		if(!(lFlags & g_lHeCDisableAlignBtn))return HtmlEditGetCmdBtnSub(strId,"_i_JustifyLeft","JustifyLeft","left.gif",g_strHeTextLeftAlign)
		break
	case "CenterAlign":
		if(!(lFlags & g_lHeCDisableAlignBtn))return HtmlEditGetCmdBtnSub(strId,"_i_JustifyCenter","JustifyCenter","center.gif",g_strHeTextCenterAlign)
		break
	case "RightAlign":
		if(!(lFlags & g_lHeCDisableAlignBtn))return HtmlEditGetCmdBtnSub(strId,"_i_JustifyRight","JustifyRight","right.gif",g_strHeTextRightAlign)
		break
	case "JustifyAlign":
		if(!(lFlags & g_lHeCDisableAlignBtn))return HtmlEditGetCmdBtnSub(strId,"_i_JustifyFull","JustifyFull","justify.gif",g_strHeTextJustifyAlign)
		break
	case "Hyperlink":
		if(!(lFlags & g_lHeCDisableLinkBtn))return HtmlEditGetBtnSub(strId,"_CreateLink","javascript:g_heElement=null;HtmlEditLink('"+strId+"')","link.gif",g_strHeTextHyperlink)
		break
	case "HorizontalLine":
		if(!(lFlags & g_lHeCDisableHorizontalRuleBtn))return HtmlEditGetBtnSub(strId,"_InsertLine","javascript: HtmlEditInsertCode('"+strId +"','<hr>')","line.gif",g_strHeTextTable)
		break
	case "InsertTable":
		if(!(lFlags & g_lHeCDisableTableBtn))return HtmlEditGetBtnSub(strId,"_table","javascript:HtmlEditTable('"+strId+"')","table.gif",g_strHeTextTable)
		break
	case "ShowHideBorder":
		if(!(lFlags & g_lHeCDisableTableBtn)&&!is_safari)return HtmlEditGetBtnSub(strId,"_tableborder","javascript: HtmlEditTableBorder('"+strId+"')","border.gif",g_strHeTextTableBorder)
		break
	case "InsertImage":
		if(!(lFlags & g_lHeCDisableImageBtn))
			return HtmlEditGetBtnSub(strId,"_image",
				"javascript: HtmlEditImg('" + strId + "')",
				"image.gif",g_strHeTextImage)
		break
	case "InsertSymbol":
		if(!(lFlags & g_lHeCDisableSymbolBtn))
			return HtmlEditGetBtnSub(strId,"_symbol","","symbol.gif",g_strHeTextSymbol)
		break
	case "ShowHideSource":
		if(!(lFlags & g_lHeCDisableSourceBtn))
			return HtmlEditGetBtnSub(strId,"_src",
				"javascript: HtmlEditSrc('" + strId + "')",
				"10101.gif",g_strHeTextHTMLSource)
		break
	default:
		if(name.substr(0,9)=="CustomBtn"){
			var i=name.substr(9,1)
			i=parseInt(i)
 			if(!isNaN(i)&&obj.customBtns&&obj.customBtns[i]){
				return"<img align=absmiddle class=\"htmleditbtn\" id=\"hebtn" + strId + "_custom" +i+ "\" "
					+"src=\"" + g_strHtmlEditPath + "htmleditimg/" + obj.customBtns[i].imgname + "\" "
					+"alt=\"" + HtmlSpecialChars(obj.customBtns[i].title) + "\" "
					+"title=\"" + HtmlSpecialChars(obj.customBtns[i].title) + "\" width=\"20\" height=\"20\" />"
			}
		}
	}

	return false
}

function HtmlEditOutControlCode(strId){
	var str
	var obj=g_arrHtmlEdit[strId]
	var lFlags=obj.lFlags
	var d=document
	var bSomething=false

	str=(lFlags & g_lHeCBorder)?"1":"0"
	d.write("<table cellpadding=0 cellspacing=0 style=\"border: "+str+"px solid "+g_strHeCssEditorBorderColor+"; width: " + obj.strWidth + "\"><tr><td>")
	d.write("<div id=\"hetoolbar_" + strId + "\" unselectable=on class=\"htmledittoolbarback\" oncontextmenu=\"return false\">")

	for (var i=0;i<g_arrHeEditorStyles[obj.className].toolbarBtns.length;i++){
		var toolbar=g_arrHeEditorStyles[obj.className].toolbarBtns[i]
		if(toolbar&&toolbar.length){
			var str=""
			for (var j=0;j<toolbar.length;j++){
				var val
				if(toolbar[j]!="Sep"||str.length>0){
					val=HtmlEditGetBtnCode(obj,toolbar[j])
					if(val)str+=val
				}
			}
			if(str.length>0){
				d.write("<nobr class=\"htmledittoolbar\">"+str
					+"<img src=\""+g_strHtmlEditPath+"/htmleditimg/spacer.gif\" align=\"absmiddle\" width=\"1\" height=\""+g_strHeCssBtnHeight+"\" alt=\"\" />"
					+"</nobr>")
				if(is_ie)d.write(" ")
			}
		}
	}

	HtmlEditOutControlControlSub(obj)
	if(obj.strPageSrc){
	    d.write("<iframe src=\"" + obj.strPageSrc + "\" name=\"" + strId + "_iframe\" id=\"" + strId + "_iframe\" style=\"position: absolute; left: 1px; top: 1px; visibility: hidden;\"")
	    d.write(" onload=\"javascript: HtmlEditFrameLoaded('"+strId+"')\"")
	    d.write("></iframe>")
	}
	
	d.write("<div id=\"heDummyDiv_" + strId + "\" style=\"position: absolute; width: 0px; height: 0px; left: 0px; top: 0px; visibility: hidden\"></div>")
	
	d.write("</td></tr></table>")
	
	var re = /[\[\]]/g
	var strSafeElementName = obj.strElementName.replace(re, "")
	
	// create corresponding form elements
	if((lFlags & g_lHeCModeMask)==g_lHeCModeStandaloneForm && obj.strElementName){
		d.write("<div style=\"overflow: hidden; position: absolute; width: 0px; height: 0px; visibility: hidden;\">")
		d.write("<form method=\"post\"")
		if(obj.strFormName)d.write(" name=\"" + obj.strFormName + "\"")
		if(obj.strAction)d.write(" action=\"" + obj.strAction + "\"")
		if(obj.strTarget)d.write(" target=\"" + obj.strTarget + "\"")
		d.write(">")
		d.write("<input type=\"hidden\" id=\"" + strId + "_" + obj.strElementName + "\" name=\"" + obj.strElementName + "\" />")
		d.write("<input type=\"hidden\" name=\"" + strSafeElementName + "_bHtmlEdit\" value=\"1\" />")
		d.write("</form></div>")
	}
	// create the hidden field to hold the content
	else if((lFlags&g_lHeCModeMask)==g_lHeCModeFormElement && obj.strElementName){
		d.write("<input type=\"hidden\" id=\"" + strId + "_" + obj.strElementName + "\" name=\"" + obj.strElementName + "\" />")
		d.write("<input type=\"hidden\" name=\"" + strSafeElementName + "_bHtmlEdit\" value=\"1\" />")
		//var func=new Function("var obj=document.getElementById('"+strId+"_"+obj.strElementName+"');if(obj){obj.value=HtmlEditGetDefContent('" + strId + "');}")
		//AttachEventListener(d.getElementById(strId + "_" + obj.strElementName).form, "submit", func)
		var tmpForm=d.getElementById(strId + "_" + obj.strElementName).form
		if(tmpForm){
			if(typeof(tmpForm.onhtmleditsubmit)=="undefined"){
				if(tmpForm.onsubmit)
					tmpForm.onhtmleditsubmit=tmpForm.onsubmit
				else
					tmpForm.onhtmleditsubmit=null
				tmpForm.onsubmit=HtmlEditOnSubmitHandler
			}
		}
	}
	
	if(lFlags&g_lHeCResizeToWindow){
		var func = new Function("HtmlEditResize('"+strId+"')")
		AttachEventListener(d.getElementById("hetoolbar_" + strId), "resize", func)
		AttachEventListener(window,"resize",func)
		window.setTimeout("HtmlEditResize('"+strId+"')", 100)
	}
	// ie requires designMode to be on first before initialization	
	if (is_ie) HtmlEditGetDoc(strId).designMode='on'
	// leave remaining initialization in another function to
	// wait for that all objects are accessible
	// better use timer to do initialization after system is ready
	// need to turn on designMode before attach event for IE??
	if(is_safari)
		window.setTimeout("HtmlEditInit('" + strId + "')", 1)
	else
		HtmlEditInit(strId)	
}

function HtmlEditOnSubmitHandler() {
	HtmlEditUpdateAllFormElements()
	if(this.onhtmleditsubmit){
		return this.onhtmleditsubmit(arguments[0])
	}
	else{
		return true
	}
}

function HtmlEditNew(strId){
	if(window.confirm(g_strHeTextNewMsg)){
		if(is_safari){
			HtmlEditSetContent(strId,'')
		}
		else{
			HtmlEditCmd(strId,"SelectAll")
			HtmlEditCmd(strId,"Delete")
			if(is_ie&&(g_arrHtmlEdit[strId].lFlags&g_lHeCUseDivForIE))HtmlEditExecCmd(strId,"FormatBlock",false,"<div>")
		}
	}
}

function HtmlEditFrameLoaded(strId){g_arrHtmlEdit[strId].bFrameLoaded=true}
function HtmlEditBlankLoaded(strId){g_arrHtmlEdit[strId].bBlankLoaded=true}

function HtmlEditUpdateBtnEvents(obj){
	if(!obj)return
	if(obj.id&&obj.id.substring(0,5)=="hebtn"){
		obj.onmouseover=HtmlEditBtnOver
		obj.onmouseout=HtmlEditBtnOut
		obj.onmousedown=HtmlEditBtnDown
		obj.onmouseup=HtmlEditBtnUp
	}
	else{
		var child=obj.firstChild
		while (child){
			HtmlEditUpdateBtnEvents(child)
			child=child.nextSibling
		}
	}
}

function HtmlEditCreateControlFromObj(obj){
	// temp popup flashing on the screen for some page layout under firefox.
	// delay popup creation to latter time. However, delaying popup creation
	// cause problems under IE. So, still create popup here.
	if (!is_gecko) HtmlEditCreatePopups()
	
	// some defaults
	var strId=obj.strId?obj.strId:("htmledit"+g_lHeEditors)
	var className=obj.className&&(obj.className in g_arrHeEditorStyles)?obj.className:"default"
	var strWidth=obj.strWidth?obj.strWidth:g_arrHeEditorStyles[className].strWidth
	var strHeight=obj.strHeight?obj.strHeight:g_arrHeEditorStyles[className].strHeight
	var strCssStyle=obj.strCssStyle?obj.strCssStyle:g_arrHeEditorStyles[className].strCssStyle
	var customBtns=g_arrHeEditorStyles[className].customBtns
	var strValue
	var lFlags=g_arrHeEditorStyles[className].lFlags
	if (obj.lFlags) {
		if (obj.lMask) {
			lFlags=(lFlags&~obj.lMask)|obj.lFlags
		}
		else{
			lFlags=obj.lFlags
		}
	}
	if(!strCssStyle)lFlags|=g_lHeCDisableStyleBox
	if(lFlags&g_lHeCResizeToWindow)lFlags&=~g_lHeCBorder
	if(lFlags&g_lHeCEnableSafeHtml)lFlags|=g_lHeCXHTMLSource
	var strBaseHref,strBaseHrefOrig
	if(typeof(obj.strBaseHref)!="undefined"){
		strBaseHref=obj.strBaseHref
	}
	else if(typeof(obj.strPageSrc)=="undefined"){
		if(g_arrHeEditorStyles[className].strBaseHref){
			strBaseHref=g_arrHeEditorStyles[className].strBaseHref
		}
		else{
			strBaseHref=DirName(location.href)+"/"
		}
	}
	else {
		strBaseHref=""
	}
	if(typeof(obj.strBaseHref)!="undefined"){
		strBaseHrefOrig=obj.strBaseHref
	}
	else{
		strBaseHrefOrig=g_arrHeEditorStyles[className].strBaseHref
	}
	

	// save data in global object
	var newObj={
		strId:strId,
		className:className,
		lFlags:lFlags,
		strFormName:obj.strFormName,
		strElementName:obj.strElementName,
		strCssStyle:strCssStyle,
		lMarginWidth:obj.lMarginWidth?obj.lMarginWidth:g_arrHeEditorStyles[className].lMarginWidth,
		lMarginHeight:obj.lMarginHeight?obj.lMarginHeight:g_arrHeEditorStyles[className].lMarginHeight,
		strWidth:strWidth,
		strHeight:strHeight,
		bEditSource:false,
		bTableBorder:true,
		bInit:true,
		strAction:obj.strAction,
		strElementName:obj.strElementName,
		strFormName:obj.strFormName,
		lBlankCount:0,
		lFrameCount:0,
		customBtns:customBtns,
		strBaseHref:strBaseHref,
		strBaseHrefOrig:strBaseHrefOrig,
		"onLoad":obj.onLoad,
		"body":new Object(),
		"bLoaded":false,
		"strAPI":obj.strAPI?obj.strAPI:"html"
		};
	if(typeof(obj.customBtns)=="object"&&obj.customBtns.length>0){
		for(var i=0;i<obj.customBtns.length;i++){
			newObj.customBtns[newObj.customBtns.length]=obj.customBtns[i]
		}
	}
	if(obj.strPageSrc){
		newObj.strPageSrc=obj.strPageSrc
	}
	else {
		newObj.strValue=obj.strValue ? obj.strValue : ''
	}
	if(obj.strTextareaId)newObj.strTextareaId=obj.strTextareaId
	g_arrHtmlEdit[strId]=newObj
	g_lHeEditors++

	// mozilla wants editor creation code in another function, then the editor can be
	// accessed by getElementById()
	HtmlEditOutControlCode(strId)
}

// deprecated function. should not be used.
function HtmlEditCreateControl2(
    strId, strWidth, strHeight, strValue, lFlags,
    strFormName, strElementName, strAction, strTarget){
	var obj = new Object()
	obj.strId = strId
	obj.strWidth = strWidth
	obj.strHeight = strHeight
	obj.strValue = strValue
	obj.lFlags = lFlags
	obj.strFormName = strFormName
	obj.strElementName = strElementName
	obj.strAction = strAction
	obj.strTarget = strTarget
	HtmlEditCreateControlFromObj(obj)
}

function HtmlEditUpdateAllFormElements(){
	if(g_lUpdateTimer >= 0) window.clearTimeout(g_lUpdateTimer)
	for(var i in g_arrHtmlEdit){
		// form element?
		if((g_arrHtmlEdit[i].lFlags & g_lHeCModeMask)==g_lHeCModeFormElement){
			var strId = g_arrHtmlEdit[i].strId
			var obj = document.getElementById(strId + "_" + g_arrHtmlEdit[i].strElementName)
			if(obj){
				obj.value = HtmlEditGetDefContent(strId)
				if(g_arrHtmlEdit[i].strTextareaId && document.getElementById(g_arrHtmlEdit[i].strTextareaId))
					document.getElementById(g_arrHtmlEdit[i].strTextareaId).value = obj.value
			}
		}
	}
}

var g_arrContextData
function HtmlEditContextMenu(myEvent, strId){
	if(!myEvent) {
		if (window.event) 
			myEvent=window.event // ie6
		else
			myEvent=window.frames[0].event	// ie5.5
	}
	var element = (myEvent.target) ? myEvent.target : myEvent.srcElement
	if(myEvent.preventDefault) myEvent.preventDefault()
	var doc=HtmlEditGetDoc(strId)
	var win=HtmlEditGetDocParent(strId)
	var ctrl=document.getElementById(strId)
	var lefter2 = myEvent.clientX
	var topper2 = myEvent.clientY
	var str = ""
	var numitems = 0
	
	if (HtmlEditIsEditSrc(strId)) {
		if(is_ie){
			str+=
				HtmlEditGetMenuItem(g_strHeTextCut, (doc.queryCommandEnabled("Cut") ? "HtmlEditCmd('" + strId + "', 'Cut')" : null)) +
				HtmlEditGetMenuItem(g_strHeTextCopy, (doc.queryCommandEnabled("Copy") ? "HtmlEditCmd('" + strId + "', 'Copy')" : null)) +
				HtmlEditGetMenuItem(g_strHeTextPaste, (doc.queryCommandEnabled("Paste") ? "HtmlEditExecCmd('" + strId + "', 'Paste', false, null)" : null))
			numitems += 3
		}
		str+=
			HtmlEditGetMenuItem(g_strHeTextDelete, (doc.queryCommandEnabled("Delete") ? "HtmlEditCmd('" + strId + "', 'Delete')" : null)) +
			HtmlEditGetMenuItem(g_strHeTextSelectAll, (doc.queryCommandEnabled("SelectAll") ? "HtmlEditCmd('" + strId + "', 'SelectAll')" : null))
		numitems += 2
	}
	
	if(!HtmlEditIsEditSrc(strId)){
		if (numitems) {
			str+=HtmlEditGetMenuSeparator()
			numitems++
		}
	
		g_heElement = element
		if (!is_safari) {
			str += HtmlEditGetMenuItem(g_strHeTextRemoveFormats, (doc.queryCommandEnabled("RemoveFormat") ? "HtmlEditCmd('" + strId + "', 'RemoveFormat')" : null))
			numitems ++
		}
		str += HtmlEditGetMenuItem(g_strHeTextRemoveAllFormats, "HtmlEditRemoveAllFormats('" + strId + "')") +
			HtmlEditGetMenuItem(g_strHeTextRemoveLink, (doc.queryCommandEnabled("Unlink") ? "HtmlEditCmd('" + strId + "', 'Unlink')" : null))
		numitems += 2
		if (!is_safari) {
			str += HtmlEditGetMenuItem(g_strHeTextHyperlink, (doc.queryCommandEnabled("CreateLink") ? "HtmlEditLink('" + strId + "')" : null))
			numitems ++
		}
		else {
			var strTemp=new String(win.getSelection()+"")
			if(GetParentObjectByType(element, new Array("A")) || strTemp.length > 0){
				str += HtmlEditGetMenuItem(g_strHeTextHyperlink, "HtmlEditLink('" + strId + "')")
			}
			else{
				str += HtmlEditGetMenuItem(g_strHeTextHyperlink, null)
			}
			numitems ++
		}
		var bSep = false
		if(GetParentObjectByType(element, new Array("TABLE"))){
		    bSep = true
		    str = str +
				HtmlEditGetMenuSeparator() +
				HtmlEditGetMenuItem(g_strHeTextInsColBefore, "HtmlEditInsertColumnBefore('" + strId + "')") +
				HtmlEditGetMenuItem(g_strHeTextInsColAfter, "HtmlEditInsertColumnAfter('" + strId + "')") +
				HtmlEditGetMenuItem(g_strHeTextInsRowAbove, "HtmlEditInsertRowBefore('" + strId + "')") +
				HtmlEditGetMenuItem(g_strHeTextInsRowBelow, "HtmlEditInsertRowAfter('" + strId + "')") +
				HtmlEditGetMenuItem(g_strHeTextDelCol, "HtmlEditDeleteColumn('" + strId + "')") +
				HtmlEditGetMenuItem(g_strHeTextDelRow, "HtmlEditDeleteRow('" + strId + "')") +
				HtmlEditGetMenuItem(g_strHeTextDeleteTable, "HtmlEditDeleteTable()") +
				HtmlEditGetMenuItem(g_strHeTextTableProp, "HtmlEditTableProperties('" + strId + "')") +
				HtmlEditGetMenuItem(g_strHeTextCellProp, "HtmlEditCellProperties('" + strId + "')") +
				HtmlEditGetMenuItem("Merge with right cell", "HtmlEditMergeCellRight('" + strId + "')") +
				HtmlEditGetMenuItem("Merge with bottom cell", "HtmlEditMergeCellBottom('" + strId + "')")
		    numitems += 12
		}
		if(element.tagName=="IMG"){
		    bSep=true
		    str=str+
		        HtmlEditGetMenuSeparator()+
		        HtmlEditGetMenuItem(g_strHeTextImageProp, "HtmlEditImageProperties()")
		    numitems+=2
		}
		if(GetParentObjectByType(element, new Array("OL"), new Array("TD", "TH", "TABLE", "UL"))){
		    if(!bSep){ str = str + HtmlEditGetMenuSeparator(); numitems ++; bSep = true}
		    str=str+HtmlEditGetMenuItem(g_strHeTextOListProp, "HtmlEditOListProperties()")
		    numitems++
		}
		
		if(GetParentObjectByType(element, new Array("UL"), new Array("TD", "TH", "TABLE", "OL"))){
		    if(!bSep){ str = str + HtmlEditGetMenuSeparator(); numitems ++; bSep = true}
		    str = str + HtmlEditGetMenuItem(g_strHeTextUListProp, "HtmlEditUListProperties()")
		    numitems ++
		}
		if(g_arrHtmlEdit[strId].lFlags&g_lHeCEditPage){
		    str = str +
				HtmlEditGetMenuSeparator() +
				HtmlEditGetMenuItem(g_strHeTextPageProperties, "HtmlEditPageProperties('" + strId + "')")
		    numitems += 2
		}
	}
	
	g_arrContextData = new Array(str, numitems, lefter2, topper2, ctrl)
	window.setTimeout("HtmlEditContextTime()", 1)
	return false
}

function HtmlEditContextTime(){
	PopupSetContent(g_hePopup, HtmlEditGetMenuStart() + g_arrContextData[0] + HtmlEditGetMenuEnd())
	PopupShow(g_hePopup, g_arrContextData[2], 
		g_arrContextData[3], 
		160, 
		is_ie ? (18 * g_arrContextData[1] + g_strHeCssMenuBorderWidth * 2 - 2) : (18 * g_arrContextData[1]), 
		g_arrContextData[4]);
}

function HtmlEditResize(strId){
	var docheight,toolbarheight
	var statusbarheight=0
	toolbarheight=document.getElementById("hetoolbar_"+strId).offsetHeight
	if(document.getElementById("hestatusbar_"+strId)){
	    statusbarheight=document.getElementById("hestatusbar_" + strId).offsetHeight
	}
	if(window.innerHeight)
	    docheight=window.innerHeight
	else{
	    if(document.documentElement&&document.documentElement.clientHeight)
	        docheight=document.documentElement.clientHeight
	    else
	        docheight=document.body.clientHeight
	}
	docheight=docheight-toolbarheight-statusbarheight
	document.getElementById(strId).style.height=docheight+"px"
}

function HtmlEditPopulateFontListBox(strId) {
	var doc=HtmlEditGetDoc(strId)
	var arr=new Array()
	var fontList
	if(is_ie)fontList=document.all("hedropdown" + strId + "_FormatFont")
	else fontList=document.getElementById("hedropdown"+strId+"_FormatFont")
	if(fontList){
		var dlgObj=document.getElementById("heDlgHelper")
	    if(dlgObj&&(g_arrHtmlEdit[strId].lFlags & g_lHeCEnumSysFonts)){
	    	var count=dlgObj.fonts.Count
	        for(var i=1;i<count;i++) {
	        	var font=heDlgHelper.fonts(i)
	            if(dlgObj.getCharset(font)==g_lHeCharset)arr[arr.length]=font
	        }
			arr.sort()
			for(i=0;i<arr.length;i++){
				oOption=document.createElement("OPTION")
				oOption.text=arr[i]
				oOption.value=arr[i]
				if(is_ie)fontList.add(oOption)
				else fontList.appendChild(oOption)
			}
	    }
	}
}

// populate style drop down list box
function HtmlEditInitPopulateStyle(strId){
	var doc=HtmlEditGetDoc(strId)
	var arr=new Array()
	if (!document.getElementById("hedropdown" + strId + "_ApplyStyle")) return
	if (g_arrHtmlEdit[strId].styleSheetMain.length==0) return
	
	var bAllLoaded=true
	for (var j=0;j<g_arrHtmlEdit[strId].styleSheetMain.length;j++){
		if(g_arrHtmlEdit[strId].styleSheetMain[j]) {
			var rules=new Array()
			var e
			try {
				// may failed because stylesheet is in other domain
				rules=StyleSheetGetRulesArray(g_arrHtmlEdit[strId].styleSheetMain[j])
			}catch(e){}
			if (rules.length<=0) {
				bAllLoaded=false
				break
			}
		}
	}
	
	// not loaded yet. try again later
	if (!bAllLoaded) {
		if(g_arrHtmlEdit[strId].lCssCheck < g_lTimeOutCss*1000/200){
			window.setTimeout("HtmlEditInitPopulateStyle('" + strId + "')", 200)
			g_arrHtmlEdit[strId].lCssCheck ++
			return
		}
		// tried too many times, just continue and populate the box
	}
	
	// populate style drop down list box
	for (var j=0;j<g_arrHtmlEdit[strId].styleSheetMain.length;j++){
		if (!g_arrHtmlEdit[strId].styleSheetMain[j])continue
		var rules=new Array()
        var e
        try {
			// may failed due to security issue (eg. stylesheet is in another domain)
			rules=StyleSheetGetRulesArray(g_arrHtmlEdit[strId].styleSheetMain[j])
        }catch(e){}
		var obj=document.getElementById("hedropdown" + strId + "_ApplyStyle")
		for(var i=0;i<rules.length;i++){
		    var selector=rules[i].selectorText
		    if(selector.indexOf(",")<0 &&
		        selector.indexOf(" ")<0 &&
		        selector.charAt(0)=="."){
		        arr[arr.length] = new String(selector.substring(1,selector.length))
		    }
		}
	}
	arr.sort()
	for(i = 0; i < arr.length; i ++){
		oOption = document.createElement("OPTION")
		oOption.text = arr[i]
		oOption.value = arr[i]
		if(document.all)
			obj.add(oOption)
		else
			obj.appendChild(oOption)
	}
}

function HtmlEditPrepareUpdate(strId){
	HtmlEditHideAllPopup()
	if(g_lUpdateTimer>=0)window.clearTimeout(g_lUpdateTimer)
	g_lUpdateTimer=window.setTimeout(new Function("HtmlEditUpdate('"+strId+"')"),160)
}

// trace thru all tool bar buttons and update them
function HtmlEditUpdateBtnState(obj,strElement){
	var i
	if(obj.id){
		var id = obj.id
		if(id.substring(0, 5)=="hebtn" /*&& id.indexOf("_i_") > 0 */&& id.indexOf(strElement) > 0){
		    var pos = id.indexOf("_i_")
		    var str = id.substr(pos + 3, id.length - pos - 3)
		    HtmlEditDrawBtn(obj, "")
		}
	}
	if(obj.tagName=="DIV"||obj.tagName=="NOBR"){
		if(obj.childNodes && obj.childNodes.length)
			for(i=0; i<obj.childNodes.length; i++)
		    	HtmlEditUpdateBtnState(obj.childNodes.item(i), strElement)
	}
}

function HtmlEditUpdate(strId){
	var doc=HtmlEditGetDoc(strId)
	if(!doc)return
	if(!g_arrHtmlEdit[strId])return
	var i
	var count = 0
	// force IE to use <div> tag if editor contains nothing
	if(is_ie){
	    if(g_arrHtmlEdit[strId].lFlags&g_lHeCUseDivForIE){
			var str=new String(HtmlEditGetContent(strId,true))
			str=Trim(str)
			str=str.toLowerCase()
			if(!g_arrHtmlEdit[strId].bEditSource && (str=="" || str=="<p>&nbsp;</p>")){
				HtmlEditCmd(strId,"SelectAll")
				HtmlEditCmd(strId,"Delete")
				HtmlEditExecCmd(strId,"FormatBlock",false,"<div>")
			}
	    }
	}
	// button states
	var obj=document.getElementById('hetoolbar_'+strId)
	if(obj&&obj.childNodes)for(i=0;i<obj.childNodes.length;i++)HtmlEditUpdateBtnState(obj.childNodes.item(i),strId)
	
	// update formatting
	obj=document.getElementById("hedropdown"+strId+"_FormatBlock")
	if(obj){
		var rng=RangeGetCurrent(HtmlEditGetDocParent(strId))
		var node=null
		if(rng){
			node=RangeGetParentNode(rng)
			node=GetParentObjectByType(node,['P','DIV','PRE','H1','H2','H3','H4','H5','H6'],['td','th'])
		}
		if(node){
			var tagName=node.tagName
			var selected=0
			if(is_ie){
				if(node.className)tagName=tagName+"."+node.className
			}
			else{
				if(node.getAttribute('class'))tagName=tagName+"."+node.getAttribute('class')
			}
			for(var i=0;i<obj.options.length;i++){
				if(obj.options[i].value==tagName){
					selected=i
					break
				}
			}
			obj.selectedIndex=selected
		}
	}

	// size
	obj=document.getElementById("hedropdown"+strId+"_FormatSize")
	if(obj){
		var str=doc.queryCommandValue('FontSize')
		var bFound=false
		if(str){
		    for(i = 0; i < obj.options.length; i ++){
		        if(obj.options[i].value==str){
		            obj.selectedIndex = i
		            bFound = true
		            break
		        }
			}
		}
		if(!bFound)obj.selectedIndex=0
	}
	// font name
	obj=document.getElementById("hedropdown"+strId+"_FormatFont")
	if(obj){
		var str=doc.queryCommandValue('FontName')
		var bFound=false
		if(str){
		    for(i = 0; i < obj.options.length; i ++){
				var str2=obj.options[i].value
				str2=str2.toLowerCase()
				str=str.toLowerCase()
				if(str2==str){
				    obj.selectedIndex=i
				    bFound=true
				    break
				}
		    }
		}
		if(!bFound)obj.selectedIndex=0
	}
	// insert/overwrite
	if(is_ie){
		obj=document.getElementById("hestatus_"+strId+"_insert")
		if(obj)obj.style.color = (doc.queryCommandState("OverWrite")) ? "graytext" : "windowtext"
	}
	
	// style
	var rng=RangeGetCurrent(HtmlEditGetDocParent(strId))
	obj=document.getElementById("hedropdown"+strId+"_ApplyStyle")
	if(rng&&obj){
		var node = RangeGetParentNode(rng)
		var className = null
		var bFound = false
		while(node && !bFound){
		    if(is_ie)
		        className = node.className
		    else if(node.getAttribute)
		        className = node.getAttribute("class")
		    if(className){
				for(i = 0; i < obj.options.length; i ++){
				    if(obj.options[i].value==className){
						obj.selectedIndex=i
						bFound=true
						break
				    }
				}
		    }
		    node=is_ie?node.parentElement:node.parentNode
		}
		if(!bFound)obj.selectedIndex=0
	}
}

function HtmlEditPopupInsertCode(strId, content){
	HtmlEditHideAllPopup()
	HtmlEditFocus(strId)
	HtmlEditInsertCode(strId,content)
}

// parse event information for different browsers
function HtmlEditGetEventObj(event){
	var obj=new Object()
	// gecko pass event object to event handler
	if(!event) {
		if(window.event) 
			event=window.event // ie6
		else
			event=window.frames[0].event // ie5.5
	}	
	obj.target=(event.target)?event.target:event.srcElement
	obj.targetId=obj.target.id
	obj.clientX=event.clientX
	obj.clientY=event.clientY
	var pos=obj.targetId.lastIndexOf("_")
	if(obj.targetId.substring(0,5)=="hebtn" && pos > 0)
		obj.editorId=obj.targetId.substr(5,pos-5)
	else
		return false
	return obj
}

function HtmlEditInsertSymbol(event){
	var eventObj=HtmlEditGetEventObj(event)
	
	// toolbar offset relative to the page
	var lefter2=0
	var topper2=24
	
	var numitems=g_arrHeCharacterList.length
	g_heElement=null
	var str=new String()
	for(var i = 0; i < g_arrHeCharacterList.length; i ++){
		str = str + HtmlEditGetMenuItem(
		    g_arrHeCharacterList[i],
		    HtmlSpecialChars("HtmlEditPopupInsertCode('"+eventObj.editorId+"', '"+g_arrHeCharacterList[i]+"')"))
	}
	PopupSetContent(g_hePopup, HtmlEditGetMenuStart() + str + HtmlEditGetMenuEnd())
	PopupShow(
		g_hePopup, 
		lefter2, 
		topper2, 
		g_lSymbolMenuWidth, 
		(is_ie ? (18 * numitems + g_strHeCssMenuBorderWidth * 2 - 2) : (18 * numitems)), 
		eventObj.target)
	return false
}

function HtmlEditGetMenuStart(){
    return "<div oncontextmenu=\"return false\" style=\"position: relative; top:0; left:0; border:"+g_strHeCssMenuBorderWidth+"px solid "+g_strHeCssMenuBottomRight+";  border-top:"+g_strHeCssMenuBorderWidth+"px solid "+g_strHeCssMenuTopLeft+"; border-left:"+g_strHeCssMenuBorderWidth+"px solid "+g_strHeCssMenuTopLeft+"; background: "+g_strHeCssMenuBack+"; height:100%; width:100%; \">\n"
}

// strItem - htmlentities encoded menu item text
// strAction - htmlentities encoded text that called a single javascript function
function HtmlEditGetMenuItem(strItem, strAction){
	var strParent
	if(window.createPopup)
	    strParent = "parent."
	else
	    strParent = ""
	if(strAction)
	    str =
	        "<div unselectable=on style=\"position:relative; top:0px; left:0px; background:" + g_strHeCssMenuBack + "; height:" + (is_ie ? 18 : 16) + "px; color:windowtext; font-family:sans-serif; padding: 0px 0px 0px 10px; margin: 0px 2px 0px 2px; font-size:8pt; cursor:pointer; border: 1px solid " + g_strHeCssMenuBack + ";\" "
	        + "onmouseover=\"this.style.background='"+g_strHeCssMenuUBack+"'; this.style.color='"+g_strHeCssMenuUText+"'; this.style.borderLeftColor = '"+g_strHeCssMenuUTopLeft+"'; this.style.borderTopColor = '"+g_strHeCssMenuUTopLeft+"'; this.style.borderRightColor = '"+g_strHeCssMenuUBottomRight+"'; this.style.borderBottomColor = '"+g_strHeCssMenuUBottomRight+"'\"; "
	        + "onmouseout=\"this.style.background='"+g_strHeCssMenuBack+"'; this.style.color='"+g_strHeCssMenuText+"'; this.style.borderLeftColor = '"+g_strHeCssMenuBack+"'; this.style.borderTopColor = '"+g_strHeCssMenuBack+"'; this.style.borderRightColor = '"+g_strHeCssMenuBack+"'; this.style.borderBottomColor = '"+g_strHeCssMenuBack+"'\";\" "
			+ "onmousedown=\"return false\" "
	        + "onclick=\"" + strParent + strAction + "\""
	else
	    str = "<div style=\"position:relative; top:0px; left:0px; background:" + g_strHeCssMenuBack + "; height:" + (is_ie ? 18 : 16) + "px; color:" + g_strHeCssMenuGrayText + "; font-family:sans-serif; padding: 0px 0px 0px 10px; margin: 0px 2px 0px 2px; border: 1px solid " + g_strHeCssMenuBack + "; font-size:8pt;\" "
	return str + ">" + strItem + "</div>\n"
}

function HtmlEditGetMenuSeparator(){
	return "<div unselectable=on style=\"position:relative; top:0px; left:0px; background: " + g_strHeCssMenuBack + "; height: " + (is_ie ? 18 : 16) + "px; padding: 0px 0px 0px 10px; margin: 0px 2px 0px 2px; border: 1px solid " + g_strHeCssMenuBack + ";\">"
	+"<table cellpadding=0 cellspacing=0 border=0 width=98%>"
	+"<tr><td height=5></td></tr>"
	+"<tr><td height=1 style=\"background-color: " + g_strHeCssMenuSeparatorTop + ";\"></td></tr>"
	+"<tr><td height=1 style=\"background-color: " + g_strHeCssMenuSeparatorBottom + ";\"></td></tr>"
	+"</table></div>"
}

function HtmlEditGetMenuEnd(){return"</div>"}

var g_heBodyAttrs={
"ACCESSKEY":true,"ALINK":true,"BACKGROUND":true,"BGCOLOR":true,
"BGPROPERTIES":true,"BOTTOMMARGIN":true,"CLASS":true,"ID":true,
"LANG":true,"LEFTMARGIN":true,"LINK":true,"RIGHTMARGIN":true,
"SCROLL":true,"STYLE":true,"TABINDEX":true,"TEXT":true,
"TITLE":true,"TOPMARGIN":true,"VLINK":true,"MARGINWIDTH":true,
"MARGINHEIGHT":true
}
var g_heBodyAttrsSkip={
"DISABLED":true,"CONTENTEDITABLE":true,"HIDEFOCUS":true,"TABINDEX":true,"NOWRAP":true
}
function HtmlEditGetPage(strId){
	var doc=HtmlEditGetDoc(strId)
	if(doc&&doc.body){
		// change back to editing mode
		if(HtmlEditIsEditSrc(strId))HtmlEditSrc(strId)
		var attrs=""
		var str="<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n"
		str+="<html>\n<head>\n"
		str+="<title>"+HtmlSpecialChars(doc.title)+"</title>\n"
		var charset = (document.characterSet) ? document.characterSet : document.charset
		str+="<meta HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; CHARSET=" + charset + "\" />\n"
		str+="<base href=\""+g_arrHtmlEdit[strId].strBaseHref+"\" />\n"
		if (g_arrHtmlEdit[strId].strPageSrc&&g_arrHtmlEdit[strId].bFrameLoaded) {
			var e,obj
			try{obj=HtmlEditGetDoc(strId + "_iframe")}
			catch (e){}
			if(obj){
				var styles=obj.getElementsByTagName("link")
				for (var j=0;j<styles.length;j++){
					if (styles[j].getAttribute("rel") == "stylesheet" &&
						styles[j].getAttribute("href")) {
						str+="<link rel=\"stylesheet\" type=\"text/css\" href=\""+styles[j].getAttribute("href")+"\" />\n"
					}
				}
				var metas=obj.getElementsByTagName("meta")
				for (var j=0;j<metas.length;j++){
					if (metas[j].getAttribute("name")) {
						str+="<meta name=\""+metas[j].getAttribute("name")+"\" content=\""+metas[j].getAttribute("content")+"\" />\n"
					}
				}
				// get body attributes not set by editor
				for(var i=0;i<obj.body.attributes.length;i ++){
					if(obj.body.attributes[i].value &&
						obj.body.attributes[i].value.length &&
						obj.body.attributes[i].value!="null"){
						var strName=new String(obj.body.attributes[i].name)
						strName=strName.toUpperCase()
						if(typeof(g_heBodyAttrs[strName])=="undefined"&&
							typeof(g_heBodyAttrsSkip[strName])=="undefined"){
							attrs+=" "+obj.body.attributes[i].name+"=\""+HtmlSpecialChars(obj.body.attributes[i].value)+"\""
						}
					}
				}
			}
		}
		if(g_arrHtmlEdit[strId].strCssStyle){
			str+="<link rel=\"stylesheet\" type=\"text/css\" href=\""+g_arrHtmlEdit[strId].strCssStyle+"\" />\n"
		}
		str+="</head>\n<body"+attrs
		// copy body attributes in editor
		for(var i=0;i<doc.body.attributes.length;i ++){
			// ie attributes array contains all everything, even not defined in HTML.
			if(doc.body.attributes[i].value&&
				doc.body.attributes[i].value.length&&
				doc.body.attributes[i].value!="null"){
				var strName=new String(doc.body.attributes[i].name)
				strName=strName.toUpperCase()
				if(typeof(g_heBodyAttrs[strName])!="undefined"&&
					typeof(g_heBodyAttrsSkip[strName])=="undefined"){
					str+=" "+doc.body.attributes[i].name+"=\""+HtmlSpecialChars(doc.body.attributes[i].value)+"\""
				}
			}
		}
		str=str+">\n"
		str=str+HtmlEditGetContent(strId)
		str=str+"\n</body>\n</html>\n"
		return str
	}
	return ""
}

function HtmlEditGetContent(strId,bFast){
	var doc=HtmlEditGetDoc(strId)
	if(doc&&doc.body){
		if(g_arrHtmlEdit[strId].bEditSource){
		    if(is_ie)return doc.body.innerText
		    else{
		    	var str
		    	// convert "1234<br>5678" to "1234 5678" in source mode.
		    	// otherwise, firefox return text of it to "12345678" instead of "1234 5678"
		    	var div = document.getElementById("heDummyDiv_"+strId)
		    	str = doc.body.innerHTML
		    	div.innerHTML = str.replace(/<br[^>]*>/ig, "\n")
		        var html = document.body.ownerDocument.createRange()
		        html.selectNodeContents(div);
				//var html = doc.body.ownerDocument.createRange()
				//html.selectNodeContents(doc.body);
		        str=html.toString()
		        // convert all nbsp to normal space if in source mode
		        // otherwise, they will be converted to &nbsp; in firefox
				str=str.replace(new RegExp(String.fromCharCode(160),"g")," ")
				return str
		    }
		}
		else{
		    if(bFast||(is_ie&&g_heBrowser.version<6)||
				((g_arrHtmlEdit[strId].lFlags&g_lHeCXHTMLSource)==0)&&g_arrHtmlEdit[strId].strBaseHrefOrig.length==0) {				
		        return doc.body.innerHTML
			}
		    else {
		        return GetInnerHtmlFromNode(doc.body,g_arrHtmlEdit[strId].strBaseHrefOrig,(g_arrHtmlEdit[strId].lFlags&g_lHeCEnableSafeHtml))
			}
		}
	}
	return ''
}

function HtmlEditGetDefContent(strId){return((g_arrHtmlEdit[strId].lFlags&g_lHeCEditPage)?HtmlEditGetPage(strId):HtmlEditGetContent(strId))}

function HtmlEditSetInsertPoint(strId, bStart){
	var doc = HtmlEditGetDoc(strId)
	if(doc && doc.body){
	    if(is_gecko){
			var sel=document.getElementById(strId).contentWindow.getSelection()
			sel.removeAllRanges()
			var range=doc.createRange()
			
			if(doc.body.childNodes.length > 0){
			    var container = doc.body
			    var pos = 0
			
			    container = bStart ? doc.body.childNodes[0] : doc.body.childNodes[doc.body.childNodes.length - 1]
			    if(container.nodeType==3 ||
					container.tagName=="H1" ||
					container.tagName=="H2" ||
					container.tagName=="H3" ||
					container.tagName=="H4" ||
					container.tagName=="H5" ||
					container.tagName=="H6" ||
					container.tagName=="P" ||
					container.tagName=="DIV"
					){
			        range.setStart(container, 0)
			        range.setEnd(container, 0)
			        // cant set to end!
			    }
			    else{
			        if(bStart){
			            range.setStartBefore(container)
			            range.setEndBefore(container)
			        }
			        else{
			            range.setStartAfter(container)
			            range.setEndAfter(container)
			        }
			    }
			}
			else{
			    range.selectNodeContents(doc.body)
			}
			sel.addRange(range)
	    }
	    else if(is_ie){
	        var range = doc.body.createTextRange()
	        range.collapse(bStart)
	        range.select()
	    }
	}
}

function HtmlEditSetContent(strId, strContent){
	var doc=HtmlEditGetDoc(strId)
	if(doc&&doc.body){
		var str
		if(g_arrHtmlEdit[strId].bEditSource){
			str = new String(HtmlSpecialChars(Trim(strContent)))
			// convert all forms of EOLN to single linefeed, then convert to br tag
			str = str.replace(/\r\n/g, "\n")
			str = str.replace(/\r/g, "\n")
			str = str.replace(/\n\n/g, "\n")
			str = str.replace(/[ ]+\n/g, "<br />")
			str = str.replace(/\n/g, "<br />")
			// remove excessive linebreak
			str = str.replace(/(<br \/>)+/g, "<br />")
		}
		else{
			str = strContent
			str = str.replace(/\r\n/g, "\n")
			str = str.replace(/\r/g, "\n")
			str = str.replace(/[\n]+/g, "\n")
		}
		
		// for gecko browsers, strValue will be copied to editor
		// for the first focus and therefore better to sync this
		// value when this function is called.
		// g_arrHtmlEdit[strId].strValue = str
		
		// NOTE1: midas not working properly after using innerHTML method for setting content.
		// using execCommand instead (but need to avoid focus problem that cause
		// page scrolling)
		
		// NOTE2: midas href not work properly with HtmlEditInsertCode() if base href is specified.
		// anyway, problem mentioned in note 1 seemed to be solved under firefox.
		if(is_safari||is_ie){
			doc.body.innerHTML=str
		}
		else if(is_gecko){
			doc.body.innerHTML=""
			HtmlEditInsertCode(strId,str)
		}
		HtmlEditSetInsertPoint(strId,true)
		HtmlEditFocus(strId)
	}
}

function HtmlEditInsertColumnBefore(strId){
	HtmlEditTableColumnOp(strId, "insert_before", null)
}

function HtmlEditInsertColumnAfter(strId){
	HtmlEditTableColumnOp(strId, "insert_after", null)
}

function HtmlEditInsertRowBefore(strId){
	HtmlEditTableRowOp(strId, "insert_before", null)
}

function HtmlEditInsertRowAfter(strId){
	HtmlEditTableRowOp(strId, "insert_after", null)
}

function HtmlEditDeleteColumn(strId) {
	HtmlEditTableColumnOp(strId, "delete_column", null)
}

function HtmlEditDeleteRow(strId){
	HtmlEditTableRowOp(strId, "delete_row", null)
}

function HtmlEditMergeCellRight(strId) {
	var obj = HtmlEditCellMergeSub(strId)
	var e=GetParentObjectByType(g_heElement, new Array("TD", "TH"))
	var table=GetParentObjectByType(g_heElement, new Array("TABLE"))

	if (!obj.bFound) {
		alert("Unable to merge cell due to unexpected error.")
		return		
	}
	
	var nextX = obj.cellX + obj.arrCells[obj.cellY][obj.cellX].colspan
	var nextY = obj.cellY
	
	if (typeof(obj.arrCells[nextY]) == "undefined" ||
		typeof(obj.arrCells[nextY][nextX]) == "undefined") {
		alert("There is no cell to merge with.")
		return
	}
	
	if (obj.arrCells[obj.cellY][obj.cellX].rowspan != obj.arrCells[nextY][nextX].rowspan) {
		alert("Next cell has different dimension.")
		return
	}

	var newColSpan = obj.arrCells[obj.cellY][obj.cellX].colspan + obj.arrCells[nextY][nextX].colspan
	obj.arrCells[nextY][nextX].cell.parentNode.removeChild(obj.arrCells[nextY][nextX].cell)
	e.colSpan = newColSpan
	
	// IE wont readjust table after above DOM operations.
	// get around it by take out the table and reinsert it.
	if (is_ie) {
		var content=table.outerHTML
		table.parentNode.removeChild(table)
		HtmlEditInsertCode(strId, content)
	}
}

function HtmlEditMergeCellBottom(strId) {
	var obj = HtmlEditCellMergeSub(strId)
	var e=GetParentObjectByType(g_heElement, new Array("TD", "TH"))
	var table=GetParentObjectByType(g_heElement, new Array("TABLE"))

	if (!obj.bFound) {
		alert("Unable to merge cell due to unexpected error.")
		return		
	}
	
	var nextX = obj.cellX
	var nextY = obj.cellY + obj.arrCells[obj.cellY][obj.cellX].rowspan
	
	if (typeof(obj.arrCells[nextY]) == "undefined" ||
		typeof(obj.arrCells[nextY][nextX]) == "undefined") {
		alert("There is no cell to merge with.")
		return
	}

	if (obj.arrCells[obj.cellY][obj.cellX].colspan != obj.arrCells[nextY][nextX].colspan) {
		alert("Next cell has different dimension.")
		return
	}
	
	var newRowSpan = obj.arrCells[obj.cellY][obj.cellX].rowspan + obj.arrCells[nextY][nextX].rowspan
	obj.arrCells[nextY][nextX].cell.parentNode.removeChild(obj.arrCells[nextY][nextX].cell)
	e.rowSpan = newRowSpan
	
	// IE wont readjust table after above DOM operations.
	// get around it by take out the table and reinsert it.
	if (is_ie) {
		var content=table.outerHTML
		table.parentNode.removeChild(table)
		HtmlEditInsertCode(strId, content)
	}
}

function HtmlEditDeleteTable(){
	HtmlEditHideAllPopup()
	var table=GetParentObjectByType(g_heElement, new Array("TABLE"))
	if (table) {
		table.parentNode.removeChild(table)
	}
}

function HtmlEditDblClick(myEvent, strId){
	if(!myEvent) {
		if (window.event) 
			myEvent=window.event // ie6
		else
			myEvent=window.frames[0].event	// ie5.5
	}
	var element = (myEvent.target) ? myEvent.target : myEvent.srcElement
	
	if(myEvent.preventDefault)myEvent.preventDefault()
	
	doc=HtmlEditGetDoc(strId)
	var ctrl=document.getElementById(strId)
	
	if(element.tagName=="IMG"){
	    g_heElement=element
		if (is_ie) {
		 	HtmlEditImageProperties(strId)
		}
		else {
			window.setTimeout("HtmlEditImageProperties('"+strId+"')", 1)
		}		
	}
	else {
		g_heElement=GetParentObjectByType(element, new Array("A"))
		if(g_heElement){
		    g_heElement = element
		    if (is_ie) {
				HtmlEditLink(strId)
		    }
		    else {
				window.setTimeout("HtmlEditLink('" + strId + "')", 1)
		    }
		}
		else {
			g_heElement=null
		}
	}
}

function HtmlEditCreatePopupsSub(strId){
	var i,j,strParent,str
	
	// obj for enum sys font
	if(is_ie6up)document.write("<object id=\"heDlgHelper\" CLASSID=\"clsid:3050f819-98b5-11cf-bb82-00aa00bdce0b\" width=\"0px\" height=\"0px\" style=\"position: absolute; left: 0px; top: 0px;\"></object>")
	
	// color dialog
	var arrColor=new Array(
		new Array("ff0000","400000","800000","c00000","ff4040","ff8080","ffc0c0","000000"),
		new Array("ff8000","402000","804000","c06000","ffa040","ffc080","ffe0c0","171717"),
		new Array("ffff00","404000","808000","c0c000","ffff40","ffff80","ffffc0","2e2e2e"),
		new Array("80ff00","204000","408000","60c000","a0ff40","c0ff80","e0ffc0","464646"),
		new Array("00ff00","004000","008000","00c000","40ff40","80ff80","c0ffc0","5d5d5d"),
		new Array("00ff80","004020","008040","00c060","40ffa0","80ffc0","c0ffe0","747474"),
		new Array("00ffff","004040","008080","00c0c0","40ffff","80ffff","c0ffff","8b8b8b"),
		new Array("0080ff","002040","004080","0060c0","40a0ff","80c0ff","c0e0ff","a2a2a2"),
		new Array("0000ff","000040","000080","0000c0","4040ff","8080ff","c0c0ff","b9b9b9"),
		new Array("8000ff","200040","400080","6000c0","a040ff","c080ff","e0c0ff","d1d1d1"),
		new Array("ff00ff","400040","800080","c000c0","ff40ff","ff80ff","ffc0ff","e8e8e8"),
		new Array("ff0080","400020","800040","c00060","ff40a0","ff80c0","ffc0e0","ffffff"));
	str="";
	strParent=(!g_heColor.bDiv)?"parent.":''
	for(i=0;i<arrColor.length;i++){
	    for(j=0;j<arrColor[i].length;j++){
	        var coords=(j*13)+","+(i*7)+","+((j+1)*13)+","+((i+1)*7)
	        str=str+"<area shape=\"rect\" coords=\""+coords
	            +"\" onclick=\"javascript: "+strParent+"HtmlEditColorReturn('#"+arrColor[i][j]+"')\" title=\"#"+arrColor[i][j]+"\" "
				+"onmousedown=\"return false\" "
				+"/>"
	    }
	}
	PopupSetContent(g_heColor,
	    HtmlEditGetMenuStart() +
	    "<map name=\"colormap\">" + str +"</map>" +
	    "<img src="+g_strHtmlEditPath+"htmleditimg/colortable.gif width=104 height=84 alt=\"\" border=0 usemap=\"#colormap\" style=\"cursor: pointer;\" />" +
	    HtmlEditGetMenuEnd())
	
	// symbol popup
	var numitems = g_arrHeCharacterList.length
	strParent=(!g_heSymbol.bDiv)?"parent.":''
	str=""
	for(i=0;i<g_arrHeCharacterList.length;i++)
	    str=str+HtmlEditGetMenuItem(g_arrHeCharacterList[i],strParent+"HtmlEditPopupInsertCode('" + strId + "', '" + g_arrHeCharacterList[i] + "')")
	PopupSetContent(g_heSymbol,HtmlEditGetMenuStart()+str+HtmlEditGetMenuEnd())
}

function HtmlEditRemoveAllFormats(strId) {
	var doc=HtmlEditGetDoc(strId)
	if(doc&&doc.body)HtmlEditSetContent(strId, GetCleanCode(doc.body))
	HtmlEditHideAllPopup()
}

function HtmlEditIsLoaded(strId){
	return g_arrHtmlEdit[strId]?g_arrHtmlEdit[strId].bLoaded:false
}

function HtmlEditIsModified(strId) {
	if (g_arrHtmlEdit[strId]) {
		var strContent=HtmlEditGetContent(strId, true)
		return strContent!=g_arrHtmlEdit[strId].strValue
	}
	return false 
}
