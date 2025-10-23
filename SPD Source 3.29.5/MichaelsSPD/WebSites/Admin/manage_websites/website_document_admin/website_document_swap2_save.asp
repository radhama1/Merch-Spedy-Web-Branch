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
Server.ScriptTimeout = 99999

Dim objConn, objRec, SQLStr, connStr, i
Dim topicID, targetID, thisTopicID
Dim strCheckedItem
Dim thisElementID, thisElementType, intElementType
Dim thisElementDataID
Dim ActivityLog, ActivityType, ActivityReferenceType, curDocName, newDocName, utils, rs

thisElementType = Trim(Request("itemType"))
if thisElementType = "document" then
	intElementType = 2
else
	intElementType = 1
end if

thisElementID = Request("itemID")
if IsNumeric(thisElementID) then
	thisElementID = CInt(thisElementID)
else
	thisElementID = 0
end if

strCheckedItem = Replace(Request.Form("chkItem"), "num_", "")
strCheckedItem = Replace(strCheckedItem, "_num", "")

Response.Write "thisElementID:" & thisElementID & "<br>" & vbCrLf
Response.Write "thisElementType:" & thisElementType & "<br>" & vbCrLf
Response.Write "strCheckedItem:" & strCheckedItem & "<br>" & vbCrLf

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr
objConn.CommandTimeout = 99999

if IsNumeric(strCheckedItem) then

	Set ActivityLog				= New cls_ActivityLog
	Set ActivityType			= New cls_ActivityType
	Set ActivityReferenceType	= New cls_ActivityReferenceType
	Set utils					= New cls_UtilityLibrary
	
	'Get the Element_ShortTitle for auditing purposes
	SQLStr = "Select Top 1 Element_ShortTitle From Website_Element_Data Where Element_ID = " & thisElementID
	Set rs = utils.LoadRSFromDB(SQLStr)
	
	if Not rs.EOF then
		curDocName = SmartValues(rs("Element_ShortTitle"), "CStr")
	end if
	
	rs.Close
		
	SQLStr = "sp_websites_addnew_element_swap " & CInt(Session.Value("websiteID")) & ", " & thisElementID & ", " & strCheckedItem & ", " & intElementType
	Response.Write "SQLStr: " & SQLStr & "<br>" & vbCrLf
	Set objRec = objConn.Execute(SQLStr)
	if not objRec.EOF then
		if not IsNull(objRec(0)) then
			thisElementDataID = Trim(objRec(0))
		end if
	end if
	objRec.Close
	
	'Get the Element_ShortTitle for auditing purposes
	SQLStr = "Select Top 1 Element_ShortTitle From Website_Element_Data Where ID = " & thisElementDataID
	Set rs = utils.LoadRSFromDB(SQLStr)
	
	if Not rs.EOF then
		newDocName = SmartValues(rs("Element_ShortTitle"), "CStr")
	end if
	
	rs.Close
	Set rs = Nothing
	
	'Audit Swap
	ActivityLog.Reference_Type = ActivityReferenceType.Websites_Document
	ActivityLog.Reference_ID = thisElementDataID
	ActivityLog.Activity_Type = ActivityType.Swap_ID
	ActivityLog.Activity_Summary = "Swapped Document " & curDocName & " with Document " & newDocName	
	ActivityLog.Save
	
	Set utils					= Nothing
	Set ActivityLog				= Nothing
	Set ActivityType			= Nothing
	Set ActivityReferenceType	= Nothing
	
end if

Dim newNavString
SQLStr = "sp_websites_admin_climbladder " & thisElementID & ", " & CInt(Session.Value("websiteID")) & ", 1"
Set objRec = objConn.Execute(SQLStr)
if not objRec.EOF then
	if not IsNull(objRec(0)) then
		newNavString = Trim(objRec(0))
	end if
end if
objRec.Close

Call DB_CleanUp

Response.Redirect "./website_document_swap2_finish.asp?open=" & Server.URLEncode(newNavString)

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
