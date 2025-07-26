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
Dim ActivityLog, ActivityType, ActivityReferenceType, utils, rs

Set Security = New cls_Security
Security.Initialize Session.Value("UserID"), "ADMIN.SPEDY", checkQueryID(Request("fid"), 0)
Set ActivityLog				= New cls_ActivityLog
Set ActivityType			= New cls_ActivityType
Set ActivityReferenceType	= New cls_ActivityReferenceType
Set utils					= New cls_UtilityLibrary

ActivityLog.Reference_Type = ActivityReferenceType.Custom_Field

Dim thisUserID
thisUserID = SmartValues(Session.Value("UserID"), "Integer")

Dim objConn, objRec, SQLStr, connStr, i
Dim recordID, fieldID, boolIsNew
Dim Record_Type, Field_Name, Field_Type, Field_Limit, Grid, isEnabled
Dim Sort_Order, Current_Date

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr

recordID = checkQueryID(Request("tid"), 0)
fieldID = checkQueryID(Request("fid"), 0)

boolIsNew = CBool(Request.Form("boolIsNew"))

if boolIsNew and fieldID = 0 then
	boolIsNew = true
else
	boolIsNew = false
end if

Record_Type = checkQueryID(Request.Form("recordType"), 0)
Field_Name = SmartValues(Trim(Request.Form("Field_Name")), "String")
Field_Type = checkQueryID(Request.Form("Field_Type"), 9)
Field_Limit = SmartValues(Request.Form("Field_Limit"), "Integer")
if Field_Limit <= 0 then
    Field_Limit = Null
end if
if Request.Form("Grid") = "1" then
    Grid = true
else
    Grid = false
end if

' get the Sort_Order
Sort_Order = 10000
SQLStr = "sp_CustomFields_GetNextSortOrder " & Record_Type
Set rs = utils.LoadRSFromDB(SQLStr)
if Not rs.EOF then
	Sort_Order = checkQueryID(rs("Next_Sort_Order"), 1)
end if
rs.Close
Set rs = Nothing

objConn.BeginTrans

Current_Date = CDate(Now())

if boolIsNew then
    
	objRec.Open "Custom_Fields", objConn, adOpenKeyset, adLockOptimistic, adCmdTable
	objRec.AddNew
	
	objRec("Record_Type") = Record_Type
	objRec("Field_Name") = Field_Name
	objRec("Field_Type") = Field_Type
	objRec("Field_Limit") = Field_Limit
	objRec("Sort_Order") = Sort_Order
	objRec("Display") = true
	objRec("Grid") = Grid
	objRec("Last_Update_User_ID") = thisUserID
	objRec("Create_User_ID") = thisUserID
	objRec("Date_Last_Modified") = Current_Date
	objRec("Date_Created") = Current_Date

	objRec.Update
	objRec.Close

	SQLStr = "SELECT @@IDENTITY FROM Custom_Fields"
	Set objRec = objConn.Execute(SQLStr)
	fieldID = objRec(0)
	objRec.Close

else
	SQLStr = "SELECT * FROM Custom_FIelds WHERE [ID] = " & fieldID
	objRec.Open SQLStr, objConn, adOpenKeyset, adLockBatchOptimistic, adCmdText
	if not objRec.EOF then
		objRec("Record_Type") = Record_Type
	    objRec("Field_Name") = Field_Name
	    objRec("Field_Type") = Field_Type
	    objRec("Field_Limit") = Field_Limit
	    objRec("Sort_Order") = Sort_Order
	    objRec("Display") = true
	    objRec("Grid") = Grid
	    objRec("Last_Update_User_ID") = thisUserID
	    objRec("Date_Last_Modified") = Current_Date
	    
		objRec.UpdateBatch
	end if
	objRec.Close
end if

if objConn.Errors.Count < 1 and Err.number < 1 then
	objConn.CommitTrans
	Session.Value("CUSTOMFIELD_SAVE_SUCCESS") = "1"
	
	ActivityLog.Reference_ID = fieldID
	
	if boolIsNew then
		ActivityLog.Activity_Type = ActivityType.Create_ID
		ActivityLog.Activity_Summary = "Created New Field " & Field_Name
	else
		ActivityLog.Activity_Type = ActivityType.Modify_ID
		ActivityLog.Activity_Summary = "Modified Field " & Field_Name
	end if
	
	ActivityLog.Save
	
else
	objConn.RollbackTrans
	Session.Value("CUSTOMFIELD_SAVE_SUCCESS") = "0"
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

if CBool(Session.Value("CUSTOMFIELD_SAVE_SUCCESS")) then
%>
<script language="javascript">
	parent.frames["header"].document.location = "./../../app_include/blank_cccccc.html";
	parent.frames["controls"].document.location = "./../../app_include/blank_cccccc.html";
	parent.frames["body"].document.location = "field_details_work_finish.asp";
</script>
<%
else
%>
Errors Occurred.  Please Try Again. Or...<br>
<a href="javascript:self.close();">Click to close</a>
<%
end if

Session.Value("CUSTOMFIELD_SAVE_SUCCESS") = ""
Response.Write "TEST": Response.End
%>
