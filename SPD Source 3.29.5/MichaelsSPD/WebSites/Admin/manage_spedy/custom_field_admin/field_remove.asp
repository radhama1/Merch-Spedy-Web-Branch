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
Dim fieldID
Dim Field_Name
Dim ActivityLog, ActivityType, ActivityReferenceType, fieldName, utils, rs

recordID = Request("tid")
if IsNumeric(recordID) then
	recordID = CInt(recordID)
else
	recordID = 0
end if

fieldID = Request("fid")
if IsNumeric(fieldID) then
	fieldID = CInt(fieldID)
else
	fieldID = 0
end if

if fieldID > 0 then

	fieldName = ""
	Set ActivityLog				= New cls_ActivityLog
	Set ActivityType			= New cls_ActivityType
	Set ActivityReferenceType	= New cls_ActivityReferenceType
	Set utils					= New cls_UtilityLibrary

	'Get the Element_ShortTitle for auditing purposes
	SQLStr = "Select Top 1 Field_Name From Custom_Fields Where [ID] = " & fieldID
	Set rs = utils.LoadRSFromDB(SQLStr)
	
	if Not rs.EOF then
		fieldName = SmartValues(rs("Field_Name"), "CStr")
	end if
	
	rs.Close
	Set rs = Nothing
	
	' get the record type
	Dim recordType
	recordType = recordID
	SQLStr = "select top 1 Record_Type_ID from Custom_Field_Record_Types where [ID] = " & recordID
	Set rs = utils.LoadRSFromDB(SQLStr)
	if Not rs.EOF then
		recordType = SmartValues(rs("Record_Type_ID"), "CInt")
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
	SQLStr = "sp_CustomFields_DeleteField '0" & recordType & "', '0" & fieldID & "'"
	'Set objRec = objConn.Execute(SQLStr)
	
	objConn.Execute(SQLStr)

	if objConn.Errors.Count < 1 and Err.number < 1 then
		objConn.CommitTrans
		
		'Audit Delete
		ActivityLog.Reference_Type = ActivityReferenceType.Custom_Field
		ActivityLog.Reference_ID = fieldID
		ActivityLog.Activity_Type = ActivityType.Delete_ID
		ActivityLog.Activity_Summary = "Deleted Field " & fieldName	
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

Response.Redirect "./../custom_fields_detail.asp?tid=" & recordID

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