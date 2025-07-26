<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
' 
' Updated: Jeff Littlefield Save Field Locking Data
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
' Security.Initialize Session.Value("UserID"), "ADMIN.SPEDY", checkQueryID(Request("fid"), 0)
Security.Initialize Session.Value("UserID"), "ADMIN.SPEDY", checkQueryID(Request("wid"), 0)

Set ActivityLog				= New cls_ActivityLog
Set ActivityType			= New cls_ActivityType
Set ActivityReferenceType	= New cls_ActivityReferenceType
Set utils					= New cls_UtilityLibrary

' TO DO - Activity LOG Stuff
' ActivityLog.Reference_Type = ActivityReferenceType.Custom_Field

Dim thisUserID
thisUserID = SmartValues(Session.Value("UserID"), "Integer")

Dim objConn, objRec, SQLStr, connStr, i
Dim recordID, fieldID, boolIsNew
Dim Record_Type, Field_Name, Field_Type, Field_Limit, Grid, isEnabled
Dim Sort_Order, Current_Date

Dim wfID, wfsID, iNumRows, iNumCols, sRecords, r, c, sHID, sSaveOnly

' Get the data from the form
wfID = Request.Form("HwfID")
wfsID = Request.Form("HwfsID")
iNumRows = CInt(Request.Form("HuiRows"))
iNumCols = CInt(Request.Form("HuiCols"))
sSaveOnly = Request.Form("HRefresh")

if wfsID = "" OR iNumRows = 0 OR iNumCols = 0 then
    Response.Write("<br />Internal Error: Expected Form Elements NOT FOUND.<br />")
    response.Write(wfsID & " | " & iNumRows & " | " & iNumCols)
    Response.End
end if

sRecords = ""
for r = 1 to iNumRows
    for c = 1 to iNumCols
        ' Edit Cols
        sHID = "H_" & Cstr(r) & "_" & Cstr(c)
        if Request.Form(sHID) <> "" then
            sRecords = sRecords & Request.Form(sHID) & "|"
        else
            Response.Write("Internal Error: Expected Form Element " & sHID & " NOT FOUND.")
            Response.End
        end if
    next    ' c
next    ' r
if len(sRecords) > 1 then
    sRecords = Left(sRecords,len(sRecords)-1)  ' lop of trailing |
end if

' Spit out what we should save
'response.Write("<div>")
'response.Write("<div>wfsID = " & wfsID & "<br />UserID = " & Cstr(thisUserID) & "<br />" )
'response.Write("Records: " & "<br /><hr>" & sRecords & "<br /><hr><br />")
'response.Write("Length of Records String: " & Cstr(len(sRecords)) & "<br /></div>")
' response.End

Dim cmd, strSQL, strMessage

strSQL = "exec usp_SPD_FieldLocking_Save @WFSID=" & wfsID & ", " & "@RowDelimiter='|', @FieldDelimiter='_', @UserID=" & thisUserID & ", @Records='" & sRecords & "'"
' response.Write("SQL Call:<br />" & strSQL)
' response.End

Set cmd = Server.CreateObject("ADODB.Command")
cmd.ActiveConnection  = Application.Value("connStr")
'		cmd.ActiveConnection.BeginTrans
cmd.CommandText = strSQL
cmd.CommandType = adCmdText
cmd.CommandTimeout = 1400

' Execute the query without returning a recordset
' Specifying adExecuteNoRecords reduces overhead and improves performance
cmd.Execute true, , adExecuteNoRecords
' cmd.ActiveConnection.CommitTrans


if Err <> 0 then
    strMessage = "Error Occurred Saving Data.  Error Message:<br />" & Err.Description
    Set cmd.ActiveConnection = Nothing
    Set cmd = Nothing
Else
    Set cmd.ActiveConnection = Nothing
    Set cmd = Nothing
    strMessage = ""
    if sSaveOnly = 1 then
        Response.Redirect("FieldLocking_details.asp?wid=" & wfID & "&wfsID=" & wfsID)
        ' response.Redirect("field_locking_frm.asp?wid=" & wfID & "&id=" & wfsID)
    end if
end if

'if objConn.Errors.Count < 1 and Err.number < 1 then
'	objConn.CommitTrans
'	Session.Value("CUSTOMFIELD_SAVE_SUCCESS") = "1"
'	
'	ActivityLog.Reference_ID = fieldID
'	
'	if boolIsNew then
'		ActivityLog.Activity_Type = ActivityType.Create_ID
'		ActivityLog.Activity_Summary = "Created New Field " & Field_Name
'	else
'		ActivityLog.Activity_Type = ActivityType.Modify_ID
'		ActivityLog.Activity_Summary = "Modified Field " & Field_Name
'	end if
'	
'	ActivityLog.Save
'	
'else
'	objConn.RollbackTrans
'	Session.Value("CUSTOMFIELD_SAVE_SUCCESS") = "0"
'end if

Set ActivityLog				= Nothing
Set ActivityType			= Nothing
Set ActivityReferenceType	= Nothing

%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7" />
	<title>Field Locking</title>
<%
if strMessage = "" then
%>

<script language="javascript">
	parent.frames["header"].document.location = "./../../app_include/blank_cccccc.html";
	parent.frames["controls"].document.location = "./../../app_include/blank_cccccc.html";
	parent.frames["body"].document.location = "FieldLocking_details_work_finish.asp";
</script>
</head>
<body></body></html>

<%
else
%>

</head>
<body>
<h4><%=strMessage %></h4>
Please Try Again. Or...<br>
<a href="javascript:self.close();">Click to close</a>
</body></html>
<%
end if
Response.Write "TEST": Response.End
%>
