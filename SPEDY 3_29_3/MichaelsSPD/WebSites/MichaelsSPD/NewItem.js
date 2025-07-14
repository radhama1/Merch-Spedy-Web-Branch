var clickedButton;  // used to keep track of the last grid button clicked.

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
    note = hdnote.value;
    if (note.length > 0) {
        return true;
    }

    var grItems = document.getElementById('gvNewBatches');
    var rowElement = grItems.rows[rowIndex];
    var rowcell = rowElement.cells[7];
    var selvalue = rowcell.querySelector('select').value;
    
    clickedButton = window.event.srcElement;    // Var for the Action GO button that was clicked
    var obj = document.getElementById('lblNewItemMessage')  // clear out any old error message with a single space
    if (obj) {
        obj.innerHTML = "&nbsp;";
    }
    
    if (selvalue == 3) {
        // REMOVE
        new Lightbox.base('dvPrompt', { externalControl: 'btnCancel' });
        $('msgHeader').innerHTML = "Confirm Removal";
        $('msgPrompt').innerHTML = "<br /><br />Please confirm you want to Remove this item from the active batches.";
        $('dvDDL').style.display = "none";
        $('btnCommit').value = "Yes"
        $('btnCancel').value = "No"
        return false;
    }
    else if (selvalue == 2) {
        // DISAPPROVE
        var BatchID = rowElement.cells[11].querySelector('input').value;
        var StageID = rowElement.cells[12].querySelector('input').value;
        
        new Lightbox.base('dvPrompt', { externalControl: 'btnCancel' });

        var obj = $('txtResponse');
        if (obj) {
            obj.value = "";     // make sure any previous reason is cleared
        }
        $('dvDDL').style.display = "inline";
        $('msgHeader').innerHTML = "Disapprove Batch: " + BatchID;
        $('msgPrompt').innerHTML = "<br />Please enter the reason you are disapproving this batch.";
        $('txtPrompt').innerHTML = "Reason:";
        $('btnCommit').value = "OK";
        $('btnCancel').value = "Cancel";
        // set up the list of valid stages
        var selList = $('ddList'); 
        if (selList) {
            // Get rid of any existing options
            while (selList.length > 0) {
                selList.remove(0);
            }
        }
        
        // Show a Loading Option while calling Ajax routine
        var optNew = document.createElement('option');
        optNew.innerText = "Loading... ";
        optNew.value = "-2";
        
        if (selList) {
            try {
                selList.add(optNew, null);
            }
            catch (ex) {
                selList.add(optNew);       // IE Only
            }
        }
        
        var url = "LookupDisApproveStages.aspx?BatchID=" + BatchID + "&StageID=" + StageID;
        
        new Ajax.Request(url, {
            method: 'get',
            onSuccess: function (response) {
                LoadDisApprovalStages(response);
            }
        });
        return false;           // So the submit won't fire this time
    } 
}

// Ajax return Routine
function LoadDisApprovalStages(response) {
    var optText = new String();
    var optText = response.responseText;
    var selList = $('ddList');
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
                optNew.text = optRec[2];
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
        optNew.text = "Error retrieving Stage Info. "
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
    if ($('dvDDL').style.display == "none") {
        hdnote.value = "OK to remove"
        Lightbox.hideAll();     // turn off the lightbox
        if (clickedButton) {
            // Fire the last Grid button referenced and run click event again
            clickedButton.click();
        } else {
            alert("Serious error encountered. Can't find submitting control. Contact Support.");
        }
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
                obj = $('ddList');    // Now get the stage ID to send it to.
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
                if (clickedButton) {
                    clickedButton.click();
                } else {
                    alert("Serious error encountered. Can't find submitting control. Contact Support.");
                }
                return true;
            }
        }
    }
    return true;
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
  

