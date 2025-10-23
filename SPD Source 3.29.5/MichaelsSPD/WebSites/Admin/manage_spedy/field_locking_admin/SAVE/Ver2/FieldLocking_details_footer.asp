<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441
%>
<!--#include file="./../../app_include/_globalInclude.asp"-->
<%

'Dim boolIsNew
'Dim recordID
'Dim fieldID
'Dim objConn, objRec, SQLStr, connStr

'recordID = checkQueryID(Request("tid"), 0)
'fieldID = checkQueryID(Request("fid"), 0)

'boolIsNew = false
'if fieldID = 0 then
'	boolIsNew = true
'end if
%>
<html>
<head>
	<title></title>
	<style type="text/css">
	<!--
		A {text-decoration: none;}
	//-->
	</style>
	<script language="javascript" type="text/javascript">
	<!--
	    function doCancel() {
		    if ( parent.frames['body'].bDirty ) {
			    if (!confirm("Really discard your changes?"))
				   return false;
			}
			parent.window.close();
		}

		function doCommit(i) {   // i=0 Save and Exit, i=1 Save only
		    parent.frames['body'].validateForm(i);
		}
		
		function EnableSaves() {
            document.theForm.doSubmit1.disabled=false;
            document.theForm.doSubmit2.disabled=false;
		    return true;
		}

	//-->
	</script>
</head>
<body bgcolor="cccccc" link=0000ff vlink=0000ff topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>
<form name=theForm action="" method=POST>
    <table width=100% cellpadding=0 cellspacing=0 border=0 align=center>
	<tr><td colspan=3><img src="./../images/spacer.gif" height=3 width=1 border=0></td></tr>
	<tr>
		<td><img src="./../images/spacer.gif" height=1 width=5 border=0></td>
		<td>
			<table width=100% cellpadding=0 cellspacing=0 border=0>
				<tr>
					<td width=100%><img src="./../images/spacer.gif" height=1 width=40 border=0></td>
					<td><input type=button name="btnCancel" id="btnCancel" value="Cancel" onClick="javascript: void(0); doCancel();"></td>
					<td><img src="./../images/spacer.gif" height=1 width=5 border=0></td>
					<td><input type=button name="doSubmit1" id="doSubmit1" disabled="disabled" value=" Save " onClick="javascript: void(0); doCommit('1');"></td>
					<td><img src="./../images/spacer.gif" height=1 width=5 border=0></td>
					<td><input type=button name="doSubmit2" id="doSubmit2" disabled="disabled" value=" Save & Close " onClick="javascript: void(0); doCommit('0');"></td>
				</tr>
			</table>
		</td>
		<td><img src="./../images/spacer.gif" height=1 width=5 border=0></td>
	</tr>
	<tr><td colspan=2><img src="../images/spacer.gif" height=5 border=0></td></tr>
    </table>
</form>

</body>
</html>
