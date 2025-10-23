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
Dim Tax_ID, strOpenedNodes, arOpenedNodes, NestLevel
Dim questionID, sortQuestionID
Dim closeQuestionID

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr

Tax_ID = checkQueryID(Trim(Request("tid")), 1)
if not IsNumeric(Tax_ID) or Len(Trim(Tax_ID)) = 0 then
	if IsNumeric(Session.Value("taxID")) and Trim(Session.Value("taxID")) <> "" then
		Tax_ID = Session.Value("taxID")
	else
		Tax_ID = 0
	end if
end if
Session.Value("taxID") = Tax_ID

questionID = checkQueryID(Trim(Request("qid")), 0)
sortQuestionID = checkQueryID(Trim(Request("sortid")), 0)
closeQuestionID = checkQueryID(Trim(Request("closeid")), 0)

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
Sub WriteTree(p_Parent_Question_ID, p_nodelist)
	Dim objTreeRec, TreeSQLStr, z, rowcolor, numFound
	Dim thisOpenString, boolIsLast, boolShowOpen
	Dim Question_ID, Parent_Question_ID, Tax_Question
	Dim Enabled
	Dim boolHasChildren, numChildren
	Dim Date_Created, Date_Modified
	Dim strTemp

	Set objTreeRec = Server.CreateObject("ADODB.RecordSet")

	TreeSQLStr = "sp_SPEDY_TaxWizard_Return_Questions '0" & Tax_ID & "', '0" & p_Parent_Question_ID & "'"
	'Response.Write "TreeSQLStr = " & TreeSQLStr & "<br>"
	objTreeRec.Open TreeSQLStr, objConn, adOpenKeyset, adLockReadOnly, adCmdText
	
	if p_Parent_Question_ID = 0 then
	%>
	<form name="frmMenu" action="question_move_save.asp" method="post" ID="frmMenu">
	<table cellpadding=0 cellspacing=0 border=0 ID="Table1" onselectstart="return false;">
		<tr><td><img src="./../../app_images/spacer.gif" height=2 width=1></td></tr>
	<%
	end if

	if not objTreeRec.EOF then
		numFound = objTreeRec.RecordCount
		z = 1
			
		Do Until objTreeRec.EOF
		'	Response.Write "z = " & z & " of " & numFound & "<br>"

			Question_ID = SmartValues(objTreeRec("ID"), "CLng")
			Parent_Question_ID = SmartValues(objTreeRec("Parent_Tax_Question_ID"), "CLng")
			Tax_Question = SmartValues(objTreeRec("Tax_Question"), "CStr")
			Enabled = SmartValues(objTreeRec("Enabled"), "CBool")
			boolHasChildren = SmartValues(objTreeRec("boolHasChildren"), "CBool")
			numChildren = SmartValues(objTreeRec("numChildren"), "CInt")

			Date_Created = SmartValues(objTreeRec("Date_Created"), "CDate")
			Date_Modified = SmartValues(objTreeRec("Date_Last_Modified"), "CDate")

			thisOpenString = p_nodelist
			if Len(Trim(thisOpenString)) > 0 then
				thisOpenString = thisOpenString & ","
			end if
			thisOpenString = thisOpenString & Question_ID

			boolIsLast = false
			if z >= numFound then
				boolIsLast = true
			end if

			boolShowOpen = false
			if CBool(findNeedleInHayStack(arOpenedNodes, Question_ID, "true")) and boolHasChildren then
				boolShowOpen = true
			end if
			
			if boolShowOpen and Question_ID = closeQuestionID Then
				boolShowOpen = false
			end if
			
			if boolShowOpen then
				strTemp = "&closeid=" & Question_ID
			else
				strTemp = ""
			end if

			if i mod 2 = 1 then				
				rowcolor = "fff"
			else
				rowcolor = "ececec"
			end if
		%>
		<tr id="datarow_<%=Question_ID%>" class="datarow" style="background: #<%=rowcolor%>;">
			<td class="bodyText spacercell">&nbsp;</td>
			<td class="datatreecol">
				<div class="datatreenode" style="padding-left: <%=NestLevel*20%>px;">
					<table cellpadding=0 cellspacing=0 class="datatreenodetable">
						<tr>
							<td class="datatreeimg"><%if boolHasChildren then%><a href="question_move_tree.asp?tid=<%=Tax_ID%>&qid=<%=Question_ID%>&open=<%=thisOpenString%>&sortid=<%=questionID%><%=strTemp%>"><%end if%><img class="" src="./../../app_images/folderlist_icons/<%=findTreeIcon(boolIsLast, false, "document", boolHasChildren, boolShowOpen)%>" width=16 height=16 border=0></a></td>
							<td class="datatreefileicon"><%if boolHasChildren then%><a href="question_move_tree.asp?tid=<%=Tax_ID%>&qid=<%=Question_ID%>&open=<%=thisOpenString%>&sortid=<%=questionID%><%=strTemp%>"><%end if%><img class="" src="./../../app_images/spacer.gif" width=1 height=16 border=0></a></td>
							<td class="bodyText datatreetext"><a href="javascript: void(0);" id="datarow_link_<%=Question_ID%>" onclick="commitMove(<%=Question_ID%>,<%=Parent_Question_ID%>);"><%=Tax_Question%></a></td>
						</tr>
					</table>
				</div>
			</td>
			<td class="bodyText spacercell">&nbsp;</td>
		</tr>
		<%
			i = i + 1
			if boolShowOpen then
				NestLevel = NestLevel + 1
				WriteTree Question_ID, thisOpenString
				NestLevel = NestLevel - 1
			end if
			
			z = z + 1
			objTreeRec.MoveNext
			Response.Flush
		Loop
	end if
	
	if p_Parent_Question_ID = 0 then
	%>
	</table>
	<input type=hidden name="moveDirection" value="above" ID="Hidden3"><!-- Valid values are "WITHIN", "ABOVE" or "BELOW" -->
	<input type=hidden name="moveReference" value="0" ID="Hidden5">
	<input type=hidden name="newParentID" value="0" ID="Hidden6">
	<input type=hidden name="sortid" value="<%=questionID%>" ID="Hidden7">
	<input type=hidden name="qid" value="<%=questionID%>" ID="Hidden8">
	<input type="hidden" name="selectedItemID" value="-1" ID="Hidden1">
	<input type="hidden" name="hoveredItemID" value="-1" ID="Hidden2">
	<input type="hidden" name="open" value="<%=strOpenedNodes%>" ID="Hidden4">
	<input type="hidden" name="tid" value="<%=Tax_ID%>">
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


