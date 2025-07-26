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

Dim objConn, objRec, SQLStr, connStr, i
Dim Website_Name, Website_Summary, isEnabled
Dim Website_Language_ID, Website_Keywords, Website_Abstract
Dim txtStartDate, txtStartTime, txtEndDate, txtEndTime, boolUseSchedule, boolUseStartDate, boolUseEndDate
Dim allowedRoles, allowedGroups, allowedUsers
Dim arAllowedRoles, arAllowedGroups, arAllowedUsers
Dim Staging_allowedRoles, Staging_allowedGroups, Staging_allowedUsers
Dim Staging_arAllowedRoles, Staging_arAllowedGroups, Staging_arAllowedUsers
Dim Live_allowedRoles, Live_allowedGroups, Live_allowedUsers
Dim Live_arAllowedRoles, Live_arAllowedGroups, Live_arAllowedUsers
Dim role, group, user
Dim websiteID, boolIsNewWebsite
Dim Staging_URL, Staging_Path, Live_URL, Live_Path
Dim Staging_Allow_Anon, Live_Allow_Anon
Dim ActivityLog, ActivityType, ActivityReferenceType

Set ActivityLog				= New cls_ActivityLog
Set ActivityType			= New cls_ActivityType
Set ActivityReferenceType	= New cls_ActivityReferenceType

ActivityLog.Reference_Type = ActivityReferenceType.Websites_Website

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr

websiteID = Trim(Request.Form("wid"))
if IsNumeric(websiteID) then
	websiteID = CInt(websiteID)
else
	websiteID = 0
end if

boolIsNewWebsite = CBool(Request.Form("boolIsNewWebsite"))

if boolIsNewWebsite and websiteID = 0 then
	boolIsNewWebsite = true
else
	boolIsNewWebsite = false
end if

Website_Name = Trim(Request.Form("Website_Name"))
Website_Summary = Trim(Request.Form("Website_Summary"))
Website_Language_ID = Trim(Request.Form("Website_Language_ID"))
Website_Keywords = Trim(Request.Form("Website_Keywords"))
Website_Abstract = Trim(Request.Form("Website_Abstract"))
Staging_URL = Trim(Request.Form("Staging_URL"))
Staging_Path = Trim(Request.Form("Staging_Path"))
Live_URL = Trim(Request.Form("Live_URL"))
Live_Path = Trim(Request.Form("Live_Path"))

txtStartDate = Trim(Request.Form("txtStartDate"))
txtStartTime = Trim(Request.Form("txtStartTime"))
txtEndDate = Trim(Request.Form("txtEndDate"))
txtEndTime = Trim(Request.Form("txtEndTime"))

boolUseSchedule = CBool(Request.Form("boolUseSchedule"))
boolUseStartDate = CBool(Request.Form("boolUseStartDate"))
boolUseEndDate = CBool(Request.Form("boolUseEndDate"))

'Promotion State Security Lists
Staging_Allow_Anon = CBool(Trim(Request.Form("Staging_Allow_Anon")))
Live_Allow_Anon = CBool(Trim(Request.Form("Live_Allow_Anon")))

Staging_allowedRoles = Trim(Request.Form("Staging_allowedRoles"))
Staging_allowedGroups = Trim(Request.Form("Staging_allowedGroups"))
Staging_allowedUsers = Trim(Request.Form("Staging_allowedUsers"))

Staging_arAllowedRoles = Split(Staging_allowedRoles, ",")
Staging_arAllowedGroups = Split(Staging_allowedGroups, ",")
Staging_arAllowedUsers = Split(Staging_allowedUsers, ",")

Live_allowedRoles = Trim(Request.Form("Live_allowedRoles"))
Live_allowedGroups = Trim(Request.Form("Live_allowedGroups"))
Live_allowedUsers = Trim(Request.Form("Live_allowedUsers"))

Live_arAllowedRoles = Split(Live_allowedRoles, ",")
Live_arAllowedGroups = Split(Live_allowedGroups, ",")
Live_arAllowedUsers = Split(Live_allowedUsers, ",")

'Website Editing Security
allowedRoles = Trim(Request.Form("allowedRoles"))
allowedGroups = Trim(Request.Form("allowedGroups"))
allowedUsers = Trim(Request.Form("allowedUsers"))

arAllowedRoles = Split(allowedRoles, ",")
arAllowedGroups = Split(allowedGroups, ",")
arAllowedUsers = Split(allowedUsers, ",")

objConn.BeginTrans

if boolIsNewWebsite then
	objRec.Open "Website", objConn, adOpenKeyset, adLockOptimistic, adCmdTable
	objRec.AddNew
	
	if Len(Website_Name) > 0 then
		objRec("Website_Name") = SmartValues(Website_Name, "CStr")
	else
		objRec("Website_Name") = "UNTITLED WEBSITE"
	end if
	
	Website_Name = objRec("Website_Name")
	
	if Len(Website_Summary) > 0 then
		objRec("Website_Summary") = SmartValues(Website_Summary, "CStr")
	else
		objRec("Website_Summary") = Null
	end if
	objRec("Website_Language_ID") = checkQueryID(Website_Language_ID, 0)
	if Len(Website_Keywords) > 0 then
		objRec("Website_Keywords") = SmartValues(Website_Keywords, "CStr")
	else
		objRec("Website_Keywords") = Null
	end if
	if Len(Website_Abstract) > 0 then
		objRec("Website_Abstract") = SmartValues(Website_Abstract, "CStr")
	else
		objRec("Website_Abstract") = Null
	end if

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

	objRec.Update
	objRec.Close

	SQLStr = "SELECT @@IDENTITY FROM Website"
	Set objRec = objConn.Execute(SQLStr)
	websiteID = objRec(0)
	objRec.Close

else
	SQLStr = "SELECT * FROM Website WHERE [ID] = " & websiteID
	objRec.Open SQLStr, objConn, adOpenKeyset, adLockBatchOptimistic, adCmdText
	if not objRec.EOF then

		if Len(Website_Name) > 0 then
			objRec("Website_Name") = SmartValues(Website_Name, "CStr")
		else
			objRec("Website_Name") = "UNTITLED WEBSITE"
		end if
		
		Website_Name = objRec("Website_Name")
		
		if Len(Website_Summary) > 0 then
			objRec("Website_Summary") = SmartValues(Website_Summary, "CStr")
		else
			objRec("Website_Summary") = Null
		end if
		objRec("Website_Language_ID") = checkQueryID(Website_Language_ID, 0)
		if Len(Website_Keywords) > 0 then
			objRec("Website_Keywords") = SmartValues(Website_Keywords, "CStr")
		else
			objRec("Website_Keywords") = Null
		end if
		if Len(Website_Abstract) > 0 then
			objRec("Website_Abstract") = SmartValues(Website_Abstract, "CStr")
		else
			objRec("Website_Abstract") = Null
		end if

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

SQLStr = "SELECT * FROM Website_Promotion_States_Details WHERE Promotion_State_ID = 1 AND Website_ID = " & websiteID
objRec.Open SQLStr, objConn, adOpenKeyset, adLockBatchOptimistic, adCmdText
	if objRec.EOF then
		objRec.AddNew
		objRec("Promotion_State_ID") = 1
		objRec("Website_ID") = websiteID
	else
		objRec("Date_Last_Modified") = CDate(Now)
	end if

	if Len(Staging_URL) > 0 then
		objRec("Promotion_State_URL") = SmartValues(Staging_URL, "CStr")
	else
		objRec("Promotion_State_URL") = null
	end if
	if Len(Staging_Path) > 0 then
		objRec("Promotion_State_PATH") = SmartValues(Staging_Path, "CStr")
	else
		objRec("Promotion_State_PATH") = null
	end if
	objRec("Allow_Anon_Access") = Staging_Allow_Anon

objRec.UpdateBatch
objRec.Close

SQLStr = "SELECT * FROM Website_Promotion_States_Details WHERE Promotion_State_ID = 2 AND Website_ID = " & websiteID
objRec.Open SQLStr, objConn, adOpenKeyset, adLockBatchOptimistic, adCmdText
	if objRec.EOF then
		objRec.AddNew
		objRec("Promotion_State_ID") = 2
		objRec("Website_ID") = websiteID
	else
		objRec("Date_Last_Modified") = CDate(Now)
	end if

	if Len(Live_URL) > 0 then
		objRec("Promotion_State_URL") = SmartValues(Live_URL, "CStr")
	else
		objRec("Promotion_State_URL") = null
	end if
	if Len(Live_Path) > 0 then
		objRec("Promotion_State_PATH") = SmartValues(Live_Path, "CStr")
	else
		objRec("Promotion_State_PATH") = null
	end if
	objRec("Allow_Anon_Access") = Live_Allow_Anon

objRec.UpdateBatch
objRec.Close

Dim objSecurityPrivilegeRec
Dim strCheckBoxSet, arCheckBoxSet, strCheckBoxSubset

Set objSecurityPrivilegeRec = Server.CreateObject("ADODB.RecordSet")

SQLStr = "sp_security_list_privileges_by_scopeConstant 'ADMIN.WEBSITES.WEBSITE'"
objSecurityPrivilegeRec.Open SQLStr, objConn, adOpenStatic, adLockReadOnly, adCmdText
if not objSecurityPrivilegeRec.EOF then

	Do Until objSecurityPrivilegeRec.EOF
		strCheckBoxSet = Request.Form("chk_priv_" & objSecurityPrivilegeRec("ID"))
		arCheckBoxSet = Split(strCheckBoxSet, ",")
		Response.Write "strCheckBoxSet: " & strCheckBoxSet & "<br>" & vbCrLf
		Response.Write "UBound(arCheckBoxSet): " & UBound(arCheckBoxSet) & "<br>" & vbCrLf

		SQLStr = "DELETE FROM Security_Privilege_Object WHERE " &_
				" Privilege_ID =  '" & objSecurityPrivilegeRec("ID") & "' " &_
				" AND Secured_Object_ID = '" & websiteID & "' "
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
					" '" & websiteID & "' As Secured_Object_ID," &_
					" Element As Group_ID," &_
					" 0 As User_ID " &_
					" FROM dbo.Split('" & strCheckBoxSubset & "', ',')"
			Response.Write SQLStr & "<br>" & vbCrLf
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
					" '" & websiteID & "' As Secured_Object_ID," &_
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
	Session.Value("WEBSITE_SAVE_SUCCESS") = "1"
	
	ActivityLog.Reference_ID = websiteID
	
	if boolIsNewWebsite then
		ActivityLog.Activity_Type = ActivityType.Create_ID
		ActivityLog.Activity_Summary = "Created New Website " & Website_Name
	else
		ActivityLog.Activity_Type = ActivityType.Modify_ID
		ActivityLog.Activity_Summary = "Modified Website " & Website_Name
	end if
	
	ActivityLog.Save
	
else
	objConn.RollbackTrans
	Session.Value("WEBSITE_SAVE_SUCCESS") = "0"
end if

Set ActivityLog				= Nothing
Set ActivityType			= Nothing
Set ActivityReferenceType	= Nothing

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

if CBool(Session.Value("WEBSITE_SAVE_SUCCESS")) then
%>
<script language="javascript">
	parent.frames["header"].document.location = "./../../app_include/blank_cccccc.html";
	parent.frames["controls"].document.location = "./../../app_include/blank_cccccc.html";
	parent.frames["body"].document.location = "website_details_work_finish.asp?wid=<%=websiteID%>";
</script>
<%
else
%>
Errors Occurred.  Please Try Again. Or...<br>
<a href="javascript:self.close();">Click to close</a>
<%
end if

Session.Value("WEBSITE_SAVE_SUCCESS") = ""
%>
