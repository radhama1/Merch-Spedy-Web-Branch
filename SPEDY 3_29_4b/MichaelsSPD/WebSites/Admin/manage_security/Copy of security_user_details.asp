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
Dim enumerateUserGroup, enumerateUserRole, selectedGroupID
Dim numFound, startRow, pageSize, curPage, pageCount

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

'Response.Write "pageSize: " & pageSize & "<br>" & vbCrLf
'Response.Write "curPage: " & curPage & "<br>" & vbCrLf
'Response.Write "pageCount: " & pageCount & "<br>" & vbCrLf
'Response.Write "startRow: " & startRow & "<br>" & vbCrLf

enumerateUserGroup = Request("enumgroup")
if IsNumeric(enumerateUserGroup) then
	enumerateUserGroup = CBool(enumerateUserGroup)
else
	enumerateUserGroup = CBool(0)
end if

enumerateUserRole = Request("enumrole")
if IsNumeric(enumerateUserRole) then
	enumerateUserRole = CBool(enumerateUserRole)
else
	enumerateUserRole = CBool(0)
end if

selectedGroupID = Request("sgid")
if IsNumeric(selectedGroupID) then
	selectedGroupID = CInt(selectedGroupID)
else
	selectedGroupID = 0
end if

SortColumn = Trim(Request("sort"))
if IsNumeric(SortColumn) and Trim(SortColumn) <> "" then
	SortColumn = CInt(SortColumn)
	Session.Value("Security_User_SortColumn") = SortColumn
else
	if IsNumeric(Session.Value("Security_User_SortColumn")) and Trim(Session.Value("Security_User_SortColumn")) <> "" then
		SortColumn = CInt(Session.Value("Security_User_SortColumn"))
	else
		SortColumn = 0
		Session.Value("Security_User_SortColumn") = SortColumn
	end if
end if

SortDirection = Trim(Request("direction"))
if IsNumeric(SortDirection) and Trim(SortDirection) <> "" then
	SortDirection = CInt(SortDirection)
	Session.Value("Security_User_SortDirection") = SortDirection
else
	if IsNumeric(Session.Value("Security_User_SortDirection")) and Trim(Session.Value("Security_User_SortDirection")) <> "" then
		SortDirection = CInt(Session.Value("Security_User_SortDirection"))
	else
		SortDirection = 0
		Session.Value("Security_User_SortDirection") = SortDirection
	end if
end if

Session.Value("Allowed_Edit_List") = ""
Session.Value("Allowed_Publish_List") = ""
Session.Value("Picked_Topic") = ""

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
	<script language="javascript" src="./include/security_user_details_contextmenu.js"></script><!--right click menu-->
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
			editWin = window.open("./security_user_admin/security_user_details_frm.asp?cid=" + RowID, "editWindow_" + RowID, "width=600,height=500,toolbar=0,location=0,directories=0,status=1,menuBar=0,scrollBars=1,resizable=0");
			editWin.focus();
		}

		function deleteDocument(RowID)
		{
			if (confirm("Really remove this user?"))
			{
				document.location = "./security_user_admin/security_user_remove.asp?cid=" + RowID + "&sort=<%=SortColumn%>&direction=<%=SortDirection%>";
			}
		}

		function launchNewWin(myLoc, myName, myWidth, myHeight)
		{
				var myFeatures = "directories=no,dependent=yes,width=" + myWidth + ",height=" + myHeight + ",hotkeys=no,location=no,menubar=no,resizable=yes,screenX=100,screenY=100,scrollbars=yes,titlebar=no,toolbar=no,status=no";
				var newWin = window.open(myLoc, myName, myFeatures);
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
			if enumerateUserGroup and selectedGroupID > 0 then
				SQLStr = "sp_security_list_users_by_group '" & selectedGroupID & "', " & SortColumn & ", " & SortDirection & ", " & pageSize & ", " & startRow
			elseif enumerateUserRole and selectedGroupID > 0 then
				SQLStr = "sp_security_list_users_by_group '" & selectedGroupID & "', " & SortColumn & ", " & SortDirection & ", " & pageSize & ", " & startRow
			else
				SQLStr = "sp_security_list_users " & SortColumn & ", " & SortDirection & ", " & pageSize & ", " & startRow
			end if
			
			'response.write SQLStr
			objRec.Open SQLStr, objConn, adOpenStatic, adLockReadOnly, adCmdText
			if not objRec.EOF then
				numFound = CInt(objRec("totRecords"))
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
				<tr bgcolor=e6e6e6><td colspan=30><img src="./images/spacer.gif" height=1 width=1></td></tr>
				<%end if%>
				<tr bgcolor=<%=rowcolor%> id="datarow_<%=objRec("ID")%>" onMouseOver="HoverRow(<%=objRec("ID")%>);" onMouseOut="HoverRow(0);" onDblClick="highlightRow();" oncontextmenu="HoverRow(<%=objRec("ID")%>);SelectRow(<%=objRec("ID")%>);displayMenu(); return false;">
					<td><img src="./images/spacer.gif" height=1 width=6></td>
					<td valign=top nowrap>
						<font style="font-family:Arial, Helvetica;font-size:11px;<%if not CBool(objRec("Enabled")) then Response.Write "color:#999999" end if%>">
						<a href="javascript: openItemEditorWindow(<%=objRec("ID")%>); void(0);"><%if not IsNull(objRec("UserName")) then Response.Write Server.HTMLEncode(objRec("UserName")) end if%><%if not enumerateUserGroup then Response.Write "</a>" end if%>&nbsp;&nbsp;<%if not CBool(objRec("Enabled")) then Response.Write "[Disabled]" end if%>
						</font>
					</td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap>
						<font style="font-family:Arial, Helvetica;font-size:11px;<%if not CBool(objRec("Enabled")) then Response.Write "color:#999999" end if%>">
						<%if not IsNull(objRec("Last_Name")) then Response.Write Server.HTMLEncode(objRec("Last_Name")) end if%>
						</font>
					</td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap>
						<font style="font-family:Arial, Helvetica;font-size:11px;<%if not CBool(objRec("Enabled")) then Response.Write "color:#999999" end if%>">
						<%if not IsNull(objRec("First_Name")) then Response.Write Server.HTMLEncode(objRec("First_Name")) end if%>
						</font>
					</td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap>
						<font style="font-family:Arial, Helvetica;font-size:11px;<%if not CBool(objRec("Enabled")) then Response.Write "color:#999999" end if%>">
						<%if not IsNull(objRec("Organization")) then Response.Write Server.HTMLEncode(objRec("Organization")) end if%>
						</font>
					</td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap>
						<font style="font-family:Arial, Helvetica;font-size:11px;<%if not CBool(objRec("Enabled")) then Response.Write "color:#999999" end if%>">
						<%if not IsNull(objRec("Email_Address")) then Response.Write Server.HTMLEncode(objRec("Email_Address")) end if%>
						</font>
					</td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap>
						<font style="font-family:Arial, Helvetica;font-size:11px;<%if not CBool(objRec("Enabled")) then Response.Write "color:#999999" end if%>">
						<%if not IsNull(objRec("Department")) then Response.Write Server.HTMLEncode(objRec("Department")) end if%>
						</font>
					</td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap>
						<font style="font-family:Arial, Helvetica;font-size:11px;<%if not CBool(objRec("Enabled")) then Response.Write "color:#999999" end if%>">
						<%if not IsNull(objRec("Job_Title")) then Response.Write Server.HTMLEncode(objRec("Job_Title")) end if%>
						</font>
					</td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap>
						<font style="font-family:Arial, Helvetica;font-size:11px;<%if not CBool(objRec("Enabled")) then Response.Write "color:#999999" end if%>">
						<%if not IsNull(objRec("Office_Location")) then Response.Write Server.HTMLEncode(objRec("Office_Location")) end if%>
						</font>
					</td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap>
						<font style="font-family:Arial, Helvetica;font-size:11px;<%if not CBool(objRec("Enabled")) then Response.Write "color:#999999" end if%>">
						<%if not IsNull(objRec("Gender")) then Response.Write Server.HTMLEncode(objRec("Gender")) end if%>
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
					<td id="col_11_data"><img id="col_11_dataimg" src="./images/spacer.gif" height=1 width=1></td>
					<td><img src="./images/spacer.gif" height=1 width=1></td>
				</tr>
			</table>
			<script language="javascript">
			<!--
				parent.frames["DetailFrameHdr"].document.location = "security_user_details_header.asp?enumgroup=<%=Request.QueryString("enumgroup")%>&enumrole=<%=Request.QueryString("enumrole")%>&sgid=<%=Request.QueryString("sgid")%>&sort=<%=SortColumn%>&direction=<%=SortDirection%>";
				parent.frames["PagingNavFrame"].document.location = "./../app_include/paging_navbar.asp?loc=<%=Request.ServerVariables("SCRIPT_NAME")%>&frm=DetailFrame&pageCount=<%=pageCount%>&curPage=<%=curPage%>&pageSize=<%=pageSize%>&q=<%=Server.URLEncode("cid=" & Request.QueryString("cid"))%>";
			//-->
			</script>
			<%
			else
			%>
			<script language="javascript">
			<!--

				parent.frames["DetailFrameHdr"].document.location = "../app_include/blank_999999.html";
				parent.frames["PagingNavFrame"].document.location = "./../app_include/blank_cccccc.html";

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
<!--#include file="./include/security_user_details_contextmenu.asp"--><!--right click menu-->

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