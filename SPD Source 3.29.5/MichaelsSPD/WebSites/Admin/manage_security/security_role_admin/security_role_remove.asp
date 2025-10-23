<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441

Dim objConn, objRec, SQLStr, connStr, i
Dim groupID

groupID = Request("gid")
if IsNumeric(groupID) then
	groupID = CInt(groupID)
else
	groupID = 0
end if

if groupID > 0 then
	Set objConn = Server.CreateObject("ADODB.Connection")
	Set objRec = Server.CreateObject("ADODB.RecordSet")

	connStr = Application.Value("connStr")
	objConn.Open connStr
	objConn.BeginTrans

	SQLStr = "DELETE FROM Security_Privilege_Object WHERE Group_ID = " & groupID
	Set objRec = objConn.Execute(SQLStr)

	SQLStr = "DELETE FROM Security_Group_Privilege WHERE Group_ID = " & groupID
	Set objRec = objConn.Execute(SQLStr)

	SQLStr = "DELETE FROM Security_User_Group WHERE Group_ID = " & groupID
 	Set objRec = objConn.Execute(SQLStr)

	SQLStr = "DELETE FROM Security_Group WHERE ID = " & groupID
	Set objRec = objConn.Execute(SQLStr)

	if objConn.Errors.Count < 1 and Err.number < 1 then
		objConn.CommitTrans
	else
		objConn.RollbackTrans
	end if

	Call DB_CleanUp
end if

Response.Redirect "./../security_role_details.asp?gid=" & Request.QueryString("gid") & "&sort=" & Request.QueryString("sort") & "&direction=" & Request.QueryString("direction")

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