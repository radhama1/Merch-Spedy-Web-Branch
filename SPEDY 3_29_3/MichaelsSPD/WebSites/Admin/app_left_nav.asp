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
Dim selectedNavTab
Dim Security
Set Security = New cls_Security

Security.Initialize CLng(Session.Value("UserID")), "ADMIN", 0
'Response.Write "XMLSource: " & Server.HTMLEncode(Security.XMLSource) & "<br><br>"
'Security.saveXMLToFile "c:\Security_Out.xml"

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
			selectedNavTab = 1
		end if
	end if
end if

Dim requestedSecurityScope, requestedSecurityPrivilege
requestedSecurityScope = "ADMIN"
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
	Case 12
		requestedSecurityScope = "ADMIN.CUSTOMERS"
	Case 16
		requestedSecurityScope = "ADMIN.PROMOTIONS"
	Case 20
		requestedSecurityScope = "ADMIN.TACTICALGRID"
	Case 30
	    requestedSecurityScope = "ADMIN.SPEDY"
End Select

'Response.Write Security.isRequestedScopeAllowed("ADMIN") & "<br>"
'Response.Write Security.isRequestedPrivilegeAllowed("ADMIN", "ADMINACCESS") & "<br>"
if not Security.isRequestedScopeAllowed("ADMIN") or not Security.isRequestedPrivilegeAllowedWithinCurrentContext("ADMINACCESS") then
	Response.Redirect "./logout.asp"
end if
'Response.Write "Security.isRequestedScopeAllowed(" & requestedSecurityScope & "): " & Security.isRequestedScopeAllowed(requestedSecurityScope) & "<br>"
'Response.Write "Security.isRequestedPrivilegeAllowed(" & requestedSecurityScope & ", " & requestedSecurityPrivilege & "): " & Security.isRequestedPrivilegeAllowed(requestedSecurityScope, requestedSecurityPrivilege) & "<br>"
if not Security.isRequestedScopeAllowed(requestedSecurityScope) or not Security.isRequestedPrivilegeAllowed(requestedSecurityScope, requestedSecurityPrivilege) then
	selectedNavTab = -1
end if

'	Record the currently selected in the session.
'	This way, if the user hits F5 or 'Refresh', they will return 
'	to the same module they were previously working with.
Session.Value("SELECTED_MODULE") = selectedNavTab
Response.Cookies(Application.Value("ADMINTOOL_PERSISTENTSTATE_COOKIE_NAME"))("SELECTED_MODULE") = selectedNavTab
Response.Cookies(Application.Value("ADMINTOOL_PERSISTENTSTATE_COOKIE_NAME")).Expires = Date + 14

function writeTabImgSuffix(tabOrdinal)
	Dim strImgSuffix
	strImgSuffix = "_off"

	'pass the zero-based ordinal of the requested tab
	if IsNumeric(tabOrdinal) and not IsNull(tabOrdinal) and tabOrdinal <> "" then
		if CInt(selectedNavTab) = CInt(tabOrdinal) then
			strImgSuffix = "_on"
		end if
	end if

	writeTabImgSuffix = strImgSuffix
end function

function writeCornerGraphic()
	Dim strReturnVal
	strReturnVal = "cornergraphic_blank4.jpg"

	'pass the zero-based ordinal of the requested tab
	if IsNumeric(selectedNavTab) and not IsNull(selectedNavTab) and selectedNavTab <> "" then

		Select Case selectedNavTab
			Case 0
				strReturnVal = "cornergraphic_content.jpg"
			Case 1
				strReturnVal = "cornergraphic_security.jpg"
			Case 2
				strReturnVal = "cornergraphic_websites.jpg"
			Case 3
				strReturnVal = "cornergraphic_reporting.jpg"
			Case 4
				strReturnVal = "cornergraphic_contacts2.jpg"
			Case 5
				strReturnVal = "cornergraphic_workflow2.jpg"
			Case 6
				strReturnVal = "cornergraphic_products5.jpg"
			Case 10
				strReturnVal = "cornergraphic_orders.jpg"
			Case 11
				strReturnVal = "cornergraphic_courses.jpg"
			Case 12
				strReturnVal = "cornergraphic_customers.jpg"
			Case 16
				strReturnVal = "cornergraphic_promotions.jpg"
			Case 20
				strReturnVal = "cornergraphic_blank4.jpg"
		    Case 30
		        strReturnVal = "cornergraphic_spedy.jpg"
		End Select

	end if

	writeCornerGraphic = strReturnVal
end function
%>
<html>
<head>
	<title></title>
	<style type="text/css">
	<!--
		A {text-decoration: none; cursor: hand;}
		A:HOVER {text-decoration: underline; cursor: hand;}
		BODY
		{
			cursor: default;
		}
		.navBtn
		{
			cursor: hand;
		}
	//-->
	</style>
	<script language=javascript>
	<!--
		preloadImgs();
		function preloadImgs()
		{
			if (document.images)
			{		

				contentBtn_ImgOn = new Image(100, 15);
				contentBtn_ImgOff = new Image(100, 15);
				securityBtn_ImgOn = new Image(100, 15);
				securityBtn_ImgOff = new Image(100, 15);
				sitesBtn_ImgOn = new Image(100, 15);
				sitesBtn_ImgOff = new Image(100, 15);
				reportBtn_ImgOn = new Image(100, 15);
				reportBtn_ImgOff = new Image(100, 15);
				contactBtn_ImgOn = new Image(100, 15);
				contactBtn_ImgOff = new Image(100, 15);
				workflowBtn_ImgOn = new Image(100, 15);
				workflowBtn_ImgOff = new Image(100, 15);
				productsBtn_ImgOn = new Image(100, 15);
				productsBtn_ImgOff = new Image(100, 15);
				ordersBtn_ImgOn = new Image(100, 15);
				ordersBtn_ImgOff = new Image(100, 15);
				customersBtn_ImgOn = new Image(100, 15);
				customersBtn_ImgOff = new Image(100, 15);
				promotionsBtn_ImgOn = new Image(100, 15);
				promotionsBtn_ImgOff = new Image(100, 15);
				gridBtn_ImgOn = new Image(100, 15);
				gridBtn_ImgOff = new Image(100, 15);
				spedyBtn_ImgOn = new Image(100, 15);
				spedyBtn_ImgOff = new Image(100, 15);

				contentBtn_ImgOn.src = "./app_images/navbtn_content_on.gif";
				contentBtn_ImgOff.src = "./app_images/navbtn_content_off.gif";
				securityBtn_ImgOn.src = "./app_images/navbtn_security_on.gif";
				securityBtn_ImgOff.src = "./app_images/navbtn_security_off.gif";
				sitesBtn_ImgOn.src = "./app_images/navbtn_websites_on.gif";
				sitesBtn_ImgOff.src = "./app_images/navbtn_websites_off.gif";
				reportBtn_ImgOn.src = "./app_images/navbtn_reporting_on.gif";
				reportBtn_ImgOff.src = "./app_images/navbtn_reporting_off.gif";
				contactBtn_ImgOn.src = "./app_images/navbtn_contacts_on.gif";
				contactBtn_ImgOff.src = "./app_images/navbtn_contacts_off.gif";
				workflowBtn_ImgOn.src = "./app_images/navbtn_workflow_on.gif";
				workflowBtn_ImgOff.src = "./app_images/navbtn_workflow_off.gif";
				productsBtn_ImgOn.src = "./app_images/navbtn_products_on.gif";
				productsBtn_ImgOff.src = "./app_images/navbtn_products_off.gif";
				ordersBtn_ImgOn.src = "./app_images/navbtn_orders_on.gif";
				ordersBtn_ImgOff.src = "./app_images/navbtn_orders_off.gif";
				customersBtn_ImgOn.src = "./app_images/navbtn_customer_on.gif";
				customersBtn_ImgOff.src = "./app_images/navbtn_customer_off.gif";
				promotionsBtn_ImgOn.src = "./app_images/navbtn_promotions_on.gif";
				promotionsBtn_ImgOff.src = "./app_images/navbtn_promotions_off.gif";
				gridBtn_ImgOn.src = "./app_images/navbtn_grid_on.gif";
				gridBtn_ImgOff.src = "./app_images/navbtn_grid_off.gif";
				spedyBtn_ImgOn.src = "./app_images/navbtn_spedy_on.gif";
				spedyBtn_ImgOff.src = "./app_images/navbtn_spedy_off.gif";

				contentBtn_CornerGraphic = new Image(100, 100);
				securityBtn_CornerGraphic = new Image(100, 100);
				sitesBtn_CornerGraphic = new Image(100, 100);
				reportBtn_CornerGraphic = new Image(100, 100);
				contactBtn_CornerGraphic = new Image(100, 100);
				workflowBtn_CornerGraphic = new Image(100, 100);
				productsBtn_CornerGraphic = new Image(100, 100);
				ordersBtn_CornerGraphic = new Image(100, 100);
				customersBtn_CornerGraphic = new Image(100, 100);
				promotionsBtn_CornerGraphic = new Image(100, 100);
				gridBtn_CornerGraphic = new Image(100, 100);
				spedyBtn_CornerGraphic = new Image(100, 100);
				
				contentBtn_CornerGraphic.src = "./app_images/cornergraphic_content.jpg";
				securityBtn_CornerGraphic.src = "./app_images/cornergraphic_security.jpg";
				sitesBtn_CornerGraphic.src = "./app_images/cornergraphic_websites.jpg";
				reportBtn_CornerGraphic.src = "./app_images/cornergraphic_reporting.jpg";
				contactBtn_CornerGraphic.src = "./app_images/cornergraphic_contacts2.jpg";
				workflowBtn_CornerGraphic.src = "./app_images/cornergraphic_workflow2.jpg";
				productsBtn_CornerGraphic.src = "./app_images/cornergraphic_products5.jpg";
				ordersBtn_CornerGraphic.src = "./app_images/cornergraphic_orders.jpg";
				customersBtn_CornerGraphic.src = "./app_images/cornergraphic_customers.jpg";
				promotionsBtn_CornerGraphic.src = "./app_images/cornergraphic_promotions.jpg";
				gridBtn_CornerGraphic.src = "./app_images/cornergraphic_blank4.jpg";
				spedyBtn_CornerGraphic.src = "./app_images/cornergraphic_spedy.jpg";
				
				selected_CornerGraphic = new Image(100, 100);
				selected_CornerGraphic.src = "./app_images/<%=writeCornerGraphic%>";
			}
		}
		
		function highlightNavBtn(imgName, boolOn)
		{
			if (document.images) 
			{
				if (boolOn)
				{
					document.images[imgName].src = eval(imgName + "_ImgOn.src");
				}
				else
				{
					document.images[imgName].src = eval(imgName + "_ImgOff.src");
				}
				
				swapCornerGraphic(imgName, boolOn)
			}
		}

		function swapCornerGraphic(imgName, boolOn)
		{
			if (document.images) 
			{
				if (boolOn)
				{
					document.images['cornerGraphic'].src = eval(imgName + "_CornerGraphic.src");
				}
				else
				{
					document.images['cornerGraphic'].src = selected_CornerGraphic.src;
				}
				document.images['cornerGraphic'].focus();
				document.images['cornerGraphic'].blur();
			}
		}
		
		function clickMenu(srcBtn)
		{			
			switch (srcBtn)
			{
				case "contentBtn":
					parent.frames["MainDisplayFrame"].document.location = "./manage_repository/content_default.asp";
					document.location = "app_left_nav.asp?tab=0";
					break;
				
				case "securityBtn":
					parent.frames["MainDisplayFrame"].document.location = "./manage_security/security_default.asp";
					document.location = "app_left_nav.asp?tab=1";
					break;
				
				case "sitesBtn":
					parent.frames["MainDisplayFrame"].document.location = "./manage_websites/website_default.asp";
					document.location = "app_left_nav.asp?tab=2";
					break;
				
				case "reportBtn":
					parent.frames["MainDisplayFrame"].document.location = "./manage_reporting/reporting_default.asp";
					document.location = "app_left_nav.asp?tab=3";
					break;
				
				case "contactBtn":
					parent.frames["MainDisplayFrame"].document.location = "./manage_contacts/contact_default.asp";
					document.location = "app_left_nav.asp?tab=4";
					break;
				
				case "workflowBtn":
					parent.frames["MainDisplayFrame"].document.location = "./manage_workflow/workflow_default.asp";
					document.location = "app_left_nav.asp?tab=5";
					break;
				
				case "productsBtn":
					parent.frames["MainDisplayFrame"].document.location = "./manage_products/product_default.asp";
					document.location = "app_left_nav.asp?tab=6";
					break;
				
				case "ordersBtn":
					parent.frames["MainDisplayFrame"].document.location = "./manage_orders/order_default.asp";
					document.location = "app_left_nav.asp?tab=10";
					break;
				
				case "customersBtn":
					parent.frames["MainDisplayFrame"].document.location = "./manage_customers/customer_default.asp";
					document.location = "app_left_nav.asp?tab=12";
					break;

				case "promotionsBtn":
					parent.frames["MainDisplayFrame"].document.location = "./manage_promotions/promotions_default.asp";
					document.location = "app_left_nav.asp?tab=16";
					break;
				
				case "suppfilesBtn":
					parent.frames["MainDisplayFrame"].document.location = "./manage_suppfiles/files_default.asp";
					document.location = "app_left_nav.asp?tab=7";
					break;
				
				case "gridBtn":
					parent.frames["MainDisplayFrame"].document.location = "./manage_phonak_tacticalgrid/tacticalgrid_default.asp";
					document.location = "app_left_nav.asp?tab=20";
					break;
					
		        case "spedyBtn":
					parent.frames["MainDisplayFrame"].document.location = "./manage_spedy/spedy_default.asp";
					document.location = "app_left_nav.asp?tab=30";
					break;
				
				default:
					parent.frames["MainDisplayFrame"].document.location = "./app_include/blank_cccccc.html";
					document.location = "app_left_nav.asp?tab=0";
					break;
			}
		}
	//-->
	</script>
</head>
<body bgcolor="cccccc" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>

<table width=100 cellpadding=0 cellspacing=0 border=0>
	<tr><td><img name="cornerGraphic" id="cornerGraphic" src="./app_images/<%=writeCornerGraphic%>" height=100 width=100 border=0></td></tr>
	<tr bgcolor=ffffff><td><img src="./app_images/spacer.gif" height=1 width=100 border=0></td></tr>
	<tr>
		<td valign=top>
			<table width=100% cellpadding=0 cellspacing=0 border=0>
				<%if Security.isRequestedPrivilegeAllowed("ADMIN.CONTENT", requestedSecurityPrivilege) and 1 = 1 then%>
				<tr><td><a href="./manage_repository/content_default.asp" target="_top" onClick="javascript: clickMenu('contentBtn'); return false;"><img name="navBtn" class="navBtn" id="contentBtn" src="./app_images/navbtn_content<%=writeTabImgSuffix(0)%>.gif" height="15" width="100" border="0"<%if selectedNavTab <> 0 then%> onMouseOver="highlightNavBtn('contentBtn', true); window.status='';return true;" onMouseOut="highlightNavBtn('contentBtn', false); window.status='';return true;"<%else%> onMouseOver="window.status='';return true;" onMouseOut="window.status='';return true;"<%end if%>></a></td></tr>
				<tr bgcolor=ffffff><td><img src="./app_images/spacer.gif" height=1 width=100 border=0></td></tr>
				<%end if%>
				<%if Security.isRequestedPrivilegeAllowed("ADMIN.WEBSITES", requestedSecurityPrivilege) and 1 = 1 then%>
				<tr><td><a href="./manage_websites/website_default.asp" target="_top" onClick="javascript: clickMenu('sitesBtn'); return false;"><img name="navBtn" class="navBtn" id="sitesBtn" src="./app_images/navbtn_websites<%=writeTabImgSuffix(2)%>.gif" height="15" width="100" border="0"<%if selectedNavTab <> 2 then%> onMouseOver="highlightNavBtn('sitesBtn', true); window.status='';return true;" onMouseOut="highlightNavBtn('sitesBtn', false); window.status='';return true;"<%else%> onMouseOver="window.status='';return true;" onMouseOut="window.status='';return true;"<%end if%>></a></td></tr>
				<tr bgcolor=ffffff><td><img src="./app_images/spacer.gif" height=1 width=100 border=0></td></tr>
				<%end if%>
				<%if Security.isRequestedPrivilegeAllowed("ADMIN.PRODUCT", requestedSecurityPrivilege) and 1 = 2 then%>
				<tr><td><a href="./manage_products/product_default.asp" target="_top" onClick="javascript: clickMenu('productsBtn'); return false;"><img name="navBtn" class="navBtn" id="productsBtn" src="./app_images/navbtn_products<%=writeTabImgSuffix(6)%>.gif" height="15" width="100" border="0"<%if selectedNavTab <> 6 then%> onMouseOver="highlightNavBtn('productsBtn', true); window.status='';return true;" onMouseOut="highlightNavBtn('productsBtn', false); window.status='';return true;"<%else%> onMouseOver="window.status='';return true;" onMouseOut="window.status='';return true;"<%end if%>></a></td></tr>
				<tr bgcolor=ffffff><td><img src="./app_images/spacer.gif" height=1 width=100 border=0></td></tr>
				<%end if%>
				<%if Security.isRequestedPrivilegeAllowed("ADMIN.ORDER", requestedSecurityPrivilege) and 1 = 2 then%>
				<tr><td><a href="./manage_orders/order_default.asp" target="_top" onClick="javascript: clickMenu('ordersBtn'); return false;"><img name="navBtn" class="navBtn" id="ordersBtn" src="./app_images/navbtn_orders<%=writeTabImgSuffix(10)%>.gif" height="15" width="100" border="0"<%if selectedNavTab <> 10 then%> onMouseOver="highlightNavBtn('ordersBtn', true); window.status='';return true;" onMouseOut="highlightNavBtn('ordersBtn', false); window.status='';return true;"<%else%> onMouseOver="window.status='';return true;" onMouseOut="window.status='';return true;"<%end if%>></a></td></tr>
				<tr bgcolor=ffffff><td><img src="./app_images/spacer.gif" height=1 width=100 border=0></td></tr>
				<%end if%>
				<%if Security.isRequestedPrivilegeAllowed("ADMIN.CUSTOMERS", requestedSecurityPrivilege) and 1 = 2 then%>
				<tr><td><a href="./manage_customers/customer_default.asp" target="_top" onClick="javascript: clickMenu('customersBtn'); return false;"><img name="navBtn" class="navBtn" id="customersBtn" src="./app_images/navbtn_customer<%=writeTabImgSuffix(12)%>.gif" height="15" width="100" border="0"<%if selectedNavTab <> 12 then%> onMouseOver="highlightNavBtn('customersBtn', true); window.status='';return true;" onMouseOut="highlightNavBtn('customersBtn', false); window.status='';return true;"<%else%> onMouseOver="window.status='';return true;" onMouseOut="window.status='';return true;"<%end if%>></a></td></tr>
				<tr bgcolor=ffffff><td><img src="./app_images/spacer.gif" height=1 width=100 border=0></td></tr>
				<%end if%>
				<%if Security.isRequestedPrivilegeAllowed("ADMIN.SECURITY", requestedSecurityPrivilege) then%>
				<tr><td><a href="./manage_security/security_default.asp" target="_top" onClick="javascript: clickMenu('securityBtn'); return false;"><img name="navBtn" class="navBtn" id="securityBtn" src="./app_images/navbtn_security<%=writeTabImgSuffix(1)%>.gif" height="15" width="100" border="0"<%if selectedNavTab <> 1 then%> onMouseOver="highlightNavBtn('securityBtn', true); window.status='';return true;" onMouseOut="highlightNavBtn('securityBtn', false); window.status='';return true;"<%else%> onMouseOver="window.status='';return true;" onMouseOut="window.status='';return true;"<%end if%>></a></td></tr>
				<tr bgcolor=ffffff><td><img src="./app_images/spacer.gif" height=1 width=100 border=0></td></tr>
				<%end if%>
				<%if Security.isRequestedPrivilegeAllowed("ADMIN.CONTACT", requestedSecurityPrivilege) and 1 = 2 then%>
				<tr><td><a href="./manage_contacts/contact_default.asp" target="_top" onClick="javascript: clickMenu('contactBtn'); return false;"><img name="navBtn" class="navBtn" id="contactBtn" src="./app_images/navbtn_contacts<%=writeTabImgSuffix(4)%>.gif" height="15" width="100" border="0"<%if selectedNavTab <> 4 then%> onMouseOver="highlightNavBtn('contactBtn', true); window.status='';return true;" onMouseOut="highlightNavBtn('contactBtn', false); window.status='';return true;"<%else%> onMouseOver="window.status='';return true;" onMouseOut="window.status='';return true;"<%end if%>></a></td></tr>
				<tr bgcolor=ffffff><td><img src="./app_images/spacer.gif" height=1 width=100 border=0></td></tr>
				<%end if%>
				<%if Security.isRequestedPrivilegeAllowed("ADMIN.REPORTING", requestedSecurityPrivilege) and 1 = 2 then%>
				<tr><td><a href="./manage_reporting/reporting_default.asp" target="_top" onClick="javascript: clickMenu('reportBtn'); return false;"><img name="navBtn" class="navBtn" id="reportBtn" src="./app_images/navbtn_reporting<%=writeTabImgSuffix(3)%>.gif" height="15" width="100" border="0"<%if selectedNavTab <> 3 then%> onMouseOver="highlightNavBtn('reportBtn', true); window.status='';return true;" onMouseOut="highlightNavBtn('reportBtn', false); window.status='';return true;"<%else%> onMouseOver="window.status='';return true;" onMouseOut="window.status='';return true;"<%end if%>></a></td></tr>
				<tr bgcolor=ffffff><td><img src="./app_images/spacer.gif" height=1 width=100 border=0></td></tr>
				<%end if%>
				<%if Security.isRequestedPrivilegeAllowed("ADMIN.SPEDY", requestedSecurityPrivilege) then%>
				<tr><td><a href="./manage_spedy/spedy_default.asp" target="_top" onClick="javascript: clickMenu('spedyBtn'); return false;"><img name="navBtn" class="navBtn" id="spedyBtn" src="./app_images/navbtn_spedy<%=writeTabImgSuffix(30)%>.gif" height="15" width="100" border="0"<%if selectedNavTab <> 30 then%> onMouseOver="highlightNavBtn('spedyBtn', true); window.status='';return true;" onMouseOut="highlightNavBtn('spedyBtn', false); window.status='';return true;"<%else%> onMouseOver="window.status='';return true;" onMouseOut="window.status='';return true;"<%end if%>></a></td></tr>
				<tr bgcolor=ffffff><td><img src="./app_images/spacer.gif" height=1 width=100 border=0></td></tr>
				<%end if%>
			</table>
		</td>
	</tr>
</table>

</body>
</html>
<%
Security.Clear()
%>