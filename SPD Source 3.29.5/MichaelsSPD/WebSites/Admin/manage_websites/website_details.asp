<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441
%>
<!--#include file="./../app_include/_globalInclude.asp"--> 
<!--#include file="./../app_include/getfile_icon_name.asp"-->
<%
'	Dim Security
'	Set Security = New cls_Security
'	Security.Initialize Session.Value("UserID"), "ADMIN", 0

Dim objConn, objRec, SQLStr, connStr, i
Dim Website_ID, strOpenedNodes, arOpenedNodes, NestLevel

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr

Website_ID = Request("webid")
if not IsNumeric(Website_ID) or Len(Trim(Website_ID)) = 0 then
	if IsNumeric(Session.Value("websiteID")) and Trim(Session.Value("websiteID")) <> "" then
		Website_ID = Session.Value("websiteID")
	else
		Website_ID = 0
	end if
end if
Session.Value("websiteID") = Website_ID

strOpenedNodes = Trim(Request("open"))
arOpenedNodes = Split(strOpenedNodes, ",")
NestLevel = 0
i = 0

'Response.Write "strOpenedNodes = " & strOpenedNodes & "<br>"
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
			padding-left: 10px;
			white-space: nowrap;
		}
		
		.datacol_center
		{
			white-space: nowrap;
			text-align: center;
		}

		.datacol_right
		{
			padding-left: 10px;
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
	<link rel="stylesheet" href="./../app_include/contextmenu.css" type="text/css" media="screen"><!--right click styles-->
	<script language="javascript" src="./../app_include/resizeFrame.js"></script>
	<script language="javascript" src="./include/website_details_contextmenu.js"></script><!--right click menu-->
	<script language="javascript" src="./../app_include/prototype/prototype.js"></script>
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
		
		function promoteDocumentWFirstSublevel(RowID)
		{
			document.location = "./website_document_admin/website_document_promotion.asp?tid=" + RowID + "&promoswitch=1&chkIncludeChildren=1&LevelRequired=1";
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

		function openSortWindow(RowID)
		{
			sortWin = window.open("./website_document_admin/website_document_sort_frm.asp?pcid=" + RowID, "sortWindow_" + selectedItemID, "width=360,height=325,toolbar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=0,resizable=0");
			sortWin.focus();
		}

		function sortChildDocumentsByName(RowID)
		{
				document.location = "./website_document_admin/website_document_sort_alpha.asp?pcid=" + RowID;
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
				case "ItemPromoteWFirstSubLevel":
					waitLyr.style.display = "";
					promoteDocumentWFirstSublevel(selectedItemID);
					break;
				case "ItemTreePromote":
					waitLyr.style.display = "";
					promoteDocumentTree(selectedItemID);
					waitLyr.style.display = "none";
					break;
				case "ItemMove":
					openItemMoveWindow(selectedItemID);
					break;
				case "ItemSortAlpha":
					waitLyr.style.display = "";
					sortChildDocumentsByName(selectedItemID);
					waitLyr.style.display = "none";
					break;
				case "ItemSort":
					openSortWindow(selectedItemID);
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

		var url = "./../ajaxtest_lookup.asp";
		var myObj;

		function fetchData()
		{
			var tmpUrl = url + "?r=" + Math.round(Math.random()*1000000);
			window.status = "URL: " + tmpUrl;
			
			new Ajax.Request(tmpUrl, {
				method: 'get',
				onSuccess: function(transport) {
					myObj = eval("(" + transport.responseText + ")");
				}
			});
			
			return true;
		 }
		 fetchData();

		//-->
	</script>
	<script language="javascript" src="./../app_include/evaluator.js"></script>
</head>
<body bgcolor="ffffff" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0 onLoad="initPlaceLayers();" oncontextmenu="return false;">
<div style="position: absolute; z-index:100; width:100%; height:100%; top:0px; left:0px; clip: auto; overflow: hidden; border-top: 1px solid #333; filter:progid:DXImageTransform.Microsoft.Gradient(GradientType=0, StartColorStr='#FFE8E8E8', EndColorStr='#33FFFFFF')" id="waitLyr" name="waitLyr">
	<div id="waitText" name="waitText" style="position: absolute; top:10px; left:10px; font-family:Arial, Helvetica;font-size:12px; color:#666666;">
		Gathering Data<br>
		Please Wait…
	</div>
	<img src="./images/spacer.gif" border=0 style="width:100%; height:1000px;" galleryimg="no">
</div>

<div id="contentLyr">
<%WriteTree 0, 0%>
</div>

<!--#include file="./include/website_details_contextmenu.asp"--><!--right click menu-->

<script language="javascript">
	waitLyr.style.display = "none";
	resizeFrame("1,0,*,0,25", "WebsiteDetailsWrapperFrameset", parent.frames, "rows");
</script>
</body>
</html>
<%
Sub WriteTree(p_Parent_Element_ID, p_nodelist)
	Dim objTreeRec, TreeSQLStr, z, rowcolor, numFound
	Dim thisOpenString, boolIsLast, boolShowOpen
	Dim Element_ID, Parent_Element_ID, Element_FullTitle, Element_Type, FileName, Status_ID, Status_Name
	Dim Element_ShortTitle, Element_CustomHTMLTitle, Enabled, DisplayInNav, DisplayInSearchResults
	Dim boolPromotedToStaging, boolPromotedToLive, boolHasChildren, numChildren, Staging_Source_ID, Live_Source_ID
	Dim Date_Published, Date_Modified_Staging, Date_Modified_Live
	Dim Start_Date, End_Date, Template_Name, Template_Constant
	Dim Element_Type_Summary
	Dim isStagingSameAsLive

	Set objTreeRec = Server.CreateObject("ADODB.RecordSet")

	TreeSQLStr = "sp_websites_return_website_contents '0" & Website_ID & "', '0" & p_Parent_Element_ID & "'"
	'Response.Write "EXEC " & TreeSQLStr & "<br>"
	objTreeRec.Open TreeSQLStr, objConn, adOpenKeyset, adLockReadOnly, adCmdText
	
	if p_Parent_Element_ID = 0 then
	%>
	<form name="frmMenu" action="website_details.asp?<%=Request.ServerVariables("QUERY_STRING")%>" method="post" ID="frmMenu">
	<table cellpadding=0 cellspacing=0 border=0 ID="Table1" onselectstart="return false;">
		<tr class="hdrrow">
			<td class="bodyText spacercell">&nbsp;</td>
			<td class="bodyText datatreecol_hdrrow" width=100%>Document</td>
			<td class="bodyText datacol_hdrrow">Tasks</td>
			<td class="bodyText datacol_hdrrow">Staging</td>
			<td class="bodyText datacol_hdrrow">Live</td>
			<td class="bodyText datacol_hdrrow">Status</td>
			<td class="bodyText datacol_hdrrow">ID</td>
			<td class="bodyText datacol_hdrrow">Date Published</td>
			<td class="bodyText datacol_hdrrow">Date Modified Staging</td>
			<td class="bodyText datacol_hdrrow">Date Modified Live</td>
			<td class="bodyText datacol_hdrrow">Type</td>
			<td class="bodyText datacol_hdrrow">Navigable</td>
			<td class="bodyText datacol_hdrrow">Searchable</td>
			<td class="bodyText datacol_hdrrow">Template</td>
			<td class="bodyText datacol_hdrrow">Start Date</td>
			<td class="bodyText datacol_hdrrow">End Date</td>
			<td class="bodyText spacercell">&nbsp;</td>
		</tr>
		<tr><td><img src="./../app_images/spacer.gif" height=2 width=1></td></tr>
	<%
	end if

	if not objTreeRec.EOF then
		numFound = objTreeRec.RecordCount
		z = 1
			
		Do Until objTreeRec.EOF
			Element_ID = SmartValues(objTreeRec("Element_ID"), "CLng")
			Parent_Element_ID = SmartValues(objTreeRec("Parent_Element_ID"), "CLng")
			Element_FullTitle = SmartValues(objTreeRec("Element_FullTitle"), "CStr")
			Element_Type = SmartValues(objTreeRec("Element_Type"), "CInt")
			FileName = SmartValues(objTreeRec("FileName"), "CStr")
			Status_ID = SmartValues(objTreeRec("Status_ID"), "CInt")
			Status_Name = SmartValues(objTreeRec("Status_Name"), "CStr")
			Element_CustomHTMLTitle = SmartValues(objTreeRec("Element_CustomHTMLTitle"), "CStr")
			Enabled = SmartValues(objTreeRec("Enabled"), "CBool")
			DisplayInNav = SmartValues(objTreeRec("DisplayInNav"), "CBool")
			DisplayInSearchResults = SmartValues(objTreeRec("DisplayInSearchResults"), "CBool")
			boolPromotedToStaging = SmartValues(objTreeRec("boolPromotedToStaging"), "CBool")
			boolPromotedToLive = SmartValues(objTreeRec("boolPromotedToLive"), "CBool")
			boolHasChildren = SmartValues(objTreeRec("boolHasChildren"), "CBool")
			numChildren = SmartValues(objTreeRec("numChildren"), "CStr")
			Staging_Source_ID = SmartValues(objTreeRec("Staging_Source_ID"), "CLng")
			Live_Source_ID = SmartValues(objTreeRec("Live_Source_ID"), "CLng")
			Date_Published = SmartValues(objTreeRec("Date_Published"), "CDate")
			Date_Modified_Staging = SmartValues(objTreeRec("Date_Modified_Staging"), "CDate")
			Date_Modified_Live = SmartValues(objTreeRec("Date_Modified_Live"), "CDate")
			Start_Date = SmartValues(objTreeRec("Start_Date"), "CDate")
			End_Date = SmartValues(objTreeRec("End_Date"), "CDate")
			Template_Name = SmartValues(objTreeRec("Template_Name"), "CStr")
			Element_Type_Summary = SmartValues(objTreeRec("Element_Type_Summary"), "CStr")
			isStagingSameAsLive = SmartValues(objTreeRec("isStagingSameAsLive"), "CBool")

			thisOpenString = p_nodelist
			if Len(Trim(thisOpenString)) > 0 then
				thisOpenString = thisOpenString & ","
			end if
			thisOpenString = thisOpenString & Element_ID

			boolIsLast = false
			if z >= numFound then
				boolIsLast = true
			end if

			boolShowOpen = false
			if CBool(findNeedleInHayStack(arOpenedNodes, Element_ID, "true")) and boolHasChildren then
				boolShowOpen = true
			end if

			if i mod 2 = 1 then				
				rowcolor = "f3f3f3"
			else
				rowcolor = "ffffff"
			end if
		%>
		<tr id="datarow_<%=Element_ID%>" class="datarow" style="background: #<%=rowcolor%>;" onMouseOver="HoverRow(<%=Element_ID%>);" onMouseOut="HoverRow(0);" onDblClick="highlightRow();" oncontextmenu="HoverRow(<%=Element_ID%>);SelectRow(<%=Element_ID%>);displayMenu(); return false;">
			<td class="bodyText spacercell">&nbsp;</td>
			<td class="datatreecol">
				<div class="datatreenode" style="padding-left: <%=NestLevel*20%>px;">
					<table cellpadding=0 cellspacing=0 class="datatreenodetable" ID="Table2">
						<tr>
							<td class="datatreeimg"><%if boolHasChildren then%><a href="website_details.asp?pid=<%=Element_ID%>&open=<%=thisOpenString%>"><%end if%><img class="" src="./../app_images/folderlist_icons/<%=findTreeIcon(boolIsLast, false, "document", boolHasChildren, boolShowOpen)%>" width=16 height=16 border=0></a></td>
							<td class="datatreefileicon"><%if boolHasChildren then%><a href="website_details.asp?pid=<%=Element_ID%>&open=<%=thisOpenString%>"><%end if%><img class="" src="./../app_images/app_icons/<%=findItemIcon(Element_Type, FileName, boolPromotedToLive)%>" width=16 height=16 border=0></a></td>
							<td class="bodyText datatreetext"><%if boolHasChildren then%><a href="website_details.asp?pid=<%=Element_ID%>&open=<%=thisOpenString%>"><%end if%><%=Element_FullTitle%></a></td>
						</tr>
					</table>
				</div>
			</td>
			<td class="datacol"><a href="#<%=Element_ID%>" onMouseOver="hTaskBtn('taskIcon<%=Element_ID%>', true)"  onMouseOut="hTaskBtn('taskIcon<%=Element_ID%>', false)" onClick="SelectRow(<%=Element_ID%>);HoverRow(<%=Element_ID%>);this.parentElement.parentElement.click(); displayMenu(); return false;"><img id="taskIcon<%=Element_ID%>" src="./../app_images/tasks_icon_off.gif" width=24 height=16 alt=":: Click to access tasks ::" border=0></a></td>
			<%if isStagingSameAsLive then%>
				<td class="datacol_center"><img src="./images/promostate_on.gif" height=14 width=14></td>
			<%elseif Len(Trim(Live_Source_ID)) = 0 then%>
				<td class="datacol_center"><img src="./images/promostate_on.gif" height=14 width=14 alt="The staging document has not yet been promoted."></td>
			<%elseif not isStagingSameAsLive then%>
				<td class="datacol_center"><img src="./images/promostate_new.gif" height=14 width=14 alt="The staging document is not the same as the live document."></td>
			<%end if%>
			<td class="datacol_center"><img src="./images/promostate_<%if boolPromotedToLive then%>on<%else%>off<%end if%>.gif" height=14 width=14></td>
			<td class="bodyText datacol"><%=Status_Name%>&nbsp;</td>
			<td class="bodyText datacol_right"><%=Element_ID%>&nbsp;</td>
			<td class="bodyText datacol"><%=Date_Published%>&nbsp;</td>
			<td class="bodyText datacol"><%=Date_Modified_Staging%>&nbsp;</td>
			<td class="bodyText datacol"><%=Date_Modified_Live%>&nbsp;</td>
			<td class="bodyText datacol"><%=Element_Type_Summary%>&nbsp;</td>
			<td class="datacol_center"><img src="./../app_images/checkbox_<%=DisplayInNav%>.gif" width=13 height=11></td>
			<td class="datacol_center"><img src="./../app_images/checkbox_<%=DisplayInSearchResults%>.gif" width=13 height=11></td>
			<td class="bodyText datacol"><%=Template_Name%>&nbsp;</td>
			<td class="bodyText datacol"><%=Start_Date%>&nbsp;</td>
			<td class="bodyText datacol"><%=End_Date%>&nbsp;</td>
			<td class="bodyText spacercell">&nbsp;</td>
		</tr>
		<%
			i = i + 1
			if CBool(findNeedleInHayStack(arOpenedNodes, Element_ID, "true")) and boolHasChildren then
				NestLevel = NestLevel + 1
				WriteTree Element_ID, thisOpenString
				NestLevel = NestLevel - 1
			end if
			
			z = z + 1
			objTreeRec.MoveNext
			Response.Flush
		Loop
	end if
	
	if p_Parent_Element_ID = 0 then
	%>
	</table>
	<input type="hidden" name="selectedItemID" value="-1" ID="selectedItemID">
	<input type="hidden" name="hoveredItemID" value="-1" ID="hoveredItemID">
	<input type="hidden" name="open" value="<%=strOpenedNodes%>" ID="Hidden4">
	</form>

	<script language=javascript>
		//printEvaluator();
	</script>

	<%
	end if
	
	if objTreeRec.State <> adStateClosed then
		On Error Resume Next
		objTreeRec.Close
	end if
End Sub


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
%>


