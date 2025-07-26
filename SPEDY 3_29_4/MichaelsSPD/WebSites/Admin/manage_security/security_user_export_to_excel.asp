<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Oscar Treto, Principal - Oscar Treto Design
'==============================================================================
Option Explicit
Response.ContentType = "application/vnd.ms-excel"
Response.AddHeader "Content-Disposition", "attachment; filename=Security_Users.csv"
Response.Buffer = True
Response.Expires = -1441
%>
<!--#include file="./../app_include/_globalInclude.asp"-->
<%

Dim objExcelConn, objExcelRec, ExcelSQLStr
Dim counter, numRowsNeededToFlush
Dim column, rowStr
Dim template
	
Set objExcelConn = Server.CreateObject("ADODB.Connection")
Set objExcelRec = Server.CreateObject("ADODB.RecordSet")

counter					= 0
numRowsNeededToFlush	= 2000
ExcelSQLStr				= Session("SecurityUserExportToExcelStr")
template				= SmartValues(checkQueryID(SmartValues(Request("Template"), "CStr"), 0), "CBool")

If template Then
	ExcelSQLStr = "sp_security_list_users_search_to_Excel NULL, 1, 0"
End If

objExcelConn.Open Application.Value("connStr")
objExcelRec.Open ExcelSQLStr, objExcelConn, adOpenStatic, adLockReadOnly, adCmdText

'Display Headers
rowStr = ""
For Each column In objExcelRec.fields
	If column.name <> "totRecords" Then
		If Len(rowStr) > 0 Then
			rowStr = rowStr & ","
		End If
		rowStr = rowStr & """" & Replace(SmartValues(column.name, "CStr"), """", """""") & """"
	End If
Next
Response.Write rowStr & vbCrLf

'Display Data
Do Until objExcelRec.EOF Or template

	counter = counter + 1
	
	rowStr = ""
	For Each column In objExcelRec.fields
		If column.name <> "totRecords" Then
			If Len(rowStr) > 0 Then
				rowStr = rowStr & ","
			End If
			rowStr = rowStr & """" & Replace(SmartValues(objExcelRec(column.name), "CStr"), """", """""") & """"
		End If
	Next
	Response.Write rowStr & vbCrLf
	
	If counter = numRowsNeededToFlush Then
		Response.Flush()
		counter = 0
	End If
	objExcelRec.MoveNext
Loop
objExcelRec.Close
objExcelConn.Close

Response.Flush()

Set objExcelRec = Nothing
Set objExcelConn = Nothing
%>