<%@ Page Language="VB" AutoEventWireup="false" CodeFile="upload.aspx.vb" Inherits="upload" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>Import</title>
	<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE10" />
<link href="css/styles.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" language="javascript" src="include/global.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
<script language="javascript" type="text/javascript" src="novagrid/prototype.js"></script>
<script type="text/javascript" language="javascript">
<!--
function closewin()
{
    <% If RefreshParent Then %>
    window.parent.opener.location = window.parent.opener.location;
    <% ElseIf SendToDefault Then %>
    window.parent.opener.location = 'default.aspx';
    <% End If %>
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
//-->
</script>
</head>
<body>
    <form id="form1" runat="server" enctype="multipart/form-data" onsubmit="onUpload(); return true;">
        <asp:HiddenField ID="r" runat="server" />
        <asp:HiddenField ID="sd" runat="server" />
	<div id="sitediv">
		<div id="bodydiv">
			<div id="content">
				<div id="shadowtop"></div>
				<div id="main" style="text-align:center">
					<div id="">
						<div id="logincontent">
						<strong>UPLOAD NEW ITEM SPREADSHEET &nbsp;<br /><br /></strong>
		<asp:Panel ID="fileImportPanel" runat="server" style="padding: 20px;">
		<span class="formLabel">File: </span><asp:FileUpload ID="importFile" runat="server" CssClass="formButton" style="width: 250px;" />
		&nbsp;  
		<asp:Button ID="btnSubmit" runat="server" Text="Submit" CssClass="formButton" />
		<asp:Button ID="btnSubmitting" runat="server" Text="Submitting..." CssClass="formButton hideElement" />
		</asp:Panel>
		
		<asp:Panel ID="fileImportSuccess" runat="server" Visible="false">
		File was successfully uploaded.  &nbsp; <a href="javascript:closewin();">&lt;Close window.&gt;</a>
		<br />
		<asp:Literal ID="lblImageError" runat="server" Text="" Mode="PassThrough" />
		</asp:Panel>
		
		<asp:Panel ID="fileImportError" runat="server" Visible="false">
		There was an error during file upload. &nbsp; 
		<a href="upload.aspx<%=UploadQueryString%>">Try again.</a> &nbsp;<a href="javascript:closewin();">&lt;Close window.&gt;</a>
		</asp:Panel>
		
		<asp:Panel ID="fileImportCustomError" runat="server" Visible="false">
		<asp:Label ID="importError" runat="server"></asp:Label> &nbsp; <br />
		<br />
		<a href="upload.aspx<%=UploadQueryString%>">Try again.</a> &nbsp;<a href="javascript:closewin();">&lt;Close window.&gt;</a>
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
