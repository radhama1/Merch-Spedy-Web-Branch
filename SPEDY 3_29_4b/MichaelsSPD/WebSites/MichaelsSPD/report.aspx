<%@ Page Language="VB" AutoEventWireup="false" CodeFile="report.aspx.vb" Inherits="report" EnableViewState="false" %>
<%@ Register Src="NovaGrid.ascx" TagName="NovaGrid" TagPrefix="ucgrid" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>Report</title>
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE10" />
	<link rel="stylesheet" href="css/styles.css" type="text/css" />
<style type="text/css">
.gridHC
{
    background-color: #000000;
    color: #ffffff;
    padding: 3px;
    white-space: nowrap;
    font-weight: bold;
}
.gridC
{
    padding: 3px;
    vertical-align: top;
    white-space: nowrap;
}
table {
 border-collapse: collapse;
}
</style>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    <br />
    <asp:Label ID="reportName" runat="server" Text="" CssClass="pageTitle"></asp:Label>
    <br /><br />
    Run Date: <asp:Label ID="runDate" runat="server" Text="" CssClass=""></asp:Label>
    <br /><br />
    </div>
        <ucgrid:NovaGrid ID="ReportGrid" runat="server" />
    <br />
    Total Records: <asp:Label ID="totalRecords" runat="server" Text="" CssClass=""></asp:Label>
    <br /><br />
    <asp:Label ID="lblErrorMessage" runat="server" CssClass="redText" Text="" />

    </form>
</body>
</html>
