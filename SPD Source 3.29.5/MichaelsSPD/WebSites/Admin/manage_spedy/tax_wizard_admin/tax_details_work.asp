<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441
%>
<!--#include file="./../../app_include/_globalInclude.asp"-->
<%
Dim Security
Dim ActivityLog, ActivityType, ActivityReferenceType

Set Security = New cls_Security
Security.Initialize Session.Value("UserID"), "ADMIN.SPEDY", checkQueryID(Request("tid"), 0)
Set ActivityLog				= New cls_ActivityLog
Set ActivityType			= New cls_ActivityType
Set ActivityReferenceType	= New cls_ActivityReferenceType

ActivityLog.Reference_Type = ActivityReferenceType.SPEDY_Tax_UDA
			
Dim objConn, objRec, SQLStr, connStr, i
Dim taxID, boolIsNew
Dim Tax_UDA_Number, Tax_UDA_Description, isEnabled

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr

taxID = checkQueryID(Request("tid"), 0)

boolIsNew = CBool(Request.Form("boolIsNew"))

if boolIsNew and taxID = 0 then
	boolIsNew = true
else
	boolIsNew = false
end if


Tax_UDA_Number = Trim(Request.Form("Tax_UDA_Number"))
Tax_UDA_Description = Trim(Request.Form("Tax_UDA_Description"))

objConn.BeginTrans

if boolIsNew then
	objRec.Open "SPD_Tax_UDA", objConn, adOpenKeyset, adLockOptimistic, adCmdTable
	objRec.AddNew

	if Len(Tax_UDA_Number) > 0 then
		objRec("Tax_UDA_Number") = SmartValues(Tax_UDA_Number, "CStr")
	else
		objRec("Tax_UDA_Number") = ""
	end if
	if Len(Tax_UDA_Description) > 0 then
		objRec("Tax_UDA_Description") = SmartValues(Tax_UDA_Description, "CStr")
	else
		objRec("Tax_UDA_Description") = ""
	end if
	objRec("Enabled") = True
	objRec("SortOrder") = padMe(Trim(Tax_UDA_Number), 5, "0", "left")

	objRec.Update
	objRec.Close

	SQLStr = "SELECT @@IDENTITY FROM SPD_Tax_UDA"
	Set objRec = objConn.Execute(SQLStr)
	taxID = objRec(0)
	objRec.Close

else
	SQLStr = "SELECT * FROM SPD_Tax_UDA WHERE [ID] = " & taxID
	objRec.Open SQLStr, objConn, adOpenKeyset, adLockBatchOptimistic, adCmdText
	if not objRec.EOF then

		if Len(Tax_UDA_Number) > 0 then
			Tax_UDA_Number = SmartValues(Tax_UDA_Number, "CStr")
		else
			Tax_UDA_Number = ""
		end if
		objRec("Tax_UDA_Number") = Tax_UDA_Number
		
		if Len(Tax_UDA_Description) > 0 then
			Tax_UDA_Description = SmartValues(Tax_UDA_Description, "CStr")
		else
			Tax_UDA_Description = ""
		end if
		objRec("Tax_UDA_Description") = Tax_UDA_Description
		
		objRec("SortOrder") = padMe(Trim(Tax_UDA_Number), 5, "0", "left")

		objRec("Date_Last_Modified") = CDate(Now())
		objRec.UpdateBatch
	end if
	objRec.Close
end if

SQLStr = "sp_SPEDY_TaxWizard_Tax_UDA_ResetListValues"
objConn.Execute(SQLStr)


if objConn.Errors.Count < 1 and Err.number < 1 then
	objConn.CommitTrans
	Session.Value("TAXWIZARDTAX_SAVE_SUCCESS") = "1"
	
	ActivityLog.Reference_ID = taxID
	
	if boolIsNew then
		ActivityLog.Activity_Type = ActivityType.Create_ID
		ActivityLog.Activity_Summary = "Created New Tax UDA " & Tax_UDA_Number
	else
		ActivityLog.Activity_Type = ActivityType.Modify_ID
		ActivityLog.Activity_Summary = "Modified Tax UDA " & Tax_UDA_Number
	end if
	
	ActivityLog.Save
	
else
	objConn.RollbackTrans
	Session.Value("TAXWIZARDTAX_SAVE_SUCCESS") = "0"
end if

Set ActivityLog				= Nothing
Set ActivityType			= Nothing
Set ActivityReferenceType	= Nothing

Call DB_CleanUp

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

if CBool(Session.Value("TAXWIZARDTAX_SAVE_SUCCESS")) then
%>
<script language="javascript">
	parent.frames["header"].document.location = "./../../app_include/blank_cccccc.html";
	parent.frames["controls"].document.location = "./../../app_include/blank_cccccc.html";
	parent.frames["body"].document.location = "tax_details_work_finish.asp";
</script>
<%
else
%>
Errors Occurred.  Please Try Again. Or...<br>
<a href="javascript:self.close();">Click to close</a>
<%
end if

Session.Value("TAXWIZARDTAX_SAVE_SUCCESS") = ""
%>
