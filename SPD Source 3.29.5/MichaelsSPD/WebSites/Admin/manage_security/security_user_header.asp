<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441 
%>
<!--#include file="../app_include/findNeedleInHayStack.asp"-->
<!--#include file="../app_include/smartValues.asp"-->
<!--#include file="./../app_include/checkQueryID.asp"-->
<%
Dim objConn, objRec, SQLStr, connStr
Dim rowcolor, i
Dim strToolTip
Dim SortColumn, SortDirection
Dim enumerateUserGroup, enumerateUserRole, selectedGroupID

enumerateUserGroup = Request("enumgroup")
if IsNumeric(enumerateUserGroup) then
	enumerateUserGroup = CBool(enumerateUserGroup)
else
	enumerateUserGroup = CBool(0)
end if

enumerateUserRole = Request("enumrole")
if IsNumeric(enumerateUserRole) then
	enumerateUserRole = CBool(enumerateUserRole)
else
	enumerateUserRole = CBool(0)
end if

selectedGroupID = Request("sgid")
if IsNumeric(selectedGroupID) then
	selectedGroupID = CInt(selectedGroupID)
else
	selectedGroupID = 0
end if

SortColumn = Trim(Request("sort"))
if IsNumeric(SortColumn) and Trim(SortColumn) <> "" then
	SortColumn = CInt(SortColumn)
	Session.Value("Security_User_SortColumn") = SortColumn
else
	if IsNumeric(Session.Value("Security_User_SortColumn")) and Trim(Session.Value("Security_User_SortColumn")) <> "" then
		SortColumn = CInt(Session.Value("Security_User_SortColumn"))
	else
		SortColumn = 0
		Session.Value("Security_User_SortColumn") = SortColumn
	end if
end if

SortDirection = Trim(Request("direction"))
if IsNumeric(SortDirection) and Trim(SortDirection) <> "" then
	SortDirection = CInt(SortDirection)
	Session.Value("Security_User_SortDirection") = SortDirection
else
	if IsNumeric(Session.Value("Security_User_SortDirection")) and Trim(Session.Value("Security_User_SortDirection")) <> "" then
		SortDirection = CInt(Session.Value("Security_User_SortDirection"))
	else
		SortDirection = 0
		Session.Value("Security_User_SortDirection") = SortDirection
	end if
end if

'Response.Write SortColumn & SortDirection

Session.Value("Allowed_Edit_List") = ""
Session.Value("Allowed_Publish_List") = ""
Session.Value("Picked_Topic") = ""

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr
%>
<html>
<head>
	<title>View All Content</title>
	<style type="text/css">
	<!--
		A {text-decoration: none; color: #000000; cursor: hand;}
		A:HOVER {text-decoration: underline; color: #0000ff; cursor: hand;}
		.rover {background-color: #ffff99}
		BODY
		{
			scrollbar-face-color: "#cccccc"; 
			scrollbar-highlight-color: "#ffffff"; 
			scrollbar-shadow: "#999999";
			scrollbar-3dlight-color: "#cccccc"; 
			scrollbar-arrow-color: "#000000";
			scrollbar-track-color: "#ececec";
			scrollbar-darkshadow-color: "#000000";
			cursor: default;
		}
  	//-->
	</style>
	<script language="javascript" src="../app_include/selectrow.js"></script><!--row highlighting-->
	<script language="javascript" src="../app_include/lockscroll.js"></script><!--locked headers code-->
	<script language=javascript>
	<!--
		function doRemoveRecord(strURL)
		{
			if (confirm("Are you sure you would like to remove this user?\n\nThis action cannot be undone!"))
			{
				document.location = strURL
			}
		}

		function launchNewWin(myLoc, myName, myWidth, myHeight)
		{
				var myFeatures = "directories=no,dependent=yes,width=" + myWidth + ",height=" + myHeight + ",hotkeys=no,location=no,menubar=no,resizable=yes,screenX=100,screenY=100,scrollbars=yes,titlebar=no,toolbar=no,status=no";
				var newWin = window.open(myLoc, myName, myFeatures);
		}
	//-->
	</script>
</head>
<body bgcolor="cccccc" topmargin=0 leftmargin=0 rightmargin=0 marginheight=0 marginwidth=0>

<%
if enumerateUserGroup and selectedGroupID > 0 then
	SQLStr = "sp_security_group_details '0" & selectedGroupID & "'"
elseif enumerateUserRole and selectedGroupID > 0 then
	SQLStr = "sp_security_group_details '0" & selectedGroupID & "'"
end if
'Response.Write SQLStr
objRec.Open SQLStr, objConn, adOpenStatic, adLockReadOnly, adCmdText
if not objRec.EOF then
%>
<table cellpadding=0 cellspacing=0 onSelectStart="return false" border=0>
	<tr>
		<td><img src="./images/spacer.gif" height=1 width=6></td>
		<td valign=top nowrap>
			<font style="font-family:Arial, Helvetica;font-size:11px;color:#333">
			Members of <%if not IsNull(objRec("Group_Name")) then Response.Write objRec("Group_Name")%>
			</font>
		</td>
		<td><img src="./images/spacer.gif" height=1 width=10></td>
	</tr>
</table>
<%
end if
objRec.Close
%>

</body>
</html>
<%
Call DB_CleanUp
Sub DB_CleanUp
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