<%@ Page Language="VB" AutoEventWireup="false" CodeFile="IMDomesticForm.aspx.vb" Inherits="IMDomesticForm" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE10" />
    <title>Add New Item</title>
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
	width: 134px;
	text-align: right;
	white-space: nowrap;
	height: 21px;
	line-height: 21px;
}
.formField
{
	height: 21px;
	line-height: 21px;
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
#nlcCCOrigC_ImageID .nlcCCT, #nlcCCOrigC_MSDSID .nlcCCT
{
    padding-left: 0;
}
#I_Image_ORIG, #I_MSDS_ORIG
{
    padding-top: 5px;
}

#LstBoxStockingStrategies { height: 150px; width: 250px;}

    #chkLstWarehouses label {
        margin-left: 5px;
    }

</style>
<script type="text/javascript" language="javascript" src="include/global.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
<script type="text/javascript" language="javascript" src="novagrid/prototype.js"></script>
<script type="text/javascript" language="javascript" src="novagrid/scriptaculous.js"></script>
<script language="javascript" type="text/javascript" src="./js/SpryData.js"></script>
<script language="javascript" type="text/javascript" src="./js/SpryUtils.js"></script>
<script language="javascript" type="text/javascript" src="./js/SpryXML.js"></script>
<script language="javascript" type="text/javascript" src="./js/xpath.js"></script>
<script language="javascript" type="text/javascript" src="./IMDomesticForm.js?v=139"></script>
<script type="text/javascript" language="javascript" src="nlcontrols/nlcontrols.js"></script>

<script type="text/javascript" language="javascript">

<!--

//-->
</script>
</head>
<body onload="javascript:initPageOnLoad();">
    <form id="form1" runat="server">
    <asp:HiddenField ID="hid" runat="server" />
	<asp:HiddenField ID="additionalCOOStart" runat="server" />
	<asp:HiddenField ID="additionalCOOEnd" runat="server" />
	<asp:HiddenField ID="additionalUPCValues" runat="server" />
	<asp:HiddenField ID="additionalUPCEnd" runat="server" />
    <asp:HiddenField ID="additionalCOOCount" runat="server" value="" />
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true" AsyncPostBackTimeout="4500" ></asp:ScriptManager>
    <div id="content" style="padding: 10px;">
        <div id="itemdetail">
            <table border="0" cellpadding="0" cellspacing="0" style="width: 100%">
                <tr>
                    <td style="width: 100%;">
                        <table border="0" cellpadding="3" cellspacing="0" style="width: 100%; height: 100%">
                            <!--<tr>
                                <td colspan="5"><img src="images/spacer.gif" width="1" height="1" alt="" /></td>
                            </tr>-->
                            <tr>
                                <td colspan="5">
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
<%--                                <th colspan="5" align="left"><asp:Label ID="lblHeading" runat="server" Text="Label">Edit Item</asp:Label></th>--%>
    							<th colspan="5" align="left">
    							    <asp:Label ID="lblHeading" runat="server" Text="Label">Edit Item</asp:Label>
    							    <asp:Label ID="batch" runat="server" Text=""></asp:Label><asp:Label ID="batchVendorName" runat="server" Text=""></asp:Label>
    							    <asp:Label ID="stageName" runat="server" Text=""></asp:Label>
    							    <asp:Label ID="lastUpdated" runat="server" Text=""></asp:Label>
    							</th>
                            </tr>
                            <tr>
                                <td align="left" colspan="5" class="subHeading">
                                    <asp:Label ID="lblSubHeading" runat="server" Text="Using the fields below, add a new item entry." CssClass="bodyText"></asp:Label>&nbsp;&nbsp;  
                                </td>
                            </tr>
                            <tr>
                                <td colspan="5"><img src="images/spacer.gif" width="1" height="1" alt="" /></td>
                            </tr>
                            <tr>
                                <td style="width: 40%" valign="top">
                                    <table border="0" cellpadding="2" cellspacing="0">
										<tr>
											<td runat="server" id="departmentNumFL" class="formLabel">Dept. #:</td>
											<td class="formField"><novalibra:NLTextBox ID="departmentNum" runat="server" MaxLength="10" RenderReadOnly="true"></novalibra:NLTextBox></td>
										</tr>
                                        <tr>
                                            <td runat="server" id="michaelsSKUFL" class="formLabel">SKU:</td>
                                            <td class="formField"><novalibra:NLTextBox ID="michaelsSKU" runat="server" MaxLength="10" RenderReadOnly="true"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="quotereferenceNumFL" class="formLabel">Quote Reference Number:</td>
                                            <td class="formField"><novalibra:NLTextBox ID="QuoteReferenceNumber" runat="server" MaxLength="20" RenderReadOnly="true" ChangeControl="true"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="VendorNumberFL" class="formLabel">Vendor No:</td>
                                            <td class="formField"><novalibra:NLTextBox ID="VendorNumber" runat="server" MaxLength="10" RenderReadOnly="true"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="VendorNameFL" class="formLabel">Vendor Name:</td>
                                            <td class="formField"><novalibra:NLTextBox ID="VendorName" runat="server" MaxLength="10" RenderReadOnly="true"></novalibra:NLTextBox></td>
                                        </tr>
										<tr>
											<td runat="server" id="stockCategoryFL" class="formLabel">Stock Category:</td>
											<td class="formField">
												<novalibra:NLTextBox ID="stockCategory" runat="server" MaxLength="10" RenderReadOnly="true"></novalibra:NLTextBox>
											</td>
										</tr>
										<tr>
											<td runat="server" id="itemTypeAttributeFL" class="formLabel">Item Type Attribute:</td>
											<td class="formField">
												<novalibra:NLDropDownList ID="itemTypeAttribute" runat="server" RenderReadOnly="true"></novalibra:NLDropDownList>
											</td>
										</tr>
										<tr>
											<td runat="server" id="AllowStoreOrderFL" class="formLabel">Allow Store Order:</td>
											<td class="formField">
												<novalibra:NLDropDownList ID="AllowStoreOrder" runat="server" ChangeControl="true"></novalibra:NLDropDownList>
											</td>
										</tr>
										<tr>
											<td runat="server" id="InventoryControlFL" class="formLabel">Inventory Control:</td>
											<td class="formField">
												<novalibra:NLDropDownList ID="InventoryControl" runat="server" ChangeControl="true"></novalibra:NLDropDownList>
											</td>
										</tr>
										<tr>
											<td runat="server" id="DiscountableFL" class="formLabel">Discountable:</td>
											<td class="formField">
												<novalibra:NLDropDownList ID="Discountable" runat="server" ChangeControl="true"></novalibra:NLDropDownList>
											</td>
										</tr>
										<tr>
											<td runat="server" id="freightTermsFL" class="formLabel">Freight Terms:</td>
											<td class="formField">
												<novalibra:NLTextBox ID="freightTerms" runat="server" MaxLength="20" RenderReadOnly="true"></novalibra:NLTextBox>
											</td>
										</tr>
										<tr>
											<td runat="server" id="AutoReplenishFL" class="formLabel">Auto Replenish:</td>
											<td class="formField">
												<novalibra:NLDropDownList ID="AutoReplenish" runat="server" ChangeControl="true"></novalibra:NLDropDownList>
											</td>
										</tr>
										<tr>
											<td runat="server" id="SKUGroupFL" class="formLabel">SKU Group:</td>
											<td class="formField">
												<novalibra:NLDropDownList ID="SKUGroup" runat="server" RenderReadOnly="true"></novalibra:NLDropDownList>
											</td>
										</tr>
										<tr>
											<td runat="server" id="StoreSupplierZoneGroupFL" class="formLabel">Store Supp Zone Group:</td>
											<td class="formField"><novalibra:NLTextBox ID="StoreSupplierZoneGroup" runat="server" MaxLength="20" RenderReadOnly="true"></novalibra:NLTextBox></td>
										</tr>
										<tr>
											<td runat="server" id="WHSSupplierZoneGroupFL" class="formLabel">WHS Supp Zone Group:</td>
											<td class="formField"><novalibra:NLTextBox ID="WHSSupplierZoneGroup" runat="server" MaxLength="20" RenderReadOnly="true"></novalibra:NLTextBox></td>
										</tr>
                                       <tr>
                                            <td runat="server" id="PackItemIndicatorFL" class="formLabel">Pack Item Indicator:</td>
                                            <td class="formField">
												<novalibra:NLDropDownList ID="PackItemIndicator" runat="server" RenderReadOnly="true">
												</novalibra:NLDropDownList>
											</td>
                                        </tr>
                                        <tr>
                                            <td  runat="server" id="vendorUPCFL" class="formLabel">Primary UPC:</td>
                                            <td class="formField"><novalibra:NLTextBox ID="vendorUPC" runat="server" MaxLength="20" RenderReadOnly="true"></novalibra:NLTextBox></td>
                                        </tr>  
                                        <tr>
                                            <td runat="server" id="additionalUPCFL" class="formLabel" valign="top">Additional UPC(s):</td>
                                            <td runat="server" id="additionalUPCParent" class="formField" style="white-space:nowrap;">
                                                <asp:HiddenField ID="additionalUPCCount" runat="server" value="1" />
                                                <asp:Label ID="additionalUPCs" runat="server">
                                                </asp:Label>
                                            </td>
                                        </tr>
                                        <!--PMO200141 GTIN14 Enhancements changes -->
                                        <tr style="display:none;">
                                            <td  runat="server" id="InnerGTINFL" class="formLabel">Inner GTIN14:</td>
                                            <td class="formField"><novalibra:NLTextBox ID="InnerGTIN" runat="server" MaxLength="20" RenderReadOnly="true" ChangeControl="true"></novalibra:NLTextBox></td>
                                        </tr>  
                                        <tr style="display:none;">
                                            <td  runat="server" id="CaseGTINFL" class="formLabel">Case GTIN14:</td>
                                            <td class="formField"><novalibra:NLTextBox ID="CaseGTIN" runat="server" MaxLength="20" RenderReadOnly="true" ChangeControl="true"></novalibra:NLTextBox></td>
                                        </tr>  
                                        <!--PMO200141 GTIN14 Enhancements End -->
                                        <tr>
                                            <td runat="server" id="classNumFL" class="formLabel">Class #:</td>
                                            <td class="formField"><novalibra:NLTextBox ID="classNum" runat="server" MaxLength="20" RenderReadOnly="true"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="subClassNumFL" class="formLabel">Sub-Class #:</td>
                                            <td class="formField"><novalibra:NLTextBox ID="subClassNum" runat="server" MaxLength="20" RenderReadOnly="true"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="VendorStyleNumFL" class="formLabel">Vendor Style #:</td>
                                            <td class="formField"><novalibra:NLTextBox ID="VendorStyleNum" runat="server" MaxLength="20" ChangeControl="true"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="ItemDescFL" class="formLabel">Item Description:</td>
                                            <td class="formField"><novalibra:NLTextBox ID="ItemDesc" runat="server" MaxLength="30" Width="180" ChangeControl="true"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td id="PrivateBrandLabelFL" class="formLabel" valign="top" runat="server">Private Brand Label:</td>
                                            <td class="formField" id="PrivateBrandLabelParent" runat="server">
                                                <novalibra:NLDropDownList ID="PrivateBrandLabel" runat="server" autopostback="true" ChangeControl="true"></novalibra:NLDropDownList>
                                                <!-- PMO200141 GTIN14 Enhancements changes modified autopostback="true" -->
                                            </td>
                                        </tr>
                                        <tr><td colspan="2">&nbsp;</td></tr>
                                        <tr>
							                <td runat="server" id="HarmonizedCodeNumberFL" class="formLabel">Harmonized Code No.:</td>
							                <td class="formField"><novalibra:NLTextBox ID="HarmonizedCodeNumber" runat="server" MaxLength="10" ChangeControl="true" ></novalibra:NLTextBox></td>
							            </tr>
							            <tr>
							                <td runat="server" id="CanadaHarmonizedCodeNumberFL" class="formLabel">Canada Harmonized Code No.:</td>
							                <td class="formField"><novalibra:NLTextBox ID="CanadaHarmonizedCodeNumber" runat="server" MaxLength="10" ChangeControl="true" ></novalibra:NLTextBox></td>
							            </tr>
							            <tr><td colspan="2">&nbsp;</td></tr>
							            <tr>
							                <td runat="server" id="DetailInvoiceCustomsDescFL" class="formLabel">Detail Invoice / Customs Description:</td>
							                <td class="formField"><novalibra:NLTextBox ID="DetailInvoiceCustomsDesc0" runat="server" Width="210" MaxLength="35" ChangeControl="true" ></novalibra:NLTextBox></td>
							            </tr>
							            <tr>
							                <td runat="server" id="ComponentMaterialBreakdownFL" class="formLabel">Component / Material Breakdown by %:</td>
							                <td class="formField"><novalibra:NLTextBox ID="ComponentMaterialBreakdown0" runat="server" Width="210" MaxLength="35" ChangeControl="true" ></novalibra:NLTextBox></td>
							            </tr>
							            <tr><td colspan="2">&nbsp;</td></tr>
                                        <tr>
                                            <td runat="server" id="StockingStrategyCodeFL" class="formLabel">Stocking Strategy:</td>
                                            <td class="formField">
												<novalibra:NLDropDownList ID="StockingStrategyCode" runat="server" ChangeControl="true" RenderReadOnly="true"></novalibra:NLDropDownList>
                                                <input type="button" id="btnStockStratHelper" runat="server" visible="false" value="Helper" class="formButton" onclick="showStockStratHelper();" />&nbsp;&nbsp;
                                            </td>
                                        </tr>
<%--                                        <tr>
                                            <td colspan="2" class="formGroupLabel">Hybrid</td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="hybridTypeFL" class="formLabel">Hybrid Type:</td>
                                            <td class="formField">
												<novalibra:NLDropDownList ID="hybridType" runat="server" RenderReadOnly="true"></novalibra:NLDropDownList>
											</td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="hybridSourceDCFL" class="formLabel" visible="false">Source DC:</td>
                                            <td class="formField">
												<novalibra:NLDropDownList ID="hybridSourceDC" runat="server" RenderReadOnly="true" Visible="false"></novalibra:NLDropDownList></td>
                                        </tr>
                                        <tr>
											<td class="formLabel">&nbsp;</td>
                                            <td class="formGroupEndLabel">&nbsp;</td>
                                        </tr>--%>
                                        <tr id="qtyInPackRow" runat="server">
                                            <td runat="server" id="qtyInPackFL" class="formLabel">Component Qty Ea:</td>
                                            <td class="formField"><novalibra:NLTextBox ID="qtyInPack" runat="server" MaxLength="5" ChangeControl="true"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="eachesMasterCaseFL" class="formLabel">Eaches in Master Case:</td>
                                            <td class="formField"><novalibra:NLTextBox ID="eachesMasterCase" runat="server" MaxLength="15" ChangeControl="true"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="eachesInnerPackFL" class="formLabel">Eaches in Inner Pack:</td>
                                            <td class="formField"><novalibra:NLTextBox ID="eachesInnerPack" runat="server" MaxLength="15" ChangeControl="true"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="prePricedFL" class="formLabel">Pre-Priced:</td>
                                            <td class="formField">
												<novalibra:NLDropDownList ID="prePriced" runat="server" ChangeControl="true"></novalibra:NLDropDownList></td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="prePricedUDAFL" class="formLabel">Pre-Priced UDA:</td>
                                            <td class="formField">
												<novalibra:NLDropDownList ID="prePricedUDA" runat="server" ChangeControl="true"></novalibra:NLDropDownList></td>
                                        </tr>
                                        <tr>
                                            <td class="formGroupLabel">Languages</td>
											<td class="formField">&nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="PLI" style="text-align: right; white-space: nowrap;">Package Language Indicators</td>
                                            <td colspan="2" >&nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="PLIEnglishFL"  style="text-align: right; white-space: nowrap;">English: </td>
                                            <td colspan="2">
                                                <novalibra:NLDropDownList ID="PLIEnglish" runat="server" ChangeControl="true" >
                                                    <asp:ListItem Text="" Value="" />
                                                    <asp:ListItem Text="No" Value="N" />
                                                    <asp:ListItem Text="Yes" Value="Y" />
                                                </novalibra:NLDropDownList>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="PLIFrenchFL"  style="text-align: right; white-space: nowrap;">Canadian French: </td>
                                            <td colspan="2" style="vertical-align: middle" >
                                                <div style="width: 100%">
                                                    <novalibra:NLDropDownList ID="PLIFrench" runat="server" ChangeControl="true" >
			                                            <asp:ListItem Text="" Value="" />
                                                        <asp:ListItem Text="No" Value="N" />
                                                        <asp:ListItem Text="Yes" Value="Y" />
			                                        </novalibra:NLDropDownList>
                                                        &nbsp;&nbsp;
                                                        <asp:Label ID="ExemptEndDateFrenchFL" runat="server" Text="Exempt End Date:" />
                                                        <novalibra:NLTextBox ID="ExemptEndDateFrench" runat="server" ReadOnly="true" RenderReadOnly="true"/>
                                                
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="PLISpanishFL"  style="text-align: right; white-space: nowrap;">Latin American Spanish: </td>
                                            <td colspan="2">
                                                <novalibra:NLDropDownList ID="PLISpanish" runat="server" ChangeControl="true" >
			                                        <asp:ListItem Text="" Value="" />
                                                    <asp:ListItem Text="No" Value="N" />
                                                    <asp:ListItem Text="Yes" Value="Y" />
			                                    </novalibra:NLDropDownList>
                                            </td>
                                        </tr>
                                        <tr><td colspan="3">&nbsp;</td></tr>
                                        <tr>
                                            <td runat="server" id="CustomsDescriptionFL"  style="text-align: right; white-space: nowrap;">Customs Description: </td>
                                            <td colspan="2"><novalibra:NLTextBox ID="CustomsDescription" runat="server" ChangeControl="true" Width="200" MaxLength="255" /> </td>
                                        </tr>
                                        <tr><td colspan="3">&nbsp;</td></tr>
                                        <tr>
                                            <td runat="server" id="TIs" style="text-align: right; white-space: nowrap;">Translation Indicators: </td>
                                            <td colspan="2" >&nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="TIEnglishFL"  style="text-align: right; white-space: nowrap;">English: </td>
                                            <td colspan="2">
                                                <novalibra:NLDropDownList ID="TIEnglish" runat="server" ChangeControl="true" >
			                                        <asp:ListItem Text="" Value="" />
                                                    <asp:ListItem Text="No" Value="N" />
                                                    <asp:ListItem Text="Yes" Value="Y" />
			                                    </novalibra:NLDropDownList>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="TIFrenchFL"  style="text-align: right; white-space: nowrap;">Canadian French: </td>
                                            <td colspan="2">
                                                <novalibra:NLDropDownList ID="TIFrench" runat="server" ChangeControl="true">
			                                        <asp:ListItem Text="" Value="" />
                                                    <asp:ListItem Text="No" Value="N" />
                                                    <asp:ListItem Text="Yes" Value="Y" />
			                                    </novalibra:NLDropDownList>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="TISpanishFL"  style="text-align: right; white-space: nowrap;">Latin American Spanish: </td>
                                            <td colspan="2">
                                                <novalibra:NLDropDownList ID="TISpanish" runat="server" ChangeControl="false" Enabled="false">
			                                        <asp:ListItem Text="" Value="" />
                                                    <asp:ListItem Text="No" Value="N" Selected="True"/>
                                                    <asp:ListItem Text="Yes" Value="Y" />
			                                    </novalibra:NLDropDownList>
                                            </td>
                                        </tr>
                                        <tr><td colspan="3">&nbsp;</td></tr>
                                        <tr>
                                            <td runat="server" id="CFDs" style="text-align: right; white-space: nowrap;">Consumer Friendly Descriptions: </td>
                                            <td colspan="2" >&nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td colspan="3">
                                                <div id="EnglishDescriptions">
                                                    <table cellpadding="3" cellspacing="0" border="0">
                                                        <tr>
                                                            <td runat="server" id="EnglishShortDescriptionFL"  style="padding-left:50px;text-align: right; white-space: nowrap;">English &nbsp;<br /> Short Description: &nbsp;</td>
                                                            <td><novalibra:NLTextBox ID="EnglishShortDescription" runat="server"  Width="200" MaxLength="17" ChangeControl="true" /></td>
                                                        </tr>
                                                        <tr>
                                                            <td runat="server" id="EnglishLongDescriptionFL"  style="text-align: right; white-space: nowrap;">English &nbsp;<br /> Long Description: &nbsp;<br />(max 100 chars.) &nbsp;</td>
                                                            <td><novalibra:NLTextBox ID="EnglishLongDescription" runat="server"  Width="200" MaxLength="100" TextMode="MultiLine" Height="50" ChangeControl="true" /></td>
                                                        </tr>
                                                     </table>
                                                     <br />
                                                 </div>
                                                 <div id="FrenchDescriptions">
                                                    <table cellpadding="3" cellspacing="0" border="0">
                                                        <tr>
                                                            <td runat="server" id="FrenchShortDescriptionFL"  style="padding-left:50px;text-align: right; white-space: nowrap;">Canadian French &nbsp;<br /> Short Description: &nbsp;</td>
                                                            <td><novalibra:NLTextBox ID="FrenchShortDescription" runat="server"  Width="200" MaxLength="17"  ChangeControl="true"/></td>
                                                        </tr>
                                                        <tr>
                                                            <td runat="server" id="FrenchLongDescriptionFL"  style="text-align: right; white-space: nowrap;">Canadian French &nbsp;<br /> Long Description: &nbsp;<br />(max 150 chars.) &nbsp;</td>
                                                            <td><novalibra:NLTextBox ID="FrenchLongDescription" runat="server"  Width="200" MaxLength="150" TextMode="MultiLine" Height="50"  ChangeControl="true"/></td>
                                                        </tr>
                                                     </table>
                                                     <br />
                                                 </div>
                                                 <div id="SpanishDescriptions">
                                                    <table cellpadding="3" cellspacing="0" border="0">
                                                        <tr>
                                                            <td runat="server" id="SpanishShortDescriptionFL"  style="padding-left:23px;text-align: right; white-space: nowrap;">Latin American Spanish &nbsp;<br /> Short Description: &nbsp;</td>
                                                            <td><novalibra:NLTextBox ID="SpanishShortDescription" runat="server"  Width="200" MaxLength="17" ChangeControl="true" /></td>
                                                        </tr>
                                                        <tr>
                                                            <td runat="server" id="SpanishLongDescriptionFL"  style="text-align: right; white-space: nowrap;">Latin American Spanish &nbsp;<br /> Long Description: &nbsp;<br />(max 150 chars.) &nbsp;</td>
                                                            <td><novalibra:NLTextBox ID="SpanishLongDescription" runat="server"  Width="200" MaxLength="150" TextMode="MultiLine" Height="50"  ChangeControl="true"/></td>
                                                        </tr>
                                                     </table>
                                                 </div>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td><img src="images/spacer.gif" width="1" height="1" alt="" /></td>
                                <td style="width: 27%" valign="top">
                                    <table border="0" cellpadding="2" cellspacing="0" style="padding-right:5px;" >
                                        <tr>
                                            <td colspan="3">
                                                <table cellpadding="3" cellspacing="0" border="0">
                                                    <tr>
                                                        <td colspan="2" class="formGroupLabel">Costs</td>
                                                    </tr>
                                                    <tr id="DisplayerCostRow" runat="server">
                                                        <td runat="server" id="DisplayerCostFL" class="formLabel">Additional Cost Per Unit:</td>
                                                        <td class="formField"><novalibra:NLTextBox ID="DisplayerCost" runat="server" MaxLength="20" ChangeControl="true"></novalibra:NLTextBox></td>
                                                    </tr>
                                                    <tr>
                                                        <td runat="server" id="ItemCostFL" class="formLabel">Item Cost ($ each):</td>
                                                        <td class="formField"><novalibra:NLTextBox ID="ItemCost" runat="server" MaxLength="20" ChangeControl="true"></novalibra:NLTextBox></td>
                                                    </tr>
                                                    <tr>
                                                        <td runat="server" id="FOBShippingPointFL" class="formLabel" >Total Cost:</td>
                                                        <td runat="server" id="FOBShippingPointParent" class="formField formGroupEndLabelBottom">
                                                            <novalibra:NLTextBox ID="FOBShippingPointEdit" runat="server" ReadOnly="true" MaxLength="20" ChangeControl="true" RevertEnabled="false" CssClass="calculatedField"></novalibra:NLTextBox>
                                                            <asp:HiddenField ID="FOBShippingPoint" runat="server" />
                                                            <asp:Label ID="FOBShippingPointLabel" runat="server" Text=""></asp:Label>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td  colspan="3" class="formGroupLabel">Retails</td>
                                        </tr>
                                        <tr>
                                            <td class="formField"></td>
											<td class="formField">Retail</td>
											<td class="formField">Clearance</td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="base1RetailFL" class="formLabel">Low Elas3 (29):</td>
                                            <td class="formField"><novalibra:NLTextBox ID="base1Retail" runat="server" MaxLength="15" RenderReadOnly="true"></novalibra:NLTextBox></td>
                                            <td class="formField"><novalibra:NLTextBox ID="base1Clearance" runat="server" MaxLength="15" RenderReadOnly="true"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="Base2RetailFL" class="formLabel">High Elas3 (28):</td>
                                            <td class="formField">
                                                <novalibra:NLTextBox ID="Base2RetailEdit" runat="server" MaxLength="15" RenderReadOnly="true"></novalibra:NLTextBox>
                                                <asp:HiddenField ID="Base2Retail" runat="server" />
                                            </td>
                                            <td class="formField">
                                                <novalibra:NLTextBox ID="Base2ClearanceEdit" runat="server" MaxLength="15" RenderReadOnly="true"></novalibra:NLTextBox>
                                                <asp:HiddenField ID="Base2Clearance" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="testRetailFL" class="formLabel">Do Not Use (3):</td>
                                            <td class="formField">
                                                <novalibra:NLTextBox ID="testRetailEdit" runat="server" MaxLength="15" RenderReadOnly="true"></novalibra:NLTextBox>
                                                <asp:HiddenField ID="testRetail" runat="server" />
                                            </td>
                                            <td class="formField">
                                                <novalibra:NLTextBox ID="testClearanceEdit" runat="server" MaxLength="15" RenderReadOnly="true"></novalibra:NLTextBox>
                                                <asp:HiddenField ID="testClearance" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="alaskaRetailFL" class="formLabel">High Cost (27):</td>
                                            <td class="formField">
                                                <novalibra:NLTextBox ID="alaskaRetail" runat="server" MaxLength="15" RenderReadOnly="true"></novalibra:NLTextBox>
                                            </td>
                                            <td class="formField">
                                                <novalibra:NLTextBox ID="alaskaClearance" runat="server" MaxLength="15" RenderReadOnly="true"></novalibra:NLTextBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="canadaRetailFL" class="formLabel">Canada (5):</td>
                                            <td class="formField">
                                                <novalibra:NLTextBox ID="canadaRetail" runat="server" MaxLength="15" RenderReadOnly="true"></novalibra:NLTextBox>
                                            </td>
                                            <td class="formField">
                                                <novalibra:NLTextBox ID="canadaClearance" runat="server" MaxLength="15" RenderReadOnly="true"></novalibra:NLTextBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="High2RetailFL" class="formLabel">Canada2 (16):</td>
                                            <td class="formField">
                                                <novalibra:NLTextBox ID="High2RetailEdit" runat="server" MaxLength="15" RenderReadOnly="true"></novalibra:NLTextBox>
                                                <asp:HiddenField ID="High2Retail" runat="server" />
                                            </td>
                                            <td class="formField">
                                                <novalibra:NLTextBox ID="High2ClearanceEdit" runat="server" MaxLength="15" RenderReadOnly="true"></novalibra:NLTextBox>
                                                <asp:HiddenField ID="High2Clearance" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="High3RetailFL" class="formLabel">Canada E-Comm (17):</td>
                                            <td class="formField">
                                                <novalibra:NLTextBox ID="High3RetailEdit" runat="server" MaxLength="15" RenderReadOnly="true"></novalibra:NLTextBox>
                                                <asp:HiddenField ID="High3Retail" runat="server" />
                                            </td>
                                            <td class="formField">
                                                <novalibra:NLTextBox ID="High3ClearanceEdit" runat="server" MaxLength="15" RenderReadOnly="true"></novalibra:NLTextBox>
                                                <asp:HiddenField ID="High3Clearance" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="SmallMarketRetailFL" class="formLabel">Do Not Use (8):</td>
                                            <td class="formField">
                                                <novalibra:NLTextBox ID="SmallMarketRetailEdit" runat="server" MaxLength="15" RenderReadOnly="true"></novalibra:NLTextBox>
                                                <asp:HiddenField ID="SmallMarketRetail" runat="server" />
                                            </td>
                                            <td class="formField">
                                                <novalibra:NLTextBox ID="SmallMarketClearanceEdit" runat="server" MaxLength="15" RenderReadOnly="true"></novalibra:NLTextBox>
                                                <asp:HiddenField ID="SmallMarketClearance" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="High1RetailFL" class="formLabel">Do Not Use (9):</td>
                                            <td class="formField">
                                                <novalibra:NLTextBox ID="High1RetailEdit" runat="server" MaxLength="15" RenderReadOnly="true"></novalibra:NLTextBox>
                                                <asp:HiddenField ID="High1Retail" runat="server" />
                                            </td>
                                            <td class="formField">
                                                <novalibra:NLTextBox ID="High1ClearanceEdit" runat="server" MaxLength="15" RenderReadOnly="true"></novalibra:NLTextBox>
                                                <asp:HiddenField ID="High1Clearance" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="Base3RetailFL" class="formLabel">Do Not Use (10):</td>
                                            <td class="formField">
                                                <novalibra:NLTextBox ID="Base3RetailEdit" runat="server" MaxLength="15" RenderReadOnly="true"></novalibra:NLTextBox>
                                                <asp:HiddenField ID="Base3Retail" runat="server" />
                                            </td>
                                            <td class="formField">
                                                <novalibra:NLTextBox ID="Base3ClearanceEdit" runat="server" MaxLength="15" RenderReadOnly="true"></novalibra:NLTextBox>
                                                <asp:HiddenField ID="Base3Clearance" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="Low1RetailFL" class="formLabel">Do Not Use (11):</td>
                                            <td class="formField">
                                                <novalibra:NLTextBox ID="Low1RetailEdit" runat="server" MaxLength="15" RenderReadOnly="true"></novalibra:NLTextBox>
                                                <asp:HiddenField ID="Low1Retail" runat="server" />
                                            </td>
                                            <td class="formField">
                                                <novalibra:NLTextBox ID="Low1ClearanceEdit" runat="server" MaxLength="15" RenderReadOnly="true"></novalibra:NLTextBox>
                                                <asp:HiddenField ID="Low1Clearance" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="Low2RetailFL" class="formLabel">Do Not Use (12):</td>
                                            <td class="formField">
                                                <novalibra:NLTextBox ID="Low2RetailEdit" runat="server" MaxLength="15" RenderReadOnly="true"></novalibra:NLTextBox>
                                                <asp:HiddenField ID="Low2Retail" runat="server" />
                                            </td>
                                            <td class="formField">
                                                <novalibra:NLTextBox ID="Low2ClearanceEdit" runat="server" MaxLength="15" RenderReadOnly="true"></novalibra:NLTextBox>
                                                <asp:HiddenField ID="Low2Clearance" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="ManhattanRetailFL" class="formLabel">E-Comm (13):</td>
                                            <td class="formField">
                                                <novalibra:NLTextBox ID="ManhattanRetailEdit" runat="server" MaxLength="15" RenderReadOnly="true"></novalibra:NLTextBox>
                                                <asp:HiddenField ID="ManhattanRetail" runat="server" />
                                            </td>
                                            <td class="formField">
                                                <novalibra:NLTextBox ID="ManhattanClearanceEdit" runat="server" MaxLength="15" RenderReadOnly="true"></novalibra:NLTextBox>
                                                <asp:HiddenField ID="ManhattanClearance" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="QuebecRetailFL" class="formLabel">Quebec (14):</td>
                                            <td class="formField">
                                                <novalibra:NLTextBox ID="QuebecRetailEdit" runat="server" MaxLength="15" RenderReadOnly="true"></novalibra:NLTextBox>
                                                <asp:HiddenField ID="QuebecRetail" runat="server" />
                                            </td>
                                            <td class="formField">
                                                <novalibra:NLTextBox ID="QuebecClearanceEdit" runat="server" MaxLength="15" RenderReadOnly="true"></novalibra:NLTextBox>
                                                <asp:HiddenField ID="QuebecClearance" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="PuertoRicoRetailFL" class="formLabel">Comp (30):</td>
                                            <td class="formField">
                                                <novalibra:NLTextBox ID="PuertoRicoRetailEdit" runat="server" MaxLength="15" RenderReadOnly="true"></novalibra:NLTextBox>
                                                <asp:HiddenField ID="PuertoRicoRetail" runat="server" />
                                            </td>
                                            <td class="formField">
                                                <novalibra:NLTextBox ID="PuertoRicoClearanceEdit" runat="server" MaxLength="15" RenderReadOnly="true"></novalibra:NLTextBox>
                                                <asp:HiddenField ID="PuertoRicoClearance" runat="server" />
                                            </td>
                                        </tr>        
                                        <tr>
                                            <td  colspan="3" class="formGroupLabel">Each Case Pack</td>
											<%--<td class="formGroupEndLabel">&nbsp;</td>--%>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="eachCaseHeightFL" class="formLabel">Each Case Pack Height:</td>
                                            <td colspan="2" class="formField"><novalibra:NLTextBox ID="eachCaseHeight" runat="server" MaxLength="15" Width="75" ChangeControl="true"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="eachCaseWidthFL" class="formLabel">Each Case Pack Width:</td>
                                            <td colspan="2" class="formField"><novalibra:NLTextBox ID="eachCaseWidth" runat="server" MaxLength="15" Width="75" ChangeControl="true"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="eachCaseLengthFL" class="formLabel">Each Case Pack Length:</td>
                                            <td colspan="2" class="formField"><novalibra:NLTextBox ID="eachCaseLength" runat="server" MaxLength="15" Width="75" ChangeControl="true"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="eachCaseWeightFL" class="formLabel">Each Case Pack Weight:</td>
                                            <td colspan="2" class="formField"><novalibra:NLTextBox ID="eachCaseWeight" runat="server" MaxLength="15" Width="75" ChangeControl="true"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="eachCaseCubeFL" class="formLabel">Each Case Pack Cube:</td>
                                            <td colspan="2" runat="server" id="eachCaseCubeParent" class="formField formGroupEndLabelBottom">
                                                <novalibra:NLTextBox ID="eachCaseCubeEdit" runat="server" MaxLength="15" ReadOnly="true" Width="75" ChangeControl="true" RevertEnabled="false" CssClass="calculatedField"></novalibra:NLTextBox>
                                                <asp:HiddenField ID="eachCaseCube" runat="server" />
                                                <asp:Label ID="eachCaseCubeLabel" runat="server" Text=""></asp:Label>
                                            </td>
                                        </tr>                                   
                                        <tr>
                                            <td  colspan="3" class="formGroupLabel">Inner Case Pack</td>
											<%--<td class="formGroupEndLabel">&nbsp;</td>--%>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="innerCaseHeightFL" class="formLabel">Inner Case Pack Height:</td>
                                            <td colspan="2" class="formField"><novalibra:NLTextBox ID="innerCaseHeight" runat="server" MaxLength="15" Width="75" ChangeControl="true"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="innerCaseWidthFL" class="formLabel">Inner Case Pack Width:</td>
                                            <td colspan="2" class="formField"><novalibra:NLTextBox ID="innerCaseWidth" runat="server" MaxLength="15" Width="75" ChangeControl="true"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="innerCaseLengthFL" class="formLabel">Inner Case Pack Length:</td>
                                            <td colspan="2" class="formField"><novalibra:NLTextBox ID="innerCaseLength" runat="server" MaxLength="15" Width="75" ChangeControl="true"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="innerCaseWeightFL" class="formLabel">Inner Case Pack Weight:</td>
                                            <td colspan="2" class="formField"><novalibra:NLTextBox ID="innerCaseWeight" runat="server" MaxLength="15" Width="75" ChangeControl="true"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="InnerCaseCubeFL" class="formLabel">Inner Case Pack Cube:</td>
                                            <td colspan="2" runat="server" id="InnerCaseCubeParent" class="formField formGroupEndLabelBottom">
                                                <novalibra:NLTextBox ID="InnerCaseCubeEdit" runat="server" MaxLength="15" ReadOnly="true" Width="75" ChangeControl="true" RevertEnabled="false" CssClass="calculatedField"></novalibra:NLTextBox>
                                                <asp:HiddenField ID="InnerCaseCube" runat="server" />
                                                <asp:Label ID="InnerCaseCubeLabel" runat="server" Text=""></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="3" class="formGroupLabel">Master Case Pack</td>
<%--                                            <td class="formField">&nbsp;</td>
--%>                                        </tr>
                                        <tr>
                                            <td runat="server" id="masterCaseHeightFL" class="formLabel">Master Case Pack Height:</td>
                                            <td colspan="2" class="formField"><novalibra:NLTextBox ID="masterCaseHeight" runat="server" MaxLength="15" Width="75" ChangeControl="true"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="masterCaseWidthFL" class="formLabel">Master Case Pack Width:</td>
                                            <td colspan="2" class="formField"><novalibra:NLTextBox ID="masterCaseWidth" runat="server" MaxLength="15" Width="75" ChangeControl="true"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="masterCaseLengthFL" class="formLabel">Master Case Pack Length:</td>
                                            <td colspan="2" class="formField"><novalibra:NLTextBox ID="masterCaseLength" runat="server" MaxLength="15" Width="75" ChangeControl="true"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="masterCaseWeightFL" class="formLabel">Master Case Pack Weight:</td>
                                            <td colspan="2" class="formField"><novalibra:NLTextBox ID="masterCaseWeight" runat="server" MaxLength="15" Width="75" ChangeControl="true"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="MasterCaseCubeFL" class="formLabel">Master Case Pack Cube:</td>
                                            <td colspan="2" runat="server" id="MasterCaseCubeParent" class="formField">
                                                <novalibra:NLTextBox ID="MasterCaseCubeEdit" runat="server" MaxLength="15" ReadOnly="true" Width="75" ChangeControl="true" RevertEnabled="false" CssClass="calculatedField"></novalibra:NLTextBox>
                                                <asp:HiddenField ID="MasterCaseCube" runat="server" />
                                                <asp:Label ID="MasterCaseCubeLabel" runat="server" Text=""></asp:Label>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td><img src="images/spacer.gif" width="1" height="1" alt="" /></td>
                                <td style="width: 33%" valign="top">
                                    <table border="0" cellpadding="2" cellspacing="0">
                                        <tr>
                                            <td colspan="2" class="formGroupLabel">Countries Of Origin</td>
<%--											<td class="formField">&nbsp;</td>
--%>                                        </tr>
                                         
                                        <tr>
                                            <td runat="server" id="CountryOfOriginFL" class="formLabel">Primary Country Of Origin:</td>
                                            <td runat="server" id="CountryOfOriginParent" class="formField" >
                                                <novalibra:NLTextBox ID="CountryOfOriginName" runat="server" Width="200" RenderReadOnly="true" ChangeControl="true" MaxLength="50"></novalibra:NLTextBox>
                                                <div id="CountryOfOriginName_choices" class="autocomplete"></div>
                                                <asp:HiddenField ID="CountryOfOrigin" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="2">
                                                <asp:Table id="additionalCOOTbl" runat="server" border="0" cellpadding="0" cellspacing="0">
                                                    <asp:TableRow>
                                                        <asp:TableCell runat="server" id="additionalCOOFL" class="formLabel"  style="padding-right:2px;" valign="top">Additional COO's:</asp:TableCell>
                                                        <asp:TableCell><span id="CooMsg" class='redText'></span></asp:TableCell>
                                                    </asp:TableRow>
                                                </asp:Table>
                                            </td>
                                        </tr>
<%--                                        </table>
                                        <table border="0" cellpadding="2" cellspacing="0">
                                        
--%>                                        <tr>
                                            <td colspan="2" class="formGroupLabel">Tax Information</td>
<%--											<td class="formField">&nbsp;</td>
--%>                                        </tr>
                                        <tr>
                                            <td runat="server" id="taxUDAFL" class="formLabel">Tax UDA:</td>
                                            <td runat="server" id="taxUDAParent" class="formField">
												<novalibra:NLDropDownList ID="taxUDA" runat="server" ChangeControl="true"></novalibra:NLDropDownList>
<%--												<asp:Label ID="taxUDALabel" runat="server"></asp:Label>
--%>							                    <asp:HiddenField ID="taxUDAValue" runat="server" />
											</td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="taxValueUDAFL" class="formLabel">Tax Value UDA:</td>
                                            <td runat="server" id="taxValueUDAParent" class="formField">
                                                <novalibra:NLTextBox ID="taxValueUDA" runat="server" MaxLength="10" ChangeControl="true"></novalibra:NLTextBox>
<%--                                                <asp:Label ID="taxValueUDALabel" runat="server"></asp:Label>
--%>							                    <asp:HiddenField ID="taxValueUDAValue" runat="server" />
							                </td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="HazardousFL" class="formGroupLabel">Hazardous</td>
											<td class="formField">
											    <novalibra:NLDropDownList ID="Hazardous" runat="server" ChangeControl="true"></novalibra:NLDropDownList>&nbsp;
										    </td>
                                        </tr>
                                        <tr id="HazardousFlammableRow" runat="server">
                                            <td runat="server" id="HazardousFlammableFL" class="formLabel">Flammable:</td>
                                            <td runat="server" id="HazardousFlammableParent" class="formField">
												<novalibra:NLDropDownList ID="HazardousFlammable" runat="server" ChangeControl="true"></novalibra:NLDropDownList>
											</td>
                                        </tr>
                                        <tr id="HazardousContainerTypeRow" runat="server" >
                                            <td runat="server" id="HazardousContainerTypeFL" class="formLabel">Container Type:</td>
                                            <td runat="server" id="HazardousContainerTypeParent" class="formField">
												<novalibra:NLDropDownList ID="HazardousContainerType" runat="server" ChangeControl="true"></novalibra:NLDropDownList>
											</td>
                                        </tr>
                                        <tr id="HazardousContainerSizeRow" runat="server">
                                            <td runat="server" id="HazardousContainerSizeFL" class="formLabel">Container Size:</td>
                                            <td runat="server" id="HazardousContainerSizeParent" class="formField">
                                                <novalibra:NLTextBox ID="HazardousContainerSize" runat="server" MaxLength="15" ChangeControl="true"></novalibra:NLTextBox>
                                            </td>
                                        </tr>
                                        <tr id="HazardousMSDSUOMRow" runat="server">
                                            <td runat="server" id="HazardousMSDSUOMFL" class="formLabel">MSDS UOM:</td>
                                            <td runat="server" id="HazardousMSDSUOMParent" class="formField">
												<novalibra:NLDropDownList ID="HazardousMSDSUOM" runat="server" ChangeControl="true"></novalibra:NLDropDownList>
                                            </td>
                                        </tr>
                                        <tr id="HazardousManufacturerNameRow" runat="server">
                                            <td runat="server" id="HazardousManufacturerNameFL" class="formLabel">Mfr. Name:</td>
                                            <td runat="server" id="HazardousManufacturerNameParent" class="formField">
                                                <novalibra:NLTextBox ID="HazardousManufacturerName" runat="server" MaxLength="100" ChangeControl="true"></novalibra:NLTextBox>
                                            </td>
                                        </tr>
                                        <tr id="HazardousManufacturerCityRow" runat="server">
                                            <td runat="server" id="HazardousManufacturerCityFL" class="formLabel">Mfr. City:</td>
                                            <td runat="server" id="HazardousManufacturerCityParent" class="formField">
                                                <novalibra:NLTextBox ID="HazardousManufacturerCity" runat="server" MaxLength="50" ChangeControl="true"></novalibra:NLTextBox>
                                            </td>
                                        </tr>
                                        <tr id="HazardousManufacturerStateRow" runat="server">
                                            <td runat="server" id="HazardousManufacturerStateFL" class="formLabel">Mfr. State:</td>
                                            <td runat="server" id="HazardousManufacturerStateParent" class="formField">
                                                <novalibra:NLTextBox ID="HazardousManufacturerState" runat="server" MaxLength="50" ChangeControl="true"></novalibra:NLTextBox>
                                            </td>
                                        </tr>
                                        <tr id="HazardousManufacturerPhoneRow" runat="server">
                                            <td runat="server" id="HazardousManufacturerPhoneFL" class="formLabel">Mfr. Phone:</td>
                                            <td runat="server" id="HazardousManufacturerPhoneParent" class="formField">
                                                <novalibra:NLTextBox ID="HazardousManufacturerPhone" runat="server" MaxLength="20" ChangeControl="true"></novalibra:NLTextBox>
                                            </td>
                                        </tr>
                                        <tr id="HazardousManufacturerCountryRow" runat="server">
                                            <td runat="server" id="HazardousManufacturerCountryFL" class="formLabel">Mfr. Country:</td>
                                            <td class="formField formGroupEndLabelBottom">
                                                <novalibra:NLTextBox ID="HazardousManufacturerCountry" runat="server" MaxLength="100" ChangeControl="true"></novalibra:NLTextBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="2" class="formGroupLabel">Special Documents Required</td>
                                        </tr>

                                        <tr>
                                            <td runat="server" id="FumigationCertificateFL"  style="text-align: right; white-space: nowrap;">Phytosanitary Certificate: </td>
                                            <td colspan="2">
                                                <novalibra:NLDropDownList ID="FumigationCertificate" runat="server" ChangeControl="true" >
                                                    <asp:ListItem Text="" Value="" />
                                                    <asp:ListItem Text="No" Value="N" />
                                                    <asp:ListItem Text="Yes" Value="Y" />
                                                </novalibra:NLDropDownList>
                                            </td>
                                        </tr>

                                        <tr>
                                            <td runat="server" id="PhytoTemporaryShipmentFL"  style="text-align: right; white-space: nowrap;">Phyto Temporary Shipment:</td>
                                            <td colspan="2">
                                                <novalibra:NLDropDownList ID="PhytoTemporaryShipment" runat="server" ChangeControl="true" >
                                                    <asp:ListItem Text="" Value="" />
                                                    <asp:ListItem Text="No" Value="N" />
                                                    <asp:ListItem Text="Yes" Value="Y" />
                                                </novalibra:NLDropDownList>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="2" class="formGroupLabel">Image / MSDS Sheet</td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="ImageIDFL" class="formLabel">Item Image:</td>
                                            <td runat="server" id="ImageIDParent" class="formField">
                                            
                                                <div id="nlcCCC_ImageID" class="nlcCCC_hide">
                                                <table border="0" cellpadding="0" cellspacing="0"><tr><td>
                                                
                                                <asp:HiddenField ID="ImageID" runat="server" />
                                                <asp:Image ID="I_Image" runat="server" Visible="false" BorderColor="#d3d3a3" BorderWidth="0" Width="16" Height="16" />&nbsp;&nbsp;
                                                <input type="button" id="B_UpdateImage" runat="server" value="Upload" class="formButton" />
                                                <input type="button" id="B_DeleteImage" runat="server" value="Delete" class="formButton" />
                                                
                                                <div id="nlcCCOrigC_ImageID" class="nlcCCOrigC nlcHide">
                                                <span id="ImageID_ORIGS" class="nlcCCT" style="text-align: left;">
                                                <asp:HiddenField ID="ImageID_ORIG" runat="server" value="" />
                                                <asp:Image id="I_Image_ORIG" runat="server" style="border-color:#D3D3A3;border-width:0px;height:16px;width:16px;cursor:hand;" />&nbsp;
                                                &nbsp;
                                                </span></div>
                                                </td><td valign="bottom">
                                                <div id="nlcCCRevert_ImageID" runat="server" class="nlcCCRevert nlcHide" onclick="undoImage();"></div>
                                                </td></tr></table>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="MSDSIDFL" class="formLabel">MSDS Sheet:</td>
                                            <td runat="server" id="MSDSIDParent" class="formField">
                                            
                                                <div id="nlcCCC_MSDSID" class="nlcCCC_hide">
                                                <table border="0" cellpadding="0" cellspacing="0"><tr><td>
                                            
                                                <asp:HiddenField ID="MSDSID" runat="server" />
                                                <asp:Image ID="I_MSDS" runat="server" Visible="false" BorderColor="#d3d3a3" BorderWidth="0" Width="16" Height="16" />&nbsp;&nbsp;
                                                <input type="button" id="B_UpdateMSDS" runat="server" value="Upload" class="formButton" />
					                            <input type="button" id="B_DeleteMSDS" runat="server" value="Delete" class="formButton" />
					                            
					                            <div id="nlcCCOrigC_MSDSID" class="nlcCCOrigC nlcHide">
                                                <span id="MSDSID_ORIGS" class="nlcCCT" style="text-align: left;">
                                                <asp:HiddenField ID="MSDSID_ORIG" runat="server" value="" />
                                                <asp:Image id="I_MSDS_ORIG" runat="server" style="border-color:#D3D3A3;border-width:0px;height:16px;width:16px;cursor:hand;" />&nbsp;
                                                &nbsp;
                                                </span></div>
                                                </td><td valign="bottom">
                                                <div id="nlcCCRevert_MSDSID" runat="server" class="nlcCCRevert nlcHide" onclick="undoImage();"></div>
                                                </td></tr></table>
                                                </div>
					                        
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="5"><img src="images/spacer.gif" width="1" height="2" alt="" /></td>
                            </tr>
                            <tr>
                                <th colspan="5" class="detailFooter">
                                    <table border="0" cellpadding="0" cellspacing="0" style="width: 100%;">
                                        <tr>
                                            <td width="50%" style="width: 50%;" align="left" valign="top">
                                                <input type="button" id="btnCancel" onclick="javascript:window.close()" value="Cancel" class="formButton" runat="server" />&nbsp;
                                            </td>
                                            <td width="50%" style="width: 50%;" align="right" valign="top">
                                                &nbsp;<asp:Button ID="btnUpdate" runat="server" UseSubmitBehavior="false" CommandName="Update" Text="Save" CssClass="formButton" /> 
                                                &nbsp;&nbsp;<asp:Button ID="btnUpdateClose" runat="server" UseSubmitBehavior="false" CommandName="UpdateClose" Text="Save &amp; Close" CssClass="formButton" />
                                            </td>
                                        </tr>
                                    </table>
                                </th>
                            </tr>
                            <tr>
                                <td colspan="5"><img src="images/spacer.gif" width="1" height="2" alt="" /></td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
            <!-- Stocking Strategy Helper -->
            <div id="StockStratHelper" onclick="" onmouseover="" onmouseout="" style="position:absolute; left:300px; top: 450px; display: none; z-index: 3000; width: 500px; background-color: #ececec; border: 1px solid #333333; cursor: default;">
                <div id="StockStratHelperContent">
                    <table border="0" cellpadding="0" cellspacing="0" class="StockStratHelperBG" style="width: 100%">
                    <tr><td>
                        <table border="0" cellpadding="2" cellspacing="1" style="width: 100%;">
                            <tr>
	                            <td id="StockStratHelperHeader"><img align="right" id="Img1" src="images/close.gif" alt="Close" title="" border="0" onclick="StockStratHelperClose();" />Stocking Strategy Helper</td>
	                        </tr>

                            <tr class="StockStratHelperRow">
                                <td>
                                    <asp:UpdatePanel ID="StockStratPanel" runat="server" UpdateMode="Conditional" >
                                        <Triggers>
                                            <asp:AsyncPostBackTrigger ControlID="btnShowStockStrats" EventName="Click" />
                                        </Triggers>
                                        <ContentTemplate>
                                            <table>
                                                <tr>
                                                    <td>Warehouses</td>
                                                    <td>Stocking Strategies</td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <div style="OVERFLOW-Y:scroll; WIDTH:220px; HEIGHT:150px">
                                                            <asp:CheckBoxList ID="chkLstWarehouses" runat="server" CellPadding="1" CellSpacing="1" ></asp:CheckBoxList>
                                                        </div><br />
                                                        <asp:Button id="btnShowStockStrats" runat="server" Cssclass="formButton" Text="Show Strategies" style="font-weight: bold;" OnClientClick="this.disabled=true;" UseSubmitBehavior="false"/>
                                                    </td>
                                                    <td>
                                                        <asp:ListBox ID="LstBoxStockingStrategies" runat="server" Rows="10" SelectionMode="Single">
                                                        </asp:ListBox>
                                                        <asp:Label ID="lblStockStratMsg" runat="server" Font-Bold="true" ForeColor="Red"></asp:Label>
                                                    </td>
                                                </tr>
                                            </table>
                                        </ContentTemplate>
                                    </asp:UpdatePanel>
                                </td>
                            </tr>
                            <tr class="StockStratHelperRow">
	                            <td id="StockStratHelperBlank">&nbsp;</td>
	                        </tr>
	                        <tr class="StockStratHelperFooter">
	                            <td>
	                                <table border="0" cellpadding="0" cellspacing="0" style="width: 100%;" class="StockStratHelperFooter">
	                                    <tr>
	                                        <td align="left"><input type="button" id="btnStockStratHelperClose" onclick="StockStratHelperClose()" value="Cancel" class="formButton" style="font-weight: bold;" /></td>
	                                        <td align="right"><input type="button" id="btnStockStratHelperSelect" onclick="StockStratHelperSave(); onChangeNLC('StockingStrategyCode');" value="Select" class="formButton" style="font-weight: bold;" /></td>
	                                    </tr>
	                                </table>
	                            </td>
	                        </tr>
                        </table>
                    </td></tr>
                    </table>
                </div>
            </div>
        </div>
    </div>
<script language="javascript" type="text/javascript">
<!--
    <% If RefreshGrid Then %>
    //window.parent.opener.location = window.parent.opener.location;
    window.parent.opener.reloadPage();
    <% End If %>
//    <%if CloseForm then %>
//    setTimeout("closeDetailForm();", 250);
//    <%Else%>
//    initPageOnLoad();
//    <%End IF %>
////-->
</script>
    </form>
</body>
</html>
