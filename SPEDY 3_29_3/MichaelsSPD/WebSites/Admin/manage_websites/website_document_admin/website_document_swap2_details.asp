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
%>
<!--#include file="./../../app_include/getfile_icon_name.asp"-->
<%

Dim objConn, objRec, SQLStr, connStr
Dim rowcolor, i, categoryID
Dim strToolTip
Dim SortColumn, SortDirection
Dim thisElementID, thisElementType
Dim numFound, startRow, pageSize, curPage, pageCount

pageCount = checkQueryID(Trim(Request("pageCount")), 1)
pageSize = checkQueryID(Trim(Request("pageSize")), 0)
if pageSize > 0 then
	Session.Value("pageSize") = pageSize
else
	if IsNumeric(Session.Value("pageSize")) and Trim(Session.Value("pageSize")) <> "" then
		pageSize = CInt(Session.Value("pageSize"))
	else
		pageSize = 50
		Session.Value("pageSize") = pageSize
	end if
end if
curPage = checkQueryID(Trim(Request("curPage")), 1)
startRow = ((curPage-1) * pageSize) + 1

'Response.Write "pageSize: " & pageSize & "<br>" & vbCrLf
'Response.Write "curPage: " & curPage & "<br>" & vbCrLf
'Response.Write "pageCount: " & pageCount & "<br>" & vbCrLf
'Response.Write "startRow: " & startRow & "<br>" & vbCrLf

thisElementType = Trim(Request("itemType"))

thisElementID = Request("itemID")
if IsNumeric(thisElementID) then
	thisElementID = CInt(thisElementID)
else
	thisElementID = 0
end if

categoryID = Trim(Request("cid"))
if IsNumeric(categoryID) and Trim(categoryID) <> "" then
	categoryID = CInt(categoryID)
else
	categoryID = 0
end if

SortColumn = Trim(Request("sort"))
if IsNumeric(SortColumn) and Trim(SortColumn) <> "" then
	SortColumn = CInt(SortColumn)
	Session.Value("Content_Repository_SortColumn") = SortColumn
else
	if IsNumeric(Session.Value("Content_Repository_SortColumn")) and Trim(Session.Value("Content_Repository_SortColumn")) <> "" then
		SortColumn = CInt(Session.Value("Content_Repository_SortColumn"))
	else
		SortColumn = 0
		Session.Value("Content_Repository_SortColumn") = SortColumn
	end if
end if

SortDirection = Trim(Request("direction"))
if IsNumeric(SortDirection) and Trim(SortDirection) <> "" then
	SortDirection = CInt(SortDirection)
	Session.Value("Content_Repository_SortDirection") = SortDirection
else
	if IsNumeric(Session.Value("Content_Repository_SortDirection")) and Trim(Session.Value("Content_Repository_SortDirection")) <> "" then
		SortDirection = CInt(Session.Value("Content_Repository_SortDirection"))
	else
		SortDirection = 0
		Session.Value("Content_Repository_SortDirection") = SortDirection
	end if
end if

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr

%>
<!--#include file="./../../app_include/getfile_icon_name.asp"-->
<%
function findItemIcon(intTopicType, strFileName, bitIsPublished)
	Dim content_icon_root, file_icon_root, link_icon_root, list_icon_root, portal_icon_root
	Dim strOutput, strIconPath	
	
	strIconPath = ""
	
	if CBool(bitIsPublished) then
		content_icon_root = "icon_nativedoc_small_on.gif"
		link_icon_root = "icon_weblink_small_on.gif"
		list_icon_root = "icon_list_small_on.gif"
		portal_icon_root = "icon_portal_small_on.gif"
	else
		content_icon_root = "icon_nativedoc_small.gif"
		link_icon_root =  "icon_weblink_small.gif"
		list_icon_root = "icon_list_small.gif"
		portal_icon_root = "icon_portal_small.gif"
	end if
	file_icon_root = getFileIcon(strFileName, 0, bitIsPublished)
	
	strOutput = content_icon_root
	
	if IsNumeric(intTopicType) and not IsNull(intTopicType) then
		intTopicType = CInt(intTopicType)
		Select Case intTopicType
			Case 0
				strOutput = strIconPath & content_icon_root
			Case 1
				strOutput = strIconPath & file_icon_root
			Case 2
				strOutput = strIconPath & link_icon_root
			Case 3
				strOutput = strIconPath & list_icon_root
			Case 4
				strOutput = strIconPath & portal_icon_root
		End Select
	end if
	
	findItemIcon = strOutput
end function

function findTopicType(intTopicType)
	if IsNumeric(intTopicType) then
		Dim strOutput
		Select Case intTopicType
			Case 0
				strOutput = "Web Document"
			Case 1
				strOutput = "File"
			Case 2
				strOutput = "Web Link"
			Case 3
				strOutput = "Web List"
			Case 4
				strOutput = "Web Portal"
			Case Else
				strOutput = ""
		End Select
	end if
	findTopicType = strOutput
end function
%>
<html>
<head>
	<title>View All Content</title>
	<style type="text/css">
	<!--
		A {text-decoration: none; color: #000000; cursor: hand;}
		A:HOVER {text-decoration: none; color: #0000ff; cursor: hand;}
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
  	//-->
	</style>
	<script language="javascript" src="./../../app_include/selectrow.js"></script><!--row highlighting-->
	<script language="javascript" src="./../../app_include/lockscroll.js"></script><!--locked headers code-->
</head>
<body bgcolor="ffffff" topmargin=0 leftmargin=0 rightmargin=0 marginheight=0 marginwidth=0>

<table width=100% cellpadding=0 cellspacing=0 border=0>
	<form name="theForm" action="website_document_swap2_save.asp" method="POST">
	<input type="hidden" name="selectedItemID" value="0">
	<input type="hidden" name="hoveredItemID" value="0">
	<input type="hidden" name="itemType" value="<%=thisElementType%>">
	<input type="hidden" name="itemID" value="<%=thisElementID%>">
	<tr>
		<td width=100%>
			<%
			SQLStr = "sp_repository_content_by_catID_showall_langs " & categoryID & ", " & SortColumn & ", " & SortDirection & ", " & pageSize & ", " & startRow
		'	Response.Write SQLStr
			objRec.Open SQLStr, objConn, adOpenStatic, adLockReadOnly, adCmdText
			if not objRec.EOF then
				numFound = CInt(objRec("totRecords"))

				if pageSize < numFound then
					if pageSize > 0 then
						if numFound mod pageSize = 0 then
							pageCount = CInt(numFound/pageSize)
						else
							pageCount = Fix(numFound/pageSize) + 1
						end if
					end if
				else
					pageCount = 1
				end if

			%>
			<table cellpadding=0 cellspacing=0 onSelectStart="return false" width=100% border=0>
				<tr bgcolor=ffffff><td colspan=13><img src="./images/spacer.gif" height=2 width=1></td></tr>
			<%
					i = 0
					Do Until objRec.EOF
						if i mod 2 = 1 then				
							rowcolor = "f3f3f3"
						else
							rowcolor = "ffffff"
						end if 
			%>
				<%if i > 0 then%>
				<tr bgcolor=e6e6e6><td colspan=13><img src="./images/spacer.gif" height=1 width=1></td></tr>
				<%end if%>
				<tr bgcolor=<%=rowcolor%> id="datarow" onDblClick="checkHighlight(true);" onClick="checkHighlight(false);" oncontextmenu="checkHighlight(true);">
					<td align="right" valign="middle"><input type=radio name="chkItem" value="num_<%=objRec("ID")%>_num" align=left></td>
					<td valign=top><img src="./../../app_images/app_icons/<%=findItemIcon(CInt(objRec("Topic_Type")), objRec("Type1_FileName"), 1)%>" border=0></td>
					<td><img src="./images/spacer.gif" height=1 width=5></td>
					<td valign=top>
						<font style="font-family:Arial, Helvetica;font-size:11px;">
						<%if not IsNull(objRec("Topic_Name")) then Response.Write Server.HTMLEncode(objRec("Topic_Name")) end if%>
						</font>
					</td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top>
						<font style="font-family:Arial, Helvetica;font-size:11px;">
						<%if not IsNull(objRec("Status_Name")) then Response.Write Server.HTMLEncode(objRec("Status_Name")) end if%>
						</font>
					</td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top>
						<font style="font-family:Arial, Helvetica;font-size:11px;">
						<%if not IsNull(objRec("Date_Last_Modified")) then Response.Write Server.HTMLEncode(objRec("Date_Last_Modified")) end if%>
						</font>
					</td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top>
						<font style="font-family:Arial, Helvetica;font-size:11px;">
						<%if not IsNull(objRec("Date_Created")) then Response.Write Server.HTMLEncode(objRec("Date_Created")) end if%>
						</font>
					</td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top>
						<font style="font-family:Arial, Helvetica;font-size:11px;">
						<%if not IsNull(objRec("Language_PrettyName")) then Response.Write Server.HTMLEncode(objRec("Language_PrettyName")) end if%>
						</font>
					</td>
					<td><img src="./images/spacer.gif" height=1 width=10></td>
					<td valign=top>
						<font style="font-family:Arial, Helvetica;font-size:11px;">
						<%if CBool(objRec("Locked")) and not IsNull(objRec("Lock_Owner_UserName")) then Response.Write Server.HTMLEncode(objRec("Lock_Owner_UserName")) end if%>
						</font>
					</td>
					<td width=100%><img src="./images/spacer.gif" height=1 width=5></td>
				</tr>
			<%
					objRec.MoveNext
					i = i + 1
					Loop
			%>
				<tr style="visibility:none;">
					<td><img src="./images/spacer.gif" height=1 width=1></td>
					<td><img src="./images/spacer.gif" height=1 width=1></td>
					<td><img src="./images/spacer.gif" height=1 width=1></td>
					<td><img src="./images/spacer.gif" height=1 width=275></td>
					<td><img src="./images/spacer.gif" height=1 width=1></td>
					<td><img src="./images/spacer.gif" height=1 width=100></td>
					<td><img src="./images/spacer.gif" height=1 width=1></td>
					<td><img src="./images/spacer.gif" height=1 width=120></td>
					<td><img src="./images/spacer.gif" height=1 width=1></td>
					<td><img src="./images/spacer.gif" height=1 width=120></td>
					<td><img src="./images/spacer.gif" height=1 width=1></td>
					<td><img src="./images/spacer.gif" height=1 width=100></td>
					<td><img src="./images/spacer.gif" height=1 width=1></td>
					<td><img src="./images/spacer.gif" height=1 width=100></td>
					<td><img src="./images/spacer.gif" height=1 width=1></td>
				</tr>
			</table>
			<script language="javascript">
			<!--
				parent.frames["DetailFrameHdr"].document.location = "website_document_swap2_details_header.asp?itemType=<%=thisElementType%>&cid=<%=categoryID%>&sort=<%=SortColumn%>&direction=<%=SortDirection%>";
				parent.frames["PagingNavFrame"].document.location = "./../../app_include/paging_navbar.asp?loc=<%=Request.ServerVariables("SCRIPT_NAME")%>&frm=DetailFrame&pageCount=<%=pageCount%>&curPage=<%=curPage%>&pageSize=<%=pageSize%>&q=<%=Server.URLEncode("cid=" & Request.QueryString("cid") & "&itemID=" & Request.QueryString("itemID") & "&itemType=" & Request.QueryString("itemType"))%>";
			//-->
			</script>
			<%
			else
			%>
			<script language="javascript">
			<!--

				parent.frames["DetailFrameHdr"].document.location = "./../../app_include/blank_999999.html";
				parent.frames["PagingNavFrame"].document.location = "./../../app_include/blank_cccccc.html";
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