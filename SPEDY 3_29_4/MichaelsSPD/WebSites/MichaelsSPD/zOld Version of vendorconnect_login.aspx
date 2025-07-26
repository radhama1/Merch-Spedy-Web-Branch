<%@ page language="VB" autoeventwireup="false" aspcompat="true" %>
    <!--#INCLUDE FILE="include/adovbs.inc"-->
<%
dim objConn, objRS, connStr, strSQL, loginError, LOGON_USER, vendorId, company, userId
'process login from form

'dim item
'for each item in request.form
'	response.write(item & ": " & request(item) & "<br>")
'next
'response.end
vendorId=request.form("vendorId")
if vendorId="TEST01" then
	vendorId="61153" 
	company="LI & FUNG / 4KIDS CO. MFG LT"
end if
userId=request.form("userId")

if userId="" then
	userId=request.form("email")		'	"undefined"
end if
if instr(vendorId, ",") then
	vendorId=left(vendorId, instr(vendorId, ",")-1)
end if
'response.write(vendorId)
'response.end
if userId<>"" and isnumeric(vendorId) then
	connStr = "Provider=sqloledb;" & ConfigurationManager.ConnectionStrings("AppConnection").ConnectionString & ";"
	objConn = Server.CreateObject("ADODB.Connection")
	objRS = Server.CreateObject("ADODB.RecordSet")
	objConn.Open(connStr)

	strSQL = "select * from spd_vendor where vendor_number=" & vendorId
	objRS.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
	if not objRS.eof then
		company=objRS("vendor_name").value
	else
		company="undefined"
	end if
	objRS.close
	strSQL = "select * from security_user where username='" & userId & "_" & vendorId & "' and enabled=1"
	objRS.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
	if not objRS.eof then
'vendorId: TEST01
'userId: SPEDY_1@aplaceonthenet.com
'mySessionId: 1207850424873_5770214461453577
'email: SPEDY_1@aplaceonthenet.com
'company: TEST01
'phone: 123-123-1234
'lastname: User
'firstname: Test
		Session("UserID") = CType(objRS("ID").value, Integer)
		session("Email_Address")=objRS("Email_Address").value
		session("UserName")=left(objRS("UserName").value, instrrev(objRS("UserName").value, "_")-1)
		session("vendorId")=right(objRS("UserName").value, len(objRS("UserName").value)-instrrev(objRS("UserName").value, "_"))
		session("Last_name")=objRS("Last_name").value
		session("First_Name")=objRS("First_Name").value
		session("Organization")=objRS("Organization").value
	else
		objRS.addnew
		objRS("Email_Address").value=request.form("email")
		objRS("UserName").value=userId & "_" & vendorId
		objRS("Last_name").value=request.form("lastname")
		objRS("First_Name").value=request.form("firstname")
		objRS("Organization").value=company
		objRS("office_location").value=request.form("phone")
		objRS.update
		objRS.requery
		Session("UserID") = CType(objRS("ID").value, Integer)
		session("Email_Address")=objRS("Email_Address").value
		session("UserName")=left(objRS("UserName").value, instr(objRS("UserName").value, "_"))
		session("vendorId")=right(objRS("UserName").value, len(objRS("UserName").value)-instrrev(objRS("UserName").value, "_"))
		session("Last_name")=objRS("Last_name").value
		session("First_Name")=objRS("First_Name").value
		session("Organization")=objRS("Organization").value
	end if
	objRS.close
	objRS = nothing
	objConn = nothing
	response.redirect("default.aspx")
end if

'process hardcoded password
    'if request.form("username")="admin" and request.form("password")="spedy" then
    '	session("UserID")=2
    '	session("Email_Address")="tom@novalibra.com"
    '	session("UserName")="TGREENHAW"
    '	session("Last_name")="User"
    '	session("First_Name")="Test"
    '	session("Organization")="Nova Libra"
    '	response.redirect("default.aspx")
    'end if
'dim item1
'response.write("Session Contents:<BR>")
'for each item1 in session.contents
'	response.write(item1 & ": " & session(item1).tostring()  & "<BR>")
'next 
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
	<title>Item Data Management</title>
	<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE10" />
	<meta name="author" content="Randy Cochran" />
	<link rel="stylesheet" href="css/styles.css" type="text/css" />
	<script type="text/javascript" src="include/global.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
</head>
<body>
<%
'dim item
'response.write("Request Contents:<BR>")
'for each item in request.form
'	response.write(item & ": " & request.form(item).tostring()  & "<BR>")
'next 

%>
    <form method="post" action="vendorconnect_login.aspx">
	<div id="sitediv">
		<div id="bodydiv">
			<div id="header">
				<div class="spacer"></div>
				<div id="logo"><img src="images/logo.gif" width="125" height="41" border="0" alt="Home" /></div>
				<div id="search">
					&nbsp;
				</div>
				<div class="spacer"></div>
			</div>
			<div id="content">
				<div id="shadowtop"></div>
				<div id="main" style="text-align:center">
					<div id="login">
						<div id="logincontent">
								<asp:Label ID="loginError" runat="server"></asp:Label><CENTER><FONT COLOR="DD0000"><B><%=loginError%></B></FONT></CENTER>
								<table cellpadding="5" cellspacing="0" border="0">
									<tr>
										<td align="right">&nbsp;</td>
										<td align="center"><img src="images/hdr_user_login.gif" width="91" height="18" border="0" alt="User Login" /></td>
									</tr>
									<tr>
										<td align="right"><img src="images/hdr_username.gif" width="66" height="10" border="0" alt="Username" /></td>
										<td align="left"><input type="text" name="username" maxlength="25" value="<%=request("username")%>" /></td>
									</tr>
									<tr>
										<td align="right"><img src="images/hdr_password.gif" width="61" height="10" border="0" alt="Password" /></td>
										<td align="left"><input type="password" name="password" maxlength="25" /></td>
									</tr>
									<tr>
										<td align="right">&nbsp;</td>
										<td align="center"><input type="image" src="images/btn_login.gif" width="46" height="16" border="0" alt="LOGIN" value="submit" /></td>
									</tr>
								</table>
						</div>
					</div>
				</div>
				<div id="shadowbottom"></div>
			</div>
			<div id="footer">
				&nbsp;
			</div>
		</div>
	</div>
    </form>
</body>
</html>
