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
Dim UserName, Password, ID, Email_Address, Enabled, Last_Name, First_Name, Middle_Name, Title, Suffix, Gender
Dim Language_ID, Comments, Organization, Department, Job_Title, Office_Location, Primary_Approver
Dim Start_Date, End_Date, Date_Created, Date_Last_Modified
Dim txtStartDate, txtStartTime, txtEndDate, txtEndTime, boolUseSchedule, boolUseStartDate, boolUseEndDate
Dim contactID, boolIsNewContact
Dim strRoles, strGroups, strPrivileges, arRoles, arGroups, arPrivileges, role, group, privilege

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr

contactID = Trim(Request.Form("cid"))
if IsNumeric(contactID) then
	contactID = cLng(contactID)
else
	contactID = 0
end if

boolIsNewContact = CBool(Request.Form("boolIsNewContact"))

if boolIsNewContact and contactID = 0 then
	boolIsNewContact = true
else
	boolIsNewContact = false
end if

UserName = Trim(Request.Form("UserName"))
Password = Trim(Request.Form("Password"))
Email_Address = Trim(Request.Form("Email_Address"))
Enabled = Trim(Request.Form("Enabled"))
' Primary_Approver = Trim(Request.Form("PrimaryApprover"))
Last_Name = Trim(Request.Form("Last_Name"))
First_Name = Trim(Request.Form("First_Name"))
Middle_Name = Trim(Request.Form("Middle_Name"))
Title = Trim(Request.Form("Title"))
Suffix = Trim(Request.Form("Suffix"))
Gender = Trim(Request.Form("Gender"))
Language_ID = Trim(Request.Form("Language_ID"))
Comments = Trim(Request.Form("Comments"))
Organization = Trim(Request.Form("Organization"))
Department = Trim(Request.Form("Department"))
Job_Title = Trim(Request.Form("Job_Title"))
Office_Location = Trim(Request.Form("Office_Location"))

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
arRoles = Split(strRoles, ",")
arGroups = Split(strGroups, ",")
arPrivileges = Split(strPrivileges, ",")

objConn.BeginTrans

if boolIsNewContact then
	objRec.Open "Security_User", objConn, adOpenKeyset, adLockBatchOptimistic, adCmdTable
	objRec.AddNew
else
	SQLStr = "SELECT * FROM Security_User WHERE [ID] = " & contactID
	objRec.Open SQLStr, objConn, adOpenKeyset, adLockBatchOptimistic, adCmdText
end if

if (not boolIsNewContact and not objRec.EOF) or boolIsNewContact then

	if Len(UserName) > 0 then objRec("UserName") = SmartValues(UserName, "CStr") else objRec("UserName") = Null end if
	if Len(Password) > 0 then objRec("Password") = SmartValues(Password, "CStr") else objRec("Password") = Null end if
	if Len(Email_Address) > 0 then objRec("Email_Address") = SmartValues(Email_Address, "CStr") else objRec("Email_Address") = Null end if
	' if Len(Primary_Approver) > 0 then objRec("Primary_Approver") = 1 else objRec("Primary_Approver") = 0 end if
	if Len(Enabled) > 0 then objRec("Enabled") = 1 else objRec("Enabled") = 0 end if
	if Len(Last_Name) > 0 then objRec("Last_Name") = SmartValues(Last_Name, "CStr") else objRec("Last_Name") = Null end if
	if Len(First_Name) > 0 then objRec("First_Name") = SmartValues(First_Name, "CStr") else objRec("First_Name") = Null end if
	if Len(Middle_Name) > 0 then objRec("Middle_Name") = SmartValues(Middle_Name, "CStr") else objRec("Middle_Name") = Null end if
	if Len(Title) > 0 then objRec("Title") = SmartValues(Title, "CStr") else objRec("Title") = Null end if
	if Len(Suffix) > 0 then objRec("Suffix") = SmartValues(Suffix, "CStr") else objRec("Suffix") = Null end if
	if Len(Gender) > 0 then objRec("Gender") = SmartValues(Gender, "CStr") else objRec("Gender") = Null end if
	if Len(Language_ID) > 0 then objRec("Language_ID") = SmartValues(Language_ID, "cLng") else objRec("Language_ID") = Null end if
	if Len(Comments) > 0 then objRec("Comments") = SmartValues(Comments, "CStr") else objRec("Comments") = Null end if
	if Len(Organization) > 0 then objRec("Organization") = SmartValues(Organization, "CStr") else objRec("Organization") = Null end if
	if Len(Department) > 0 then objRec("Department") = SmartValues(Department, "CStr") else objRec("Department") = Null end if
	if Len(Job_Title) > 0 then objRec("Job_Title") = SmartValues(Job_Title, "CStr") else objRec("Job_Title") = Null end if
	if Len(Office_Location) > 0 then objRec("Office_Location") = SmartValues(Office_Location, "CStr") else objRec("Office_Location") = Null end if
	
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

	if not boolIsNewContact then
		objRec("Date_Last_Modified") = CDate(Now())
	end if
	
	objRec.UpdateBatch
end if
objRec.Close

if boolIsNewContact then
	SQLStr = "SELECT @@IDENTITY FROM Security_User"
	Set objRec = objConn.Execute(SQLStr)
	contactID = objRec(0)
	objRec.Close
end if

SQLStr = "DELETE FROM Security_User_Group WHERE User_ID = " & contactID
Set objRec = objConn.Execute(SQLStr)

SQLStr = "SELECT * FROM Security_User_Group WHERE User_ID = " & contactID
objRec.Open SQLStr, objConn, adOpenKeyset, adLockBatchOptimistic, adCmdText
if objRec.EOF then

	for each role in arRoles
		objRec.AddNew
		objRec("User_ID") = contactID
		objRec("Group_ID") = role
		objRec.Update
	next
	for each group in arGroups
		objRec.AddNew
		objRec("User_ID") = contactID
		objRec("Group_ID") = group
		objRec.Update
	next

end if
objRec.UpdateBatch
objRec.Close

SQLStr = "DELETE FROM Security_User_Privilege WHERE User_ID = " & contactID
Set objRec = objConn.Execute(SQLStr)

SQLStr = "SELECT * FROM Security_User_Privilege WHERE User_ID = " & contactID
objRec.Open SQLStr, objConn, adOpenKeyset, adLockBatchOptimistic, adCmdText
if objRec.EOF then

	for each privilege in arPrivileges
		objRec.AddNew
		objRec("User_ID") = contactID
		objRec("Privilege_ID") = privilege
		objRec.Update
	next

end if
objRec.UpdateBatch
objRec.Close

'********************************************
'SYNC DEPARTMENT
'********************************************
SQLStr = "Update Security_User Set Department = dbo.udf_SPD_Get_Departments(" & contactID & ") WHERE ID = " & contactID
Set objRec = objConn.Execute(SQLStr)

'********************************************
'END OF SYNC DEPARTMENT
'********************************************

if objConn.Errors.Count < 1 and Err.number < 1 then
	objConn.CommitTrans
	Session.Value("SECURITYUSER_SAVE_SUCCESS") = "1"
else
	objConn.RollbackTrans
	Session.Value("SECURITYUSER_SAVE_SUCCESS") = "0"
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

if CBool(Session.Value("SECURITYUSER_SAVE_SUCCESS")) then
%>
<script language="javascript">

	//Set a reference to the Details frame in the Repository frameset...
	var myFrameSetRef = new Object(parent.window.opener.parent.parent.frames['WorkspaceFrame'].frames['DetailFrame']);

	//If the user hasnt left the repository framset, then refresh the details screen, otherwise dont worry bout it...
	if (typeof(myFrameSetRef == 'object'))
	{
		myFrameSetRef.document.location.reload();
	}

	parent.window.document.location.reload();
</script>
<%
else
%>
Errors Occurred.  Please Try Again. Or...<br>
<a href="javascript:self.close();">Click to close</a>
<%
end if

Session.Value("SECURITYUSER_SAVE_SUCCESS") = ""
%>
