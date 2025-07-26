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
	<title>Move Question</title>
	<style type="text/css">
	<!--
		A {text-decoration: none;}
	//-->
	</style>
	<script language=javascript>
	<!--
		window.defaultStatus = "Move Question"
	//-->
	</script>
</head>
<body bgcolor="cccccc" link=0000ff vlink=0000ff topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>
<table width=100% cellpadding=0 cellspacing=0 border=0 align=center>
	<tr>
		<td><img src="./../images/spacer.gif" height=1 width=5 border=0></td>
		<td>
			<table width=100% cellpadding=0 cellspacing=0 border=0>
				<tr>
					<td>
						<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
						<b>Move Question</b>
						</font>
					</td>
				</tr>
				<tr>
					<td>
						<font style="font-family:Arial, Helvetica;font-size:11px;color:#000000">
						Select a new location for this question
						</font>
					</td>
				</tr>
			</table>
		</td>
		<td><img src="./../images/spacer.gif" height=1 width=5 border=0></td>
	</tr>
</table>

</body>
</html>