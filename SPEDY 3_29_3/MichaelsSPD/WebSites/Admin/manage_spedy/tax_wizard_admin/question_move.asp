<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
%>
<!--#include file="./../../app_include/_globalInclude.asp"-->
<%
Response.Buffer = True
Response.Expires = -1441

Dim questionID, taxID

taxID = checkQueryID(Request("tid"),1)
questionID = Request.QueryString("qid")
if IsNumeric(questionID) then
	questionID = CInt(questionID)
else
	questionID = 0
end if
%>
<html>
<head>
	<title>Move</title>
	<script language=javascript>
	<!--
	self.focus();
	//-->
	</script>
</head>
<frameset rows="30,1,1,*,1,1,50" border="0">
	<frame name="header" src="question_move_header.asp" scrolling="no" marginwidth="0" marginheight="0" noresize>
	<frame name="line1" src="./../../app_include/blank_999999.html" scrolling="no" marginwidth="0" marginheight="0" noresize>
	<frame name="line2" src="./../../app_include/blank_666666.html" scrolling="no" marginwidth="0" marginheight="0" noresize>
	<frame name="body" src="question_move_tree.asp?tid=<%=taxID%>&open=<%=Request("open")%>&qid=<%=questionID%>" scrolling="auto" marginwidth="0" marginheight="0" noresize>
	<frame name="line3" src="./../../app_include/blank_666666.html" scrolling="no" marginwidth="0" marginheight="0" noresize>
	<frame name="line4" src="./../../app_include/blank_ffffff.html" scrolling="no" marginwidth="0" marginheight="0" noresize>
	<frame name="controls" src="question_move_footer.asp" scrolling="no" marginwidth="0" marginheight="0" noresize>
</frameset>
</html>