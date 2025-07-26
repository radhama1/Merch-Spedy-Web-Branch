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
Dim Security
Set Security = New cls_Security
Security.Initialize Session.Value("UserID"), "ADMIN.CONTENT.REPOSITORY.CATEGORIES", 0
%>
<html>
<head>
	<title></title>
	<script language=javascript>
		var selectedCatID = 0;
		var selectedItemID = 0;
		
		function openNewCatWindow()
		{
			newCatWin = window.open("./category_admin/category_details_frm.asp?pcid=" + selectedCatID, "newCatWindow_" + selectedItemID, "width=500,height=500,toolbar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=0,resizable=1");
			newCatWin.focus();
		}

		function openCatEditorWindow()
		{
			editWin = window.open("./category_admin/category_details_frm.asp?cid=" + selectedCatID, "editCatWindow_" + selectedItemID, "width=500,height=500,toolbar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=0,resizable=1");
			editWin.focus();
		}


		function openItemEditorWindow(RowID)
		{
			editWin = window.open("./document_admin/document_details_frm.asp?cid=" + selectedItemID + "&tid=0", "newDocWindow_" + selectedItemID, "width=800,height=610,toolbar=0,location=0,directories=0,status=1,menuBar=0,scrollBars=1,resizable=1");
			editWin.focus();
		}
	</script>
</head>
<body bgcolor="999999" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>

<div id="CategoryOptionsLyr" name="CategoryOptionsLyr">
<table cellpadding=0 cellspacing=0 border=0>
	<tr><td colspan=2><img src="./images/spacer.gif" height=3 width=1></td></tr>
	<tr>
		<%if Security.isRequestedPrivilegeAllowed("ADMIN.CONTENT.REPOSITORY.CATEGORIES", "CATTOPLEVELADD") then%>
		<td><a href="javascript: openNewCatWindow(); void(0);"><img src="./images/new_category.gif" height=20 width=100 border=0 onMouseOver="window.status='';return true;" onMouseOut="window.status='';return true;"></a></td>
		<%end if%>
		<td><a href="javascript: openItemEditorWindow(0); void(0);"><img src="./images/new_document.gif" height=20 width=100 border=0 onMouseOver="window.status='';return true;" onMouseOut="window.status='';return true;"></a></td>
	</tr>
</table>
</div>

</body>
</html>
