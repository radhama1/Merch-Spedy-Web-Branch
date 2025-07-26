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

Dim objConn, objRec, SQLStr, connStr
Dim websiteID
Dim Website_Name, oldWebsiteName, Date_Created, Date_Last_Modified
Dim ActivityLog, ActivityType, ActivityReferenceType

websiteID = Request("webid")
if IsNumeric(websiteID) then
	websiteID = CInt(websiteID)
else
	websiteID = 0
end if

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")
connStr = Application.Value("connStr")
objConn.Open connStr

if Request.Form.Count > 0 and len(Request.Form("Website_Name")) > 0 then
	SQLStr = "SELECT * FROM Website WHERE ID = " & websiteID
	objRec.Open SQLStr, objConn, adOpenKeyset, adLockOptimistic, adCmdText
	if not objRec.EOF then
		oldWebsiteName = objRec("Website_Name")
		objRec("Website_Name") = Request.Form("Website_Name")
		objRec("Date_Last_Modified") = CDate(Now)
		objRec.Update
	end if
	objRec.Close
	
	Set ActivityLog				= New cls_ActivityLog
	Set ActivityType			= New cls_ActivityType
	Set ActivityReferenceType	= New cls_ActivityReferenceType

	ActivityLog.Reference_Type = ActivityReferenceType.Websites_Website
	ActivityLog.Reference_ID = websiteID
	ActivityLog.Activity_Type = ActivityType.Modify_ID
	ActivityLog.Activity_Summary = "Modified Website - Renamed from " & oldWebsiteName & " to " & Request.Form("Website_Name")
	
	ActivityLog.Save
	
	Set ActivityLog				= Nothing
	Set ActivityType			= Nothing
	Set ActivityReferenceType	= Nothing

	Call DB_CleanUp
	Response.Redirect "website_save_result.asp"
end if

SQLStr = "SELECT Website_Name, Date_Created, Date_Last_Modified FROM Website WHERE ID = " & websiteID
objRec.Open SQLStr, objConn, adOpenForwardOnly, adLockReadOnly, adCmdText
if not objRec.EOF then
	Website_Name = objRec("Website_Name")
	Date_Created = CDate(objRec("Date_Created"))
	Date_Last_Modified = CDate(objRec("Date_Last_Modified"))
end if
objRec.Close

Call DB_CleanUp
%>
<html>
<head>
	<title>Edit Website:&nbsp;<%=Website_Name%></title>
</head>
<body bgcolor="cccccc" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>

<table cellpadding=0 cellspacing=0 border=0 align=center>
	<tr>
	<tr><td colspan=2><img src="../images/spacer.gif" height=10 width=1 border=0></td></tr>
	<form name="theForm" action="website_rename.asp" method=POST>
	<tr>
		<td colspan=2>
			<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:11px;color:#000000">
			<b>Website Name</b>
			</font>
		</td>
	</tr>
	<tr><td colspan=2><input type="text" size=40 maxlength=200 name="Website_Name" value="<%=Website_Name%>" AutoComplete="off"></td></tr>
	<tr><td colspan=2><img src="../images/spacer.gif" height=10 width=1 border=0></td></tr>
	<tr>
		<td>
			<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:11px;color:#000000">
			<b>Date Created</b>
			</font>
		</td>
		<td align=right>
			<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:11px;color:#000000">
			<%=Date_Created%>
			</font>
		</td>
	</tr>
	<tr>
		<td>
			<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:11px;color:#000000">
			<b>Date Last Modified</b>
			</font>
		</td>
		<td align=right>
			<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:11px;color:#000000">
			<%=Date_Last_Modified%>
			</font>
		</td>
	</tr>
	<tr><td colspan=2><img src="../images/spacer.gif" height=10 width=1 border=0></td></tr>
	<tr>
		<td colspan=2 align=right>
			<table cellpadding=0 cellspacing=0 border=0>
				<tr width=100%>
					<td><input type=button name="doSubmit" value=" Cancel " onClick="self.close();"></td>
					<td width=100%><img src="../images/spacer.gif" height=1 width=5 border=0></td>
					<td><input type=submit name="doSubmit" value=" Save & Close "></td>
				</tr>
			</table>
		</td>
	</tr>
	<input type="hidden" name="webid" value="<%=websiteID%>">
	</form>
</table>

</body>
</html>

<!--
<table cellpadding=0 cellspacing=0 border=0>
	<tr>
		<td colspan=2>
			<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:11px;color:#333333">
			</font>
		</td>
	</tr>
</table>
-->

<%
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