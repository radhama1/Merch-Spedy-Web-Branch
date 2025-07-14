<%@ LANGUAGE=VBSCRIPT%>
<%
Option Explicit
Response.Buffer = True
Response.Expires = -1441
%>
<!--#include file="./../../app_include/SmartValues.asp"-->
<!--#include file="./../../app_include/checkQueryID.asp"-->
<%
Dim objConn, objRec, SQLStr, connStr, objCmd, objParam

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")
Set objCmd = Server.CreateObject("ADODB.Command")
connStr = Application.Value("connStr")
objConn.Open connStr
%>
<html>
<head>
	<title>Modify Order Status</title>
	<style type="text/css">
		A {text-decoration: none; color: #000000; cursor: hand;}
		A:HOVER {text-decoration: none; color: #000000; cursor: hand;}
		BODY
		{
			scrollbar-face-color: "#cccccc"; 
			scrollbar-highlight-color: "#ffffff"; 
			scrollbar-shadow: "#999999";
			scrollbar-3dlight-color: "#cccccc"; 
			scrollbar-arrow-color: "#000000";
			scrollbar-track-color: "#ececec";
			scrollbar-darkshadow-color: "#000000";
			cursor: default;
			padding: 10px;
		}

		INPUT * {font-family:Arial, Helvetica; font-size:12px; color:#000;}
		SELECT {font-family:Arial, Helvetica; font-size:12px; color:#000;}
		TEXTAREA {font-family:Arial, Helvetica; font-size:12px; color:#000;}

		.headerText
		{
			font-family: Arial, Helvetica, Sans-Serif;
			font-size: 18px;
			color: #999;
		}

		.subheaderText
		{
			font-family: Arial, Helvetica, Sans-Serif;
			font-size: 14px;
			color: #666;
		}

		.bodyText
		{
			font-family: Arial, Helvetica, Sans-Serif;
			font-size: 12px;
			color: #000;
		}

	</style>
	<script language="javascript" type="text/javascript" src="../../app_include/global.js"></script>
	<script language="javascript" type="text/javascript">

		function openNewOrderWindow(url)
		{
			statusWin = window.open(url, "_blank", "width=800,height=600,toolbar=1,location=1,directories=0,status=1,menuBar=0,scrollBars=1,resizable=1");
			statusWin.focus();
		}
		
		function goToURL()
		{
			var checkedValue = "";
			for (var i = 0; i < document.theForm.chkChosenStore.length; i++)
			{
				if (document.theForm.chkChosenStore[i].checked == true) checkedValue = document.theForm.chkChosenStore[i].value;
			}
		//	alert(checkedValue);
			
			if (checkedValue != "")
			{
				openNewOrderWindow(checkedValue + "?g=<%=Session.Value("User_GUID")%>");
				self.close();
			}
		}
	</script>
</head>
<body bgcolor="cccccc" style="padding: 10px; margin: 0;">

<form id="theForm" name="theForm" action="order_status.asp" method="POST" onsubmit="return checkForm();" style="padding: 0; margin: 0;">
<div style="background: #ececec; padding: 10px; border: 1px solid #666;">
	<div class="subheaderText" style="margin-bottom: 10px;"><b>Choose a Store</b></div>
	<%
	SQLStr = "SELECT * FROM Shopping_Store ORDER BY Store_Name"
	objRec.Open SQLStr, objConn, adOpenKeyset, adLockReadOnly, adCmdText
	if not objRec.EOF then
		Do until objRec.EOF
	%>
	<div class="bodyText"><input type="radio" name="chkChosenStore" id="chkChosenStore_<%=objRec("ID")%>" value="<%=objRec("Store_URL")%>">&nbsp;&nbsp;<label for="chkChosenStore_<%=objRec("ID")%>"><%=objRec("Store_Name")%></label></div>
	<%
			objRec.MoveNext
		Loop
	end if
	objRec.Close
	%>
	<div style="margin-top: 20px;">
		<table cellpadding=0 cellspacing=0 border=0>
			<tr width="100%">
				<td><input type=button name="doCancel" value=" Cancel " onClick="self.close();"></td>
				<td width=100%><img src="../images/spacer.gif" height=1 width=5 border=0></td>
				<td><input type=button name="doSubmit" value=" Go " onclick="goToURL();"></td>
			</tr>
		</table>
	</div>
</div>
</form>

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