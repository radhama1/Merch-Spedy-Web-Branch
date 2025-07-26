var clickedButton;  // used to keep track of the last grid button clicked.
var saveURL = "";   // used to keep track of URL in Link Button that was clicked.

//function beginRequest(sender, args) {
//	//alert("start");
//	window.status = "Please wait...";
//	document.body.style.cursor = "wait";
//}

//function pageLoaded(sender, args) {
//	//alert("end");
//	window.status = "Done";
//	document.body.style.cursor = "default";
//}
	
function ShowSearch() {
    var url = "IMAddRecords.aspx?m=y&bid=0"
    var width = pageWidth() - 20;
    var height = pageHeight() - 20;
    
    if (window.showModalDialog) {
        var features = "dialogHeight:" + height + "px; dialogWidth:" + width + "px; center:yes; resizable:yes;"
        window.showModalDialog(url, "", features);
    } else {
        var features = 'height=' + height + ',width=' + width + ',toolbar=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=yes,modal=yes';
        window.open(url, '', features);
    }

    var button = $('btnFindShow');
    if (button) button.click();
}

//function test() {
//    var button = $('btnFindShow');
//    if (button) button.click();
//}
function ShowHistory(id) {
    var now = new Date();
    var url = 'Batch_History.aspx?hid=' + id + '&modal=1&tstamp=' + now.getTime()
    
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

    var grItems = $('gvBatches');
    var rowElement = grItems.rows[rowIndex];
    /* Test finding the control */
//    var found = false;
//    var cnt=rowElement.cells.length
//    for (var i = 0; i < cnt && !found; i++) {
//        var rowcell = rowElement.cells[i];
//        if (rowcell.firstChild) {
//            if (rowcell.firstChild.tagName == "SELECT") {
//                var str = rowcell.innerText;
//                var selvalue = rowcell.firstChild.value;
//                found = true;
//            }
//        }
//    }
//    if (!found)
//        return false;
//
    // Update cells as necessary to get correct offset.  .Net Visible=false cells don't count in the offset 
    var rowcell = rowElement.cells[9];
    // var str = rowcell.innerText;
     var selvalue = rowcell.querySelector('select').value;
    
    clickedButton = window.event.srcElement;    // Var for the Action GO button that was clicked
    var obj = $('lblNewItemMessage')  // clear out any old error message with a single space
    if (obj) {
        obj.innerHTML = "&nbsp;";
        //obj.disabled = true;
    }
    // REMOVE
    if (selvalue == 3) {
        new Lightbox.base('dvPrompt', { externalControl : 'btnCancel' });
        $('msgHeader').innerHTML = "Confirm Removal";
        $('msgPrompt').innerHTML = "<br /><br />Please confirm you want to Remove this item from the active batches.";
        $('dvDDL').style.display="none";
        $('dvDDL2').style.display = "none";
        $('btnCommit').value = "Yes"
        $('btnCancel').value = "No"
        return false;
    }

    // DISAPPROVE
    if (selvalue == 2) {
        // Update cells as necessary to get correct offset.  .Net Visible=false cells don't count in the offset 
        var BatchID = rowElement.cells[12].querySelector('input').value;
        var StageID = rowElement.cells[13].querySelector('input').value;

        new Lightbox.base('dvPrompt', { externalControl : 'btnCancel' });
        var obj = $('txtResponse');
        if (obj)
            obj.value = "";     // make sure any previous reason is cleared
        $('dvDDL').style.display = "inline";
        $('dvDDL2').style.display = "none";
        $('msgHeader').innerHTML = "Disapprove Batch: " + BatchID ;
        $('msgPrompt').innerHTML = "<br />Please enter the reason you are disapproving this batch.";
        $('txtPrompt').innerHTML = "Reason:";
        $('btnCommit').value = "OK";
        $('btnCancel').value = "Cancel";
        $('txtResponse').style.display = "inline";

        // set up the list of valid stages
        
        var selList = $('ddList');
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
            catch(ex) {
                selList.add(optNew);       // IE Only
            }
        }
        

        var url = "LookupDisApproveStages.aspx?BatchID=" + BatchID + "&StageID=" + StageID
        new Ajax.Request(url, {
            method: 'get',
            onSuccess: function(response) {
                //                LoadDisApprovalStages(response);
            LoadDDL(response, 'ddList')
                return false;
            }
        });
        return false;           // So the submit won't fire this time
    }
}

// Process Lightbox response
function SaveReason() {
    var pipe = $('hdnPipe').value;
    var hdnote = $('hdnNotes');    
    hdnote.value = ""       // Make sure the note is cleared out
    var hdDDList = $('hdnDDListValue');
    hdDDList.value = ""
    
    // if Container Div for Text box is not displayed then its a confirm prompt 
    if ($('dvDDL').style.display == "none")  {
        hdnote.value = "OK to remove"
        Lightbox.hideAll();     // turn off the lightbox
        if (clickedButton)  // Fire the last Grid button referenced and run click event again
            clickedButton.click();
        else
            alert("Serious error encountered. Can't find submitting control. Contact Support.");
        return true;
    }
    else {  // Process DDL and textbox
        // if textbox is shown then it needs to have a value
        var note = new String();
        var objTxt = $('txtResponse');
        if (objTxt) {
            if (objTxt.style.display == "inline") {
                note = objTxt.value;
                note = note.strip();
            }
            else {
                note = "Stage Selected"
            }
            if (note.length > 0) {
                var objDDL = $('ddList');    // Now get the DDList value
                hdDDList.value = objDDL.value;
                if (hdDDList.value < 0) {
                    note = "";
                }
            }
            // check if DDList2 is shown and add to note if it has a value
            if (note.length > 0) {
                var objdiv = $('dvDDL2');
                if (objdiv.style.display == "inline") {
                    var objDDL = $('ddList2');
                    if (objDDL.value <= 0) {
                        note = "";
                    }
                    else {
                        if (note.length > 0) {
                            hdDDList.value += pipe + objDDL.value
                        }
                    }
                }
            }

            if (note.length == 0) {
                hdnote.value = "";
                var msg = document.getElementById('lblNewItemMessage')
                if (msg) {
                    if (objTxt.style.display == "inline")
                        msg.innerHTML = "Disapprove canceled because reason was not entered.";
                    else
                        msg.innerHTML = "Create Batch Canceled because selections were not made";
                }
            }
            else
                hdnote.value = note;
                
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

// Process Create New Item Maint Batch link click
function getMaintType() {
    var obj = $('lnkNewMaint');
    var note = new String();    // if there is something in the hdnHotes field then return true so Page will Postback
    var hdnote = $('hdnNotes')
    note = hdnote.value;
    if (note.length > 0) {
        obj.href = saveURL;     // Restore the url and go
        return true;
    }

    // Save URL so when lightbox is done we can go to it. Do it only once so we don't wipe it out with subsequent clicks before page refresh
    if (saveURL.length == 0) {
        saveURL = obj.href;
        obj.href = "#";
    }

    clickedButton = window.event.srcElement;    // Var for the Action GO button that was clicked
    
    new Lightbox.base('dvNewItem', { externalControl: 'btnCancelNI' });
    var obj = $('txtResponseNI');
    if (obj)
        obj.value = "";     // make sure any previous reason is cleared
    
    $('msgHeaderNI').innerHTML = "Enter Required Info for the Item Maintenance Batch";
    $('msgPromptNI').innerHTML = "";
    $('btnCommitNI').value = "OK";
    $('btnCancelNI').value = "Cancel";
    //$('btnCancelNI').disabled = false;
    $('txtVendorLookup').value = '';
    $('txtVendorLookup').style.backgroundColor = 'white';

    // Load Depts
    ClearDDL('ddListNI');
    ShowLoadingDDL('ddListNI');
    var url = "ItemMaintAJAX.aspx?f=DeptList"
    new Ajax.Request(url, {
        method: 'get',
        onSuccess: function(response) {
            LoadDDL(response, 'ddListNI');
            return false;   // So the submit won't fire this time on return from Server call
        }
    });
    
//    // Load Stock Cat
//    ClearDDL('ddListNI2');
//    ShowLoadingDDL('ddListNI2');
//    url = "ItemMaintAJAX.aspx?f=StockCat"
//    new Ajax.Request(url, {
//        method: 'get',
//        onSuccess: function(response) {
//            LoadDDL(response, 'ddListNI2');
//            return false;   // So the submit won't fire this time on return from Server call
//        }
//    });

//    // Load Item Type Attr
//    ClearDDL('ddListNI3');
//    ShowLoadingDDL('ddListNI3');
//    url = "ItemMaintAJAX.aspx?f=ItemTypeAttr"
//    new Ajax.Request(url, {
//        method: 'get',
//        onSuccess: function(response) {
//            LoadDDL(response, 'ddListNI2');
//            return false;   // So the submit won't fire this time on return from Server call
//        }
//    });
    // Set up Vendor Textbox lookup
    new Ajax.Autocompleter("txtVendorLookup", "VendorResults", "ItemMaintAJAX.aspx", {
        paramName: "value",
        parameters: "f=vendor",
        minChars: 1,
        afterUpdateElement: VendorLookupDone
    });

    $('btnCommitNI').disabled = true;
    return false;           // So the submit won't fire this time
}

function VendorLookupDone() {
    var VendorID = "";
    var VendorName = $('txtVendorLookup').value;
    var i = VendorName.indexOf('-');
    if (i >= 0) {
        VendorID = VendorName.substring(0, i - 1);
        highlightControls('txtVendorLookup');
        $('hidVendorID').value = VendorID;
        var VendorName = $('txtVendorLookup').value;
        var i = VendorName.indexOf('-');
        $('hidVendorName').value = VendorName.substr(i + 2);
        CheckControls();
    }
}

function CheckControls() {
    if ($('hidVendorID').value > 0 && $('ddListNI').value > 0 && $('ddListNI2').value != "" && $('ddListNI3').value != "")
        $('btnCommitNI').disabled = false;
    else
        $('btnCommitNI').disabled = true;
}

function SaveReasonNI() {
    var pipe = $('hdnPipe').value;
    var hdnote = $('hdnNotes');
    hdnote.value = ""       // Make sure the note is cleared out
    var hdDDList = $('hdnDDListValue');
    hdDDList.value = ""
    var bOK = true;

    // Get DDListNI
    var objDDL = $('ddListNI');    // Now get the DDList value Dept No
    if (objDDL.value < 0) {
        note = "";
        bOK = false;
    }
    else {
        hdDDList.value = objDDL.value;
    }

    // Get DDListNI2
    if (bOK) { // continue with Vendor #
        var objDDL = $('ddListNI2');    // Now get the DDList value Stock Cat
        if (objDDL.value == "") {
            note = "";
            bOK = false;
        }
        else {
            hdDDList.value += pipe +objDDL .value;
        }
    }

    // Get DDListNI3
    if (bOK) { // continue with Vendor #
        var objDDL = $('ddListNI3');    // Now get the DDList value Item Type Attr
        if (objDDL.value == "") {
            note = "";
            bOK = false;
        }
        else {
            hdDDList.value += pipe + objDDL.value;
        }
    }

    if (bOK) { // continue with Vendor #
        var Vendor = $('hidVendorID').value;
        if (Vendor.length > 0 ) {
            note = Vendor + pipe + $('hidVendorName').value;
        }
        else {
            note = "";
            bOK = false;
        }
    }        
        
    if (note.length == 0) {
        hdnote.value = "";
        var msg = document.getElementById('lblNewItemMessage')
        if (msg) {
            msg.innerHTML = "Create Batch Canceled because selections were not made.";
        }
    }
    else
        hdnote.value = note;

    Lightbox.hideAll();
    if (note.length > 0) {
        if (clickedButton)
            clickedButton.click();
        else
            alert("Serious error encountered. Can't find submitting control. Contact Support.");
    }
}

function ClearDDL(ddlID) {
    var selList = $(ddlID);
    if (selList) {
        // Get rid of any existing options
        while (selList.length > 0)
            selList.remove(0);
    }
}
function ShowLoadingDDL(ddlID) {
    // Show a Loading Option while calling Ajax routine
    var selList = $(ddlID);
    var optNew = document.createElement('option');
    optNew.text = "Loading... ";
    optNew.value = "-2";
    try {
        selList.add(optNew, null);
    }
    catch (ex) {
        selList.add(optNew);       // IE Only
    }
}


// Load a select control with encoded options
function LoadDDL(response, ddlControl) {
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
            if (optRec.length == 3) {      // Make sure record length parsed to a legit value
                optNew.innerText = optRec[2];
                optNew.value = optRec[0];
                try {
                    objDDL.add(optNew, null);
                }
                catch (ex) {
                    objDDL.add(optNew);       // IE Only
                }
                if (optRec[1] == '1') {     // Select it
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
        catch (ex) {
            objDDL.add(optNew);       // IE Only
        }
    }
}


function clickButton(e, buttonid) {
    var bt = document.getElementById(buttonid);
    if (typeof bt == 'object') {
        if (navigator.appName.indexOf("Netscape") > (-1)) {
            if (e.keyCode == 13) {
                bt.click();
                return false;
            }
        }
        if (navigator.appName.indexOf("Microsoft Internet Explorer") > (-1)) {
            if (event.keyCode == 13) {
                bt.click();
                return false;
            }
        }
    }
}