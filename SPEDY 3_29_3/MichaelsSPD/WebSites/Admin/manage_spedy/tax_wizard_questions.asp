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
Dim Tax_ID, strOpenedNodes, arOpenedNodes, NestLevel
Dim closeQuestionID

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr

Tax_ID = Request("tid")
if not IsNumeric(Tax_ID) or Len(Trim(Tax_ID)) = 0 then
	if IsNumeric(Session.Value("taxID")) and Trim(Session.Value("taxID")) <> "" then
		Tax_ID = Session.Value("taxID")
	else
		Tax_ID = 0
	end if
end if
Session.Value("taxID") = Tax_ID

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
			/*width: 100%;*/
			padding-right: 30px;
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
	<script language="javascript" src="./include/tax_wizard_questions_contextmenu.js"></script><!--right click menu-->
	<script language="javascript" src="./../app_include/prototype/prototype.js"></script>
	<script language=javascript>
	<!--
		window.defaultStatus = "Manage Tax Wizard Questions";
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
	
		function openEditQuestionWindow(selectedItemID)
		{
			newDocWin = window.open("./tax_wizard_admin/question_details_frm.asp?tid=<%=Tax_ID%>&qid=" + selectedItemID, "editQuestionWindow_" + selectedItemID, "width=500,height=400,toolbar=0,titlebar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=0,resizable=0");
			newDocWin.focus();
		}

		function openItemMoveWindow(RowID)
		{
			moveWin = window.open("./tax_wizard_admin/question_move.asp?tid=<%=Tax_ID%>&open=<%=Request("open")%>&qid=" + RowID, "moveWindow_" + RowID, "width=300,height=300,toolbar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=1,resizable=0");
			moveWin.focus();
		}
		
		function deleteDocument(RowID)
		{
			if (confirm("Really remove this question?\n\nThis cannot be undone!"))
			{
				document.location = "./tax_wizard_admin/question_remove.asp?tid=<%=Tax_ID%>&qid=" + RowID;
			}
			
		}
		
		function deleteDocumentTree(RowID)
		{
			if (confirm("Really remove these questions?\n\nThis cannot be undone!"))
			{
				document.location = "./tax_wizard_admin/question_remove_tree.asp?tid=<%=Tax_ID%>&qid=" + RowID;
			}
		}
		
		function openAddChildQuestionWindow(RowID)
		{
			var newQuestionWin = window.open("./tax_wizard_admin/question_details_frm.asp?tid=<%=Tax_ID%>&pqid=" + RowID, "newQuestionWindow_" + RowID, "width=500,height=400,toolbar=0,titlebar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=0,resizable=0");
			newQuestionWin.focus();
		}

		function openSortWindow(RowID)
		{
			sortWin = window.open("./tax_wizard_admin/question_sort_frm.asp?pqid=" + RowID, "sortWindow_" + RowID, "width=360,height=325,toolbar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=0,resizable=0");
			sortWin.focus();
		}

		function sortChildDocumentsByName(RowID)
		{
				document.location = "./tax_wizard_admin/question_sort_alpha.asp?pqid=" + RowID;
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
				case "ItemEdit":
					openEditQuestionWindow(selectedItemID);
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
					openAddChildQuestionWindow(selectedItemID);
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

<!--#include file="./include/tax_wizard_questions_contextmenu.asp"--><!--right click menu-->

<script language="javascript">
	waitLyr.style.display = "none";
	resizeFrame("1,0,*,0,25", "TaxWizardDetailsWrapperFrameset", parent.frames, "rows");
</script>
</body>
</html>
<%
Sub WriteTree(p_Parent_Tax_Question_ID, p_nodelist)
	Dim objTreeRec, TreeSQLStr, z, rowcolor, numFound
	Dim thisOpenString, boolIsLast, boolShowOpen
	Dim boolHasChildren, numChildren
	Dim Tax_Question_ID, Tax_Question, Enabled
	Dim Date_Created, Date_Modified
	Dim strTemp

	Set objTreeRec = Server.CreateObject("ADODB.RecordSet")

	TreeSQLStr = "sp_SPEDY_TaxWizard_Return_Questions '0" & Tax_ID & "', '0" & p_Parent_Tax_Question_ID & "'"
	'Response.Write "EXEC " & TreeSQLStr & "<br>"
	objTreeRec.Open TreeSQLStr, objConn, adOpenKeyset, adLockReadOnly, adCmdText
	
	if p_Parent_Tax_Question_ID = 0 then
	%>
	<form name="frmMenu" action="tax_wizard_questions.asp?<%=Request.ServerVariables("QUERY_STRING")%>" method="post" ID="frmMenu">
	<table cellpadding=0 cellspacing=0 border=0 ID="Table1" onselectstart="return false;">
		<tr class="hdrrow">
			<td class="bodyText spacercell">&nbsp;</td>
			<td class="bodyText datatreecol_hdrrow">Tax Question</td>
			<td class="bodyText datacol_hdrrow">Tasks</td>
			<td class="bodyText datacol_hdrrow">Date Created</td>
			<td class="bodyText datacol_hdrrow" width="100%" style="width: 100%;">Date Modified</td>
			<td class="bodyText spacercell">&nbsp;</td>
		</tr>
		<tr><td><img src="./../app_images/spacer.gif" height=2 width=1></td></tr>
	<%
	end if

	if not objTreeRec.EOF then
		numFound = objTreeRec.RecordCount
		z = 1
			
		Do Until objTreeRec.EOF
			Tax_Question_ID = SmartValues(objTreeRec("ID"), "CLng")
			Tax_Question = SmartValues(objTreeRec("Tax_Question"), "CStr")
			Enabled = SmartValues(objTreeRec("Enabled"), "CBool")
			Date_Created = SmartValues(objTreeRec("Date_Created"), "CDate")
			Date_Modified = SmartValues(objTreeRec("Date_Last_Modified"), "CDate")
			boolHasChildren = SmartValues(objTreeRec("boolHasChildren"), "CBool")
			numChildren = SmartValues(objTreeRec("numChildren"), "CStr")

			thisOpenString = p_nodelist
			if Len(Trim(thisOpenString)) > 0 then
				thisOpenString = thisOpenString & ","
			end if
			thisOpenString = thisOpenString & Tax_Question_ID

			boolIsLast = false
			if z >= numFound then
				boolIsLast = true
			end if

			boolShowOpen = false
			if CBool(findNeedleInHayStack(arOpenedNodes, Tax_Question_ID, "true")) and boolHasChildren then
				boolShowOpen = true
			end if
			
			if boolShowOpen and Tax_Question_ID = closeQuestionID Then
				boolShowOpen = false
			end if
			
			if boolShowOpen then
				strTemp = "&closeid=" & Tax_Question_ID
			else
				strTemp = ""
			end if

			if i mod 2 = 1 then				
				rowcolor = "f3f3f3"
			else
				rowcolor = "ffffff"
			end if
		%>
		<tr id="datarow_<%=Tax_Question_ID%>" class="datarow" style="background: #<%=rowcolor%>;" onMouseOver="HoverRow(<%=Tax_Question_ID%>);" onMouseOut="HoverRow(0);" onDblClick="highlightRow();" oncontextmenu="HoverRow(<%=Tax_Question_ID%>);SelectRow(<%=Tax_Question_ID%>);displayMenu(); return false;">
			<td class="bodyText spacercell">&nbsp;</td>
			<td class="datatreecol">
				<div class="datatreenode" style="padding-left: <%=NestLevel*20%>px;">
					<table cellpadding=0 cellspacing=0 class="datatreenodetable" ID="Table2">
						<tr>
							<td class="datatreeimg"><%if boolHasChildren then%><a href="tax_wizard_questions.asp?pid=<%=Tax_Question_ID%>&open=<%=thisOpenString%><%=strTemp%>"><%end if%><img class="" src="./../app_images/folderlist_icons/<%=findTreeIcon(boolIsLast, false, "document", boolHasChildren, boolShowOpen)%>" width=16 height=16 border=0></a></td>
							<td class="datatreefileicon"><%if boolHasChildren then%><a href="tax_wizard_questions.asp?pid=<%=Tax_Question_ID%>&open=<%=thisOpenString%><%=strTemp%>"><%end if%><img class="" src="./../app_images/spacer.gif" width=1 height=16 border=0></a></td>
							<td class="bodyText datatreetext"><%if boolHasChildren then%><a href="tax_wizard_questions.asp?pid=<%=Tax_Question_ID%>&open=<%=thisOpenString%><%=strTemp%>"><%end if%><%=Tax_Question%></a></td>
						</tr>
					</table>
				</div>
			</td>
			<td class="datacol"><a href="#<%=Tax_Question_ID%>" onMouseOver="hTaskBtn('taskIcon<%=Tax_Question_ID%>', true)"  onMouseOut="hTaskBtn('taskIcon<%=Tax_Question_ID%>', false)" onClick="SelectRow(<%=Tax_Question_ID%>);HoverRow(<%=Tax_Question_ID%>);this.parentElement.parentElement.click(); displayMenu(); return false;"><img id="taskIcon<%=Tax_Question_ID%>" src="./../app_images/tasks_icon_off.gif" width=24 height=16 alt=":: Click to access tasks ::" border=0></a></td>
			<td class="bodyText datacol"><%=Date_Created%>&nbsp;</td>
			<td class="bodyText datacol" width="100%" style="width: 100%;"><%=Date_Modified%>&nbsp;</td>
			<td class="bodyText spacercell">&nbsp;</td>
		</tr>
		<%
			i = i + 1
			if boolShowOpen then
				NestLevel = NestLevel + 1
				WriteTree Tax_Question_ID, thisOpenString
				NestLevel = NestLevel - 1
			end if
			
			z = z + 1
			objTreeRec.MoveNext
			Response.Flush
		Loop
	end if
	
	if p_Parent_Tax_Question_ID = 0 then
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


