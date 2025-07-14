<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
' LP MODIFIED TO DELETE WORK STAGE, Dec 2009
' the whole exception process is reworked for Michaels SPEDY2, old file names saved
'this file is used now to mark work stage as deleted
'==============================================================================
Option Explicit
%>
<!--#include file="./../../app_include/_globalInclude.asp"-->
<%
Response.Buffer = True
Response.Expires = -1441

Dim objConn, objRec, SQLStr, connStr, i
Dim itemID
Dim Tax_UDA_Number
Dim thisElementDataID, parentElementID
Dim ActivityLog, ActivityType, ActivityReferenceType, docName, utils, rs

itemID = Request("id")
if IsNumeric(itemID) then
	itemID = CInt(itemID)
else
	itemID = 0
end if

thisElementDataID = 0
parentElementID = 0

if itemID > 0 then

	docName = ""
	Set ActivityLog				= New cls_ActivityLog
	Set ActivityType			= New cls_ActivityType
	Set ActivityReferenceType	= New cls_ActivityReferenceType
	Set utils					= New cls_UtilityLibrary
	
	'Get the Element_ShortTitle for auditing purposes
	'SQLStr = "Select Top 1 Exception_Name From SPD_Workflow_Exception Where [ID] = " & itemID
	SQLStr = "Select Top 1 Stage_Name From SPD_Workflow_Stage Where [ID] = " & itemID
	Set rs = utils.LoadRSFromDB(SQLStr)
	
	if Not rs.EOF then
		docName = SmartValues(rs("Stage_Name"), "CStr")
	end if
	
	rs.Close
	Set rs = Nothing
	
	Set objConn = Server.CreateObject("ADODB.Connection")
	Set objRec = Server.CreateObject("ADODB.RecordSet")

	connStr = Application.Value("connStr")
	objConn.Open connStr
	objConn.CommandTimeout = 99999
	objConn.BeginTrans
	
	'Now, kill the tax uda
	'SQLStr = "DELETE FROM SPD_Workflow_Exception WHERE [ID] = " & itemID
	SQLStr = "update SPD_Workflow_Stage set deleted = 1 where [id] = " & itemID
	objConn.Execute(SQLStr)

	if objConn.Errors.Count < 1 and Err.number < 1 then
		objConn.CommitTrans
		
		'Audit Delete
		ActivityLog.Reference_Type = ActivityReferenceType.SPEDY_Workflow
		ActivityLog.Reference_ID = itemID
		ActivityLog.Activity_Type = ActivityType.Delete_ID
		ActivityLog.Activity_Summary = "Deleted Workflow Exception " & docName	
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

Response.Redirect "./../workflow_exception_list.asp"

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