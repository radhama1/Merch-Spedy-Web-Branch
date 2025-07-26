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
Dim taxID
Dim questionID
Dim Tax_Question
Dim thisElementDataID, parentElementID
Dim ActivityLog, ActivityType, ActivityReferenceType, docName, utils, rs

taxID = Request("tid")
if IsNumeric(taxID) then
	taxID = CInt(taxID)
else
	taxID = 0
end if

questionID = Request("qid")
if IsNumeric(questionID) then
	questionID = CInt(questionID)
else
	questionID = 0
end if

thisElementDataID = 0
parentElementID = 0

if questionID > 0 then

	docName = ""
	Set ActivityLog				= New cls_ActivityLog
	Set ActivityType			= New cls_ActivityType
	Set ActivityReferenceType	= New cls_ActivityReferenceType
	Set utils					= New cls_UtilityLibrary
	
	'Get the Element_ShortTitle for auditing purposes
	SQLStr = "Select Top 1 Tax_Question From SPD_Tax_Question Where [ID] = " & questionID
	Set rs = utils.LoadRSFromDB(SQLStr)
	
	if Not rs.EOF then
		docName = SmartValues(rs("Tax_Question"), "CStr")
	end if
	
	rs.Close
	Set rs = Nothing
	
	Set objConn = Server.CreateObject("ADODB.Connection")
	Set objRec = Server.CreateObject("ADODB.RecordSet")

	connStr = Application.Value("connStr")
	objConn.Open connStr
	objConn.CommandTimeout = 99999
	objConn.BeginTrans

	SQLStr =	" SELECT a.[ID], a.Parent_Tax_Question_ID " &_
				" FROM SPD_Tax_Question a " &_
				" WHERE a.Tax_UDA_ID = " & taxID & " AND a.[ID] = " & questionID & " " &_
				" ORDER BY a.SortOrder, a.[ID] "
	Set objRec = objConn.Execute(SQLStr)
	if not objRec.EOF then
		if not IsNull(objRec(0)) then
			thisElementDataID = Trim(objRec(0))
		end if
		if not IsNull(objRec(1)) then
			parentElementID = Trim(objRec(1))
		end if
	end if
	objRec.Close
	
	SQLStr = "sp_SPEDY_TaxWizard_Questions_ResetSort '0" & Session.Value("taxID") & "', '0" & parentElementID & "'"
	objConn.Execute(SQLStr)

	SQLStr = "UPDATE SPD_Tax_Question SET Parent_Tax_Question_ID = " & parentElementID & " WHERE Parent_Tax_Question_ID = " & questionID
	Set objRec = objConn.Execute(SQLStr)

	'Now, finally, kill the document
	SQLStr = "DELETE FROM SPD_Tax_Question WHERE Tax_UDA_ID = " & Session.Value("taxID") & " AND [ID] = " & questionID
	Set objRec = objConn.Execute(SQLStr)

	if objConn.Errors.Count < 1 and Err.number < 1 then
		objConn.CommitTrans
		
		'Audit Delete
		ActivityLog.Reference_Type = ActivityReferenceType.SPEDY_Tax_Question
		ActivityLog.Reference_ID = questionID
		ActivityLog.Activity_Type = ActivityType.Delete_ID
		ActivityLog.Activity_Summary = "Deleted Question " & docName	
		ActivityLog.Save
	else
		objConn.RollbackTrans
	end if

	Dim newNavString
	SQLStr = "sp_SPEDY_TaxWizard_Questions_ClimbLadder " & parentElementID & ", " & CInt(Session.Value("taxID")) & ""
	Set objRec = objConn.Execute(SQLStr)
	if not objRec.EOF then
		if not IsNull(objRec(0)) then
			newNavString = Trim(objRec(0))
		end if
	end if
	objRec.Close

	Set utils					= Nothing
	Set ActivityLog				= Nothing
	Set ActivityType			= Nothing
	Set ActivityReferenceType	= Nothing
	
	Call DB_CleanUp
end if

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