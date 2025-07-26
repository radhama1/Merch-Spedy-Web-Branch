<%@ LANGUAGE=VBSCRIPT%>
<%
Option Explicit
Response.Buffer = True
Response.Expires = -1441
%>
<html>
<head>
	<title>Frameset</title>
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
<frameset id="MainListFrame" rows="*,0" border="0" framespacing=2 topmargin=0 leftmargin=0 rightmargin=0 bottommargin=0 marginheight=0 marginwidth=0 frameborder=yes bordercolor=cccccc>
	<frame name="DetailFrameWrapper" src="validation_doc_list_frm.asp" scrolling="no">
	<frame name="DetailFrame" src="../app_include/blank_999999.html" scrolling="no" frameborder=no>
</frameset>
</html>
