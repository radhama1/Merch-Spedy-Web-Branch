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
Dim topicID, currentStatus
Dim ActivityLog, ActivityType, ActivityReferenceType, utils, rs
Dim topicName

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")
connStr = Application.Value("connStr")
objConn.Open connStr

topicName = ""
topicID = Request("tid")
if IsNumeric(topicID) then
	topicID = CInt(topicID)
else
	topicID = 0
end if

Dim newNavString
SQLStr = "sp_websites_admin_climbladder " & topicID & ", " & CInt(Session.Value("websiteID")) & ", 1"
Set objRec = objConn.Execute(SQLStr)
if not objRec.EOF then
	if not IsNull(objRec(0)) then
		newNavString = Trim(objRec(0))
	end if
end if
objRec.Close

if Request.Form.Count > 0 and len(Request.Form("chosenStatus")) > 0 then

	SQLStr = "SELECT * FROM Website_Element WHERE ID = " & topicID
	objRec.Open SQLStr, objConn, adOpenKeyset, adLockOptimistic, adCmdText
	
	objRec("Status_ID") = CInt(Request.Form("chosenStatus"))

	objRec.Update
	objRec.Close

	Set ActivityLog				= New cls_ActivityLog
	Set ActivityType			= New cls_ActivityType
	Set ActivityReferenceType	= New cls_ActivityReferenceType
	Set utils					= New cls_UtilityLibrary
	
	'Get the topic Name for auditing purposes
	SQLStr = "Select Top 1 Element_ShortTitle From Website_Element_Data Where Element_ID = " & topicID
	Set rs = utils.LoadRSFromDB(SQLStr)
	
	if Not rs.EOF then
		topicName = SmartValues(rs("Element_ShortTitle"), "CStr")
	end if
	
	rs.Close
	Set rs = Nothing
	
	'Audit Modify activity
	ActivityLog.Reference_ID = topicID
	ActivityLog.Activity_Summary = "Modified Status of Document " & topicName
	ActivityLog.Reference_Type = ActivityReferenceType.Websites_Document
	ActivityLog.Activity_Type = ActivityType.Modify_ID
	ActivityLog.Save
	
	Set utils					= Nothing
	Set ActivityLog				= Nothing
	Set ActivityType			= Nothing
	Set ActivityReferenceType	= Nothing
	
	Call DB_CleanUp
	Response.Redirect "website_document_status_result.asp?open=" & Server.URLEncode(newNavString)

else

	SQLStr = "SELECT Status_ID FROM Website_Element WHERE ID = " & topicID
	objRec.Open SQLStr, objConn, adOpenKeyset, adLockOptimistic, adCmdText
	Set objRec = objConn.Execute(SQLStr)
	if not objRec.EOF then
		if IsNumeric(objRec(0)) then
			currentStatus = CInt(objRec(0))
		else
			currentStatus = 0
		end if
	end if
	objRec.Close

end if

%>
<html>
<head>
	<title>Edit Document Status</title>
</head>
<body bgcolor="cccccc" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0 onLoad="document.theForm.chosenStatus.focus()">

<table cellpadding=0 cellspacing=0 border=0 align=center>
	<tr>
	<tr><td colspan=2><img src="../images/spacer.gif" height=10 width=1 border=0></td></tr>
	<form name="theForm" action="website_document_status.asp" method=POST>
	<tr>
		<td colspan=2>
			<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:11px;color:#000000">
			<b>Choose a New Status</b>
			</font>
		</td>
	</tr>
	<tr>
		<td colspan=2>
		<%
		SQLStr = "SELECT * FROM Repository_Status WHERE Display = 1 ORDER BY SortOrder, Status_Name"
		objRec.Open SQLStr, objConn, adOpenKeyset, adLockReadOnly, adCmdText
		if not objRec.EOF then
		%>
			<select name="chosenStatus">
				<option value="0">None
			<%
			Do until objRec.EOF
			%>
				<option value="<%=objRec("ID")%>"<%if currentStatus = CInt(objRec("ID")) then Response.Write " SELECTED"%>><%=objRec("Status_Name")%>
			<%
				objRec.MoveNext
			Loop
			%>
			</select>
		<%
		end if
		objRec.Close
		%>
		</td>
	</tr>
	<tr><td colspan=2><img src="../images/spacer.gif" height=20 width=1 border=0></td></tr>
	<tr>
		<td colspan=2 align=right>
			<table cellpadding=0 cellspacing=0 border=0>
				<tr width=100%>
					<td><input type=button name="doSubmit" value=" Cancel " onClick="self.close();"></td>
					<td width=100%><img src="../images/spacer.gif" height=1 width=5 border=0></td>
					<td><input type=submit name="doSubmit" value=" Save "></td>
				</tr>
			</table>
		</td>
	</tr>
	<input type="hidden" name="tid" value="<%=topicID%>">
	</form>
</table>

</body>
</html>

<%
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

%>