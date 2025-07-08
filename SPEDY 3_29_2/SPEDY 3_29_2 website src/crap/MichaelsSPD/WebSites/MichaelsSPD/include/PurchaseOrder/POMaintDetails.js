function preloadItemImages()
{
    var img1 = new Image(); img1.src = 'images/tab_po_header_off.gif';
    var img2 = new Image(); img2.src = 'images/tab_po_detail_on.gif';
}

function goUrl(url)
{
    document.location = url;
}

function setPageAsDirty() {
    $('hdnPageIsDirty').value = "1"
}

/*
var callbackSep = "{{|}}";

function itemTypeChanged()
{
    var it = getSelectValue('itemType');
    if(it == 'R') {
        $('addUnitCost').value = '';
        $('addUnitCostRow').hide();
    } else {
        $('addUnitCostRow').show();
    }
}
function lookupVendor(vendorType, vendorNumCtrl)
{
	var goValue = "";
	var vendorNum = vendorNumCtrl.value;
	if (vendorType != null && vendorType != '' && vendorNum != null && vendorNum != '')
	{
		goValue = "100" + callbackSep + vendorType + callbackSep + vendorNum;
		CallServer(goValue, "");
	} else {
	    if (vendorType == "Canadian") $('CanadianVendorNum').value = vendorNum;
	    if (vendorType == "US") $('USVendorNum').value = vendorNum;
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
					if(vType == "US") {
					    $('USVendorNum').value = vNum;
					    $('USVendorNumEdit').value = vNum;
					    $('USVendorName').value = vName;
					    $('USVendorNameLabel').innerText = vName;
					    highlightControls('USVendorNameLabel');
					} else {
					    if (vType == "Canadian") {
					        $('CanadianVendorNum').value = vNum;
					        $('CanadianVendorNumEdit').value = vNum;
					        $('CanadianVendorName').value = vName;
					        $('CanadianVendorNameLabel').innerText = vName;
					        highlightControls('CanadianVendorNameLabel');
					    }
					}
				}
				else 
				{
				    var vType = (arr.length >= 3) ? arr[2] : "";
				    var vNum = (arr.length >= 4) ? arr[3] : "";
				    var vNumShow = (vNum != "") ? (" " + vNum) : "";
				    var vName = (arr.length >= 5) ? arr[4] : "";
				    var vError = (arr.length >= 6) ? arr[5] : "";
				    
				    if(vType == "US") {
					    $('USVendorNum').value = vNum;
					    $('USVendorNumEdit').value = vNum;
					    $('USVendorName').value = '';
					    $('USVendorNameLabel').innerText = '';
					    
					    $('USVendorNumEdit').focus();
					    $('USVendorNumEdit').select();
					} else {
					    if (vType == "Canadian") {
					        $('CanadianVendorNum').value = vNum;
					        $('CanadianVendorNumEdit').value = vNum;
					        $('CanadianVendorName').value = '';
					        $('CanadianVendorNameLabel').innerText = '';
					        
					        $('CanadianVendorNumEdit').focus(); 
					        $('CanadianVendorNumEdit').select(); 
					    }
					}
					
					if (vError != "")
					    alert(vError);
					else
					    alert(vType + " Vendor Number" + vNumShow + " is not valid.  Please re-enter the " + vType + " Vendor Number.");
				}
			} 
			else {alert("ERROR: Unknown callback response given!");}
		}
		else {alert("ERROR: Invalid callback response given!");}
	}
}

*/