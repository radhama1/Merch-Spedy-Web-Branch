<%@ Page Language="VB" AutoEventWireup="false" CodeFile="detailform.aspx.vb" Inherits="detailform" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>Add New Item</title>
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE10" />
<link href="css/styles.css" rel="stylesheet" type="text/css" />
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
    list-style-type: none;
    display: block;
    margin: 0;
    padding: 1px;
    cursor: pointer;
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
<script language="javascript" type="text/javascript" src="./detailform.js?v=3>"></script>
<script type="text/javascript" language="javascript">
<!--

//-->
</script>
</head>
<body>
    <form id="form1" runat="server">
    <asp:HiddenField ID="hid" runat="server" />
	<asp:HiddenField ID="recordID" runat="server" />
	<asp:HiddenField ID="itemHeaderID" runat="server" />
	<asp:HiddenField ID="additionalUPCValues" runat="server" />
	<asp:HiddenField ID="dirtyFlag" runat="server" />
	<asp:HiddenField ID="PLIEnglish_Dirty" runat="server" Value="0" />
    <asp:HiddenField ID="PLIFrench_Dirty" runat="server" Value="0" />
    <asp:HiddenField ID="PLISpanish_Dirty" runat="server" Value="0" />
    <asp:HiddenField ID="hdnWorkflowStageID" runat="server" Value="0" />
    <asp:HiddenField ID="ItemTypeAttribute" runat="server" Value="" />
    <asp:HiddenField ID="hdnStageType" runat="server" Value="0" />
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
                                <th colspan="5" align="left"><asp:Label ID="lblHeading" runat="server" Text="Label">Add New Item</asp:Label></th>
                            </tr>
                            <tr>
                                <td align="left" colspan="5" class="subHeading">
                                <asp:Label ID="lblSubHeading" runat="server" Text="Using the fields below, add a new item entry." CssClass="bodyText"></asp:Label>&nbsp;&nbsp;
                                <asp:LinkButton ID="DeleteLink" runat="server" CssClass="">&lt;Delete this Item.&gt;</asp:LinkButton>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="5"><img src="images/spacer.gif" width="1" height="1" alt="" /></td>
                            </tr>
                            <tr>
                                <td style="width: 34%" valign="top">
                                    <table border="0" cellpadding="2" cellspacing="0">
                                        <tr>
                                            <td runat="server" id="addChangeFL" class="formLabel">Add or Change:</td>
                                            <td class="formField">
												<novalibra:NLDropDownList ID="addChange" runat="server">
												</novalibra:NLDropDownList>
											</td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="packItemIndicatorFL" class="formLabel">Pack Item Indicator:</td>
                                            <td class="formField">
												<novalibra:NLDropDownList ID="packItemIndicator" runat="server">
												</novalibra:NLDropDownList>
											</td>
                                        </tr>
                                        <tr>
                                            <td  runat="server" id="QuoteRefNoFL" class="formLabel">Quote Reference Number:</td>
                                            <td class="formField"><novalibra:NLTextBox ID="QuoteReferenceNumber" runat="server" MaxLength="20" RenderReadOnly="true"></novalibra:NLTextBox></td>
                                        </tr>
<%--                                        <tr>
                                            <td runat="server" id="packTypeFL" class="formLabel">Pack Type:</td>
                                            <td class="formField">
												<novalibra:NLDropDownList ID="packType" runat="server">
												</novalibra:NLDropDownList>
											</td>
                                        </tr>
--%>                                        <tr>
                                            <td runat="server" id="michaelsSKUFL" class="formLabel">SKU:</td>
                                            <td class="formField"><novalibra:NLTextBox ID="michaelsSKU" RenderReadOnly="true" ReadOnly="true" runat="server" MaxLength="10"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td  runat="server" id="vendorUPCFL" class="formLabel">Vendor UPC:</td>
                                            <td class="formField"><novalibra:NLTextBox ID="vendorUPC" runat="server" MaxLength="20"></novalibra:NLTextBox></td>
                                        </tr>  
                                        <tr>
                                            <td runat="server" id="additionalUPCFL" class="formLabel" valign="top">Additional UPC(s):</td>
                                            <td runat="server" id="additionalUPCParent" class="formField" style="white-space:nowrap;">
                                                <asp:HiddenField ID="additionalUPCCount" runat="server" value="1" />
                                                <asp:Label ID="additionalUPCs" runat="server">
                                                <input type="text" id="additionalUPC1" maxlength="20" value="" onchange="additionalUPCChanged('1');" /><sup>1</sup>
                                                </asp:Label>
                                                &nbsp;<a href="#" ID="additionalUPCLink" runat="server" onclick="addAdditionalUPC(); return false;">[+]</a>
                                            </td>
                                        </tr>

                                        <!--PMO200141 GTIN14 Enhancements changes Start-->
                                        <tr style="display:none;">
                                            <td  runat="server" id="vendorInnerGTINFL" class="formLabel">Vendor Inner Pack GTIN:</td>
                                            <td class="formField"><novalibra:NLTextBox ID="vendorInnerGTIN" runat="server" MaxLength="14"></novalibra:NLTextBox></td>
                                        </tr> 

                                        <tr style="display:none;">
                                            <td  runat="server" id="vendorCaseGTINFL" class="formLabel">Vendor Case Pack GTIN:</td>
                                            <td class="formField"><novalibra:NLTextBox ID="vendorCaseGTIN" runat="server" MaxLength="14"></novalibra:NLTextBox></td>
                                        </tr> 
                                        <!--PMO200141 GTIN14 Enhancements changes End-->

                                        <tr>
                                            <td runat="server" id="classNumFL" class="formLabel">Class #:</td>
                                            <td class="formField"><novalibra:NLTextBox ID="classNum" runat="server" MaxLength="20"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="subClassNumFL" class="formLabel">Sub-Class #:</td>
                                            <td class="formField"><novalibra:NLTextBox ID="subClassNum" runat="server" MaxLength="20"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="vendorStyleNumFL" class="formLabel">Vendor Style #:</td>
                                            <td class="formField"><novalibra:NLTextBox ID="vendorStyleNum" runat="server" MaxLength="20"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="itemDescFL" class="formLabel">Item Description:</td>
                                            <td class="formField"><novalibra:NLTextBox ID="itemDesc" runat="server" MaxLength="30"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td id="PrivateBrandLabelFL" class="formLabel" valign="top" runat="server">Private Brand Label:</td>
                                            <td class="formField" id="PrivateBrandLabelParent" runat="server">
                                                <novalibra:NLDropDownList ID="PrivateBrandLabel" runat="server"></novalibra:NLDropDownList>
                                                <br />&nbsp;<a href="#" id="pblApplyAll" runat="server">Set for Entire Batch</a>
							                    <asp:HiddenField ID="hdnPBLApplyAll" runat="Server" />
                                            </td>
                                        </tr>
                                        <tr><td colspan="2">&nbsp;</td></tr>
                                        <tr>
							                <td runat="server" id="HarmonizedCodeNumberFL" class="formLabel">Harmonized Code No.:</td>
							                <td class="formField"><novalibra:NLTextBox ID="HarmonizedCodeNumber" runat="server" MaxLength="10" ></novalibra:NLTextBox></td>
							            </tr>
							            <tr>
							                <td runat="server" id="CanadaHarmonizedCodeNumberFL" class="formLabel">Canada Harmonized Code No.:</td>
							                <td class="formField"><novalibra:NLTextBox ID="CanadaHarmonizedCodeNumber" runat="server" MaxLength="10" ></novalibra:NLTextBox></td>
							            </tr>
							            <tr><td colspan="2">&nbsp;</td></tr>
							            <tr>
							                <td runat="server" id="DetailInvoiceCustomsDescFL" class="formLabel">Detail Invoice / Customs Description:</td>
							                <td class="formField"><novalibra:NLTextBox ID="DetailInvoiceCustomsDesc" runat="server" Width="210" MaxLength="35" ></novalibra:NLTextBox></td>
							            </tr>
							            <tr>
							                <td runat="server" id="ComponentMaterialBreakdownFL" class="formLabel">Component / Material Breakdown by %:</td>
							                <td class="formField"><novalibra:NLTextBox ID="ComponentMaterialBreakdown" runat="server" Width="210" MaxLength="35" ></novalibra:NLTextBox></td>
							            </tr>
							            <tr><td colspan="2">&nbsp;</td></tr>
  <%--                                      <tr>
                                            <td class="formGroupLabel">Hybrid</td>
                                            <td class="formField">&nbsp;</td>
                                        </tr>--%>
                                        <tr>
                                            <td runat="server" id="StockingStrategyFL" class="formLabel">Stocking Strategy:</td>
                                            <td class="formField">
												<novalibra:NLDropDownList ID="StockingStrategyCode" runat="server">
												</novalibra:NLDropDownList>
                                                <input type="button" id="btnStockStratHelper" runat="server" value="Helper" class="formButton" onclick="showStockStratHelper();" />&nbsp;&nbsp;
                                            </td>
                                        </tr>
<%--                                        <tr>
                                            <td runat="server" id="hybridTypeFL" class="formLabel">Hybrid Type:</td>
                                            <td class="formField">
												<novalibra:NLDropDownList ID="hybridType" runat="server">
												</novalibra:NLDropDownList>
											</td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="hybridSourceDCFL" class="formLabel" visible="false">Source DC:</td>
                                            <td class="formField">
												<novalibra:NLDropDownList ID="hybridSourceDC" runat="server" visible="false">
												</novalibra:NLDropDownList></td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="hybridLeadTimeFL" class="formLabel">Lead Time:</td>
                                            <td class="formField"><novalibra:NLTextBox ID="hybridLeadTime" runat="server" MaxLength="15"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="hybridConversionDateFL" class="formLabel">Conversion Date:</td>
                                            <td class="formField">
                                                <novalibra:NLTextBox ID="hybridConversionDateEdit" runat="server" MaxLength="10" ReadOnly="true" CssClass="calculatedField"></novalibra:NLTextBox>
                                                <asp:HiddenField ID="hybridConversionDate" runat="server" />
                                            </td>
                                        </tr>--%>
<%--                                        <tr>
											<td class="formLabel">&nbsp;</td>
                                            <td class="formGroupEndLabel">&nbsp;</td>
                                        </tr>--%>
                                        <tr id="qtyInPackRow" runat="server">
                                            <td runat="server" id="qtyInPackFL" class="formLabel">Component Qty Ea:</td>
                                            <td class="formField"><novalibra:NLTextBox ID="qtyInPack" runat="server" MaxLength="15"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="eachesMasterCaseFL" class="formLabel">Eaches in Master Case:</td>
                                            <td class="formField"><novalibra:NLTextBox ID="eachesMasterCase" runat="server" MaxLength="15"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="eachesInnerPackFL" class="formLabel">Eaches in Inner Pack:</td>
                                            <td class="formField"><novalibra:NLTextBox ID="eachesInnerPack" runat="server" MaxLength="15"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="prePricedFL" class="formLabel">Pre-Priced:</td>
                                            <td class="formField">
												<novalibra:NLDropDownList ID="prePriced" runat="server">
												</novalibra:NLDropDownList></td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="prePricedUDAFL" class="formLabel">Pre-Priced UDA:</td>
                                            <td class="formField">
												<novalibra:NLDropDownList ID="prePricedUDA" runat="server">
												</novalibra:NLDropDownList></td>
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
                                                <novalibra:NLDropDownList ID="PLIEnglish" runat="server" >
							                        <asp:ListItem Text="" Value="" />
							                        <asp:ListItem Text="No" Value="N" />
							                        <asp:ListItem Text="Yes" Value="Y" />
			                                    </novalibra:NLDropDownList>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="PLIFrenchFL"  style="text-align: right; white-space: nowrap;">Canadian French: </td>
                                            <td colspan="2">
                                                <novalibra:NLDropDownList ID="PLIFrench" runat="server" >
			                                        <asp:ListItem Text="" Value="" />
							                        <asp:ListItem Text="No" Value="N" />
							                        <asp:ListItem Text="Yes" Value="Y" />
			                                    </novalibra:NLDropDownList> 
                                                &nbsp;
                                                <asp:Label ID="ExemptEndDateFrenchFL" runat="server" Text="Exempt End Date:" />
                                                <novalibra:NLTextBox ID="ExemptEndDateFrench" runat="server" ReadOnly="true" RenderReadOnly="true"/>
                                                
                                            </td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="PLISpanishFL"  style="text-align: right; white-space: nowrap;">Latin American Spanish: </td>
                                            <td colspan="2">
                                                <novalibra:NLDropDownList ID="PLISpanish" runat="server" >
			                                        <asp:ListItem Text="" Value="" />
							                        <asp:ListItem Text="No" Value="N" />
							                        <asp:ListItem Text="Yes" Value="Y" />
			                                    </novalibra:NLDropDownList>
                                            </td>
                                        </tr>
                                        <tr><td colspan="3">&nbsp;</td></tr>
                                        <tr>
                                            <td runat="server" id="CustomsDescriptionFL"  style="text-align: right; white-space: nowrap;">Customs Description: </td>
                                            <td colspan="2"><novalibra:NLTextBox ID="CustomsDescription" runat="server"  Width="200" MaxLength="150" /> </td>
                                        </tr>
                                        <tr><td colspan="3">&nbsp;</td></tr>
                                        <tr>
                                            <td runat="server" id="TIs" style="text-align: right; white-space: nowrap;">Translation Indicators: </td>
                                            <td colspan="2" >&nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="TIEnglishFL"  style="text-align: right; white-space: nowrap;">English: </td>
                                            <td colspan="2">
                                                <novalibra:NLDropDownList ID="TIEnglish" runat="server" >
			                                        <asp:ListItem Text="" Value="" />
							                        <asp:ListItem Text="No" Value="N" />
							                        <asp:ListItem Text="Yes" Value="Y" />
			                                    </novalibra:NLDropDownList>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="TIFrenchFL"  style="text-align: right; white-space: nowrap;">Canadian French: </td>
                                            <td colspan="2">
                                                <novalibra:NLDropDownList ID="TIFrench" runat="server" >
			                                        <asp:ListItem Text="" Value="" />
							                        <asp:ListItem Text="No" Value="N" />
							                        <asp:ListItem Text="Yes" Value="Y" />
			                                    </novalibra:NLDropDownList>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="TISpanishFL"  style="text-align: right; white-space: nowrap;">Latin American Spanish: </td>
                                            <td colspan="2">
                                                <novalibra:NLDropDownList ID="TISpanish" runat="server" Enabled="false" >
			                                        <asp:ListItem Text="" Value="" />
							                        <asp:ListItem Text="No" Value="N" Selected="True" />
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
                                                <div id="English_Descriptions">
                                                    <table cellpadding="3" cellspacing="0" border="0">
                                                        <tr>
                                                            <td runat="server" id="EnglishShortDescriptionFL"  style="padding-left:50px;text-align: right; white-space: nowrap;">English &nbsp;<br /> Short Description: &nbsp;</td>
                                                            <td><novalibra:NLTextBox ID="EnglishShortDescription" runat="server"  Width="200" MaxLength="17" /></td>
                                                        </tr>
                                                        <tr>
                                                            <td runat="server" id="EnglishLongDescriptionFL"  style="text-align: right; white-space: nowrap;">English &nbsp;<br /> Long Description: &nbsp;<br />(max 100 chars.) &nbsp;</td>
                                                            <td><novalibra:NLTextBox ID="EnglishLongDescription" runat="server"  Width="200" MaxLength="100" TextMode="MultiLine" Height="50" /></td>
                                                        </tr>
                                                     </table>
                                                     <br />
                                                 </div>
                                                 <div id="French_Descriptions">
                                                    <table cellpadding="3" cellspacing="0" border="0">
                                                        <tr>
                                                            <td runat="server" id="FrenchShortDescriptionFL"  style="padding-left:50px;text-align: right; white-space: nowrap;">Canadian French &nbsp;<br /> Short Description: &nbsp;</td>
                                                            <td><novalibra:NLTextBox ID="FrenchShortDescription" runat="server"  Width="200" MaxLength="17" /></td>
                                                        </tr>
                                                        <tr>
                                                            <td runat="server" id="FrenchLongDescriptionFL"  style="text-align: right; white-space: nowrap;">Canadian French &nbsp;<br /> Long Description: &nbsp;<br />(max 150 chars.) &nbsp;</td>
                                                            <td><novalibra:NLTextBox ID="FrenchLongDescription" runat="server"  Width="200" MaxLength="150" TextMode="MultiLine" Height="50" /></td>
                                                        </tr>
                                                     </table>
                                                     <br />
                                                 </div>
                                                 <div id="Spanish_Descriptions">
                                                    <table cellpadding="3" cellspacing="0" border="0">
                                                        <tr>
                                                            <td runat="server" id="SpanishShortDescriptionFL"  style="padding-left:23px;text-align: right; white-space: nowrap;">Latin American Spanish &nbsp;<br /> Short Description: &nbsp;</td>
                                                            <td><novalibra:NLTextBox ID="SpanishShortDescription" runat="server"  Width="200" MaxLength="17" /></td>
                                                        </tr>
                                                        <tr>
                                                            <td runat="server" id="SpanishLongDescriptionFL"  style="text-align: right; white-space: nowrap;">Latin American Spanish &nbsp;<br /> Long Description: &nbsp;<br />(max 150 chars.) &nbsp;</td>
                                                            <td><novalibra:NLTextBox ID="SpanishLongDescription" runat="server"  Width="200" MaxLength="150" TextMode="MultiLine" Height="50" /></td>
                                                        </tr>
                                                     </table>
                                                 </div>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td><img src="images/spacer.gif" width="1" height="1" alt="" /></td>
                                <td style="width: 33%" valign="top">
                                    <table border="0" cellpadding="2" cellspacing="0">
                                        <tr>
                                            <td class="formGroupLabel">Costs</td>
											<td class="formField">&nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="USCostFL" class="formLabel">US Cost ($ each):</td>
                                            <td class="formField"><novalibra:NLTextBox ID="USCost" runat="server" MaxLength="20"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="totalUSCostFL" class="formLabel">Total US Cost ($ each):</td>
                                            <td runat="server" id="totalUSCostParent" class="formField">
                                                <novalibra:NLTextBox ID="totalUSCostEdit" runat="server" MaxLength="15" ReadOnly="true" CssClass="calculatedField"></novalibra:NLTextBox>
                                                <asp:HiddenField ID="totalUSCost" runat="server" />
                                                <asp:Label ID="totalUSCostLabel" runat="server" Text=""></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="canadaCostFL" class="formLabel">Canada Cost ($ each):</td>
                                            <td class="formField"><novalibra:NLTextBox ID="canadaCost" runat="server" MaxLength="20"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="totalCanadaCostFL" class="formLabel">Total Canada Cost ($ each):</td>
                                            <td runat="server" id="totalCanadaCostParent" class="formField formGroupEndLabelBottom">
                                                <novalibra:NLTextBox ID="totalCanadaCostEdit" runat="server" MaxLength="15" ReadOnly="true" CssClass="calculatedField"></novalibra:NLTextBox>
                                                <asp:HiddenField ID="totalCanadaCost" runat="server" />
                                                <asp:Label ID="totalCanadaCostLabel" runat="server" Text=""></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="formGroupLabel">Retails</td>
											<td class="formField">&nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="baseRetailFL" class="formLabel">Low Elas3 (29):</td>
                                            <td class="formField"><novalibra:NLTextBox ID="baseRetail" runat="server" MaxLength="20"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="centralRetailFL" class="formLabel">High Elas3 (28):</td>
                                            <td class="formField">
                                            <novalibra:NLTextBox ID="centralRetailEdit" runat="server" MaxLength="20"></novalibra:NLTextBox>
                                            <asp:HiddenField ID="centralRetail" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="testRetailFL" class="formLabel">Do Not Use (3):</td>
                                            <td class="formField">
                                            <novalibra:NLTextBox ID="testRetailEdit" runat="server" MaxLength="20"></novalibra:NLTextBox>
                                            <asp:HiddenField ID="testRetail" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="alaskaRetailFL" class="formLabel">High Cost (27):</td>
                                            <td class="formField">
                                            <novalibra:NLTextBox ID="alaskaRetail" runat="server" MaxLength="20"></novalibra:NLTextBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="canadaRetailFL" class="formLabel">Canada (5):</td>
                                            <td class="formField">
                                            <novalibra:NLTextBox ID="canadaRetail" runat="server" MaxLength="20"></novalibra:NLTextBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="zeroNineRetailFL" class="formLabel">Canada2 (16):</td>
                                            <td class="formField">
                                            <novalibra:NLTextBox ID="zeroNineRetailEdit" runat="server" MaxLength="20"></novalibra:NLTextBox>
                                            <asp:HiddenField ID="zeroNineRetail" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="californiaRetailFL" class="formLabel">Canada E-Comm (17):</td>
                                            <td class="formField">
                                            <novalibra:NLTextBox ID="californiaRetailEdit" runat="server" MaxLength="20"></novalibra:NLTextBox>
                                            <asp:HiddenField ID="californiaRetail" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="villageCraftRetailFL" class="formLabel">Do Not Use (8):</td>
                                            <td class="formField">
                                            <novalibra:NLTextBox ID="villageCraftRetailEdit" runat="server" MaxLength="20"></novalibra:NLTextBox>
                                            <asp:HiddenField ID="villageCraftRetail" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="Retail9FL" class="formLabel">Do Not Use (9):</td>
                                            <td class="formField">
                                            <novalibra:NLTextBox ID="Retail9Edit" runat="server" MaxLength="20"></novalibra:NLTextBox>
                                            <asp:HiddenField ID="Retail9" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="Retail10FL" class="formLabel">Do Not Use (10):</td>
                                            <td class="formField">
                                            <novalibra:NLTextBox ID="Retail10Edit" runat="server" MaxLength="20"></novalibra:NLTextBox>
                                            <asp:HiddenField ID="Retail10" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="Retail11FL" class="formLabel">Do Not Use (11):</td>
                                            <td class="formField">
                                            <novalibra:NLTextBox ID="Retail11Edit" runat="server" MaxLength="20"></novalibra:NLTextBox>
                                            <asp:HiddenField ID="Retail11" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="Retail12FL" class="formLabel">Do Not Use (12):</td>
                                            <td class="formField">
                                            <novalibra:NLTextBox ID="Retail12Edit" runat="server" MaxLength="20"></novalibra:NLTextBox>
                                            <asp:HiddenField ID="Retail12" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="Retail13FL" class="formLabel">E-Comm (21):</td>
                                            <td class="formField">
                                            <novalibra:NLTextBox ID="Retail13Edit" runat="server" MaxLength="20" ></novalibra:NLTextBox>
                                            <asp:HiddenField ID="Retail13" runat="server" />
                                            </td>
                                        </tr> 
                                        <tr>
                                            <td runat="server" id="RDQuebecFL" class="formLabel">Quebec (14):</td>
                                            <td class="formField">
                                            <novalibra:NLTextBox ID="RDQuebecEdit" runat="server" MaxLength="20" ></novalibra:NLTextBox>
                                            <asp:HiddenField ID="RDQuebec" runat="server" />
                                            </td>
                                        </tr> 
                                        <tr>
                                            <td runat="server" id="RDPuertoRicoFL" class="formLabel">Comp (30):</td>
                                            <td class="formField">
                                            <novalibra:NLTextBox ID="RDPuertoRicoEdit" runat="server" MaxLength="20" ></novalibra:NLTextBox>
                                            <asp:HiddenField ID="RDPuertoRico" runat="server" />
                                            </td>
                                        </tr>  
                                        <tr>
                                            <td class="formGroupLabel">Each Case Pack</td>
											<td class="formGroupEndLabel">&nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="eachCaseHeightFL" class="formLabel">Each Case Pack Height:</td>
                                            <td class="formField"><novalibra:NLTextBox ID="eachCaseHeight" runat="server" MaxLength="15"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="eachCaseWidthtFL" class="formLabel">Each Case Pack Width:</td>
                                            <td class="formField"><novalibra:NLTextBox ID="eachCaseWidth" runat="server" MaxLength="15"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="eachCaseLengthFL" class="formLabel">Each Case Pack Length:</td>
                                            <td class="formField"><novalibra:NLTextBox ID="eachCaseLength" runat="server" MaxLength="15"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="eachCaseWeightFL" class="formLabel">Each Case Pack Weight:</td>
                                            <td class="formField"><novalibra:NLTextBox ID="eachCaseWeight" runat="server" MaxLength="15"></novalibra:NLTextBox></td>
                                        </tr>   
                                        <tr>
                                            <td runat="server" id="eachCasePackCubeFL" class="formLabel">Each Case Pack Cube:</td>
                                            <td runat="server" id="eachCasePackCubeParent" class="formField formGroupEndLabelBottom">
                                                <novalibra:NLTextBox ID="eachCasePackCubeEdit" runat="server" MaxLength="15" ReadOnly="true" CssClass="calculatedField"></novalibra:NLTextBox>
                                                <asp:HiddenField ID="eachCasePackCube" runat="server" />
                                                <asp:Label ID="eachCasePackCubeLabel" runat="server" Text=""></asp:Label>
                                            </td>
                                        </tr>                                      
                                        <tr>
                                            <td class="formGroupLabel">Inner Case Pack</td>
											<td class="formGroupEndLabel">&nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="innerCaseHeightFL" class="formLabel">Inner Case Pack Height:</td>
                                            <td class="formField"><novalibra:NLTextBox ID="innerCaseHeight" runat="server" MaxLength="15"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="innerCaseWidthFL" class="formLabel">Inner Case Pack Width:</td>
                                            <td class="formField"><novalibra:NLTextBox ID="innerCaseWidth" runat="server" MaxLength="15"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="innerCaseLengthFL" class="formLabel">Inner Case Pack Length:</td>
                                            <td class="formField"><novalibra:NLTextBox ID="innerCaseLength" runat="server" MaxLength="15"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="innerCaseWeightFL" class="formLabel">Inner Case Pack Weight:</td>
                                            <td class="formField"><novalibra:NLTextBox ID="innerCaseWeight" runat="server" MaxLength="15"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="innerCasePackCubeFL" class="formLabel">Inner Case Pack Cube:</td>
                                            <td runat="server" id="innerCasePackCubeParent" class="formField formGroupEndLabelBottom">
                                                <novalibra:NLTextBox ID="innerCasePackCubeEdit" runat="server" MaxLength="15" ReadOnly="true" CssClass="calculatedField"></novalibra:NLTextBox>
                                                <asp:HiddenField ID="innerCasePackCube" runat="server" />
                                                <asp:Label ID="innerCasePackCubeLabel" runat="server" Text=""></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="formGroupLabel">Master Case Pack</td>
                                            <td class="formField">&nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="masterCaseHeightFL" class="formLabel">Master Case Pack Height:</td>
                                            <td class="formField"><novalibra:NLTextBox ID="masterCaseHeight" runat="server" MaxLength="15"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="masterCaseWidthFL" class="formLabel">Master Case Pack Width:</td>
                                            <td class="formField"><novalibra:NLTextBox ID="masterCaseWidth" runat="server" MaxLength="15"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="masterCaseLengthFL" class="formLabel">Master Case Pack Length:</td>
                                            <td class="formField"><novalibra:NLTextBox ID="masterCaseLength" runat="server" MaxLength="15"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="masterCaseWeightFL" class="formLabel">Master Case Pack Weight:</td>
                                            <td class="formField"><novalibra:NLTextBox ID="masterCaseWeight" runat="server" MaxLength="15"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="masterCasePackCubeFL" class="formLabel">Master Case Pack Cube:</td>
                                            <td runat="server" id="masterCasePackCubeParent" class="formField">
                                                <novalibra:NLTextBox ID="masterCasePackCubeEdit" runat="server" MaxLength="15" ReadOnly="true" CssClass="calculatedField"></novalibra:NLTextBox>
                                                <asp:HiddenField ID="masterCasePackCube" runat="server" />
                                                <asp:Label ID="masterCasePackCubeLabel" runat="server" Text=""></asp:Label>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td><img src="images/spacer.gif" width="1" height="1" alt="" /></td>
                                <td style="width: 33%" valign="top">
                                    <table border="0" cellpadding="2" cellspacing="0">
                                        <!--
                                        <tr>
                                            <td class="formGroupLabel">Master Case Pack</td>
											<td class="formField">&nbsp;</td>
                                        </tr>
                                        
                                        
                                        <tr>
                                            <td class="formLabel">&nbsp;</td>
                                            <td class="formGroupEndLabel">&nbsp;</td>
                                        </tr>
                                        -->
                                        <tr>
                                            <td runat="server" id="countryOfOriginFL" class="formLabel">Country Of Origin:</td>
                                            <td runat="server" id="countryOfOriginParent" class="formField" >
                                                <novalibra:NLTextBox ID="countryOfOriginName" runat="server" MaxLength="50"></novalibra:NLTextBox>
                                                <div id="countryOfOriginName_choices" class="autocomplete"></div>
                                                <asp:HiddenField ID="countryOfOrigin" runat="server" />
                                            </td>
                                        </tr>
                                        <% If ItemID <> String.Empty Then%>
                                        <tr>
                                            <td runat="server" id="taxWizardCompleteFL" class="formLabel">Tax Wizard:</td>
                                            <td runat="server" id="taxWizardCompleteParent" class="formField">
                                                <a href="#" ID="taxWizardLink" runat="server"><asp:Image ID="taxWizard" runat="server" /></a>
                                                <asp:HiddenField ID="taxWizardComplete" runat="server" />
                                            </td>
                                        </tr>
                                        <% End If %>
                                        <tr>
                                            <td runat="server" id="taxUDAFL" class="formLabel">Tax UDA:</td>
                                            <td runat="server" id="taxUDAParent" class="formField">
												<novalibra:NLDropDownList ID="taxUDA" runat="server">
												</novalibra:NLDropDownList>
												<asp:Label ID="taxUDALabel" runat="server"></asp:Label>
							                    <asp:HiddenField ID="taxUDAValue" runat="server" />
											</td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="taxValueUDAFL" class="formLabel">Tax Value UDA:</td>
                                            <td runat="server" id="taxValueUDAParent" class="formField">
                                                <novalibra:NLTextBox ID="taxValueUDA" runat="server" MaxLength="10"></novalibra:NLTextBox>
                                                <asp:Label ID="taxValueUDALabel" runat="server"></asp:Label>
							                    <asp:HiddenField ID="taxValueUDAValue" runat="server" />
							                </td>
                                        </tr>
                                        <!--
                                        <tr>
                                            <td class="formLabel">Hazardous:</td>
                                            <td class="formField">
												
												</td>
                                        </tr>
                                        -->
                                        <tr>
                                            <td runat="server" id="hazardousFL" class="formGroupLabel">Hazardous</td>
											<td class="formField">
											    <novalibra:NLDropDownList ID="hazardous" runat="server">
												</novalibra:NLDropDownList>&nbsp;
										    </td>
                                        </tr>
                                        <tr id="hazardousFlammableRow" runat="server">
                                            <td runat="server" id="hazardousFlammableFL" class="formLabel">Flammable:</td>
                                            <td runat="server" id="hazardousFlammableParent" class="formField">
												<novalibra:NLDropDownList ID="hazardousFlammable" runat="server">
												</novalibra:NLDropDownList></td>
                                        </tr>
                                        <tr id="hazardousContainerTypeRow" runat="server" >
                                            <td runat="server" id="hazardousContainerTypeFL" class="formLabel">Container Type:</td>
                                            <td runat="server" id="hazardousContainerTypeParent" class="formField">
												<novalibra:NLDropDownList ID="hazardousContainerType" runat="server">
												</novalibra:NLDropDownList></td>
                                        </tr>
                                        <tr id="hazardousContainerSizeRow" runat="server">
                                            <td runat="server" id="hazardousContainerSizeFL" class="formLabel">Container Size:</td>
                                            <td runat="server" id="hazardousContainerSizeParent" class="formField">
                                                <novalibra:NLTextBox ID="hazardousContainerSize" runat="server" MaxLength="15"></novalibra:NLTextBox>
                                            </td>
                                        </tr>
                                        <tr id="hazardousMSDSUOMRow" runat="server">
                                            <td runat="server" id="hazardousMSDSUOMFL" class="formLabel">MSDS UOM:</td>
                                            <td runat="server" id="hazardousMSDSUOMParent" class="formField">
												<novalibra:NLDropDownList ID="hazardousMSDSUOM" runat="server">
												</novalibra:NLDropDownList>
                                            </td>
                                        </tr>
                                        <tr id="hazardousManufacturerNameRow" runat="server">
                                            <td runat="server" id="hazardousManufacturerNameFL" class="formLabel">Mfr. Name:</td>
                                            <td runat="server" id="hazardousManufacturerNameParent" class="formField">
                                                <novalibra:NLTextBox ID="hazardousManufacturerName" runat="server" MaxLength="100"></novalibra:NLTextBox>
                                            </td>
                                        </tr>
                                        <tr id="hazardousManufacturerCityRow" runat="server">
                                            <td runat="server" id="hazardousManufacturerCityFL" class="formLabel">Mfr. City:</td>
                                            <td runat="server" id="hazardousManufacturerCityParent" class="formField">
                                                <novalibra:NLTextBox ID="hazardousManufacturerCity" runat="server" MaxLength="50"></novalibra:NLTextBox>
                                            </td>
                                        </tr>
                                        <tr id="hazardousManufacturerStateRow" runat="server">
                                            <td runat="server" id="hazardousManufacturerStateFL" class="formLabel">Mfr. State:</td>
                                            <td runat="server" id="hazardousManufacturerStateParent" class="formField">
                                                <novalibra:NLTextBox ID="hazardousManufacturerState" runat="server" MaxLength="50"></novalibra:NLTextBox>
                                            </td>
                                        </tr>
                                        <tr id="hazardousManufacturerPhoneRow" runat="server">
                                            <td runat="server" id="hazardousManufacturerPhoneFL" class="formLabel">Mfr. Phone:</td>
                                            <td runat="server" id="hazardousManufacturerPhoneParent" class="formField">
                                                <novalibra:NLTextBox ID="hazardousManufacturerPhone" runat="server" MaxLength="20"></novalibra:NLTextBox>
                                            </td>
                                        </tr>
                                        <tr id="hazardousManufacturerCountryRow" runat="server">
                                            <td runat="server" id="hazardousManufacturerCountryFL" class="formLabel">Mfr. Country:</td>
                                            <td class="formField formGroupEndLabelBottom">
                                                <novalibra:NLTextBox ID="hazardousManufacturerCountry" runat="server" MaxLength="100"></novalibra:NLTextBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="formGroupLabel">Like Item Approval</td>
											<td class="formField">&nbsp;</td>
                                        </tr>
                                        <tr>
					                        <td align="right">Selected Forecast Type:</td>
					                        <td>
					                        <novalibra:NLTextBox ID="tb_CalcOptions" runat="server" RenderReadOnly ="true"> </novalibra:NLTextBox>
					                         &nbsp Store Total:
					                        <novalibra:NLTextBox ID="storeTotal" runat="server" RenderReadOnly ="true"> </novalibra:NLTextBox></td>
					                    </tr>    
                                        <tr>
					                        <td runat="server" id="likeItemSKUFL" class="formLabel">Like Item SKU:</td>
					                        <td class="formField">
						                        <novalibra:NLTextBox ID="likeItemSKU" runat="server" MaxLength="20" ></novalibra:NLTextBox>
					                        </td>
				                        </tr>
				                        <tr>
					                        <td runat="server" id="likeItemDescriptionFL" class="formLabel">Like Item Description:</td>
					                        <td class="formField">
						                        <novalibra:NLTextBox ID="likeItemDescriptionEdit" runat="server" ReadOnly="true" CssClass="calculatedField"></novalibra:NLTextBox>
                                                <asp:HiddenField ID="likeItemDescription" runat="server" />
					                        </td>
				                        </tr>
				                        <tr>
					                        <td runat="server" id="likeItemRetailFL" class="formLabel">Like Item Retail $:</td>
					                        <td class="formField">
						                        <novalibra:NLTextBox ID="likeItemRetailEdit" runat="server" ReadOnly="true" CssClass="calculatedField"></novalibra:NLTextBox>
                                                <asp:HiddenField ID="likeItemRetail" runat="server" />
					                        </td>
				                        </tr>
				                        <tr>
					                        <td runat="server" id="AnnualRegularUnitForecastFL" class="formLabel">Annual Regular Unit Forecast (52 week):</td>
					                        <td class="formField">
						                        <novalibra:NLTextBox ID="AnnualRegularUnitForecastEdit" runat="server" ReadOnly="true" CssClass="calculatedField"></novalibra:NLTextBox>
                                                <asp:HiddenField ID="AnnualRegularUnitForecast" runat="server" />
					                        </td>
				                        </tr>
				                        <tr>
					                        <td runat="server" id="LikeItemUnitStoreMonthFL" class="formLabel">Avg Reg Units/Store/Month:</td>
					                        <td class="formField">
						                        <novalibra:NLTextBox ID="LikeItemUnitStoreMonthEdit" runat="server" ReadOnly="true" CssClass="calculatedField"></novalibra:NLTextBox>
                                                <asp:HiddenField ID="LikeItemUnitStoreMonth" runat="server" />
					                        </td>
				                        </tr>
				                        <tr>
                                            <td runat="server" id="LikeItemStoreCountFL" class="formLabel">Like Item Store Count:</td>
                                            <td class="formField" style="height: 20px">
                                                 <novalibra:NLTextBox ID="LikeItemStoreCount" runat="server" MaxLength="4"></novalibra:NLTextBox></td>
                                        </tr>
				                        <tr>
					                        <td runat="server" id="LikeItemRegularUnitFL" class="formLabel">"Seasonality" Like Item Regular Unit (52 week):</td>
					                        <td class="formField">
						                        <novalibra:NLTextBox ID="LikeItemRegularUnit" runat="server" MaxLength="14" ></novalibra:NLTextBox>
					                        </td>
				                        </tr>
				                        <tr>
					                        <td runat="server" id="AnnualRegRetailSalesFL" class="formLabel">Annual Reg Retail Sales $:</td>
					                        <td class="formField">
						                        <novalibra:NLTextBox ID="AnnualRegRetailSalesEdit" runat="server" ReadOnly="true" CssClass="calculatedField"></novalibra:NLTextBox>
                                                <asp:HiddenField ID="AnnualRegRetailSales" runat="server" />
					                        </td>
				                        </tr>
				                        <tr>
					                        <td runat="server" id="facingsFL" class="formLabel">Facings:</td>
					                        <td class="formField">
						                        <novalibra:NLTextBox ID="facings" runat="server" MaxLength="3" ></novalibra:NLTextBox>
					                        </td>
				                        </tr>
				                        <tr>
					                        <td runat="server" id="POGMinQtyFL" class="formLabel">PQPF (Min Pres per Facing):</td>
					                        <td class="formField">
						                        <novalibra:NLTextBox ID="POGMinQty" runat="server" MaxLength="3" ></novalibra:NLTextBox>
					                        </td>
				                        </tr>
				                        <tr>
                                            <td runat="server" id="POGMaxQtyFL" class="formLabel">POG Max Qty:</td>
                                            <td class="formField"><novalibra:NLTextBox ID="POGMaxQty" runat="server" MaxLength="15"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="POGSetupPerStoreFL" class="formLabel">Initial Set Qty Per Store:</td>
                                            <td class="formField"><novalibra:NLTextBox ID="POGSetupPerStore" runat="server" MaxLength="20"></novalibra:NLTextBox></td>
                                        </tr>
                                        <tr>
                                            <td class="formGroupLabel">Special Documents Required</td>
											<td class="formField">&nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="PhytoSanitaryCertificateFL"  style="text-align: right; white-space: nowrap;">Phytosanitary Certificate: </td>
                                            <td colspan="2">
                                                <novalibra:NLDropDownList ID="PhytoSanitaryCertificate" runat="server" >
			                                        <asp:ListItem Text="" Value="" />
			                                        <asp:ListItem Text="No" Value="N" />
			                                        <asp:ListItem Text="Yes" Value="Y" />
		                                        </novalibra:NLDropDownList>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="PhytoTemporaryShipmentFL"  style="text-align: right; white-space: nowrap;">Phyto Temporary Shipment: </td>
                                            <td colspan="2">
                                                <novalibra:NLDropDownList ID="PhytoTemporaryShipment" runat="server" >
			                                        <asp:ListItem Text="" Value="" />
			                                        <asp:ListItem Text="No" Value="N" />
			                                        <asp:ListItem Text="Yes" Value="Y" />
		                                        </novalibra:NLDropDownList>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="formGroupLabel">Image / MSDS Sheet</td>
											<td class="formField">&nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="ImageIDFL" class="formLabel">Item Image:</td>
                                            <td runat="server" id="ImageIDParent" class="formField">
                                                <asp:HiddenField ID="ImageID" runat="server" />
                                                <asp:Image ID="I_Image" runat="server" Visible="false" BorderColor="#d3d3a3" BorderWidth="0" Width="16" Height="16" />&nbsp;&nbsp;
                                                <input type="button" id="B_UpdateImage" runat="server" value="Upload" class="formButton" />
                                                <input type="button" id="B_DeleteImage" runat="server" value="Delete" class="formButton" />
                                                <!--<span class="subHeading" id="I_Image_Label" runat="server">(view)</span>-->
                                            </td>
                                        </tr>
                                        <tr>
                                            <td runat="server" id="MSDSIDFL" class="formLabel">MSDS Sheet:</td>
                                            <td runat="server" id="MSDSIDParent" class="formField">
                                            <asp:HiddenField ID="MSDSID" runat="server" />
                                            <asp:Image ID="I_MSDS" runat="server" Visible="false" BorderColor="#d3d3a3" BorderWidth="0" Width="16" Height="16" />&nbsp;&nbsp;
                                            <input type="button" id="B_UpdateMSDS" runat="server" value="Upload" class="formButton" />
					                        <input type="button" id="B_DeleteMSDS" runat="server" value="Delete" class="formButton" />
					                        <!--<span class="subHeading" id="I_MSDS_Label" runat="server">(view)</span>-->
                                            </td>
                                        </tr>
                                        
                                        <!-- BEGIN CUSTOM FIELDS -->
                                        <% If Me.custFields.FieldCount > 0 Then%>
                                        <tr>
                                            <td class="formGroupLabel">Custom Fields</td>
											<td class="formField">&nbsp;</td>
                                        </tr>
                                        <novalibra:NLCustomFields ID="custFields" runat="server"></novalibra:NLCustomFields>
                                        <% End If %>
                                        <!-- END CUSTOM FIELDS -->
                                        
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
                                                <input type="button" id="btnCancel" onclick="javascript:window.close()" value="Cancel" class="formButton" />&nbsp;
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
            <div id="StockStratHelper" onclick="" onmouseover="" onmouseout="" style="position:absolute; left:300px; top: 500px; display: none; z-index: 3000; width: 500px; background-color: #ececec; border: 1px solid #333333; cursor: default;">
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
	                                        <td align="right"><input type="button" id="btnStockStratHelperSelect" onclick="StockStratHelperSave()" value="Select" class="formButton" style="font-weight: bold;" /></td>
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
    <%if CloseForm then %>
    setTimeout("closeDetailForm();", 250);
    <%Else%>
    initPageOnLoad();
    <%End IF %>
//-->
</script>
    </form>
</body>
</html>
