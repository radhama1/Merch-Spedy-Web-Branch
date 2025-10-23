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
Dim Security
Set Security = New cls_Security
Security.Initialize Session.Value("UserID"), "ADMIN.SPEDY", checkQueryID(Request("tid"), 0)

Dim objConn, objCmd, SQLStr, connStr, i, rowcolor
Dim batchID, taxUDA, taxValueUDA



%>
<html>
<head>
	<title>TESTING :: Set Tax Wizard Data</title>
	<style type="text/css">
		A {text-decoration: none; cursor: hand;}
		A:HOVER {text-decoration: underline; cursor: hand;}
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
			font-family: Arial, Verdana, Geneva, Helvetica;
			font-size: 11px;
		}

		.bodyText
		{
			font-family: Arial, Helvetica, Sans-Serif;
			font-size: 12px;
			line-height: 18px;
			color: #000;
		}
	</style>
	<script language="javascript" type="text/javascript" src="./../../app_include/global.js"></script>
	<script language=javascript>
		var isMac = (navigator.appVersion.indexOf("Mac")!=-1) ? true : false;
		
		function validateForm()
		{
			var msg = '';
			
			//Check Batch_ID
			if (document.theForm.Batch_ID.value == "")
			{
				if(document.getElementById("BatchIDWarningImg")) document.getElementById("BatchIDWarningImg").src = "./../images/alert_icon_small.gif";
				if(msg != '')msg += '\n'; msg += "You did not specify a Batch ID.";
			} else {
				if (!IsPosNumber(document.theForm.Batch_ID.value))
				{
					if(document.getElementById("BatchIDWarningImg")) document.getElementById("BatchIDWarningImg").src = "./../images/alert_icon_small.gif";
					if(msg != '')msg += '\n'; msg += "You did not enter a valid numeric value for Batch ID.";
				}
			}
			
			//Check Tax_UDA
			if (document.theForm.Tax_UDA.value == "")
			{
				if(document.getElementById("TaxUDAWarningImg")) document.getElementById("TaxUDAWarningImg").src = "./../images/alert_icon_small.gif";
				if(msg != '')msg += '\n'; msg += "You did not specify a Tax UDA.";
			} else {
				if (!IsPosNumber(document.theForm.Tax_UDA.value))
				{
					if(document.getElementById("TaxUDAWarningImg")) document.getElementById("TaxUDAWarningImg").src = "./../images/alert_icon_small.gif";
					if(msg != '')msg += '\n'; msg += "You did not enter a valid numeric value for Tax UDA.";
				}
			}
			
			//Check Tax_UDA_Value
			if (document.theForm.Tax_UDA_Value.value == "")
			{
				if(document.getElementById("TaxUDAValueWarningImg")) document.getElementById("TaxUDAValueWarningImg").src = "./../images/alert_icon_small.gif";
				if(msg != '')msg += '\n'; msg += "You did not specify a Tax Value UDA.";
			} else {
				if (!IsPosNumber(document.theForm.Tax_UDA_Value.value))
				{
					if(document.getElementById("TaxUDAValueWarningImg")) document.getElementById("TaxUDAValueWarningImg").src = "./../images/alert_icon_small.gif";
					if(msg != '')msg += '\n'; msg += "You did not enter a valid numeric value for Tax Value UDA.";
				}
			}
			
			if (msg != ''){
				alert(msg);
				return false;
			}
			
			if(document.getElementById("BatchIDWarningImg"))document.getElementById("BatchIDWarningImg").src = "./../images/spacer.gif";
			if(document.getElementById("TaxUDAWarningImg"))document.getElementById("TaxUDAWarningImg").src = "./../images/spacer.gif";
			if(document.getElementById("TaxUDAValueWarningImg"))document.getElementById("TaxUDAValueWarningImg").src = "./../images/spacer.gif";
			
			document.theForm.submit();
		}
		
	</script>
</head>
<body bgcolor="cccccc" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0 >
<%
If Request.Form("submitForm") = "1" Then
    Set objConn = Server.CreateObject("ADODB.Connection")
    Set objCmd = Server.CreateObject("ADODB.Command")
    connStr = Application.Value("connStr")
    objConn.Open connStr
    
    SQLStr = "sp_SPEDY_TaxWizard_UpdateBatch"
    objCmd.ActiveConnection = objConn
    objCmd.CommandText = SQLStr
    objCmd.CommandType = adCmdStoredProc
    objCmd.Parameters.Append objCmd.CreateParameter("@batchID", adBigInt, adParamInput, , SmartValues(Request.Form("Batch_ID"), "CLng"))
    objCmd.Parameters.Append objCmd.CreateParameter("@taxUDA", adVarChar, adParamInput, 1, SmartValues(Request.Form("Tax_UDA"), "CStr"))
    objCmd.Parameters.Append objCmd.CreateParameter("@@taxValueUDA", adInteger, adParamInput, , SmartValues(Request.Form("Tax_UDA_Value"), "CInt"))
    objCmd.Execute
    
    Call DB_CleanUp
%>
<br />
<br />
<strong>Done!</strong>  &nbsp;<a href="set_tax_wizard_data.asp" >&lt;Reset&gt;</a>
<%
Else
%>
<form name="theForm" action="set_tax_wizard_data.asp" method="POST" onsubmit="return validateForm();">

<table width=100% cellpadding=0 cellspacing=0 border=0>

	<tr bgcolor="cccccc"><td colspan=2><img src="./../images/spacer.gif" height=5 border=0></td></tr>
	<tr bgcolor="cccccc">
		<td><img src="./../images/spacer.gif" height=300 width=1 border=0></td>
		<td width=100% valign=top>
			<%
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			'DESCRIPTION EDITING TAB
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			%>
			<div id="workspace_description" name="workspace_description">
				<table width=100% cellpadding=0 cellspacing=0 border=0>
					<tr>
						<td><img src="./../images/spacer.gif" height=1 width=20 border=0></td>
						<td nowrap=true width=100% valign=top>
							<table cellpadding=0 cellspacing=0 border=0>
							    <tr><td colspan=3><img src="./../images/spacer.gif" height=10 width=1 border=0></td></tr>
							    <tr><td colspan=3><strong>Set Tax Wizard Data</strong></td></tr>
								<tr><td colspan=3><img src="./../images/spacer.gif" height=20 width=1 border=0></td></tr>
								
								<tr>
									<td colspan=3 class="bodyText">
										<img src="./../images/spacer.gif" id="BatchIDWarningImg"><b>BatchID</b>
									</td>
								</tr>
								<tr><td colspan=3><input type="text" size=10 maxlength=8 style="width: 70px;" id="Batch_ID" name="Batch_ID" value="" AutoComplete="off"></td></tr>
								
								<tr><td colspan=3><img src="./../images/spacer.gif" height=10 width=1 border=0></td></tr>
								<tr>
									<td colspan=3 class="bodyText">
										<img src="./../images/spacer.gif" id="TaxUDAWarningImg"><b>Tax UDA</b>
									</td>
								</tr>
								<tr><td colspan=3><input type="text" size="10" maxlength="1" style="width: 50px;" id="Tax_UDA" name="Tax_UDA" value="" AutoComplete="off"></td></tr>
								
								<tr><td colspan=3><img src="./../images/spacer.gif" height=10 width=1 border=0></td></tr>
								<tr>
									<td colspan=3 class="bodyText">
										<img src="./../images/spacer.gif" id="TaxUDAValueWarningImg"><b>Tax UDA Value</b>
									</td>
								</tr>
								<tr><td colspan=3><input type="text" size=10 maxlength=5 style="width: 70px;" id="Tax_UDA_Value" name="Tax_UDA_Value" value="" AutoComplete="off"></td></tr>
								<tr><td colspan=3><img src="./../images/spacer.gif" height=10 width=1 border=0></td></tr>
                                <tr><td colspan=3><input type="submit" id="btnSubmit" value="Submit" /></td></tr>
								<tr><td colspan=3><img src="./../images/spacer.gif" height=10 width=1 border=0></td></tr>
							</table>
						</td>
						<td><img src="./../images/spacer.gif" height=1 width=20 border=0></td>
						
					</tr>
				</table>
			</div>
		</td>
	</tr>
	
</table>
<input type="hidden" id="submitForm" name="submitForm" value="1" />
</form>
<script language="javascript">
	<!--
		
	//-->
</script>
<%
End If
%>
</body>
</html>

<%

Sub DB_CleanUp
	if objConn.State <> adStateClosed then
		On Error Resume Next
		objConn.Close
	end if
	Set objCmd = Nothing
	Set objConn = Nothing
End Sub
%>