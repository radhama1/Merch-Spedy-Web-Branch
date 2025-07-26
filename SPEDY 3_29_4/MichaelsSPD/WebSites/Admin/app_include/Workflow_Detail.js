var clickedButton;  // used to keep track of the last grid button clicked.
var continueValidation = false;

function appl_init() {
    var pgRegMgr = Sys.WebForms.PageRequestManager.getInstance();
    // No Bore postback handler needed
    // pgRegMgr.add_beginRequest(BeginHandler); 
    pgRegMgr.add_endRequest(EndHandler);
}

// Run after AJAX postback ends
function EndHandler() { 
    CheckScroll();
}

// Run before Ajax postback occurs
function BeginHandler() {
}


function CheckSecurity() {
    // Get hooks to Script manager AJAX handlers
    //    Sys.WebForms.PageRequestManager.getInstance().add_beginRequest(BeginRequestHandler);
    //    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler);

    var closeme = $('hdnCloseme').value;
    if (closeme == '1')
        closeWin();

     //uncomment for testing
      //return;

//    if (window.opener) { }
//    else {
//        window.close;
//        window.location = 'login.asp';
//    }
}

// When exceptions div is scrolled then save where its at
function saveScroll() {
    var ctl = $('hdnScrollTo');
    if (ctl) {
        ctl.value = divExceptions.scrollTop;
    }
}

// reset Exceptions Dive to whre it was. Note if exception is added then 100 is added to the scroll position.
function CheckScroll() {
    var ctl = $('hdnScrollTo');
    if (ctl && ctl.value != "") {
        //self.setTimeout("ScrollTo(" + ctl.value +")", 200);
        divExceptions.scrollTop = ctl.value
    }
}

function openDepartSet(excorder, condorder, extype, fn) {
    var s = $(fn)
    if (s) {
        var id = $('txtName').value;
        var url = 'SetDeptForExc.aspx?id=' + id + "&ExcOrder=" + excorder + "&CondOrder=" + condorder + "&ExcType=" + extype + "&s=" + s.value + "&f=" + fn;
        //alert (url);
        var win = window.open(url, 'Dept', 'scrollbars=0,location=0,menubar=0,top=200,left=400,titlebar=1,toolbar=0,width=400,HEIGHT=600');
        win.focus();
    }
}

function openFieldSet(exception, condition, fn) {
    var s = $(fn)
    if (s) {
        //alert(s.value);
        var stageName = $('txtName').value;
        var id = $('hdnCurrentStageId').value;
        var url = 'SetFieldsForExc.aspx?id=' + id + "&StageName=" + stageName + "&ExcOrder=" + exception + "&CondOrder=" + condition + "&s=" + s.value +"&f=" + fn;
        var win = window.open(url, 'excFields', 'scrollbars=0,location=0,menubar=0,top=200,left=400,titlebar=1,toolbar=0,width=400,HEIGHT=600');
        win.focus();
    }
}

function openInitSet(exception, condition, fn) {
    var s = $(fn)
    if (s) {
        //alert(s.value);
        var id = $('hdnCurrentStageId').value;
        var url = 'SetInitForExc.aspx?id=' + id + "&ExcOrder=" + exception + "&CondOrder=" + condition + "&s=" + s.value + "&f=" + fn;
        var win = window.open(url, 'Initiators', 'scrollbars=0,location=0,menubar=0,top=200,left=400,titlebar=1,toolbar=0,width=400,HEIGHT=600');
        win.focus();
    }
}

function RemoveBtnClickEx(excnum, exctype) {
    if (exctype == 'A') {
        var idholdername = 'hdnIdofExc' + excnum;
    }
    else {
        var idholdername = 'hdnIdofDAExc' + excnum;
    }
    var id = $(idholdername).value;
    var ret;
    if (id > 0) {
        return confirm('Are you sure you want to delete this Exception? It will be permanently removed!');
    }
    else {
        return true;
    }
}

function AddExcClick(exctype) {
    if (exctype == 'A') {
        var exccount = $('hdnAddedApprExcept').value;
    }
    else {
        var exccount = $('hdnAddedDisApprExcept').value;
    }
    if (exccount == 19) {
        alert("Only 20 Exceptions are allowed at the moment!");
        return false;
    }
}

String.prototype.trim = function() {
    return this.replace(/^\s+|\s+$/g, "");
}

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

// Use AJAX to validate Seq # is unique and that it is less than the seq # of the Approval Stage
// Error if not unique or > than Next Approval stage (when current stage <> completed)
// Don't perform this test when its a new stage as the next stage may not exist yet

function CheckSeq() {
    var seqNo = $('txtSequence').value;
    if (seqNo == '' || !isInteger(seqNo)) {
        ShowSeqError('');
        return false;
    }

    var StageID = $('hdnCurrentStageId').value;
    if (StageID == 0) {
        if (clickedButton) {
            continueValidation = true;
        }
        return true;
    }

    var nextStages = $('ddNextStage').value;
    var ok = true;
    for (var i = 1; (i <= 10 && ok); i++) {   // add in any exception Approval stages
        var x = $('DDApprStageExc' + i)
        if (x) {
            if (x.value != "0")
                nextStages += '|$|' + x.value;
        }
        else
            ok = false;
    }

    var wfID = $('hdnWorkflowId').value;
    var prevStage = $('ddDisapprovalStage').value;

    var url = "WorkflowAJAX.aspx?SeqID=" + seqNo + "&NextStage=" + nextStages + "&wfid=" + wfID + "&StageID=" + StageID + "&PrevStage=" + prevStage
    new Ajax.Request(url, {
        method: 'get',
        onSuccess: function(response) {
            var res = response.responseText.split('|')
            if (res[0] == '0') {
                ShowSeqError(res[1]);
            }
            else {
                if (clickedButton) {
                    continueValidation = true;
                    clickedButton.click();  // Click the button so rest of validation will work
                }
            }
        }
    });
    return false;           // So the submit won't fire this time
}

function ShowSeqError(msg) {
    if (msg.length > 0)
        alert("Sequence Validation Error\n\n" + msg + "\n\nSequence Number must follow these rules:\n   1. Must be a unique postive integer.\n   2. Must be Less than the Sequence # of all Stages\n       that are specified as Approval Stages.\n   3.Must be Greater than the Sequence # of the\n       Default DisApproval Stage.");

    else
        alert("Sequence Validation Error\n\nSequence Number must follow these rules:\n   1. Must be a unique postive integer.\n   2. Must be Less than the Sequence # of all Stages\n       that are specified as Approval Stages.\n   3.Must be Greater than the Sequence # of the\n       Default DisApproval Stage.");
}

function SaveButtonClick() {

    if (!continueValidation) {
        clickedButton = window.event.srcElement;    // Var for the Action GO button that was clicked
        if (!CheckSeq() )
            return false;       // so submit won't fire
    }

    // FJL Feb 2010 Ensure that Primary Approver is included in the lstGroupList
    var strname = $('txtName').value;
    strname = strname.trim();
    var ddnextstage = $('ddNextStage').value;
    var ddpriorStage = $('ddDisapprovalStage').value;
    var stagetype = $('ddStageType').value;
    var grpitemscount = $('lstGroupList').options.length;
    var StageID = $('hdnCurrentStageId').value;
    var objPriApprover = $('ddPrimaryApprover');
    var objGroups = $('lstGroupList');

    if (stagetype !=3 && stagetype !=4) {   // If stagetype is not completed or Waiting for SKU
        if (objPriApprover && objGroups) {
            var OK = false
            var iCount = objGroups.length;
            for (var i = 0; (i < iCount && !OK); i++) {
                if (objPriApprover.value == objGroups[i].value) {
                    OK = true
                }
            }
            if (!OK) {
                alert("Validation Error \n\nThe Primary Approver must be part of the Selected Approver list.");
                objPriApprover.focus();
                return false;
            }
        }
    }

    if (strname == '') {
        alert("Stage Name is a required field!");
        strname.focus();
        return false;
    }
    
    if (ddnextstage != 0) {
        if (grpitemscount == 0 && stagetype !=3 && stagetype !=4) {
            alert('At least one Approval Group is required!');
            return false;
        }
    }
    else {
        if (stagetype != 4  && StageID != 0) {
            alert('Default Next Stage is a required field!');
            return false;
        }
    }
    
    if (ddpriorStage == 0 && StageID != 0) {
        if ( (stagetype != 4 && stagetype != 5) ) {     // Not Completed and not Vendor
            alert('Default Disapproval Stage is a required field!');
            return false;
        }
    }
    // Make sure that if an exception has a condition, it also has a stage exception
    var ok = true;
    for (var stage = 1; stage <= 20 && ok; stage += 1) {
        var curStage = $('pnlException' + stage);
        if (curStage) {
            var gotoStage = $('DDApprStageExc' + stage);
            var condOne = $('ddCondExc' + stage);
            if (gotoStage && condOne) {
                if ((gotoStage.value == "0" && condOne.value != "0") || (gotoStage.value != "0" && condOne.value == "0")) {
                    alert('If you specify an Exception Stage or Exception Condition, then you must select both.');
                    if (gotoStage.value == "0")
                        gotoStage.focus();
                    else
                        condOne.focus();
                    return false;
                }
            }
        }
        else
            ok = false;
    }
    return true;
}

function CloseButtonClick() {
    var myFrameSetRef = new Object(parent.window.opener.parent.frames['DetailFrame']);
    if (typeof (myFrameSetRef == 'object')) {
        myFrameSetRef.document.location.reload();
    }
    else {
        window.opener.location.reload();
    }
    window.close();
    return false;
}

function RefreshParent() {
    if (window.opener) {
        var myFrameSetRef = new Object(parent.window.opener.parent.frames['DetailFrame']);
        if (typeof (myFrameSetRef == 'object')) {
            myFrameSetRef.document.location.reload();
        }
        else {
            window.opener.location.reload();
        }
    }
}

function closeWin() {
    if (window.opener) window.opener.location.reload();
    window.close();
}
