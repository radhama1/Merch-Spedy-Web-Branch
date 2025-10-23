var clickedButton;  // used to keep track of the last grid button clicked.

function ShowHistory(id) {
    var now = new Date();
    var url = 'POBatchHistory.aspx?poid=' + id + '&potype=M&tstamp=' + now.getTime()
    
    if (window.showModalDialog) {
        var features = "center:yes; dialogHeight:650px; dialogWidth:950px; edge:raised; help:no; resizable:yes; status:yes;"
        window.showModalDialog(url, "junk", features);
    } else {
        var features = 'height=650,width=950,toolbar=no,directories=no,status=yes,menubar=no,scrollbars=no,resizable=yes,modal=yes';
        window.open(url, 'junk', features);
    }
}

//this function to pop up message confirming Remove or Disapprove Action
 function RemoveDisappr_ActionButtonClick(rowIndex) {
    var note = new String();    // if there is something in the hdnHotes field then return true so Page will Postback
    var hdnote = $('hdnNotes')
    note = hdnote.value
    if (note.length > 0)
        return true;
        
    var grItems = document.getElementById('gvMaint');
    var rowElement = grItems.rows[rowIndex];
    
    var rowcell = rowElement.cells[14];
     var selvalue = rowcell.querySelector('select').value;
    
    clickedButton = window.event.srcElement;    // Var for the Action GO button that was clicked
    var obj = document.getElementById('lblNewItemMessage')  // clear out any old error message with a single space
    if (obj) {
        obj.innerHTML = "&nbsp;";
        //obj.disabled = true;
    }
    // REMOVE
    if (selvalue==3) {
        new Lightbox.base('dvPrompt', { externalControl : 'btnCancel' });
        $('msgHeader').innerHTML = "Confirm Rollback";
        $('msgPrompt').innerHTML = "<br /><br />Please confirm you want to Rollback this PO";
        $('divDis').style.display="none";
        $('btnCommit').value = "Yes"
        $('btnCancel').value = "No"
        return false;
    }

    // DISAPPROVE
    if (selvalue == 2) {
        var POID = rowElement.cells[17].querySelector('input').value;
        var StageID = rowElement.cells[18].querySelector('input').value;
  
        new Lightbox.base('dvPrompt', { externalControl : 'btnCancel' });
        var obj = $('txtResponse');
        if (obj)
            obj.value = "";     // make sure any previous reason is cleared
 
        $('divDis').style.display="inline";
        $('msgHeader').innerHTML = "Disapprove PO: " + POID ;
        $('msgPrompt').innerHTML = "<br />Please enter the reason you are disapproving this batch.";
        $('txtPrompt').innerHTML = "Reason:";
        $('btnCommit').value = "OK"
        $('btnCancel').value = "Cancel"
        
        // set up the list of valid stages
        var selList = $('DisStages');
        if (selList) {
            // Get rid of any existing options
            while (selList.length > 0)
                selList.remove(0);
        }

        // Show a Loading Option while calling Ajax routine
        var optNew = document.createElement('option');
        optNew.innerText = "Loading... "
        optNew.value = "-2"
        if (selList) {
            try {
                selList.add(optNew, null);
            }
            catch (ex) {
                selList.add(optNew);       // IE Only
            }
        }

        var url = "LookupPODisApproveStages.aspx?POID=" + POID + "&POType=M&StageID=" + StageID
        new Ajax.Request(url, {
            method: 'get',
            onSuccess: function(response) {
                LoadDisApprovalStages(response);
            }
        } );
        return false;           // So the submit won't fire this time
    }
}

// Ajax return Routine
function LoadDisApprovalStages(response) {
    var optText = new String();
    var optText = response.responseText;
    var selList = $('DisStages');
    if (selList) {
        // Get rid of any existing options
        while (selList.length > 0)
            selList.remove(0);
    }
    
    if (selList && optText.length > 0) {
        // split options into array of records
        var optLines = optText.split("|%|");    // Record delimiter

        // Now Create Options for Select
        for (var i = 0; i < optLines.length; i++) {
            var optRec = optLines[i].split("|$|");   // value , selected, text
            var optNew = document.createElement('option');
            if (optRec.length == 3) {      // Make sure record parsed to a legit value
                optNew.innerText = optRec[2];
                optNew.value = optRec[0];
                try {
                    selList.add(optNew, null);
                }
                catch(ex) {
                    selList.add(optNew);       // IE Only
                }
                if (optRec[1] == '1') {     // Select it
                    selList.options[i].selected = true;
                }
                if (optRec[0] == '-2') {    // Session Timed out
                    $('btnCommit').disabled = true
                }
            }
        }
    }
    else {
        var optNew = document.createElement('option');
        optNew.innerText = "Error retrieving Stage Info. "
        optNew.value = "-2"
        try {
            selList.add(optNew, null);
        }
        catch(ex) {
            selList.add(optNew);       // IE Only
        }
    }
}       

// Process Lightbox response
function SaveReason() {
    var hdnote = $('hdnNotes');    
    hdnote.value = ""       // Make sure the note is cleared out
    var hdDisStage = $('hdnDisApproveStageID');
    hdDisStage.value = ""
    
    // if Container Div for Text box is not displayed then its a confirm prompt
    if ($('divDis').style.display == "none") {
        hdnote.value = "OK to remove"
        Lightbox.hideAll();     // turn off the lightbox
        if (clickedButton)  // Fire the last Grid button referenced and run click event again
            clickedButton.click();
        else 
            alert("Serious error encountered. Can't find submitting control. Contact Support.");
        return true;
    } 
    else {
        var note = new String();
        var obj = $('txtResponse');
        if (obj) {
            note = obj.value;
            note = note.strip();
            if (note.length > 0) {
                hdnote.value = note;
                obj = $('DisStages');    // Now get the stage ID to send it to.
                hdDisStage.value  = obj.value;
            }
            else {
                hdnote.value = "";
                obj = document.getElementById('lblNewItemMessage')
                if (obj) {
                    obj.innerHTML = "Disapprove canceled because reason was not entered.";
                    //obj.disabled = false;
                }
            }
            Lightbox.hideAll();   
            if (note.length > 0) {
                if (clickedButton)  
                    clickedButton.click();
                else 
                    alert("Serious error encountered. Can't find submitting control. Contact Support.");
            }
            return true;
        }
    }
    return true;
}

////////////////////////////////////////////////////////////////
// Search
///////////////////////////////////////////////////////////////

var clickedBox;  // used to keep track of the last grid button clicked.
var ajaxLookupURL = 'POMaintAjax.aspx';

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
}

function ResetSearch() {

    if ($('srchDept').disabled == false) {
        $('srchDept').selectedIndex = 0;
    }
    
    $('srchPONumber').value = "";
    $('srchBatchNumber').value = "";
    $('srchSKU').value = "";
    $('srchVPN').value = "";
    $('srchUPC').value = "";
    $('UPCMsg').innerHTML = "";
    $('srchStockCat').selectedIndex = 0;
    $('srchWrittenStartDate').value = "";
    $('srchWrittenEndDate').value = "";
    $('srchVendor').value = "";
    $('srchPOStatus').selectedIndex = 0;
    $('srchAllocationEvent').selectedIndex = 0;
    $('srchBasicSeasonal').selectedIndex = 0;
    $('srchLocation').value = "";
    $('srchPODept').selectedIndex = 0;
    $('srchPOType').selectedIndex = 0;
    $('srchInitiator').selectedIndex = 0;
        
    if (obj = $('divResults')) obj.style.display = "none";
    if (obj = $('btnAddRecs')) obj.style.display = "none";
    if (obj = $('lblMessage')) obj.innerHTML = "";
    if (obj = $('txtVendorLookup')) obj.value = "";
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
    new Ajax.Autocompleter("txtVendorLookup", "VendorResults", ajaxLookupURL, {
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
    $('srchVendor').focus();
}


function ShowDDLLoading(objDDL, showLoad, text) {
    if (objDDL != null){
        while (objDDL.length > 0)
            objDDL.remove(0);
        if (showLoad) {
            var optNew = document.createElement('option');
            optNew.text = "Loading... "
            optNew.value = "-2"
            try {
                objDDL.add(optNew, null);
            }
            catch (ex) {
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
                catch (ex) {
                    objDDL.add(optNew);       // IE Only
                }
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

  
////////////////////////////////////////////////////////////////
// End Of Search
///////////////////////////////////////////////////////////////

