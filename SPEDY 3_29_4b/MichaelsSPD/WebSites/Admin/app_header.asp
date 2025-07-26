<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441
%>
<!--#include file="./app_include/_globalInclude.asp"-->
<html>
<head>
	<title>Application Header Frame</title>
	<style type="text/css">
	<!--
		A {text-decoration: none; color:#000000;}
	//-->
	</style>
</head>
<body bgcolor="cccccc" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>

<table width=100% cellpadding=0 cellspacing=0 border=0>
	<tr>
		<td><img src="./app_images/spacer.gif" width=1 height=25 border=0></td>
		<td width=100% valign=bottom>
			<table width=100% cellpadding=0 cellspacing=0 border=0 align=right>
				<tr>
					<td width=100% nowrap=true align=right valign=bottom>
						<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:10px;color:#666666">
						<%
						if Trim(Session.Value("UserID")) <> "" then
						%>
						<b>User <%=Trim(Session.Value("User_First_Name"))%> Logged In</b>
						<%
						end if
						%>
						</font>
					</td>
					<td><img src="./app_images/spacer.gif" width=10 height=1 border=0></td>
					<td width=100% nowrap=true align=right valign=bottom>
						<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:10px;color:#000000">
						<%
						if Trim(Session.Value("UserID")) <> "" then
						%>
						<!--
						<a href="logout.asp" target="_top" onMouseOver="window.status='Click to Log Out';return true;" onMouseOut="window.status='';return true;">Account</a>&nbsp;|
						<a href="logout.asp" target="_top" onMouseOver="window.status='Click to Log Out';return true;" onMouseOut="window.status='';return true;">Preferences</a>&nbsp;|
						<a href="logout.asp" target="_top" onMouseOver="window.status='Click to Log Out';return true;" onMouseOut="window.status='';return true;">History</a>&nbsp;|
						-->
						<a href="logout.asp" target="_top" onMouseOver="window.status='Click to Log Out';return true;" onMouseOut="window.status='';return true;">Logout</a>
						<%
						end if
						%>
						</font>
					</td>
					<!--
					<td width=100%><img src="./app_images/spacer.gif" width=1 height=1 border=0></td>
					<td><a href="" target="_top" title=":: Account ::" onMouseOver="window.status=':: Account ::';return true;" onMouseOut="window.status='';return true;"><img src="./app_images/header/hdr_account_off.gif" width=20 height=20 border=0></a></td>
					<td><a href="" target="_top" title=":: Preferences ::" onMouseOver="window.status=':: Preferences ::';return true;" onMouseOut="window.status='';return true;"><img src="./app_images/header/hdr_prefs_off.gif" width=20 height=20 border=0></a></td>
					<td><a href="" target="_top" title=":: History ::" onMouseOver="window.status=':: History ::';return true;" onMouseOut="window.status='';return true;"><img src="./app_images/header/hdr_history_off.gif" width=20 height=20 border=0></a></td>
					-->
					<td><img src="./app_images/spacer.gif" width=2 height=1 border=0></td>
				</tr>
				<tr><td><img src="./app_images/spacer.gif" width=1 height=2 border=0></td></tr>
			</table>
		</td>
	</tr>
</table>

</body>
</html>
