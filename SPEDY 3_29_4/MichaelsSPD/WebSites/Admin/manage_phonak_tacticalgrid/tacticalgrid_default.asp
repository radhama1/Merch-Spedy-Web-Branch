<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441

Dim selectedTab

selectedTab = Request("tab")
if IsNumeric(selectedTab) and Trim(selectedTab) <> "" then
	selectedTab = CInt(selectedTab)
else
	if IsNumeric(Session.Value("TACTICALGRID_SELECTEDTAB")) and Trim(Session.Value("TACTICALGRID_SELECTEDTAB")) <> "" then
		selectedTab = Session.Value("TACTICALGRID_SELECTEDTAB")
	else
		selectedTab = 0
	end if
end if

Session.Value("TACTICALGRID_SELECTEDTAB") = selectedTab
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
	<script language="javascript">
	<!--
		window.defaultStatus = "Manage Phonak Tactical Grid";
	//-->
	</script>
</head>
<frameset rows="25,4,*" border="0" topmargin=0 leftmargin=0 rightmargin=0 bottommargin=0 marginheight=0 marginwidth=0>
	<frame name="TitleFrame" src="tacticalgrid_tabnav.asp?tab=<%=selectedTab%>" scrolling="no" noresize>
	<frame name="blankmargin" src="../app_include/blank_cccccc.html" scrolling="no" noresize>
<%
	Select Case selectedTab
		Case 0
%>
	<frame name="WorkspaceFrame" src="tacticalgrid_columns.asp" scrolling="yes" noresize>
<%
		Case 1
%>
	<frame name="WorkspaceFrame" src="tacticalgrid_customdataimport.asp" scrolling="yes" noresize>
<%
		Case Else
%>
	<frame name="WorkspaceFrame" src="../app_include/blank_cccccc.html" scrolling="no" noresize>
<%
	End Select
%>
</frameset>
</html>
