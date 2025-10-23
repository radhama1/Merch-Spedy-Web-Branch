<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'============================================================================== 
Option Explicit
Response.Buffer = True
Response.Expires = -1441 
%>
<!--#include file="./../app_include/checkQueryID.asp"-->
<%
Dim objConn, objRec, SQLStr, connStr
Dim rowcolor, i, Order_ID
Dim strToolTip
Dim SortColumn, SortDirection
Dim anchorName, anchorSeed, rowTopBorder_FillColor

Order_ID = CInt(checkQueryID(Request("oid"), 0))

SortColumn = Trim(Request("sort"))
if IsNumeric(SortColumn) and Trim(SortColumn) <> "" then
	SortColumn = CInt(SortColumn)
	Session.Value("Order_Product_SortColumn") = SortColumn
else
	if IsNumeric(Session.Value("Order_Product_SortColumn")) and Trim(Session.Value("Order_Product_SortColumn")) <> "" then
		SortColumn = CInt(Session.Value("Order_Product_SortColumn"))
	else
		SortColumn = 0
		Session.Value("Order_Product_SortColumn") = SortColumn
	end if
end if

SortDirection = Trim(Request("direction"))
if IsNumeric(SortDirection) and Trim(SortDirection) <> "" then
	SortDirection = CInt(SortDirection)
	Session.Value("Order_Product_SortDirection") = SortDirection
else
	if IsNumeric(Session.Value("Order_Product_SortDirection")) and Trim(Session.Value("Order_Product_SortDirection")) <> "" then
		SortDirection = CInt(Session.Value("Order_Product_SortDirection"))
	else
		SortDirection = 0
		Session.Value("Order_Product_SortDirection") = SortDirection
	end if
end if

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr

%>
<!--#include file="../app_include/findNeedleInHayStack.asp"-->
<!--#include file="../app_include/smartValues.asp"-->
<!--#include file="../app_include/stripHTML.asp"-->
<html>
<head>
	<title>View All Content</title>
	<style type="text/css">
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
	</style>
	<script language="javascript" src="../app_include/lockscroll.js"></script><!--locked headers code-->
	<link rel="stylesheet" href="../app_include/contextmenu.css" type="text/css" media="screen"><!--right click styles-->
	<script language="javascript" src="./include/order_details_contextmenu.js"></script><!--right click menu-->
	<script language=javascript>
	<!--
		function openItemEditorWindow(RowID)
		{
			editWin = window.open("./product_admin/product_details_frm.asp?oid=<%=Order_ID%>&pid=" + RowID, "editWindow_" + RowID, "width=675,height=500,toolbar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=0,resizable=1");
			editWin.focus();
		}

	//-->
	</script>
</head>
<body bgcolor="ffffff" topmargin=0 leftmargin=0 rightmargin=0 marginheight=0 marginwidth=0><!-- oncontextmenu="return false;"-->

<table width=100% cellpadding=0 cellspacing=0 border=0>
	<form name="theForm" action="boo.asp" method="POST">
	<input type="hidden" name="selectedItemID" value="0">
	<input type="hidden" name="hoveredItemID" value="0">
	<tr>
		<td width=100%>
			<%
			SQLStr = "sp_shopping_order_product_headings_by_orderID " & Order_ID & ", " & SortColumn & ", " & SortDirection
			'Response.Write SQLStr
			objRec.Open SQLStr, objConn, adOpenForwardOnly, adLockReadOnly, adCmdText
			if not objRec.EOF then
			%>
			<table cellpadding=0 cellspacing=0 onSelectStart="return false" width=100% border=0>
			<%
					i = 0
					Do Until objRec.EOF
						if i mod 2 = 1 then				
							rowcolor = "f3f3f3"
						else
							rowcolor = "ffffff"
						end if 
						
						If not IsNull(objRec("Display_Name")) then
							if len(objRec("Display_Name")) > 0 then
								anchorSeed = LCase(Left(stripHTML(SmartValues(objRec("Display_Name"), "CStr")),1))
								if isNumeric(anchorSeed) and len(anchorSeed) = 1 then
									'Make all numeric items link to "123"
									anchorName = "123"
								elseif len(anchorSeed) = 1 then
									'All string items link to their first char
									anchorName = anchorSeed
								else
									anchorName = "anchorError3"
								end if
							else
								anchorName = "anchorError2"
							end if
						else
							anchorName = "anchorError1"
						end if
						
						rowTopBorder_FillColor = "ffffff"
						if i > 0 then rowTopBorder_FillColor = "e3e3e3"

			%>
				<tr bgcolor=<%=rowTopBorder_FillColor%>><td colspan=50><a name="<%=anchorName%>"><img src="./images/spacer.gif" height=1 width=1 border=0></a></td></tr>
				<tr bgcolor=<%=rowcolor%> id="datarow_<%=objRec("ID")%>" onDblClick="highlightRow();">
					<td><img src="./images/spacer.gif" height=1 width=5></td>
					<td valign=top nowrap align=right>
						<font style="font-family:Arial, Helvetica;font-size:11px;">
						<%= SmartValues(objRec("Product_Heading_ID"), "CInt")%>
						</font>
					</td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap>
						<font style="font-family:Arial, Helvetica;font-size:11px;">
						<a href="javascript:void(0);"><%= stripHTML(SmartValues(objRec("Display_Name"), "CStr"))%></a>
						</font>
					</td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>					
					<td valign=top nowrap>
						<font style="font-family:Arial, Helvetica;font-size:11px;">
						<%= SmartValues(objRec("SKU"), "CStr")%>
						</font>
					</td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap align=right>
						<font style="font-family:Arial, Helvetica;font-size:11px;">
						<%= SmartValues(objRec("Quantity_Requested"), "CInt")%>
						</font>
					</td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap align=right>
						<font style="font-family:Arial, Helvetica;font-size:11px;">
						<%= SmartValues(objRec("PricePerUOM"), "CCur")%>
						</font>
					</td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap>
						<font style="font-family:Arial, Helvetica;font-size:11px;">
						<%= SmartValues(objRec("Product_Type_Name"), "CStr")%>
						</font>
					</td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap>
						<font style="font-family:Arial, Helvetica;font-size:11px;">
						<%= SmartValues(objRec("Manufacturer_Name"), "CStr")%>
						</font>
					</td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap>
						<font style="font-family:Arial, Helvetica;font-size:11px;">
						<%= SmartValues(objRec("Supplier_Name"), "CStr")%>
						</font>
					</td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap>
						<font style="font-family:Arial, Helvetica;font-size:11px;">
						<%= SmartValues(objRec("Mfg_Model_Number"), "CStr")%>
						</font>
					</td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap align=right>
						<font style="font-family:Arial, Helvetica;font-size:11px;">
						<%= SmartValues(objRec("Mfg_MSRP"), "CCur")%>
						</font>
					</td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap align=right>
						<font style="font-family:Arial, Helvetica;font-size:11px;">
						<%= SmartValues(objRec("Shipping_Length"), "CStr")%>
						</font>
					</td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap align=right>
						<font style="font-family:Arial, Helvetica;font-size:11px;">
						<%= SmartValues(objRec("Shipping_Width"), "CStr")%>
						</font>
					</td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap align=right>
						<font style="font-family:Arial, Helvetica;font-size:11px;">
						<%= SmartValues(objRec("Shipping_Height"), "CStr")%>
						</font>
					</td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap align=right>
						<font style="font-family:Arial, Helvetica;font-size:11px;">
						<%= SmartValues(objRec("Shipping_Depth"), "CStr")%>
						</font>
					</td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap align=right>
						<font style="font-family:Arial, Helvetica;font-size:11px;">
						<%= SmartValues(objRec("Shipping_Weight"), "CStr")%>
						</font>
					</td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap>
						<font style="font-family:Arial, Helvetica;font-size:11px;">
						<%= SmartValues(objRec("Date_Last_Modified"), "CStr")%>
						</font>
					</td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top nowrap>
						<font style="font-family:Arial, Helvetica;font-size:11px;">
						<%= SmartValues(objRec("Date_Created"), "CStr")%>
						</font>
					</td>
					<td width=100%><img src="./images/spacer.gif" height=1 width=5></td>
				</tr>

			<%
					objRec.MoveNext
					i = i + 1
					Loop
			%>
				<tr>
					<td><img src="./images/spacer.gif" height=1024 width=1></td>
				<%for i = 0 to 17%>
					<td id="col_<%=i%>_data"><img id="col_<%=i%>_dataimg" src="./images/spacer.gif" height=1 width="<%if i < 0 then%>100<%else%>1<%end if%>"></td>
					<td><img src="./images/spacer.gif" height=1 width=1></td>
				<%next%>
				</tr>
			</table>
			<script language="javascript">
			<!--
				parent.frames["blankheaderframe"].document.location = "../app_include/blank_666666.html";
				parent.frames["edge_separator1"].document.location = "../app_include/blank_999999.html";
				parent.frames["DetailFrameHdr"].document.location = "order_details_product_details_header.asp?oid=<%=Order_ID%>&sort=<%=SortColumn%>&direction=<%=SortDirection%>";
				parent.frames["edge_separator2"].document.location = "../app_include/blank_666666.html";
				parent.frames["edge_separator3"].document.location = "../app_include/blank_999999.html";
				parent.frames["FooterFrame"].document.location = "order_details_product_details_footer.asp?oid=<%=Order_ID%>&sort=<%=SortColumn%>&direction=<%=SortDirection%>";
			//-->
			</script>
			<%
			else
			%>
			<script language="javascript">
			<!--
				parent.frames["blankheaderframe"].document.location = "../app_include/blank_999999.html";
				parent.frames["edge_separator1"].document.location = "../app_include/blank.html";
				parent.frames["DetailFrameHdr"].document.location = "../app_include/blank.html";
				parent.frames["edge_separator2"].document.location = "../app_include/blank.html";
				parent.frames["edge_separator3"].document.location = "../app_include/blank_cccccc.html";
				parent.frames["FooterFrame"].document.location = "order_details_product_details_footer.asp?oid=<%=Order_ID%>&sort=<%=SortColumn%>&direction=<%=SortDirection%>";
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