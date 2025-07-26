<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441

Dim SortColumn, SortDirection

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

%>
<html>
<head>
	<title></title>
	<style type="text/css">
	<!--
		A {text-decoration: none; color: #333333;}
		A:HOVER {text-decoration: none; color: #ffffff;}
	//-->
	</style>
	<script language="javascript">
	<!--
	function sortDetails(col_ordinal, sort_direction)
	{
		// col_ordinal:		Numerical position of column to be sorted
		// sort_direction:	0:ASC; 1:DESC
		parent.frames["DetailFrame"].document.location = "order_list.asp?sort=" + col_ordinal + "&direction=" + sort_direction;
	}

	//-->
	</script>
	<script language="javascript" src="../app_include/autoColSize.js"></script>
</head>

<%
Dim colOrd
colOrd = 0
function writeColHeader(colOrdinal, colDisplayName, boolAllowSorting)

	Dim curSortDir, curSortIcon, nextSortDir, nextSortHelpText, helpText
	curSortDir = SortDirection

	if CBool(boolAllowSorting) then
		if SortColumn = colOrdinal then
			if SortDirection = 0 then
				nextSortDir = 1
				nextSortHelpText = "Descending Order"
				curSortIcon = "./../app_images/sort_asc.gif"
			else
				nextSortDir = 0
				nextSortHelpText = "Ascending Order"
				curSortIcon = "./../app_images/sort_desc.gif"
			end if
			helpText = ":: Click to sort by " & colDisplayName & " in " & nextSortHelpText & " ::"
%>
		<td nowrap=true id="col_<%=colOrd%>" valign=bottom>
			<table width=100% cellpadding=0 cellspacing=0 border=0>
				<tr>
					<td nowrap=true width=100%>
						<font style="font-family:Arial, Helvetica;font-size:11px;color:#333333;line-height:11px;">
						<a href="javascript:void(0); sortDetails(<%=colOrdinal%>,<%=nextSortDir%>);" onMouseOver="window.status='<%=helpText%>';return true;" title="<%=helpText%>"><%=colDisplayName%></a>
						</font>
					</td>
					<td><a href="javascript:void(0); sortDetails(<%=colOrdinal%>,<%=nextSortDir%>);" onMouseOver="window.status='<%=helpText%>';return true;" title="<%=helpText%>"><img src="<%=curSortIcon%>" height=8 width=8 border=0 alt=":: Click to sort by <%=colDisplayName%> in <%=nextSortHelpText%> ::"></a></td>
				</tr>
			</table>
		</td>
<%
		else
			nextSortDir = 0
			nextSortHelpText = "Ascending Order"
			curSortIcon = "./../app_images/sort_desc.gif"
			helpText = ":: Click to sort by " & colDisplayName & " in " & nextSortHelpText & " ::"
%>
		<td nowrap=true id="col_<%=colOrd%>" valign=bottom>
			<table width=100% cellpadding=0 cellspacing=0 border=0>
				<tr>
					<td nowrap=true width=100%>
						<font style="font-family:Arial, Helvetica;font-size:11px;color:#333333;line-height:11px;">
						<a href="javascript:void(0); sortDetails(<%=colOrdinal%>,<%=nextSortDir%>);" onMouseOver="window.status='<%=helpText%>';return true;" title="<%=helpText%>"><%=colDisplayName%></a>
						</font>
					</td>
					<td><img src="./images/spacer.gif" height=8 width=8></td>
				</tr>
			</table>
		</td>
<%
		end if
	else
%>
		<td nowrap=true id="col_<%=colOrd%>" valign=bottom>
			<table width=100% cellpadding=0 cellspacing=0 border=0>
				<tr>
					<td nowrap=true width=100%>
						<font style="font-family:Arial, Helvetica;font-size:11px;color:#333333;line-height:11px;">
						<%=colDisplayName%>
						</font>
					</td>
					<td><img src="./images/spacer.gif" height=8 width=8></td>
				</tr>
			</table>
		</td>
<%
	end if
	colOrd = colOrd + 1
end function

function writeSeparatorBar()
%>
		<td><img src="./images/spacer.gif" height=1 width=4></td>
		<td bgcolor=666666><img src="./images/spacer.gif" height=1 width=1></td>
		<td><img src="./images/spacer.gif" height=1 width=5></td>
<%
end function
%>

<body bgcolor="999999" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0 onLoad="initDataLayout('DetailFrame')" oncontextmenu="return false;">
<layer name=defaultLyr id=defaultLyr><!--Netscrape 4 compatibility for header scrolling-->
<table cellpadding=0 cellspacing=0 border=0>
	<tr>
		<td><img src="./images/spacer.gif" height=1 width=5></td>
		<%=writeColHeader(0, "ID", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(6, "Order&nbsp;Date", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(0, "&nbsp;", false)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(4, "Status", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(40, "Store<br>Name", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(39, "Customer<br>Email&nbsp;Address", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(1, "Customer<br>Last&nbsp;Name", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(2, "Customer<br>First&nbsp;Name", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(3, "Organization", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(8, "Order<br>Subtotal", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(9, "Order<br>Coupon&nbsp;Total", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(10, "Order<br>Tax&nbsp;Total", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(11, "Order<br>Shipping&nbsp;Cost", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(114, "Order<br>Handling&nbsp;Fee", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(12, "Order<br>Grand&nbsp;Total", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(13, "Name&nbsp;on&nbsp;Card", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(14, "Card<br>Type", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(15, "Card<br>Number", true)%>
		<%=writeSeparatorBar()%>
		<%if 1 = 2 then%>
		<!--
		<%=writeColHeader(17, "BILLTO<br>Last&nbsp;Name", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(18, "BILLTO<br>First&nbsp;Name", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(19, "BILLTO<br>Address&nbsp;Line1", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(20, "BILLTO<br>Address&nbsp;Line2", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(21, "BILLTO<br>Address&nbsp;City", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(22, "BILLTO<br>Address&nbsp;State", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(23, "BILLTO<br>Address&nbsp;Country", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(24, "BILLTO<br>Address&nbsp;PostalCode", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(25, "BILLTO<br>Phone", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(27, "BILLTO<br>Fax", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(28, "SHIPTO<br>Last&nbsp;Name", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(29, "SHIPTO<br>First&nbsp;Name", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(30, "SHIPTO<br>Address&nbsp;Line1", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(31, "SHIPTO<br>Address&nbsp;Line2", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(32, "SHIPTO<br>Address&nbsp;City", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(33, "SHIPTO<br>Address&nbsp;State", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(34, "SHIPTO<br>Address&nbsp;Country", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(35, "SHIPTO<br>Address&nbsp;PostalCode", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(36, "SHIPTO<br>Phone", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(37, "SHIPTO<br>Fax", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(16, "Gender", true)%>
		<%=writeSeparatorBar()%>
		-->
		<%end if%>
		<%=writeColHeader(5, "Modified", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(6, "Created", true)%>
		<td width=100%><img src="./images/spacer.gif" height=1 width=1000></td>
	</tr>
</table>
</layer>
</body>
</html>