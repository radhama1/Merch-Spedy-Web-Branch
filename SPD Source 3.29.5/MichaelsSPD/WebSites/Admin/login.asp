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
if Trim(Session.Value("UserID")) <> "" then
	Response.Redirect "default.asp"
end if
%>
<html>
<head>
	<title><%=Application.Value("GLOBAL_SITE_TITLE")%> | Authentication Required</title>
	<style type="text/css">
		@import url('./app_include/global.css');
		A {text-decoration: underline; color:#000000;}
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
			top.location = "login.asp";
		}
	</script>
</head>
<body bgcolor="e8e8e8" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>


<div id="bodyContainer" style="">
	<div id="loginForm" style="">
		<form name="theForm" action="./app_include/dologin.asp" method=POST style="padding: 0; margin: 0;">
		<table cellpadding=0 cellspacing=0 border=0>
			<tr>
				<td valign=top><img src="./app_images/lock.jpg" style="margin: 20px;"></td>
				<td valign=top>
					<div style="margin-left: 20px;">
						<div class="bodyText"><b>Login Required</b></div>
						<div class="bodyText">
							<%
							if Trim(Session.Value("LOGIN_ERROR_MSG")) = "" then
							%>
							Please enter your Username and Password<br>
							in the spaces provided below.
							<%
							else
							%>
							<span style="color:#ff0000">
							<b><%=Session.Value("LOGIN_ERROR_MSG")%></b>
							</span>
							<%
							end if
							%>
						</div>
						<div class="bodyText" style="margin-top: 10px;"><b>Username</b></div>
						<div class="bodyText"><input type=text name="Login_UserName" value="<%=Session.Value("Login_UserName")%>" AutoComplete="OFF"></div>
						<div class="bodyText" style="margin-top: 5px;"><b>Password</b></div>
						<div class="bodyText"><input type=password name="Login_Password" value="" AutoComplete="OFF"></div>
						<div class="bodyText" style="margin-top: 10px;"><input type=submit name="doMeBaby" value=" Login "></div>
					</div>
				</td>
			</tr>
		</table>
		<input type=hidden name="redir" value="<%=Request("redir")%>">
		</form>
	</div>
</div>

<%if Instr(UCase(Request.ServerVariables("HTTP_USER_AGENT")), "MSIE") > 0 then%>
<script language=javascript>
<!--
	document.theForm.Login_UserName.select();
	document.theForm.Login_UserName.focus();
//-->
</script>
<%end if%>

</body>
</html>
<!--#include file="./app_include/listServerVariables.asp"-->
