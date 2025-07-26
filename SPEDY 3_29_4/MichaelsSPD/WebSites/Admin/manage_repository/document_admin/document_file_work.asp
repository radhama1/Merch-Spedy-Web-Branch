<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441 
Server.ScriptTimeout = 99999
%>
<!--#include file="./../../app_include/_globalInclude.asp"-->
<!--#include file="./../../app_include/freeaspupload.asp" -->
<%
Dim Uploader, File
Dim topicID
Dim objConn, objRec, SQLStr, connStr, i
Dim objFSO, myFilePath, convertPDFFlag

Set Uploader = New FreeASPUpload
Uploader.Upload()

convertPDFFlag = Uploader.Form("ConvertPDF")

topicID = Uploader.Form("topicID")
if IsNumeric(topicID) then
	topicID = CInt(topicID)
else
	topicID = 0
end if

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")

objConn.Open connStr
objConn.BeginTrans

'--------------------------------------------
'Set Uploaded File Information to Variables
'--------------------------------------------
Dim ks, fileKey
ks = Uploader.UploadedFiles.keys
if (UBound(ks) <> -1) then
    for each fileKey in Uploader.UploadedFiles.keys
		Dim FileName, FileSize, FilePath, FileID, FileType, FileExtension
		FileName = Uploader.UploadedFiles(fileKey).FileName
		FileSize = Uploader.UploadedFiles(fileKey).Length
		FilePath = Uploader.UploadedFiles(fileKey).Path
		
		if Instr(FileName, ".") > 0 then
			FileExtension = Mid(FileName, InStrRev(FileName, "."), Len(FileName))
		else
			FileExtension = ""
		end if
		FileExtension = Replace(FileExtension, ".", "")
		
		if Len(Trim(FileExtension)) > 0 then
			FileType = FileExtension
		else
			FileType = File.ContentType
		end if
		
		FileID = 0

		'--------------------------------------------
		'Save uploaded file to BLOB field in DB
		'--------------------------------------------
		'I know, I know.  Saving files to the database
		'isn't as efficient as saving them natively,
		'but this code will eventually need to be
		'easily portable to a load-balanced server
		'configuration, and I don't want to have to turn
		'around at that time and worry about replicating
		'directories full of uploaded files.  Also,
		'this way, it is much easier to re-use the
		'uploaded files in other apps.  --KW 3.19.02
		'--------------------------------------------
		objConn.CommandTimeout = 3600

		objRec.Open "Repository_Topic_Files", objConn, adOpenDynamic, adLockOptimistic, adCmdTable
		objRec.AddNew

			Response.Write "<br>FileName:" & FileName
			Response.Write "<br>FilePath:" & FilePath
			Response.Write "<br>FileSize:" & FileSize & "<br>"

			'--- Add file to database
			objRec("FileName") = FileName
			objRec("Orig_FilePath") = FilePath
			objRec("File_ContentType") = FileType
			Uploader.SaveToDatabase objRec.Fields("File_BLOB_Data")
			objRec("File_TotalSize") = FileSize
			objRec("Creator_ID") = Session.Value("UserID")
			objRec("Is_Temp_File") = 1

		objRec.Update
		objRec.Close

		'--------------------------------------------
		'Get the assigned file id
		'--------------------------------------------
		SQLStr = "SELECT @@IDENTITY FROM Repository_Topic_Files"
		Set objRec = objConn.Execute(SQLStr)
		FileID = objRec(0)
		objRec.Close
		
		'---------------------------------------------
		'Save a local copy and also save to pdf_queue
		'---------------------------------------------
		if convertPDFFlag = "on" AND lcase(FileExtension) = "pdf" AND CInt(FileID) > 0 then
			
			Set objFSO = Server.CreateObject("Scripting.FileSystemObject")
				
			If Not objFSO.FolderExists(Server.MapPath("FileCache")) Then
				objFSO.CreateFolder(Server.MapPath("FileCache"))
			End If
			If Not objFSO.FolderExists(Server.MapPath("FileCache/" & Year(Now))) Then
				objFSO.CreateFolder(Server.MapPath("FileCache/" & Year(Now)))
			End If
			If Not objFSO.FolderExists(Server.MapPath("FileCache/" & Year(Now) & "/" & padMe(CStr(Month(Now)), 2, "0", "L") & "_" & MonthName(Month(Now)))) Then
				objFSO.CreateFolder(Server.MapPath("FileCache/" & Year(Now) & "/" & padMe(CStr(Month(Now)), 2, "0", "L") & "_" & MonthName(Month(Now))))
			End If

			Set objFSO = Nothing
			
			myFilePath = Server.MapPath("./FileCache/" & Year(Now) & "/" & padMe(CStr(Month(Now)), 2, "0", "L") & "_" & MonthName(Month(Now)))

			Uploader.UploadedFiles(fileKey).FileName = FileID & "_" & Uploader.UploadedFiles(fileKey).FileName
			Uploader.Save myFilePath

			SQLStr = "INSERT INTO PDF_Queue (Repository_Topic_Files_ID, FileLocation) VALUES (" & FileID & ",'" & myFilePath & Uploader.UploadedFiles(fileKey).FileName & "')"
			objConn.Execute(SQLStr)
		
		end if

		if objConn.Errors.Count < 1 and Err.number < 1 then
			objConn.CommitTrans
		else
			objConn.RollbackTrans
		end if

		Call DB_CleanUp
	Next
end if

if CInt(FileID) > 0 then
	Session.Value("FileName") = FileName
	Session.Value("FileID") = CInt(FileID)
	Response.Redirect "document_file_result.asp"
else
	Response.Redirect Request.ServerVariables("HTTP_REFERER")
end if

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