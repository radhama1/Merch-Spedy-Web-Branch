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
'Dim Security
'Set Security = New cls_Security
'Security.Initialize Session.Value("UserID"), "ADMIN", 0

Dim outputToExcel, querystring, Filter_ID, bolSaveSearch
Dim SortColumn, SortDirection, xmlSearchCriteria, xmlString
Dim numFilterParamsWrittenSoFar, numSortParamsWrittenSoFar
Dim objConn, objRec, SQLStr, connStr, i
Dim Website_ID, strOpenedNodes, arOpenedNodes, NestLevel
Dim numFound, startRow, pageSize, curPage, pageCount
Dim z, rowcolor
Dim thisOpenString, boolIsLast, boolShowOpen
Dim Element_ID, Parent_Element_ID, Element_FullTitle, Element_Type, FileName, Status_ID, Status_Name
Dim Element_ShortTitle, Element_CustomHTMLTitle, Enabled, DisplayInNav, DisplayInSearchResults
Dim boolPromotedToStaging, boolPromotedToLive, boolHasChildren, numChildren, Staging_Source_ID, Live_Source_ID
Dim Date_Published, Date_Modified_Staging, Date_Modified_Live
Dim Start_Date, End_Date, Template_Name, Template_Constant
Dim Element_Type_Summary
Dim isStagingSameAsLive

'Initialize Variables
numFilterParamsWrittenSoFar = 0
numSortParamsWrittenSoFar = 0

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

'Get the Website ID
Website_ID = Request("webid")
if not IsNumeric(Website_ID) or Len(Trim(Website_ID)) = 0 then
	if IsNumeric(Session.Value("websiteID")) and Trim(Session.Value("websiteID")) <> "" then
		Website_ID = Session.Value("websiteID")
	else
		Website_ID = 0
	end if
end if
Session.Value("websiteID") = Website_ID

'Save Search?
if Len(Trim(SmartValues(Request("Save_Search_Name"), "CStr"))) > 0 then
	bolSaveSearch = true
	Filter_ID = SaveSearch(Website_ID, "ADMIN.WEBSITE", Trim(SmartValues(Request("Save_Search_Name"), "CStr")))
else
	bolSaveSearch = false
	Filter_ID = 0
end if

'Get the Sort Column
SortColumn = Trim(Request("sort"))
if IsNumeric(SortColumn) and Trim(SortColumn) <> "" then
	SortColumn = CInt(SortColumn)
	Session.Value("Webiste_SortColumn") = SortColumn
else
	if IsNumeric(Session.Value("Webiste_SortColumn")) and Trim(Session.Value("Webiste_SortColumn")) <> "" then
		SortColumn = CInt(Session.Value("Webiste_SortColumn"))
	else
		SortColumn = 0
		Session.Value("Webiste_SortColumn") = SortColumn
	end if
end if

'Get the Sort Direction
SortDirection = Trim(Request("direction"))
if IsNumeric(SortDirection) and Trim(SortDirection) <> "" then
	SortDirection = CInt(SortDirection)
	Session.Value("Website_SortDirection") = SortDirection
else
	if IsNumeric(Session.Value("Website_SortDirection")) and Trim(Session.Value("Website_SortDirection")) <> "" then
		SortDirection = CInt(Session.Value("Website_SortDirection"))
	else
		SortDirection = 0
		Session.Value("Website_SortDirection") = SortDirection
	end if
end if

'Get the XML String
xmlSearchCriteria = GenerateXMLString()

'Output to Excel
outputToExcel = CBool(checkQueryID(Trim(Request("excel")), 0))
if outputToExcel then
	Call OutputToExcelDocument(xmlSearchCriteria)
end if

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr

'CREATE PROCEDURE sp_websites_admin_content_search
'  @xmlSortCriteria varchar(8000) = NULL,
'  @maxRows int = -1,
'  @startRow int = 0,
'  @printDebugMsgs bit = 0

SQLStr = "sp_websites_admin_content_search '" & xmlSearchCriteria & "', '" & pageSize & "', '" & startRow & "', 0"
'Response.Write Server.HTMLEncode(SQLStr) & "<br><br>" & vbCrLf & vbCrLf
i = 0
%>
<html>
<head>
	<title>Tree Test</title>
	<style type="text/css">
		@import url('./../app_include/global.css');
		A {text-decoration: none; color:#000;}
		A:HOVER {text-decoration: underline; color: #00f;}
		BODY {width: 100%; clip: auto; overflow: auto;}
		
		.bodyText
		{
			font-size: 11px;
			line-height: 16px;
		}
		
		.hdrrow TD
		{
			background: #999;
			border-top: 1px solid #333;
			border-bottom: 1px solid #666;
			line-height: 16px;
			color: #333;
		}
		
		.datarow TD
		{
			height: 16px;
		}
		.spacercell
		{
			padding-left: 5px;
		}
		
		.datatreecol
		{
			width: 100%;
			white-space: nowrap;
		}
		
		.datatreecol DIV
		{
			white-space: nowrap;
		}
		
		.datatreefileicon
		{
			margin-right: 5px;
			padding-right: 5px;
		}
		
		.datatreenode
		{
			white-space: nowrap;
		}
		
		.datatreenodetable
		{
			margin: 0;
			padding: 0;
		}
		
		.datatreetext
		{
			white-space: nowrap;
		}
		
		.datacol
		{
			white-space: nowrap;
		}
		
		.datacol_center
		{
			white-space: nowrap;
			text-align: center;
		}

		.datacol_right
		{
			white-space: nowrap;
			text-align: right;
		}

		.datatreecol_hdrrow
		{
			white-space: nowrap;
		}
		
		.datacol_hdrrow
		{
			padding-left: 5px;
			padding-right: 5px;
			white-space: nowrap;
			border-left: 1px solid #666;
		}

		.rover TD
		{
			background: #ff9; 
			color: #000;
		}
		.selectedRow *
		{
			background: #ccc; 
			color: #000;
		}
	</style>
	<script language="javascript" src="./../app_include/lockscroll.js"></script><!--locked headers code-->
	<link rel="stylesheet" href="./../app_include/contextmenu.css" type="text/css" media="screen"><!--right click styles-->
	<script language="javascript" src="./../app_include/resizeFrame.js"></script>
	<script language="javascript" src="./include/website_details_contextmenu.js"></script><!--right click menu-->
	<script language=javascript>
	<!--
		window.defaultStatus = "Manage Website Data";
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
	
		function openSelectDocumentWindow(selectedItemID)
		{
			newDocWin = window.open("./website_document_admin/website_document_select.asp?itemType=document&itemID=" + selectedItemID, "newDocWindow_" + selectedItemID, "width=700,height=550,toolbar=0,location=0,directories=0,status=1,menuBar=0,scrollBars=1,resizable=0");
			newDocWin.focus();
		}

		function openItemSwapWindow(RowID)
		{
				newDocWin = window.open("./website_document_admin/website_document_swap2.asp?itemType=document&itemID=" + RowID, "newDocWindow_" + RowID, "width=700,height=550,toolbar=0,location=0,directories=0,status=1,menuBar=0,scrollBars=1,resizable=0");
				newDocWin.focus();
		}

		function openItemStatusWindow(RowID)
		{
			statusWin = window.open("./website_document_admin/website_document_status.asp?tid=" + RowID, "statusWindow_" + RowID, "width=300,height=100,toolbar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=1,resizable=1");
			statusWin.focus();
		}

		function openItemApprovalWindow(RowID)
		{
			approvalWin = window.open("./../manage_workflow/approval/approval.asp?rid=" + RowID + "&rsrc=0", "approvalWindow_" + RowID, "width=650,height=470,toolbar=0,location=0,directories=0,status=1,menuBar=0,scrollBars=1,resizable=1");
			approvalWin.focus();
		}

		function openItemSettingsWindow(RowID)
		{
			settingsWin = window.open("./website_document_admin/website_document_details_frm.asp?tid=" + RowID, "settingsWin_" + RowID, "width=460,height=500,toolbar=0,location=0,directories=0,status=1,menuBar=0,scrollBars=0,resizable=1");
			settingsWin.focus();
		}

		function openItemMoveWindow(RowID)
		{
			moveWin = window.open("./website_document_admin/website_document_move.asp?webid=<%=Website_ID%>&open=<%=Request("open")%>&tid=" + RowID, "moveWindow_" + RowID, "width=300,height=300,toolbar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=1,resizable=0");
			moveWin.focus();
		}

		function demoteDocument(RowID)
		{
			document.location = "./website_document_admin/website_document_promotion.asp?tid=" + RowID + "&promoswitch=0&chkIncludeChildren=0";
		}
		
		function demoteDocumentTree(RowID)
		{
			document.location = "./website_document_admin/website_document_promotion.asp?tid=" + RowID + "&promoswitch=0&chkIncludeChildren=1";
		}
		
		function promoteDocument(RowID)
		{
			document.location = "./website_document_admin/website_document_promotion.asp?tid=" + RowID + "&promoswitch=1&chkIncludeChildren=0";
		}
		
		function promoteDocumentTree(RowID)
		{
			document.location = "./website_document_admin/website_document_promotion.asp?tid=" + RowID + "&promoswitch=1&chkIncludeChildren=1";
		}
		
		function deleteDocument(RowID)
		{
			if (confirm("Really remove this element?\n\nThis cannot be undone!"))
			{
				document.location = "./website_document_admin/website_document_remove.asp?tid=" + RowID;
			}
			
		}
		
		function deleteDocumentTree(RowID)
		{
			if (confirm("Really remove these elements?\n\nThis cannot be undone!"))
			{
				document.location = "./website_document_admin/website_document_remove_tree.asp?tid=" + RowID;
			}
		}
		
		function showPreview(field)
		{
			previewWin = window.open('./website_document_preview.asp?tid=' + escape(field), 'previewWin', 'width=600,height=500,toolbar=0,location=0,directories=0,status=1,menuBar=0,scrollBars=1,resizable=1');
			previewWin.focus();
		}

		function checkMenuElement(checkValue, menuItemID)
		{
			if (checkValue == "1")
				document.getElementById(menuItemID).className = "menuItem";
			else
				document.getElementById(menuItemID).className = "menuItemDisabled";

		}

		var arClickedElementID = new Array();

		function configureOptions(RowID)
		{
		}

		function clickMenu()
		{
			el = event.srcElement;
			if (el.className == "menuItemDisabled")
				return;

			hideMenu();
			var selectedItemID = document.frmMenu.selectedItemID.value;
			
			switch (el.id)
			{
				case "ItemView":
					showPreview(selectedItemID);
					break;
				case "ItemSwap":
					openItemSwapWindow(selectedItemID);
					break;
				case "ItemStatus":
					openItemStatusWindow(selectedItemID);
					break;
				case "ItemSettings":
					openItemSettingsWindow(selectedItemID);
					break;
				case "ItemApproval":
					openItemApprovalWindow(selectedItemID);
					break;
				case "ItemDemote":
					waitLyr.style.display = "";
					demoteDocument(selectedItemID);
					waitLyr.style.display = "none";
					break;
				case "ItemTreeDemote":
					waitLyr.style.display = "";
					demoteDocumentTree(selectedItemID);
					waitLyr.style.display = "none";
					break;
				case "ItemPromote":
					waitLyr.style.display = "";
					promoteDocument(selectedItemID);
					break;
				case "ItemTreePromote":
					waitLyr.style.display = "";
					promoteDocumentTree(selectedItemID);
					waitLyr.style.display = "none";
					break;
				case "ItemMove":
					openItemMoveWindow(selectedItemID);
					break;
				case "ItemDelete":
					waitLyr.style.display = "";
					deleteDocument(selectedItemID);
					waitLyr.style.display = "none";
					break;
				case "TreeDelete":
					waitLyr.style.display = "";
					deleteDocumentTree(selectedItemID);
					waitLyr.style.display = "none";
					break;
				case "ItemAdd":
					openSelectDocumentWindow(selectedItemID);
					break;

				default:
					break;
			}
		}

		//-->
	</script>
</head>
<body bgcolor="ffffff" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0 onLoad="initPlaceLayers();" oncontextmenu="return false;">
<div style="position: absolute; z-index:100; width:100%; height:100%; top:0px; left:0px; clip: auto; overflow: hidden; border-top: 1px solid #333; filter:progid:DXImageTransform.Microsoft.Gradient(GradientType=0, StartColorStr='#FFE8E8E8', EndColorStr='#33FFFFFF')" id="waitLyr" name="waitLyr">
	<div id="waitText" name="waitText" style="position: absolute; top:10px; left:10px; font-family:Arial, Helvetica;font-size:12px; color:#666666;">
		Gathering Data<br>
		Please Wait…
	</div>
	<img src="./images/spacer.gif" border=0 style="width:100%; height:1000px;" galleryimg="no">
</div>

<form name="frmMenu" action="website_filter_details.asp" method="post" ID="frmMenu">
<table width=100% cellpadding=0 cellspacing=0 border=0 ID="Table1">
	<input type="hidden" name="selectedItemID" value="0" ID="selectedItemID">
	<input type="hidden" name="hoveredItemID" value="0" ID="hoveredItemID">
<%
objRec.Open SQLStr, objConn, adOpenKeyset, adLockReadOnly, adCmdText
if not objRec.EOF then
	numFound = objRec("totRecords")

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

	Do Until objRec.EOF
		Element_ID = SmartValues(objRec("Element_ID"), "CLng")
		Parent_Element_ID = SmartValues(objRec("Parent_Element_ID"), "CLng")
		Element_FullTitle = SmartValues(objRec("Element_FullTitle"), "CStr")
		Element_Type = SmartValues(objRec("Element_Type"), "CInt")
		FileName = SmartValues(objRec("FileName"), "CStr")
		Status_ID = SmartValues(objRec("Status_ID"), "CInt")
		Status_Name = SmartValues(objRec("Status_Name"), "CStr")
		Element_CustomHTMLTitle = SmartValues(objRec("Element_CustomHTMLTitle"), "CStr")
		Enabled = SmartValues(objRec("Enabled"), "CBool")
		DisplayInNav = SmartValues(objRec("DisplayInNav"), "CBool")
		DisplayInSearchResults = SmartValues(objRec("DisplayInSearchResults"), "CBool")
		boolPromotedToStaging = SmartValues(objRec("boolPromotedToStaging"), "CBool")
		boolPromotedToLive = SmartValues(objRec("boolPromotedToLive"), "CBool")
		boolHasChildren = SmartValues(objRec("boolHasChildren"), "CBool")
		numChildren = SmartValues(objRec("numChildren"), "CStr")
		Staging_Source_ID = SmartValues(objRec("Staging_Source_ID"), "CLng")
		Live_Source_ID = SmartValues(objRec("Live_Source_ID"), "CLng")
		Date_Published = SmartValues(objRec("Date_Published"), "CDate")
		Date_Modified_Staging = SmartValues(objRec("Date_Modified_Staging"), "CDate")
		Date_Modified_Live = SmartValues(objRec("Date_Modified_Live"), "CDate")
		Start_Date = SmartValues(objRec("Start_Date"), "CDate")
		End_Date = SmartValues(objRec("End_Date"), "CDate")
		Template_Name = SmartValues(objRec("Template_Name"), "CStr")
		Element_Type_Summary = SmartValues(objRec("Element_Type_Summary"), "CStr")
		isStagingSameAsLive = SmartValues(objRec("isStagingSameAsLive"), "CBool")

		if i mod 2 = 1 then				
			rowcolor = "f3f3f3"
		else
			rowcolor = "ffffff"
		end if
	%>
	<tr id="datarow_<%=Element_ID%>" class="datarow" style="background: #<%=rowcolor%>;" onMouseOver="HoverRow(<%=Element_ID%>);" onMouseOut="HoverRow(0);" onDblClick="highlightRow();" oncontextmenu="HoverRow(<%=Element_ID%>);SelectRow(<%=Element_ID%>);displayMenu(); return false;">
		<td><img src="./images/spacer.gif" height=1 width=5></td>
		<td class="bodyText datacol"><%=Element_FullTitle%>&nbsp;</td>
		<td><img src="./images/spacer.gif" height=1 width=10></td>
		<td class="datacol_center"><a href="#<%=Element_ID%>" onMouseOver="hTaskBtn('taskIcon<%=Element_ID%>', true)"  onMouseOut="hTaskBtn('taskIcon<%=Element_ID%>', false)" onClick="SelectRow(<%=Element_ID%>);HoverRow(<%=Element_ID%>);this.parentElement.parentElement.click(); displayMenu(); return false;"><img id="taskIcon<%=Element_ID%>" src="./../app_images/tasks_icon_off.gif" width=24 height=16 alt=":: Click to access tasks ::" border=0></a></td>
		<td><img src="./images/spacer.gif" height=1 width=10></td>
		<%if isStagingSameAsLive then%>
			<td class="datacol_center"><img src="./images/promostate_on.gif" height=14 width=14></td>
		<%elseif Len(Trim(Live_Source_ID)) = 0 then%>
			<td class="datacol_center"><img src="./images/promostate_on.gif" height=14 width=14 alt="The staging document has not yet been promoted."></td>
		<%elseif not isStagingSameAsLive then%>
			<td class="datacol_center"><img src="./images/promostate_new.gif" height=14 width=14 alt="The staging document is not the same as the live document."></td>
		<%end if%>
		<td><img src="./images/spacer.gif" height=1 width=10></td>
		<td class="datacol_center"><img src="./images/promostate_<%if boolPromotedToLive then%>on<%else%>off<%end if%>.gif" height=14 width=14></td>
		<td><img src="./images/spacer.gif" height=1 width=10></td>
		<td class="bodyText datacol"><%=Status_Name%>&nbsp;</td>
		<td><img src="./images/spacer.gif" height=1 width=10></td>
		<td class="bodyText datacol_right"><%=Element_ID%>&nbsp;</td>
		<td><img src="./images/spacer.gif" height=1 width=10></td>
		<td class="bodyText datacol"><%=Date_Published%>&nbsp;</td>
		<td><img src="./images/spacer.gif" height=1 width=10></td>
		<td class="bodyText datacol"><%=Date_Modified_Staging%>&nbsp;</td>
		<td><img src="./images/spacer.gif" height=1 width=10></td>
		<td class="bodyText datacol"><%=Date_Modified_Live%>&nbsp;</td>
		<td><img src="./images/spacer.gif" height=1 width=10></td>
		<td class="bodyText datacol"><%=Element_Type_Summary%>&nbsp;</td>
		<td><img src="./images/spacer.gif" height=1 width=10></td>
		<td class="datacol_center"><img src="./../app_images/checkbox_<%=DisplayInNav%>.gif" width=13 height=11></td>
		<td><img src="./images/spacer.gif" height=1 width=10></td>
		<td class="datacol_center"><img src="./../app_images/checkbox_<%=DisplayInSearchResults%>.gif" width=13 height=11></td>
		<td><img src="./images/spacer.gif" height=1 width=10></td>
		<td class="bodyText datacol"><%=Template_Name%>&nbsp;</td>
		<td><img src="./images/spacer.gif" height=1 width=10></td>
		<td class="bodyText datacol"><%=Start_Date%>&nbsp;</td>
		<td><img src="./images/spacer.gif" height=1 width=10></td>
		<td class="bodyText datacol"><%=End_Date%>&nbsp;</td>
		<td><img src="./images/spacer.gif" height=1 width=10></td>
		<td width=100%><img src="./images/spacer.gif" height=1 width=5></td>
	</tr>
	<%
		i = i + 1
		if CBool(findNeedleInHayStack(arOpenedNodes, Element_ID, "true")) and boolHasChildren then
			NestLevel = NestLevel + 1
			WriteTree Element_ID, thisOpenString
			NestLevel = NestLevel - 1
		end if
		
		objRec.MoveNext
		Response.Flush
	Loop
	%>
	<tr>
		<td><img src="./images/spacer.gif" height=1 width=1></td>
	<%for i = 0 to 16%>
		<%if i = 0 then%>
		<td id="col_<%=i%>_data"><img id="col_<%=i%>_dataimg" src="./images/spacer.gif" height=1 width=100></td>
		<%else%>
		<td id="col_<%=i%>_data"><img id="col_<%=i%>_dataimg" src="./images/spacer.gif" height=1 width=1></td>
		<%end if%>
		<td><img src="./images/spacer.gif" height=1 width=1></td>
	<%next%>
		<td><img src="./images/spacer.gif" height=1 width=1></td>
	</tr>
	<script language="javascript">
	<!--
		waitLyr.style.display = "none";
		resizeFrame("1,15,*,27,0", "WebsiteDetailsWrapperFrameset", parent.frames, "rows");
		parent.frames["DetailFrameHdr"].document.location = "website_filter_details_header.asp?sort=<%=SortColumn%>&direction=<%=SortDirection%>&q=<%= Server.URLEncode(querystring) %>";
		parent.frames["PagingNavFrame"].document.location = "./../app_include/paging_navbar.asp?loc=<%=Request.ServerVariables("SCRIPT_NAME")%>&frm=DetailFrame&pageCount=<%=pageCount%>&curPage=<%=curPage%>&pageSize=<%=pageSize%>&numFound=<%=numFound%>&q=<%= Server.URLEncode(querystring) %>";
	//-->
	</script>
	<%
	else
	%>
	<script language="javascript">
	<!--
		waitLyr.style.display = "none";
		resizeFrame("1,15,*,27,0", "WebsiteDetailsWrapperFrameset", parent.frames, "rows");
		parent.frames["DetailFrameHdr"].document.location = "./../app_include/blank_999999.html";
		parent.frames["PagingNavFrame"].document.location = "./../app_include/blank_cccccc.html";
	//-->
	</script>
<%
end if
%>
</table>
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
		
		parent.parent.frames["FilterFrame"].document.location = Load_Saved_Search(parent.parent.frames["FilterFrame"].document.location.toString(), parent.parent.frames["FilterFrame"].document.location.search.toString(), <%=Filter_ID%>);
		
	</script>
<%
end if
%>
<!--#include file="./include/website_filter_details_contextmenu.asp"--><!--right click menu-->
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

function findItemIcon(intTopicType, strFileName, bitIsPublished)
	Dim content_icon_root, file_icon_root, link_icon_root, list_icon_root, portal_icon_root
	Dim strOutput, strIconPath	
	
	strIconPath = ""
	
	if CBool(bitIsPublished) then
		content_icon_root = "icon_nativedoc_small_on.gif"
		link_icon_root = "icon_weblink_small_on.gif"
		list_icon_root = "icon_list_small_on.gif"
		portal_icon_root = "icon_portal_small_on.gif"
	else
		content_icon_root = "icon_nativedoc_small.gif"
		link_icon_root =  "icon_weblink_small.gif"
		list_icon_root = "icon_list_small.gif"
		portal_icon_root = "icon_portal_small.gif"
	end if
	file_icon_root = getFileIcon(strFileName, 0, bitIsPublished)
	
	strOutput = content_icon_root
	
	if IsNumeric(intTopicType) and not IsNull(intTopicType) then
		intTopicType = CInt(intTopicType)
		Select Case intTopicType
			Case 2
				strOutput = strIconPath & content_icon_root
			Case 3
				strOutput = strIconPath & file_icon_root
			Case 4
				strOutput = strIconPath & link_icon_root
			Case 5
				strOutput = strIconPath & list_icon_root
			Case 6
				strOutput = strIconPath & portal_icon_root
		End Select
	end if
	
	findItemIcon = strOutput
end function

function findTreeIcon(bIsLast, bIsRoot, sNodeType, bHasChildren, bShowOpen)
	dim sIcon
	
	sIcon = ""
	
	if (sNodeType = "document") then  
		if (bHasChildren = true) then
			'Folder has children, so use default folder open icon
			if (bShowOpen = true) then
				sIcon = "doc_folderopen.gif"
			else
				sIcon = "doc_folderclosed.gif"
			end if
		elseif (bHasChildren = false) then
			'Folder does NOT have children, so first check
			'what order it is in the list
			if (bIsLast = false) then
				'Not the last member, so use an empty folder with a line join graphic
				sIcon = "doc_folderclosedjoinempty.gif"	
			else
				'Is the last member, so use an empty folder with a line angle graphic
				sIcon = "doc_folderclosedempty.gif"
			end if
		end if
	else 
		if (bIsRoot = true) then
			'Root item requires special icon
			if (bShowOpen = true) then
				sIcon = "minusonly.gif"
			else
				sIcon = "plusonly.gif"
			end if
		elseif  (bHasChildren = true) then
			'Folder has children, so use default folder open icon
			if (bShowOpen = true) then
				sIcon = "folderopen.gif"
			else
				sIcon = "folderclosed.gif"
			end if
		elseif (bHasChildren = false) then
			'Folder does NOT have children, so first check
			'what order it is in the list
			if (bIsLast = false) then
				'Not the last member, so use an empty folder with a line join graphic
				sIcon = "folderclosedjoinempty.gif"	
			else
				'Is the last member, so use an empty folder with a line angle graphic
				sIcon = "folderclosedempty.gif"
			end if
		end if
	end if
	
	findTreeIcon = sIcon
end function

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
	
	querystringOut = "Num_Panes" & "=" & Request("Num_Panes")

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
					
				'	if curParameterID = "" then
				'		curParameterID = -400
				'	end if
					
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

Function OutputToExcelDocument( xmlStr )

	Dim FileName, Relative_Path, Physical_Path
	Dim objExcelConn, objExcelRec, ExcelSQLStr
	
	Set objExcelConn = Server.CreateObject("ADODB.Connection")
	Set objExcelRec = Server.CreateObject("ADODB.RecordSet")

	objExcelConn.Open Application.Value("connStr")

	'file name & path
	Relative_Path = "./files/export/filter_results_xls/"
	Physical_Path = InitRelativeFolder(Relative_Path, false)

	ExcelSQLStr = "sp_websites_admin_content_search_to_Excel '" & xmlStr & "', 0, 0, '" & Physical_Path & "', 0"
	Response.Write Server.HTMLEncode(ExcelSQLStr) & "<br><br>" & vbCrLf & vbCrLf
	objExcelRec.Open ExcelSQLStr, objExcelConn, adOpenStatic, adLockReadOnly, adCmdText
	if not objExcelRec.EOF then
		FileName = Trim(SmartValues(objExcelRec("XLS_File_Name"), "CStr"))
		Response.Redirect Relative_Path & FileName
	end if
	objExcelRec.Close
	objExcelConn.Close
	
	Set objExcelRec = Nothing
	Set objExcelConn = Nothing

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


