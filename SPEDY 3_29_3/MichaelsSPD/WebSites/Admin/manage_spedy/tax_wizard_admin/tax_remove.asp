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
Dim Tax_UDA_Number
Dim thisElementDataID, parentElementID
Dim ActivityLog, ActivityType, ActivityReferenceType, docName, utils, rs

taxID = Request("tid")
if IsNumeric(taxID) then
	taxID = CInt(taxID)
else
	taxID = 0
end if

thisElementDataID = 0
parentElementID = 0

if taxID > 0 then

	docName = ""
	Set ActivityLog				= New cls_ActivityLog
	Set ActivityType			= New cls_ActivityType
	Set ActivityReferenceType	= New cls_ActivityReferenceType
	Set utils					= New cls_UtilityLibrary
	
	'Get the Element_ShortTitle for auditing purposes
	SQLStr = "Select Top 1 Tax_UDA_Number From SPD_Tax_UDA Where [ID] = " & taxID
	Set rs = utils.LoadRSFromDB(SQLStr)
	
	if Not rs.EOF then
		docName = SmartValues(rs("Tax_UDA_Number"), "CStr")
	end if
	
	rs.Close
	Set rs = Nothing
	
	Set objConn = Server.CreateObject("ADODB.Connection")
	Set objRec = Server.CreateObject("ADODB.RecordSet")

	connStr = Application.Value("connStr")
	objConn.Open connStr
	objConn.CommandTimeout = 99999
	objConn.BeginTrans

	SQLStr =	" SELECT a.[ID] " &_
				" FROM SPD_Tax_UDA a " &_
				" WHERE a.[ID] = " & taxID & " " &_
				" ORDER BY a.SortOrder, a.[ID] "
	Set objRec = objConn.Execute(SQLStr)
	if not objRec.EOF then
		if not IsNull(objRec(0)) then
			thisElementDataID = Trim(objRec(0))
		end if
	end if
	objRec.Close

	SQLStr = "DELETE FROM SPD_Tax_Question WHERE Tax_UDA_ID = " & taxID
	objConn.Execute(SQLStr)
	
	'Now, kill the tax uda
	SQLStr = "DELETE FROM SPD_Tax_UDA WHERE [ID] = " & taxID
	objConn.Execute(SQLStr)
	
	SQLStr = "sp_SPEDY_TaxWizard_Tax_UDA_ResetListValues"
	objConn.Execute(SQLStr)

	if objConn.Errors.Count < 1 and Err.number < 1 then
		objConn.CommitTrans
		
		'Audit Delete
		ActivityLog.Reference_Type = ActivityReferenceType.SPEDY_Tax_UDA
		ActivityLog.Reference_ID = taxID
		ActivityLog.Activity_Type = ActivityType.Delete_ID
		ActivityLog.Activity_Summary = "Deleted Tax UDA " & docName	
		ActivityLog.Save
	else
		objConn.RollbackTrans
	end if

	Set utils					= Nothing
	Set ActivityLog				= Nothing
	Set ActivityType			= Nothing
	Set ActivityReferenceType	= Nothing
	
	Call DB_CleanUp
end if

Response.Redirect "./../tax_wizard_list.asp"

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