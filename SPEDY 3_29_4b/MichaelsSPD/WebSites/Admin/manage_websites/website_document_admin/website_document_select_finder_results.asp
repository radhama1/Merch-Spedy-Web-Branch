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
Dim rowcolor, i
Dim SortColumn, SortDirection
Dim searchString, modifiedSearchString, searchStatus
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

searchString = Trim(Request("searchString"))
modifiedSearchString = searchString
if Len(modifiedSearchString) > 0 then
	if InStr(modifiedSearchString, """") = 1 and InStr(modifiedSearchString, """") = Len(modifiedSearchString) then
		modifiedSearchString = modifiedSearchString
	else
		if InStr(modifiedSearchString, "*") > 1 and InStr(modifiedSearchString, "*") < Len(modifiedSearchString) then
			modifiedSearchString = Left(modifiedSearchString, InStr(modifiedSearchString, "*")) & "%"
		elseif InStr(modifiedSearchString, "*") > 0 then
			modifiedSearchString = Replace(modifiedSearchString, "*", "%")
		else
			modifiedSearchString = "%" & modifiedSearchString & "%"
		end if
	end if
end if

searchStatus = Trim(Request("searchStatus"))
if IsNumeric(searchStatus) and Trim(searchStatus) <> "" then
	searchStatus = CInt(searchStatus)
else
	searchStatus = 0
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
	<form name="theForm" action="website_document_select_save.asp" method="POST">
	<input type="hidden" name="selectedItemID" value="0">
	<input type="hidden" name="hoveredItemID" value="0">
	<tr>
		<td width=100%>
			<%
			SQLStr = "SELECT b.ID, b.Topic_ID, b.Topic_Name, b.Topic_Type, b.Type1_FileName, b.Type2_LinkURL, b.Date_Last_Modified, b.Date_Created, "
			SQLStr = SQLStr & "  a.Locked, a.Lock_Owner_ID, a.Lock_Summary, a.Date_Locked,  "
			SQLStr = SQLStr & "  u.UserName As Lock_Owner_UserName, u.First_Name As Lock_Owner_First_Name, u.Last_Name As Lock_Owner_Last_Name, u.Email_Address As Lock_Owner_Email_Address, "
			SQLStr = SQLStr & "  a.Status_ID, s.Status_Name, "
			SQLStr = SQLStr & "  b.Default_Language, "
			SQLStr = SQLStr & "  b.Language_ID, "
			SQLStr = SQLStr & "  (SELECT Language_PrettyName FROM app_languages WHERE ID = b.Language_ID) As Language_PrettyName "
			SQLStr = SQLStr & "FROM Repository_Topic a "
			SQLStr = SQLStr & "INNER JOIN Repository_Topic_Details b ON b.Topic_ID = a.ID AND b.Default_Language = 1 "
			SQLStr = SQLStr & "INNER JOIN Repository_Category_Topic c ON c.Topic_ID = a.ID "
			SQLStr = SQLStr & "LEFT OUTER JOIN Repository_Status s ON s.[ID] = a.Status_ID "
			SQLStr = SQLStr & "LEFT OUTER JOIN Security_User u ON u.[ID] = a.Lock_Owner_ID "
			SQLStr = SQLStr & "WHERE b.Topic_Name LIKE '" & modifiedSearchString & "' "
			if searchStatus > 0 then
				SQLStr = SQLStr & "AND Status_ID = " & searchStatus
			end if
			
			Dim sortIndicator
			if SortDirection = 1 then
				sortIndicator = "DESC"			
			else
				sortIndicator = "ASC"			
			end if
			
			Select Case SortColumn
				Case 0
					SQLStr = SQLStr & "ORDER BY Topic_Name " & sortIndicator & ", a.[ID] " & sortIndicator & " "			
				Case 1
					SQLStr = SQLStr & "ORDER BY Status_Name " & sortIndicator & ", Topic_Name " & sortIndicator & ", a.[ID] " & sortIndicator & " "			
				Case 2
					SQLStr = SQLStr & "ORDER BY Locked " & sortIndicator & ", Lock_Owner_UserName " & sortIndicator & ", Topic_Name " & sortIndicator & ", a.[ID] " & sortIndicator & " "			
				Case 3
					SQLStr = SQLStr & "ORDER BY Language_PrettyName " & sortIndicator & ", Topic_Name " & sortIndicator & ", a.[ID] " & sortIndicator & " "			
				Case 4
					SQLStr = SQLStr & "ORDER BY Topic_Type_Summary " & sortIndicator & ", Topic_Name " & sortIndicator & ", a.[ID] " & sortIndicator & " "			
				Case 5
					SQLStr = SQLStr & "ORDER BY a.Date_Last_Modified " & sortIndicator & ", Topic_Name " & sortIndicator & ", a.[ID] " & sortIndicator & " "			
				Case 6
					SQLStr = SQLStr & "ORDER BY a.Date_Created " & sortIndicator & ", Topic_Name " & sortIndicator & ", a.[ID] " & sortIndicator & " "			
				Case Else
					SQLStr = SQLStr & "ORDER BY Topic_Name " & sortIndicator & ", a.[ID] " & sortIndicator & " "			
			End Select
		'	Response.Write SQLStr
			objRec.Open SQLStr, objConn, adOpenStatic, adLockReadOnly, adCmdText
			if not objRec.EOF then
			%>
			<table cellpadding=0 cellspacing=0 onSelectStart="return false" width=100% border=0>
				<tr bgcolor=ffffff><td colspan=18><img src="./images/spacer.gif" height=2 width=1></td></tr>
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
				<tr bgcolor=e6e6e6><td colspan=18><img src="./images/spacer.gif" height=1 width=1></td></tr>
				<%end if%>
				<tr bgcolor=<%=rowcolor%> id="datarow" onDblClick="checkHighlight(true);" onClick="checkHighlight(false);" oncontextmenu="checkHighlight(true);">
					<td align="right" valign="middle"><input type=checkbox name="chkItem" value="num_<%=objRec("ID")%>_num" align=left></td>
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
				parent.frames["DetailFrameHdr"].document.location = "website_document_select_finder_results_header.asp?searchString=<%=searchString%>&searchStatus=<%=searchStatus%>&sort=<%=SortColumn%>&direction=<%=SortDirection%>";
				parent.frames["PagingNavFrame"].document.location = "./../../app_include/blank_cccccc.html";
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