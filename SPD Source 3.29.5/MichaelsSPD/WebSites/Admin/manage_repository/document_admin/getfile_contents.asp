<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
%>
<!--#include file="./../../app_include/_globalInclude.asp"-->
<%
Response.Buffer = True
Response.Expires = -1441
%>
<!--#include file="../../app_include/getfile_MIMEtype.asp"-->
<%

Dim objConn, objRec, SQLStr, connStr
Dim FileID, FileName, FileSize, FileContents
Dim boolDownloadOnly
Dim tempDirPath, fullFilePath, FileExt
Dim topicID

topicID = Request("tid")
if IsNumeric(topicID) then
	topicID = CInt(topicID)
else
	topicID = 0
end if

FileID = Request("fid")
if IsNumeric(FileID) then
	FileID = CInt(FileID)
else
	FileID = 0
end if

boolDownloadOnly = CBool(Request("dl"))

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr

' Clear out any existing HTTP header information 
Response.Clear

' Change the HTTP header to reflect that an image is being passed. 
if FileID <= 0 and topicID > 0 then
	SQLStr = "sp_admincontent_by_topicID " & topicID
	objRec.Open SQLStr, objConn, adOpenStatic, adLockReadOnly, adCmdText
	if not objRec.EOF then
		if objRec("Topic_Type") = 1 then
			FileID = objRec("Type1_FileID")
		end if
	end if
	objRec.Close
elseif FileID <= 0 and topicID <= 0 then
	FileID = 0
end if

if FileID > 0 then
	SQLStr = "SELECT FileName, File_TotalSize, File_BLOB_Data FROM Repository_Topic_Files WHERE ID = " & FileID
	objRec.Open SQLStr, objConn, adOpenDynamic, adLockReadOnly, adCmdText
	if not objRec.EOF then
		if objRec("File_TotalSize") > 0 then
			FileName = objRec("FileName")
			FileSize = objRec("File_TotalSize")
			FileContents = objRec("File_BLOB_Data")
		end if
	end if
	objRec.Close
	
	fullFilePath = tempDirPath & FileName
	FileExt = Mid(FileName, InStrRev(FileName, "."), Len(FileName))
	
	if boolDownloadOnly then
		Response.Clear
		Response.ContentType = "application/unknown" 
		Response.CacheControl = "public"
		Response.Addheader "Content-Disposition", "attachment; filename=" & LCase(FileName)
		Response.AddHeader "Content-Length", FileSize
		Response.BinaryWrite FileContents
	else
		Response.Clear
		Response.CacheControl = "public"
		Response.ContentType = getFileType(LCase(FileName))
		Response.BinaryWrite FileContents
	end if
else
	Response.Write "File Not Found."
end if

Call DB_CleanUp

Sub DB_CleanUp
	'---- ObjectStateEnum Values ----
'	Const adStateClosed = &H00000000
'	Const adStateOpen = &H00000001
'	Const adStateConnecting = &H00000002
'	Const adStateExecuting = &H00000004
'	Const adStateFetching = &H00000008

	if objRec.State <> adStateClosed then
		On Error Resume Next
		objRec.Close
	end if
	if objConn.State <> adStateClosed then
		On Error Resume Next
		objConn.Close
	end if
	Set objRec = Nothing
	Set objConn = Nothing
End Sub
%>