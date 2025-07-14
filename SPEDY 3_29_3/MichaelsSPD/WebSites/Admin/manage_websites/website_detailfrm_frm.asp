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

Dim selectedTab, websiteID

'websiteID = checkQueryID(Request("webid"), 0)

'Get the Website ID
websiteID = Request("webid")
if not IsNumeric(websiteID) or Len(Trim(websiteID)) = 0 then
	if IsNumeric(Session.Value("websiteID")) and Trim(Session.Value("websiteID")) <> "" then
		websiteID = Session.Value("websiteID")
	else
		websiteID = 0
	end if
end if
Session.Value("websiteID") = websiteID

selectedTab = checkQueryID(Request("tab"), 1)
if IsNumeric(selectedTab) and Trim(selectedTab) <> "" then
	selectedTab = CInt(selectedTab)
else
	if IsNumeric(Session.Value("WEBSITE_SELECTEDTAB")) and Trim(Session.Value("WEBSITE_SELECTEDTAB")) <> "" then
		selectedTab = Session.Value("WEBSITE_SELECTEDTAB")
	else
		selectedTab = 0
	end if
end if

Session.Value("WEBSITE_SELECTEDTAB") = selectedTab
%>
<html>
<head>
	<title>Website Treeview Frameset</title>
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
<%
	if websiteID > 0 then
%>
	<frameset id="WebsiteWrapperFrameset" rows="25,4,10,*" border="0" topmargin=0 leftmargin=0 rightmargin=0 bottommargin=0 marginheight=0 marginwidth=0>
		<frame name="DetailsTabFrame" src="website_details_tabnav.asp?tab=<%=selectedTab%>&webid=<%=Request("webid")%>" scrolling="no" noresize>
		<frame name="blankmargin" src="../app_include/blank_cccccc.html" scrolling="no" noresize>
		<frameset rows="1,1,*,7,1" border="0" name="FilterFrameWrapper" id="FilterFrameWrapper">
			<frame name="line1" src="../app_include/blank_999999.html" scrolling="no" noresize>
			<frame name="line2" src="../app_include/blank_ececec.html" scrolling="no" noresize>
			<frame name="FilterFrame" src="website_filter.asp" scrolling="no" noresize>
			<frame name="FilterFrameHandle" src="website_filter_handle.asp" scrolling="no" noresize>
			<frame name="line3" src="../app_include/blank_999999.html" scrolling="no" noresize>
		</frameset>
		<frameset cols="*,2" border="0" topmargin=0 leftmargin=0 rightmargin=0 bottommargin=0 marginheight=0 marginwidth=0>
			<frame name="DetailFrameWrapper" src="website_details_frm.asp?tab=<%=selectedTab%>&webid=<%=Request("webid")%>" scrolling="no" noresize>
			<frame name="edge_separator" src="../app_include/blank_cccccc.html" scrolling="no" noresize>
		</frameset>
	</frameset>
<%
	else
%>
	<frameset id="WebsiteWrapperFrameset" rows="*"  border="0" topmargin=0 leftmargin=0 rightmargin=0 bottommargin=0 marginheight=0 marginwidth=0>
		<frame name="blank_page" src="../app_include/blank_cccccc.html" scrolling="no" noresize>
	</frameset>
<%
	end if
%>
</html>
