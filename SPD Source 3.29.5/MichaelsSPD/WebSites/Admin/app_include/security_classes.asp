<% 
'==============================================================================
' Security Classes
'==============================================================================
%>
<!--#include file="./security_cls_security.asp"-->
<!--#include file="./security_cls_security_group.asp"-->
<!--#include file="./security_cls_security_group_privilege.asp"-->
<!--#include file="./security_cls_security_privilege.asp"-->
<!--#include file="./security_cls_security_privileges.asp"-->
<!--#include file="./security_cls_security_privileged_object.asp"-->
<!--#include file="./security_cls_security_privileged_objects.asp"-->
<!--#include file="./security_cls_security_scope.asp"-->
<!--#include file="./security_cls_security_user.asp"-->
<!--#include file="./security_cls_security_user_group.asp"-->
<!--#include file="./security_cls_security_user_privilege.asp"-->
<!--#include file="./security_cls_security_utilitylibrary.asp"-->
<%
'==============================================================================
'==============================================================================
'
'	Example Usage:
'
'==============================================================================
'==============================================================================
'	Dim Security
'	Set Security = New cls_Security
'
'	Security.Initialize Session.Value("UserID"), "", 0
'	Security.saveXMLToFile "E:\internet\DriversEdDirect_Dev_Admin\Security_Out.xml"

'==============================================================================
'==============================================================================
'
'	Test Code
'
'==============================================================================
'==============================================================================
if 1 = 2 then
	Dim testSecurityObj, testgroup
	Set testSecurityObj = New cls_Security

	testSecurityObj.Initialize 2, "", 0
	testSecurityObj.saveXMLToFile "E:\internet\DriversEdDirect_Dev_Admin\Security_Out.xml"
%>
<style type="text/css">
.testCode
{
	margin-top: 20px;
}
</style>
<dl>
	<dt class="testCode">XML</dt>
		<dd>
			<div style="width:500px; height: 100px; clip: auto; overflow: auto; border: 1px dashed #ccc; padding: 10px;">
			<%=Server.HTMLEncode(Replace(testSecurityObj.XMLObject.xml, vbCrLf, ""))%>
			</div>
		</dd>
	<dt class="testCode">isRequestedPrivilegeAllowed</dt><dd><%=testSecurityObj.isRequestedPrivilegeAllowed("ADMIN", "ADMINACCESS")%></dd>
	<dt class="testCode">isRequestedScopeAllowed</dt><dd><%=testSecurityObj.isRequestedScopeAllowed("ADMIN.CONTACT")%></dd>
	<dt class="testCode">isRequestedAccessToObjectAllowed</dt><dd><%=testSecurityObj.isRequestedAccessToObjectAllowed("ADMIN.CUSTOMERS", "ADMINACCESS.MODULEACCESS", "468")%></dd>
	<dt class="testCode">testSecurityObj.Groups.Items</dt>
		<dd>
		<%
			for each testgroup in testSecurityObj.Groups.Items
				Response.Write "<p>" & testgroup.ID & ": " & testgroup.Group_Name
			next
		%>
		</dd>
</dl>
<%
end if
%>