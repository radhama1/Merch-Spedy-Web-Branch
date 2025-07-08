
var reportstartdate1;
var reportenddate1;

function initPage()
{
    reportstartdate1 = new Spry.Widget.ValidationTextField("reportStartDate", "date", {format:"mm/dd/yyyy", isRequired:false, validateOn:["change"], useCharacterMasking:true});
    reportenddate1 = new Spry.Widget.ValidationTextField("reportEndDate", "date", { format: "mm/dd/yyyy", isRequired: false, validateOn: ["change"], useCharacterMasking: true });
    GetStages();
    GetPOStages();
}

var opboxdrag = null;
var opboxid = '0';

function openReport(link, rptid, rptConst, rptoutput, rptname, rptDateRangeLabel, showstartdate, showenddate, showdept, showworkflow, showstage, showItemStatus, isVendorLoaded, showVendorFilter, showSKU, showSKUGroup, showStockCat, showItemType, showApprover, showHours, showMssOrSpedy, showPLIFrench, showPOStockCategory, showPOStatus, showPOType, showPOStage) {
    if (showstartdate == null || !showstartdate) showstartdate = false;
    if (showenddate == null || !showenddate) showenddate = false;
    if (showdept == null || !showdept) showdept = false;
    if (showworkflow == null || !showworkflow) showworkflow = false;
    if (showstage == null || !showstage) showstage = false;
    if (showItemStatus == null || !showItemStatus) showItemStatus = false;
    if (showVendorFilter == null || !showVendorFilter) showVendorFilter = false;
    if (showSKU == null || !showSKU) showSKU = false;
    if (showSKUGroup == null || !showSKUGroup) showSKUGroup = false;
    if (showStockCat == null || !showStockCat) showStockCat = false;
    if (showItemType == null || !showItemType) showItemType = false;
    if (showApprover == null || !showApprover) showApprover = false;
    if (showHours == null || !showHours) showHours = false;
    if (showMssOrSpedy == null || !showMssOrSpedy) showMssOrSpedy = false;
    if (showPLIFrench == null || !showPLIFrench) showPLIFrench = false;
    if (showPOStockCategory == null || !showPOStockCategory) showPOStockCategory = false;
    if (showPOStatus == null || !showPOStatus) showPOStatus = false;
    if (showPOType == null || !showPOType) showPOType = false;
    if (showPOStage == null || !showPOStage) showPOStage = false;

    if(opboxid != '0')
        reportOptionsClose();
    var o = $('opBox');
    var rptoptions = '';
    //var ctl = $('btnDuplicate');
    if(o && link) {
        // set the id
        opboxid = rptid;
        // setup the controls 
        $('reportName').innerText = rptname;
        $('reportID').value = rptid;
        $('reportConstant').value = rptConst;
        $('reportOutput').value = rptoutput;
        $('reportStartDate').value = "";
        $('reportEndDate').value = "";
        $('reportDept').selectedIndex = 0;
        $('reportStage').selectedIndex = 0;
        $('reportPOStage').selectedIndex = 0;
        
        //Reset Date Range Label 
        if (rptDateRangeLabel.length > 0) {
            $('lblDateRange').innerText = rptDateRangeLabel;
        }
        else {
            $('lblDateRange').innerText = 'Batch Last Modified Date Range';
        }

        if (showstartdate) { Element.show($('reportStartDateRow')); rptoptions += '1'; } else { Element.hide($('reportStartDateRow')); rptoptions += '0'; }
        if (showenddate) {Element.show($('reportEndDateRow')); rptoptions += '1';} else {Element.hide($('reportEndDateRow')); rptoptions += '0';}
        if (showHours) { Element.show($('reportHoursRow')); rptoptions += '1'; } else { Element.hide($('reportHoursRow')); rptoptions += '0'; }
        if (showdept) { Element.show($('reportDeptRow')); rptoptions += '1'; } else { Element.hide($('reportDeptRow')); rptoptions += '0'; }
        if (showworkflow) { Element.show($('reportWorkflowRow')); rptoptions += '1'; } else { Element.hide($('reportWorkflowRow')); rptoptions += '0'; }
        if (showstage) { Element.show($('reportStageRow')); rptoptions += '1'; } else { Element.hide($('reportStageRow')); rptoptions += '0'; }
        if (showItemStatus) { Element.show($('reportItemStatusRow')); rptoptions += '1'; } else { Element.hide($('reportItemStatusRow')); rptoptions += '0'; }
        if (showSKU) { Element.show($('reportSKURow')); rptoptions += '1'; } else { Element.hide($('reportSKURow')); rptoptions += '0'; }
        if (showSKUGroup) { Element.show($('reportSKUGroupRow')); rptoptions += '1'; } else { Element.hide($('reportSKUGroupRow')); rptoptions += '0'; }
        if (showStockCat) { Element.show($('reportStockCategoryRow')); rptoptions += '1'; } else { Element.hide($('reportStockCategoryRow')); rptoptions += '0'; }
        if (showItemType) { Element.show($('reportItemTypeRow')); rptoptions += '1'; } else { Element.hide($('reportItemTypeRow')); rptoptions += '0'; }
        //Only display the Vendor Filter if the user did not log in via vendor connect
        if (showVendorFilter && !isVendorLoaded) { Element.show($('reportVendorRow')); rptoptions += '1'; } else { Element.hide($('reportVendorRow')); rptoptions += '0'; }
        if(showstartdate || showenddate) {Element.show($('reportDateRange'));} else {Element.hide($('reportDateRange'));}
        if((showstartdate || showenddate) && (showdept || showstage)) {Element.show($('reportDateRange2'));} else {Element.hide($('reportDateRange2'));}
        if (!showstartdate && !showenddate && !showdept && !showstage) { Element.show($('reportNoOptions')); } else { Element.hide($('reportNoOptions')); }
        if (showApprover) { Element.show($('reportApproverRow')); rptoptions += '1'; } else { Element.hide($('reportApproverRow')); rptoptions += '0'; }
        if (showMssOrSpedy) { Element.show($('reportMssOrSpedyRow')); rptoptions += '1'; } else { Element.hide($('reportMssOrSpedyRow')); rptoptions += '0'; }
        if (showPLIFrench) { Element.show($('reportPLIFrenchRow')); rptoptions += '1'; } else { Element.hide($('reportPLIFrenchRow')); rptoptions += '0'; }
        if (showPOStockCategory) { Element.show($('reportPOStockCategoryRow')); rptoptions += '1'; } else { Element.hide($('reportPOStockCategoryRow')); rptoptions += '0'; }
        if (showPOStatus) { Element.show($('reportPOStatusRow')); rptoptions += '1'; } else { Element.hide($('reportPOStatusRow')); rptoptions += '0'; }
        if (showPOType) { Element.show($('reportPOTypeRow')); rptoptions += '1'; } else { Element.hide($('reportPOTypeRow')); rptoptions += '0'; }
        if (showPOStage) { Element.show($('reportPOStageRow')); rptoptions += '1'; } else { Element.hide($('reportPOStageRow')); rptoptions += '0'; }
        $('reportOptions').value = rptoptions;
        
        // position the div
        var wh;
        // the more standards compliant browsers (mozilla/netscape/opera/IE7) use window.innerWidth and window.innerHeight
        if (typeof window.innerWidth != 'undefined')
        {
          wh = window.innerHeight
        }
        // IE6 in standards compliant mode (i.e. with a valid doctype as the first line in the document)
        else if (typeof document.documentElement != 'undefined' && typeof document.documentElement.clientWidth != 'undefined' && document.documentElement.clientWidth != 0)
        {
           wh = document.documentElement.clientHeight
        }
        // older versions of IE
        else
        {
           wh = document.getElementsByTagName('body')[0].clientHeight
        }
		if(link != undefined && link != null)
		{
			var newXPos = Element.positionedOffset(link).left + (link.offsetWidth) - 175;
			if(newXPos < 0)
			    newXPos = 0;
			var newYPos = Element.positionedOffset(link).top + link.offsetHeight;
			
			o.style.left = newXPos;
			o.style.top = newYPos - 4;
		}
        // show the div
        Element.show(o);
		if(newYPos + o.offsetHeight > wh){
		    newYPos = wh - o.offsetHeight;
		    o.style.top = newYPos - 4;
		}
        // setup the draggable
        opboxdrag = new Draggable('opBox');// , {handle:'dupItemHeader'});
    }
}

function reportOptionsClose()
{
    var o = $('opBox')
    if(o) {
        // clear the controls
        $('reportStartDate').value = "";
        $('reportEndDate').value = "";
        $('reportHoursDelayed').value = "";
        $('reportDept').selectedIndex = 0;
        $('reportStage').selectedIndex = 0;
        $('reportItemStatus').value = "";
        $('reportSKU').value = "";
        $('reportSKUGroup').value = "";
        $('reportStockCategory').value = "";
        $('reportItemType').selectedIndex = 0;
        $('reportVendorNum').value = "";
        $('reportWorkflow').selectedIndex = 0;
        $('reportApprover').value = $('hdnUserID').value;
        $('reportMssOrSpedy').selectedIndex = 0;
        $('reportPLIFrench').selectedIndex = 0;
        $('reportPOStockCategory').selectedIndex = 0;
        $('reportPOStatus').selectedIndex = 0;
        $('reportPOType').selectedIndex = 0;
        $('reportPOStage').selectedIndex = 0;

        Element.hide($('opBoxErrorMessage'));
        Element.show($('opBoxMessage'));
        // hide the div
        Element.hide(o);
        // clear the draggable
        if(opboxdrag != null) {
            opboxdrag.destroy();
            opboxdrag = null;
        }
    }
    // clear the id
    opboxid = '0';
}

function runReport()
{
    Element.hide($('opBoxErrorMessage'));
    Element.show($('opBoxMessage'));
    var rptid = $('reportID').value;
    var rptConst = $('reportConstant').value;
    var rptoutput = $('reportOutput').value;
    var rptoptions = $('reportOptions').value;
    
    var sd = $('reportStartDate').value;
    var ed = $('reportEndDate').value;
    var hours = $('reportHoursDelayed').value;
    var dept = $('reportDept').options[$('reportDept').selectedIndex].value;
    var stage = $('reportStage').options[$('reportStage').selectedIndex].value;
    var itemStatus = $('reportItemStatus').value;
    var itemType = $('reportItemType').options[$('reportItemType').selectedIndex].value;
    var sku = $('reportSKU').value;
    var skuGroup = $('reportSKUGroup').value;
    var stockCategory = $('reportStockCategory').value;
    var vendorNum = $('reportVendorNum').value;
    var workflowID = $('reportWorkflow').options[$('reportWorkflow').selectedIndex].value;
    var approver = $('reportApprover').options[$('reportApprover').selectedIndex].value;
    var mssOrSpedy = $('reportMssOrSpedy').options[$('reportMssOrSpedy').selectedIndex].value;
    var pliFrench = $('reportPLIFrench').options[$('reportPLIFrench').selectedIndex].value;
    var poStockCategory = $('reportPOStockCategory').options[$('reportPOStockCategory').selectedIndex].value;
    var poStatus = $('reportPOStatus').options[$('reportPOStatus').selectedIndex].value;
    var poType = $('reportPOType').options[$('reportPOType').selectedIndex].value;
    var poStage = $('reportPOStage').options[$('reportPOStage').selectedIndex].value;
    var url = '';
    var msg = '';
    var isValid = true;
    
    if(isReportOption(rptoptions, 0)) {
        // start date
        if (!(sd == "" || (sd != "" && isDate2(sd)) || sd == "99/99/9999") ){
            if(msg != '') msg += '<br />';
            msg += "Start Date is not valid.";
            isValid = false;
        }
    }
    if(isReportOption(rptoptions, 1)) {
        // end date
        if (!(ed == "" || (ed != "" && isDate2(ed)) || ed == "99/99/9999") ){
            if(msg != '') msg += '<br />';
            msg += "End Date is not valid.";
            isValid = false;
        }
    }
    if(!isInteger(hours)){
        msg += "Hours must be a whole number.";
        isValid = false;
    }

    /*
    if(isReportOption(rptoptions, 2)) {
        // dept
    }
    */
    /*
    if(isReportOption(rptoptions, 3)) {
        // stage
    }
    */
    
    if (isValid) {
        //Throw soft warning if date range is over 2 months
        var dateConfirm = false;
        if (sd.length > 0 || ed.length > 0) {
            var startDate = new Date(sd);
            var endDate = new Date(ed);

            if (startDate == "Invalid Date") {
                startDate = new Date('1/1/1990');
            }
            if (endDate == "Invalid Date") {
                endDate = new Date();
            }

            var diffDate = dateDiff(startDate, endDate);
            if (diffDate > 91 && rptoutput != "email") {
                alert('The date range you have selected is too large.  Please select a date range less than 3 months.');
            }
            else if (rptConst == "PO_DETAIL" && diffDate > 91 && rptoutput == "email") {
                if (confirm('The date range filter exceeds 90 days and might cause performance issues.  Are you sure you want to continue?')) {
                    dateConfirm = true;
                }
            }
            else{
                if (diffDate >= 60 && rptoutput != "email") {
                    dateConfirm = confirm("Warning: you have selected a date range that may take a long time to process. Please consider running this as an emailed report. Do you wish to continue?")
                }
                else {
                    dateConfirm = true;
                }
            }
        }
        else if (rptConst == "PO_DETAIL" && sd.length == 0 && ed.length == 0 && rptoutput != "email") {
            alert('Date range you selected is too large, please select the date range less than 3 months');
        }
        else if (rptConst == "PO_DETAIL" && sd.length == 0 && ed.length == 0 && rptoutput == "email") {
            if (confirm('The date range filter exceeds 90 days and might cause performance issues.  Are you sure you want to continue?')) {
                dateConfirm = true;
            }
        }
        else {
            dateConfirm = true;
        }

        if (dateConfirm){
            reportOptionsClose();
            var url = rptid + '&startdate=' + URLEncodeStr(sd) + '&enddate=' + URLEncodeStr(ed) + '&dept=' + URLEncodeStr(dept) + '&stage=' + URLEncodeStr(stage) + '&itemstatus=' + URLEncodeStr(itemStatus) + '&sku=' + URLEncodeStr(sku) + '&skuGroup=' + URLEncodeStr(skuGroup) + '&stockcategory=' + URLEncodeStr(stockCategory) + '&itemtype=' + URLEncodeStr(itemType) + '&vendorfilter=' + URLEncodeStr(vendorNum) + '&workflowID=' + URLEncodeStr(workflowID) + '&approver=' + URLEncodeStr(approver) + '&hours=' + URLEncodeStr(hours) + '&mssorspedy=' + URLEncodeStr(mssOrSpedy) + '&plifrench=' + URLEncodeStr(pliFrench) + '&poStockCategory=' + URLEncodeStr(poStockCategory) + '&poStatus=' + URLEncodeStr(poStatus) + '&poType=' + URLEncodeStr(poType) + '&poStage=' + URLEncodeStr(poStage);
            switch (rptoutput)
            {
                case "excel":
                    url = 'reportexcel.aspx?id=' + url;
                    document.location = url;
                    break;
                case "email":
                    url = 'reportemail.aspx?id=' + url;
                    var win = window.open(url, "reportemailview" + rptid, "directories=no,height=200,width=415,menubar=no,resizable=yes,scrollbars=yes,status=no,titlebar=no,toolbar=no", true);
                    win.focus();
                    break;
                default:
                    url = 'report.aspx?id=' + url;
                    var win = window.open(url, "reportview" + rptid, "directories=no,height=600,width=955,menubar=no,resizable=yes,scrollbars=yes,status=no,titlebar=no,toolbar=no", true);
                    win.focus();
                    break;
            }
        }

    } else {
        // hide message
        Element.hide($('opBoxMessage'));
        // show error message
        $('opBoxErrorMessage').innerHTML = msg;
        Element.show($('opBoxErrorMessage'));
    }
}

function dateDiff(dateEarlier, dateLater) {
    var one_day = 1000 * 60 * 60 * 24
    return (Math.round((dateLater.getTime() - dateEarlier.getTime()) / one_day));
}

// ----------------------------------------------------------------- //
// ----------------------------------------------------------------- //

function isReportOption(optionsval, index)
{
    if(optionsval.length > index){
        if(optionsval.substr(index, 1) == '1')
            return true;
        else
            return false;
    }
    else
        return false;
}

function isDate2(dtStr){
    var daysInMonth = DaysArray(12);
    var pos1 = dtStr.indexOf(dtCh);
    var pos2 = dtStr.indexOf(dtCh, pos1 + 1);
    var strMonth = dtStr.substring(0, pos1);
    var strDay = dtStr.substring(pos1 + 1, pos2);
    var strYear = dtStr.substring(pos2 + 1);
    strYr = strYear;
    if (strDay.charAt(0) == "0" && strDay.length > 1) 
        strDay = strDay.substring(1);
    if (strMonth.charAt(0) == "0" && strMonth.length > 1) 
        strMonth = strMonth.substring(1);
    for (var i = 1; i <= 3; i++) {
        if (strYr.charAt(0) == "0" && strYr.length > 1) 
            strYr = strYr.substring(1);
    }
    month = parseInt(strMonth);
    day = parseInt(strDay);
    year = parseInt(strYr);
    if (pos1 == -1 || pos2 == -1) {
        return false;
    }
    if (strMonth.length < 1 || month < 1 || month > 12) {
        return false;
    }
    if (strDay.length < 1 || day < 1 || day > 31 || (month == 2 && day > daysInFebruary(year)) || day > daysInMonth[month]) {
        return false;
    }
    if (strYear.length != 4 || year == 0 || year < minYear || year > maxYear) {
        return false;
    }
    if (dtStr.indexOf(dtCh, pos2 + 1) != -1 || isInteger(stripCharsInBag(dtStr, dtCh)) == false) {
        return false;
    }
    return true;
}

var dtCh = "/";
var minYear = 1900;
var maxYear = 2100;

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

function getNumberFromString(s){
    var i;
    var ret = "";
    var bfirst = true;
    for (i = 0; i < s.length; i++) {
        var c = s.charAt(i);
        if (((c >= "0") && (c <= "9")) || c == ".") 
            ret += c;
        else {
            // include '-' if first character before the numbers
            if (c == "-" && ret == "" && bfirst) 
                ret += c;
            if (c != " " && bfirst) 
                bfirst = false;
        }
    }
    // All characters are numbers or a "."
    return ret;
}

function getNumberPrefix(s){
    var i;
    var ret = "";
    for (i = 0; i < s.length; i++) {
        var c = s.charAt(i);
        if (((c < "0") || (c > "9")) && c != ".") 
            ret += c;
        else 
            break;
    }
    // All characters are numbers or a "."
    return ret;
}

function getNumberSuffix(s){
    var i;
    var ret = "";
    for (i = (s.length - 1); i >= 0; i--) {
        var c = s.charAt(i);
        if (((c < "0") || (c > "9")) && c != ".") 
            ret = c + ret;
        else 
            break;
    }
    // All characters are numbers or a "."
    return ret;
}

function stripCharsInBag(s, bag){
    var i;
    var returnString = "";
    // Search through string's characters one by one.
    // If character is not in bag, append to returnString.
    for (i = 0; i < s.length; i++) {
        var c = s.charAt(i);
        if (bag.indexOf(c) == -1) 
            returnString += c;
    }
    return returnString;
}

function daysInFebruary(year){
    // February has 29 days in any year evenly divisible by four,
    // EXCEPT for centurial years which are not also divisible by 400.
    return (((year % 4 == 0) && ((!(year % 100 == 0)) || (year % 400 == 0))) ? 29 : 28);
}

function DaysArray(n){
    for (var i = 1; i <= n; i++) {
        this[i] = 31
        if (i == 4 || i == 6 || i == 9 || i == 11) {
            this[i] = 30
        }
        if (i == 2) {
            this[i] = 29
        }
    }
    return this
}


function ShowDDLLoading(objDDL, showLoad, text) {
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

// Get List of Stages for Workflow
function GetStages() {
    var w = $("reportWorkflow");
    if (w) {
        var wid = w.value;
        obj = $('reportStage');
        ShowDDLLoading(obj, true, "");
        var url = "ReportListAJAX.aspx?f=stage&w=" + wid;
        new Ajax.Request(url, {
            method: 'get',
            onSuccess: function(response) {
            LoadDDL(response, 'reportStage', "");
            }
        });
    }
}


// Get List of Stages for PO Workflow
function GetPOStages() {
    var w = $("reportPOType");
    if (w) {
        var wid;
        if (w.value == 'C') {
            wid = 3;
        }
        else {
            wid = 4;
        }
        obj = $('reportPOStage');
        ShowDDLLoading(obj, true, "");
        var url = "ReportListAJAX.aspx?f=stage&w=" + wid;
        new Ajax.Request(url, {
            method: 'get',
            onSuccess: function (response) {
                LoadDDL(response, 'reportPOStage', "");
            }
        });
    }
}


// Load a select control with encoded options
function LoadDDL(response, ddlControl, selValue) {
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
                catch (ex) {
                    objDDL.add(optNew);       // IE Only
                }
                if ((optRec[1] == '1') || (selValue == optRec[0])) {     // Select it
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