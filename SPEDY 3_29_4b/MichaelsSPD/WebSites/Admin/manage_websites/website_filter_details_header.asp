<%@ LANGUAGE=VBSCRIPT%>
<% 
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441
%>
<!--#include file="./../app_include/_globalInclude.asp"-->
<%

Dim CategoryID
Dim SortColumn, SortDirection
Dim querystring

CategoryID = Trim(Request("cid"))
if IsNumeric(CategoryID) then
	CategoryID = CInt(CategoryID)
else
	CategoryID = 0
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

querystring = Request("q")
%>
<html>
<head>
	<title></title>
	<style type="text/css">
		A {text-decoration: none; color: #333333;}
		A:HOVER {text-decoration: none; color: #ffffff;}
	</style>
	<script language="javascript">
		function sortDetails(col_ordinal, sort_direction)
		{
			parent.frames["DetailFrame"].document.location = "website_filter_details.asp?sort=" + col_ordinal + "&direction=" + sort_direction + "&<%=querystring%>";
		}

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
		<td nowrap=true id="col_<%=colOrd%>">
			<table width=100% cellpadding=0 cellspacing=0 border=0>
				<tr>
					<td nowrap=true width=100%>
						<font style="font-family:Arial, Helvetica;font-size:11px;color:#333333">
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
		<td nowrap=true id="col_<%=colOrd%>">
			<table width=100% cellpadding=0 cellspacing=0 border=0>
				<tr>
					<td nowrap=true width=100%>
						<font style="font-family:Arial, Helvetica;font-size:11px;color:#333333">
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
		<td nowrap=true id="col_<%=colOrd%>">
			<table width=100% cellpadding=0 cellspacing=0 border=0>
				<tr>
					<td nowrap=true width=100%>
						<font style="font-family:Arial, Helvetica;font-size:11px;color:#333333">
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

<body bgcolor="999999" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0 onLoad="initDataLayout('DetailFrame')">
<layer name=defaultLyr id=defaultLyr><!--Netscrape 4 compatibility for header scrolling-->
<table cellpadding=0 cellspacing=0 border=0>
	<tr>
		<td><img src="./images/spacer.gif" height=1 width=5></td>
		<%=writeColHeader(0, "Document", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(0, "Tasks", false)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(31, "Staging", false)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(30, "Live", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(16, "Status", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(3, "ID", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(32, "Date Published", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(33, "Date Modified Staging", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(34, "Date Modified Live", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(12, "Type", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(23, "Navigable", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(24, "Searchable", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(35, "Template", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(26, "Start Date", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(27, "End Date", true)%>
		<%=writeSeparatorBar()%>
		<td width=100%><img src="./images/spacer.gif" height=1 width=1000></td>
	</tr>
</table>
</layer>
</body>
</html>