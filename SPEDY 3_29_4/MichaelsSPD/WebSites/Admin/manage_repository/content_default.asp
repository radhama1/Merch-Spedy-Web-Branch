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
Dim Security
Set Security = New cls_Security
Security.Initialize CLng(Session.Value("UserID")), "ADMIN.CONTENT", 0
'Security.saveXMLToFile "f:\International\DocMan_NewAdmin\Security_Out.xml"

Dim selectedTab
Dim requestedSecurityScope, requestedSecurityPrivilege

selectedTab = Request("tab")
if IsNumeric(selectedTab) and Trim(selectedTab) <> "" then
	selectedTab = CInt(selectedTab)
else
	if IsNumeric(Session.Value("CONTENT_SELECTEDTAB")) and Trim(Session.Value("CONTENT_SELECTEDTAB")) <> "" then
		selectedTab = Session.Value("CONTENT_SELECTEDTAB")
	else
		selectedTab = 0
	end if
end if

requestedSecurityScope = "ADMIN.CONTENT"
requestedSecurityPrivilege = "ADMINACCESS.MODULEACCESS"
Select Case selectedTab
	Case 0
		requestedSecurityScope = "ADMIN.CONTENT.REPOSITORY"
	Case 1
		requestedSecurityScope = "ADMIN.CONTENT.LANGUAGES"
	Case 2
		requestedSecurityScope = "ADMIN.CONTENT.CUSTOMDATA"
End Select
if not Security.isRequestedScopeAllowed(requestedSecurityScope) or not Security.isRequestedPrivilegeAllowed(requestedSecurityScope, requestedSecurityPrivilege) then
	selectedTab = -1
end if

Session.Value("CONTENT_SELECTEDTAB") = selectedTab
%>
<html>
<head>
	<title></title>
	<style type="text/css">
	</style>
	<script language="javascript">
		window.defaultStatus = "Manage Content";
	</script>
</head>
<frameset rows="25,4,*" border="0" topmargin=0 leftmargin=0 rightmargin=0 bottommargin=0 marginheight=0 marginwidth=0>
	<frame name="TitleFrame" src="content_tabnav.asp?tab=<%=selectedTab%>" scrolling="no" noresize>
	<frame name="blankmargin" src="../app_include/blank_cccccc.html" scrolling="no" noresize>
	<%
	Select Case selectedTab
		Case 0
	%>
	<frame name="WorkspaceFrame" src="content_repository_frm.asp" scrolling="no" noresize>
	<%
		Case 1
	%>
	<frame name="WorkspaceFrame" src="content_settings.asp" scrolling="yes" noresize>
	<%
		Case 2
	%>
	<frame name="WorkspaceFrame" src="content_language.asp" scrolling="yes" noresize>
	<%
		Case Else
	%>
	<frame name="WorkspaceFrame" src="../app_include/blank_cccccc.html" scrolling="no" noresize>
	<%
	End Select
	%>
</frameset>
</html>
