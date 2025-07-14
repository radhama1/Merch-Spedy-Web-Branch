<%@ Page Language="VB" AutoEventWireup="false" CodeFile="UploadBulkItemMaint.aspx.vb" Inherits="UploadBulkItemMaint" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Import for Bulk Item Maintenance</title>
	<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE10" />
    <link href="css/styles.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" language="javascript" src="include/global.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
    <script language="javascript" type="text/javascript" src="novagrid/prototype.js"></script>
    <script type="text/javascript" language="javascript">
    <!--
    function closewin() {
            <% If RefreshParent Then %>
        window.parent.opener.location = window.parent.opener.location;
            <% ElseIf SendToDefault Then %>
        window.parent.opener.location = 'default.aspx';
            <% End If %>
        window.close();
    }
    function onUpload() {
        var b1 = $('btnSubmit');
        var b2 = $('btnSubmitting');
        if (b1 != null && b2 != null) {
            b1.addClassName("hideElement");

            b2.removeClassName('hideElement');
            b1.addClassName("formButton");
            b2.disabled = true;
        }
        // hide the buttons panel too
        var pB = $('panelButtons');
        if (pB != null) {
            pB.style.visibility = 'hidden';
        }
        return true;
    }
    //-->
    </script>
</head>
<body>
    <form id="form1" runat="server" enctype="multipart/form-data" onsubmit="onUpload(); return true;">
        <asp:HiddenField ID="r" runat="server" />
        <asp:HiddenField ID="sd" runat="server" />
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
					<div id="">
						<div id="logincontent">
						    <strong>UPLOAD BULK ITEM MAINTENANCE SPREADSHEET &nbsp;<br /><br /></strong>
		                    <asp:Panel ID="fileImportPanel" runat="server" style="padding: 20px;">
		                        <span class="formLabel">File: </span><asp:FileUpload ID="importFile" runat="server" CssClass="formButton" style="width: 250px;" />
		                        &nbsp;  
		                        <asp:Button ID="btnSubmit" runat="server" Text="Submit" CssClass="formButton" />
		                        <asp:Button ID="btnSubmitting" runat="server" Text="Submitting..." CssClass="formButton hideElement" />
		                    </asp:Panel>
		                
		                    <asp:Panel ID="panelButtons" runat="server" style="padding: 20px;" Visible="false">
		                        <asp:label ID="lblFeedback" runat="server"></asp:label><br />
	                            <asp:Button ID="btnCancel" runat="server" Text="Close" Visible="true" CssClass="formButton" OnClientClick="javascript:closewin();" /><br />
		                    </asp:Panel>
		                                		
		                    <br />&nbsp;
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
