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

<frameset rows="15,1,*,2,25" border="0" topmargin=0 leftmargin=0 rightmargin=0 bottommargin=0 marginheight=0 marginwidth=0>
	<frameset cols="5,*,5" border="0" topmargin=0 leftmargin=0 rightmargin=0 bottommargin=0 marginheight=0 marginwidth=0>
		<frame name="edge_separator" src="../app_include/blank_cccccc.html" scrolling="no" noresize>
		<frame name="TreeFrameHdr" src="repository_tree_header.asp" scrolling="no" noresize><!-- Tree List Header -->
		<frame name="edge_separator" src="../app_include/blank_cccccc.html" scrolling="no" noresize>
	</frameset>
	<frame name="blankheaderframe1" src="../app_include/blank_999999.html" scrolling="no" noresize>
	<frame name="TreeFrame" src="repository_tree.asp" scrolling="auto" noresize><!-- Tree List -->
	<frame name="OptionsFrameHdr" src="../app_include/blank_cccccc.html" scrolling="no" noresize>
	<frame name="OptionsFrame" src="content_footer_shortcuts.asp" scrolling="no" noresize>
</frameset>

</html>
