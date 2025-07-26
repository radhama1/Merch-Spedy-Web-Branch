<%@ Page Language="VB" AutoEventWireup="false" CodeFile="SPEDYError.aspx.vb" Inherits="SPEDYError" %>
<%@ Register Assembly="System.Web.Extensions, Version=1.0.61025.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" Namespace="System.Web.UI" TagPrefix="asp" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <meta http-equiv="expires" content="Wed, 19 Feb 2003 08:00:00 GMT"/>
    <meta http-equiv="pragma" content="no-cache" />
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE10" />
    <title>Michaels Error Page</title>
    <meta name="author" content="Nova Libra, Inc"/>
    
	<script type="text/javascript" language="javascript" src="include/global.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
    
	<link href="novagrid/novagrid.css?v=<%=ConfigurationManager.AppSettings("AppVersion")%>" rel="stylesheet" type="text/css" />

	<link rel="stylesheet" href="css/styles.css" type="text/css"/>
	<style type="text/css">
        .menu td
        {
            padding:5px 0px;
        }
        .selectedPage a
        {
            font-weight:bold;
            color:white;
        }
        .margin1 
        {
            margin-left:3px;
            margin-right:3px;
        }
	</style>

</head>

<body class="spacer">
    <form id="formHome" runat="server">
        <div id="sitediv">
		    <div id="Div1">
			    <div id="header">
				    <div class="spacer"></div>
				    <div id="logo"><img src="images/logo.png" border="0" alt="Home" style="padding-top:5px" /></div>
				    <div id="search">
					    &nbsp;
				    </div>
				    <div class="spacer">
				    </div>
			    </div>
			    <div id="content" style="height: 350px;">
                    <br /><br />
                    <p style="font-size:16pt; color: red">SPEDY has encountered an error.  </p>
                    <div style="text-align:center;">
                       If the error persists, please contact your system administrator.<br />
                       <a href="default.aspx">Return</a> to SPEDY.
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
