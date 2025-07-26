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

Dim objConn, objRec, SQLStr, connStr, i, j
Dim Topic_Name, Topic_Byline, Topic_Summary, isDefault, Topic_Type, Type1_FileName, Type1_FileID, Type2_LinkURL
Dim Topic_ContactInfo, Topic_SourceWebsite
Dim UserDefinedField1, UserDefinedField2, UserDefinedField3, UserDefinedField4, UserDefinedField5
Dim Topic_Abstract, Topic_Keywords
Dim txtStartDate, txtStartTime, txtEndDate, txtEndTime, boolUseSchedule, boolUseStartDate, boolUseEndDate
Dim allowedRoles, allowedGroups, allowedUsers
Dim role, group, user
Dim arAllowedRoles, arAllowedGroups, arAllowedUsers
Dim categoryID, topicID, boolIsNewDocument, totNumlanguages, curLangID
Dim FileName, FilePath, FileSize, FileID
Dim boolCanSaveChanges
Dim boolIsPublishedItemCopy
Dim NewDocumentStatus

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr

categoryID = Trim(Request.Form("categoryID"))
if IsNumeric(categoryID) then
	categoryID = CInt(categoryID)
else
	categoryID = 0
end if

topicID = Trim(Request.Form("topicID"))
if IsNumeric(topicID) then
	topicID = CInt(topicID)
else
	topicID = 0
end if

boolIsNewDocument = CBool(Request.Form("boolIsNewDocument"))
NewDocumentStatus = CInt(Request.Form("NewDocumentStatus"))
boolIsPublishedItemCopy = CBool(Request.Form("boolIsPublishedItemCopy"))

if boolIsNewDocument or topicID = 0 or boolIsPublishedItemCopy then
	boolIsNewDocument = true
else
	boolIsNewDocument = false
end if

totNumlanguages = Trim(Request.Form("totNumlanguages"))
if IsNumeric(totNumlanguages) then
	totNumlanguages = CInt(totNumlanguages)
else
	totNumlanguages = 0
end if

txtStartDate = Trim(Request.Form("txtStartDate"))
txtStartTime = Trim(Request.Form("txtStartTime"))
txtEndDate = Trim(Request.Form("txtEndDate"))
txtEndTime = Trim(Request.Form("txtEndTime"))

boolUseSchedule = CBool(Request.Form("boolUseSchedule"))
boolUseStartDate = CBool(Request.Form("boolUseStartDate"))
boolUseEndDate = CBool(Request.Form("boolUseEndDate"))

allowedRoles = Trim(Request.Form("allowedRoles"))
allowedGroups = Trim(Request.Form("allowedGroups"))
allowedUsers = Trim(Request.Form("allowedUsers"))

arAllowedRoles = Split(allowedRoles, ",")
arAllowedGroups = Split(allowedGroups, ",")
arAllowedUsers = Split(allowedUsers, ",")

objConn.BeginTrans

'Make sure the user has the document locked,
'if not, save this as a copy.
if not boolIsNewDocument then
	SQLStr = "SELECT * FROM Repository_Topic WHERE [ID] = " & topicID
	objRec.Open SQLStr, objConn, adOpenKeyset, adLockBatchOptimistic, adCmdText
	if not objRec.EOF then
		Response.Write "MOO <br>" & vbCrLF
		Response.Write "Lock_Owner_ID: " & CLng(objRec("Lock_Owner_ID")) & "<br>" & vbCrLF
		Response.Write "UserID: " & CLng(Session.Value("UserID")) & "<br>" & vbCrLF

		if CLng(objRec("Lock_Owner_ID")) = CLng(Session.Value("UserID")) then
			'if this user has locked the document, let them save their changes...
			boolCanSaveChanges = true
		else
			'This user didnt lock their document, or an administrator overrode their lock while they had the edit window open...
			'dont save their changes.  Create a new doument so the user doesnt lose any work.
			boolCanSaveChanges = false
			boolIsNewDocument = true
		end if
	end if
	objRec.Close
else
	boolCanSaveChanges = true
end if

if boolIsNewDocument then
	SQLStr = "SELECT * FROM Repository_Topic"
	objRec.Open SQLStr, objConn, adOpenKeyset, adLockBatchOptimistic, adCmdText
	objRec.AddNew

		if boolUseSchedule then
			if boolUseStartDate then
				if Len(txtStartDate) > 0 and IsDate(txtStartDate) then
					objRec("Start_Date") = CDate(txtStartDate & " " & txtStartTime)
				else
					objRec("Start_Date") = Null
				end if
			else
				objRec("Start_Date") = Null
			end if
			if boolUseEndDate then
				if Len(txtEndDate) > 0 and IsDate(txtEndDate) then
					objRec("End_Date") = CDate(txtEndDate & " " & txtEndTime)
				else
					objRec("End_Date") = Null
				end if
			else
				objRec("End_Date") = Null
			end if
		else
			objRec("Start_Date") = Null
			objRec("End_Date") = Null
		end if
		
		objRec("Status_ID") = NewDocumentStatus

	objRec.UpdateBatch
	objRec.Close

	SQLStr = "SELECT @@IDENTITY FROM Repository_Topic"
	Set objRec = objConn.Execute(SQLStr)
	topicID = objRec(0)
	objRec.Close
else
	SQLStr = "SELECT * FROM Repository_Topic WHERE [ID] = " & topicID
	objRec.Open SQLStr, objConn, adOpenKeyset, adLockBatchOptimistic, adCmdText
	if not objRec.EOF then

		if boolUseSchedule then
			if boolUseStartDate then
				if Len(txtStartDate) > 0 and IsDate(txtStartDate) then
					objRec("Start_Date") = CDate(txtStartDate & " " & txtStartTime)
				else
					objRec("Start_Date") = Null
				end if
			else
				objRec("Start_Date") = Null
			end if
			if boolUseEndDate then
				if Len(txtEndDate) > 0 and IsDate(txtEndDate) then
					objRec("End_Date") = CDate(txtEndDate & " " & txtEndTime)
				else
					objRec("End_Date") = Null
				end if
			else
				objRec("End_Date") = Null
			end if
		else
			objRec("Start_Date") = Null
			objRec("End_Date") = Null
		end if

		objRec("Date_Last_Modified") = CDate(Now())
		objRec.UpdateBatch
	end if
	objRec.Close
end if

UserDefinedField1 = SmartValues(Trim(Request.Form("UserDefinedField1")), "CStr")
UserDefinedField2 = SmartValues(Trim(Request.Form("UserDefinedField2")), "CStr")
UserDefinedField3 = SmartValues(Trim(Request.Form("UserDefinedField3")), "CStr")
UserDefinedField4 = SmartValues(Trim(Request.Form("UserDefinedField4")), "CStr")
UserDefinedField5 = SmartValues(Trim(Request.Form("UserDefinedField5")), "CStr")

for i = 1 to totNumlanguages

	curLangID = SmartValues(Trim(Request.Form("lang" & i & "_langID")), "CInt")
	Topic_Name = SmartValues(Trim(Request.Form("lang" & i & "_dirty_title")), "CStr")
	isDefault = CBool(SmartValues(Trim(Request.Form("lang" & i & "_dirty_boolDefault")), "CBool"))
	if not boolCanSaveChanges and boolIsNewDocument and isDefault then
		Topic_Name = Left(Topic_Name & " (Lock Conflict Backup)", 1000)
	end if
	Topic_Byline = SmartValues(Trim(Request.Form("lang" & i & "_dirty_byline")), "CStr")
	Topic_Summary = SmartValues(Trim(Request.Form("lang" & i & "_dirty_content")), "CStr")
	Topic_Abstract = SmartValues(Trim(Request.Form("lang" & i & "_dirty_abstract")), "CStr")
	Topic_Keywords = SmartValues(Trim(Request.Form("lang" & i & "_dirty_keywords")), "CStr")
	Topic_Type = SmartValues(Trim(Request.Form("lang" & i & "_dirty_type")), "CInt")
	Type1_FileName = SmartValues(Trim(Request.Form("lang" & i & "_dirty_filename")), "CStr")
	Type1_FileID = SmartValues(Trim(Request.Form("lang" & i & "_dirty_fileID")), "CInt")
	Type2_LinkURL = SmartValues(Trim(Request.Form("lang" & i & "_dirty_url")), "CStr")
	Topic_ContactInfo = SmartValues(Trim(Request.Form("lang" & i & "_dirty_topic_contactinfo")), "CStr")
	Topic_SourceWebsite = SmartValues(Trim(Request.Form("lang" & i & "_dirty_topic_sourcewebsite")), "CStr")

	Dim NO_CONTENT
	NO_CONTENT = true
	
	if Len(Topic_Name) > 0 then
		NO_CONTENT = false
	elseif Len(Topic_Summary) > 0 or Len(Type1_FileName) > 0 or Len(Type2_LinkURL) > 0 then
		NO_CONTENT = false
		Topic_Name = "UNTITLED DOCUMENT"
		if Len(Type1_FileName) > 0 then
			Topic_Name = "UNTITLED FILE"
		elseif Len(Type2_LinkURL) > 0 then
			Topic_Name = Type2_LinkURL
		end if
	end if
	
	if NO_CONTENT and isDefault then
		NO_CONTENT = false
		Topic_Name = "UNTITLED DOCUMENT"
	end if

	if CInt(Topic_Type) = 1 then 
		SQLStr = "SELECT * FROM Repository_Topic_Files WHERE ID = " & Type1_FileID
		objRec.Open SQLStr, objConn, adOpenDynamic, adLockBatchOptimistic, adCmdText
		if objRec.EOF then
			Topic_Type = 0
		else
			FileID = objRec("ID")
			FileName = objRec("FileName")
			FilePath = objRec("Orig_FilePath")
			FileSize = objRec("File_TotalSize")
			objRec("Is_Temp_File") = 0
		end if

		objRec.UpdateBatch
		objRec.Close
	end if

	if not NO_CONTENT then
		SQLStr = "SELECT * FROM Repository_Topic_Details WHERE Topic_ID = " & topicID & " AND Language_ID = " & curLangID
		objRec.Open SQLStr, objConn, adOpenKeyset, adLockBatchOptimistic, adCmdText
			if objRec.EOF then
				objRec.AddNew
			end if

			objRec("Topic_ID") = topicID

			if Len(Topic_Name) > 0 then
				objRec("Topic_Name") = Topic_Name
			else
				objRec("Topic_Name") = "UNTITLED DOCUMENT"
			end if

			if Len(Topic_Byline) > 0 then
				objRec("Topic_Byline") = Topic_Byline
			else
				objRec("Topic_Byline") = null
			end if

			if Len(Topic_Summary) > 0 then
				objRec("Topic_Summary") = Topic_Summary
			else
				objRec("Topic_Summary") = null
			end if
			
			if Len(Topic_Abstract) > 0 then
				objRec("Topic_Abstract") = Topic_Abstract
			else
				objRec("Topic_Abstract") = null
			end if

			if Len(Topic_Keywords) > 0 then
				objRec("Topic_Keywords") = Topic_Keywords
			else
				objRec("Topic_Keywords") = null
			end if

			if Len(Topic_ContactInfo) > 0 then
				objRec("Topic_ContactInfo") = Topic_ContactInfo
			else
				objRec("Topic_ContactInfo") = null
			end if

			if Len(Topic_SourceWebsite) > 0 then
				objRec("Topic_SourceWebsite") = Topic_SourceWebsite
			else
				objRec("Topic_SourceWebsite") = null
			end if

			if Len(UserDefinedField1) > 0 then
				objRec("UserDefinedField1") = UserDefinedField1
			else
				objRec("UserDefinedField1") = null
			end if

			if Len(UserDefinedField2) > 0 then
				objRec("UserDefinedField2") = UserDefinedField2
			else
				objRec("UserDefinedField2") = null
			end if

			if Len(UserDefinedField3) > 0 then
				objRec("UserDefinedField3") = UserDefinedField3
			else
				objRec("UserDefinedField3") = null
			end if

			if Len(UserDefinedField4) > 0 then
				objRec("UserDefinedField4") = UserDefinedField4
			else
				objRec("UserDefinedField4") = null
			end if

			if Len(UserDefinedField5) > 0 then
				objRec("UserDefinedField5") = UserDefinedField5
			else
				objRec("UserDefinedField5") = null
			end if

			objRec("Default_Language") = isDefault
			objRec("Language_ID") = curLangID

			if IsNumeric(Topic_Type) then
				objRec("Topic_Type") = Topic_Type
			else
				objRec("Topic_Type") = 0
			end if
			
			Select Case Topic_Type
				Case 0
					objRec("Type1_FileName") = null
					objRec("Type1_FileID") = 0
					objRec("Type1_FileSize") = 0
					objRec("Type2_LinkURL") = null
				Case 1
					if Len(FileName) > 0 then
						objRec("Type1_FileName") = FileName
					else
						objRec("Type1_FileName") = null
					end if
					if FileID > 0 then
						objRec("Type1_FileID") = FileID
					else
						objRec("Type1_FileID") = 0
					end if
					if FileSize > 0 then
						objRec("Type1_FileSize") = FileSize
					else
						objRec("Type1_FileSize") = 0
					end if
					objRec("Type2_LinkURL") = null
				Case 2
					if Len(Type2_LinkURL) > 0 then
						objRec("Type2_LinkURL") = Type2_LinkURL
					else
						objRec("Type2_LinkURL") = null
					end if
					
			End Select

			
			if boolUseSchedule then
				if boolUseStartDate then
					if Len(txtStartDate) > 0 and IsDate(txtStartDate) then
						objRec("Start_Date") = CDate(txtStartDate & " " & txtStartTime)
					else
						objRec("Start_Date") = Null
					end if
				else
					objRec("Start_Date") = Null
				end if
				if boolUseEndDate then
					if Len(txtEndDate) > 0 and IsDate(txtEndDate) then
						objRec("End_Date") = CDate(txtEndDate & " " & txtEndTime)
					else
						objRec("End_Date") = Null
					end if
				else
					objRec("End_Date") = Null
				end if
			else
				objRec("Start_Date") = Null
				objRec("End_Date") = Null
			end if

			objRec("Date_Last_Modified") = CDate(Now())
		objRec.UpdateBatch
		objRec.Close
	
	else
	
		SQLStr = "DELETE FROM Repository_Topic_Details WHERE Topic_ID = " & topicID & " AND Language_ID = " & curLangID
		Set objRec = objConn.Execute(SQLStr)

	end if
	
	curLangID = ""
	Topic_Name = ""
	Topic_Byline = ""
	Topic_Summary = ""
	Topic_Abstract = ""
	Topic_Keywords = ""
	isDefault = ""
	Topic_Type = ""
	Type1_FileName = ""
	Type1_FileID = ""
	Type2_LinkURL = ""

	FileName = ""
	FilePath = ""
	FileSize = ""
	FileID = ""
next


SQLStr = "DELETE FROM Repository_Category_Topic WHERE Topic_ID = " & topicID
Set objRec = objConn.Execute(SQLStr)

SQLStr = "SELECT * FROM Repository_Category_Topic WHERE Topic_ID = " & topicID
objRec.Open SQLStr, objConn, adOpenKeyset, adLockBatchOptimistic, adCmdText
if objRec.EOF then
	objRec.AddNew
	objRec("Topic_ID") = topicID
	objRec("Category_ID") = categoryID
	objRec.Update
end if
objRec.UpdateBatch
objRec.Close

Dim objSecurityPrivilegeRec
Dim strCheckBoxSet, arCheckBoxSet, strCheckBoxSubset

Set objSecurityPrivilegeRec = Server.CreateObject("ADODB.RecordSet")

SQLStr = "sp_security_list_privileges_by_scopeConstant 'ADMIN.CONTENT.REPOSITORY.ITEM'"
objSecurityPrivilegeRec.Open SQLStr, objConn, adOpenStatic, adLockReadOnly, adCmdText
if not objSecurityPrivilegeRec.EOF then

	Do Until objSecurityPrivilegeRec.EOF
		strCheckBoxSet = Request.Form("chk_priv_" & objSecurityPrivilegeRec("ID"))
		arCheckBoxSet = Split(strCheckBoxSet, ",")
		Response.Write "strCheckBoxSet: " & strCheckBoxSet & "<br>" & vbCrLf
		Response.Write "UBound(arCheckBoxSet): " & UBound(arCheckBoxSet) & "<br>" & vbCrLf

		SQLStr = "DELETE FROM Security_Privilege_Object WHERE " &_
				" Privilege_ID =  '" & objSecurityPrivilegeRec("ID") & "' " &_
				" AND Secured_Object_ID = '" & topicID & "' "
		Response.Write SQLStr & "<br>" & vbCrLf
		Set objRec = objConn.Execute(SQLStr)
	
		'iterate thru the roles and groups
		strCheckBoxSubset = ""
		for i = 0 to UBound(arCheckBoxSet)
			if InStr(arCheckBoxSet(i), "role_") > 0 or InStr(arCheckBoxSet(i), "group_") > 0 then
				if Len(Trim(strCheckBoxSubset)) > 0 then strCheckBoxSubset = strCheckBoxSubset & ","
				strCheckBoxSubset = strCheckBoxSubset & Replace(Replace(arCheckBoxSet(i), "role_", ""), "group_", "")
			end if
		next
		
		if Len(strCheckBoxSubset) > 0 then
			SQLStr = "INSERT INTO Security_Privilege_Object (Privilege_ID, Secured_Object_ID, Group_ID, User_ID) " &_
					" SELECT '" & objSecurityPrivilegeRec("ID") & "' As Privilege_ID," &_
					" '" & topicID & "' As Secured_Object_ID," &_
					" Element As Group_ID," &_
					" 0 As User_ID " &_
					" FROM dbo.Split('" & strCheckBoxSubset & "', ',')"
			Response.Write SQLStr & "<br>" & vbCrLf
			Set objRec = objConn.Execute(SQLStr)
		end if

		'iterate thru the users
		strCheckBoxSubset = ""
		for i = 0 to UBound(arCheckBoxSet)
			response.Write "IN HERE"
			if InStr(arCheckBoxSet(i), "user_") then
				if Len(Trim(strCheckBoxSubset)) > 0 then strCheckBoxSubset = strCheckBoxSubset & ","
				strCheckBoxSubset = strCheckBoxSubset & Replace(arCheckBoxSet(i), "user_", "")
			end if
		next
		
		if Len(strCheckBoxSubset) > 0 then
			SQLStr = "INSERT INTO Security_Privilege_Object (Privilege_ID, Secured_Object_ID, Group_ID, User_ID) " &_
					" SELECT '" & objSecurityPrivilegeRec("ID") & "' As Privilege_ID," &_
					" '" & topicID & "' As Secured_Object_ID," &_
					" 0 As Group_ID," &_
					" Element As User_ID " &_
					" FROM dbo.Split('" & strCheckBoxSubset & "', ',')"
			Response.Write SQLStr & "<br>" & vbCrLf
			Set objRec = objConn.Execute(SQLStr)
		end if
	
		objSecurityPrivilegeRec.MoveNext
	Loop
	
end if
Set objSecurityPrivilegeRec = Nothing

if objConn.Errors.Count < 1 and Err.number < 1 then
	objConn.CommitTrans
	Session.Value("CONTENT_SAVE_SUCCESS") = "1"
else
	objConn.RollbackTrans
	Session.Value("CONTENT_SAVE_SUCCESS") = "0"
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

if CBool(Session.Value("CONTENT_SAVE_SUCCESS")) then
%>
<script language="javascript">
	//Set a reference to the Details frame in the Repository frameset...
	var myFrameSetRef = new Object(parent.window.opener.parent.parent.frames['DetailFrameWrapper'].frames['DetailFrame']);
	
	//If the user hasnt left the repository framset, then refresh the details screen, otherwise dont worry bout it...
	if (typeof(myFrameSetRef == 'object'))
	{
	//	myFrameSetRef.document.location.reload();
	}

	parent.frames['body'].document.location = "document_details.asp?tid=<%=topicID%>&cid=<%=categoryID%>&curlangord=<%=Request("CurrentSelectedLanguageOrdinal")%>";
</script>
<%
else
%>
Errors Occurred.  Please Try Again. Or...<br>
<a href="javascript:self.close();">Click to close</a>
<%
end if
%>
