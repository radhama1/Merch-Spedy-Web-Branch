<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441 
%>
<!--#include file="./../app_include/_globalInclude.asp"-->
<!--#include file="./../app_include/getfile_icon_name.asp"-->
<!--#include file="./../app_include/InitRelativeFolder.asp"-->
<%
Dim objConn, objRec, SQLStr, connStr, i
Dim rowcolor, strToolTip
Dim outputToExcel, querystring, Filter_ID, bolSaveSearch
Dim enumerateUserGroup, enumerateUserRole, selectedGroupID
Dim SortColumn, SortDirection, xmlSearchCriteria, xmlString
Dim numFound, startRow, pageSize, curPage, pageCount, totRecords
Dim numFilterParamsWrittenSoFar, numSortParamsWrittenSoFar

'Initialize Variables
numFilterParamsWrittenSoFar = 0
numSortParamsWrittenSoFar = 0

'Paging
pageCount = checkQueryID(Trim(Request("pageCount")), 1)
pageSize = checkQueryID(Trim(Request("pageSize")), 0)
if pageSize > 0 then
	Session.Value("pageSize") = pageSize
else
	if IsNumeric(Session.Value("pageSize")) and Trim(Session.Value("pageSize")) <> "" then
		pageSize = CInt(Session.Value("pageSize"))
	else
		pageSize = 50
		Session.Value("pageSize") = pageSize
	end if
end if
curPage = checkQueryID(Trim(Request("curPage")), 1)
startRow = ((curPage-1) * pageSize) + 1

'Enum User Role/Group
enumerateUserGroup = Request("enumgroup")
if IsNumeric(enumerateUserGroup) then
	enumerateUserGroup = CBool(enumerateUserGroup)
else
	enumerateUserGroup = CBool(0)
end if

enumerateUserRole = Request("enumrole")
if IsNumeric(enumerateUserRole) then
	enumerateUserRole = CBool(enumerateUserRole)
else
	enumerateUserRole = CBool(0)
end if

'Selected Group
selectedGroupID = Request("sgid")
if IsNumeric(selectedGroupID) then
	selectedGroupID = CInt(selectedGroupID)
else
	selectedGroupID = 0
end if

'Save Search?
if Len(Trim(SmartValues(Request("Save_Search_Name"), "CStr"))) > 0 then
	bolSaveSearch = true
	Filter_ID = SaveSearch(0, "ADMIN.SECURITY", Trim(SmartValues(Request("Save_Search_Name"), "CStr")))
else
	bolSaveSearch = false
	Filter_ID = 0
end if

'Get the Sort Column
SortColumn = Trim(Request("sort"))
if IsNumeric(SortColumn) and Trim(SortColumn) <> "" then
	SortColumn = CInt(SortColumn)
	Session.Value("Security_User_SortColumn") = SortColumn
else
	if IsNumeric(Session.Value("Security_User_SortColumn")) and Trim(Session.Value("Security_User_SortColumn")) <> "" then
		SortColumn = CInt(Session.Value("Security_User_SortColumn"))
	else
		SortColumn = 0
		Session.Value("Security_User_SortColumn") = SortColumn
	end if
end if

'Get the Sort Direction
SortDirection = Trim(Request("direction"))
if IsNumeric(SortDirection) and Trim(SortDirection) <> "" then
	SortDirection = CInt(SortDirection)
	Session.Value("Security_User_SortDirection") = SortDirection
else
	if IsNumeric(Session.Value("Security_User_SortDirection")) and Trim(Session.Value("Security_User_SortDirection")) <> "" then
		SortDirection = CInt(Session.Value("Security_User_SortDirection"))
	else
		SortDirection = 0
		Session.Value("Security_User_SortDirection") = SortDirection
	end if
end if

Session.Value("Allowed_Edit_List") = ""
Session.Value("Allowed_Publish_List") = ""
Session.Value("Picked_Topic") = ""

'Get the XML String
xmlSearchCriteria = GenerateXMLString()

'ALTER PROCEDURE sp_security_list_users_search
'  @xmlSortCriteria varchar(8000) = NULL,
'  @maxRows int = -1,
'  @startRow int = 0,
'  @printDebugMsgs bit = 0
SQLStr = "sp_security_list_users_search '" & xmlSearchCriteria & "', '" & pageSize & "', '" & startRow & "', 0"
'Response.Write Server.HTMLEncode(SQLStr) & "<br><br>" & vbCrLf & vbCrLf

'Output to Excel
outputToExcel = CBool(checkQueryID(Trim(Request("excel")), 0))
if outputToExcel then
	Call OutputToExcelDocument(SQLStr)
end if

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr
%>
<html>
<head>
	<title>View All Content</title>
	<style type="text/css">
	<!--
		A {text-decoration: none; color: #000000; cursor: hand;}
		A:HOVER {text-decoration: none; color: #0000ff; cursor: hand;}
		.rover * {background-color: #ffff99}
		.selectedRow * {background-color: #cccccc; color: #000000}
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
		}
		.bodyText
		{
			font-family: Arial, Helvetica, Sans-Serif;
			font-size: 11px;
			line-height: 18px;
			color: #000;
		}
  	//-->
	</style>
	<script language="javascript" src="../app_include/lockscroll.js"></script><!--locked headers code-->
	<link rel="stylesheet" href="../app_include/contextmenu.css" type="text/css" media="screen"><!--right click styles-->
	<script language="javascript" src="./include/security_user_details_contextmenu.js"></script><!--right click menu-->
	<script language=javascript>
	<!--
	
		window.defaultStatus = "Manage Security";
		preloadImgs();
		function preloadImgs()
		{
			if (document.images)
			{		
				taskIcon_ImgOn = new Image(16, 16);
				taskIcon_ImgOff = new Image(16, 16);

				taskIcon_ImgOn.src = "./../app_images/tasks_icon_on.gif";
				taskIcon_ImgOff.src = "./../app_images/tasks_icon_off.gif";
			}
		}
		
		function hTaskBtn(imgName, boolOn)
		{
			if (document.images) 
			{
				if (boolOn)
				{
					document.images[imgName].src = taskIcon_ImgOn.src;
				}
				else
				{
					document.images[imgName].src = taskIcon_ImgOff.src;
				}
			}
		}

		function checkMenuElement(checkValue, menuItemID)
		{
			if (checkValue == "1")
				document.getElementById(menuItemID).className = "menuItem";
			else
				document.getElementById(menuItemID).className = "menuItemDisabled";

		}
		
		function rowPermissions(allowEdit, allowRemove, allowCreate)
		{
			this.allowEdit = allowEdit;
			this.allowRemove = allowRemove;
			this.allowCreate = allowCreate;
		}

		var arRowPermissions = new Array();

		function configureOptions(RowID)
		{
			if (isNaN(RowID))
				return;
		
			if (!arRowPermissions[RowID])
				return;
				
			checkMenuElement(arRowPermissions[RowID].allowEdit, "ItemEdit");
			checkMenuElement(arRowPermissions[RowID].allowRemove, "ItemDelete");
			checkMenuElement(arRowPermissions[RowID].allowCreate, "ItemAdd");
		}

		function clickMenu()
		{
			el = event.srcElement;
			if (el.className == "menuItemDisabled") return;

			hideMenu();
			var selectedItemID = document.theForm.selectedItemID.value;
			// if (!arRowPermissions[selectedItemID]) return;
			
			switch (el.id)
			{
				case "ItemEdit":
					openItemEditorWindow(selectedItemID);
					break;
				case "ItemMove":
					openItemMoveWindow(selectedItemID);
					break;
				case "ItemDelete":
					deleteDocument(selectedItemID);
					break;
				case "ItemAdd":
					openItemEditorWindow(0);
					break;
				default:
					break;
			}
		}

		function openItemEditorWindow(RowID)
		{
			editWin = window.open("./security_user_admin/security_user_details_frm.asp?cid=" + RowID, "editWindow_" + RowID, "width=600,height=500,toolbar=0,location=0,directories=0,status=1,menuBar=0,scrollBars=1,resizable=0");
			editWin.focus();
		}

		function deleteDocument(RowID)
		{
			if (confirm("Really remove this user?"))
			{
				document.location = "./security_user_admin/security_user_remove.asp?cid=" + RowID + "&sort=<%=SortColumn%>&direction=<%=SortDirection%>";
			}
		}

		function launchNewWin(myLoc, myName, myWidth, myHeight)
		{
				var myFeatures = "directories=no,dependent=yes,width=" + myWidth + ",height=" + myHeight + ",hotkeys=no,location=no,menubar=no,resizable=yes,screenX=100,screenY=100,scrollbars=yes,titlebar=no,toolbar=no,status=no";
				var newWin = window.open(myLoc, myName, myFeatures);
		}
	//-->
	</script>
</head>
<body bgcolor="ffffff" topmargin=0 leftmargin=0 rightmargin=0 marginheight=0 marginwidth=0 onLoad="initPlaceLayers();" oncontextmenu="return false;">

<table width=100% cellpadding=0 cellspacing=0 border=0>
	<form name="theForm" action="boo.asp" method="POST">
	<input type="hidden" name="selectedItemID" value="0">
	<input type="hidden" name="hoveredItemID" value="0">
	<tr>
		<td width=100%>
			<%
			if enumerateUserGroup and selectedGroupID > 0 then
				SQLStr = "sp_security_list_users_by_group '" & selectedGroupID & "', " & SortColumn & ", " & SortDirection & ", " & pageSize & ", " & startRow
			elseif enumerateUserRole and selectedGroupID > 0 then
				SQLStr = "sp_security_list_users_by_group '" & selectedGroupID & "', " & SortColumn & ", " & SortDirection & ", " & pageSize & ", " & startRow
			else
				'SQLStr = "sp_security_list_users " & SortColumn & ", " & SortDirection & ", " & pageSize & ", " & startRow
			end if
			
			'response.write ("<div>" & Server.HTMLEncode(SQLStr)& "</div>")
			objRec.Open SQLStr, objConn, adOpenStatic, adLockReadOnly, adCmdText
			if not objRec.EOF then
				numFound = CInt(objRec("totRecords"))
				if pageSize < numFound then
					if pageSize > 0 then
						if numFound mod pageSize = 0 then
							pageCount = CInt(numFound/pageSize)
						else
							pageCount = Fix(numFound/pageSize) + 1
						end if
					end if
				else
					pageCount = 1
				end if
			%>
			<table cellpadding=0 cellspacing=0 onSelectStart="return false" width=100% border=0>
				<tr bgcolor=ffffff><td colspan=17><img src="./images/spacer.gif" height=2 width=1></td></tr>
			<%
					i = 0
					Do Until objRec.EOF
						if i mod 2 = 1 then				
							rowcolor = "f3f3f3"
						else
							rowcolor = "ffffff"
						end if 
			%>
				<%if i > 0 then%>
				<tr bgcolor=e6e6e6><td colspan=30><img src="./images/spacer.gif" height=1 width=1></td></tr>
				<%end if%>
				<tr bgcolor=<%=rowcolor%> id="datarow_<%=objRec("ID")%>" onMouseOver="HoverRow(<%=objRec("ID")%>);" onMouseOut="HoverRow(0);" onDblClick="highlightRow();" oncontextmenu="HoverRow(<%=objRec("ID")%>);SelectRow(<%=objRec("ID")%>);displayMenu(); return false;">
					<td><img src="./images/spacer.gif" height=1 width=6></td>
					<td valign=top nowrap>
						<font style="font-family:Arial, Helvetica;font-size:11px;<%if not CBool(objRec("Enabled")) then Response.Write "color:#999999" end if%>">
						<a href="javascript: openItemEditorWindow(<%=objRec("ID")%>); void(0);"><%if not IsNull(objRec("UserName")) then Response.Write Server.HTMLEncode(objRec("UserName")) end if%><%if not enumerateUserGroup then Response.Write "</a>" end if%>&nbsp;&nbsp;<%if not CBool(objRec("Enabled")) then Response.Write "[Disabled]" end if%>
						</font>
					</td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap>
						<font style="font-family:Arial, Helvetica;font-size:11px;<%if not CBool(objRec("Enabled")) then Response.Write "color:#999999" end if%>">
						<%if not IsNull(objRec("Last_Name")) then Response.Write Server.HTMLEncode(objRec("Last_Name")) end if%>
						</font>
					</td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap>
						<font style="font-family:Arial, Helvetica;font-size:11px;<%if not CBool(objRec("Enabled")) then Response.Write "color:#999999" end if%>">
						<%if not IsNull(objRec("First_Name")) then Response.Write Server.HTMLEncode(objRec("First_Name")) end if%>
						</font>
					</td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap>
						<font style="font-family:Arial, Helvetica;font-size:11px;<%if not CBool(objRec("Enabled")) then Response.Write "color:#999999" end if%>">
						<%if not IsNull(objRec("Organization")) then Response.Write Server.HTMLEncode(objRec("Organization")) end if%>
						</font>
					</td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap>
						<font style="font-family:Arial, Helvetica;font-size:11px;<%if not CBool(objRec("Enabled")) then Response.Write "color:#999999" end if%>">
						<%if not IsNull(objRec("Email_Address")) then Response.Write Server.HTMLEncode(objRec("Email_Address")) end if%>
						</font>
					</td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap>
						<font style="font-family:Arial, Helvetica;font-size:11px;<%if not CBool(objRec("Enabled")) then Response.Write "color:#999999" end if%>">
						<%if not IsNull(objRec("Department")) then Response.Write Server.HTMLEncode(objRec("Department")) end if%>
						</font>
					</td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap>
						<font style="font-family:Arial, Helvetica;font-size:11px;<%if not CBool(objRec("Enabled")) then Response.Write "color:#999999" end if%>">
						<%if not IsNull(objRec("Primary_Approver")) then if CBool(objRec("Primary_Approver")) then Response.Write Server.HTMLEncode("Yes") else Response.Write Server.HTMLEncode("No") end if else Response.Write Server.HTMLEncode("") end if%>
						</font>
					</td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap>
						<font style="font-family:Arial, Helvetica;font-size:11px;<%if not CBool(objRec("Enabled")) then Response.Write "color:#999999" end if%>">
						<%if not IsNull(objRec("Job_Title")) then Response.Write Server.HTMLEncode(objRec("Job_Title")) end if%>
						</font>
					</td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap>
						<font style="font-family:Arial, Helvetica;font-size:11px;<%if not CBool(objRec("Enabled")) then Response.Write "color:#999999" end if%>">
						<%if not IsNull(objRec("Office_Location")) then Response.Write Server.HTMLEncode(objRec("Office_Location")) end if%>
						</font>
					</td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap>
						<font style="font-family:Arial, Helvetica;font-size:11px;<%if not CBool(objRec("Enabled")) then Response.Write "color:#999999" end if%>">
						<%if not IsNull(objRec("Gender")) then Response.Write Server.HTMLEncode(objRec("Gender")) end if%>
						</font>
					</td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap>
						<font style="font-family:Arial, Helvetica;font-size:11px;">
						<%if not IsNull(objRec("Date_Last_Modified")) then Response.Write Server.HTMLEncode(objRec("Date_Last_Modified")) end if%>
						</font>
					</td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap>
						<font style="font-family:Arial, Helvetica;font-size:11px;">
						<%if not IsNull(objRec("Date_Created")) then Response.Write Server.HTMLEncode(objRec("Date_Created")) end if%>
						</font>
					</td>
					<td width=100%><img src="./images/spacer.gif" height=1 width=5></td>
				</tr>
			<%
					objRec.MoveNext
					i = i + 1
					Loop
			%>
				<tr style="visibility:none;">
					<td><img src="./images/spacer.gif" height=1 width=1></td>
					<td id="col_0_data"><img id="col_0_dataimg" src="./images/spacer.gif" height=1 width=100></td>
					<td><img src="./images/spacer.gif" height=1 width=1></td>
					<td id="col_1_data"><img id="col_1_dataimg" src="./images/spacer.gif" height=1 width=1></td>
					<td><img src="./images/spacer.gif" height=1 width=1></td>
					<td id="col_2_data"><img id="col_2_dataimg" src="./images/spacer.gif" height=1 width=1></td>
					<td><img src="./images/spacer.gif" height=1 width=1></td>
					<td id="col_3_data"><img id="col_3_dataimg" src="./images/spacer.gif" height=1 width=1></td>
					<td><img src="./images/spacer.gif" height=1 width=1></td>
					<td id="col_4_data"><img id="col_4_dataimg" src="./images/spacer.gif" height=1 width=1></td>
					<td><img src="./images/spacer.gif" height=1 width=1></td>
					<td id="col_5_data"><img id="col_5_dataimg" src="./images/spacer.gif" height=1 width=1></td>
					<td><img src="./images/spacer.gif" height=1 width=1></td>
					<td id="col_6_data"><img id="col_6_dataimg" src="./images/spacer.gif" height=1 width=1></td>
					<td><img src="./images/spacer.gif" height=1 width=1></td>
					<td id="col_7_data"><img id="col_7_dataimg" src="./images/spacer.gif" height=1 width=1></td>
					<td><img src="./images/spacer.gif" height=1 width=1></td>
					<td id="col_8_data"><img id="col_8_dataimg" src="./images/spacer.gif" height=1 width=1></td>
					<td><img src="./images/spacer.gif" height=1 width=1></td>
					<td id="col_9_data"><img id="col_9_dataimg" src="./images/spacer.gif" height=1 width=1></td>
					<td><img src="./images/spacer.gif" height=1 width=1></td>
					<td id="col_10_data"><img id="col_10_dataimg" src="./images/spacer.gif" height=1 width=1></td>
					<td><img src="./images/spacer.gif" height=1 width=1></td>
					<td id="col_11_data"><img id="col_11_dataimg" src="./images/spacer.gif" height=1 width=1></td>
					<td><img src="./images/spacer.gif" height=1 width=1></td>
				</tr>
			</table>
			<script language="javascript">
			<!--
				parent.frames["DetailFrameHdr"].document.location = "security_user_details_header.asp?enumgroup=<%=Request.QueryString("enumgroup")%>&enumrole=<%=Request.QueryString("enumrole")%>&sgid=<%=Request.QueryString("sgid")%>&sort=<%=SortColumn%>&direction=<%=SortDirection%>&q=<%= Server.URLEncode(querystring)%>";
				parent.frames["PagingNavFrame"].document.location = "./../app_include/paging_navbar.asp?loc=<%=Request.ServerVariables("SCRIPT_NAME")%>&frm=DetailFrame&pageCount=<%=pageCount%>&curPage=<%=curPage%>&pageSize=<%=pageSize%>&numFound=<%=totRecords%>&q=<%= Server.URLEncode(querystring) %>";
			//-->
			</script>
			<%
			Else
			%>
			No Results Found
			<script language="javascript">
			<!--
				parent.frames["DetailFrameHdr"].document.location = "../app_include/blank_999999.html";
				parent.frames["PagingNavFrame"].document.location = "./../app_include/blank_cccccc.html";
			//-->
			</script>
			<%
			End If
			objRec.Close
			%>
		</td>
	</tr>
	</form>
<%
if bolSaveSearch then
%>
	<script language=javascript>
		function Load_Saved_Search(pLocation, pSearchLocation, selectedValue) 
		{
			var sLocation = pLocation;
			var sQuery = pSearchLocation;
			var sFilterID;
			if(sQuery.length <= 1) {
				sQuery = '?Filter_ID=' + selectedValue;
			}
			else {
				sFilterID = sQuery.replace( /.*Filter_ID=([0-9]+).*/i,'$1' );
				sQuery = sQuery.replace('&Filter_ID=' + sFilterID, '');
				sQuery = sQuery.replace('Filter_ID=' + sFilterID, '');
				
				if(sQuery.length <= 1) {
					sQuery = '?Filter_ID=' + selectedValue;
				}
				else {
					sQuery = sQuery + '&Filter_ID=' + selectedValue;
				}
			}
			if(pSearchLocation.length <= 1) {
				sLocation = pLocation + sQuery;
			}
			else {
				sLocation = sLocation.replace(pSearchLocation, sQuery);
			}
			return sLocation;
		}
		
		parent.frames["FilterFrame"].document.location = Load_Saved_Search(parent.frames["FilterFrame"].document.location.toString(), parent.frames["FilterFrame"].document.location.search.toString(), <%=Filter_ID%>);
		
	</script>
<%
end if
%>
</table>
<!--#include file="./include/security_user_details_contextmenu.asp"--><!--right click menu-->

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

Sub appendFilterParameter(ByRef p_xmlStr, p_colOrd, p_filterParam)
	numFilterParamsWrittenSoFar = numFilterParamsWrittenSoFar + 1
	if not IsNull(p_filterParam) then
		p_xmlStr = p_xmlStr & "<Parameter FilterID=""" & numFilterParamsWrittenSoFar & """ intColOrdinal=""" & p_colOrd & """>" & p_filterParam & "</Parameter>"
	else
		p_xmlStr = p_xmlStr & "<Parameter FilterID=""" & numFilterParamsWrittenSoFar & """ intColOrdinal=""" & p_colOrd & """ />"
	end if
End Sub

Sub appendSortParameter(ByRef p_xmlStr, p_colOrd, p_sortDir)
	numSortParamsWrittenSoFar = numSortParamsWrittenSoFar + 1
	p_xmlStr = p_xmlStr & "<Parameter SortID=""" & numSortParamsWrittenSoFar & """ intColOrdinal=""" & p_colOrd & """ intDirection=""" & p_sortDir & """ />"
End Sub

Function GenerateXMLString()

	Dim dataSetTypes
	Dim numPanes, numParameters, numQuestions
	Dim StartDate, EndDate, txtStartDate, txtStartTime, txtEndDate, txtEndTime
	Dim curPaneNumber, curPaneTypeID, curQuestion, curAnswer, curWhen, curParameterNumber, curParameterID, curParameterStr
	Dim xmlSearch, searchString, tempSearchString, tmpSearchSQLStrOut, conjunction, arWords, wnum
	Dim strHiddenParams, arHiddenParams, strThisHiddenParam, arThisHiddenParam, tmpHiddenParameterID, tmpHiddenParameterStr
	Dim querystringOut
	
	Set dataSetTypes = New cls_FilterPaneChoiceSetType
	numPanes = checkQueryID(Request("Num_Panes"), 0)
	
	if numPanes > 0 then
		querystringOut = "Num_Panes" & "=" & Request("Num_Panes")
	end if

	xmlSearch = "<Filter>"

	For curPaneNumber = 1 to numPanes
		
		curQuestion		= checkQueryID(Request("Select_Questions_" & curPaneNumber), 1)
		numParameters	= checkQueryID(Request("QS" & curPaneNumber & "_PS" & curQuestion & "_PCount"), 0)
		curPaneTypeID	= SmartValues(Request("Pane_Type_" & curPaneNumber), "CInt")
		
		if curQuestion > 1 then
			querystringOut	= querystringOut & "&Select_Questions_" & curPaneNumber & "=" & Request("Select_Questions_" & curPaneNumber)
			querystringOut	= querystringOut & "&QS" & curPaneNumber & "_PS" & curQuestion & "_PCount=" & Request("QS" & curPaneNumber & "_PS" & curQuestion & "_PCount")
		end if
		
		querystringOut	= querystringOut & "&Pane_Type_" & curPaneNumber & "=" & Request("Pane_Type_" & curPaneNumber)
		
		Select Case curPaneTypeID
		
			Case dataSetTypes.TEXT
				
				'Loop through all parameters
				For curParameterNumber = 1 to numParameters
								
					curParameterID	= SmartValues(Request("QS" & curPaneNumber & "_PS" & curQuestion & "_PID" & curParameterNumber), "CStr")
					curParameterStr	= SmartValues(Request("QS" & curPaneNumber & "_PS" & curQuestion & "_PStr" & curParameterNumber), "CStr")
					curAnswer		= SmartValues(Request("Text_Choices_" & curPaneNumber), "CStr")
					
					querystringOut	= querystringOut & "&QS" & curPaneNumber & "_PS" & curQuestion & "_PID" & curParameterNumber & "=" & Request("QS" & curPaneNumber & "_PS" & curQuestion & "_PID" & curParameterNumber)
					querystringOut	= querystringOut & "&QS" & curPaneNumber & "_PS" & curQuestion & "_PStr" & curParameterNumber & "=" & Request("QS" & curPaneNumber & "_PS" & curQuestion & "_PStr" & curParameterNumber)
					querystringOut	= querystringOut & "&Text_Choices_" & curPaneNumber & "=" & Request("Text_Choices_" & curPaneNumber)
					
					searchString		= ""
					tmpSearchSQLStrOut	= ""
										
					'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
					'	Available Full-Text searchType(s)
					'	1 = Use the EXACT PHRASE entered
					'	2 = Use ANY of the words entered (OR Search)
					'	3 = Use ALL of the words entered (AND Search)
					'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
					if curParameterStr = "[EXACT_PHRASE]" then	'Use the EXACT PHRASE entered
					'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
						searchString = Replace(curAnswer, "%", "")
						searchString = Replace(searchString, "'", "")
						searchString = Replace(searchString, """", "")
						searchString = Chr(34) & searchString & Chr(34)
						Call appendFilterParameter(xmlSearch, curParameterID, searchString)

					'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
					elseIf curParameterStr = "[OR_SEARCH]" then	'Use ANY of the words entered (OR Search)
					'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
						'Make sure there are no double spaces
						searchString = Replace(curAnswer, "%", "")
						searchString = Replace(searchString, "'", "")
						searchString = Replace(searchString, "  ", " ")
						searchString = Trim(searchString)
						tempSearchString = searchString

						conjunction = "" 

						arWords = Split(tempSearchString, " ")
						For wnum = 0 to UBound(arWords)
							tmpSearchSQLStrOut = tmpSearchSQLStrOut & conjunction & arWords(wnum)
							conjunction = " OR "
						Next
						searchString = tmpSearchSQLStrOut

						Call appendFilterParameter(xmlSearch, curParameterID, searchString)

					'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
					elseIf curParameterStr = "[AND_SEARCH]"	then 'Use ALL of the words entered (AND Search)
					'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
						'Make sure there are no double spaces
						searchString = Replace(curAnswer, "%", "")
						searchString = Replace(searchString, "'", "")
						searchString = Replace(searchString, "  ", " ")
						searchString = Trim(searchString)
						tempSearchString = searchString

						conjunction = "" 

						arWords = Split(tempSearchString, " ")
						For wnum = 0 to UBound(arWords)
							tmpSearchSQLStrOut = tmpSearchSQLStrOut & conjunction & arWords(wnum)
							conjunction = " AND "
						Next
						searchString = tmpSearchSQLStrOut

						Call appendFilterParameter(xmlSearch, curParameterID, searchString)

					else
					
						curAnswer = Replace(curAnswer, "%", "")
						curAnswer = Replace(curAnswer, "'", "")
						curAnswer = Replace(curAnswer, """", "")
						curAnswer = Replace(curAnswer, "*", "%")
						
						Call appendFilterParameter(xmlSearch, curParameterID, curAnswer)
						
					end if
					
				Next
				
			Case dataSetTypes.LIST, dataSetTypes.DB_LOOKUP
			
				curAnswer = SmartValues(Request("Select_Choices_" & curPaneNumber), "CStr")
				
				if len(curAnswer) > 0 then
					querystringOut	= querystringOut & "&Select_Choices_" & curPaneNumber & "=" & Request("Select_Choices_" & curPaneNumber)	
				end if
				
				'Loop through all parameters
				For curParameterNumber = 1 to numParameters
				
					querystringOut	= querystringOut & "&QS" & curPaneNumber & "_PS" & curQuestion & "_PID" & curParameterNumber & "=" & Request("QS" & curPaneNumber & "_PS" & curQuestion & "_PID" & curParameterNumber)
					querystringOut	= querystringOut & "&QS" & curPaneNumber & "_PS" & curQuestion & "_PStr" & curParameterNumber & "=" & Request("QS" & curPaneNumber & "_PS" & curQuestion & "_PStr" & curParameterNumber)

					curParameterID	= SmartValues(Request("QS" & curPaneNumber & "_PS" & curQuestion & "_PID" & curParameterNumber), "CStr")
					curParameterStr	= SmartValues(Request("QS" & curPaneNumber & "_PS" & curQuestion & "_PStr" & curParameterNumber), "CStr")
										 
					if curParameterStr = "[SELECTED_VALUES]" then
						curParameterStr = curAnswer
					elseif Trim(curParameterStr) = "" then
						curParameterStr = null
					end if
					
					Call appendFilterParameter(xmlSearch, curParameterID, curParameterStr)
					
				Next
				
			Case dataSetTypes.DATE_TIME
				
				if curQuestion > 1 then 'Should only be performed if it is not the first question (regardless of time)
				
					querystringOut	= querystringOut & "&Select_When_" & curPaneNumber & "=" & Request("Select_When_" & curPaneNumber)
					querystringOut	= querystringOut & "&txtStartDate_" & curPaneNumber & "=" & Request("txtStartDate_" & curPaneNumber)
					querystringOut	= querystringOut & "&txtStartTime_" & curPaneNumber & "=" & Request("txtStartTime_" & curPaneNumber)
					querystringOut	= querystringOut & "&txtEndDate_" & curPaneNumber & "=" & Request("txtEndDate_" & curPaneNumber)
					querystringOut	= querystringOut & "&txtEndTime_" & curPaneNumber & "=" & Request("txtEndTime_" & curPaneNumber)
				
					curWhen			= checkQueryID(Request("Select_When_" & curPaneNumber), -1)
					txtStartDate	= Request("txtStartDate_" & curPaneNumber)
					txtStartTime	= Request("txtStartTime_" & curPaneNumber)
					txtEndDate		= Request("txtEndDate_" & curPaneNumber)
					txtEndTime		= Request("txtEndTime_" & curPaneNumber)
									
					if IsDate(txtStartDate) then StartDate = CDate(txtStartDate & " " & txtStartTime)
					if IsDate(txtEndDate) then EndDate = CDate(txtEndDate & " " & txtEndTime)
		
					'Loop through all parameters
					For curParameterNumber = 1 to numParameters
												
						curParameterID	= SmartValues(Request("QS" & curPaneNumber & "_PS" & curQuestion & "_PID" & curParameterNumber), "CStr")
						curParameterStr	= SmartValues(Request("QS" & curPaneNumber & "_PS" & curQuestion & "_PStr" & curParameterNumber), "CStr")
					
						if curParameterStr = "[START_DATE]" then
							curParameterStr = StartDate
						elseif curParameterStr = "[END_DATE]" then
							curParameterStr = EndDate
						elseif Trim(curParameterStr) = "" then
							curParameterStr = null
						end if
								
						if curWhen = curParameterNumber then	'today, this week, this month, yesterday, last week, last month, on or after this date, on or before this date
						
							querystringOut	= querystringOut & "&QS" & curPaneNumber & "_PS" & curQuestion & "_PID" & curParameterNumber & "=" & Request("QS" & curPaneNumber & "_PS" & curQuestion & "_PID" & curParameterNumber)
							querystringOut	= querystringOut & "&QS" & curPaneNumber & "_PS" & curQuestion & "_PStr" & curParameterNumber & "=" & Request("QS" & curPaneNumber & "_PS" & curQuestion & "_PStr" & curParameterNumber)
						
							Call appendFilterParameter(xmlSearch, curParameterID, curParameterStr)
						
						elseif curWhen = 9 and curParameterNumber >= 9 then ' Between these Dates
						
							querystringOut	= querystringOut & "&QS" & curPaneNumber & "_PS" & curQuestion & "_PID" & curParameterNumber & "=" & Request("QS" & curPaneNumber & "_PS" & curQuestion & "_PID" & curParameterNumber)
							querystringOut	= querystringOut & "&QS" & curPaneNumber & "_PS" & curQuestion & "_PStr" & curParameterNumber & "=" & Request("QS" & curPaneNumber & "_PS" & curQuestion & "_PStr" & curParameterNumber)
						
							Call appendFilterParameter(xmlSearch, curParameterID, curParameterStr)
							
						end if
					Next
					
				end if
				
		End Select

	Next
	
	'for i = 1 to Request.QueryString.Count
		'Response.Write Request.QueryString.Key(i) & ": '" & Request.QueryString(i) & "'<br>" & vbCrLf
	'next

	'Loop through Hidden Parameters
	if Len(Trim(Request("filterHiddenParams"))) > 0 then
		querystringOut	= querystringOut & "&filterHiddenParams=" & Trim(Request("filterHiddenParams"))
		strHiddenParams = Request.QueryString("filterHiddenParams") 'expecting something like "6,'test'; 7, 'test'"
		arHiddenParams = Split(strHiddenParams, ";")
		
		for z = 0 to UBound(arHiddenParams)-1
			strThisHiddenParam = arHiddenParams(z)
			arThisHiddenParam = Split(strThisHiddenParam, ",")
			tmpHiddenParameterID = Trim(arThisHiddenParam(0))
			tmpHiddenParameterStr = Trim(arThisHiddenParam(1))
			
			
			if IsNumeric(tmpHiddenParameterID) then
				if Len(tmpHiddenParameterStr) = 0 then tmpHiddenParameterStr = null
				Call appendFilterParameter(xmlSearch, tmpHiddenParameterID, tmpHiddenParameterStr)
			end if
		next
	
	end if
	
	xmlSearch = xmlSearch & "</Filter>"

	xmlSearch = xmlSearch & "<Sort>"

	Call appendSortParameter(xmlSearch, SortColumn, SortDirection)

	xmlSearch = xmlSearch & "</Sort>"
	xmlSearch = "<?xml version=""1.0"" encoding=""ISO-8859-1""?><Root>" & xmlSearch & "</Root>"
			
	Set dataSetTypes = Nothing
	querystring = querystringOut
	GenerateXMLString = xmlSearch
	
End Function

Function OutputToExcelDocument( pSQLStr )
	
	Session("SecurityUserExportToExcelStr") = Replace(pSQLStr, "sp_security_list_users_search", "sp_security_list_users_search_to_Excel ")
	
	Response.Redirect "security_user_export_to_excel.asp"	

End Function

Function SaveSearch(referenceID, securityModule, filterName)

	Dim dataSetTypes, utils, rs
	Dim cur_Filter_ID, choiceArray, choiceCounter
	Dim numPanes
	Dim StartDate, EndDate, txtStartDate, txtStartTime, txtEndDate, txtEndTime
	Dim curPaneNumber, curPaneTypeID, curQuestion, curAnswer, curWhen
			
	Set dataSetTypes	= New cls_FilterPaneChoiceSetType
	Set utils			= New cls_UtilityLibrary
	
	numPanes = checkQueryID(Request("Num_Panes"), 0)
	
	'Save Filter Name
	Set rs = utils.LoadRSFromDB("sp_Filter_InsertUpdate '" & utils.FormatDBStringForInsert(filterName) & "', '0" & Session.Value("UserID") & "', '0" & referenceID & "', '" & utils.FormatDBStringForInsert(securityModule) & "'")

	'Get Filter ID
	cur_Filter_ID = rs("ID")
	
	Set rs = Nothing
	
	'Loop through all panes to see what needs to be saved
	For curPaneNumber = 1 to numPanes
		
		curQuestion		= checkQueryID(Request("Select_Questions_" & curPaneNumber), 1)
		curPaneTypeID	= checkQueryID(Request("Pane_Type_" & curPaneNumber), 3)
		
		'Save Question
		if curQuestion > 1 then
			utils.RunSQL "sp_Filter_Question_InsertUpdate '" & cur_Filter_ID & "', '0" & curPaneNumber & "', '" & curQuestion & "'"
		end if
		
		Select Case curPaneTypeID
		
			Case dataSetTypes.TEXT
				
				curAnswer = Trim(SmartValues(Request("Text_Choices_" & curPaneNumber), "CStr"))
				
				'Save this answer
				if Len(curAnswer) > 0 then
					utils.RunSQL "sp_Filter_Choice_InsertUpdate '" & cur_Filter_ID & "', '0" & curPaneNumber & "', '" & curAnswer & "', '1'"
				end if
								
			Case dataSetTypes.LIST, dataSetTypes.DB_LOOKUP
			
				curAnswer = Trim(SmartValues(Request("Select_Choices_" & curPaneNumber), "CStr"))
								
				if Len(curAnswer) > 0 then
				
					'Split the curAnswer and save each into a selected option
					choiceArray = Split(curAnswer, ",")
					
					for choiceCounter = 0 to UBound(choiceArray)
						utils.RunSQL "sp_Filter_Choice_InsertUpdate '" & cur_Filter_ID & "', '0" & curPaneNumber & "', '" & Trim(choiceArray(choiceCounter)) & "', '1'"	
					next
					
				end if
								
			Case dataSetTypes.DATE_TIME
				
				if curQuestion > 1 then 'Should only be performed if it is not the first question (regardless of time)
				
					curWhen			= checkQueryID(Request("Select_When_" & curPaneNumber), -1)
					txtStartDate	= Trim(SmartValues(Request("txtStartDate_" & curPaneNumber), "CStr"))
					txtStartTime	= Trim(SmartValues(Request("txtStartTime_" & curPaneNumber), "CStr"))
					txtEndDate		= Trim(SmartValues(Request("txtEndDate_" & curPaneNumber), "CStr"))
					txtEndTime		= Trim(SmartValues(Request("txtEndTime_" & curPaneNumber), "CStr"))
					
					'Save curWhen
					utils.RunSQL "sp_Filter_Choice_InsertUpdate '" & cur_Filter_ID & "', '0" & curPaneNumber & "', '" & curWhen & "', '1'"
					
					'Save the start date and time
					if Len(txtStartDate) > 0 AND Len(txtStartTime) > 0 then
						utils.RunSQL "sp_Filter_Choice_InsertUpdate '" & cur_Filter_ID & "', '0" & curPaneNumber & "', '" & txtStartDate & "', '2'"
						utils.RunSQL "sp_Filter_Choice_InsertUpdate '" & cur_Filter_ID & "', '0" & curPaneNumber & "', '" & txtStartTime & "', '3'"
					end if
					
					'Save the end date and time
					if Len(txtEndDate) > 0 AND Len(txtEndTime) > 0 then
						utils.RunSQL "sp_Filter_Choice_InsertUpdate '" & cur_Filter_ID & "', '0" & curPaneNumber & "', '" & txtEndDate & "', '4'"
						utils.RunSQL "sp_Filter_Choice_InsertUpdate '" & cur_Filter_ID & "', '0" & curPaneNumber & "', '" & txtEndTime & "', '5'"
					end if
									
				end if
				
		End Select

	Next
	
	Set utils = Nothing
	Set dataSetTypes = Nothing

	SaveSearch = cur_Filter_ID
	
End Function
%>