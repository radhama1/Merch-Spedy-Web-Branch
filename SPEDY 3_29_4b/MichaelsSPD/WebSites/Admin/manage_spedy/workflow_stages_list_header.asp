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
		parent.frames["DetailFrame"].document.location = "workflow_stages_list.asp?sort=" + col_ordinal + "&direction=" + sort_direction + "&id=<%=Request("id")%>";  
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
						<font style="font-family:Arial, Helvetica;font-size:11px;color:#333333;">
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
		<%=writeColHeader(0, "Stage Name", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(0, "&nbsp;", false)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(1, "Sequence", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(2, "Enabled", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(3, "Primary Approver Group", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(4, "Default Next Stage", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(5, "Default Previous Stage", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(6, "Created User", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(7, "Created", true)%>
		<%=writeSeparatorBar()%>	
		<%=writeColHeader(8, "Modified User", true)%>
		<%=writeSeparatorBar()%>
		<%=writeColHeader(9, "Modified", true)%>
		<td width=100%><img src="./images/spacer.gif" height=1 width=1000></td>
	</tr>
</table>
</layer>
</body>
</html>