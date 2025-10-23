<%@ LANGUAGE=VBSCRIPT%>
<%
Option Explicit
Response.Buffer = True
Response.Expires = -1441
%>
<!--#include file="./../app_include/_globalInclude.asp"-->
<%
Dim Security
Dim ActivityLog, ActivityType, ActivityReferenceType, utils

'Settings 
Dim fieldName, fieldValue, Item, settingID

'Connections
Dim conn, cmd, param, rs, SQLStr, connStr

Set conn = Server.CreateObject("ADODB.Connection")
Set cmd = Server.CreateObject("ADODB.Command")
Set rs = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
conn.Open connStr

Set cmd.ActiveConnection = conn


For Each Item In Request.Form
    fieldName = Item
    fieldValue = Request.Form(Item)

	settingID = Replace(fieldName, "txtValue_", "")
	
	'Save Settings
	If IsNumeric(settingID) Then
		Response.Write(settingID & "<br/>")
		
		SQLStr = "SPD_Settings_Update"
		cmd.CommandText = SQLStr
		cmd.CommandType = adCmdStoredProc
		
		cmd.Parameters.Append cmd.CreateParameter("@ID", adInteger, adParamInput,, settingID)
		cmd.Parameters.Append cmd.CreateParameter("@Value", adVarChar, adParamInput, 500, CStr(fieldValue))
		cmd.Execute
		
		'Reset Command Parameters
		do while cmd.Parameters.Count > 0
			cmd.Parameters.Delete(0)
		loop
		
		Response.Write fieldName & " = " & fieldValue & "<br/>"   
	End If
Next 



' ******************************************************************
' clean up
' ******************************************************************
Call DB_CleanUp

Response.Redirect "settings_list.asp"

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
%>
