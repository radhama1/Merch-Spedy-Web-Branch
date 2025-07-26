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
Dim Website_Keywords, Website_Abstract
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
	if Len(Website_Summary) > 0 then
		objRec("Website_Summary") = SmartValues(Website_Summary, "CStr")
	else
		objRec("Website_Summary") = Null
	end if
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
		if Len(Website_Summary) > 0 then
			objRec("Website_Summary") = SmartValues(Website_Summary, "CStr")
		else
			objRec("Website_Summary") = Null
		end if
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

SQLStr = "DELETE FROM Website_Promotion_States_Security WHERE Website_ID = " & websiteID
Set objRec = objConn.Execute(SQLStr)

SQLStr = "SELECT * FROM Website_Promotion_States_Security WHERE Website_ID = " & websiteID
objRec.Open SQLStr, objConn, adOpenKeyset, adLockBatchOptimistic, adCmdText
if objRec.EOF then

	for each role in Staging_arAllowedRoles
		objRec.AddNew
		objRec("Website_ID") = websiteID
		objRec("Promotion_State_ID") = 1
		objRec("Security_Role_ID") = role
		objRec.Update
	next
	for each group in Staging_arAllowedGroups
		objRec.AddNew
		objRec("Website_ID") = websiteID
		objRec("Promotion_State_ID") = 1
		objRec("Group_ID") = group
		objRec.Update
	next
	for each user in Staging_arAllowedUsers
		objRec.AddNew
		objRec("Website_ID") = websiteID
		objRec("Promotion_State_ID") = 1
		objRec("User_ID") = user
		objRec.Update
	next

end if
objRec.UpdateBatch
objRec.Close

SQLStr = "SELECT * FROM Website_Promotion_States_Security WHERE Website_ID = " & websiteID
objRec.Open SQLStr, objConn, adOpenKeyset, adLockBatchOptimistic, adCmdText
if objRec.EOF then

	for each role in Live_arAllowedRoles
		objRec.AddNew
		objRec("Website_ID") = websiteID
		objRec("Promotion_State_ID") = 2
		objRec("Security_Role_ID") = role
		objRec.Update
	next
	for each group in Live_arAllowedGroups
		objRec.AddNew
		objRec("Website_ID") = websiteID
		objRec("Promotion_State_ID") = 2
		objRec("Group_ID") = group
		objRec.Update
	next
	for each user in Live_arAllowedUsers
		objRec.AddNew
		objRec("Website_ID") = websiteID
		objRec("Promotion_State_ID") = 2
		objRec("User_ID") = user
		objRec.Update
	next

end if
objRec.UpdateBatch
objRec.Close

if objConn.Errors.Count < 1 and Err.number < 1 then
	objConn.CommitTrans
	Session.Value("WEBSITE_SAVE_SUCCESS") = "1"
else
	objConn.RollbackTrans
	Session.Value("WEBSITE_SAVE_SUCCESS") = "0"
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

if CBool(Session.Value("WEBSITE_SAVE_SUCCESS")) then
%>
<script language="javascript">
	//Set a reference to the Details frame in the Repository frameset...
	//var myFrameSetRef = new Object(parent.window.opener.parent.parent.frames['DetailFrameWrapper'].frames['DetailFrame']);
	var myFrameSetRef = new Object(parent.window.opener.parent.frames['TreeFrame']);
	
	//If the user hasnt left the repository framset, then refresh the details screen, otherwise dont worry bout it...
	if (typeof(myFrameSetRef == 'object'))
	{
		myFrameSetRef.document.location.reload();
	}
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
