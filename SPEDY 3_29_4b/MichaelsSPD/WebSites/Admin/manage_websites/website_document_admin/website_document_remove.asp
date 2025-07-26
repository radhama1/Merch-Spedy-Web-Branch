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
Dim topicID
Dim Type1_FileID, Topic_Type
Dim thisElementDataID, parentElementID
Dim ActivityLog, ActivityType, ActivityReferenceType, docName, utils, rs

topicID = Request("tid")
if IsNumeric(topicID) then
	topicID = CInt(topicID)
else
	topicID = 0
end if

thisElementDataID = 0
parentElementID = 0

if topicID > 0 then

	docName = ""
	Set ActivityLog				= New cls_ActivityLog
	Set ActivityType			= New cls_ActivityType
	Set ActivityReferenceType	= New cls_ActivityReferenceType
	Set utils					= New cls_UtilityLibrary
	
	'Get the Element_ShortTitle for auditing purposes
	SQLStr = "Select Top 1 Element_ShortTitle From Website_Element_Data Where Element_ID = " & topicID
	Set rs = utils.LoadRSFromDB(SQLStr)
	
	if Not rs.EOF then
		docName = SmartValues(rs("Element_ShortTitle"), "CStr")
	end if
	
	rs.Close
	Set rs = Nothing
	
	Set objConn = Server.CreateObject("ADODB.Connection")
	Set objRec = Server.CreateObject("ADODB.RecordSet")

	connStr = Application.Value("connStr")
	objConn.Open connStr
	objConn.CommandTimeout = 99999
	objConn.BeginTrans

	SQLStr =	" SELECT c.[ID], c.Parent_Element_ID " &_
				" FROM Website_Element a " &_
				" INNER JOIN Website_Element_Promotion b ON b.Element_ID = a.[ID] AND b.Promotion_State_ID = 1 " &_
				" INNER JOIN Website_Element_Data c ON c.[ID] = b.Element_Data_ID " &_
				" INNER JOIN Website w ON w.[ID] = " & CInt(Session.Value("websiteID")) & " " &_
				" WHERE a.Website_ID = w.[ID] AND b.Element_ID = " & topicID & " " &_
				" ORDER BY c.SortOrder, a.Date_Created "
	Set objRec = objConn.Execute(SQLStr)
	if not objRec.EOF then
		if not IsNull(objRec(0)) then
			thisElementDataID = Trim(objRec(0))
		end if
		if not IsNull(objRec(1)) then
			parentElementID = Trim(objRec(1))
		end if
	end if
	objRec.Close

	SQLStr = "UPDATE Website_Element_Data SET Parent_Element_ID = " & parentElementID & " WHERE Parent_Element_ID = " & topicID
	Set objRec = objConn.Execute(SQLStr)
	SQLStr = "DELETE FROM Website_Files WHERE ID IN (SELECT FILE_ID FROM Website_Element_Files WHERE Element_Data_ID = " & thisElementDataID & ")"
	Set objRec = objConn.Execute(SQLStr)
	SQLStr = "DELETE FROM Website_Element_Files WHERE Element_Data_ID = " & thisElementDataID
	Set objRec = objConn.Execute(SQLStr)
	SQLStr = "DELETE FROM Website_Element_Data WHERE ID IN (SELECT Element_Data_ID FROM Website_Element_Promotion WHERE Element_ID = " & topicID & ")"
	Set objRec = objConn.Execute(SQLStr)
	SQLStr = "DELETE FROM Website_Element_Promotion WHERE Element_Data_ID = " & thisElementDataID
	Set objRec = objConn.Execute(SQLStr)

	'Now, finally, kill the document
	SQLStr = "DELETE FROM Website_Element WHERE Website_ID = " & Session.Value("websiteID") & " AND ID = " & topicID
	Set objRec = objConn.Execute(SQLStr)

	if objConn.Errors.Count < 1 and Err.number < 1 then
		objConn.CommitTrans
		
		'Audit Delete
		ActivityLog.Reference_Type = ActivityReferenceType.Websites_Document
		ActivityLog.Reference_ID = topicID
		ActivityLog.Activity_Type = ActivityType.Delete_ID
		ActivityLog.Activity_Summary = "Deleted Document " & docName	
		ActivityLog.Save
	else
		objConn.RollbackTrans
	end if

	Dim newNavString
	SQLStr = "sp_websites_admin_climbladder " & parentElementID & ", " & CInt(Session.Value("websiteID")) & ", 1"
	Set objRec = objConn.Execute(SQLStr)
	if not objRec.EOF then
		if not IsNull(objRec(0)) then
			newNavString = Trim(objRec(0))
		end if
	end if
	objRec.Close

	Set utils					= Nothing
	Set ActivityLog				= Nothing
	Set ActivityType			= Nothing
	Set ActivityReferenceType	= Nothing
	
	Call DB_CleanUp
end if

Response.Redirect "./../website_details.asp?open=" & Server.URLEncode(newNavString)

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