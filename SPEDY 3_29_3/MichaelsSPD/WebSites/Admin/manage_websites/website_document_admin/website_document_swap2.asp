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

Dim thisElementID, thisElementType

thisElementType = Trim(Request("itemType"))

thisElementID = Request("itemID")
if IsNumeric(thisElementID) then
	thisElementID = CInt(thisElementID)
else
	thisElementID = 0
end if
%>
<html>
<head>
	<title>Swap</title>
	<script language=javascript>
	<!--
	self.focus();
	//-->
	</script>
</head>
<frameset rows="30,1,1,*,1,1,30" border="0" frameborder="1" border="0" marginwidth="0" marginheight="0" leftmargin="0" topmargin="0">
	<frame name="header" src="website_document_swap2_header.asp?itemType=<%=thisElementType%>&itemID=<%=thisElementID%>" scrolling="no" marginwidth="0" marginheight="0">
	<frame name="line1" src="./../../app_include/blank_999999.html" scrolling="no" marginwidth="0" marginheight="0" noresize>
	<frame name="line2" src="./../../app_include/blank_666666.html" scrolling="no" marginwidth="0" marginheight="0" noresize>
	<frameset cols="240,*" bordercolor="cccccc" frameborder="1" framespacing=2 border="0" marginwidth="0" marginheight="0" leftmargin="0" topmargin="0">
		<frameset rows="*,80" border="0" frameborder="0" border="0" marginwidth="0" marginheight="0" leftmargin="0" topmargin="0">
			<frame name="tree" src="website_document_swap2_tree.asp?itemType=<%=thisElementType%>&itemID=<%=thisElementID%>" scrolling="auto">
			<frame name="finder" src="website_document_swap2_finder.asp" scrolling="no" marginwidth="0" marginheight="0">
		</frameset>
		<frame name="body" src="website_document_swap2_details_frm.asp?itemType=<%=thisElementType%>&itemID=<%=thisElementID%>" scrolling="auto" marginwidth="0" marginheight="0" >
	</frameset>
	<frame name="line3" src="./../../app_include/blank_666666.html" scrolling="no" marginwidth="0" marginheight="0" noresize>
	<frame name="line4" src="./../../app_include/blank_ffffff.html" scrolling="no" marginwidth="0" marginheight="0" noresize>
	<frame name="controls" src="website_document_swap2_footer.asp?itemType=<%=thisElementType%>&itemID=<%=thisElementID%>" scrolling="no" marginwidth="0" marginheight="0" noresize>
</frameset>
</html>