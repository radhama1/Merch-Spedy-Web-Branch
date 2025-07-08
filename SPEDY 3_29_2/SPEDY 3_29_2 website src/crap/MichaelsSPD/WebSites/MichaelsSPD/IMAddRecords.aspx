<%@ Page Language="VB" AutoEventWireup="false" CodeFile="IMAddRecords.aspx.vb" Inherits="_IMAddRecords" %>
<%@ Register Assembly="System.Web.Extensions, Version=1.0.61025.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" Namespace="System.Web.UI" TagPrefix="asp" %>
<%@ Register Src="~/CORALControls/pageheader.ascx" TagName="thispageheader" TagPrefix="thisheaderlayout" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE10" />
    <meta http-equiv="expires" content="Wed, 19 Feb 2003 08:00:00 GMT"/>
    <meta http-equiv="pragma" content="no-cache"/>
    <title>Item Data Management: Search</title>
    <meta name="author" content="Nova Libra, Inc"/>
    
	<script type="text/javascript" language="javascript" src="include/global.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
    <script language="javascript" type="text/javascript" src="novagrid/prototype.js"></script>
    <script language="javascript" type="text/javascript" src="novagrid/scriptaculous.js"></script>
    <script language="javascript" type="text/javascript" src="novagrid/lightbox.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
	<script type="text/javascript" language="javascript" src="IMAddRecords.js"></script>

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

<%--background = "images/MichaelsBigLogo.GIF"   --%>
<body  onload="SetControls();" >
<div style="width:100%; margin-left:auto; margin-right:auto; overflow-x:hidden;">
    <form id="formHome" runat="server">

	<asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
	<asp:HiddenField ID="hidWindowed" runat="server" />
	<asp:HiddenField ID="hidClass" runat="server"  />
	<asp:HiddenField ID="hidSubClass" runat="server" />
	<asp:HiddenField ID="hidRefreshParent" runat="server" />
<%--	<asp:HiddenField ID="hidEmptyBatchCreated" runat="server" /> --%>
	<asp:HiddenField ID="hidLockClass" runat="server" />
	<asp:HiddenField ID="hidLockStockIT" runat="server" />
	<asp:HiddenField ID="hidBatchPackSKU" runat="server" />
	

    <div id="pageheader" runat="server">
		<thisheaderlayout:thispageheader ID="headerControl" SendToDefault="true" runat="server" />
	</div>

    <div id="Shadowbottom2" ></div>

    <div id="ItemSearch" >
        <table width="100%" align="center" border="0">
            <tr>
                <td width="50%" align="left">
                    <span class="caption">Search for Items</span>
                </td>
                <td width="35%" align="right">
                    <span class="navyText" >Batch Type: </span>
                    <asp:Label ID="lblBatchInfo" runat="server" ></asp:Label>
                </td>

                <td width="15%" align="right">
                    <span class="navyText" >Batch ID: </span>
                    <asp:Label ID="lblBatchID" runat="server" ></asp:Label>
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
                                <novalibra:NLTextBox ID="srchVendor" MaxLength="10" Width="60px" CssClass="srchTextMed textBoxPad" runat="server"></novalibra:NLTextBox>&nbsp;
                            </td>
                            <td style="padding-top:4px;">
                                <a id="vendorLookUp" runat="server" href="#" onclick="GetVendorID();" title="Lookup Vendor Number"><img src="images/view.gif" alt="Lookup" border="0"/></a>
                            </td>
                            <td style="padding-left:5px;" >
                                <asp:Label runat="server" ID="vendorName" EnableViewState="false"></asp:Label>
                            </td>
                            <td>
                                <span class="srchParm">Quote Reference Number:</span>
                                <novalibra:NLTextBox ID="srchQRN" CssClass="srchTextMed textBoxPad" Width="125px" MaxLength="20" runat="server"></novalibra:NLTextBox>&nbsp;&nbsp;
                            </td>
                        </tr>
                    </table>
                </td>
                <td width="5%" align="right" valign="top" style="padding-top:6px;white-space:nowrap">
                    <span class="srchParm">SKU:</span>
                </td>
                <td  align="left">
                    <table cellpadding="0" cellspacing="0">
                        <tr valign="top" style="white-space:nowrap">
                            <td >
                                <novalibra:NLTextBox ID="srchSKU" CssClass="srchTextMed textBoxPad" runat="server" MaxLength="12" Width="75px"></novalibra:NLTextBox>&nbsp;&nbsp;
                            </td>
                            <td>
                                <span class="srchParm">VPN:</span>
                                <novalibra:NLTextBox ID="srchVPN" CssClass="srchTextMed textBoxPad" Width="125px" MaxLength="20" runat="server"></novalibra:NLTextBox>&nbsp;&nbsp;
                            </td>
                            <td>
                                <span class="srchParm">Vendor UPC No:</span>
                                <novalibra:NLTextBox ID="srchUPC" CssClass="srchTextMed textBoxPad" MaxLength="14" runat="server" Width="85px"></novalibra:NLTextBox>&nbsp;&nbsp;
                                <span id="UPCMsg" style="color:Red";></span>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td align="right" width="5%" style="white-space:nowrap">
                    <span class="srchParm">Department No:</span>
                </td>
                <td  align="left" style="white-space:nowrap">
                    <asp:DropDownList ID="srchDept" runat="server"></asp:DropDownList>
                </td>
                <td width="5%" align="right" style="white-space:nowrap">
                    <span class="srchParm">Class:</span>
                </td>
                <td  align="left">
                    <select ID="srchClass" runat="server" ></select>&nbsp;&nbsp;
                    <span style="white-space:nowrap">
                        <span class="srchParm">Subclass:</span>
                        <select ID="srchSubClass" runat="server" ></select>
                    </span>
                </td>
            </tr>
            <tr>
                <td align="right" width="5%" style="white-space:nowrap">
                    <span class="srchParm">Stock Category:</span>
                </td>
                <td align="left" style="padding-right:10px;white-space:nowrap;">
                    <asp:DropDownList ID="srchStockCat" runat="server"></asp:DropDownList>
                    &nbsp;&nbsp;&nbsp;<span class="srchParm">Item Type Attribute:</span>
                    <asp:DropDownList ID="srchItemTypeAttr" runat="server"></asp:DropDownList>
                </td>
                <td width="5%" align="right" style="white-space:nowrap">
                    <span class="srchParm">Item Desc Contains:</span>
                </td>
                <td align="left">
                    <novalibra:NLTextBox ID="srchItemDesc" MaxLength="30" Width="250px" CssClass="srchTextLarge textBoxPad" runat="server"></novalibra:NLTextBox>
                </td>
            </tr>
            <tr>
                <td colspan="4" align="center">
                    <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="formButton" OnClientClick="ShowSearch();return true;" /> &nbsp;&nbsp;&nbsp;
                    <asp:Button ID="btnReset" runat="server" Text="Reset"  CssClass="formButton" OnClientClick="ResetSearch();return false;" />
                </td>
            </tr>
        </table>
    </div>
	<div id="shadowtop"></div>

    <div class="gridTitle">
        <span class="caption"> &nbsp;Search Results&nbsp;&nbsp;</span>
        <asp:label ID="lblSearchType" runat="server"></asp:label>
    </div>
    
    <asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="true" >
 <%--   <Triggers>
        <asp:AsyncPostBackTrigger ControlID="btnSearch" />
    </Triggers>--%>
    <ContentTemplate>
    
    <div class="clearBoth" >
        <asp:Label ID="lblMessage" runat="server" style="padding-left:5px;" ></asp:Label>
    </div>
    <asp:Panel ID="divResults" runat="server" CssClass="clearBoth" >
        <asp:GridView ID="gvSearch" runat="server" AllowPaging="True" 
            AllowSorting="True" AutoGenerateColumns="False" 
            BackColor="#dedede" BorderColor="#cecece" BorderWidth="1px" 
            CellPadding="2" DataKeyNames="SKU" DataSourceID="" 
            EmptyDataText="No records match the specified search criteria." EnableViewState="true" Font-Names="Arial" 
            Font-Size="Larger" ForeColor="Black" GridLines="None" HeaderStyle-Height="17px" 
            HorizontalAlign="Left" PagerStyle-Height="17px" PageSize="12" Width="100%">
            <Columns>
            
                <asp:TemplateField HeaderText="Add">
                    <ItemTemplate>
                        <asp:CheckBox ID="chkAddRec" runat="server"
                            Checked='<%# GetCheckedStatus(Eval("BatchID")) %>' 
                            Enabled='<%# GetCheckedTTEnabled(Eval("SKU"), Eval("IndEditable"), Eval("PackSKU"), Eval("ItemType"), Eval("ItemStatus"), True)%>' 
                            ToolTip='<%# GetCheckedTTEnabled(Eval("SKU"), Eval("IndEditable"), Eval("PackSKU"), Eval("ItemType"), Eval("ItemStatus"), False)%>' />
                    </ItemTemplate>
                    <ItemStyle ForeColor="Black" HorizontalAlign="center" />
                    <HeaderStyle HorizontalAlign="center" ForeColor="lightgreen" VerticalAlign="Bottom" />
                </asp:TemplateField>
                
                <asp:TemplateField HeaderText="SKU" SortExpression="SKU">
                    <ItemTemplate>
                        <a href="#" 
                            onclick="javascript:ViewDetail('<%#Eval("SKU")%>','<%#Eval("VendorNumber")%>',<%#Eval("VendorType") %>)" 
                            title='Click to View Item Details'><%#Eval("SKU")%></a>
                    </ItemTemplate>
                    <ItemStyle ForeColor="Black" HorizontalAlign="Left" />
                    <HeaderStyle HorizontalAlign="Left"  VerticalAlign="Bottom"/>
                </asp:TemplateField>
                
                <asp:BoundField DataField="ItemDesc" HeaderText="Item Description" 
                    HtmlEncode="False" SortExpression="ItemDesc">
                    <ItemStyle HorizontalAlign="Left" />
                    <HeaderStyle HorizontalAlign="Left"  VerticalAlign="Bottom"/>
                </asp:BoundField>
                
                <asp:BoundField DataField="DeptNo" HeaderText="Dept.<br />Number" HtmlEncode="False" 
                    SortExpression="DeptNo">
                    <ItemStyle HorizontalAlign="Center" />
                    <HeaderStyle HorizontalAlign="Center" VerticalAlign="Bottom" />
                </asp:BoundField>
                
                <asp:BoundField DataField="DeptName" HeaderText="Dept. Name" HtmlEncode="False" 
                    SortExpression="DeptName">
                    <ItemStyle HorizontalAlign="Left" />
                    <HeaderStyle HorizontalAlign="Left"  VerticalAlign="Bottom"/>
                </asp:BoundField>
                
                <asp:BoundField DataField="ClassNum" HeaderText="Class<br />Number" HtmlEncode="False" 
                    SortExpression="ClassNum">
                    <ItemStyle HorizontalAlign="Center" />
                    <HeaderStyle HorizontalAlign="Center"  VerticalAlign="Bottom"/>
                </asp:BoundField>
                
                <asp:BoundField DataField="SubClassNum" HeaderText="SubClass<br />Number" 
                    HtmlEncode="False" SortExpression="SubClassNum">
                    <ItemStyle HorizontalAlign="Center" />
                    <HeaderStyle HorizontalAlign="Center"  VerticalAlign="Bottom"/>
                </asp:BoundField>
                
                <asp:BoundField DataField="VendorNumber" HeaderText="Vendor<br />Number" 
                    HtmlEncode="False" SortExpression="VendorNumber">
                    <ItemStyle HorizontalAlign="Center" />
                    <HeaderStyle HorizontalAlign="Center"  VerticalAlign="Bottom"/>
                </asp:BoundField>
                
                <asp:TemplateField HeaderText="Vendor Name" SortExpression="VendorName">
                    <ItemTemplate>
                        <span><%#eval("VendorName") %></span><span class="greenTextBold">&nbsp;<%#eval("VPI") %></span>
                    </ItemTemplate>
                    <HeaderStyle HorizontalAlign="Left"  VerticalAlign="Bottom"/>
                    <ItemStyle HorizontalAlign="Left" />
                </asp:TemplateField>
                
                <asp:BoundField DataField="VendorStyleNum" HeaderText="VPN" HtmlEncode="False" 
                    SortExpression="VendorStyleNum">
                    <ItemStyle HorizontalAlign="Center" />
                    <HeaderStyle HorizontalAlign="Center"  VerticalAlign="Bottom"/>
                </asp:BoundField>
                
                <asp:TemplateField HeaderText="UPC" SortExpression="UPC">
                    <ItemTemplate>
                        <span><%#eval("UPC") %></span><span class="greenTextBold">&nbsp;<%#eval("UPCPI") %></span>
                    </ItemTemplate>
                    <HeaderStyle HorizontalAlign="Left" VerticalAlign="Bottom" />
                    <ItemStyle HorizontalAlign="Left" />
                </asp:TemplateField>
                
                <asp:BoundField DataField="ItemStatus" HeaderText="Item<br />Status" HtmlEncode="False" 
                    SortExpression="ItemStatus">
                    <ItemStyle HorizontalAlign="Center" />
                    <HeaderStyle HorizontalAlign="Center" VerticalAlign="Bottom"/>
                </asp:BoundField>
                
                <asp:BoundField DataField="StockCategory" HeaderText="Stock<br />Cat." 
                    HtmlEncode="False" SortExpression="StockCategory">
                    <ItemStyle HorizontalAlign="Center" />
                    <HeaderStyle HorizontalAlign="Center" VerticalAlign="Bottom" />
                </asp:BoundField>
                
                <asp:BoundField DataField="ItemTypeAttribute" HeaderText="Item<br />Attr." 
                    HtmlEncode="False" SortExpression="ItemTypeAttribute">
                    <ItemStyle HorizontalAlign="Center" />
                    <HeaderStyle HorizontalAlign="Center" VerticalAlign="Bottom" />
                </asp:BoundField>

                <asp:BoundField DataField="ItemType" HeaderText="Pack<br />Type" 
                    HtmlEncode="False" SortExpression="ItemType">
                    <ItemStyle HorizontalAlign="Center" />
                    <HeaderStyle HorizontalAlign="Center" VerticalAlign="Bottom" />
                </asp:BoundField>
<%--                 <asp:BoundField DataField="HybridType" HeaderText="Hybrid<br />Type" HtmlEncode="False" SortExpression="HybridType">
                    <ItemStyle HorizontalAlign="Center" />
                    <HeaderStyle HorizontalAlign="Center" VerticalAlign="Bottom" />
                 </asp:BoundField>--%>
<%--                 <asp:BoundField DataField="HybridSourceDC" HeaderText="Source<br />WH" HtmlEncode="False" SortExpression="HybridSourceDC">
                    <ItemStyle HorizontalAlign="Center" />
                    <HeaderStyle HorizontalAlign="Center" VerticalAlign="Bottom" />
                 </asp:BoundField>--%>
                 <asp:BoundField DataField="ConversionDate" HeaderText="Conversion<br />Date" HtmlEncode="False" SortExpression="ConversionDate" DataFormatString="{0:M/dd/yyyy}">
                    <ItemStyle HorizontalAlign="Center" />
                    <HeaderStyle HorizontalAlign="Center" VerticalAlign="Bottom" />
                </asp:BoundField>
                <asp:TemplateField >
                    <ItemTemplate>
                        <%--following fields used to handle row commands  --%>
                        <asp:HiddenField ID="hdnSKUNo" runat="server" Value='<%#eval("SKU") %>' />
                        <asp:HiddenField ID="hdnSKUID" runat="server" Value='<%#eval("SKUID") %>' />
                        <asp:HiddenField ID="hdnVendor" runat="server" Value='<%#eval("VendorNumber") %>' />
                        <asp:HiddenField ID="hdnDeptNo" runat="server" Value='<%#eval("DeptNo") %>' />
                        <asp:HiddenField ID="hdnStockCat" runat="server" Value='<%#eval("StockCategory") %>' />
                        <asp:HiddenField ID="hdnItemTypeAttr" runat="server" Value='<%#eval("ItemTypeAttribute") %>' />
                        <asp:HiddenField ID="hdnItemType" runat="server" Value='<%#eval("ItemType") %>' />
                        <asp:HiddenField ID="hdnIndEditable" runat="server" Value='<%#eval("IndEditable") %>' />
                        <asp:HiddenField ID="hdnPackSKU" runat="server" Value='<%#eval("PackSKU") %>' />
                        <asp:HiddenField ID="hdnIsPackParent" runat="server" Value='<%#eval("IsPackParent") %>' />
                        <asp:HiddenField ID="hdnItemStatus" runat="server" Value='<%#eval("ItemStatus") %>' />
                    </ItemTemplate>
                    <ItemStyle HorizontalAlign="Left" width="0" />
                </asp:TemplateField>
           </Columns>
            <FooterStyle BackColor="#cecece" />
            <PagerStyle BackColor="Black" ForeColor="White" Height="17px" 
                HorizontalAlign="left" />
            <PagerTemplate>
                <table border="0" width="100%">
                    <tr>
                        <td align="left" style="white-space:nowrap; padding-left:5px;" width="20%">
                            <span style="color:lightgreen;">* - Indicates Primary</span>
                        </td>
                        <td align="center" style="white-space:nowrap;" width="60%">
                            <span style="background-color:Black; color:White;">
                            <asp:Label ID="lblRecsFound" runat="server" CssClass="pager" 
                                Text="Items Found" />
                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                            <asp:LinkButton ID="LinkButton1" Runat="server" CommandArgument="First" 
                                CommandName="Page" CssClass="pager" ForeColor="White" Text="&lt;&lt;" 
                                ToolTip="First Page" />
                            &nbsp;
                            <asp:LinkButton ID="lnkPrevious" Runat="server" CommandArgument="Prev" 
                                CommandName="Page" CssClass="pager" Text="&lt;" ToolTip="Previous Page" />
                            &nbsp;
                            <asp:Label ID="PagingInformation" runat="server" BorderWidth="0" 
                                CssClass="pager" width="90px" />
                            &nbsp;
                            <asp:LinkButton ID="lnkNext" Runat="server" CommandArgument="Next" 
                                CommandName="Page" CssClass="pager" Text="&gt;" ToolTip="Next Page" />
                            &nbsp;
                            <asp:LinkButton ID="LinkButton2" Runat="server" CommandArgument="Last" 
                                CommandName="Page" CssClass="pager" Text="&gt;&gt;" ToolTip="Last Page" />
                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                            <asp:Button ID="btngo" runat="server" CommandArgument="0" CommandName="PageGo" 
                                CssClass="formButton" Height="20px" text="go to page" Width="60px" />
                            <asp:TextBox ID="txtgotopage" runat="server" CssClass="textBoxPad" 
                                Width="40px" />
                            </span>
                        </td>
                        <td align="right" style="white-space:nowrap; padding-right:5px;" width="20%">
                            <span style="background-color:Black; color:White;">
                            <asp:Label ID="numBatches" runat="server" style="text-align:right;" 
                                Text="Items / Page:"></asp:Label>
                            <asp:TextBox ID="txtBatchPerPage" runat="server" CssClass="textBoxPad" 
                                Width="20px"></asp:TextBox>
                            <asp:Button ID="btnSetBP" runat="server" CommandArgument="0" 
                                CommandName="PageReset" CssClass="formButton" height="20px" 
                                style="vertical-align: bottom" text="go" Width="20px" />
                            </span>
                        </td>
                    </tr>
                </table>
            </PagerTemplate>
            <SelectedRowStyle BackColor="LightGray" ForeColor="GhostWhite" Height="17px" />
            <HeaderStyle BackColor="#cecece" Font-Bold="True" Font-Names="Arial" 
                Font-Size="11px" ForeColor="White" Height="17px" HorizontalAlign="Left" />
            <AlternatingRowStyle BackColor="White" Height="17px" />
            <EditRowStyle HorizontalAlign="Center" />
            <RowStyle Height="17px" />
        </asp:GridView>
    
    </asp:Panel>

<%--  Object Data Source for SearchResults
        Select Parameters are coded here but set by the code behind page. 
 --%>
    <asp:ObjectDataSource ID="objDSData" runat="server"
        EnablePaging="True" StartRowIndexParameterName="rowIndex" MaximumRowsParameterName="maxRows" 
        TypeName="BatchesData"
        SelectMethod="SearchSKURecs"
        SelectCountMethod="SearchSKURecsCount" >
        <SelectParameters>
            <asp:Parameter Type="Int32" Name="deptNo" />
            <asp:Parameter Type="Int32" Name="vendorNum" />
            <asp:Parameter Type="Int32" Name="classNo" />
            <asp:Parameter Type="Int32" Name="subClassNo" />
            <asp:Parameter Type="String" Name="VPN" />
            <asp:Parameter Type="String" Name="UPC" />
            <asp:Parameter Type="String" Name="SKU" />
            <asp:Parameter Type="String" Name="stockCat" />
            <asp:Parameter Type="String" Name="ItemTypeAttr" />
            <asp:Parameter Type="String" Name="itemDesc" />
            <asp:Parameter Type="String" Name="itemStatus" />
            <asp:Parameter Type="String" Name="packSearch" />
            <asp:Parameter Type="String" Name="packSKU" />
            <asp:Parameter Type="Int32" Name="userID" />
            <asp:Parameter Type="Int32" Name="vendorID" />
            <asp:Parameter Type="String" Name="sortCol" />
            <asp:Parameter Type="String" Name="sortDir" />
            <asp:Parameter Type="Int32" Name="maxRows" />
            <asp:Parameter Type="Int32" Name="rowIndex" />
            <asp:Parameter Type="String" Name="quoteRefNum" />
        </SelectParameters>
    </asp:ObjectDataSource>

    </ContentTemplate>
    </asp:UpdatePanel>
    
    <div class="clearBoth">
        <table width="90%" align="center" border="0" cellpadding="3px">
            <tr>
                <td align="center">
                    <asp:Button runat="server" ID="btnAddRecsToBatch" Text="Add to Batch"  onmouseover="buttonHiLight(1);" onmouseout="buttonHiLight(0);" CssClass="formButton" />
                    &nbsp;&nbsp;
                    <asp:Button runat="server" ID="btnClose" Text="Close Window" onmouseover="buttonHiLight(1);" onmouseout="buttonHiLight(0);" CssClass="formButton" />
                </td>
            </tr>
        </table>
    </div>
    <div id="shadowbottom1" style="clear:both"></div>

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
</div>

<%--<%  If RefreshGrid Then%>
<script language="javascript" type="text/javascript">
<!--
refreshList();
//-->
</script>
<% End If%>--%>
</body>
</html>