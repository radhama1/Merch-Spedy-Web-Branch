<%@ LANGUAGE=VBSCRIPT%> 
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441
%>
<!--#include file="./../app_include/_globalInclude.asp"-->
<%
%>
<html>
<head>
	<title>Content Treeview Frameset</title>
	<style type="text/css">
	</style>
</head>
<frameset rows="1,15,*,27" border="0" topmargin=0 leftmargin=0 rightmargin=0 bottommargin=0 marginheight=0 marginwidth=0>
	<frame name="blankheaderframe2" src="../app_include/blank_666666.html" scrolling="no" noresize>
	<frameset cols="1,*,1,15" border="0" topmargin=0 leftmargin=0 rightmargin=0 bottommargin=0 marginheight=0 marginwidth=0>
		<frame name="edge_separator" src="../app_include/blank_666666.html" scrolling="no" noresize>
		<frame name="DetailFrameHdr" src="../app_include/blank_999999.html" scrolling="no" noresize><!-- Detail View Header -->
		<frame name="edge_separator" src="../app_include/blank_666666.html" scrolling="no" noresize>
		<frame name="edge_separator" src="../app_include/blank_999999.html" scrolling="no" noresize>
	</frameset>
	<frame name="DetailFrame" src="repository_details.asp?cid=0" scrolling="yes" noresize><!-- Detail View Content -->
	<frame name="PagingNavFrame" src="../app_include/blank_cccccc.html" scrolling="no" frameborder=no noresize>
</frameset>
</html>
