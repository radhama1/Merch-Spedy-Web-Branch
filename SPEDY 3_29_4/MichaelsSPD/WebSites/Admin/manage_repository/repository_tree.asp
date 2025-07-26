<%@ Language=VBScript %> 
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441
%>
<!--#include file="./../app_include/_globalInclude.asp"-->
<%
Dim Security
Set Security = New cls_Security
Security.Initialize Session.Value("UserID"), "ADMIN.CONTENT.REPOSITORY.CATEGORY", 0

Dim i
Dim strOpenElements, expandall

expandall = Trim(Request("expandall"))
if IsNumeric(expandall) and Trim(expandall) <> "" then
	expandall = CBool(expandall)
else
	expandall = false
end if

strOpenElements = Trim(Request("open"))
if Len(Trim(strOpenElements)) > 0 then
	strOpenElements = CStr(strOpenElements)
else
	strOpenElements = ""
end if

'Response.Write strOpenElements & " xxxxxxxxxx"
%>
<!-- #include file="repository_tree_routines.asp" -->
<html>
<head>
	<link rel="stylesheet" type="text/css" href="../app_include/folderlist/style.css">
	<link rel="stylesheet" href="../app_include/contextmenu.css" type="text/css" media="screen"><!--right click styles-->
	<style type="text/css">
	</style>
	<script language=javascript>
		var iconImgPath = "./../app_images/folderlist_icons/";	
	</script>
	<script language="javascript" src="./include/repository_tree_contextmenu.js"></script><!--right click menu-->
	<script language="javascript" src="./../app_include/folderlist/functions.js"></script>
	<!-- script language="javascript" src="./../app_include/security_cls_security.js"></script-->
	<script language="javascript" src="./../app_include/evaluator.js"></script>
	<script language=javascript>
		var Security;
		function initSecurity()
		{
		//	Security = new cls_Security("<%=Security.CurrentUserGUID%>");
		}
		
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
			checkMenuElement(Security.isRequestedAccessToObjectAllowed("ADMIN.CONTENT.REPOSITORY.CATEGORY", "CATEDIT", RowID), "CatAdd");
			checkMenuElement(Security.isRequestedAccessToObjectAllowed("ADMIN.CONTENT.REPOSITORY.CATEGORY", "CATEDIT", RowID), "ItemAdd");
			checkMenuElement(Security.isRequestedAccessToObjectAllowed("ADMIN.CONTENT.REPOSITORY.CATEGORY", "CATEDIT", RowID), "CatEdit");
			checkMenuElement(Security.isRequestedAccessToObjectAllowed("ADMIN.CONTENT.REPOSITORY.CATEGORY", "CATEDIT", RowID), "CatMove");
			checkMenuElement(Security.isRequestedAccessToObjectAllowed("ADMIN.CONTENT.REPOSITORY.CATEGORY", "CATEDIT", RowID), "CatDelete");
			*/
			checkMenuElement(true, "CatAdd");
			checkMenuElement(true, "ItemAdd");
			checkMenuElement(true, "CatEdit");
			checkMenuElement(true, "CatMove");
			checkMenuElement(true, "CatDelete");
			
			//check overall permissions, so, if the user doesnt have any object-specific rights, they'll 
			//be able to do the following if they've been granted access...
			/*
			checkMenuElement(Security.isRequestedPrivilegeAllowed("ADMIN.CONTENT.REPOSITORY.CATEGORIES", "CATTOPLEVELADD"), "CatAddTop");
			checkMenuElement(Security.isRequestedPrivilegeAllowed("ADMIN.CONTENT.REPOSITORY.CATEGORIES", "CATTOPLEVELADD"), "ItemAddTop");
			*/
			checkMenuElement(true, "CatAddTop");
			checkMenuElement(true, "ItemAddTop");

			//NOTE: Members of the sysadmins role can access everything.
		}
		
		function clickMenu()
		{
			hideMenu();
			el = event.srcElement;
			
			var myFeatures = "";
			var dialogResult = "";
			
			switch (el.id)
			{				
				case "CatAdd":
					openNewCatWindow();
					break;
				
				case "CatAddTop":
					openNewCatWindow();
					break;
				
				case "CatEdit":
					openCatEditorWindow();
					break;
				
				case "CatMove":
					openCatMoveWindow();
					break;
				
				case "CatDelete":
					deleteCategory();
					break;
				
				case "ItemAdd":
					openNewDocumentWindow();
					break;
				
				case "ItemAddTop":
					openNewDocumentWindow();
					break;
				
				default:
					break;
			}
		}

		function openNewCatWindow()
		{
			newCatWin = window.open("./category_admin/category_details_frm.asp?pcid=" + selectedItemID, "newCatWindow_" + selectedItemID, "width=500,height=500,toolbar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=0,resizable=1");
			newCatWin.focus();
		}

		function openCatEditorWindow()
		{
			editWin = window.open("./category_admin/category_details_frm.asp?cid=" + selectedItemID, "editCatWindow_" + selectedItemID, "width=500,height=500,toolbar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=0,resizable=1");
			editWin.focus();
		}

		function openCatMoveWindow()
		{
			moveWin = window.open("./category_admin/category_move.asp?cid=" + selectedItemID, "moveCatWindow_" + selectedItemID, "width=300,height=300,toolbar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=1,resizable=0");
			moveWin.focus();
		}

		function openNewDocumentWindow()
		{
			newDocWin = window.open("./document_admin/document_details_frm.asp?cid=" + selectedItemID + "&tid=0", "newDocWindow_" + selectedItemID, "width=800,height=610,toolbar=0,location=0,directories=0,status=1,menuBar=0,scrollBars=1,resizable=1");
			newDocWin.focus();
		}

		function deleteCategory()
		{
			if (confirm("Really remove this category?\n\nThis cannot be undone!"))
			{
				if (confirm("All categories and documents within this\ncategory will be moved up one level.\n\nContinue?"))
				{
					document.location = "./category_admin/category_remove.asp?cid=" + selectedItemID;
				}
			}
		}		
	</script>
</head>
<body bgcolor="ffffff" topmargin=0 leftmargin=0 rightmargin=0 marginheight=0 marginwidth=0 onLoad="initPlaceLayers();" oncontextmenu="return false;">

<div style="position: absolute; z-index:100; width:100%; height:1000px; top:0px; left:0px; filter:progid:DXImageTransform.Microsoft.Gradient(GradientType=0, StartColorStr='#339c9c9c', EndColorStr='#339c9c9c')" id="waitLyr" name="waitLyr">
	<div id="waitText" name="waitText" style="position: absolute; top:10px; left:10px; font-family:Arial, Helvetica;font-size:12px;color:#666666;">
		Gathering Data<br>
		Please Wait…
	</div>
	<!--<img src="./images/spacer.gif" border=0 style="width:100%; height:1000px;">-->
</div>

<%
Response.Flush

'On Error Resume Next
dim iTotal, sLeftIndent
dim bLoaded
Dim bLoadSubItems
Dim objDocument
Dim sOpenFolders
	
iTotal = 0
sLeftIndent = ""

'Check if we clicked an "on demand" folder
if (Request.Form <> "") then
	bLoadSubItems = true
else
	bLoadSubItems = false
end if

bLoaded = fnLoadXMLData(objDocument, bLoadSubItems)

if (bLoaded = true) then
	'Start building the menu table structure
%>
	<table border="0" cellspacing="0" cellpadding="0" width="100%">
		<tr>
			<td>
				<form name="frmMenu" action="menu.asp" method="post">
<!-- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: -->
<!-- :: Menu is written below                                                         :: -->
<!-- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: -->
				<%
				sOpenFolders = Request.Form("hdnOpenFolders")
				'response.write "sOpenFolders = " & sOpenFolders
				
				'This subroutine generates the HTML for the menu based on
				'data loaded into the XML object
				DisplayNode objDocument.childNodes, iTotal, sLeftIndent, sOpenFolders
				%>
				<input type="hidden" name="selectedItemID" value="-1">
				<input type="hidden" name="hoveredItemID" value="-1">
				<input type="hidden" name="hdnOpenFolders" value="<%=sOpenFolders%>">
<!-- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: -->
<!-- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: -->
				</form>
			</td>
		</tr>
	</table>
<%
end if
%>
<script language="javascript">
	//These two arrays work with each other to identify the menu element that should
	//be hidden or made visible.  There is a one-to-one relationship between
	//the rows of each array.  For example arClickedElementID(0) contains the
	//ID to access the element ID stored in arAffectedMenuItemID(0).
		
	//Note: The value of the ASP variable iTotal used below represents the
	//total number of items and subitems in the menu.  The value is set by
	//reference in the DisplayNode() subroutine call
	var arClickedElementID = new Array(<% for i = 1 to iTotal %> "<%=i%>"<%if i < iTotal then%>,<%end if%> <%next%>);
	var arAffectedMenuItemID = new Array(<% for i = 1 to iTotal %> "<%=i+1%>"<%if i < iTotal then%>,<%end if%> <%next%>);
		
	//printEvaluator();
</script>
<%
'Save the XML document in case we need to examine it for debuggin...
'objDocument.save ("c:\temp\temp.xml")

'Release memory reserved by XML object
Set objDocument	= Nothing

if err <> 0 then
	'We got an error, so display the message
	Response.Write err.description
end if
%>

<!--#include file="./include/repository_tree_contextmenu.asp"--><!--right click menu-->

<script language="javascript">waitLyr.style.display = "none";</script>
</body>
</html>