<%@ Page Language="VB" AutoEventWireup="false" CodeFile="uploaditemfile.aspx.vb" Inherits="uploaditemfile" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>Import</title>
	<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE10" />
<link href="css/styles.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" language="javascript" src="include/global.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
<script language="javascript" type="text/javascript" src="novagrid/prototype.js"></script>
<script language="javascript" type="text/javascript" src="novagrid/scriptaculous.js"></script>
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
function updateParentImage(id, newid)
{
    window.parent.opener.updateImage(id, newid);
}
function updateParentMSDS(id, newid)
{
    window.parent.opener.updateMSDS(id, newid);
}
var validFileTypes = '';

function isValidFileType(fileName)
{
    var isValid = false;
    var arr, fileext = '', i, index;
    if(fileName != null && fileName != '') {
        index = fileName.lastIndexOf('.');
        if(index >= 0)
            fileext = fileName.substr(index+1).toLowerCase();
    }
    if(validFileTypes != '' && fileext != null && fileext != '') {
        arr = validFileTypes.split(',');
        for(i = 0; i < arr.length; i++) {
            if(arr[i] == fileext){
                isValid = true;
                break;
            }
        }
    } else {
        return true;
    }
    return isValid;
}

function validateForm()
{
    var fileName = '';
    if($('uploadFile')) {
        fileName = $('uploadFile').value;
        var isValid = isValidFileType(fileName);
        if(!isValid)
            alert('Please select a valid file type to upload!');
        return isValid;
    } else {
        alert('Error: Could not validate item file upload!');
        return true;
    }
}

function showUpload()
{
    var itemtype, itemid, filetype, updateimage;
    itemtype = $('fileitemtype').value;
    itemid = $('fileitemid').value;
    filetype = $('filefiletype').value;
    updateimage = $('fileupdateimage').value;
    var url = 'uploaditemfile.aspx?itemtype=' + itemtype + '&itemid=' + itemid + '&filetype=' + filetype + '&updateimage=' + updateimage;
    document.location = url;
}

//-->
</script>
</head>
<body>
    <form id="form1" runat="server" enctype="multipart/form-data" method="post">
        <asp:HiddenField ID="fileitemtype" runat="server" />
        <asp:HiddenField ID="fileitemid" runat="server" />
        <asp:HiddenField ID="filefiletype" runat="server" />
        <asp:HiddenField ID="fileupdateimage" runat="server" />
        <asp:HiddenField ID="newfileid" runat="server" />
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
						<strong><asp:Label ID="UploadTitle" runat="server"></asp:Label> &nbsp;<br /><br /></strong>
		<asp:Panel ID="fileUploadPanel" runat="server" style="padding: 20px;">
		<span class="formLabel">File: </span><asp:FileUpload ID="uploadFile" runat="server" CssClass="formButton" style="width: 250px;" />
		&nbsp;  
		<asp:Button ID="btnSubmit" runat="server" Text="Submit" CssClass="formButton" />
		</asp:Panel>
		
		<asp:Panel ID="fileUploadSuccess" runat="server" Visible="false">
		Item File was successfully uploaded.  &nbsp; <a href="javascript:closewin();">&lt;Close window.&gt;</a>
		</asp:Panel>
		
		<asp:Panel ID="fileImageTypeError" runat="server" Visible="false">
		The file upload failed.  <br />The image is a CMYK formatted image, which is not web safe.  Please upload a RGB formatted image instead.<br />
		<a href="javascript:showUpload();">Try again.</a> &nbsp;<a href="javascript:closewin();">&lt;Close window.&gt;</a>
		</asp:Panel>
		
		<asp:Panel ID="fileTypeError" runat="server" Visible="false">
		The file upload failed.  <br />Only the following file types are allowed: <span id="fileTypeErrorLabel" runat="server"></span>.<br />
		<a href="javascript:showUpload();">Try again.</a> &nbsp;<a href="javascript:closewin();">&lt;Close window.&gt;</a>
		</asp:Panel>
		
		<asp:Panel ID="fileParamsError" runat="server" Visible="false">
		An error occured.  Please contact the system administrator.  &nbsp; <a href="javascript:closewin();">&lt;Close window.&gt;</a>
		</asp:Panel>
		
		<asp:Panel ID="fileUploadError" runat="server" Visible="false">
		There was an error during item file upload. &nbsp; <br />
		<a href="javascript:showUpload();">Try again.</a> &nbsp;<a href="javascript:closewin();">&lt;Close window.&gt;</a>
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
