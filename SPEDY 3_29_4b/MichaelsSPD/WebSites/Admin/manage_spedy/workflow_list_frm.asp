<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441
%>
<html>
<head>
	<title>Content Treeview Frameset</title>
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

<frameset rows="1,15,*,27" border="0" framespacing=0 topmargin=0 leftmargin=0 rightmargin=0 bottommargin=0 marginheight=0 marginwidth=0 frameborder=no>
	<frame name="blankheaderframe" src="../app_include/blank_666666.html" scrolling="no" noresize frameborder=no>
	<frameset cols="1,*,1,15" border="0" topmargin=0 leftmargin=0 rightmargin=0 bottommargin=0 marginheight=0 marginwidth=0 frameborder=no>
		<frame name="edge_separator" src="../app_include/blank_666666.html" scrolling="no" noresize>
		<frame name="DetailFrameHdr" src="../app_include/blank_999999.html" scrolling="no" noresize><!-- Detail View Header -->
		<frame name="edge_separator" src="../app_include/blank_666666.html" scrolling="no" noresize>
		<frame name="edge_separator" src="../app_include/blank_999999.html" scrolling="no" noresize>
	</frameset>
	<frame name="DetailFrame" src="workflow_list.asp?tid=0" scrolling="yes"><!-- Detail View Content -->
	<frame name="PagingNavFrame" src="../app_include/blank_cccccc.html" scrolling="no" noresize frameborder=no>
</frameset>

</html>
