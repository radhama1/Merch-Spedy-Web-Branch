<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Nathan Fernau
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441 
%>
<!--#include file="./../app_include/SmartValues.asp"-->
<!--#include file="./../app_include/returnDataWithGetRows.asp"-->
<!--#include file="./../app_include/checkQueryID.asp"-->
<%
Dim arRecRows, dictRecCols
Dim rowCounter, curIteration, displayCount', numFound
Dim SQLStr, connStr
Dim rowcolor, i
Dim strToolTip
Dim SortColumn, SortDirection

Dim Record_ID
Dim Table_ID

Dim Rule_ID, Validation_Document_ID, Enabled

Dim taskStr, separatorStr
Dim numFound, startRow, pageSize, curPage, pageCount

Record_ID = Request("tid")
if not IsNumeric(Record_ID) or Len(Trim(Record_ID)) = 0 then
	if IsNumeric(Session.Value("recordID")) and Trim(Session.Value("recordID")) <> "" then
		Record_ID = Session.Value("recordID")
	else
		Record_ID = 0
	end if
end if
Session.Value("recordID") = Record_ID
i = 0
Table_ID = 0

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

SortColumn = Trim(Request("sort"))
if IsNumeric(SortColumn) and Trim(SortColumn) <> "" then
	SortColumn = CInt(SortColumn)
	Session.Value("ValidationRule_List_SortColumn") = SortColumn
else
	if IsNumeric(Session.Value("ValidationRule_List_SortColumn")) and Trim(Session.Value("ValidationRule_List_SortColumn")) <> "" then
		SortColumn = CInt(Session.Value("ValidationRule_List_SortColumn"))
	else
		SortColumn = 0
		Session.Value("ValidationRule_List_SortColumn") = SortColumn
	end if
end if

SortDirection = Trim(Request("direction"))
if IsNumeric(SortDirection) and Trim(SortDirection) <> "" then
	SortDirection = CInt(SortDirection)
	Session.Value("ValidationRule_List_SortDirection") = SortDirection
else
	if IsNumeric(Session.Value("ValidationRule_List_SortDirection")) and Trim(Session.Value("ValidationRule_List_SortDirection")) <> "" then
		SortDirection = CInt(Session.Value("ValidationRule_List_SortDirection"))
	else
		SortDirection = 0
		Session.Value("ValidationRule_List_SortDirection") = SortDirection
	end if
end if

Set dictRecCols	= Server.CreateObject("Scripting.Dictionary")
connStr = Application.Value("connStr")
SQLStr = "usp_Validation_GetRuleList " & Record_ID & ", " & SortColumn & ", " & SortDirection & ", " & pageSize & ", " & startRow
'Response.Write "SQLStr: " & SQLStr & "<br>" & vbCrLf
Call returnDataWithGetRows(connStr, SQLStr, arRecRows, dictRecCols)

Dim strPermissionStr, thisUserID
Dim canEdit, canModifyStatus, canDelete
thisUserID = CLng(Session.Value("UserID"))

separatorStr = "&nbsp;&nbsp;|&nbsp;"

'Response.Write "ColCount: " & dictRecCols("ColCount") & "<br>" & vbCrLf
'Response.Write "RecordCount: " & dictRecCols("RecordCount") & "<br>" & vbCrLf
%>
<html>
<head>
	<title>Validation Rule List</title>
	<style type="text/css">
	<!--
		A {text-decoration: none; cursor: hand;}
		A:HOVER {text-decoration: none; color: #0000ff; cursor: hand;}
		.rover * {background-color: #ffff99}
		.selectedRow * {background-color: #cccccc; color: #000000}
		.rover_special * {background-color: navy; color: #fff;}
		.rover_special a:hover{color: #ccc;}
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
  	//-->
	</style>
	<script language="javascript" src="../app_include/lockscroll.js"></script><!--locked headers code-->
	<link rel="stylesheet" href="../app_include/contextmenu.css" type="text/css" media="screen"><!--right click styles-->
	<script language="javascript" src="./include/contextmenu.js"></script><!--right click menu-->
	<script language=javascript>
	<!--
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
		
		function configureOptions(RowID)
		{
			return true;
		}
	
		var lastSelectedItemID = 0;
		var lastSelectedItemClassName = "";
		function highlightSelectedItemRow(selectedItemID)
		{
			var row = document.getElementById("datarow_" + selectedItemID)
			var prevrow = document.getElementById("datarow_" + lastSelectedItemID)

			if (row==null) return;		
			if (prevrow!=null)
			{
				prevrow.className = lastSelectedItemClassName;
			}
			lastSelectedItemClassName = row.className;
			row.className = "rover_special";
			
			lastSelectedItemID = selectedItemID;
			document.location.hash = "datarow_" + selectedItemID;
		}

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
					openEditRuleWindow(selectedItemID);
					break;				
				case "ItemDelete":
					waitLyr.style.display = "";
					deleteRule(selectedItemID);
					waitLyr.style.display = "none";
					break;
				case "ItemAdd":
					openAddRuleWindow(selectedItemID);
					break;
					

				default:
					break;
			}
		}
		
		function openEditRuleWindow(selectedItemID)
		{
			var newRuleWin = window.open("./validation_admin/rule_details_frm.asp?tid=<%=Record_ID%>&rid=" + selectedItemID, "editRuleWindow_" + selectedItemID, "width=800,height=600,toolbar=0,titlebar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=0,resizable=0");
			newRuleWin.focus();
		}
		
		function deleteRule(RowID)
		{
			if (confirm("Really remove this rule?\n\nThis cannot be undone!"))
			{
				document.location = "./validation_admin/rule_remove.asp?tid=<%=Record_ID%>&rid=" + RowID;
			}
			
		}
		
		function openAddRuleWindow(RowID)
		{
			var newRuleWin = window.open("./validation_admin/rule_details_frm.asp?tid=<%=Record_ID%>&rid=" + '0', "newRuleWindow_" + RowID, "width=800,height=600,toolbar=0,titlebar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=0,resizable=0");
			newRuleWin.focus();
		}
		
		
		
		function resizeFrame(newSizeFramesetArgs, what, where)
		{
			if (what == "")
				return false;
			if (newSizeFramesetArgs == "")
				return false;
			
			var parentDoc = new Object();
			if (where)
			{
				parentDoc = where;
			}
			else
			{
				alert(parentDoc + " does not exist!")
			}
			
			if (parentDoc)
			{
				parentDoc.document.getElementById(what).rows = newSizeFramesetArgs;
			}
			else
			{
				alert(parentDoc + " does not exist!")
			}
		}
		
		function closeDetailsFrame()
		{
			resizeFrame('*,0', 'MainListFrame', parent.parent.frames);
			boolFrameClosed = true;
		}
	//-->
	</script>
</head>
<body bgcolor="ffffff" link="000000" vlink="000000" topmargin=0 leftmargin=0 rightmargin=0 marginheight=0 marginwidth=0 onLoad="initPlaceLayers();"><!--  oncontextmenu="return false;"> -->
<div style="position: absolute; z-index:100; width:100%; height:1000px; top:0px; left:0px; filter:progid:DXImageTransform.Microsoft.Gradient(GradientType=0, StartColorStr='#339c9c9c', EndColorStr='#339c9c9c')" id="waitLyr" name="waitLyr">
	<div id="waitText" name="waitText" style="position: absolute; top:10px; left:10px; font-family:Arial, Helvetica;font-size:12px;color:#666666;">
		Gathering Data<br>
		Please Wait…
	</div>
	<img src="./images/spacer.gif" border=0 style="width:100%; height:1000px;">
</div>


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
						if not CBool(numFound mod pageSize) then
							pageCount = CInt(numFound/pageSize)
						else
							Dim tempFloat, tempInt
							tempInt = CInt(numFound/pageSize)
							tempFloat = CDbl(numFound/pageSize)
												
							if tempFloat - tempInt >= 0 then
								pageCount = CInt(tempInt + .5)
							elseif tempFloat - tempInt < 0 then
								pageCount = CInt(tempInt)
							end if
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

					Rule_ID = SmartValues(arRecRows(dictRecCols("ID"), rowCounter), "CInt")
					Validation_Document_ID = SmartValues(arRecRows(dictRecCols("Validation_Document_ID"), rowCounter), "CInt")
					Enabled = SmartValues(arRecRows(dictRecCols("Enabled"), rowCounter), "CBool")
				%>
				<%if i > 0 then%>
				<tr bgcolor=e6e6e6><a name="datarow_<%=Rule_ID%>" /><td colspan=100><img src="./images/spacer.gif" height=1 width=1></td></tr>
				<%end if%>
				<tr bgcolor=<%=rowcolor%> id="datarow_<%=Rule_ID%>" onMouseOver="HoverRow(<%=Rule_ID%>);" onMouseOut="HoverRow(0);" onDblClick="highlightRow();" oncontextmenu="HoverRow(<%=Rule_ID%>);SelectRow(<%=Rule_ID%>);displayMenu(); return false;">
					<td><img src="./images/spacer.gif" height=1 width=7></td>
					<td valign=top nowrap align="center"><font style="font-family:Arial, Helvetica;font-size:11px;"><a href="javascript:openEditRuleWindow(<%=Rule_ID%>); void(0);"><%=SmartValues(arRecRows(dictRecCols("Validation_Rule"), rowCounter), "CStr")%></a></font></td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap><font style="font-family:Arial, Helvetica;font-size:11px;"><%=SmartValues(arRecRows(dictRecCols("Rule_Type"), rowCounter), "CStr")%></font></td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap><font style="font-family:Arial, Helvetica;font-size:11px;"><%=SmartValues(arRecRows(dictRecCols("Display_Name"), rowCounter), "CStr")%></font></td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap><font style="font-family:Arial, Helvetica;font-size:11px;"><%if Enabled then Response.Write "YES" else Response.Write "NO" end if %></font></td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					
					<td class="datacol"><a href="#<%=Rule_ID%>" onMouseOver="hTaskBtn('taskIcon<%=Rule_ID%>', true)"  onMouseOut="hTaskBtn('taskIcon<%=Rule_ID%>', false)" onClick="SelectRow(<%=Rule_ID%>);HoverRow(<%=Rule_ID%>);this.parentElement.parentElement.click(); displayMenu(); return false;"><img id="taskIcon<%=Rule_ID%>" src="./../app_images/tasks_icon_off.gif" width=24 height=16 alt=":: Click to access tasks ::" border=0></a></td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					
					<td valign=top nowrap><font style="font-family:Arial, Helvetica;font-size:11px;"><%=SmartValues(arRecRows(dictRecCols("Date_Last_Modified"), rowCounter), "CStr")%></font></td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap><font style="font-family:Arial, Helvetica;font-size:11px;"><%=SmartValues(arRecRows(dictRecCols("Date_Created"), rowCounter), "CStr")%></font></td>
					<td width=100%><img src="./images/spacer.gif" height=1 width=5></td>
				</tr>
				<%
				i = i + 1
				Next
				%>
				<tr>
					<td><img src="./images/spacer.gif" height=1 width=1></td>
				<%for i = 0 to 4%>
					<td id="col_<%=i%>_data"><img id="col_<%=i%>_dataimg" src="./images/spacer.gif" height=1 width="<%if i < 0 then%>100<%else%>1<%end if%>"></td>
					<td><img src="./images/spacer.gif" height=1 width=1></td>
				<%next%>
				</tr>
			</table>
			<script language="javascript">
			<!--
				waitLyr.style.display = "none";
				parent.frames["DetailFrameHdr"].document.location = "validation_rules_detail_header.asp?sort=" + <%=SortColumn%> + "&direction=" + <%=SortDirection%>;
				parent.frames["PagingNavFrame"].document.location = "./../app_include/paging_navbar.asp?loc=<%=Request.ServerVariables("SCRIPT_NAME")%>&frm=DetailFrame&pageCount=<%=pageCount%>&curPage=<%=curPage%>&pageSize=<%=pageSize%>&numFound=<%=numFound%>&q=<%=Server.URLEncode("tid=" & Request.QueryString("tid"))%>";
			//-->
			</script>
			<%
			else
			%>
			<script language="javascript">
			<!--
				waitLyr.style.display = "none";
				parent.frames["DetailFrameHdr"].document.location = "../app_include/blank_999999.html";
				parent.frames["PagingNavFrame"].document.location = "../app_include/blank_cccccc.html";
			//-->
			</script>
			<%
			end if
			%>
		</td>
	</tr>
	</form>
</table>
<!--#include file="./include/validation_rules_contextmenu.asp"--><!--right click menu-->
</body>
</html>
<%
Set dictRecCols = Nothing
%>