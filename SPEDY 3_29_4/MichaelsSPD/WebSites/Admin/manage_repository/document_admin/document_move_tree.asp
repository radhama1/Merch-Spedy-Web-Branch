<%@ Language=VBScript %>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
%>
<!--#include file="./../../app_include/_globalInclude.asp"-->
<%
Response.Buffer = True
Response.Expires = -1441

Dim topicID

topicID = Request.QueryString("tid")
if IsNumeric(topicID) then
	topicID = CInt(topicID)
else
	topicID = 0
end if
%>
<!-- #include file="document_move_tree_routines.asp" -->
<html>
<head>
	<link rel="stylesheet" type="text/css" href="./../../app_include/folderlist/style.css">
	<script language=javascript>
	<!--
		//tell the folderlist function where to find the folder tree icons...
		var iconImgPath = "./../../app_images/folderlist_icons/";	
	//-->
	</script>
	<script language="javascript" src="./../../app_include/folderlist/functions.js"></script>
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
	
		function setTargetItemID(selectedID)
		{
			if (selectedID > 0)
			{
				document.frmMenu.targetID.value = selectedID;
			}
			else
			{
				document.frmMenu.targetID.value = 0;
			}
		}
	
	//-->
	</script>
</head>
<body bgcolor="ffffff" topmargin=0 leftmargin=0 rightmargin=0 marginheight=0 marginwidth=0>
<%
'On Error Resume Next
dim iTotal, sLeftIndent
dim bLoaded
Dim bLoadSubItems
Dim objDocument
Dim sOpenFolders
Dim i
	
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
				<form name="frmMenu" action="document_move_save.asp" method="post">
<!-- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: -->
<!-- :: Menu is written below                                                         :: -->
<!-- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: -->
				<%
				sOpenFolders = Request.Form("hdnOpenFolders")
				
				'This subroutine generates the HTML for the menu based on
				'data loaded into the XML object
				DisplayNode objDocument.childNodes, iTotal, sLeftIndent, sOpenFolders
				%>
				<input type="hidden" name="topicID" value="<%=topicID%>">
				<input type="hidden" name="targetID" value="0">
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
</body>
</html>