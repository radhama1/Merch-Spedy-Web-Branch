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
Security.Initialize Session.Value("UserID"), "ADMIN.SPEDY", checkQueryID(Request("fid"), 0)

Dim recordID, fieldID, boolIsNew
Dim winTitle
Dim objConn, objRec, SQLStr, connStr, i, rowcolor
Dim thisUserID
thisUserID = SmartValues(Session.Value("UserID"), "Integer")
Dim Record_Type, Field_Name, Field_Type, Field_Limit, Field_Limit_Str, Grid, isEnabled


Dim rowCounter, curIteration
Dim arDetailsDataRows, dictDetailsDataCols

Set dictDetailsDataCols	= Server.CreateObject("Scripting.Dictionary")

recordID = checkQueryID(Request("tid"), 0)
fieldID = checkQueryID(Request("fid"), 0)
' response.Write(recordID & "   " & fieldID & "<br />")

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")
connStr = Application.Value("connStr")
objConn.Open connStr


Dim recordTypeID, gridViewEnabled
recordTypeID = 0
gridViewEnabled = false
if recordID > 0 then
	SQLStr = "sp_CustomFields_Records_GetRecord " & recordID
	objRec.Open SQLStr, objConn, adOpenStatic, adLockReadOnly, adCmdText
	if not objRec.EOF then
	    recordTypeID = SmartValues(objRec("Record_Type_ID"), "Integer")
	    gridViewEnabled = SmartValues(objRec("Grid_View_Enabled"), "Boolean")
	end if
	objRec.Close
end if


if fieldID = 0 then
	boolIsNew = true
else
	boolIsNew = false

	Call returnDataWithGetRows(connStr, "SELECT * FROM Custom_Fields WHERE [ID] = " & fieldID, arDetailsDataRows, dictDetailsDataCols)
end if

%>
<html>
<head>
	<title><%if boolIsNew then%>Add Field<%else%>Edit Field<%end if%></title>
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
			//Check Category Name
			if (document.theForm.Field_Name.value == "")
			{
				parent.frames['header'].clickMenu("descriptionTab");
				if(document.getElementById("FieldNameWarningImg")) document.getElementById("FieldNameWarningImg").src = "./../images/alert_icon_small.gif";
				alert("You did not specify a field name.");
				return false;
			}
			if(document.getElementById("FieldNameWarningImg"))document.getElementById("FieldNameWarningImg").src = "./../images/spacer.gif";
			
			document.theForm.submit();
		}
		
		function doLoad()
		{
		}
		
	</script>
</head>
<body bgcolor="cccccc" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0 onload="doLoad();">
<table width=100% cellpadding=0 cellspacing=0 border=0>
	<form name="theForm" action="field_details_work.asp" method="POST">
	<tr bgcolor="cccccc"><td colspan=2><img src="./../images/spacer.gif" height=5 border=0></td></tr>
	<tr bgcolor="cccccc">
		<td><img src="./../images/spacer.gif" height=300 width=1 border=0></td>
		<td width=100% valign=top>
			<%
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			'DESCRIPTION EDITING TAB
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			if dictDetailsDataCols("ColCount") > 0 and dictDetailsDataCols("RecordCount") > 0 then
				Record_Type = SmartValues(arDetailsDataRows(dictDetailsDataCols("Record_Type"), 0), "Integer")
				Field_Name = SmartValues(arDetailsDataRows(dictDetailsDataCols("Field_Name"), 0), "String")
				Field_Type = SmartValues(arDetailsDataRows(dictDetailsDataCols("Field_Type"), 0), "Integer")
				if Field_Type <= 0 then
				    Field_Type = 9
				end if
				Field_Limit = SmartValues(arDetailsDataRows(dictDetailsDataCols("Field_Limit"), 0), "Integer")
				if Field_Limit <= 0 then
				    Field_Limit_Str = ""
				else
				    Field_Limit_Str = "" & Field_Limit
				end if
				Grid = SmartValues(arDetailsDataRows(dictDetailsDataCols("Grid"), 0), "Boolean")
			else
			    Field_Type = 9
			    Field_Limit_Str = ""
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
										<img src="./../images/spacer.gif" id="FieldNameWarningImg"><b>Field Name</b>
									</td>
								</tr>
								<tr><td colspan=3><input type="text" size="40" maxlength="100" style="width: 250px;" id="Field_Name" name="Field_Name" value="<%=Field_Name%>" AutoComplete="off"></td></tr>
								<tr><td colspan=3><img src="./../images/spacer.gif" height=10 width=1 border=0></td></tr>
								
								<tr>
									<td colspan=3 class="bodyText">
										<img src="./../images/spacer.gif" id="FieldTypeWarningImg"><b>Field Type</b>
									</td>
								</tr>
								<tr><td colspan=3>
								    <select id="Field_Type" name="Field_Type">
								        <option value="1"<% if Field_Type = 1 then Response.Write " selected=""selected""" %>>BOOLEAN</option>
								        <option value="2"<% if Field_Type = 2 then Response.Write " selected=""selected""" %>>DATE</option>
								        <!--<option value="3"<% if Field_Type = 3 then Response.Write " selected=""selected""" %>>DATE/TIME</option>-->
								        <option value="4"<% if Field_Type = 4 then Response.Write " selected=""selected""" %>>DECIMAL</option>
								        <option value="5"<% if Field_Type = 5 then Response.Write " selected=""selected""" %>>INTEGER</option>
								        <option value="6"<% if Field_Type = 6 then Response.Write " selected=""selected""" %>>LONG</option>
								        <option value="7"<% if Field_Type = 7 then Response.Write " selected=""selected""" %>>MONEY</option>
								        <option value="8"<% if Field_Type = 8 then Response.Write " selected=""selected""" %>>PERCENT</option>
								        <option value="9"<% if Field_Type = 9 then Response.Write " selected=""selected""" %>>STRING</option>
								        <option value="10"<% if Field_Type = 10 then Response.Write " selected=""selected""" %>>TEXT</option>
								        <!--<option value="11"<% if Field_Type = 11 then Response.Write " selected=""selected""" %>>TIME</option>-->
								    </select>
								</td></tr>
								<tr><td colspan=3><img src="./../images/spacer.gif" height=10 width=1 border=0></td></tr>
								
								<tr>
									<td colspan=3 class="bodyText">
										<img src="./../images/spacer.gif" id="FieldLimitWarningImg"><b>Field Limit</b>
									</td>
								</tr>
								<tr><td colspan=3><input type="text" size="4" maxlength="4" id="Field_Limit" name="Field_Limit" value="<%=Field_Limit_Str%>" AutoComplete="off"></td></tr>
								<tr><td colspan=3><img src="./../images/spacer.gif" height=10 width=1 border=0></td></tr>
								
								<% if gridViewEnabled = true then %>
								<tr>
									<td colspan=3 class="bodyText">
										<img src="./../images/spacer.gif" id="GridWarningImg"><b>Show In Grid?</b>
									</td>
								</tr>
								<tr><td colspan=3><input type="checkbox" id="Grid" name="Grid" AutoComplete="off" value="1" <% if Grid = true then Response.Write " checked=""checked""" end if  %> /></td></tr>
								<tr><td colspan=3><img src="./../images/spacer.gif" height=10 width=1 border=0></td></tr>
								<% else %>
								<tr><td colspan="3"><input type="hidden" id="Grid" name="Grid" value="0" /></td></tr>
								<% end if %>
								
								<tr><td colspan=3><img src="./../images/spacer.gif" height=10 width=1 border=0></td></tr>
							</table>
						</td>
						<td><img src="./../images/spacer.gif" height=1 width=20 border=0></td>
					</tr>
				</table>
			</div>
		</td>
	</tr>
	<input type="hidden" name="tid" value="<%=recordID%>" />
	<input type="hidden" name="recordType" value="<%=recordTypeID%>" />
	<input type="hidden" name="fid" value="<%=fieldID%>">
	<input type="hidden" name="boolIsNew" value="<%=boolIsNew%>">

	</form>
</table>
<script language="javascript">
	<!--
		parent.frames["header"].document.location = "field_details_header.asp?tid=<%=recordID%>&fid=<%=fieldID%>";
		parent.frames["controls"].document.location = "field_details_footer.asp?tid=<%=recordID%>&fid=<%=fieldID%>";
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