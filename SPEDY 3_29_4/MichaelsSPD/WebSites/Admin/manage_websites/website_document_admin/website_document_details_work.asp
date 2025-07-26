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
Dim elementID, Website_Template_ID, Element_ShortTitle, DisplayInNav, DisplayInSearchResults
Dim Element_Type, Enabled, Element_Abstract, Element_Keywords
Dim Start_Date, End_Date, Date_Created, Date_Last_Modified
Dim txtStartDate, txtStartTime, txtEndDate, txtEndTime, boolUseSchedule, boolUseStartDate, boolUseEndDate
Dim strRoles, strGroups, strPrivileges, arRoles, arGroups, arPrivileges, role, group, privilege
Dim ActivityLog, ActivityType, ActivityReferenceType, utils, rs
Dim WebsiteID, WebsiteName

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr

elementID = checkQueryID(Trim(Request.Form("tid")), 0)

Element_ShortTitle = Trim(Request.Form("Element_ShortTitle"))
Website_Template_ID = checkQueryID(Trim(Request.Form("Website_Template_ID")), 0)
DisplayInNav = CBool(checkQueryID(Trim(Request.Form("DisplayInNav")), 0))
DisplayInSearchResults = CBool(checkQueryID(Trim(Request.Form("DisplayInSearchResults")), 0))
Enabled = CBool(checkQueryID(Trim(Request.Form("Enabled")), 0))
Element_Abstract = Trim(Request.Form("Element_Abstract"))
Element_Keywords = Trim(Request.Form("Element_Keywords"))
Element_Type = Trim(Request.Form("Element_Type"))

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

if Request.Form.Count > 0 then
	'SQLStr = "SELECT * FROM Website_Element_Data WHERE [ID] = " & elementID
	
	SQLStr = "SELECT " & vbCrLf & _
			" a.Status_ID, " & vbCrLf & _
			" a.Website_ID, " & vbCrLf & _
			" c.Element_ID, " & vbCrLf & _
			" c.Parent_Element_ID, " & vbCrLf & _
			" c.[ID] As Element_Data_ID, " & vbCrLf & _
			" c.Element_FullTitle, " & vbCrLf & _
			" c.Element_ShortTitle, " & vbCrLf & _
			" c.Element_CustomHTMLTitle, " & vbCrLf & _
			" c.Element_Abstract, " & vbCrLf & _
			" c.Element_Keywords, " & vbCrLf & _
			" c.Element_Type, " & vbCrLf & _
			" c.Enabled, " & vbCrLf & _
			" c.Start_Date, " & vbCrLf & _
			" c.End_Date, " & vbCrLf & _
			" c.DisplayInNav, " & vbCrLf & _
			" c.DisplayInSearchResults, " & vbCrLf & _
			" c.Repository_Topic_Details_ID As Staging_Source_ID, " & vbCrLf & _
			" c.Date_Last_Modified " & vbCrLf & _
			" FROM Website_Element a " & vbCrLf & _
			" INNER JOIN Website_Element_Promotion b ON b.Element_ID = a.[ID] AND b.Promotion_State_ID = 1 " & vbCrLf & _
			" INNER JOIN Website_Element_Data c ON c.[ID] = b.Element_Data_ID " & vbCrLf & _
			" WHERE c.Element_ID = '0" & elementID & "'"
	
	Response.Write SQLStr
	objRec.Open SQLStr, objConn, adOpenKeyset, adLockBatchOptimistic, adCmdText

	WebsiteID = objRec("Website_ID")
	if Len(Element_ShortTitle) > 0 then objRec("Element_ShortTitle") = SmartValues(Element_ShortTitle, "CStr") else objRec("Element_ShortTitle") = Null end if
	if Len(DisplayInNav) > 0 then objRec("DisplayInNav") = SmartValues(DisplayInNav, "CStr") else objRec("DisplayInNav") = Null end if
	if Len(DisplayInSearchResults) > 0 then objRec("DisplayInSearchResults") = SmartValues(DisplayInSearchResults, "CStr") else objRec("DisplayInSearchResults") = Null end if
	if Len(Enabled) > 0 then objRec("Enabled") = SmartValues(Enabled, "CStr") else objRec("Enabled") = Null end if
	if Len(Element_Abstract) > 0 then objRec("Element_Abstract") = SmartValues(Element_Abstract, "CStr") else objRec("Element_Abstract") = Null end if
	if Len(Element_Keywords) > 0 then objRec("Element_Keywords") = SmartValues(Element_Keywords, "CStr") else objRec("Element_Keywords") = Null end if
	
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

	Set ActivityLog				= New cls_ActivityLog
	Set ActivityType			= New cls_ActivityType
	Set ActivityReferenceType	= New cls_ActivityReferenceType
	Set utils					= New cls_UtilityLibrary
	
	'Set the reference type
	ActivityLog.Reference_Type = ActivityReferenceType.Websites_Document
	
	'Get the Website Name for auditing purposes
	SQLStr = "Select Website_Name From Website Where ID = " & WebsiteID
	Set rs = utils.LoadRSFromDB(SQLStr)
	
	if Not rs.EOF then
		WebsiteName = SmartValues(rs("Website_Name"), "CStr")
	end if
	
	rs.Close
	Set rs = Nothing
	
	if Website_Template_ID <> 0 then
		SQLStr = "SELECT * FROM Website_Template_Element WHERE Website_Element_ID = '0" & elementID & "'"
		Response.Write SQLStr & "<br>" & vbCrLf
		objRec.Open SQLStr, objConn, adOpenKeyset, adLockOptimistic, adCmdText

			if objRec.EOF then
				objRec.AddNew
			end if
	
			objRec("Website_Template_ID") = Website_Template_ID
			objRec("Website_Element_ID") = elementID
	
		objRec.Update
		objRec.Close
	else
		SQLStr = "DELETE FROM Website_Template_Element WHERE Website_Element_ID = '0" & elementID & "'"
		Response.Write SQLStr & "<br>" & vbCrLf
		Set objRec = objConn.Execute(SQLStr)
	end if
end if

Dim objSecurityPrivilegeRec
Dim strCheckBoxSet, arCheckBoxSet, strCheckBoxSubset

Set objSecurityPrivilegeRec = Server.CreateObject("ADODB.RecordSet")

SQLStr = "sp_security_list_privileges_by_scopeConstant 'ADMIN.WEBSITES.WEBSITE.DOCUMENT'"
objSecurityPrivilegeRec.Open SQLStr, objConn, adOpenStatic, adLockReadOnly, adCmdText
if not objSecurityPrivilegeRec.EOF then

	Do Until objSecurityPrivilegeRec.EOF
		strCheckBoxSet = Request.Form("chk_priv_" & objSecurityPrivilegeRec("ID"))
		arCheckBoxSet = Split(strCheckBoxSet, ",")
		Response.Write "strCheckBoxSet: " & strCheckBoxSet & "<br>" & vbCrLf
		Response.Write "UBound(arCheckBoxSet): " & UBound(arCheckBoxSet) & "<br>" & vbCrLf

		SQLStr = "DELETE FROM Security_Privilege_Object WHERE " &_
				" Privilege_ID =  '" & objSecurityPrivilegeRec("ID") & "' " &_
				" AND Secured_Object_ID = '" & elementID & "' "
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
					" '" & elementID & "' As Secured_Object_ID," &_
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
					" '" & elementID & "' As Secured_Object_ID," &_
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
	Session.Value("WEDDOCSETTINGS_SAVE_SUCCESS") = "1"
	
	'Audit delete activity
	ActivityLog.Reference_ID = elementID
	ActivityLog.Activity_Type = ActivityType.Modify_ID
	ActivityLog.Activity_Summary = "Modified Document " & Element_ShortTitle
	ActivityLog.Save	
else
	objConn.RollbackTrans
	Session.Value("WEDDOCSETTINGS_SAVE_SUCCESS") = "0"
end if

Set utils					= Nothing
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

Response.Redirect "website_document_details_work_finish.asp?tid='0" & elementID & "'"
%>
