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
<frameset id="RepositoryWrapperFrameset" rows="10,*" border="0" topmargin=0 leftmargin=0 rightmargin=0 bottommargin=0 marginheight=0 marginwidth=0>
	<frameset rows="1,1,*,7,1" border="0" name="FilterFrameWrapper" id="FilterFrameWrapper">
		<frame name="line1" src="../app_include/blank_999999.html" scrolling="no" noresize>
		<frame name="line2" src="../app_include/blank_ececec.html" scrolling="no" noresize>
		<frame name="FilterFrame" src="repository_filter.asp" scrolling="no" noresize>
		<frame name="FilterFrameHandle" src="repository_filter_handle.asp" scrolling="no" noresize>
		<frame name="line3" src="../app_include/blank_999999.html" scrolling="no" noresize>
	</frameset>
	<frameset cols="200,*" border="0" name="MainDetailFrameWrapper" id="MainDetailFrameWrapper" frameborder=1 framespacing=2 bordercolor=cccccc>
		<frame name="TreeFrameWrapper" src="repository_tree_frm.asp" scrolling="no">
		<frame name="DetailFrameWrapper" src="repository_details_frm.asp" scrolling="no">
	</frameset>
</frameset>
</html>
