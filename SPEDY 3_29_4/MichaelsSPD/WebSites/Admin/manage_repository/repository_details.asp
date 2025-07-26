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
Dim Security
Set Security = New cls_Security
Security.Initialize Session.Value("UserID"), "ADMIN.CONTENT.REPOSITORY.CATEGORY", checkQueryID(Trim(Request("cid")), 0)

Dim arRecRows, dictRecCols
Dim rowCounter, curIteration, displayCount', numFound
Dim SQLStr, connStr
Dim rowcolor, i, categoryID
Dim strToolTip
Dim SortColumn, SortDirection, xmlSearchCriteria
Dim Repository_Details_ID, Topic_ID
Dim Topic_Name
Dim Topic_Type
Dim Type1_FileName, Type1_FileSize
Dim Locked
Dim Lock_Owner_UserName
Dim Lock_Owner_Email_Address
Dim Lock_Owner_ID
Dim Date_Locked
Dim Status_Name
Dim Date_Last_Modified
Dim Date_Created
Dim Language_PrettyName
Dim taskStr, separatorStr, boolCanOverrideLock
Dim numFound, startRow, pageSize, curPage, pageCount
Dim outputToExcel, Filter_ID, bolSaveSearch
Dim numFilterParamsWrittenSoFar, numSortParamsWrittenSoFar

Dim selectWhat
Dim chosenContent
Dim selectFilterTextType
Dim filterText
Dim selectStatus
Dim chosenStatus
Dim selectStartEndDateType
Dim selectStartEndDateWhen
Dim txtStartEndDate_StartDate
Dim txtStartEndDate_StartTime
Dim txtStartEndDate_EndDate
Dim txtStartEndDate_EndTime
Dim StartEndDate_StartDate
Dim StartEndDate_EndDate
Dim selectLanguage
Dim chosenLanguage
Dim selectHow
Dim selectWhen
Dim txtStartDate
Dim txtStartTime
Dim txtEndDate
Dim txtEndTime
Dim StartDate
Dim EndDate
Dim selectWho
Dim chosenUser
Dim chosenGroup

Dim querystring
Dim searchString, tempSearchString, tmpSearchSQLStrOut
Dim arWords, wnum
Dim SQT, conjunction

'Get Category ID
categoryID = checkQueryID(Trim(Request("cid")), 0)

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

'Save Search?
if Len(Trim(SmartValues(Request("Save_Search_Name"), "CStr"))) > 0 then
	bolSaveSearch = true
	Filter_ID = SaveSearch(0, "ADMIN.CONTENT", Trim(SmartValues(Request("Save_Search_Name"), "CStr")))
else
	bolSaveSearch = false
	Filter_ID = 0
end if

'Get the Sort Column
SortColumn = Trim(Request("sort"))
if IsNumeric(SortColumn) and Trim(SortColumn) <> "" then
	SortColumn = CInt(SortColumn)
	Session.Value("Content_Repository_SortColumn") = SortColumn
else
	if IsNumeric(Session.Value("Content_Repository_SortColumn")) and Trim(Session.Value("Content_Repository_SortColumn")) <> "" then
		SortColumn = CInt(Session.Value("Content_Repository_SortColumn"))
	else
		SortColumn = 0
		Session.Value("Content_Repository_SortColumn") = SortColumn
	end if
end if

'Get the Sort Direction
SortDirection = Trim(Request("direction"))
if IsNumeric(SortDirection) and Trim(SortDirection) <> "" then
	SortDirection = CInt(SortDirection)
	Session.Value("Content_Repository_SortDirection") = SortDirection
else
	if IsNumeric(Session.Value("Content_Repository_SortDirection")) and Trim(Session.Value("Content_Repository_SortDirection")) <> "" then
		SortDirection = CInt(Session.Value("Content_Repository_SortDirection"))
	else
		SortDirection = 0
		Session.Value("Content_Repository_SortDirection") = SortDirection
	end if
end if

Set dictRecCols	= Server.CreateObject("Scripting.Dictionary")
connStr = Application.Value("connStr")

if categoryID >= 0 then
	querystring = "cid=" & Request("cid")
	SQLStr = "sp_repository_content_by_catID_showdefault_lang " & categoryID & ", " & SortColumn & ", " & SortDirection & ", " & pageSize & ", " & startRow
	'Response.Write SQLStr
else
	
	'Get the XML String
	xmlSearchCriteria = GenerateXMLString()

	querystring = querystring & "&cid=" & categoryID
	
	'ALTER PROCEDURE sp_repository_content_search
	'  @xmlSortCriteria varchar(8000) = NULL,
	'  @maxRows int = -1,
	'  @startRow int = 0,
	'  @printDebugMsgs bit = 0
	SQLStr = "sp_repository_content_search '" & xmlSearchCriteria & "', '" & pageSize & "', '" & startRow & "', 0"
	'Response.Write Server.HTMLEncode(SQLStr) & "<br><br>" & vbCrLf & vbCrLf
	
	'Output to Excel
	outputToExcel = CBool(checkQueryID(Trim(Request("excel")), 0))
	if outputToExcel then
		Call OutputToExcelDocument(xmlSearchCriteria)
	end if

end if
Call returnDataWithGetRows(connStr, SQLStr, arRecRows, dictRecCols)

Dim strPermissionStr, thisUserID
Dim isPublished, canEdit, canView, canModifyStatus, canLock, canUnlock, canOverrideLock, canRequestApproval, canClone, canMove, canDelete, canCreateNew
thisUserID = CLng(Session.Value("UserID"))

boolCanOverrideLock = false
separatorStr = "&nbsp;&nbsp;|&nbsp;"

if CBool(findNeedleInHayStack(Split(Session.Value("Security_Role_List"),","), "9", "true")) or CBool(findNeedleInHayStack(Split(Session.Value("Security_Role_List"),","), "6", "true")) then
	boolCanOverrideLock = true
end if

if dictRecCols("ColCount") > 0 and dictRecCols("RecordCount") > 0 then
	numFound = CLng(dictRecCols("RecordCount"))
	for rowCounter = 0 to numFound - 1
		Topic_ID = 0
		Repository_Details_ID = 0
		Locked = false
		Lock_Owner_ID = 0
		isPublished = ""

		if not IsNull(arRecRows(dictRecCols("Topic_ID"), rowCounter)) then Topic_ID = CInt(arRecRows(dictRecCols("Topic_ID"), rowCounter))
		if not IsNull(arRecRows(dictRecCols("ID"), rowCounter)) then Repository_Details_ID = CInt(arRecRows(dictRecCols("ID"), rowCounter))
		if not IsNull(arRecRows(dictRecCols("Locked"), rowCounter)) then Locked = CBool(arRecRows(dictRecCols("Locked"), rowCounter))
		if not IsNull(arRecRows(dictRecCols("Lock_Owner_ID"), rowCounter)) then Lock_Owner_ID = CLng(arRecRows(dictRecCols("Lock_Owner_ID"), rowCounter))
		if not IsNull(arRecRows(dictRecCols("isPublished"), rowCounter)) then isPublished = CInt(arRecRows(dictRecCols("isPublished"), rowCounter))
		
		isPublished = 0
		canEdit = 0
		canView = 0
		canModifyStatus = 0
		canLock = 0
		canUnlock = 0
		canOverrideLock = 0
		canRequestApproval = 1
		canClone = 1
		canMove = 0
		canDelete = 0
		canCreateNew = 1
		
		canView = 1
		if not Locked or (Locked and Lock_Owner_ID = thisUserID) then
			canEdit = 1
			canModifyStatus = 1
			canMove = 1
			canDelete = 1
		end if
		if Locked and (Lock_Owner_ID = thisUserID) then
			canUnlock = 1
			canRequestApproval = 1
			canMove = 1
			canDelete = 1
		elseif Locked and (Lock_Owner_ID <> thisUserID) and boolCanOverrideLock then 
			canOverrideLock = 1
			canRequestApproval = 0
		else
			canLock = 1
			canMove = 1
			canDelete = 1
		end if
		
		strPermissionStr = strPermissionStr & vbCrLf & vbTab & vbTab
		strPermissionStr = strPermissionStr & "arRowPermissions[" & Topic_ID & "] = new rowPermissions("
		strPermissionStr = strPermissionStr & isPublished & ","
		strPermissionStr = strPermissionStr & canEdit & ","
		strPermissionStr = strPermissionStr & canView & ","
		strPermissionStr = strPermissionStr & canModifyStatus & ","
		strPermissionStr = strPermissionStr & canLock & ","
		strPermissionStr = strPermissionStr & canUnlock & ","
		strPermissionStr = strPermissionStr & canOverrideLock & ","
		strPermissionStr = strPermissionStr & canRequestApproval & ","
		strPermissionStr = strPermissionStr & canClone & ","
		strPermissionStr = strPermissionStr & canMove & ","
		strPermissionStr = strPermissionStr & canDelete & ","
		strPermissionStr = strPermissionStr & canCreateNew & ","
		strPermissionStr = strPermissionStr & Repository_Details_ID & ");"

	next
end if 
%>
<html>
<head>
	<title>View All Content</title>
	<style type="text/css">

		A {text-decoration: none; cursor: hand;}
		A:HOVER {text-decoration: none; color: #0000ff; cursor: hand;}
		.rover * {background-color: #ffff99}
		.selectedRow * {background-color: #cccccc; color: #000000}

	</style>
	<script language="javascript" src="../app_include/lockscroll.js"></script><!--locked headers code-->
	<link rel="stylesheet" href="../app_include/contextmenu.css" type="text/css" media="screen"><!--right click styles-->
	<script language="javascript" src="./include/repository_details_contextmenu.js"></script><!--right click menu-->
	<!-- script language="javascript" src="./../app_include/security_cls_security.js"></script-->
	<script language=javascript>

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
		
		function openItemApprovalWindow(RowID)
		{
			approvalWin = window.open("./../manage_workflow/approval/approval.asp?rid=" + RowID + "&rsrc=1", "approvalWindow_" + RowID, "width=550,height=470,toolbar=0,location=0,directories=0,status=1,menuBar=0,scrollBars=1,resizable=1");
			approvalWin.focus();
		}

		function openItemEditorWindow(RowID)
		{
			editWin = window.open("./document_admin/document_details_frm.asp?cid=<%=categoryID%>&tid=" + RowID, "editWindow_" + RowID, "width=800,height=600,toolbar=0,location=0,directories=0,status=1,menuBar=0,scrollBars=1,resizable=1");
			editWin.focus();
		}

		function editPublishedItem(RowID)
		{
			var msg = "This document is currently Published to a website.\nYou may not directly edit a Published document,\nbut you may edit a COPY of this document.";
			msg = msg + "\n\nWould you like to edit a COPY of this document?";
			msg = msg + "\n";
			msg = msg + "\nClick 'OK' to edit a COPY of this document";
			msg = msg + "\nClick 'Cancel' to cancel.";
			if (confirm(msg))
			{
				editWin = window.open("./document_admin/document_details_frm.asp?pub=1&cid=<%=categoryID%>&tid=" + RowID, "editWindow_" + RowID, "width=700,height=550,toolbar=0,location=0,directories=0,status=1,menuBar=0,scrollBars=1,resizable=0");
				editWin.focus();
			}
		}

		function lockOverride(lockOwnerName, RowID)
		{
			var msg = "This document is currently locked by " + lockOwnerName + ".\nYou have requested to cancel their document lock.";
			msg = msg + "\n\nAny changes this user is currently making to this\ndocument will be lost, and the user will be locked\nout until you unlock the document.";
			msg = msg + "\n\nContinue?";
			msg = msg + "\n";
			msg = msg + "\nClick 'OK' to edit a UNLOCK of this document";
			msg = msg + "\nClick 'Cancel' to cancel.";
			if (confirm(msg))
			{
				document.lockOverRideForm.tid.value = RowID;
				document.lockOverRideForm.lock.value = "1";
				document.lockOverRideForm.action = "content_lock.asp";
				document.lockOverRideForm.submit();
			}
		}

		function openItemMoveWindow(RowID)
		{
			moveWin = window.open("./document_admin/document_move.asp?tid=" + RowID, "moveWindow_" + RowID, "width=300,height=300,toolbar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=1,resizable=0");
			moveWin.focus();
		}

		function openItemStatusWindow(RowID)
		{
			statusWin = window.open("./document_admin/document_status.asp?tid=" + RowID, "statusWindow_" + RowID, "width=300,height=100,toolbar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=1,resizable=1");
			statusWin.focus();
		}

		function openItemCopyWindow(RowID)
		{
			copyWin = window.open("./document_admin/document_copy.asp?tid=" + RowID, "copyWindow_" + RowID, "width=300,height=300,toolbar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=1,resizable=0");
			copyWin.focus();
		}

		function deleteDocument(RowID)
		{
			if (confirm("Really remove this document?\n\nThis cannot be undone!"))
			{
				document.location = "./document_admin/document_remove.asp?cid=<%=categoryID%>&tid=" + RowID + "&sort=" + <%=SortColumn%> + "&direction=" + <%=SortDirection%>;
			}
		}
		
		function copyItemHere(RowID)
		{
			document.location = "./document_admin/document_copyhere.asp?cid=<%=categoryID%>&tid=" + RowID + "&sort=" + <%=SortColumn%> + "&direction=" + <%=SortDirection%>;
		}
		
		function launchFileWin(myLoc, myName)
		{
				var myFeatures = "directories=0,dependent=1,width=800,height=600,hotkeys=0,location=0,menubar=0,resizable=1,screenX=10,screenY=10,scrollbars=1,titlebar=0,toolbar=0,status=0";
				var newWin = window.open(myLoc, myName, myFeatures);
		}
		
		function showPreview(field)
		{
			previewWin = window.open('./content_preview.asp?tid=' + escape(field), 'previewWin', 'width=600,height=500,toolbar=0,location=0,directories=0,status=1,menuBar=0,scrollBars=1,resizable=1');
			previewWin.focus();
		}
		
	//	var Security = new cls_Security("<%=Security.CurrentUserGUID%>");
		
		function checkMenuElement(checkValue, menuItemID)
		{
		//	alert(menuItemID)
			if (checkValue == true)
			{
				if (document.getElementById(menuItemID)) document.getElementById(menuItemID).className = "menuItem";
				if (document.getElementById(menuItemID + "_Separator")) document.getElementById(menuItemID + "_Separator").className = "menuSeparator";
			}
			else
			{
				if (document.getElementById(menuItemID)) document.getElementById(menuItemID).className = "menuItemHidden";
				if (document.getElementById(menuItemID + "_Separator")) document.getElementById(menuItemID + "_Separator").className = "menuItemHidden";
			}
		}

		function configureOptions(RowID)
		{
			if (isNaN(RowID)) return;
		
			//check row-level permissions for the selected row
			/*
			checkMenuElement(Security.isRequestedAccessToObjectAllowed("ADMIN.CONTENT.REPOSITORY.CATEGORY", "CATEDIT", RowID), "ItemEdit");
			checkMenuElement(Security.isRequestedAccessToObjectAllowed("ADMIN.CONTENT.REPOSITORY.CATEGORY", "CATEDIT", RowID), "ItemView");
			checkMenuElement(Security.isRequestedAccessToObjectAllowed("ADMIN.CONTENT.REPOSITORY.CATEGORY", "CATEDIT", RowID), "ItemStatus");
			checkMenuElement(Security.isRequestedAccessToObjectAllowed("ADMIN.CONTENT.REPOSITORY.CATEGORY", "CATEDIT", RowID), "ItemLock");
			checkMenuElement(Security.isRequestedAccessToObjectAllowed("ADMIN.CONTENT.REPOSITORY.CATEGORY", "CATEDIT", RowID), "ItemUnlock");
			checkMenuElement(Security.isRequestedAccessToObjectAllowed("ADMIN.CONTENT.REPOSITORY.CATEGORY", "CATEDIT", RowID), "ItemOverridelock");
			checkMenuElement(Security.isRequestedAccessToObjectAllowed("ADMIN.CONTENT.REPOSITORY.CATEGORY", "CATEDIT", RowID), "ItemApproval");
			checkMenuElement(Security.isRequestedAccessToObjectAllowed("ADMIN.CONTENT.REPOSITORY.CATEGORY", "CATEDIT", RowID), "ItemCopy");
			checkMenuElement(Security.isRequestedAccessToObjectAllowed("ADMIN.CONTENT.REPOSITORY.CATEGORY", "CATEDIT", RowID), "ItemCopyHere");
			checkMenuElement(Security.isRequestedAccessToObjectAllowed("ADMIN.CONTENT.REPOSITORY.CATEGORY", "CATEDIT", RowID), "ItemMove");
			checkMenuElement(Security.isRequestedAccessToObjectAllowed("ADMIN.CONTENT.REPOSITORY.CATEGORY", "CATEDIT", RowID), "ItemDelete");
			checkMenuElement(Security.isRequestedAccessToObjectAllowed("ADMIN.CONTENT.REPOSITORY.CATEGORY", "CATEDIT", RowID), "ItemAdd");
			*/
			checkMenuElement(true, "ItemEdit");
			checkMenuElement(true, "ItemView");
			checkMenuElement(true, "ItemStatus");
			checkMenuElement(true, "ItemLock");
			checkMenuElement(true, "ItemUnlock");
			checkMenuElement(true, "ItemOverridelock");
			checkMenuElement(true, "ItemApproval");
			checkMenuElement(true, "ItemCopy");
			checkMenuElement(true, "ItemCopyHere");
			checkMenuElement(true, "ItemMove");
			checkMenuElement(true, "ItemDelete");
			checkMenuElement(true, "ItemAdd");

			//check overall permissions, so, if the user doesnt have any object-specific rights, they'll 
			//be able to do the following if they've been granted access...
			checkMenuElement(true, "ItemView");
			
			//NOTE: Members of the sysadmins role can access everything.
		}

/*
		function configureOptions(RowID)
		{
			if (isNaN(RowID))
				return;
		
			if (!arRowPermissions[RowID])
				return;
				
			checkMenuElement(arRowPermissions[RowID].canEdit, "ItemEdit");
			checkMenuElement(arRowPermissions[RowID].canView, "ItemView");
			checkMenuElement(arRowPermissions[RowID].canModifyStatus, "ItemStatus");
			checkMenuElement(arRowPermissions[RowID].canLock, "ItemLock");
			checkMenuElement(arRowPermissions[RowID].canUnlock, "ItemUnlock");
			checkMenuElement(arRowPermissions[RowID].canOverrideLock, "ItemOverridelock");
		//	checkMenuElement(arRowPermissions[RowID].canRequestApproval, "ItemApproval");
			checkMenuElement(arRowPermissions[RowID].canClone, "ItemCopy");
			checkMenuElement(arRowPermissions[RowID].canMove, "ItemMove");
			checkMenuElement(arRowPermissions[RowID].canDelete, "ItemDelete");
			checkMenuElement(arRowPermissions[RowID].canCreateNew, "ItemAdd");
				
			if (document.getElementById("ItemOverridelock").className == 'menuItemDisabled')
			{
				document.getElementById("ItemLock").style.display = "";
				document.getElementById("ItemUnlock").style.display = "";
				document.getElementById("ItemOverridelock").style.display = "none";
			}
			else
			{
				document.getElementById("ItemLock").style.display = "none";
				document.getElementById("ItemUnlock").style.display = "none";
				document.getElementById("ItemOverridelock").style.display = "";
			}
		}
		
		function checkMenuElement(checkValue, menuItemID)
		{
			if (checkValue == "1")
				document.getElementById(menuItemID).className = "menuItem";
			else
				document.getElementById(menuItemID).className = "menuItemDisabled";

		}
		
		function rowPermissions(isPublished, canEdit, canView, canModifyStatus, canLock, canUnlock, canOverrideLock, canRequestApproval, canClone, canMove, canDelete, canCreateNew, RepositoryDetailsID)
		{
			this.isPublished = isPublished;
			this.canEdit = canEdit;
			this.canView = canView;
			this.canModifyStatus = canModifyStatus;
			this.canLock = canLock;
			this.canUnlock = canUnlock;
			this.canOverrideLock = canOverrideLock;
			this.canRequestApproval = canRequestApproval;
			this.canClone = canClone;
			this.canMove = canMove;
			this.canDelete = canDelete;
			this.canCreateNew = canCreateNew;
			this.RepositoryDetailsID = RepositoryDetailsID;
		}

		var arRowPermissions = new Array();
		<%=strPermissionStr%>
*/
		function clickMenu()
		{
			el = event.srcElement;
			if (el.className == "menuItemDisabled")
				return;

			hideMenu();
			var selectedItemID = document.theForm.selectedItemID.value;
			
			switch (el.id)
			{
				case "ItemEdit":
					openItemEditorWindow(selectedItemID);
					break;
				
				case "ItemEditPublished":
					editPublishedItem(selectedItemID);
					break;
				
				case "ItemView":
					showPreview(selectedItemID);
					break;
				
				case "ItemStatus":
					openItemStatusWindow(selectedItemID);
					break;
				
				case "ItemLock":
					document.theForm.action = "content_lock.asp?tid=" + selectedItemID + "&lock=1";
					document.theForm.submit();
					break;
				
				case "ItemUnlock":
					document.theForm.action = "content_lock.asp?tid=" + selectedItemID + "&lock=0";
					document.theForm.submit();
					break;

				case "ItemOverridelock":
					lockOverride("another user", selectedItemID);
					break;
				
				case "ItemApproval":
				//	openItemApprovalWindow(arRowPermissions[selectedItemID].RepositoryDetailsID);
					break;
				
				case "ItemCopy":
					openItemCopyWindow(selectedItemID);
					break;
				
				case "ItemCopyHere":
					copyItemHere(selectedItemID);
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

	</script>
</head>
<body bgcolor="ffffff" link="000000" vlink="000000" topmargin=0 leftmargin=0 rightmargin=0 marginheight=0 marginwidth=0 onLoad="initPlaceLayers();"><!-- oncontextmenu="return false;">-->
<div style="position: absolute; z-index:100; width:100%; height:1000px; top:0px; left:0px; filter:progid:DXImageTransform.Microsoft.Gradient(GradientType=0, StartColorStr='#339c9c9c', EndColorStr='#339c9c9c')" id="waitLyr" name="waitLyr">
	<div id="waitText" name="waitText" style="position: absolute; top:10px; left:10px; font-family:Arial, Helvetica;font-size:12px;color:#666666;">
		Gathering Data<br>
		Please Wait…
	</div>
	<img src="./images/spacer.gif" border=0 style="width:100%; height:1000px;">
</div>

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

<table width=100% cellpadding=0 cellspacing=0 border=0>
	<form name="theForm" action="" method="POST">
	<input type="hidden" name="selectedItemID" value="0">
	<input type="hidden" name="hoveredItemID" value="0">
	<tr>
		<td width=100%>
			<%
			rowCounter = 0
			if dictRecCols("ColCount") > 0 and dictRecCols("RecordCount") > 0 then
			%>
			<table cellpadding=0 cellspacing=0 onSelectStart="return false" width=100% border=0>
				<tr bgcolor=ffffff><td colspan=21><img src="./images/spacer.gif" height=2 width=1></td></tr>
				<%
				i = 0
				numFound = SmartValues(arRecRows(dictRecCols("totRecords"), rowCounter), "CInt")
				
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

				if numFound <= pageSize then
					displayCount = numFound
				else
					displayCount = pageSize
				end if
				
				for rowCounter = 0 to displayCount - 1
					if rowCounter >= dictRecCols("RecordCount") then exit for
					if i mod 2 = 1 then				
						rowcolor = "f3f3f3"
					else
						rowcolor = "ffffff"
					end if

					Topic_ID = 0
					Topic_Name = ""
					Topic_Type = ""
					Type1_FileName = ""
					Type1_FileSize = ""
					Locked = ""
					Lock_Owner_UserName = ""
					Lock_Owner_Email_Address = ""
					Lock_Owner_ID = 0
					Date_Locked = ""
					isPublished = ""
					Status_Name = ""
					Date_Last_Modified = ""
					Date_Created = ""
					Language_PrettyName = ""

					if not IsNull(arRecRows(dictRecCols("Topic_ID"), rowCounter)) then Topic_ID = arRecRows(dictRecCols("Topic_ID"), rowCounter)
					if not IsNull(arRecRows(dictRecCols("Topic_Name"), rowCounter)) then Topic_Name = arRecRows(dictRecCols("Topic_Name"), rowCounter)
					if not IsNull(arRecRows(dictRecCols("Topic_Type"), rowCounter)) then Topic_Type = arRecRows(dictRecCols("Topic_Type"), rowCounter)
					if not IsNull(arRecRows(dictRecCols("Type1_FileName"), rowCounter)) then Type1_FileName = arRecRows(dictRecCols("Type1_FileName"), rowCounter)
					if not IsNull(arRecRows(dictRecCols("Type1_FileSize"), rowCounter)) then Type1_FileSize = arRecRows(dictRecCols("Type1_FileSize"), rowCounter)
					if not IsNull(arRecRows(dictRecCols("Locked"), rowCounter)) then Locked = arRecRows(dictRecCols("Locked"), rowCounter)
					if not IsNull(arRecRows(dictRecCols("Lock_Owner_UserName"), rowCounter)) then Lock_Owner_UserName = arRecRows(dictRecCols("Lock_Owner_UserName"), rowCounter)
					if not IsNull(arRecRows(dictRecCols("Lock_Owner_Email_Address"), rowCounter)) then Lock_Owner_Email_Address= arRecRows(dictRecCols("Lock_Owner_Email_Address"), rowCounter)
					if not IsNull(arRecRows(dictRecCols("Lock_Owner_ID"), rowCounter)) then Lock_Owner_ID = arRecRows(dictRecCols("Lock_Owner_ID"), rowCounter)
					if not IsNull(arRecRows(dictRecCols("Date_Locked"), rowCounter)) then Date_Locked = arRecRows(dictRecCols("Date_Locked"), rowCounter)
					if not IsNull(arRecRows(dictRecCols("isPublished"), rowCounter)) then isPublished = arRecRows(dictRecCols("isPublished"), rowCounter)
					if not IsNull(arRecRows(dictRecCols("Status_Name"), rowCounter)) then Status_Name = arRecRows(dictRecCols("Status_Name"), rowCounter)
					if not IsNull(arRecRows(dictRecCols("Date_Last_Modified"), rowCounter)) then Date_Last_Modified = arRecRows(dictRecCols("Date_Last_Modified"), rowCounter)
					if not IsNull(arRecRows(dictRecCols("Date_Created"), rowCounter)) then Date_Created = arRecRows(dictRecCols("Date_Created"), rowCounter)
					if not IsNull(arRecRows(dictRecCols("Language_PrettyName"), rowCounter)) then Language_PrettyName = arRecRows(dictRecCols("Language_PrettyName"), rowCounter)
				%>
				<%if i > 0 then%>
				<tr bgcolor=e6e6e6><td colspan=17><img src="./images/spacer.gif" height=1 width=1></td></tr>
				<%end if%>
				<tr bgcolor=<%=rowcolor%> id="datarow_<%=Topic_ID%>" onMouseOver="HoverRow(<%=Topic_ID%>);" onMouseOut="HoverRow(0);" onDblClick="highlightRow();" oncontextmenu="HoverRow(<%=Topic_ID%>);SelectRow(<%=Topic_ID%>);displayMenu(); return false;">
					<td><img src="./images/spacer.gif" height=1 width=5></td>
					<td valign=top nowrap>
						<table cellpadding=0 cellspacing=0 border=0>
							<tr>
								<td valign=top><img src="../app_images/app_icons/<%=findItemIcon(CInt(Topic_Type), Type1_FileName, 1)%>" border=0></td>
								<td><img src="./images/spacer.gif" height=1 width=2></td>
								<td valign=top nowrap>
									<font style="font-family:Arial, Helvetica;font-size:11px;">
									<%
									if CBool(Locked) = false or (CBool(Locked) = true and CLng(Lock_Owner_ID) = CLng(Session.Value("UserID"))) then
										if Security.isRequestedPrivilegeAllowed("ADMIN.CONTENT.REPOSITORY.CATEGORY", "CATEDIT") then
									%>
									<a href="javascript:openItemEditorWindow(<%=Topic_ID%>); void(0);"><%if not IsNull(Topic_Name) then Response.Write Server.HTMLEncode(Topic_Name) end if%></a>
									<%
										else
									%>
									<a href="javascript:showPreview(<%=Topic_ID%>); void(0);"><%if not IsNull(Topic_Name) then Response.Write Server.HTMLEncode(Topic_Name) end if%></a>
									<%
										end if
									else
										if not IsNull(Topic_Name) then
											Response.Write Server.HTMLEncode(Topic_Name)
										end if
									end if
									%>
									</font>
								</td>
							</tr>
						</table>
					</td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td><a href="" onMouseOver="hTaskBtn('taskIcon<%=Topic_ID%>', true)"  onMouseOut="hTaskBtn('taskIcon<%=Topic_ID%>', false)" onClick="SelectRow(<%=Topic_ID%>);HoverRow(<%=Topic_ID%>);this.parentElement.parentElement.click(); displayMenu(); return false;"><img id="taskIcon<%=Topic_ID%>" src="./../app_images/tasks_icon_off.gif" height=16 width=24 alt=":: Click to access tasks ::" border=0></a></td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap><font style="font-family:Arial, Helvetica;font-size:11px;"><%if Topic_Type = 1 then%><%=Type1_FileName%><%end if%></font></td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap align=right><font style="font-family:Arial, Helvetica;font-size:11px;"><%if Topic_Type = 1 then%><%=FormatFileSize(Type1_FileSize)%><%end if%></font></td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap><font style="font-family:Arial, Helvetica;font-size:11px;"><%=Status_Name%></font></td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap><font style="font-family:Arial, Helvetica;font-size:11px;"><%if CBool(Locked) then Response.Write "<a href=""mailto:" & Server.HTMLEncode(Lock_Owner_Email_Address) & """ target=""_blank"">" & Server.HTMLEncode(Lock_Owner_UserName) & "</a>" end if%></font></td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap><font style="font-family:Arial, Helvetica;font-size:11px;"><%if CBool(Locked) then Response.Write Date_Locked end if%></font></td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap><font style="font-family:Arial, Helvetica;font-size:11px;"><%if CBool(isPublished) then Response.Write "Published" end if%></font></td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap><font style="font-family:Arial, Helvetica;font-size:11px;"><%=Date_Last_Modified%></font></td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap><font style="font-family:Arial, Helvetica;font-size:11px;"><%=Date_Created%></font></td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap><font style="font-family:Arial, Helvetica;font-size:11px;"><%=Language_PrettyName%></font></td>
					<td width=100%><img src="./images/spacer.gif" height=1 width=5></td>
				</tr>
				<%
				i = i + 1
				Next
				%>
				<tr>
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
				</tr>
			</table>
			<script language="javascript">
			<!--
				waitLyr.style.display = "none";
				parent.frames["DetailFrameHdr"].document.location = "repository_details_header.asp?sort=<%=SortColumn%>&direction=<%=SortDirection%>&q=<%= Server.URLEncode(querystring) %>";
				parent.frames["PagingNavFrame"].document.location = "./../app_include/paging_navbar.asp?loc=<%=Request.ServerVariables("SCRIPT_NAME")%>&frm=DetailFrame&pageCount=<%=pageCount%>&curPage=<%=curPage%>&pageSize=<%=pageSize%>&numFound=<%=numFound%>&q=<%= Server.URLEncode(querystring) %>";
			//-->
			</script>
			<%
			else
			%>
			<script language="javascript">
			<!--
				waitLyr.style.display = "none";
				parent.frames["DetailFrameHdr"].document.location = "./../app_include/blank_999999.html";
				parent.frames["PagingNavFrame"].document.location = "./../app_include/blank_cccccc.html";
			//-->
			</script>
			<%
			end if
			%>
		</td>
	</tr>
	</form>
</table>
<form name="lockOverRideForm" action="" method="POST">
<input type=hidden name="tid" value="">
<input type=hidden name="lock" value="">
</form>
<!--#include file="./include/repository_details_contextmenu.asp"--><!--right click menu-->
</body>
</html>
<%

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
			Case 0
				strOutput = strIconPath & content_icon_root
			Case 1
				strOutput = strIconPath & file_icon_root
			Case 2
				strOutput = strIconPath & link_icon_root
			Case 3
				strOutput = strIconPath & list_icon_root
			Case 4
				strOutput = strIconPath & portal_icon_root
		End Select
	end if
	
	findItemIcon = strOutput
end function

function findTopicType(intTopicType)
	if IsNumeric(intTopicType) then
		Dim strOutput
		Select Case intTopicType
			Case 0
				strOutput = "Web Document"
			Case 1
				strOutput = "File"
			Case 2
				strOutput = "Web Link"
			Case 3
				strOutput = "Web List"
			Case 4
				strOutput = "Web Portal"
			Case Else
				strOutput = ""
		End Select
	end if
	findTopicType = strOutput
end function

sub appendFilterParameter(ByRef p_xmlStr, p_colOrd, p_filterParam)
	numFilterParamsWrittenSoFar = numFilterParamsWrittenSoFar + 1
	if not IsNull(p_filterParam) then
		p_xmlStr = p_xmlStr & "<Parameter FilterID=""" & numFilterParamsWrittenSoFar & """ intColOrdinal=""" & p_colOrd & """>" & p_filterParam & "</Parameter>"
	else
		p_xmlStr = p_xmlStr & "<Parameter FilterID=""" & numFilterParamsWrittenSoFar & """ intColOrdinal=""" & p_colOrd & """ />"
	end if
end sub

sub appendSortParameter(ByRef p_xmlStr, p_colOrd, p_sortDir)
	numSortParamsWrittenSoFar = numSortParamsWrittenSoFar + 1
	p_xmlStr = p_xmlStr & "<Parameter SortID=""" & numSortParamsWrittenSoFar & """ intColOrdinal=""" & p_colOrd & """ intDirection=""" & p_sortDir & """ />"
end sub

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

	'Loop through Hidden Parameters
	if Len(Trim(SmartValues(Request("filterHiddenParams"), "CStr"))) > 0 then
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

	ExcelSQLStr = "sp_repository_content_search_to_Excel '" & xmlStr & "', 0, 0, '" & Physical_Path & "', 0"
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

Set dictRecCols = Nothing
%>