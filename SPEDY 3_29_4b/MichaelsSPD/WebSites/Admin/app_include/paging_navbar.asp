<%@ LANGUAGE=VBSCRIPT %>
<%
Option Explicit
%>
<!--#include file="./checkQueryID.asp"-->
<%
Dim pageCount, i
Dim curPage
Dim pageSize
Dim pageSizeImgAltTxt, printableAltTxt, submitSelectionsAltTxt
Dim frm, loc, querystring
Dim numFound

pageSize = checkQueryID(Trim(Request("pageSize")), 50)
curPage = checkQueryID(Trim(Request("curPage")), 1)
pageCount = checkQueryID(Trim(Request("pageCount")), 1)

loc = Request("loc")
frm = Request("frm")
querystring = Request("q")
numFound = Trim(Request("numFound"))
pageSizeImgAltTxt = "Click here to update number of items per page"

if Trim(curPage) = "" or not IsNumeric(curPage) then
	curPage = 1
else
	curPage = CInt(curPage)
end if

if Trim(pageSize) = "" or not IsNumeric(pageSize) then
	pageSize = 50
else
	pageSize = CInt(pageSize)
end if
%>
<HTML>
<HEAD>
	<TITLE>Member Statement | Nav</TITLE>
<script language=javascript>
<!--//
	function movePage()
	{
		parent.frames['<%=frm%>'].document.location = "<%=loc%>?curPage=" + (document.theForm.page.selectedIndex + 1) + "&<%=querystring%>";
	}
	function moveFirst()
	{
		parent.frames['<%=frm%>'].document.location = "<%=loc%>?curPage=1&<%=querystring%>";
	}
	function movePrev()
	{
		parent.frames['<%=frm%>'].document.location = "<%=loc%>?curPage=<%=curPage - 1%>&<%=querystring%>";
	}
	function moveNext()
	{
		parent.frames['<%=frm%>'].document.location = "<%=loc%>?curPage=<%=curPage + 1%>&<%=querystring%>";
	}
	function moveLast()
	{
		parent.frames['<%=frm%>'].document.location = "<%=loc%>?curPage=<%=pageCount%>&<%=querystring%>";
	}
	
	function changePageSize()
	{
		var invalidChars = /\D/g;
		if (invalidChars.test(document.theForm.lineCount.value))
		{
			document.theForm.lineCount.select();
			alert("Please enter a valid number greater than 0 and less than 200 in the Record Count field.");
			document.theForm.lineCount.focus();
		}
		else
		{
			var pageSize = new Number(document.theForm.lineCount.value);
			if ((pageSize.valueOf() > 0)&&(pageSize.valueOf() <= 200))
			{
				parent.frames['<%=frm%>'].document.location = "<%=loc%>?curPage=<%=curPage%>&pageSize=" + document.theForm.lineCount.value + "&<%=querystring%>";
			}
			else
			{
				document.theForm.lineCount.select();
				alert("Please enter a number greater than 0 and less than 200 in the Record Count field.");
				document.theForm.lineCount.focus();
			}
		}
	}
	//-->
</script>
</HEAD>
<body bgcolor="CCCCCC" topmargin=2 leftmargin=0 rightmargin=0 marginheight=0 marginwidth=0>
<form name=theForm action="javascript: void(0);">

<table border=0 cellpadding=0 cellspacing=0>
	<tr>
		<%if pageCount > 0 then%>
		<td><nobr><img src="./../app_images/spacer.gif" height=2 width=5><a href="javascript:moveFirst();"><img name="first" src="./../app_images/paging/btn_vcr_top.gif" border=0 alt="Jump to the first page"></a><a href="javascript:<%if curPage > 1 then%>movePrev();<%else%>moveFirst();<%end if%>"><img name="prev" src="./../app_images/paging/btn_vcr_prev.gif" border=0 alt="Jump to the previous page"></a></td>
		<td valign=top>
		<nobr>
			<img src="./../app_images/spacer.gif" height=2 width=1>
			<select name=page onChange="javascript:movePage();" style="font-size:9px; padding: 0px; margin: 0px;">
			<%
			for i = 1 to pageCount
			%>
				<option value="<%=i%>"<%if curPage = i then%> SELECTED<%end if%>>Page <%=i%> of <%=pageCount%></option>
			<%
			next
			%>
			</select>
		</td>
		<td><nobr><img src="./../app_images/spacer.gif" height=2 width=5><a href="javascript:<%if CInt(curPage) = CInt(pageCount) then%>moveLast();<%else%>moveNext();<%end if%>"><img name="next" src="./../app_images/paging/btn_vcr_next.gif" border=0 alt="Jump to the next page"></a><a href="javascript:moveLast();"><img name="last" src="./../app_images/paging/btn_vcr_bot.gif" border=0 alt="Jump to the last page"></a></td>
		<td valign=top><img src="./../app_images/spacer.gif" height=2 width=20></td>
		<td valign=middle>
			<font style="font-family:Arial; font-size:11px;">
			Show
			</font>
		</td>
		<td valign=top><img src="./../app_images/spacer.gif" height=2 width=4></td>
		<td><input type="text" name="lineCount" value="<%=pageSize%>" size=3 maxlength=3 onChange="changePageSize()" style="font-size: 9px; width:25px; height:15px; border: 1px solid #666; padding: 0px; margin: 0px;"></td>
		<td valign=top><img src="./../app_images/spacer.gif" height=2 width=4></td>
		<td valign=middle>
			<font style="font-family:Arial; font-size:11px;">
			Records
			</font>
		</td>
		<td valign=top><img src="./../app_images/spacer.gif" height=2 width=2></td>
		<td><a href="#"><img name="pageSizeImg" src="./../app_images/paging/refresh.gif" alt="<%=pageSizeImgAltTxt%>" border=0></a></td>
		<%end if%>
		<% if Len(numFound) > 0 then%>
		<td valign=top><img src="./../app_images/spacer.gif" height=2 width=10></td>
		<td valign=middle align=right width=100%>
			<font style="font-family:Arial; font-size:11px;">
			<%=numFound%>&nbsp;Found
			</font>
		</td>
		<td valign=top><img src="./../app_images/spacer.gif" height=2 width=10></td>
		<%else%>
		<td valign=top><img src="./../app_images/spacer.gif" height=2 width=40></td>
		<%end if%>
	</tr>
</table>

</form>

</body>
</HTML>
