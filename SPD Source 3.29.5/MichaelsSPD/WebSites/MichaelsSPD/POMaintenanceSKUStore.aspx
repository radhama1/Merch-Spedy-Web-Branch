<%@ Page Language="VB" AutoEventWireup="false" CodeFile="POMaintenanceSKUStore.aspx.vb" Inherits="POMaintenanceSKUStore" %>
<%@ Register Assembly="System.Web.Extensions, Version=1.0.61025.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" Namespace="System.Web.UI" TagPrefix="asp" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <meta http-equiv="expires" content="Wed, 19 Feb 2003 08:00:00 GMT"/>
    <meta http-equiv="pragma" content="no-cache"/>
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE10" />
    <title>PO Maintenance SKU: Quantity Details</title>
    <meta name="author" content="Nova Libra, Inc"/>
    
	<script type="text/javascript" language="javascript" src="include/global.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
    <script language="javascript" type="text/javascript" src="novagrid/prototype.js"></script>
    <script language="javascript" type="text/javascript" src="novagrid/scriptaculous.js"></script>
    <script language="javascript" type="text/javascript" src="novagrid/lightbox.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
    <script language="javascript" type="text/javascript" src="include/PurchaseOrder/POMaintenanceDetailsSKUStore.js"></script>

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
                
        .fixedheadercell, .fixedheadercell a, .fixedheadercell a:link, .fixedheadercell a:active, .fixedheadercell a:visited, .fixedheadercell a:hover
        {
            FONT-SIZE: 10pt; 
            width: auto; 
            COLOR: Black; 
            text-align: center;
            FONT-FAMILY: Arial;
            font-weight: bold; 
            BACKGROUND-COLOR: #D3D3A3;
            margin: 0px;
            overflow: auto;
        }

        
        .fixedheadertable
        {
            left: 0px;
            position: relative;
            top: 0px;
            padding-right: 2px;
            padding-left: 2px;
            padding-bottom: 2px;
            padding-top: 2px;
            margin: 0px;
            overflow: auto;
            BACKGROUND-COLOR: #D3D3A3;
        }
         #lightbox 
		{
			display: none;
			position: absolute;
			top: 0px;
			left: 0px;
			width: 100%;
			height: 100%;
			z-index: 200;
			text-align: center;
			vertical-align: middle;
		}
		
        #StoreSaving
		{
			padding: 10px;
			font-size: 11px;
			line-height: 16px;
			color: #000000;
		}
		
		#shadow 
		{
			display: none;
			visibility: hidden;
			position: absolute;
			top: 0px;
			left: 0px;
			width: 100%;
			height: 100%;
			z-index: 100;
		}
            
	</style>

</head>

<%--background = "images/MichaelsBigLogo.GIF"   --%>
<body onload="SetControls();" >
<div style="width:100%; margin-left:auto; margin-right:auto; overflow-x:hidden;">
    <form id="formHome" runat="server">

	<asp:HiddenField ID="hidWindowed" runat="server" Value="1" />
	<asp:HiddenField ID="hidRefreshParent" runat="server" Value="0" />
	<asp:HiddenField ID="hidCloseWindow" runat="server" Value="0" />
	<asp:HiddenField ID="hidClass" runat="server"  />
	<asp:HiddenField ID="hidSubClass" runat="server" />	
	<asp:HiddenField ID="hidLockClass" runat="server" />

    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <div id="submissiondetail">
        <div style="padding: 10px;">
            <table cellpadding="0" cellspacing="0" border="0" width="100%">
                <tr>
                    <td></td>
                    <td>
                        <novalibra:NLValidationSummary ID="validationDisplay" ShowSummary="true" ShowMessageBox="false" CssClass="validationDisplay" EnableClientScript="false" EnableViewState="true" runat="server" />
                        <br />
                        <asp:Label ID="lblErrorMsg" runat="server" CssClass="redText" />
                    </td>
                </tr>
                <tr>
                    <th valign="top" colspan="2">
                        <span>SKU <asp:Label ID="lblSKUNumber" runat="Server" /> Details</span>&nbsp;
                    </th>
                </tr>
                <tr>
                    <td align="left" class="subHeading bodyText" style="width: 20%; padding: 5px;">
                        <b>VPN: </b> <asp:Label ID="lblVPN" runat="Server" />
                    </td>
                    <td align="left" class="subHeading bodyText" style="width: 80%; padding: 5px;">
                        <b>DESCRIPTION: </b> <asp:Label ID="lblSKUDescription" runat="server" />
                    </td>
                </tr>
                <tr>
                    <td colspan="2" style="height: 22px; white-space: nowrap; padding: 5px;" valign="middle"
                        align="left" nowrap="nowrap">
                        <asp:LinkButton ID="BtnImport" runat="server" Text="Import Excel Store List" style="color:#336699; font-weight:normal; background-color:#dedede;font-size: 11px;line-height: 16px;" /><%If BtnImport.Visible = True AndAlso BtnAddStore.Visible = True %><span>&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;</span><%End If%>
                        Add Store: &nbsp; <novalibra:NLTextBox ID="StoreNumber" runat="server" />
                        <asp:Button ID="BtnAddStore" runat="server" Text="Add"  />
                         &nbsp;&nbsp;
                        Filter: &nbsp;<novalibra:NLDropDownList ID="StoreFilter" runat="server">
                            <asp:ListItem Text="ALL" Value="" />
                            <asp:ListItem Text="ERROR" Value="ERROR" />
                            <asp:ListItem Text="WARNING" Value="WARNING" />
                        </novalibra:NLDropDownList>
                        <asp:Button ID="BtnFilterStore" runat="server" Text="GO"/>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <table cellpadding="0" cellspacing="0" class="fixedheadertable" width="97%">
                            <tr>
                                <% If Not (_isSkuLocked) Then%><td class="fixedheadercell" style="width:10%" align="center"><asp:Button ID="BtnRemove" runat="server" Text="Remove" class="formButton"/></td><% End If %>
                                <td class="fixedheadercell" style="width:8%" align="center">Valid</td>
                                <td class="fixedheadercell" style="width:8%" align="center"><asp:LinkButton ID="BtnSortByStoreNo" runat="server" Text="Store No." /></td>
                                <td class="fixedheadercell" style="width:29%" align="center"><asp:LinkButton ID="BtnSortByStoreName" runat="Server" Text="Store Name" /></td>
                                <td class="fixedheadercell" style="width:9%" align="center"><asp:LinkButton ID="BtnSortByZone" runat="server" Text="Zone" /></td>
                                <td class="fixedheadercell" style="width:17%" align="center">Quantity</td>
                                <td class="fixedheadercell" style="width:18%" align="center">Cancelled<br /> Quantity</td>
                                <td class="fixedheadercell" style="width:18%" align="center">Received<br /> Quantity</td>
                            </tr>
                        </table>
                        <asp:Panel ID="Panel1" runat="server" Height="350px" Width="100%" ScrollBars="Vertical" >
                            <asp:GridView ID="SKUStoreGrid" runat="server" ShowHeader="false" BackColor="#dedede"
                                BorderColor="#cecece" BorderWidth="1px" CellPadding="2" ForeColor="#D3D3A3" GridLines="None"
                                AllowSorting="True" AllowPaging="False" AutoGenerateColumns="False" DataKeyNames="ID"
                                DataSourceID="" Font-Names="Arial" Font-Size="Larger" HorizontalAlign="Left"
                                HeaderStyle-Height="17px" PagerStyle-Height="17px" EnableViewState="true" Width="97%">
                                <EditRowStyle HorizontalAlign="Center" />
                                <RowStyle Height="17px" />
                                <Columns>
                                    <asp:TemplateField>
                                        <ItemTemplate>
                                            <novalibra:NLCheckBox ID="IsRemoved" runat="server" Checked='<% #Eval("IsSelected") %>' Visible='<% #Eval("IsRemoveable") %>' /></ItemTemplate>
                                        <ItemStyle HorizontalAlign="Center" Width="5%" />
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Valid">
                                        <ItemTemplate>
                                            <img src="<%# GetCheckBoxUrl(Eval("IsValid"), Eval("IsWarning")) %>" alt="" />
                                        </ItemTemplate>
                                        <ItemStyle HorizontalAlign="Center" Width="7%" />
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Store No." >
                                        <ItemTemplate>
                                            <asp:Label ID="lblStoreNumber" runat="server" Text='<%#Eval("StoreNumber")%>' /></ItemTemplate>
                                        <ItemStyle HorizontalAlign="Center"  Width="8%"  />
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Store Name">
                                        <ItemTemplate>
                                            <asp:Label ID="lblStoreName" runat="server" Text='<%#Eval("StoreName")%>' /></ItemTemplate>
                                        <ItemStyle HorizontalAlign="Center" Width="31%"  />
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Zone" >
                                        <ItemTemplate>
                                            <asp:Label ID="lblZone" runat="server" Text='<%#Eval("Zone")%>' /></ItemTemplate>
                                        <ItemStyle HorizontalAlign="Center"  Width="8%"  />
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Quantity">
                                        <ItemTemplate>
                                            <novalibra:NLTextBox ID="Qty" runat="server" Text='<%#Eval("OrderedQty")%>' RenderReadOnly='true' Width="60px" /></ItemTemplate>
                                        <ItemStyle HorizontalAlign="Center" Width="17%"  />
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Cancelled Quantity">
                                        <ItemTemplate>
                                            <novalibra:NLTextBox ID="CancelledQty" runat="server" Text='<%#Eval("CancelledQty")%>' RenderReadOnly='true' Width="60px" /></ItemTemplate>
                                        <ItemStyle HorizontalAlign="Center" Width="17%"  />
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Received Quantity">
                                        <ItemTemplate>
                                            <novalibra:NLTextBox ID="ReceivedQty" runat="server" Text='<%#Eval("ReceivedQty")%>' RenderReadOnly="True" Width="60px" /></ItemTemplate>
                                        <ItemStyle HorizontalAlign="Center" Width="17%"  />
                                    </asp:TemplateField>
                                    <asp:TemplateField Visible="false">
                                        <ItemTemplate>
                                            <asp:Label ID="lblPOLocationID" runat="server" Text='<%#Eval("POLocationID")%>' /></ItemTemplate>
                                        <ItemStyle HorizontalAlign="Center" />
                                    </asp:TemplateField>
                                    <asp:TemplateField Visible="false">
                                        <ItemTemplate>
                                            <asp:Label ID="lblIsValid" runat="server" Text='<%# Eval("IsValidText")%>' />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField Visible="false">
                                        <ItemTemplate>
                                            <asp:Label ID="lblLandedCost" runat="server" Text='<%# Eval("LandedCost")%>' />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField Visible="false">
                                        <ItemTemplate>
                                            <asp:Label ID="lblOrderRetail" runat="server" Text='<%# Eval("OrderRetail")%>' />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                                <FooterStyle BackColor="#cecece" />
                                <PagerStyle BackColor="#D3D3A3" ForeColor="Black" HorizontalAlign="Center" Height="17px" />
                            </asp:GridView>
                        </asp:Panel>
                    </td>
                </tr>
                <tr>
                    <td colspan="2" style="height: 5px;">
                        <img src="images/spacer.gif" border="0" alt="" height="5" width="1" />
                    </td>
                </tr> 
                <tr>
                    <th colspan="2" class="detailFooter">
                        <table border="0" cellpadding="0" cellspacing="0" style="width: 100%;" width="100%">
                            <tr>
                                <td width="50%" style="width: 50%;" align="left" valign="top">
                                    <asp:Button id="btnCancel" runat="server" onClientclick="cancelForm(); return false;" Text="Cancel" class="formButton" />&nbsp;
                                </td>
                                <td width="50%" style="width: 50%;" align="right" valign="top">
                                    &nbsp;<asp:Button id="btnUpdate" runat="server" Text="Save" class="formButton" />&nbsp;
                                    &nbsp;<asp:Button id="btnUpdateClose" runat="server" Text="Save &amp; Close" class="formButton" />
                                </td>
                            </tr>
                        </table>
                    </th>
                </tr>
                <tr>
                    <td colspan="2" style="height: 5px;">
                        <img src="images/spacer.gif" border="0" alt="" height="5" width="1" />
                    </td>
                </tr>
            </table>
        </div>
    </div>
	<div id="shadow"></div>
	<!-- LightBox Divs  -->
	<div id="lightbox">
        <div id="StoreSaving" style="width:30px; height:30px; position:absolute; top:476px; left:433px;">
		    <img id="imgWaiting" src="images/wait30trans.gif" alt="Saving..." />
		</div>
	</div>
    
    </form>
</div>
	<script type="text/javascript">
	    Sys.WebForms.PageRequestManager.getInstance().add_beginRequest(mSaveBeginRequest);
	    Sys.WebForms.PageRequestManager.getInstance().add_pageLoaded(mSavePageLoaded);
	</script>	
</body>
</html>