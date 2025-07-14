<%@ LANGUAGE=VBSCRIPT%>
<%
Option Explicit
Response.Buffer = True
Response.Expires = -1441

Dim selectedTab

selectedTab = Request("tab")
if IsNumeric(selectedTab) and Trim(selectedTab) <> "" then
	selectedTab = CInt(selectedTab)
else
	if IsNumeric(Session.Value("SPEDY_SELECTEDTAB")) and Trim(Session.Value("SPEDY_SELECTEDTAB")) <> "" then
		selectedTab = Session.Value("SPEDY_SELECTEDTAB")
	else
		selectedTab = 0
	end if
end if

Session.Value("SPEDY_SELECTEDTAB") = selectedTab
%>
<html>
<head>
	<title>SPEDY Management</title>
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
		window.defaultStatus = "Manage SPEDY";
	//-->
	</script>
</head>
<frameset rows="25,4,*" border="0" topmargin=0 leftmargin=0 rightmargin=0 bottommargin=0 marginheight=0 marginwidth=0 bordercolor=cccccc>
	<frame name="TitleFrame" src="spedy_tabnav.asp?tab=<%=selectedTab%>" scrolling="no" noresize>
	<frame name="blankmargin" src="../app_include/blank_cccccc.html" scrolling="no" noresize>
<%
	Select Case selectedTab
		Case 0 'Tax Wizard
%>
	<frame name="WorkspaceFrame" src="tax_wizard_frm.asp" scrolling="no" noresize>
<%
		Case 1 'Workflow
%>
	<frame name="WorkspaceFrame" src="workflow_frm.asp" scrolling="no" noresize>
<%
		Case 2 'Custom Fields
%>
	<frame name="WorkspaceFrame" src="custom_field_records_frm.asp" scrolling="no" noresize>
<%
		Case 3 'Custom Validation
%>
	<frame name="WorkspaceFrame" src="validation_docs_frm.asp" scrolling="no" noresize>
<%
		Case 4 'Settings
%>
	<frame name="WorkspaceFrame" src="settings_frm.asp" scrolling="no" noresize>
<%
		Case Else
%>
	<frame name="WorkspaceFrame" src="../app_include/blank_cccccc.html" scrolling="no" noresize>
<%
	End Select
%>
</frameset>
</html>
