

function initPageOnLoad() {   // FJL Dec 2009: check if Parent line of Country of Orgin exists before setting the auto-complete
    if ( $('CountryOfOriginParent') )
    {
        new Ajax.Autocompleter("CountryOfOriginName", "CountryOfOriginName_choices", "lookupcountry.aspx", {
          paramName: "value", 
          minChars: 1,
          afterUpdateElement: CountryOfOriginChanged
        } );
    }
    //        new Ajax.Autocompleter("additionalCOOName1", "additionalCOO_choices1", "lookupcountry.aspx", {
    var addCtr = $("additionalCOOEnd");
    if (!addCtr) {
        return;
    }
    var cnt = addCtr.value;
    if (isInteger(cnt)) {
        // Add an Autocompleter for each control that is found (may be missing due to revert)
        for (var i = 1; i <= cnt; i++) {
            var ctlName = "AddCountryOfOriginName" + i.toString();
            if ($(ctlName)) {
                new Ajax.Autocompleter(ctlName, "CountryOfOriginName_choices", "lookupcountry.aspx", {
                    paramName: "value",
                    minChars: 1,
                    afterUpdateElement: additionalCOOChanged
                });
            }
        }
    }
}

// create a new AdditionalCOO set when the "+" is clicked
// 3 html elements created  
// - Name field
// - Div tag for lookup results
// - hiddden field for Country short name
// Note that there are two counts one for the control index and one for the number of fields on the screen

function addAdditionalCOO() {
    var oCount = $('additionalCOOCount');
    var oCTLMax = $('additionalCOOEnd');
    var cntval, cnt, maxIDval, maxID;
    if (oCount) {
        if (oCTLMax) {
            cntval = oCount.value;
            maxIDVal = oCTLMax.value;
            if (isInteger(cntval) & isInteger(maxIDVal)) {
                cnt = parseInt(cntval);
                cnt += 1;
                maxID = parseInt(maxIDVal);
                maxID += 1;

                oCount.value = cnt.toString();
                oCTLMax.value = maxID.toString();

                var tbID = 'AddCountryOfOriginName' + maxID.toString();
                var cbID = 'CountryOfOriginName' + maxID.toString();
                var divID = 'CountryOfOriginName_choices';

                var newCOOControl = '<input type="text" id="' + tbID + '" name="' + tbID + '" onchange="checkNewPrimary(' + maxID.toString() + ');" maxlength="50" value="" /><sup>' + cnt.toString() + '</sup>';

                // add the addtional controls to the parent label control
                var tbl = $('additionalCOOTbl')

                if (tbl) {
                    var rowCount = tbl.rows.length;
                    var row = tbl.insertRow(rowCount-1);
                    var cell1 = row.insertCell(0);
                    cell1.style.textAlign = "right"
                    cell1.style.paddingRight = "2px"

                    var chkbox = '<input type="checkbox" id="' + cbID + '" name="' + cbID + '" value="on" onclick="checkNewPrimary();" />'
                    cell1.innerHTML = chkbox;

	                var cell2 = row.insertCell(1);
	                cell2.style.paddingLeft = "2px"
	                cell2.innerHTML = newCOOControl;
	                var obj = $(tbID);
	                if (obj)
	                    obj.focus();

                    // attached the AJAX Autocomplete handdler to it
                    new Ajax.Autocompleter(tbID, divID, "lookupcountry.aspx", {
                        paramName: "value",
                        minChars: 1,
                        afterUpdateElement: additionalCOOChanged
                    });
                    // force autocomplete=on for each control
                    var s = $("additionalCOOStart").value;
                    for (var i = s; i <= maxID; i++) {
                        $("AddCountryOfOriginName" + i.toString()).autocomplete = "on"
                    }
                    //alert (stemp + '\n\nAFTER: \n'+$('additionalCOOs').innerHTML );
                }
            }
        }
    }
}


// this handler is passed the object of the control that is filled in by the autocompleter: additionalCOONameXXX
function additionalCOOChanged(obj, objSourceElement) {
    // debugger;
    // "AddCountryOfOriginName1"
    // CountryOfOriginNameXXXXXX
    // 01234567890123456789012
    // FJL Feb 2010 Nolonger make AJAX call
    var retValue = true;
    if (obj) {
        var objID = new String();
        objID = obj.id;
        if (objID.substr(0, 22) == 'AddCountryOfOriginName') {
            // Make sure the count of this country = 1
            var ctlCtr = $('additionalCOOCount');
            var countryName = obj.value;
            if (countryName.rtrim() == "")
                return retValue;
            var count = 0;
            if (ctlCtr){
                for (var i = 1; i <= ctlCtr.value; i++) {
                    var thisObj = $('AddCountryOfOriginName' + i);
                    if (thisObj && thisObj.value == countryName)
                        count++;
                }
            }
            //CountryOfOriginName and Original if > ''
            ctlCtr = $('CountryOfOriginName')
            if (ctlCtr && ctlCtr.value == countryName)
                count++;

            var msgID = $('CooMsg')
            if (count > 1) {
                if (msgID)
                    msgID.innerHTML = "Duplicate COO's not allowed";

                obj.value = "";
                retValue = false;
            }
            else {
                if (msgID)
                    msgID.innerHTML = "";
                setControlValue(obj.id, obj.value, false, true);
            }
        }
    }
    return retValue;
}    
        //        var strID = new String(obj.id);
        //        var Index = strID.substr(19);    // get the index count for this field
        //        var hidID = "CountryOfOrigin" + Index;
        // send data
        //        var goValue = hidID + callbackSep + obj.value;
        // CallServer is created by the code behind Page.  When the page is returned it calls the function ReceiveServerData()
        //	    CallServer(goValue, "");

function checkNewPrimary(index) {
    // Name: CountryOfOriginName12
    //       012345678901234567
    // check current Textbox if checked then verify associated country as a name in it if so turn off all other cbs
    if (index) {  // if passed in with index its because a country was changed via revert or a quick change
        var obj = $('AddCountryOfOriginName' + index);      // Make sure country is OK before setting value
        if (obj) {
            var OK = additionalCOOChanged(obj, null);
            if (!OK) return;
        }
        var cb = $('CountryOfOriginName' + index);
    }
    else
        var cb = window.event.srcElement;
        
    var msgID = $('CooMsg')
    if (msgID)
        msgID.innerHTML = "";
    if (cb) {   // source element exists
        var id = cb.id;
        var x = id.substr(19);
        var obj = $('AddCountryOfOriginName' + x);
        if (obj)    // found matching country control
            var country = obj.value;
        if (cb.checked && country.length > 0) {   // theres a name in there and the control is checked
            var ctlCtr = $('additionalCOOCount');
            if (ctlCtr) {
                for (var i = 1; i <= ctlCtr.value; i++) {
                    obj = $('CountryOfOriginName' + i);
                    if (obj && obj.id != id)
                        obj.checked = false;
                }
            }
        }
        else {  // Make sure check box is turned off and show msg
            if (cb.checked) {
                cb.checked = false;
                if (msgID)
                    msgID.innerHTML = "Empty COO cannot be primary";
            }
        }
    }
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
            
            // show the wrapper
            showNLCWrapper('ImageID')
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
            
            // show the wrapper
            showNLCWrapper('MSDSID');
        }
    }
}

function showImage(orig)
{
    if(orig == null || !orig) orig = false;
    var id;
    var isrc = $('I_Image'+((orig==true)?'_ORIG':'')).src;
    if(isrc.indexOf('id=') > 0){
        id = isrc.substring(isrc.indexOf('id=')+3);
        var url = 'getimage.aspx?id=' + id;
        var i = window.open(url, "itemimg"+((orig==true)?'_ORIG':''), "directories=no,height=600,width=955,menubar=no,resizable=yes,scrollbars=yes,status=no,titlebar=no,toolbar=no", true);
        i.focus();
    }else{
        if(!orig) {
            if(!($('B_UpdateImage')) || $('B_UpdateImage').disabled == true) return false;
            //var cmd = Element.readAttribute('B_UpdateImage', 'onclick');
            var cmd = getElementAttribute($('B_UpdateImage'), 'onclick');
            if(cmd != '')
                eval(cmd);
        }
    }
}
function showMSDS(filename, orig)
{
    if(orig == null || !orig) orig = false;
    if(filename == null) filename = '';
    var id;
    var isrc = $('I_MSDS'+((orig==true)?'_ORIG':'')).src;
    if(isrc.indexOf('id=') > 0){
        id = isrc.substring(isrc.indexOf('id=')+3);
        var url = 'getfile.aspx?ad=1&id=' + id + '&filename=' + filename;
        document.location = url;
    }else{
        if(!orig) {
            if(!($('B_UpdateMSDS')) || $('B_UpdateMSDS').disabled == true) return false;
            //var cmd = Element.readAttribute('B_UpdateMSDS', 'onclick');
            var cmd = getElementAttribute($('B_UpdateMSDS'), 'onclick');
            if(cmd != '')
                eval(cmd);
        }
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
        // show/hide the wrapper
        if($('ImageID_ORIG').value != '')
            showNLCWrapper('ImageID');
        else
            hideNLCWrapper('ImageID');
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
        // show/hide the wrapper
        if($('MSDSID_ORIG').value != '')
            showNLCWrapper('MSDSID');
        else
            hideNLCWrapper('MSDSID');
    }
}

function undoImage(itemid)
{
    // get the original value
    var val = '';
    val = $('ImageID_ORIG').value;
    if(val != '')
        $('I_Image').src = 'images/app_icons/icon_jpg_small_on.gif?id=' + val;
    else
        $('I_Image').src = 'images/app_icons/icon_jpg_small.gif';
    // undo / save the value
    goValue = "UNDOIMAGE" + callbackSep + itemid + callbackSep + val;
    CallServer(goValue, "");
    // hide the wrapper
    hideNLCWrapper('ImageID');
}

function undoMSDS(itemid)
{
    // get the original value
    var val = '';
    val = $('MSDSID_ORIG').value;
    if(val != '')
        $('I_MSDS').src = 'images/app_icons/icon_pdf_small.gif?id=' + val;
    else
        $('I_MSDS').src = 'images/app_icons/icon_pdf_small_off.gif';
    // undo / save the value
    goValue = "UNDOMSDS" + callbackSep + itemid + callbackSep + val;
    CallServer(goValue, "");
    // hide the wrapper
    hideNLCWrapper('MSDSID');
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
		            setControlValue('eachCaseCube', arr[2]);

		            //onChangeNLC('eachCaseCubeEdit');
		            onChangeNLC('eachCaseCubeEdit');

		        }
		        else { alert("ERROR: There was a problem calculating the Each Case Pack Cube!"); }
		    }
			else if(arr[0] == "ICPC")
			{
				if(arr[1] == "1" && arr.length >= 3)
				{
					//alert("SUCCESS !");
				    setControlValue('InnerCaseCube', arr[2]);
				   
				    //onChangeNLC('InnerCaseCubeEdit');
				    onChangeNLC('InnerCaseCubeEdit');

				}
				else {alert("ERROR: There was a problem calculating the Inner Case Pack Cube!");}
			} 
			
			else if(arr[0] == "MCPC")
			{
			    if(arr[1] == "1" && arr.length >= 3)
				{
				    //debugger;
					//alert("SUCCESS !");
					setControlValue('MasterCaseCube', arr[2]);
					onChangeNLC('MasterCaseCubeEdit');
                    
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
				if(arr[1] == "1" && arr.length >= 5)
				{
				    var fromField = arr[2];
				    var skipHighlight = false;
				    if(fromField == 'prepriced'){
				        if($('Base1Retail') && $('Base2Retail') && $('testRetail')){
				            if($('Base1Retail').value != $('Base2Retail').value || $('Base1Retail').value != $('testRetail').value)
				                skipHighlight = false;
				            else
				                skipHighlight = true;
				        }else{
				            skipHighlight = true;
				        }
				    }
					setControlValue('Base1Retail', arr[3], true, true);
					if ($('Base2Retail').value.length == 0) {setControlValue('Base2Retail', arr[3], false, true)};
					if ($('testRetail').value.length == 0) {setControlValue('testRetail', arr[3], false, true)};
					if($('alaskaRetail').value != arr[4] && $('Base1Retail').value !=''){
					    setControlValue('alaskaRetail', arr[4], false, true);
					}
					if ($('High2Retail').value.length == 0) {setControlValue('High2Retail', arr[3], false, true)};
					if ($('High3Retail').value.length == 0) {setControlValue('High3Retail', arr[3], false, true)};
					if ($('SmallMarketRetail').value.length == 0) {setControlValue('SmallMarketRetail', arr[3], false, true)};
					//lp change order 14 change zone prices only if the fields are empty, per Tom
					if ($('High1Retail').value.length == 0) {setControlValue('High1Retail', arr[3], false, true)};
					if ($('Base3Retail').value.length == 0) {setControlValue('Base3Retail', arr[3], false, true)};
					if ($('Low1Retail').value.length == 0) {setControlValue('Low1Retail', arr[3], false, true)};
					if ($('Low2Retail').value.length == 0) {setControlValue('Low2Retail', arr[3], false, true)};
					if ($('ManhattanRetail').value.length == 0) { setControlValue('ManhattanRetail', arr[3], false, true) };
					if ($('QuebecRetail').value.length == 0) { setControlValue('QuebecRetail', arr[3], false, true) };
					if ($('PuertoRicoRetail').value.length == 0) { setControlValue('PuertoRicoRetail', arr[3], false, true) };
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
					var Base1Retail = arr[4];
					setControlValue('likeItemDescription', itemDesc, elementTextEquals('likeItemDescription', itemDesc));
					setControlValue('likeItemRetail', Base1Retail, elementTextEquals('likeItemRetail', Base1Retail));
					if(itemDesc == '' && Base1Retail == '')
					    alert("Like Item SKU is not a valid SKU in RMS 12.");
				}
				else {alert("ERROR: There was a problem with Like Item SKU!");}
			} 
			else if(arr[0] == "UNDOIMAGE")
			{
			    if(arr[1] == "1" && arr.length >= 3)
				{
				    // do nothing
				}
				else {alert("ERROR: There was a problem undoing the Item Image!");}
			}
			else if(arr[0] == "UNDOMSDS")
			{
			    if(arr[1] == "1" && arr.length >= 3)
				{
				    // do nothing
				}
				else {alert("ERROR: There was a problem undoing the MSDS Sheet!");}
			}
			else if(arr[0] == "TotalCost")
			{
			    if(arr[1] == "1" && arr.length >= 5)
				{
				    var dc = arr[2];
				    var ic = arr[3];
				    var fob = arr[4];
				    if($('DisplayerCost')) {
				        setControlValue('DisplayerCost', dc);
				        onChangeNLC('DisplayerCostEdit');
				    }
				    setControlValue('ItemCost', ic); onChangeNLC('ItemCostEdit');
				    setControlValue('FOBShippingPoint', fob); onChangeNLC('FOBShippingPointEdit'); 
				}
				else {alert("ERROR: There was a problem calculating the Total Cost!");}
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
function costChanged()
{
    var dc = $('DisplayerCost');
    var ic = $('ItemCost');
    var fob = $('FOBShippingPoint');
    var goValue;
    if(ic && fob) {
        if(ic.value != "") {
            // send data for calculation
            goValue = "TotalCost" + callbackSep + ((dc) ? dc.value : '') + callbackSep + ic.value + callbackSep + fob.value;
		    CallServer(goValue, "");
        }
        else {
            setControlValue('FOBShippingPoint', '');
            onChangeNLC('FOBShippingPointEdit');
        }
    }
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
            setControlValue('eachCaseCube', '');
            onChangeNLC('eachCaseCubeEdit');
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
            setControlValue('InnerCaseCube', '');
            onChangeNLC('InnerCaseCubeEdit');
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
            setControlValue('MasterCaseCube', '');
            onChangeNLC('MasterCaseCubeEdit');
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
    if(fromField == null) fromField = '';
    var pp = $('prePriced'); var br = $('Base1Retail'); var ar = $('alaskaRetail'); var goValue;
    if(pp && br && ar) {
        // send data
        goValue = "Retail" + callbackSep + fromField + callbackSep + pp.options[pp.selectedIndex].value + callbackSep + br.value + callbackSep + ar.value;
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
function taxUDAChanged()
{
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
    var show = true;
    var o = $('Hazardous');
    if(o){
        show = ($('Hazardous').options[$('Hazardous').selectedIndex].value == 'Y') ? true : false;
        showElement('HazardousFlammableRow', show);
        showElement('HazardousContainerTypeRow', show);
        showElement('HazardousContainerSizeRow', show);
        showElement('HazardousMSDSUOMRow', show);
        showElement('HazardousManufacturerNameRow', show);
        showElement('HazardousManufacturerCityRow', show);
        showElement('HazardousManufacturerStateRow', show);
        showElement('HazardousManufacturerPhoneRow', show);
        showElement('HazardousManufacturerCountryRow', show);
    }
}
function CountryOfOriginChanged()
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
    var baseItemRetail = $('Base1Retail').value;
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
    var baseItemRetail = $('Base1Retail').value;
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
var baseItemRetail = $('Base1Retail').value;
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

var itemCustomURL = 'IMCostChange.aspx';
var itemCustomWidth = '910';
var itemCustomHeight = '600';
function openItemCustomWindow(RowID)
{
    var url = '';
	if(!RowID && RowID == null)
		RowID = 0;
	if(itemCustomURL != '') {
	    url = itemCustomURL + ((itemCustomURL.indexOf('?') >= 0) ? "&id=" : "?id=") + RowID;
	}
	if(url != '')
	{
		editWin = window.open(url, "customWindow_" + RowID, "width=" + ((itemCustomWidth != '')?itemCustomWidth:"1000") + ",height=" + ((itemCustomHeight != '')?itemCustomHeight:"750") + ",toolbar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=1,resizable=1");
		editWin.focus();
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
        StockStratHelperdrag = new Draggable('StockStratHelper');
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
        if (StockStratHelperdrag != null) {
            StockStratHelperdrag.destroy();
            StockStratHelperdrag = null;
        }
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