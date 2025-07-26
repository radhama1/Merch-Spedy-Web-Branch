<%@ Page Language="VB" AutoEventWireup="false" CodeFile="importdetail.aspx.vb" Inherits="importdetail" ValidateRequest="false" %>
<%@ Register Src="NovaGrid.ascx" TagName="NovaGrid" TagPrefix="ucgrid" %>
<%@ Register Src="~/CORALControls/pageheader.ascx" TagName="pageheader" TagPrefix="uclayout" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
	<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE10" />
    <title>Item Data Management</title>
	<link rel="stylesheet" href="css/styles.css" type="text/css"/>
<style type="text/css">
th { text-align: left; padding: 5px; }
input, select, textarea
{
    background-color: #ffffff;
}
.formLabel
{
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
  width:240px;
  background-color:white;
  border:1px solid #888;
  margin:0px;
  padding:0px;
  height: 100px;
  overflow: auto;
}

#LstBoxStockingStrategies { height: 150px; width: 250px;}

    #chkLstWarehouses label {
        margin-left: 5px;
    }

</style>
	<link href="novagrid/novagrid.css?v=<%=ConfigurationManager.AppSettings("AppVersion")%>" rel="stylesheet" type="text/css" />
	<link href="novagrid/lightbox.css?v=<%=ConfigurationManager.AppSettings("AppVersion")%>" rel="stylesheet" type="text/css" />
	<link href="novagrid/gridcontextmenu.css?v=<%=ConfigurationManager.AppSettings("AppVersion")%>" rel="stylesheet" type="text/css" />
<script type="text/javascript" language="javascript" src="include/global.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
<script language="javascript" type="text/javascript" src="novagrid/prototype.js"></script>
<script language="javascript" type="text/javascript" src="novagrid/scriptaculous.js"></script>
<script language="javascript" type="text/javascript" src="novagrid/novagrid.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
<!--<script language="javascript" type="text/javascript" src="novagrid/lightbox.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>-->
<script language="javascript" type="text/javascript" src="./js/SpryData.js"></script>
<script language="javascript" type="text/javascript" src="./js/SpryUtils.js"></script>
<script language="javascript" type="text/javascript" src="./js/SpryXML.js"></script>
<script language="javascript" type="text/javascript" src="./js/xpath.js"></script>
<script language="javascript" type="text/javascript" src="./importdetail.js?v=139"></script>
	<script type="text/javascript">
<!--
//var callbackSep = "<%=CALLBACK_SEP%>";

function cancelForm()
{
    if (confirm('Cancel adding/updating this item?'))
        window.location = 'default.aspx';
}
//var disableTaxWizard = false;
function openTaxWizard(id)
{
    //if (disableTaxWizard == true) return false;
    var url = 'Tax_Wizard.aspx?type=I&id=' + id;
    var win = window.open(url, 'taxwiz', 'scrollbars=0,location=0,menubar=0,titlebar=0,toolbar=0,width=700,HEIGHT=525');
    return false;
}
function openTaxWizardSA(id, bid)
{
    //if (disableTaxWizard == true) return false;
    var url = 'Tax_Wizard.aspx?type=I&id=' + id + '&sa=1&bid=' + bid;
    var win = window.open(url, 'taxwiz', 'scrollbars=0,location=0,menubar=0,titlebar=0,toolbar=0,width=700,HEIGHT=525');
    return false;
}
function updateItemTaxWizard(id, completed, taxUDA)
{
    if (!completed || completed == null)
        completed = false;
    if (taxUDA == null) taxUDA = 0;
    if (!isNum(taxUDA)) taxUDA = 0;
    var imgID = 'taxWizard';
    if($(imgID)){
        $(imgID).src = (completed) ? 'images/checkbox_true.gif' : 'images/checkbox_false.gif';
        $('taxWizardComplete').value = (completed) ? '1' : '0';
    }
    var i, val = '', text = '';
    var o = $('TaxUDA')
    if(o){
        for(i = 0; i < o.options.length; i++){
            if (o.options[i].value == taxUDA.toString()){
                o.selectedIndex = i;
                val = o.options[i].value;
                text = o.options[i].text;
                break;
            }
        }
    }
    if($('TaxUDALabel')) $('TaxUDALabel').innerText = text;
    $('TaxUDAValue').value = val;
}

function showExcel()
{
	document.location = 'importexport.aspx?hid=<%=ItemID%>';
	return false;
}

function initPage()
{
    //calculateGMPercent(true);
    //LP Change Order 14
    calculateIMUPercent('RDVillageCraft');
    calculateIMUPercent('RDCentral');
    calculateIMUPercent('RDTest');
    calculateIMUPercent('RD0Thru9');
    calculateIMUPercent('RDCalifornia');
            //change order 14
    calculateIMUPercent('Retail9');
    calculateIMUPercent('Retail10');
    calculateIMUPercent('Retail11');
    calculateIMUPercent('Retail12');
    calculateIMUPercent('Retail13');
    calculateIMUPercent('RDQuebec');
    calculateIMUPercent('RDPuertoRico');
    calculateIMUPercent('RDCanada');
    
}

//-->
    </script>

</head>
<body onload="CalculateOptionsChanged();" oncontextmenu="return false;" style="background-color:#dedede">
    <form id="form1" runat="server">
		<asp:HiddenField ID="hid" runat="server" />
		<asp:HiddenField ID="additionalUPCValues" runat="server" />
		<asp:HiddenField ID="AddedNewSKUs" runat="server" />
		<asp:HiddenField ID="dirtyFlag" runat="server" />
        <asp:HiddenField ID="PLIEnglish_Dirty" runat="server" Value="0" />
        <asp:HiddenField ID="PLIFrench_Dirty" runat="server" Value="0" />
        <asp:HiddenField ID="PLISpanish_Dirty" runat="server" Value="0" />
        <asp:HiddenField ID="hdnWorkflowStageID" runat="server" Value="0" />
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true" AsyncPostBackTimeout="4500" ></asp:ScriptManager>
	<div id="sitediv">
		<div id="bodydiv">
			<div id="header">
				<uclayout:pageheader ID="headerControl" RefreshOnUpload="false" runat="server" />
			</div>
			<div id="content">
				<div id="submissiondetail">
					
						<table cellpadding="0" cellspacing="0" border="0" width="100%">
						<tr>
                            <td colspan="2">
                                <table border="0" cellpadding="0" cellspacing="0" width="100%">
					                <tr>
					                    <td valign="bottom" style="width: 189px;">
					                        <img src="images/spacer.gif" border="0" alt="" height="1" width="189" />
					                    </td>
					                    <td style="width: 15px;"><img src="images/spacer.gif" border="0" alt="" height="1" width="15" /></td>
					                    <td style="width: 50px;"><img src="images/spacer.gif" border="0" alt="" height="1" width="50" /></td>
					                    <td>
                                            <novalibra:NLValidationSummary ID="V_Summary" ShowSummary="true" ShowMessageBox="false" CssClass="validationDisplay" EnableClientScript="false" EnableViewState="true" runat="server" />
                                        </td>
					                    <td style="width: 100%;" align="right" valign="bottom">
                                            <asp:Label ID="validFlagDisplay" runat="server" Text=""></asp:Label>
					                    </td>
					                </tr>
                                </table>
                            </td>
                        </tr>
						<tr>
							<th valign="top" colspan="2">IMPORT ITEM ADDITION &amp; CHANGES<asp:Label ID="batch" runat="server" Text=""></asp:Label><asp:Label ID="batchVendorName" runat="server" Text=""></asp:Label><asp:Label ID="stageName" runat="server" Text=""></asp:Label><asp:Label ID="lastUpdated" runat="server" Text=""></asp:Label></th>
						</tr>
						<tr>
                            <td align="left" colspan="2" class="subHeading bodyText" style="padding: 5px;">
                                <table cellpadding="0" cellspacing="0" border="0" width="100%">
                                    <tr>
                                        <td valign="middle" align="left" style="height: 17px"><asp:HyperLink ID="linkExcel" runat="server" NavigateUrl="#">Export to Excel</asp:HyperLink>&nbsp;&nbsp;</td>
                                        <td valign="middle" align="right" style="height: 17px">
                                            <asp:HyperLink ID="lnkAddExisting" runat="server" NavigateUrl="#">Add Existing Item(s)</asp:HyperLink>
                                            <asp:Label ID="lnkAddExistingSep" runat="server">&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;</asp:Label>    
                                            <input type="button" id="btnAddToBatch" runat="server" value="Add to Batch" class="formButton" onclick="showAddToBatch();" />
                                            <asp:Label ID="btnAddToBatchSep" runat="server">&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;</asp:Label>
                                            <input type="button" id="btnDuplicate" runat="server" value="Duplicate" class="formButton" onclick="showDuplicateItem();" />&nbsp;&nbsp;
                                        </td>
                                    </tr>            
                                </table>
                            </td>
                        </tr>
                        <tr>
						    <td colspan="2" style="padding: 5px;" align="right"><span id="childItemsDetail" runat="server">
						    <strong><asp:label ID="lblPackItemList" runat="server" Text="Child / Pack Items: " /></strong>
						    <novalibra:NLDropDownList ID="childItems" runat="server" AutoPostBack="false"></novalibra:NLDropDownList>&nbsp;&nbsp;
						    <input type="button" id="btnSplit" runat="server" value="Move Item" class="formButton" onclick="splitItemClick();"/>&nbsp;&nbsp;
						    </span>
						    </td>
						</tr>
						<tr>
						    <td colspan="2" style="padding-left: 10px;">					    
						        <table cellpadding="0" cellspacing="0" border="0">
                                <tr>
							        <td>
							            <table cellpadding="0" cellspacing="0" border="0">
							            <tr>
							               <td colspan="3">
							                    <table cellpadding="0" cellspacing="0" border="0">
							                    <tr>
							                        <td colspan="12">&nbsp;</td>
							                    </tr>
							                    <tr>
							                        <td runat="server" id="DateSubmittedFL" style="text-align: right;">Date Submitted:</td>
							                        <td>
							                            <novalibra:NLTextBox ID="DateSubmitted" runat="server" MaxLength="10" Width="100" ></novalibra:NLTextBox>
							                        </td>
							                        <!--<td colspan="2">&nbsp;</td>-->
							                        <td style="width: 100px;">&nbsp;</td>
							                        <td>&nbsp;</td>
							                        <td style="width: 80px;">&nbsp;</td>
							                        <td runat="server" id="VendorAgentFL" style="text-align: right; width: 80px; white-space: nowrap;">Vendor:</td>
							                        <td>
							                            <novalibra:NLDropDownList ID="VendorAgent" runat="server" AutoPostBack="true">
							                                <asp:ListItem Value="" Text=""></asp:ListItem>
							                                <asp:ListItem Value="YES" Text="YES"></asp:ListItem>
							                            </novalibra:NLDropDownList>
							                        </td>
							                        <td style="width: 20px;">&nbsp;</td>
							                        <td colspan="2">&nbsp;</td>
							                        <td style="width: 15px;">&nbsp;</td>
							                        <td>&nbsp;</td>
							                    </tr>
							                    <tr>
							                        <td colspan="5">&nbsp;</td>
							                        <td runat="server" id="AgentFL" style="text-align: right; white-space: nowrap;">Merch Burden:</td>
							                        <td>
							                            <novalibra:NLDropDownList ID="Agent" runat="server" AutoPostBack="true">
							                                <asp:ListItem Value="" Text=""></asp:ListItem>
							                                <asp:ListItem Value="YES" Text="YES"></asp:ListItem>
							                            </novalibra:NLDropDownList>
							                        </td>
							                        <td colspan="2">
							                            <novalibra:NLDropDownList ID="AgentType" runat="server">
							                            </novalibra:NLDropDownList>
							                        </td>
							                        <td colspan="3">&nbsp;</td>
							                    </tr>
							                    <tr>
							                        <td colspan="6">&nbsp;</td>
							                        <td runat="server" id="BuyerFL" style="text-align: right;">Buyer:</td>
							                        <td colspan="5"><novalibra:NLTextBox ID="Buyer" runat="server" Width="120" MaxLength="100" ></novalibra:NLTextBox></td>
							                    </tr>
							                    <tr>
							                        <td  runat="server" id="QuoteReferenceNumberFL" style="text-align: right; white-space: nowrap;">Quote Reference Number:</td>
							                        <td><novalibra:NLTextBox ID="QuoteReferenceNumber" runat="server" Width="100" MaxLength="20" RenderReadOnly="true" ></novalibra:NLTextBox></td>
							                        <td runat="server" id="QuoteSheetStatusFL" colspan="2" style="text-align: right;">Quote Sheet Status:</td>
							                        <td colspan="2">
							                            <novalibra:NLDropDownList ID="QuoteSheetStatus" runat="server" >
							                                <asp:ListItem Value="" Text=""></asp:ListItem>
							                                <asp:ListItem Value="REVISED" Text="REVISED"></asp:ListItem>
							                                <asp:ListItem Value="FINAL" Text="FINAL"></asp:ListItem>
							                            </novalibra:NLDropDownList>
							                        </td>
							                        <td runat="server" id="FaxFL" style="text-align: right;">Fax:</td>
							                        <td colspan="2"><novalibra:NLTextBox ID="Fax" runat="server" Width="120" MaxLength="100" ></novalibra:NLTextBox></td>
							                        <td runat="server" id="EnteredByFL" style="text-align: right;">Entered By:</td>
							                        <td colspan="2"><novalibra:NLTextBox ID="EnteredBy" runat="server" Width="120" MaxLength="100" ></novalibra:NLTextBox></td>
							                    </tr>
							                    <tr>
							                        <td runat="server" id="SKUGroupFL" style="text-align: right; white-space: nowrap;">SKU Group:</td>
							                        <td>
							                            <novalibra:NLDropDownList ID="SKUGroup" runat="server" >
							                            </novalibra:NLDropDownList>
							                        </td>
							                        <td runat="server" id="ItemTaskFL" colspan="2" style="text-align: right; white-space: nowrap;">Item Task:</td>
							                        <td colspan="2">
							                            <novalibra:NLDropDownList ID="ItemTask" runat="server" >
							                                <asp:ListItem Value="" Text=""></asp:ListItem>
							                                <asp:ListItem Value="NEW ITEM" Text="NEW ITEM"></asp:ListItem>
							                                <asp:ListItem Value="EDIT ITEM" Text="EDIT ITEM"></asp:ListItem>
							                            </novalibra:NLDropDownList>
							                        </td>
							                        <td runat="server" id="EmailFL" style="text-align: right;">Email:</td>
							                        <td colspan="2"><novalibra:NLTextBox ID="Email" runat="server" Width="120" MaxLength="100" ></novalibra:NLTextBox></td>
							                        <td runat="server" id="EnteredDateFL" style="text-align: right;">Entered Date:</td>
							                        <td colspan="2"><novalibra:NLTextBox ID="EnteredDate" runat="server" Width="120" MaxLength="10" ></novalibra:NLTextBox></td>
							                    </tr>
							                    <tr>
							                        <td runat="server" id="DeptFL" style="text-align: right;">Dept:</td>
							                        <td><novalibra:NLTextBox ID="Dept" runat="server" Width="100" MaxLength="2" ></novalibra:NLTextBox></td>
							                        <td colspan="10">&nbsp;</td>
							                    </tr>
							                    <tr>
							                        <td runat="server" id="ClassFL" style="text-align: right;">Class:</td>
							                        <td colspan="4"><novalibra:NLTextBox ID="Class" runat="server" Width="100" MaxLength="3" ></novalibra:NLTextBox></td>							                
							                        <td colspan="7" style="white-space: nowrap;">Required management approval if UPC will not be on product</td>
							                    </tr>
							                    <tr>
							                        <td runat="server" id="SubClassFL" style="text-align: right; white-space: nowrap;">Sub-Class (Line):</td>
							                        <td><novalibra:NLTextBox ID="SubClass" runat="server" Width="100" MaxLength="4" ></novalibra:NLTextBox></td>
							                        <td runat="server" id="SeasonFL" style="text-align: right; white-space: nowrap;">Season:</td>
							                        <td style="text-align: right; white-space: nowrap;">
							                            <novalibra:NLDropDownList ID="Season" runat="server" >
							                                <asp:ListItem Value="" Text=""></asp:ListItem>
							                                <asp:ListItem Value="CHRISTMAS" Text="CHRISTMAS"></asp:ListItem>
							                                <asp:ListItem Value="FALL" Text="FALL"></asp:ListItem>
							                                <asp:ListItem Value="SPRING" Text="SPRING"></asp:ListItem>
							                                <asp:ListItem Value="SUMMER" Text="SUMMER"></asp:ListItem>
							                                <asp:ListItem Value="TREND" Text="TREND"></asp:ListItem>
							                            </novalibra:NLDropDownList>
							                        </td>
							                        <td style="width: 80px">&nbsp;</td>
							                        <td runat="server" id="PrimaryUPCFL" style="text-align: right; white-space: nowrap;">Primary UPC:</td>
							                        <td runat="server" id="PrimaryUPCParent" colspan="6">
							                            <novalibra:NLTextBox ID="PrimaryUPC" runat="server" Width="100" MaxLength="14" ></novalibra:NLTextBox>
							                            <span id="GenerateMichaelsUPCLabel" runat="server">
							                            &nbsp;&nbsp;Generate UPC #: 
							                            <novalibra:NLDropDownList ID="GenerateMichaelsUPC" runat="server" >
							                                <asp:ListItem Value="" Text=""></asp:ListItem>
							                                <asp:ListItem Value="X" Text="X"></asp:ListItem>
							                            </novalibra:NLDropDownList>
							                            </span>
							                        </td>
							                    </tr>
							                    <tr>
							                        <td runat="server" id="MichaelsSKUFL" style="text-align: right; white-space: nowrap;">SKU #:</td>
							                        <td colspan="4"><novalibra:NLTextBox ID="MichaelsSKU" RenderReadOnly="true" ReadOnly="true" runat="server" Width="100" MaxLength="8" ></novalibra:NLTextBox></td>

							                        <td runat="server" id="AdditionalUPCFL" style="text-align: right; white-space: nowrap; padding-top:3px;" valign="top">Additional UPCs:</td>
	                                                <td colspan="6" runat="server" id="additionalUPCParent" class="formField" style="white-space:nowrap;">
		                                                <asp:HiddenField ID="additionalUPCCount" runat="server" value="1" />
		                                                <asp:Label ID="additionalUPCs" runat="server">
		                                                <input type="text" id="additionalUPC1" maxlength="20" value="" onchange="additionalUPCChanged('1');" /><sup>1</sup>
		                                                </asp:Label>
		                                                &nbsp;<a href="#" ID="additionalUPCLink" runat="server" onclick="addAdditionalUPC(); return false;">[+]</a>
	                                                </td>
							                    </tr>
							                    <tr>
							                        <td runat="server" id="PackSKUFL" style="text-align: right; white-space: nowrap;">Pack SKU #:</td>
							                        <td colspan="4"><novalibra:NLTextBox ID="PackSKU" runat="server" ReadOnly="true" RenderReadOnly="true" Width="100" MaxLength="8" ></novalibra:NLTextBox></td>
							                        <td colspan="7" style="text-align: right; white-space: nowrap;">&nbsp;</td>
							                    </tr>
							                    <tr>
							                        <td colspan="4">&nbsp;</td>
							                        <td runat="server" id="PlanogramNameFL" colspan="2" style="text-align: right; white-space: nowrap;">Planogram Name:</td>
							                        <td colspan="6"><novalibra:NLTextBox ID="PlanogramName" runat="server" Width="412" MaxLength="50" ></novalibra:NLTextBox></td>
							                    </tr>
							                    <tr>
							                        <td runat="server" id="VendorNumberFL" style="text-align: right;">Vendor Number:</td>
							                        <td runat="server" id="VendorNumberParent" colspan="3">
							                            <novalibra:NLTextBox ID="VendorNumberEdit" runat="server" Width="100" MaxLength="7" CssClass="formTextBox"></novalibra:NLTextBox>
                                                        <asp:HiddenField ID="VendorNumber" runat="server" />
                                                        <asp:Label ID="VendorNumberLabel" runat="server" Text=""></asp:Label>
							                        </td>
							                        <td runat="server" id="DescriptionFL" colspan="2" style="text-align: right; white-space: nowrap;">Description 30 Characters:</td>
							                        <td colspan="6"><novalibra:NLTextBox ID="Description" runat="server" Width="412" MaxLength="30" ></novalibra:NLTextBox></td>
							                    </tr>
							                    <tr>
							                        <td runat="server" id="VendorRankFL" style="text-align: right;">Vendor Rank:</td>
							                        <td colspan="3">
							                            <novalibra:NLDropDownList ID="VendorRank" runat="server" >
							                                <asp:ListItem Value="" Text=""></asp:ListItem>
							                                <asp:ListItem Value="PRIMARY" Text="PRIMARY"></asp:ListItem>
							                                <asp:ListItem Value="SECONDARY" Text="SECONDARY"></asp:ListItem>
							                            </novalibra:NLDropDownList>
							                        </td>
							                        <td colspan="2" runat="server" id="PrivateBrandLabelFL" style="text-align: right; white-space: nowrap;">Private Brand Label:</td>
							                        <td colspan="6" id="PrivateBrandLabelParent"  runat="server">
							                            <novalibra:NLDropDownList ID="PrivateBrandLabel" runat="server" autopostback="true"></novalibra:NLDropDownList>
                                                        <asp:HiddenField ID="hdnPrivateBrand" runat="Server" />
							                            &nbsp;&nbsp;&nbsp;<a href="#" id="pblApplyAll" runat="server">Set for Entire Batch</a>
							                            <asp:HiddenField ID="hdnPBLApplyAll" runat="Server" />
							                        </td>
							                    </tr>
												<!-- PMO200141 GTIN14 Enhancements changes Start-->
												<tr style="display:none;">
							                        <td colspan="1" runat="server" id="InnerGTINFL" style="text-align: right; white-space: nowrap;">Inner Pack GTIN14:</td>
							                        <td colspan="2" runat="server" id="InnerGTINParent" >
							                            <novalibra:NLTextBox ID="InnerGTIN" runat="server" Width="100"  MaxLength="14" ></novalibra:NLTextBox></td>
							                        <td colspan="3" runat="server" id="CaseGTINFL" style="text-align: right; white-space: nowrap;">Case Pack GTIN14:</td>
							                        <td colspan="4" runat="server" id="CaseGTINParent" >
							                            <novalibra:NLTextBox ID="CaseGTIN" runat="server" Width="100"  MaxLength ="14" ></novalibra:NLTextBox>							                            
														<span colspan="5" id="GenerateGTIN14InnerLabel" runat="server">
							                            &nbsp;&nbsp;Generate GTIN14#: 
							                            <novalibra:NLDropDownList ID="GenerateMichaelsGTIN14" runat="server" >
							                                <asp:ListItem Value="" Text=""></asp:ListItem>
							                                <asp:ListItem Value="X" Text="X"></asp:ListItem>
							                            </novalibra:NLDropDownList>
							                            </span>
							                        </td>
												</tr>
												<!-- PMO200141 GTIN14 Enhancements changes End -->
							                    </table>
							               </td> 
							            </tr>
							            <!--<tr><td colspan="3" style="line-height: 2px;"><hr /></td></tr>-->
					                    <tr><td colspan="3">&nbsp;</td></tr>
					                    <tr><th colspan="3">&nbsp;</th></tr>
					                    <tr><td colspan="3">&nbsp;</td></tr>
							            <tr>
							                <td valign="top" style="padding-right: 5px;">
							                    <table cellpadding="0" cellspacing="0" border="0">
							                    <tr>
							                        <td>
							                            <table cellpadding="0" cellspacing="0" border="0">
							                            <tr>
							                                <td runat="server" id="PaymentTermsFL" style="text-align: right; white-space: nowrap;">Payment terms:</td>
							                                <td>
							                                    <novalibra:NLDropDownList ID="PaymentTerms" runat="server" >
							                                        <asp:ListItem Value="" Text=""></asp:ListItem>
							                                        <asp:ListItem Value="DA" Text="DA"></asp:ListItem>
							                                        <asp:ListItem Value="DP" Text="DP"></asp:ListItem>
							                                        <asp:ListItem Value="LC" Text="LC"></asp:ListItem>
							                                    </novalibra:NLDropDownList>
							                                </td>
							                                <td runat="server" id="DaysFL" style="text-align: right;">Days</td>
							                                <td>
							                                    <novalibra:NLDropDownList ID="Days" runat="server" >
							                                        <asp:ListItem Value="" Text=""></asp:ListItem>
							                                        <asp:ListItem Value="30" Text="30"></asp:ListItem>
							                                        <asp:ListItem Value="45" Text="45"></asp:ListItem>
							                                        <asp:ListItem Value="60" Text="60"></asp:ListItem>
							                                        <asp:ListItem Value="90" Text="90"></asp:ListItem>
							                                        <asp:ListItem Value="180" Text="180"></asp:ListItem>
							                                        <asp:ListItem Value="SIGHT" Text="SIGHT"></asp:ListItem>
							                                    </novalibra:NLDropDownList>
							                                </td>
							                            </tr>

							                            <tr>
							                                <td runat="server" id="VendorNameFL" colspan="2" style="text-align: right; white-space: nowrap;">Vendor Name:</td>
							                                <td runat="server" id="VendorNameParent" colspan="2">
							                                    <asp:HiddenField ID="VendorName" runat="server" />
                                                                <asp:Label ID="VendorNameLabel" runat="server" Text=""></asp:Label>
							                                </td>
							                            </tr>
							                            <tr>
							                                <td runat="server" id="VendorAddress1FL" colspan="2" style="text-align: right; white-space: nowrap;">Address Line 1:</td>
							                                <td colspan="2"><novalibra:NLTextBox ID="VendorAddress1" runat="server" Width="300" MaxLength="100" ></novalibra:NLTextBox></td>
							                            </tr>
							                            <tr>
							                                <td runat="server" id="VendorAddress2FL" colspan="2" style="text-align: right; white-space: nowrap;">Address Line 2:</td>
							                                <td colspan="2"><novalibra:NLTextBox ID="VendorAddress2" runat="server" Width="300" MaxLength="100" ></novalibra:NLTextBox></td>
							                            </tr>
							                            <tr>
							                                <td runat="server" id="VendorAddress3FL" colspan="2" style="text-align: right; white-space: nowrap;">Address Line 3:</td>
							                                <td colspan="2"><novalibra:NLTextBox ID="VendorAddress3" runat="server" Width="300" MaxLength="100" ></novalibra:NLTextBox></td>
							                            </tr>
							                            <tr>
							                                <td runat="server" id="VendorAddress4FL" colspan="2" style="text-align: right; white-space: nowrap;">Address Line 4:</td>
							                                <td colspan="2"><novalibra:NLTextBox ID="VendorAddress4" runat="server" Width="300" MaxLength="100" ></novalibra:NLTextBox></td>
							                            </tr>
							                            <tr>
							                                <td runat="server" id="VendorContactNameFL" colspan="2" style="text-align: right; white-space: nowrap;">Contact Name:</td>
							                                <td colspan="2"><novalibra:NLTextBox ID="VendorContactName" runat="server" Width="300" MaxLength="100" ></novalibra:NLTextBox></td>
							                            </tr>
							                            <tr>
							                                <td runat="server" id="VendorContactPhoneFL" colspan="2" style="text-align: right; white-space: nowrap;">Phone:</td>
							                                <td colspan="2"><novalibra:NLTextBox ID="VendorContactPhone" runat="server" Width="300" MaxLength="100" ></novalibra:NLTextBox></td>
							                            </tr>
							                            <tr>
							                                <td runat="server" id="VendorContactEmailFL" colspan="2" style="text-align: right; white-space: nowrap;">Email:</td>
							                                <td colspan="2"><novalibra:NLTextBox ID="VendorContactEmail" runat="server" Width="300" MaxLength="100" ></novalibra:NLTextBox></td>
							                            </tr>
							                            <tr>
							                                <td runat="server" id="VendorContactFaxFL" colspan="2" style="text-align: right; white-space: nowrap;">Fax:</td>
							                                <td colspan="2"><novalibra:NLTextBox ID="VendorContactFax" runat="server" Width="300" MaxLength="100" ></novalibra:NLTextBox></td>
							                            </tr>
							                            <tr runat="server" id="tMan1">
				                                            <td runat="server" id="ManufactureNameFL"  colspan="2"
                                                                style="text-align: right; white-space: nowrap;">Manufacture Name:</td>
				                                            <td colspan="2" style="text-align:left"><novalibra:NLTextBox ID="ManufactureName" runat="server" Width="300" MaxLength="100" ></novalibra:NLTextBox></td>
				                                        </tr>
							                            <tr runat="server" id="tMan2">
				                                            <td runat="server" id="ManufactureAddress1FL" colspan="2" 
                                                                style="text-align: right; white-space: nowrap;">MFT Address 1:</td>
				                                            <td colspan="2" style="text-align:left"><novalibra:NLTextBox ID="ManufactureAddress1" runat="server" Width="300" MaxLength="100" ></novalibra:NLTextBox></td>
				                                        </tr>
							                            <tr runat="server" id="tMan3">
				                                            <td runat="server" id="ManufactureAddress2FL" colspan="2"
                                                                style="text-align: right; white-space: nowrap;">MFT Address 2:</td>
				                                            <td colspan="2" style="text-align:left"><novalibra:NLTextBox ID="ManufactureAddress2" runat="server" Width="300" MaxLength="100" ></novalibra:NLTextBox></td>
				                                        </tr>
							                            <tr>
							                                <td runat="server" id="ManufactureContactFL" colspan="2" style="text-align: right; white-space: nowrap;"><asp:Label ID="L_Contact" runat="server"></asp:Label></td>
							                                <td colspan="2"><novalibra:NLTextBox ID="ManufactureContact" runat="server" Width="300" MaxLength="100" ></novalibra:NLTextBox></td>
							                            </tr>
							                            <tr>
							                                <td runat="server" id="ManufacturePhoneFL" colspan="2" style="text-align: right; white-space: nowrap;">Phone:</td>
							                                <td colspan="2"><novalibra:NLTextBox ID="ManufacturePhone" runat="server" Width="300" MaxLength="100" ></novalibra:NLTextBox></td>
							                            </tr>
							                            <tr>
							                                <td runat="server" id="ManufactureEmailFL" colspan="2" style="text-align: right; white-space: nowrap;">Email:</td>
							                                <td colspan="2"><novalibra:NLTextBox ID="ManufactureEmail" runat="server" Width="300" MaxLength="100" ></novalibra:NLTextBox></td>
							                            </tr>
							                            <tr>
							                                <td runat="server" id="ManufactureFaxFL" colspan="2" style="text-align: right; white-space: nowrap;">Fax:</td>
							                                <td colspan="2"><novalibra:NLTextBox ID="ManufactureFax" runat="server" Width="300" MaxLength="100" ></novalibra:NLTextBox></td>
							                            </tr>
							                            <tr runat="server" id="tAgent1" >
				                                            <td runat="server" id="AgentContactFL" colspan="2"
                                                                style="text-align: right; white-space: nowrap;">Agent Contact:</td>
				                                            <td colspan="2" style="text-align:left"><novalibra:NLTextBox ID="AgentContact" runat="server" Width="300" MaxLength="100" ></novalibra:NLTextBox></td>
				                                        </tr>
							                            <tr runat="server" id="tAgent2" >
				                                            <td runat="server" id="AgentPhoneFL" colspan="2" 
                                                                style="text-align: right; white-space: nowrap;">Phone:</td>
				                                            <td colspan="2" style="text-align: left">
				                                                <novalibra:NLTextBox ID="AgentPhone" runat="server" Width="300" MaxLength="100" ></novalibra:NLTextBox>
				                                            </td>
				                                        </tr>
				                                        <tr runat="server" id="tAgent3">
				                                            <td runat="server" id="AgentEmailFL" colspan="2"
                                                                style="text-align: right; white-space: nowrap;">Email:</td>
				                                            <td colspan="2" style="text-align: left"><novalibra:NLTextBox ID="AgentEmail" runat="server" Width="300" MaxLength="100" ></novalibra:NLTextBox></td>
				                                        </tr>
				                                        
							                            <tr runat="server" id="tAgent4" >
				                                            <td runat="server" id="AgentFaxFL" colspan="2"
                                                                style="text-align: right; white-space: nowrap;">Fax:</td>
				                                            <td colspan="2" style="text-align: left">
				                                                <novalibra:NLTextBox ID="AgentFax" runat="server" Width="300" MaxLength="100" ></novalibra:NLTextBox>
				                                            </td>
				                                        </tr>
							                            <tr><td colspan="4">&nbsp;</td></tr>
							                            <tr>
							                                <td runat="server" id="VendorStyleNumberFL" colspan="2" style="text-align: right; white-space: nowrap;">Vendor Style#:</td>
							                                <td colspan="2"><novalibra:NLTextBox ID="VendorStyleNumber" runat="server" Width="300" MaxLength="20" ></novalibra:NLTextBox></td>
							                            </tr>
							                            <tr><td colspan="4">&nbsp;</td></tr>
							                            <tr>
							                                <td runat="server" id="HarmonizedCodeNumberFL" colspan="2" style="text-align: right; white-space: nowrap;">Harmonized Code No.:</td>
							                                <td colspan="2"><novalibra:NLTextBox ID="HarmonizedCodeNumber" runat="server" Width="300" MaxLength="100" ></novalibra:NLTextBox></td>
							                            </tr>
                                                         <tr>
							                                <td runat="server" id="CanadaHarmonizedCodeNumberFL" colspan="2" style="text-align: right; white-space: nowrap;">Canada HTS Code No.:</td>
							                                <td colspan="2"><novalibra:NLTextBox ID="CanadaHarmonizedCodeNumber" runat="server" Width="300" MaxLength="100" ></novalibra:NLTextBox></td>
							                            </tr>
							                            <tr><td colspan="4">&nbsp;</td></tr>
							                            <tr>
							                                <td runat="server" id="DetailInvoiceCustomsDescFL" colspan="2" rowspan="6" style="vertical-align: text-top; text-align: right; white-space: nowrap;">Detail Invoice / Customs Description:</td>
							                                <td colspan="2"><novalibra:NLTextBox ID="DetailInvoiceCustomsDesc1" runat="server" Width="300" MaxLength="150" ></novalibra:NLTextBox></td>
							                            </tr>
							                            <tr>
							                                <td colspan="2"><novalibra:NLTextBox ID="DetailInvoiceCustomsDesc2" runat="server" Width="300" MaxLength="150" ></novalibra:NLTextBox></td>
							                            </tr>
							                            <tr>
							                                <td colspan="2"><novalibra:NLTextBox ID="DetailInvoiceCustomsDesc3" runat="server" Width="300" MaxLength="150" ></novalibra:NLTextBox></td>
							                            </tr>
							                            <tr>
							                                <td colspan="2"><novalibra:NLTextBox ID="DetailInvoiceCustomsDesc4" runat="server" Width="300" MaxLength="150" ></novalibra:NLTextBox></td>
							                            </tr>
							                            <tr>
							                                <td colspan="2"><novalibra:NLTextBox ID="DetailInvoiceCustomsDesc5" runat="server" Width="300" MaxLength="150" ></novalibra:NLTextBox></td>
							                            </tr>
							                            <tr>
							                                <td colspan="2"><novalibra:NLTextBox ID="DetailInvoiceCustomsDesc6" runat="server" Width="300" MaxLength="150" ></novalibra:NLTextBox></td>
							                            </tr>
							                            <tr>
							                                <td runat="server" id="ComponentMaterialBreakdownFL" colspan="2" rowspan="5" style="text-align: right; vertical-align: text-top; white-space: nowrap;">Component / Material Breakdown By %:</td>
							                                <td colspan="2"><novalibra:NLTextBox ID="ComponentMaterialBreakdown1" runat="server" Width="300" MaxLength="150" ></novalibra:NLTextBox></td>
							                            </tr>
							                            <tr>
							                                <td colspan="2"><novalibra:NLTextBox ID="ComponentMaterialBreakdown2" runat="server" Width="300" MaxLength="150" ></novalibra:NLTextBox></td>
							                            </tr>
							                            <tr>
							                                <td colspan="2"><novalibra:NLTextBox ID="ComponentMaterialBreakdown3" runat="server" Width="300" MaxLength="150" ></novalibra:NLTextBox></td>
							                            </tr>
							                            <tr>
							                                <td colspan="2"><novalibra:NLTextBox ID="ComponentMaterialBreakdown4" runat="server" Width="300" MaxLength="150" ></novalibra:NLTextBox></td>
							                            </tr>
							                            <tr>
							                                <td colspan="2"><novalibra:NLTextBox ID="ComponentMaterialBreakdown5" runat="server" Width="300" MaxLength="150" ></novalibra:NLTextBox></td>
							                            </tr>
							                            <tr>
							                                <td runat="server" id="ComponentConstructionMethodFL" colspan="2" rowspan="4" style="text-align: right; vertical-align: text-top; white-space: nowrap;">Component Construction Method:</td>
							                                <td colspan="2"><novalibra:NLTextBox ID="ComponentConstructionMethod1" runat="server" Width="300" MaxLength="150" ></novalibra:NLTextBox></td>
							                            </tr>
							                            <tr>
							                                <td colspan="2"><novalibra:NLTextBox ID="ComponentConstructionMethod2" runat="server" Width="300" MaxLength="150" ></novalibra:NLTextBox></td>
							                            </tr>
							                            <tr>
							                                <td colspan="2"><novalibra:NLTextBox ID="ComponentConstructionMethod3" runat="server" Width="300" MaxLength="150" ></novalibra:NLTextBox></td>
							                            </tr>
							                            <tr>
							                                <td colspan="2"><novalibra:NLTextBox ID="ComponentConstructionMethod4" runat="server" Width="300" MaxLength="150" ></novalibra:NLTextBox></td>
							                            </tr>
							                            <tr>
							                                <td runat="server" id="IndividualItemPackagingFL" colspan="2" style="text-align: right; white-space: nowrap;">Individual Item Packaging:</td>
							                                <td colspan="2"><novalibra:NLTextBox ID="IndividualItemPackaging" runat="server" Width="300" MaxLength="100" ></novalibra:NLTextBox></td>
							                            </tr>
							                            <tr id="QtyInPackRow" runat="server">
							                                <td runat="server" id="QtyInPackFL" colspan="2" style="text-align: right; white-space: nowrap;">Component Qty Ea:</td>
							                                <td colspan="2"><novalibra:NLTextBox ID="QtyInPack" runat="server" Width="300" MaxLength="10" ></novalibra:NLTextBox></td>
							                            </tr>
							                            <tr>
							                                <td runat="server" id="EachInsideMasterCaseBoxFL" colspan="2" style="text-align: right; white-space: nowrap;"># Eaches Inside Master Case Box:</td>
							                                <td colspan="2"><novalibra:NLTextBox ID="EachInsideMasterCaseBox" runat="server" Width="300" MaxLength="9" ></novalibra:NLTextBox></td>
							                            </tr>
							                            <tr>
							                                <td runat="server" id="EachInsideInnerPackFL" colspan="2" style="text-align: right; white-space: nowrap;"># Eaches Inside Inner Pack:</td>
							                                <td colspan="2"><novalibra:NLTextBox ID="EachInsideInnerPack" runat="server" Width="300" MaxLength="9" ></novalibra:NLTextBox></td>
							                            </tr>

							                            </table>
							                        </td>
							                    </tr>
							                    <tr>
							                        <td>
							                            <table cellpadding="0" cellspacing="0" border="0">
                                                            <tr><td colspan="3">&nbsp;</td></tr>
                                                            <tr>
							                                    <td colspan="3" style="white-space: nowrap;">Each Dimensions (shown in inches below):</td>
							                                </tr>
                                                            <tr runat="server" id="EachDimensionsFLParent" >
                                                                <td style="text-align: center;">Length = (down)</td>
                                                                <td style="text-align: center;">Width = (down)</td>
                                                                <td style="text-align: center;">Height = (down)</td>
                                                            </tr>
                                                            <tr runat="server" id="EachDimensionsParent" >
                                                                <td><novalibra:NLTextBox ID="EachLength" runat="server" Width="100" MaxLength="9" ></novalibra:NLTextBox></td>
                                                                <td><novalibra:NLTextBox ID="EachWidth" runat="server" Width="100" MaxLength="9" ></novalibra:NLTextBox></td>
                                                                <td><novalibra:NLTextBox ID="EachHeight" runat="server" Width="100" MaxLength="9" ></novalibra:NLTextBox></td>
                                                            </tr>
                                                            <tr>
                                                                <td runat="server" id="CubicFeetPerEachDimensionsFL" colspan="2">Cubic Feet Per Each:</td>
                                                                <td runat="server" id="CubicFeetPerEachDimensionsParent" >
                                                                    <novalibra:NLTextBox ID="CubicFeetPerEachEdit" runat="server" Width="100" MaxLength="14" ReadOnly="true" CssClass="calculatedField"></novalibra:NLTextBox>*
                                                                    <asp:HiddenField ID="CubicFeetPerEach" runat="server" />
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td runat="server" id="EachWeightFL" colspan="2">Weight of Each (lbs):</td>
                                                                <td><novalibra:NLTextBox ID="EachWeight" runat="server" Width="100" MaxLength="14" ></novalibra:NLTextBox></td>
                                                            </tr>
                                                            <tr><td colspan="3">&nbsp;</td></tr>
							                                <tr>
							                                    <td colspan="3" style="white-space: nowrap;">Reshippable Inner Carton Dimensions (shown in inches below):</td>
							                                </tr>
							                                <tr runat="server" id="ReshippableInnerCartonFLParent" >
							                                    <td style="text-align: center;">Length = (down)</td>
							                                    <td style="text-align: center;">Width = (down)</td>
							                                    <td style="text-align: center;">Height = (down)</td>
							                                </tr>
							                                <tr runat="server" id="ReshippableInnerCartonParent" >
							                                    <td><novalibra:NLTextBox ID="ReshippableInnerCartonLength" runat="server" Width="100" MaxLength="9" ></novalibra:NLTextBox></td>
							                                    <td><novalibra:NLTextBox ID="ReshippableInnerCartonWidth" runat="server" Width="100" MaxLength="9" ></novalibra:NLTextBox></td>
							                                    <td><novalibra:NLTextBox ID="ReshippableInnerCartonHeight" runat="server" Width="100" MaxLength="9" ></novalibra:NLTextBox></td>
							                                </tr>
                                                            <tr>
							                                    <td runat="server" id="CubicFeetPerInnerCartonFL" colspan="2">Cubic Feet Per Inner Carton:</td>
							                                    <td runat="server" id="CubicFeetPerInnerCartonParent" >
							                                       <novalibra:NLTextBox ID="CubicFeetPerInnerCartonEdit" runat="server" Width="100" MaxLength="14" ReadOnly="true" CssClass="calculatedField"></novalibra:NLTextBox>*
							                                       <asp:HiddenField ID="CubicFeetPerInnerCarton" runat="server" />
							                                    </td>
							                                </tr>
                                                            <%--<tr>
							                                    <td runat="server" id="EachPieceNetWeightLbsPerOunceFL"  colspan="2">Weight of Inner Carton (lbs):</td>
							                                    <td><novalibra:NLTextBox ID="EachPieceNetWeightLbsPerOunce" runat="server" Width="100" MaxLength="9" ></novalibra:NLTextBox></td>
							                                </tr>--%>
                                                            <tr>
							                                    <td runat="server" id="ReshippableInnerCartonWeightFL"  colspan="2">Weight of Inner Carton (lbs):</td>
							                                    <td><novalibra:NLTextBox ID="ReshippableInnerCartonWeight" runat="server" Width="100" MaxLength="9" ></novalibra:NLTextBox></td>
							                                </tr>
                                                            <tr><td colspan="3">&nbsp;</td></tr>
							                                <tr>
							                                    <td colspan="3" style="white-space: nowrap;">Master Carton Dimensions (shown in inches below):</td>
							                                </tr>
							                                <tr runat="server" id="MasterCartonDimensionsFLParent" >
							                                    <td style="text-align: center;">Length = (down)</td>
							                                    <td style="text-align: center;">Width = (down)</td>
							                                    <td style="text-align: center;">Height = (down)</td>
							                                </tr>
							                                <tr runat="server" id="MasterCartonDimensionsParent" >
							                                    <td><novalibra:NLTextBox ID="MasterCartonDimensionsLength" runat="server" Width="100" MaxLength="9" ></novalibra:NLTextBox></td>
							                                    <td><novalibra:NLTextBox ID="MasterCartonDimensionsWidth" runat="server" Width="100" MaxLength="9" ></novalibra:NLTextBox></td>
							                                    <td><novalibra:NLTextBox ID="MasterCartonDimensionsHeight" runat="server" Width="100" MaxLength="9" ></novalibra:NLTextBox></td>
							                                </tr>
							                                <tr>
							                                    <td runat="server" id="CubicFeetPerMasterCartonFL" colspan="2">Cubic Feet Per Master Carton:</td>
							                                    <td runat="server" id="CubicFeetPerMasterCartonParent" >
							                                        <novalibra:NLTextBox ID="CubicFeetPerMasterCartonEdit" runat="server" Width="100" MaxLength="14" ReadOnly="true" CssClass="calculatedField"></novalibra:NLTextBox>*
							                                        <asp:HiddenField ID="CubicFeetPerMasterCarton" runat="server" />
							                                    </td>
							                                </tr>
							                                <tr>
							                                    <td runat="server" id="WeightMasterCartonFL" colspan="2">Weight of Master Carton (lbs):</td>
							                                    <td><novalibra:NLTextBox ID="WeightMasterCarton" runat="server" Width="100" MaxLength="14" ></novalibra:NLTextBox></td>
							                                </tr>
							                            </table>
							                        </td>
							                    </tr>
							                    <tr>
							                        <td>
							                            <table cellpadding="0" cellspacing="0" border="0">
                                                            <tr><td colspan="3">&nbsp;</td></tr>
							                                <tr><th colspan="3">Language Settings</th></tr >
							                                <tr><td colspan="3">&nbsp;</td></tr>
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
                                                                <td colspan="2"><novalibra:NLTextBox ID="CustomsDescription" runat="server"  Width="300" MaxLength="255" /> </td>
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
                                                                    <novalibra:NLDropDownList ID="TISpanish" runat="server" Enabled="false">
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
                                                                 <td runat="server" id="EnglishShortDescriptionFL"  style="padding-left:80px;text-align: right; white-space: nowrap;">English &nbsp;<br /> Short Description: &nbsp;</td>
                                                                 <td colspan="2"><novalibra:NLTextBox ID="EnglishShortDescription" runat="server"  Width="300" MaxLength="17" /></td>
                                                            </tr>
                                                            <tr>
                                                                 <td runat="server" id="EnglishLongDescriptionFL"  style="text-align: right; white-space: nowrap;">English &nbsp;<br /> Long Description: &nbsp;<br />(max 100 chars.) &nbsp;</td>
                                                                 <td colspan="2"><novalibra:NLTextBox ID="EnglishLongDescription" runat="server"  Width="300" MaxLength="100" TextMode="MultiLine" Height="80" /></td>
                                                            </tr>
                                                            <tr>
                                                                 <td runat="server" id="FrenchShortDescriptionFL"  style="padding-left:80px;text-align: right; white-space: nowrap;">Canadian French &nbsp;<br /> Short Description: &nbsp;</td>
                                                                 <td colspan="2"><novalibra:NLTextBox ID="FrenchShortDescription" runat="server"  Width="300" MaxLength="17" /></td>
                                                            </tr>
                                                            <tr>
                                                                <td runat="server" id="FrenchLongDescriptionFL"  style="text-align: right; white-space: nowrap;">Canadian French &nbsp;<br /> Long Description: &nbsp;<br />(max 150 chars.) &nbsp;</td>
                                                                <td colspan="2"><novalibra:NLTextBox ID="FrenchLongDescription" runat="server"  Width="300" MaxLength="150" TextMode="MultiLine" Height="80" /></td>
                                                            </tr>
                                                            <tr>
                                                                <td runat="server" id="SpanishShortDescriptionFL"  style="padding-left:53px;text-align: right; white-space: nowrap;">Latin American Spanish &nbsp;<br /> Short Description: &nbsp;</td>
                                                                <td colspan="2"><novalibra:NLTextBox ID="SpanishShortDescription" runat="server"  Width="300" MaxLength="17" /></td>
                                                            </tr>
                                                            <tr>
                                                                <td runat="server" id="SpanishLongDescriptionFL"  style="text-align: right; white-space: nowrap;">Latin American Spanish &nbsp;<br /> Long Description: &nbsp;<br />(max 150 chars.) &nbsp;</td>
                                                                <td colspan="2"><novalibra:NLTextBox ID="SpanishLongDescription" runat="server"  Width="300" MaxLength="150" TextMode="MultiLine" Height="80" /></td>
                                                            </tr>
							                                <tr><td colspan="3">&nbsp;</td></tr>
							                                <tr><th colspan="3">Purchase Order</th></tr >
							                                <tr><td colspan="3">&nbsp;</td></tr>
															<tr>
																<td runat="server" id="MinimumOrderQuantityFL" style="text-align: right;">Minimum Order Quantity:</td>
																<td colspan="2"><novalibra:NLTextBox ID="MinimumOrderQuantity" runat="server" Width="330" MaxLength="9" ></novalibra:NLTextBox></td>
															</tr>
															<tr>
																<td runat="server" id="VendorMinOrderAmountFL" style="text-align: right;">Minimum Order Amount:</td>
																<td colspan="2"><novalibra:NLTextBox ID="VendorMinOrderAmount" runat="server" Width="330" MaxLength="20" ></novalibra:NLTextBox></td>
															</tr>
															<tr>
																<td runat="server" id="ProductIdentifiesAsCosmeticFL"  style="text-align: right; white-space: nowrap;">Product Identifies as a Cosmetic: </td>
																<td colspan="2">
																	<novalibra:NLDropDownList ID="ProductIdentifiesAsCosmetic" runat="server">
																		<asp:ListItem Text="" Value="" Selected="True"/>
																		<asp:ListItem Text="No" Value="N"  />
																		<asp:ListItem Text="Yes" Value="Y" />
																	</novalibra:NLDropDownList>
																</td>
															</tr>
							                                <tr>
							                                    <td runat="server" id="PurchaseOrderIssuedToFL" style="text-align: right; vertical-align: text-top; white-space: nowrap;" rowspan="3">Purchase Order To Be Issued To: </td>
							                                    <td colspan="2"><novalibra:NLTextBox ID="PurchaseOrderIssuedTo1" runat="server" Width="330" MaxLength="150" ></novalibra:NLTextBox></td>
							                                </tr>
							                                <tr>
							                                    <td colspan="2"><novalibra:NLTextBox ID="PurchaseOrderIssuedTo2" runat="server" Width="330" MaxLength="150" ></novalibra:NLTextBox></td>
							                                </tr>
							                                <tr>
							                                    <td colspan="2"><novalibra:NLTextBox ID="PurchaseOrderIssuedTo3" runat="server" Width="330" MaxLength="150" ></novalibra:NLTextBox></td>
							                                </tr>
							                                <tr>
							                                    <td runat="server" id="ShippingPointFL" style="text-align: right;">Shipping Point:</td>
							                                    <td colspan="2"><novalibra:NLTextBox ID="ShippingPoint" runat="server" Width="330" MaxLength="100" ></novalibra:NLTextBox></td>
							                                </tr>
							                                <tr>
							                                    <td runat="server" id="CountryOfOriginFL" style="text-align: right;">Country Of Origin:</td>
							                                    <td runat="server" id="CountryOfOriginParent" colspan="2">
							                                        <novalibra:NLTextBox ID="CountryOfOriginName" runat="server" Width="330" MaxLength="50" ></novalibra:NLTextBox>
							                                        <div id="CountryOfOriginName_choices" class="autocomplete"></div>
							                                        <asp:HiddenField ID="CountryOfOrigin" runat="server" />
							                                    </td>
							                                </tr>
							                                <tr>
							                                    <td runat="server" id="VendorCommentsFL" style="text-align: right;" valign="top">Vendor Comments:</td>
							                                    <td colspan="2">
							                                        <novalibra:NLTextBox ID="VendorComments" runat="server" Rows="8" Width="330" TextMode="MultiLine"></novalibra:NLTextBox>
							                                    </td>
							                                </tr>
							                            </table>
							                        </td>
							                    </tr>
							                    </table>
							                </td>							        
                                            <td style="width: 1px; border-right: solid 1px #000000;">&nbsp;</td>
							                <td valign="top" style="padding-left: 5px;">
                                                <asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Conditional" >
                                                    <Triggers>
                                                        <asp:AsyncPostBackTrigger ControlID="ItemTypeAttribute" EventName="SelectedIndexChanged" />
                                                    </Triggers>
                                                    <ContentTemplate>
							                    <table cellpadding="0" cellspacing="0" border="0">
							                    <tr>
							                        <td runat="server" id="StockCategoryFL" style="text-align: right; white-space: nowrap; width: 133px;">Stock Category:</td>
							                        <td><novalibra:NLTextBox ID="StockCategory" runat="server" Width="40" ReadOnly="true" CssClass="calculatedField"></novalibra:NLTextBox></td>
							                        <td runat="server" id="FreightTermsFL" style="text-align: right; white-space: nowrap;">Freight Terms:</td>
							                        <td><novalibra:NLTextBox ID="FreightTerms" runat="server" Width="60" ReadOnly="true" CssClass="calculatedField"></novalibra:NLTextBox></td>
							                    </tr>
							                    <tr>
							                        <td runat="server" id="ItemTypeFL" style="text-align: right; white-space: nowrap; width: 133px;">Item Type:</td>
							                        <td>
							                            <novalibra:NLDropDownList ID="ItemType" runat="server" >
							                            </novalibra:NLDropDownList>
							                        </td>
							                        <td runat="server" id="PackItemIndicatorFL" style="text-align: right; white-space: nowrap;">Pack Item Indicator:</td>
							                        <td>
							                            <novalibra:NLDropDownList ID="PackItemIndicator" runat="server" >
							                            </novalibra:NLDropDownList>
							                        </td>
							                    </tr>
							                    <tr>
							                        <td runat="server" id="ItemTypeAttributeFL" style="text-align: right; white-space: nowrap; width: 133px;">Item Type Attribute:</td>
							                        <td>
							                            <novalibra:NLDropDownList ID="ItemTypeAttribute" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ItemTypeAttribute_SelectedIndexChanged">
							                            </novalibra:NLDropDownList>
							                        </td>							                        
							                    </tr>
							                    <tr>
							                        <td runat="server" id="InventoryControlFL" style="text-align: right; white-space: nowrap; width: 133px;">Inventory Control:</td>
							                        <td>
							                            <novalibra:NLDropDownList ID="InventoryControl" runat="server" >
							                                <asp:ListItem Value="" Text=""></asp:ListItem>
							                                <asp:ListItem Value="Y" Text="Y - Rebuy"></asp:ListItem>
							                                <asp:ListItem Value="N" Text="N - No Rebuy"></asp:ListItem>
							                            </novalibra:NLDropDownList>
							                        </td>
							                        <td runat="server" id="AllowStoreOrderFL" style="text-align: right; white-space: nowrap;">Allow Store Order:</td>
							                        <td>
							                            <novalibra:NLDropDownList ID="AllowStoreOrder" runat="server" >
							                                <asp:ListItem Value="" Text=""></asp:ListItem>
							                                <asp:ListItem Value="Y" Text="Yes"></asp:ListItem>
							                                <asp:ListItem Value="N" Text="No"></asp:ListItem>							                        
							                            </novalibra:NLDropDownList>
							                        </td>
							                    </tr>
							                    <tr>
							                        <td runat="server" id="discountableFL" style="text-align: right; white-space: nowrap;">Discountable:</td>
							                        <td>
							                            <novalibra:NLDropDownList ID="discountable" runat="server" >
							                            </novalibra:NLDropDownList>
							                        </td>
							                        <td runat="server" id="AutoReplenishFL" style="text-align: right; white-space: nowrap;">Auto Replenish:</td>
							                        <td>
							                            <novalibra:NLDropDownList ID="AutoReplenish" runat="server" >
							                                <asp:ListItem Value="" Text=""></asp:ListItem>
							                                <asp:ListItem Value="Y" Text="Yes"></asp:ListItem>
							                                <asp:ListItem Value="N" Text="No"></asp:ListItem>							                        
							                            </novalibra:NLDropDownList>
							                        </td>
							                    </tr>
							                    <% If ItemID <> String.Empty Then%>
							                    <tr>
							                        <td colspan="2" style="text-align: right; white-space: nowrap;"></td>
							                        <!-- TAX WIZARD -->
                                                    <td runat="server" id="taxWizardFL" style="text-align: right; white-space: nowrap;">Tax Wizard:</td>
                                                    <td runat="server" id="taxWizardParent" >
                                                        <a href="#" ID="taxWizardLink" runat="server"><asp:Image ID="taxWizard" runat="server" /></a> &nbsp; 
                                                        <a href="#" id="taxWizardSALink" runat="server">Set for Entire Batch</a>
                                                        <asp:HiddenField ID="taxWizardComplete" runat="server" />
                                                    </td>
							                    </tr>
							                    <% End If %>
							                    <tr>
							                        <td runat="server" id="PrePricedFL" style="text-align: right; white-space: nowrap; width: 133px;">Pre-Priced:</td>
							                        <td>
							                            <novalibra:NLDropDownList ID="PrePriced" runat="server" >
							                            </novalibra:NLDropDownList>
							                        </td>
							                        <td runat="server" id="TaxUDAFL" style="text-align: right; white-space: nowrap;">Tax UDA:</td>
							                        <td runat="server" id="TaxUDAParent" >
							                            <novalibra:NLDropDownList ID="TaxUDA" runat="server">
							                            </novalibra:NLDropDownList>
							                            <asp:Label ID="TaxUDALabel" runat="server"></asp:Label>
							                            <asp:HiddenField ID="TaxUDAValue" runat="server" />
							                        </td>
							                    </tr>
							                    <tr>
							                        <td runat="server" id="PrePricedUDAFL" style="text-align: right; white-space: nowrap; width: 133px;">Pre-Priced UDA:</td>
							                        <td>
							                            <novalibra:NLDropDownList ID="PrePricedUDA" runat="server" >
							                            </novalibra:NLDropDownList>
							                        </td>
							                        <td runat="server" id="TaxValueUDAFL" style="text-align: right; white-space: nowrap;">Tax Value UDA:</td>
							                        <td runat="server" id="TaxValueUDAParent" >
							                            <novalibra:NLTextBox ID="TaxValueUDA" runat="server" Width="60" MaxLength="10" ></novalibra:NLTextBox>
							                            <asp:Label ID="TaxValueUDALabel" runat="server"></asp:Label>
							                            <asp:HiddenField ID="TaxValueUDAValue" runat="server" />
							                        </td>
							                    </tr>
                                                    
                                                <tr>
                                                    <td runat="server" id="StockingStrategyFL" style="text-align: right; white-space: nowrap;">Stocking Strategy:</td>
							                        <td>


<novalibra:NLDropDownList ID="StockingStrategyCode" runat="server">
							                            </novalibra:NLDropDownList>

							                            

                                                        <input type="button" id="btnStockStratHelper" runat="server" value="Helper" class="formButton" onclick="showStockStratHelper();" />&nbsp;&nbsp;
							                        </td>
                                                    
                                                </tr>
<%--							                    <tr>
							                        <td runat="server" id="HybridTypeFL" style="text-align: right; white-space: nowrap; width: 133px;">Hybrid Type:</td>
							                        <td>
							                            <novalibra:NLDropDownList ID="HybridType" runat="server" >
							                            </novalibra:NLDropDownList>
							                        </td>
							                        <td runat="server" id="SourcingDCFL" style="text-align: right; white-space: nowrap;" visible="false">Sourcing DC:</td>
							                        <td>
							                            <novalibra:NLDropDownList ID="SourcingDC" runat="server" visible="false">
							                            </novalibra:NLDropDownList>
							                        </td>
					                            </tr>--%>
<%--					                            <tr>
					                                <td runat="server" id="LeadTimeFL" style="text-align: right; white-space: nowrap; width: 133px;">Conversion Lead Time:</td>
					                                <td>
					                                    <novalibra:NLTextBox ID="LeadTime" runat="server" Width="40" MaxLength="3" ></novalibra:NLTextBox>
					                                </td>
					                                <td runat="server" id="ConversionDateFL" style="text-align: right; white-space: nowrap;">Conversion Date:</td>
					                                <td runat="server" id="ConversionDateParent" >
					                                    <novalibra:NLTextBox ID="ConversionDateEdit" runat="server" Width="60" MaxLength="10" ReadOnly="true" CssClass="calculatedField"></novalibra:NLTextBox>
					                                    <asp:HiddenField ID="ConversionDate" runat="server" />
					                                </td>
					                            </tr>--%>
					                            <tr>
					                                <td runat="server" id="StoreSuppZoneGRPFL" style="text-align: right; white-space: nowrap; width: 133px;">Store Supp Zone GRP:</td>
					                                <td><novalibra:NLTextBox ID="StoreSuppZoneGRP" runat="server" Width="40" ReadOnly="true" CssClass="calculatedField"></novalibra:NLTextBox></td>
					                                <td runat="server" id="WhseSuppZoneGRPFL" style="text-align: right; white-space: nowrap;">WHSE Supp Zone GRP:</td>
					                                <td><novalibra:NLTextBox ID="WhseSuppZoneGRP" runat="server" Width="60" ReadOnly="true" CssClass="calculatedField"></novalibra:NLTextBox></td>
					                            </tr>
					                            
					                            <tr>
					                                <td style="text-align: right; white-space: nowrap; width: 133px;"></td>
					                                <td></td>
					                                <td style="text-align: right; white-space: nowrap;">
                                                    </td>
                                                    <td>
                                                    </td>
					                            </tr>
					                            <tr>
					                                <td colspan="2">&nbsp;</td>
					                                <td style="text-align: right; white-space: nowrap;"></td>
					                                <td><novalibra:NLTextBox ID="ProjSalesPerStorePerMonth" runat="server" Width="60" MaxLength="9" Visible="False" ></novalibra:NLTextBox></td>
					                            </tr>
                                                <tr><td colspan="4">&nbsp;</td></tr>
							                    <tr><th colspan="4">Cost Information</th></tr>
							                    <tr><td colspan="4">&nbsp;</td></tr>
					                            <tr>
                                                    <td colspan="4">Estimated Landed Cost (All Figures For Each)</td>
							                    </tr>
							                    <tr>
					                                <td runat="server" id="DisplayerCostFL" colspan="1">Additional Cost Per Unit (US$)</td>
					                                <td><novalibra:NLTextBox ID="DisplayerCost" runat="server" Width="100" MaxLength="14" ></novalibra:NLTextBox></td>
					                                <td colspan="2">&nbsp;</td>
					                            </tr>
					                            <tr>
					                                <td runat="server" id="ProductCostFL" colspan="1">FOB First Cost (US$)</td>
					                                <td><novalibra:NLTextBox ID="ProductCost" runat="server" Width="100" MaxLength="14" ></novalibra:NLTextBox></td>
					                                <td colspan="2">&nbsp;</td>
					                            </tr>
					                            
					                            <tr>
					                                <td runat="server" id="FOBShippingPointFL" colspan="1">Total FOB First Cost (US$)</td>
					                                <td runat="server" id="FOBShippingPointParent" >
					                                    <novalibra:NLTextBox ID="FOBShippingPointEdit" runat="server" Width="100" MaxLength="14" ReadOnly="true" CssClass="calculatedField"></novalibra:NLTextBox>*
					                                    <asp:HiddenField ID="FOBShippingPoint" runat="server" />
					                                </td>
					                                <td colspan="2">&nbsp;</td>
					                            </tr>
					                            <tr>
					                                <td runat="server" id="DutyPercentFL" style="text-align: right;">Duty:</td>
					                                <td runat="server" id="DutyPercentParent" >
					                                    <novalibra:NLTextBox ID="DutyPercent" runat="server" Width="100" MaxLength="14" ></novalibra:NLTextBox>%</td>
					                                <td runat="server" id="DutyAmountParent" >
					                                    <novalibra:NLTextBox ID="DutyAmountEdit" runat="server" Width="100" MaxLength="14" ReadOnly="true" CssClass="calculatedField"></novalibra:NLTextBox>*
					                                    <asp:HiddenField ID="DutyAmount" runat="server" />
					                                </td>
					                                <td>&nbsp;</td>
					                            </tr>
					                            <tr>
					                                <td runat="server" id="AdditionalDutyFL" style="text-align: right;">Additional Duty:</td>
					                                <td><novalibra:NLTextBox ID="AdditionalDutyComment" runat="server" Width="100" MaxLength="100" ></novalibra:NLTextBox></td>
					                                <td><novalibra:NLTextBox ID="AdditionalDutyAmount" runat="server" Width="100"></novalibra:NLTextBox></td>
					                                <td>&nbsp;</td>
					                            </tr>
                                                <tr>
                                                    <td runat="server" id="SuppTariffPercentFL" style="text-align: right;">Supplementary Tariff:</td>
                                                    <td runat="server" id="SuppTariffPercentParent" >
                                                        <novalibra:NLTextBox ID="SuppTariffPercent" runat="server" Width="100" MaxLength="14" ></novalibra:NLTextBox>%</td>
                                                    <td runat="server" id="SuppTariffAmountParent" >
                                                        <novalibra:NLTextBox ID="SuppTariffAmountEdit" runat="server" Width="100" MaxLength="14" ReadOnly="true" CssClass="calculatedField"></novalibra:NLTextBox>*
                                                        <asp:HiddenField ID="SuppTariffAmount" runat="server" />
                                                    </td>
                                                    <td>&nbsp;</td>
                                                </tr>
					                            <tr>
					                                <td runat="server" id="OceanFreightAmountFL" style="text-align: right;">Ocean Freight: (Per CU. FT.)</td>
					                                <td>
					                                    <novalibra:NLTextBox ID="OceanFreightAmount" runat="server" Width="100" MaxLength="14" ></novalibra:NLTextBox></td>
					                                <td runat="server" id="OceanFreightComputedAmountParent" >
					                                    <novalibra:NLTextBox ID="OceanFreightComputedAmountEdit" runat="server" Width="100" ReadOnly="true" CssClass="calculatedField"></novalibra:NLTextBox>*
					                                    <asp:HiddenField ID="OceanFreightComputedAmount" runat="server" />
					                                </td>
					                                <td>&nbsp;</td>
					                            </tr>
					                            <tr id="agentCommissionRow" runat="server">
					                                <td runat="server" id="AgentCommissionAmountFL" style="text-align: right;">Merch Burden:</td>
					                                <td><novalibra:NLTextBox ID="AgentCommissionPercent" runat="server" Width="100" ></novalibra:NLTextBox>%</td>
					                                <td runat="server" id="AgentCommissionAmountParent" >
					                                    <novalibra:NLTextBox ID="AgentCommissionAmountEdit" runat="server" Width="100" ReadOnly="true" CssClass="calculatedField"></novalibra:NLTextBox>*
					                                    <asp:HiddenField ID="AgentCommissionAmount" runat="server" />
					                                </td>
					                            </tr>
                                                <tr id="RecagentCommissionRow"  runat="server">
                                                    <td runat="server" id="RecAgentCommissionAmountFL" style="text-align: right;">Rec. Merch Burden:</td>
                                                    <td><novalibra:NLTextBox ID="RecAgentCommissionPercent" runat="server" Width="100" ReadOnly="true" CssClass="calculatedField"></novalibra:NLTextBox>%</td>
                                                    <td colspan="2">&nbsp;</td>
                                                </tr>
					                            <tr>
					                                <td runat="server" id="OtherImportCostsPercentFL" style="text-align: right;">Other Import Costs:</td>
					                                <td runat="server" id="OtherImportCostsPercentParent" >
					                                    <novalibra:NLTextBox ID="OtherImportCostsPercentEdit" runat="server" Width="100" ReadOnly="true" CssClass="calculatedField"></novalibra:NLTextBox>%
					                                    <asp:HiddenField ID="OtherImportCostsPercent" runat="server" />
					                                </td>
					                                <td runat="server" id="OtherImportCostsAmountParent" >
					                                    <novalibra:NLTextBox ID="OtherImportCostsAmountEdit" runat="server" Width="100" ReadOnly="true" CssClass="calculatedField"></novalibra:NLTextBox>*
					                                    <asp:HiddenField ID="OtherImportCostsAmount" runat="server" />
					                                </td>
					                                <td>&nbsp;</td>
					                            </tr>
					                            <tr>
					                                <td style="text-align: right;">&nbsp;<!--PDQ Packaging Cost:--></td>
					                                <td>&nbsp;</td>
					                                <td>
					                                    <!--<novalibra:NLTextBox ID="PackagingCostAmountEdit" runat="server" Width="100" ></novalibra:NLTextBox>-->
					                                    <asp:HiddenField ID="PackagingCostAmount" runat="server" />
					                                </td>
					                                <td>&nbsp;</td>
					                            </tr>
					                            <tr>
					                                <td runat="server" id="TotalImportBurdenFL" style="text-align: right;">Total Import Burden:</td>
					                                <td>&nbsp;</td>
					                                <td runat="server" id="TotalImportBurdenParent" >
					                                    <novalibra:NLTextBox ID="TotalImportBurdenEdit" runat="server" Width="100" ReadOnly="true" CssClass="calculatedField"></novalibra:NLTextBox>*
					                                    <asp:HiddenField ID="TotalImportBurden" runat="server" />
					                                </td>
					                                <td>&nbsp;</td>
					                            </tr>
					                            <tr>
					                                <td runat="server" id="WarehouseLandedCostFL" style="text-align: right;">Total Warehouse Landed Cost:</td>
					                                <td>&nbsp;</td>
					                                <td runat="server" id="WarehouseLandedCostParent" >
					                                    <novalibra:NLTextBox ID="WarehouseLandedCostEdit" runat="server" Width="100" ReadOnly="true" CssClass="calculatedField"></novalibra:NLTextBox>*
					                                    <asp:HiddenField ID="WarehouseLandedCost" runat="server" />
					                                </td>
					                                <td>&nbsp;</td>
					                            </tr>
					                            <!--<tr><td colspan="4"><hr /></td></tr>-->
							                    <tr><td colspan="4">&nbsp;</td></tr>
							                    <tr><th colspan="4">Store Selling Cost / Retail Dollars&nbsp;</th></tr>
							                    <tr><td colspan="4">&nbsp;</td></tr>
					                            <tr>
					                                <td colspan="5">
					                                    <table>
					                                    <tr>
					                                        <td colspan="3">Calculate Store Selling Cost Each</td>
					                                        <td colspan="2" style="text-align: center;">Retail Dollars</td>
					                                    </tr>
					                                    <tr>
					                                        <td colspan="4">&nbsp;</td>
					                                        <td style="padding-left: 5px;">IMU%</td>
					                                        <td colspan="2">&nbsp;</td>
					                                        <td style="padding-left: 5px;">IMU%</td>
					                                    </tr>							            
					                                    <tr>
					                                        <td runat="server" id="FirstCostFL" colspan="1" style="text-align: right; white-space: nowrap;">Total FOB First Cost (US$)</td>
					                                        <td runat="server" id="FirstCostParent" >
					                                        <novalibra:NLTextBox ID="FirstCostEdit" runat="server" Width="60" MaxLength="15" ReadOnly="true" CssClass="calculatedField"></novalibra:NLTextBox>*
					                                        <asp:HiddenField ID="FirstCost" runat="server" />
					                                        </td>
					                                        <td runat="server" id="RDBaseFL" style="text-align: right; white-space: nowrap;">Low Elas3 (29):</td>
					                                        <td>
					                                        <novalibra:NLTextBox ID="RDBase" runat="server" Width="50" MaxLength="12"></novalibra:NLTextBox>
					                                        </td>
					                                        <td style="padding-left: 5px;"><span runat="server" id="RDBaseGM"></span>&nbsp;</td>
					                                        
					                                        <td runat="server" id="Retail9FL" style="text-align: right; white-space: nowrap;">Do Not Use (9):</td>
					                                        <td runat="server" id="Retail9Parent" >
					                                        <novalibra:NLTextBox ID="Retail9Edit" runat="server" Width="50" MaxLength="9"></novalibra:NLTextBox>
					                                        <asp:HiddenField ID="Retail9" runat="server"/>
					                                        </td>
					                                        <td style="padding-left: 5px;"><span runat="server" id="Retail9GM"></span>&nbsp;</td>
					                                    </tr>
					                                    <tr>
					                                        <td runat="server" id="StoreTotalImportBurdenFL" colspan="1" style="text-align: right; white-space: nowrap;">+ Total Import Burden</td>
					                                        <td runat="server" id="StoreTotalImportBurdenParent" >
					                                        <novalibra:NLTextBox ID="StoreTotalImportBurdenEdit" runat="server" Width="60" MaxLength="15" ReadOnly="true" CssClass="calculatedField"></novalibra:NLTextBox>*
					                                        <asp:HiddenField ID="StoreTotalImportBurden" runat="server" />
					                                        </td>
					                                        <td runat="server" id="RDCentralFL" style="text-align: right; white-space: nowrap;">High Elas3 (28):</td>
					                                        <td runat="server" id="RDCentralParent" >
					                                        <novalibra:NLTextBox ID="RDCentralEdit" runat="server" Width="50" MaxLength="9"></novalibra:NLTextBox>
					                                        <asp:HiddenField ID="RDCentral" runat="server" />
					                                        </td>
					                                        <td style="padding-left: 5px;"><span runat="server" id="RDCentralGM"></span>&nbsp;</td>
					                                        <td runat="server" id="Retail10FL" style="text-align: right; white-space: nowrap;">Do Not Use (10):</td>
					                                        <td runat="server" id="Retail10Parent" >
					                                        <novalibra:NLTextBox ID="Retail10Edit" runat="server" Width="50" MaxLength="9"></novalibra:NLTextBox>
					                                        <asp:HiddenField ID="Retail10" runat="server"/>
					                                        </td>
					                                        <td style="padding-left: 5px;"><span runat="server" id="Retail10GM"></span>&nbsp;</td>
					                                    </tr>
					                                    <tr>
					                                        <td runat="server" id="TotalWhseLandedCostFL" colspan="1" style="text-align: right; white-space: nowrap;">= Total WHSE. Landed Cost</td>
					                                        <td runat="server" id="TotalWhseLandedCostParent" >
					                                            <novalibra:NLTextBox ID="TotalWhseLandedCostEdit" runat="server" Width="60" MaxLength="15" ReadOnly="true" CssClass="calculatedField"></novalibra:NLTextBox>*
					                                            <asp:HiddenField ID="TotalWhseLandedCost" runat="server" />
					                                        </td>
					                                        <td runat="server" id="RDTestFL" style="text-align: right; white-space: nowrap;">Do Not Use (3):</td>
					                                        <td runat="server" id="RDTestParent" >
					                                        <novalibra:NLTextBox ID="RDTestEdit" runat="server" Width="50" MaxLength="9"></novalibra:NLTextBox>
					                                        <asp:HiddenField ID="RDTest" runat="server" />
					                                        </td>
					                                        <td style="padding-left: 5px;"><span runat="server" id="RDTestGM"></span>&nbsp;</td>
					                                        <td runat="server" id="Retail11FL" style="text-align: right; white-space: nowrap;">Do Not Use (11):</td>
					                                        <td runat="server" id="Retail11Parent" >
					                                        <novalibra:NLTextBox ID="Retail11Edit" runat="server" Width="50" MaxLength="9"></novalibra:NLTextBox>
					                                        <asp:HiddenField ID="Retail11" runat="server"/>
					                                        </td>
					                                        <td style="padding-left: 5px;"><span runat="server" id="Retail11GM"></span>&nbsp;</td>
					                                    </tr>
					                                    <tr>
					                                        <td runat="server" id="OutboundFreightFL" colspan="1" style="text-align: right; white-space: nowrap;">+ Outbound Freight</td>
					                                        <td runat="server" id="OutboundFreightParent" >
					                                            <novalibra:NLTextBox ID="OutboundFreightEdit" runat="server" Width="60" MaxLength="15" ReadOnly="true" CssClass="calculatedField"></novalibra:NLTextBox>*
					                                            <asp:HiddenField ID="OutboundFreight" runat="server" />
					                                        </td>
					                                        <td runat="server" id="RDAlaskaFL" style="text-align: right; white-space: nowrap;">High Cost (27):</td>
					                                        <td>
					                                            <novalibra:NLTextBox ID="RDAlaska" runat="server" Width="50" MaxLength="9"></novalibra:NLTextBox>
					                                        </td>
					                                        <td style="padding-left: 5px;"><span runat="server" id="RDAlaskaGM"></span>&nbsp;</td>
					                                        <td runat="server" id="Retail12FL" style="text-align: right; white-space: nowrap;">Do Not Use (12):</td>
					                                        <td runat="server" id="Retail12Parent" >
					                                            <novalibra:NLTextBox ID="Retail12Edit" runat="server" Width="50" MaxLength="9"></novalibra:NLTextBox>
					                                            <asp:HiddenField ID="Retail12" runat="server"/>
					                                        </td>
					                                        <td style="padding-left: 5px;"><span runat="server" id="Retail12GM"></span>&nbsp;</td>
					                                    </tr>
					                                    <tr>
					                                        <td runat="server" id="NinePercentWhseChargeFL" colspan="1" style="text-align: right; white-space: nowrap;">+ 9% WHSE. Charge</td>
					                                        <td runat="server" id="NinePercentWhseChargeParent" >
					                                            <novalibra:NLTextBox ID="NinePercentWhseChargeEdit" runat="server" Width="60" MaxLength="15" ReadOnly="true" CssClass="calculatedField"></novalibra:NLTextBox>*
					                                            <asp:HiddenField ID="NinePercentWhseCharge" runat="server" />
					                                        </td>
					                                        <td runat="server" id="RDCanadaFL" style="text-align: right; white-space: nowrap;">Canada (5):</td>
					                                        <td>
					                                            <novalibra:NLTextBox ID="RDCanada" runat="server" Width="50" MaxLength="9" ></novalibra:NLTextBox>
					                                        </td>
					                                        <td style="padding-left: 5px;"><span runat="server" id="RDCanadaGM"></span>&nbsp;</td>
					                                        <td runat="server" id="Retail13FL" style="text-align: right; white-space: nowrap;">E-Comm (21):</td>
					                                        <td runat="server" id="Retail13Parent" >
					                                            <novalibra:NLTextBox ID="Retail13Edit" runat="server" Width="50" MaxLength="9" ></novalibra:NLTextBox>
					                                            <asp:HiddenField ID="Retail13" runat="server"/>
					                                        </td>
					                                        <td style="padding-left: 5px;"><span runat="server" id="Retail13GM"></span>&nbsp;</td>
					                                    </tr>
					                                    <tr>
					                                        <td runat="server" id="TotalStoreLandedCostFL" colspan="1" style="text-align: right; white-space: nowrap;">= Total Store Landed Cost</td>
					                                        <td runat="server" id="TotalStoreLandedCostParent" >
					                                            <novalibra:NLTextBox ID="TotalStoreLandedCostEdit" runat="server" Width="60" MaxLength="15" ReadOnly="true" CssClass="calculatedField"></novalibra:NLTextBox>*
					                                            <asp:HiddenField ID="TotalStoreLandedCost" runat="server" />
					                                        </td>
					                                        <td runat="server" id="RD0Thru9FL" style="text-align: right; white-space: nowrap;">Canada2 (16):</td>
					                                        <td runat="server" id="RD0Thru9Parent" >
					                                            <novalibra:NLTextBox ID="RD0Thru9Edit" runat="server" Width="50" MaxLength="9"></novalibra:NLTextBox>
					                                            <asp:HiddenField ID="RD0Thru9" runat="server" />
					                                        </td>
					                                        <td style="padding-left: 5px;"><span runat="server" id="RD0Thru9GM"></span>&nbsp;</td>
					                                        <td runat="server" id="RDQuebecFL" style="text-align: right; white-space: nowrap;">Quebec (14):</td>
					                                        <td runat="server" id="RDQuebecParent" >
					                                            <novalibra:NLTextBox ID="RDQuebecEdit" runat="server" Width="50" MaxLength="9" ></novalibra:NLTextBox>
					                                            <asp:HiddenField ID="RDQuebec" runat="server"/>
					                                        </td>
					                                        <td style="padding-left: 5px;"><span runat="server" id="RDQuebecGM"></span>&nbsp;</td>
					                                    </tr>
					                                    </tr>
					                                    <tr>
					                                        <td colspan="2" style="text-align: right; white-space: nowrap;">&nbsp;</td>
					                                        <td runat="server" id="RDCaliforniaFL" style="text-align: right; white-space: nowrap;">Canada E-Comm (17):</td>
					                                        <td runat="server" id="RDCaliforniaParent" >
					                                            <novalibra:NLTextBox ID="RDCaliforniaEdit" runat="server" Width="50" MaxLength="9"></novalibra:NLTextBox>
					                                            <asp:HiddenField ID="RDCalifornia" runat="server" />
					                                        </td>
					                                        <td style="padding-left: 5px;"><span runat="server" id="RDCaliforniaGM"></span>&nbsp;</td>
					                                        <td runat="server" id="RDPuertoRicoFL" style="text-align: right; white-space: nowrap;">Comp (30):</td>
					                                        <td runat="server" id="RDPuertoRicoParent" >
					                                            <novalibra:NLTextBox ID="RDPuertoRicoEdit" runat="server" Width="50" MaxLength="9" ></novalibra:NLTextBox>
					                                            <asp:HiddenField ID="RDPuertoRico" runat="server"/>
					                                        </td>
					                                        <td style="padding-left: 5px;"><span runat="server" id="RDPuertoRicoGM"></span>&nbsp;</td>
					                                    </tr>
					                                    <tr>
					                                        <td colspan="2" style="text-align: right; white-space: nowrap;">&nbsp;</td>
					                                        <td runat="server" id="RDVillageCraftFL" style="text-align: right; white-space: nowrap;">Do Not Use (8):</td>
					                                        <td runat="server" id="RDVillageCraftParent" >
					                                            <novalibra:NLTextBox ID="RDVillageCraftEdit" runat="server" Width="50" MaxLength="9"></novalibra:NLTextBox>
					                                            <asp:HiddenField ID="RDVillageCraft" runat="server" />
					                                        </td>
					                                        <td style="padding-left: 5px;"><span runat="server" id="RDVillageCraftGM"></span>&nbsp;</td>
					                                    </tr>
					                                    </table>
                                                        </ContentTemplate>
                                                        </asp:UpdatePanel>
					                                </td>							                
							                    </tr>
							                    <!--<tr><td colspan="4"><hr /></td></tr>-->
							                    <tr><td colspan="4">&nbsp;</td></tr>
							                    <tr><th colspan="4">Hazardous Materials (Mark One)</th></tr>
							                    <tr><td colspan="4">&nbsp;</td></tr>
							                    <tr>
							                        <td colspan="4">
							                            <table cellpadding="0" cellspacing="0" border="0">
							                            <tr>
							                                <td colspan="6" style="text-align:center;"></td>
							                            </tr>
							                            <tr runat="server" id="HazMatParent" >
							                                <td style="text-align: right; white-space: nowrap; width: 100px;">Yes:</td>
							                                <td>
							                                    <novalibra:NLDropDownList ID="HazMatYes" runat="server" Width="50"  AutoPostBack="true">
							                                        <asp:ListItem Text="" Value=""></asp:ListItem>
							                                        <asp:ListItem Text="X" Value="X"></asp:ListItem>
							                                    </novalibra:NLDropDownList>
							                                </td>
							                                <td style="width: 100px;">&nbsp;</td>
							                                <td style="text-align: right;">No:</td>
							                                <td>
							                                    <novalibra:NLDropDownList ID="HazMatNo" runat="server" Width="50"  AutoPostBack="true">
							                                        <asp:ListItem Text="" Value=""></asp:ListItem>
							                                        <asp:ListItem Text="X" Value="X"></asp:ListItem>
							                                    </novalibra:NLDropDownList>
							                                </td>
							                            </tr>
							                            <tr>
							                                <td colspan="5">
							                                    <asp:Panel ID="P_HazMat" runat="server" Visible="false">
							                                        <table cellpadding="0" cellspacing="0" border="0">
							                                        <tr>
							                                            <td runat="server" id="HazMatMFGNameFL" style="text-align: right; white-space: nowrap;">MFG's Name:</td>
							                                            <td><novalibra:NLTextBox ID="HazMatMFGName" runat="server" Width="100" MaxLength="100" ></novalibra:NLTextBox></td>
							                                            <td style="width: 100px;">&nbsp;</td>
							                                            <td runat="server" id="HazMatMFGCountryFL" style="text-align: right; white-space: nowrap;">MFG's Country:</td>
							                                            <td><novalibra:NLTextBox ID="HazMatMFGCountry" runat="server" Width="100" MaxLength="100" ></novalibra:NLTextBox></td>
							                                        </tr>
							                                        <tr>
							                                            <td runat="server" id="HazMatMFGCityFL" style="text-align: right; white-space: nowrap;">MFG's City:</td>
							                                            <td><novalibra:NLTextBox ID="HazMatMFGCity" runat="server" Width="100" MaxLength="100" ></novalibra:NLTextBox></td>
							                                            <td>&nbsp;</td>
							                                            <td runat="server" id="HazMatMFGFlammableFL" style="text-align: right; white-space: nowrap;">Flammable:</td>
							                                            <td>
							                                                <novalibra:NLDropDownList ID="HazMatMFGFlammable" runat="server">
							                                                </novalibra:NLDropDownList>
							                                            </td>
							                                        </tr>
							                                        <tr>
							                                            <td runat="server" id="HazMatMFGStateFL" style="text-align: right; white-space: nowrap;">MFG's State:</td>
							                                            <td><novalibra:NLTextBox ID="HazMatMFGState" runat="server" Width="100" MaxLength="100" ></novalibra:NLTextBox></td>
							                                            <td>&nbsp;</td>
							                                            <td runat="server" id="HazMatContainerTypeFL" style="text-align: right; white-space: nowrap;">Container Type:</td>
							                                            <td>
							                                                <novalibra:NLDropDownList ID="HazMatContainerType" runat="server">
							                                                </novalibra:NLDropDownList>
							                                            </td>
							                                        </tr>
							                                        <tr>
							                                            <td runat="server" id="HazMatMFGPhoneFL" style="text-align: right; white-space: nowrap;">MFG's Phone:</td>
							                                            <td><novalibra:NLTextBox ID="HazMatMFGPhone" runat="server" Width="100" MaxLength="100" ></novalibra:NLTextBox></td>
							                                            <td>&nbsp;</td>
							                                            <td runat="server" id="HazMatContainerSizeFL" style="text-align: right; white-space: nowrap;">Container Size:</td>
							                                            <td><novalibra:NLTextBox ID="HazMatContainerSize" runat="server" Width="100" MaxLength="100" ></novalibra:NLTextBox></td>
							                                        </tr>
							                                        <tr>
							                                            <td colspan=3>&nbsp;</td>
							                                            <td runat="server" id="HazMatMSDSUOMFL" style="text-align: right; white-space: nowrap;">MSDS UOM:</td>
							                                            <td>
							                                                <novalibra:NLDropDownList ID="HazMatMSDSUOM" runat="server">
							                                                </novalibra:NLDropDownList>
							                                            </td>
							                                        </tr>
							                                        </table>
							                                    </asp:Panel>
							                                </td>
							                            </tr>
							                            </table>
							                        </td>
							                    </tr>
							                    <!--<tr><td colspan="4"><hr /></td></tr>-->
							                    <tr><td colspan="4">&nbsp;</td></tr>
							                    <tr><th colspan="4">Note: Vendor Must Check Below Yes Or No For Each Row</th></tr>
							                    <tr><td colspan="4">&nbsp;</td></tr>
							                    <tr>
							                        <td colspan="4">
							                            <table cellpadding="0" cellspacing="0" border="0">
							                            <tr>
							                                <td colspan="3" style="text-align: center;"></td>
							                            </tr>
							                            <tr>
							                                <td style="text-align: center;min-width:360px;" >Special Documents Required</td>
							                                <td style="width: 20px;">&nbsp;</td>
							                                <td style="text-align: center;">YES / NO</td>
							                            </tr>
							                            <tr>
							                                <td runat="server" id="CoinBatteryFL" >REESE'S LAW (Product Contains Button Cell/Coin Battery)</td>
							                                <td style="width: 20px;">&nbsp;</td>
							                                <td style="text-align: center;">
							                                    <novalibra:NLDropDownList ID="CoinBattery" runat="server" >
							                                        <asp:ListItem Value="" Text=""></asp:ListItem>
							                                        <asp:ListItem Value="Y" Text="Yes"></asp:ListItem>
							                                        <asp:ListItem Value="N" Text="No"></asp:ListItem>							                        
							                                    </novalibra:NLDropDownList>
							                                </td>
							                            </tr>
							                            <tr style="display:none;">
							                                <td runat="server" id="TSSAFL" >TSSA - STUFFED ARTICLES ACT CURRENT REGISTRATION (Canada)</td>
							                                <td style="width: 20px;">&nbsp;</td>
							                                <td style="text-align: center;">
							                                    <novalibra:NLDropDownList ID="TSSA" runat="server" >
							                                        <asp:ListItem Value="" Text=""></asp:ListItem>
							                                        <asp:ListItem Value="Y" Text="Yes"></asp:ListItem>
							                                        <asp:ListItem Value="N" Text="No"></asp:ListItem>							                        
							                                    </novalibra:NLDropDownList>
							                                </td>
							                            </tr>
							                            <tr>
							                                <td runat="server" id="CSAFL" >ELECTRICAL APPLIANCE STANDARDS - CSA, UL, INTERTEK (Canada)</td>
							                                <td style="width: 20px;">&nbsp;</td>
							                                <td style="text-align: center;">
							                                    <novalibra:NLDropDownList ID="CSA" runat="server" >
							                                        <asp:ListItem Value="" Text=""></asp:ListItem>
							                                        <asp:ListItem Value="Y" Text="Yes"></asp:ListItem>
							                                        <asp:ListItem Value="N" Text="No"></asp:ListItem>							                        
							                                    </novalibra:NLDropDownList>
							                                </td>
							                            </tr>
							                            <tr>
							                                <td runat="server" id="ULFL" >ELECTRICAL APPLIANCE STANDARDS - CSA, UL, INTERTEK (US)</td>
							                                <td style="width: 20px;">&nbsp;</td>
							                                <td style="text-align: center;">
							                                    <novalibra:NLDropDownList ID="UL" runat="server" >
							                                        <asp:ListItem Value="" Text=""></asp:ListItem>
							                                        <asp:ListItem Value="Y" Text="Yes"></asp:ListItem>
							                                        <asp:ListItem Value="N" Text="No"></asp:ListItem>							                        
							                                    </novalibra:NLDropDownList>
							                                </td>
							                            </tr>
							                            <tr>
							                                <td runat="server" id="LicenceAgreementFL" >LICENSING AGREEMENT</td>
							                                <td style="width: 20px;">&nbsp;</td>
							                                <td style="text-align: center;">
							                                    <novalibra:NLDropDownList ID="LicenceAgreement" runat="server" >
							                                        <asp:ListItem Value="" Text=""></asp:ListItem>
							                                        <asp:ListItem Value="Y" Text="Yes"></asp:ListItem>
							                                        <asp:ListItem Value="N" Text="No"></asp:ListItem>							                        
							                                    </novalibra:NLDropDownList>
							                                </td>
							                            </tr>
							                            <tr>
							                                <td runat="server" id="FumigationCertificateFL" >PHYTOSANITARY CERTIFICATE</td>
							                                <td style="width: 20px;">&nbsp;</td>
							                                <td style="text-align: center;">
							                                    <novalibra:NLDropDownList ID="FumigationCertificate" runat="server" >
							                                        <asp:ListItem Value="" Text=""></asp:ListItem>
							                                        <asp:ListItem Value="Y" Text="Yes"></asp:ListItem>
							                                        <asp:ListItem Value="N" Text="No"></asp:ListItem>							                        
							                                    </novalibra:NLDropDownList>
							                                </td>
							                            </tr>
							                            <tr>
							                                <td runat="server" id="KILNDriedCertificateFL" >KILN DRIED CERTIFICATE</td>
							                                <td style="width: 20px;">&nbsp;</td>
							                                <td style="text-align: center;">
							                                    <novalibra:NLDropDownList ID="KILNDriedCertificate" runat="server" >
							                                        <asp:ListItem Value="" Text=""></asp:ListItem>
							                                        <asp:ListItem Value="Y" Text="Yes"></asp:ListItem>
							                                        <asp:ListItem Value="N" Text="No"></asp:ListItem>							                        
							                                    </novalibra:NLDropDownList>
							                                </td>
							                            </tr>
							                            <tr>
							                                <td runat="server" id="ChinaComInspecNumAndCCIBStickersFL" >CHINA COMMODITY INSPECTION BUREAUS # AND CCIB STICKERS</td>
							                                <td style="width: 20px;">&nbsp;</td>
							                                <td style="text-align: center;">
							                                    <novalibra:NLDropDownList ID="ChinaComInspecNumAndCCIBStickers" runat="server" >
							                                        <asp:ListItem Value="" Text=""></asp:ListItem>
							                                        <asp:ListItem Value="Y" Text="Yes"></asp:ListItem>
							                                        <asp:ListItem Value="N" Text="No"></asp:ListItem>							                        
							                                    </novalibra:NLDropDownList>
							                                </td>
							                            </tr>
							                            <tr>
							                                <td runat="server" id="OriginalVisaFL" >ORIGINAL VISA</td>
							                                <td style="width: 20px;">&nbsp;</td>
							                                <td style="text-align: center;">
							                                    <novalibra:NLDropDownList ID="OriginalVisa" runat="server" >
							                                        <asp:ListItem Value="" Text=""></asp:ListItem>
							                                        <asp:ListItem Value="Y" Text="Yes"></asp:ListItem>
							                                        <asp:ListItem Value="N" Text="No"></asp:ListItem>							                        
							                                    </novalibra:NLDropDownList>
							                                </td>
							                            </tr>
							                            <tr>
							                                <td runat="server" id="TextileDeclarationMidCodeFL" >TEXTILE DECLARATION - MID CODE</td>
							                                <td style="width: 20px;">&nbsp;</td>
							                                <td style="text-align: center;">
							                                    <novalibra:NLDropDownList ID="TextileDeclarationMidCode" runat="server" >
							                                        <asp:ListItem Value="" Text=""></asp:ListItem>
							                                        <asp:ListItem Value="Y" Text="Yes"></asp:ListItem>
							                                        <asp:ListItem Value="N" Text="No"></asp:ListItem>							                        
							                                    </novalibra:NLDropDownList>
							                                </td>
							                            </tr>
							                            <tr>
							                                <td runat="server" id="QuotaChargeStatementFL" >QUOTA CHARGE STATEMENT</td>
							                                <td style="width: 20px;">&nbsp;</td>
							                                <td style="text-align: center;">
							                                    <novalibra:NLDropDownList ID="QuotaChargeStatement" runat="server" >
							                                        <asp:ListItem Value="" Text=""></asp:ListItem>
							                                        <asp:ListItem Value="Y" Text="Yes"></asp:ListItem>
							                                        <asp:ListItem Value="N" Text="No"></asp:ListItem>							                        
							                                    </novalibra:NLDropDownList>
							                                </td>
							                            </tr>
							                            <tr>
							                                <td runat="server" id="MSDSFL" >SDS - SAFETY DATA SHEET (formerly MSDS)</td>
							                                <td style="width: 20px;">&nbsp;</td>
							                                <td style="text-align: center;">
							                                    <novalibra:NLDropDownList ID="MSDS" runat="server" >
							                                        <asp:ListItem Value="" Text=""></asp:ListItem>
							                                        <asp:ListItem Value="Y" Text="Yes"></asp:ListItem>
							                                        <asp:ListItem Value="N" Text="No"></asp:ListItem>							                        
							                                    </novalibra:NLDropDownList>
							                                </td>
							                            </tr>
							                            <tr>
							                                <td runat="server" id="TSCAFL" >TSCA STATEMENT - TECHNICAL STANDARDS</td>
							                                <td style="width: 20px;">&nbsp;</td>
							                                <td style="text-align: center;">
							                                    <novalibra:NLDropDownList ID="TSCA" runat="server" >
							                                        <asp:ListItem Value="" Text=""></asp:ListItem>
							                                        <asp:ListItem Value="Y" Text="Yes"></asp:ListItem>
							                                        <asp:ListItem Value="N" Text="No"></asp:ListItem>							                        
							                                    </novalibra:NLDropDownList>
							                                </td>
							                            </tr>
							                            <tr>
							                                <td runat="server" id="DropBallTestCertFL" >DROP BALL TEST CERTIFICATION - SAFETY AUTHORITY</td>
							                                <td style="width: 20px;">&nbsp;</td>
							                                <td style="text-align: center;">
							                                    <novalibra:NLDropDownList ID="DropBallTestCert" runat="server" >
							                                        <asp:ListItem Value="" Text=""></asp:ListItem>
							                                        <asp:ListItem Value="Y" Text="Yes"></asp:ListItem>
							                                        <asp:ListItem Value="N" Text="No"></asp:ListItem>							                        
							                                    </novalibra:NLDropDownList>
							                                </td>
							                            </tr>
							                            <tr>
							                                <td runat="server" id="ManMedicalDeviceListingFL" >MANUFACTURERS MEDICAL DEVICE LISTING #</td>
							                                <td style="width: 20px;">&nbsp;</td>
							                                <td style="text-align: center;">
							                                    <novalibra:NLDropDownList ID="ManMedicalDeviceListing" runat="server" >
							                                        <asp:ListItem Value="" Text=""></asp:ListItem>
							                                        <asp:ListItem Value="Y" Text="Yes"></asp:ListItem>
							                                        <asp:ListItem Value="N" Text="No"></asp:ListItem>							                        
							                                    </novalibra:NLDropDownList>
							                                </td>
							                            </tr>
							                            <tr>
							                                <td runat="server" id="ManFDARegistrationFL" >MANUFACTURER'S FDA REGISTRATION</td>
							                                <td style="width: 20px;">&nbsp;</td>
							                                <td style="text-align: center;">
							                                    <novalibra:NLDropDownList ID="ManFDARegistration" runat="server" >
							                                        <asp:ListItem Value="" Text=""></asp:ListItem>
							                                        <asp:ListItem Value="Y" Text="Yes"></asp:ListItem>
							                                        <asp:ListItem Value="N" Text="No"></asp:ListItem>							                        
							                                    </novalibra:NLDropDownList>
							                                </td>
							                            </tr>
							                            <tr>
							                                <td runat="server" id="CopyRightIndemnificationFL" >COPYRIGHT INDEMNIFICATION</td>
							                                <td style="width: 20px;">&nbsp;</td>
							                                <td style="text-align: center;">
							                                    <novalibra:NLDropDownList ID="CopyRightIndemnification" runat="server" >
							                                        <asp:ListItem Value="" Text=""></asp:ListItem>
							                                        <asp:ListItem Value="Y" Text="Yes"></asp:ListItem>
							                                        <asp:ListItem Value="N" Text="No"></asp:ListItem>							                        
							                                    </novalibra:NLDropDownList>
							                                </td>
							                            </tr>
							                            <tr>
							                                <td runat="server" id="FishWildLifeCertFL" >FISH & WILDLIFE CERTIFICATE</td>
							                                <td style="width: 20px;">&nbsp;</td>
							                                <td style="text-align: center;">
							                                    <novalibra:NLDropDownList ID="FishWildLifeCert" runat="server" >
							                                        <asp:ListItem Value="" Text=""></asp:ListItem>
							                                        <asp:ListItem Value="Y" Text="Yes"></asp:ListItem>
							                                        <asp:ListItem Value="N" Text="No"></asp:ListItem>							                        
							                                    </novalibra:NLDropDownList>
							                                </td>
							                            </tr>
							                            <tr>
							                                <td runat="server" id="Proposition65LabelReqFL" >PROPOSITION 65 LABELING REQUIREMENTS (California)</td>
							                                <td style="width: 20px;">&nbsp;</td>
							                                <td style="text-align: center;">
							                                    <novalibra:NLDropDownList ID="Proposition65LabelReq" runat="server" >
							                                        <asp:ListItem Value="" Text=""></asp:ListItem>
							                                        <asp:ListItem Value="Y" Text="Yes"></asp:ListItem>
							                                        <asp:ListItem Value="N" Text="No"></asp:ListItem>							                        
							                                    </novalibra:NLDropDownList>
							                                </td>
							                            </tr>
							                            <tr>
							                                <td runat="server" id="CCCRFL" >CCCR - CONSUMER CHEMICAL & CONTAINER REGULATION (Canada)</td>
							                                <td style="width: 20px;">&nbsp;</td>
							                                <td style="text-align: center;">
							                                    <novalibra:NLDropDownList ID="CCCR" runat="server" >
							                                        <asp:ListItem Value="" Text=""></asp:ListItem>
							                                        <asp:ListItem Value="Y" Text="Yes"></asp:ListItem>
							                                        <asp:ListItem Value="N" Text="No"></asp:ListItem>							                        
							                                    </novalibra:NLDropDownList>
							                                </td>
							                            </tr>
							                            <tr>
							                                <td runat="server" id="FormaldehydeCompliantFL" >FORMALDEHYDE COMPLIANT</td>
							                                <td style="width: 20px;">&nbsp;</td>
							                                <td style="text-align: center;">
							                                    <novalibra:NLDropDownList ID="FormaldehydeCompliant" runat="server" >
							                                        <asp:ListItem Value="" Text=""></asp:ListItem>
							                                        <asp:ListItem Value="Y" Text="Yes"></asp:ListItem>
							                                        <asp:ListItem Value="N" Text="No"></asp:ListItem>							                        
							                                    </novalibra:NLDropDownList>
							                                </td>
							                            </tr>       
														<tr>
							                                <td runat="server" id="PhytoTemporaryShipmentFL" >PHYTO TEMPORARY SHIPMENT</td>
							                                <td style="width: 20px;">&nbsp;</td>
							                                <td style="text-align: center;">
							                                    <novalibra:NLDropDownList ID="PhytoTemporaryShipment" runat="server" >
							                                        <asp:ListItem Value="" Text=""></asp:ListItem>
							                                        <asp:ListItem Value="Y" Text="Yes"></asp:ListItem>
							                                        <asp:ListItem Value="N" Text="No"></asp:ListItem>							                        
							                                    </novalibra:NLDropDownList>
							                                </td>
							                            </tr>
							                            </table>
							                        </td>
							                    </tr>
							                    
							                    <% If ShowRMSFields = True Then%>
							                    <!--<tr><td colspan="4"><hr /></td></tr>-->
							                    <tr><td colspan="4">&nbsp;</td></tr>
							                    <tr><th colspan="4" style="height: 20px">RMS</th></tr>
							                    <tr><td colspan="4">&nbsp;</td></tr>
							                    <tr>
							                        <td colspan="4">
							                            <table cellpadding="1" cellspacing="0" border="0" >
									                        <tr>
										                        <td valign="top"><table cellpadding="3" cellspacing="0" border="0">
												                        <tr>
													                        <td runat="server" id="RMSSellableFL" class="formLabel" style="text-align: right; white-space:nowrap;">RMS Sellable<span id="RMSSellableRF" class="requiredFieldsIcon" runat="server">*</span>:</td>
													                        <td class="formField">
														                        <novalibra:NLDropDownList ID="RMSSellable" runat="server">
														                        </novalibra:NLDropDownList>
													                        </td>
												                        </tr>
												                        <tr>
													                        <td runat="server" id="RMSOrderableFL" class="formLabel" style="text-align: right; white-space:nowrap;">RMS Orderable<span id="RMSOrderableRF" class="requiredFieldsIcon" runat="server">*</span>:</td>
													                        <td class="formField">
														                        <novalibra:NLDropDownList ID="RMSOrderable" runat="server">
														                        </novalibra:NLDropDownList>
													                        </td>
												                        </tr>
												                        <tr>
													                        <td runat="server" id="RMSInventoryFL" class="formLabel" style="text-align: right; white-space:nowrap;">RMS Inventory<span id="RMSInventoryRF" class="requiredFieldsIcon" runat="server">*</span>:</td>
													                        <td class="formField">
														                        <novalibra:NLDropDownList ID="RMSInventory" runat="server">
														                        </novalibra:NLDropDownList>
													                        </td>
												                        </tr>
											                        </table>
											                    </td>
									                        </tr>
								                        </table>
							                        </td>
							                    </tr>
							                    <% End If %>
							                    
							                    <!--<tr><td colspan="4"><hr /></td></tr>-->
							                    <tr><td colspan="4">&nbsp;</td></tr>
							                    <tr><th colspan="4" style="height: 19px">Like Item Approval</th></tr>
							                    <tr>
							                        <td colspan="4">
							                            <table cellpadding="1" cellspacing="0" border="0" >
									                        <tr>
										                        <td valign="top" style="width: 281px">
										                            <table cellpadding="3" cellspacing="0" border="0">
										                                <tr>
													                        <td runat="server" id="CalculateOptionsFL" colspan="1" style="text-align: right; white-space:nowrap;">Select Forecast Type:</td>
													                        <td class="formField"><novalibra:NLDropDownList ID="CalculateOptions" runat="server" >
													                            <asp:ListItem Value="0" Text="0-No Selection"></asp:ListItem>
                                                                                <asp:ListItem Value="1" Text="1-Provide Annual Forecast"></asp:ListItem>
                                                                                <asp:ListItem Value="2" Text="2-Provide Units/Store/Month"></asp:ListItem>
													                        </novalibra:NLDropDownList></td>
												                        </tr>
												                        <tr>
													                        <td runat="server" id="storeTotalFL" class="formLabel" style="text-align: right; white-space:nowrap; width: 118px;">Store Total:</td>
													                        <td class="formField">
														                        <novalibra:NLTextBox ID="storeTotal" runat="server" Width="100" MaxLength="10" ></novalibra:NLTextBox>
													                        </td>
												                        </tr>
												                        <tr>
													                        <td runat="server" id="POGStartDateFL" class="formLabel" style="text-align: right; white-space:nowrap; width: 118px;">POG Start Date:</td>
													                        <td class="formField">
														                        <novalibra:NLTextBox ID="POGStartDate" runat="server" Width="100" MaxLength="10" ></novalibra:NLTextBox>
													                        </td>
												                        </tr>
												                        <tr>
													                        <td runat="server" id="POGCompDateFL" class="formLabel" style="text-align: right; white-space:nowrap; width: 118px;">POG Comp Date:</td>
													                        <td class="formField">
														                        <novalibra:NLTextBox ID="POGCompDate" runat="server" Width="100" MaxLength="10" ></novalibra:NLTextBox>
													                        </td>
												                        </tr><!-- 'RegUnitForecast >> AnnualRegularUnitForecast     -->
												                        <tr> 
													                        <td runat="server" id="AnnualRegularUnitForecastFL" class="formLabel" style="text-align: right; white-space:nowrap; width: 138px; height: 34px;">
                                                                                Annual Regular Unit Forecast (52 Week):</td>
													                        <td runat="server" id="AnnualRegularUnitForecastParent" class="formField">
													                            <novalibra:NLTextBox ID="AnnualRegularUnitForecast" runat="server" MaxLength="9" Width="91" Height="15px" CssClass="calculatedField"></novalibra:NLTextBox>*
													                            <asp:HiddenField ID="calculatedAnnualRegularUnitForecast" runat="server" />
                                                                            </td>
												                        </tr>
												                        <tr>
													                        <td runat="server" id="calculatedLikeItemUnitStoreMonthFL" class="formLabel" style="text-align: right; white-space:nowrap; width: 138px;">
                                                                                Avg Reg Units/Store/Month:</td>
													                        <td runat="server" id="calculatedLikeItemUnitStoreMonthParent" class="formField">
														                        <novalibra:NLTextBox ID="calculatedLikeItemUnitStoreMonthEdit" runat="server" Width="91" Height="15px" CssClass="calculatedField"></novalibra:NLTextBox>*
							                                                    <asp:HiddenField ID="calculatedLikeItemUnitStoreMonth" runat="server" />
													                        </td>
												                        </tr>
												                        <tr>
													                        <td runat="server" id="facingsFL" class="formLabel" style="text-align: right; white-space:nowrap; width: 138px;">Facings:</td>
													                        <td class="formField">
														                        <novalibra:NLTextBox ID="facings" runat="server" Width="97px" MaxLength="9" ></novalibra:NLTextBox>&nbsp;
													                        </td>
												                        </tr>
												                        <tr>
                                                                            <td runat="server" id="POGMaxQtyFL" class="formLabel" style="text-align: right; white-space:nowrap; width: 138px;">POG Max Qty:</td>
                                                                            <td class="formField"><novalibra:NLTextBox ID="POGMaxQty" runat="server" Width="40" MaxLength="9" ></novalibra:NLTextBox></td>
                                                                        </tr>
											                        </table>
											                    </td>
											                    <td valign="top">
											                        <table cellpadding="3" cellspacing="0" border="0">
											                            <tr>
													                        <td runat="server" id="likeItemSKUFL" class="formLabel" style="text-align: right; white-space:nowrap; width: 138px;">Like Item SKU:</td>
													                        <td class="formField">
														                        <novalibra:NLTextBox ID="likeItemSKU" runat="server" Width="100" MaxLength="20" ></novalibra:NLTextBox>
													                        </td>
												                        </tr>
												                        <tr>
													                        <td runat="server" id="likeItemDescriptionFL" class="formLabel" style="text-align: right; white-space:nowrap; width: 138px;">Like Item Description:</td>
													                        <td runat="server" id="likeItemDescriptionParent" class="formField">
														                        <novalibra:NLTextBox ID="likeItemDescriptionEdit" runat="server" Width="150" ReadOnly="true" CssClass="calculatedField"></novalibra:NLTextBox>*
							                                                    <asp:HiddenField ID="likeItemDescription" runat="server" />
													                        </td>
												                        </tr>
												                        <tr>
													                        <td runat="server" id="likeItemRetailFL" class="formLabel" style="text-align: right; white-space:nowrap; width: 138px;">Like Item Retail $:</td>
													                        <td runat="server" id="likeItemRetailParent" class="formField">
														                        <novalibra:NLTextBox ID="likeItemRetailEdit" runat="server" Width="100" ReadOnly="true" CssClass="calculatedField" Height="15px"></novalibra:NLTextBox>*
							                                                    <asp:HiddenField ID="likeItemRetail" runat="server" />
													                        </td>
												                        </tr>
												                        <tr>
                                                                            <td runat="server" id="likeItemStoreCountFL" class="formLabel" style="width: 118px; white-space: nowrap; width: 138px; height: 20px; text-align: right">
                                                                                Like Item Store Count:</td>
                                                                            <td class="formField" style="height: 20px">
                                                                                <novalibra:NLTextBox ID="likeItemStoreCount" runat="server" MaxLength="4" Width="80px"></novalibra:NLTextBox></td>
                                                                        </tr>
												                        <tr>
													                        <td runat="server" id="likeItemRegularUnitFL" class="formLabel" style="text-align: right; white-space:nowrap; height: 11px;">
                                                                                "Seasonality"&nbsp;Like Item<br />
                                                                                &nbsp;Regular Unit (52 Week):</td>
													                        <td class="formField" style="height: 11px; position: relative; top: 10px;">
														                        <novalibra:NLTextBox ID="likeItemRegularUnit" runat="server" Width="97px" MaxLength="14" Height="16px" style="position: relative; top: 10px" ></novalibra:NLTextBox></td>
												                        </tr>       
												                        <tr>
													                        <td runat="server" id="AnnualRegRetailSalesFL" class="formLabel" style="text-align: right; white-space:nowrap;">
                                                                                Annual Reg Retail Sales $:</td>
                                                                            <td runat="server" id="AnnualRegRetailSalesParent" class="formField">
														                        <novalibra:NLTextBox ID="AnnualRegRetailSalesEdit" runat="server" Width="100" ReadOnly="true" CssClass="calculatedField" Height="15px"></novalibra:NLTextBox>*
														                        <asp:HiddenField ID="AnnualRegRetailSales" runat="server" />
													                        </td>
												                        </tr>
												                        
												                        <tr>
												                            <td runat="server" id="POGMinQtyFL" class="formLabel" style="text-align: right; white-space:nowrap;">
                                                                            PQPF ( Min Pres per Facing):</td>
													                        <td class="formField">
														                        <novalibra:NLTextBox ID="POGMinQty" runat="server" Width="40px" MaxLength="9" ></novalibra:NLTextBox>
													                        </td>
												                        </tr>
                                                                        
												                        <tr>
												                            <td runat="server" id="POGSetupPerStoreFL" class="formLabel" style="text-align: right; white-space:nowrap;">Initial Set Qty Per Store:</td>
					                                                        <td class="formField">
					                                                            <novalibra:NLTextBox ID="POGSetupPerStore" runat="server" Width="40" MaxLength="9" ></novalibra:NLTextBox>
					                                                        </td>
												                        </tr>
											                        </table>
											                    </td>
									                        </tr>
								                        </table>
							                        </td>
							                    </tr>
							                    
							                    <!--<tr><td colspan="4"><hr /></td></tr>-->
							                    <tr><td colspan="4">&nbsp;</td></tr>
							                    <tr><th colspan="4">Item Image / Item MSDS Sheet</th></tr>
							                    <tr><td colspan="4">&nbsp;</td></tr>
							                    <tr>
							                        <td colspan="4" style="height: 140px">
							                            <table cellpadding="0" cellspacing="0" border="0">
							                                <tr>
							                                    <td width="4" style="width: 4px" valign="top"><img src="images/spacer.gif" width="4" height="1" alt="" /></td>
							                                    <td runat="server" id="Image_IDFL" width="260" style="width: 260px" valign="top">
							                                        <table cellpadding="0" cellspacing="0" border="0">
					                                                    <tr>
					                                                        <td style="white-space: nowrap;"><strong>Item Image</strong></td>
					                                                        <td style="white-space: nowrap;" align="right">
					                                                            <asp:HiddenField ID="ImageID" runat="server" />
					                                                            <input type="button" id="B_UpdateImage" runat="server" value="Upload" class="formButton" />
					                                                            <input type="button" id="B_DeleteImage" runat="server" value="Delete" class="formButton" />
					                                                        </td>
					                                                    </tr>
					                                                    <tr>
					                                                        <td colspan="2" style="border: solid 1px">
					                                                            <div id="DIV_Image" runat="server" style="width: 260px; text-align: center; background-color: #eee8aa;">
					                                                            <asp:Image ID="I_Image" runat="server" Visible="false" BorderColor="#d3d3a3" BorderWidth="5" /><br />
					                                                            <span class="subHeading" id="I_Image_Label" runat="server">(click on image to view full size)</span>
                                                                                </div>
					                                                        </td>
					                                                    </tr>							                            
					                                                </table>
							                                    </td>
							                                    <td width="7" style="width: 7px" valign="top"><img src="images/spacer.gif" width="7" height="1" alt="" /></td>
                                                                <td style="width: 1px; border-right: solid 1px #000000;">&nbsp;</td>
                                                                <td style="width: 1px;">&nbsp;</td>
							                                    <td width="7" style="width: 7px" valign="top"><img src="images/spacer.gif" width="7" height="1" alt="" /></td>
							                                    <td runat="server" id="MSDS_IDFL" Width="300" style="width: 220px" valign="top">
							                                        <table cellpadding="0" cellspacing="0" border="0">
					                                                    <tr>
					                                                        <td style="white-space: nowrap;"><strong>Item MSDS Sheet</strong></td>
					                                                        <td style="white-space: nowrap;" align="right">
					                                                            <asp:HiddenField ID="MSDSID" runat="server" />
					                                                            <input type="button" id="B_UpdateMSDS" runat="server" value="Upload" class="formButton" />
					                                                            <input type="button" id="B_DeleteMSDS" runat="server" value="Delete" class="formButton" />
					                                                        </td>
					                                                    </tr>
					                                                    <tr>
					                                                        <td colspan="2" style="border: solid 1px">
					                                                            <div id="DIV_MSDS" runat="server" style="width: 220px; text-align: center; background-color: #eee8aa;">
					                                                            <asp:Image ID="I_MSDS" runat="server" Visible="false" BorderColor="#d3d3a3" BorderWidth="5" /><br />
					                                                            <span class="subHeading" id="I_MSDS_Label" runat="server">(click on icon to view MSDS Sheet)</span>
                                                                                </div>
					                                                        </td>
					                                                    </tr>							                            
					                                                </table>
							                                    </td>
							                                    <td width="7" style="width: 7px" valign="top"><img src="images/spacer.gif" width="7" height="1" alt="" /></td>
                                                                <td style="width: 1px; border-right: solid 1px #000000;">&nbsp;</td>
							                                </tr>
							                            </table>
					                                    
							                        </td>
							                    </tr>
							                    
							                    <% If Me.custFields.FieldCount > 0 Then%>
							                    <!--<tr><td colspan="4"><hr /></td></tr>-->
							                    <tr><td colspan="4">&nbsp;</td></tr>
							                    <tr><th colspan="4" style="height: 20px">Custom Fields</th></tr>
							                    <tr><td colspan="4">&nbsp;</td></tr>
							                    <tr>
							                        <td colspan="4">
							                            <table cellpadding="1" cellspacing="0" border="0" >
									                        <tr>
										                        <td valign="top"><table cellpadding="3" cellspacing="0" border="0">
												                        <novalibra:NLCustomFields ID="custFields" runat="server"></novalibra:NLCustomFields>
											                        </table>
											                    </td>
									                        </tr>
								                        </table>
							                        </td>
							                    </tr>
							                    <% End If %>
							                    
							                    </table>
							                </td>
							            </tr>
							            </table>
							        </td>
						        </tr>
						        
						        </table>				
						    </td>
						</tr>
						<tr><td colspan="2" style="height: 15px;">&nbsp;</td></tr>
						<tr>
                            <th colspan="2" class="detailFooter">
                                <table border="0" cellpadding="0" cellspacing="0" style="width: 911px;" width="911">
                                    <tr>
                                        <td width="50%" style="width: 50%;" align="left" valign="top">
                                            <input type="button" id="btnCancel" onclick="cancelForm();" value="Cancel" class="formButton" />&nbsp;
                                        </td>
                                        <td width="50%" style="width: 50%;" align="right" valign="top">
                                            &nbsp;<asp:Button UseSubmitBehavior="false" ID="btnUpdate" runat="server" CommandName="Update" Text="Save" CssClass="formButton" /> 
                                            &nbsp;&nbsp;<asp:Button UseSubmitBehavior="false" ID="btnUpdateClose" runat="server" CommandName="UpdateClose" Text="Save &amp; Close" CssClass="formButton" />
                                        </td>
                                    </tr>
                                </table>
                            </th>
                        </tr>
						</table>
						
					</div>
				
			</div>
		</div>
	</div>
	
	<div id="settingsDiv" style="display:none">
	
	</div>
	
<!-- duplicate item -->

<div id="dupItem" onclick="" onmouseover="" onmouseout="" style="position:absolute; left:300px; top: 300px; display: none; z-index: 2000; width: 250px; background-color: #ececec; border: 1px solid #333333; cursor: default;">
	<div id="dupItemContent">
	    <table border="0" cellpadding="0" cellspacing="0" class="dupItemBG" style="width: 100%">
	    <tr><td>
	        <table border="0" cellpadding="2" cellspacing="1" style="width: 100%;">
	            <tr>
	                <td id="dupItemHeader"><img align="right" id="close" src="images/close.gif" alt="Close" title="" border="0" onclick="duplicateClose();" />Duplicate Item</td>
	            </tr>
	            <!--
	            <tr class="dupItemRow">
	                <td style="width: 100%;"><span id="dupItemColumn">Duplicate Item</span>
	                </td>
	            </tr>
	            -->
	            <tr class="dupItemRow">
	                <td id="dupItemData"><input type="hidden" id="dupItemID" value="" />How Many?&nbsp;&nbsp;<input type="text" id="dupItemHowMany" runat="server" value="" size="2" maxlength="2" /></td>
	            </tr>
	            <tr class="dupItemRow<%If IsPack Then Response.Write(" hideElement")%>">
	                <td id="dupItemDataType"><input type="checkbox" id="dupItemRegular" value="1" runat="server"/> &nbsp;Create a batch of regular items?</td>
	            </tr>
	            <tr class="dupItemRow">
	                <td id="dupItemBlank">&nbsp;</td>
	            </tr>
	            <tr class="dupItemFooter">
	                <td>
	                    <table border="0" cellpadding="0" cellspacing="0" style="width: 100%;" class="dupItemFooter">
	                        <tr>
	                            <td align="left"><input type="button" id="btnDupItemClose" onclick="duplicateClose()" value="Cancel" class="formButton" style="font-weight: bold;" /></td>
	                            <td align="right"><input type="button" id="btnDupItemSave" onclick="duplicateSave()" value="Duplicate" class="formButton" style="font-weight: bold;" /></td>
	                        </tr>
	                    </table>
	                </td>
	            </tr>
	        </table>
	    </td></tr>
	    </table>
	</div>
</div>

<!-- add to batch -->

<div id="addToBatch" onclick="" onmouseover="" onmouseout="" style="position:absolute; left:300px; top: 300px; display: none; z-index: 2000; width: 250px; background-color: #ececec; border: 1px solid #333333; cursor: default;">
	<div id="addToBatchContent">
	    <table border="0" cellpadding="0" cellspacing="0" class="addToBatchBG" style="width: 100%">
	    <tr><td>
	        <table border="0" cellpadding="2" cellspacing="1" style="width: 100%;">
	            <tr>
	                <td id="addToBatchHeader"><img align="right" id="close2" class="closeImage" src="images/close.gif" alt="Close" title="" border="0" onclick="addToBatchClose();" />Add to Batch</td>
	            </tr>
	            <!--
	            <tr class="addToBatchRow">
	                <td style="width: 100%;"><span id="addToBatchColumn"></span>
	                </td>
	            </tr>
	            -->
	            <tr class="addToBatchRow" id="addToBatchBlankRow">
	                <td>&nbsp;</td>
	            </tr>
	            <tr class="addToBatchRow" id="addToBatchSelectRow">
	                <td id="addToBatchData"><input type="hidden" id="addToBatchID" value="" runat="server" />Select another batch to add to this one:&nbsp;&nbsp;</td>
	            </tr>
	            <tr class="addToBatchRow" id="addToBatchListRow">
	                <td id="addToBatchDataSelect">
                        <novalibra:NLDropDownList ID="addToBatchList" runat="server"></novalibra:NLDropDownList>
                    </td>
	            </tr>
	            <tr class="addToBatchRow" id="addToBatchMessageRow">
	                <td id="addToBatchMessage"><span style="font-style: italic;">Sorry, there are no eligible batches to add.</span>&nbsp;</td>
	            </tr>
	            <tr class="addToBatchRow">
	                <td id="addToBatchBlank">&nbsp;</td>
	            </tr>
	            <tr class="opBoxFooter">
	                <td>
	                    <table border="0" cellpadding="0" cellspacing="0" style="width: 100%;" class="opBoxFooter">
	                        <tr>
	                            <td align="left"><input type="button" id="btnAddToBatchClose" onclick="addToBatchClose()" value="Cancel" class="formButton" style="font-weight: bold;" /></td>
	                            <td align="right"><input type="button" id="btnAddToBatchSave" onclick="addToBatchSave()" value="Add to Batch" class="formButton" style="font-weight: bold;" /></td>
	                        </tr>
	                    </table>
	                </td>
	            </tr>
	        </table>
	    </td></tr>
	    </table>
	</div>
</div>

<!-- Stocking Strategy Helper -->
<div id="StockStratHelper" onclick="" onmouseover="" onmouseout="" style="position:absolute; left:400px; top: 500px; display: none; z-index: 3000; width: 500px; background-color: #ececec; border: 1px solid #333333; cursor: default;">
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
                                            <div style="OVERFLOW-Y:scroll; WIDTH:200px; HEIGHT:150px">
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

<script language="javascript" type="text/javascript">
<!--
initPageOnLoad();
//-->
</script>

    </form>
    
    
</body>
</html>

