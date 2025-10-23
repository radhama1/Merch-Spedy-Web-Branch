<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441 
%>
<!--#include file="../app_include/findNeedleInHayStack.asp"-->
<!--#include file="../app_include/smartValues.asp"-->
<!--#include file="./../app_include/checkQueryID.asp"-->
<%
Dim objConn, objRec, SQLStr, connStr
Dim rowcolor, i
Dim strToolTip
Dim SortColumn, SortDirection

SortColumn = Trim(Request("sort"))
if IsNumeric(SortColumn) and Trim(SortColumn) <> "" then
	SortColumn = CInt(SortColumn)
	Session.Value("Security_Group_SortColumn") = SortColumn
else
	if IsNumeric(Session.Value("Security_Group_SortColumn")) and Trim(Session.Value("Security_Group_SortColumn")) <> "" then
		SortColumn = CInt(Session.Value("Security_Group_SortColumn"))
	else
		SortColumn = 0
		Session.Value("Security_Group_SortColumn") = SortColumn
	end if
end if

SortDirection = Trim(Request("direction"))
if IsNumeric(SortDirection) and Trim(SortDirection) <> "" then
	SortDirection = CInt(SortDirection)
	Session.Value("Security_User_Group_SortDirection") = SortDirection
else
	if IsNumeric(Session.Value("Security_User_Group_SortDirection")) and Trim(Session.Value("Security_User_Group_SortDirection")) <> "" then
		SortDirection = CInt(Session.Value("Security_User_Group_SortDirection"))
	else
		SortDirection = 0
		Session.Value("Security_User_Group_SortDirection") = SortDirection
	end if
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
	<script language="javascript" src="./include/security_group_details_contextmenu.js"></script><!--right click menu-->
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
				case "ItemMembers":
					showUserList(selectedItemID);
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
			editWin = window.open("./security_group_admin/security_group_details_frm.asp?gid=" + RowID, "editWindow_" + RowID, "width=600,height=500,toolbar=0,location=0,directories=0,status=1,menuBar=0,scrollBars=1,resizable=0");
			editWin.focus();
		}

		function deleteDocument(RowID)
		{
			if (confirm("Really remove this group?"))
			{
				document.location = "./security_group_admin/security_group_remove.asp?gid=" + RowID + "&sort=<%=SortColumn%>&direction=<%=SortDirection%>";
			}
		}

		function launchNewWin(myLoc, myName, myWidth, myHeight)
		{
				var myFeatures = "directories=no,dependent=yes,width=" + myWidth + ",height=" + myHeight + ",hotkeys=no,location=no,menubar=no,resizable=yes,screenX=100,screenY=100,scrollbars=yes,titlebar=no,toolbar=no,status=no";
				var newWin = window.open(myLoc, myName, myFeatures);
		}
		function showUserList(selectedID)
		{
			if (selectedID > 0)
			{
				parent.parent.frames['WorkspaceFrame'].document.location = 'security_group_details_frm.asp?showusers=1&grouptype=1&id=' + selectedID;
			}
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
			SQLStr = "sp_security_list_groups 0, " & SortColumn & ", " & SortDirection
			objRec.Open SQLStr, objConn, adOpenStatic, adLockReadOnly, adCmdText
			if not objRec.EOF then
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
				<tr bgcolor=e6e6e6><td colspan=17><img src="./images/spacer.gif" height=1 width=1></td></tr>
				<%end if%>
				<tr bgcolor=<%=rowcolor%> id="datarow_<%=objRec("ID")%>" onMouseOver="HoverRow(<%=objRec("ID")%>);" onMouseOut="HoverRow(0);" onDblClick="highlightRow();" oncontextmenu="HoverRow(<%=objRec("ID")%>);SelectRow(<%=objRec("ID")%>);displayMenu(); return false;">
					<td><img src="./images/spacer.gif" height=1 width=6></td>
					<td valign=top nowrap>
						<font style="font-family:Arial, Helvetica;font-size:11px;">
						<a href="javascript: openItemEditorWindow(<%=objRec("ID")%>); void(0);"><%if not IsNull(objRec("Group_Name")) then Response.Write Server.HTMLEncode(objRec("Group_Name")) end if%></a>
						</font>
					</td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top align=right>
						<font style="font-family:Arial, Helvetica;font-size:11px;">
						<%if not IsNull(objRec("Num_Members")) then Response.Write Server.HTMLEncode(objRec("Num_Members")) end if%>
						</font>
					</td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top>
						<font style="font-family:Arial, Helvetica;font-size:11px;">
						<%if not IsNull(objRec("Group_Summary")) then Response.Write Server.HTMLEncode(objRec("Group_Summary")) end if%>
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
					<td id="col_2_data"><img id="col_2_dataimg" src="./images/spacer.gif" height=1 width=300></td>
					<td><img src="./images/spacer.gif" height=1 width=1></td>
					<td id="col_3_data"><img id="col_3_dataimg" src="./images/spacer.gif" height=1 width=1></td>
					<td><img src="./images/spacer.gif" height=1 width=1></td>
					<td id="col_4_data"><img id="col_4_dataimg" src="./images/spacer.gif" height=1 width=1></td>
					<td><img src="./images/spacer.gif" height=1 width=1></td>
					<td id="col_5_data"><img id="col_5_dataimg" src="./images/spacer.gif" height=1 width=1></td>
					<td><img src="./images/spacer.gif" height=1 width=1></td>
				</tr>
			</table>
			<script language="javascript">
			<!--
				parent.frames["DetailFrameHdr"].document.location = "security_group_details_header.asp?sort=" + <%=SortColumn%> + "&direction=" + <%=SortDirection%>;

			//-->
			</script>
			<%
			else
			%>
			<script language="javascript">
			<!--

				parent.frames["DetailFrameHdr"].document.location = "../app_include/blank_999999.html";

			//-->
			</script>
			<%
			end if
			objRec.Close
			%>
		</td>
	</tr>
	</form>
</table>
<!--#include file="./include/security_group_details_contextmenu.asp"--><!--right click menu-->

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

%>