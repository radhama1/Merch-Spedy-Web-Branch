

var isCFPMCCalc = true;
function isCubicFeetPerMasterCartonCalculated()
{
    return isCFPMCCalc;
}
function setIsCubicFeetPerMasterCartonCalculated(value)
{
    if(value == null || !value) isCFPMCCalc = false; else isCFPMCCalc = true;
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
  //  new Ajax.Autocompleter("additionalCOOName1", "additionalCOO_choices1", "lookupcountry.aspx", {
    var addCtr = $("additionalCOOEnd");
    if (!addCtr) {
      return;
    }
    var cnt = addCtr.value;
    if (isInteger(cnt)) {
    // Add an Autocompleter for each control that is found 
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

function checkNewPrimary(index) {
    // Name: NewPrimaryCOOName12
    //       CountryOfOriginName1
    //       01234567890123456789
    // check current Textbox if checked then verify associated country as a name in it if so turn off all other cbs
    if (index) {  // if passed in with index its because a country was reverted
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
                //debugger;
                var newCOOControl = '<input type="text" id="' + tbID + '" name="' + tbID + '" onchange="javascript:checkNewPrimary(' + maxID.toString() + ')" maxlength="50" style="width:175px;" value="" /><sup>' + cnt.toString() + '</sup>';

                // add the addtional controls to the parent label control
                var tbl = $('additionalCOOTbl')

                if (tbl) {
                    var rowCount = tbl.rows.length;
                    var row = tbl.insertRow(rowCount - 1);
                    var cell1 = row.insertCell(0);
                    cell1.style.textAlign = "right"
                    cell1.style.paddingRight = "2px"

                    var chkbox = '<input type="checkbox" id="' + cbID + '" name="' + cbID + '" value="on" onclick="checkNewPrimary();" />'
                    cell1.innerHTML = chkbox;

//                    var element1 = document.createElement("input");
//                    element1.type = "checkbox";
//                    element1.setAttribute('id', cbID)
//                    element1.setAttribute('name', cbID)
//                    element1.setAttribute('value', 'on')
//                    element1.setAttribute('onclick', 'javascript:checkNewPrimary()')
//                    cell1.appendChild(element1);

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
                    //self.setTimeout("ScrollTo('additionalCOOTbl')", 100);
                }
            }
        }
    }
}

function ScrollTo(ctlID) {
    if ($(ctlID))
        $(ctlID).scrollTo();
}

// this handler is passed the object of the control that is filled in by the autocompleter: additionalCOONameXXX
function additionalCOOChanged(obj, objSourceElement) {
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
            if (ctlCtr) {
                for (var i = 1; i <= ctlCtr.value; i++) {
                    var thisObj = $('AddCountryOfOriginName' + i);
                    if (thisObj && thisObj.value == countryName)
                        count++;
                }
            }
            //CountryOfOriginName
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
    
//    if (obj) {
//        setControlValue(obj.id, obj.value, false, true);

//        //        var strID = new String(obj.id);
//        //        var Index = strID.substr(19);    // get the index count for this field
//        //        var hidID = "countryOfOrigin" + Index;
//        // send data
//        //        var goValue = hidID + callbackSep + obj.value;
//        // CallServer is created by the code behind Page.  When the page is returned it calls the function ReceiveServerData()
//        //	    CallServer(goValue, "");
//    }
//}

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
            Element.writeAttribute(i, "width", "232");
            Element.setStyle(i, { width: '232px' });
            if($('ImageID')) $('ImageID').value = newid;
            if($('B_UpdateImage')) $('B_UpdateImage').value = 'Update';
            if($('I_Image_Label')) $('I_Image_Label').innerText = '(click on image to view full size)';
            Element.writeAttribute($('B_DeleteImage'), "disabled", "");
            
            // show the wrapper
            showNLCWrapper('ImageID');
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
        var i = window.open(url, "importimg"+((orig==true)?'_ORIG':''), "directories=no,height=600,width=955,menubar=no,resizable=yes,scrollbars=yes,status=no,titlebar=no,toolbar=no", true);
        i.focus();
    }else{
        if(!orig) {
            if(!($('B_UpdateImage')) || $('B_UpdateImage').disabled == true) return false;
            var cmd = Element.readAttribute('B_UpdateImage', 'onclick');
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
            var cmd = Element.readAttribute('B_UpdateMSDS', 'onclick');
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
        Element.writeAttribute(i, "width", "16");
        Element.setStyle(i, { width: '16px' });
        i.src = 'images/app_icons/icon_jpg_small.gif';
        if($('ImageID')) $('ImageID').value = '';
        if($('B_UpdateImage')) $('B_UpdateImage').value = 'Upload';
        if($('I_Image_Label')) $('I_Image_Label').innerText = '(click upload button to add Item Image)';
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
        Element.writeAttribute(i, "width", "16");
        Element.setStyle(i, { width: '16px' });
        i.src = 'images/app_icons/icon_pdf_small_off.gif';
        if($('MSDSID')) $('MSDSID').value = '';
        if($('B_UpdateMSDS')) $('B_UpdateMSDS').value = 'Upload';
        if($('I_MSDS_Label')) $('I_MSDS_Label').innerText = '(click upload button to add MSDS Sheet)';
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
    if(val != '') {
        $('I_Image').src = 'getimage.aspx?id=' + val;
        Element.writeAttribute($('I_Image'), "width", "232");
        Element.setStyle($('I_Image'), { width: '232px' });
    } else {
        $('I_Image').src = 'images/app_icons/icon_jpg_small.gif';
        Element.writeAttribute($('I_Image'), "width", "16");
        Element.setStyle($('I_Image'), { width: '16px' });
        if($('I_Image_Label')) $('I_Image_Label').innerText = '(click upload button to add Item Image)';
    }
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
    if(val != '') {
        $('I_MSDS').src = 'images/app_icons/icon_pdf_large.gif?id=' + val;
        Element.writeAttribute($('I_MSDS'), "width", "32");
        Element.writeAttribute($('I_MSDS'), "height", "32");
        Element.setStyle($('I_MSDS'), { width: '32px' });
        Element.setStyle($('I_MSDS'), { height: '32px' });
    } else {
        $('I_MSDS').src = 'images/app_icons/icon_pdf_small_off.gif';
        Element.writeAttribute($('I_MSDS'), "width", "16");
        Element.writeAttribute($('I_MSDS'), "height", "16");
        Element.setStyle($('I_MSDS'), { width: '16px' });
        Element.setStyle($('I_MSDS'), { height: '16px' });
        if($('I_MSDS_Label')) $('I_MSDS_Label').innerText = '(click upload button to add MSDS Sheet)';
    }
    // undo / save the value
    goValue = "UNDOMSDS" + callbackSep + itemid + callbackSep + val;
    CallServer(goValue, "");
    // hide the wrapper
    hideNLCWrapper('MSDSID');
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
			        setControlValue('EachCaseCube', arr[2]);
			        onChangeNLC('EachCaseCubeEdit');

			    }
			    else { alert("ERROR: There was a problem calculating the Each Case Pack Cube!"); }
			}
			else if(arr[0] == "ICPC")
			{
				if(arr[1] == "1" && arr.length >= 3)
				{
				    setControlValue('InnerCaseCube', arr[2]);
				    onChangeNLC('InnerCaseCubeEdit');

				}
				else {alert("ERROR: There was a problem calculating the Inner Case Pack Cube!");}
			} 
			else if(arr[0] == "CALC_OceanFreight")
			{
			    if(arr[1] == "1" && arr.length >= 3)
				{
				    setControlValue('OceanFreightComputedAmount', arr[2]);
				    onChangeNLC('OceanFreightComputedAmountEdit');
					
				}
				else {alert("ERROR: There was a problem calculating the Ocean Freight!");}
}
			else if(arr[0] == "CALC_EstLandedCost")
			{
			    if (arr[1] == "1" && arr.length >= 4 && arr[3] != null && arr[3] != '')
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
					onChangeNLC('DisplayerCost');

                    // prodcost
                    if(fromField == 'prodcost')
					    setControlValue('ProductCost', getXMLValue(xmlDOMDoc, 'prodcost'), false, true);
					else
					    setControlValue('ProductCost', getXMLValue(xmlDOMDoc, 'prodcost'), true, true);
					onChangeNLC('ProductCost');

                    // fob
				    setControlValue('FOBShippingPoint', getXMLValue(xmlDOMDoc, 'fob'));
				    onChangeNLC('FOBShippingPointEdit');

				    setControlValue('FirstCost', getXMLValue(xmlDOMDoc, 'fob'));
				    onChangeNLC('FirstCostEdit');

				    // dutyper
					if(fromField == 'dutyper')
					    setControlValue('DutyPercent', getXMLValue(xmlDOMDoc, 'dutyper'), false, true);
					else
					    setControlValue('DutyPercent', getXMLValue(xmlDOMDoc, 'dutyper'), true, true);
					onChangeNLC('DutyPercent');

					// addduty
					if(fromField == 'addduty')
					    setControlValue('AdditionalDutyAmount', getXMLValue(xmlDOMDoc, 'addduty'), false, true);
					else
					    setControlValue('AdditionalDutyAmount', getXMLValue(xmlDOMDoc, 'addduty'), true, true);
					onChangeNLC('AdditionalDutyAmount');

			        // supptariffper
					if (fromField == 'supptariffper')
                    setControlValue('SuppTariffPercent', getXMLValue(xmlDOMDoc, 'supptariffper'), false, true);
					else
					    setControlValue('SuppTariffPercent', getXMLValue(xmlDOMDoc, 'supptariffper'), true, true);
					onChangeNLC('SuppTariffPercent');

					// eachesmc
					if(fromField == 'eachesmc')
					    setControlValue('EachesMasterCase', getXMLValue(xmlDOMDoc, 'eachesmc'), false, true);
					else
					    setControlValue('EachesMasterCase', getXMLValue(xmlDOMDoc, 'eachesmc'), true, true);
					onChangeNLC('EachesMasterCase');

					// mclength
					if(fromField == 'mclength')
					    setControlValue('MasterCaseLength', getXMLValue(xmlDOMDoc, 'mclength'), false, true);
					else
					    setControlValue('MasterCaseLength', getXMLValue(xmlDOMDoc, 'mclength'), true, true);
					onChangeNLC('MasterCaseLength');
					    
					// mcwidth
					if(fromField == 'mcwidth')
					    setControlValue('MasterCaseWidth', getXMLValue(xmlDOMDoc, 'mcwidth'), false, true);
					else
					    setControlValue('MasterCaseWidth', getXMLValue(xmlDOMDoc, 'mcwidth'), true, true);
					onChangeNLC('MasterCaseWidth');
					    
					// mcheight
					if(fromField == 'mcheight')
					    setControlValue('MasterCaseHeight', getXMLValue(xmlDOMDoc, 'mcheight'), false, true);
					else
					    setControlValue('MasterCaseHeight', getXMLValue(xmlDOMDoc, 'mcheight'), true, true);
					onChangeNLC('MasterCaseHeight');

					// oceanfre
					if(fromField == 'oceanfre')
					    setControlValue('OceanFreightAmount', getXMLValue(xmlDOMDoc, 'oceanfre'), false, true);
					else
					    setControlValue('OceanFreightAmount', getXMLValue(xmlDOMDoc, 'oceanfre'), true, true);
					onChangeNLC('OceanFreightComputedAmountEdit');
					    
					// agentcommper
					if(fromField == 'agentcommper')
					    setControlValue('AgentCommissionPercent', getXMLValue(xmlDOMDoc, 'agentcommper'), false, true);
					else
					    setControlValue('AgentCommissionPercent', getXMLValue(xmlDOMDoc, 'agentcommper'), true, true);
					onChangeNLC('AgentCommissionAmountEdit');

					// otherimportper
					//debugger;
					if (fromField == 'otherimportper')
					    setControlValue('OtherImportCostsPercent', getXMLValue(xmlDOMDoc, 'otherimportper'));
					
					else
					    setControlValue('OtherImportCostsPercent', getXMLValue(xmlDOMDoc, 'otherimportper'), true);
					onChangeNLC('OtherImportCostsPercentEdit');

					// packcost
					//if(fromField == 'packcost')
					//    setControlValue('PackagingCostAmount', getXMLValue(xmlDOMDoc, 'packcost'), false, true);
					//else
					//    setControlValue('PackagingCostAmount', getXMLValue(xmlDOMDoc, 'packcost'), true, true);
					
					
					// cubicftpermc
					if (isCubicFeetPerMasterCartonCalculated()) {
					    setControlValue('MasterCaseCube', getXMLValue(xmlDOMDoc, 'cubicftpermc'), true);
					    onChangeNLC('MasterCaseCubeEdit');
					}
					
					// duty
					setControlValue('DutyAmount', getXMLValue(xmlDOMDoc, 'duty'));
					onChangeNLC('DutyAmountEdit');

			        // SuppTariff
					setControlValue('SuppTariffAmount', getXMLValue(xmlDOMDoc, 'supptariff'));
					onChangeNLC('SuppTariffAmountEdit');
										
					// ocean
					setControlValue('OceanFreightComputedAmount', getXMLValue(xmlDOMDoc, 'ocean'));
					onChangeNLC('OceanFreightComputedAmountEdit');
					
					// agentcomm
					setControlValue('AgentCommissionAmount', getXMLValue(xmlDOMDoc, 'agentcomm'));
					onChangeNLC('AgentCommissionAmountEdit');

					// otherimport
					setControlValue('OtherImportCostsAmount', getXMLValue(xmlDOMDoc, 'otherimport'));
					onChangeNLC('OtherImportCostsAmountEdit');

					// totalimport
					setControlValue('ImportBurden', getXMLValue(xmlDOMDoc, 'totalimport'));
					onChangeNLC('ImportBurdenEdit');
					setControlValue('StoreTotalImportBurden', getXMLValue(xmlDOMDoc, 'totalimport'));
					onChangeNLC('StoreTotalImportBurdenEdit');

					// totalcost
					setControlValue('WarehouseLandedCost', getXMLValue(xmlDOMDoc, 'totalcost'));
					onChangeNLC('WarehouseLandedCostEdit');
					setControlValue('TotalWhseLandedCost', getXMLValue(xmlDOMDoc, 'totalcost'));
					onChangeNLC('TotalWhseLandedCostEdit');

					// outfreight
					setControlValue('OutboundFreight', getXMLValue(xmlDOMDoc, 'outfreight'));
					onChangeNLC('OutboundFreightEdit');

					// ninewhse
					setControlValue('NinePercentWhseCharge', getXMLValue(xmlDOMDoc, 'ninewhse'));
					onChangeNLC('NinePercentWhseChargeEdit');

					// totalstore
					setControlValue('TotalStoreLandedCost', getXMLValue(xmlDOMDoc, 'totalstore'));
					onChangeNLC('TotalStoreLandedCostEdit');
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
				if(arr[1] == "1" && arr.length >= 5)
				{
				    var fromField = arr[2];
				    var skipHighlight = false;
				    if(fromField == 'prepriced'){
				        if($('Base1Retail') && $('Base2Retail') && $('TestRetail')){
				            if($('Base1Retail').value != $('Base2Retail').value || $('Base1Retail').value != $('TestRetail').value)
				                skipHighlight = false;
				            else
				                skipHighlight = true;
				        }else{
				            skipHighlight = true;
				        }
				    }
					setControlValue('Base1Retail', arr[3], true, true);
					
					if($('AlaskaRetail').value != arr[4] && $('Base1Retail').value !=''){
					    setControlValue('AlaskaRetail', arr[4], false, true);
					}
					if ($('High2Retail').value.length == 0) {setControlValue('High2Retail', arr[3], false, true)};
					if ($('High3Retail').value.length == 0) {setControlValue('High3Retail', arr[3], false, true)};
					if ($('SmallMarketRetail').value.length == 0) {setControlValue('SmallMarketRetail', arr[3], false, true)};
					if ($('Base2Retail').value.length == 0) {setControlValue('Base2Retail', arr[3], false, true)};
					if ($('TestRetail').value.length == 0) {setControlValue('TestRetail', arr[3], false, true)};

					//lp change order 14 19 aug 2009
					if ($('High1Retail').value.length == 0) {setControlValue('High1Retail', arr[3], false, true)};
					if ($('Base3Retail').value.length == 0) {setControlValue('Base3Retail', arr[3], false, true)};
					if ($('Low1Retail').value.length == 0) {setControlValue('Low1Retail', arr[3], false, true)};
					if ($('Low2Retail').value.length == 0) {setControlValue('Low2Retail', arr[3], false, true)};
					if ($('ManhattanRetail').value.length == 0) { setControlValue('ManhattanRetail', arr[3], false, true) };
					if ($('QuebecRetail').value.length == 0) { setControlValue('QuebecRetail', arr[3], false, true) };
					if ($('PuertoRicoRetail').value.length == 0) { setControlValue('PuertoRicoRetail', arr[3], false, true) };

				}
				else {alert("ERROR: There was a problem with Base Retail!");}
			} 
			else if(arr[0] == "RetailAlaska")
			{
				if(arr[1] == "1" && arr.length >= 3)
				{
					setControlValue('AlaskaRetail', arr[2], false, true);
					//lp need a change here?
					//calculateGMPercent();
				}
				else {alert("ERROR: There was a problem with Alaska Retail!");}
			} 
			else if(arr[0] == "RetailCanada")
			{
				if(arr[1] == "1" && arr.length >= 3)
				{
					setControlValue('CanadaRetail', arr[2], false, true);
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
			else {alert("ERROR: Unknown callback response given!");}
		}
		else {alert("ERROR: Invalid callback response given!");}
	}
}

function calcfixfocus() {
    //alert('here');
    $('txtFocusFix').focus();
}

function eachCaseChanged() {
    var he = $('EachCaseHeight'); var wi = $('EachCaseWidth'); var le = $('EachCaseLength'); var goValue;
    if (he && wi && le) {
        if (he.value != "" && wi.value != "" && le.value != "") {
            // send data for calculation
            goValue = "ECPC" + callbackSep + he.value + callbackSep + wi.value + callbackSep + le.value + callbackSep + "";
            CallServer(goValue, "");
        }
        else {
            if ($('EachCaseCube') && $('EachCaseCubeEdit')) {
                $('EachCaseCube').value = ''; $('EachCaseCubeEdit').value = '';
                onChangeNLC('EachCaseCubeEdit');
            }
        }
    }
}
function innerCaseChanged()
{
    var he = $('InnerCaseHeight'); var wi = $('InnerCaseWidth'); var le = $('InnerCaseLength'); var goValue;
    if(he && wi && le) {
        if(he.value != "" && wi.value != "" && le.value != "") {
            // send data for calculation
            goValue = "ICPC" + callbackSep + he.value + callbackSep + wi.value + callbackSep + le.value + callbackSep + "";
		    CallServer(goValue, "");
		}
		else {
		    if ($('InnerCaseCube') && $('InnerCaseCubeEdit')) {
		        $('InnerCaseCube').value = ''; $('InnerCaseCubeEdit').value = '';
		        onChangeNLC('InnerCaseCubeEdit');
		    } 
		}
    }
}
function calculateOceanFreight()
{
    var emc = $('EachesMasterCase'); var cf = $('MasterCaseCube'); var oceanf = $('OceanFreightAmount');
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
    //var agent = $('Agent');
    var agent = $('VendorOrAgent');
    var dispcost = $('DisplayerCost');
    var prodcost = $('ProductCost');
    var fob = $('FOBShippingPoint');
    var dutyper = $('DutyPercent');
    var addduty = $('AdditionalDutyAmount');
    var supptariffper = $('SuppTariffPercent');
    var eachesmc = $('EachesMasterCase');
    var mclength = $('MasterCaseLength');
    var mcwidth = $('MasterCaseWidth');
    var mcheight = $('MasterCaseHeight');
    var cubicftpermc = $('MasterCaseCube');
    var oceanfre = $('OceanFreightAmount');
    var oceanamt = $('OceanFreightComputedAmount');
    var agentcommper = $('AgentCommissionPercent');
    var otherimportper = $('OtherImportCostsPercent');
    var packcost = $('PackagingCostAmount');
    var goValue;
    if (agent && dispcost && prodcost && fob && dutyper && addduty && supptariffper && eachesmc && mclength && mcwidth && mcheight && cubicftpermc && oceanfre && oceanamt && agentcommper && otherimportper && packcost) {
    //if(agent && fob && dutyper && addduty && eachesmc && mclength && mcwidth && mcheight && cubicftpermc && oceanfre && oceanamt && agentcommper && otherimportper && packcost) {
        // send data for calculation
        var agentResp = agent.options[agent.selectedIndex].value == "A" ? "X" : "";
        goValue = formatCalcXML(agentResp, dispcost.value, prodcost.value, fob.value, dutyper.value, addduty.value, supptariffper.value, eachesmc.value, mclength.value, mcwidth.value, mcheight.value, cubicftpermc.value, oceanfre.value, oceanamt.value, agentcommper.value, otherimportper.value, packcost.value);
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
var baseItemRetail = $('Base1Retail').value;
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
function CalculateUnitStoreMonth()
{
    var storeTotals = $('storeTotal').value;
    var AnnualRegularUnitForecast = $('AnnualRegularUnitForecast').value;
    var baseItemRetail = $('Base1Retail').value;
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
    var baseItemRetail = $('Base1Retail').value;
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
    if ( $('CalculateOptions') ) {
        
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

function baseRetailChanged(fromField)
{
    if(fromField == null) fromField = '';
    var pp = $('PrePriced'); var br = $('Base1Retail'); var ar = $('AlaskaRetail'); var goValue;
    if(pp && br && ar) {
        // send data
        goValue = "Retail" + callbackSep + fromField + callbackSep + pp.options[pp.selectedIndex].value + callbackSep + br.value + callbackSep + ar.value;
	    CallServer(goValue, "");
    }
}
function alaskaRetailChanged()
{
    var ar = $('AlaskaRetail'); var goValue;
    if(ar) {
        // send data
        goValue = "RetailAlaska" + callbackSep + ar.value;
	    CallServer(goValue, "");
	    //LP Change here change order 14
	    calculateIMUPercent('AlaskaRetail');
    }
}
function canadaRetailChanged()
{
    var cr = $('CanadaRetail'); var goValue;
    if(cr) {
        // send data
        goValue = "RetailCanada" + callbackSep + cr.value;
	    CallServer(goValue, "");
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
    var objE = $('MasterCaseCubeEdit');
    var obj = $('MasterCaseCube');
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
    var br = $('Base1Retail'), brval;
    var ar = $('AlaskaRetail'), arval;
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
        
        $('Base1RetailGM').innerText = gmval;
        //$('Base2RetailGM').innerText = gmval;
        //$('TestRetailGM').innerText = gmval;
        /*
        if(ppval == 'Y')
            $('AlaskaRetailGM').innerText = gmval;
        else
            $('AlaskaRetailGM').innerText = '';
        */
        $('AlaskaRetailGM').innerText = gmval2;
        
        //$('High2RetailGM').innerText = gmval;
        //$('High3RetailGM').innerText = gmval;
        //$('SmallMarketRetailGM').innerText = gmval;
        //lp change order 14 aug 2009
        //$('High1RetailGM').innerText = gmval;
        //$('Base3RetailGM').innerText = gmval;
        //$('Low1RetailGM').innerText = gmval;
        //$('Low2RetailGM').innerText = gmval;
        //$('ManhattanRetailGM').innerText = gmval;
        //$('QuebecRetailGM').innerText = gmval;
        //$('PuertoRicoRetailGM').innerText = gmval;
        
        //change order 14
        if(gmval != '' && skipHighlight != true){
            highlightControls2('Base1RetailGM');
            highlightControls2('Base2RetailGM');
            highlightControls2('TestRetailGM');
            highlightControls2('AlaskaRetailGM');
            highlightControls2('High2RetailGM');
            highlightControls2('High3RetailGM');
            highlightControls2('SmallMarketRetailGM');
            //change order 14
            highlightControls2('High1RetailGM');
            highlightControls2('Base3RetailGM');
            highlightControls2('Low1RetailGM');
            highlightControls2('Low2RetailGM');
            highlightControls2('ManhattanRetailGM');
            highlightControls2('QuebecRetailGM');
            highlightControls2('PuertoRicoRetailGM');
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