var clickedBox;  // used to keep track of the last grid button clicked.
var ajaxLookupURL = 'POMaintenanceDetailsAddSKUAJAX.aspx';

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
            $('srchSubClass').className = "calculatedField";
        }
    }
    if ($('srchVendor').disabled == true) {
        $('vendorLookUp').style.display="none";
    }
    var refresh = $('hidRefreshParent');
    var windowed = $('hidWindowed');

    if (refresh && windowed) {
        if (refresh.value == "1" && windowed.value == "1") {
            if(window.parent.opener.document.getElementById('hdnOpenPopup')){
                window.parent.opener.document.getElementById('hdnOpenPopup').value = 'ADDSKUFOCUS';
            }
            window.parent.opener.SaveCache();
            $('hidRefreshParent').value = "0";
        }
    }

    //Sys.WebForms.PageRequestManager.getInstance().add_beginRequest(mAjaxBeginRequest);
    //Sys.WebForms.PageRequestManager.getInstance().add_pageLoaded(mAjaxPageLoaded);

    //mAjaxPageLoaded(this, 0);
}

function ResetSearch() {

    if ($('srchDept').disabled == false) {
        $('srchDept').selectedIndex = 0;
    }
    if ($('srchItemTypeAttr').disabled == false) {
        $('srchItemTypeAttr').selectedIndex = 0;
    }

    $('srchSKU').value = "";
    $('srchItemDesc').value = "";
    $('srchVPN').value = "";
    $('srchUPC').value = "";
    $('UPCMsg').innerHTML = "";
    $('srchClass').selectedIndex = 0;
    $('srchSubClass').selectedIndex = 0;
        
    if (obj = $('divResults')) obj.style.display = "none";
    if (obj = $('btnAddRecs')) obj.style.display = "none";
    if (obj = $('lblMessage')) obj.innerHTML = "";
    if (obj = $('txtVendorLookup')) obj.value = "";
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
            var url = ajaxLookupURL + "?f=class&DeptNo=" + deptNo
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
            var url = ajaxLookupURL + "?f=subclass&DeptNo=" + deptNo + "&ClassNo=" + classNo
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
    //mAjaxBeginRequest(this, 0);
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
    var url = ajaxLookupURL + "?f=upc&UPCNo=" + UPC
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
