<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
%>
<!--#include file="./../app_include/_globalInclude.asp"-->
<%
Response.Buffer = True
Response.Expires = -1441

Dim selectedTab

selectedTab = Request("tab")
if IsNumeric(selectedTab) and Trim(selectedTab) <> "" then
	selectedTab = CInt(selectedTab)
else
	if IsNumeric(Session.Value("WEBSITE_SELECTEDTAB")) and Trim(Session.Value("WEBSITE_SELECTEDTAB")) <> "" then
		selectedTab = Session.Value("WEBSITE_SELECTEDTAB")
	else
		selectedTab = -1
	end if
end if

Session.Value("WEBSITE_SELECTEDTAB") = selectedTab
%>
<html>
<head>
	<title></title>
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
<frameset rows="*" border="0" topmargin=0 leftmargin=0 rightmargin=0 bottommargin=0 marginheight=0 marginwidth=0>
	<frame name="WorkspaceFrame" src="website_frm.asp?tab=<%=selectedTab%>" scrolling="no" noresize>
</frameset>
</html>
