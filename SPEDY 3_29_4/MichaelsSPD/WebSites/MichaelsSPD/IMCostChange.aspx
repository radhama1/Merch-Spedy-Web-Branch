<%@ Page Language="VB" AutoEventWireup="false" CodeFile="IMCostChange.aspx.vb" Inherits="IMCostChange" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>Edit Item Master</title>
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE10" />
<link href="css/styles.css" rel="stylesheet" type="text/css" />
<link href="nlcontrols/nlcontrols.css" rel="stylesheet" type="text/css" />

<style type="text/css">
body {background-color: #dedede;}
th {padding-left: 5px; padding-right: 5px;}
input, select, textarea
{
    background-color: #ffffff;
}
.formGroupLabel
{
	text-align: left; padding-left: 2px; padding-right: 2px;
	border-bottom-width: 1px;
	border-bottom-style: solid;
	border-bottom-color: #d3d3a3;
	height: 21px;
	line-height: 21px;
}
.formGroupEndLabel
{
	border-top-width: 1px;
	border-top-style: solid;
	border-top-color: #d3d3a3;
	height: 21px;
	line-height: 21px;
}
.formGroupEndLabelBottom
{
	border-bottom-width: 1px;
	border-bottom-style: solid;
	border-bottom-color: #d3d3a3;
	height: 21px;
	line-height: 21px;
}
.formLabel
{
/*	width: 134px; */
	text-align: right;
	white-space: nowrap;
	height: 15px;
	line-height: 15px;
	white-space:nowrap;
}
.formField
{
	height: 15px;
	line-height: 15px;
}
.colorLocked 
{
	background-color: #ffff99;
}

div.autocomplete {
  position:absolute;
  width:250px;
  background-color:white;
  border:1px solid #888;
  margin:0px;
  padding:0px;
  height: 70px;
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
#tblFutureCost td 
{
	padding-left:4px;
	padding-right:4px;
}
</style>

<script type="text/javascript" language="javascript" src="include/global.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
<script language="javascript" type="text/javascript" src="novagrid/prototype.js"></script>
<script type="text/javascript" language="javascript" src="IMCostChange.js"></script>

<script type="text/javascript" language="javascript">
<!--

//-->
</script>
</head>
<body>
    <form id="form1" runat="server">
    <asp:HiddenField ID="hidBatchID" runat="server" />
    <asp:HiddenField ID="recordID" runat="server" />    <!-- ID of Item record to edit -->
    <asp:HiddenField ID="hidMichaelsSKU" runat="server" />
	<asp:HiddenField ID="hidVendorNumber" runat="server" />
<%--	<asp:HiddenField ID="hidRefreshParent" runat="server" />
--%>	
    <div id="content" style="padding: 10px;">
        <div id="itemdetail">
            <table border="0" cellpadding="3" cellspacing="0" style="width: 100%; height: 100%; ">
                <tr>
                    <td width="100%">
                        <table border="0" cellpadding="0" cellspacing="0" width="100%">
			                <tr>
			                    <td valign="bottom" style="width: 189px;">
			                        <img src="images/spacer.gif" border="0" alt="" height="1" width="189" />
			                    </td>
			                    <td style="width: 15px;"><img src="images/spacer.gif" border="0" alt="" height="1" width="15" /></td>
			                    <td style="width: 50px;"><img src="images/spacer.gif" border="0" alt="" height="1" width="50" /></td>
			                    <td>
                                    <novalibra:NLValidationSummary ID="validationDisplay" ShowSummary="true" ShowMessageBox="false" CssClass="validationDisplay" EnableClientScript="false" runat="server" />
                                </td>
			                    <td style="width: 100%;" align="right" valign="bottom">
                                    <asp:Label ID="validFlagDisplay" runat="server" Text=""></asp:Label>
			                    </td>
			                </tr>
                        </table>
                    </td>
                </tr>
                <tr>
					<th colspan="5" align="left">
					    <asp:Label ID="lblHeading" runat="server" Text="Label">Edit Item</asp:Label>
					    <asp:Label ID="batch" runat="server" Text=""></asp:Label><asp:Label ID="batchVendorName" runat="server" Text=""></asp:Label>
					    <asp:Label ID="stageName" runat="server" Text=""></asp:Label>
					    <asp:Label ID="lastUpdated" runat="server" Text=""></asp:Label>
					</th>
                </tr>
            </table>
            <br />
            <table width="90%" align="center" cellpadding="3">
                <tr>
                    <td width="5%" runat="server" id="SKUFL" class="formLabel">SKU:</td>
                    <td runat="server" id="SKUParent" >
						<novalibra:NLTextBox ID="SKU" runat="server" RenderReadOnly="true">
						</novalibra:NLTextBox>
                    </td>
                    <td width="5%" runat="server" id="VendorNumberFL" class="formLabel">Vendor Number:</td>
                    <td runat="server" id="VendorNumberParent" class="formField">
						<novalibra:NLTextBox ID="VendorNumber" runat="server" RenderReadOnly="true">
						</novalibra:NLTextBox>
                    </td>
                    <td width="5%" runat="server" id="VendorNameFL" class="formLabel">Vendor Name:</td>
                    <td runat="server" id="VendorNameParent" class="formField">
						<novalibra:NLTextBox ID="VendorName" runat="server" RenderReadOnly="true">
						</novalibra:NLTextBox>
                    </td>
                </tr>
                <tr>
                    <td width="5%" runat="server" id="ItemDescFL" class="formLabel">Item Description:</td>
                    <td runat="server" id="ItemDescParent" class="formField">
						<novalibra:NLTextBox ID="ItemDesc" runat="server" RenderReadOnly="true">
						</novalibra:NLTextBox>
                    </td>
                    <td width="5%" runat="server" id="PrimaryUPCFL" class="formLabel">Primary UPC:</td>
                    <td runat="server" id="PrimaryUPCParent" class="formField">
						<novalibra:NLTextBox ID="PrimaryUPC" runat="server" RenderReadOnly="true">
						</novalibra:NLTextBox>
                    </td>
                    <td width="5%" runat="server" id="VendorStyleNumFL" class="formLabel">VPN:</td>
                    <td runat="server" id="VendorStyleNumParent" class="formField">
						<novalibra:NLTextBox ID="VendorStyleNum" runat="server" RenderReadOnly="true">
						</novalibra:NLTextBox>
                    </td>
                </tr>
               <tr>
                    <td width="100%" colspan="6">
                        &nbsp;                   
                    </td>
                </tr>
            </table>
            <table width="90%" align="center" cellpadding="3">
                <tr>
                    <td  width="30%" class="formLabel" valign="top"></td>
                    <td width="70%" align="left"><asp:Label ID="lblMessage" runat="server" style="padding-left:5px;" CssClass="redText"></asp:Label></td>
                </tr>
                <tr>
                    <td  width="30%" class="formLabel" valign="top">Approved Future Costs:</td>

                    <td width="70%" align="left">
                        <asp:GridView ID="gvCostChanges" 
                            runat="server" 
                            Width="70%" 
                            BackColor="#dedede" 
                            BorderColor="#cecece" 
                            BorderWidth="1px" 
                            CellPadding="2" 
                            ForeColor="Black" 
                            GridLines="None" 
                            AutoGenerateColumns="False" 
                            DataKeyNames="ID" 
                            DataSourceID="" 
                            Font-Names="Arial" 
                            Font-Size="Larger" 
                            PageSize="12" 
                            HorizontalAlign="Left"
                            HeaderStyle-Height = "17px"
                            PagerStyle-Height = "17px"
                            EmptyDataText="No Cost Records for for this SKU / Vendor / Country"
                            EnableViewState="true" 
                            >
                            <SelectedRowStyle BackColor="LightGray" ForeColor="GhostWhite" Height="17px" />
                            <HeaderStyle BackColor="#cecece" Font-Bold="True" ForeColor="White" Font-Names="Arial" Font-Size="11px" Height="17px" HorizontalAlign="Left" />
                            <AlternatingRowStyle BackColor="White" Height="17px" />
                            <EditRowStyle HorizontalAlign="Center" />
                            <RowStyle Height="17px" />
                            <Columns>
                                <asp:BoundField 
                                    HtmlEncode="False"
                                    DataField="FutureCost" 
                                    DataFormatString="{0:C4}"
                                    HeaderText="Cost" 
                                    >
                                    <ItemStyle HorizontalAlign="Right"/>
                                    <HeaderStyle HorizontalAlign="Right" />
                                </asp:BoundField>
                                
                                <asp:BoundField 
                                    HtmlEncode="False"
                                    DataField="FutureDisplayerCost" 
                                    DataFormatString="{0:C4}"
                                    HeaderText="Displayer Cost" 
                                    >
                                    <ItemStyle HorizontalAlign="Right"/>
                                    <HeaderStyle HorizontalAlign="Right" />
                                </asp:BoundField>

                                <asp:BoundField 
                                    HtmlEncode="False"
                                    DataField="EffectiveDate" 
                                    HeaderText="Effective Date" 
                                    >
                                    <ItemStyle HorizontalAlign="center"/>
                                    <HeaderStyle HorizontalAlign="center" />
                                </asp:BoundField>
                                
                                <asp:TemplateField HeaderText="Status" >
                                    <ItemTemplate>
                                        <asp:label id="Status" runat="server"><%#GetInfo(Eval("ID"), Eval("CountryOfOrigin"), Eval("EffectiveDate"), "S")%></asp:label>
                                    </ItemTemplate>
                                    <HeaderStyle HorizontalAlign="Center" />
                                    <ItemStyle HorizontalAlign="Center" />
                                </asp:TemplateField>
                               
                                <asp:TemplateField>
                                    <ItemTemplate>
                                        <asp:Button ID="btnAction"
                                            runat="server" 
                                            Text='<%#GetInfo(Eval("ID"), Eval("CountryOfOrigin"), Eval("EffectiveDate"), "B")%>' 
                                            CssClass="formButton"
                                            CommandName="Action"/>
                                    </ItemTemplate>
                                    <HeaderStyle HorizontalAlign="Left" />
                                   <ItemStyle HorizontalAlign="center" />
                                </asp:TemplateField>
                               
                                <asp:TemplateField>
                                    <ItemTemplate>
                                        <asp:HiddenField ID="hdnItemID" runat="server" Value='<%#eval("ID") %>' />
                                        <asp:HiddenField ID="hdnPriCOO" runat="server" Value='<%#eval("CountryOfOrigin") %>' />
                                        <asp:HiddenField ID="hdnEffectiveDate" runat="server" Value='<%#eval("EffectiveDate") %>' />
                                        <asp:HiddenField ID="hdnStatus" runat="server" Value='<%#GetInfo(Eval("ID"), Eval("CountryOfOrigin"), Eval("EffectiveDate"), "S")%>' />
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Left" width= "0"/>
                                </asp:TemplateField>    
                            </Columns>
                            <FooterStyle BackColor="#cecece" />
                        </asp:GridView>
                    </td>
                </tr>
            </table>
            <br />
            <br />
            <table width="100%">
                <tr>
                    <th class="detailFooter">
                        <table border="0" cellpadding="0" cellspacing="0" style="width: 94%;" align="center">
                            <tr>
                                <td width="20%" align="left" valign="top">
                                    <input type="button" id="btnCancel" onclick="javascript:CloseWindow();" value="Close" class="formButton" />&nbsp;
                                </td>
                                <td width="60%" align="center"><span id="msg" runat="server"></span></td>
                                <td width="20%"  align="right" valign="top">
                                    &nbsp;<asp:Button ID="btnUpdate" runat="server" CommandName="Update" Text="Save" CssClass="formButton" /> 
                                    &nbsp;&nbsp;<asp:Button ID="btnUpdateClose" runat="server" CommandName="UpdateClose" Text="Save &amp; Close" CssClass="formButton" />
                                </td>
                            </tr>
                        </table>
                    </th>
                </tr>
                <tr>
                    <td><img src="images/spacer.gif" width="1" height="2" alt="" /></td>
                </tr>
            </table>
        </div>
    </div>

    </form>
</body>

<script language="javascript" type="text/javascript">
<!--
    <% If RefreshGrid and AllowRefresh Then %>
    window.parent.opener.reloadPage();
    <% End If %>
//-->
</script>

</html>
