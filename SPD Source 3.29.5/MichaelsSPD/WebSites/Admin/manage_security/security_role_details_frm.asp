<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441

Dim showUserList, listType, selectedGroupID

showUserList = Request("showusers")
if IsNumeric(showUserList) then
	showUserList = CBool(showUserList)
else
	showUserList = CBool(0)
end if

listType = Request("grouptype")
if IsNumeric(listType) then
	listType = CInt(listType)
else
	listType = CInt(0)
end if

selectedGroupID = Request("id")
if IsNumeric(selectedGroupID) then
	selectedGroupID = CInt(selectedGroupID)
else
	selectedGroupID = 0
end if
%>
<html>
<head>
	<title>Role Security Frameset</title>
	<style type="text/css">
	<!--
		BODY
		{
			scrollbar-face-color: "#cccccc"; 
			scrollbar-highlight-color: "#cccccc"; 
			scrollbar-shadow-color: "#cccccc";
			scrollbar-3dlight-color: "#cccccc"; 
			scrollbar-arrow-color: "#000000";
			scrollbar-track-color: "#FFFFFF";
			scrollbar-darkshadow-color: "#cccccc";
		}
	//-->
	</style>
</head>
<frameset rows="*<%if showUserList and selectedGroupID > 0 then Response.Write ",200" end if%>" framespacing=2 border="0" topmargin=0 leftmargin=0 rightmargin=0 bottommargin=0 marginheight=0 marginwidth=0>
	<frameset rows="1,16,*" framespacing=0 border="0" topmargin=0 leftmargin=0 rightmargin=0 bottommargin=0 marginheight=0 marginwidth=0 frameborder=no>
		<frame name="blankheaderframe2" src="../app_include/blank_666666.html" scrolling="no" noresize frameborder=no>
		<frameset cols="1,*,1" framespacing=0 border="0" topmargin=0 leftmargin=0 rightmargin=0 bottommargin=0 marginheight=0 marginwidth=0 frameborder=no>
			<frame name="edge_separator" src="../app_include/blank_666666.html" scrolling="no" noresize frameborder=no>
			<frame name="DetailFrameHdr" src="../app_include/blank_999999.html" scrolling="no" noresize frameborder=no><!-- Security Detail View Header -->
			<frame name="edge_separator" src="../app_include/blank_666666.html" scrolling="no" noresize frameborder=no>
		</frameset>
		<frame name="GroupDetailFrame" src="security_role_details.asp" scrolling="yes" frameborder=no><!-- Security Detail View Content -->
	</frameset>
<%
if showUserList and selectedGroupID > 0 and listType = 2 then
%>
	<frame name="UserList" src="security_user_details_frm.asp?enumgroup=0&enumrole=1&sgid=<%=selectedGroupID%>" scrolling="no" frameborder=yes>
<%
end if
%>
</frameset>
</html>
