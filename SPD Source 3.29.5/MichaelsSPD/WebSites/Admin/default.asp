<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441
%>
<!--#include file="./app_include/_globalInclude.asp"-->
<%
Dim selectedNavTab, MainDisplayFrame_URL
Dim Security
Set Security = New cls_Security

Security.Initialize CLng(Session.Value("UserID")), "ADMIN", 0

selectedNavTab = Trim(Request("tab"))
if IsNumeric(selectedNavTab) and Len(selectedNavTab) > 0 then
	selectedNavTab = CInt(selectedNavTab)
else
	selectedNavTab = Session.Value("SELECTED_MODULE")
	if IsNumeric(selectedNavTab) and Len(Trim(selectedNavTab)) > 0 then
		selectedNavTab = CInt(selectedNavTab)
	else
		selectedNavTab = Trim(Request.Cookies(Application.Value("ADMINTOOL_PERSISTENTSTATE_COOKIE_NAME"))("SELECTED_MODULE"))
		if IsNumeric(selectedNavTab) and Len(Trim(selectedNavTab)) > 0 then
			selectedNavTab = CInt(selectedNavTab)
		else
			selectedNavTab = -1
		end if
	end if
end if

Dim requestedSecurityScope, requestedSecurityPrivilege
requestedSecurityScope = ""
requestedSecurityPrivilege = "ADMINACCESS.MODULEACCESS"

Select Case selectedNavTab
	Case 0
		requestedSecurityScope = "ADMIN.CONTENT"
	Case 1
		requestedSecurityScope = "ADMIN.SECURITY"
	Case 2
		requestedSecurityScope = "ADMIN.WEBSITES"
	Case 3
		requestedSecurityScope = "ADMIN.REPORTING"
	Case 4
		requestedSecurityScope = "ADMIN.CONTACT"
	Case 5
		requestedSecurityScope = "ADMIN.WORKFLOW"
	Case 6
		requestedSecurityScope = "ADMIN.PRODUCT"
	Case 10
		requestedSecurityScope = "ADMIN.ORDER"
	Case 11
		requestedSecurityScope = "ADMIN.COURSE"
	Case 12
		requestedSecurityScope = "ADMIN.CUSTOMERS"
	Case 13
		requestedSecurityScope = "ADMIN.AFFILIATES"
	Case 14
		requestedSecurityScope = "ADMIN.CERTIFICATES"
	Case 15
		requestedSecurityScope = "ADMIN.BTW"
	Case 16
		requestedSecurityScope = "ADMIN.PROMOTIONS"
	Case 20
		requestedSecurityScope = "ADMIN.TACTICALGRID"
End Select

'Response.Write Security.isRequestedScopeAllowed("ADMIN") & "<br>"
'Response.Write Security.isRequestedPrivilegeAllowed("ADMIN", "ADMINACCESS") & "<br>"
'Response.End
if not Security.isRequestedScopeAllowed("ADMIN") or not Security.isRequestedPrivilegeAllowed("ADMIN", "ADMINACCESS") then
	Response.Redirect "./logout.asp"
end if
if not Security.isRequestedScopeAllowed(requestedSecurityScope) or not Security.isRequestedPrivilegeAllowed(requestedSecurityScope, requestedSecurityPrivilege) then
	selectedNavTab = -1
end if

Select Case selectedNavTab
	Case 0
		MainDisplayFrame_URL = "./manage_repository/content_default.asp"
	Case 1
		MainDisplayFrame_URL = "./manage_security/security_default.asp"
	Case 2
		MainDisplayFrame_URL = "./manage_websites/website_default.asp"
	Case 3
		MainDisplayFrame_URL = "./manage_reporting/reporting_default.asp"
	Case 4
		MainDisplayFrame_URL = "./manage_contacts/contact_default.asp"
	Case 5
		MainDisplayFrame_URL = "./manage_workflow/workflow_default.asp"
	Case 6
		MainDisplayFrame_URL = "./manage_products/product_default.asp"
	Case 10
		MainDisplayFrame_URL = "./manage_orders/order_default.asp"
	Case 11
		MainDisplayFrame_URL = "./manage_courses/courses_default.asp"
	Case 12
		MainDisplayFrame_URL = "./manage_customers/customer_default.asp"
	Case 13
		MainDisplayFrame_URL = "./manage_affiliates/affiliates_default.asp"
	Case 14
		MainDisplayFrame_URL = "./manage_certificates/certificates_default.asp"
	Case 15
		MainDisplayFrame_URL = "./manage_behindthewheel/behindthewheel_default.asp"
	Case 16
		MainDisplayFrame_URL = "./manage_promotions/promotions_default.asp"
	Case 20
		MainDisplayFrame_URL = "./manage_phonak_tacticalgrid/tacticalgrid_default.asp"
	Case Else
		MainDisplayFrame_URL = "./app_include/blank_cccccc.html"
End Select
%>
<html>
<head>
	<title>Website Admin Tool</title>
	<script language=javascript>
	<!--
		window.defaultStatus = "";
	//-->
	</script>
</head>
<frameset rows="25,1,*,1" border="0" topmargin=0 leftmargin=0 rightmargin=0 bottommargin=0 marginheight=0 marginwidth=0>
	<frame name="HeaderFrame" src="./app_header.asp" scrolling="no" noresize><!-- Header Navigation -->
	<frame name="blankmargin" src="./app_include/blank.html" scrolling="no" noresize>
	<frameset cols="100,1,*" border="0" topmargin=0 leftmargin=0 rightmargin=0 bottommargin=0 marginheight=0 marginwidth=0>
		<frame name="LeftNavFrame" src="app_left_nav.asp?tab=<%=selectedNavTab%>" scrolling="no" noresize><!-- Left-hand Navigation Menu -->
		<frame name="blankmargin" src="./app_include/blank.html" scrolling="no" noresize>
		<frame name="MainDisplayFrame" src="<%=MainDisplayFrame_URL%>" scrolling="no" noresize><!-- Main Display Area -->
	</frameset>
	<frame name="blankmargin" src="./app_include/blank.html" scrolling="no" noresize>
</frameset>
</html>
