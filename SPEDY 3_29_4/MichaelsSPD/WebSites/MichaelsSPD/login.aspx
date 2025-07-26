<%@ page language="VB" autoeventwireup="false" CodeFile="login.aspx.vb" inherits="login" aspcompat="true" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%
    Dim objConn, objRS, connStr, strSQL, loginError, LOGON_USER
    loginError = ""
    LOGON_USER = Request.ServerVariables("LOGON_USER")
    If InStr(LOGON_USER, "\") > 0 Then
        LOGON_USER = Right(LOGON_USER, Len(LOGON_USER) - InStr(LOGON_USER, "\"))
    End If
    If (LOGON_USER <> "") Or LCase(LOGON_USER) = "novadmin" Or LCase(LOGON_USER) = "ebenezej" Or LCase(LOGON_USER) = "wallacja" Then

        'connStr = "Driver={SQL Server};Server=localhost;UID=spd;PWD=Spd!21408!;Database=MichaelsSPD;"
        connStr = ConfigurationManager.ConnectionStrings("ClassicASPAppConnection").ConnectionString
        If Right(connStr, 1) <> ";" Then
            connStr = connStr + ";"
        End If
        objConn = Server.CreateObject("ADODB.Connection")
        objRS = Server.CreateObject("ADODB.RecordSet")
        objConn.Open(connStr)
        strSQL = "select * from security_user where username='" & LOGON_USER & "' and enabled=1"

        objRS.Open(strSQL, objConn)

        If Not objRS.eof Then
            Session("UserID") = CType(objRS("id").value, Integer)
            Session("Email_Address") = objRS("Email_Address").value
            Session("UserName") = objRS("UserName").value
            Session("Last_name") = objRS("Last_name").value
            Session("First_Name") = objRS("First_Name").value
            Session("Organization") = objRS("Organization").value
            objRS.close()
            strSQL = "select sortorder from security_user_group, security_group where security_user_group.group_id=security_group.id and [user_id]=" & Session("UserID")
            objRS.Open(strSQL, objConn)
            While Not objRS.eof
                Session("UserRole") = Session("UserRole") & objRS("sortorder").value & ","
                objRS.movenext()
            End While
            objRS.close()

            strSQL = "select sortorder from security_user_privilege, security_privilege where security_user_privilege.privilege_id=security_privilege.id and [user_id]=" & Session("UserID")
            objRS.Open(strSQL, objConn)
            While Not objRS.eof
                Session("UserDept") = Session("UserDept") & objRS("sortorder").value & ","
                objRS.movenext()
            End While
            objRS.close()
            objRS = Nothing
            objConn = Nothing
            Response.Redirect("default.aspx")
        Else
            objRS.close()
            objRS = Nothing
            objConn = Nothing
            loginError = "Invalid Username or Password"
        End If
    End If
    'process login from form
    If Request.Form("username") <> "" And Request.Form("password") <> "" Then
        connStr = ConfigurationManager.ConnectionStrings("ClassicASPAppConnection").ConnectionString
        objConn = Server.CreateObject("ADODB.Connection")
        objRS = Server.CreateObject("ADODB.RecordSet")
        objConn.Open(connStr)

        Dim safeName As String = Request.Form("username")
        Dim safePass As String = Request.Form("password")
        safeName = Left(safeName, 200)
        safeName = Replace(safeName, "'", "''")
        safePass = Left(safePass, 200)
        safePass = Replace(safePass, "'", "''")
        strSQL = "select * from security_user where username = '" & safeName & "' and password = '" & safePass & "' and enabled=1"
        objRS.Open(strSQL, objConn)
        If Not objRS.eof Then
            Session("UserID") = CType(objRS("id").value, Integer)
            Session("Email_Address") = objRS("Email_Address").value
            Session("UserName") = objRS("UserName").value
            Session("Last_name") = objRS("Last_name").value
            Session("First_Name") = objRS("First_Name").value
            Session("Organization") = objRS("Organization").value
            objRS.close()
            strSQL = "select sortorder from security_user_group, security_group where security_user_group.group_id=security_group.id and [user_id]=" & Session("UserID")
            objRS.Open(strSQL, objConn)
            While Not objRS.eof
                Session("UserRole") = Session("UserRole") & objRS("sortorder").value & ","
                objRS.movenext()
            End While
            objRS.close()

            strSQL = "select sortorder from security_user_privilege, security_privilege where security_user_privilege.privilege_id=security_privilege.id and [user_id]=" & Session("UserID")
            objRS.Open(strSQL, objConn)
            While Not objRS.eof
                Session("UserDept") = Session("UserDept") & objRS("sortorder").value & ","
                objRS.movenext()
            End While
            objRS.close()
            objRS = Nothing
            objConn = Nothing
            Response.Redirect("default.aspx")
        Else
            objRS.close()
            objRS = Nothing
            objConn = Nothing
            loginError = "Invalid Username or Password"
        End If
    End If

    Session.Abandon
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
	<title>Item Data Management</title>
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE10" />
	<meta name="author" content="Randy Cochran">
	<link rel="stylesheet" href="css/styles.css" type="text/css">
	<script type="text/javascript" src="include/global.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
    <script language="javascript" type="text/javascript" src="js/prototype.js"></script>
    <script language="javascript" type="text/javascript" src="js/scriptaculous.js"></script>
<style type="text/css">
#content {
    background-color: #fff !important;
}
.headerbar {
    background-color: #cf202f !important;
    height: 10px;
    width: 100%;
}
#login-main {
    padding: 0;
    text-align: left;
    width: 350px;
    margin: 0 auto;
    margin-bottom: 100px;
    margin-top: 50px;
    background: #FCFCFC;
	border: solid #E3E3E3 1px;
	box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
	-webkit-box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
	-moz-box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
}
#login-main #login-content {
    padding: 25px 25px 25px 25px;
    width: 350px;
}
#login-main h1.title {
    background-color: #cf202f !important;
    border-bottom: 1px solid #ae1522;
    color: #ffffff;
    padding: 15px 8px;
    text-align: center;
    font-style: italic;
}
#login-main .row {
    width: 250px !important;
    padding: 4px 15px;
}
#login-main .col {
    width: 250px !important;
}
#login-main label {
    font-size: 16px;
    font-weight: bolder;
    width: 100%;
}
#login-main input[type="text"], #login-main input[type="password"] {
    display: block;
    font-size: 14px;
    font-weight: 700;
    height: 28px;
    margin-bottom: 15px;
    padding: 2px 8px !important;
    width: 100%;
}
#login-main input[type="button"], #login-main input[type="submit"] {
    background-color: #d81230;
    border: 1px solid #820619 !important;
    color: #ffffff;
    font-size: 18px;
    font-weight: 700;
    padding: 4px 30px;
    height: 32px;
    border-radius: 5px;
}
#login-main input[type="button"]:hover, #login-main input[type="submit"]:hover {
    background-color: #820619;
}
#footer {
    position: absolute;
    bottom: 0;
    width: 100%;
}
#bodydiv {
    border-bottom: none !important;
}
</style>
</head>
<body>
    <form method="post" action="login.aspx">
	<div id="loginpage">
		<div id="bodydiv">
			<div id="header">
				<div class="spacer"></div>
				
                <div id="logo" class="header-logo" style="padding: 10px 0 0 17px;">
				    <a href="default.aspx"><img src="images/logo-big.png" border="0" alt="Home" width="187" height="73" /></a>
			    </div>
				<div id="search">
					&nbsp;
				</div>
				<div class="spacer"></div>
			</div>
            <div class="headerbar"></div>
			<div id="content">
				<div id="login-main">
                    <div>
                        <div><h1 class="title">User Login</h1></div>
                    </div>
                    <div id="login-content">
                        <div class="row"><div class="col"><asp:Label ID="loginError" runat="server"></asp:Label><CENTER><FONT COLOR="DD0000"><B><%=loginError%></B></FONT></CENTER></div></div>
                        <div class="row">
                            <div class="col"><label id="usernameLabel" for="username">Username</label></div>
                        </div>
                        <div class="row">
                            <div class="col">
                                <input type="text" id="username" name="username" maxlength="25" value="<%=request("username")%>" />
                            </div>
                        </div>
                        <div class="row">
                            <div class="col"><label id="passwordLabel" for="password">Password</label></div>
                        </div>
                        <div class="row">
                            <div class="col">
                                <input type="password" id="password" name="password" maxlength="25" autocomplete="off"  />
                            </div>
                        </div>
                        
                        <div class="row">
                            <div class="col">
                                <input type="submit" title="LOGIN" value="LOGIN" />
                            </div>
                        </div>
                    </div>
				</div>
				<div></div>
			</div>
			<div id="footer">
				&nbsp;
			</div>
		</div>
	</div>
	<script language="javascript" type="text/javascript">
	<!--
	<% If Not Page.IsPostBack Then %>
	function selectUsername() {
	    if($('username')) {
	        $('username').focus();
	        $('username').select();
	    }
	}
	selectUsername();
	<% End If %>
	//-->
	</script>
    </form>
</body>
</html>
