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
Dim Record_ID, recordTypeID, gridViewEnabled
Dim thisUserID
thisUserID = CLng(Session.Value("UserID"))

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr

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
recordTypeID = 0
gridViewEnabled = false
if Record_ID > 0 then
	SQLStr = "sp_CustomFields_Records_GetRecord " & Record_ID
	objRec.Open SQLStr, objConn, adOpenStatic, adLockReadOnly, adCmdText
	if not objRec.EOF then
	    recordTypeID = SmartValues(objRec("Record_Type_ID"), "CInt")
	    gridViewEnabled = SmartValues(objRec("Grid_View_Enabled"), "CBool")
	end if
	objRec.Close
end if
%>
<html>
<head>
	<title>Custom Field List</title>
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
	<script language="javascript" src="./include/custom_fields_contextmenu.js"></script><!--right click menu-->
	<script language="javascript" src="./../app_include/prototype/prototype.js"></script>
	<script language="javascript" src="./../app_include/prototype/scriptaculous.js"></script>
	<script language=javascript>
	<!--
		window.defaultStatus = "Manage Custom Fields";
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
	
		function openEditFieldWindow(selectedItemID)
		{
			newDocWin = window.open("./custom_field_admin/field_details_frm.asp?tid=<%=Record_ID%>&fid=" + selectedItemID, "editFieldWindow_" + selectedItemID, "width=500,height=400,toolbar=0,titlebar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=0,resizable=0");
			newDocWin.focus();
		}
		
		function deleteField(RowID)
		{
			if (confirm("Really remove this field?\n\nThis cannot be undone!"))
			{
				document.location = "./custom_field_admin/field_remove.asp?tid=<%=Record_ID%>&fid=" + RowID;
			}
			
		}
		
		function openAddFieldWindow(RowID)
		{
			var newFieldWin = window.open("./custom_field_admin/field_details_frm.asp?tid=<%=Record_ID%>&fid=" + '0', "newFieldWindow_" + RowID, "width=500,height=400,toolbar=0,titlebar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=0,resizable=0");
			newFieldWin.focus();
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
					openEditFieldWindow(selectedItemID);
					break;			
				case "ItemDelete":
					waitLyr.style.display = "";
					deleteField(selectedItemID);
					waitLyr.style.display = "none";
					break;
				case "ItemAdd":
					openAddFieldWindow(selectedItemID);
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
<%WriteFieldList(recordTypeID) %>
</div>

<!--#include file="./include/custom_fields_contextmenu.asp"--><!--right click menu-->

<script language="javascript">
	waitLyr.style.display = "none";
	resizeFrame("1,0,*,0,25", "CustomFieldsDetailsWrapperFrameset", parent.frames, "rows");
</script>
</body>
</html>
<%
Sub WriteFieldList(recordType)
	Dim SQLStr, z, rowcolor, numFound
	Dim thisOpenString, boolIsLast, boolShowOpen
	Dim boolHasChildren, numChildren
	Dim Field_ID, Record_Type, Field_Name, Field_Type, Field_Limit, Display, Grid
	Dim Date_Created, Date_Modified
	Dim strTemp

	SQLStr = "sp_CustomFields_GetFieldList '0" & recordType & "'"
	'Response.Write "EXEC " & SQLStr & "<br>"
	objRec.Open SQLStr, objConn, adOpenKeyset, adLockReadOnly, adCmdText
	
	
	%>
	<form name="frmMenu" action="custom_fields_detail.asp?<%=Request.ServerVariables("QUERY_STRING")%>" method="post" ID="frmMenu">
	<table cellpadding=0 cellspacing=0 border=0 ID="Table1" onselectstart="return false;">
		<tr class="hdrrow">
			<td class="bodyText spacercell">&nbsp;</td>
			<td class="bodyText datacol_hdrrow">Field Name&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;</td>
			<td class="bodyText datacol_hdrrow">Type</td>
			<td class="bodyText datacol_hdrrow">Limit</td>
			<td class="bodyText datacol_hdrrow">Display</td>
			<% if gridViewEnabled then %>
			<td class="bodyText datacol_hdrrow">Show in Grid</td>
			<% end if %>
			<td class="bodyText datacol_hdrrow">Tasks</td>
			<td class="bodyText datacol_hdrrow">Date Created</td>
			<td class="bodyText datacol_hdrrow" width="100%" style="width: 100%;">Date Modified</td>
			<td class="bodyText spacercell">&nbsp;</td>
		</tr>
		<tr><td><img src="./../app_images/spacer.gif" height=2 width=1></td></tr>
	<%

	if not objRec.EOF then
		Do Until objRec.EOF
		    Field_ID = SmartValues(objRec("ID"), "CInt")
		    Record_Type = SmartValues(objRec("Record_Type"), "CInt")
		    Field_Name = SmartValues(objRec("Field_Name"), "CStr")
		    Field_Type = SmartValues(objRec("Field_Type"), "CInt")
		    Field_Limit = SmartValues(objRec("Field_Limit"), "CInt")
		    Display = SmartValues(objRec("Display"), "CBool")
		    Grid = SmartValues(objRec("Grid"), "CBool")
		    Date_Created = SmartValues(objRec("Date_Created"), "CDate")
		    Date_Modified = SmartValues(objRec("Date_Last_Modified"), "CDate")

			if i mod 2 = 1 then				
				rowcolor = "f3f3f3"
			else
				rowcolor = "ffffff"
			end if
		%>
		<tr id="datarow_<%=Field_ID%>" class="datarow" style="background: #<%=rowcolor%>;" onMouseOver="HoverRow(<%=Field_ID%>);" onMouseOut="HoverRow(0);" onDblClick="highlightRow();" oncontextmenu="HoverRow(<%=Field_ID%>);SelectRow(<%=Field_ID%>);displayMenu(); return false;">
			<td class="bodyText spacercell">&nbsp;</td>
			<td class="bodyText datacol"><%=Field_Name %>&nbsp;</td>
			<td class="bodyText datacol">
			<%
			select case Field_Type
			  case 1
			    Response.Write "BOOLEAN"
			  case 2
			    Response.Write "DATE"
			  case 3
			    Response.Write "DATE/TIME"
			  case 4
			    Response.Write "DECIMAL"
			  case 5
			    Response.Write "INTEGER"
			  case 6
			    Response.Write "LONG"
			  case 7
			    Response.Write "MONEY"
			  case 8
			    Response.Write "PERCENT"
			  case 10
			    Response.Write "TEXT"
			  case 11
			    Response.Write "TIME"
			  case else  
			    Response.Write "STRING"
			end select
			%>
			&nbsp;</td>
			<td class="bodyText datacol"><%=Field_Limit %>&nbsp;</td>
			<td class="bodyText datacol"><%if Display then Response.Write "YES" else Response.Write "NO" end if %>&nbsp;</td>
			<% if gridViewEnabled then %>
			<td class="bodyText datacol"><%if Grid then Response.Write "YES" else Response.Write "NO" end if %>&nbsp;</td>
			<% end if %>
			<td class="datacol"><a href="#<%=Field_ID%>" onMouseOver="hTaskBtn('taskIcon<%=Field_ID%>', true)"  onMouseOut="hTaskBtn('taskIcon<%=Field_ID%>', false)" onClick="SelectRow(<%=Field_ID%>);HoverRow(<%=Field_ID%>);this.parentElement.parentElement.click(); displayMenu(); return false;"><img id="taskIcon<%=Field_ID%>" src="./../app_images/tasks_icon_off.gif" width=24 height=16 alt=":: Click to access tasks ::" border=0></a></td>
			<td class="bodyText datacol"><%=Date_Created%>&nbsp;</td>
			<td class="bodyText datacol" width="100%" style="width: 100%;"><%=Date_Modified%>&nbsp;</td>
			<td class="bodyText spacercell">&nbsp;</td>
		</tr>
		<%
			i = i + 1
			objRec.MoveNext
			Response.Flush
		Loop
	end if
	
	%>
	</table>
	<input type="hidden" name="selectedItemID" value="-1" ID="selectedItemID">
	<input type="hidden" name="hoveredItemID" value="-1" ID="hoveredItemID">
	</form>

	<script language=javascript>
		//printEvaluator();
	</script>

	<%
	
	if objRec.State <> adStateClosed then
		On Error Resume Next
		objRec.Close
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

%>


