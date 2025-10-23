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

Dim boolIsNewWebsite
Dim websiteID
Dim objConn, objRec, SQLStr, connStr

websiteID = Request("wid")
if IsNumeric(websiteID) then
	websiteID = CInt(websiteID)
else
	websiteID = 0
end if

boolIsNewWebsite = false
if websiteID = 0 then
	boolIsNewWebsite = true
end if

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")
connStr = Application.Value("connStr")
objConn.Open connStr
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
			parent.frames['body'].document.theForm.submit();
		}
		
		function reloadParentFrame()
		{
			//Set a reference to the Details frame in the Repository frameset...
			var myFrameSetRef = new Object(parent.window.opener.parent.parent.frames['DetailFrameWrapper'].frames['DetailFrame']);
	
			//If the user hasnt left the repository framset, then refresh the details screen, otherwise dont worry bout it...
			if (typeof(myFrameSetRef == 'object'))
			{
				myFrameSetRef.document.location.reload();
			}
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
<%
Call DB_CleanUp

Sub DB_CleanUp
	'---- ObjectStateEnum Values ----
'	Const adStateClosed = &H00000000
'	Const adStateOpen = &H00000001
'	Const adStateConnecting = &H00000002
'	Const adStateExecuting = &H00000004
'	Const adStateFetching = &H00000008

	if objRec.State <> adStateClosed then
		On Error Resume Next
		objRec.Close
	end if
	if objConn.State <> adStateClosed then
		On Error Resume Next
		objConn.Close
	end if
	Set objRec = Nothing
	Set objConn = Nothing
End Sub

%>