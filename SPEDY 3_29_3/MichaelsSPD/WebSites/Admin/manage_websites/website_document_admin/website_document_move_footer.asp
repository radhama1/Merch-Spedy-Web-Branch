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
	<title>Move Document</title>
	<style type="text/css">
	<!--
		A {text-decoration: none;}
	//-->
	</style>
	<script language=javascript>
	<!--
		function doCommit()
		{
			parent.frames['body'].document.frmMenu.submit();
		}

		function updateMoveDirection()
		{
			var myDir = document.theForm.selDir.value;
			parent.frames['body'].document.frmMenu.moveDirection.value = myDir;
		//	alert("You have chosen to move your document " + myDir + " the selected item in the list.\n\nPlease Note:  The selected item will be used as a point of reference and will not be modified or moved..");
		}
	//-->
	</script>
</head>
<body bgcolor="cccccc" link=0000ff vlink=0000ff topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>
<table width=100% cellpadding=0 cellspacing=0 border=0 align=center>
	<form name=theForm action="" method=POST>
	<tr>
		<td><img src="./../images/spacer.gif" height=1 width=5 border=0></td>
		<td>
			<table width="100%" cellpadding=0 cellspacing=0 border=0>
				<tr>
					<td colspan=3>
						<select name="selDir" onChange="javascript:updateMoveDirection();">
							<option value="above">Move ABOVE the Selected Item
							<option value="below">Move BELOW the Selected Item
							<option value="within">Move WITHIN the Selected Item
						</select>
					</td>
				</tr>
				<tr><td colspan=3><img src="./../images/spacer.gif" height=3 width=1 border=0></td></tr>
				<tr>
					<td colspan=3>
						<table cellpadding=0 cellspacing=0 border=0>
							<tr>
								<td><input type=button name="btnCancel" value="Cancel" onClick="javascript: void(0); parent.window.close();"></td>
								<td width=100%><img src="./../images/spacer.gif" height=1 width=5 border=0></td>
								<td><input type=button name="btnCommit" value="    OK    " onClick="javascript: void(0); doCommit();"></td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
		<td><img src="./../images/spacer.gif" height=1 width=5 border=0></td>
	</tr>
	</form>
</table>



</body>
</html>