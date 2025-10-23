// File:            htmledit_ta.js
// Description:     Used to generate codes for browser that does not have necessary cap. for QWebEditor.
// Copyright (c) Q-Surf Computing Solutions, 2003. All rights reserved.
// http://www.q-surf.com

var g_strHeVersion="3.03"

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

var g_lHeNumCtrl = 0
var g_bHeInited = false

function HtmlEditOpenEditor(strId, strTitle, strCharset)
{
    var myTitle = (strTitle ? strTitle : "")
    var myCharset = (strCharset ? strCharset : "iso-8859-1")
    str = MyDlgOpen(
        g_strHtmlEditPath+"htmleditpopup.html",
        500, 400,                       // width and height of dialog
        new Function("HtmlEditOpenEditorReturn('"+strId+"')"),           // if dialog box closed normally, call this function
        new Array(
            myCharset,               // character encoding
            myTitle,                // dialog title
            g_strHtmlEditPath,          // path to QWebEditor directory
            g_strHtmlEditImgUrl,        // file for browsing images
            g_strHtmlEditLangFile,      // language resourses
            ((document.getElementById) ? document.getElementById(strId).innerHTML : '')
            ),
        null, true)
}

function HtmlEditOpenEditorReturn(strId)
{
    result = dialogWin.returnedValue
    if (result != null)
    {
        if (document.getElementById)
        {
            document.getElementById(strId).innerHTML = dialogWin.returnedValue
        }
    }
}

function HtmlEditDrawBtn(obj,state)
{
    if(!obj) return
    if(!obj.style) return
    var os=obj.style
    var btc,blc,bbc,brc
    switch (state)
    {
    case "Over":
        btc="threedhighlight";
        blc="threedhighlight";
        bbc="threedshadow";
        brc="threedshadow";
        break;
    case "Down":
        btc="threedshadow";
        blc="threedshadow";
        bbc="threedhighlight";
        brc="threedhighlight";
        break;
    default:
        btc="threedface"
        blc=btc
        bbc=btc
        brc=btc
        break;
    }
    if(os.borderTopColor!=btc)os.borderTopColor=btc
    if(os.borderLeftColor!=blc)os.borderLeftColor=blc
    if(os.borderBottomColor!=bbc)os.borderBottomColor=bbc
    if(os.borderRightColor!=brc)os.borderRightColor=brc
}

function HtmlEditBtnOver(e)
{HtmlEditDrawBtn((e)?e.target:window.event.srcElement,"Over")}

function HtmlEditBtnOut(e)
{HtmlEditDrawBtn((e)?e.target:window.event.srcElement,"Out")}

function HtmlEditBtnDown(e)
{HtmlEditDrawBtn((e)?e.target:window.event.srcElement,"Down")}

function HtmlEditBtnUp(e)
{HtmlEditDrawBtn((e)?e.target:window.event.srcElement,"Up")}

function HtmlEditCreateControl2(a_strId, strWidth, strHeight, strValue, lFlags,
    strFormName, strElementName, strAction, strTarget)
{
    var strId = a_strId ? a_strId : ("htmledit"+g_lHeNumCtrl++)
    var myFormName = strFormName ? strFormName : ("frm_" + strId)
    var myAction = strAction ? strAction : ""
    var myElementName = strElementName ? strElementName : ("element_" + strId)
    var myTarget = strTarget ? strTarget : ""
    var myValue = (lFlags & g_lHeCToTextIfFail) ? HtmlToPlainText(strValue) : HtmlSpecialChars(strValue)

    if ((lFlags & g_lHeCModeMask) == g_lHeCModeStandaloneForm ||
        (lFlags & g_lHeCModeMask) == g_lHeCModeStandaloneDialog)
    {
        if (g_heBrowser.is_dom1)
        {
            document.write("<style type=\"text/css\">\n")
            document.write(".htmledittoolbar {position: relative; left: 0px; top: 0px; padding: 1px 1px 1px 1px; background-color: threedface; border-width: 1px; border-style: solid; border-color: threedshadow; border-top-color: threedhighlight; border-left-color: threedhighlight; overflow: hidden; }\n")
            document.write(".htmleditbtn {cursor: pointer; padding: 0px 0px 0px 0px; border: solid; border-width: 1px; background-color: threedface; Border-Top-Color: buttonface; Border-Left-Color: threedface; Border-Bottom-Color: threedface; Border-Right-Color: threedface;}\n")
            document.write(".htmledittext {cursor: default; font-family: tahoma, sans-serif; font-size: 8pt; }")
            document.write(".htmleditstatusbox {cursor: default; font-family: tahoma, sans-serif; font-size: 8pt; border-width: 1px; border-style: solid; border-color: threedshadow; border-right-color: threedhighlight; border-bottom-color: threedhighlight; text-align: center; padding: 1px 1px 1px 1px;}")
            document.write("</style>\n")
            if (lFlags & g_lHeCBorder)
            {
                document.write("<div style=\"padding: 1px 1px 1px 1px; background-color: black; width: " + strWidth + ";\">")
                document.write("<div align=left id=\"hetoolbar_" + strId + "\" unselectable=on class=\"htmledittoolbar\" oncontextmenu=\"return false\">")
            }
            else
            {
                document.write("<div align=left id=\"hetoolbar_" + strId + "\" unselectable=on class=\"htmledittoolbar\" style=\"width: " + strWidth + ";\" oncontextmenu=\"return false\">")
            }
            document.write("<img align=absmiddle class=\"htmleditbtn\" id=\"hebtn" + strId + "_new\" onclick=\"javascript: if (confirm(g_strHeTextNewMsg)) document.getElementById('"+strId+"_"+strElementName+"').value = ''\" src=" + g_strHtmlEditPath + "htmleditimg/new.gif alt=\"" + g_strHeTextNew + "\" width=\"20\" height=\"20\" />")
            document.write("<img align=absmiddle class=\"htmleditbtn\" id=\"hebtn" + strId + "_save\" onclick=\"javascript: ")
            if ((lFlags & g_lHeCModeMask) == g_lHeCModeStandaloneForm)
                document.write("document.getElementById('"+strId+"_"+strElementName+"').form.submit()")
            else
                document.write("MyDlgHandleOK(document.getElementById('"+strId+"_"+strElementName+"').value)")
            document.write("\" src=" + g_strHtmlEditPath + "htmleditimg/save.gif alt=\"" + g_strHeTextSave + "\" width=\"20\" height=\"20\" />")
            document.write("</div>")

            document.write("<table cellpadding=0 cellspacing=0 border=0 width=100%>")
            document.write("<form name=\"" + myFormName + "\" action=\"" + myAction + "\" method=\"post\" target=\"" + myTarget + "\">")
            document.write("<tr><td><textarea id="+strId+"_"+strElementName+" name=\""+strElementName+"\" cols=40 rows=10 "
            + "style=\"solid; position: relative; width: "+strWidth+"; height: "+strHeight+";\" >"
            + myValue+"</textarea></td></tr>")
            document.write("</form></table>")

            document.write("</div>")
            if (lFlags & g_lHeCBorder)
                document.write("</div>")
                
            var obj
            obj = document.getElementById("hebtn"+strId+"_new")
            if (obj)
            {
                obj.onmouseover = HtmlEditBtnOver
                obj.onmouseout = HtmlEditBtnOut
                obj.onmousedown = HtmlEditBtnDown
                obj.onmouseup = HtmlEditBtnUp
            }
            obj = document.getElementById("hebtn"+strId+"_save")
            if (obj)
            {
                obj.onmouseover = HtmlEditBtnOver
                obj.onmouseout = HtmlEditBtnOut
                obj.onmousedown = HtmlEditBtnDown
                obj.onmouseup = HtmlEditBtnUp
            }
        }
        // probably netscape 4
        else
        {
            var str = new String()
            str = str + "<form name=\"" + myFormName + "\" action=\"" + myAction + "\" method=\"post\" target=\"" + myTarget + "\">"
            if ((lFlags & g_lHeCModeMask) == g_lHeCModeStandaloneForm)
                str = str + "<input type=submit name=mysubmit value=\""+g_strHeTextSave+"\" /><br />"
            else
                str = str + "<input type=button name=mybtn value=\""+g_strHeTextSave+"\" onclick=\"javascript: MyDlgHandleOK(document.forms['"+myFormName+"'].elements['"+myElementName+"'].value)\"/><br />"
            str = str + "<textarea name=\""+myElementName+"\" id=\"" + strId + "\" cols=40 rows=10 "
                + (!is_nav4 ? "style=\"position: relative; width: "+strWidth+"; height: "+strHeight+";\" >" : '>')
                + myValue+"</textarea><br />"
            str = str + "</form>"
            document.write(str)
        }
    }
    else
    {
        document.write("<textarea name=\""+strElementName+"\" id=\"" + strId + "\" cols=40 rows=10 "
            + (!is_nav4 ? "style=\"position: relative; width: "+strWidth+"; height: "+strHeight+";\" >" : '>')
            + myValue+"</textarea><br />")
    }
}

function HtmlEditUpdateAllFormElements()
{
}

function HtmlEditCreateControlFromObj(obj)
{
    // some defaults
    var strId = obj.strId ? obj.strId : ''
    var strWidth = obj.strWidth ? obj.strWidth : '100%'
    var strHeight = obj.strHeight ? obj.strHeight : '100px'
    var strValue = obj.strValue ? obj.strValue : ''
    var lFlags = obj.lFlags ? obj.lFlags : (g_lHeCModeFormElement | g_lHeCBorder)

    HtmlEditCreateControl2(
        strId,
        strWidth,
        strHeight,
        strValue,
        lFlags,
        obj.strFormName,
        obj.strElementName,
        obj.strAction,
        obj.strTarget)
}

function HtmlEditFocus(strId)
{
	if (document.getElementById) {
		var obj = document.getElementById(strId)
		if (obj && obj.focus) {
			obj.focus()
		}
	}
}

function HtmlEditSetContent(strId, strContent) {
    if (document.getElementById) {
        var obj = document.getElementById(strId)
        if (obj) {
            obj.value = strContent
        }
    }
}

function HtmlEditGetContent(strId) {
    if (document.getElementById) {
        var obj = document.getElementById(strId)
        if (obj) {
            return obj.value
        }
    }
    return ""
}

function HtmlEditGetDefContent(strId) {
    return HtmlEditGetContent(strId)
}

function HtmlEditIsModified(strId) {
	return false
}