<%@ Page Language="VB" AutoEventWireup="false" CodeFile="POCreationHeader.aspx.vb" Inherits="POCreationHeader" %>
<%@ Register Src="~/CORALControls/pageheader.ascx" TagName="pageheader" TagPrefix="uclayout" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <meta http-equiv="expires" content="Wed, 19 Feb 2003 08:00:00 GMT"/>
    <meta http-equiv="pragma" content="no-cache"/>
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE10" />
    <title>Purchase Order Management</title>
    <meta name="author" content="Nova Libra, Inc"/>
    
    <script type="text/javascript" language="javascript" src="include/global.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
    <script language="javascript" type="text/javascript" src="novagrid/prototype.js"></script>
    <script language="javascript" type="text/javascript" src="novagrid/scriptaculous.js"></script>
    <script language="javascript" type="text/javascript" src="novagrid/novagrid.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
    <script language="javascript" type="text/javascript" src="novagrid/lightbox.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
    <script language="javascript" type="text/javascript" src="include/PurchaseOrder/POCreationHeader.js"></script>
    <script language="javascript" type="text/javascript" src="./js/calendar_us.js"></script>
	
	<link href="novagrid/novagrid.css?v=<%=ConfigurationManager.AppSettings("AppVersion")%>" rel="stylesheet" type="text/css" />
	<link href="novagrid/lightbox.css?v=<%=ConfigurationManager.AppSettings("AppVersion")%>" rel="stylesheet" type="text/css" />
    <link rel="stylesheet" href="css/styles.css" type="text/css" />
    <link rel="stylesheet" href="css/calendar.css?v=<%=ConfigurationManager.AppSettings("AppVersion")%>" type="text/css" />
    <style type="text/css">
        th { text-align: left; padding: 5px; }
        .formLabel
        {
            padding-left: 2px;
            padding-right: 2px;            
        }
        .formField
        {
	        padding-left: 2px;
            padding-right: 2px;
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

    function CBAllClick(pID, pNumItems)
    {
        //Get Checkbox ALL value
        var checked = $(pID + '_0').checked;

        //hack here for DC cutovers, read the labels to see if a seasonal DC has been replaced.
        //if so, then find the replacement DC number and find it in the basic DC list.
        if (pID == "SeasonalWarehouse")
        {
            for (var i = 1; i <= pNumItems; i++)
            {
                var label = $(pID + '_' + i).nextSibling.innerHTML;
                var loc = label.indexOf("replaced");

                if (loc == -1)
                {
                    $(pID + '_' + i).checked = checked;
                }
                else
                {
                    var newtarget = label.substr(loc + 12, label.length - loc - 13) + ' -';
                    var found = 0;
                    for (var j = 1; j <= 12 && found == 0; j++)
                    {
                        label = $('BasicWarehouse' + '_' + j).nextSibling.innerHTML;
                        if (newtarget == label.substr(0, newtarget.length))
                        {
                            $('BasicWarehouse' + '_' + j).checked = checked;
                            found = 1;
                        }
                    }
                }
            }

            //new code changes to include the new DCs which handles Basic and Seasonal
            var basicwhcount = document.getElementById("BasicWarehouse").rows.length;

            for (var i = 0; i < basicwhcount; i++)
            {
                var label = $('BasicWarehouse' + '_' + i).nextSibling.innerHTML;
                var text = label.substr(label.length - 16, label.length);

                    if (text == '(basic+seasonal)')
                    {
                        $('BasicWarehouse' + '_' + i).checked = checked;
                    }
            }
        }
        else
        {
            //Apply To All Items
            for (var i = 1; i <= pNumItems; i++) {
                $(pID + '_' + i).checked = checked;
            }
        }
    }
    
    function BasicSeasonalChanged(pID, pBasicWarehouseID, pSeasonalWarehouseID)
    {
        var valueSelected = $(pID).value;
        
        if(valueSelected == 'B') {
            $(pBasicWarehouseID + 'TD').show();
            $(pSeasonalWarehouseID + 'TD').hide();
            
            //Uncheck All Seasonal Checkboxes
            $(pSeasonalWarehouseID + '_0').click();
            if($(pSeasonalWarehouseID + '_0').checked) {
                $(pSeasonalWarehouseID + '_0').click();
            }
        }
        else if(valueSelected == 'S') {
            $(pBasicWarehouseID + 'TD').show();
            $(pSeasonalWarehouseID + 'TD').show();
        }
    }

    function CheckLocationSelection(pBasicWarehouseID, pSeasonalWarehouseID, pStoreZoneID) 
    {
        var isChecked = false
        var containerCheckboxes = []
        var control = $(pBasicWarehouseID)
        
        if (control != null) {
            containerCheckboxes = control.select('input[type=checkbox]')
            for (var i = 0; i < containerCheckboxes.length; i++) {
                if (containerCheckboxes[i].checked) {
                    isChecked = containerCheckboxes[i].checked

                    return true;
                }
            }
        }
        
        control = $(pSeasonalWarehouseID)
        if(control != null){
            containerCheckboxes = control.select('input[type=checkbox]')
            for (var i = 0; i < containerCheckboxes.length; i++) {
                if (containerCheckboxes[i].checked) {
                    isChecked = containerCheckboxes[i].checked
                    return true;
                }
            }
        }

        control = $(pStoreZoneID)
        if(control != null) {
            containerCheckboxes = control.select('input[type=checkbox]')
            for (var i = 0; i < containerCheckboxes.length; i++) {
                if (containerCheckboxes[i].checked) {
                    isChecked = containerCheckboxes[i].checked
                    return true;
                }
            }
        }
        
        if (!isChecked) {
            alert('At least 1 location must be selected before the PO can be saved.')
            return false;
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
        CheckLocationSelection('BasicWarehouse', 'SeasonalWarehouse', 'StoreZone');
        ShowProcessing();
    }

    function WriteCalendar(textCtrl) {
        new tcal
			(
				{
				    'id': 0,
				    'formname': 'form1',
				    'controlname': textCtrl,
				    'selectinthepast': true
				}
			);
}

function ValidateHeader() {
    var isValid = CheckLocationSelection('BasicWarehouse', 'SeasonalWarehouse', 'StoreZone');

    if (isValid) {
        isValid = ValidateDates();
    }

    return isValid;
}


function ValidateDates() {

    if ($('POGStartDate').value != '') {
        if (!ValidateUSDate($('POGStartDate').value)) {
            alert("The POG Start Date value is not in a valid format. Please correct before continuing.");
            return false;
        }
    }

    if ($('POGEndDate').value != '') {
        if (!ValidateUSDate($('POGEndDate').value)) {
            alert("The POG End Date value is not in a valid format. Please correct before continuing.");
            return false;
        }
    }

    return true;
}

function PODetailValidate() {
    var isValid = ValidateDates();

    if (isValid) {
        DisplayDetailWait();
        return true;
    }

    return false;
}
    //-->
    </script>

</head><!--oncontextmenu="return false;"-->
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
						        <td style="width: 100%"><novalibra:NLValidationSummary ID="ValidationSummary" ShowSummary="true" ShowMessageBox="false" CssClass="validationDisplay" EnableClientScript="false" EnableViewState="true" runat="server" Width="99%" /></td>
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
			                                    <asp:LinkButton ID="PODetailLink" runat="server" CssClass="tabPOText" Text="PO Detail" Width="109" Height="20" OnClientClick="javascript:return PODetailValidate();">
			                                        <span>PO Detail</span>&nbsp;<img runat="server" id="PODetailImage" src="images/spacer.gif" alt="" style="padding-left:8px;" width="11" height="11" border="0" />    
			                                    </asp:LinkButton>
				                            </td>
				                            <td style="width: 15px;">
						                        <img src="images/spacer.gif" border="0" alt="" height="1" width="15" />
						                    </td>
				                        </tr>
				                    </table>
						        </td>					       
						    </tr>
                        </table>
						<table cellpadding="0" cellspacing="0" border="0" width="100%">
							<tr>
								<th colspan="1" width="30%">
                                    P U R C H A S E &nbsp;&nbsp;&nbsp;O R D E R
								</th>
								<th width="40%">
								    <span>Log ID: </span>&nbsp;
								    <asp:Label ID="BatchOrderNo" runat="Server"></asp:Label>
								    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								    <span>Current Status: </span>&nbsp;
								    <asp:Label ID="WorkflowStageName" runat="Server"></asp:Label>
								</th>
							    <th width="30%">
							        <asp:Label ID="LastModified" runat="server"></asp:Label>								    
							    </th>
							</tr>
						</table>
						<table cellpadding="0" cellspacing="0" border="0" width="100%">
							<tr>
                                <td align="left" colspan="2" class="subHeading bodyText" style="padding: 5px;">
                                <span>Required Fields<span>*</span>&nbsp;&nbsp;</span>
                                </td>
                            </tr>							
							<tr>
							    <td colspan="2">&nbsp;</td>
							</tr>
							</table>
							<table style="border-style:solid; border-width:1px; border-color:silver" width="100%" cellpadding="4">
							<tr>
							    <td valign="top">
							        <table cellpadding="2" cellspacing="0" border="0" width="100%">
							            <tr>
							                <td valign="top">
							                    <table cellpadding="2" cellspacing="0" border="0" width="100%">
    								            <tr>
    								               <td width="30%" align="right" class="formLabel">Warehouse / Direct:</td>
							                       <td align="left" class="formField">
							                            <asp:Label ID="WarehouseDirect" runat="server"></asp:Label>						                
    								               </td>
    								            </tr>
    								            <tr>
    								               <td align="right" class="formLabel">Basic / Seasonal:</td>
							                       <td align="left" class="formField">
							                            <novalibra:NLDropDownList runat="server" ID="BasicSeasonal" AutoPostBack="true" onChange="javascript:setPageAsDirty()" ></novalibra:NLDropDownList>
    								               </td>
    								            </tr>    								
    								            <tr>
    								               <td align="right" class="formLabel">Allocation Event:</td>
							                       <td align="left" class="formField">
							                            <novalibra:NLDropDownList runat="server" ID="AllocationEvent" onChange="javascript:setPageAsDirty()" ></novalibra:NLDropDownList>
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
							                            <novalibra:NLDropDownList runat="server" ID="EventYear" onChange="javascript:setPageAsDirty()" ></novalibra:NLDropDownList>							                
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
    							            <td valign="top">
                                                <table cellpadding="2" cellspacing="0" border="0" width="100%">
    								                <tr>
        								               <td width="30%" align="right" class="formLabel">POG #:</td>
	    						                       <td align="left" class="formField">
		    					                            <novalibra:NLTextBox runat="server" ID="POGNumber" onChange="javascript:setPageAsDirty();"></novalibra:NLTextBox>
    		    						               </td>
    			    					            </tr>
    			    					            <tr>
        								               <td width="30%" align="right" class="formLabel">POG Start Date:</td>
	    						                       <td align="left" class="formField">
		    					                            <novalibra:NLTextBox runat="server" ID="POGStartDate" onChange="javascript:setPageAsDirty();"></novalibra:NLTextBox>
		    					                            <%IF Not _pogStartDateLocked THEN %><span><script type='text/javascript'>WriteCalendar('POGStartDate');</script></span> <%END IF%>
    		    						               </td>
    			    					            </tr>
    			    					            <tr>
        								               <td width="30%" align="right" class="formLabel">POG End Date:</td>
	    						                       <td align="left" class="formField">
		    					                            <novalibra:NLTextBox runat="server" ID="POGEndDate" onChange="javascript:setPageAsDirty();"></novalibra:NLTextBox>
		    					                             <%IF Not _pogEndDateLocked THEN %><span><script type='text/javascript'>WriteCalendar('POGEndDate');</script></span> <%END IF%>
    		    						               </td>
    			    					            </tr>
    								            </table>    							            
    								        </td>
							            </tr>
							        </table>
    								<br />
    							    <table cellpadding="2" cellspacing="0" border="0" width="100%" style="border-style:solid; border-width:1px; border-color:silver">
    								<tr id="WarehouseTR" runat="server" visible="false">
    								    <td id="BasicWarehouseTD" runat="server" style="padding-left: 25px; vertical-align: top;">
    								        <table cellpadding="3" cellspacing="0" border="0">
    								        <tr>    								            
    								            <td style="color:navy;">Basic</td>
    								        </tr>    								        
    								        <tr>
    								            <td>
    								                <novaLibra:NLCheckBoxList ID="BasicWarehouse" runat="server" CssClass="WarehouseTable" onClick="javascript:setPageAsDirty()"></novaLibra:NLCheckBoxList>
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
    								                <novaLibra:NLCheckBoxList ID="SeasonalWarehouse" runat="server" CssClass="WarehouseTable" onClick="javascript:setPageAsDirty()"></novaLibra:NLCheckBoxList>
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
    								                <novalibra:NLCheckBoxList ID="StoreZone" runat="server" CssClass="StoreZoneTable" onClick="javascript:setPageAsDirty()"></novalibra:NLCheckBoxList>
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
			                                                Special: <novalibra:NLDropDownList ID="POSpecial" runat="server"  onChange="javascript:setPageAsDirty()"/>
			                                            </td>
			                                        </tr>
			                                        <tr>
			                                            <td width="50%" align="left" class="formLabel" >
			                                                <novalibra:NLCheckBox runat="server" ID="EDIPO" RenderReadOnly="true" />&nbsp;-&nbsp;EDI PO
			                                            </td>
			                                            <td width="50%" align="left" class="formLabel" >
			                                            </td>
			                                        </tr>
                                                    <tr>
                                                        <td width="50%" align="left" class="formLabel" >
                                                            <novalibra:NLCheckBox runat="server" ID="AllowSeasonalItemsBasicDC"/>&nbsp;-&nbsp;Allow Seasonal Items at Basic DC
                                                        </td>
                                                        <td width="50%" align="left" class="formLabel" >
			                                            </td>
                                                    </tr>
			                                        <tr>
			                                            <td width="50%" align="left" class="formLabel" >&nbsp;
			                                            </td>
			                                            <td width="50%" align="left" class="formLabel" >
			                                            </td>
			                                        </tr>
			                                    </table>
			                                </td>
			                            </tr>
    								    <tr>
    								       <td style="white-space:nowrap" align="right" class="formLabel">Vendor Payment Terms:
    								    </td>
							               <td align="left" class="formField">
							                    <novalibra:NLDropDownList ID="PaymentTerms" runat="server" onChange="javascript:setPageAsDirty()" ></novalibra:NLDropDownList>
							                    &nbsp;<asp:Label id="warningPaymentTerms" class="Red" runat="server"></asp:Label>
    								        </td>
    								    </tr>
        								<tr>
    								       <td style="white-space:nowrap" align="right" class="formLabel">Order Currency:</td>
							               <td align="left" class="formField">
							                    <asp:Label ID="OrderCurrency" runat="server"></asp:Label>
    								        </td>
    								    </tr>
    								    <tr>
    								       <td style="white-space:nowrap" align="right" class="formLabel">Freight Terms:</td>
							               <td align="left" class="formField">
							                    <novalibra:NLDropDownList ID="FreightTerms" runat="server" onChange="javascript:setPageAsDirty()" ></novalibra:NLDropDownList>
							                     &nbsp;<asp:Label id="warningFreightTerms" class="Red" runat="server"></asp:Label>
    								        </td>
    								    </tr>
           							    <tr>
						                   <td style="white-space:nowrap" align="right" class="formLabel">Internal Comments:</td>
				                           <td align="left" class="formField">
				                                <novalibra:NLTextBox ID="InternalComment" Rows="7" Columns="100" TextMode="MultiLine" runat="server" MaxLength="2000" onChange="javascript:setPageAsDirty()"></novalibra:NLTextBox>
						                    </td>
							            </tr>
							            <tr>
						                   <td style="white-space:nowrap" align="right" class="formLabel">External Comments:</td>
				                           <td align="left" class="formField" >
				                                <novalibra:NLTextBox ID="ExternalComment" Rows="7" Columns="100" TextMode="MultiLine" runat="server" MaxLength="1850" onChange="javascript:setPageAsDirty()"> ></novalibra:NLTextBox>
						                    </td>
							            </tr>
							            <tr id="GeneratedCommentsTR" runat="server">
						                   <td style="white-space:nowrap" align="right" class="formLabel">Generated Comments:</td>
				                           <td align="left" class="formField" >
				                                <novalibra:NLTextBox ID="GeneratedComment" Rows="3" Columns="100" TextMode="MultiLine" RenderReadonly="true" runat="server" MaxLength="150" ></novalibra:NLTextBox>
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
                                                &nbsp;<asp:Button ID="Save" runat="server" CssClass="formButton" Text="Save" OnClientClick="javascript:return ValidateHeader();" />
                                                &nbsp;&nbsp;<asp:Button ID="SaveAndClose" runat="server" CssClass="formButton" Text="Save & Close" OnClientClick="javascript:return ValidateHeader();" />
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
   
	<!-- <div id="lightbox2"> <div id="StoreSaving" style="width:30px; height:30px; position:absolute; top:476px; left:433px;">
		    <img id="imgWaiting" src="images/wait30trans.gif" alt="Saving..." />
		</div>
	</div> -->
	
	<asp:HiddenField runat="server" ID="hdnPageIsDirty" Value="0" />
	
	<script language="javascript" type="text/javascript">
    <!--
    //Effect.toggle('submissiondetail','slide',{duration:0.5, afterFinish:toggleCallbackOnFinish});
    //-->
	</script>
    </form>
</body>
</html>
