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
		
		function openNewCatWindow()
		{
			newCatWin = window.open("./website_document_admin/website_document_select.asp?itemType=folder", "newCatWindow", "width=700,height=550,toolbar=0,location=0,directories=0,status=1,menuBar=0,scrollBars=0,resizable=1");
			newCatWin.focus();
		}

		function openDocChooseWindow()
		{
			newDocWin = window.open("./website_document_admin/website_document_select.asp?itemType=document", "chooseDocWindow", "width=700,height=550,toolbar=0,location=0,directories=0,status=1,menuBar=0,scrollBars=1,resizable=0");
			newDocWin.focus();
		}
		
	//-->
	</script>
</head>
<body bgcolor="999999" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>

<div id="CategoryOptionsLyr" name="CategoryOptionsLyr">
<table cellpadding=0 cellspacing=0 border=0>
	<tr><td colspan=2><img src="./images/spacer.gif" height=3 width=1></td></tr>
	<tr>
		<!--
		<td><a href="javascript: openNewCatWindow(); void(0);"><img src="./images/new_category.gif" height=20 width=100 border=0 onMouseOver="window.status='';return true;" onMouseOut="window.status='';return true;"></a></td>
		-->
		<td><a href="javascript: openDocChooseWindow(); void(0);"><img src="./images/new_document2.gif" height=20 width=100 border=0 onMouseOver="window.status='';return true;" onMouseOut="window.status='';return true;"></a></td>
	</tr>
</table>
</div>

</body>
</html>
