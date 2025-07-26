<%@ LANGUAGE=VBSCRIPT%> 
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441
%>
<!--#include file="./../app_include/_globalInclude.asp"-->
<%

Dim objConn, objRec, SQLStr, connStr, i
Dim topicID
Dim boolAction
Dim ActivityLog, ActivityType, ActivityReferenceType, utils, rs
Dim topicName

topicID = Request("tid")
if not IsNumeric(topicID) then
	Response.Redirect Trim(Request.ServerVariables("HTTP_REFERER"))
end if

boolAction = Request("lock")
if IsNumeric(boolAction) then
	boolAction = CBool(boolAction)
else
	boolAction = false
end if

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr

objConn.BeginTrans

SQLStr = "sp_toggle_topic_lock " & topicID & ", " & CLng(Session.Value("UserID")) & ", " & CInt(boolAction)
'Response.Write SQLStr
Set objRec = objConn.Execute(SQLStr)

if objConn.Errors.Count < 1 and Err.number < 1 then
	objConn.CommitTrans
	
	Set ActivityLog				= New cls_ActivityLog
	Set ActivityType			= New cls_ActivityType
	Set ActivityReferenceType	= New cls_ActivityReferenceType
	Set utils					= New cls_UtilityLibrary
	
	'Get the topic Name for auditing purposes
	SQLStr = "Select Top 1 Topic_Name From Repository_Topic_Details Where Topic_ID = " & topicID
	Set rs = utils.LoadRSFromDB(SQLStr)
	
	if Not rs.EOF then
		topicName = SmartValues(rs("Topic_Name"), "CStr")
	end if
	
	rs.Close
	Set rs = Nothing
	
	'Audit Copy activity
	ActivityLog.Reference_ID = topicID
	if boolAction then
		ActivityLog.Activity_Summary = "Modified Document " & topicName & " - Locked"
	else
		ActivityLog.Activity_Summary = "Modified Document " & topicName & " - Unlocked"
	end if
	ActivityLog.Reference_Type = ActivityReferenceType.Content_Document
	ActivityLog.Activity_Type = ActivityType.Modify_ID
	ActivityLog.Save
	
	Set utils					= Nothing
	Set ActivityLog				= Nothing
	Set ActivityType			= Nothing
	Set ActivityReferenceType	= Nothing
else
	objConn.RollbackTrans
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

Response.Redirect Trim(Request.ServerVariables("HTTP_REFERER"))
%>