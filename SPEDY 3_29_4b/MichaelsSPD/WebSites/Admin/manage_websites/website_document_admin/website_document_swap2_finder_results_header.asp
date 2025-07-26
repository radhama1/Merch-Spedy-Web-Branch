<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
%>
<!--#include file="./../../app_include/_globalInclude.asp"-->
<%
Response.Buffer = True
Response.Expires = -1441

Dim SortColumn, SortDirection
Dim searchString, searchStatus

searchString = Trim(Request("searchString"))
searchStatus = Trim(Request("searchStatus"))

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
		parent.frames["DetailFrame"].document.location = "website_document_swap2_finder_results.asp?searchString=<%=searchString%>&searchStatus=<%=searchStatus%>&sort=" + col_ordinal + "&direction=" + sort_direction;
	}
	//-->
	</script>
</head>

<%
function writeColHeader(colOrdinal, colDisplayName, boolAllowSorting)

	Dim curSortDir, curSortIcon, nextSortDir, nextSortHelpText
	curSortDir = SortDirection

	if CBool(boolAllowSorting) then
		if SortColumn = colOrdinal then
			if SortDirection = 0 then
				nextSortDir = 1
				nextSortHelpText = "Descending Order"
				curSortIcon = "./../../app_images/sort_asc.gif"
			else
				nextSortDir = 0
				nextSortHelpText = "Ascending Order"
				curSortIcon = "./../../app_images/sort_desc.gif"
			end if
%>
		<td nowrap=true>
			<table width=100% cellpadding=0 cellspacing=0 border=0>
				<tr>
					<td nowrap=true width=100%>
						<font style="font-family:Arial, Helvetica;font-size:11px;color:#333333">
						<a href="javascript: sortDetails(<%=colOrdinal%>,<%=nextSortDir%>);" onMouseOver="window.status='Click to sort by <%=colDisplayName%> in <%=nextSortHelpText%>';return true;"><%=colDisplayName%></a>
						</font>
					</td>
					<td><a href="javascript: sortDetails(<%=colOrdinal%>,<%=nextSortDir%>);" onMouseOver="window.status='Click to sort by <%=colDisplayName%> in <%=nextSortHelpText%>';return true;"><img src="<%=curSortIcon%>" height=8 width=8 border=0 alt="Click to sort by <%=colDisplayName%> in <%=nextSortHelpText%>"></a></td>
				</tr>
			</table>
		</td>
<%
		else
			nextSortDir = 0
			nextSortHelpText = "Ascending Order"
			curSortIcon = "./../../app_images/sort_desc.gif"
%>
		<td nowrap=true>
			<table width=100% cellpadding=0 cellspacing=0 border=0>
				<tr>
					<td nowrap=true width=100%>
						<font style="font-family:Arial, Helvetica;font-size:11px;color:#333333">
						<a href="javascript: sortDetails(<%=colOrdinal%>,<%=nextSortDir%>);" onMouseOver="window.status='Click to sort by <%=colDisplayName%> in <%=nextSortHelpText%>';return true;"><%=colDisplayName%></a>
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
		<td nowrap=true>
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
end function

function writeSeparatorBar()
%>
		<td><img src="./images/spacer.gif" height=1 width=5></td>
		<td bgcolor=666666><img src="./images/spacer.gif" height=1 width=1></td>
		<td><img src="./images/spacer.gif" height=1 width=4></td>
<%
end function
%>

<body bgcolor="999999" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>
<layer name=defaultLyr id=defaultLyr><!--Netscrape 4 compatibility for header scrolling-->
<table cellpadding=0 cellspacing=0 border=0>
	<tr>
		<td><img src="./images/spacer.gif" height=1 width=20></td>
		<%=writeColHeader(0, "Document&nbsp;Name", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(1, "Status&nbsp;Name", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(5, "Date&nbsp;Last&nbsp;Modified", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(6, "Date&nbsp;Created", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(3, "Language", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(2, "Locked&nbsp;by", true)%>
		<td><img src="./images/spacer.gif" height=1 width=1></td>
	</tr>
	<tr style="visibility:none;">
		<td><img src="./images/spacer.gif" height=1 width=1></td>
		<td><img src="./images/spacer.gif" height=1 width=295></td>
		<%=writeSeparatorBar()%>
		<td><img src="./images/spacer.gif" height=1 width=100></td>
		<%=writeSeparatorBar()%>
		<td><img src="./images/spacer.gif" height=1 width=120></td>
		<%=writeSeparatorBar()%>
		<td><img src="./images/spacer.gif" height=1 width=120></td>
		<%=writeSeparatorBar()%>
		<td><img src="./images/spacer.gif" height=1 width=100></td>
		<%=writeSeparatorBar()%>
		<td><img src="./images/spacer.gif" height=1 width=100></td>
		<td><img src="./images/spacer.gif" height=1 width=20></td>
	</tr>
</table>
</layer>
</body>
</html>