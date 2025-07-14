// File             : mydlg.js
// Programmer       : John Wong
// Copyright (c) Q-Surf Computing Solutions, 2003-05. All rights reserved.
// http://www.qwebeditor.com

// One object tracks the current modal dialog opened from this window.
var dialogWin=new Object()
var Nav4=((navigator.appName=="Netscape")&&(parseInt(navigator.appVersion)>=4))

function MyDlgHandleOK(obj){
    if (top.opener && !top.opener.closed && top.opener.dialogWin){
        top.opener.dialogWin.returnedValue = obj
        if (top.opener.dialogWin.returnFunc)
            top.opener.dialogWin.returnFunc()
    }
    else 
        window.alert("You have closed the main window.\n\nNo action will be taken on the choices in this dialog box.")
    top.window.close()
    return false
}

// Handle click of Cancel button
function MyDlgHandleCancel(){
    top.window.close()
    return false
}

function MyDlgGetObj(){return top.opener.dialogWin}

// Generate a modal dialog.
// Parameters:
//    url -- URL of the page/frameset to be loaded into dialog
//    width -- pixel width of the dialog window
//    height -- pixel height of the dialog window
//    returnFunc -- reference to the function (on this page)
//                  that is to act on the data returned from the dialog
//    args -- [optional] any data you need to pass to the dialog
function MyDlgOpen(url, width, height, returnFunc, args, callerdata, bResize, strScrolling) {
    if (!dialogWin.win||(dialogWin.win && dialogWin.win.closed)) {
        // Initialize properties of the modal dialog object.
        dialogWin.returnFunc = returnFunc
        dialogWin.returnedValue = null
        dialogWin.args = args
        dialogWin.callerdata = callerdata
        dialogWin.url = url
        dialogWin.width = width
        dialogWin.height = height
        dialogWin.scrolling = strScrolling ? strScrolling : "no"
        // Keep name unique so Navigator doesn't overwrite an existing dialog.
        dialogWin.name = (new Date()).getSeconds().toString()
        var strResize=bResize?"yes":"on"
        // Assemble window attributes and try to center the dialog.
        var attr
        if(Nav4){
            // Center on the main window.
            dialogWin.left=window.screenX+((window.outerWidth-dialogWin.width)/2)
            dialogWin.top=window.screenY+((window.outerHeight-dialogWin.height)/2)
            attr="screenX="+dialogWin.left+",screenY="+dialogWin.top+",resizable="+strResize+",width="+ 
               dialogWin.width+",height="+dialogWin.height
        } else {
            // The best we can do is center in screen.
            dialogWin.left=(screen.width-dialogWin.width)/2
            dialogWin.top=(screen.height-dialogWin.height)/2
            attr="left="+dialogWin.left+",top="+dialogWin.top+",resizable="+strResize+",width="+dialogWin.width+ 
               ",height="+dialogWin.height
        }
        // Generate the dialog and make sure it has focus.
        dialogWin.win=window.open(g_strHtmlEditPath+"dlgfrm.html",dialogWin.name,attr)
        if (!dialogWin.win)
            // window cannot be opened. popup block stopped it?
            alert("Popup window cannot be opened. Please turn off your popup blocker for proper operations.")
        else
            dialogWin.win.focus()
    }else dialogWin.win.focus()
}

// Event handler to inhibit Navigator form element 
// and IE link activity when dialog window is active.
function deadend() {
    if (dialogWin.win && !dialogWin.win.closed) {
        dialogWin.win.focus()
        return false
    }
}

var g_bMyDlgAttachedListener=false

// Disable form elements and links in all frames for IE.
function MyDlgDisableForms() {
    if (!g_bMyDlgAttachedListener) {
        for (var h = 0; h < frames.length; h++) {
        	var e
        	try {
	            AttachEventListener(frames[h], "focus", MyDlgCheckModal)
    	        AttachEventListener(frames[h].document, "click", MyDlgCheckModal)
    	    } catch (e) {}
        }
        g_bMyDlgAttachedListener = true
    }
}

// Restore IE form elements and links to normal behavior.
function MyDlgEnableForms() {
}

// Grab all Navigator events that might get through to form
// elements while dialog is open. For IE, disable form elements.
function MyDlgBlockEvents() {
    if (Nav4) {
        window.captureEvents(Event.CLICK | Event.MOUSEDOWN | Event.MOUSEUP | Event.FOCUS)
        window.onclick = deadend
    } else {
        MyDlgDisableForms()
    }
    window.onfocus = MyDlgCheckModal
}

// As dialog closes, restore the main window's original
// event mechanisms.
function MyDlgUnblockEvents() {
    if (Nav4) {
        window.releaseEvents(Event.CLICK|Event.MOUSEDOWN|Event.MOUSEUP|Event.FOCUS)
        window.onclick=null
        window.onfocus=null
    } else {
        MyDlgEnableForms()
    }
}

// Invoked by onFocus event handler of EVERY frame,
// return focus to dialog window if it's open.
function MyDlgCheckModal() {
    setTimeout("MyDlgFinishChecking()", 50)
    return true
}

function MyDlgFinishChecking() {
    if (dialogWin.win&&!dialogWin.win.closed) {
        dialogWin.win.focus()
        // checking for whether popup opened another popup
        if (dialogWin.win.dlogBody && dialogWin.win.dlogBody.dialogWin)
            dialogWin.win.dlogBody.MyDlgCheckModal()
    }
}
