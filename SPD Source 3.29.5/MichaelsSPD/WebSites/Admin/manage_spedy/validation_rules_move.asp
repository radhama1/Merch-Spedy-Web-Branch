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
Dim Security
Dim utils

Set Security = New cls_Security
Security.Initialize Session.Value("UserID"), "ADMIN.SPEDY", checkQueryID(Request("rid"), 0)

Dim thisUserID
thisUserID = SmartValues(Session.Value("UserID"), "Integer")

Dim conn, cmd, param, rs, SQLStr, connStr, i, j, n, x, y
Dim recordID, ruleID, boolIsNew, ruleXML, xmlDoc

Set conn = Server.CreateObject("ADODB.Connection")
Set cmd = Server.CreateObject("ADODB.Command")
Set rs = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
conn.Open connStr

Set cmd.ActiveConnection = conn

recordID = checkQueryID(Request("tid"), 0)
ruleID = checkQueryID(Request("rid"), 0)

' ******************************************************************
' Save Validation_Rules record
' ******************************************************************
SQLStr = "usp_Validation_MoveRule"
cmd.CommandText = SQLStr
cmd.CommandType = adCmdStoredProc
cmd.Parameters.Append cmd.CreateParameter("@ID", adInteger, adParamInput,, ruleID)
cmd.Parameters.Append cmd.CreateParameter("@Validation_Document_ID", adInteger, adParamInput,, recordID)
cmd.Parameters.Append cmd.CreateParameter("@Move_Direction", adVarChar, adParamInput, 10, Request("d"))
cmd.Parameters.Append cmd.CreateParameter("@userID", adInteger, adParamInput,, thisUserID)
cmd.Execute

' ******************************************************************
' clean up
' ******************************************************************
Call DB_CleanUp

Sub DB_CleanUp
	'---- ObjectStateEnum Values ----
'	Const adStateClosed = &H00000000
'	Const adStateOpen = &H00000001
'	Const adStateConnecting = &H00000002
'	Const adStateExecuting = &H00000004
'	Const adStateFetching = &H00000008

	if rs.State <> adStateClosed then
		On Error Resume Next
		rs.Close
	end if
	if conn.State <> adStateClosed then
		On Error Resume Next
		conn.Close
	end if
	Set rs = Nothing
	Set conn = Nothing
End Sub

Response.Redirect "validation_rules_detail.asp?tid=" & recordID & "&rid=" & ruleID
%>