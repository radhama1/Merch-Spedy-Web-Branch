<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441 
%>
<!--#include file="./../app_include/returnDataWithGetRows.asp"-->
<!--#include file="./../app_include/checkQueryID.asp"-->
<%
Dim objConn, objRec, SQLStr, connStr
Dim rowcolor, i, Order_ID
Dim strToolTip
Dim SortColumn, SortDirection, showImgType
Dim anchorName, anchorSeed
Dim numCols, curCol, curRecord, colLength, firstColLength, numFound
Dim rowCounter, curIteration
Dim arProductDataRows, dictProductDataCols
Dim addressSource, imgName
Dim Email, Phone, Extension, CellPhone, Website
Dim tblHeight, tblWidth, tblLineSpacing
Dim productSummaryHeight, productSummaryWidth
Dim productImgHeight, productImgWidth

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

numCols = Trim(Request("numcols"))
if IsNumeric(numCols) and Trim(numCols) <> "" then
	numCols = CInt(numCols)
	Session.Value("Order_Product_NumCols") = numCols
else
	if IsNumeric(Session.Value("Order_Product_NumCols")) and Trim(Session.Value("Order_Product_NumCols")) <> "" then
		numCols = CInt(Session.Value("Order_Product_NumCols"))
	else
		numCols = 0
		Session.Value("Order_Product_NumCols") = numCols
	end if
end if

showImgType = Trim(Request("imgtype"))
if IsNumeric(showImgType) and Trim(showImgType) <> "" then
	showImgType = CInt(showImgType)
	Session.Value("Order_Product_ImgType") = showImgType
else
	if IsNumeric(Session.Value("Order_Product_ImgType")) and Trim(Session.Value("Order_Product_ImgType")) <> "" then
		showImgType = CInt(Session.Value("Order_Product_ImgType"))
	else
		showImgType = 0
		Session.Value("Order_Product_ImgType") = showImgType
	end if
end if 

Set dictProductDataCols	= Server.CreateObject("Scripting.Dictionary")

connStr = Application.Value("connStr")
SQLStr = "sp_shopping_order_product_headings_by_orderID " & Order_ID & ", " & SortColumn & ", " & SortDirection
Call returnDataWithGetRows(connStr, SQLStr, arProductDataRows, dictProductDataCols)

if showImgType = 1 then
	tblWidth = "100px"
	tblHeight = "100px"
	tblLineSpacing = "200px"
	productSummaryWidth = "150px"
	productSummaryHeight = "260px"
	productImgWidth = "300px"
	productImgHeight = "300px"
else
	tblWidth = "100px"
	tblHeight = "100px"
	tblLineSpacing = "200px"
	productSummaryWidth = "150px"
	productSummaryHeight = "120px"
	productImgWidth = "150px"
	productImgHeight = "150px"
end if
%>
<!--#include file="../app_include/findNeedleInHayStack.asp"-->
<html>
<head>
	<title>View All Content</title>
	<style type="text/css">
		A {text-decoration: none; color: #000000; cursor: hand;}
		A:HOVER {text-decoration: underline; color: #0000ff; cursor: hand;}
		A.EditLinks {text-decoration: none; color: #666666; cursor: hand;}
		A.EditLinks:HOVER {text-decoration: underline; color: #0000ff; cursor: hand;}
		.rover {background-color: #ffff99}
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
		.contentTable
		{
			width: <%=tblWidth%>;
			height: <%=tblHeight%>;
			border-top: 1px solid #cccccc;
			border-left: 1px solid #cccccc;
			border-bottom: 1px solid #999999;
			border-right: 1px solid #999999;
			padding: 5px;
			float: left;
		}
		.contentTableContainer
		{
			height: <%=tblLineSpacing%>;
			margin: 2px;
			float: left;
		}
		.productImgContainer
		{
			width: <%=productImgWidth%>;
			height: <%=productImgHeight%>;
			clip: auto;
			overflow: auto;
		}
		.productSummary
		{
			width: <%=productSummaryWidth%>;
			height: <%=productSummaryHeight%>;
			clip: auto;
			overflow: auto;
			font-family: Arial, Helvetica;
			font-size: 11px;
			float: left;
			cursor: text;
		}
		.productDates
		{
			font-family: Arial, Helvetica;
			font-size: 9px;
			margin-top: 10px;
			color: #999;
			display: none;
		}

		@media print {
		.screenOnly {display: none;}
		}
	</style>
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

<%
if dictProductDataCols("ColCount") > 0 and dictProductDataCols("RecordCount") > 0 then
	curRecord = 1
	curCol = 1
	numFound = CLng(dictProductDataCols("RecordCount"))
	
	if numCols > 0 then	
		colLength = 3
		firstColLength = colLength
		if numFound > 3 then
			if numCols mod 2 = 0 then
				'Even Columns
				if numFound mod numCols = 0 then
					colLength = (numFound/numCols)
					firstColLength = colLength
				else
					if numFound/numCols < CInt(numFound/numCols) then
						colLength = (numFound/numCols - (CInt(numFound/numCols) - numFound/numCols))
					else
						colLength = CInt(numFound/numCols)
					end if
						firstColLength = colLength + 1
				end if
			else
				'Odd Columns
				if numFound mod numCols = 0 then
					colLength = CInt(numFound/numCols)
					firstColLength = colLength
				else
					if numFound/numCols < CInt(numFound/numCols) then
						colLength = CInt(numFound/numCols)
						firstColLength = colLength
					else
						colLength = CInt(numFound/numCols)
						firstColLength = colLength + 1
					end if
				end if
			end if
		end if
	end if
	
end if
'	Response.Write "numFound: " & numFound & "<br>"
'	Response.Write "numCols: " & numCols & "<br>"
'	Response.Write "colLength: " & colLength & "<br>"
'	Response.Write "firstColLength: " & firstColLength
if numCols > 0 then	
%>
<table cellpadding=0 cellspacing=0 border=0>
	<tr><td valign=top><img src="./images/spacer.gif" height=10 width=1></td></tr>
	<tr>
	<%
	for rowCounter = 0 to numFound - 1
		if rowCounter <> 0 then
			if curCol = 1 then
				if curRecord > firstColLength then
	%>
		<td><img src="./images/spacer.gif" height=1 width=10></td>
		<td valign=top>
			<table cellpadding=0 cellspacing=0 border=0 style="width: 100%;">
	<%
					curRecord = 1
				end if
			else
				if  curRecord > colLength then
	%>
		<td><img src="./images/spacer.gif" height=1 width=10></td>
		<td valign=top>
			<table cellpadding=0 cellspacing=0 border=0 style="width: 100%;">
	<%
					curRecord = 1
				end if
			end if
		else
	%>
		<td><img src="./images/spacer.gif" height=1 width=10></td>
		<td valign=top>
			<table cellpadding=0 cellspacing=0 border=0 style="width: 100%;">
	<%
		end if
		
		imgName = "./images/noimage_large.gif"
		Select Case showImgType
			Case 0
				if not IsNull(arProductDataRows(dictProductDataCols("Thumb_Img_FileName"), rowCounter)) then
					if Len(Trim(arProductDataRows(dictProductDataCols("Thumb_Img_FileName"), rowCounter))) > 0 then
						imgName = "./../product_images/" & arProductDataRows(dictProductDataCols("Thumb_Img_FileName"), rowCounter)
					end if
				end if
			Case 1
				if not IsNull(arProductDataRows(dictProductDataCols("Large_Img_FileName"), rowCounter)) then
					if Len(Trim(arProductDataRows(dictProductDataCols("Large_Img_FileName"), rowCounter))) > 0 then
						imgName = "./../product_images/" & arProductDataRows(dictProductDataCols("Large_Img_FileName"), rowCounter)
					end if
				end if
			Case 2
				if not IsNull(arProductDataRows(dictProductDataCols("LineArt_Img_FileName"), rowCounter)) then
					if Len(Trim(arProductDataRows(dictProductDataCols("LineArt_Img_FileName"), rowCounter))) > 0 then
						imgName = "./../product_images/" & arProductDataRows(dictProductDataCols("LineArt_Img_FileName"), rowCounter)
					end if
				end if
		End Select
	%>
				<tr>
					<td>
						<%
						writeItemPanel	arProductDataRows(dictProductDataCols("ID"), rowCounter), _
										arProductDataRows(dictProductDataCols("Display_Name"), rowCounter), _
										imgName, _
										arProductDataRows(dictProductDataCols("Display_Summary_Short"), rowCounter), _
										arProductDataRows(dictProductDataCols("Date_Last_Modified"), rowCounter), _
										arProductDataRows(dictProductDataCols("Date_Created"), rowCounter)
						%>
					</td>
				</tr>
				<tr><td valign=top><img src="./images/spacer.gif" height=10 width=1></td></tr>
	<%
		if curCol <= 1 then
			if curRecord = firstColLength or rowCounter = numFound - 1 then
	%>
			</table>
		</td>
	<%
				if curRecord = firstColLength and rowCounter < numFound - 1 then
	%>
		<td><img src="./images/spacer.gif" height=1 width=10></td>
		<td bgcolor=ececec><img src="./images/spacer.gif" height=1 width=1></td>
	<%
				end if

				curCol = curCol + 1
			end if
		else
			if curRecord = colLength or rowCounter = numFound - 1 then
	%>
			</table>
		</td>
	<%
				if curRecord = colLength and rowCounter < numFound - 1 then
	%>
		<td><img src="./images/spacer.gif" height=1 width=10></td>
		<td bgcolor=ececec><img src="./images/spacer.gif" height=1 width=1></td>
	<%
				end if

				curCol = curCol + 1
			end if
		end if
	curRecord = curRecord + 1
	Next
	%>
	</tr>
	<tr><td valign=top><img src="./images/spacer.gif" height=10 width=1></td></tr>
</table>
<%
else

	for rowCounter = 0 to numFound - 1		
		imgName = "./images/noimage_large.gif"
		Select Case showImgType
			Case 0
				if not IsNull(arProductDataRows(dictProductDataCols("Thumb_Img_FileName"), rowCounter)) then
					if Len(Trim(arProductDataRows(dictProductDataCols("Thumb_Img_FileName"), rowCounter))) > 0 then
						imgName = "./../product_images/" & arProductDataRows(dictProductDataCols("Thumb_Img_FileName"), rowCounter)
					end if
				end if
			Case 1
				if not IsNull(arProductDataRows(dictProductDataCols("Large_Img_FileName"), rowCounter)) then
					if Len(Trim(arProductDataRows(dictProductDataCols("Large_Img_FileName"), rowCounter))) > 0 then
						imgName = "./../product_images/" & arProductDataRows(dictProductDataCols("Large_Img_FileName"), rowCounter)
					end if
				end if
			Case 2
				if not IsNull(arProductDataRows(dictProductDataCols("LineArt_Img_FileName"), rowCounter)) then
					if Len(Trim(arProductDataRows(dictProductDataCols("LineArt_Img_FileName"), rowCounter))) > 0 then
						imgName = "./../product_images/" & arProductDataRows(dictProductDataCols("LineArt_Img_FileName"), rowCounter)
					end if
				end if
		End Select
%>
<table cellpadding=0 cellspacing=0 border=0 class="contentTableContainer">
	<tr>
		<td valign=top>
			<%
			writeItemPanel	arProductDataRows(dictProductDataCols("ID"), rowCounter), _
							arProductDataRows(dictProductDataCols("Display_Name"), rowCounter), _
							imgName, _
							arProductDataRows(dictProductDataCols("Display_Summary_Short"), rowCounter), _
							arProductDataRows(dictProductDataCols("Date_Last_Modified"), rowCounter), _
							arProductDataRows(dictProductDataCols("Date_Created"), rowCounter)
			%>
		</td>
	</tr>
</table>


<%
	curRecord = curRecord + 1
	Next
end if
%>


<script language="javascript">
<!--

	parent.frames["blankheaderframe"].document.location = "../app_include/blank_999999.html";
	parent.frames["edge_separator1"].document.location = "../app_include/blank.html";
	parent.frames["DetailFrameHdr"].document.location = "../app_include/blank.html";
	parent.frames["edge_separator2"].document.location = "../app_include/blank.html";
	parent.frames["edge_separator3"].document.location = "../app_include/blank.html";
	parent.frames["FooterFrame"].document.location = "order_details_product_details_footer.asp?oid=<%=Order_ID%>&sort=<%=SortColumn%>&direction=<%=SortDirection%>&numcols=<%=numCols%>&imgtype=<%=showImgType%>";
//-->
</script>
<p>
<img src="./images/spacer.gif" height=800 width=1>
<p>
<img src="./images/spacer.gif" height=1 width=1>

</body>
</html>

<%
Sub writeItemPanel(thisItemID, thisItemDisplayName, thisItemImgFileName, thisItemSummary, thisDateLastModified, thisDateCreated)
	if not IsNull(thisItemDisplayName) then
		if len(thisItemDisplayName) > 0 then
			anchorSeed = LCase(Left(thisItemDisplayName,1))
			if isNumeric(anchorSeed) and len(anchorSeed) = 1 then
				anchorName = "123"
			elseif len(anchorSeed) = 1 then
				anchorName = anchorSeed
			end if
		end if
	end if
%>
<table cellpadding=0 cellspacing=0 border=0>
	<tr><td><a name="<%=anchorName%>"><img src="./images/spacer.gif" height=1 width=1></a></td></tr>
	<tr>
		<td>
			<table cellpadding=0 cellspacing=0 border=0 class="contentTable">
				<tr bgcolor=ececec height=1%>
					<td>
						<font style="font-family:Arial, Helvetica;font-size:11px;">
						<a href="javascript:openItemEditorWindow(<%=thisItemID%>); void(0);"><b><%if not IsNull(thisItemDisplayName) then Response.Write thisItemDisplayName end if%></b></a>
						</font>
					</td>
				</tr>
				<tr bgcolor=ffffff>
					<td colspan=2 valign=top>
						<table cellpadding=0 cellspacing=0 border=0 width="100%">
							<tr>
								<td valign=top align=center>
									<div class="productImgContainer">
										<img src="<%=thisItemImgFileName%>" border=0 class="productImg" alt="<%=Replace(thisItemImgFileName, "./../product_images/", "")%>">
									</div>
								</td>
								<td><img src="./images/spacer.gif" height=1 width=20></td>
								<td valign=top width="100%">
									<div class="productSummary">
										<%=thisItemSummary%>
									</div>
									<div class="productDates">
										<nobr>Modified:&nbsp;<%=thisDateLastModified%></nobr><br>
										<nobr>Created:&nbsp;<%=thisDateCreated%></nobr>
									</div>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>

<%
End Sub
%>