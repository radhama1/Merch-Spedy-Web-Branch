
function initPageOnLoad()
{   // FJL Dec 2009: check if Parent line of Country of Orgin exists before setting the auto-complete
    if ( $('countryOfOriginParent') )
    {
        new Ajax.Autocompleter("countryOfOriginName", "countryOfOriginName_choices", "lookupcountry.aspx", {
          paramName: "value", 
          minChars: 1,
          afterUpdateElement: countryOfOriginChanged
        } );
    }
    setIsDirty(0);
}

function confirmDelete(msg) {
    var isConfirm = confirm(msg);
    if (isConfirm) {
        window.parent.opener.reloadPage();
    }
    return confirm;
}


function closeDetailForm()
{
    window.close();
}

function VerifyUpdatePBLforBatch() {
    var ret = false;
    var ret = confirm('Please Verify you want ALL ITEMS in the Batch to use this selected Private Brand Label.');
    if (ret == false)
        return; 
    var obj = $('hdnPBLApplyAll');
    obj.value = "1";            // set flag to apply all instead of normal save.
    var cmd = $('btnUpdate');   // use the update button click event to post action.
    cmd.click();
}

function addAdditionalUPC()
{
    var oCount = $('additionalUPCCount');
    var cntval, cnt, newUPCControl;
    if(oCount){
        cntval = oCount.value;
        if (isInteger(cntval)){
            cnt = parseInt(cntval);
            cnt += 1;
            oCount.value = cnt.toString();
            newUPCControl = '<input type="text" id="additionalUPC' + cnt.toString() + '" maxlength="20" value="" onchange="additionalUPCChanged(' + cnt.toString() + ');" /><sup>' + cnt.toString() + '</sup>';
            $('additionalUPCs').innerHTML += ("<br />" + newUPCControl);
        }
    }
}

function saveAdditionalUPCValues()
{
    var o, oID, oCount = $('additionalUPCCount');
    var iCount = 1;
    if(oCount && isInteger(oCount.value)) iCount = parseInt(oCount.value);
    var i, val = '';
    for(i = 1; i <= iCount; i++){
        oID = 'additionalUPC' + i.toString();
        o = $(oID);
        if(o){
            if(val != '') val += ",";
            val += o.value;
        }
    }
    // save the values (val,val,...)
    $('additionalUPCValues').value = val;
}

var callbackSep = "{{|}}";

function updateImage(id, newid)
{
    var i = $('I_Image');
    if(i){
        var isrc = i.src;
        if (newid != null && isNum(newid)) {
            i.src = 'images/app_icons/icon_jpg_small_on.gif?id=' + newid;
            if($('ImageID')) $('ImageID').value = newid;
            if($('B_UpdateImage')) $('B_UpdateImage').value = 'Update';
            if($('I_Image_Label')) $('I_Image_Label').innerText = '(view)';
            Element.writeAttribute($('B_DeleteImage'), "disabled", "");
        }
    }
}

function updateMSDS(id, newid)
{
    var i = $('I_MSDS');
    if(i){
        var isrc = i.src;
        if (newid != null && isNum(newid)) {
            i.src = 'images/app_icons/icon_pdf_small.gif?id=' + newid;
            if($('MSDSID')) $('MSDSID').value = newid;
            if($('B_UpdateMSDS')) $('B_UpdateMSDS').value = 'Update';
            if($('I_MSDS_Label')) $('I_MSDS_Label').innerText = '(view)';
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
        var i = window.open(url, "itemimg", "directories=no,height=600,width=955,menubar=no,resizable=yes,scrollbars=yes,status=no,titlebar=no,toolbar=no", true);
        i.focus();
    }else{
        if(!($('B_UpdateImage')) || $('B_UpdateImage').disabled == true) return false;
        //var cmd = Element.readAttribute('B_UpdateImage', 'onclick');
        var cmd = getElementAttribute($('B_UpdateImage'), 'onclick');
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
        //var cmd = Element.readAttribute('B_UpdateMSDS', 'onclick');
        var cmd = getElementAttribute($('B_UpdateMSDS'), 'onclick');
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
        //Element.writeAttribute(i, "width", "16");
        //Element.setStyle(i, { width: '16px' });
        i.src = 'images/app_icons/icon_jpg_small.gif';
        if($('ImageID')) $('ImageID').value = '';
        if($('B_UpdateImage')) $('B_UpdateImage').value = 'Upload';
        if($('I_Image_Label')) $('I_Image_Label').innerText = '(upload)';
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
        //Element.writeAttribute(i, "width", "16");
        //Element.setStyle(i, { width: '16px' });
        i.src = 'images/app_icons/icon_pdf_small_off.gif';
        if($('MSDSID')) $('MSDSID').value = '';
        if($('B_UpdateMSDS')) $('B_UpdateMSDS').value = 'Upload';
        if($('I_MSDS_Label')) $('I_MSDS_Label').innerText = '(upload)';
        Element.writeAttribute($('B_DeleteMSDS'), "disabled", "disabled");
    }
}
function SetHiddenFieldValue(controlName) {
    $(controlName).value = $(controlName + 'Edit').value;
    //alert($(controlName + 'Edit').value);
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

		    if (arr[0] == "ECPC") {
		        if (arr[1] == "1" && arr.length >= 3) {
		            //alert("SUCCESS !");
		            setControlValue('eachCasePackCube', arr[2]);
		        }
		        else { alert("ERROR: There was a problem calculating the Each Case Pack Cube!"); }
		    }

			else if(arr[0] == "ICPC")
			{
				if(arr[1] == "1" && arr.length >= 3)
				{
					//alert("SUCCESS !");
					setControlValue('innerCasePackCube', arr[2]);
				}
				else {alert("ERROR: There was a problem calculating the Inner Case Pack Cube!");}
			} 
			
			else if(arr[0] == "MCPC")
			{
			    if(arr[1] == "1" && arr.length >= 3)
				{
					//alert("SUCCESS !");
					setControlValue('masterCasePackCube', arr[2]);
                    
				}
				else {alert("ERROR: There was a problem calculating the Master Case Pack Cube!");}
			}
			else if(arr[0] == "ConversionDate")
			{
				if(arr[1] == "1" && arr.length >= 3)
				{
					setControlValue('hybridConversionDate', arr[2]);
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
				        if($('baseRetail') && $('centralRetail') && $('testRetail')){
				            if($('baseRetail').value != $('centralRetail').value || $('baseRetail').value != $('testRetail').value)
				                skipHighlight = false;
				            else
				                skipHighlight = true;
				        }else{
				            skipHighlight = true;
				        }
				    }
					setControlValue('baseRetail', arr[3], true, true);
					if ($('centralRetail').value.length == 0 || $('hdnWorkflowStageID').value == 5) { setControlValue('centralRetail', arr[3], false, true) };
					if ($('testRetail').value.length == 0 || $('hdnWorkflowStageID').value == 5) { setControlValue('testRetail', arr[3], false, true) };
					if($('alaskaRetail').value != arr[4] && $('baseRetail').value !=''){
					    setControlValue('alaskaRetail', arr[4], false, true);
					}
					if ($('canadaRetail').value != arr[5] && $('baseRetail').value != '' && isNum(arr[5])) {
					    setControlValue('canadaRetail', arr[5], false, true);
					    setControlValue('RDQuebec', arr[5], false, true);

					    if ($('canadaRetail') || $('canadaRetailEdit')) {
					        if ($('canadaRetail')) {
					            if($('canadaRetail').previous('.renderReadOnly'))
					                $('canadaRetail').previous().innerText = arr[5];
					        }
					        if ($('canadaRetailEdit')) {
					            if ($('canadaRetailEdit').previous('.renderReadOnly'))
					                $('canadaRetailEdit').previous().innerText = arr[5];
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
					if ($('zeroNineRetail').value.length == 0 || $('hdnWorkflowStageID').value == 5) { setControlValue('zeroNineRetail', arr[3], false, true) };
					if ($('californiaRetail').value.length == 0 || $('hdnWorkflowStageID').value == 5) { setControlValue('californiaRetail', arr[3], false, true) };
					if ($('villageCraftRetail').value.length == 0 || $('hdnWorkflowStageID').value == 5) { setControlValue('villageCraftRetail', arr[3], false, true) };
					//lp change order 14 change zone prices only if the fields are empty, per Tom
					if ($('Retail9').value.length == 0 || $('hdnWorkflowStageID').value == 5) { setControlValue('Retail9', arr[3], false, true) };
					if ($('Retail10').value.length == 0 || $('hdnWorkflowStageID').value == 5) { setControlValue('Retail10', arr[3], false, true) };
					if ($('Retail11').value.length == 0 || $('hdnWorkflowStageID').value == 5) { setControlValue('Retail11', arr[3], false, true) };
					if ($('Retail12').value.length == 0 || $('hdnWorkflowStageID').value == 5) { setControlValue('Retail12', arr[3], false, true) };
					if ($('Retail13').value.length == 0 || $('hdnWorkflowStageID').value == 5) { setControlValue('Retail13', arr[3], false, true) };
					if ($('RDPuertoRico').value.length == 0 || $('hdnWorkflowStageID').value == 5) { setControlValue('RDPuertoRico', arr[3], false, true) };
					//calculateGMPercent(); lp -this function does not work here
				}
				else {alert("ERROR: There was a problem with Base Retail!");}
			} 
			else if(arr[0] == "RetailAlaska")
			{
				if(arr[1] == "1" && arr.length >= 3)
				{
					setControlValue('alaskaRetail', arr[2], false, true);
				}
				else {alert("ERROR: There was a problem with Alaska Retail!");}
			} 
			else if(arr[0] == "RetailCanada")
			{
				if(arr[1] == "1" && arr.length >= 3)
				{
				    setControlValue('canadaRetail', arr[2], false, true);
				    if (($('RDQuebec').value.length == 0) || ($('hdnWorkflowStageID').value == 5)) { setControlValue('RDQuebec', arr[2], false, true) };
				}
				else {alert("ERROR: There was a problem with Canada Retail!");}
			} 
			else if(arr[0] == "CountryOfOrigin")
			{
				if(arr[1] == "1" && arr.length >= 4)
				{
				    if (arr[2] != '' && arr[3] != ''){
					    setControlValue('countryOfOriginName', arr[2], false, true);
					    $('countryOfOrigin').value = arr[3];
					} else {
					    $('countryOfOrigin').value = '';
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
			else if(arr[0] == "TotalUSCost")
			{
				if(arr[1] == "1" && arr.length >= 4)
				{
					var uscost = arr[2];
					var tuscost = arr[3];
					setControlValue('USCost', uscost, elementTextEquals('USCost', uscost));
					setControlValue('totalUSCost', tuscost, elementTextEquals('totalUSCost', tuscost));
				}
				else {alert("ERROR: There was a problem with Total US Cost!");}
			} 
			else if(arr[0] == "TotalCanadaCost")
			{
				if(arr[1] == "1" && arr.length >= 4)
				{
					var ccost = arr[2];
					var tccost = arr[3];
					setControlValue('canadaCost', ccost, elementTextEquals('canadaCost', ccost));
					setControlValue('totalCanadaCost', tccost, elementTextEquals('totalCanadaCost', tccost));
				}
				else {alert("ERROR: There was a problem with Total US Cost!");}
			} 
			else if(arr[0] == "TotalCosts")
			{
				if(arr[1] == "1" && arr.length >= 4)
				{
					var tuscost = arr[2];
					var tccost = arr[3];
					setControlValue('totalUSCost', tuscost, elementTextEquals('totalUSCost', tuscost));
					setControlValue('totalCanadaCost', tccost, elementTextEquals('totalCanadaCost', tccost));
				}
				else {alert("ERROR: There was a problem with Total US Cost!");}
			} 
			else {alert("ERROR: Unknown callback response given!");}
		}
		else {alert("ERROR: Invalid callback response given!");}
	}
}

function refreshItemGrid()
{
    window.parent.opener.reloadPage();
}

function openTaxWizard(id)
{
    var url = 'Tax_Wizard.aspx?type=D&id=' + id;
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
    var o = $('taxUDA')
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
    if($('taxUDALabel')) $('taxUDALabel').innerText = text;
    $('taxUDAValue').value = val;
}

function packItemIndicatorChanged() 
{
    setIsDirty(1);
    var pii = getSelectValue('packItemIndicator');
    if(pii == 'C') {
        // show the qtyInPack row
        $('qtyInPackRow').show();
    } else {
        $('qtyInPack').value = '';
        $('qtyInPackRow').hide();
    }
    var uscost = getValue('USCost');
    var ccost = getValue('canadaCost');
    goValue = "PackItemIndicator" + callbackSep + pii + callbackSep + uscost + callbackSep + ccost;
    CallServer(goValue, "");
}
function USCostChanged()
{
    var pii = getSelectValue('packItemIndicator');
    var uscost = getValue('USCost');
    var ccost = getValue('canadaCost');
    goValue = "USCost" + callbackSep + pii + callbackSep + uscost + callbackSep + ccost;
    CallServer(goValue, "");
}
function canadaCostChanged()
{
    var pii = getSelectValue('packItemIndicator');
    var uscost = getValue('USCost');
    var ccost = getValue('canadaCost');
    goValue = "CanadaCost" + callbackSep + pii + callbackSep + uscost + callbackSep + ccost;
    CallServer(goValue, "");
}

function eachCaseChanged() {
    var he = $('eachCaseHeight');
    var wi = $('eachCaseWidth');
    var le = $('eachCaseLength');
    var we = $('eachCaseWeight');
    var goValue;
    if (he && wi && le && we) {
        if (he.value != "" && wi.value != "" && le.value != "") {
            // send data for calculation
            goValue = "ECPC" + callbackSep + he.value + callbackSep + wi.value + callbackSep + le.value + callbackSep + we.value;
            //alert("CallServer: " + goValue);
            CallServer(goValue, "");
        }
        else {
            setControlValue('eachCasePackCube', '');
        }
    }
}

function innerCaseChanged()
{
    var he = $('innerCaseHeight');
    var wi = $('innerCaseWidth');
    var le = $('innerCaseLength');
    var we = $('innerCaseWeight');
    var goValue;
    if(he&&wi&&le&&we) {
        if(he.value != "" && wi.value != "" && le.value != "") {
            // send data for calculation
            goValue = "ICPC" + callbackSep + he.value + callbackSep + wi.value + callbackSep + le.value + callbackSep + we.value;
		    //alert("CallServer: " + goValue);
		    CallServer(goValue, "");
        }
        else {
            setControlValue('innerCasePackCube', '');
        }
    }
}
function masterCaseChanged()
{
    var he = $('masterCaseHeight');
    var wi = $('masterCaseWidth');
    var le = $('masterCaseLength');
    var we = $('masterCaseWeight');
    var goValue;
    if(he&&wi&&le&&we) {
        if(he.value != "" && wi.value != "" && le.value != "" ) {
            // send data for calculation
            goValue = "MCPC" + callbackSep + he.value + callbackSep + wi.value + callbackSep + le.value + callbackSep + we.value;
		    //alert("CallServer: " + goValue);
		    CallServer(goValue, "");
        }
        else {
            setControlValue('masterCasePackCube', '');
        }
    }
}
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
function additionalUPCChanged(upcnum)
{
    var vupc = $('additionalUPC' + upcnum);
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
    saveAdditionalUPCValues();
}

function leadTimeChanged()
{
    var lt = $('hybridLeadTime'); var goValue;
    if(lt) {
        // send data for calculation
        goValue = "ConversionDate" + callbackSep + lt.value;
        CallServer(goValue, "");
    }
}
function baseRetailChanged(fromField)
{
    setIsDirty(1);
    if(fromField == null) fromField = '';
    var pp = $('prePriced'); var br = $('baseRetail'); var ar = $('alaskaRetail'); var cr = $('canadaRetail'); var goValue;
    if(pp && br && ar) {
        // send data
        goValue = "Retail" + callbackSep + fromField + callbackSep + pp.options[pp.selectedIndex].value + callbackSep + br.value + callbackSep + ar.value + callbackSep + cr.value;
	    CallServer(goValue, "");
    }
}
function alaskaRetailChanged()
{
    var ar = $('alaskaRetail'); var goValue;
    if(ar) {
        // send data
        goValue = "RetailAlaska" + callbackSep + ar.value;
	    CallServer(goValue, "");
    }
}
function canadaRetailChanged()
{
    var cr = $('canadaRetail'); var goValue;
    if(cr) {
        // send data
        goValue = "RetailCanada" + callbackSep + cr.value;
	    CallServer(goValue, "");
    }
}
function taxUDAChanged() {
    var o = $('taxUDA');
    $('taxUDAValue').value = o.options[o.selectedIndex].value;
    return true;
}
function taxValueUDAChanged()
{
    var o = $('taxValueUDA');
    $('taxValueUDAValue').value = o.value;
    return true;
}
function hazardousChanged() 
{
    setIsDirty(1);
    var show = true;
    var o = $('hazardous');
    if(o){
        show = ($('hazardous').options[$('hazardous').selectedIndex].value == 'Y') ? true : false;
        showElement('hazardousFlammableRow', show);
        showElement('hazardousContainerTypeRow', show);
        showElement('hazardousContainerSizeRow', show);
        showElement('hazardousMSDSUOMRow', show);
        showElement('hazardousManufacturerNameRow', show);
        showElement('hazardousManufacturerCityRow', show);
        showElement('hazardousManufacturerStateRow', show);
        showElement('hazardousManufacturerPhoneRow', show);
        showElement('hazardousManufacturerCountryRow', show);
    }
}
function countryOfOriginChanged()
{
    var coo = $('countryOfOriginName'); var goValue;
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


// helper functions

function showElement(elementid, show)
{
    if(show) Element.show($(elementid)); else Element.hide($(elementid));
}

function isGreaterThanZero(s){
    var i = parseInt(s);
    if(isNaN(i) || i <= 0)
        return false;
    else
        return true;
}
//LP SPEDY order 12, only allow to key in numbers(0-9), backspace-8, tab-9,delete-46, left-37,right-39 arows
function SetInteger(e)
{
var keychar, keycode;
keycode = e.keyCode;
keychar = String.fromCharCode(keycode);
if ((keycode == 8) || (keycode == 9) || (keycode == 46) || (keycode==37) || (keycode == 39) || (keycode > 95 && keycode <106)) {
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
//lp spedy order 12- new calucaltions
function CalculateUnitStoreMonth()
{
    var storeTotals = $('storeTotal').value;
    var regUnitForecast = $('AnnualRegularUnitForecastEdit').value;
    var baseItemRetail = $('baseRetail').value;
    var tempHolder = 0;
    if(isNum(storeTotals) && isNum(regUnitForecast) && (storeTotals !='0'))
        {
        tempHolder =  regUnitForecast / storeTotals / 13;
        // now round the temHolder
        tempHolder = Math.round(tempHolder*Math.pow(10,2))/Math.pow(10,2);
        //$('LikeItemUnitStoreMonthEdit').value = regUnitForecast / storeTotals / 13;
        $('LikeItemUnitStoreMonthEdit').value = tempHolder;
        $('LikeItemUnitStoreMonth').value = $('LikeItemUnitStoreMonthEdit').value;
        if(isNum(baseItemRetail))
            {
            tempHolder = (baseItemRetail*1) * (regUnitForecast*1);
            tempHolder = Math.round(tempHolder*Math.pow(10,2))/Math.pow(10,2);
            $('AnnualRegRetailSalesEdit').value = tempHolder;//(baseItemRetail*1) * (regUnitForecast*1);
            $('AnnualRegRetailSales').value = $('AnnualRegRetailSalesEdit').value;
            }
        }
    else 
        {
         $('LikeItemUnitStoreMonthEdit').value ='0';
         $('LikeItemUnitStoreMonth').value = '0';
         $('AnnualRegRetailSalesEdit').value = '0';
         $('AnnualRegRetailSales').value = '0';
        }    
}
function CalculateRegularForecast()
{
    var storeTotals = $('storeTotal').value;
    var unitStoreMonth =  $('LikeItemUnitStoreMonthEdit').value;
    var baseItemRetail = $('baseRetail').value;
    var tempHolder = 0;
    if(isNum(storeTotals) && isNum(unitStoreMonth))
        {
        tempHolder = storeTotals * unitStoreMonth * 13;
        //now, round to the whole number!
        tempHolder = Math.round(tempHolder*Math.pow(10,0))/Math.pow(10,0);
        $('AnnualRegularUnitForecastEdit').value = tempHolder; //storeTotals * unitStoreMonth * 13;
        $('AnnualRegularUnitForecast').value = $('AnnualRegularUnitForecastEdit').value;
        if(isNum(baseItemRetail))
            {
            tempHolder =(baseItemRetail*1) * $('AnnualRegularUnitForecast').value;
            tempHolder = Math.round(tempHolder*Math.pow(10,2))/Math.pow(10,2);
            $('AnnualRegRetailSalesEdit').value = tempHolder;//(baseItemRetail*1) * $('calculatedRegUnitForecast').value;
            $('AnnualRegRetailSales').value = $('AnnualRegRetailSalesEdit').value;
            }
        }
    else 
        {
        $('AnnualRegularUnitForecastEdit').value = '0';
        $('AnnualRegularUnitForecast').value = '0';
        $('AnnualRegRetailSalesEdit').value = '0';
        $('AnnualRegRetailSales').value = '0';
        }      
}  
function CalculateTotalRetail()
{
var baseItemRetail = $('baseRetail').value;
var tempHolder = 0;
var regUnitForecast = $('AnnualRegularUnitForecastEdit').value;
if (isNum(baseItemRetail) && isNum(regUnitForecast))
    {
    tempHolder =(baseItemRetail*1) * (regUnitForecast*1)
    tempHolder = Math.round(tempHolder*Math.pow(10,2))/Math.pow(10,2);
    $('AnnualRegRetailSalesEdit').value = tempHolder;
    $('AnnualRegRetailSales').value = $('AnnualRegRetailSalesEdit').value;
    }
}

function getElementAttribute(o, attribute){
    var n =  o.attributes.getNamedItem(attribute);
    if(n) return n.value; else return '';
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

//*********************
//StockStratHelper
//*********************
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