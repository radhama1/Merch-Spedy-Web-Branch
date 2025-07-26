<%@ Page Language="VB" AutoEventWireup="false" CodeFile="Default.aspx.vb" Inherits="_Default" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE10" />
    <meta http-equiv="expires" content="Wed, 19 Feb 2003 08:00:00 GMT" />
    <meta http-equiv="pragma" content="no-cache" />
    <title>Item Data Management: Search</title>
    <meta name="author" content="Nova Libra, Inc"/>
    
	<link rel="stylesheet" href="css/styles.css" type="text/css"/>
	<script language="javascript" type="text/javascript">
	    function Logoff() {
	        if (document.forms[0].windowed.value == "1")
	            window.close();
	        else
	            window.location = "Login.aspx"
	    }
	</script>
</head>

<body class="spacer">
<div id="bodydiv">
    <form action="closeform.aspx" method="post" runat="server" id="theForm">
    <asp:HiddenField id="windowed" runat="server" Value="" />

    <div class="spacer"></div>
	<div id="logo"><img src="images/logo.png" border="0" alt="Home" /></div>
	<div id="search" style="padding-right: 15px;">
		<img src="images/spedy-logo.png" width="135" height="40" border="0" alt="" title="<%=VersionNo %>" />
	</div>
	<div class="spacer"></div>
    <br />
    <div id="shadowtop"></div>
        <table border="0" width="100%" cellpadding="10" >
            <tr>
                <td align="center">
                    <h2>
                        <asp:Label ID="lblMessage" runat="server"></asp:Label>
                    </h2>
            </td>
            </tr>
            <tr>
                <td align="center">
                    <asp:button runat="server" OnClientClick="Logoff(); return false;" id="btnClose" Text="Log Off" />
                </td>
            </tr>
        </table>
    <div id="shadowbottom1" style="clear:both">&nbsp;</div>
    </form>
</div>
</body>
</html>