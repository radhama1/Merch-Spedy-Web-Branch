<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
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
		
		function openNewUserWindow()
		{
			newUserWin = window.open("./security_user_admin/security_user_details_frm.asp?cid=0", "newUserWindow", "width=600,height=500,toolbar=0,location=0,directories=0,status=1,menuBar=0,scrollBars=1,resizable=0");
			newUserWin.focus();
		}

		function openNewGroupWindow()
		{
			newGroupWin = window.open("./security_group_admin/security_group_details_frm.asp?gid=0", "newGroupWindow", "width=600,height=500,toolbar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=1,resizable=0");
			newGroupWin.focus();
		}
		
		function openSecurityImportCSVWindow()
		{
			newGroupWin = window.open("./security_user_import_from_excel.asp", "SecurityExcelImport", "width=510,height=170,toolbar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=1,resizable=1");
			newGroupWin.focus();
		}
		
	//-->
	</script>
</head>
<body bgcolor="999999" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>

<div id="CategoryOptionsLyr" name="CategoryOptionsLyr">
<table width=100% cellpadding=0 cellspacing=0 border=0>
	<tr><td><img src="./images/spacer.gif" height=3 width=1></td></tr>
	<tr>
		<td>
			<table cellpadding=0 cellspacing=0 border=0>
				<tr>
					<td><a href="javascript: openNewUserWindow(); void(0);"><img src="./images/new_user.gif" height=20 width=100 border=0 onMouseOver="window.status='';return true;" onMouseOut="window.status='';return true;"></a></td>
					<td><a href="javascript: openNewGroupWindow();  void(0);"><img src="./images/new_user_group.gif" height=20 width=100 border=0 onMouseOver="window.status='';return true;" onMouseOut="window.status='';return true;"></a></td>
					<td nowrap>&nbsp;<a href="javascript: openSecurityImportCSVWindow();  void(0);"><FONT SIZE="1" FACE="Arial" COLOR="white">Update Users Using CSV File</FONT></a>&nbsp;</td>
					<td width=100%><img src="./images/spacer.gif" height=3 width=1></td>
				</tr>
			</table>
		</td>
	</tr>
</table>
</div>

</body>
</html>
