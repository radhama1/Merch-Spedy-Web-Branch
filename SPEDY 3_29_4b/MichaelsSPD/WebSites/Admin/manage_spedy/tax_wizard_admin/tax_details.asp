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

Dim taxID, boolIsNew
Dim winTitle
Dim objConn, objRec, SQLStr, connStr, i, rowcolor
Dim Tax_UDA_Number, Tax_UDA_Description, isEnabled

Dim rowCounter, curIteration
Dim arDetailsDataRows, dictDetailsDataCols

Set dictDetailsDataCols	= Server.CreateObject("Scripting.Dictionary")

taxID = checkQueryID(Request("tid"), 0)

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")
connStr = Application.Value("connStr")
objConn.Open connStr

if taxID = 0 then
	boolIsNew = true
else
	boolIsNew = false

	Call returnDataWithGetRows(connStr, "SELECT * FROM SPD_Tax_UDA WHERE [ID] = " & taxID, arDetailsDataRows, dictDetailsDataCols)
end if

%>
<html>
<head>
	<title><%if boolIsNew then%>Add Tax UDA<%else%>Edit Tax UDA<%end if%></title>
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

		function initTabs(thisTabName)
		{
			clearMenus();
			switch (thisTabName)
			{
				case "descriptionTab":
					workspace_description.style.display = "";
					break;
			}
		}
	
		function clickMenu(tabName)
		{
			clearMenus();

			switch (tabName)
			{
				case "descriptionTab":
					workspace_description.style.display = "";
					break;
				
				default:
					clearMenus();
					break;
			}
		}
		
		function clearMenus()
		{
			workspace_description.style.display = "none";
		}
				
		//called when the Calendar icon is clicked
		function dateWin(field)
		{ 
			hwnd = window.open('../../app_include/popup_calendar.asp?f=' + escape(field), 'winCalendar', 'width=150,height=150,toolbar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=0,resizable=0');
			hwnd.focus();
		}
		
		function validateForm()
		{
			var msg = '';
			//Check Tax_UDA_Number
			if (document.theForm.Tax_UDA_Number.value == "")
			{
				parent.frames['header'].clickMenu("descriptionTab");
				if(document.getElementById("TaxUDAWarningImg")) document.getElementById("TaxUDAWarningImg").src = "./../images/alert_icon_small.gif";
				msg += "You did not specify a Tax UDA.";
			} else {
				if (!IsPosNumber(document.theForm.Tax_UDA_Number.value))
				{
					parent.frames['header'].clickMenu("descriptionTab");
					if(document.getElementById("TaxUDAWarningImg")) document.getElementById("TaxUDAWarningImg").src = "./../images/alert_icon_small.gif";
					msg += "You did not enter a valid numeric value for Tax UDA.";
				}
			}
			
			
			//Check Tax_UDA_Description
			if (document.theForm.Tax_UDA_Description.value == "")
			{
				parent.frames['header'].clickMenu("descriptionTab");
				if(document.getElementById("TaxUDADescriptionWarningImg")) document.getElementById("TaxUDADescriptionWarningImg").src = "./../images/alert_icon_small.gif";
				if(msg != '') msg += '\n';
				msg += "You did not specify a Tax UDA Description.";
			}
			
			if (msg != ''){
				alert(msg);
				return false;
			}
			
			if(document.getElementById("TaxUDAWarningImg"))document.getElementById("TaxUDAWarningImg").src = "./../images/spacer.gif";
			if(document.getElementById("TaxUDADescriptionWarningImg"))document.getElementById("TaxUDADescriptionWarningImg").src = "./../images/spacer.gif";
			
			document.theForm.submit();
		}
		
	</script>
</head>
<body bgcolor="cccccc" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0 onload="doLoad();">
<table width=100% cellpadding=0 cellspacing=0 border=0>
	<form name="theForm" action="tax_details_work.asp" method="POST">
	<tr bgcolor="cccccc"><td colspan=2><img src="./../images/spacer.gif" height=5 border=0></td></tr>
	<tr bgcolor="cccccc">
		<td><img src="./../images/spacer.gif" height=300 width=1 border=0></td>
		<td width=100% valign=top>
			<%
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			'DESCRIPTION EDITING TAB
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			if dictDetailsDataCols("ColCount") > 0 and dictDetailsDataCols("RecordCount") > 0 then
				Tax_UDA_Number = SmartValues(arDetailsDataRows(dictDetailsDataCols("Tax_UDA_Number"), 0), "CStr")
				Tax_UDA_Description = SmartValues(arDetailsDataRows(dictDetailsDataCols("Tax_UDA_Description"), 0), "CStr")
			end if
			%>
			<div id="workspace_description" name="workspace_description" style="display:none">
				<table width=100% cellpadding=0 cellspacing=0 border=0>
					<tr>
						<td><img src="./../images/spacer.gif" height=1 width=20 border=0></td>
						<td nowrap=true width=100% valign=top>
							<table cellpadding=0 cellspacing=0 border=0>
								<tr><td colspan=3><img src="./../images/spacer.gif" height=10 width=1 border=0></td></tr>
								<tr>
									<td colspan=3 class="bodyText">
										<img src="./../images/spacer.gif" id="TaxUDAWarningImg"><b>Tax UDA</b>
									</td>
								</tr>
								<tr><td colspan=3><input type="text" size="10" maxlength="1" style="width: 50px;" id="Tax_UDA_Number" name="Tax_UDA_Number" value="<%=Tax_UDA_Number%>" AutoComplete="off"></td></tr>
								<tr><td colspan=3><img src="./../images/spacer.gif" height=10 width=1 border=0></td></tr>
								
								<tr>
									<td colspan=3 class="bodyText">
										<img src="./../images/spacer.gif" id="TaxUDADescriptionWarningImg"><b>Tax UDA Description</b>
									</td>
								</tr>
								<tr><td colspan=3><input type="text" size=60 maxlength=200 style="width: 450px;" id="Tax_UDA_Description" name="Tax_UDA_Description" value="<%=Tax_UDA_Description%>" AutoComplete="off"></td></tr>
								<tr><td colspan=3><img src="./../images/spacer.gif" height=10 width=1 border=0></td></tr>

								<tr><td colspan=3><img src="./../images/spacer.gif" height=10 width=1 border=0></td></tr>
							</table>
						</td>
						<td><img src="./../images/spacer.gif" height=1 width=20 border=0></td>
					</tr>
				</table>
			</div>
		</td>
	</tr>
	<input type=hidden name="tid" value="<%=taxID%>" />
	<input type=hidden name="boolIsNew" value="<%=boolIsNew%>">

	</form>
</table>
<script language="javascript">
	<!--
		parent.frames["header"].document.location = "tax_details_header.asp?tid=<%=taxID%>";
		parent.frames["controls"].document.location = "tax_details_footer.asp?tid=<%=taxID%>";
	//-->
</script>

</body>
</html>

<%
Call DB_CleanUp
Sub DB_CleanUp
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

Set arDetailsDataRows = Nothing
Set dictDetailsDataCols = Nothing
%>