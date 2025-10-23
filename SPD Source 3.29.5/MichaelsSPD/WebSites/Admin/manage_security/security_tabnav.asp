<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441
%>
<!--#include file="./../app_include/_globalInclude.asp"-->
<%
Dim selectedTab

selectedTab = Trim(Request("tab"))
if IsNumeric(selectedTab) and Trim(selectedTab) <> "" then
	selectedTab = CInt(selectedTab)
else
	if IsNumeric(Session.Value("SECURITY_SELECTEDTAB")) and Trim(Session.Value("SECURITY_SELECTEDTAB")) <> "" then
		selectedTab = Session.Value("SECURITY_SELECTEDTAB")
	else
		selectedTab = 0
	end if
end if

Session.Value("SECURITY_SELECTEDTAB") = selectedTab

function writeTabImgSuffix(tabOrdinal)
	Dim strImgSuffix
	strImgSuffix = "_off"

	'pass the zero-based ordinal of the requested tab
	if IsNumeric(tabOrdinal) and not IsNull(tabOrdinal) and tabOrdinal <> "" then
		if CInt(selectedTab) = CInt(tabOrdinal) then
			strImgSuffix = "_on"
		end if
	end if

	writeTabImgSuffix = strImgSuffix
end function

function writeLabelGraphic()
	Dim strReturnVal
	strReturnVal = "spacer.gif"

	'pass the zero-based ordinal of the requested tab
	if IsNumeric(selectedTab) and not IsNull(selectedTab) and selectedTab <> "" then

		Select Case selectedTab
			Case 0
				strReturnVal = "label_security_user.gif"
			Case 1
				strReturnVal = "label_security_group.gif"
			Case 2
				strReturnVal = "label_security_role.gif"
			Case 3
				strReturnVal = "label_security_settings.gif"
		End Select

	end if

	writeLabelGraphic = strReturnVal
end function

Dim Security
Dim bIsSystemAdmin

bIsSystemAdmin = False
Set Security = New cls_Security
Security.Initialize "0" & Session.Value("UserID"), "ADMIN", "0"

If Security.isSystemAdministrator() Then
	bIsSystemAdmin = True
End If
Set Security = Nothing
%>
<html>
<head>
	<title></title>
	<style type="text/css">
	<!--
		A {text-decoration: none; cursor: hand;}
		A:HOVER {text-decoration: underline; cursor: hand;}
		BODY
		{
			cursor: default;
		}
		.tSmall
		{
		    font-size:0.6em;
		    font-family: arial;
		    color: lightblue;
		}
	//-->
	</style>
	<script language="javascript">
		function launchNewWin(myLoc, myName, myWidth, myHeight)
		{
			var myFeatures = "directories=no,dependent=yes,width=" + myWidth + ",height=" + myHeight + ",hotkeys=no,location=no,menubar=no,resizable=yes,screenX=10,screenY=10,scrollbars=yes,titlebar=no,toolbar=no,status=no";
			var newWin = window.open(myLoc, myName, myFeatures);
		}
	</script>
</head>
<body bgcolor="333333" text=ffffff topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>

<table width=100% cellpadding=0 cellspacing=0 border=0>
	<tr bgcolor=333333><td><img src="./images/spacer.gif" height=13 width=1 border=0></td></tr>
	<tr>
		<td>
			<div id="navigation" name="navigation">
				<table width=100% cellpadding=0 cellspacing=0 border=0>
					<tr bgcolor=333333>
						<td><img src="./images/spacer.gif" height=1 width=20 border=0></td>
						<td><a href="security_default.asp?tab=0" target="MainDisplayFrame"><img src="./images/tab_user<%=writeTabImgSuffix(0)%>.gif" height=12 width=100 border=0 alt="user administration" onMouseOver="window.status='';return true;" onMouseOut="window.status='';return true;"></a></td>
						<td><img src="./images/spacer.gif" height=1 width=4 border=0></td>
						<td><a href="security_default.asp?tab=1" target="MainDisplayFrame"><img src="./images/tab_group<%=writeTabImgSuffix(1)%>.gif" height=12 width=100 border=0 alt="group administration" onMouseOver="window.status='';return true;" onMouseOut="window.status='';return true;"></a></td>
						<td><img src="./images/spacer.gif" height=1 width=4 border=0></td>
						<td><a href="security_default.asp?tab=2" target="MainDisplayFrame"><img src="./images/tab_role<%=writeTabImgSuffix(2)%>.gif" height=12 width=100 border=0 alt="role administration" onMouseOver="window.status='';return true;" onMouseOut="window.status='';return true;"></a></td>
						<!--
						<td><img src="./images/spacer.gif" height=1 width=4 border=0></td>
						<td><a href="security_default.asp?tab=3" target="MainDisplayFrame"><img src="./images/tab_settings<%=writeTabImgSuffix(3)%>.gif" height=12 width=100 border=0 alt="security settings" onMouseOver="window.status='';return true;" onMouseOut="window.status='';return true;"></a></td>
						-->

						<td width=100%><img src="./images/spacer.gif" height=1 width=10 border=0><!--<span class="tSmall">Export: </span><A HREF="user_report.asp" target=_blank><FONT SIZE="1" FACE="Arial" COLOR="white">User List</FONT></A><img src="./images/spacer.gif" height=1 width=10 border=0><A HREF="user_department_report.asp" target=_blank><FONT SIZE="1" FACE="Arial" COLOR="white">Dept List</FONT></A><img src="./images/spacer.gif" height=1 width=25 border=0>--><%If bIsSystemAdmin Then%><span class="tSmall">Manage: </span><a href="#" onclick="launchNewWin('./security_department_admin/security_department_details_frm.asp', 'Manage_Dept_Sec', 590, 600); return false;"><font size="1" face="Arial" color="white">Dept Security</font></a><img src="./images/spacer.gif" height=1 width=10 border=0><a href="#" onclick="launchNewWin('./Security_Department_PriApprover/security_PriApprover_details_frm.asp', 'Manage_Dept_PriApprovers', 900, 700); return false;"><font size="1" face="Arial" color="white">Primary Approvers</font></a><img src="./images/spacer.gif" height=1 width=1 border=0><%End If%></td>
						<td align=right><img src="./images/<%=writeLabelGraphic%>" height=12 width=195 border=0></td>
					</tr>
				</table>
			</div>
		</td>
	</tr>
</table>

</body>
</html>