<%@ Page Language="VB" AutoEventWireup="false" CodeFile="TestVendorLogin.aspx.vb" Inherits="TestVendorLogin" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
	<link rel="stylesheet" href="css/styles.css" type="text/css"/>

<head runat="server">
    <title>Test Vendor Login</title>
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE10" />
</head>
<body>
    <form id="form1" runat="server">
	<div id="logo"><a href="default.aspx"><img src="images/logo.png" border="0" alt="Home" /></a></div>
	<div id="search" >
		<img src="images/spedy_logo.gif" width="121" height="34" border="0" alt="" title="<%=VersionNo %>" />
	</div>
	<div class="spacer"></div>    
    <div style="text-align:center">
        <h3>Test SPEDY with Vendor ID</h3>
         <br />
        <h4>Enter Vendor Details</h4>
        <table width="40%" border="0" cellpadding="3px">
            <tr>
                <td align="right">Vendor ID:</td>
                <td align="left"><asp:TextBox ID="vendorID" runat="server"></asp:TextBox></td>
            </tr>
            <tr>
                <td align="right">Authentication Code:</td>
                <td align="left"><asp:TextBox ID="AuthCode" TextMode="password" runat="server"></asp:TextBox></td>
            </tr>
        </table>
        <asp:Button ID="btnlogin" runat="server" Text="Login" />
        <br />
        <br />
        <asp:Label ID="lblMessage" runat="server"></asp:Label>
    </div>
    </form>
</body>
</html>
