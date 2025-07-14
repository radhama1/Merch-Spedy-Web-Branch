<%@ Page Language="VB" AutoEventWireup="false" CodeFile="IMImportForm.aspx.vb" Inherits="IMImportForm" ValidateRequest="false" %>
<%@ Register Src="NovaGrid.ascx" TagName="NovaGrid" TagPrefix="ucgrid" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE10" />
    <title>Item Data Management</title>
    <link rel="stylesheet" href="css/styles.css" type="text/css" />
    <link href="nlcontrols/nlcontrols.css" rel="stylesheet" type="text/css" />
    <style type="text/css">
        th
        {
            text-align: left;
            padding: 5px;
        }
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
        div.autocomplete
        {
            position: absolute;
            width: 250px;
            background-color: white;
            border: 1px solid #888;
            margin: 0px;
            padding: 0px;
            height: 70px;
            overflow: auto;
        }
        div.autocomplete ul
        {
            list-style-type: none;
            margin: 0px;
            padding: 0px;
        }
        div.autocomplete ul li.selected
        {
            background-color: #ffb;
        }
        div.autocomplete ul li
        {
            list-style-type: none;
            display: block;
            margin: 0;
            padding: 1px;
            cursor: pointer;
        }
        /*
div.autocomplete {
  position:absolute;
  width:240px;
  background-color:white;
  border:1px solid #888;
  margin:0px;
  padding:0px;
  height: 100px;
  overflow: auto;
        top: 2559px;
        left: 349px;
}
*/
        #nlcCCOrigC_ImageID .nlcCCT, #nlcCCOrigC_MSDSID .nlcCCT
        {
            padding-left: 0;
        }
        #I_Image_ORIG, #I_MSDS_ORIG
        {
            padding-top: 10px;
        }
        .nlcCCC
        {
            margin: 0;
            padding: 0;
            border-width: 0px;
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

    <script language="javascript" type="text/javascript" src="./IMImportForm.js?v=139"></script>

    <script type="text/javascript" language="javascript" src="nlcontrols/nlcontrols.js"></script>

    <script type="text/javascript">
<!--
        //var callbackSep = "<%=CALLBACK_SEP%>";

        function cancelForm() {
            if (confirm('Cancel adding/updating this item?'))
                window.location = 'default.aspx';
        }
        //var disableTaxWizard = false;
        function openTaxWizard(id) {
            //if (disableTaxWizard == true) return false;
            var url = 'Tax_Wizard.aspx?type=I&id=' + id;
            var win = window.open(url, 'taxwiz', 'scrollbars=0,location=0,menubar=0,titlebar=0,toolbar=0,width=700,HEIGHT=525');
            return false;
        }
        function openTaxWizardSA(id, bid) {
            //if (disableTaxWizard == true) return false;
            var url = 'Tax_Wizard.aspx?type=I&id=' + id + '&sa=1&bid=' + bid;
            var win = window.open(url, 'taxwiz', 'scrollbars=0,location=0,menubar=0,titlebar=0,toolbar=0,width=700,HEIGHT=525');
            return false;
        }
        function updateItemTaxWizard(id, completed, taxUDA) {
            if (!completed || completed == null)
                completed = false;
            if (taxUDA == null) taxUDA = 0;
            if (!isNum(taxUDA)) taxUDA = 0;
            var imgID = 'taxWizard';
            if ($(imgID)) {
                $(imgID).src = (completed) ? 'images/checkbox_true.gif' : 'images/checkbox_false.gif';
                $('taxWizardComplete').value = (completed) ? '1' : '0';
            }
            var i, val = '', text = '';
            var o = $('TaxUDA')
            if (o) {
                for (i = 0; i < o.options.length; i++) {
                    if (o.options[i].value == taxUDA.toString()) {
                        o.selectedIndex = i;
                        val = o.options[i].value;
                        text = o.options[i].text;
                        break;
                    }
                }
            }
            if ($('TaxUDALabel')) $('TaxUDALabel').innerText = text;
            $('TaxUDAValue').value = val;
        }

        function showExcel() {
            document.location = 'importexport.aspx?hid=<%=ItemID%>';
            return false;
        }

        function initPage() {
            //calculateGMPercent(true);
            //LP Change Order 14
            calculateIMUPercent('SmallMarketRetail');
            calculateIMUPercent('Base2Retail');
            calculateIMUPercent('TestRetail');
            calculateIMUPercent('High2Retail');
            calculateIMUPercent('High3Retail');
            //change order 14
            calculateIMUPercent('High1Retail');
            calculateIMUPercent('Base3Retail');
            calculateIMUPercent('Low1Retail');
            calculateIMUPercent('Low2Retail');
            calculateIMUPercent('ManhattanRetail');
            calculateIMUPercent('QuebecRetail');
            calculateIMUPercent('PuertoRicoRetail');
            calculateIMUPercent('CanadaRetail');

        }

//-->
    </script>

</head>
<body onload="CalculateOptionsChanged();" style="background-color: #dedede">
    <form id="form1" runat="server">
    <asp:HiddenField ID="hid" runat="server" />
    <asp:HiddenField ID="additionalUPCValues" runat="server" />
    <asp:HiddenField ID="additionalCOOStart" runat="server" />
    <asp:HiddenField ID="additionalCOOEnd" runat="server" />
    <asp:HiddenField ID="additionalCOOCount" runat="server" Value="" />
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true" AsyncPostBackTimeout="4500" ></asp:ScriptManager>
    <div id="sitediv">
        <div id="bodydiv">
            <div id="content">
                <div id="submissiondetail">
                    <table cellpadding="0" cellspacing="0" border="0" width="100%">
                        <tr>
                            <td colspan="3">
                                <table border="0" cellpadding="0" cellspacing="0" width="100%">
                                    <tr>
                                        <td valign="bottom" style="width: 189px;">
                                            <img src="images/spacer.gif" border="0" alt="" height="1" width="189" />
                                        </td>
                                        <td style="width: 15px;">
                                            <img src="images/spacer.gif" border="0" alt="" height="1" width="15" />
                                        </td>
                                        <td style="width: 50px;">
                                            <img src="images/spacer.gif" border="0" alt="" height="1" width="50" />
                                        </td>
                                        <td>
                                            <novalibra:NLValidationSummary ID="V_Summary" ShowSummary="true" ShowMessageBox="false"
                                                CssClass="validationDisplay" EnableClientScript="false" EnableViewState="true"
                                                runat="server" />
                                        </td>
                                        <td style="width: 100%;" align="right" valign="bottom">
                                            <asp:Label ID="validFlagDisplay" runat="server" Text=""></asp:Label>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <th valign="top" colspan="3">
                                IMPORT ITEM ADDITION &amp; CHANGES
                                <asp:Label ID="batch" runat="server" Text=""></asp:Label>
                                <asp:Label ID="batchVendorName" runat="server" Text="">
                                </asp:Label><asp:Label ID="stageName" runat="server" Text=""></asp:Label>
                                <asp:Label ID="lastUpdated" runat="server" Text=""></asp:Label>
                            </th>
                        </tr>
                        <tr>
                            <td align="left" colspan="3" class="subHeading bodyText" style="padding: 5px;">
                                <table cellpadding="0" cellspacing="0" border="0" width="100%">
                                    <tr>
                                        <td valign="middle" align="left" style="height: 15px">
                                            <asp:HyperLink ID="linkExcel" runat="server" NavigateUrl="#">Export to Excel</asp:HyperLink>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="3">
                                <table cellpadding="0" cellspacing="0" border="0">
                                    <tr>
                                        <td colspan="2">
                                            &nbsp;
                                        </td>
                                        <td style="width: 100px;">
                                            &nbsp;
                                        </td>
                                        <td>
                                            &nbsp;
                                        </td>
                                        <td style="width: 20px;">
                                            &nbsp;
                                        </td>
                                        <td runat="server" id="VendorOrAgentFL" style="text-align: right; width: 80px; white-space: nowrap;">
                                            Vendor / Merch Burden:
                                        </td>
                                        <td>
                                            <novalibra:NLDropDownList ID="VendorOrAgent" runat="server" AutoPostBack="true" RenderReadOnly="true">
                                            </novalibra:NLDropDownList>
                                        </td>
                                        <td>
                                            <novalibra:NLTextBox ID="AgentType" runat="server" RenderReadOnly="true"></novalibra:NLTextBox>
                                        </td>
                                        <td colspan="2">&nbsp;</td>
                                        <td style="width: 15px;">&nbsp;</td>
                                        <td>&nbsp;</td>
                                    </tr>
                                    <tr>
                                        <td runat="server" id="SKUGroupFL" style="text-align: right; white-space: nowrap;">SKU Group:</td>
                                        <td>
                                            <novalibra:NLDropDownList ID="SKUGroup" runat="server" RenderReadOnly="true">
                                            </novalibra:NLDropDownList>
                                        </td>
                                        <td colspan="10"></td>
                                    </tr>
                                    <tr>
                                        <td runat="server" id="DeptFL" style="text-align: right;">Dept:</td>
                                        <td>
                                            <novalibra:NLTextBox ID="Dept" runat="server" Width="100" MaxLength="3" RenderReadOnly="true"></novalibra:NLTextBox>
                                        </td>
                                        <td colspan="10">&nbsp;</td>
                                    </tr>
                                    <tr>
                                        <td runat="server" id="ClassFL" style="text-align: right;">Class:</td>
                                        <td colspan="4">
                                            <novalibra:NLTextBox ID="Class" runat="server" Width="100" MaxLength="3" RenderReadOnly="true"></novalibra:NLTextBox>
                                        </td>
                                        <td colspan="7" style="white-space: nowrap;">&nbsp;</td>
                                    </tr>
                                    <tr>
                                        <td runat="server" id="SubClassFL" style="text-align: right; white-space: nowrap;">Sub-Class (Line):</td>
                                        <td>
                                            <novalibra:NLTextBox ID="SubClass" runat="server" Width="100" MaxLength="4" RenderReadOnly="true"></novalibra:NLTextBox>
                                        </td>
                                        <td runat="server" id="SeasonFL" style="text-align: right; white-space: nowrap;">Season:</td>
                                        <td style="text-align: right; white-space: nowrap;">
                                            <novalibra:NLDropDownList ID="Season" runat="server" ChangeControl="true">
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
                                            <novalibra:NLTextBox ID="PrimaryUPC" runat="server" Width="100" MaxLength="14" RenderReadOnly="true"></novalibra:NLTextBox>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td runat="server" id="MichaelsSKUFL" style="text-align: right; white-space: nowrap;">SKU #:</td>
                                        <td colspan="4">
                                            <novalibra:NLTextBox ID="MichaelsSKU" runat="server" Width="100" MaxLength="10" RenderReadOnly="true"></novalibra:NLTextBox>
                                        </td>
                                        <td runat="server" id="AdditionalUPCFL" style="text-align: right; white-space: nowrap; padding-top: 3px;" valign="top">
                                            Additional UPCs:
                                        </td>
                                        <td colspan="6" runat="server" id="additionalUPCParent" class="formField" style="white-space: nowrap;">
                                            <asp:HiddenField ID="additionalUPCCount" runat="server" Value="1" />
                                            <asp:Label ID="additionalUPCs" runat="server"></asp:Label>&nbsp;
                                        </td>
                                    </tr>
                                    <tr>
                                        <td runat="server" id="QuoteReferenceNumberFL" style="text-align: right;">Quote Reference Number:</td>
                                        <td runat="server" id="QuoteReferenceNumberParent" colspan="3">
                                            <novalibra:NLTextBox ID="QuoteReferenceNumber" runat="server" Width="100" MaxLength="20"
                                                RenderReadOnly="true" ChangeControl="true"></novalibra:NLTextBox>
                                        </td>
                                        <td runat="server" id="PlanogramNameFL" colspan="2" style="text-align: right; white-space: nowrap;">Planogram Name:</td>
                                        <td colspan="6">
                                            <novalibra:NLTextBox ID="PlanogramName" runat="server" Width="412" MaxLength="50" ChangeControl="true"></novalibra:NLTextBox>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td runat="server" id="VendorNumberFL" style="text-align: right;">Vendor Number:</td>
                                        <td runat="server" id="VendorNumberParent" colspan="3">
                                            <novalibra:NLTextBox ID="VendorNumber" runat="server" Width="100" MaxLength="8" RenderReadOnly="true"></novalibra:NLTextBox>
                                        </td>
                                        <td runat="server" id="ItemDescFL" colspan="2" style="text-align: right; white-space: nowrap;">Description 30 Characters:</td>
                                        <td colspan="6"><novalibra:NLTextBox ID="ItemDesc" runat="server" Width="412" MaxLength="30" ChangeControl="true"></novalibra:NLTextBox></td>
                                    </tr>
                                    <tr>
                                        <td runat="server" id="PrimaryVendorFL" style="text-align: right;">Vendor Rank:</td>
                                        <td colspan="3">
                                            <novalibra:NLDropDownList ID="PrimaryVendor" runat="server" RenderReadOnly="true">
                                                <asp:ListItem Value="PRIMARY" Text="PRIMARY"></asp:ListItem>
                                                <asp:ListItem Value="SECONDARY" Text="SECONDARY"></asp:ListItem>
                                            </novalibra:NLDropDownList>
                                        </td>
                                        <td colspan="2" runat="server" id="PrivateBrandLabelFL" style="text-align: right; white-space: nowrap;">Private Brand Label:</td>
                                        <td colspan="6" id="PrivateBrandLabelParent" runat="server">
                                            <novalibra:NLDropDownList ID="PrivateBrandLabel" runat="server" autopostback="true" ChangeControl="true">
                                            </novalibra:NLDropDownList>
                                            <asp:HiddenField ID="hdnPBLApplyAll" runat="Server" />
                                            <!-- PMO200141 GTIN14 Enhancements changes modified autopostback="true" -->
                                        </td>
                                    </tr>

                                    <!-- PMO200141 GTIN14 Enhancements changes Start-->
									<tr style="display:none;">
							            <td colspan="1" runat="server" id="InnerGTINFL" style="text-align: right; white-space: nowrap;">Inner Pack GTIN14:</td>
							            <td colspan="2" runat="server" id="InnerGTINParent" >
							                <novalibra:NLTextBox ID="InnerGTIN" runat="server" Width="100"  MaxLength="14" ChangeControl="true"></novalibra:NLTextBox></td>
							            <td colspan="3" runat="server" id="CaseGTINFL" style="text-align: right; white-space: nowrap;">Case Pack GTIN14:</td>
							            <td colspan="4" runat="server" id="CaseGTINParent" >
							                <novalibra:NLTextBox ID="CaseGTIN" runat="server" Width="100"  MaxLength ="14" ChangeControl="true"></novalibra:NLTextBox>							                            
							              </td>
									</tr>
									<!-- PMO200141 GTIN14 Enhancements changes End -->
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="3">&nbsp;</td>
                        </tr>
                        <tr>
                            <th colspan="3">&nbsp;</th>
                        </tr>
                        <tr>
                            <td colspan="3">&nbsp;</td>
                        </tr>
                        <tr valign="top">
                            <td style="padding-left: 10px;">
                                <table cellpadding="0" cellspacing="0" border="0">
                                    <tr valign="top">
                                        <td>
                                            <table cellpadding="0" cellspacing="0" border="0">
                                                <tr>
                                                    <td colspan="3">
                                                        <table cellpadding="0" cellspacing="0" border="0">
                                                            <tr>
                                                                <td runat="server" id="VendorNameFL" style="text-align: right; white-space: nowrap;">
                                                                    Vendor Name:
                                                                </td>
                                                                <td runat="server" id="VendorNameParent" colspan="2">
                                                                    <novalibra:NLTextBox ID="VendorName" runat="server" Width="225" MaxLength="100" RenderReadOnly="true"></novalibra:NLTextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td runat="server" id="VendorAddress1FL" style="text-align: right; white-space: nowrap;">
                                                                    Address Line 1:
                                                                </td>
                                                                <td colspan="2">
                                                                    <novalibra:NLTextBox ID="VendorAddress1" runat="server" Width="225" MaxLength="100"
                                                                        ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td runat="server" id="VendorAddress2FL" style="text-align: right; white-space: nowrap;">
                                                                    Address Line 2:
                                                                </td>
                                                                <td colspan="2">
                                                                    <novalibra:NLTextBox ID="VendorAddress2" runat="server" Width="225" MaxLength="100"
                                                                        ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td runat="server" id="VendorAddress3FL" style="text-align: right; white-space: nowrap;">
                                                                    Address Line 3:
                                                                </td>
                                                                <td colspan="2">
                                                                    <novalibra:NLTextBox ID="VendorAddress3" runat="server" Width="225" MaxLength="100"
                                                                        ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td runat="server" id="VendorAddress4FL" style="text-align: right; white-space: nowrap;">
                                                                    Address Line 4:
                                                                </td>
                                                                <td colspan="2">
                                                                    <novalibra:NLTextBox ID="VendorAddress4" runat="server" Width="225" MaxLength="100"
                                                                        ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td runat="server" id="VendorContactNameFL"  style="text-align: right;
                                                                    white-space: nowrap;">
                                                                    Contact Name:
                                                                </td>
                                                                <td colspan="2">
                                                                    <novalibra:NLTextBox ID="VendorContactName" runat="server" Width="225" MaxLength="100"
                                                                        ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td runat="server" id="VendorContactPhoneFL" style="text-align: right;
                                                                    white-space: nowrap;">
                                                                    Phone:
                                                                </td>
                                                                <td colspan="2">
                                                                    <novalibra:NLTextBox ID="VendorContactPhone" runat="server" Width="225" MaxLength="100"
                                                                        ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td runat="server" id="VendorContactEmailFL" style="text-align: right;
                                                                    white-space: nowrap;">
                                                                    Email:
                                                                </td>
                                                                <td colspan="2">
                                                                    <novalibra:NLTextBox ID="VendorContactEmail" runat="server" Width="225" MaxLength="100"
                                                                        ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td runat="server" id="VendorContactFaxFL" style="text-align: right;
                                                                    white-space: nowrap;">
                                                                    Fax:
                                                                </td>
                                                                <td colspan="2">
                                                                    <novalibra:NLTextBox ID="VendorContactFax" runat="server" Width="225" MaxLength="100"
                                                                        ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                            </tr>
                                                            <tr runat="server" id="trM1" visible="true">
                                                                <td runat="server" id="ManufactureNameFL" style="text-align: right; white-space: nowrap;">
                                                                    Manufacture Name:
                                                                </td>
                                                                <td colspan="2">
                                                                    <novalibra:NLTextBox ID="ManufactureName" runat="server" Width="225" MaxLength="100"
                                                                        ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                            </tr>
                                                            <tr runat="server" id="trM2" visible="true">
                                                                <td runat="server" id="ManufactureAddress1FL" style="text-align: right;
                                                                    white-space: nowrap;">
                                                                    MFT Address 1:
                                                                </td>
                                                                <td colspan="2">
                                                                    <novalibra:NLTextBox ID="ManufactureAddress1" runat="server" Width="225" MaxLength="100"
                                                                        ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                            </tr>
                                                            <tr runat="server" id="trM3" visible="true">
                                                                <td runat="server" id="ManufactureAddress2FL" style="text-align: right;
                                                                    white-space: nowrap;">
                                                                    MFT Address 2:
                                                                </td>
                                                                <td colspan="2">
                                                                    <novalibra:NLTextBox ID="ManufactureAddress2" runat="server" Width="225" MaxLength="100"
                                                                        ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td runat="server" id="ManufactureContactFL" style="text-align: right;
                                                                    white-space: nowrap;">
                                                                    <asp:Label ID="L_Contact" runat="server"></asp:Label>
                                                                </td>
                                                                <td colspan="2">
                                                                    <novalibra:NLTextBox ID="ManufactureContact" runat="server" Width="225" MaxLength="100"
                                                                        ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td runat="server" id="ManufacturePhoneFL" style="text-align: right;
                                                                    white-space: nowrap;">
                                                                    Phone:
                                                                </td>
                                                                <td colspan="2">
                                                                    <novalibra:NLTextBox ID="ManufacturePhone" runat="server" Width="225" MaxLength="100"
                                                                        ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td runat="server" id="ManufactureEmailFL" style="text-align: right;
                                                                    white-space: nowrap;">
                                                                    Email:
                                                                </td>
                                                                <td colspan="2">
                                                                    <novalibra:NLTextBox ID="ManufactureEmail" runat="server" Width="225" MaxLength="100"
                                                                        ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td runat="server" id="ManufactureFaxFL" style="text-align: right; white-space: nowrap;">
                                                                    Fax:
                                                                </td>
                                                                <td colspan="2">
                                                                    <novalibra:NLTextBox ID="ManufactureFax" runat="server" Width="225" MaxLength="100"
                                                                        ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                            </tr>
                                                            <tr runat="server" visible="true" id="trA1">
                                                                <td runat="server" id="AgentContactFL" style="text-align: right; white-space: nowrap;">
                                                                    Agent Contact:
                                                                </td>
                                                                <td colspan="2">
                                                                    <novalibra:NLTextBox ID="AgentContact" runat="server" Width="225" MaxLength="100"
                                                                        ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                            </tr>
                                                            <tr runat="server" visible="true" id="trA2">
                                                                <td runat="server" id="AgentPhoneFL" style="text-align: right; white-space: nowrap;">
                                                                    Phone:
                                                                </td>
                                                                <td colspan="2">
                                                                    <novalibra:NLTextBox ID="AgentPhone" runat="server" Width="225" MaxLength="100" ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                            </tr>
                                                            <tr runat="server" visible="true" id="trA3">
                                                                <td runat="server" id="AgentEmailFL" style="text-align: right; white-space: nowrap;">
                                                                    Email:
                                                                </td>
                                                                <td colspan="2">
                                                                    <novalibra:NLTextBox ID="AgentEmail" runat="server" Width="225" MaxLength="100" ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                            </tr>
                                                            <tr runat="server" visible="true" id="trA4">
                                                                <td runat="server" id="AgentFaxFL" style="text-align: right; white-space: nowrap;">
                                                                    Fax:
                                                                </td>
                                                                <td colspan="2">
                                                                    <novalibra:NLTextBox ID="AgentFax" runat="server" Width="225" MaxLength="100" ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td colspan="3">&nbsp;</td>
                                                            </tr>
                                                            <tr>
                                                                <td runat="server" id="VendorStyleNumFL" style="text-align: right; white-space: nowrap;">
                                                                    Vendor Style#:
                                                                </td>
                                                                <td colspan="2">
                                                                    <novalibra:NLTextBox ID="VendorStyleNum" runat="server" Width="225" MaxLength="20"
                                                                        ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td colspan="3">
                                                                    &nbsp;
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td runat="server" id="HarmonizedCodeNumberFL" style="text-align: right;
                                                                    white-space: nowrap;">
                                                                    Harmonized Code No.:
                                                                </td>
                                                                <td colspan="2">
                                                                    <novalibra:NLTextBox ID="HarmonizedCodeNumber" runat="server" Width="225" MaxLength="100"
                                                                        ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td runat="server" id="CanadaHarmonizedCodeNumberFL" style="text-align: right;
                                                                    white-space: nowrap;">
                                                                    Canada Harmonized Code No.:
                                                                </td>
                                                                <td colspan="2">
                                                                    <novalibra:NLTextBox ID="CanadaHarmonizedCodeNumber" runat="server" Width="225" MaxLength="100"
                                                                        ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td colspan="4">
                                                                    &nbsp;
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td runat="server" id="DetailInvoiceCustomsDescFL"  rowspan="6" style="vertical-align: text-top;
                                                                    text-align: right; white-space: nowrap;">
                                                                    Detail Invoice / Customs Description:
                                                                </td>
                                                                <td colspan="2">
                                                                    <novalibra:NLTextBox ID="DetailInvoiceCustomsDesc0" runat="server" Width="225" MaxLength="150"
                                                                        ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td colspan="3">
                                                                    <novalibra:NLTextBox ID="DetailInvoiceCustomsDesc1" runat="server" Width="225" MaxLength="150"
                                                                        ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td colspan="3">
                                                                    <novalibra:NLTextBox ID="DetailInvoiceCustomsDesc2" runat="server" Width="225" MaxLength="150"
                                                                        ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td colspan="3">
                                                                    <novalibra:NLTextBox ID="DetailInvoiceCustomsDesc3" runat="server" Width="225" MaxLength="150"
                                                                        ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td colspan="3">
                                                                    <novalibra:NLTextBox ID="DetailInvoiceCustomsDesc4" runat="server" Width="225" MaxLength="150"
                                                                        ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td colspan="3">
                                                                    <novalibra:NLTextBox ID="DetailInvoiceCustomsDesc5" runat="server" Width="225" MaxLength="150"
                                                                        ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td runat="server" id="ComponentMaterialBreakdownFL" rowspan="5" style="text-align: right;
                                                                    vertical-align: text-top; white-space: nowrap;">
                                                                    Component / Material Breakdown By %:
                                                                </td>
                                                                <td colspan="2">
                                                                    <novalibra:NLTextBox ID="ComponentMaterialBreakdown0" runat="server" Width="225"
                                                                        MaxLength="150" ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td colspan="3">
                                                                    <novalibra:NLTextBox ID="ComponentMaterialBreakdown1" runat="server" Width="225"
                                                                        MaxLength="150" ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td colspan="3">
                                                                    <novalibra:NLTextBox ID="ComponentMaterialBreakdown2" runat="server" Width="225"
                                                                        MaxLength="150" ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td colspan="3">
                                                                    <novalibra:NLTextBox ID="ComponentMaterialBreakdown3" runat="server" Width="225"
                                                                        MaxLength="150" ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td colspan="3">
                                                                    <novalibra:NLTextBox ID="ComponentMaterialBreakdown4" runat="server" Width="225"
                                                                        MaxLength="150" ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td runat="server" id="ComponentConstructionMethodFL" rowspan="4" style="text-align: right;
                                                                    vertical-align: text-top; white-space: nowrap;">
                                                                    Component Construction Method:
                                                                </td>
                                                                <td colspan="2">
                                                                    <novalibra:NLTextBox ID="ComponentConstructionMethod0" runat="server" Width="225"
                                                                        MaxLength="150" ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td colspan="3">
                                                                    <novalibra:NLTextBox ID="ComponentConstructionMethod1" runat="server" Width="225"
                                                                        MaxLength="150" ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td colspan="3">
                                                                    <novalibra:NLTextBox ID="ComponentConstructionMethod2" runat="server" Width="225"
                                                                        MaxLength="150" ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td colspan="3">
                                                                    <novalibra:NLTextBox ID="ComponentConstructionMethod3" runat="server" Width="225"
                                                                        MaxLength="150" ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td runat="server" id="IndividualItemPackagingFL" style="text-align: right;
                                                                    white-space: nowrap;">
                                                                    Individual Item Packaging:
                                                                </td>
                                                                <td colspan="2">
                                                                    <novalibra:NLTextBox ID="IndividualItemPackaging" runat="server" Width="225" MaxLength="100"
                                                                        ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                            </tr>
                                                            <tr id="QtyInPackRow" runat="server">
                                                                <td runat="server" id="QtyInPackFL" style="text-align: right; white-space: nowrap;">
                                                                    Component Qty Ea:
                                                                </td>
                                                                <td colspan="2">
                                                                    <novalibra:NLTextBox ID="QtyInPack" runat="server" Width="225" MaxLength="5" ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td runat="server" id="EachesMasterCaseFL" style="text-align: right;
                                                                    white-space: nowrap;">
                                                                    # Eaches Inside Master Case Box:
                                                                </td>
                                                                <td colspan="2">
                                                                    <novalibra:NLTextBox ID="EachesMasterCase" runat="server" Width="225" MaxLength="9"
                                                                        ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td runat="server" id="EachesInnerPackFL" style="text-align: right; white-space: nowrap;">
                                                                    # Eaches Inside Inner Pack:
                                                                </td>
                                                                <td colspan="2">
                                                                    <novalibra:NLTextBox ID="EachesInnerPack" runat="server" Width="225" MaxLength="9"
                                                                        ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                            </tr>
                                                    
                                              
                                                        </table>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td colspan="3">&nbsp;</td>
                                                </tr>
                                                <tr>
                                                    <td colspan="3">
                                                        <table cellpadding="0" cellspacing="0" border="0" width="100%">
                                                            <tr>
                                                                <td colspan="3" style="white-space: nowrap;">
                                                                    Each Dimensions (shown in inches below):
                                                                </td>
                                                            </tr>
                                                            <tr runat="server" id="EachCaseFLParent">
                                                                <td style="text-align: center;">
                                                                    Length = (down)
                                                                </td>
                                                                <td style="text-align: center;">
                                                                    Width = (down)
                                                                </td>
                                                                <td style="text-align: center;">
                                                                    Height = (down)
                                                                </td>
                                                            </tr>
                                                            <tr runat="server" id="EachCaseParent">
                                                                <td>
                                                                    <novalibra:NLTextBox ID="EachCaseLength" runat="server" Width="100" MaxLength="9"
                                                                        ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                                <td>
                                                                    <novalibra:NLTextBox ID="EachCaseWidth" runat="server" Width="100" MaxLength="9"
                                                                        ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                                <td>
                                                                    <novalibra:NLTextBox ID="EachCaseHeight" runat="server" Width="100" MaxLength="9"
                                                                        ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td runat="server" id="EachCaseCubeFL" colspan="2">
                                                                    Cubic Feet Per Each Carton:
                                                                </td>
                                                                <td runat="server" id="EachCaseCubeParent">
                                                                    <novalibra:NLTextBox ID="EachCaseCubeEdit" runat="server" Width="100" MaxLength="14"
                                                                        ReadOnly="true" ChangeControl="true" RevertEnabled="false" CssClass="calculatedField"></novalibra:NLTextBox>*
                                                                    <asp:HiddenField ID="EachCaseCube" runat="server" />
                                                                    <asp:Label ID="EachCaseCubeLabel" runat="server" Text=""></asp:Label>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td runat="server" id="EachCaseWeightFL"    colspan="2">
                                                                    Weight of Each (lbs):
                                                                </td>
                                                                <td colspan="2">
                                                                    <novalibra:NLTextBox ID="EachCaseWeight" runat="server" Width="100" MaxLength="9"
                                                                        ChangeControl="true"></novalibra:NLTextBox>
                                                                    
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td colspan="3">&nbsp;<div style="width: 0; overflow: hidden;"><asp:TextBox ID="txtFocusFix" runat="server"></asp:TextBox></div></td>
                                                            </tr>
                                                            <tr>
                                                                <td colspan="3" style="white-space: nowrap;">
                                                                    Reshippable Inner Carton Dimensions (shown in inches below):
                                                                </td>
                                                            </tr>
                                                            <tr runat="server" id="InnerCaseFLParent">
                                                                <td style="text-align: center;">
                                                                    Length = (down)
                                                                </td>
                                                                <td style="text-align: center;">
                                                                    Width = (down)
                                                                </td>
                                                                <td style="text-align: center;">
                                                                    Height = (down)
                                                                </td>
                                                            </tr>
                                                            <tr runat="server" id="InnerCaseParent">
                                                                <td>
                                                                    <novalibra:NLTextBox ID="InnerCaseLength" runat="server" Width="100" MaxLength="9"
                                                                        ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                                <td>
                                                                    <novalibra:NLTextBox ID="InnerCaseWidth" runat="server" Width="100" MaxLength="9"
                                                                        ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                                <td>
                                                                    <novalibra:NLTextBox ID="InnerCaseHeight" runat="server" Width="100" MaxLength="9"
                                                                        ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td runat="server" id="InnerCaseCubeFL" colspan="2">
                                                                    Cubic Feet Per Inner Carton:
                                                                </td>
                                                                <td runat="server" id="InnerCaseCubeParent">
                                                                    <novalibra:NLTextBox ID="InnerCaseCubeEdit" runat="server" Width="100" MaxLength="14"
                                                                        ReadOnly="true" ChangeControl="true" RevertEnabled="false" CssClass="calculatedField"></novalibra:NLTextBox>*
                                                                    <asp:HiddenField ID="InnerCaseCube" runat="server" />
                                                                    <asp:Label ID="innerCaseCubeLabel" runat="server" Text=""></asp:Label>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td runat="server" id="InnerCaseWeightFL"  colspan="2">
                                                                    Weight of Inner Carton (lbs):
                                                                </td>
                                                                <td colspan="2">
                                                                    <novalibra:NLTextBox ID="InnerCaseWeight" runat="server" Width="100" MaxLength="9"
                                                                        ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td colspan="3">&nbsp;</td>
                                                            </tr>
                                                            <tr>
                                                                <td colspan="3" style="white-space: nowrap;">
                                                                    Master Carton Dimensions (shown in inches below):
                                                                </td>
                                                            </tr>
                                                            <tr runat="server" id="MasterCaseFLParent">
                                                                <td style="text-align: center;">
                                                                    Length = (down)
                                                                </td>
                                                                <td style="text-align: center;">
                                                                    Width = (down)
                                                                </td>
                                                                <td style="text-align: center;">
                                                                    Height = (down)
                                                                </td>
                                                            </tr>
                                                            <tr runat="server" id="MasterCaseParent">
                                                                <td>
                                                                    <novalibra:NLTextBox ID="MasterCaseLength" runat="server" Width="100" MaxLength="9"
                                                                        ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                                <td>
                                                                    <novalibra:NLTextBox ID="MasterCaseWidth" runat="server" Width="100" MaxLength="9"
                                                                        ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                                <td>
                                                                    <novalibra:NLTextBox ID="MasterCaseHeight" runat="server" Width="100" MaxLength="9"
                                                                        ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td runat="server" id="MasterCaseCubeFL" colspan="2">
                                                                    Cubic Feet Per Master Carton:
                                                                </td>
                                                                <td runat="server" id="MasterCaseCubeParent">
                                                                    <novalibra:NLTextBox ID="MasterCaseCubeEdit" runat="server" Width="100" MaxLength="14"
                                                                        ReadOnly="true" ChangeControl="true" RevertEnabled="false" CssClass="calculatedField"></novalibra:NLTextBox>*
                                                                    <asp:HiddenField ID="MasterCaseCube" runat="server" />
                                                                    <asp:Label ID="MasterCaseCubeLabel" runat="server" Text=""></asp:Label>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td runat="server" id="MasterCaseWeightFL" colspan="2">
                                                                    Weight of Master Carton (lbs):
                                                                </td>
                                                                <td>
                                                                    <novalibra:NLTextBox ID="MasterCaseWeight" runat="server" Width="100" MaxLength="14"
                                                                        ChangeControl="true"></novalibra:NLTextBox>
                                                                </td>
                                                            </tr>

                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr><td>&nbsp;</td></tr>
							        <tr><th>Purchase Order</th></tr >
							        <tr><td>&nbsp;</td></tr>
                                    <tr>
                                        <td>
                                            <table cellpadding="0" cellspacing="0" border="0">
                                                <tr>
                                                    <td colspan="3">
                                                        &nbsp;
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="MinimumOrderQuantityFL" style="text-align: right;">
                                                        Minimum Order Quantity:
                                                    </td>
                                                    <td colspan="2">
                                                        <novalibra:NLTextBox ID="MinimumOrderQuantity" runat="server" Width="250" MaxLength="9"
                                                            ChangeControl="true"></novalibra:NLTextBox>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="VendorMinOrderAmountFL" style="text-align: right;">
                                                        Minimum Order Amount:
                                                    </td>
                                                    <td colspan="2">
                                                        <novalibra:NLTextBox ID="VendorMinOrderAmount" runat="server" Width="250" MaxLength="20"
                                                            ChangeControl="true"></novalibra:NLTextBox>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="ProductIdentifiesAsCosmeticFL" style="text-align: right;">
                                                        Product Identifies as a Cosmetic:
                                                    </td>
                                                    <td colspan="2">
		                                                <novalibra:NLDropDownList ID="ProductIdentifiesAsCosmetic" runat="server" ChangeControl="true">
			                                                <asp:ListItem Value="" Text=""></asp:ListItem>
			                                                <asp:ListItem Value="Y" Text="Yes"></asp:ListItem>
			                                                <asp:ListItem Value="N" Text="No"></asp:ListItem>
		                                                </novalibra:NLDropDownList>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="ShippingPointFL" style="text-align: right;">
                                                        Shipping Point:
                                                    </td>
                                                    <td colspan="2">
                                                        <novalibra:NLTextBox ID="ShippingPoint" runat="server" Width="250" MaxLength="100"
                                                            ChangeControl="true"></novalibra:NLTextBox>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="CountryOfOriginFL" style="text-align: right;">
                                                        Primary Country Of Origin:
                                                    </td>
                                                    <td runat="server" id="CountryOfOriginParent" colspan="2">
                                                        <novalibra:NLTextBox ID="CountryOfOriginName" ChangeControl="true" runat="server"
                                                            Width="250" MaxLength="50" RenderReadOnly="true"></novalibra:NLTextBox>
                                                        <div id="CountryOfOriginName_choices" class="autocomplete">
                                                        </div>
                                                        <asp:HiddenField ID="CountryOfOrigin" runat="server" />
                                                    </td>
                                                </tr>
                                            </table>
                                            <asp:Table ID="additionalCOOTbl" runat="server" border="0" CellPadding="0" CellSpacing="0">
                                                <asp:TableRow>
                                                    <asp:TableCell runat="server" ID="additionalCOOFL" class="formLabel" Width="150px"
                                                        Style="padding-right: 2px;" valign="top">Additional COO's:</asp:TableCell>
                                                    <asp:TableCell ColumnSpan="2"><span id="CooMsg" class='redText'></span></asp:TableCell>
                                                </asp:TableRow>
                                            </asp:Table>
                                            <table cellpadding="0" cellspacing="0" border="0">
                                                <tr>
                                                    <td runat="server" id="VendorCommentsFL" style="text-align: right;" width="100px"
                                                        valign="top">
                                                        Comments:
                                                    </td>
                                                    <td colspan="2">
                                                        <novalibra:NLTextBox ID="VendorComments" runat="server" Rows="8" Width="325" TextMode="MultiLine"
                                                            ChangeControl="true"></novalibra:NLTextBox>
                                                    </td>
                                                </tr>
                                            </table>
                                            <table cellpadding="0" cellspacing="0" border="0" width="100%">
                                                <tr>
                                                    <td colspan="3">
                                                        &nbsp;
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <th colspan="3">
                                                        Language Settings
                                                    </th>
                                                </tr>
                                                <tr>
                                                    <td colspan="3">
                                                        &nbsp;
                                                    </td>
                                                </tr>
                                                <tr>
                                                     <td colspan="3">
                                                        <table cellpadding="0" cellspacing="0" border="0">
                                                            <tr>
                                                                <td runat="server" id="PLI" style="text-align: right; white-space: nowrap;">Package Language Indicators</td>
                                                                <td>&nbsp;</td>
                                                                <td>&nbsp;</td>
                                                            </tr>
                                                            <tr>
                                                                <td runat="server" id="PLIEnglishFL" style="text-align: right; white-space: nowrap;">English:</td>
                                                                <td>
                                                                    <novalibra:NLDropDownList ID="PLIEnglish" runat="server" ChangeControl="true" >
                                                                        <asp:ListItem Text="" Value="" />
                                                                        <asp:ListItem Text="No" Value="N" />
                                                                        <asp:ListItem Text="Yes" Value="Y" />
                                                                    </novalibra:NLDropDownList>
                                                                </td>
                                                                <td>&nbsp;</td>
                                                            </tr>
                                                            <tr>
                                                                <td runat="server" id="PLIFrenchFL" style="text-align: right; white-space: nowrap;">Canadian French:</td>
                                                                <td>
                                                                    <novalibra:NLDropDownList ID="PLIFrench" runat="server" ChangeControl="true" >
                                                                        <asp:ListItem Text="" Value="" />
                                                                        <asp:ListItem Text="No" Value="N" />
                                                                        <asp:ListItem Text="Yes" Value="Y" />
                                                                    </novalibra:NLDropDownList>
                                                                </td>
                                                                <td>
                                                                    <table cellpadding="0" cellspacing="0" border="0">
                                                                        <tr>
                                                                            <td runat="server" id="ExemptEndDateFrenchFL" style="text-align: right; white-space: nowrap;">Exempt End Date:</td>
                                                                            <td><novalibra:NLTextBox ID="ExemptEndDateFrench" runat="server" RenderReadOnly="true" ReadOnly="true" ChangeControl="true" MaxLength="10" /></td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td runat="server" id="PLISpanishFL" style="text-align: right; white-space: nowrap;">Latin American Spanish:</td>
                                                                <td>
                                                                    <novalibra:NLDropDownList ID="PLISpanish" runat="server" ChangeControl="true">
                                                                        <asp:ListItem Text="" Value="" />
                                                                        <asp:ListItem Text="No" Value="N" />
                                                                        <asp:ListItem Text="Yes" Value="Y" />
                                                                    </novalibra:NLDropDownList>
                                                                </td>
                                                                <td>&nbsp;</td>
                                                            </tr>
                                                            <tr>
                                                                <td>&nbsp;</td>
                                                                <td>&nbsp;</td>
                                                                <td>&nbsp;</td>
                                                            </tr>
                                                            <tr>
                                                                <td runat="server" id="CustomsDescriptionFL" style="text-align: right; white-space: nowrap;">Customs Description:</td>
                                                                <td colspan="2">
                                                                    <novalibra:NLTextBox ID="CustomsDescription" runat="server" ChangeControl="true" Width="300" MaxLength="255" />
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>&nbsp;</td>
                                                                <td>&nbsp;</td>
                                                                <td>&nbsp;</td>
                                                            </tr>
                                                            <tr>
                                                                <td runat="server" id="TIs" style="text-align: right; white-space: nowrap;">Translation Indicators:</td>
                                                                <td>&nbsp;</td>
                                                                <td>&nbsp;</td>
                                                            </tr>
                                                            <tr>
                                                                <td runat="server" id="TIEnglishFL" style="text-align: right; white-space: nowrap;">English:</td>
                                                                <td colspan="2">
                                                                    <novalibra:NLDropDownList ID="TIEnglish" runat="server" ChangeControl="true">
                                                                        <asp:ListItem Text="" Value="" />
                                                                        <asp:ListItem Text="No" Value="N" />
                                                                        <asp:ListItem Text="Yes" Value="Y" />
                                                                    </novalibra:NLDropDownList>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td runat="server" id="TIFrenchFL" style="text-align: right; white-space: nowrap;">Canadian French:</td>
                                                                <td colspan="2">
                                                                    <novalibra:NLDropDownList ID="TIFrench" runat="server" ChangeControl="true">
                                                                        <asp:ListItem Text="" Value="" />
                                                                        <asp:ListItem Text="No" Value="N" />
                                                                        <asp:ListItem Text="Yes" Value="Y" />
                                                                    </novalibra:NLDropDownList>
                                                                </td>
                                                                <td>&nbsp;</td>
                                                            </tr>
                                                            <tr>
                                                                <td runat="server" id="TISpanishFL" style="text-align: right; white-space: nowrap;">Latin American Spanish:</td>
                                                                <td colspan="2">
                                                                    <novalibra:NLDropDownList ID="TISpanish" runat="server" ChangeControl="false" Enabled="false">
                                                                        <asp:ListItem Text="" Value="" />
                                                                        <asp:ListItem Text="No" Value="N" Selected="True" />
                                                                        <asp:ListItem Text="Yes" Value="Y" />
                                                                    </novalibra:NLDropDownList>
                                                                </td>
                                                                <td>&nbsp;</td>
                                                            </tr>
                                                        </table>
                                                     </td>
                                                </tr>
                                                <tr>
                                                    <td colspan="3">
                                                        &nbsp;
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="CFDs" style="text-align: left; white-space: nowrap;">Consumer Friendly Descriptions:</td>
                                                    <td>&nbsp;</td>
                                                    <td>&nbsp;</td>
                                                </tr>
                                                <tr>
                                                    <td colspan="3">
                                                        <div id="EnglishDescriptions">
                                                            <table cellpadding="0" cellspacing="0" border="0">
                                                                <tr>
                                                                    <td runat="server" id="EnglishShortDescriptionFL" style="padding-left: 60px; text-align: right;
                                                                        white-space: nowrap;" >
                                                                        English &nbsp;<br />
                                                                        Short Description: &nbsp;
                                                                    </td>
                                                                    <td>
                                                                        <novalibra:NLTextBox ID="EnglishShortDescription" runat="server" Width="300" MaxLength="17" ChangeControl="true"/>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td runat="server" id="EnglishLongDescriptionFL" style="text-align: right; white-space: nowrap;">
                                                                        English &nbsp;<br />
                                                                        Long Description: &nbsp;<br />
                                                                        (max 100 chars.) &nbsp;
                                                                    </td>
                                                                    <td>
                                                                        <novalibra:NLTextBox ID="EnglishLongDescription" runat="server" Width="300" MaxLength="100" ChangeControl="true" TextMode="MultiLine" Height="80" />
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                            <br />
                                                        </div>
                                                        <div id="FrenchDescriptions">
                                                            <table cellpadding="0" cellspacing="0" border="0">
                                                                <tr>
                                                                    <td runat="server" id="FrenchShortDescriptionFL" style="padding-left: 60px; text-align: right;
                                                                        white-space: nowrap;">
                                                                        Canadian French &nbsp;<br />
                                                                        Short Description: &nbsp;
                                                                    </td>
                                                                    <td>
                                                                        <novalibra:NLTextBox ID="FrenchShortDescription" runat="server" Width="300" MaxLength="17" />
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td runat="server" id="FrenchLongDescriptionFL" style="text-align: right; white-space: nowrap;">
                                                                        Canadian French &nbsp;<br />
                                                                        Long Description: &nbsp;<br />
                                                                        (max 150 chars.) &nbsp;
                                                                    </td>
                                                                    <td>
                                                                        <novalibra:NLTextBox ID="FrenchLongDescription" runat="server" Width="300" MaxLength="150"
                                                                            TextMode="MultiLine" Height="80" />
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                            <br />
                                                        </div>
                                                        <div id="Spanish_Descriptions">
                                                            <table cellpadding="0" cellspacing="0" border="0">
                                                                <tr>
                                                                    <td runat="server" id="SpanishShortDescriptionFL" style="padding-left: 33px; text-align: right;
                                                                        white-space: nowrap;">
                                                                        Latin American Spanish &nbsp;<br />
                                                                        Short Description: &nbsp;
                                                                    </td>
                                                                    <td>
                                                                        <novalibra:NLTextBox ID="SpanishShortDescription" runat="server" Width="300" MaxLength="17" />
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td runat="server" id="SpanishLongDescriptionFL" style="text-align: right; white-space: nowrap;">
                                                                        Latin American Spanish &nbsp;<br />
                                                                        Long Description: &nbsp;<br />
                                                                        (max 150 chars.) &nbsp;
                                                                    </td>
                                                                    <td>
                                                                        <novalibra:NLTextBox ID="SpanishLongDescription" runat="server" Width="300" MaxLength="150"
                                                                            TextMode="MultiLine" Height="80" />
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                            <td style="width: 1px; border-right: solid 1px #000000;">
                                &nbsp;
                            </td>
                            <td valign="top" style="padding-left: 5px;">
                                <table cellpadding="0" cellspacing="0" border="0">
                                    <tr>
                                        <td runat="server" id="StockCategoryFL" style="text-align: right; white-space: nowrap;
                                            width: 133px;">
                                            Stock Category:
                                        </td>
                                        <td>
                                            <novalibra:NLTextBox ID="StockCategory" runat="server" Width="40" RenderReadOnly="true"></novalibra:NLTextBox>
                                        </td>
                                        <td runat="server" id="FreightTermsFL" style="text-align: right; white-space: nowrap;">
                                            Freight Terms:
                                        </td>
                                        <td>
                                            <novalibra:NLTextBox ID="FreightTerms" runat="server" Width="60" RenderReadOnly="true"></novalibra:NLTextBox>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td runat="server" id="ItemTypeAttributeFL" style="text-align: right; white-space: nowrap;
                                            width: 133px;">
                                            Item Type Attribute:
                                        </td>
                                        <td>
                                            <novalibra:NLDropDownList ID="ItemTypeAttribute" runat="server" RenderReadOnly="true">
                                            </novalibra:NLDropDownList>
                                        </td>
                                        <td runat="server" id="PackItemIndicatorFL" style="text-align: right; white-space: nowrap;">
                                            Pack Item Indicator:
                                        </td>
                                        <td>
                                            <novalibra:NLDropDownList ID="PackItemIndicator" runat="server" RenderReadOnly="true">
                                            </novalibra:NLDropDownList>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td runat="server" id="InventoryControlFL" style="text-align: right; white-space: nowrap;
                                            width: 133px;">
                                            Inventory Control:
                                        </td>
                                        <td>
                                            <novalibra:NLDropDownList ID="InventoryControl" runat="server" ChangeControl="true">
                                            </novalibra:NLDropDownList>
                                        </td>
                                        <td style="text-align: right; white-space: nowrap;">
                                            Allow Store Order:
                                        </td>
                                        <td>
                                            <novalibra:NLDropDownList ID="AllowStoreOrder" runat="server" ChangeControl="true"></novalibra:NLDropDownList>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td runat="server" id="DiscountableFL" style="text-align: right; white-space: nowrap;
                                            width: 133px;">
                                            Discountable:
                                        </td>
                                        <td>
                                            <novalibra:NLDropDownList ID="Discountable" runat="server" ChangeControl="true">
                                            </novalibra:NLDropDownList>
                                        </td>
                                        <td runat="server" id="AutoReplenishFL" style="text-align: right; white-space: nowrap;">
                                            Auto Replenish:
                                        </td>
                                        <td>
                                            <novalibra:NLDropDownList ID="AutoReplenish" runat="server" ChangeControl="true"></novalibra:NLDropDownList>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td runat="server" id="PrePricedFL" style="text-align: right; white-space: nowrap;
                                            width: 133px;">
                                            Pre-Priced:
                                        </td>
                                        <td>
                                            <novalibra:NLDropDownList ID="PrePriced" runat="server" ChangeControl="true">
                                            </novalibra:NLDropDownList>
                                        </td>
                                        <td runat="server" id="TaxUDAFL" style="text-align: right; white-space: nowrap;">
                                            Tax UDA:
                                        </td>
                                        <td runat="server" id="TaxUDAParent">
                                            <novalibra:NLDropDownList ID="TaxUDA" runat="server" ChangeControl="true">
                                            </novalibra:NLDropDownList>
                                            <asp:Label ID="TaxUDALabel" runat="server"></asp:Label>
                                            <asp:HiddenField ID="TaxUDAValue" runat="server" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td runat="server" id="PrePricedUDAFL" style="text-align: right; white-space: nowrap;
                                            width: 133px;">
                                            Pre-Priced UDA:
                                        </td>
                                        <td>
                                            <novalibra:NLDropDownList ID="PrePricedUDA" runat="server" ChangeControl="true">
                                            </novalibra:NLDropDownList>
                                        </td>
                                        <td runat="server" id="TaxValueUDAFL" style="text-align: right; white-space: nowrap;">
                                            Tax Value UDA:
                                        </td>
                                        <td runat="server" id="TaxValueUDAParent">
                                            <novalibra:NLTextBox ID="TaxValueUDA" runat="server" Width="60" MaxLength="10" ChangeControl="true"></novalibra:NLTextBox>
                                            <asp:Label ID="TaxValueUDALabel" runat="server"></asp:Label>
                                            <asp:HiddenField ID="TaxValueUDAValue" runat="server" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td runat="server" id="StockingStrategyCodeFL" style="text-align: right; white-space: nowrap;">
                                            Stocking Strategy:
                                        </td>
                                        <td>
                                            <novalibra:NLDropDownList ID="StockingStrategyCode" runat="server" ChangeControl="true" RenderReadOnly="true">
                                            </novalibra:NLDropDownList>
                                            <input type="button" id="btnStockStratHelper" runat="server" visible="false" value="Helper" class="formButton" onclick="showStockStratHelper();" />&nbsp;&nbsp;
                                        </td>
<%--                                        <td runat="server" id="HybridTypeFL" style="text-align: right; white-space: nowrap;
                                            width: 133px;">
                                            Hybrid Type:
                                        </td>
                                        <td>
                                            <novalibra:NLDropDownList ID="HybridType" runat="server" RenderReadOnly="true">
                                            </novalibra:NLDropDownList>
                                        </td>
                                        <td runat="server" id="HybridSourceDCFL" style="text-align: right; white-space: nowrap;" visible="false">
                                            Sourcing DC:
                                        </td>
                                        <td>
                                            <novalibra:NLDropDownList ID="HybridSourceDC" runat="server" RenderReadOnly="true" Visible="false">
                                            </novalibra:NLDropDownList>
                                        </td>--%>
                                    </tr>
                                    <tr>
                                        <td runat="server" id="StoreSupplierZoneGroupFL" style="text-align: right; white-space: nowrap;
                                            width: 133px;">
                                            Store Supp Zone GRP:
                                        </td>
                                        <td>
                                            <novalibra:NLTextBox ID="StoreSupplierZoneGroup" runat="server" Width="40" RenderReadOnly="true"></novalibra:NLTextBox>
                                        </td>
                                        <td runat="server" id="WHSSupplierZoneGroupFL" style="text-align: right; white-space: nowrap;">
                                            WHSE Supp Zone GRP:
                                        </td>
                                        <td>
                                            <novalibra:NLTextBox ID="WHSSupplierZoneGroup" runat="server" Width="60" RenderReadOnly="true"></novalibra:NLTextBox>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="text-align: right; white-space: nowrap; width: 133px;">
                                        </td>
                                        <td>
                                        </td>
                                        <td style="text-align: right; white-space: nowrap;">
                                        </td>
                                        <td>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="4">&nbsp;</td>
                                    </tr>
                                    <tr>
                                        <th colspan="4">Cost Information</th>
                                    </tr>
                                    <tr>
                                        <td colspan="4">&nbsp;</td>
                                    </tr>
                                    <tr>
                                        <td colspan="3">
                                            Estimated Landed Cost (All Figures For Each)
                                        </td>
                                    </tr>
                                                <tr>
                                                    <td runat="server" id="DisplayerCostFL" colspan="2">
                                                        PDQ Packaging Cost Per Unit (US$)
                                                    </td>
                                                    <td>
                                                        <novalibra:NLTextBox ID="DisplayerCost" runat="server" Width="100" MaxLength="14"
                                                            ChangeControl="true"></novalibra:NLTextBox>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="ProductCostFL" colspan="2">
                                                        FOB First Cost (US$)
                                                    </td>
                                                    <td>
                                                        <novalibra:NLTextBox ID="ProductCost" runat="server" Width="100" MaxLength="14" ChangeControl="true"></novalibra:NLTextBox>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="FOBShippingPointFL" colspan="2">
                                                        Total FOB First Cost (US$)
                                                    </td>
                                                    <td runat="server" id="FOBShippingPointParent">
                                                        <novalibra:NLTextBox ID="FOBShippingPointEdit" runat="server" Width="100" MaxLength="14"
                                                            ReadOnly="true" ChangeControl="true" RevertEnabled="false" CssClass="calculatedField"></novalibra:NLTextBox>*
                                                        <asp:HiddenField ID="FOBShippingPoint" runat="server" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="DutyPercentFL" style="text-align: right;">
                                                        Duty:
                                                    </td>
                                                    <td runat="server" id="DutyPercentParent">
                                                        <novalibra:NLTextBox ID="DutyPercent" runat="server" Width="100" MaxLength="14" ChangeControl="true"></novalibra:NLTextBox>%
                                                    </td>
                                                    <td runat="server" id="DutyAmountParent">
                                                        <novalibra:NLTextBox ID="DutyAmountEdit" runat="server" Width="100" MaxLength="14"
                                                            ReadOnly="true" ChangeControl="true" RevertEnabled="false" CssClass="calculatedField"></novalibra:NLTextBox>*
                                                        <asp:HiddenField ID="DutyAmount" runat="server" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="AdditionalDutyFL" style="text-align: right;">
                                                        Additional Duty:
                                                    </td>
                                                    <td>
                                                        <novalibra:NLTextBox ID="AdditionalDutyComment" runat="server" Width="100" MaxLength="100"
                                                            ChangeControl="true"></novalibra:NLTextBox>
                                                    </td>
                                                    <td>
                                                        <novalibra:NLTextBox ID="AdditionalDutyAmount" runat="server" Width="100" ChangeControl="true"></novalibra:NLTextBox>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="SuppTariffPercentFL" style="text-align: right;">
                                                        Supplementary Tariff:
                                                    </td>
                                                    <td runat="server" id="SuppTariffPercentParent">
                                                        <novalibra:NLTextBox ID="SuppTariffPercent" runat="server" Width="100" MaxLength="14" ChangeControl="true"></novalibra:NLTextBox>%
                                                    </td>
                                                    <td runat="server" id="SuppTariffAmountParent">
                                                        <novalibra:NLTextBox ID="SuppTariffAmountEdit" runat="server" Width="100" MaxLength="14"
                                                            ReadOnly="true" ChangeControl="true" RevertEnabled="false" CssClass="calculatedField"></novalibra:NLTextBox>*
                                                        <asp:HiddenField ID="SuppTariffAmount" runat="server" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="OceanFreightAmountFL" style="text-align: right;">
                                                        Ocean Freight: (Per CU. FT.)
                                                    </td>
                                                    <td>
                                                        <novalibra:NLTextBox ID="OceanFreightAmount" runat="server" Width="100" MaxLength="14"
                                                            ChangeControl="true"></novalibra:NLTextBox>
                                                    </td>
                                                    <td runat="server" id="OceanFreightComputedAmountParent">
                                                        <novalibra:NLTextBox ID="OceanFreightComputedAmountEdit" runat="server" Width="100"
                                                            ReadOnly="true" ChangeControl="true" RevertEnabled="false" CssClass="calculatedField"></novalibra:NLTextBox>*
                                                        <asp:HiddenField ID="OceanFreightComputedAmount" runat="server" />
                                                    </td>
                                                </tr>
                                                <tr id="agentCommissionRow" runat="server">
                                                    <td runat="server" id="AgentCommissionAmountFL" style="text-align: right;">
                                                        Merch Burden:
                                                    </td>
                                                    <td>
                                                        <novalibra:NLTextBox ID="AgentCommissionPercent" runat="server" Width="100" ChangeControl="true"></novalibra:NLTextBox>%
                                                    </td>
                                                    <td runat="server" id="AgentCommissionAmountParent">
                                                        <novalibra:NLTextBox ID="AgentCommissionAmountEdit" runat="server" Width="100" ReadOnly="true"
                                                            ChangeControl="true" RevertEnabled="false" CssClass="calculatedField"></novalibra:NLTextBox>*
                                                        <asp:HiddenField ID="AgentCommissionAmount" runat="server" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="OtherImportCostsPercentFL" style="text-align: right;">
                                                        Other Import Costs:
                                                    </td>
                                                    <td runat="server" id="OtherImportCostsPercentParent">
                                                        <novalibra:NLTextBox ID="OtherImportCostsPercentEdit" runat="server" Width="100"
                                                            ReadOnly="true" ChangeControl="true" RevertEnabled="false" CssClass="calculatedField"></novalibra:NLTextBox>%
                                                        <asp:HiddenField ID="OtherImportCostsPercent" runat="server" />
                                                    </td>
                                                    <td runat="server" id="OtherImportCostsAmountParent">
                                                        <novalibra:NLTextBox ID="OtherImportCostsAmountEdit" runat="server" Width="100" ReadOnly="true"
                                                            ChangeControl="true" RevertEnabled="false" CssClass="calculatedField"></novalibra:NLTextBox>*
                                                        <asp:HiddenField ID="OtherImportCostsAmount" runat="server" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td style="text-align: right;">
                                                        &nbsp;<!--PDQ Packaging Cost:-->
                                                    </td>
                                                    <td>
                                                        &nbsp;
                                                    </td>
                                                    <td>
                                                        <!--<novalibra:NLTextBox ID="PackagingCostAmountEdit" runat="server" Width="100" ></novalibra:NLTextBox>-->
                                                        <asp:HiddenField ID="PackagingCostAmount" runat="server" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="ImportBurdenFL" style="text-align: right;">
                                                        Total Import Burden:
                                                    </td>
                                                    <td>
                                                        &nbsp;
                                                    </td>
                                                    <td runat="server" id="ImportBurdenParent">
                                                        <novalibra:NLTextBox ID="ImportBurdenEdit" runat="server" Width="100" ReadOnly="true"
                                                            ChangeControl="true" RevertEnabled="false" CssClass="calculatedField"></novalibra:NLTextBox>*
                                                        <asp:HiddenField ID="ImportBurden" runat="server" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="WarehouseLandedCostFL" style="text-align: right;">
                                                        Total Warehouse Landed Cost:
                                                    </td>
                                                    <td>
                                                        &nbsp;
                                                    </td>
                                                    <td runat="server" id="WarehouseLandedCostParent">
                                                        <novalibra:NLTextBox ID="WarehouseLandedCostEdit" runat="server" Width="100" ReadOnly="true"
                                                            ChangeControl="true" RevertEnabled="false" CssClass="calculatedField"></novalibra:NLTextBox>*
                                                        <asp:HiddenField ID="WarehouseLandedCost" runat="server" />
                                                    </td>
                                                </tr>
                                    
                                    <tr>
                                        <td colspan="4">
                                            &nbsp;
                                        </td>
                                    </tr>
                                    <tr>
                                        <th colspan="4">
                                            Store Selling Cost / Retail Dollars&nbsp;
                                        </th>
                                    </tr>
                                    <tr>
                                        <td colspan="4">
                                            &nbsp;
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="2" valign="top">
                                            <table border="0" cellpadding="1" cellspacing="0" width="100%">
                                                <tr>
                                                    <td colspan="2">
                                                        Calculate Store Selling Cost Each
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="FirstCostFL" colspan="1" style="text-align: right; white-space: nowrap;">
                                                        Total FOB First Cost (US$)
                                                    </td>
                                                    <td runat="server" id="FirstCostParent">
                                                        <novalibra:NLTextBox ID="FirstCostEdit" runat="server" Width="60" MaxLength="15"
                                                            ReadOnly="true" ChangeControl="true" RevertEnabled="false" CssClass="calculatedField"></novalibra:NLTextBox>*
                                                        <asp:HiddenField ID="FirstCost" runat="server" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="StoreTotalImportBurdenFL" colspan="1" style="text-align: right;
                                                        white-space: nowrap;">
                                                        + Total Import Burden
                                                    </td>
                                                    <td runat="server" id="StoreTotalImportBurdenParent">
                                                        <novalibra:NLTextBox ID="StoreTotalImportBurdenEdit" runat="server" Width="60" MaxLength="15"
                                                            ReadOnly="true" ChangeControl="true" RevertEnabled="false" CssClass="calculatedField"></novalibra:NLTextBox>*
                                                        <asp:HiddenField ID="StoreTotalImportBurden" runat="server" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="TotalWhseLandedCostFL" colspan="1" style="text-align: right;
                                                        white-space: nowrap;">
                                                        = Total WHSE. Landed Cost
                                                    </td>
                                                    <td runat="server" id="TotalWhseLandedCostParent">
                                                        <novalibra:NLTextBox ID="TotalWhseLandedCostEdit" runat="server" Width="60" MaxLength="15"
                                                            ReadOnly="true" ChangeControl="true" RevertEnabled="false" CssClass="calculatedField"></novalibra:NLTextBox>*
                                                        <asp:HiddenField ID="TotalWhseLandedCost" runat="server" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="OutboundFreightFL" colspan="1" style="text-align: right; white-space: nowrap;">
                                                        + Outbound Freight
                                                    </td>
                                                    <td runat="server" id="OutboundFreightParent">
                                                        <novalibra:NLTextBox ID="OutboundFreightEdit" runat="server" Width="60" MaxLength="15"
                                                            ReadOnly="true" ChangeControl="true" RevertEnabled="false" CssClass="calculatedField"></novalibra:NLTextBox>*
                                                        <asp:HiddenField ID="OutboundFreight" runat="server" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="NinePercentWhseChargeFL" colspan="1" style="text-align: right;
                                                        white-space: nowrap;">
                                                        + 9% WHSE. Charge
                                                    </td>
                                                    <td runat="server" id="NinePercentWhseChargeParent">
                                                        <novalibra:NLTextBox ID="NinePercentWhseChargeEdit" runat="server" Width="60" MaxLength="15"
                                                            ReadOnly="true" ChangeControl="true" RevertEnabled="false" CssClass="calculatedField"></novalibra:NLTextBox>*
                                                        <asp:HiddenField ID="NinePercentWhseCharge" runat="server" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="TotalStoreLandedCostFL" colspan="1" style="text-align: right;
                                                        white-space: nowrap;">
                                                        = Total Store Landed Cost
                                                    </td>
                                                    <td runat="server" id="TotalStoreLandedCostParent">
                                                        <novalibra:NLTextBox ID="TotalStoreLandedCostEdit" runat="server" Width="60" MaxLength="15"
                                                            ReadOnly="true" ChangeControl="true" RevertEnabled="false" CssClass="calculatedField"></novalibra:NLTextBox>*
                                                        <asp:HiddenField ID="TotalStoreLandedCost" runat="server" />
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                        <td colspan="2" valign="top">
                                            <table border="0" cellpadding="1" cellspacing="0" width="100%">
                                                <tr>
                                                    <td style="text-align: right; padding-right: 10px;">
                                                        Retail Dollars
                                                    </td>
                                                    <td colspan="3">
                                                        &nbsp;
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        &nbsp;
                                                    </td>
                                                    <td style="padding-left: 3px; padding-right: 6px;">
                                                        Retail
                                                    </td>
                                                    <td style="padding-left: 2px;">
                                                        Retail IMU%
                                                    </td>
                                                    <td style="padding-left: 2px;">
                                                        Clearance
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="Base1RetailFL" style="text-align: right; white-space: nowrap;">
                                                        Low Elas3 (29):
                                                    </td>
                                                    <td>
                                                        <novalibra:NLTextBox ID="Base1Retail" runat="server" Width="50" MaxLength="12" RenderReadOnly="true"></novalibra:NLTextBox>
                                                    </td>
                                                    <td style="padding-left: 5px;">
                                                        <span runat="server" id="Base1RetailGM"></span>&nbsp;
                                                    </td>
                                                    <td>
                                                        <novalibra:NLTextBox ID="Base1Clearance" runat="server" Width="50" MaxLength="12"
                                                            RenderReadOnly="true"></novalibra:NLTextBox>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="Base2RetailFL" style="text-align: right; white-space: nowrap;">
                                                        High Elas3 (28):
                                                    </td>
                                                    <td runat="server" id="Base2RetailParent">
                                                        <novalibra:NLTextBox ID="Base2RetailEdit" runat="server" Width="50" MaxLength="9"
                                                            RenderReadOnly="true"></novalibra:NLTextBox>
                                                        <asp:HiddenField ID="Base2Retail" runat="server" />
                                                    </td>
                                                    <td style="padding-left: 5px;">
                                                        <span runat="server" id="Base2RetailGM"></span>&nbsp;
                                                    </td>
                                                    <td runat="server" id="Base2ClearanceParent">
                                                        <novalibra:NLTextBox ID="Base2ClearanceEdit" runat="server" Width="50" MaxLength="9"
                                                            RenderReadOnly="true"></novalibra:NLTextBox>
                                                        <asp:HiddenField ID="Base2Clearance" runat="server" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="TestRetailFL" style="text-align: right; white-space: nowrap;">
                                                        Do Not Use (3):
                                                    </td>
                                                    <td runat="server" id="TestRetailParent">
                                                        <novalibra:NLTextBox ID="TestRetailEdit" runat="server" Width="50" MaxLength="9"
                                                            RenderReadOnly="true"></novalibra:NLTextBox>
                                                        <asp:HiddenField ID="TestRetail" runat="server" />
                                                    </td>
                                                    <td style="padding-left: 5px;">
                                                        <span runat="server" id="TestRetailGM"></span>&nbsp;
                                                    </td>
                                                    <td runat="server" id="TestClearanceParent">
                                                        <novalibra:NLTextBox ID="TestClearanceEdit" runat="server" Width="50" MaxLength="9"
                                                            RenderReadOnly="true"></novalibra:NLTextBox>
                                                        <asp:HiddenField ID="TestClearance" runat="server" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="AlaskaRetailFL" style="text-align: right; white-space: nowrap;">
                                                        High Cost (27):
                                                    </td>
                                                    <td>
                                                        <novalibra:NLTextBox ID="AlaskaRetail" runat="server" Width="50" MaxLength="9" RenderReadOnly="true">></novalibra:NLTextBox>
                                                    </td>
                                                    <td style="padding-left: 5px;">
                                                        <span runat="server" id="AlaskaRetailGM"></span>&nbsp;
                                                    </td>
                                                    <td>
                                                        <novalibra:NLTextBox ID="AlaskaClearance" runat="server" Width="50" MaxLength="9"
                                                            RenderReadOnly="true">></novalibra:NLTextBox>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="CanadaRetailFL" style="text-align: right; white-space: nowrap;">
                                                        Canada (5):
                                                    </td>
                                                    <td>
                                                        <novalibra:NLTextBox ID="CanadaRetail" runat="server" Width="50" MaxLength="9" RenderReadOnly="true"></novalibra:NLTextBox>
                                                    </td>
                                                    <td style="padding-left: 5px;">
                                                        <span runat="server" id="CanadaRetailGM"></span>&nbsp;
                                                    </td>
                                                    <td>
                                                        <novalibra:NLTextBox ID="CanadaClearance" runat="server" Width="50" MaxLength="9"
                                                            RenderReadOnly="true"></novalibra:NLTextBox>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="High2RetailFL" style="text-align: right; white-space: nowrap;">
                                                        Canada2 (16):
                                                    </td>
                                                    <td runat="server" id="High2RetailParent">
                                                        <novalibra:NLTextBox ID="High2RetailEdit" runat="server" Width="50" MaxLength="9"
                                                            RenderReadOnly="true"></novalibra:NLTextBox>
                                                        <asp:HiddenField ID="High2Retail" runat="server" />
                                                    </td>
                                                    <td style="padding-left: 5px;">
                                                        <span runat="server" id="High2RetailGM"></span>&nbsp;
                                                    </td>
                                                    <td runat="server" id="High2ClearanceParentFL">
                                                        <novalibra:NLTextBox ID="High2ClearanceEdit" runat="server" Width="50" MaxLength="9"
                                                            RenderReadOnly="true"></novalibra:NLTextBox>
                                                        <asp:HiddenField ID="High2Clearance" runat="server" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="High3RetailFL" style="text-align: right; white-space: nowrap;">
                                                        Canada E-Comm (17):
                                                    </td>
                                                    <td runat="server" id="High3RetailParent">
                                                        <novalibra:NLTextBox ID="High3RetailEdit" runat="server" Width="50" MaxLength="9"
                                                            RenderReadOnly="true"></novalibra:NLTextBox>
                                                        <asp:HiddenField ID="High3Retail" runat="server" />
                                                    </td>
                                                    <td style="padding-left: 5px;">
                                                        <span runat="server" id="High3RetailGM"></span>&nbsp;
                                                    </td>
                                                    <td runat="server" id="High3ClearanceParent">
                                                        <novalibra:NLTextBox ID="High3ClearanceEdit" runat="server" Width="50" MaxLength="9"
                                                            RenderReadOnly="true"></novalibra:NLTextBox>
                                                        <asp:HiddenField ID="High3Clearance" runat="server" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="SmallMarketRetailFL" style="text-align: right; white-space: nowrap;">
                                                        Do Not Use (8):
                                                    </td>
                                                    <td runat="server" id="SmallMarketRetailParent">
                                                        <novalibra:NLTextBox ID="SmallMarketRetailEdit" runat="server" Width="50" MaxLength="9"
                                                            RenderReadOnly="true"></novalibra:NLTextBox>
                                                        <asp:HiddenField ID="SmallMarketRetail" runat="server" />
                                                    </td>
                                                    <td style="padding-left: 5px;">
                                                        <span runat="server" id="SmallMarketRetailGM"></span>&nbsp;
                                                    </td>
                                                    <td runat="server" id="SmallMarketClearanceParent">
                                                        <novalibra:NLTextBox ID="SmallMarketClearanceEdit" runat="server" Width="50" MaxLength="9"
                                                            RenderReadOnly="true"></novalibra:NLTextBox>
                                                        <asp:HiddenField ID="SmallMarketClearance" runat="server" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="High1RetailFL" style="text-align: right; white-space: nowrap;">
                                                        Do Not Use (9):
                                                    </td>
                                                    <td runat="server" id="High1RetailParent">
                                                        <novalibra:NLTextBox ID="High1RetailEdit" runat="server" Width="50" MaxLength="9"
                                                            RenderReadOnly="true"></novalibra:NLTextBox>
                                                        <asp:HiddenField ID="High1Retail" runat="server" />
                                                    </td>
                                                    <td style="padding-left: 5px;">
                                                        <span runat="server" id="High1RetailGM"></span>&nbsp;
                                                    </td>
                                                    <td runat="server" id="High1ClearanceParent">
                                                        <novalibra:NLTextBox ID="High1ClearanceEdit" runat="server" Width="50" MaxLength="9"
                                                            RenderReadOnly="true"></novalibra:NLTextBox>
                                                        <asp:HiddenField ID="High1Clearance" runat="server" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="Base3RetailFL" style="text-align: right; white-space: nowrap;">
                                                        Do Not Use (10):
                                                    </td>
                                                    <td runat="server" id="Base3RetailParent">
                                                        <novalibra:NLTextBox ID="Base3RetailEdit" runat="server" Width="50" MaxLength="9"
                                                            RenderReadOnly="true"></novalibra:NLTextBox>
                                                        <asp:HiddenField ID="Base3Retail" runat="server" />
                                                    </td>
                                                    <td style="padding-left: 5px;">
                                                        <span runat="server" id="Base3RetailGM"></span>&nbsp;
                                                    </td>
                                                    <td runat="server" id="Base3ClearanceParent">
                                                        <novalibra:NLTextBox ID="Base3ClearanceEdit" runat="server" Width="50" MaxLength="9"
                                                            RenderReadOnly="true"></novalibra:NLTextBox>
                                                        <asp:HiddenField ID="Base3Clearance" runat="server" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="Low1RetailFL" style="text-align: right; white-space: nowrap;">
                                                        Do Not Use (11):
                                                    </td>
                                                    <td runat="server" id="Low1RetailParent">
                                                        <novalibra:NLTextBox ID="Low1RetailEdit" runat="server" Width="50" MaxLength="9"
                                                            RenderReadOnly="true"></novalibra:NLTextBox>
                                                        <asp:HiddenField ID="Low1Retail" runat="server" />
                                                    </td>
                                                    <td style="padding-left: 5px;">
                                                        <span runat="server" id="Low1RetailGM"></span>&nbsp;
                                                    </td>
                                                    <td runat="server" id="Low1ClearanceParent">
                                                        <novalibra:NLTextBox ID="Low1ClearanceEdit" runat="server" Width="50" MaxLength="9"
                                                            RenderReadOnly="true"></novalibra:NLTextBox>
                                                        <asp:HiddenField ID="Low1Clearance" runat="server" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="Low2RetailFL" style="text-align: right; white-space: nowrap;">
                                                        Do Not Use (12):
                                                    </td>
                                                    <td runat="server" id="Low2RetailParent">
                                                        <novalibra:NLTextBox ID="Low2RetailEdit" runat="server" Width="50" MaxLength="9"
                                                            RenderReadOnly="true"></novalibra:NLTextBox>
                                                        <asp:HiddenField ID="Low2Retail" runat="server" />
                                                    </td>
                                                    <td style="padding-left: 5px;">
                                                        <span runat="server" id="Low2RetailGM"></span>&nbsp;
                                                    </td>
                                                    <td runat="server" id="Low2ClearanceParent">
                                                        <novalibra:NLTextBox ID="Low2ClearanceEdit" runat="server" Width="50" MaxLength="9"
                                                            RenderReadOnly="true"></novalibra:NLTextBox>
                                                        <asp:HiddenField ID="Low2Clearance" runat="server" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="ManhattanRetailFL" style="text-align: right; white-space: nowrap;">
                                                        E-Comm (21):
                                                    </td>
                                                    <td runat="server" id="ManhattanRetailParent">
                                                        <novalibra:NLTextBox ID="ManhattanRetailEdit" runat="server" Width="50" MaxLength="9"
                                                            RenderReadOnly="true"></novalibra:NLTextBox>
                                                        <asp:HiddenField ID="ManhattanRetail" runat="server" />
                                                    </td>
                                                    <td style="padding-left: 5px;">
                                                        <span runat="server" id="ManhattanRetailGM"></span>&nbsp;
                                                    </td>
                                                    <td runat="server" id="ManhattanClearanceParent">
                                                        <novalibra:NLTextBox ID="ManhattanClearanceEdit" runat="server" Width="50" MaxLength="9"
                                                            RenderReadOnly="true"></novalibra:NLTextBox>
                                                        <asp:HiddenField ID="ManhattanClearance" runat="server" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="QuebecRetailFL" style="text-align: right; white-space: nowrap;">
                                                        Quebec (14):
                                                    </td>
                                                    <td runat="server" id="QuebecRetailParent">
                                                        <novalibra:NLTextBox ID="QuebecRetailEdit" runat="server" Width="50" MaxLength="9"
                                                            RenderReadOnly="true"></novalibra:NLTextBox>
                                                        <asp:HiddenField ID="QuebecRetail" runat="server" />
                                                    </td>
                                                    <td style="padding-left: 5px;">
                                                        <span runat="server" id="QuebecRetailGM"></span>&nbsp;
                                                    </td>
                                                    <td runat="server" id="QuebecClearanceParent">
                                                        <novalibra:NLTextBox ID="QuebecClearanceEdit" runat="server" Width="50" MaxLength="9"
                                                            RenderReadOnly="true"></novalibra:NLTextBox>
                                                        <asp:HiddenField ID="QuebecClearance" runat="server" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="PuertoRicoFL" style="text-align: right; white-space: nowrap;">
                                                        Comp (30):
                                                    </td>
                                                    <td runat="server" id="PuertoRicoRetailParent">
                                                        <novalibra:NLTextBox ID="PuertoRicoRetailEdit" runat="server" Width="50" MaxLength="9"
                                                            RenderReadOnly="true"></novalibra:NLTextBox>
                                                        <asp:HiddenField ID="PuertoRicoRetail" runat="server" />
                                                    </td>
                                                    <td style="padding-left: 5px;">
                                                        <span runat="server" id="PuertoRicoRetailGM"></span>&nbsp;
                                                    </td>
                                                    <td runat="server" id="PuertoRicoParent">
                                                        <novalibra:NLTextBox ID="PuertoRicoClearanceEdit" runat="server" Width="50" MaxLength="9"
                                                            RenderReadOnly="true"></novalibra:NLTextBox>
                                                        <asp:HiddenField ID="PuertoRicoClearance" runat="server" />
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <!--<tr><td colspan="4"><hr /></td></tr>-->
                                    <tr>
                                        <td colspan="4">
                                            &nbsp;
                                        </td>
                                    </tr>
                                    <tr>
                                        <th colspan="4">
                                            Hazardous Materials
                                        </th>
                                    </tr>
                                    <tr>
                                        <td colspan="4">
                                            &nbsp;
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="4">
                                            <table cellpadding="0" cellspacing="0" border="0">
                                                <tr>
                                                    <td colspan="2">
                                                    </td>
                                                </tr>
                                                <tr runat="server" id="HazardousParent">
                                                    <td width="10%" style="text-align: right; white-space: nowrap;">
                                                        Hazardous:&nbsp;
                                                    </td>
                                                    <td width="90%" align="left">
                                                        <novalibra:NLDropDownList ID="Hazardous" runat="server" Width="50" AutoPostBack="true"
                                                            ChangeControl="true">
                                                        </novalibra:NLDropDownList>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td colspan="2">
                                                        <asp:Panel ID="P_HazMat" runat="server" Visible="false">
                                                            <table cellpadding="0" cellspacing="0" border="0">
                                                                <tr>
                                                                    <td runat="server" id="HazardousManufacturerNameFL" style="text-align: right; white-space: nowrap;">
                                                                        MFG's Name:
                                                                    </td>
                                                                    <td>
                                                                        <novalibra:NLTextBox ID="HazardousManufacturerName" runat="server" Width="100" MaxLength="100"
                                                                            ChangeControl="true"></novalibra:NLTextBox>
                                                                    </td>
                                                                    <td style="width: 100px;">
                                                                        &nbsp;
                                                                    </td>
                                                                    <td runat="server" id="HazardousManufacturerCountryFL" style="text-align: right;
                                                                        white-space: nowrap;">
                                                                        MFG's Country:
                                                                    </td>
                                                                    <td>
                                                                        <novalibra:NLTextBox ID="HazardousManufacturerCountry" runat="server" Width="100"
                                                                            MaxLength="100" ChangeControl="true"></novalibra:NLTextBox>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td runat="server" id="HazardousManufacturerCityFL" style="text-align: right; white-space: nowrap;">
                                                                        MFG's City:
                                                                    </td>
                                                                    <td>
                                                                        <novalibra:NLTextBox ID="HazardousManufacturerCity" runat="server" Width="100" MaxLength="100"
                                                                            ChangeControl="true"></novalibra:NLTextBox>
                                                                    </td>
                                                                    <td>
                                                                        &nbsp;
                                                                    </td>
                                                                    <td runat="server" id="HazardousFlammableFL" style="text-align: right; white-space: nowrap;">
                                                                        Flammable:
                                                                    </td>
                                                                    <td>
                                                                        <novalibra:NLDropDownList ID="HazardousFlammable" runat="server" ChangeControl="true">
                                                                        </novalibra:NLDropDownList>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td runat="server" id="HazardousManufacturerStateFL" style="text-align: right; white-space: nowrap;">
                                                                        MFG's State:
                                                                    </td>
                                                                    <td>
                                                                        <novalibra:NLTextBox ID="HazardousManufacturerState" runat="server" Width="100" MaxLength="100"
                                                                            ChangeControl="true"></novalibra:NLTextBox>
                                                                    </td>
                                                                    <td>
                                                                        &nbsp;
                                                                    </td>
                                                                    <td runat="server" id="HazardousContainerTypeFL" style="text-align: right; white-space: nowrap;">
                                                                        Container Type:
                                                                    </td>
                                                                    <td>
                                                                        <novalibra:NLDropDownList ID="HazardousContainerType" runat="server" ChangeControl="true">
                                                                        </novalibra:NLDropDownList>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td runat="server" id="HazardousManufacturerPhoneFL" style="text-align: right; white-space: nowrap;">
                                                                        MFG's Phone:
                                                                    </td>
                                                                    <td>
                                                                        <novalibra:NLTextBox ID="HazardousManufacturerPhone" runat="server" Width="100" MaxLength="100"
                                                                            ChangeControl="true"></novalibra:NLTextBox>
                                                                    </td>
                                                                    <td>
                                                                        &nbsp;
                                                                    </td>
                                                                    <td runat="server" id="HazardousContainerSizeFL" style="text-align: right; white-space: nowrap;">
                                                                        Container Size:
                                                                    </td>
                                                                    <td>
                                                                        <novalibra:NLTextBox ID="HazardousContainerSize" runat="server" Width="100" MaxLength="100"
                                                                            ChangeControl="true"></novalibra:NLTextBox>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td colspan="3">
                                                                        &nbsp;
                                                                    </td>
                                                                    <td runat="server" id="HazardousMSDSUOMFL" style="text-align: right; white-space: nowrap;">
                                                                        MSDS UOM:
                                                                    </td>
                                                                    <td>
                                                                        <novalibra:NLDropDownList ID="HazardousMSDSUOM" runat="server" ChangeControl="true">
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
                                    <tr>
                                        <td colspan="4">
                                            &nbsp;
                                        </td>
                                    </tr>
                                    <tr>
                                        <th colspan="4">
                                            Note: Vendor Must Check Below Yes Or No For Each Row
                                        </th>
                                    </tr>
                                    <tr>
                                        <td colspan="4">
                                            &nbsp;
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="4">
                                            <table cellpadding="0" cellspacing="0" border="0">
                                                <tr>
                                                    <td colspan="3" style="text-align: center;">
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td style="text-align: center;min-width:360px;">
                                                        Special Documents Required
                                                    </td>
                                                    <td style="width: 20px;">
                                                        &nbsp;
                                                    </td>
                                                    <td style="text-align: center;">
                                                        YES / NO
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="CoinBatteryFL">
                                                        REESE'S LAW (Product Contains Button Cell/Coin Battery)
                                                    </td>
                                                    <td style="width: 20px;">
                                                        &nbsp;
                                                    </td>
                                                    <td style="text-align: center;">
                                                        <novalibra:NLDropDownList ID="CoinBattery" runat="server" ChangeControl="true">
                                                            <asp:ListItem Value="" Text=""></asp:ListItem>
                                                            <asp:ListItem Value="Y" Text="Yes"></asp:ListItem>
                                                            <asp:ListItem Value="N" Text="No"></asp:ListItem>
                                                        </novalibra:NLDropDownList>
                                                    </td>
                                                </tr>
                                                <tr style="display:none;">
                                                    <td runat="server" id="TSSAFL">
                                                        TSSA - STUFFED ARTICLES ACT CURRENT REGISTRATION (Canada)
                                                    </td>
                                                    <td style="width: 20px;">
                                                        &nbsp;
                                                    </td>
                                                    <td style="text-align: center;">
                                                        <novalibra:NLDropDownList ID="TSSA" runat="server" ChangeControl="true">
                                                            <asp:ListItem Value="" Text=""></asp:ListItem>
                                                            <asp:ListItem Value="Y" Text="Yes"></asp:ListItem>
                                                            <asp:ListItem Value="N" Text="No"></asp:ListItem>
                                                        </novalibra:NLDropDownList>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="CSAFL">
                                                        ELECTRICAL APPLIANCE STANDARDS - CSA, UL, INTERTEK (Canada)
                                                    </td>
                                                    <td style="width: 20px;">
                                                        &nbsp;
                                                    </td>
                                                    <td style="text-align: center;">
                                                        <novalibra:NLDropDownList ID="CSA" runat="server" ChangeControl="true">
                                                            <asp:ListItem Value="" Text=""></asp:ListItem>
                                                            <asp:ListItem Value="Y" Text="Yes"></asp:ListItem>
                                                            <asp:ListItem Value="N" Text="No"></asp:ListItem>
                                                        </novalibra:NLDropDownList>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="ULFL">
                                                        ELECTRICAL APPLIANCE STANDARDS - CSA, UL, INTERTEK (US)
                                                    </td>
                                                    <td style="width: 20px;">
                                                        &nbsp;
                                                    </td>
                                                    <td style="text-align: center;">
                                                        <novalibra:NLDropDownList ID="UL" runat="server" ChangeControl="true">
                                                            <asp:ListItem Value="" Text=""></asp:ListItem>
                                                            <asp:ListItem Value="Y" Text="Yes"></asp:ListItem>
                                                            <asp:ListItem Value="N" Text="No"></asp:ListItem>
                                                        </novalibra:NLDropDownList>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="LicenceAgreementFL">
                                                        LICENSING AGREEMENT
                                                    </td>
                                                    <td style="width: 20px;">
                                                        &nbsp;
                                                    </td>
                                                    <td style="text-align: center;">
                                                        <novalibra:NLDropDownList ID="LicenceAgreement" runat="server" ChangeControl="true">
                                                            <asp:ListItem Value="" Text=""></asp:ListItem>
                                                            <asp:ListItem Value="Y" Text="Yes"></asp:ListItem>
                                                            <asp:ListItem Value="N" Text="No"></asp:ListItem>
                                                        </novalibra:NLDropDownList>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="FumigationCertificateFL">
                                                        PHYTOSANITARY CERTIFICATE
                                                    </td>
                                                    <td style="width: 20px;">
                                                        &nbsp;
                                                    </td>
                                                    <td style="text-align: center;">
                                                        <novalibra:NLDropDownList ID="FumigationCertificate" runat="server" ChangeControl="true">
                                                            <asp:ListItem Value="" Text=""></asp:ListItem>
                                                            <asp:ListItem Value="Y" Text="Yes"></asp:ListItem>
                                                            <asp:ListItem Value="N" Text="No"></asp:ListItem>
                                                        </novalibra:NLDropDownList>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="KILNDriedCertificateFL">
                                                        KILN DRIED CERTIFICATE
                                                    </td>
                                                    <td style="width: 20px;">
                                                        &nbsp;
                                                    </td>
                                                    <td style="text-align: center;">
                                                        <novalibra:NLDropDownList ID="KILNDriedCertificate" runat="server" ChangeControl="true">
                                                            <asp:ListItem Value="" Text=""></asp:ListItem>
                                                            <asp:ListItem Value="Y" Text="Yes"></asp:ListItem>
                                                            <asp:ListItem Value="N" Text="No"></asp:ListItem>
                                                        </novalibra:NLDropDownList>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="ChinaComInspecNumAndCCIBStickersFL">
                                                        CHINA COMMODITY INSPECTION BUREAUS # AND CCIB STICKERS
                                                    </td>
                                                    <td style="width: 20px;">
                                                        &nbsp;
                                                    </td>
                                                    <td style="text-align: center;">
                                                        <novalibra:NLDropDownList ID="ChinaComInspecNumAndCCIBStickers" runat="server" ChangeControl="true">
                                                            <asp:ListItem Value="" Text=""></asp:ListItem>
                                                            <asp:ListItem Value="Y" Text="Yes"></asp:ListItem>
                                                            <asp:ListItem Value="N" Text="No"></asp:ListItem>
                                                        </novalibra:NLDropDownList>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="OriginalVisaFL">
                                                        ORIGINAL VISA
                                                    </td>
                                                    <td style="width: 20px;">
                                                        &nbsp;
                                                    </td>
                                                    <td style="text-align: center;">
                                                        <novalibra:NLDropDownList ID="OriginalVisa" runat="server" ChangeControl="true">
                                                            <asp:ListItem Value="" Text=""></asp:ListItem>
                                                            <asp:ListItem Value="Y" Text="Yes"></asp:ListItem>
                                                            <asp:ListItem Value="N" Text="No"></asp:ListItem>
                                                        </novalibra:NLDropDownList>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="TextileDeclarationMidCodeFL">
                                                        TEXTILE DECLARATION - MID CODE
                                                    </td>
                                                    <td style="width: 20px;">
                                                        &nbsp;
                                                    </td>
                                                    <td style="text-align: center;">
                                                        <novalibra:NLDropDownList ID="TextileDeclarationMidCode" runat="server" ChangeControl="true">
                                                            <asp:ListItem Value="" Text=""></asp:ListItem>
                                                            <asp:ListItem Value="Y" Text="Yes"></asp:ListItem>
                                                            <asp:ListItem Value="N" Text="No"></asp:ListItem>
                                                        </novalibra:NLDropDownList>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="QuotaChargeStatementFL">
                                                        QUOTA CHARGE STATEMENT
                                                    </td>
                                                    <td style="width: 20px;">
                                                        &nbsp;
                                                    </td>
                                                    <td style="text-align: center;">
                                                        <novalibra:NLDropDownList ID="QuotaChargeStatement" runat="server" ChangeControl="true">
                                                            <asp:ListItem Value="" Text=""></asp:ListItem>
                                                            <asp:ListItem Value="Y" Text="Yes"></asp:ListItem>
                                                            <asp:ListItem Value="N" Text="No"></asp:ListItem>
                                                        </novalibra:NLDropDownList>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="MSDSFL">
                                                        SDS - SAFETY DATA SHEET (formerly MSDS)
                                                    </td>
                                                    <td style="width: 20px;">
                                                        &nbsp;
                                                    </td>
                                                    <td style="text-align: center;">
                                                        <novalibra:NLDropDownList ID="MSDS" runat="server" ChangeControl="true">
                                                            <asp:ListItem Value="" Text=""></asp:ListItem>
                                                            <asp:ListItem Value="Y" Text="Yes"></asp:ListItem>
                                                            <asp:ListItem Value="N" Text="No"></asp:ListItem>
                                                        </novalibra:NLDropDownList>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="TSCAFL">
                                                        TSCA STATEMENT - TECHNICAL STANDARDS
                                                    </td>
                                                    <td style="width: 20px;">
                                                        &nbsp;
                                                    </td>
                                                    <td style="text-align: center;">
                                                        <novalibra:NLDropDownList ID="TSCA" runat="server" ChangeControl="true">
                                                            <asp:ListItem Value="" Text=""></asp:ListItem>
                                                            <asp:ListItem Value="Y" Text="Yes"></asp:ListItem>
                                                            <asp:ListItem Value="N" Text="No"></asp:ListItem>
                                                        </novalibra:NLDropDownList>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="DropBallTestCertFL">
                                                        DROP BALL TEST CERTIFICATION - SAFETY AUTHORITY
                                                    </td>
                                                    <td style="width: 20px;">
                                                        &nbsp;
                                                    </td>
                                                    <td style="text-align: center;">
                                                        <novalibra:NLDropDownList ID="DropBallTestCert" runat="server" ChangeControl="true">
                                                            <asp:ListItem Value="" Text=""></asp:ListItem>
                                                            <asp:ListItem Value="Y" Text="Yes"></asp:ListItem>
                                                            <asp:ListItem Value="N" Text="No"></asp:ListItem>
                                                        </novalibra:NLDropDownList>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="ManMedicalDeviceListingFL">
                                                        MANUFACTURERS MEDICAL DEVICE LISTING #
                                                    </td>
                                                    <td style="width: 20px;">
                                                        &nbsp;
                                                    </td>
                                                    <td style="text-align: center;">
                                                        <novalibra:NLDropDownList ID="ManMedicalDeviceListing" runat="server" ChangeControl="true">
                                                            <asp:ListItem Value="" Text=""></asp:ListItem>
                                                            <asp:ListItem Value="Y" Text="Yes"></asp:ListItem>
                                                            <asp:ListItem Value="N" Text="No"></asp:ListItem>
                                                        </novalibra:NLDropDownList>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="ManFDARegistrationFL">
                                                        MANUFACTURER'S FDA REGISTRATION
                                                    </td>
                                                    <td style="width: 20px;">
                                                        &nbsp;
                                                    </td>
                                                    <td style="text-align: center;">
                                                        <novalibra:NLDropDownList ID="ManFDARegistration" runat="server" ChangeControl="true">
                                                            <asp:ListItem Value="" Text=""></asp:ListItem>
                                                            <asp:ListItem Value="Y" Text="Yes"></asp:ListItem>
                                                            <asp:ListItem Value="N" Text="No"></asp:ListItem>
                                                        </novalibra:NLDropDownList>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="CopyRightIndemnificationFL">
                                                        COPYRIGHT INDEMNIFICATION
                                                    </td>
                                                    <td style="width: 20px;">
                                                        &nbsp;
                                                    </td>
                                                    <td style="text-align: center;">
                                                        <novalibra:NLDropDownList ID="CopyRightIndemnification" runat="server" ChangeControl="true">
                                                            <asp:ListItem Value="" Text=""></asp:ListItem>
                                                            <asp:ListItem Value="Y" Text="Yes"></asp:ListItem>
                                                            <asp:ListItem Value="N" Text="No"></asp:ListItem>
                                                        </novalibra:NLDropDownList>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="FishWildLifeCertFL">
                                                        FISH & WILDLIFE CERTIFICATE
                                                    </td>
                                                    <td style="width: 20px;">
                                                        &nbsp;
                                                    </td>
                                                    <td style="text-align: center;">
                                                        <novalibra:NLDropDownList ID="FishWildLifeCert" runat="server" ChangeControl="true">
                                                            <asp:ListItem Value="" Text=""></asp:ListItem>
                                                            <asp:ListItem Value="Y" Text="Yes"></asp:ListItem>
                                                            <asp:ListItem Value="N" Text="No"></asp:ListItem>
                                                        </novalibra:NLDropDownList>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="Proposition65LabelReqFL">
                                                        PROPOSITION 65 LABELING REQUIREMENTS (California)
                                                    </td>
                                                    <td style="width: 20px;">
                                                        &nbsp;
                                                    </td>
                                                    <td style="text-align: center;">
                                                        <novalibra:NLDropDownList ID="Proposition65LabelReq" runat="server" ChangeControl="true">
                                                            <asp:ListItem Value="" Text=""></asp:ListItem>
                                                            <asp:ListItem Value="Y" Text="Yes"></asp:ListItem>
                                                            <asp:ListItem Value="N" Text="No"></asp:ListItem>
                                                        </novalibra:NLDropDownList>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="CCCRFL">
                                                        CCCR - CONSUMER CHEMICAL & CONTAINER REGULATION (Canada)
                                                    </td>
                                                    <td style="width: 20px;">
                                                        &nbsp;
                                                    </td>
                                                    <td style="text-align: center;">
                                                        <novalibra:NLDropDownList ID="CCCR" runat="server" ChangeControl="true">
                                                            <asp:ListItem Value="" Text=""></asp:ListItem>
                                                            <asp:ListItem Value="Y" Text="Yes"></asp:ListItem>
                                                            <asp:ListItem Value="N" Text="No"></asp:ListItem>
                                                        </novalibra:NLDropDownList>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="FormaldehydeCompliantFL">
                                                        FORMALDEHYDE COMPLIANT
                                                    </td>
                                                    <td style="width: 20px;">
                                                        &nbsp;
                                                    </td>
                                                    <td style="text-align: center;">
                                                        <novalibra:NLDropDownList ID="FormaldehydeCompliant" runat="server" ChangeControl="true">
                                                            <asp:ListItem Value="" Text=""></asp:ListItem>
                                                            <asp:ListItem Value="Y" Text="Yes"></asp:ListItem>
                                                            <asp:ListItem Value="N" Text="No"></asp:ListItem>
                                                        </novalibra:NLDropDownList>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td runat="server" id="PhytoTemporaryShipmentFL">
                                                        PHYTO TEMPORARY SHIPMENT
                                                    </td>
                                                    <td style="width: 20px;">
                                                        &nbsp;
                                                    </td>
                                                    <td style="text-align: center;">
                                                        <novalibra:NLDropDownList ID="PhytoTemporaryShipment" runat="server" ChangeControl="true">
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
                                    <tr>
                                        <td colspan="4">
                                            &nbsp;
                                        </td>
                                    </tr>
                                    <tr>
                                        <th colspan="4" style="height: 20px">
                                            RMS
                                        </th>
                                    </tr>
                                    <tr>
                                        <td colspan="4">
                                            &nbsp;
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="4">
                                            <table cellpadding="1" cellspacing="0" border="0">
                                                <tr>
                                                    <td valign="top">
                                                        <table cellpadding="3" cellspacing="0" border="0">
                                                            <tr>
                                                                <td runat="server" id="RMSSellableFL" class="formLabel" style="text-align: right;
                                                                    white-space: nowrap;">
                                                                    RMS Sellable<span id="RMSSellableRF" class="requiredFieldsIcon" runat="server">*</span>:
                                                                </td>
                                                                <td class="formField">
                                                                    <novalibra:NLDropDownList ID="RMSSellable" runat="server" ChangeControl="true">
                                                                    </novalibra:NLDropDownList>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td runat="server" id="RMSOrderableFL" class="formLabel" style="text-align: right;
                                                                    white-space: nowrap;">
                                                                    RMS Orderable<span id="RMSOrderableRF" class="requiredFieldsIcon" runat="server">*</span>:
                                                                </td>
                                                                <td class="formField">
                                                                    <novalibra:NLDropDownList ID="RMSOrderable" runat="server" ChangeControl="true">
                                                                    </novalibra:NLDropDownList>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td runat="server" id="RMSInventoryFL" class="formLabel" style="text-align: right;
                                                                    white-space: nowrap;">
                                                                    RMS Inventory<span id="RMSInventoryRF" class="requiredFieldsIcon" runat="server">*</span>:
                                                                </td>
                                                                <td class="formField">
                                                                    <novalibra:NLDropDownList ID="RMSInventory" runat="server" ChangeControl="true">
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
                                    <tr>
                                        <td colspan="4">
                                            &nbsp;
                                        </td>
                                    </tr>
                                    <tr>
                                        <th colspan="4">
                                            Item Image / Item MSDS Sheet
                                        </th>
                                    </tr>
                                    <tr>
                                        <td colspan="4">
                                            &nbsp;
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="4" style="height: 140px">
                                            <table cellpadding="0" cellspacing="0" border="0">
                                                <tr>
                                                    <td width="4" style="width: 4px" valign="top">
                                                        <img src="images/spacer.gif" width="4" height="1" alt="" />
                                                    </td>
                                                    <td runat="server" id="Image_IDFL" width="260" style="width: 260px" valign="top">
                                                        <table cellpadding="0" cellspacing="0" border="0">
                                                            <tr>
                                                                <td style="white-space: nowrap;">
                                                                    <strong>Item Image</strong>
                                                                </td>
                                                                <td style="white-space: nowrap;" align="right">
                                                                    <asp:HiddenField ID="ImageID" runat="server" />
                                                                    <input type="button" id="B_UpdateImage" runat="server" value="Upload" class="formButton" />
                                                                    <input type="button" id="B_DeleteImage" runat="server" value="Delete" class="formButton" />
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td colspan="2" style="border: solid 1px">
                                                                    <div id="nlcCCC_ImageID" class="nlcCCC_hide">
                                                                        <table border="0" cellpadding="0" cellspacing="0">
                                                                            <tr>
                                                                                <td align="center">
                                                                                    <div id="DIV_Image" runat="server" style="width: 242px; text-align: center; background-color: #d3d3a3;">
                                                                                        <asp:Image ID="I_Image" runat="server" Visible="false" BorderColor="#d3d3a3" BorderWidth="5" /><br />
                                                                                        <span class="subHeading" id="I_Image_Label" runat="server">(click on image to view full
                                                                                            size)</span>
                                                                                    </div>
                                                                                    <div id="nlcCCOrigC_ImageID" class="nlcCCOrigC nlcHide" style="text-align: center;">
                                                                                        <span id="ImageID_ORIGS" class="nlcCCT" style="text-align: center;">
                                                                                            <asp:HiddenField ID="ImageID_ORIG" runat="server" Value="" />
                                                                                            <asp:Image ID="I_Image_ORIG" runat="server" BorderColor="#d3d3a3" BorderWidth="5" /><br />
                                                                                        </span>
                                                                                    </div>
                                                                                    <span class="subHeading nlcHide" id="nlcCCLabel_ImageID" runat="server">(original image)</span>
                                                                                </td>
                                                                                <td valign="bottom">
                                                                                    <div id="nlcCCRevert_ImageID" runat="server" class="nlcCCRevert nlcHide" onclick="undoImage();">
                                                                                    </div>
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </div>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                    <td width="7" style="width: 7px" valign="top">
                                                        <img src="images/spacer.gif" width="7" height="1" alt="" />
                                                    </td>
                                                    <td style="width: 1px; border-right: solid 1px #000000;">
                                                        &nbsp;
                                                    </td>
                                                    <td style="width: 1px;">
                                                        &nbsp;
                                                    </td>
                                                    <td width="7" style="width: 7px" valign="top">
                                                        <img src="images/spacer.gif" width="7" height="1" alt="" />
                                                    </td>
                                                    <td runat="server" id="MSDS_IDFL" width="225" style="width: 220px" valign="top">
                                                        <table cellpadding="0" cellspacing="0" border="0">
                                                            <tr>
                                                                <td style="white-space: nowrap;">
                                                                    <strong>Item MSDS Sheet</strong>
                                                                </td>
                                                                <td style="white-space: nowrap;" align="right">
                                                                    <asp:HiddenField ID="MSDSID" runat="server" />
                                                                    <input type="button" id="B_UpdateMSDS" runat="server" value="Upload" class="formButton" />
                                                                    <input type="button" id="B_DeleteMSDS" runat="server" value="Delete" class="formButton" />
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td colspan="2" style="border: solid 1px">
                                                                    <div id="nlcCCC_MSDSID" class="nlcCCC_hide">
                                                                        <table border="0" cellpadding="0" cellspacing="0">
                                                                            <tr>
                                                                                <td align="center">
                                                                                    <div id="DIV_MSDS" runat="server" style="width: 220px; text-align: center; background-color: #d3d3a3;">
                                                                                        <asp:Image ID="I_MSDS" runat="server" Visible="false" BorderColor="#d3d3a3" BorderWidth="5" /><br />
                                                                                        <span class="subHeading" id="I_MSDS_Label" runat="server">(click on icon to view MSDS
                                                                                            Sheet)</span>
                                                                                    </div>
                                                                                    <div id="nlcCCOrigC_MSDSID" class="nlcCCOrigC nlcHide">
                                                                                        <span id="MSDSID_ORIGS" class="nlcCCT" style="text-align: left;">
                                                                                            <asp:HiddenField ID="MSDSID_ORIG" runat="server" Value="" />
                                                                                            <asp:Image ID="I_MSDS_ORIG" runat="server" BorderColor="#d3d3a3" BorderWidth="5" /><br />
                                                                                        </span>
                                                                                    </div>
                                                                                    <span class="subHeading nlcHide" id="nlcCCLabel_MSDSID" runat="server">(original MSDS
                                                                                        Sheet)</span>
                                                                                </td>
                                                                                <td valign="bottom">
                                                                                    <div id="nlcCCRevert_MSDSID" runat="server" class="nlcCCRevert nlcHide" onclick="undoImage();">
                                                                                    </div>
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </div>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                    <td width="7" style="width: 7px" valign="top">
                                                        <img src="images/spacer.gif" width="7" height="1" alt="" />
                                                    </td>
                                                    <td style="width: 1px; border-right: solid 1px #000000;">
                                                        &nbsp;
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="3" style="height: 15px;">&nbsp;</td>
                        </tr>
                        <tr>
                            <th colspan="3" class="detailFooter">
                                <table border="0" cellpadding="0" cellspacing="0" width="100%">
                                    <tr>
                                        <td colspan="2" align="left" valign="top">
                                            <asp:Button UseSubmitBehavior="false" ID="btnCancel" runat="server" Text="Cancel" CssClass="formButton" />
                                        </td>
                                        <td align="right" valign="top">
                                            &nbsp;<asp:Button UseSubmitBehavior="false" ID="btnUpdate" runat="server" CommandName="Update" Text="Save" CssClass="formButton" />
                                            &nbsp;&nbsp;<asp:Button UseSubmitBehavior="false" ID="btnUpdateClose" runat="server" CommandName="UpdateClose" Text="Save &amp; Close" CssClass="formButton" />
                                        </td>
                                    </tr>
                                </table>
                            </th>
                        </tr>
                    </table>

                    <!-- Stocking Strategy Helper -->
                    <div id="StockStratHelper" onclick="" onmouseover="" onmouseout="" style="position:absolute; left:300px; top: 400px; display: none; z-index: 3000; width: 500px; background-color: #ececec; border: 1px solid #333333; cursor: default;">
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
        </div>
    </div>
    <div id="settingsDiv" style="display: none"></div>
    
    <script language="javascript" type="text/javascript">
<!--
    <% If RefreshGrid Then %>
    //window.parent.opener.location = window.parent.opener.location;
    window.parent.opener.reloadPage();
    <% End If %>
    initPageOnLoad();
////-->
    </script>

    </form>
</body>
</html>
