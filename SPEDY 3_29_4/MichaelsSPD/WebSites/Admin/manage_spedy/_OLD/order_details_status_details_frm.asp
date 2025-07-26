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
	<title>Details Frameset</title>
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

<frameset rows="1,15,*" border="0" framespacing=0 topmargin=0 leftmargin=0 rightmargin=0 bottommargin=0 marginheight=0 marginwidth=0 frameborder=no bordercolor=cccccc>
	<frame name="blankheaderframe" src="../app_include/blank_999999.html" scrolling="no" noresize frameborder=no>
	<frameset cols="1,*,1,18" framespacing=0 border="0" topmargin=0 leftmargin=0 rightmargin=0 bottommargin=0 marginheight=0 marginwidth=0 frameborder=no>
		<frame name="edge_separator1" src="../app_include/blank.html" scrolling="no" noresize frameborder=no>
		<frame name="DetailFrameHdr" src="../app_include/blank.html" scrolling="no" noresize frameborder=no><!-- Detail View Header -->
		<frame name="edge_separator2" src="../app_include/blank_cccccc.html" scrolling="no" noresize frameborder=no>
		<frame name="edge_separator3" src="../app_include/blank_cccccc.html" scrolling="no" noresize frameborder=no>
	</frameset>
	<frame name="DetailFrame" src="order_details_status_details.asp?oid=<%=Request("oid")%>" scrolling="yes" frameborder=no><!-- Detail View Content -->
</frameset>

</html>
