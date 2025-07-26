<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441
%>
<!--#include file="./../../app_include/_globalInclude.asp"-->
<%

Dim Item_ID
Item_ID = Request("id")
if IsNumeric(Item_ID) then
	Item_ID = CInt(Item_ID)
else
	Item_ID = 0
end if
%>
<html>
<head>
	<title><%if Item_ID > 0 then%>Edit<%else%>New<%end if%> Workflow Exception</title>
	<script language=javascript>
	<!--
	self.focus();
	//-->
	</script>
</head>
<frameset rows="50,1,1,*,1,1,30,0" border="0">
	<frame name="header" src="./../../app_include/blank_cccccc.html" scrolling="no" marginwidth="0" marginheight="0" noresize>
	<frame name="line1" src="./../../app_include/blank_666666.html" scrolling="no" marginwidth="0" marginheight="0" noresize>
	<frame name="line2" src="./../../app_include/blank_ffffff.html" scrolling="no" marginwidth="0" marginheight="0" noresize>
	<frame name="body" src="exception_details.asp?id=<%=Item_ID%>" scrolling="auto" marginwidth="0" marginheight="0" noresize>
	<frame name="line3" src="./../../app_include/blank_666666.html" scrolling="no" marginwidth="0" marginheight="0" noresize>
	<frame name="line4" src="./../../app_include/blank_ffffff.html" scrolling="no" marginwidth="0" marginheight="0" noresize>
	<frame name="controls" src="./../../app_include/blank_cccccc.html" scrolling="no" marginwidth="0" marginheight="0" noresize>
	<frame name="calcFrame" src="./../../app_include/blank_cccccc.html" scrolling="no" marginwidth="0" marginheight="0" noresize>
</frameset>
</html>