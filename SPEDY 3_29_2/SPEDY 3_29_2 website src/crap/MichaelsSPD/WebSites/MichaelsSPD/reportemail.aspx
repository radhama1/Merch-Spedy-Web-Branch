<%@ Page Language="VB" AutoEventWireup="false" CodeFile="reportemail.aspx.vb" Inherits="reportemail" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Report</title>
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE10" />
    <link rel="stylesheet" href="css/styles.css" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div id="sitediv">
        <br />
        <br />
        <asp:Literal ID="ltlOutput" runat="server" Mode="PassThrough"/>
        <br /><br />
        <input type="button" id="btnClose" onclick="javascript:window.close();" value="Close" class="formButton"  />
        <br />
        <br />
    </div>
    </form>
</body>
</html>
