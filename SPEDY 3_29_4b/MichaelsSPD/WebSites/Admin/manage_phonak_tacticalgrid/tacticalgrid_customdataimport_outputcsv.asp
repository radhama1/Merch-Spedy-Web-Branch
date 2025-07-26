<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace for Nova Libra, Inc.
'==============================================================================
Option Explicit
Response.Buffer = False
Response.Expires = -1441 
Server.ScriptTimeout = 2147483000

Response.ContentType = "application/vnd.ms-excel"
Response.AddHeader "Content-Disposition", "attachment; filename=Tactical_Grid.csv"
%>
<!--#include file="./../app_include/_globalInclude.asp"-->
<%
Dim objConn, objRec
Dim SQLStr, connStr
Dim rowcolor, i
Dim numFound, startRow, pageSize, curPage, pageCount
Dim Table_ID, Column_ID
Dim Table_Name, Table_UpdateKey, Is_LookupTable
Dim Column_Name, Use_LookupTable, LookupTable_TableName, LookupTable_Key_ColumnName, LookupTable_Value_ColumnName

Dim ActivityLog, ActivityType, ActivityReferenceType
Set ActivityLog = New cls_ActivityLog
Set ActivityType = New cls_ActivityType

ActivityLog.Activity_Type = 101
ActivityLog.Activity_Summary = Trim(Session.Value("User_First_Name") & " " & Session.Value("User_Last_Name")) & " exported a csv of column to update data in the Tactical Grid."

ActivityLog.Reference_ID = 0	
ActivityLog.Save

Set ActivityLog = Nothing
Set ActivityType = Nothing

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")

objConn.Open connStr

Table_ID = Request("selTable")
Column_ID = Request("selColumn")
'Response.Write "Table_ID: " & Table_ID & "<br>"
'Response.Write "Column_ID: " & Column_ID & "<br>"

SQLStr = "SELECT * FROM Phonak_Updateable_Table WHERE ID = '0" & Table_ID & "'"
'Response.Write "SQLStr: " & SQLStr & "<br>"
objRec.Open SQLStr, objConn, adOpenDynamic, adLockOptimistic, adCmdText
if not objRec.EOF then

	Table_Name = SmartValues(objRec("Table_Name"), "CStr")
	Table_UpdateKey = SmartValues(objRec("Table_UpdateKey"), "CStr")
	Is_LookupTable = SmartValues(objRec("Is_LookupTable"), "CBool")
	
end if
objRec.Close

SQLStr = "SELECT * FROM Phonak_Updateable_Table_Column WHERE ID = '0" & Column_ID & "'"
'Response.Write "SQLStr: " & SQLStr & "<br>"
objRec.Open SQLStr, objConn, adOpenDynamic, adLockOptimistic, adCmdText
if not objRec.EOF then

	Column_Name = SmartValues(objRec("Column_Name"), "CStr")
	Use_LookupTable = SmartValues(objRec("Use_LookupTable"), "CBool")
	LookupTable_TableName = SmartValues(objRec("LookupTable_TableName"), "CStr")
	LookupTable_Key_ColumnName = SmartValues(objRec("LookupTable_Key_ColumnName"), "CStr")
	LookupTable_Value_ColumnName = SmartValues(objRec("LookupTable_Value_ColumnName"), "CStr")
	
end if
objRec.Close

if Use_LookupTable then
	SQLStr = "SELECT m.[" & Table_UpdateKey & "], x.[" & LookupTable_Value_ColumnName & "] As COLOUT FROM [" & Table_Name & "] m " &_
			" INNER JOIN [" & LookupTable_TableName & "] x ON x.[" & LookupTable_Key_ColumnName & "] = m.[" & Column_Name & "]" &_
			" ORDER BY m.[" & Table_UpdateKey & "]"
else
	SQLStr = "SELECT [" & Table_UpdateKey & "], [" & Column_Name & "] As COLOUT FROM [" & Table_Name & "] ORDER BY [" & Table_UpdateKey & "]"
end if
'Response.Write SQLStr & vbCrLf & vbCrLf
objRec.Open SQLStr, objConn, adOpenForwardOnly, adLockReadOnly, adCmdText
Response.Write """AccountNumber"",""NewData""" & vbCrLf
if not objRec.EOF then

	Do Until objRec.EOF
	
		Response.Write """" & SmartValues(objRec(Table_UpdateKey), "CStr") & """" & "," & """" & SmartValues(objRec("COLOUT"), "CStr") & """" & vbCrLf
		objRec.MoveNext
	
	Loop

end if

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