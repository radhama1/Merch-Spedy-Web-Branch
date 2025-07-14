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

<frameset cols="*,200" border="0" framespacing=0 topmargin=0 leftmargin=0 rightmargin=0 bottommargin=0 marginheight=0 marginwidth=0 frameborder=no bordercolor=cccccc>
	<frame name="CurrentCalendarFrame" src="order_details_info_calendar.asp?showdetail=1&oid=<%=Request.QueryString("oid")%>" scrolling="no" frameborder=no>
	<frame name="CalendarContextFrame" src="../app_include/blank_cccccc.html?showdetail=1&oid=<%=Request.QueryString("oid")%>" scrolling="no" noresize frameborder=no>
</frameset>

</html>
