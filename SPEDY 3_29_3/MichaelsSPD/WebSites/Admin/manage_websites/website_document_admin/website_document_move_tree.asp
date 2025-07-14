<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441
%>
<!--#include file="./../../app_include/_globalInclude.asp"--> 
<!--#include file="./../../app_include/getfile_icon_name.asp"-->
<%
'	Dim Security
'	Set Security = New cls_Security
'	Security.Initialize Session.Value("UserID"), "ADMIN", 0

Dim objConn, objRec, SQLStr, connStr, i
Dim Website_ID, strOpenedNodes, arOpenedNodes, NestLevel
Dim topicID, sortTopicID

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr

Website_ID = checkQueryID(Trim(Request("webid")), 1)
if not IsNumeric(Website_ID) or Len(Trim(Website_ID)) = 0 then
	if IsNumeric(Session.Value("websiteID")) and Trim(Session.Value("websiteID")) <> "" then
		Website_ID = Session.Value("websiteID")
	else
		Website_ID = 0
	end if
end if
Session.Value("websiteID") = Website_ID

topicID = checkQueryID(Trim(Request("tid")), 0)
sortTopicID = checkQueryID(Trim(Request("sortid")), 0)

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
		@import url('./../../app_include/global.css');
		A {text-decoration: none; color:#000;}
		A:HOVER {text-decoration: none; color: #000;}
		BODY {padding: 0;}
		
		.bodyText
		{
			font-size: 12px;
			line-height: 16px;
		}
		
		.hdrrow TD
		{
			background: #ccc;
			border-bottom: 1px solid #999;
			line-height: 16px;
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
			float: left;
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
			border-left: 1px solid #999;
		}

		.rover TD
		{
			background: #ff9; 
			color: #000;
		}
		.selectedRow
		{
			background: navy !important; 
			color: white;
			text-decoration: none;
		}
		A.selectedRow
		{
			background: navy !important; 
			color: white;
			text-decoration: none;
		}
		A.selectedRow:HOVER
		{
			background: navy !important; 
			color: white;
			text-decoration: none;
		}
	</style>
	<script language=javascript>
	<!--
		var SelectedID = 0;
		function commitMove(intReferenceID, intNewParentID)
		{
			var myDir = document.frmMenu.moveDirection.value;
			document.frmMenu.moveReference.value = intReferenceID;
			document.frmMenu.newParentID.value = intNewParentID;
			if (document.getElementById("datarow_link_" + SelectedID)) document.getElementById("datarow_link_" + SelectedID).className = "";
			if (document.getElementById("datarow_link_" + intReferenceID)) document.getElementById("datarow_link_" + intReferenceID).className = "selectedRow";
			SelectedID = intReferenceID;
		}
	//-->
	</script>
</head>
<body bgcolor="ffffff" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>

<%WriteTree 0, 0%>

</body>
</html>
<%
Sub WriteTree(p_Parent_Element_ID, p_nodelist)
	Dim objTreeRec, TreeSQLStr, z, rowcolor, numFound
	Dim thisOpenString, boolIsLast, boolShowOpen
	Dim Element_ID, Parent_Element_ID, Element_FullTitle, Element_Type, FileName, Status_ID, Status_Name
	Dim Element_ShortTitle, Element_CustomHTMLTitle, Enabled, DisplayInNav, DisplayInSearchResults
	Dim boolPromotedToStaging, boolPromotedToLive, boolHasChildren, numChildren, Staging_Source_ID, Live_Source_ID
	Dim Date_Published_Staging, Date_Published_Live, Date_Published, Date_Created_Staging, Date_Created_Live
	Dim Start_Date, End_Date, Date_Modified_Staging, Date_Modified_Live

	Set objTreeRec = Server.CreateObject("ADODB.RecordSet")

	TreeSQLStr = "sp_websites_return_website_contents '0" & Website_ID & "', '0" & p_Parent_Element_ID & "'"
	'Response.Write "TreeSQLStr = " & TreeSQLStr & "<br>"
	objTreeRec.Open TreeSQLStr, objConn, adOpenKeyset, adLockReadOnly, adCmdText
	
	if p_Parent_Element_ID = 0 then
	%>
	<form name="frmMenu" action="website_document_move_save.asp" method="post" ID="frmMenu">
	<table cellpadding=0 cellspacing=0 border=0 ID="Table1" onselectstart="return false;">
		<tr><td><img src="./../../app_images/spacer.gif" height=2 width=1></td></tr>
	<%
	end if

	if not objTreeRec.EOF then
		numFound = objTreeRec.RecordCount
		z = 1
			
		Do Until objTreeRec.EOF
		'	Response.Write "z = " & z & " of " & numFound & "<br>"

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
				rowcolor = "fff"
			else
				rowcolor = "ececec"
			end if
		%>
		<tr id="datarow_<%=Element_ID%>" class="datarow" style="background: #<%=rowcolor%>;">
			<td class="bodyText spacercell">&nbsp;</td>
			<td class="datatreecol">
				<div class="datatreenode" style="padding-left: <%=NestLevel*20%>px;">
					<table cellpadding=0 cellspacing=0 class="datatreenodetable">
						<tr>
							<td class="datatreeimg"><%if boolHasChildren then%><a href="website_document_move_tree.asp?webid=<%=Website_ID%>&pid=<%=Element_ID%>&open=<%=thisOpenString%>&tid=<%=topicID%>&sortid=<%=topicID%>"><%end if%><img class="" src="./../../app_images/folderlist_icons/<%=findTreeIcon(boolIsLast, false, "document", boolHasChildren, boolShowOpen)%>" width=16 height=16 border=0></a></td>
							<td class="datatreefileicon"><%if boolHasChildren then%><a href="website_document_move_tree.asp?webid=<%=Website_ID%>&pid=<%=Element_ID%>&open=<%=thisOpenString%>&tid=<%=topicID%>&sortid=<%=topicID%>"><%end if%><img class="" src="./../../app_images/app_icons/<%=findItemIcon(Element_Type, FileName, boolPromotedToLive)%>" width=16 height=16 border=0></a></td>
							<td class="bodyText datatreetext"><a href="javascript: void(0);" id="datarow_link_<%=Element_ID%>" onclick="commitMove(<%=Element_ID%>,<%=Parent_Element_ID%>);"><%=Element_FullTitle%></a></td>
						</tr>
					</table>
				</div>
			</td>
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
	<input type=hidden name="moveDirection" value="above" ID="Hidden3"><!-- Valid values are "WITHIN", "ABOVE" or "BELOW" -->
	<input type=hidden name="moveReference" value="0" ID="Hidden5">
	<input type=hidden name="newParentID" value="0" ID="Hidden6">
	<input type=hidden name="sortid" value="<%=topicID%>" ID="Hidden7">
	<input type=hidden name="tid" value="<%=topicID%>" ID="Hidden8">
	<input type="hidden" name="selectedItemID" value="-1" ID="Hidden1">
	<input type="hidden" name="hoveredItemID" value="-1" ID="Hidden2">
	<input type="hidden" name="open" value="<%=strOpenedNodes%>" ID="Hidden4">
	<input type="hidden" name="webid" value="<%=Website_ID%>">
	</form>
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


