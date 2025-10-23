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
		selectedTab = 0
	end if
end if

Session.Value("WEBSITE_SELECTEDTAB") = selectedTab
%>
<html>
<head>
	<title>Website Treeview Frameset</title>
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
<frameset cols="*,2,1" border="0" topmargin=0 leftmargin=0 rightmargin=0 bottommargin=0 marginheight=0 marginwidth=0>
	<frameset rows="4,15,1,*,2,25" border="0" topmargin=0 leftmargin=0 rightmargin=0 bottommargin=0 marginheight=0 marginwidth=0>
		<frame name="blankheaderframe1" src="../app_include/blank_cccccc.html" scrolling="no" noresize>
		<frameset cols="5,*,5" border="0" topmargin=0 leftmargin=0 rightmargin=0 bottommargin=0 marginheight=0 marginwidth=0>
			<frame name="edge_separator" src="../app_include/blank_cccccc.html" scrolling="no" noresize>
			<frame name="TreeFrameHdr" src="website_tree_header.asp" scrolling="no" noresize><!-- Tree List Header -->
			<frame name="edge_separator" src="../app_include/blank_cccccc.html" scrolling="no" noresize>
		</frameset>
		<frame name="blankheaderframe1" src="../app_include/blank_999999.html" scrolling="no" noresize>
		<frame name="TreeFrame" src="website_tree.asp" scrolling="auto" noresize><!-- Tree List -->
		<frame name="TreeOptionsFrameHdr" src="../app_include/blank_cccccc.html" scrolling="no" noresize>
		<frame name="TreeOptionsFrame" src="website_tree_footer.asp" scrolling="no" noresize>
	</frameset>
	<frame name="edge_separator" src="../app_include/blank_cccccc.html" scrolling="no" noresize>
	<frame name="edge_separator" src="../app_include/blank.html" scrolling="no" noresize>
</frameset>
</html>
