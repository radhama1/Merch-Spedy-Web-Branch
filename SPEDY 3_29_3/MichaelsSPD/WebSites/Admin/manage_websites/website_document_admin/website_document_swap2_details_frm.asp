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
	<title></title>
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
<frameset rows="1,15,*,20" border="0" topmargin=0 leftmargin=0 rightmargin=0 bottommargin=0 marginheight=0 marginwidth=0>
	<frame name="blankheaderframe2" src="../../app_include/blank_666666.html" scrolling="no" noresize>
	<frameset cols="1,*,1" border="0" topmargin=0 leftmargin=0 rightmargin=0 bottommargin=0 marginheight=0 marginwidth=0>
		<frame name="edge_separator" src="../../app_include/blank_666666.html" scrolling="no" noresize>
		<frame name="DetailFrameHdr" src="../../app_include/blank_999999.html" scrolling="no" noresize><!-- Detail View Header -->
		<frame name="edge_separator" src="../../app_include/blank_666666.html" scrolling="no" noresize>
	</frameset>
	<frame name="DetailFrame" src="website_document_swap2_details.asp?cid=0&itemType=<%=thisElementType%>&itemID=<%=thisElementID%>" scrolling="yes" noresize><!-- Detail View Content -->
	<frame name="PagingNavFrame" src="./../../app_include/blank_cccccc.html" scrolling="no" frameborder=no noresize>
</frameset>
</html>
