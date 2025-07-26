<%@ LANGUAGE=VBSCRIPT%>
<%
Option Explicit
Response.Buffer = True
Response.Expires = -1441
%>
<!--#include file="./../../app_include/_globalInclude.asp"-->
<%
Dim Security
Set Security = New cls_Security
Security.Initialize Session.Value("UserID"), "ADMIN.SPEDY", checkQueryID(Request("dept"), 0)

Dim objConn, objRec, SQLStr, connStr

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")
connStr = Application.Value("connStr")
objConn.Open connStr

Dim Dept_Num, strReturn
Dept_Num = checkQueryID(Request("dept"), 0)
strReturn = ""
SQLStr = "select [CLASS], (convert(varchar(20), convert(int, [CLASS])) + isnull(' - ' + [CLASS_NAME], '')) as CLASS_DISPLAY from SPD_Fineline_Class " & _
	"where [DEPT] = " & Dept_Num
objRec.Open SQLStr, objConn, adOpenKeyset, adLockBatchOptimistic, adCmdText
do while Not objRec.EOF
	if strReturn <> "" then strReturn = strReturn & ","
	strReturn = strReturn & SmartValues(objRec("CLASS"), "Integer") & "," & Replace(SmartValues(objRec("CLASS_DISPLAY"), "String"), ",", "{{COMMA}}")
	objRec.MoveNext
loop
objRec.Close


Call DB_CleanUp

Response.Clear
Response.Write strReturn
Response.End

Sub DB_CleanUp
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