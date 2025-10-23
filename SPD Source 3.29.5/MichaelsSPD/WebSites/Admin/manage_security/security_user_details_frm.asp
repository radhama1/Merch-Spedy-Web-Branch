<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441

Dim enumerateUserGroup, enumerateUserRole, selectedGroupID

enumerateUserGroup = Request("enumgroup")
if IsNumeric(enumerateUserGroup) then
	enumerateUserGroup = CBool(enumerateUserGroup)
else
	enumerateUserGroup = CBool(0)
end if

enumerateUserRole = Request("enumrole")
if IsNumeric(enumerateUserRole) then
	enumerateUserRole = CBool(enumerateUserRole)
else
	enumerateUserRole = CBool(0)
end if
%>
<html>
<head>
	<title>Users Security Frameset</title>
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
<%if enumerateUserGroup or enumerateUserRole then%>
<frameset id="MainDetailFrame" rows="15,10,1,15,*,20" border="0" topmargin=0 leftmargin=0 rightmargin=0 bottommargin=0 marginheight=0 marginwidth=0>
	<frame name="Titleframe2" src="security_user_header.asp?enumgroup=<%=Request.QueryString("enumgroup")%>&enumrole=<%=Request.QueryString("enumrole")%>&sgid=<%=Request.QueryString("sgid")%>" scrolling="no" noresize>
	<frameset rows="1,1,*,7,1" border="0" name="FilterFrameWrapper" id="FilterFrameWrapper">
		<frame name="line1" src="../app_include/blank_999999.html" scrolling="no" noresize>
		<frame name="line2" src="../app_include/blank_ececec.html" scrolling="no" noresize>
		<frame name="FilterFrame" src="security_user_filter.asp?enumgroup=<%=Request.QueryString("enumgroup")%>&enumrole=<%=Request.QueryString("enumrole")%>" scrolling="no" noresize>
		<frame name="FilterFrameHandle" src="security_user_filter_handle.asp?enumgroup=<%=Request.QueryString("enumgroup")%>&enumrole=<%=Request.QueryString("enumrole")%>" scrolling="no" noresize>
		<frame name="line3" src="../app_include/blank_999999.html" scrolling="no" noresize>
	</frameset>
	<frame name="blankheaderframe2" src="../app_include/blank_666666.html" scrolling="no" noresize>
	<frameset cols="1,*,1" border="0" topmargin=0 leftmargin=0 rightmargin=0 bottommargin=0 marginheight=0 marginwidth=0>
		<frame name="edge_separator" src="../app_include/blank_666666.html" scrolling="no" noresize>
		<frame name="DetailFrameHdr" src="../app_include/blank_999999.html" scrolling="no" noresize><!-- Security Detail View Header -->
		<frame name="edge_separator" src="../app_include/blank_666666.html" scrolling="no" noresize>
	</frameset>
	<frame name="DetailFrame" src="security_user_details.asp?enumgroup=<%=Request.QueryString("enumgroup")%>&enumrole=<%=Request.QueryString("enumrole")%>&sgid=<%=Request.QueryString("sgid")%>" scrolling="yes" noresize><!-- Security Detail View Content -->
	<frame name="PagingNavFrame" src="../app_include/blank_cccccc.html" scrolling="no" frameborder=no noresize>
</frameset>
<%else%>
<frameset id="MainDetailFrame" rows="1,10,15,*,20" border="0" topmargin=0 leftmargin=0 rightmargin=0 bottommargin=0 marginheight=0 marginwidth=0>
	<frame name="blankheaderframe2" src="../app_include/blank_666666.html" scrolling="no" noresize>
	<frameset rows="1,1,*,7,1" border="0" name="FilterFrameWrapper" id="FilterFrameWrapper">
		<frame name="line1" src="../app_include/blank_999999.html" scrolling="no" noresize>
		<frame name="line2" src="../app_include/blank_ececec.html" scrolling="no" noresize>
		<frame name="FilterFrame" src="security_user_filter.asp?enumgroup=<%=Request.QueryString("enumgroup")%>&enumrole=<%=Request.QueryString("enumrole")%>" scrolling="no" noresize>
		<frame name="FilterFrameHandle" src="security_user_filter_handle.asp?enumgroup=<%=Request.QueryString("enumgroup")%>&enumrole=<%=Request.QueryString("enumrole")%>" scrolling="no" noresize>
		<frame name="line3" src="../app_include/blank_999999.html" scrolling="no" noresize>
	</frameset>
	<frameset cols="1,*,1" border="0" topmargin=0 leftmargin=0 rightmargin=0 bottommargin=0 marginheight=0 marginwidth=0>
		<frame name="edge_separator" src="../app_include/blank_666666.html" scrolling="no" noresize>
		<frame name="DetailFrameHdr" src="../app_include/blank_999999.html" scrolling="no" noresize><!-- Security Detail View Header -->
		<frame name="edge_separator" src="../app_include/blank_666666.html" scrolling="no" noresize>
	</frameset>
	<frame name="DetailFrame" src="security_user_details.asp?enumgroup=<%=Request.QueryString("enumgroup")%>&enumrole=<%=Request.QueryString("enumrole")%>&sgid=<%=Request.QueryString("sgid")%>" scrolling="yes" noresize><!-- Security Detail View Content -->
	<frame name="PagingNavFrame" src="../app_include/blank_cccccc.html" scrolling="no" frameborder=no noresize>
</frameset>
<%end if%>
</html>
