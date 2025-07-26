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
<!--#include file="./../app_include/checkQueryID.asp"-->
<%
'	Dim Security
'	Set Security = New cls_Security
'	Security.Initialize Session.Value("UserID"), "ADMIN", 0

Dim objConn, objRec, SQLStr, connStr, i
Dim Record_ID, Table_ID, recordTypeID, gridViewEnabled
Dim thisUserID
thisUserID = CLng(Session.Value("UserID"))

Dim Rule_ID, Validation_Document_ID, Enabled

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr

Record_ID = checkQueryID(Request("tid"), 0)
if not IsNumeric(Record_ID) or Record_ID = 0 then
	if IsNumeric(Session.Value("recordID")) and Trim(Session.Value("recordID")) <> "" then
		Record_ID = Session.Value("recordID")
	else
		Record_ID = 0
	end if
end if
Session.Value("recordID") = Record_ID
i = 0
if Record_ID > 0 then
	SQLStr = "usp_Validation_Docs_GetRecord " & Record_ID
	objRec.Open SQLStr, objConn, adOpenStatic, adLockReadOnly, adCmdText
	if not objRec.EOF then
	    Table_ID = SmartValues(objRec("Metadata_Table_ID"), "Integer")
	end if
	objRec.Close
end if
%>
<html>
<head>
	<title>Validation Rule List</title>
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
	<script language="javascript" src="./include/validation_rules_contextmenu.js"></script><!--right click menu-->
	<script language="javascript" src="./../app_include/prototype/prototype.js"></script>
	<script language="javascript" src="./../app_include/prototype/scriptaculous.js"></script>
	<script language="javascript" type="text/javascript">
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
					openEditRuleWindow(selectedItemID);
					break;	
			    case "ItemMoveUp":
			        moveup(<%=Record_ID%>, selectedItemID);
			        break;
			    case "ItemMoveDown":
			        movedown(<%=Record_ID%>, selectedItemID);
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
		 
		 function moveup(tid, rid) 
		 {
		    var s = '#ruleListRows' + ' tr';
            var arr = $$(s);
            var i, rowid, row, h;
            for(i = 0; i < arr.length; i++){
                row = arr[i];
                rowid = row.id;
                if(rowid == ('datarow_'+rid)){
                    if(i > 0){
                        document.location = './validation_rules_move.asp?d=up&tid=' + tid + '&rid=' + rid;
                    }
                    break;
                }
            }
		 }
		 
		 function movedown(tid, rid)
		 {
		    var s = '#ruleListRows' + ' tr';
            var arr = $$(s);
            var i, rowid, row, h;
            for(i = 0; i < arr.length; i++){
                row = arr[i];
                rowid = row.id;
                if(rowid == ('datarow_'+rid)){
                    if(i < (arr.length - 1)){
                        document.location = './validation_rules_move.asp?d=down&tid=' + tid + '&rid=' + rid;
                    }
                    break;
                }
            }
		 }
		 
		 function restyleList()
		 {
		 }

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
<%WriteFieldList(Record_ID) %>
</div>

<!--#include file="./include/validation_rules_contextmenu.asp"--><!--right click menu-->

<script language="javascript">
	waitLyr.style.display = "none";
	resizeFrame("1,0,*,0,25", "DetailsWrapperFrameset", parent.frames, "rows");
</script>
</body>
</html>
<%
Function GetAlphaOnlyStr(checkString)
    Dim isValid, i, charStr, charVal
    isValid = True
    Dim returnStr
    returnStr = ""
    Dim charArr
    If Len(checkString) > 0 Then
        For i = 0 To Len(checkString) - 1
            charStr = Mid(checkString, i + 1, 1)
            charVal = Asc(charStr)
            If charVal < 65 Or (charVal > 90 And charVal < 97) Or charVal > 122 Then
                isValid = False
            Else
                returnStr = returnStr & charStr
            End If
        Next
    End If
    GetAlphaOnlyStr = returnStr
End Function

Sub WriteFieldList(recordID)
	Dim SQLStr, z, rowcolor, numFound
	Dim thisOpenString, boolIsLast, boolShowOpen
	Dim boolHasChildren, numChildren
	Dim Rule_ID, Validation_Document_ID, Validation_Rule, Metadata_Column_ID, Column_Name, Display_Name, Rule_Ordinal, Enabled
	Dim Date_Created, Date_Modified
	Dim strTemp

	SQLStr = "usp_Validation_GetRuleList '0" & recordID & "', '" & GetAlphaOnlyStr(Request("search")) & "'"
	'Response.Write "EXEC " & SQLStr & "<br>"
	objRec.Open SQLStr, objConn, adOpenKeyset, adLockReadOnly, adCmdText
	
	
	%>
	<form name="frmMenu" action="validation_rules_detail.asp?<%=Request.ServerVariables("QUERY_STRING")%>" method="post" ID="frmMenu">
	<table cellpadding="0" cellspacing="0" border="0" id="ruleList" name="ruleList" onselectstart="return false;">
	    <thead>
		<tr class="hdrrow">
			<td class="bodyText spacercell">&nbsp;</td>
			<td class="bodyText spacercell">&nbsp;</td>
			<td class="bodyText datacol_hdrrow">Rule&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;</td>
			<td class="bodyText datacol_hdrrow">Column</td>
			<td class="bodyText datacol_hdrrow">Enabled</td>
			<td class="bodyText datacol_hdrrow">&nbsp;</td>
			<td class="bodyText datacol_hdrrow">Modified</td>
			<td class="bodyText datacol_hdrrow" width="100%" style="width: 100%;">Created</td>
			<td class="bodyText spacercell">&nbsp;</td>
		</tr>
		<tr><td><img src="./../app_images/spacer.gif" height=2 width=1></td></tr>
		</thead>
		<tbody id="ruleListRows">
	<%

	if not objRec.EOF then
		Do Until objRec.EOF
		    Rule_ID = SmartValues(objRec("ID"), "Integer")
		    Validation_Document_ID = SmartValues(objRec("Validation_Document_ID"), "Integer")
		    Validation_Rule = SmartValues(objRec("Validation_Rule"), "String")
		    Column_Name = SmartValues(objRec("Column_Name"), "String")
		    Display_Name = SmartValues(objRec("Display_Name"), "String")
		    Enabled = SmartValues(objRec("Enabled"), "CBool")
		    Date_Created = SmartValues(objRec("Date_Created"), "CDate")
		    Date_Modified = SmartValues(objRec("Date_Last_Modified"), "CDate")

			if i mod 2 = 1 then				
				rowcolor = "f3f3f3"
			else
				rowcolor = "ffffff"
			end if
		%>
		<tr id="datarow_<%=Rule_ID%>" class="datarow" style="background: #<%=rowcolor%>;" onmouseover="HoverRow(<%=Rule_ID%>);" onmouseout="HoverRow(0);" ondblclick="highlightRow();" oncontextmenu="HoverRow(<%=Rule_ID%>);SelectRow(<%=Rule_ID%>);displayMenu(); return false;">
			<td class="bodyText spacercell">&nbsp;</td>
			<td class="bodyText spacercell" style="padding-right: 5px;"><table border="0" cellpadding="0" cellspacing="0" style="height: 11px; width: 7px;">
			    <tr><td style="height: 4px; width: 7px;"><a href="#" onclick="moveup(<%=recordID%>, <%=Rule_ID%>); return false;" title="move up"><img src="./../app_images/app_icons/arrowup.gif" alt="move up" height="4" width="7" border="0" /></a></td></tr>
			    <tr><td style="height: 3px; width: 7px;"><img src="./images/spacer.gif" alt="" height="3" width="7" border="0" /></td></tr>
			    <tr><td style="height: 4px; width: 7px;"><a href="#" onclick="movedown(<%=recordID%>, <%=Rule_ID%>); return false;" title="move down"><img src="./../app_images/app_icons/arrowdown.gif" alt="move down" height="4" width="7" border="0" /></a></td></tr>
			</table></td>
			<td class="bodyText datacol"><%=Validation_Rule%>&nbsp;</td>
			<td class="bodyText datacol"><%=Display_Name %>&nbsp;</td>
			<td class="bodyText datacol"><%if Enabled then Response.Write "YES" else Response.Write "NO" end if %>&nbsp;</td>
			<td class="datacol"><a href="#<%=Rule_ID%>" onMouseOver="hTaskBtn('taskIcon<%=Rule_ID%>', true)"  onMouseOut="hTaskBtn('taskIcon<%=Rule_ID%>', false)" onClick="SelectRow(<%=Rule_ID%>);HoverRow(<%=Rule_ID%>);this.parentElement.parentElement.click(); displayMenu(); return false;"><img id="taskIcon<%=Rule_ID%>" src="./../app_images/tasks_icon_off.gif" width=24 height=16 alt=":: Click to access tasks ::" border=0></a></td>
			<td class="bodyText datacol"><%=Date_Modified%>&nbsp;</td>
			<td class="bodyText datacol" width="100%" style="width: 100%;"><%=Date_Created%>&nbsp;</td>
			<td class="bodyText spacercell">&nbsp;</td>
		</tr>
		<%
			i = i + 1
			objRec.MoveNext
			Response.Flush
		Loop
	end if
	
	%>
	    </tbody>
	</table>
	<input type="hidden" name="selectedItemID" value="-1" id="selectedItemID" />
	<input type="hidden" name="hoveredItemID" value="-1" id="hoveredItemID" />
	</form>

<script language="javascript" type="text/javascript">
<!--
//printEvaluator();
//Sortable.create('ruleListRows', { tag: 'tr', handle: '', onUpdate: function() {reorderRuleList();} });
//-->
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


