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
%>
<html>
<head>
	<title><%=Request.QueryString("fn")%></title>
	<style type="text/css">
	<!--
		A {text-decoration: none;}
	//-->
	</style>
	<script language=javascript>
		self.focus();
		window.defaultStatus = "Retrieve File";
	</script>
</head>
<frameset rows="*" border="0" topmargin=0 leftmargin=0 rightmargin=0 bottommargin=0 marginheight=0 marginwidth=0>
	<frame name="filePopUpWin_ContentFrame" src="getfile_contents.asp?tid=<%=Request.QueryString("tid")%>&fid=<%=Request.QueryString("fid")%>" scrolling="yes" noresize>
</frameset>
</html>
