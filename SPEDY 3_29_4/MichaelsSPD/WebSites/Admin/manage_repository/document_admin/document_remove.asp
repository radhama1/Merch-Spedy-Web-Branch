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
Dim ActivityLog, ActivityType, ActivityReferenceType, docName, utils, rs

topicID = Request("tid")
if IsNumeric(topicID) then
	topicID = CInt(topicID)
else
	topicID = 0
end if

if topicID > 0 then

	docName = ""
	Set ActivityLog				= New cls_ActivityLog
	Set ActivityType			= New cls_ActivityType
	Set ActivityReferenceType	= New cls_ActivityReferenceType
	Set utils					= New cls_UtilityLibrary
	
	'Set the reference type
	ActivityLog.Reference_Type = ActivityReferenceType.Content_Document
	
	'Get the Category Name for auditing purposes
	SQLStr = "Select Topic_Name From Repository_Topic_Details Where Topic_ID = " & topicID
	Set rs = utils.LoadRSFromDB(SQLStr)
	
	if Not rs.EOF then
		docName = SmartValues(rs("Topic_Name"), "CStr")
	end if
	
	rs.Close
	Set rs = Nothing
	
	Set objConn = Server.CreateObject("ADODB.Connection")
	Set objRec = Server.CreateObject("ADODB.RecordSet")

	connStr = Application.Value("connStr")
	objConn.Open connStr
	objConn.BeginTrans

	'Find out what kind of file this is, and whether or not we need to then go and delete a corresponding BLOB document as well
	SQLStr = "SELECT Topic_Type, Type1_FileID FROM Repository_Topic_Details WHERE Topic_ID = " & topicID
	Set objRec = objConn.Execute(SQLStr)
		Topic_Type = objRec(0)
		Type1_FileID = objRec(1)
	objRec.Close
	
	'Delete the referenced BLOB document... if necessary.
	if Topic_Type = 1 then
		SQLStr = "DELETE FROM Repository_Topic_Files WHERE ID = " & Type1_FileID
		Set objRec = objConn.Execute(SQLStr)
	end if

	'Now, finally, kill the document
	SQLStr = "DELETE FROM Repository_Topic WHERE ID = " & topicID
	Set objRec = objConn.Execute(SQLStr)
	SQLStr = "DELETE FROM Repository_Topic_Details WHERE Topic_ID = " & topicID
	Set objRec = objConn.Execute(SQLStr)

	'And remove any reference to it having lived under any categories.
	SQLStr = "DELETE FROM Repository_Category_Topic WHERE Topic_ID = " & topicID
	Set objRec = objConn.Execute(SQLStr)

	if objConn.Errors.Count < 1 and Err.number < 1 then
		objConn.CommitTrans
		Session.Value("CONTENT_REMOVE_SUCCESS") = "1"
		
		'Audit delete activity
		ActivityLog.Reference_ID = topicID
		ActivityLog.Activity_Type = ActivityType.Delete_ID
		ActivityLog.Activity_Summary = "Deleted Document " & docName	
		ActivityLog.Save
	else
		objConn.RollbackTrans
		Session.Value("CONTENT_REMOVE_SUCCESS") = "0"
	end if

	Set utils					= Nothing
	Set ActivityLog				= Nothing
	Set ActivityType			= Nothing
	Set ActivityReferenceType	= Nothing
	
	Call DB_CleanUp
end if

Response.Redirect "./../repository_details.asp?cid=" & Request.QueryString("cid") & "&sort=" & Request.QueryString("sort") & "&direction=" & Request.QueryString("direction")

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