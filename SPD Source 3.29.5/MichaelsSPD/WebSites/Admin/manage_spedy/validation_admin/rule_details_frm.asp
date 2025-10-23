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

Dim Record_ID
Record_ID = Request("tid")
if not IsNumeric(Record_ID) or Len(Trim(Record_ID)) = 0 then
	if IsNumeric(Session.Value("recordID")) and Trim(Session.Value("recordID")) <> "" then
		Record_ID = Session.Value("recordID")
	else
		Record_ID = 0
	end if
end if

Dim ruleID

ruleID = Request("rid")
if IsNumeric(ruleID) then
	ruleID = CInt(ruleID)
else
	ruleID = 0
end if
%>
<html>
<head>
	<title><%if ruleID > 0 then%>Edit<%else%>New<%end if%> Rule</title>
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
	<frame name="body" src="rule_details.asp?tid=<%=Record_ID%>&rid=<%=ruleID%>" scrolling="auto" marginwidth="0" marginheight="0" noresize>
	<frame name="line3" src="./../../app_include/blank_666666.html" scrolling="no" marginwidth="0" marginheight="0" noresize>
	<frame name="line4" src="./../../app_include/blank_ffffff.html" scrolling="no" marginwidth="0" marginheight="0" noresize>
	<frame name="controls" src="./../../app_include/blank_cccccc.html" scrolling="no" marginwidth="0" marginheight="0" noresize>
	<frame name="calcFrame" src="./../../app_include/blank_cccccc.html" scrolling="no" marginwidth="0" marginheight="0" noresize>
</frameset>
</html>