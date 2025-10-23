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
Dim recordID
Dim ruleID
Dim validationRule
Dim ActivityLog, ActivityType, ActivityReferenceType, utils, rs

recordID = Request("tid")
if IsNumeric(recordID) then
	recordID = CInt(recordID)
else
	recordID = 0
end if

ruleID = Request("rid")
if IsNumeric(ruleID) then
	ruleID = CInt(ruleID)
else
	ruleID = 0
end if

if ruleID > 0 then

	validationRule = ""
	Set ActivityLog				= New cls_ActivityLog
	Set ActivityType			= New cls_ActivityType
	Set ActivityReferenceType	= New cls_ActivityReferenceType
	Set utils					= New cls_UtilityLibrary

	'Get the Element_ShortTitle for auditing purposes
	SQLStr = "Select Top 1 Validation_Rule From Validation_Rules Where [ID] = " & ruleID
	Set rs = utils.LoadRSFromDB(SQLStr)
	
	if Not rs.EOF then
		validationRule = SmartValues(rs("Validation_Rule"), "CStr")
	end if
	
	rs.Close
	Set rs = Nothing
	
	Set objConn = Server.CreateObject("ADODB.Connection")
	Set objRec = Server.CreateObject("ADODB.RecordSet")

	connStr = Application.Value("connStr")
	objConn.Open connStr
	objConn.CommandTimeout = 99999
	objConn.BeginTrans

	' delete the field
	SQLStr = "usp_Validation_DeleteRule '0" & recordID & "', '0" & ruleID & "'"
	'Set objRec = objConn.Execute(SQLStr)
	
	objConn.Execute(SQLStr)

	if objConn.Errors.Count < 1 and Err.number < 1 then
		objConn.CommitTrans
		
		'Audit Delete
		ActivityLog.Reference_Type = ActivityReferenceType.Validation_Rule
		ActivityLog.Reference_ID = ruleID
		ActivityLog.Activity_Type = ActivityType.Delete_ID
		ActivityLog.Activity_Summary = "Deleted Rule " & validationRule	
		ActivityLog.Save
	else
		objConn.RollbackTrans
	end if

	Set utils					= Nothing
	Set ActivityLog				= Nothing
	Set ActivityType			= Nothing
	Set ActivityReferenceType	= Nothing
	
	Call DB_CleanUp
end if

Response.Redirect "./../validation_rules_detail.asp?tid=" & recordID

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