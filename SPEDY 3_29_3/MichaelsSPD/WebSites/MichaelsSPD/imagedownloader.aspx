<%@ Page Language="VB" AutoEventWireup="false" CodeFile="imagedownloader.aspx.vb" Inherits="imagedownloader" %>
<%@ Register Src="~/CORALControls/pageheader.ascx" TagName="pageheader" TagPrefix="uclayout" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>Item Image Downloader</title>
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE10" />
	<link rel="stylesheet" href="css/styles.css" type="text/css" />
    <link href="novagrid/novagrid.css?v=<%=ConfigurationManager.AppSettings("AppVersion")%>" rel="stylesheet" type="text/css" />
    <script language="javascript" type="text/javascript" src="js/prototype.js"></script>
    <script type="text/javascript" language="javascript">

        function submitItems() {
            var skuList = $('txtSKUList').innerText;
            $('lblOutput').innerText = '';
            
            //Show waiting Image
            togglePopup('SKUSubmitting', 'block', 'visible');

            //Submit SKU List for Validation
            PageMethods.ValidateSKUs(skuList, onValidateSuccess, onValidateFailure);
        }

        function resetForm() {
            $('txtSKUList').innerText = '';
            $('preSubmit').show();
            $('postSubmit').hide();
        }


        function onValidateSuccess(response) {
            togglePopup('SKUSubmitting', 'none', 'hidden');
            if (response.Success) {
                
                $('preSubmit').hide();
                $('postSubmit').show();
                var skuList = $('txtSKUList').innerText;
                var emailAddress = $('lblUserEmail').innerText;
                var userID = $('hdnUserID').value;

                PageMethods.EmailImages(skuList, emailAddress, userID, onEmailSuccess, onEmailFailure);
            } else {
                $('lblOutput').innerText = response.Message;
            }
        }

        function onValidateFailure(response) {
            $('lblOutput').innerText = 'There was a problem submitting the SKUs for image retrieval. Please try again.  If the problem continues, please contact your system administrator.';
        }

        function onEmailSuccess() {
            //TODO: Do nothing?
        }

        function onEmailFailure() {
            //TODO: Do nothing?
        }

        function togglePopup(pDivToToggle, pDisplay, pVisibility) {
            var popup = $(pDivToToggle);

            popup.setStyle(
			{
			    display: pDisplay,
			    visibility: pVisibility
			});
        }

        
    </script>
    <style type="text/css">
        #SKUSubmitting
		{
			padding: 10px;
			color: #000000;
            background-color:#000;
            -moz-opacity: 0.5;
            opacity:.50;
            filter: alpha(opacity=50);
			display: none;
			visibility: hidden;
			position: absolute;
			top: 0px;
			left: 0px;
			width: 100%;
			height: 100%;
			z-index: 300;
		}
        #imgWaiting {
            margin: auto;
            position: absolute;
            top: 0; left: 0; bottom: 0; right: 0;
        }

    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:HiddenField ID="hdnUserID" runat="server" />
	    <div id="sitediv">
		    <div id="bodydiv">
			    <div id="header">
				    <uclayout:pageheader ID="headerControl" RefreshOnUpload="false" runat="server" />
			    </div>
			    <div id="content">
				    <div id="submissiondetail">
                        <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>
                        <div style="padding:10px;">
						    <table border="0" cellpadding="0" cellspacing="0" width="100%">
						        <tr>
						            <td>
						                <span class="pageTitle">SPEDY :: ITEM IMAGE DOWNLOADER</span>&nbsp;
						            </td>
						        </tr>
						        <tr>
							        <td colspan="5" style="height: 5px;"><img src="images/spacer.gif" border="0" alt="" height="5" width="1" /></td>
							    </tr>
                            </table>
                            <div id="preSubmit">
                                <table>
                                    <tr>
                                        <td>
                                            This page can be used to retrieve images associated with items in SPEDY.  Specify up to <asp:Label ID="lblMaxSKUs" runat="server" /> SKUs in the form below, separating each SKU by a carriage return.  When you are finished, click the Submit button.  
                                            An email will be compiled and sent to <asp:Label ID="lblUserEmail" runat="server" /> with a .ZIP file containing all the associated images.
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><asp:Label ID="lblOutput" runat="server" CssClass="redText"/></td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <div id="downloader" style="padding-top: 30px; padding-left: 100px" >
                                                <table>
                                                    <tr>
                                                        <td valign="top">SKU List</td>
                                                        <td><asp:TextBox ID="txtSKUList" runat="server" TextMode="MultiLine" Height="105px" Width="220px" /></td>
                                                    </tr>
                                                    <tr>
                                                        <td>&nbsp;</td><td>&nbsp;</td>
                                                    </tr>
                                                    <tr>
                                                        <td></td>
                                                        <td><div style="float:left"><asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="formButton" /></div><div style="float:right"><asp:Button ID="btnSubmit" runat="server" Text="Submit" OnClientClick="submitItems(); return false;" CssClass="formButton"/></div></td>
                                                    </tr>
                                                </table>
                                            </div>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                            <div id="postSubmit" style="display:none; text-align:center;">
                                An email will be sent shortly to <asp:Label ID="lblUserEmail2" runat="server" /> with the specified item images.  Please allow 5-10 minutes for the email to appear.  
                                If you are not receiving any emails from SPEDY, please contact your system administrator for assistance.<br />
                                Click <a href="#" onclick="resetForm()">here</a> to enter new SKUs for image download.
                            </div>
                        </div>
				    </div>
				    <div id="shadowtop"></div>
				    <div id="main"></div>
			    </div>
		    </div>
	</div>
    <div id="SKUSubmitting">
	    <img id="imgWaiting" src="images/wait30trans.gif" alt="Saving..." />
	</div>
    </form>
</body>
</html>
