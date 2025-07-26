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
Security.Initialize Session.Value("UserID"), "ADMIN.SPEDY", checkQueryID(Request("qid"), 0)
Set ActivityLog				= New cls_ActivityLog
Set ActivityType			= New cls_ActivityType
Set ActivityReferenceType	= New cls_ActivityReferenceType

ActivityLog.Reference_Type = ActivityReferenceType.SPEDY_Tax_Question
			
Dim objConn, objRec, SQLStr, connStr, i
Dim taxID, questionID, boolIsNew, parentQuestionID
Dim Tax_Question, isEnabled

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr

taxID = checkQueryID(Request("tid"), 0)
questionID = checkQueryID(Request("qid"), 0)
parentQuestionID = checkQueryID(Request("pqid"), 0)

boolIsNew = CBool(Request.Form("boolIsNew"))

if boolIsNew and questionID = 0 then
	boolIsNew = true
else
	boolIsNew = false
end if


Tax_Question = Trim(Request.Form("Tax_Question"))

objConn.BeginTrans

if boolIsNew then
	objRec.Open "SPD_Tax_Question", objConn, adOpenKeyset, adLockOptimistic, adCmdTable
	objRec.AddNew
	
	objRec("Tax_UDA_ID") = taxID
	objRec("Parent_Tax_Question_ID") = parentQuestionID

	if Len(Tax_Question) > 0 then
		objRec("Tax_Question") = SmartValues(Tax_Question, "CStr")
	else
		objRec("Tax_Question") = ""
	end if

	objRec.Update
	objRec.Close

	SQLStr = "SELECT @@IDENTITY FROM SPD_Tax_Question"
	Set objRec = objConn.Execute(SQLStr)
	questionID = objRec(0)
	objRec.Close
	
	if boolIsNew then
		SQLStr = "sp_SPEDY_TaxWizard_Questions_ResetSort 0" & taxID & ", 0" & parentQuestionID
		objConn.Execute(SQLStr)
	end if

else
	SQLStr = "SELECT * FROM SPD_Tax_Question WHERE [ID] = " & questionID
	objRec.Open SQLStr, objConn, adOpenKeyset, adLockBatchOptimistic, adCmdText
	if not objRec.EOF then

		if Len(Tax_Question) > 0 then
			Tax_Question = SmartValues(Tax_Question, "CStr")
		else
			Tax_Question = ""
		end if
		objRec("Tax_Question") = Tax_Question

		objRec("Date_Last_Modified") = CDate(Now())
		objRec.UpdateBatch
	end if
	objRec.Close
end if

if objConn.Errors.Count < 1 and Err.number < 1 then
	objConn.CommitTrans
	Session.Value("TAXWIZARDQUESTION_SAVE_SUCCESS") = "1"
	
	ActivityLog.Reference_ID = questionID
	
	if boolIsNew then
		ActivityLog.Activity_Type = ActivityType.Create_ID
		ActivityLog.Activity_Summary = "Created New Question " & Tax_Question
	else
		ActivityLog.Activity_Type = ActivityType.Modify_ID
		ActivityLog.Activity_Summary = "Modified Question " & Tax_Question
	end if
	
	ActivityLog.Save
	
else
	objConn.RollbackTrans
	Session.Value("TAXWIZARDQUESTION_SAVE_SUCCESS") = "0"
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

if CBool(Session.Value("TAXWIZARDQUESTION_SAVE_SUCCESS")) then
%>
<script language="javascript">
	parent.frames["header"].document.location = "./../../app_include/blank_cccccc.html";
	parent.frames["controls"].document.location = "./../../app_include/blank_cccccc.html";
	parent.frames["body"].document.location = "question_details_work_finish.asp";
</script>
<%
else
%>
Errors Occurred.  Please Try Again. Or...<br>
<a href="javascript:self.close();">Click to close</a>
<%
end if

Session.Value("TAXWIZARDQUESTION_SAVE_SUCCESS") = ""
%>
