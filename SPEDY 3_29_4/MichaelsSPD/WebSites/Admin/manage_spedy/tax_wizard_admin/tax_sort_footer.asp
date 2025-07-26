<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441

Dim boolIsNew
Dim parentQuestionID
Dim objConn, objRec, SQLStr, connStr


boolIsNew = true
%>
<html>
<head>
	<title></title>
	<style type="text/css">
	<!--
		A {text-decoration: none;}
	//-->
	</style>
	<script language=javascript>
	<!--
		function doCancel()
		{
			if (confirm("Really discard your changes?"))
			{
				parent.window.close();
			}
		}

		function doCommit()
		{
			strOut = "";
			for (i = 0; i < parent.frames['body'].document.theForm.itemList.options.length; i++)
			{
				if (parent.frames['body'].document.theForm.itemList.options[i] && parent.frames['body'].document.theForm.itemList.options[i].value != "")
				{
					strOut = strOut + parent.frames['body'].document.theForm.itemList.options[i].value + ",";
				}
			}
			parent.frames['body'].document.theForm.sortedList.value = strOut;
		//	alert(parent.frames['body'].document.theForm.sortedList.value);
			parent.frames['body'].document.theForm.submit();
		}
	//-->
	</script>
</head>
<body bgcolor="cccccc" link=0000ff vlink=0000ff topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>
<table width=100% cellpadding=0 cellspacing=0 border=0 align=center>
	<form name=theForm action="" method=POST>
	<tr><td colspan=3><img src="./../images/spacer.gif" height=3 width=1 border=0></td></tr>
	<tr>
		<td><img src="./../images/spacer.gif" height=1 width=5 border=0></td>
		<td>
			<table width=100% cellpadding=0 cellspacing=0 border=0>
				<tr>
					<td width=100%><img src="./../images/spacer.gif" height=1 width=40 border=0></td>
					<td><input type=button name="btnCancel" value="Cancel" onClick="javascript: void(0); doCancel();"></td>
					<td><img src="./../images/spacer.gif" height=1 width=5 border=0></td>
					<td><input type=button name="doSubmit2" value=" Save & Close " onClick="javascript: void(0); doCommit();"></td>
				</tr>
			</table>
		</td>
		<td><img src="./../images/spacer.gif" height=1 width=5 border=0></td>
	</tr>
	<tr><td colspan=2><img src="../images/spacer.gif" height=5 border=0></td></tr>
	</form>
</table>

</body>
</html>
