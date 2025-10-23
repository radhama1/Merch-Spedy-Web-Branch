<%@ LANGUAGE=VBSCRIPT%>
<%
Option Explicit
Response.Buffer = True
Response.Expires = -1441
%>
<!--#include file="./../app_include/_globalInclude.asp"-->
<%
Dim objConn, objRec, SQLStr, connStr, i

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")
connStr = Application.Value("connStr")
objConn.Open connStr

if Request.Form.Count > 0 then
	Persist_EnabledColumns
	Persist_ColumnSettings
end if

Sub Persist_EnabledColumns()
	Dim m_EnabledCols
	
	m_EnabledCols = Trim(Request.Form("chkEnabledCols"))
	if Len(Trim(Request.Form("chkEnabledCols"))) > 0 then m_EnabledCols = "," & m_EnabledCols

	SQLStr = "UPDATE Phonak_TacticalGrid_ColumnDisplayName  "
	SQLStr = SQLStr & " SET Display = 0 "
	Set objRec = objConn.Execute(SQLStr)

	if Len(Trim(Request.Form("chkEnabledCols"))) > 0 then
		SQLStr = "UPDATE Phonak_TacticalGrid_ColumnDisplayName  "
		SQLStr = SQLStr & " SET Display = 1, Date_Last_Modified = '" & CDate(Now) & "' WHERE ID IN (0" & m_EnabledCols & ") "
		'Response.Write SQLStr & "<p>"
		Set objRec = objConn.Execute(SQLStr)
	end if
End Sub
			
Sub Persist_ColumnSettings()

	for i = 0 to 100

		if Len(Trim(Request.Form("txtDisplayName_" & i))) > 0 then
			SQLStr = "UPDATE Phonak_TacticalGrid_ColumnDisplayName  "
			SQLStr = SQLStr & " SET Display_Name = '" & Replace(Trim(Request.Form("txtDisplayName_" & i)), "'", "''") & "', Date_Last_Modified = '" & CDate(Now) & "' WHERE ID = '0" & i & "' "
			'Response.Write SQLStr & "<p>"
			Set objRec = objConn.Execute(SQLStr)
		end if

		if Len(Trim(Request.Form("Select_Default_UserDisplay_" & i))) > 0 then
			SQLStr = "UPDATE Phonak_TacticalGrid_ColumnDisplayName  "
			SQLStr = SQLStr & " SET Default_UserDisplay = '0" & Request.Form("Select_Default_UserDisplay_" & i) & "', Date_Last_Modified = '" & CDate(Now) & "' WHERE ID = '0" & i & "' "
			'Response.Write SQLStr & "<p>"
			Set objRec = objConn.Execute(SQLStr)
		end if

		if Len(Trim(Request.Form("Select_Allow_UserDisable_" & i))) > 0 then
			SQLStr = "UPDATE Phonak_TacticalGrid_ColumnDisplayName  "
			SQLStr = SQLStr & " SET Allow_UserDisable = '0" & Request.Form("Select_Allow_UserDisable_" & i) & "', Date_Last_Modified = '" & CDate(Now) & "' WHERE ID = '0" & i & "' "
			'Response.Write SQLStr & "<p>"
			Set objRec = objConn.Execute(SQLStr)
		end if
	next

End Sub
			
Call DB_CleanUp

Response.Redirect "./tacticalgrid_columns.asp"

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