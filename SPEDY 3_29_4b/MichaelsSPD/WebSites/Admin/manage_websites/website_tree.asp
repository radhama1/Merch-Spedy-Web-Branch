<%@ Language=VBScript %>
<!--#include file="./../app_include/_globalInclude.asp"-->

<!-- #include file="website_tree_routines.asp" -->
<%'On Error Resume Next%>
<html>
<head>
	<link rel="stylesheet" type="text/css" href="../app_include/folderlist/style.css">
	<script language=javascript>
	<!--
		//tell the folderlist function where to find the folder tree icons...
		var iconImgPath = "./../app_images/folderlist_icons/websites/";	
	//-->
	</script>
	<script language="javascript" src="../app_include/folderlist/functions.js"></script>
	<style type="text/css">
	<!--
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
		}
	//-->
	</style>
	<script language=javascript>
	<!--
		function clickMenu()
		{
			hideMenu();
			el = event.srcElement;
			
			var myFeatures = "";
			var dialogResult = "";
			
			switch (el.id)
			{				
				case "SiteAdd":
					openNewSiteWindow();
					break;
				
				case "SiteEdit":
					openSiteEditWindow();
					break;
				
				case "SiteRename":
					openSiteRenameWindow();
					break;
				
				case "SiteDelete":
					deleteWebsite();
					break;
				
				default:
					break;
			}
		}

		function openNewSiteWindow()
		{
			newSiteWin = window.open("./website_admin/website_details_frm.asp?wid=0", "newSiteWindow_" + selectedItemID, "width=600,height=500,toolbar=0,location=0,directories=0,status=1,menuBar=0,scrollBars=0,resizable=1");
			newSiteWin.focus();
		}

		function openSiteEditWindow()
		{
			editSiteWin = window.open("./website_admin/website_details_frm.asp?wid=" + selectedItemID, "editSiteWindow_" + selectedItemID, "width=600,height=500,toolbar=0,location=0,directories=0,status=1,menuBar=0,scrollBars=0,resizable=1");
			editSiteWin.focus();
		}

		function openSiteRenameWindow()
		{
			renameSiteWin = window.open("./website_admin/website_rename.asp?webid=" + selectedItemID, "renameSiteWindow_" + selectedItemID, "width=300,height=150,toolbar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=0,resizable=1");
			renameSiteWin.focus();
		}

		function deleteWebsite(RowID)
		{
			if (confirm("Really remove this website?\n\nThis cannot be undone!"))
			{
				document.location = "./website_admin/website_remove.asp?webid=" + selectedItemID;
			}
		}
		
	//-->
	</script>
	<link rel="stylesheet" href="../app_include/contextmenu.css" type="text/css" media="screen"><!--right click styles-->
	<script language="javascript" src="./include/website_tree_contextmenu.js"></script><!--right click menu-->
</head>
<body bgcolor="ffffff" topmargin=0 leftmargin=0 rightmargin=0 marginheight=0 marginwidth=0 oncontextmenu="return false;" onLoad="initPlaceLayers();">
<%
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
<SCRIPT LANGUAGE="Javascript">
	<!--
		//These two arrays work with each other to identify the menu element that should
		//be hidden or made visible.  There is a one-to-one relationship between
		//the rows of each array.  For example arClickedElementID(0) contains the
		//ID to access the element ID stored in arAffectedMenuItemID(0).
			
		//Note: The value of the ASP variable iTotal used below represents the
		//total number of items and subitems in the menu.  The value is set by
		//reference in the DisplayNode() subroutine call
		var arClickedElementID = new Array(<% for i = 1 to iTotal %> "<%=i%>"<%if i < iTotal then%>,<%end if%> <%next%>);
		var arAffectedMenuItemID = new Array(<% for i = 1 to iTotal %> "<%=i+1%>"<%if i < iTotal then%>,<%end if%> <%next%>);
	//-->
</SCRIPT>
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

<!--#include file="./include/website_tree_contextmenu.asp"--><!--right click menu-->

</body>
</html>