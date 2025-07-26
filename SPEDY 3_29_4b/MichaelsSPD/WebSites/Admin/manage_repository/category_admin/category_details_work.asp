<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441
%>
<!--#include file="./../../app_include/_globalInclude.asp"-->
<%
Dim Security
Dim ActivityLog, ActivityType, ActivityReferenceType

Set Security = New cls_Security
Security.Initialize Session.Value("UserID"), "ADMIN.CONTENT.REPOSITORY.CATEGORY", checkQueryID(Request("cid"), 0)
Set ActivityLog				= New cls_ActivityLog
Set ActivityType			= New cls_ActivityType
Set ActivityReferenceType	= New cls_ActivityReferenceType

ActivityLog.Reference_Type = ActivityReferenceType.Content_Category
			
Dim objConn, objRec, SQLStr, connStr, i
Dim categoryID, boolIsNew, parentCategoryID
Dim Category_Name, Category_Summary, isEnabled
Dim LargeImgFileName, ThumbImgFileName, InstallGuideFileName, BOMFileName
Dim txtStartDate, txtStartTime, txtEndDate, txtEndTime, boolUseSchedule, boolUseStartDate, boolUseEndDate
Dim allowedRoles, allowedGroups, allowedUsers
Dim arAllowedRoles, arAllowedGroups, arAllowedUsers
Dim role, group, user
Dim boolCreateDefaultDocumentOnSave


Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr

categoryID = checkQueryID(Request("cid"), 0)
parentCategoryID = checkQueryID(Request("pcid"), 0)

boolIsNew = CBool(Request.Form("boolIsNew"))

if boolIsNew and categoryID = 0 then
	boolIsNew = true
else
	boolIsNew = false
end if

boolCreateDefaultDocumentOnSave = CBool(checkQueryID(Request("boolCreateDefaultDocumentOnSave"), 0))

Category_Name = Trim(Request.Form("Category_Name"))
Category_Summary = Trim(Request.Form("Category_Summary"))
LargeImgFileName = Trim(Request.Form("LargeImgFileName"))
ThumbImgFileName = Trim(Request.Form("ThumbImgFileName"))
InstallGuideFileName = Trim(Request.Form("InstallGuideFileName"))
BOMFileName = Trim(Request.Form("BOMFileName"))

'Schedule
txtStartDate = Trim(Request.Form("txtStartDate"))
txtStartTime = Trim(Request.Form("txtStartTime"))
txtEndDate = Trim(Request.Form("txtEndDate"))
txtEndTime = Trim(Request.Form("txtEndTime"))

boolUseSchedule = CBool(Request.Form("boolUseSchedule"))
boolUseStartDate = CBool(Request.Form("boolUseStartDate"))
boolUseEndDate = CBool(Request.Form("boolUseEndDate"))

'Security
allowedRoles = Trim(Request.Form("allowedRoles"))
allowedGroups = Trim(Request.Form("allowedGroups"))
allowedUsers = Trim(Request.Form("allowedUsers"))
arAllowedRoles = Split(allowedRoles, ",")
arAllowedGroups = Split(allowedGroups, ",")
arAllowedUsers = Split(allowedUsers, ",")

objConn.BeginTrans

if boolIsNew then
	objRec.Open "Repository_Category", objConn, adOpenKeyset, adLockOptimistic, adCmdTable
	objRec.AddNew
	
	objRec("Parent_Category_ID") = parentCategoryID

	if Len(Category_Name) > 0 then
		objRec("Category_Name") = SmartValues(Category_Name, "CStr")
	else
		objRec("Category_Name") = "UNTITLED CATEGORY"
	end if
	if Len(Category_Summary) > 0 then
		objRec("Category_Summary") = SmartValues(Category_Summary, "CStr")
	else
		objRec("Category_Summary") = Null
	end if

	objRec.Update
	objRec.Close

	SQLStr = "SELECT @@IDENTITY FROM Repository_Category"
	Set objRec = objConn.Execute(SQLStr)
	categoryID = objRec(0)
	objRec.Close

else
	SQLStr = "SELECT * FROM Repository_Category WHERE [ID] = " & categoryID
	objRec.Open SQLStr, objConn, adOpenKeyset, adLockBatchOptimistic, adCmdText
	if not objRec.EOF then

		if Len(Category_Name) > 0 then
			Category_Name = SmartValues(Category_Name, "CStr")
		else
			Category_Name = "UNTITLED CATEGORY"
		end if
		objRec("Category_Name") = Category_Name
		if Len(Category_Summary) > 0 then
			objRec("Category_Summary") = SmartValues(Category_Summary, "CStr")
		else
			objRec("Category_Summary") = Null
		end if

		objRec("Date_Last_Modified") = CDate(Now())
		objRec.UpdateBatch
	end if
	objRec.Close
end if

if boolCreateDefaultDocumentOnSave then
	addDocumentToRepository categoryID, Category_Name
end if

Dim objSecurityPrivilegeRec
Dim strCheckBoxSet, arCheckBoxSet, strCheckBoxSubset

Set objSecurityPrivilegeRec = Server.CreateObject("ADODB.RecordSet")

SQLStr = "sp_security_list_privileges_by_scopeConstant 'ADMIN.CONTENT.REPOSITORY.CATEGORY'"
objSecurityPrivilegeRec.Open SQLStr, objConn, adOpenStatic, adLockReadOnly, adCmdText
if not objSecurityPrivilegeRec.EOF then

	Do Until objSecurityPrivilegeRec.EOF
		strCheckBoxSet = Request.Form("chk_priv_" & objSecurityPrivilegeRec("ID"))
		arCheckBoxSet = Split(strCheckBoxSet, ",")
		'Response.Write "strCheckBoxSet: " & strCheckBoxSet & "<br>" & vbCrLf
		'Response.Write "UBound(arCheckBoxSet): " & UBound(arCheckBoxSet) & "<br>" & vbCrLf

		SQLStr = "DELETE FROM Security_Privilege_Object WHERE " &_
				" Privilege_ID =  '" & objSecurityPrivilegeRec("ID") & "' " &_
				" AND Secured_Object_ID = '" & categoryID & "' "
		'Response.Write SQLStr & "<br>" & vbCrLf
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
					" '" & categoryID & "' As Secured_Object_ID," &_
					" Element As Group_ID," &_
					" 0 As User_ID " &_
					" FROM dbo.Split('" & strCheckBoxSubset & "', ',')"
			'Response.Write SQLStr & "<br>" & vbCrLf
			Set objRec = objConn.Execute(SQLStr)
		end if

		'iterate thru the users
		strCheckBoxSubset = ""
		for i = 0 to UBound(arCheckBoxSet)
			if InStr(arCheckBoxSet(i), "user_") then
				if Len(Trim(strCheckBoxSubset)) > 0 then strCheckBoxSubset = strCheckBoxSubset & ","
				strCheckBoxSubset = strCheckBoxSubset & Replace(arCheckBoxSet(i), "user_", "")
			end if
		next
		
		if Len(strCheckBoxSubset) > 0 then
			SQLStr = "INSERT INTO Security_Privilege_Object (Privilege_ID, Secured_Object_ID, Group_ID, User_ID) " &_
					" SELECT '" & objSecurityPrivilegeRec("ID") & "' As Privilege_ID," &_
					" '" & categoryID & "' As Secured_Object_ID," &_
					" 0 As Group_ID," &_
					" Element As User_ID " &_
					" FROM dbo.Split('" & strCheckBoxSubset & "', ',')"
			'Response.Write SQLStr & "<br>" & vbCrLf
			Set objRec = objConn.Execute(SQLStr)
		end if
	
		objSecurityPrivilegeRec.MoveNext
	Loop
	
	if CBool(Request.Form("PropogatePrivilegesToChildren")) then
		SQLStr = "sp_repository_category_propogateobjectsecuritytochildren '0" & categoryID & "'"
		Set objRec = objConn.Execute(SQLStr)
	end if
	
end if
Set objSecurityPrivilegeRec = Nothing

if objConn.Errors.Count < 1 and Err.number < 1 then
	objConn.CommitTrans
	Session.Value("CONTENTCATEGORY_SAVE_SUCCESS") = "1"
	
	ActivityLog.Reference_ID = categoryID
	
	if boolIsNew then
		ActivityLog.Activity_Type = ActivityType.Create_ID
		ActivityLog.Activity_Summary = "Created New Category " & Category_Name
	else
		ActivityLog.Activity_Type = ActivityType.Modify_ID
		ActivityLog.Activity_Summary = "Modified Category " & Category_Name
	end if
	
	ActivityLog.Save
	
else
	objConn.RollbackTrans
	Session.Value("CONTENTCATEGORY_SAVE_SUCCESS") = "0"
end if

Set ActivityLog				= Nothing
Set ActivityType			= Nothing
Set ActivityReferenceType	= Nothing

Call DB_CleanUp

function addDocumentToRepository(p_Parent_Category_ID, p_Document_Name)
	Dim m_topicID, m_repositoryTopicDetailsID
	SQLStr = "INSERT INTO Repository_Topic (Start_Date) VALUES (NULL)"
	objRec = objConn.Execute(SQLStr)

	SQLStr = "SELECT @@IDENTITY FROM Repository_Topic"
	Set objRec = objConn.Execute(SQLStr)
	m_topicID = objRec(0)
	objRec.Close

	SQLStr = "INSERT INTO Repository_Topic_Details (Topic_ID, Topic_Name, Default_Language, Language_ID, Topic_Type) " &_
			" VALUES ('0" & m_topicID & "', '" & p_Document_Name & "', 1, 0, 0)"
	objRec = objConn.Execute(SQLStr)

	SQLStr = "SELECT @@IDENTITY FROM Repository_Topic_Details"
	Set objRec = objConn.Execute(SQLStr)
	m_repositoryTopicDetailsID = objRec(0)
	objRec.Close

	SQLStr = "INSERT INTO Repository_Category_Topic (Topic_ID, Category_ID) " &_
			" VALUES ('0" & m_topicID & "', '0" & p_Parent_Category_ID & "')"
	objRec = objConn.Execute(SQLStr)

	addDocumentToRepository = m_topicID
end function

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

if CBool(Session.Value("CONTENTCATEGORY_SAVE_SUCCESS")) then
%>
<script language="javascript">
	parent.frames["header"].document.location = "./../../app_include/blank_cccccc.html";
	parent.frames["controls"].document.location = "./../../app_include/blank_cccccc.html";
	parent.frames["body"].document.location = "category_details_work_finish.asp";
</script>
<%
else
%>
Errors Occurred.  Please Try Again. Or...<br>
<a href="javascript:self.close();">Click to close</a>
<%
end if

Session.Value("CONTENTCATEGORY_SAVE_SUCCESS") = ""
%>
