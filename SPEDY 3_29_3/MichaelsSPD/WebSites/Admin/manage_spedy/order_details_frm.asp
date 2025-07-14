<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
' Modified by Ken Wallace 4/21/04 for Nova Libra, Inc.
'==============================================================================

Option Explicit
Response.Buffer = True
Response.Expires = -1441
%>
<html>
<head>
	<title>Editpane Frameset</title>
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

<frameset rows="48,*" border="0" framespacing=4 topmargin=0 leftmargin=0 rightmargin=0 bottommargin=0 marginheight=0 marginwidth=0 frameborder=yes bordercolor=cccccc>
	<frame name="EditPaneTitleframe" src="order_details_header.asp?showdetail=1&oid=<%=Request.QueryString("oid")%>" scrolling="no" noresize frameborder=no>
	<frame name="EditPaneDetailsFrame" src="../app_include/blank_cccccc.html?showdetail=1&oid=<%=Request.QueryString("oid")%>" scrolling="yes" frameborder=no>
</frameset>

</html>
