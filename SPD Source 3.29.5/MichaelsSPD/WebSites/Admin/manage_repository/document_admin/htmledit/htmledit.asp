<%
' File:         htmledit.asp
' Programmer:   John Wong
' Description:  ASP helper class to create QWebEditor control
' Product:      QWebEditor 2.0
' History:
'   20030928JW
'       Initial Version
'   20040113JW
'       Added methods, constant to access features from previous 3.00 prereleases
'       Added method SetContentFromFile to load content from a file in server
' Copyright (c) Q-Surf Computing Solutions, 2003-05. All rights reserved.
' http://www.q-surf.com

const HeCModeMask = 3
const HeCModeFormElement = 0
const HeCModeStandaloneForm = 1
const HeCModeStandaloneDialog = 2
const HeCDisableParagraph = 8
const HeCDisableFontSize = 16
const HeCDisableFontName = 32
const HeCDisableNewBtn = 64
const HeCDisableCutCopyPasteBtn = 128
const HeCDisableUndoRedoBtn = 256
const HeCDisableSourceBtn = 512
const HeCDisableForeColor = 1024
const HeCDisableBackColor = 2048
const HeCDisableAlignBtn = 4096
const HeCDisableTableBtn = 8192
const HeCDisableImageBtn = 16384
const HeCEnumSysFonts = 32768
const HeCBorder = 65536
const HeCDetectPlainText = 131072
const HeCDisableStyleBox = 262144
const HeCDisableStatusBar = 524288
const HeCToTextIfFail = 1048576
const HeCEditPage = 2097152
const HeCDisableFormattingBtns1 = 4194304
const HeCDisableFormattingBtns2 = 8388608
const HeCDisableFormattingBtns3 = 16777216
const HeCDisableLinkBtn = 33554432
const HeCDisableHorizontalRuleBtn = 67108864
const HeCDisableSymbolBtn = 134217728
const HeCXHTMLSource = 268435456
const HeCUseDivForIE = 536870912
const HeCEnableSafeHtml = 1073741824
const HeCDisableIncDecFontSizeBtns = 2147483648

const HECEnableMergedImageDialog = 1

Const ForReading = 1, ForWriting = 2, ForAppending = 3
Const TristateUseDefault = -2, TristateTrue = -1, TristateFalse = 0

dim g_strHeThemeFile
dim g_dwHeFlags
dim g_hebrowser
dim g_lNumControl

set g_hebrowser = new BrowserSniffer
g_dwHeFlags = 0

class QWebEditor

	dim m_strCtrlName
	dim m_strWidth
	dim m_strHeight
	dim m_strContent
	dim m_dwFlags
	dim m_dwMask
	dim m_strFormName
	dim m_strElementName
	dim m_strFormActionUrl
	dim m_strFormTarget
	dim m_strCssFile
	dim m_strPageSrc
	dim m_lTabIndex
	dim m_lMarginWidth
	dim m_lMarginHeight
	dim m_strBaseHref
	dim m_strOnLoadHandler
	dim m_customBtns()
	dim m_className
	
	private sub Class_Initialize()
		m_strCtrlName = ""
		m_strWidth = ""
		m_strHeight = ""
		m_strContent = ""
		m_dwFlags = 0
		m_dwMask = 0
		m_strFormName = ""
		m_strElementName = ""
		m_strFormActionUrl = ""
		m_strFormTarget = ""
		m_strCssFile = ""
		m_strPageSrc = ""
		m_lTabIndex = ""
		m_lMarginWidth = ""
		m_lMarginHeight = ""
		m_strBaseHref = ""
		m_strOnLoadHandler = ""
		redim m_customBtns(2,0)
		m_className = ""
	end sub
	
	private sub EnableFlag(flag, a_bEnable)
		m_dwFlags = (m_dwFlags and not flag)
		if a_bEnable then
			m_dwFlags = m_dwFlags or flag
		end if
		m_dwMask = m_dwMask or flag
	end sub
	
	private function AddCSlashes(strText)
		dim mystr
		dim i
	
		mystr = strText
		mystr = replace(mystr, "\", "\\")
		mystr = replace(mystr, chr(34), "\" & chr(34))
		mystr = replace(mystr, "'", "\'")
		mystr = replace(mystr, vbCr, "\r")
		mystr = replace(mystr, vbLf, "\n")
		mystr = replace(mystr, vbTab, "\t")
		for i = 0 to 31
			if chr(i) <> vbLf and chr(i) <> vbCr and chr(i) <> vbTab then
				mystr = replace(mystr, chr(i), "\" & oct(i))
			end if
		next
		AddCSlashes = mystr
	end function
	
	private function QuoteStr(strText)
		QuoteStr = chr(34) & AddCSlashes(strText) & chr(34)
	end function
	
	private function HtmlSpecialChars(strText)
		dim mystr
		
		mystr = strText
		mystr = replace(mystr, "&", "&amp;")
		mystr = replace(mystr, "<", "&lt;")
		mystr = replace(mystr, ">", "&gt;")
		mystr = replace(mystr, chr(34), "&quot;")
	
		HtmlSpecialChars = mystr
	end function
	
	public sub SetCtrlName(a_strCtrlName)
		m_strCtrlName = a_strCtrlName
	end sub
	
	public sub SetWidth(a_strWidth)
	   m_strWidth = a_strWidth
	end sub
	
	public sub SetHeight(a_strHeight)
		m_strHeight = a_strHeight
	end sub
	
	public sub SetContent(a_strContent)
		m_strContent = a_strContent
	end sub
	
	public sub SetContentFromFile(a_strFileName)
		Dim FSO
		set FSO = server.createObject("Scripting.FileSystemObject")
	
		' Map the logical path to the physical system path
		Dim Filepath
		Filepath = Server.MapPath(a_strFileName)
	
		if FSO.FileExists(Filepath) Then
			dim TextStream
			Set TextStream = FSO.OpenTextFile(Filepath, ForReading, False, TristateUseDefault)
			' Read file in one hit
			m_strContent = TextStream.ReadAll
			TextStream.Close
			Set TextStream = nothing
		End If
	end sub
	
	public sub SetContentFromUrl(a_strUrl)
		m_strPageSrc = a_strUrl
	end sub
	
	public sub SetTabIndex(a_lIndex)
		m_lTabIndex = a_lIndex
	end sub
	
	public sub SetFlags(a_dwFlags)
		m_dwFlags = a_dwFlags
	end sub
	
	public sub EnableParagraphBox(a_bEnable)
		call EnableFlag(HeCDisableParagraph, not a_bEnable)
	end sub
	
	public sub EnableFontSizeBox(a_bEnable)
		call EnableFlag(HeCDisableFontSize, not a_bEnable)
	end sub
	
	public sub EnableFontNameBox(a_bEnable)
		call EnableFlag(HeCDisableFontName, not a_bEnable)
	end sub
	
	public sub EnableNewBtn(a_bEnable)
		call EnableFlag(HeCDisableNewBtn, not a_bEnable)
	end sub
	
	public sub EnableCutCopyPasteBtn(a_bEnable)
		call EnableFlag(HeCDisableCutCopyPasteBtn, not a_bEnable)
	end sub
	
	public sub EnableUndoRedoBtn(a_bEnable)
		call EnableFlag(HeCDisableUndoRedoBtn, not a_bEnable)
	end sub
	
	public sub EnableSourceBtn(a_bEnable)
		call EnableFlag(HeCDisableSourceBtn, not a_bEnable)
	end sub
	
	public sub EnableForeColorBtn(a_bEnable)
		call EnableFlag(HeCDisableForeColor, not a_bEnable)
	end sub
	
	public sub EnableBackColorBtn(a_bEnable)
		call EnableFlag(HeCDisableBackColor, not a_bEnable)
	end sub
	
	public sub EnableAlignBtn(a_bEnable)
		call EnableFlag(HeCDisableAlignBtn, not a_bEnable)
	end sub
	
	public sub EnableTableBtn(a_bEnable)
		call EnableFlag(HeCDisableTableBtn, not a_bEnable)
	end sub
	
	public sub EnableImageBtn(a_bEnable)
		call EnableFlag(HeCDisableImageBtn, not a_bEnable)
	end sub
	
	public sub EnableBorder(a_bEnable)
		call EnableFlag(HeCBorder, a_bEnable)
	end sub
	
	public sub EnableEnumSysFonts(a_bEnable)
		call EnableFlag(HeCEnumSysFonts, a_bEnable)
	end sub
	
	public sub SetMode(a_mode)
		m_dwFlags = (m_dwFlags and not HeCModeMask) or a_mode
	end sub
	
	public sub SetFormName(a_value)
		m_strFormName = a_value
	end sub
	
	public sub SetElementName(a_value)
		m_strElementName = a_value
	end sub
	
	public sub SetFormActionUrl(a_value)
		m_strFormActionUrl = a_value
	end sub
	
	public sub SetFormTarget(a_value)
		m_strFormTarget = a_value
	end sub
	
	public sub EnableDetectPlainText(a_bEnable)
		call EnableFlag(HeCDetectPlainText, a_bEnable)
	end sub
	
	public sub SetEditorCssFile(a_value)
		m_strCssFile = a_value
	end sub
	
	public sub SetMarginWidth(a_lMarginWidth) 
		m_lMarginWidth = a_lMarginWidth
	end sub
	
	public sub SetMarginHeight(a_lMarginHeight) 
		m_lMarginHeight = a_lMarginHeight
	end sub
	
	public sub SetBaseHref(a_strBaseHref) 
		m_strBaseHref = a_strBaseHref
	end sub
	
	public sub EnableToTextIfFail(a_bEnable)
		call EnableFlag(HeCToTextIfFail, a_bEnable)
	end sub
	
	public sub EnableStatusBar(a_bEnable)
		call EnableFlag(HeCDisableStatusBar, not a_bEnable)
	end sub
	
	public sub EnableStyleBox(a_bEnable)
		call EnableFlag(HeCToTextIfFail, a_bEnable)
	end sub
	
	public sub EnableEditPage(a_bEnable)
		call EnableFlag(HeCEditPage, a_bEnable)
	end sub    
	
	public sub EnableFormattingBtns1(a_bEnable)
		call EnableFlag(HeCDisableFormattingBtns1, not a_bEnable)
	end sub
	
	public sub EnableFormattingBtns2(a_bEnable)
		call EnableFlag(HeCDisableFormattingBtns2, not a_bEnable)
	end sub
	
	public sub EnableFormattingBtns3(a_bEnable)
		call EnableFlag(HeCDisableFormattingBtns3, not a_bEnable)
	end sub
	
	public sub EnableLinkBtn(a_bEnable)
		call EnableFlag(HeCDisableLinkBtn, not a_bEnable)
	end sub
	
	public sub EnableHorizontalRuleBtn(a_bEnable)
		call EnableFlag(HeCDisableHorizontalRuleBtn, not a_bEnable)
	end sub
	
	public sub EnableSymbolBtn(a_bEnable)
		call EnableFlag(HeCDisableSymbolBtn, not a_bEnable)
	end sub
	
	public sub EnableXHTMLSource(a_bEnable)
		call EnableFlag(HeCXHTMLSource, a_bEnable)
	end sub
	
	public sub EnableUseDivForIE(a_bEnable)
		call EnableFlag(HeCUseDivForIE, a_bEnable)
	end sub
	
	public sub EnableSafeHtml(a_bEnable)
		call EnableFlag(HeCEnableSafeHtml, a_bEnable)
	end sub
	
	public sub SetOnLoadHandler(a_value) 
		m_strOnLoadHandler = a_value
	end sub
	
	public sub AddCustomButton(title, funcname, imgname)
		dim i
		i = ubound(m_customBtns,2)
		m_customBtns(0,i) = title
		m_customBtns(1,i) = funcname
		m_customBtns(2,i) = imgname
		redim preserve m_customBtns(2,i+1)
	end sub
	
	public sub SetClassName(className)
		m_className = className
	end sub
	
	public sub CreateControl
		if g_hebrowser.HasHtmlEdit then
			dim tempnam
			dim bForm
		
			tempnam = "tmpcontent_he_"&g_lNumControl
			g_lNumControl = g_lNumControl + 1
			bForm = (m_dwFlags and HeCModeMask) <> HeCModeFormElement
	
			if len(m_strContent) then
				Response.Write "<div style='width:1px; height: 1px; position: absolute; visibility: hidden;'>"
				if bForm then
					Response.Write "<form>"
				end if
				Response.Write "<textarea id='"&tempnam&"'>"
				Response.Write htmlspecialchars(m_strContent) & "</textarea>"
				if bForm then
					Response.Write "</form>"
				end if
				Response.Write "</div>"
			end if
	
			Response.Write "<script language=javascript><!--" & vbCrlf
			Response.Write "var obj = new Object()" & vbCrlf
			if len(m_strCtrlName) then
				Response.Write "obj.strId = " & QuoteStr(m_strCtrlName) & vbCrlf
			end if
			if len(m_strWidth) then
				Response.Write "obj.strWidth = " & QuoteStr(m_strWidth) & vbCrlf
			end if
			if len(m_strHeight) then
				Response.Write "obj.strHeight = " & QuoteStr(m_strHeight) & vbCrlf
			end if
			if len(m_dwMask) Then
				Response.Write "obj.lFlags = " & m_dwFlags & vbCrlf
				Response.Write "obj.lMask = " & m_dwFlags & vbCrlf
			end if
			if len(m_strFormName) Then
				Response.Write "obj.strFormName = " & QuoteStr(m_strFormName) & vbCrlf
			end if
			if len(m_strElementName) Then
				Response.Write "obj.strElementName = " & QuoteStr(m_strElementName) & vbCrlf
			end if
			if len(m_strFormTarget) Then
				Response.Write "obj.strTarget = " & QuoteStr(m_strFormTarget) & vbCrlf
			end if
			if len(m_strFormActionUrl) Then
				Response.Write "obj.strAction = " & QuoteStr(m_strFormActionUrl) & vbCrlf
			end if
			if IsArray(m_strCssFile) Then
				Response.Write "obj.strCssStyle = new Array()" & vbCrLf
				dim css, i
				i = 0
				for each css in m_strCssFile
					Response.Write "obj.strCssStyle[" & i & "] = " & QuoteStr(css) & vbCrLf
					i = i + 1
				next
			else
				if len(m_strCssFile) then
					Response.Write"obj.strCssStyle = " & QuoteStr(m_strCssFile) & vbCrlf
				end if
			end if
			if len(m_lTabIndex) then
				Response.Write "obj.lTabIndex = " & QuoteStr(m_lTabIndex) & vbCrlf
			end if
			if len(m_lMarginWidth) then
				Response.Write "obj.lMarginWidth = " & QuoteStr(m_lMarginWidth) & vbCrlf
			end if
			if len(m_lMarginHeight) then
				Response.Write "obj.lMarginHeight = " & QuoteStr(m_lMarginHeight) & vbCrlf
			end if
			if len(m_strBaseHref) then
				Response.Write "obj.strBaseHref = " & QuoteStr(m_strBaseHref) & vbCrlf
			end if
			if len(m_strOnLoadHandler) then
				Response.Write "obj.onLoad = " & m_strOnLoadHandler & vbCrLf
			end if
			if len(m_strPageSrc) then
				Response.Write"obj.strPageSrc = " & QuoteStr(m_strPageSrc) & vbCrlf
			else
				Response.Write "obj.strTextareaId = " & QuoteStr(tempnam) & vbCrlf
			end if
			if ubound(m_customBtns,2) > 0 then
				Response.Write "obj.customBtns = new Array()" & vbCrLf
				for i = 0 to ubound(m_customBtns) - 1
					Response.Write "obj.customBtns["&i&"] = new Object()" & vbCrLf
					Response.Write "obj.customBtns["&i&"].title = " & QuoteStr(m_customBtns(0,i)) & vbCrLf
					Response.Write "obj.customBtns["&i&"].funcname = " & QuoteStr(m_customBtns(1,i)) & vbCrLf
					Response.Write "obj.customBtns["&i&"].imgname = " & QuoteStr(m_customBtns(2,i)) & vbCrLf
				next
			end if	
			if len(m_className) then
				Response.Write"obj.className = " & QuoteStr(m_className) & vbCrlf
			end if
			Response.Write "obj.strAPI = " & QuoteStr("asp") & vbCrlf
			Response.Write "HtmlEditCreateControlFromObj(obj)" & vbCrlf
			Response.Write "//--></script>" & vbCrlf
		else
			dim nav4, str
			nav4 = (g_hebrowser.GetBrowser = "Netscape") and (g_hebrowser.GetVersion < 6)
			if (m_dwFlags and HeCModeMask) = HeCModeStandaloneForm then
				str = ""
				if nav4 then
					str = str & "<form name="&chr(34)&m_strFormName&chr(34)&" action="&chr(34)&m_strFormActionUrl&chr(34)&" method=post target="&chr(34)&m_strFormTarget&chr(34)&">"
					str = str & "<input type=submit name=mysubmit value=Save /><br />"
					str = str & "<textarea name="&chr(34)&m_strElementName&chr(34)&" cols=40 rows=10 " _
						& "style="&chr(34)&"position: relative; width: "&m_strWidth&"; height: "&m_strHeight&";"&chr(34)&" >" _
						& HtmlSpecialChars(m_strContent) & "</textarea><br />"
					str = str & "</form>"
				else
					if m_dwFlags and HeCBorder then
						str = str & "<div style="&chr(34)&"padding: 1px 1px 1px 1px; background-color: black; width: "&m_strWidth&";"&chr(34)&">" _
							&"<div id="&chr(34)&"hetoolbar_"&m_strCtrlName&chr(34)&" unselectable=on class=htmledittoolbar>"
					else
						str = str & "<div id="&chr(34)&"hetoolbar_"&m_strCtrlName&chr(34)&" unselectable=on class=htmledittoolbar style="&chr(34)&"width: "&m_strWidth&";"&chr(34)&">"
					end if
					
					str = str & "<table cellpadding=0 cellspacing=0 border=0 width=100% >"
					str = str & "<form name="&chr(34)&m_strFormName&chr(34)&" action="&chr(34)&m_strFormActionUrl&chr(34)&" method=post target="&chr(34)&m_strFormTarget&chr(34)&">"
					str = str & "<tr><td><input type=submit name=mysubmit value=Save /><br />"
					str = str & "<textarea name="&chr(34)&m_strElementName&chr(34)&" cols=40 rows=10 " _
						& "style="&chr(34)&"position: relative; width: 100%; height: "&m_strHeight&";"&chr(34)&" >" _
						& HtmlSpecialChars(m_strContent) & "</textarea></td></tr>"
					str = str & "</form></table>"
	
					str = str & "</div>"
					if m_dwFlags and HeCBorder then
						str = str & "</div>"
					end if
				end if
				response.write str
			else
				response.write "<textarea name="&chr(34)&m_strElementName&chr(34)&" cols=40 rows=10 " _
					& "style="&chr(34)&"position: relative; width: "&m_strWidth&"; height: "&m_strHeight&";"&chr(34)&" >" _
					& HtmlSpecialChars(m_strContent) & "</textarea><br />"
			end if
		end if
	end sub

end class

sub HtmlEditInit(strHtmlEditPath, strImageUrl, strLangFileUrl)
    if g_hebrowser.HasHtmlEdit then
%><!-- Initialize the QWebEditor 2.0 library -->
<script language="javascript"><!--
// some important global variables
var g_strHtmlEditPath = "<% =strHtmlEditPath %>"
//--></script>
<script language=javascript src="<% =strHtmlEditPath %>browserSniffer.js"></script>
<script language=javascript src="<% =strHtmlEditPath %>utils.js"></script>
<script language=javascript src="<% =strHtmlEditPath %>mydlg.js"></script>
<script language=javascript src="<% =strHtmlEditPath&strLangFileUrl %>"></script>
<%
if len(g_strHeThemeFile) > 0 then
%>
<script language=javascript src="<% =strHtmlEditPath & g_strHeThemeFile %>"></script>
<%
end if
%><script language=javascript src="<% =strHtmlEditPath %>license.js"></script>
<script language=javascript src="<% =strHtmlEditPath %>htmledit_cfg.js"></script>
<script language="javascript"><!--
var g_strHtmlEditImgUrl = "<% =strImageUrl %>"
var g_strHtmlEditLangFile = "<% =strLangFileUrl %>"
var g_bMergedImageDialog = <%
if g_dwHeFlags & HECEnableMergedImageDialog then
	Response.Write "true"
else
	Response.Write "false"
end if
%>
//--></script>
<script language=javascript src="<% =strHtmlEditPath %>htmledit.js"></script>
<script language=javascript src="<% =strHtmlEditPath %>htmledit_styles.js"></script>
<!-- End of initialization --><%
    else
%><!-- Initialize the QWebEditor 2.0 library -->
<script language=javascript src="<% =strHtmlEditPath %>browserSniffer.js"></script>
<script language=javascript src="<% =strHtmlEditPath %>utils.js"></script>
<script language=javascript src="<% =strHtmlEditPath %>mydlg.js"></script>
<script language=javascript src="<% =strHtmlEditPath&strLangFileUrl %>"></script>
<script language=javascript src="<% =strHtmlEditPath %>htmledit_cfg.js"></script>
<script language=javascript src="<% =strHtmlEditPath %>htmledit_ta.js"></script>
<style type="text/css">
<!--
.htmledittoolbar {position: relative; left: 0px; top: 0px; padding: 1px 1px 1px 1px; background-color: threedface; border-width: 1px; border-style: solid; border-color: threedshadow; border-top-color: threedhighlight; border-left-color: threedhighlight; overflow: hidden; }
.htmleditbtn {cursor: pointer; padding: 0px 0px 0px 0px; border: solid; border-width: 1px; background-color: threedface; Border-Top-Color: buttonface; Border-Left-Color: threedface; Border-Bottom-Color: threedface; Border-Right-Color: threedface;}
.htmledittext {cursor: default; font-family: tahoma, sans-serif; font-size: 8pt; }
.htmleditstatusbox {cursor: default; font-family: tahoma, sans-serif; font-size: 8pt; border-width: 1px; border-style: solid; border-color: threedshadow; border-right-color: threedhighlight; border-bottom-color: threedhighlight; text-align: center; padding: 1px 1px 1px 1px;}
--></style><!-- End of initialization -->
<%  end if
end sub

sub HtmlEditInit2(strHtmlEditPath, strOverride)
%>
<!-- QWebEditor 3.12 Initialization Start 
--><script language="javascript"><!--
// variables to match your qwebeditor installation
var g_strHtmlEditPath="<% =strHtmlEditPath %>"			// uri to qwebeditor directory
function ijs(file){document.write("<scr"+"ipt language=\"javascript\" src=\""
	+g_strHtmlEditPath+file+"\"></scr"+"ipt>")}
// load utility libraries and configuration file
ijs("browserSniffer.js");ijs("utils.js");ijs("mydlg.js");ijs("htmledit_cfg.js")
//--></script><script language="javascript"><!--
// load necessary file if browser supports the editor
<% =strOverride %>
ijs(g_strHtmlEditLangFile)
if(has_htmledit){ijs(g_strHtmlEditThemeUrl);ijs("license.js");ijs("htmledit.js");ijs("htmledit_styles.js")}
// browser does not support the editor. load compatibility file
else {ijs("htmledit_ta.js")}
//--></script><!-- 
QWebEditor 3.12 Initialization End -->
<%
end sub

sub HtmlEditSaveFile(a_strFileName, a_strContent)
	dim FSO
	set FSO = server.createObject("Scripting.FileSystemObject")
	
	' Map the logical path to the physical system path
	Dim Filepath
	Filepath = Server.MapPath(a_strFileName)
	
	dim TextStream
	Set TextStream = FSO.OpenTextFile(Filepath, ForWriting, true, TristateUseDefault)
	TextStream.Write a_strContent
	TextStream.Close
	Set TextStream = nothing
	
	Set FSO = nothing
end sub

function HtmlEditReadFile(a_strFileName)
	dim FSO
	set FSO = server.createObject("Scripting.FileSystemObject")
	
	' Map the logical path to the physical system path
	Dim Filepath
	Filepath = Server.MapPath(a_strFileName)
	
	dim TextStream
	Set TextStream = FSO.OpenTextFile(Filepath, ForReading, true, TristateUseDefault)
	On Error Resume Next
	HtmlEditReadFile = TextStream.ReadAll()
	TextStream.Close
	Set TextStream = nothing
end function

%>