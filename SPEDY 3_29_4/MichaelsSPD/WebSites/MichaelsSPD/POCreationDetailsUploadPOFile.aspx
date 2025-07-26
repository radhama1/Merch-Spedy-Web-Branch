<%@ Page Language="VB" AutoEventWireup="false" CodeFile="POCreationDetailsUploadPOFile.aspx.vb" Inherits="_POCreationDetailsUploadPOFile" %>
<%@ Register Assembly="System.Web.Extensions, Version=1.0.61025.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" Namespace="System.Web.UI" TagPrefix="asp" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <meta http-equiv="expires" content="Wed, 19 Feb 2003 08:00:00 GMT"/>
    <meta http-equiv="pragma" content="no-cache"/>
	<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE10" />
    <title>Purchase Order Data: Upload</title>
    <link href="css/styles.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" language="javascript" src="include/global.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
    <script language="javascript" type="text/javascript" src="novagrid/prototype.js"></script>
    <script type="text/javascript" language="javascript">
    <!--
    function closewin()
    {
	    window.close();
    }
    function onUpload()
    {
        var b1 = $('btnSubmit');
        var b2 = $('btnSubmitting');
        if(b1 != null && b2 != null){
            b1.addClassName("hideElement");
            
            b2.removeClassName('hideElement');
            b1.addClassName("formButton");
            b2.disabled = true;
        }
        return true;
    }
    
    function DoUnload()
    {
        <% If RefreshParent Then %>        
        window.parent.opener.RefreshDisplayOfCache();
        <% End If %>	    
    }
    //-->
    </script>
</head>
<body onunload="DoUnload();">
    <form id="form1" runat="server" enctype="multipart/form-data" onsubmit="onUpload(); return true;">
        <asp:HiddenField ID="r" runat="server" Value="0"/>        
        <asp:HiddenField ID="POID" runat="server" />
        <asp:HiddenField ID="UID" runat="server" Value="0" />
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
						    <strong>UPLOAD PO FILE &nbsp;<br /><br /></strong>
		                    <asp:Panel ID="fileImportPanel" runat="server" style="padding: 20px;">
		                    <span class="formLabel">File: </span><asp:FileUpload ID="importFile" runat="server" CssClass="formButton" style="width: 250px;" />
		                    &nbsp;  
		                    <asp:Button ID="btnSubmit" runat="server" Text="Submit" CssClass="formButton" />
		                    <asp:Button ID="btnSubmitting" runat="server" Text="Submitting..." CssClass="formButton hideElement" />
		                    </asp:Panel>
		
		                    <asp:Panel ID="fileImportSuccess" runat="server" Visible="false">
		                    File was successfully uploaded.  &nbsp; <a href="javascript:closewin();">&lt;Close window.&gt;</a>
		                    </asp:Panel>
		                    
		                    <asp:Panel ID="fileImportCustomError" runat="server" Visible="false">
		                    <novalibra:NLValidationSummary ID="errorSummary" ShowSummary="true" ShowMessageBox="false" CssClass="validationDisplay" EnableClientScript="false" EnableViewState="true" runat="server" />
		                    <br />
		                    <a href="POCreationDetailsUploadPOFile.aspx<%=UploadQueryString%>">Try again.</a> &nbsp;<a href="javascript:closewin();">&lt;Close window.&gt;</a>
		                    </asp:Panel>                    		
                    		<asp:Panel ID="fileDifferences" runat="server" Visible="false">
		                        <asp:RadioButtonList runat="server" ID="DiffChoice">
		                            <asp:ListItem Text="Process Changes Only" Value="0" Selected="True"/>
		                            <asp:ListItem Text="Replace Existing Data" Value="1"/>
		                        </asp:RadioButtonList>
		                        <br />
		                        <asp:Button ID="ProcessDiffBtn" runat="server" Text="Submit" CssClass="formButton" />
		                    <br /><br />
		                        <div class="validationDisplay" style="padding: 0px 5px 5px 0px; height: 200px; width:500px; overflow: auto;">
		                            <div id="DiffNewData" runat="server" style="padding-bottom:10px;"></div>		                            
		                            <div id="DiffModifyData" runat="server" style="padding-bottom:10px;"></div>
		                            <div id="DiffOldData" runat="server" style="padding-bottom:10px;"></div>
		                        </div>
		                    <br />
		                        <a href="POCreationDetailsUploadPOFile.aspx<%=UploadQueryString%>">Cancel.</a> &nbsp;<a href="javascript:closewin();">&lt;Close window.&gt;</a>
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
    
	