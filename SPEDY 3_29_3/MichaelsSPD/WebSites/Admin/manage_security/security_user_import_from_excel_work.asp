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
Dim csvfile, first_line

Set Uploader = New FreeASPUpload
Uploader.Upload()

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")

objConn.Open connStr

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

		objConn.CommandTimeout = 3600

		'---------------------------------------------
		'Save a local copy
		'---------------------------------------------
		Relative_Path = "./files/import/csv_import/" & Year(Now) & "/" & padMe(CStr(Month(Now)), 2, "0", "L") & "_" & MonthName(Month(Now)) & "/"
		Physical_Path = InitRelativeFolder(Relative_Path, false)

		
		myFilePath = Physical_Path
		myFileName = Year(Now) & padMe(CStr(Month(Now)), 2, "0", "L") & padMe(CStr(Day(Now)), 2, "0", "L") & Hour(Now) & Minute(Now) & Second(Now) & "_" & _
						Right(Uploader.UploadedFiles(fileKey).FileName, 25)
		'Response.Write "myFilePath: " & myFilePath & "<br>"
		'Response.Write "myFileName: " & myFileName & "<br>"
		
		myFileName = Replace(myFileName, "-", "_")

		Uploader.UploadedFiles(fileKey).FileName =	myFileName
		Uploader.Save myFilePath
		
		'Set Variables needed for the files to be saved
		set objFSO = CreateObject("Scripting.FileSystemObject")
		set csvfile = objFSO.OpenTextFile(myFilePath & "\" & myFileName)

		first_line = Trim(SmartValues(csvfile.ReadLine(), "CStr"))
		
		
		Dim Import_ID			
		Dim Invalid_Departments_Found, Invalid_Department_List
		
		if first_line = """Security_User_ID"",""Rank"",""Email_Address"",""UserName"",""Enabled"",""Last_Name"",""First_Name"",""Organization"",""Department"",""Access_New_Item"",""Access_Item_Maintenance"",""Access_PO_Creation"",""Access_PO_Maintenance"",""Job_Title"",""Office_Location"",""Gender"",""Date_Created"",""Date_Last_Modified""" OR first_line = "Security_User_ID,Rank,Email_Address,UserName,Enabled,Last_Name,First_Name,Organization,Department,Access_New_Item,Access_Item_Maintenance,Access_PO_Creation,Access_PO_Maintenance,Job_Title,Office_Location,Gender,Date_Created,Date_Last_Modified"	Then
			'Good, the first line has the correct headers
						
			Import_ID = 0
			Invalid_Departments_Found = False
						
			'Create New Import
			SQLStr = "sp_Security_User_Import_Insert @Import_User_ID=" & Session("UserID")
			objRec.Open SQLStr, connStr, adOpenForwardOnly, adLockReadOnly			
			
			If Not objRec.EOF Then
				Import_ID = SmartValues(objRec("ID"), "CLng")
			End If
			objRec.Close
			
			'Loop through the file, and save records into the TEMP table.
			do while csvfile.AtEndOfStream = false
			
				Dim csvLine 
				csvLine = Trim(SmartValues(csvfile.ReadLine(), "CStr"))
				'Response.Write(csvLine)
								
				Dim index
				index = 0
								
				Dim userID, rank, emailAddress, userName, isEnabled, lastName, firstName, organization, department, accessNewItem, accessItemMaint, accessPOCreate, accessPOMaint
				Dim jobTitle, officeLocation, gender, dateCreated, dateModified
				
				userID = GetNextArg(csvLine)
				rank = GetNextArg(csvLine)
				emailAddress = GetNextArg(csvLine)
				userName = GetNextArg(csvLine)
				isEnabled = GetNextArg(csvLine)
				lastName = GetNextArg(csvLine)
				firstName = GetNextArg(csvLine)
				organization = GetNextArg(csvLine)
				department = GetNextArg(csvLine)
				accessNewItem = GetNextArg(csvLine)
				accessItemMaint = GetNextArg(csvLine)
				accessPOCreate = GetNextArg(csvLine)
				accessPOMaint = GetNextArg(csvLine)
				jobTitle = GetNextArg(csvLine)
				officeLocation = GetNextArg(csvLine)
				gender = GetNextArg(csvLine)
				dateCreated = GetNextArg(csvLine)
				dateModified = GetNextArg(csvLine)
				
				
				SQLStr = "INSERT INTO [Security_User_Import_Item] (Import_ID, Security_User_ID, Email_Address, UserName, Enabled, Last_Name, First_Name, Organization, Department, Access_New_Item, Access_Item_Maintenance, Access_PO_Creation, Access_PO_Maintenance, Job_Title, Office_Location, Gender) " & vbCrLf &_
				"VALUES(" & Import_ID & "," &  _
							Parameterize(userID, True, False) & "," &  _
							Parameterize(Replace(emailAddress,"'","''"), False, False) & "," & _
							Parameterize(Replace(userName,"'","''"), False, False) & "," & _
							Parameterize(isEnabled, False, True) & "," & _
							Parameterize(Replace(lastName,"'","''"), True, False) & "," & _
							Parameterize(Replace(firstName,"'","''"), True, False) & "," & _
							Parameterize(Replace(organization,"'","''"), True, False) & "," & _
							Parameterize(Replace(Replace(department, " ", ""),"'","''"), True, False) & "," & _
							Parameterize(accessNewItem, False, True) & "," & _
							Parameterize(accessItemMaint, False, True) & "," & _
							Parameterize(accessPOCreate, False, True) & "," & _
							Parameterize(accessPOMaint, False, True) & "," & _
							Parameterize(Replace(jobTitle,"'","''"), True, False) & "," & _
							Parameterize(Replace(officeLocation,"'","''"), True, False) & "," & _
							Parameterize(gender, True, False) & "" & _
							")"
				
				'Response.Write(SQLStr)
				objConn.Execute(SQLStr)
				
				
			loop
				
			'Get List Of Invalid Departments
			SQLStr = "sp_security_user_import_get_invalid_departments @Import_ID=" & Import_ID
			objRec.Open SQLStr, connStr, adOpenForwardOnly, adLockReadOnly
			
			If Not objRec.EOF Then
				
				Invalid_Departments_Found = True				
				Invalid_Department_List = "" & _
					"<table cellpadding=0 cellspacing=0 width=""300"" class=""invalidDepts"">" & _
					"<tr>" & _
						"<th>UserName</th>" & _
						"<th>Last Name</th>" & _
						"<th>First Name</th>" & _
						"<th>Invalid Departments</th>" & _
					"</tr>"												
				
				Do Until objRec.EOF
				
					Invalid_Department_List = Invalid_Department_List & _
						"<tr>" & _
							"<td>" & SmartValues(objRec("UserName"), "CStr") & "</td>" & _
							"<td>" & SmartValues(objRec("Last_Name"), "CStr") & "</td>" & _
							"<td>" & SmartValues(objRec("First_Name"), "CStr") & "</td>" & _
							"<td>" & SmartValues(objRec("Invalid_Departments"), "CStr") & "</td>" & _
						"</tr>"
			
					objRec.MoveNext()

				Loop
				
				Invalid_Department_List = Invalid_Department_List & "</table>"
			
			End If
			objRec.Close
			
			If Invalid_Departments_Found Then			
				
				'Send Message Back To User
				Session.Value("SECURITYUSER_CUSTOMDATAIMPORT_MESSAGE") = "<div class=""messageHeader"">Woops!</div>Sorry, your file (" & FileName & ") could not be used, because it contains users with invalid departments.<br><br>"
				Session.Value("SECURITYUSER_CUSTOMDATAIMPORT_MESSAGE") = Session.Value("SECURITYUSER_CUSTOMDATAIMPORT_MESSAGE") & Invalid_Department_List
				
				Call DB_CleanUp
				Response.Redirect "security_user_import_from_excel.asp"
			
			Else
			
				'Process Import
				SQLStr = "sp_security_user_import_process @Import_ID=" & Import_ID
				objConn.Execute(SQLStr)
			
			End If
			
		else
			'Boo. This user didnt follow directions.
			Session.Value("SECURITYUSER_CUSTOMDATAIMPORT_MESSAGE") = "<div class=""messageHeader"">Woops!</div>Sorry, your file (" & FileName & ") could not be used, because it wasn't formatted properly.  Refer to the <a href=""./security_user_export_to_excel.asp?template=1"" onMouseOver=""window.status='';return true;"" onMouseOut=""window.status='';return true;"">sample CSV file</a> if you need help.<br><br>Please modify your file and try again."
			Call DB_CleanUp
			Response.Redirect "security_user_import_from_excel.asp"
		end if

		csvfile.close
		Set csvfile = nothing
		Set objFSO = nothing

		Call DB_CleanUp
	Next
else
	Session.Value("SECURITYUSER_CUSTOMDATAIMPORT_SUCCESS") = 0
	Session.Value("SECURITYUSER_CUSTOMDATAIMPORT_MESSAGE") = "<div class=""messageHeader"">Uh-Oh!</div>Sorry, " & FileName & " could not be uploaded."
	Call DB_CleanUp
	Response.Redirect "security_user_import_from_excel.asp"
end if

Session.Value("SECURITYUSER_CUSTOMDATAIMPORT_SUCCESS") = 1
Session.Value("SECURITYUSER_CUSTOMDATAIMPORT_MESSAGE") = "<div class=""messageHeader"">Success!</div>Security Users have been successfully updated with the data from " & FileName & "."
Response.Redirect "security_user_import_from_excel.asp"


Function Parameterize(arg, allowNull, isBoolean)

	If Len(arg) = 0 Then
		If allowNull Then
			Parameterize = "NULL"
		Else
			Parameterize = "''"
		End If
	Else
		If isBoolean Then
			If UCase(arg) = "TRUE" Then 
				Parameterize = "1"
			Else
				Parameterize = "0"
			End IF
		Else 
			Parameterize = "'" & arg & "'"
		End If
	End IF
End Function

Function GetNextArg(ByRef csvLine)
	If InStr(csvLine, """") = 1 Then
	
		csvLine = Mid(csvLine, 2, Len(csvLine)-1)
		
		Dim parenIndex
		parenIndex = InStr(csvLine, """")
		
		GetNextArg = Left(csvLine, parenIndex-1)
		
		If (Len(csvLine) - (parenIndex+1)) >=0 Then
			csvLine = Mid(csvLine, parenIndex + 2, Len(csvLine) - (parenIndex+1))
		Else
			csvLine = Mid(csvLine, parenIndex + 2, Len(csvLine) - (parenIndex))
		End If
	
	Else
		Dim commaIndex, arg
		commaIndex = InStr(csvLine, ",")
		
		If commaIndex > 0 Then
			GetNextArg = Left(csvLine, commaIndex-1)
			csvLine = Mid(csvLine, commaIndex + 1, Len(csvLine)-commaIndex)
		Else
			GetNextArg = csvLine
		End If
		
	End If
End Function



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
