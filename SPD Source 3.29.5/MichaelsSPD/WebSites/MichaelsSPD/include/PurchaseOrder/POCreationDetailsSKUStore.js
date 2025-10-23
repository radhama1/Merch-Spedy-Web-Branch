
function SetControls() {
    var refresh = $('hidRefreshParent');
    var windowed = $('hidWindowed');

    if (refresh && windowed) {
        if (refresh.value == "1" && windowed.value == "1") {
            if($('hidCloseWindow').value != "1" && window.parent.opener.document.getElementById('hdnOpenPopup')){
                window.parent.opener.document.getElementById('hdnOpenPopup').value = 'ADDSTOREFOCUS';
            }
            window.parent.opener.SaveCache();
            $('hidRefreshParent').value = "0";
        }
    }
    
    if ($('hidCloseWindow').value == "1") {
        window.location = 'closeform.aspx?r=0';
    }
}

function cancelForm() {
    if (confirm('Cancel your SKU store changes?'))
        window.location = 'closeform.aspx?r=0';
}

function SearchByStore(storeNumber) {
    var num = ""
    var rowCollection = document.getElementById("SKUStoreGrid").rows;
    for (var i = 0; i < rowCollection.length; i++) {
        var cellCollection = rowCollection[i].cells
        if (cellCollection[2].children.length > 0) {
            num = cellCollection[2].children[0].innerHTML;
        }
        else {
            num = cellCollection[2].innerHTML;
        }
        if (storeNumber == num) {
            var element = document.getElementById("SKUStoreGrid").rows[i]
            element.style.backgroundColor = "#F6F6C6";
            cellCollection[2].scrollIntoView();
            cellCollection[2].focus();
        }
        else {
            var element = document.getElementById("SKUStoreGrid").rows[i]
            element.style.backgroundColor = "#dedede"
        }
    }
}

function toggleLightBox(divtotoggle, display, visibility) {
    var xScroll, yScroll;
    if (window.innerHeight && window.scrollMaxY) {
        xScroll = document.body.scrollWidth;
        yScroll = window.innerHeight + window.scrollMaxY;
    }
    else if (document.body.scrollHeight > document.body.offsetHeight) {
        xScroll = document.body.scrollWidth;
        yScroll = document.body.scrollHeight;
    }
    else {
        xScroll = document.body.offsetWidth;
        yScroll = document.body.offsetHeight;
    }

    var windowWidth, windowHeight;
    if (self.innerHeight) {
        windowWidth = self.innerWidth;
        windowHeight = self.innerHeight;
    }
    else if (document.documentElement && document.documentElement.clientHeight) {
        windowWidth = document.documentElement.clientWidth;
        windowHeight = document.documentElement.clientHeight;
    }
    else if (document.body) {
        windowWidth = document.body.clientWidth;
        windowHeight = document.body.clientHeight;
    }

    var adjustedWidth, adjustedHeight;
    if (xScroll < windowWidth) {
        adjustedWidth = windowWidth;
    }
    else {
        adjustedWidth = xScroll;
    }
    if (yScroll < windowHeight) {
        adjustedHeight = windowHeight;
    }
    else {
        adjustedHeight = yScroll;
    }

    var overlay = $(divtotoggle);

    overlay.setStyle(
			{
			    opacity: 0.8,
			    backgroundImage: 'url(images/black_50.png)',
			    backgroundRepeat: 'repeat',
			    height: adjustedHeight + 'px',
			    display: display,
			    visibility: visibility
			});
}

function togglePopup(pDivToToggle, pDisplay, pVisibility) {
    var popup = $(pDivToToggle);
    popup.setStyle(
			{
			    display: pDisplay,
			    visibility: pVisibility
			});
}

function ShowProcessing() {
    toggleLightBox('shadow', 'block', 'visible');
    togglePopup('lightbox', 'block', 'visible');
    togglePopup('StoreSaving', 'block', 'visible');
}

function HideOverlay() {
    toggleLightBox('shadow', 'none', 'hidden');
    togglePopup('StoreSaving', 'none', 'hidden');
    togglePopup('lightbox', 'none', 'hidden');
    return false;
}

function mSaveBeginRequest(sender, args) {
    window.status = "Please wait...";
    document.body.style.cursor = "wait";
    // if a control is defined that caused a postback (not during initial load) or if this is called by a non .net ajax process
    // set it to disabled
    ShowProcessing();
    if ((args) && (args._postBackElement)) {
        var e = $(args._postBackElement.id);
        if (e) e.disabled = true;
    }
}

function mSavePageLoaded(sender, args) {
    window.status = "Done";
    document.body.style.cursor = "auto";
    HideOverlay();
    // Turn control back on if one was passed in with the args parm
    if ((sender) && (sender._postBackSettings) && (sender._postBackSettings.sourceElement)) {
        var e = $(sender._postBackSettings.sourceElement.id);
        if (e) e.disabled = false;
    }
}