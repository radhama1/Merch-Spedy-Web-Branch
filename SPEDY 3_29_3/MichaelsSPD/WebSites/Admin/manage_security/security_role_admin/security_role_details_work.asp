<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441
%>
<!--#include file="../../app_include/smartValues.asp"-->
<%
Dim objConn, objRec, SQLStr, connStr, i
Dim Group_Name, Group_Summary
Dim Start_Date, End_Date, Date_Created, Date_Last_Modified
Dim txtStartDate, txtStartTime, txtEndDate, txtEndTime, boolUseSchedule, boolUseStartDate, boolUseEndDate
Dim groupID, boolIsNew
Dim strRoles, strGroups, strPrivileges, arRoles, arGroups, arPrivileges, role, group, privilege
Dim strUsers, arUsers, userid

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr

groupID = Trim(Request.Form("gid"))
if IsNumeric(groupID) then
	groupID = CInt(groupID)
else
	groupID = 0
end if

boolIsNew = CBool(Request.Form("boolIsNew"))

if boolIsNew and groupID = 0 then
	boolIsNew = true
else
	boolIsNew = false
end if

Group_Name = Trim(Request.Form("Group_Name"))
Group_Summary = Trim(Request.Form("Group_Summary"))

txtStartDate = Trim(Request.Form("txtStartDate"))
txtStartTime = Trim(Request.Form("txtStartTime"))
txtEndDate = Trim(Request.Form("txtEndDate"))
txtEndTime = Trim(Request.Form("txtEndTime"))

boolUseSchedule = CBool(Request.Form("boolUseSchedule"))
boolUseStartDate = CBool(Request.Form("boolUseStartDate"))
boolUseEndDate = CBool(Request.Form("boolUseEndDate"))

strRoles = Trim(Request.Form("strRoles"))
strGroups = Trim(Request.Form("strGroups"))
strPrivileges = Trim(Request.Form("strPrivileges"))
strUsers = Trim(Request.Form("chkSelectedUsers"))
arRoles = Split(strRoles, ",")
arGroups = Split(strGroups, ",")
arPrivileges = Split(strPrivileges, ",")
arUsers = Split(strUsers, ",")

objConn.BeginTrans

if boolIsNew then
	objRec.Open "Security_Group", objConn, adOpenKeyset, adLockBatchOptimistic, adCmdTable
	objRec.AddNew
else
	SQLStr = "SELECT * FROM Security_Group WHERE [ID] = " & groupID
	objRec.Open SQLStr, objConn, adOpenKeyset, adLockBatchOptimistic, adCmdText
end if

if (not boolIsNew and not objRec.EOF) or boolIsNew then

	if Len(Group_Name) > 0 then objRec("Group_Name") = SmartValues(Group_Name, "CStr") else objRec("Group_Name") = Null end if
	if Len(Group_Summary) > 0 then objRec("Group_Summary") = Left(SmartValues(Group_Summary, "CStr"), 1000) else objRec("Group_Summary") = Null end if
	objRec("Is_Role") = 1
	
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

	if not boolIsNew then
		objRec("Date_Last_Modified") = CDate(Now())
	end if
	
	objRec.UpdateBatch
end if
objRec.Close

if boolIsNew then
	SQLStr = "SELECT @@IDENTITY FROM Security_Group"
	Set objRec = objConn.Execute(SQLStr)
	groupID = objRec(0)
	objRec.Close
end if

SQLStr = "DELETE FROM Security_Group_Privilege WHERE Group_ID = " & groupID
Set objRec = objConn.Execute(SQLStr)

SQLStr = "SELECT * FROM Security_Group_Privilege WHERE Group_ID = " & groupID
objRec.Open SQLStr, objConn, adOpenKeyset, adLockBatchOptimistic, adCmdText
if objRec.EOF then

	for each privilege in arPrivileges
		objRec.AddNew
		objRec("Group_ID") = groupID
		objRec("Privilege_ID") = privilege
		objRec.Update
	next

end if
objRec.UpdateBatch
objRec.Close

SQLStr = "DELETE FROM Security_User_Group WHERE Group_ID = " & groupID
Set objRec = objConn.Execute(SQLStr)

SQLStr = "SELECT * FROM Security_User_Group WHERE Group_ID = " & groupID
'Response.Write SQLStr & "<br>"
objRec.Open SQLStr, objConn, adOpenKeyset, adLockBatchOptimistic, adCmdText
if objRec.EOF then

	for each userid in arUsers
		objRec.AddNew
		objRec("Group_ID") = groupID
		objRec("User_ID") = userid
		objRec.Update
	next

end if
objRec.UpdateBatch
objRec.Close

if objConn.Errors.Count < 1 and Err.number < 1 then
	objConn.CommitTrans
	Session.Value("SECURITYGROUP_SAVE_SUCCESS") = "1"
else
	objConn.RollbackTrans
	Session.Value("SECURITYGROUP_SAVE_SUCCESS") = "0"
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

if CBool(Session.Value("SECURITYGROUP_SAVE_SUCCESS")) then
%>
<script language="javascript">
	parent.frames["header"].document.location = "./../../app_include/blank_cccccc.html";
	parent.frames["controls"].document.location = "./../../app_include/blank_cccccc.html";
	parent.frames["body"].document.location = "security_role_details_work_finish.asp?gid=<%=groupID%>";
</script>
<%
else
%>
Errors Occurred.  Please Try Again. Or...<br>
<a href="javascript:self.close();">Click to close</a>
<%
end if

Session.Value("SECURITYGROUP_SAVE_SUCCESS") = ""
%>
