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

	SQLStr = "sp_website_content_hide_document_tree '0" & topicID & "'"
	Response.Write SQLStr & "<br>"
	Set objRec = objConn.Execute(SQLStr)

	'Audit Delete
	ActivityLog.Reference_Type = ActivityReferenceType.Websites_Document
	ActivityLog.Reference_ID = topicID
	ActivityLog.Activity_Type = ActivityType.Delete_ID
	ActivityLog.Activity_Summary = "Deleted Document Tree Starting with Document " & docName	
	ActivityLog.Save
	
	Set utils					= Nothing
	Set ActivityLog				= Nothing
	Set ActivityType			= Nothing
	Set ActivityReferenceType	= Nothing
		
	Call DB_CleanUp
end if

Response.Redirect "./../website_details.asp"

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