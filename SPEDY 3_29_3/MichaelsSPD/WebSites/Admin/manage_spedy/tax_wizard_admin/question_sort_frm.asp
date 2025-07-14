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
	<title>Sort Tax Questions</title>
	<script language=javascript>
	<!--
	self.focus();
	//-->
	</script>
</head>
<frameset rows="25,1,1,*,1,1,30,0" border="0">
	<frame name="header" src="./../../app_include/blank_cccccc.html" scrolling="no" marginwidth="0" marginheight="0" noresize>
	<frame name="line1" src="./../../app_include/blank_666666.html" scrolling="no" marginwidth="0" marginheight="0" noresize>
	<frame name="line2" src="./../../app_include/blank_ffffff.html" scrolling="no" marginwidth="0" marginheight="0" noresize>
	<frame name="body" src="question_sort.asp?pqid=<%=Request("pqid")%>" scrolling="no" marginwidth="0" marginheight="0" noresize>
	<frame name="line3" src="./../../app_include/blank_666666.html" scrolling="no" marginwidth="0" marginheight="0" noresize>
	<frame name="line4" src="./../../app_include/blank_ffffff.html" scrolling="no" marginwidth="0" marginheight="0" noresize>
	<frame name="controls" src="./../../app_include/blank_cccccc.html" scrolling="no" marginwidth="0" marginheight="0" noresize>
	<frame name="calcFrame" src="./../../app_include/blank_cccccc.html" scrolling="no" marginwidth="0" marginheight="0" noresize>
</frameset>
</html>