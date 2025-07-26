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
Security.Initialize Session.Value("UserID"), "ADMIN.SPEDY", checkQueryID(Request("id"), 0)
Set ActivityLog				= New cls_ActivityLog
Set ActivityType			= New cls_ActivityType
Set ActivityReferenceType	= New cls_ActivityReferenceType

ActivityLog.Reference_Type = ActivityReferenceType.SPEDY_Workflow
			
Dim objConn, objRec, SQLStr, connStr, i
Dim itemID, boolIsNew
Dim Exception_Name, Dept_Num, Class_Num, Sub_Class_Num, From_Stage_ID, Workflow_Direction, To_Stage_ID, isEnabled

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr

itemID = checkQueryID(Request("id"), 0)

boolIsNew = CBool(Request.Form("boolIsNew"))

if boolIsNew and itemID = 0 then
	boolIsNew = true
else
	boolIsNew = false
end if

Exception_Name = Trim(Request.Form("Exception_Name"))
Dept_Num = checkQueryID(Trim(Request.Form("Dept_Value")), 0)
Class_Num = checkQueryID(Trim(Request.Form("Class_Value")), 0)
Sub_Class_Num = checkQueryID(Trim(Request.Form("Sub_Class_Value")), 0)
From_Stage_ID = checkQueryID(Trim(Request.Form("From_Stage_ID")), 0)
Workflow_Direction = checkQueryID(Trim(Request.Form("Workflow_Direction")), 0)
To_Stage_ID = checkQueryID(Trim(Request.Form("To_Stage_ID")), 0)

objConn.BeginTrans

if boolIsNew then
	objRec.Open "SPD_Workflow_Exception", objConn, adOpenKeyset, adLockOptimistic, adCmdTable
	objRec.AddNew

	objRec("Exception_Name") = Exception_Name
	if Dept_Num > 0 then objRec("Dept") = Dept_Num else objRec("Dept") = Null
	if Class_Num > 0 then objRec("Class") = Class_Num else objRec("Class") = Null
	if Sub_Class_Num > 0 then objRec("Sub_Class") = Sub_Class_Num else objRec("Sub_Class") = Null
	if From_Stage_ID > 0 then objRec("From_Stage_ID") = From_Stage_ID else objRec("From_Stage_ID") = Null
	if Workflow_Direction > 0 then objRec("Workflow_Direction") = True else objRec("Workflow_Direction") = False
	if To_Stage_ID > 0 then objRec("To_Stage_ID") = To_Stage_ID else objRec("To_Stage_ID") = Null
	objRec("Enabled") = True
	objRec("SortOrder") = "ALPHA"

	objRec.Update
	objRec.Close

	SQLStr = "SELECT @@IDENTITY FROM SPD_Workflow_Exception"
	Set objRec = objConn.Execute(SQLStr)
	itemID = objRec(0)
	objRec.Close

else
	SQLStr = "SELECT * FROM SPD_Workflow_Exception WHERE [ID] = " & itemID
	objRec.Open SQLStr, objConn, adOpenKeyset, adLockBatchOptimistic, adCmdText
	if not objRec.EOF then

		objRec("Exception_Name") = Exception_Name
		if Dept_Num > 0 then objRec("Dept") = Dept_Num else objRec("Dept") = Null
		if Class_Num > 0 then objRec("Class") = Class_Num else objRec("Class") = Null
		if Sub_Class_Num > 0 then objRec("Sub_Class") = Sub_Class_Num else objRec("Sub_Class") = Null
		if From_Stage_ID > 0 then objRec("From_Stage_ID") = From_Stage_ID else objRec("From_Stage_ID") = Null
		if Workflow_Direction > 0 then objRec("Workflow_Direction") = True else objRec("Workflow_Direction") = False
		if To_Stage_ID > 0 then objRec("To_Stage_ID") = To_Stage_ID else objRec("To_Stage_ID") = Null

		objRec("Date_Last_Modified") = CDate(Now())
		objRec.UpdateBatch
	end if
	objRec.Close
end if

'SQLStr = "sp_SPEDY_TaxWizard_Tax_UDA_ResetListValues"
'objConn.Execute(SQLStr)


if objConn.Errors.Count < 1 and Err.number < 1 then
	objConn.CommitTrans
	Session.Value("WORKFLOWEXC_SAVE_SUCCESS") = "1"
	
	ActivityLog.Reference_ID = itemID
	
	if boolIsNew then
		ActivityLog.Activity_Type = ActivityType.Create_ID
		ActivityLog.Activity_Summary = "Created New Workflow Exception " & Exception_Name
	else
		ActivityLog.Activity_Type = ActivityType.Modify_ID
		ActivityLog.Activity_Summary = "Modified Workflow Exception " & Exception_Name
	end if
	
	ActivityLog.Save
	
else
	objConn.RollbackTrans
	Session.Value("WORKFLOWEXC_SAVE_SUCCESS") = "0"
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

if CBool(Session.Value("WORKFLOWEXC_SAVE_SUCCESS")) then
%>
<script language="javascript">
	parent.frames["header"].document.location = "./../../app_include/blank_cccccc.html";
	parent.frames["controls"].document.location = "./../../app_include/blank_cccccc.html";
	parent.frames["body"].document.location = "exception_details_work_finish.asp";
</script>
<%
else
%>
Errors Occurred.  Please Try Again. Or...<br>
<a href="javascript:self.close();">Click to close</a>
<%
end if

Session.Value("WORKFLOWEXC_SAVE_SUCCESS") = ""
%>
