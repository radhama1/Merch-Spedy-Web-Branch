<%@ Page Language="VB" AutoEventWireup="false" CodeFile="uploadImportItemFile.aspx.vb" Inherits="uploadImportItemFile" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>Import Item Image</title>
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE10" />
<link href="css/styles.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" language="javascript" src="include/global.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
<script type="text/javascript" language="javascript">
<!--
    function closewin()
    {
	    window.close();
    }
//-->
</script>
</head>
<body style="background-color: #dedede;">
    <form id="form1" runat="server" enctype="multipart/form-data" method=post>
   		<div style="padding: 10px 10px 10px 10px">
			<asp:Panel ID="fileImportPanel" runat="server">
			    <span>Select an image (jpg/gif): <br /></span>
		        <asp:FileUpload ID="importFile" runat="server" style="width: 250px;" /><br /><br />
    	        <asp:Button ID="btnSubmit" runat="server" Text="Submit" />
    	        <input type=button name="cancelBtn" onclick="closewin();" value="Cancel" />
		    </asp:Panel>
    		
	        <asp:Panel ID="fileImportError" runat="server" Visible="false">
	            There was an error during file upload. &nbsp; 
	            <a href="javascript:closewin();">&lt;Close window.&gt;</a>
	        </asp:Panel>
		</div>
    </form>
</body>
</html>
