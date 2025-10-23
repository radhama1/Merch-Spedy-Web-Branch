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

Dim Tax_ID
Tax_ID = Request("tid")
if not IsNumeric(Tax_ID) or Len(Trim(Tax_ID)) = 0 then
	if IsNumeric(Session.Value("taxID")) and Trim(Session.Value("taxID")) <> "" then
		Tax_ID = Session.Value("taxID")
	else
		Tax_ID = 0
	end if
end if

Dim questionID, parentQuestionID

questionID = Request("qid")
if IsNumeric(questionID) then
	questionID = CInt(questionID)
else
	questionID = 0
end if

parentQuestionID = Request("pqid")
if IsNumeric(parentQuestionID) then
	parentQuestionID = CInt(parentQuestionID)
else
	parentQuestionID = 0
end if
%>
<html>
<head>
	<title><%if questionID > 0 then%>Edit<%else%>New<%end if%> Question</title>
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
	<frame name="body" src="question_details.asp?tid=<%=Tax_ID%>&qid=<%=questionID%>&pqid=<%=parentQuestionID%>" scrolling="auto" marginwidth="0" marginheight="0" noresize>
	<frame name="line3" src="./../../app_include/blank_666666.html" scrolling="no" marginwidth="0" marginheight="0" noresize>
	<frame name="line4" src="./../../app_include/blank_ffffff.html" scrolling="no" marginwidth="0" marginheight="0" noresize>
	<frame name="controls" src="./../../app_include/blank_cccccc.html" scrolling="no" marginwidth="0" marginheight="0" noresize>
	<frame name="calcFrame" src="./../../app_include/blank_cccccc.html" scrolling="no" marginwidth="0" marginheight="0" noresize>
</frameset>
</html>