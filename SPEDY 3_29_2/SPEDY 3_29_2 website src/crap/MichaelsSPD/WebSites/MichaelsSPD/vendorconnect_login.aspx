<%@ page language="VB" autoeventwireup="false" CodeFile="vendorconnect_login.aspx.vb" Inherits="vendorconnect_login" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>Item Data Management</title>
	<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE10" />
    <meta name="author" content="Randy Cochran" />
    <link rel="stylesheet" href="css/styles.css" type="text/css" />
    <script type="text/javascript" src="include/global.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
</head>
<body>
    <form method="post" action="vendorconnect_login.aspx">
    <div id="sitediv">
	    <div id="bodydiv">
		    <div id="header">
			    <div class="spacer"></div>
			    <div id="logo"><img src="images/logo.png" border="0" alt="Home" /></div>
			    <div id="search">
				    &nbsp;
			    </div>
			    <div class="spacer"></div>
		    </div>
		    <div id="content">
			    <div id="shadowtop"></div>
			    <div id="main" style="text-align:center">
			        <p><asp:Label ID="lblMsg" runat="server" /></p>
			        <br />
			        <input type="button" id="close" onclick="javascript:window.close();return false;" value="Close Window" />
				    <!--<div id="login">
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
				    -->
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

