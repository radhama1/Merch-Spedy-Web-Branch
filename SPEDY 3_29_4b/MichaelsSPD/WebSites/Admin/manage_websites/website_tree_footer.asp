<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
%>
<!--#include file="./../app_include/_globalInclude.asp"-->
<%
Response.Buffer = True
Response.Expires = -1441
%>
<html>
<head>
	<title></title>
	<script language=javascript>
	<!--
		var selectedCatID = 0;
		var selectedItemID = 0;
		
		function openNewWebsiteWindow()
		{
			newWebsiteWin = window.open("./website_admin/website_details_frm.asp", "newSiteWindow", "width=600,height=500,toolbar=0,location=0,directories=0,status=1,menuBar=0,scrollBars=0,resizable=1");
			newWebsiteWin.focus();
		}
		
	//-->
	</script>
</head>
<body bgcolor="999999" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>

<table cellpadding=0 cellspacing=0 border=0>
	<tr><td colspan=2><img src="./images/spacer.gif" height=3 width=1></td></tr>
	<tr>
		<td><a href="javascript: openNewWebsiteWindow(); void(0);"><img src="./images/new_website.gif" height=20 width=100 border=0></a></td>
	</tr>
</table>

</body>
</html>
