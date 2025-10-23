<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441

%>
<!--#include file="../../app_include/smartValues.asp"-->
<!--#include file="../../app_include/findNeedleInHayStack.asp"-->
<!--#include file="../../app_include/returnDataWithGetRows.asp"-->
<%

Dim objConn, objRec, SQLStr, connStr, i
Dim thisID, Tax_UDA

Dim rowCounter, curIteration
Dim arDetailsDataRows, dictDetailsDataCols

Set dictDetailsDataCols		= Server.CreateObject("Scripting.Dictionary")

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")
connStr = Application.Value("connStr")
objConn.Open connStr

SQLStr = "sp_SPEDY_TaxWizard_Tax_UDA_ShowSorting "
'Response.Write "SQLStr = " & SQLStr & "<br>"
Call returnDataWithGetRows(connStr, SQLStr, arDetailsDataRows, dictDetailsDataCols)
%>
<html>
<head>
	<title>Sort Tax UDA</title>
	<style type="text/css">
	<!--
		A {text-decoration: none; cursor: hand;}
		A:HOVER {text-decoration: underline; cursor: hand;}
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
			font-family: Arial, Verdana, Geneva, Helvetica;
			font-size: 11px;
		}
	//-->
	</style>
	<script type="text/javascript" language="javascript">
		var selList1 = new Array();
		function saveArray(selObj)
		{
			selList1 = new Array();
			var outStr = "";
			var i = 0;
			var curPos = 0;
			//fetch current array
			with (selObj) 
			{
				for (i = 0; i < selObj.length; i++)
				{
				//	alert("text: " + selObj.options[i].text + "\nvalue: " + selObj.options[i].value + "\ni: " + i);
					selList1[curPos] = selObj.options[i].text;
					selList1[curPos + 1] = selObj.options[i].value;
				//	outStr = outStr + i + ': ' + selList1[curPos] + ' > ' + selList1[curPos + 1] + '\n';
					curPos = curPos + 2;
				}
			}
		//	alert("Array is now: \n\n" + outStr + "\n\n" + selList1.join(","));
		}

		
		function moveItem(selObj, direction)
		{
		//	alert(document.theForm.selectedAddresses.innerHTML);
			if (selObj.length > 0)
			{
				saveArray(selObj);
				var i = j = 0;
				var newItemPosition = 0;
				var selectedItem = "";
				var curPos = 0;
				var newPos = 0;
				var curArrayPos = 0;
				var newArrayPos = 0;
				var outStr = "";

				for (i = 0; i < selObj.length; i++)
				{
					if (selObj.options[i].selected)
					{
						//Figure out which item was selected
						selectedItem = selObj.options[i].value;

						//Where WAS this item?
						curPos = i;
						break;
					}
				}
		
				//Depending on the 'direction' variable, where is this item moving TO?
				switch (direction)
				{
					case "moveup":
						if ((curPos - 1) >= 0)
						{
							newPos = curPos - 1;
						}
						else
						{
							newPos = curPos;
						}
						break;
					case "movedown":
						if ((curPos + 1) < (selList1.length/2))
						{
							newPos = curPos + 1;
						}
						else
						{
							newPos = curPos;
						}
						break;
				}
			
				var curArrayPos = curPos * 2;
				var newArrayPos = newPos * 2;

			
				//Move the old occupant of this position to a temp place
				var tempOldOccupant = new Array();
				tempOldOccupant[0] = selList1[newArrayPos];				//Move OptionTag Description
				tempOldOccupant[1] = selList1[newArrayPos + 1];			//Move OptionTag Value
			
				//Move the moving item into its new place
				selList1[newArrayPos] = selList1[curArrayPos];			//Move OptionTag Description
				selList1[newArrayPos + 1] = selList1[curArrayPos + 1];	//Move OptionTag Value

				//Move the old occupant into the newly cleared space
				selList1[curArrayPos] = tempOldOccupant[0];				//Move OptionTag Description
				selList1[curArrayPos + 1] = tempOldOccupant[1];			//Move OptionTag Value

				var newItemPosition = 0;
				//Modify Select List with new order
				with (selObj) 
				{
					options.length = 0;
				//	alert("selList1.length:" + selList1.length);
					for (i = 0; i < selList1.length; i++)
					{
					//	alert("i:" + i);
					//	alert("options.length:" + options.length);
						newItemPosition = options.length;
						options[newItemPosition] = new Option(selList1[i],selList1[i + 1]);
						if (options[newItemPosition].value == selectedItem)
						{
							options[newItemPosition].selected = true;
						}
					//	alert("text: " + selObj.options[newItemPosition].text + "\nvalue: " + selObj.options[newItemPosition].value + "\nnewItemPosition: " + newItemPosition);
						if (i >= selList1.length)
							break;
						else
							i++;
					}
				}
			}
		//	alert(document.theForm.selectedAddresses.innerHTML);
		}
		function moveItem2(selObj, direction)
		{
			if (selObj.length > 0)
			{
				var tempOrdinal = targetOrdinal = srcOrdinal = 0;
				var tempText = targetText = srcText = "";
				var tempValue = targetValue = srcValue = "";
				
				srcOrdinal = selObj.selectedIndex;
				srcText = selObj.options[srcOrdinal].text;
				srcValue = selObj.options[srcOrdinal].value;

				//Depending on the 'direction' variable, where is this item moving TO?
				switch (direction)
				{
					case "moveup":
						if (srcOrdinal > 0)
						{
							targetOrdinal = srcOrdinal - 1;
						}
						else
						{
							return;
						}
						break;
					case "movedown":
						if (srcOrdinal < (selObj.length - 1))
						{
							targetOrdinal = srcOrdinal + 1;
						}
						else
						{
							return;
						}
						break;
				}
				
				//move the current resident of the target into the temp space
				tempText = selObj.options[targetOrdinal].text;
				tempValue = selObj.options[targetOrdinal].value;
				
				//move the source into the target location
				selObj.options[targetOrdinal].text = srcText;
				selObj.options[targetOrdinal].value = srcValue;
				
				//move the jilted item from the temp space into the old, source space. 
				selObj.options[srcOrdinal].text = tempText;
				selObj.options[srcOrdinal].value = tempValue;
				
				//highlight the moved item.
				selObj.options[targetOrdinal].selected = true;
			}
		}
	

		function preloadImgs()
		{
			if (document.images)
			{		
				btnMoveUp_ImgOn = new Image();
				btnMoveUp_ImgOff = new Image();
				btnMoveDn_ImgOn = new Image();
				btnMoveDn_ImgOff = new Image();
				btnMoveUp_ImgOn.src = "./../images/sortbtn_moveup_on.gif";
				btnMoveUp_ImgOff.src = "./../images/sortbtn_moveup_off.gif";
				btnMoveDn_ImgOn.src = "./../images/sortbtn_movedn_on.gif";
				btnMoveDn_ImgOff.src = "./../images/sortbtn_movedn_off.gif";
			}
		}
		preloadImgs()
		
		function highlightNavBtn(imgName, boolOn)
		{
			if (document.images) 
			{
				if (boolOn)
				{
					document.images[imgName].src = eval(imgName + "_ImgOn.src");
				}
				else
				{
					document.images[imgName].src = eval(imgName + "_ImgOff.src");
				}
			}
		}
	</script>
</head>
<body bgcolor="cccccc" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>
<table width=100% cellpadding=0 cellspacing=0 border=0>
	<form name="theForm" action="tax_sort_save.asp" method="POST">
	<tr bgcolor="cccccc"><td><img src="../images/spacer.gif" height=10 border=0></td></tr>
	<tr bgcolor="cccccc">
		<td width=100% valign=top>
			<%if dictDetailsDataCols("ColCount") > 0 and dictDetailsDataCols("RecordCount") > 0 then%>
			<table cellpadding=0 cellspacing=0 border=0>
				<tr>
					<td><img src="./../images/spacer.gif" height=1 width=10 border=0></td>
					<td valign=top>
						<select name="itemList" size=15 style="width:300px;height:250px;font-size:9px;">
						<%
						for rowCounter = 0 to dictDetailsDataCols("RecordCount") - 1
							Tax_UDA = SmartValues(arDetailsDataRows(dictDetailsDataCols("Tax_UDA_Number"), rowCounter), "CStr")
							thisID = SmartValues(arDetailsDataRows(dictDetailsDataCols("ID"), rowCounter), "CStr")
						Response.Write "<option value=""" & thisID & """>" & Tax_UDA & "</option>" & vbCrLf
						next
						%>
						</select>
					</td>
					<td><img src="./../images/spacer.gif" height=1 width=10 border=0></td>
					<td valign=top>
						<table cellpadding=0 cellspacing=0 border=0 align=center>
							<tr><td><img src="./../images/spacer.gif" height=2 width=1 border=0></td></tr>
							<tr><td><a href="javascript:void(0);moveItem2(document.theForm.itemList, 'moveup'); highlightNavBtn('btnMoveUp', true)" onMouseDown="highlightNavBtn('btnMoveUp', false)" onMouseUp="highlightNavBtn('btnMoveUp', true)"><img name="btnMoveUp" id="btnMoveUp" src="./../images/sortbtn_moveup_on.gif" border=0 alt="Move the selected Tax UDA up in the list"></a></td></tr>
							<tr><td><img src="./../images/spacer.gif" height=10 width=1 border=0></td></tr>
							<tr><td><a href="javascript:void(0);moveItem2(document.theForm.itemList, 'movedown'); highlightNavBtn('btnMoveDn', true)" onMouseDown="highlightNavBtn('btnMoveDn', false)" onMouseUp="highlightNavBtn('btnMoveDn', true)"><img name="btnMoveDn" id="btnMoveDn" src="./../images/sortbtn_movedn_on.gif" border=0 alt="Move the selected Tax UDA down in the list"></a></td></tr>
						</table>
					</td>
				</tr>
			</table>
			<%else%>
			<table cellpadding=0 cellspacing=0 border=0>
				<tr>
					<td><img src="./../images/spacer.gif" height=1 width=10 border=0></td>
					<td valign=top>
						<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
						Sorry, there is nothing to sort.
						<br><br>
						<a href="javascript: void(0); parent.window.close();" style="color:#00f; text-decoration: underline;">Close Window</a>
						</font>
					</td>
				</tr>
			</table>
			<%end if%>
		</td>
	</tr>
	<input type=hidden name="sortedList" value="">
	</form>
</table>
<script language="javascript">
	<!--
		parent.frames["header"].document.location = "tax_sort_header.asp";
		<%if dictDetailsDataCols("ColCount") > 0 and dictDetailsDataCols("RecordCount") > 0 then%>
		parent.frames["controls"].document.location = "tax_sort_footer.asp";
		<%end if%>
	//-->
</script>

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

Set arDetailsDataRows = Nothing
Set dictDetailsDataCols = Nothing
%>