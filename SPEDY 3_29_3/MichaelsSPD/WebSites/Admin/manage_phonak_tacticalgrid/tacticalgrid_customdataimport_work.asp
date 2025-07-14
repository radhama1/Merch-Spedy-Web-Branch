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
<!--#include file="./../app_include/_globalInclude.asp"-->
<!--#include file="./../app_include/freeaspupload.asp" -->
<%
Dim Uploader, File
Dim objConn, objRec, SQLStr, connStr, i
Dim objFSO, myFilePath, myFileName
Dim Relative_Path, Physical_Path
Dim Table_ID, Column_ID
Dim Table_Name, Is_LookupTable
Dim Column_Name, Use_LookupTable, LookupTable_TableName, LookupTable_Key_ColumnName, LookupTable_Value_ColumnName
Dim csvfile, first_line
Dim ActivityLog, ActivityType, ActivityReferenceType

Set Uploader = New FreeASPUpload
Uploader.Upload()

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

		objRec.Open "Phonak_ImportedFiles", objConn, adOpenDynamic, adLockOptimistic, adCmdTable
		objRec.AddNew

			Response.Write "<br>FileName:" & FileName
			Response.Write "<br>FilePath:" & FilePath
			Response.Write "<br>FileSize:" & FileSize & "<br>"

			'--- Add file to database
			objRec("FileName") = FileName
			objRec("File_ContentType") = FileType
			Uploader.SaveToDatabase objRec.Fields("File_Data")
			objRec("File_TotalSize") = FileSize
			objRec("Creator_ID") = Session.Value("UserID")

		objRec.Update
		objRec.Close

		'--------------------------------------------
		'Get the assigned file id
		'--------------------------------------------
		SQLStr = "SELECT @@IDENTITY FROM Phonak_ImportedFiles"
		Set objRec = objConn.Execute(SQLStr)
		FileID = objRec(0)
		objRec.Close
		
		if objConn.Errors.Count < 1 and Err.number < 1 then
			objConn.CommitTrans
		else
			objConn.RollbackTrans
		end if

		'---------------------------------------------
		'Save a local copy
		'---------------------------------------------
		Relative_Path = "./files/import/csv_import/" & Year(Now) & "/" & padMe(CStr(Month(Now)), 2, "0", "L") & "_" & MonthName(Month(Now)) & "/"
		Physical_Path = InitRelativeFolder(Relative_Path, false)
		
		myFilePath = Physical_Path
		myFileName = Year(Now) & padMe(CStr(Month(Now)), 2, "0", "L") & padMe(CStr(Day(Now)), 2, "0", "L") & Hour(Now) & Minute(Now) & Second(Now) & "_" & _
						Right(Uploader.UploadedFiles(fileKey).FileName, 25)
		Response.Write "myFilePath: " & myFilePath & "<br>"
		Response.Write "myFileName: " & myFileName & "<br>"
		
		myFileName = Replace(myFileName, "-", "_")

		Uploader.UploadedFiles(fileKey).FileName =	myFileName
		Uploader.Save myFilePath
		
		Table_ID = Uploader.Form("selTable")
		Column_ID = Uploader.Form("selColumn")
		Response.Write "Table_ID: " & Table_ID & "<br>"
		Response.Write "Column_ID: " & Column_ID & "<br>"

		SQLStr = "SELECT * FROM Phonak_Updateable_Table WHERE ID = '0" & Table_ID & "'"
		Response.Write "SQLStr: " & SQLStr & "<br>"
		objRec.Open SQLStr, objConn, adOpenDynamic, adLockOptimistic, adCmdText
		if not objRec.EOF then
		
			Table_Name = SmartValues(objRec("Table_Name"), "CStr")
			Is_LookupTable = SmartValues(objRec("Is_LookupTable"), "CBool")
			
		end if
		objRec.Close

		SQLStr = "SELECT * FROM Phonak_Updateable_Table_Column WHERE ID = '0" & Column_ID & "'"
		Response.Write "SQLStr: " & SQLStr & "<br>"
		objRec.Open SQLStr, objConn, adOpenDynamic, adLockOptimistic, adCmdText
		if not objRec.EOF then
		
			Column_Name = SmartValues(objRec("Column_Name"), "CStr")
			Use_LookupTable = SmartValues(objRec("Use_LookupTable"), "CBool")
			LookupTable_TableName = SmartValues(objRec("LookupTable_TableName"), "CStr")
			LookupTable_Key_ColumnName = SmartValues(objRec("LookupTable_Key_ColumnName"), "CStr")
			LookupTable_Value_ColumnName = SmartValues(objRec("LookupTable_Value_ColumnName"), "CStr")
			
		end if
		objRec.Close

		'Set Variables needed for the files to be saved
		set objFSO = CreateObject("Scripting.FileSystemObject")
		set csvfile = objFSO.OpenTextFile(myFilePath & "\" & myFileName)

		first_line = csvfile.ReadLine()
		
		if first_line = "AccountNumber,NewData" or first_line = """AccountNumber"",""NewData""" then
			'Good, the first line has the correct headers
			Set ActivityLog = New cls_ActivityLog
			Set ActivityType = New cls_ActivityType

			ActivityLog.Activity_Type = 100
			ActivityLog.Activity_Summary = Trim(Session.Value("User_First_Name") & " " & Session.Value("User_Last_Name")) & " uploaded a custom data csv file named """ & FileName & """(" & FileID & ") to update data in the Tactical Grid."

			ActivityLog.Reference_ID = FileID	
			ActivityLog.Save

			Set ActivityLog = Nothing
			Set ActivityType = Nothing
		else
			'Boo. This user didnt follow directions.
			Set ActivityLog = New cls_ActivityLog
			Set ActivityType = New cls_ActivityType

			ActivityLog.Activity_Type = 100
			ActivityLog.Activity_Summary = Trim(Session.Value("User_First_Name") & " " & Session.Value("User_Last_Name")) & " uploaded csv file """ & FileName & """(" & FileID & "), but it was incorrectly formatted to update data in the Tactical Grid."

			ActivityLog.Reference_ID = FileID	
			ActivityLog.Save

			Set ActivityLog = Nothing
			Set ActivityType = Nothing

			Session.Value("TACTICALGRID_CUSTOMDATAIMPORT_MESSAGE") = "<div class=""messageHeader"">Woops!</div>Sorry, your file (" & FileName & ") could not be used, because it wasn't formatted properly.  <br><br>The first line should contain only two column headers: <b>AccountNumber</b> and <b>NewData</b>. Refer to the <a href=""sample.csv"">sample CSV file</a> if you need help.<br><br>Please modify your file and try again."
			Call DB_CleanUp
			Response.Redirect "tacticalgrid_customdataimport.asp"
		end if

		Set csvfile = nothing
		Set objFSO = nothing

		if not Is_LookupTable then
			if Use_LookupTable then
				SQLStr = "UPDATE [" & Table_Name & "] " & vbCrLf &_
						" SET [" & Column_Name & "] = look.[" & LookupTable_Key_ColumnName & "] " & vbCrLf &_
						" FROM [" & Table_Name & "] target WITH (NOLOCK) " & vbCrLf &_
						" INNER JOIN " & vbCrLf &_
						" ( " & vbCrLf &_
						" SELECT * " & vbCrLf &_
						" FROM " & vbCrLf &_
						" 	OPENROWSET('MSDASQL', " & vbCrLf &_
						" 		'Driver={Microsoft Text Driver (*.txt; *.csv)}; " & vbCrLf &_
						" 			DEFAULTDIR=" & myFilePath & ";Extensions=CSV;', " & vbCrLf &_
						" 		'SELECT * FROM [" & myFileName & "]') " & vbCrLf &_
						" ) As import ON target.AcctNumber = CONVERT(varchar(50), import.AccountNumber)" & vbCrLf &_
						" INNER JOIN [" & LookupTable_TableName & "] look WITH (NOLOCK) ON look.[" & LookupTable_Value_ColumnName & "] = import.NewData"
				'Response.Write "SQLStr: " & Replace(SQLStr, vbCrLf, "<br>") & "<br>"
				objConn.Execute(SQLStr)
			else
				SQLStr = "UPDATE [" & Table_Name & "] " & vbCrLf &_
						" SET [" & Column_Name & "] = import.NewData " & vbCrLf &_
						" FROM [" & Table_Name & "] target WITH (NOLOCK) " & vbCrLf &_
						" INNER JOIN " & vbCrLf &_
						" ( " & vbCrLf &_
						" SELECT * " & vbCrLf &_
						" FROM " & vbCrLf &_
						" 	OPENROWSET('MSDASQL', " & vbCrLf &_
						" 		'Driver={Microsoft Text Driver (*.txt; *.csv)}; " & vbCrLf &_
						" 			DEFAULTDIR=" & myFilePath & ";Extensions=CSV;', " & vbCrLf &_
						" 		'SELECT * FROM [" & myFileName & "]') " & vbCrLf &_
						" ) As import ON target.AcctNumber = CONVERT(varchar(50), import.AccountNumber)"
				'Response.Write "SQLStr: " & Replace(SQLStr, vbCrLf, "<br>") & "<br>"
				objConn.Execute(SQLStr)
			end if
		else
			SQLStr = "UPDATE [" & Table_Name & "] SET Display = 0"
			Response.Write "SQLStr: " & Replace(SQLStr, vbCrLf, "<br>") & "<br>"
			objConn.Execute(SQLStr)
			
			SQLStr = "INSERT INTO [" & Table_Name & "] (Type_Name, Display) " & vbCrLf &_
					" SELECT import.NewData, 1" & vbCrLf &_
					" FROM ( " & vbCrLf &_
					" SELECT * " & vbCrLf &_
					" FROM " & vbCrLf &_
					" 	OPENROWSET('MSDASQL', " & vbCrLf &_
					" 		'Driver={Microsoft Text Driver (*.txt; *.csv)}; " & vbCrLf &_
					" 			DEFAULTDIR=" & myFilePath & ";Extensions=CSV;', " & vbCrLf &_
					" 		'SELECT * FROM " & myFileName & "') " & vbCrLf &_
					" ) As import"
			Response.Write "SQLStr: " & Replace(SQLStr, vbCrLf, "<br>") & "<br>"
			objConn.Execute(SQLStr)
		end if

		Call DB_CleanUp
	Next
else
	Session.Value("TACTICALGRID_CUSTOMDATAIMPORT_MESSAGE") = "<div class=""messageHeader"">Uh-Oh!</div>Sorry, " & FileName & " could not be uploaded."
	Call DB_CleanUp
	Response.Redirect "tacticalgrid_customdataimport.asp"
end if

if CLng(FileID) > 0 then
	Session.Value("TACTICALGRID_CUSTOMDATAIMPORT_MESSAGE") = "<div class=""messageHeader"">Success!</div>Table " & Table_Name & " has been successfully updated with the data from " & FileName & "."
	Response.Redirect "tacticalgrid_customdataimport.asp"
else
	Session.Value("TACTICALGRID_CUSTOMDATAIMPORT_MESSAGE") = "<div class=""messageHeader"">Success!</div>Table " & Table_Name & " was not updated from " & FileName & " because the file could not be uploaded."
	Response.Redirect "tacticalgrid_customdataimport.asp"
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