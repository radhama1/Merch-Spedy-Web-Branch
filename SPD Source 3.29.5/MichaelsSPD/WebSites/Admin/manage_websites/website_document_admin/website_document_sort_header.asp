<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441

Dim parentCategoryID

parentCategoryID = Request("pcid")
if IsNumeric(parentCategoryID) then
	parentCategoryID = CInt(parentCategoryID)
else
	parentCategoryID = 0
end if
%>
<html>
<head>
	<title></title>
	<style type="text/css">
	<!--
		A {text-decoration: none;}
	//-->
	</style>
</head>
<body bgcolor="333333" link=0000ff vlink=0000ff topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>
<img src="./../images/editscreen_label_sortwebsitedocuments.gif" height=25 width=300 border=0>
</body>
</html>