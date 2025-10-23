<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
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

Dim Item_ID
Dim Item_Name

Dim taskStr, separatorStr
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

SortColumn = Trim(Request("sort"))
if IsNumeric(SortColumn) and Trim(SortColumn) <> "" then
	SortColumn = CInt(SortColumn)
	Session.Value("WorkflowExc_List_SortColumn") = SortColumn
else
	if IsNumeric(Session.Value("WorkflowExc_List_SortColumn")) and Trim(Session.Value("WorkflowExc_List_SortColumn")) <> "" then
		SortColumn = CInt(Session.Value("WorkflowExc_List_SortColumn"))
	else
		SortColumn = 0
		Session.Value("WorkflowExc_List_SortColumn") = SortColumn
	end if
end if

SortDirection = Trim(Request("direction"))
if IsNumeric(SortDirection) and Trim(SortDirection) <> "" then
	SortDirection = CInt(SortDirection)
	Session.Value("WorkflowExc_List_SortDirection") = SortDirection
else
	if IsNumeric(Session.Value("WorkflowExc_List_SortDirection")) and Trim(Session.Value("WorkflowExc_List_SortDirection")) <> "" then
		SortDirection = CInt(Session.Value("WorkflowExc_List_SortDirection"))
	else
		SortDirection = 0
		Session.Value("WorkflowExc_List_SortDirection") = SortDirection
	end if
end if

Set dictRecCols	= Server.CreateObject("Scripting.Dictionary")
connStr = Application.Value("connStr")
dim id
id = checkQueryID(Trim(Request("id")),0)
SQLStr = "sp_SPEDY_WorkflowStages_ReturnAll " & id  & ", " & SortColumn & ", " & SortDirection & ", " & pageSize & ", " & startRow
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
	<title>View All Content</title>
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
	<script language="javascript" src="./include/workflow_stages_list_contextmenu.js"></script><!--right click menu-->
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
			    /*
				case "ItemView":
					showDetailsFrame(selectedItemID);
					break;
				case "ItemSort":
					openSortWindow(selectedItemID);
					break;
				*/
				case "ItemEdit":
					openEditItemWindow(selectedItemID);
					break;				
				case "ItemDelete":
					waitLyr.style.display = "";
					deleteItem(selectedItemID);
					waitLyr.style.display = "none";
					break;
				case "ItemAdd":
					openAddItemWindow(selectedItemID);
					break;
					
				case "ItemFieldLocking":
				    openFieldLockingWindow(selectedItemID);
				    break;

				default:
					break;
			}
		}
/*
		function showDetailsFrame(itemID)
		{
			highlightSelectedItemRow(itemID);
			parent.parent.frames['TaxWizardDetailFrame'].document.location = "tax_wizard_details_frm.asp?tid="+itemID;
			if (parent.parent.frames.document.getElementById('MainTaxWizardListFrame').rows == '*,0')
			{
				resizeFrame('200,*', 'MainTaxWizardListFrame', parent.parent.frames);
			}
		}
		
		function openSortWindow(RowID)
		{
			sortWin = window.open("./tax_wizard_admin/tax_sort_frm.asp?tid=" + RowID, "sortWindow_" + RowID, "width=360,height=325,toolbar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=0,resizable=0");
			sortWin.focus();
		}
*/
		function openEditItemWindow(selectedItemID)
		{
		    var url = './../transfersession.asp?url=' + escape("workflow_detail.aspx?id=" + selectedItemID + "&Workflowid=<%=id%>");
			newDocWin = window.open(url,  "newTaxWindow_", "width=1024,height=750,toolbar=0,titlebar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=1,resizable=1");
			newDocWin.focus();
		}
		
		function deleteItem(RowID)
		{
			if (confirm("Really remove this Workflow Exception?\n\nThis cannot be undone!"))
			{
				document.location = "./workflow_admin/exception_remove.asp?id=" + RowID;
			}
			
		}
		
		function openAddItemWindow(RowID)
		{
			var url = './../transfersession.asp?url=' + escape("workflow_detail.aspx?id="+ "&Workflowid=<%=id%>");
			var newDocWin = window.open(url, "newTaxWindow_", "width=1000,height=600,toolbar=0,titlebar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=1,resizable=1");
			newDocWin.focus();
		}
		
		
		function openFieldLockingWindow(selectedItemID)
		{
		    var userid = "<%=Session("UserId") %>";
		    newDocWin = window.open("field_locking_admin/field_locking_frm.asp?wid=<%=id%>&id=" + selectedItemID + "&userid=" + userid,  "FLWindow_", "width=785,height=700,toolbar=0,titlebar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=1,resizable=1");
			newDocWin.focus();
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
		/*
		function closeDetailsFrame()
		{
			resizeFrame('*,0', 'MainTaxWizardListFrame', parent.parent.frames);
			boolFrameClosed = true;
		}
		*/
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
				<tr bgcolor=ffffff>
				    <td colspan=23><img src="./images/spacer.gif" height=2 width=1></td>
				</tr>
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

					Item_ID = SmartValues(arRecRows(dictRecCols("ID"), rowCounter), "CInt")
					Item_Name = SmartValues(arRecRows(dictRecCols("Stage_Name"), rowCounter), "CStr")
				%>
				<%if i > 0 then%>
				<tr bgcolor=e6e6e6><a name="datarow_<%=Item_ID%>" /><td colspan=23><img src="./images/spacer.gif" height=1 width=1></td></tr>
				<%end if%>
				<tr bgcolor=<%=rowcolor%> id="datarow_<%=Item_ID%>" onMouseOver="HoverRow(<%=Item_ID%>);" onMouseOut="HoverRow(0);" onDblClick="highlightRow();" oncontextmenu="HoverRow(<%=Item_ID%>);SelectRow(<%=Item_ID%>);displayMenu(); return false;">
					<td><img src="./images/spacer.gif" height=1 width=7></td>
					<td valign=top nowrap><font style="font-family:Arial, Helvetica;font-size:11px;"><a href="javascript:openEditItemWindow(<%=Item_ID%>,<%=id%>); void(0);"><%=Item_Name%></a></font></td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td class="datacol"><a href="#<%=Item_ID%>" onMouseOver="hTaskBtn('taskIcon<%=Item_ID%>', true)"  onMouseOut="hTaskBtn('taskIcon<%=Item_ID%>', false)" onClick="SelectRow(<%=Item_ID%>);HoverRow(<%=Item_ID%>);this.parentElement.parentElement.click(); displayMenu(); return false;"><img id="taskIcon<%=Item_ID%>" src="./../app_images/tasks_icon_off.gif" width=24 height=16 alt=":: Click to access tasks ::" border=0></a></td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap><font style="font-family:Arial, Helvetica;font-size:11px;"><%=SmartValues(arRecRows(dictRecCols("Sequence"), rowCounter), "CStr")%></font></td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap><font style="font-family:Arial, Helvetica;font-size:11px;"><%=SmartValues(arRecRows(dictRecCols("Enabled"), rowCounter), "CStr")%></font></td>
					<td><img src="./images/spacer.gif" height=1 width=10</td>
					<td valign=top align=left nowrap><font style="font-family:Arial, Helvetica;font-size:11px;"><%=SmartValues(arRecRows(dictRecCols("Pri_Approver_Group"), rowCounter), "CStr")%></font></td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top align=left nowrap><font style="font-family:Arial, Helvetica;font-size:11px;"><%=SmartValues(arRecRows(dictRecCols("Next_Stage_Name"), rowCounter), "CStr")%></font></td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top align=left nowrap><font style="font-family:Arial, Helvetica;font-size:11px;"><%=SmartValues(arRecRows(dictRecCols("Previos_Stage_Name"), rowCounter), "CStr")%></font></td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap><font style="font-family:Arial, Helvetica;font-size:11px;"><%=SmartValues(arRecRows(dictRecCols("Created_User"), rowCounter), "CStr")%></font></td>
					<td><img src="./images/spacer.gif" height=1 width=10</td>
					<td valign=top nowrap><font style="font-family:Arial, Helvetica;font-size:11px;"><%=SmartValues(arRecRows(dictRecCols("Date_Created"), rowCounter), "CStr")%></font></td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap><font style="font-family:Arial, Helvetica;font-size:11px;"><%=SmartValues(arRecRows(dictRecCols("Update_User"), rowCounter), "CStr")%></font></td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap><font style="font-family:Arial, Helvetica;font-size:11px;"><%=SmartValues(arRecRows(dictRecCols("Date_Last_Modified"), rowCounter), "CStr")%></font></td>
					<td width=100%><img src="./images/spacer.gif" height=1 width=5></td>
				</tr>
				<%
				i = i + 1
				Next
				%>
				<tr>
					<td><img src="./images/spacer.gif" height=1 width=1></td>
				<%for i = 0 to 10%>
					<td id="col_<%=i%>_data"><img id="col_<%=i%>_dataimg" src="./images/spacer.gif" height=1 width="<%if i < 0 then%>100<%else%>1<%end if%>"></td>
					<td><img src="./images/spacer.gif" height=1 width=1></td>
				<%next%>
				</tr>
			</table>
			<script language="javascript">
			<!--
				waitLyr.style.display = "none";
				parent.frames["DetailFrameHdr"].document.location = "workflow_stages_list_header.asp?sort=" + <%=SortColumn%> + "&direction=" + <%=SortDirection%> + "&id=" + <%=id%>;
				parent.frames["PagingNavFrame"].document.location = "./../app_include/paging_navbar.asp?loc=<%=Request.ServerVariables("SCRIPT_NAME")%>&frm=DetailFrame&pageCount=<%=pageCount%>&curPage=<%=curPage%>&pageSize=<%=pageSize%>&numFound=<%=numFound%>&q=<%=Server.URLEncode("tid=" & Request.QueryString("tid"))%>";
				<%'if Session.Value("ORDER_LIST_CLOSE_DETAILPANE") <> "1" then%>
				//closeDetailsFrame();
				<%
				'Session.Value("ORDER_LIST_CLOSE_DETAILPANE") = ""
				'end if
				%>
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
				<%'if Session.Value("ORDER_LIST_CLOSE_DETAILPANE") <> "1" then%>
				//closeDetailsFrame();
				<%
				'Session.Value("ORDER_LIST_CLOSE_DETAILPANE") = ""
				'end if
				%>
			//-->
			</script>
			<%
			end if
			%>
		</td>
	</tr>
	</form>
</table>
<!--#include file="./include/workflow_stages_list_contextmenu.asp"--><!--right click menu-->
</body>
</html>
<%
Set dictRecCols = Nothing
%>