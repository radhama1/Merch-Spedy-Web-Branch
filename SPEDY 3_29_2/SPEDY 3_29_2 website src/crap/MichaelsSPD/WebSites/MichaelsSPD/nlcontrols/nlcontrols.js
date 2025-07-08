
// nlcontrols.js
/////////////////////////////

function restoreNLCCB(id, val) {
    // debugger;
    var e = $(id);
    var b = (val) ? true : false;
    $(id).checked = b;
    hideNLCWrapper(id);
    var cf = $(id + "_CF");
    if (cf) 
        setCF(cf, "S");
    if (e) {
        fireChangeEvent(e);
    }
}

// Revert DropDown control
function restoreNLCDD(id, val) {
    var e = $(id);
    if (e) {
        for(var i = 0; i < e.options.length; i++){
            if(e.options[i].value == val){
                e.selectedIndex = i;
                break;
            }
        }
    }
    hideNLCWrapper(id);
//    var cf = $(id + "_CF");
//    if (cf) 
//        setCF(cf, "S");

    // Revert complete. Now check for and fire any subordinate onchange events
    if (e) {
        fireChangeEvent(e);
    }
}

function restoreNLCTB(id){
    //debugger;
    var e = $(id);
    var orig = $(id + "_ORIG");
    if (orig && e) {
        var val = orig.value;
        e.value = val;
    }
    hideNLCWrapper(id);
    var cf = $(id + "_CF");
    if (cf)
        setCF(cf, "S");
    if (e) {
        fireChangeEvent(e);
    }
}

function hideNLCWrapper(id){
    var w = $('nlcCCC_' + id);
    var o = $('nlcCCRevert_' + id);
    var r = $('nlcCCOrigC_' + id);
    if (w) {
        w.removeClassName('nlcCCC');
        w.addClassName('nlcCCC_hide');
    }
    if (o) o.addClassName('nlcHide');
    if (r) r.addClassName('nlcHide');
    var lab = $('nlcCCLabel_' + id);
    if (lab) lab.addClassName('nlcHide');
}

// Fire controls onXXX events defined after the onChangeNLC
function fireChangeEvent(obj) {
    var code = new String("");
    if (obj.type == "checkbox") {
        //code = new String(obj.attributes.item("onclick").value);
        code = $(obj).readAttribute("onclick");
    } 
    else {
        //code = new String(obj.attributes.item("onchange").value);
        //code = obj.getAttribute("onchange").toString();
        code = $(obj).readAttribute("onchange");
    }
    if (code.length > 0) {
        var Index = code.indexOf(";",0);    // Get past the first statement (the CC onxxx event)
        if (Index >= 0) {
            code = code.substr(Index + 1);
            code = code.trim();
            if (code.length >0)
                eval(code);
        }
    }
}

function showNLCWrapper(id){
    var w = $('nlcCCC_' + id);
    var o = $('nlcCCRevert_' + id);
    var r = $('nlcCCOrigC_' + id);
    if (w) {
        w.removeClassName('nlcCCC_hide');
        w.addClassName('nlcCCC');
    }
    if (o) o.removeClassName('nlcHide');
    if (r) r.removeClassName('nlcHide');
    var lab = $('nlcCCLabel_' + id);
    if (lab) lab.removeClassName('nlcHide');
}

function compareNLC(id) {
    var e = $(id);
    var orig = $(id + "_ORIG");
    if (orig)
        var val = orig.value;

    if (e && orig) {
        var Same = new Boolean();
        if (e.type == "checkbox")
            Same = (e.checked ==  new Boolean(val.toLowerCase() == "true") )
        else
            Same = (e.value == val);

        if (Same)
            hideNLCWrapper(id);
        else
            showNLCWrapper(id);
    }
//    alert ("Change Flag After: " + cf.value)
}

function onChangeNLC(id) {
    // FJL Feb 2010 - Get original value from control rather than from param
    //debugger;
    var e = $(id);
    //var cf = $(id + "_CF");
    var orig = $(id + "_ORIG");
    if (orig) {
        var val = orig.value;
    }
    var teaz = treatEmptyAsZero(id);
    // alert ("Change Flag Before: " + cf.value + "  Orig Value: " + orig.value);
    if (e && orig) {
        var Same = new Boolean();
        if (e.type == "checkbox") {
            Same = (e.checked ==  new Boolean(val.toLowerCase() == "true") )
        } else {
            if(teaz){
                if(isEmptyOrBlank(e.value) && isEmptyOrBlank(val))
                    Same = true;
                else
                    Same = (e.value == val);
            } else {
                Same = (e.value == val);
            }
        }

        if (Same) {
            hideNLCWrapper(id);
//            if (cf) {
//                setCF(cf,'S');      // current and original values are the same
//            }
        } else {
            showNLCWrapper(id);
//            if (cf) {
//                setCF(cf,'D');      // current and original values are different
//            }
        }
    }
}

// set the control's change flag based on initial state and current state
function setCF(cf,curState) {
    val = new String(cf.value);
    if (val.substr(0,1) == "S") {       // Change Flag indicates initially the same values
        cf.value = curState == "S" ? "Sx" : "SC";
    } 
    else if (val.substr(0,1) == "D") {  // Change Flag indicates initially different values
        cf.value = curState == "S" ? "DR" : "DC";
    }
}

function treatEmptyAsZero(id)
{
    var t = $(id + "_teaz");
    if(t && t.value == '1')
        return true;
    else
        return false;   
}
function isEmptyOrBlank(value) {
    if(isNaN(value))
        return true;
    else if(value.toString() == '' || value.toString() == '0')
        return true;
    else if(isNum(value.toString()) && convertToNumber(value.toString()) == 0)
        return true;
    else 
        return false;
}