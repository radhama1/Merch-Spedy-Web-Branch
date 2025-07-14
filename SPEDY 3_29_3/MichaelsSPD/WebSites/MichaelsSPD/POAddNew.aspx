<%@ Page Language="VB" AutoEventWireup="false" CodeFile="POAddNew.aspx.vb" Inherits="_POAddNew" %>
<%@ Register Assembly="System.Web.Extensions, Version=1.0.61025.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"
    Namespace="System.Web.UI" TagPrefix="asp" %>
<%@ Register Src="~/CORALControls/pageheader.ascx" TagName="pageheader" TagPrefix="pagelayout" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE10" />
    <meta http-equiv="expires" content="Wed, 19 Feb 2003 08:00:00 GMT"/>
    <meta http-equiv="pragma" content="no-cache"/>
    <title>Purchase Order: Create New Batch</title>
    <meta name="author" content="Nova Libra, Inc"/>
    
	<script type="text/javascript" language="javascript" src="include/global.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
    <script language="javascript" type="text/javascript" src="novagrid/prototype.js"></script>
    <script language="javascript" type="text/javascript" src="novagrid/scriptaculous.js"></script>
    <script language="javascript" type="text/javascript" src="novagrid/lightbox.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
	<script type="text/javascript" language="javascript" src="include/PurchaseOrder/POAddNew.js"></script>

	<link href="novagrid/lightbox.css?v=<%=ConfigurationManager.AppSettings("AppVersion")%>" rel="stylesheet" type="text/css" />
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
            padding-left:10px;
            padding-right:10px;
        }
        .srchParm
        {
            color:Navy
        }
        .srchTextLarge
        {
            width:300px;
        }
        .srchTextMed
        {
            width:100px;
        }
        .srchTextSmall
        {
            width:50px;
        }
        div.autocomplete {
          position:absolute;
          width:500px;
          background-color:white;
          border:1px solid #888;
          margin:0px;
          padding:0px;
          height: 250px;
          overflow: auto;
        }
        div.autocomplete ul {
          list-style-type:none;
          margin:0px;
          padding:0px;
        }
        div.autocomplete ul li.selected { background-color: #ffb;}
        div.autocomplete ul li {
          list-style-type:none;
          display:block;
          margin:0;
          padding:1px;
          cursor:pointer;
        }            
	</style>

</head>

<body onload="SetControls();" onunload="RemoveControls();" >

    <form id="formHome" runat="server">
    
    <div style="width:100%; margin-left:auto; margin-right:auto; overflow-x:hidden;">
        
        <input type="hidden" id="validVendor" name="validVendor" value="0" runat="server" />

	    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    	
        <div id="pageheader" runat="server">
		    <pagelayout:pageheader ID="headerControl" SendToDefault="true" runat="server" />
	    </div>

        <div id="Shadowbottom2" ></div>

        <div id="ItemSearch" >
            <table width="100%" align="center" border="0">
                <tr>
                    <td align="left">
                        <span class="caption">Create New Purchase Order</span>
                    </td>                
                </tr>
            </table>
            <table width="100%" align="center" border="0" cellpadding="2" cellspacing="0">
                <tr>
                    <td align="right" width="5%" style="white-space:nowrap" >
                        <span class="srchParm">Vendor No:</span>
                    </td>
                    <td align="left" style="white-space:nowrap">
                        <table border="0" cellpadding="0" cellspacing="0">
                            <tr>
                                <td>
                                    <novalibra:NLTextBox ID="srchVendor" MaxLength="10" Width="60px" CssClass="srchTextMed textBoxPad" runat="server" onkeydown="return TabEnter(event, 'srchVendor');" ></novalibra:NLTextBox>&nbsp;
                                </td>
                                <td style="padding-top:4px;">
                                    <a id="vendorLookUp" runat="server" href="#" onclick="GetVendorID(); return false;" title="Lookup Vendor Number"><img src="images/view.gif" alt="Lookup" border="0"/></a>
                                </td>
                                <td style="padding-left:5px;" >
                                    <asp:Label runat="server" ID="vendorName" EnableViewState="false"></asp:Label>
                                </td>
                            </tr>
                        </table>
                    </td>  
                </tr>              
                <tr>
                    <td align="right" width="5%" style="white-space:nowrap">
                        <span class="srchParm">Warehouse / Direct:</span>
                    </td>
                    <td  align="left" style="white-space:nowrap">
                        <asp:DropDownList ID="warehouseDirect" runat="server" onkeydown="return TabEnter(event, 'warehouseDirect');"></asp:DropDownList><span style="padding-left: 20px;"><asp:Button ID="btnGo" runat="server" Text="Go" CssClass="formButton" OnClientClick="return Validate();"/>
                        </span>
                    </td>
                </tr>
                <tr><td colspan="3">&nbsp;</td></tr>
            </table>
        </div>
        
        <div id="shadowtop"></div>

    </div>
    
<!-- LightBox Divs  -->
    <div id="overlay" style="display:none"></div>
    <div id="dvLookupVendor" style="display:none; width:400px;">
        <div class="gS">
	        <div id="LookupHeader" class="gridSubheaderText"></div>
	        <div id="LookupPrompt" class="gS" ></div>
	        <div class="gS" style="margin-top:10px; white-space:nowrap;">
		        <span id="txtLookupPrompt" ></span>&nbsp;
		        <asp:TextBox runat="server" ID="txtVendorLookup" CssClass="gS textBoxPad" style="width:350px; border:1px inset #ccc;"></asp:TextBox>
                <div id="VendorResults" class="autocomplete"></div>
                <input type="hidden" id="hidVendorID" name="hidVendorID" />
	        </div>
        </div>
        <div class="gS" style="width: 400px; padding-top: 20px;">
	        <table cellpadding="0" cellspacing="0" border="0" width="100%">
		        <tr>
			        <td width="95%" align="right">
			            <input type="button" id="btnCommit" value="OK" onclick="SaveVendorLookup()"/>
			            &nbsp;&nbsp;&nbsp;
			            <input type="button" id="btnCancel2" value="Cancel" onclick=""/>
			        </td>
			        <td width="5%">&nbsp;</td>
		        </tr>
	        </table>
        </div>
    </div>
    
    </form>


</body>
</html>