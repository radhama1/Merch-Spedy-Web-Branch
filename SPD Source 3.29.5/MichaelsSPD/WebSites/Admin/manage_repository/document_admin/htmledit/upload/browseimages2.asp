<%@ Language=VBScript %>
<% 
option explicit 
Response.Expires = -1
Server.ScriptTimeout = 600

' File             : browseimages.asp
' Programmer       : John Wong
' Copyright (c) Q-Surf Computing Solutions, 2003-04. All rights reserved.
' http://www.q-surf.com

' This script uses 2 free web resources from
' http://www.codeproject.com/asp/thumbtools2.asp for image manipulation
' http://www.freeaspupload.net/ for saving uploaded files.
' Both resources are free but please check their license to make sure that you can incorporate 
' them in your applications.

' Before using this script, you have to:
' 1. Register the CxImageATL.dll if you want to generate thumbnail. 
'    Start command prompt and run "regsvr32 CxImageATL.dll" to do so.
'    If you are using Windows 2003 Server, you may need to restart your
'    web server by entering the follows in command prompt:
'    > net stop w3svc
'    > net start w3svc
'    If you cannot register COM control in your web server, thumbnail
'    generation feature should be disabled by changing the
'    "bUseThumbnail" variable.
' 2. Make sure you have write and delete permission for the upload directories.
' 3. Modify the uploadsDirVar and imagediruri variables in this file.
%>
<!--- #include file="freeASPUpload.asp" --->
<%
' Following are some of the configuration options you have to set.

' Physical directory of image directory. Must provide trailing slash
dim uploadsDirVar
uploadsDirVar = Application.Value("WYSIWYG_Upload_Image_Path")

' URL to access the image directory. must provide trailing slash
dim imagediruri
imagediruri = Application.Value("WYSIWYG_Upload_Image_URL")
if Request.ServerVariables("SERVER_PORT_SECURE") then
	imagediruri = "https://" & Request.ServerVariables("HTTP_HOST") & imagediruri
else
	imagediruri = "http://" & Request.ServerVariables("HTTP_HOST") & imagediruri
end if

' Root path that is saved in the IMG tag SRC attribute. must provide preceeding slash.
dim imgsrcuri
imgsrcuri = Application.Value("WYSIWYG_Upload_Image_DisplayPath")

' Number of columns in list view
const numCols = 4

' Whether to allow user to upload images
const bAllowUpload = true

' whether support image only
const bImageOnly = false

' Max. allowed upload size in bytes
const lMaxUploadFileSize = 250000

' Size of generated thumbnails in pixel
const thumbSize = 80

' Whether to use thumbnail
' If you want to use the thumbnail, you have to register the CxImageATL.dll
const bUseThumbnail = true

' End of options

dim msg
msg = ""

' Verify this script and server are configured properly.
function TestEnvironment()
    Dim fso, fileName, testFile, streamTest
    TestEnvironment = ""
    Set fso = Server.CreateObject("Scripting.FileSystemObject")
    if not fso.FolderExists(uploadsDirVar) then
        TestEnvironment = "<B>Folder " & uploadsDirVar & " does not exist.</B><br>The value of your uploadsDirVar is incorrect. Open uploadTester.asp in an editor and change the value of uploadsDirVar to the pathname of a directory with write permissions."
        exit function
    end if
    fileName = uploadsDirVar & "\test.txt"
    on error resume next
    Set testFile = fso.CreateTextFile(fileName, true)
    If Err.Number<>0 then
        TestEnvironment = "<B>Folder " & uploadsDirVar & " does not have write permissions.</B><br>The value of your uploadsDirVar is incorrect. Open uploadTester.asp in an editor and change the value of uploadsDirVar to the pathname of a directory with write permissions."
        exit function
    end if
    Err.Clear
    testFile.Close
    fso.DeleteFile(fileName)
    If Err.Number<>0 then
        TestEnvironment = "<B>Folder " & uploadsDirVar & " does not have delete permissions</B>, although it does have write permissions.<br>Change the permissions for IUSR_<I>computername</I> on this folder."
        exit function
    end if
    Err.Clear
    Set streamTest = Server.CreateObject("ADODB.Stream")
    If Err.Number<>0 then
        TestEnvironment = "<B>The ADODB object <I>Stream</I> is not available in your server.</B><br>Check the Requirements page for information about upgrading your ADODB libraries."
        exit function
    end if
    Set streamTest = Nothing
end function

Function GetFileType(sFile)
	dim dot, filetype, sExt
	dot = InStrRev(sFile, ".")
	filetype=-1
	If dot > 0 Then sExt = LCase(Mid(sFile, dot + 1, 3))
	If sExt = "bmp" Then filetype = 0
	If sExt = "gif" Then filetype = 1
	If sExt = "jpg" Then filetype = 2
	If sExt = "png" Then filetype = 3
	If sExt = "ico" Then filetype = 4
	If sExt = "tif" Then filetype = 5
	If sExt = "tga" Then filetype = 6
	If sExt = "pcx" Then filetype = 7
	GetFileType=filetype
End Function

sub DeleteFile(pathname)
	Dim objFSO
	Set objFSO = Server.CreateObject("Scripting.FileSystemObject")
	On Error Resume Next
	objFSO.DeleteFile pathname, True
	On Error Goto 0
	Set objFSO = Nothing
end sub

function FileExists(pathname)
	Dim objFSO
	Set objFSO = Server.CreateObject("Scripting.FileSystemObject")
	FileExists = fso.FileExists (pathname)
	Set objFSO = Nothing
end function

' Delete image and its thumbnail
sub DeleteImage(fileName)
	DeleteFile uploadsDirVar & fileName
	DeleteFile uploadsDirVar & "thumbs/" & fileName & ".jpg"
end sub

function AddCSlashes(strText)
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
	
if Request.ServerVariables("REQUEST_METHOD") = "POST" then
    Dim Upload
    Set Upload = New FreeASPUpload
    Upload.Save(uploadsDirVar)
    
    Dim ks, fileKey, fileName, filePath, objCxImage
    ks = Upload.UploadedFiles.keys
    if (UBound(ks) <> -1) then
        for each fileKey in Upload.UploadedFiles.keys
			if Upload.UploadedFiles(fileKey).Length > lMaxUploadFileSize then
				msg = "Size of uploaded file exceeds allowed size " & lMaxUploadFileSize & "bytes."
				DeleteImage fileName
			else
				fileName = Upload.UploadedFiles(fileKey).FileName
				filePath = uploadsDirVar & fileName
				if bUseThumbnail then
					Set objCxImage = Server.CreateObject("CxImageATL.CxImage")
					Call objCxImage.Load(filePath,GetFileType(filePath))
					Call objCxImage.IncreaseBpp(24)
		
					dim srcw, srch, dstw, dsth
					srcw = CDbl(objCxImage.GetWidth())
					srch = CDbl(objCxImage.GetHeight())
		
					if (srcw = 0) or (srch = 0) then
						if bImageOnly then
							msg = "Unable to read the image. It may not be a valid image."
							DeleteImage fileName
						end if
					else
						if (srcw > thumbSize) or (srch > thumbSize) then
							if (srcw / srch) > 1 then
								dstw = thumbSize
								dsth = round(thumbSize * srch / srcw)
							else
								dsth = thumbSize
								dstw = round(thumbsize * srcw / srch)
							end if
						else
							dsth = srch
							dstw = srcw
						end if
						call objCxImage.Resample(dstw,dsth,2)
						Call objCxImage.Save(uploadsDirVar & "thumbs\" & fileName & ".jpg", 2)
					end if ' if (srcw = 0) or (srch = 0) then
				end if ' if bUseThumbnail
			end if ' if Upload.UploadFile(fileKey).Length then
        next
    end if    
end if

if Request.QueryString("action") = "delete" then
	' verify filename is valid
	fileName = Trim(Request.QueryString("file"))
	fileName = Replace(fileName, ":", "")
	fileName = Replace(fileName, "..", "")
	fileName = Replace(fileName, "/", "")
	fileName = Replace(fileName, "\", "")
	DeleteImage fileName
	msg = "The file has been successfully deleted."
end if

%><!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Strict//EN">
<html>
<head>
<script language="javascript">
if (top.opener) {
	var charset = (top.opener.document.characterSet) ? top.opener.document.characterSet : top.opener.document.charset
	document.write("<meta HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; CHARSET=" + charset + "\" />")
}
</script>
<script language="javascript">
var g_strHtmlEditPath = top.opener.g_strHtmlEditPath
var g_strHtmlEditLangFile = top.opener.g_strHtmlEditLangFile
function ijs(file){document.write("<scr"+"ipt language=\"javascript\" src=\""
	+g_strHtmlEditPath+file+"\"></scr"+"ipt>")}
ijs(g_strHtmlEditLangFile)
</script>
<title></title>
<LINK REL=STYLESHEET TYPE="text/css" HREF="../style.css">
<script language="javascript" src="../utils.js"></script>
<script language="javascript" src="../mydlg.js"></script>
<script language="javascript">
	top.document.title = "Browse ..."
	function OnSubmit(myform) {
		if (myform.imgurl.value.length) {
			var obj = new Object()
			obj.src = myform.imgurl.value
			if (myform.objtype.value == "image") {
				obj.type = "image"
				obj.align = myform.align.value
				obj.border = myform.border.value
				obj.alt = myform.alt.value
				obj.width = myform.width.value
				obj.height = myform.height.value
			}
			else if (myform.objtype.value == "flash") {
				obj.type = "flash"
				obj.width = myform.objWidth.value
				obj.height = myform.objHeight.value
			}
			else {
				obj.type = "other"
			}
			MyDlgHandleOK(obj)
		}
		else {
			window.alert(g_strHeTextEnterImageUrl)
		}
	}
	
	function ShowHideProperties() {
		var reImage = /\.(jpg|jpeg|png|gif)$/i
		var reFlash = /\.swf$/i
		
		if (reImage.test(document.myform.imgurl.value)) {
			document.myform.objtype.value = "image"
			document.getElementById("imageprop").style.display = "block"
			document.getElementById("objprop").style.display = "none"
		}
		else if (reFlash.test(document.myform.imgurl.value)) {
			document.myform.objtype.value = "flash"
			document.getElementById("imageprop").style.display = "none"
			document.getElementById("objprop").style.display = "block"
		}
		else {
			document.myform.objtype.value = "other"
			document.getElementById("imageprop").style.display = "none"
			document.getElementById("objprop").style.display = "none"
		}
	}
</script>
<style type="text/css">
legend {font-size: 8pt; color: #4f4fdf;}
</style>
</head>
<body style="background-color: threedface;" leftmargin=10 topmargin=10 <%
if len(msg) then
%>onload="alert('<% =msg %>')"<%
end if
%>>
<div align=center>
<% call TestEnvironment %>
<script language="javascript">
document.body.style.backgroundColor = top.opener.g_strHeCssThreedFace
document.body.style.color = top.opener.g_strHeCssWindowText
</script>
<div align=center>
<form name=myform action="browseimages2.asp" method="post" enctype="multipart/form-data">
<script language="javascript">
document.writeln("    <fieldset style=\"margin-bottom: 4px;\"><legend>Specify an image by entering its URL:</legend>")
document.writeln("      <table width=\"100%\" align=center>")
document.writeln("        <tr> ")
document.writeln("          <td align=left>" + g_strHeTextImageURL + "</td>")
document.writeln("          <td><input type=text name=imgurl style=\"width: 360px;\"></td>")
document.writeln("        </tr></table></fieldset>");
</script>

<fieldset style="margin-bottom: 4px;"><legend>Or by selecting an image from photo gallery: </legend>
<div style="overflow: auto; height: <% 
if bAllowUpload then 
	Response.Write "185px"
else
	Response.Write "240px"
end if
%>; ">
<table cellpadding=4 cellspacing=0 border=0 width=96%>
<%
	Dim fso, f, f1, fc, s
	Dim lCount, lColWidth
	Dim strOnClick
	
	lCount = 0
	lColWidth = round(100 / numCols) & "%"
	
	Set fso = CreateObject("Scripting.FileSystemObject")
	Set f = fso.GetFolder(uploadsDirVar)
	Set fc = f.Files
	For Each f1 in fc

		'strOnClick = "javascript: if (document.myform.imgurl.disabled) return false; document.myform.imgurl.value = '" & imagediruri & AddCSlashes(Server.HtmlEncode(f1.name)) & "'; ShowHideProperties(); "
		strOnClick = "javascript: if (document.myform.imgurl.disabled) return false; document.myform.imgurl.value = '" & imgsrcuri & AddCSlashes(Server.HtmlEncode(f1.name)) & "'; ShowHideProperties(); "

		if (lCount Mod numCols) = 0 then
			response.write("<tr>")
		end if
		%>
		<td width=<% = lColWidth %> align=center><table cellpadding=0 cellspacing=0 border=0>
			<tr height=<% = thumbsize %>><td colspan=2 width=<% = thumbsize %> align=center valign=middle>
			<a href="#" onclick="<% = strOnClick %>">
			<% if FileExists(uploadsDirVar&"thumbs/"&f1.name&".jpg") then %>
			<img src="<% = imagediruri & "thumbs/" & f1.name %>.jpg" alt="" border=0 />
			<% else %>
			<img src="file_document_lg.gif" alt="" border=0 />
			<% end if %>
			</a></td></tr>
			<tr><td align=left style="font-size: 8pt;"><a href="#" onclick="<% = strOnClick %>"><% = f1.name %></a>&nbsp;</td>
			<td align=right><a href="browseimages2.asp?action=delete&amp;file=<% =Server.urlencode(f1.name) %>" onclick="return confirm('Are you sure to delete the file?')">
			<img src="delete_sm.gif" width="16" height="16" alt="Delete" border="0" style="cursor: hand;" /></a></td>
			</tr></table><br /></td>
		<%
		lCount = lCount + 1					
		if (lCount Mod numCols) = 0 then
			response.write("<tr>")
		end if
	Next
    if lCount = 0 then
    %>
    	<tr><td>Images directory is empty.<td></tr>
    <%
    else
        if lCount mod numCols then
            while lCount mod numCols
            	%>
                <td width=<% = lColWidth %>>&nbsp;</td>
                <%
                lCount = lCount + 1
            wend
            response.write("</tr>")
        end if
    end if 
	%>
</table></div></fieldset>

<% if bAllowUpload then %>
<fieldset style="margin-bottom: 4px;"><legend>Upload file to photo gallery:</legend>
<table cellpadding=2 cellspacing=0 border=0 width=100%><tr>
<td align=left>File Name: <input type="file" name="binImage" /></td>
<td align=right><input type="submit" name="mysubmit" value="Upload"></td>
</tr></table></fieldset>
<% end if %>

<script language="javascript">
document.writeln("<fieldset style=\"margin-bottom: 4px; display: none;\" id=\"imageprop\"><legend>Image Properties:</legend>")
document.writeln("<table width=100%><tr><input type=hidden name=width /><input type=hidden name=height /><input type=hidden name=objtype />")
document.writeln("          <td width=50% align=left>" + g_strHeTextImageAlignment + " ")
document.writeln("            <select name=align> ")
document.writeln("              <option value=\"\">-----</option> ")
document.writeln("              <option value=left>" + g_strHeTextLeft + "</option> ")
document.writeln("              <option value=right>" + g_strHeTextRight + "</option> ")
document.writeln("              <option value=top>" + g_strHeTextTop + "</option> ")
document.writeln("                <option value=middle>" + g_strHeTextMiddle + "</option> ")
document.writeln("                <option value=bottom>" + g_strHeTextBottom + "</option> ")
document.writeln("            </select></td>")
document.writeln("          <td width=50% align=left>" + g_strHeTextBorder + " ")
document.writeln("            <select name=border> ")
document.writeln("              <option value=0>0</option> ")
document.writeln("              <option value=1>1</option> ")
document.writeln("              <option value=2>2</option> ")
document.writeln("              <option value=3>3</option> ")
document.writeln("              <option value=4>4</option> ")
document.writeln("              <option value=5>5</option> ")
document.writeln("              <option value=6>6</option> ")
document.writeln("              <option value=7>7</option> ")
document.writeln("              <option value=8>8</option> ")
document.writeln("            </select></td></tr> ")
document.writeln("        <tr>")
document.writeln("          <td colspan=2 align=left>" + g_strHeTextImageDesc + " <input type=text name=alt style=\"width: 240px;\" /></td>")
document.write("</tr></table></fieldset>")
document.writeln("<fieldset style=\"margin-bottom: 4px; display: none;\" id=\"objprop\"><legend>Object Properties:</legend>")
document.writeln("<table width=100%><tr>")
document.writeln("          <td width=50% align=left>Width: <input type=text name=objWidth style=\"width: 60px;\" /></td>")
document.writeln("          <td width=50% align=left>Height: <input type=text name=objHeight style=\"width: 60px;\" /></td>")
document.writeln("</tr></table>")
document.writeln("</fieldset>")
document.write("<table width=\"100%\" align=center>")
document.writeln("        <tr>")
document.writeln("          <td align=right><input type=button value=\"" + g_strHeTextOk + "\" onclick=\"javascript: OnSubmit(document.forms[0])\"><input type=button value=\"" + g_strHeTextCancel + "\" onclick=\"javascript: MyDlgHandleCancel()\"></td></tr>")
document.writeln("    </table>")
</script>

</form>
<script language="javascript">
    if (MyDlgGetObj().args) {

        // width
        if (MyDlgGetObj().args.src) {
            str = new String(MyDlgGetObj().args.src)
            document.myform.imgurl.value = str
        }
        else {
            document.myform.imgurl.value = ""
        }

        if (MyDlgGetObj().args.align) {
            for (i = 0; i < document.myform.align.options.length; i ++) {
                var str = new String(document.myform.align.options[i].value)
                str = str.toLowerCase()
                if (MyDlgGetObj().args.align == str) {
                    document.myform.align.selectedIndex = i
                    break
                }
            }
        }

        // border
        if (MyDlgGetObj().args.border) {
            str = new String(MyDlgGetObj().args.border)
            document.myform.border.selectedIndex = str
        }
        else {
            document.myform.border.selectIndex = 0
        }

        // alt
        if (MyDlgGetObj().args.alt) {
            str = new String(MyDlgGetObj().args.alt)
            document.myform.alt.value = str
        }
        else {
            document.myform.alt.value = ""
        }

        if (MyDlgGetObj().args.width) {
            str = new String(MyDlgGetObj().args.width)
            document.myform.width.value = str
        }
        else {
            document.myform.width.value = ""
        }

        if (MyDlgGetObj().args.height) {
            str = new String(MyDlgGetObj().args.height)
            document.myform.height.value = str
        }
        else {
            document.myform.height.value = ""
        }
    }
	
	ShowHideProperties()
</script>
</div>
</body></html>