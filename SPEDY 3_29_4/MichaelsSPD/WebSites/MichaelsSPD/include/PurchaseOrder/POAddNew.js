var myLightBox;

function SetControls() {
    
}

function RemoveControls() {
    myLightBox = null;
}

function Validate() {

    var validVendor = $('validVendor').value * 1;
    var vendorID = $('srchVendor').value.trim();
    
    if(vendorID.length == 0) {
        alert('Please enter a valid vendor number');
        $('srchVendor').focus();
        $('srchVendor').select();
        return false;
    }
    else if (validVendor == 0){
        alert('Please enter a valid vendor number');
        $('srchVendor').focus();
        $('srchVendor').select();
        return false;
    }
    
    $('btnGo').value = ' Saving... ';
    
    return true;
}

function GetVendorDesc() {
    var vendorID = $('srchVendor').value;
    var vendorName = $('vendorName');
    if (vendorID.length == 0) {
        vendorName.innerHTML = "";
        $('validVendor').value = 0;
        $('btnGo').disable();   
        return;
    }
    vendorName.innerHTML = "Validating Vendor Number...";
    vendorName.style.color = "navy";
    if (isNaN(vendorID)) {
        vendorName.innerHTML = "Invalid Vendor Number.";
        vendorName.style.color="Red";
        $('validVendor').value = 0;
        $('btnGo').disable();  
        return;
    }
    var url = "IMAddRecordsAJAX.aspx?f=VendorLookup&VendorID=" + vendorID
    new Ajax.Request(url, {
        method: 'get',
        onSuccess: function(response) {
            var vendorName = $('vendorName');
            if (response.responseText == "0") {
                vendorName.innerHTML = "Invalid Vendor Number."
                vendorName.style.color="Red";
                $('validVendor').value = 0;
                $('btnGo').disable();  
            }
            else {
                vendorName.innerHTML = response.responseText;
                $('validVendor').value = 1;
                $('btnGo').enable();  
            }
            vendorName = null;
        }
    });
    //RULE:  Lookup Vendor Type.  If it is Import, then set the dropdown to Warehouse and lock it
    url = "IMAddRecordsAJAX.aspx?f=vendorIsImport&VendorID=" + vendorID
    new Ajax.Request(url, {
        method: 'get',
        onSuccess: function(response) {
            var warehouseDirect = $('warehouseDirect');
            if (response.responseText == "True") {
                warehouseDirect.disabled = true
                warehouseDirect.item(0).selected = true
            }
            else {
                warehouseDirect.disabled = false
            }
        }
    });
    vendorName = null;
}

function GetVendorID() {
    // Make sure the control is enabled. if not exist stage left
    myLightBox = new Lightbox.base('dvLookupVendor', { externalControl : 'btnCancel2' });
    $('LookupHeader').innerHTML = "Lookup Vendor Name";
    $('LookupPrompt').innerHTML = "<br />Start Entering the Name of the vendor you wish to find.";
    $('txtLookupPrompt').innerHTML = "Name:";
    $('btnCommit').value = "OK";
    $('btnCommit').disabled = true;
    $('btnCancel2').value = "Cancel";
    $('txtVendorLookup').value = "";
    $('txtVendorLookup').focus();

    // Get Vendor Name
    new Ajax.Autocompleter("txtVendorLookup", "VendorResults", "IMAddRecordsAJAX.aspx", {
          paramName: "value",
          parameters: "f=vendor", 
          minChars: 1,
          afterUpdateElement: VendorLookupDone
        } );
}

function VendorLookupDone() {
    var VendorID = "";
    var VendorName = $('txtVendorLookup').value;
    var i = VendorName.indexOf('-');
    if (i >=0 )  {
        VendorID = VendorName.substring(0,i-1);
        highlightControls('txtVendorLookup');
        $('hidVendorID').value = VendorID;
        $('btnCommit').disabled = false;
    }
}

// Process Lightbox responses
function SaveVendorLookup() {
    $('srchVendor').value = $('hidVendorID').value;
    var VendorName = $('txtVendorLookup').value;
    var i = VendorName.indexOf('-');
    $('vendorName').innerHTML  = VendorName.substr(i+2);
    $('validVendor').value = 1;
    $('btnGo').enable();  
    $('vendorName').style.color = "navy";
    myLightBox.hideBox();

    //RULE:  Lookup Vendor Type.  If it is Import, then set the dropdown to Warehouse and lock it
    var url = "IMAddRecordsAJAX.aspx?f=vendorIsImport&VendorID=" + $('srchVendor').value
    new Ajax.Request(url, {
        method: 'get',
        onSuccess: function(response) {
            var warehouseDirect = $('warehouseDirect');
            if (response.responseText == "True") {
                warehouseDirect.disabled = true
                warehouseDirect.item(0).selected = true
            }
            else {
                warehouseDirect.disabled = false
            }
        }
    });
}

function ValidateOnEnter(fieldId) {
    if (window.event && window.event.keyCode == 13) {
        GetVendorDesc();
    }
    //else
        //return true;
}

function TabEnter(e, ctrl) {

    if (window.event && (window.event.keyCode == 13 || window.event.keyCode == 9)) {
        if(window.event.keyCode == 13){
            if(ctrl == "srchVendor"){
                GetVendorDesc();
                if(!$('warehouseDirect').disabled){
                    $('warehouseDirect').focus();
                }                
            }
        }
        
        return false;
    }
}