<%@ Page Language="VB" AutoEventWireup="false" CodeFile="detail.aspx.vb" Inherits="detail" %>
<%@ Register Src="~/CORALControls/pageheader.ascx" TagName="pageheader" TagPrefix="uclayout" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
	<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE10" />
    <title>Item Data Management</title>
	<link rel="stylesheet" href="css/styles.css" type="text/css" />
<style type="text/css">
th { text-align: left; padding: 5px; }
.formLabel
{
    /*padding-left: 2px;
    padding-right: 2px;*/
	width: 124px;
	text-align: right;
	white-space: nowrap;
	height: 21px;
	line-height: 21px;
}
.formField
{
	/*padding-left: 2px;
    padding-right: 2px;*/
	
	width: 174px;
	height: 21px;
	line-height: 21px;
	text-align: left;
}
</style>

	<script type="text/javascript">
<!--

function showExcel()
{
	//var win = window.open('detailexport.aspx?hid=<%=GetItemHeaderID()%>','itemExport','scrollbars=0,location=0,menubar=0,titlebar=0,toolbar=0,width=400,HEIGHT=300');
	//return false;
	document.location = 'detailexport.aspx?hid=<%=GetItemHeaderID()%>';
	return false;
}

//-->
	</script>
	<link href="novagrid/novagrid.css?v=<%=ConfigurationManager.AppSettings("AppVersion")%>" rel="stylesheet" type="text/css" />
	<link href="novagrid/lightbox.css?v=<%=ConfigurationManager.AppSettings("AppVersion")%>" rel="stylesheet" type="text/css" />
<script type="text/javascript" language="javascript" src="include/global.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
<script language="javascript" type="text/javascript" src="novagrid/prototype.js"></script>
<script language="javascript" type="text/javascript" src="novagrid/scriptaculous.js"></script>
<script language="javascript" type="text/javascript" src="novagrid/novagrid.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
<script language="javascript" type="text/javascript" src="novagrid/lightbox.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
<script language="javascript" type="text/javascript" src="./detail.js" defer></script>

</head>
<body oncontextmenu="return false;" onload="preloadItemImages();" style="background-color:#dedede">
    <form id="form1" runat="server">
		<asp:HiddenField ID="hid" runat="server" />
	<div id="sitediv">
		<div id="bodydiv">
			<div id="header">
				<uclayout:pageheader ID="headerControl" RefreshOnUpload="false" runat="server" />
			</div>
			<div id="content">
				<div id="submissiondetail">
					<div style="padding:10px;">
						<table border="0" cellpadding="0" cellspacing="0" width="100%">
						    <tr>
						        <td valign="bottom" style="width:<%=IIf(ItemHeaderID > 0, "209", "109")%>px;">
						        <table cellpadding="0" cellspacing="0" border="0" width="<%=IIf(ItemHeaderID > 0, "209", "109")%>" height="30">
						            <tr>
						                <td id="itemHeaderTab" width="109" height="30" class="tabItemHeader tabItemHeaderOn" align="right" valign="bottom" onclick="goUrl('detail.aspx?hid=<%=Request("hid")%>');">
						                <span>Item Header</span>&nbsp;<img runat="server" id="itemHeaderImage" src="images/spacer.gif" alt="" width="11" height="11" border="0" />
						                </td>
						                <%If ItemHeaderID > 0 Then%>
						                <td id="itemDetailTab" width="100" height="30" class="tabItemDetail tabItemDetailOff" align="right" valign="bottom" onclick="goUrl('detailitems.aspx?hid=<%=Request("hid")%>');" onmouseover="Element.removeClassName('itemDetailTab', 'tabItemDetailOff');Element.addClassName('itemDetailTab', 'tabItemDetailOn');" onmousedown="Element.removeClassName('itemDetailTab', 'tabItemDetailOff');Element.addClassName('itemDetailTab', 'tabItemDetailOn');" onmouseout="Element.removeClassName('itemDetailTab', 'tabItemDetailOn');Element.addClassName('itemDetailTab', 'tabItemDetailOff');">
						                <span>Item Detail</span>&nbsp;<img runat="server" id="itemDetailImage" src="images/spacer.gif" alt="" width="11" height="11" border="0" />
						                </td>
						                <%End If%>
						            </tr>
						        </table>
						        </td>
						        <td style="width: 15px;"><img src="images/spacer.gif" border="0" alt="" height="1" width="15" /></td>
						        <td style="width: 10px;" valign="bottom">
						            <table cellpadding="0" cellspacing="0" border="0">
						            <tr>
						                <td style="height: 22px; white-space: nowrap;" valign="middle" align="left" nowrap="nowrap">
                                            <asp:HyperLink ID="linkExcel" runat="server" NavigateUrl="#">Excel</asp:HyperLink>
						                </td>
						            </tr>
						            </table>
						        </td>
						        <td style="width: 50px;"><img src="images/spacer.gif" border="0" alt="" height="1" width="50" /></td>
						        <td>
                                    <novalibra:NLValidationSummary ID="validationDisplay" ShowSummary="true" ShowMessageBox="false" CssClass="validationDisplay" EnableClientScript="false" runat="server" />
                                </td>
						        <td style="width: 100%;" align="right" valign="bottom">
                                    <asp:Label ID="validFlagDisplay" runat="server" Text=""></asp:Label>
						        </td>
						    </tr>
                        </table>
						<table cellpadding="0" cellspacing="0" border="0" width="100%">
							<tr>
								<th valign="top" colspan="2">DOMESTIC ITEM ADDITION &amp; CHANGES<asp:Label ID="batch" runat="server" Text=""></asp:Label><asp:Label ID="batchVendorName" runat="server" Text=""></asp:Label><asp:Label ID="stageName" runat="server" Text=""></asp:Label><asp:Label ID="lastUpdated" runat="server" Text=""></asp:Label>
								</th>
							</tr>
							<tr>
                                <td align="left" colspan="2" class="subHeading bodyText" style="padding: 5px;">
                                <span class="requiredFields">Required Fields<span class="requiredFieldsIcon">*</span>&nbsp;&nbsp;</span>
                                </td>
                            </tr>
							<tr>
								<td><table cellpadding="5" cellspacing="0" border="0" width="960">
										<tr>
											<td valign="top" width="310"><table cellpadding="3" cellspacing="0" border="0" width="100%">
													<!--<tr>
														<td class="formLabel">Log ID:</td>
														<td class="formField"><input type="text" name="textfield" id="textfield" /></td>
													</tr>-->
													<tr >
														<td runat="server" id="submittedByFL" class="formLabel">Submitted By:</td>
														<td class="formField" ><novalibra:NLTextBox ID="submittedBy" runat="server" MaxLength="100" CssClass="formTextBox"></novalibra:NLTextBox></td>
													</tr>
													<tr>
														<td runat="server" id="DateSubmittedFL" class="formLabel">Submitted Date:</td>
														<td class="formField"><novalibra:NLTextBox ID="DateSubmitted" runat="server" MaxLength="10" CssClass="formTextBox"></novalibra:NLTextBox></td>
													</tr>
													<tr>
														<td runat="server" id="departmentNumFL" class="formLabel">Dept. #<span id="departmentNumRF" class="requiredFieldsIcon" runat="server">*</span>:</td>
														<td class="formField"><novalibra:NLTextBox ID="departmentNum" runat="server" MaxLength="15" CssClass="formTextBox"></novalibra:NLTextBox></td>
													</tr>
												</table></td>
											<td valign="top" width="310">
												<table cellpadding="3" cellspacing="0" border="0" width="100%">
													<tr>
														<td runat="server" id="USVendorNumFL" class="formLabel">US Vendor #<span id="USVendorNumRF" class="requiredFieldsIcon" runat="server">*</span>:</td>
														<td class="formField" id="USVendorNumParent" runat="server" >
														    <novalibra:NLTextBox ID="USVendorNumEdit" runat="server" MaxLength="20" CssClass="formTextBox"></novalibra:NLTextBox>
                                                            <asp:HiddenField ID="USVendorNum" runat="server" />
                                                            <asp:Label ID="USVendorNumLabel" runat="server" Text=""></asp:Label>
														</td>
													</tr>
													<tr>
														<td runat="server" id="USVendorNameFL" class="formLabel">US Vendor Name<span id="USVendorNameRF" class="requiredFieldsIcon" runat="server">*</span>:</td>
														<td class="formField">
                                                            <asp:HiddenField ID="USVendorName" runat="server" />
                                                            <asp:Label ID="USVendorNameLabel" runat="server" Text=""></asp:Label>
														</td>
													</tr>
												</table></td>
											<td valign="top" width="310">
												<table cellpadding="3" cellspacing="0" border="0" width="100%">
													<!--<tr>
														<td class="formLabel">Buyer Approval:</td>
														<td class="formField"><input type="text" name="textfield2" id="textfield2" /></td>
													</tr>-->
													<tr>
														<td runat="server" id="CanadianVendorNumFL" class="formLabel">Canadian Vendor #<span id="CanadianVendorNumRF" class="requiredFieldsIcon" runat="server">*</span>:</td>
														<td class="formField" id="CanadianVendorNumParent" runat="server" >
														    <novalibra:NLTextBox ID="CanadianVendorNumEdit" runat="server" MaxLength="20" CssClass="formTextBox"></novalibra:NLTextBox>
                                                            <asp:HiddenField ID="CanadianVendorNum" runat="server" />
                                                            <asp:Label ID="CanadianVendorNumLabel" runat="server" Text=""></asp:Label>
														</td>
													</tr>
													<tr>
														<td runat="server" id="CanadianVendorNameFL" class="formLabel">Canadian Vendor Name<span id="CanadianVendorNameRF" class="requiredFieldsIcon" runat="server">*</span>:</td>
														<td class="formField">
                                                            <asp:HiddenField ID="CanadianVendorName" runat="server" />
                                                            <asp:Label ID="CanadianVendorNameLabel" runat="server" Text=""></asp:Label>
														</td>
													</tr>
												</table></td>
										</tr>
									</table></td> 
							</tr>
							<!--
							<tr>
								<th valign="top" colspan="2">Rebuy / Replenish / Store Order</th>
							</tr>
							<tr>
								<td><table cellpadding="5" cellspacing="0" border="0" width="960">
										<tr>
											<td valign="top" width="310"><table cellpadding="3" cellspacing="0" border="0" width="100%">
													<tr>
														<td class="formLabel">Rebuy - VP Replenish:</td>
														<td class="formField">
															<novalibra:NLDropDownList ID="rebuyYN" runat="server">
															</novalibra:NLDropDownList>
														</td>
													</tr>
												</table></td>
											<td valign="top" width="310"><table cellpadding="3" cellspacing="0" border="0" width="100%">
													
													<tr>
														<td class="formLabel">Replenish - VP Replenish:</td>
														<td class="formField">
															<novalibra:NLDropDownList ID="replenishYN" runat="server">
															</novalibra:NLDropDownList>
														</td>
													</tr>
													
												</table></td>
											<td valign="top" width="310"><table cellpadding="3" cellspacing="0" border="0" width="100%">
													<tr>
														<td class="formLabel">Store Order - Mgr. DBC:</td>
														<td class="formField">
															<novalibra:NLDropDownList ID="storeOrderYN" runat="server">
															</novalibra:NLDropDownList>
														</td>
													</tr>
												</table></td>
										</tr>
									</table></td>
							</tr>
							-->
							<tr>
								<th valign="top" colspan="2">Information Needed for All SKUs</th>
							</tr>
							<tr>
								<td><table cellpadding="5" cellspacing="0" border="0" width="960">
										<tr>
											<td valign="top" width="310"><table cellpadding="3" cellspacing="0" border="0" width="100%">
													<tr>
														<td runat="server" id="stockCategoryFL" class="formLabel">US Stock Category<span id="stockCategoryRF" class="requiredFieldsIcon" runat="server">*</span>:</td>
														<td class="formField">
															<novalibra:NLDropDownList ID="stockCategory" runat="server">
															</novalibra:NLDropDownList>
														</td>
													</tr>
													<tr>
														<td runat="server" id="canadaStockCategoryFL" class="formLabel">Canada Stock Category<span id="canadaStockCategoryRF" class="requiredFieldsIcon" runat="server">*</span>:</td>
														<td class="formField">
															<novalibra:NLDropDownList ID="canadaStockCategory" runat="server">
															</novalibra:NLDropDownList>
														</td>
													</tr>
													<tr>
														<td runat="server" id="itemTypeFL" class="formLabel">Item Type<span id="itemTypeRF" class="requiredFieldsIcon" runat="server">*</span>:</td>
														<td class="formField">
															<novalibra:NLDropDownList ID="itemType" runat="server">
															</novalibra:NLDropDownList>
														</td>
													</tr>
													<tr>
														<td runat="server" id="itemTypeAttributeFL" class="formLabel">Item Type Attribute<span id="itemTypeAttributeRF" class="requiredFieldsIcon" runat="server">*</span>:</td>
														<td class="formField">
															<novalibra:NLDropDownList ID="itemTypeAttribute" runat="server">
															</novalibra:NLDropDownList>
														</td>
													</tr>
													<tr>
														<td runat="server" id="allowStoreOrderFL" class="formLabel">Allow Store Order<span id="allowStoreOrderRF" class="requiredFieldsIcon" runat="server">*</span>:</td>
														<td class="formField">
															<novalibra:NLDropDownList ID="allowStoreOrder" runat="server">
															</novalibra:NLDropDownList>
														</td>
													</tr>
												</table>
										    </td>
											<td valign="top" width="310"><table cellpadding="3" cellspacing="0" border="0" width="100%">
													
													<tr>
														<td runat="server" id="inventoryControlFL" class="formLabel">Inventory Control<span id="inventoryControlRF" class="requiredFieldsIcon" runat="server">*</span>:</td>
														<td class="formField">
															<novalibra:NLDropDownList ID="inventoryControl" runat="server">
															</novalibra:NLDropDownList>
														</td>
													</tr>
													<tr>
														<td runat="server" id="freightTermsFL" class="formLabel">Freight Terms<span id="freightTermsRF" class="requiredFieldsIcon" runat="server">*</span>:</td>
														<td class="formField">
															<novalibra:NLDropDownList ID="freightTerms" runat="server">
															</novalibra:NLDropDownList>
														</td>
													</tr>
													<tr>
														<td runat="server" id="autoReplenishFL" class="formLabel">Auto Replenish<span id="autoReplenishRF" class="requiredFieldsIcon" runat="server">*</span>:</td>
														<td class="formField">
															<novalibra:NLDropDownList ID="autoReplenish" runat="server">
															</novalibra:NLDropDownList>
														</td>
													</tr>
													<tr>
														<td runat="server" id="discountableFL" class="formLabel">Discountable<span id="discountableRF" class="requiredFieldsIcon" runat="server">*</span>:</td>
														<td class="formField">
														    <novalibra:NLDropDownList ID="discountable" runat="server"></novalibra:NLDropDownList>
														</td>
													</tr>
													<tr>
														<td runat="server" id="SKUGroupFL" class="formLabel">SKU Group<span id="SKUGroupRF" class="requiredFieldsIcon" runat="server">*</span>:</td>
														<td class="formField">
															<novalibra:NLDropDownList ID="SKUGroup" runat="server">
															</novalibra:NLDropDownList>
														</td>
													</tr>
												</table>
											</td>
											<td valign="top" width="310"><table cellpadding="3" cellspacing="0" border="0" width="100%">
													
													
													<tr>
														<td runat="server" id="storeSupplierZoneGroupFL" class="formLabel">Store Supp Zone Group:</td>
														<td class="formField"><novalibra:NLTextBox ID="storeSupplierZoneGroup" runat="server" MaxLength="50" CssClass="formTextBox calculatedField" ReadOnly="true"></novalibra:NLTextBox></td>
													</tr>
													<tr>
														<td runat="server" id="WHSSupplierZoneGroupFL" class="formLabel">WHS Supp Zone Group:</td>
														<td class="formField"><novalibra:NLTextBox ID="WHSSupplierZoneGroup" runat="server" MaxLength="50" CssClass="formTextBox calculatedField" ReadOnly="true"></novalibra:NLTextBox></td>
													</tr>
													<tr runat="server" id="addUnitCostRow">
														<td runat="server" id="addUnitCostFL" class="formLabel">Additional Cost Per Unit:</td>
														<td class="formField"><novalibra:NLTextBox ID="addUnitCost" runat="server" MaxLength="20" CssClass="formTextBox"></novalibra:NLTextBox></td>
													</tr>
												</table>
											</td>
										</tr>
									</table></td>
							</tr>
							<tr>
								<th valign="top" colspan="2" class="">Comments / Worksheet Description</th>
							</tr>
							<tr>
								<td>
								    <table cellpadding="5" cellspacing="0" border="0" width="960">
										<tr>
											<td valign="top" width="960"><table cellpadding="3" cellspacing="0" border="0" width="100%">
													<tr>
														<td colspan="2" class=""><novalibra:NLTextBox ID="comments" runat="server" Rows="5" Columns="45" TextMode="MultiLine" style="width: 922px; height: 110px;"></novalibra:NLTextBox></td>
													</tr>
													<tr>
														<td runat="server" id="worksheetDescFL" class="formLabel" style="white-space:nowrap;" nowrap="nowrap">Worksheet Description:</td>
														<td class=""><novalibra:NLTextBox ID="worksheetDesc" runat="server"  TextMode="SingleLine" style="width: 794px;" MaxLength="4000"></novalibra:NLTextBox></td>
													</tr>
												</table>
											</td>
										</tr>
									</table>
								</td>
							</tr>
							
							<% If ShowRMSFields = True Then%>
							<tr>
								<th valign="top" colspan="2">RMS Sellable/Orderable/Inventory</th>
							</tr>
							<tr>
								<td>
								    <table cellpadding="5" cellspacing="0" border="0" width="960">
										<tr>
											<td valign="top" width="310"><table cellpadding="3" cellspacing="0" border="0" width="100%">
													<tr>
														<td runat="server" id="RMSSellableFL" class="formLabel">RMS Sellable<span id="RMSSellableRF" class="requiredFieldsIcon" runat="server">*</span>:</td>
														<td class="formField">
															<novalibra:NLDropDownList ID="RMSSellable" runat="server">
															</novalibra:NLDropDownList>
														</td>
													</tr>
												</table></td>
											<td valign="top" width="310">
											    <table cellpadding="3" cellspacing="0" border="0" width="100%">
													<tr>
														<td runat="server" id="RMSOrderableFL" class="formLabel">RMS Orderable<span id="RMSOrderableRF" class="requiredFieldsIcon" runat="server">*</span>:</td>
														<td class="formField">
															<novalibra:NLDropDownList ID="RMSOrderable" runat="server">
															</novalibra:NLDropDownList>
														</td>
													</tr>
												</table></td>
											<td valign="top" width="310">
											    <table cellpadding="3" cellspacing="0" border="0" width="100%">
													<tr>
														<td runat="server" id="RMSInventoryFL" class="formLabel">RMS Inventory<span id="RMSInventoryRF" class="requiredFieldsIcon" runat="server">*</span>:</td>
														<td class="formField">
															<novalibra:NLDropDownList ID="RMSInventory" runat="server">
															</novalibra:NLDropDownList>
														</td>
													</tr>
												</table></td>
										</tr>
									</table>
								</td>
							</tr>
							<% End If %>
							
							<tr>
								<th valign="top" colspan="2">New Item Approval</th>
							</tr>
							<tr>
								<td>
								    <table cellpadding="5" cellspacing="0" border="0" width="1050">
										<tr>
										    <td valign="top" width="320"><table cellpadding="2" cellspacing="0" border="0" width="100%">
										            <tr>
													    <td runat="server" id="calculateOptionsFL" class="formLabel">Select Forecast Type<span id="selectForecastRF" class="requiredFieldsIcon" runat="server"></span>:</td> 
													    <td class="formField">
													        <novalibra:NLDropDownList ID="calculateOptions" runat="server" >
													           <asp:ListItem Value="0" Text="0-No Selection"></asp:ListItem>
                                                               <asp:ListItem Value="1" Text="1-Provide Annual Forecast"></asp:ListItem>
                                                               <asp:ListItem Value="2" Text="2-Provide Units/Store/Month"></asp:ListItem>
													        </novalibra:NLDropDownList></td>
												    </tr>
										        </table></td>
											<td valign="top" width="240">
											    <table cellpadding="2" cellspacing="0" border="0" width="100%">
													<tr>
													    <td runat="server" id="storeTotalFL" class="formLabel">Store Total<span id="storeTotalRF" class="requiredFieldsIcon" runat="server">*</span>:</td>
								                        <td class="formField">
									                        <novalibra:NLTextBox ID="storeTotal" runat="server" Width="100" MaxLength="10" ></novalibra:NLTextBox>
								                        </td>
							                        </tr>
												</table>
											</td>
											<td valign="top" width="240">
											    <table cellpadding="2" cellspacing="0" border="0" width="100%">
													<tr>
								                        <td runat="server" id="POGStartDateFL" class="formLabel">POG Start Date<span id="POGStartDateRF" class="requiredFieldsIcon" runat="server">*</span>:</td>
								                        <td class="formField">
									                        <novalibra:NLTextBox ID="POGStartDate" runat="server" Width="100" MaxLength="10" ></novalibra:NLTextBox>
								                        </td>
							                        </tr>
												</table></td>
											<td valign="top" width="250">
											    <table cellpadding="2" cellspacing="0" border="0" width="100%">
													<tr>
								                        <td runat="server" id="POGCompDateFL" class="formLabel">POG Comp Date<span id="POGCompDateRF" class="requiredFieldsIcon" runat="server">*</span>:</td>
								                        <td class="formField">
									                        <novalibra:NLTextBox ID="POGCompDate" runat="server" Width="100" MaxLength="10" ></novalibra:NLTextBox>
								                        </td>
							                        </tr>
												</table></td>
										</tr>
									</table>
								</td>
							</tr>
							
							<% If Me.custFields.FieldCount > 0 Then%>
							<tr id="customFieldsHeader" runat="server">
								<th valign="top" colspan="2">Custom Fields</th>
							</tr>
							<tr id="customFieldsControls" runat="server">
								<td>
								    <table cellpadding="5" cellspacing="0" border="0" width="320">
								        <tr><td valign="top" width="100%"><table cellpadding="2" cellspacing="0" border="0" width="100%">
										
										<novalibra:NLCustomFields ID="custFields" runat="server"></novalibra:NLCustomFields>
										
										</table></td></tr>
									</table>
								</td>
							</tr>
							<% End If %>
							
							<tr>
							    <td colspan="2" style="height: 5px;"><img src="images/spacer.gif" border="0" alt="" height="5" width="1" /></td>
							</tr>
							<tr>
                                <th colspan="2" class="detailFooter">
                                    <table border="0" cellpadding="0" cellspacing="0" style="width: 933px;" width="933">
                                        <tr>
                                            <td width="50%" style="width: 50%;" align="left" valign="top">
                                                <input type="button" id="btnCancel" onclick="cancelForm(); return false;" value="Cancel" class="formButton" />&nbsp;
                                            </td>
                                            <td width="50%" style="width: 50%;" align="right" valign="top">
                                                &nbsp;<asp:Button ID="btnUpdate" runat="server" Text="Save" CssClass="formButton" /> 
                                                &nbsp;&nbsp;<asp:Button ID="btnUpdateClose" runat="server" Text="Save &amp; Close" CssClass="formButton" />
                                            </td>
                                        </tr>
                                    </table>
                                </th>
                            </tr>
						</table>
					</div>
				</div>
				<div id="shadowtop"></div>
				<div id="main">
				</div>
			</div>
		</div>
	</div>
	
        <asp:CustomValidator ID="itemValidator" runat="server" ErrorMessage="testing message"></asp:CustomValidator>
	<script language="javascript" type="text/javascript">
    <!--
    //Effect.toggle('submissiondetail','slide',{duration:0.5, afterFinish:toggleCallbackOnFinish});
    //-->
	</script>
    </form>
</body>
</html>
