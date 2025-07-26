<%@ Page Language="VB" AutoEventWireup="false" CodeFile="POCreationDetailsAddSKU.aspx.vb" Inherits="_POCreationDetailsAddSKU" %>
<%@ Register Assembly="System.Web.Extensions, Version=1.0.61025.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"
    Namespace="System.Web.UI" TagPrefix="asp" %>
<%@ Register Src="~/CORALControls/pageheader.ascx" TagName="pageheader" TagPrefix="pagelayout" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <meta http-equiv="expires" content="Wed, 19 Feb 2003 08:00:00 GMT"/>
    <meta http-equiv="pragma" content="no-cache"/>
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE10" />
    <title>Item Data Management: Search</title>
    <meta name="author" content="Nova Libra, Inc"/>
    
	<script type="text/javascript" language="javascript" src="include/global.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
    <script language="javascript" type="text/javascript" src="novagrid/prototype.js"></script>
    <script language="javascript" type="text/javascript" src="novagrid/scriptaculous.js"></script>
    <script language="javascript" type="text/javascript" src="novagrid/lightbox.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
	<script type="text/javascript" language="javascript" src="POCreationDetailsAddSKU.js"></script>

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
<body onload="SetControls();" >
<div style="width:100%; margin-left:auto; margin-right:auto; overflow-x:hidden;">
    <form id="formHome" runat="server">

	<asp:HiddenField ID="hidWindowed" runat="server" />
	<asp:HiddenField ID="hidRefreshParent" runat="server" />
	<asp:HiddenField ID="hidClass" runat="server"  />
	<asp:HiddenField ID="hidSubClass" runat="server" />	
	<asp:HiddenField ID="hidLockClass" runat="server" />
	<%--
	<asp:HiddenField ID="hidLockStockIT" runat="server" />
	<asp:HiddenField ID="hidBatchPackSKU" runat="server" />
    --%>
    <div id="pageheader" runat="server">
		<pagelayout:pageheader ID="headerControl" SendToDefault="true" runat="server" />
	</div>

    <div id="Shadowbottom2" ></div>

    <div id="ItemSearch" >
        <table width="100%" align="center" border="0">
            <tr>
                <td width="50%" align="left">
                    <span class="caption">Search for Items</span>
                </td>
                <!--
                <td width="35%" align="right">
                    <span class="navyText" >Batch Type: </span>
                    <asp:Label ID="lblBatchInfo" runat="server" ></asp:Label>
                </td>
                -->
                <td width="15%" align="right">
                    <span class="navyText" >Batch Number: </span>
                    <asp:Label ID="lblBatchNumber" runat="server" ></asp:Label>
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
                                <asp:Label runat="server" ID="vendorName"></asp:Label> <!--EnableViewState="false"-->
                            </td>
                        </tr>
                    </table>
                </td>
                <td width="5%" align="right" valign="top" style="padding-top:6px;white-space:nowrap">
                    <span class="srchParm">SKU:</span>
                </td>
                <td  align="left">
                    <table cellpadding="0" cellspacing="0">
                        <tr valign="top">
                            <td>
                                <novalibra:NLTextBox ID="srchSKU" CssClass="srchTextMed textBoxPad" runat="server" MaxLength="12" Width="75px"></novalibra:NLTextBox>&nbsp;&nbsp;
                            </td>
                            <td style="white-space:nowrap">
                                <span class="srchParm">VPN:</span>
                                <novalibra:NLTextBox ID="srchVPN" CssClass="srchTextMed textBoxPad" Width="125px" MaxLength="20" runat="server"></novalibra:NLTextBox>&nbsp;&nbsp;
                            </td>
                            <td style="white-space:nowrap">
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
                    <table cellpadding="0" cellspacing="0">
                        <tr valign="top">
                            <td><novalibra:NLTextBox ID="srchItemDesc" MaxLength="30" Width="240px" CssClass="srchTextLarge textBoxPad" runat="server"></novalibra:NLTextBox></td>
                            <td><span style="margin-left: 5px;" class="srchParm"> Status:</span></td>
                            <td><novalibra:NLDropDownList ID="srchStatus" runat="server" />  </td>
                        </tr>
                    </table>
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
    
    <%--
    <asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="true" >
    <ContentTemplate>
    --%>    
    <div class="clearBoth" >
        <asp:Label ID="lblMessage" runat="server" style="padding-left:5px;" ></asp:Label>
    </div>
    <asp:Panel ID="divResults" runat="server" CssClass="clearBoth" >
        <asp:GridView ID="gvSearch"
                runat="server" 
                Width="100%" 
                BackColor="#dedede" 
                BorderColor="#cecece" 
                BorderWidth="1px" 
                CellPadding="2" 
                ForeColor="Black" 
                GridLines="None" 
                AllowSorting="True"  
                AllowPaging="True" 
                AutoGenerateColumns="False" 
                DataKeyNames="RowNumber" 
                DataSourceID="" 
                Font-Names="Arial" 
                Font-Size="Larger"
                HorizontalAlign="Left"
                HeaderStyle-Height = "17px"
                PagerStyle-Height = "17px"
                EmptyDataText="No SKUs were found matching your search criteria."
                EnableViewState="true"
                >
                <SelectedRowStyle BackColor="LightGray" ForeColor="GhostWhite" Height="17px" />
                <HeaderStyle BackColor="#cecece" Font-Bold="True" ForeColor="White" Font-Names="Arial" Font-Size="11px" Height="17px" HorizontalAlign="Left" />
                <AlternatingRowStyle BackColor="White" Height="17px" />
                <EditRowStyle HorizontalAlign="Center" />
                <RowStyle Height="17px" />
                <Columns>
                
                    <asp:TemplateField HeaderText="Add">
                        <ItemTemplate>
                            <asp:CheckBox ID="chkAddRec" runat="server" 
                            Checked='<%#GetCheckedStatus(Eval("PO_Contains_SKU")) %>' 
                            Enabled='<%#GetEnabledStatus(Eval("PO_Contains_SKU")) %>' />
                        </ItemTemplate>
                        <ItemStyle ForeColor="Black" HorizontalAlign="center" />
                        <HeaderStyle HorizontalAlign="center" ForeColor="lightgreen" VerticalAlign="Bottom" />
                    </asp:TemplateField>
                    
                    <asp:TemplateField HeaderText="SKU" SortExpression="0">
                        <ItemTemplate><%#Eval("SKU")%></ItemTemplate>
                        <ItemStyle ForeColor="Black" HorizontalAlign="Left" />
                        <HeaderStyle HorizontalAlign="Left"  VerticalAlign="Bottom"/>
                    </asp:TemplateField>
                    
                    <asp:BoundField DataField="Item_Desc" HeaderText="Item Description" HtmlEncode="False" SortExpression="1">
                        <ItemStyle HorizontalAlign="Left" />
                        <HeaderStyle HorizontalAlign="Left"  VerticalAlign="Bottom"/>
                    </asp:BoundField>
                
                    <asp:BoundField DataField="Dept_No" HeaderText="Dept.<br />Number" HtmlEncode="False" SortExpression="2">
                        <ItemStyle HorizontalAlign="Center" />
                        <HeaderStyle HorizontalAlign="Center" VerticalAlign="Bottom" />
                    </asp:BoundField>
                    
                    <asp:BoundField DataField="Dept_Name" HeaderText="Dept. Name" HtmlEncode="False" SortExpression="3">
                        <ItemStyle HorizontalAlign="Left" />
                        <HeaderStyle HorizontalAlign="Left"  VerticalAlign="Bottom"/>
                    </asp:BoundField>
                    
                    <asp:BoundField DataField="Class_Num" HeaderText="Class<br />Number" HtmlEncode="False" SortExpression="4">
                        <ItemStyle HorizontalAlign="Center" />
                        <HeaderStyle HorizontalAlign="Center"  VerticalAlign="Bottom"/>
                    </asp:BoundField>
                    
                    <asp:BoundField DataField="Sub_Class_Num" HeaderText="SubClass<br />Number" HtmlEncode="False" SortExpression="5">
                        <ItemStyle HorizontalAlign="Center" />
                        <HeaderStyle HorizontalAlign="Center"  VerticalAlign="Bottom"/>
                    </asp:BoundField>
                    
                    <asp:BoundField DataField="Vendor_Number" HeaderText="Vendor<br />Number" HtmlEncode="False" SortExpression="6">
                        <ItemStyle HorizontalAlign="Center" />
                        <HeaderStyle HorizontalAlign="Center"  VerticalAlign="Bottom"/>
                    </asp:BoundField>
                    
                    <asp:TemplateField HeaderText="Vendor Name" SortExpression="7">
                        <ItemTemplate>
                            <span><%#Eval("Vendor_Name")%></span><span class="greenTextBold">&nbsp;<%#eval("VPI") %></span>
                        </ItemTemplate>
                        <HeaderStyle HorizontalAlign="Left"  VerticalAlign="Bottom"/>
                        <ItemStyle HorizontalAlign="Left" />
                    </asp:TemplateField>
                    
                    <asp:BoundField DataField="Vendor_Style_Num" HeaderText="VPN" HtmlEncode="False" SortExpression="8">
                        <ItemStyle HorizontalAlign="Center" />
                        <HeaderStyle HorizontalAlign="Center"  VerticalAlign="Bottom"/>
                    </asp:BoundField>
                    
                    <asp:TemplateField HeaderText="UPC" SortExpression="9">
                        <ItemTemplate>
                            <span><%#eval("UPC") %></span><span class="greenTextBold">&nbsp;<%#eval("UPCPI") %></span>
                        </ItemTemplate>
                        <HeaderStyle HorizontalAlign="Left" VerticalAlign="Bottom" />
                        <ItemStyle HorizontalAlign="Left" />
                    </asp:TemplateField>
                    
                    <asp:BoundField DataField="Item_Status" HeaderText="Item<br />Status" HtmlEncode="False" SortExpression="10">
                        <ItemStyle HorizontalAlign="Center" />
                        <HeaderStyle HorizontalAlign="Center" VerticalAlign="Bottom"/>
                    </asp:BoundField>
                    
                    <asp:BoundField DataField="Stock_Category" HeaderText="Stock<br />Cat." HtmlEncode="False" SortExpression="11">
                        <ItemStyle HorizontalAlign="Center" />
                        <HeaderStyle HorizontalAlign="Center" VerticalAlign="Bottom" />
                    </asp:BoundField>
                    
                    <asp:BoundField DataField="Item_Type_Attribute" HeaderText="Item<br />Attr." HtmlEncode="False" SortExpression="12">
                        <ItemStyle HorizontalAlign="Center" />
                        <HeaderStyle HorizontalAlign="Center" VerticalAlign="Bottom" />
                    </asp:BoundField>
                    
                    <asp:BoundField DataField="Item_Type" HeaderText="Pack<br />Type" HtmlEncode="False" SortExpression="13">
                        <ItemStyle HorizontalAlign="Center" />
                        <HeaderStyle HorizontalAlign="Center" VerticalAlign="Bottom" />
                    </asp:BoundField>
                    
                    <asp:BoundField DataField="Hybrid_Type" HeaderText="Hybrid<br />Type" HtmlEncode="False" SortExpression="14">
                        <ItemStyle HorizontalAlign="Center" />
                        <HeaderStyle HorizontalAlign="Center" VerticalAlign="Bottom" />
                    </asp:BoundField>
                    
                    <asp:BoundField DataField="Hybrid_Source_DC" HeaderText="Source<br />WH" HtmlEncode="False" SortExpression="15">
                        <ItemStyle HorizontalAlign="Center" />
                        <HeaderStyle HorizontalAlign="Center" VerticalAlign="Bottom" />
                    </asp:BoundField>
                    
                    <asp:BoundField DataField="Hybrid_Conversion_Date" HeaderText="Conversion<br />Date" HtmlEncode="False" SortExpression="16" DataFormatString="{0:M/dd/yyyy}">
                        <ItemStyle HorizontalAlign="Center" />
                        <HeaderStyle HorizontalAlign="Center" VerticalAlign="Bottom" />
                    </asp:BoundField>
                    
                    <asp:TemplateField >
                        <ItemTemplate>
                            <asp:HiddenField ID="hdnSKU" runat="server" Value='<%#eval("SKU") %>' />
                            <asp:HiddenField ID="hdnUPC" runat="server" Value='<%#eval("UPC") %>' />
                            <asp:HiddenField ID="hdnDeptNo" runat="server" Value='<%#eval("Dept_No") %>' />
                        </ItemTemplate>
                        <ItemStyle HorizontalAlign="Left" width="0" />
                    </asp:TemplateField>
                
                </Columns>
                <FooterStyle BackColor="#cecece" />
                <PagerStyle BackColor="Black" ForeColor="White" HorizontalAlign="Center" Height="17px" />
                <PagerTemplate>
                    <table cellpadding="5px" width="100%" border="0">
                    <tr>
                        <td align="left" style="white-space:nowrap; padding-left:5px;" width="20%">
                            <span style="color:lightgreen;">* - Indicates Primary</span>
                        </td>
                        <td align="center">
                    <asp:Label
                        id="lblItemsFound"
                        runat="server"
                        Text="Item(s) Found"
                        Style="padding-right: 15px;"
                        CssClass="pager"
                        />
                        <asp:LinkButton
                            id="LinkButton1"
                            Text="<<"
                            CommandName="Page"
                            CommandArgument="First"
                            ToolTip="First Page"
                            CssClass="pager"
                            Runat="server" ForeColor="White"/> &nbsp;
                        <asp:LinkButton
                            id="lnkPrevious"
                            Text="<"
                            CommandName="Page"
                            CommandArgument="Prev"
                            ToolTip="Previous Page"
                            CssClass="pager"
                            Runat="server"  />  &nbsp;
                        <asp:label
                            id="PagingInformation"
                            runat="server"                                    
                            CssClass="pager"
                            BorderWidth = "0"
                            Text="Page 1 of 1"
                            Style="padding-left:5px; padding-right:5px; white-space: nowrap;"                   
                            />  &nbsp;
                        <asp:LinkButton
                            id="lnkNext"
                            Text=">"
                            CommandName="Page"
                            CommandArgument="Next"
                            ToolTip="Next Page"
                            CssClass="pager"
                            Runat="server" />  &nbsp;
                        <asp:LinkButton
                            id="LinkButton2"
                            Text=">>"
                            CommandName="Page"
                            CommandArgument="Last"
                            ToolTip="Last Page"
                            CssClass="pager"                                    
                            Runat="server" />  &nbsp;
                        <asp:button
                            id="btngo"
                            runat="server"
                            Width="60px"
                            text="go to page"
                            CommandName="PageGo"
                            CommandArgument = "0"
                            Style="height:21px; vertical-align: middle;"
                            /> 
                         <asp:TextBox
                            id="txtgotopage"
                            runat="server"
                            Width="40px"
                            CssClass="textBoxPad"
                            Style="vertical-align: middle;"
                          />
                         </td>
                         <td align="right">
                             <asp:Label runat="server" ID="numItems" Width="200px" style="text-align:right;" CssClass="pager"  Text="Items / Page:"></asp:Label>
                             <asp:TextBox CssClass="textBoxPad" runat="server" ID="txtItemPerPage" Width="20px" Style="vertical-align: middle;"></asp:TextBox>
                             <asp:button id="btnSetIPP" runat="server" Width="20px" height="21px" style="vertical-align: middle;" text="go" CommandName="PageReset" CommandArgument = "0" />
                         </td>
                    </tr>
                    </table>
                </PagerTemplate>
            </asp:GridView>
    </asp:Panel>
    
    <div class="clearBoth">
        <table width="90%" align="center" border="0" cellpadding="3px">
            <tr>
                <td align="center">
                    <asp:Button runat="server" ID="btnAddRecs" Text="Add Items to PO"  onmouseover="buttonHiLight(1);" onmouseout="buttonHiLight(0);" CssClass="formButton" />
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