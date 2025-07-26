<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441

Dim objConn, objRec, SQLStr, connStr, i
Dim contactID

contactID = Request("cid")
if IsNumeric(contactID) then
	contactID = cLng(contactID)
else
	contactID = 0
end if

if contactID > 0 then
	Set objConn = Server.CreateObject("ADODB.Connection")
	Set objRec = Server.CreateObject("ADODB.RecordSet")

	connStr = Application.Value("connStr")
	objConn.Open connStr
	objConn.BeginTrans

	'SQLStr = "DELETE FROM Security_Privilege_Object WHERE User_ID = " & contactID
	'Set objRec = objConn.Execute(SQLStr)

	'SQLStr = "DELETE FROM Security_User_Privilege WHERE User_ID = " & contactID
	'Set objRec = objConn.Execute(SQLStr)

	'SQLStr = "DELETE FROM Security_User_Group WHERE User_ID = " & contactID
 	'Set objRec = objConn.Execute(SQLStr)

	'SQLStr = "DELETE FROM Security_User WHERE ID = " & contactID
	'Set objRec = objConn.Execute(SQLStr)
	
	SQLStr = "Update Security_User Set Deleted = 1, Enabled = 0 WHERE ID = " & contactID
	Set objRec = objConn.Execute(SQLStr)	

	if objConn.Errors.Count < 1 and Err.number < 1 then
		objConn.CommitTrans
	else
		objConn.RollbackTrans
	end if

	Call DB_CleanUp
end if

Response.Redirect "./../security_user_details.asp?cid=" & Request.QueryString("cid") & "&sort=" & Request.QueryString("sort") & "&direction=" & Request.QueryString("direction")

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