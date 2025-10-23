<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441

Dim objConn, objRec, SQLStr, connStr
Dim Order_ID
Dim SortColumn, SortDirection, numCols, showImgType

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

Order_ID = Trim(Request("oid"))
if IsNumeric(Order_ID) then
	Order_ID = CInt(Order_ID)
else
	Order_ID = 0
end if

SortColumn = Trim(Request("sort"))
if IsNumeric(SortColumn) then
	SortColumn = CInt(SortColumn)
else
	SortColumn = 0
end if

SortDirection = Trim(Request("direction"))
if IsNumeric(SortDirection) then
	SortDirection = CInt(SortDirection)
else
	SortDirection = 0
end if

numCols = Trim(Request("numcols"))
if IsNumeric(numCols) then
	numCols = CInt(numCols)
else
	numCols = 0
end if

showImgType = Trim(Request("imgtype"))
if IsNumeric(showImgType) then
	showImgType = CInt(showImgType)
else
	showImgType = 0
end if
%>
<html>
<head>
	<title></title>
	<script language="javascript">

	function changeDisplayStyle(sel)
	{
		parent.parent.frames['EditPaneDetailsFrame'].document.location = "order_details_product_details_frm.asp?oid=<%=Request("oid")%>&displaytype=" + sel;
	}
	function changeSortColumn(col_ordinal)
	{
		switch (document.theForm.displayStyle.value)
		{
			case '1':
				parent.frames["DetailFrame"].document.location = "order_details_product_details_results_listview.asp?oid=<%=Order_ID%>&sort=" + col_ordinal;
				break;
			case '2':
				parent.frames["DetailFrame"].document.location = "order_details_product_details_results_thumbview.asp?oid=<%=Order_ID%>&sort=" + col_ordinal;
				break;
		}
	}
	function changeSortDirection(sort_direction)
	{
		switch (document.theForm.displayStyle.value)
		{
			case '1':
				parent.frames["DetailFrame"].document.location = "order_details_product_details_results_listview.asp?oid=<%=Order_ID%>&direction=" + sort_direction;
				break;
			case '2':
				parent.frames["DetailFrame"].document.location = "order_details_product_details_results_thumbview.asp?oid=<%=Order_ID%>&direction=" + sort_direction;
				break;
		}
	}
	function changeNumCols(sel)
	{
		parent.frames["DetailFrame"].document.location = "order_details_product_details_results_thumbview.asp?oid=<%=Order_ID%>&numcols=" + sel;
	}
	function changeImgType(sel)
	{
		parent.frames["DetailFrame"].document.location = "order_details_product_details_results_thumbview.asp?oid=<%=Order_ID%>&imgtype=" + sel;
	}
	</script>
</head>
<body bgcolor="cccccc" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0 oncontextmenu="return false;">

<table cellpadding=0 cellspacing=0 border=0>
	<form name="theForm" action="order_details_product_details_footer.asp" method=POST> 
	<tr>
		<td><img src="./images/spacer.gif" height=1 width=5></td>
		<td>
			<font style="font-family:Arial, Helvetica;font-size:11px;color:#333333">
			View
			</font>
		</td>
		<td><img src="./images/spacer.gif" height=1 width=2></td>
		<td>
			<select name="displayStyle" onChange="javascript: changeDisplayStyle(this.value);">
				<option value="1"<%if Session.Value("Order_Product_DisplayStyle") = 1 then%> SELECTED<%end if%>>List
				<option value="2"<%if Session.Value("Order_Product_DisplayStyle") = 2 then%> SELECTED<%end if%>>Panels
			</select>		
		</td>
		<%if Session.Value("Order_Product_DisplayStyle") = 2 then%>
		<td><img src="./images/spacer.gif" height=1 width=2></td>
		<td>
			<select name="numCols" onChange="javascript: changeNumCols(this.value);">
				<option value="0"<%if numCols = 0 then%> SELECTED<%end if%>>Fit to Width, Left to Right
				<option value="1"<%if numCols = 1 then%> SELECTED<%end if%>>1 Column, Top to Bottom
				<option value="2"<%if numCols = 2 then%> SELECTED<%end if%>>2 Column, Top to Bottom
			</select>		
		</td>
		<%end if%>
		<td><img src="./images/spacer.gif" height=1 width=10></td>
		<td>
			<font style="font-family:Arial, Helvetica;font-size:11px;color:#333333">
			Sort&nbsp;By
			</font>
		</td>
		<td><img src="./images/spacer.gif" height=1 width=2></td>
		<td>
			<select name="SortColumn" onChange="javascript: changeSortColumn(this.value);">
				<option value="27"<%if SortColumn = 27 then%> SELECTED<%end if%>>Product ID
				<option value="10"<%if SortColumn = 10 then%> SELECTED<%end if%>>Product Type
				<option value="0"<%if SortColumn = 0 then%> SELECTED<%end if%>>Product Name
				<option value="9"<%if SortColumn = 9 then%> SELECTED<%end if%>>SKU
				<option value="20"<%if SortColumn = 20 then%> SELECTED<%end if%>>Quantity Requested
				<option value="18"<%if SortColumn = 18 then%> SELECTED<%end if%>>Price
				<option value="6"<%if SortColumn = 6 then%> SELECTED<%end if%>>Manufacturer Name
				<option value="5"<%if SortColumn = 5 then%> SELECTED<%end if%>>Supplier Name
				<option value="8"<%if SortColumn = 8 then%> SELECTED<%end if%>>Mfg Model Number
				<option value="19"<%if SortColumn = 19 then%> SELECTED<%end if%>>Mfg MSRP
				<option value="21"<%if SortColumn = 21 then%> SELECTED<%end if%>>Length
				<option value="22"<%if SortColumn = 22 then%> SELECTED<%end if%>>Width
				<option value="23"<%if SortColumn = 23 then%> SELECTED<%end if%>>Height
				<option value="24"<%if SortColumn = 24 then%> SELECTED<%end if%>>Depth
				<option value="25"<%if SortColumn = 25 then%> SELECTED<%end if%>>Weight
				<option value="16"<%if SortColumn = 16 then%> SELECTED<%end if%>>Date Created
				<option value="15"<%if SortColumn = 15 then%> SELECTED<%end if%>>Date Last Modified
			</select>		
		</td>
		<td><img src="./images/spacer.gif" height=1 width=2></td>
		<td>
			<select name="SortDirection" onChange="javascript: changeSortDirection(this.value);">
				<option value="0"<%if SortDirection = 0 then%> SELECTED<%end if%>>Asc.
				<option value="1"<%if SortDirection = 1 then%> SELECTED<%end if%>>Desc.
			</select>		
		</td>
		<%if Session.Value("Order_Product_DisplayStyle") = 2 then%>
		<td><img src="./images/spacer.gif" height=1 width=10></td>
		<td>
			<font style="font-family:Arial, Helvetica;font-size:11px;color:#333333">
			Show
			</font>
		</td>
		<td><img src="./images/spacer.gif" height=1 width=2></td>
		<td>
			<select name="showImgType" onChange="javascript: changeImgType(this.value);">
				<option value="0"<%if showImgType = 0 then%> SELECTED<%end if%>>Thumbnail Image
				<option value="1"<%if showImgType = 1 then%> SELECTED<%end if%>>Large Image
				<option value="2"<%if showImgType = 2 then%> SELECTED<%end if%>>Line Art
			</select>		
		</td>
		<%end if%>
	</tr>
	</form>
</table>

</body>
</html>
<%
Call DB_CleanUp
Sub DB_CleanUp
	'---- ObjectStateEnum Values ----
'	Const adStateClosed = &H00000000
'	Const adStateOpen = &H00000001
'	Const adStateConnecting = &H00000002
'	Const adStateExecuting = &H00000004
'	Const adStateFetching = &H00000008

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