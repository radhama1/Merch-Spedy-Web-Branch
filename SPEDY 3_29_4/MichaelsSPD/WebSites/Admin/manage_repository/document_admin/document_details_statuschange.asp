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
Dim topicID, chosenStatus

topicID = Request("tid")
if not IsNumeric(topicID) then
	Response.Redirect "./../../app_include/blank_cccccc.html"
end if

chosenStatus = Request("chosenStatus")
if IsNumeric(chosenStatus) then
	chosenStatus = CInt(chosenStatus)
else
	chosenStatus = 0
end if

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr

objConn.BeginTrans

SQLStr = "UPDATE Repository_Topic SET Status_ID = " & chosenStatus & " WHERE ID = " & topicID
Set objRec = objConn.Execute(SQLStr)

if objConn.Errors.Count < 1 and Err.number < 1 then
	objConn.CommitTrans
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

Response.Redirect "./../../app_include/blank_cccccc.html"
%>