var clickedBox;  // used to keep track of the last grid button clicked.

function SetControls() {
    if ($('srchDept').selectedIndex != 0) {
        var hidClass = $('hidClass');
        GetClass(hidClass.value);
        if (hidClass.value != "-1") {    // Load Subclass
            var hidSubClass = $('hidSubClass');
            GetSubClass(hidSubClass.value);
        }
        if ($('hidLockClass').value == "1") {
            $('srchClass').disabled = true;
            $('srchClass').className = "calculatedField";
            $('srchSubClass').disabled = true;
            $('srchSubClass').className = "calculatedField"
        }
    }
    if ($('srchVendor').disabled == true) {
        $('vendorLookUp').style.display="none";
    }
    var refresh = $('hidRefreshParent')
    var windowed = $('hidWindowed')

    if (refresh && windowed) {
        if (refresh.value == "1" && windowed.value == "1")
            window.parent.opener.reloadPage();
    }

    Sys.WebForms.PageRequestManager.getInstance().add_beginRequest(mAjaxBeginRequest);
    Sys.WebForms.PageRequestManager.getInstance().add_pageLoaded(mAjaxPageLoaded);

    mAjaxPageLoaded(this, 0);
}

function ViewDetail(SKU, VendorNo, VendorType) {
    //alert("hello");
    var url = VendorType == 1 ? "IMDomesticForm.aspx" : "IMImportForm.aspx";
    url += "?id=x&sku=" + SKU + "&vendor=" + VendorNo
    // width=1000,HEIGHT=750
    //var w = screen.width;
//    var h = screen.height;
//    if (h > 1024) h = 1024;
//    w = parseInt(h * 1.333) - 40;
//    if (w > screen.width) w = screen.width - 20;
//    h -= 70;
//    //    var features = 'scrollbars=1,location=0,menubar=0,titlebar=1,toolbar=0,resizable=1,top=5,left=5,width='+w+',height='+h
    var features = 'scrollbars=1,location=0,menubar=0,titlebar=1,toolbar=0,resizable=1,width=1120,height=750'
    mywin = window.open(url, "ViewWindow", features)
    mywin.focus();
}

function ResetSearch() {
    var txtbox = $('srchVendor');
    if (txtbox.disabled == false) {     // Only reset these fields if they are unlocked
        txtbox.value = "";
        $('vendorName').innerHTML = "";
        $('srchDept').selectedIndex = 0;
    }
    if ($('hidLockClass').value != "1") {    // Only reset these fields if they are unlocked
        $('srchClass').selectedIndex = 0;
        $('srchSubClass').selectedIndex = 0;
    }
    if ($('hidLockStockIT').value != "1") {
        $('srchStockCat').selectedIndex = 0;
        $('srchItemTypeAttr').selectedIndex = 0;
    }
    $('srchSKU').value = "";
    $('srchItemDesc').value = "";
    $('srchVPN').value = "";
    $('srchUPC').value = "";
    $('UPCMsg').innerHTML = "";
    if (obj = $('divResults')) obj.style.display = "none";
    if (obj = $('btnAddRecsToBatch')) obj.style.display = "none";
    if (obj = $('lblMessage')) obj.innerHTML = "";
    if (obj = $('txtVendorLookup')) obj.value = "";
}

function CheckChildren(childSKU, packSKU) {
    //alert('Child SKU is: ' + childSKU);
    clickedBox = window.event.srcElement;    // Var for the checkbox that was clicked
    if (clickedBox.checked == true) {
        var url = "IMAddRecordsAJAX.aspx?f=packsku&SKU=" + childSKU + "&packSKU=" + packSKU
        new Ajax.Request(url, {
            method: 'get',
            onSuccess: function(response) {
                var parents = new String();
                parents = response.responseText;
                var msg = new String()
                if (parents.length > 2) {
                    var aParents = parents.split("|");
                    if (aParents[0].length > 0)
                        msg = "This SKU is part of Displayer(s): " + aParents[0] + ".\n\n If you want to Edit the Displayer, Search for the Parent Item.";
                    // May never fire as Search blocks DP Children from being selected
                    if (aParents[1].length > 0) {
                        msg = "This SKU is part of Display Pack: " + aParents[1] + ".\n\n If you want to Edit this item then you must edit the Display Pack Item.";
                        if (aParents[0].length > 0)
                            msg += "\n\nNote: Item is also a child of Displayer(s): " + aParents[0];
                        clickedBox.checked == false;     // turn off the check box for DP Child
                    }
                }
                else
                    msg = "";

                if (msg.length > 0)
                    alert(msg);
            }
        });
    }    
 }

//function closeWindow() {
//    var modal = $('hidmodal')
//    if (modal) {
//        if (modal.value == '1') {
//            window.close();
//            return false;
//        } else {
//        window.location = "ItemMaint.aspx";
//        window.location.href = "ItemMaint.aspx";
//            if (/Firefox[\/\s](\d+\.\d+)/.test(navigator.userAgent)) {
////                window.location = "ItemMaint.aspx";
//            } else {
////                window.location.href = "ItemMaint.aspx";
//            }
//        }
//    }
//}

function GetVendorDesc() {
    var vendorID = $('srchVendor').value
    var vendorName = $('vendorName')
    if (vendorID.length ==0) {
        vendorName.innerHTML = ""
        $('btnSearch').disabled = false;
        return
    }
    vendorName.innerHTML = "Validating Vendor Number..."
    vendorName.style.color = "navy";
    if (isNaN(vendorID)) {
        vendorName.innerHTML = "Invalid Vendor Number."
        vendorName.style.color="Red";
        $('btnSearch').disabled = true;
        return
    }
    var url = "IMAddRecordsAJAX.aspx?f=VendorLookup&VendorID=" + vendorID
    new Ajax.Request(url, {
        method: 'get',
        onSuccess: function(response) {
            var vendorName = $('vendorName')
            if (response.responseText == "0") {
                vendorName.innerHTML = "Invalid Vendor Number."
                vendorName.style.color="Red";
                $('btnSearch').disabled = true;
            }
            else {
                vendorName.innerHTML = response.responseText
                $('btnSearch').disabled = false;
            }
        }
    } );
}

function GetVendorID() {
    // Make sure the control is enabled. if not exist stage left
    new Lightbox.base('dvLookupVendor', { externalControl : 'btnCancel2' });
    $('LookupHeader').innerHTML = "Lookup Vendor Name";
    $('LookupPrompt').innerHTML = "<br />Start Entering the Name of the vendor you wish to find.";
    $('txtLookupPrompt').innerHTML = "Name:";
    $('btnCommit').value = "OK"
    $('btnCommit').disabled = true;
    $('btnCancel2').value = "Cancel"
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
    if (i >=0)  {
        VendorID = VendorName.substring(0,i-1);
        highlightControls('txtVendorLookup');
        $('hidVendorID').value = VendorID;
        $('btnCommit').disabled = false;
    }
}

// Process Lightbox responses
function SaveVendorLookup() {
    $('srchVendor').value = $('hidVendorID').value
    var VendorName = $('txtVendorLookup').value;
    var i = VendorName.indexOf('-');
    $('vendorName').innerHTML  = VendorName.substr(i+2);
    Lightbox.hideAll();     // turn off the lightbox
    $('btnSearch').disabled = false;
}

function ShowDDLLoading(objDDL,showLoad,text) {
    while (objDDL.length > 0)
        objDDL.remove(0);
    if (showLoad) {
        var optNew = document.createElement('option');
        optNew.text = "Loading... "
        optNew.value = "-2"
        try {
            objDDL.add(optNew, null);
        }
        catch(ex) {
            objDDL.add(optNew);       // IE Only
        }
    }
    else {
        if (text.length > 0) {
            var optNew = document.createElement('option');
            optNew.text = text
            optNew.value = "-1"
            try {
                objDDL.add(optNew, null);
            }
            catch(ex) {
                objDDL.add(optNew);       // IE Only
            }
        }
    }
}

// Get List of Classes for Selected Dept
function GetClass(selValue) {
    if (!selValue)
        selValue = "-1";

    var deptNo = $('srchDept').value
    if (deptNo > 0) {
        obj = $('srchSubClass');
        ShowDDLLoading(obj,false,"Select Class");
        var srchClass = $('srchClass');
        if (srchClass) {
            // Show a Loading Option while calling Ajax routine
            ShowDDLLoading(srchClass,true);
            var url = "IMAddRecordsAJAX.aspx?f=class&DeptNo=" + deptNo
            new Ajax.Request(url, {
                method: 'get',
                onSuccess: function(response) {
                    LoadDDL(response, 'srchClass', selValue);
                }
            } );
        }
    }
    else {
        var obj = $('srchClass');
        ShowDDLLoading(obj,false,"Select Department");
        obj = $('srchSubClass');
        ShowDDLLoading(obj,false,"Select Class");
    }       
}

// Get List of Subclasses for Selected Class
function GetSubClass(selValue) {
    if (!selValue)
        selValue = "-1";
        
    var deptNo = $('srchDept').value
    var classNo = $('srchClass').value
    if (classNo <= 0)
        classNo = $('hidClass').value;
    if (deptNo > 0 && classNo > 0) {
        var srchSubClass = $('srchSubClass');
        if (srchSubClass) {
            // Show a Loading Option while calling Ajax routine
            ShowDDLLoading(srchSubClass,true);
            var url = "IMAddRecordsAJAX.aspx?f=subclass&DeptNo=" + deptNo + "&ClassNo=" + classNo
            new Ajax.Request(url, {
                method: 'get',
                onSuccess: function(response) {
                    LoadDDL(response, 'srchSubClass', selValue);
                }
            } );
        }
    }
    else {
        obj = $('srchSubClass');
        ShowDDLLoading(obj,false,"Select Class");
    }        
}

// Load a select control with encoded options
function LoadDDL(response, ddlControl, selValue) {
    ///<summary>Load a Drop Down List based on a special pipe delimited list</summary>
    ///<param name="response">The pipe delimited data (|%| for the record and |$| for the fields in the record</param>
    ///<param name="ddlControl">The name of the control to load</param>
    ///<param name="selValue">Specify optional selected value</param>
    var optText = new String();
    var optText = response.responseText;
    var objDDL = $(ddlControl);
    if (objDDL) {
        // Get rid of any existing options
        while (objDDL.length > 0)
            objDDL.remove(0);
    }
    
    if (objDDL && optText.length > 0) {
        // split options into array of records
        var optLines = optText.split("|%|");    // Record delimiter

        // Now Create Options for Select
        for (var i = 0; i < optLines.length; i++) {
            var optRec = optLines[i].split("|$|");   // value , selected, text
            var optNew = document.createElement('option');
            if (optRec.length == 3) {      // Make sure record parsed to a legit value
                optNew.text = optRec[2];
                optNew.value = optRec[0];
                try {
                    objDDL.add(optNew, null);
                }
                catch(ex) {
                    objDDL.add(optNew);       // IE Only
                }
                if ( (optRec[1] == '1') || (selValue == optRec[0]) ) {     // Select it
                    objDDL.options[i].selected = true;
                }
            }
        }
    }
    else {
        var optNew = document.createElement('option');
        optNew.text = "Error retrieving Info. "
        optNew.value = "-1"
        try {
            objDDL.add(optNew, null);
        }
        catch(ex) {
            objDDL.add(optNew);       // IE Only
        }
    }
}

function ShowSearch() {
    mAjaxBeginRequest(this, 0);
}

function validateUPC() {
    var UPC = $('srchUPC').value
    if (UPC.length ==0) {
        UPCMsg.innerHTML = ""
        $('btnSearch').disabled = false;
        return
    }

    // Make sure UPC is 14 chars in length
    if (UPC.length < 14) {
        while (UPC.length < 14)
            UPC = "0" + UPC;
        $('srchUPC').value = UPC;
    }        
    UPCMsg.innerHTML = "Validating UPC..."
    UPCMsg.style.color="navy";
    var url = "IMAddRecordsAJAX.aspx?f=upc&UPCNo=" + UPC
    new Ajax.Request(url, {
        method: 'get',
        onSuccess: function(response) {
            var UPCMsg = $('UPCMsg')
            if (response.responseText == "0") {
                UPCMsg.innerHTML = "Invalid UPC"
                UPCMsg.style.color="Red";
                $('btnSearch').disabled = true;
            }
            else {
                UPCMsg.innerHTML = ""
                $('btnSearch').disabled = false;
            }
        }
    } );
}

//function refreshList() {

//    if(window.parent) {
//        if(window.parent.opener) {
//            var loc = '' + window.parent.opener.document.location;
//            if(loc.indexOf('IMDetailItems.aspx') >= 0) {
//                window.parent.opener.reloadPage();
//            }
//        }
//    }

//}
