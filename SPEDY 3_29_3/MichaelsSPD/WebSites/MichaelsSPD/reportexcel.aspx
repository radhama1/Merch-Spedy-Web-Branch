<%@ Page Language="VB" AutoEventWireup="false" CodeFile="reportexcel.aspx.vb" Inherits="reportexcel" EnableViewState="false" %>
<%@ Register Src="~/CORALControls/pageheader.ascx" TagName="pageheader" TagPrefix="uclayout" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>Report</title>
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE10" />
    <link rel="stylesheet" href="css/styles.css" type="text/css" />
<style type="text/css">
body
{
    margin: 0px;
	padding: 0px;
}
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
</style>
</head>
<body oncontextmenu="return false;">
    <form id="form1" runat="server">
		<asp:HiddenField ID="sort" runat="server" />
        <asp:HiddenField ID="hdnUserID" runat="server" />
	    <div id="sitediv">
		    <div id="bodydiv">
			    <div id="header">
				    <uclayout:pageheader ID="headerControl" RefreshOnUpload="false" runat="server" />
			    </div>
			    <div id="content">
    				<div id="submissiondetail">
	    				<div style="padding:10px;">
                            <asp:Label ID="lblErrorMessage" runat="server" CssClass="redText" Text="" /><br /><br />
                            <a href="reportlist.aspx">Return to Reports</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
