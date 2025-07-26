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
Security.Initialize Session.Value("UserID"), "ADMIN.SPEDY", checkQueryID(Request("id"), 0)

Dim itemID, boolIsNew
Dim winTitle
Dim objConn, objRec, SQLStr, connStr, i, rowcolor
Dim Exception_Name, Dept_Num, Class_Num, Sub_Class_Num, From_Stage_ID, Workflow_Direction, To_Stage_ID, isEnabled
Dim bFound

' defaults
Workflow_Direction = true

Dim rowCounter, curIteration
Dim arDetailsDataRows, dictDetailsDataCols

Set dictDetailsDataCols	= Server.CreateObject("Scripting.Dictionary")

itemID = checkQueryID(Request("id"), 0)

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")
connStr = Application.Value("connStr")
objConn.Open connStr

if itemID = 0 then
	boolIsNew = true
else
	boolIsNew = false

	Call returnDataWithGetRows(connStr, "sp_SPEDY_WorkflowException_GetRecord " & itemID, arDetailsDataRows, dictDetailsDataCols)
end if

%>
<html>
<head>
	<title><%if boolIsNew then%>Add Tax UDA<%else%>Edit Workflow Exception<%end if%></title>
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
	<script language="javascript" type="text/javascript" src="./../../app_include/prototype.js"></script>
	<script language="javascript" type="text/javascript" src="./exception_details.js"></script>
	<script language=javascript>
		var isMac = (navigator.appVersion.indexOf("Mac")!=-1) ? true : false;
		
		var processing_Img;
		var spacer_Img;
		preloadDetailImgs();
		function preloadDetailImgs()
		{
			if (document.images)
			{		
				processing_Img = new Image(16, 16);
				spacer_Img = new Image(16, 16);
				processing_Img.src = "./../images/processing_ccc.gif";
				spacer_Img.src = "./../../app_images/spacer.gif";
			}
		}

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
			//Check Exception_Name
			if (document.theForm.Exception_Name.value == "")
			{
				parent.frames['header'].clickMenu("descriptionTab");
				if(document.getElementById("Exception_Name_WarningImg")) document.getElementById("Exception_Name_WarningImg").src = "./../images/alert_icon_small.gif";
				msg += "You did not specify a Workflow Exception Name.";
			}
			
			
			//Check Stages
			if (document.theForm.From_Stage_ID.selectedIndex <= 0)
			{
				parent.frames['header'].clickMenu("descriptionTab");
				if(document.getElementById("From_Stage_ID_WarningImg")) document.getElementById("From_Stage_ID_WarningImg").src = "./../images/alert_icon_small.gif";
				if(msg != '') msg += '\n';
				msg += "You did not select a From Stage.";
			}
			if (document.theForm.To_Stage_ID.selectedIndex <= 0)
			{
				parent.frames['header'].clickMenu("descriptionTab");
				if(document.getElementById("To_Stage_ID_WarningImg")) document.getElementById("To_Stage_ID_WarningImg").src = "./../images/alert_icon_small.gif";
				if(msg != '') msg += '\n';
				msg += "You did not select a To Stage.";
			}
			if (document.theForm.From_Stage_ID.selectedIndex > 0 && document.theForm.To_Stage_ID.selectedIndex > 0)
			{
				// check if forward
				if(document.theForm.Workflow_Direction.selectedIndex == 1 && document.theForm.From_Stage_ID.selectedIndex > document.theForm.To_Stage_ID.selectedIndex)
				{
					parent.frames['header'].clickMenu("descriptionTab");
					if(document.getElementById("From_Stage_ID_WarningImg")) document.getElementById("From_Stage_ID_WarningImg").src = "./../images/alert_icon_small.gif";
					if(document.getElementById("To_Stage_ID_WarningImg")) document.getElementById("To_Stage_ID_WarningImg").src = "./../images/alert_icon_small.gif";
					if(msg != '') msg += '\n';
					msg += "To Stage must be greater than or equal to From Stage when moving forward.";
				}
				// check if forward
				if(document.theForm.Workflow_Direction.selectedIndex < 1 && document.theForm.From_Stage_ID.selectedIndex < document.theForm.To_Stage_ID.selectedIndex)
				{
					parent.frames['header'].clickMenu("descriptionTab");
					if(document.getElementById("From_Stage_ID_WarningImg")) document.getElementById("From_Stage_ID_WarningImg").src = "./../images/alert_icon_small.gif";
					if(document.getElementById("To_Stage_ID_WarningImg")) document.getElementById("To_Stage_ID_WarningImg").src = "./../images/alert_icon_small.gif";
					if(msg != '') msg += '\n';
					msg += "From Stage must be greater than or equal to To Stage when moving backward.";
				}
			}
			
			if (msg != ''){
				alert(msg);
				return false;
			}
			
			if(document.getElementById("Exception_Name_WarningImg"))document.getElementById("Exception_Name_WarningImg").src = "./../images/spacer.gif";
			if(document.getElementById("From_Stage_ID_WarningImg"))document.getElementById("From_Stage_ID_WarningImg").src = "./../images/spacer.gif";
			if(document.getElementById("To_Stage_ID_WarningImg"))document.getElementById("To_Stage_ID_WarningImg").src = "./../images/spacer.gif";
			
			document.theForm.submit();
		}
		
		function doLoad()
		{
		}
		
	</script>
</head>
<body bgcolor="cccccc" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0 onload="doLoad();">
<table width=100% cellpadding=0 cellspacing=0 border=0>
	<form name="theForm" action="exception_details_work.asp" method="POST">
	<tr bgcolor="cccccc"><td colspan=2><img src="./../images/spacer.gif" height=5 border=0></td></tr>
	<tr bgcolor="cccccc">
		<td><img src="./../images/spacer.gif" height=300 width=1 border=0></td>
		<td width=100% valign=top>
			<%
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			'DESCRIPTION EDITING TAB
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			if dictDetailsDataCols("ColCount") > 0 and dictDetailsDataCols("RecordCount") > 0 then
				Exception_Name = SmartValues(arDetailsDataRows(dictDetailsDataCols("Exception_Name"), 0), "CStr")
				Dept_Num = SmartValues(arDetailsDataRows(dictDetailsDataCols("Dept"), 0), "Integer")
				Class_Num = SmartValues(arDetailsDataRows(dictDetailsDataCols("Class"), 0), "Integer")
				Sub_Class_Num = SmartValues(arDetailsDataRows(dictDetailsDataCols("Sub_Class"), 0), "Integer")
				From_Stage_ID = SmartValues(arDetailsDataRows(dictDetailsDataCols("From_Stage_ID"), 0), "Integer")
				Workflow_Direction = SmartValues(arDetailsDataRows(dictDetailsDataCols("Workflow_Direction"), 0), "Boolean")
				To_Stage_ID = SmartValues(arDetailsDataRows(dictDetailsDataCols("To_Stage_ID"), 0), "Integer")
				'SortOrder = SmartValues(arDetailsDataRows(dictDetailsDataCols("SortOrder"), 0), "CStr")
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
										<img src="./../images/spacer.gif" id="Exception_Name_WarningImg"><b>Workflow Exception Name</b>
									</td>
								</tr>
								<tr><td colspan=3><input type="text" size="60" maxlength="100" style="width: 450px;" id="Exception_Name" name="Exception_Name" value="<%=Exception_Name%>" AutoComplete="off"></td></tr>
								
								<tr><td colspan=3><img src="./../images/spacer.gif" height=10 width=1 border=0></td></tr>
								
								<tr bgcolor=666666><td colspan="3"><img src="./../images/spacer.gif" height=1 width=1 border=0></td></tr>
								<tr bgcolor=ffffff><td colspan="3"><img src="./../images/spacer.gif" height=1 width=1 border=0></td></tr>
							
								<tr><td colspan=3><img src="./../images/spacer.gif" height=10 width=1 border=0></td></tr>
								
								<%
								SQLStr = "select [DEPT], (convert(varchar(20), convert(int, [DEPT])) + isnull(' - ' + [DEPT_NAME], '')) as DEPT_DISPLAY from SPD_Fineline_Dept"
								objRec.Open SQLStr, objConn, adOpenKeyset, adLockBatchOptimistic, adCmdText
								%>
								<tr>
									<td colspan=3 class="bodyText">
										<img src="./../images/spacer.gif" id="Dept_WarningImg"><b>Dept</b>
									</td>
								</tr>
								<tr>
								    <td colspan=3>
										<input type="hidden" id="Dept_Value" name="Dept_Value" value="<%if Dept_Num > 0 then Response.Write Dept_Num%>" />
								        <select id="Dept" name="Dept" onchange="onDeptChanged();">
											<option value="">-- select --</option>
											<%do while not objRec.EOF%>
											<option value="<%=objRec("DEPT")%>"<%if SmartValues(objRec("DEPT"), "Integer") = Dept_Num then Response.Write " selected=""selected"""%>><%=objRec("DEPT_DISPLAY")%></option>
												<%objRec.MoveNext%>
											<%loop%>
								        </select>
								        &nbsp;<img src="./../images/spacer.gif" id="Dept_ProcessingImg">
								    </td>
								</tr>
								<%
								objRec.Close
								%>
								
								<tr><td colspan=3><img src="./../images/spacer.gif" height=10 width=1 border=0></td></tr>

 -->								<%
								objRec.Open "select * From [SPD_Workflow_Stage] order by [sequence], [id]", objConn, adOpenKeyset, adLockBatchOptimistic, adCmdText
								%>
								
								<tr><td colspan=3><img src="./../images/spacer.gif" height=10 width=1 border=0></td></tr>
								
								<tr bgcolor=666666><td colspan="3"><img src="./../images/spacer.gif" height=1 width=1 border=0></td></tr>
								<tr bgcolor=ffffff><td colspan="3"><img src="./../images/spacer.gif" height=1 width=1 border=0></td></tr>
								
								<tr><td colspan=3><img src="./../images/spacer.gif" height=10 width=1 border=0></td></tr>
								
								<tr>
								    <td colspan=3 class="bodyText">
								        <table border="0" cellpadding="0" cellspacing="0">
								            <tr>
								                <td class="bodyText" valign="bottom">
										            <img src="./../images/spacer.gif" id="From_Stage_ID_WarningImg"><b>From Stage</b>
									            </td>
									            <td><img src="./../images/spacer.gif" height=1 width=15 border=0></td>
									            <td class="bodyText" valign="bottom">
										            <img src="./../images/spacer.gif" id="Workflow_Direction_WarningImg"><b>Workflow<br />Direction</b>
									            </td>
									            <td><img src="./../images/spacer.gif" height=1 width=15 border=0></td>
									            <td class="bodyText" valign="bottom">
										            <img src="./../images/spacer.gif" id="To_Stage_ID_WarningImg"><b>To Stage</b>
									            </td>
								            </tr>
								            <tr>
								                <td>
								                    <select id="From_Stage_ID" name="From_Stage_ID">
								                    <option value="">-- select --</option>
								                    <%do while Not objRec.EOF%>
								                    <option value="<%=objRec("id")%>"<%if SmartValues(objRec("id"), "Integer") = From_Stage_ID then Response.Write " selected=""selected"""%>><%=objRec("stage_name")%></option>
								                        <%objRec.MoveNext%>
								                    <%loop%>
								                    </select>
								                </td>
								                <td><img src="./../images/spacer.gif" height=1 width=15 border=0></td>
								                <td>
							                        <select id="Workflow_Direction" name="Workflow_Direction">
							                            <option value="0"<%if Workflow_Direction = false then Response.Write " selected=""selected"""%>>back</option>
							                            <option value="1"<%if Workflow_Direction = true then Response.Write " selected=""selected"""%>>forward</option>
							                        </select>
							                    </td>
							                    <% objRec.MoveFirst %>
							                    <td><img src="./../images/spacer.gif" height=1 width=15 border=0></td>
							                    <td>
								                    <select id="To_Stage_ID" name="To_Stage_ID">
								                    <option value="">-- select --</option>
								                    <%do while Not objRec.EOF%>
								                    <option value="<%=objRec("id")%>"<%if SmartValues(objRec("id"), "Integer") = To_Stage_ID then Response.Write " selected=""selected"""%>><%=objRec("stage_name")%></option>
								                        <%objRec.MoveNext%>
								                    <%loop%>
								                    </select>
								                </td>
								            </tr>
								        </table>
								    </td>
								</tr>
								<%
								objRec.Close
								%>
								
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
	<input type=hidden name="id" value="<%=itemID%>" />
	<input type=hidden name="boolIsNew" value="<%=boolIsNew%>">

	</form>
</table>
<script language="javascript">
	<!--
		parent.frames["header"].document.location = "exception_details_header.asp?id=<%=itemID%>";
		parent.frames["controls"].document.location = "exception_details_footer.asp?id=<%=itemID%>";
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