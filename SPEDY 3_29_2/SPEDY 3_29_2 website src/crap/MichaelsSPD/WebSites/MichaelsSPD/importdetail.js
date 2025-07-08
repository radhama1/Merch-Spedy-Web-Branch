
function childItemsChanged()
{
    var o = $('childItems');
    if(o){
        var goID = o.options[o.selectedIndex].value;
        if(goID != '')
            goUrl("importdetail.aspx?hid=" + goID);
    }
}

var isCFPMCCalc = true;
function isCubicFeetPerMasterCartonCalculated()
{
    return isCFPMCCalc;
}
function setIsCubicFeetPerMasterCartonCalculated(value)
{
    if(value == null || !value) isCFPMCCalc = false; else isCFPMCCalc = true;
}

function AddSKUtoBatch(batchid) {
    var url = 'IMAddRecords.aspx?btype=NI&bid=' + batchid;
    var i = window.open(url, "AddItem", "directories=no,height=700,width=1020,menubar=no,resizable=yes,scrollbars=yes,status=no,titlebar=no,toolbar=no", true);
    i.focus();
    $('AddedNewSKUs').value = "1"
}

function initPageOnLoad()
{
  // FJL Dec 2009: check if Parent line of Country of Orgin exists before setting the auto-complete
    if ( $('CountryOfOriginParent') ) 
    {
      new Ajax.Autocompleter("CountryOfOriginName", "CountryOfOriginName_choices", "lookupcountry.aspx", {
          paramName: "value", 
          minChars: 1,
          afterUpdateElement: countryOfOriginChanged
      } );
  }
  setIsDirty(0);
}

function addAdditionalUPC() {
    var oCount = $('additionalUPCCount');
    var cntval, cnt, newUPCControl;
    if (oCount) {
        cntval = oCount.value;
        if (isInteger(cntval)) {
            cnt = parseInt(cntval);
            cnt += 1;
            oCount.value = cnt.toString();
            newUPCControl = '<input type="text" id="additionalUPC' + cnt.toString() + '" maxlength="20" value="" onchange="additionalUPCChanged(' + cnt.toString() + ');" /><sup>' + cnt.toString() + '</sup>';
            $('additionalUPCs').innerHTML += ("<br />" + newUPCControl);
        }
    }
}

function additionalUPCChanged(upcnum) {
    var vupc = $('additionalUPC' + upcnum);
    var val;
    if (vupc && vupc != null) {
        val = vupc.value;
        if (val != '' && isInteger(val) && isGreaterThanZero(val)) {
            while (val.length < 14) {
                val = "0" + val;
            }
            vupc.value = val;
        }
    }
    saveAdditionalUPCValues();
}

function saveAdditionalUPCValues() {
    var o, oID, oCount = $('additionalUPCCount');
    var iCount = 1;
    if (oCount && isInteger(oCount.value)) iCount = parseInt(oCount.value);
    var i, val = '';
    for (i = 1; i <= iCount; i++) {
        oID = 'additionalUPC' + i.toString();
        o = $(oID);
        if (o) {
            if (val != '') val += ",";
            val += o.value;
        }
    }
    // save the values (val,val,...)
    $('additionalUPCValues').value = val;
}

function isInteger(s) {
    var i;
    for (i = 0; i < s.length; i++) {
        // Check that current character is number.
        var c = s.charAt(i);
        if (((c < "0") || (c > "9")))
            return false;
    }
    // All characters are numbers.
    return true;
}

function isGreaterThanZero(s) {
    var i = parseInt(s);
    if (isNaN(i) || i <= 0)
        return false;
    else
        return true;
}

var callbackSep = "{{|}}";

function updateImage(id, newid)
{
    var i = $('I_Image');
    if(i){
        var isrc = i.src;
        if (newid != null && isNum(newid)) {
            i.src = 'getimage.aspx?id=' + newid;
            Element.writeAttribute(i, "width", "250");
            Element.setStyle(i, { width: '250px' });
            if($('ImageID')) $('ImageID').value = newid;
            if($('B_UpdateImage')) $('B_UpdateImage').value = 'Update';
            if($('I_Image_Label')) $('I_Image_Label').innerText = '(click on image to view full size)';
            Element.writeAttribute($('B_DeleteImage'), "disabled", "");
        }
    }
}

function VerifyUpdatePBLforBatch() {
    var ret = false;
    var ret = confirm('Please Verify you want ALL ITEMS in the Batch to use this selected Private Brand Label.');
    if (ret == false)
        return; 
    var obj = $('hdnPBLApplyAll');
    obj.value = "1";
    var cmd = $('btnUpdate');
    cmd.click();
}

function updateMSDS(id, newid)
{
    var i = $('I_MSDS');
    if(i){
        var isrc = i.src;
        if (newid != null && isNum(newid)) {
            i.src = 'images/app_icons/icon_pdf_large.gif?id=' + newid;
            Element.writeAttribute(i, "width", "32");
            Element.setStyle(i, { width: '32px' });
            if($('MSDSID')) $('MSDSID').value = newid;
            if($('B_UpdateMSDS')) $('B_UpdateMSDS').value = 'Update';
            if($('I_MSDS_Label')) $('I_MSDS_Label').innerText = '(click on icon to view MSDS Sheet)';
            Element.writeAttribute($('B_DeleteMSDS'), "disabled", "");
        }
    }
}
function showImage()
{
    var id;
    var isrc = $('I_Image').src;
    if(isrc.indexOf('id=') > 0){
        id = isrc.substring(isrc.indexOf('id=')+3);
        var url = 'getimage.aspx?id=' + id;
        var i = window.open(url, "importimg", "directories=no,height=600,width=955,menubar=no,resizable=yes,scrollbars=yes,status=no,titlebar=no,toolbar=no", true);
        i.focus();
    }else{
        if(!($('B_UpdateImage')) || $('B_UpdateImage').disabled == true) return false;
        var cmd = Element.readAttribute('B_UpdateImage', 'onclick');
        if(cmd != '')
            eval(cmd);
    }
}
function showMSDS(filename)
{
    if(filename == null) filename = '';
    var id;
    var isrc = $('I_MSDS').src;
    if(isrc.indexOf('id=') > 0){
        id = isrc.substring(isrc.indexOf('id=')+3);
        var url = 'getfile.aspx?ad=1&id=' + id + '&filename=' + filename;
        document.location = url;
    }else{
        if(!($('B_UpdateMSDS')) || $('B_UpdateMSDS').disabled == true) return false;
        var cmd = Element.readAttribute('B_UpdateMSDS', 'onclick');
        if(cmd != '')
            eval(cmd);
    }
}
function deleteImage(itemid)
{
    var id = '';
    if($('ImageID')) id = $('ImageID').value;
    if(confirmAction('Really delete this Item Image?')){
        goValue = "DELETEIMAGE" + callbackSep + itemid + callbackSep + id;
		CallServer(goValue, "");
        //clearImage();
    }
}
function clearImage()
{
    var i = $('I_Image');
    if(i){
        Element.writeAttribute(i, "width", "16");
        Element.setStyle(i, { width: '16px' });
        i.src = 'images/app_icons/icon_jpg_small.gif';
        if($('ImageID')) $('ImageID').value = '';
        if($('B_UpdateImage')) $('B_UpdateImage').value = 'Upload';
        if($('I_Image_Label')) $('I_Image_Label').innerText = '(click upload button to add Item Image)';
        Element.writeAttribute($('B_DeleteImage'), "disabled", "disabled");
    }
}
function deleteMSDS(itemid)
{
    var id = '';
    if($('MSDSID')) id = $('MSDSID').value;
    if(confirmAction('Really delete this Item MSDS Sheet?')){
        goValue = "DELETEMSDS" + callbackSep + itemid + callbackSep + id;
		CallServer(goValue, "");
        //clearMSDS();
    }
}
function clearMSDS()
{
    var i = $('I_MSDS');
    if(i){
        Element.writeAttribute(i, "width", "16");
        Element.setStyle(i, { width: '16px' });
        i.src = 'images/app_icons/icon_pdf_small_off.gif';
        if($('MSDSID')) $('MSDSID').value = '';
        if($('B_UpdateMSDS')) $('B_UpdateMSDS').value = 'Upload';
        if($('I_MSDS_Label')) $('I_MSDS_Label').innerText = '(click upload button to add MSDS Sheet)';
        Element.writeAttribute($('B_DeleteMSDS'), "disabled", "disabled");
    }
}
//LP Change Order 14
function SetHiddenFieldValue(controlName) {
    $(controlName).value = $(controlName + 'Edit').value;
    //alert($(controlName + 'Edit').value); LP Change Order 14
    calculateIMUPercent(controlName);
}
//
function lookupVendor(vendorType, vendorNumCtrl)
{
	var goValue = "";
	var vendorNum = vendorNumCtrl.value;
	if (vendorNum != null && vendorNum != '')
	{
		goValue = "100" + callbackSep + vendorType + callbackSep + vendorNum;
		CallServer(goValue, "");
	} else {
	    $('VendorNumber').value = vendorNum;
	}
}
function ReceiveServerData(rvalue, context)
{
	var arr;
	var i, msg = "";
	if(rvalue != null && rvalue != '')
	{
		arr = rvalue.split(callbackSep);
		if (arr.length > 1)
		{
			if(arr[0] == "100")
			{
				if(arr[1] == "1" && arr.length >= 5)
				{
					//alert("SUCCESS !");
					var vType = arr[2];
					var vNum = arr[3];
					var vName = arr[4];
					//if(vType == "") {
					    $('VendorNumber').value = vNum;
					    $('VendorNumberEdit').value = vNum;
					    $('VendorName').value = vName;
					    $('VendorNameLabel').innerText = vName;
					    highlightControls('VendorNameLabel');
					//}
				}
				else 
				{
				    var vType = (arr.length >= 3) ? arr[2] : "";
				    var vNum = (arr.length >= 4) ? arr[3] : "";
				    var vNumShow = (vNum != "") ? (" " + vNum) : "";
				    var vName = (arr.length >= 5) ? arr[4] : "";
				    var vError = (arr.length >= 6) ? arr[5] : "";
				    //if(vType == "") {
					    //$('VendorNumber').value = '';
					    //$('VendorNumberEdit').value = '';
					    $('VendorNumber').value = vNum;
					    $('VendorNumberEdit').value = vNum;
					    
					    $('VendorName').value = '';
					    $('VendorNameLabel').innerText = '';
					    
					    $('VendorNumberEdit').focus();
					    $('VendorNumberEdit').select();
					//}
					if (vError != "")
				        alert(vError);
				    else
				        alert("Vendor Number" + vNumShow + " is not valid.  Please re-enter the Vendor Number.");
				}
			}
			else if (arr[0] == "ECPC") {
			    if (arr[1] == "1" && arr.length >= 3) {
			        setControlValue('CubicFeetPerEach', arr[2]);
			    }
			    else { alert("ERROR: There was a problem calculating the Each Case Pack Cube!"); }
			}
			else if(arr[0] == "ICPC")
			{
				if(arr[1] == "1" && arr.length >= 3)
				{
					setControlValue('CubicFeetPerInnerCarton', arr[2]);
				}
				else {alert("ERROR: There was a problem calculating the Inner Case Pack Cube!");}
			} 
			else if(arr[0] == "CALC_OceanFreight")
			{
			    if(arr[1] == "1" && arr.length >= 3)
				{
					setControlValue('OceanFreightComputedAmount', arr[2]);
				}
				else {alert("ERROR: There was a problem calculating the Ocean Freight!");}
			}
			else if(arr[0] == "CALC_EstLandedCost")
			{
			    if(arr[1] == "1" && arr.length >= 4 && arr[3] != null && arr[3] != '')
				{
				    var fromField = arr[2];
				    //alert(arr[3]);
					// display values from XML
					//var dsResults = new Spry.Data.XMLDataSet(null, "/calcresults");
                    var xmlDOMDoc = Spry.Utils.stringToXMLDoc(arr[3]);
                    //dsEmployees.setDataFromDoc(xmlDOMDoc);
                    //var x;
                    // dispcost
                    if(fromField == 'dispcost')
					    setControlValue('DisplayerCost', getXMLValue(xmlDOMDoc, 'dispcost'), false, true);
					else
					    setControlValue('DisplayerCost', getXMLValue(xmlDOMDoc, 'dispcost'), true, true);
                    // prodcost
                    if(fromField == 'prodcost')
					    setControlValue('ProductCost', getXMLValue(xmlDOMDoc, 'prodcost'), false, true);
					else
					    setControlValue('ProductCost', getXMLValue(xmlDOMDoc, 'prodcost'), true, true);
                    // fob
				    setControlValue('FOBShippingPoint', getXMLValue(xmlDOMDoc, 'fob'));
//				    if(fromField == 'fob')
//					    setControlValue('FOBShippingPoint', getXMLValue(xmlDOMDoc, 'fob'), false, true);
//					else
//					    setControlValue('FOBShippingPoint', getXMLValue(xmlDOMDoc, 'fob'), true, true);
				    setControlValue('FirstCost', getXMLValue(xmlDOMDoc, 'fob'));
					// dutyper
					if(fromField == 'dutyper')
					    setControlValue('DutyPercent', getXMLValue(xmlDOMDoc, 'dutyper'), false, true);
					else
					    setControlValue('DutyPercent', getXMLValue(xmlDOMDoc, 'dutyper'), true, true);
					// addduty
					if(fromField == 'addduty')
					    setControlValue('AdditionalDutyAmount', getXMLValue(xmlDOMDoc, 'addduty'), false, true);
					else
					    setControlValue('AdditionalDutyAmount', getXMLValue(xmlDOMDoc, 'addduty'), true, true);

			        //supptariff
					if (fromField == 'supptariffper')
					    setControlValue('SuppTariffPercent', getXMLValue(xmlDOMDoc, 'supptariffper'), false, true);
					else
					    setControlValue('SuppTariffPercent', getXMLValue(xmlDOMDoc, 'supptariffper'), true, true);

					// eachesmc
					if(fromField == 'eachesmc')
					    setControlValue('EachInsideMasterCaseBox', getXMLValue(xmlDOMDoc, 'eachesmc'), false, true);
					else
					    setControlValue('EachInsideMasterCaseBox', getXMLValue(xmlDOMDoc, 'eachesmc'), true, true);
					// mclength
					if(fromField == 'mclength')
					    setControlValue('MasterCartonDimensionsLength', getXMLValue(xmlDOMDoc, 'mclength'), false, true);
					else
					    setControlValue('MasterCartonDimensionsLength', getXMLValue(xmlDOMDoc, 'mclength'), true, true);
					// mcwidth
					if(fromField == 'mcwidth')
					    setControlValue('MasterCartonDimensionsWidth', getXMLValue(xmlDOMDoc, 'mcwidth'), false, true);
					else
					    setControlValue('MasterCartonDimensionsWidth', getXMLValue(xmlDOMDoc, 'mcwidth'), true, true);
					// mcheight
					if(fromField == 'mcheight')
					    setControlValue('MasterCartonDimensionsHeight', getXMLValue(xmlDOMDoc, 'mcheight'), false, true);
					else
					    setControlValue('MasterCartonDimensionsHeight', getXMLValue(xmlDOMDoc, 'mcheight'), true, true);
					// oceanfre
					if(fromField == 'oceanfre')
					    setControlValue('OceanFreightAmount', getXMLValue(xmlDOMDoc, 'oceanfre'), false, true);
					else
					    setControlValue('OceanFreightAmount', getXMLValue(xmlDOMDoc, 'oceanfre'), true, true);
					// agentcommper
					if(fromField == 'agentcommper')
					    setControlValue('AgentCommissionPercent', getXMLValue(xmlDOMDoc, 'agentcommper'), false, true);
					else
					    setControlValue('AgentCommissionPercent', getXMLValue(xmlDOMDoc, 'agentcommper'), true, true);
					// otherimportper 
					if(fromField == 'otherimportper')
					    setControlValue('OtherImportCostsPercent', getXMLValue(xmlDOMDoc, 'otherimportper'));
					else
					    setControlValue('OtherImportCostsPercent', getXMLValue(xmlDOMDoc, 'otherimportper'), true);
					// packcost
					//if(fromField == 'packcost')
					//    setControlValue('PackagingCostAmount', getXMLValue(xmlDOMDoc, 'packcost'), false, true);
					//else
					//    setControlValue('PackagingCostAmount', getXMLValue(xmlDOMDoc, 'packcost'), true, true);
					
					// cubicftpermc
					if(isCubicFeetPerMasterCartonCalculated())
					    setControlValue('CubicFeetPerMasterCarton', getXMLValue(xmlDOMDoc, 'cubicftpermc'), true);
					
					// duty
					setControlValue('DutyAmount', getXMLValue(xmlDOMDoc, 'duty'));

			        //SuppTariff
					setControlValue('SuppTariffAmount', getXMLValue(xmlDOMDoc, 'supptariff'));

					// ocean
					setControlValue('OceanFreightComputedAmount', getXMLValue(xmlDOMDoc, 'ocean'));
					// agentcomm
					setControlValue('AgentCommissionAmount', getXMLValue(xmlDOMDoc, 'agentcomm'));
					// otherimport
					setControlValue('OtherImportCostsAmount', getXMLValue(xmlDOMDoc, 'otherimport'));
					// totalimport
					setControlValue('TotalImportBurden', getXMLValue(xmlDOMDoc, 'totalimport'));
					setControlValue('StoreTotalImportBurden', getXMLValue(xmlDOMDoc, 'totalimport'));
					// totalcost
					setControlValue('WarehouseLandedCost', getXMLValue(xmlDOMDoc, 'totalcost'));
					setControlValue('TotalWhseLandedCost', getXMLValue(xmlDOMDoc, 'totalcost'));
					// outfreight
					setControlValue('OutboundFreight', getXMLValue(xmlDOMDoc, 'outfreight'));
					// ninewhse
					setControlValue('NinePercentWhseCharge', getXMLValue(xmlDOMDoc, 'ninewhse'));
					// totalstore
					setControlValue('TotalStoreLandedCost', getXMLValue(xmlDOMDoc, 'totalstore'));
					calculateGMPercent();
				}
				else {alert("ERROR: There was a problem with the calculated fields!");}
			}
			else if(arr[0] == "ConversionDate")
			{
				if(arr[1] == "1" && arr.length >= 3)
				{
					setControlValue('ConversionDate', arr[2]);
				}
				else {alert("ERROR: There was a problem calculating the Conversion Date!");}
			} 
			else if(arr[0] == "Retail")
			{
				if(arr[1] == "1" && arr.length >= 6)
				{
				    var fromField = arr[2];
				    var skipHighlight = false;
				    if(fromField == 'prepriced'){
				        if($('RDBase') && $('RDCentral') && $('RDTest')){
				            if($('RDBase').value != $('RDCentral').value || $('RDBase').value != $('RDTest').value)
				                skipHighlight = false;
				            else
				                skipHighlight = true;
				        }else{
				            skipHighlight = true;
				        }
				    }
					setControlValue('RDBase', arr[3], true, true);
					
					if($('RDAlaska').value != arr[4] && $('RDBase').value !=''){
					    setControlValue('RDAlaska', arr[4], false, true);
					}
					if ($('RDCanada').value != arr[5] && $('RDBase').value != '' && isNum(arr[5])) {
					    setControlValue('RDCanada', arr[5], false, true);
					    setControlValue('RDQuebec', arr[5], false, true);
					    if ($('RDCanada') || $('RDCanadaEdit')) {
					        if ($('RDCanada')) {
					            if ($('RDCanada').previous('.renderReadOnly'))
					                $('RDCanada').previous().innerText = arr[5];
					        }
					        if ($('RDCanadaEdit')) {
					            if ($('RDCanadaEdit').previous('.renderReadOnly'))
					                $('RDCanadaEdit').previous().innerText = arr[5];
					        }
					    }
					    if ($('RDQuebec') || $('RDQuebecEdit')) {
					        if ($('RDQuebec')) {
					            if ($('RDQuebec').previous('.renderReadOnly'))
					                $('RDQuebec').previous().innerText = arr[5];
					        }
					        if ($('RDQuebecEdit')) {
					            if ($('RDQuebecEdit').previous('.renderReadOnly'))
					                $('RDQuebecEdit').previous().innerText = arr[5];
					        }
					    }
					}
                    //set all prices based on base retail entered if workflow stage is pricing mangager(5)
					if ($('RD0Thru9').value.length == 0 || $('hdnWorkflowStageID').value == 5) {setControlValue('RD0Thru9', arr[3], false, true)};
					if ($('RDCalifornia').value.length == 0 || $('hdnWorkflowStageID').value == 5) { setControlValue('RDCalifornia', arr[3], false, true) };
					if ($('RDVillageCraft').value.length == 0 || $('hdnWorkflowStageID').value == 5) { setControlValue('RDVillageCraft', arr[3], false, true) };
					if ($('RDCentral').value.length == 0 || $('hdnWorkflowStageID').value == 5) { setControlValue('RDCentral', arr[3], false, true) };
					if ($('RDTest').value.length == 0 || $('hdnWorkflowStageID').value == 5) { setControlValue('RDTest', arr[3], false, true) };
					//setControlValue('RD0Thru9', arr[3], skipHighlight);
					//setControlValue('RDCalifornia', arr[3], skipHighlight);
					//setControlValue('RDVillageCraft', arr[3], skipHighlight);
					//setControlValue('RDCentral', arr[3], skipHighlight);
					//setControlValue('RDTest', arr[3], skipHighlight);
					//lp change order 14 19 aug 2009
					if ($('Retail9').value.length == 0 || $('hdnWorkflowStageID').value == 5) { setControlValue('Retail9', arr[3], false, true) };
					if ($('Retail10').value.length == 0 || $('hdnWorkflowStageID').value == 5) { setControlValue('Retail10', arr[3], false, true) };
					if ($('Retail11').value.length == 0 || $('hdnWorkflowStageID').value == 5) { setControlValue('Retail11', arr[3], false, true) };
					if ($('Retail12').value.length == 0 || $('hdnWorkflowStageID').value == 5) { setControlValue('Retail12', arr[3], false, true) };
					if ($('Retail13').value.length == 0 || $('hdnWorkflowStageID').value == 5) { setControlValue('Retail13', arr[3], false, true) };
					
					if ($('RDPuertoRico').value.length == 0 || $('hdnWorkflowStageID').value == 5) { setControlValue('RDPuertoRico', arr[3], false, true) };
					//setControlValue('Retail9', arr[3], skipHighlight);
					//setControlValue('Retail10', arr[3], skipHighlight);
					//setControlValue('Retail11', arr[3], skipHighlight);
					//setControlValue('Retail12', arr[3], skipHighlight);
					//setControlValue('Retail13', arr[3], skipHighlight);
					//calculateGMPercent();
				}
				else {alert("ERROR: There was a problem with Base Retail!");}
			} 
			else if(arr[0] == "RetailAlaska")
			{
				if(arr[1] == "1" && arr.length >= 3)
				{
					setControlValue('RDAlaska', arr[2], false, true);
					//lp need a change here?
					//calculateGMPercent();
				}
				else {alert("ERROR: There was a problem with Alaska Retail!");}
			} 
			else if(arr[0] == "RetailCanada")
			{
				if(arr[1] == "1" && arr.length >= 3)
				{
				    setControlValue('RDCanada', arr[2], false, true);
				    if (($('RDQuebec').value.length == 0) || ($('hdnWorkflowStageID').value == 5)) { setControlValue('RDQuebec', arr[2], false, true) };
				}
				else {alert("ERROR: There was a problem with Canada Retail!");}
			} 
			else if(arr[0] == "CountryOfOrigin")
			{
				if(arr[1] == "1" && arr.length >= 4)
				{
				    if (arr[2] != '' && arr[3] != ''){
					    setControlValue('CountryOfOriginName', arr[2], false, true);
					    $('CountryOfOrigin').value = arr[3];
					} else {
					    $('CountryOfOrigin').value = '';
					}
				}
				else {alert("ERROR: There was a problem with Country of Origin!");}
			} 
			else if(arr[0] == "DELETEIMAGE")
			{
				if(arr[1] == "1" && arr.length >= 3)
				{
					clearImage();
				}
				else {alert("ERROR: There was a problem deleting the Item Image!");}
			} 
			else if(arr[0] == "DELETEMSDS")
			{
				if(arr[1] == "1" && arr.length >= 3)
				{
					clearMSDS();
				}
				else {alert("ERROR: There was a problem deleting the Item MSDS Sheet!");}
			} 
			else if(arr[0] == "LikeItemSKU")
			{
				if(arr[1] == "1" && arr.length >= 5)
				{
					var item = arr[2];
					var itemDesc = arr[3];
					var baseRetail = arr[4];
					setControlValue('likeItemDescription', itemDesc, elementTextEquals('likeItemDescription', itemDesc));
					setControlValue('likeItemRetail', baseRetail, elementTextEquals('likeItemRetail', baseRetail));
					if(itemDesc == '' && baseRetail == '')
					    alert("Like Item SKU is not a valid SKU in RMS 12.");
				}
				else {alert("ERROR: There was a problem with Like Item SKU!");}
			} 
			else {alert("ERROR: Unknown callback response given!");}
		}
		else {alert("ERROR: Invalid callback response given!");}
	}
}
function PackItemIndicatorChanged() {

    setIsDirty(1);    
    var pii = getValue('PackItemIndicator');
    if(pii == 'C') {
        // show the QtyInPack field
        $('QtyInPackRow').show();
    } else {
        // hide the QtyInPack field
        $('QtyInPack').value = '';
        $('QtyInPackRow').hide();
    }
}


function eachCaseChanged() {
    var he = $('EachHeight'); var wi = $('EachWidth'); var le = $('EachLength'); var goValue;
    if (he && wi && le) {
        if (he.value != "" && wi.value != "" && le.value != "") {
            // send data for calculation
            goValue = "ECPC" + callbackSep + he.value + callbackSep + wi.value + callbackSep + le.value + callbackSep + "";
            CallServer(goValue, "");
        } else { if ($('CubicFeetPerEach') && $('CubicFeetPerEachEdit')) { $('CubicFeetPerEach').value = ''; $('CubicFeetPerEachEdit').value = ''; } }
    }
}
function innerCaseChanged()
{
    var he = $('ReshippableInnerCartonHeight'); var wi = $('ReshippableInnerCartonWidth'); var le = $('ReshippableInnerCartonLength'); var goValue;
    if(he&&wi&&le) {
        if(he.value != "" && wi.value != "" && le.value != "") {
            // send data for calculation
            goValue = "ICPC" + callbackSep + he.value + callbackSep + wi.value + callbackSep + le.value + callbackSep + "";
		    CallServer(goValue, "");
        } else { if($('CubicFeetPerInnerCarton') && $('CubicFeetPerInnerCartonEdit')) { $('CubicFeetPerInnerCarton').value = ''; $('CubicFeetPerInnerCartonEdit').value = ''; }}
    }
}
function calculateOceanFreight()
{
    var emc = $('EachInsideMasterCaseBox'); var cf = $('CubicFeetPerMasterCarton'); var oceanf = $('OceanFreightAmount');
    var goValue;
    if(emc && cf && oceanf) {
        if(emc.value != "" && cf.value != "" && oceanf.value != "" ) {
            // send data for calculation
            goValue = "CALC_OceanFreight" + callbackSep + emc.value + callbackSep + cf.value + callbackSep + oceanf.value;
		    CallServer(goValue, "");
        }
        else {
            if($('OceanFreightComputedAmount') && $('OceanFreightComputedAmountEdit'))
            {
                $('OceanFreightComputedAmount').value = '';
                $('OceanFreightComputedAmountEdit').value = '';
            }
        }
    } 
}
function calculateEstLandedCost(fromField)
{
    if(fromField == null) fromField = '';
    var agent = $('Agent');
    var dispcost = $('DisplayerCost');
    var prodcost = $('ProductCost');
    var fob = $('FOBShippingPoint');
    var dutyper = $('DutyPercent');
    var addduty = $('AdditionalDutyAmount');
    var supptariffper = $('SuppTariffPercent');
    var eachesmc = $('EachInsideMasterCaseBox');
    var mclength = $('MasterCartonDimensionsLength');
    var mcwidth = $('MasterCartonDimensionsWidth');
    var mcheight = $('MasterCartonDimensionsHeight');
    var cubicftpermc = $('CubicFeetPerMasterCarton');
    var oceanfre = $('OceanFreightAmount');
    var oceanamt = $('OceanFreightComputedAmount');
    var agentcommper = $('AgentCommissionPercent');
    var otherimportper = $('OtherImportCostsPercent');
    var packcost = $('PackagingCostAmount');
    var goValue;
    if (agent && dispcost && prodcost && fob && dutyper && addduty && supptariffper && eachesmc && mclength && mcwidth && mcheight && cubicftpermc && oceanfre && oceanamt && agentcommper && otherimportper && packcost) {
        // send data for calculation
        goValue = formatCalcXML(agent.options[agent.selectedIndex].value, dispcost.value, prodcost.value, fob.value, dutyper.value, addduty.value, supptariffper.value, eachesmc.value, mclength.value, mcwidth.value, mcheight.value, cubicftpermc.value, oceanfre.value, oceanamt.value, agentcommper.value, otherimportper.value, packcost.value);
        goValue = "CALC_EstLandedCost" + callbackSep + fromField + callbackSep + goValue;
        CallServer(goValue, "");
    } else {
    //    alert('Error getting values for Estimated Landed Cost calculation!');
    }
}
function formatCalcXML(agent, dispcost, prodcost, fob, dutyper, addduty, supptariffper, eachesmc, mclength, mcwidth, mcheight, cubicftpermc, oceanfre, oceanamt, agentcommper, otherimportper, packcost)
{
    var xml = '' + 
    '<?xml version="1.0" encoding="utf-8" ?>' +
    '<calcdata>' +
	'    <agent>![CDATA[' + agent + ']]</agent>' +
	'    <dispcost>![CDATA[' + dispcost + ']]</dispcost>' +
	'    <prodcost>![CDATA[' + prodcost + ']]</prodcost>' +
	'    <fob>![CDATA[' + fob + ']]</fob>' +
	'    <dutyper>![CDATA[' + dutyper + ']]</dutyper>' +
	'    <addduty>![CDATA[' + addduty + ']]</addduty>' +
    '    <supptariffper>![CDATA[' + supptariffper + ']]</supptariffper>' +
    '    <eachesmc>![CDATA[' + eachesmc + ']]</eachesmc>' +
    '    <mclength>![CDATA[' + mclength + ']]</mclength>' +
    '    <mcwidth>![CDATA[' + mcwidth + ']]</mcwidth>' +
    '    <mcheight>![CDATA[' + mcheight + ']]</mcheight>' +
    '    <cubicftpermc calc="' + ((isCubicFeetPerMasterCartonCalculated()) ? '1' : '0') + '">![CDATA[' + cubicftpermc + ']]</cubicftpermc>' +
    '    <oceanfre>![CDATA[' + oceanfre + ']]</oceanfre>' +
    '    <oceanamt>![CDATA[' + oceanamt + ']]</oceanamt>' +
	'    <agentcommper>![CDATA[' + agentcommper + ']]</agentcommper>' +
	'    <otherimportper>![CDATA[' + otherimportper + ']]</otherimportper>' +
	'    <packcost>![CDATA[' + packcost + ']]</packcost>' +
    '</calcdata>'
    return xml;
}
function leadTimeChanged()
{
    var lt = $('LeadTime'); var goValue;
    if(lt) {
        // send data for calculation
        goValue = "ConversionDate" + callbackSep + lt.value;
        CallServer(goValue, "");
    }
}
//lp SPEDY Order 12
function CalculateTotalRetail()
{
    if ($('RDBASE') != null) {
        var baseItemRetail = $('RDBASE').value;
        var tempHolder = 0;
        //var AnnualRegularUnitForecast = $('AnnualRegularUnitForecast').value;
        var AnnualRegularUnitForecast = $('AnnualRegularUnitForecast').value;
        if (isNum(baseItemRetail) && isNum(AnnualRegularUnitForecast))
            {
            tempHolder =(baseItemRetail*1) * (AnnualRegularUnitForecast*1)
            tempHolder = Math.round(tempHolder*Math.pow(10,2))/Math.pow(10,2);
            $('AnnualRegRetailSalesEdit').value = tempHolder;
            $('AnnualRegRetailSales').value = $('AnnualRegRetailSalesEdit').value;
            }
    }
}
function CalculateUnitStoreMonth()
{
    var storeTotals = $('storeTotal').value;
    var AnnualRegularUnitForecast = $('AnnualRegularUnitForecast').value;
    var baseItemRetail = $('RDBASE').value;
    var tempHolder = 0;
    if(isNum(storeTotals) && isNum(AnnualRegularUnitForecast) && (storeTotals !='0'))
        {
        $('calculatedAnnualRegularUnitForecast').value = AnnualRegularUnitForecast;
        tempHolder =  AnnualRegularUnitForecast / storeTotals / 13;
        // now round the temHolder
        tempHolder = Math.round(tempHolder*Math.pow(10,2))/Math.pow(10,2);
        //$('calculatedLikeItemUnitStoreMonthEdit').value = AnnualRegularUnitForecast / storeTotals / 13;
        $('calculatedLikeItemUnitStoreMonthEdit').value = tempHolder;
        $('calculatedLikeItemUnitStoreMonth').value = $('calculatedLikeItemUnitStoreMonthEdit').value;
        if(isNum(baseItemRetail))
            {
            tempHolder = (baseItemRetail*1) * (AnnualRegularUnitForecast*1);
            tempHolder = Math.round(tempHolder*Math.pow(10,2))/Math.pow(10,2);
            $('AnnualRegRetailSalesEdit').value = tempHolder;//(baseItemRetail*1) * (AnnualRegularUnitForecast*1);
            $('AnnualRegRetailSales').value = $('AnnualRegRetailSalesEdit').value;
            }
        }
    else 
        {
         $('calculatedLikeItemUnitStoreMonthEdit').value ='0';
         $('calculatedLikeItemUnitStoreMonth').value = '0';
         $('AnnualRegRetailSalesEdit').value = '0';
         $('AnnualRegRetailSales').value = '0';
        }    
}
function CalculateRegularForecast()
{
    var storeTotals = $('storeTotal').value;
    var unitStoreMonth =  $('calculatedLikeItemUnitStoreMonthEdit').value;
    var baseItemRetail = $('RDBASE').value;
    var tempHolder = 0;
    if(isNum(storeTotals) && isNum(unitStoreMonth))
        {
        $('calculatedLikeItemUnitStoreMonth').value = unitStoreMonth;
        tempHolder = storeTotals * unitStoreMonth * 13;
        //now, round to the whole number!
        tempHolder = Math.round(tempHolder*Math.pow(10,0))/Math.pow(10,0);
        $('AnnualRegularUnitForecast').value = tempHolder; //storeTotals * unitStoreMonth * 13;
        $('calculatedAnnualRegularUnitForecast').value = $('AnnualRegularUnitForecast').value;
        if(isNum(baseItemRetail))
            {
            tempHolder =(baseItemRetail*1) * $('calculatedAnnualRegularUnitForecast').value;
            tempHolder = Math.round(tempHolder*Math.pow(10,2))/Math.pow(10,2);
            $('AnnualRegRetailSalesEdit').value = tempHolder;//(baseItemRetail*1) * $('calculatedAnnualRegularUnitForecast').value;
            $('AnnualRegRetailSales').value = $('AnnualRegRetailSalesEdit').value;
            }
        }
    else 
        {
        $('AnnualRegularUnitForecast').value = '0';
        $('calculatedAnnualRegularUnitForecast').value = '0';
        $('AnnualRegRetailSalesEdit').value = '0';
        $('AnnualRegRetailSales').value = '0';
        }      
}  
function StoreTotalChanged()
{
    var calcOption = $('CalculateOptions').value;
    var storeTotals = $('storeTotal').value;
    if(isNum(storeTotals) && storeTotals != '0')
        {
        if (calcOption == '1')
            {
            CalculateUnitStoreMonth();
            }
        else if (calcOption == '2')
            {
            CalculateRegularForecast();
            }   
        }
}  
function CalculateOptionsChanged()
{
    if ($('CalculateOptions')) {
        var calcOption = $('CalculateOptions').value;
        //alert($('CalculateOptions').value);
        if (calcOption == '0')
            {
            //$('AnnualRegularUnitForecast').readOnly = true;
            $('AnnualRegularUnitForecast').disabled = true;
            $('AnnualRegularUnitForecast').style.cssText = "background:  #eee8aa;";
            //$('calculatedLikeItemUnitStoreMonthEdit').readOnly = true;
            $('calculatedLikeItemUnitStoreMonthEdit').disabled = true;
            $('calculatedLikeItemUnitStoreMonthEdit').style.cssText = "background:  #eee8aa;";
            }
        else if (calcOption == '1') 
            {
            $('AnnualRegularUnitForecast').disabled = false;//true;
            $('AnnualRegularUnitForecast').style.cssText = "background:  #fff;";
            $('calculatedLikeItemUnitStoreMonthEdit').disabled = true;
            $('calculatedLikeItemUnitStoreMonthEdit').style.cssText = "background:  #eee8aa;";
            }
        else if  (calcOption == '2')
            {
            
            //document.getElementById('AnnualRegularUnitForecast').readOnly = true;
            $('AnnualRegularUnitForecast').disabled = true;
            $('AnnualRegularUnitForecast').style.cssText = "background:  #eee8aa;"; 
             $('calculatedLikeItemUnitStoreMonthEdit').disabled = false;
            $('calculatedLikeItemUnitStoreMonthEdit').style.cssText = "background: #fff;";
           
            }   
    }
}

function baseRetailChanged(fromField) {

    setIsDirty(1);
    if(fromField == null) fromField = '';
    var pp = $('PrePriced'); var br = $('RDBase'); var ar = $('RDAlaska'); var cr = $('RDCanada'); var goValue;
    if(pp && br && ar) {
        // send data
        goValue = "Retail" + callbackSep + fromField + callbackSep + pp.options[pp.selectedIndex].value + callbackSep + br.value + callbackSep + ar.value + callbackSep + cr.value;
	    CallServer(goValue, "");
    }
}
function alaskaRetailChanged()
{
    var ar = $('RDAlaska'); var goValue;
    if(ar) {
        // send data
        goValue = "RetailAlaska" + callbackSep + ar.value;
	    CallServer(goValue, "");
	    //LP Change here change order 14
	    calculateIMUPercent('RDAlaska');
    }
}
function canadaRetailChanged()
{
    var cr = $('RDCanada'); var goValue;
    if(cr) {
        // send data
        goValue = "RetailCanada" + callbackSep + cr.value;
        CallServer(goValue, "");
        //LP Change here change order 14
        calculateIMUPercent('RDCanada');
    }
}
function taxUDAChanged()
{
    var o = $('TaxUDA');
    $('TaxUDAValue').value = o.options[o.selectedIndex].value;
    return true;
}
function taxValueUDAChanged()
{
    var o = $('TaxValueUDA');
    $('TaxValueUDAValue').value = o.value;
    return true;
}
function countryOfOriginChanged()
{
    var coo = $('CountryOfOriginName'); var goValue;
    if(coo) {
        // send data
        goValue = "CountryOfOrigin" + callbackSep + coo.value;
	    CallServer(goValue, "");
    }
}
function likeItemSKUChanged()
{
    var sku = $('likeItemSKU'); var goValue;
    if(sku) {
        // send data for calculation
        goValue = "LikeItemSKU" + callbackSep + sku.value;
        CallServer(goValue, "");
          }
}
function cubicFeetPerMasterCartonChanged()
{
    var objE = $('CubicFeetPerMasterCartonEdit');
    var obj = $('CubicFeetPerMasterCarton');
    if(objE && obj)
    {
        obj.value = objE.value;
    }
    calculateEstLandedCost('cubicftpermc');
}
/*
function vendorUPCChanged()
{
    var vupc = $('vendorUPC');
    var val;
    if(vupc && vupc != null) {
        val = vupc.value;
        if( val != '' && isInteger(val) && isGreaterThanZero(val)) {
            while (val.length < 14) {
                val = "0" + val;
            }
            vupc.value = val;
        }
    }
}
*/
//LP Change Order 14
//this function below recalc IMU % for individ price zones
function calculateIMUPercent(controlName) {
    var gmval = '';
    var ts = $('TotalStoreLandedCost'), tsval;
    var br = $(controlName), brval;
    if (ts && br) {
        if(ts.value != '' && isNum(ts.value) && br.value != '' && isNum(br.value)) {
            tsval = convertToNumber(ts.value);
            brval = convertToNumber(br.value);
            if (brval != 0){
                gmval = ((brval - tsval) / brval) * 100;
                gmval = gmval.toFixed(2) + "%";
            } else {
                gmval = '';
            }
        } else {
            gmval = '';
        }
    } else {
        gmval = '';
    }
   $(controlName + 'GM').innerText = gmval;  

} 
function calculateGMPercent(skipHighlight)
{
    if(!skipHighlight || skipHighlight == null)skipHighlight = false;
    var ts = $('TotalStoreLandedCost'), tsval;
    var pp = $('PrePriced');
    if ( pp )   // FJL Make sure object is not hidden
        var ppval = pp.options[pp.selectedIndex].value;
    var br = $('RDBase'), brval;
    var ar = $('RDAlaska'), arval;
    var gmval = ''; 
    var gmval2 = '';
    if(ts && pp && br && ar) {
        if(ts.value != '' && isNum(ts.value) && br.value != '' && isNum(br.value)){
            tsval = convertToNumber(ts.value);
            brval = convertToNumber(br.value);
            if (brval != 0){
                gmval = ((brval - tsval) / brval) * 100;
                gmval = gmval.toFixed(2) + "%";
            } else {
                gmval = '';
            }
        }else{
            gmval = '';
        }
        
        if(ts.value != '' && isNum(ts.value) && ar.value != '' && isNum(ar.value)){
            tsval = convertToNumber(ts.value);
            arval = convertToNumber(ar.value);
            if (arval != 0){
                gmval2 = ((arval - tsval) / arval) * 100;
                gmval2 = gmval2.toFixed(2) + "%";
            } else {
                gmval2 = '';
            }
        }else{
            gmval2 = '';
        }
        
        $('RDBaseGM').innerText = gmval;
        $('RDAlaskaGM').innerText = gmval2;
        
        //change order 14
        if(gmval != '' && skipHighlight != true){
            highlightControls2('RDBaseGM');
            highlightControls2('RDCentralGM');
            highlightControls2('RDTestGM');
            highlightControls2('RDAlaskaGM');
            highlightControls2('RD0Thru9GM');
            highlightControls2('RDCaliforniaGM');
            highlightControls2('RDVillageCraftGM');
            //change order 14
            highlightControls2('Retail9GM');
            highlightControls2('Retail10GM');
            highlightControls2('Retail11GM');
            highlightControls2('Retail12GM');
            highlightControls2('Retail13GM');
            highlightControls2('RDQuebecGM');
            highlightControls2('RDPuertoRicoGM');
            highlightControls2('RDCanadaGM');
        }
    }
}

// DUPLICATE ITEM
// --------------
var dupitemdrag = null;
var dupitemid = '0';
function showDuplicateItem()
{
    if(dupitemid != '0')
        duplicateClose();
    var o = $('dupItem');
    var ctl = $('btnDuplicate');
    if(o && ctl) {
        // set the id
        dupitemid = $('hid').value;
        // set the control
        $('dupItemID').value = dupitemid;
        $('dupItemHowMany').value = "";
        $('dupItemRegular').checked = false;
        
        // position the div
		if(ctl != undefined && ctl != null)
		{
			var newXPos = Element.positionedOffset(ctl).left + (ctl.offsetWidth) - 250;
			if(newXPos < 0)
			    newXPos = 0;
			var newYPos = Element.positionedOffset(ctl).top + ctl.offsetHeight;
			
			o.style.left = newXPos;
			o.style.top = newYPos - 4;
		}
        // show the div
        Element.show(o);
        // setup the draggable
        dupitemdrag = new Draggable('dupItem');// , {handle:'dupItemHeader'});
    }
}

function duplicateClose()
{
    var o = $('dupItem')
    if(o) {
        // clear the control
        $('dupItemHowMany').value = "";
        $('dupItemRegular').checked = false;
        // hide the div
        Element.hide(o);
        // clear the draggable
        if(dupitemdrag != null) {
            dupitemdrag.destroy();
            dupitemdrag = null;
        }
    }
    // clear the id
    dupitemid = '0';
}
//LP Spedy Order 12 change
function splitItemClick()
{
    if (confirm('Are you sure you want to move current item to a new batch?'))
         {
            __doPostBack('btnSplit','');
            //alert('The current item was moved to a new batch successfully');
         }   
        else
        {
        //do nothing    
        }
}
//LP
function duplicateSave()
{
    var cid = $('dupItemID').value;
    var howmany = $('dupItemHowMany').value;
    //var reg = $('dupItemRegular').checked;
    
    if (isNum(howmany) && parseInt(howmany) > 0 && parseInt(howmany) <= 99)
        __doPostBack('btnDuplicate', '');
    else
        alert('Please enter a valid integer value for How Many duplicates you wish to create?');
}
//LP
//LP SPEDY order 12, only allow to key in numbers(0-9), backspace-8, tab-9,delete-46, left-37,right-39 arows,numeric keys
function SetInteger(e)
{
var keychar, keycode;
keycode = e.keyCode;
keychar = String.fromCharCode(keycode);
if ((keycode == 8) || (keycode == 9) || (keycode == 46) || (keycode==37) || (keycode == 39)|| (keycode > 95 && keycode <106)) {
    return true;
 }else {
    if (isInteger(keychar))
        return true;
    else
        return false;
     }   
}
function isInteger(s){
    var i;
    for (i = 0; i < s.length; i++) {
        // Check that current character is number.
        var c = s.charAt(i);
        if (((c < "0") || (c > "9"))) 
            return false;
    }
    // All characters are numbers.
    return true;
}
// ADD TO BATCH
// ------------
var atbdrag = null;
var atbid = '0';
function showAddToBatch()
{
    if(atbid != '0')
        addToBatchClose();
    var o = $('addToBatch');
    var ctl = $('btnAddToBatch');
    if(o && ctl) {
        // set the id
        atbid = $('hid').value;
        // set the control
        $('addToBatchID').value = atbid;
        $('addToBatchList').selectedIndex = 0;
        
        if($('addToBatchList').options.length < 1){
            Element.hide($('addToBatchListRow'));
            Element.show($('addToBatchMessageRow'));
            Element.show($('addToBatchBlankRow'));
            Element.hide($('addToBatchSelectRow'));
            $('btnAddToBatchSave').disabled = true;
        }else{
            Element.hide($('addToBatchMessageRow'));
            Element.show($('addToBatchListRow'));
            Element.hide($('addToBatchBlankRow'));
            Element.show($('addToBatchSelectRow'));
        }
        
        // position the div
		if(ctl != undefined && ctl != null)
		{
			var newXPos = Element.positionedOffset(ctl).left + (ctl.offsetWidth) - 250;
			if(newXPos < 0)
			    newXPos = 0;
			var newYPos = Element.positionedOffset(ctl).top + ctl.offsetHeight;
			
			o.style.left = newXPos;
			o.style.top = newYPos - 4;
		}
        // show the div
        Element.show(o);
        // setup the draggable
        atbdrag = new Draggable('addToBatch');// , {handle:'dupItemHeader'});
    }
}

function addToBatchClose()
{
    var o = $('addToBatch')
    if(o) {
        // clear the control
        $('addToBatchList').selectedIndex = 0;
        // hide the div
        Element.hide(o);
        // clear the draggable
        if(atbdrag != null) {
            atbdrag.destroy();
            atbdrag = null;
        }
    }
    // clear the id
    atbid = '0';
}

function addToBatchSave()
{
    var cid = $('addToBatchID').value;
    var oBatch = $('addToBatchList');
    //var reg = $('dupItemRegular').checked;
    
    if (oBatch && oBatch.selectedIndex > 0){
        if(confirm('Are you sure you want to add the item(s) from the other batch to the current batch?')){
            __doPostBack('btnAddToBatch', '');
        }
    } else {
        alert('Please select a batch to add to this batch.');
    }
}

function elementTextEquals(elementid, value)
{
    if ($(elementid)){
        if ($(elementid).innerText == value)
            return true;
        else
            return false;
    } else {
        return false;
    }
}

function setIsDirty(dirty, ctrl) {
    $('dirtyFlag').value = dirty;

    switch (ctrl) {
        case "PLIEnglish":
            $('PLIEnglish_Dirty').value = 1;
            break;
        case "PLIFrench":
            $('PLIFrench_Dirty').value = 1;
            break;
        case "PLISpanish":
            $('PLISpanish_Dirty').value = 1;
            break;
    }
}

//StockStratHelper
var StockStratHelperdrag = null;

function showStockStratHelper() {

    var o = $('StockStratHelper');
    var ctl = $('btnStockStratHelper');
    if (o && ctl) {

        // position the div
        if (ctl != undefined && ctl != null) {
            var newXPos = Element.positionedOffset(ctl).left + (ctl.offsetWidth) - 250;
            if (newXPos < 0)
                newXPos = 0;
            var newYPos = Element.positionedOffset(ctl).top + ctl.offsetHeight;

            o.style.left = newXPos;
            o.style.top = newYPos - 4;
        }
        // show the div
        Element.show(o);
        // setup the draggable
        //StockStratHelperdrag = new Draggable('StockStratHelper');
    }
}


function StockStratHelperClose() {
    var o = $('StockStratHelper')
    if (o) {
        // clear the controls
        document.getElementById("LstBoxStockingStrategies").options.length = 0;

        document.getElementById("lblStockStratMsg").innerHTML = "";

        var strID = "";
        var inputs = document.getElementsByTagName("input");
        for (var i = 0; i < inputs.length; i++) {
            if (inputs[i].type == "checkbox") {
                strID = inputs[i].id;
                if (strID.startsWith("chkLstWarehouses")) {
                    inputs[i].checked = false;
                } 
            }
        }

        // hide the div
        Element.hide(o);
        // clear the draggable
        //if (StockStratHelperdrag != null) {
        //    StockStratHelperdrag.destroy();
        //    StockStratHelperdrag = null;
        //}
    }

}

function StockStratHelperSave() {

    var select = document.getElementById("LstBoxStockingStrategies");
    var element = document.getElementById("StockingStrategyCode");

    //set the page's stocking strategy dropdown
    if (select.selectedIndex >= 0) {
        var myvalue = select.options[select.selectedIndex].value;
        element.value = myvalue;
    }
    else {
        element.value = "";
    }

    //close the form
    StockStratHelperClose();
}