<%@ Page Language="VB" AutoEventWireup="false" CodeFile="POMaintHeader.aspx.vb" Inherits="POMaintHeader" %>
<%@ Register Src="~/CORALControls/pageheader.ascx" TagName="pageheader" TagPrefix="uclayout" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>Purchase Order Management</title>
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE10" />
	<meta name="author" content="Randy Cochran" />
	<link rel="stylesheet" href="css/styles.css" type="text/css" />
<style type="text/css">
th { text-align: left; padding: 5px; }
.formLabel
{
    /*padding-left: 2px;
    padding-right: 2px;*/
    color:Black;
    padding:2px;
}
.formField
{
	/*padding-left: 2px;
    padding-right: 2px;*/
}

.Red { color:red; }
.WarehouseTable td{padding-top: 3px; padding-bottom: 3px;}
.WarehouseTable label{line-height: 14px; vertical-align: top; padding-left: 5px;}
.StoreZoneTable td{padding-top: 3px; padding-bottom: 3px;}
.StoreZoneTable label{line-height: 14px; vertical-align: top; padding-left: 5px;}


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
		
		#LoadMsg
		{
		    vertical-align: middle;
		    padding: 10px;
			font-size: 11px;
			line-height: 16px;
			color: #000000;
		}
		
        #DetailsProcessing
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

	<script type="text/javascript">
<!--

function showExcel()
{
	return false;
}
function BasicWarehouseAllClick(pID, pNumItems) {
    //Get Checkbox ALL value
    var checked = $(pID + '_0').checked;

    //Apply To All Items
    for (var i = 1; i <= pNumItems; i++) {
        $(pID + '_' + i).checked = checked;
    }
}

function SeasonalWarehouseAllClick(pID, pNumItems) {
    //Get Checkbox ALL value
    var checked = $(pID + '_0').checked;

    //Apply To All Items
    for (var i = 1; i <= pNumItems; i++) {
        $(pID + '_' + i).checked = checked;
    }
}

function StoreZoneAllClick(pID, pNumItems) {
    //Get Checkbox ALL value
    var checked = $(pID + '_0').checked;

    //Apply To All Items
    for (var i = 1; i <= pNumItems; i++) {
        $(pID + '_' + i).checked = checked;
    }
}

function BasicSeasonalChanged(pID, pBasicWarehouseID, pSeasonalWarehouseID) {
    var valueSelected = $(pID).value;

    if (valueSelected == 'B') {
        $(pBasicWarehouseID + 'TD').show();
        $(pSeasonalWarehouseID + 'TD').hide();

        //Uncheck All Seasonal Checkboxes
        $(pSeasonalWarehouseID + '_0').click();
        if ($(pSeasonalWarehouseID + '_0').checked) {
            $(pSeasonalWarehouseID + '_0').click();
        }
    }
    else if (valueSelected == 'S') {
        $(pBasicWarehouseID + 'TD').show();
        $(pSeasonalWarehouseID + 'TD').show();
    }
}


function toggleLightBox(divtotoggle, display, visibility) {
    var xScroll, yScroll;
    if (window.innerHeight && window.scrollMaxY) {
        xScroll = document.body.scrollWidth;
        yScroll = window.innerHeight + window.scrollMaxY;
    }
    else if (document.body.scrollHeight > document.body.offsetHeight) {
        xScroll = document.body.scrollWidth;
        yScroll = document.body.scrollHeight;
    }
    else {
        xScroll = document.body.offsetWidth;
        yScroll = document.body.offsetHeight;
    }

    var windowWidth, windowHeight;
    if (self.innerHeight) {
        windowWidth = self.innerWidth;
        windowHeight = self.innerHeight;
    }
    else if (document.documentElement && document.documentElement.clientHeight) {
        windowWidth = document.documentElement.clientWidth;
        windowHeight = document.documentElement.clientHeight;
    }
    else if (document.body) {
        windowWidth = document.body.clientWidth;
        windowHeight = document.body.clientHeight;
    }

    var adjustedWidth, adjustedHeight;
    if (xScroll < windowWidth) {
        adjustedWidth = windowWidth;
    }
    else {
        adjustedWidth = xScroll;
    }
    if (yScroll < windowHeight) {
        adjustedHeight = windowHeight;
    }
    else {
        adjustedHeight = yScroll;
    }

    var overlay = $(divtotoggle);

    overlay.setStyle(
			{
			    opacity: 0.8,
			    backgroundImage: 'url(images/black_50.png)',
			    backgroundRepeat: 'repeat',
			    height: adjustedHeight + 'px',
			    display: display,
			    visibility: visibility
			});
}

function togglePopup(pDivToToggle, pDisplay, pVisibility) {
    var popup = $(pDivToToggle);
    popup.setStyle(
			{
			    display: pDisplay,
			    visibility: pVisibility
			});
}

function ShowProcessing() {
    toggleLightBox('shadow', 'block', 'visible');
    togglePopup('lightbox', 'block', 'visible');
    //togglePopup('DetailsProcessing', 'block', 'visible');
    togglePopup('LoadMsg', 'block', 'visible');

    var div = document.getElementById("LoadMsg");
    var divHeight = div.offsetHeight;
    var divWidth = div.offsetWidth;

    xScroll = document.body.offsetWidth;
    yScroll = document.body.offsetHeight;

    div.style.position = "absolute";
    div.style.top = (yScroll - divHeight) / 2
    div.style.left = (xScroll - divWidth) / 2

    setTimeout('document.images["imgWaiting"].src = "images/wait30trans.gif"', 1800);

}

function HideOverlay() {
    toggleLightBox('shadow', 'none', 'hidden');
    //togglePopup('DetailsProcessing', 'none', 'hidden');
    togglePopup('lightbox', 'none', 'hidden');
    return false;
}

function DisplayDetailWait() {
    ShowProcessing();
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
    <script language="javascript" type="text/javascript" src="include/PurchaseOrder/POMaintHeader.js"></script>

</head><!-- oncontextmenu="return false;" -->
<body onload="preloadItemImages();" style="background-color:#dedede">
    <form id="form1" runat="server">
		<asp:HiddenField ID="POID" Value="0" runat="server" />
		<asp:ScriptManager ID="ScriptManager1" runat="server" AsyncPostBackTimeOut="600"></asp:ScriptManager>
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
						        <td colspan="5" style="width: 100%"><novalibra:NLValidationSummary ID="ValidationSummary" ShowSummary="true" ShowMessageBox="false" CssClass="validationDisplay" EnableClientScript="false" EnableViewState="true" runat="server" Width="99%" /></td>
                            </tr>
						    <tr>
						        <td valign="bottom">
						        	<table cellpadding="0" cellspacing="0" border="0" height="30">
    						            <tr>
				                             <td id="POHeaderTab" runat="server" width="110" height="27"  align="right" valign="bottom">
				                                <asp:LinkButton id="POHeaderLink" runat="server" CssClass="tabPOTextActive" Text="PO Header" Width="109" Height="20" Enabled="false">
				                                    <span>PO Header</span>&nbsp;<img runat="server" id="POHeaderImage" src="images/spacer.gif" alt="" style="padding-left:8px;" width="11" height="11" border="0" />
				                                </asp:LinkButton>
				                            </td>
				                            <td id="PODetailTab" runat="server" valign="bottom" align="right" width="100" height="27">
			                                    <asp:LinkButton ID="PODetailLink" runat="server" CssClass="tabPOText" Text="PO Detail" Width="109" Height="20" OnClientClick="javascript:DisplayDetailWait();">
			                                        <span>PO Detail</span>&nbsp;<img runat="server" id="PODetailImage" src="images/spacer.gif" alt="" style="padding-left:8px;" width="11" height="11" border="0" />    
			                                    </asp:LinkButton>
				                            </td>				                            
				                        </tr>
				                    </table>
						        </td>
						        <td style="width: 15px;">
						            <img src="images/spacer.gif" border="0" alt="" height="1" width="15" />
						        </td>
						        <td>
                                </td>
						        <td align="right" valign="bottom">
                                   
						        </td>
						        <td align="right" valign="bottom">
                                   
						        </td>
						        <td align="right" valign="bottom">
						            <span style="color:Red; font-size:10pt; white-space: nowrap;">* * * Revision:&nbsp;<novalibra:NLDropDownList ID="ddlRevisions" runat="server" AutoPostBack="true" /> * * *</span>
						        </td>						        
						    </tr>
                        </table>
						<table cellpadding="0" cellspacing="0" border="0" width="100%">
							<tr>
								<th colspan="1" width="30%">
                                    P U R C H A S E &nbsp;&nbsp;&nbsp;O R D E R
								</th>
								<th width="35%">
								    <span>Purchase Order: </span>&nbsp;
								    <asp:Label ID="PurchaseOrderNo" runat="Server"></asp:Label>
								    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                    <span>Log ID: </span>&nbsp;
								    <asp:Label ID="BatchOrderNo" runat="Server"></asp:Label>
								    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								    <span>Current Status: </span>&nbsp;
								    <asp:Label ID="StatusName" runat="Server"></asp:Label>
								</th>
							    <th width="25%">
                                    <asp:Label ID="LastModified" runat="server"></asp:Label>
							    </th>
							    <th width="10%" align="right" valign="top" style="text-align:right">
							       <asp:Button ID="btnEditRevision" runat="server" Text="Edit Revision" CssClass="formButton" Visible="false" />
							    </th>
							</tr>
						</table>
						<table cellpadding="0" cellspacing="0" border="0" width="100%">
							<tr>
                                <td align="left" colspan="2" class="subHeading bodyText" style="padding: 5px;">
                                <span class="requiredFields">Required Fields<span class="requiredFieldsIcon">*</span>&nbsp;&nbsp;</span>
                                </td>
                            </tr>							
							<tr>
							    <td colspan="2">&nbsp;</td>
							</tr>
						</table>
						<table style="border-style:solid; border-width:1px; border-color:silver" width="100%" cellpadding="4">
							<tr>
							    <td valign="top" >
    								<table cellpadding="2" cellspacing="0" border="0" width="100%">
    								    <tr>
    								        <td style="width: 70%">
    								            <table style="margin-left: 50px;" cellpadding="2" cellspacing="0" border="0" width="75%">
    								                <tr>
    								                   <td align="right" class="formLabel">Warehouse / Direct:</td>
							                           <td align="left" class="formField">
							                                <asp:Label ID="WarehouseDirect" runat="server" />
    								                    </td>
    								                </tr>
    								                <tr>
    								                   <td align="right" class="formLabel">Basic / Seasonal:</td>
							                           <td align="left" class="formField">
							                                <novalibra:NLDropDownList ID="BasicSeasonal" runat="server" AutoPostBack="true" onChange="javascript:setPageAsDirty()" />
    								                    </td>
    								                </tr>    								
    								                <tr>
    								                   <td align="right" class="formLabel">Allocation Event:</td>
							                           <td align="left" class="formField">
							                                <novalibra:NLDropDownList runat="server" ID="AllocationEvent" onChange="javascript:setPageAsDirty()"></novalibra:NLDropDownList>
    								                    </td>
    								                </tr>
    								                <tr>
    								                   <td align="right" class="formLabel">Seasonal Symbol:</td>
							                           <td align="left" class="formField">
							                                <novalibra:NLDropDownList runat="server" ID="SeasonalSymbol" onChange="javascript:setPageAsDirty()" ></novalibra:NLDropDownList>
    								                    </td>
    								                </tr>
    								                <tr>
    								                   <td align="right" class="formLabel">Season Code:</td>
							                           <td align="left" class="formField">
							                                <novalibra:NLDropDownList runat="server" ID="SeasonCode" onChange="javascript:setPageAsDirty()" ></novalibra:NLDropDownList>
    								                   </td>
    								                </tr>
    								                <tr>
    								                   <td align="right" class="formLabel">Event Year:</td>
							                           <td align="left" class="formField">
							                                <novalibra:NLDropDownList runat="server" ID="EventYear" onChange="javascript:setPageAsDirty()"></novalibra:NLDropDownList>
    								                    </td>
    								                </tr>
    								                <tr>
    								                   <td align="right" class="formLabel">Ship Point:</td>
							                           <td align="left" class="formField">
							                                <novalibra:NLDropDownList runat="server" ID="ShipPointImport" Visible="false" onChange="javascript:setPageAsDirty()"></novalibra:NLDropDownList>
							                                <novalibra:NLTextBox runat="server" ID="ShipPointDomestic" Visible="false" onChange="javascript:setPageAsDirty()"></novalibra:NLTextBox>
    								                    </td>
    								                </tr>
    								                <tr>
    								                   <td align="right" class="formLabel">Department:</td>
							                           <td align="left" class="formField">
							                                <asp:Label ID="DepartmentName" runat="server"></asp:Label>
    								                    </td>
    								                </tr>
    								            </table>
    								        </td>
    								        <td valign="top" style="width: 30%">
                                                <table cellpadding="2" cellspacing="0" border="0" width="100%">
    								                <tr>
        								               <td width="50%" align="right" class="formLabel">POG #:</td>
	    						                       <td width="50%" align="left" class="formField">
		    					                            <novalibra:NLTextBox runat="server" ID="POGNumber" onChange="javascript:setPageAsDirty()" RenderReadOnly="true"></novalibra:NLTextBox>
    		    						               </td>
    			    					            </tr>
    			    					            <tr>
        								               <td width="50%" align="right" class="formLabel">POG Start Date:</td>
	    						                       <td width="50%" align="left" class="formField">
		    					                            <novalibra:NLTextBox runat="server" ID="POGStartDate" onChange="javascript:setPageAsDirty()" RenderReadOnly="true"></novalibra:NLTextBox>
    		    						               </td>
    			    					            </tr>
    			    					            <tr>
        								               <td width="50%" align="right" class="formLabel">POG End Date:</td>
	    						                       <td width="50%" align="left" class="formField">
		    					                            <novalibra:NLTextBox runat="server" ID="POGEndDate" onChange="javascript:setPageAsDirty()" RenderReadOnly="true"></novalibra:NLTextBox>
    		    						               </td>
    			    					            </tr>
    								            </table>    							            
    								        </td>
    								    </tr>
    							    </table>
    							    <br/>
    							    <table cellpadding="2" cellspacing="0" border="0" width="100%" style="border-style:solid; border-width:1px; border-color:silver">
    								<tr id="WarehouseTR" runat="server" visible="false">
    								    <td id="BasicWarehouseTD" runat="server" style="padding-left: 25px; vertical-align: top;">
    								        <table cellpadding="3" cellspacing="0" border="0">
    								        <tr>    								            
    								            <td style="color:navy;">Basic</td>
    								        </tr>    								        
    								        <tr>
    								            <td>
    								               <novalibra:NLCheckBoxList ID="BasicWarehouse" runat="server"  CssClass="WarehouseTable" RenderReadOnly="true" onClick="javascript:setPageAsDirty()" />
    								            </td>
    								        </tr>
    								        </table>
    								    </td>
							           <td id="SeasonalWarehouseTD" runat="server" style="padding-left: 25px; vertical-align: top;">
    								        <table cellpadding="3" cellspacing="0" border="0">
    								        <tr>    								            
    								            <td style="color:navy;">Seasonal</td>
    								        </tr>    								        
    								        <tr>
    								            <td>
    								                <novalibra:NLCheckBoxList ID="SeasonalWarehouse" runat="server" CssClass="WarehouseTable" RenderReadOnly="true" onClick="javascript:setPageAsDirty()" />
    								            </td>
    								        </tr>
    								        </table>
    								    </td>
    								</tr>
    								<tr id="StoreZoneTR" runat="server" visible="false">
    								    <td style="padding-left: 25px; vertical-align: top;" colspan="2">
    								        <table cellpadding="3" cellspacing="0" border="0">
    								        <tr>    								            
    								            <td style="color:navy;">Store Zone</td>
    								        </tr>    								        
    								        <tr>
    								            <td>
    								                <novalibra:NLCheckBoxList ID="StoreZone" runat="server" CssClass="StoreZoneTable" RenderReadOnly="true"  onClick="javascript:setPageAsDirty()"  />
    								            </td>
    								        </tr>
    								        </table>
    								    </td>
    								</tr>
    							    </table>
							    </td>
							    <td valign="top" width="50%">
    								<table cellpadding="2" cellspacing="0" width="100%" >
    								    <tr>
    								       <td style="white-space:nowrap" width="30%" align="right" class="formLabel">Vendor No:</td>
							               <td align="left" class="formField">
							                    <asp:Label ID="VendorNumber" runat="server" Text="Label"></asp:Label>
							                    &nbsp;
                                               <asp:Label ID="VendorName" runat="server" Text="Label"></asp:Label></td>
    								    </tr>
			                            <tr>
			                                <td >&nbsp;</td>
			                                <td >
			                                    <table>
			                                        <tr>
			                                            <td width="50%" align="left" class="formLabel" >
			                                                <novalibra:NLCheckBox runat="server" ID="ImportOrder" RenderReadOnly="true" />&nbsp;-&nbsp;Import Order
			                                            </td>
			                                            <td width="50%" align="left" class="formLabel" >
			                                                Special: <novalibra:NLDropDownList runat="server" ID="POSpecial" RenderReadOnly="true" onChange="javascript:setPageAsDirty()" />
			                                            </td>
			                                        </tr>
			                                        <tr>
			                                            <td width="50%" align="left" class="formLabel" >
			                                                <novalibra:NLCheckBox runat="server" ID="EDIPO" RenderReadOnly="true" />&nbsp;-&nbsp;EDI PO
			                                            </td>
			                                        </tr>
			                                        <tr>
			                                            <td width="50%" align="left" class="formLabel" >&nbsp;</td>
			                                        </tr>
			                                    </table>
			                                </td>
			                            </tr>
    								    <tr>
    								       <td style="white-space:nowrap" align="right" class="formLabel">Vendor Payment Terms:
    								    </td>
							               <td align="left" class="formField">
							                    <novalibra:NLDropDownList ID="PaymentTerms" runat="server" onChange="javascript:setPageAsDirty()"></novalibra:NLDropDownList>
							                    &nbsp;<asp:Label id="warningPaymentTerms" class="Red" runat="server"></asp:Label>
    								        </td>
    								    </tr>
     								    <tr>
    								       <td style="white-space:nowrap" align="right" class="formLabel">Order Currency:</td>
							               <td align="left" class="formField">
							                    <asp:Label ID="OrderCurrency" runat="server">USD</asp:Label>
    								        </td>
    								    </tr>
    								    <tr>
    								       <td style="white-space:nowrap" align="right" class="formLabel">Freight Terms:</td>
							               <td align="left" class="formField">
							                    <novalibra:NLDropDownList ID="FreightTerms" runat="server" onChange="javascript:setPageAsDirty()"></novalibra:NLDropDownList>							                    
    								        </td>
    								    </tr>
				                        <tr>
						                   <td style="white-space:nowrap" align="right" class="formLabel">Internal Comments:</td>
				                           <td align="left" class="formField">
				                                <novalibra:NLTextBox ID="InternalComment" Rows="3" Columns="100" TextMode="MultiLine" ReadOnly="False" runat="server" MaxLength="2000" onChange="javascript:setPageAsDirty()" ></novalibra:NLTextBox>
						                    </td>
							            </tr>
							            <tr>
						                   <td style="white-space:nowrap" align="right" class="formLabel">External Comments:</td>
				                           <td align="left" class="formField" >
				                                <novalibra:NLTextBox ID="ExternalComment" Rows="3" Columns="100" TextMode="MultiLine" ReadOnly="False" runat="server" MaxLength="1850" onChange="javascript:setPageAsDirty()" ></novalibra:NLTextBox>
						                    </td>
							            </tr>
							            <tr>
						                   <td style="white-space:nowrap" align="right" class="formLabel">Generated Comments:</td>
				                           <td align="left" class="formField" >
				                                <novalibra:NLTextBox ID="GeneratedComment" Rows="3" Columns="100" TextMode="MultiLine" RenderReadonly="true" runat="server" MaxLength="150" />
						                    </td>
							            </tr>
						            </table>
    							    
							    </td>
						    </tr>
							</table>
						<table width="100%">
						    <tr>
                                <th colspan="2" class="detailFooter">
                                    <table border="0" cellpadding="0" cellspacing="0" width="100%" >
                                        <tr>
                                            <td width="50%" style="width: 50%;" align="left" valign="top">
                                                <input type="button" id="btnCancel" onclick="cancelForm(); return false;" value="Cancel" class="formButton" />&nbsp;
                                            </td>
                                            <td width="50%" style="width: 50%;" align="right" valign="top">
                                                &nbsp;<asp:Button ID="Save" runat="server" CssClass="formButton" Text="Save" />
                                                &nbsp;&nbsp;<asp:Button ID="SaveAndClose" runat="server" CssClass="formButton" Text="Save & Close" />
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
	<div id="shadow"></div>
    <!-- LightBox Divs  -->
    <div id="lightbox">
        <div style="text-align: center; width: 400px; height: 100px;" id="LoadMsg">
		    <p><span style="font-weight: bold; color: White;" >Loading PO Detail.  Please Wait...</span></p>
		     <div id="DetailsProcessing">
                <img id="imgWaiting" src="images/wait30trans.gif" alt="Saving..." />
            </div>
		</div>	
    </div>
	<asp:HiddenField runat="server" ID="hdnPageIsDirty" Value="0" />
	
    </form>
</body>
</html>
