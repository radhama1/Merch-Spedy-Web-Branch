<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441
%>
<!--#include file="./app_include/_globalInclude.asp"-->
<%
Session.Abandon
%>
<html>
<head>
	<title><%=Application.Value("GLOBAL_SITE_TITLE")%> | Logout</title>
	<style type="text/css">
		@import url('./app_include/global.css');
		A {text-decoration: underline; color:#000;}
		A:HOVER {text-decoration: underline; color:#00f;}
		.bodyText {line-height: 14px;}
		
		#bodyContainer
		{
			width: 100%;
			height: 100%;
			clip: auto;
			overflow: auto;
			text-align: center;
		}
		
		#loginForm
		{
			margin-left: auto;
			margin-right: auto;
			width: 400px; 
			background: #fff; 
			border: 1px outset #fff; 
			text-align: left; 
			padding: 10px; 
			margin-top: 50px;
		}
		
	</style>
	<script language=javascript>
		window.defaultStatus = "Redirecting…"
		if (self.parent.frames.length != 0)
		{
			top.location = "logout.asp";
		}
		else
		{
			self.location = "login.asp";			
		}
	</script>
</head>
<body bgcolor="e8e8e8" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>

<div id="bodyContainer" style="">
	<div id="loginForm" style="">
		<form name="theForm" action="./include/dologin.asp" method=POST style="padding: 0; margin: 0;" ID="Form1">
		<table cellpadding=0 cellspacing=0 border=0 ID="Table1">
			<tr>
				<td valign=top><img src="./app_images/lock.jpg" style="margin: 20px;"></td>
				<td valign=top>
					<div style="margin-left: 20px;">
						<div class="bodyText"><b>Logout Successful</b></div>
						<div class="bodyText">
							You have been logged out.
							<p><a href="./login.asp">Click here</a> to log in again.
						</div>
					</div>
				</td>
			</tr>
		</table>
		</form>
	</div>
</div>


</body>
</html>
