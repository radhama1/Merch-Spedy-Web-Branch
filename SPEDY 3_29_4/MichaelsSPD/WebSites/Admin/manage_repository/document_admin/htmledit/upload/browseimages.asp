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
const uploadsDirVar = "e:\htdocs\htmledit\upload\pages\images\"

' URL to access the image directory. must provide trailing slash
const imagediruri = "http://localhost:81/htmledit/upload/pages/images/"

' Number of columns in list view
const numCols = 4

' Whether to allow user to upload images
const bAllowUpload = true

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

' Delete image and its thumbnail
sub DeleteImage(fileName)
	Dim objFSO
	Set objFSO = Server.CreateObject("Scripting.FileSystemObject")
	On Error Resume Next
	objFSO.DeleteFile uploadsDirVar & fileName, True
	objFSO.DeleteFile uploadsDirVar & "thumbs/" & fileName & ".jpg", True
	On Error Goto 0
	Set objFSO = Nothing
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
					msg = "Unable to read the image. It may not be a valid image."
					DeleteImage fileName
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
				end if
			end if
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
<title></title>
<LINK REL=STYLESHEET TYPE="text/css" HREF="../style.css">
<script language="javascript" src="../utils.js"></script>
<script language="javascript" src="../mydlg.js"></script>
<script language="javascript">
    top.document.title = "Browse ..."
</script>
</head>
<body style="background-color: threedface;" leftmargin=10 topmargin=10 <%
if len(msg) then
%>onload="alert('<% =msg %>')"<%
end if
%>>
<div align=center>
<%
call TestEnvironment
if bAllowUpload then %>
<table cellpadding=1 cellspacing=0 border=0 width=97% bgcolor=black>
<form action="browseimages.asp" method="post" enctype="multipart/form-data">
<tr><td><table cellpadding=2 cellspacing=0 border=0 width=100% bgcolor=white><tr><td align=left>
File Name: <input type="file" name="attach1" /><br />
<input type="submit" name="mysubmit" value="Upload Now!">
</td></tr></table></td></tr></form></table><br />
<% end if %>
<div style="width: 97%; text-align: left;">Please click on an image file to select:</div>
<div style="overflow: auto; width: 97%; height: <%
 if bAllowUpload then
 	response.write("245px")
 else
 	response.write("300px")
 end if
%>; border: black 1px solid; background-color: white;">
<table cellpadding=2 cellspacing=0 border=0 width=94% bgcolor=white>
<%
	Dim fso, f, f1, fc, s
	Dim lCount, lColWidth
	
	lCount = 0
	lColWidth = round(100 / numCols) & "%"
	
	Set fso = CreateObject("Scripting.FileSystemObject")
	Set f = fso.GetFolder(uploadsDirVar)
	Set fc = f.Files
	For Each f1 in fc
		if (lCount Mod numCols) = 0 then
			response.write("<tr>")
		end if
		%><td width="<% =lColWidth %>" align=center><a href="#" onclick="javascript: MyDlgHandleOK('<% = imagediruri & AddCSlashes(Server.HtmlEncode(f1.name)) %>')"><%
			if bUseThumbnail then 
			%><img src="<% = imagediruri & "thumbs/" & f1.name & ".jpg" %>" alt="" border=0 /><br />
			<%
			end if
			%>
			<% = f1.name %></a><br />
			(<a href="browseimages.asp?action=delete&amp;file=<% = Server.urlencode(f1.name) %>" onclick="return confirm('Are you sure to delete the file?')">Delete</a>)<br /><br />
		</td><%
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
</table></div>
</div>
</body></html>
