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
Dim parentQuestionID

parentQuestionID = Request("pqid")
if IsNumeric(parentQuestionID) then
	parentQuestionID = CInt(parentQuestionID)
else
	parentQuestionID = 0
end if

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr

SQLStr = "sp_SPEDY_TaxWizard_Questions_AlphaSort_by_ParentID '0" & Session.Value("taxID") & "', '0" & parentQuestionID & "'"
'Response.Write "SQLStr = " & SQLStr & "<br>"
Set objRec = objConn.Execute(SQLStr)

Dim newNavString
SQLStr = "sp_SPEDY_TaxWizard_Questions_ClimbLadder " & parentQuestionID & ", " & CInt(Session.Value("taxID")) & ""
Set objRec = objConn.Execute(SQLStr)
if not objRec.EOF then
	if not IsNull(objRec(0)) then
		newNavString = Trim(objRec(0))
	end if
end if
objRec.Close

Call DB_CleanUp

Response.Redirect "./../tax_wizard_questions.asp?open=" & Server.URLEncode(newNavString)

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