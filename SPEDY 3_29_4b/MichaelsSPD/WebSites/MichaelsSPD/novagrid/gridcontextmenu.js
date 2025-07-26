/*
function getElement(el)
{
	var tagList = new Object;
	for (var i = 1; i < arguments.length; i++)
		tagList[arguments[i]] = true;
		while ((el!=null) && (tagList[el.tagName]==null))
			el = el.parentElement;
	return el;
}

function highlightRow()
{
	var el = getElement(event.srcElement,"TH","TD");
	if (el==null) return;
	if ((el.tagName=="TD"))
	{
		var row = getElement(el, "TR") ;
		var TABLE = getElement(row, "TABLE");

		if (row.id == "datarow_" + selectedItemID) return;
		if (row.className == "")
			row.className = "rover";
		else
			row.className = "";
	}
}
*/

var ns4 = (document.layers) ? true : false;
var ns6 = (document.getElementById) ? true : false;
var ie4 = (document.all) ? true : false;
var ie5 = false;

if (ie4) {
    if ((navigator.userAgent.indexOf('MSIE 5') > 0) || (navigator.userAgent.indexOf('MSIE 6') > 0)) {
        ie5 = true;
    }
    if (ns6) {
        ns6 = false;
    }
}

var clickRowSrc = 0;

function displayMenu() {
    configureOptions(selectedItemID);
    if (clickRowSrc != 0) {
        if ((hoveredItemID > 0) && (selectedItemID > 0)) {
            if (hoveredItemID == selectedItemID) {
                allowMove = -1;
                placeLayer();
                clickRowSrc = 0;
                contextMenu.style.display = "";
                o3_aboveheight = contextMenu.clientHeight;

                //contextMenu.setCapture();
                setClickTimer(4000);
                var oHandle = document.all ? document.all["grid_row_" + selectedItemID] : document.getElementById("grid_row_" + selectedItemID);
                if (oHandle) prevRowClassName = oHandle.className;
                if (oHandle) oHandle.className = 'selectedRow';
                //if (oHandle && document.images['taskIcon'+selectedItemID]) hTaskBtn('taskIcon'+selectedItemID, true);

                oHandle = document.all ? document.all["fixed_grid_row_" + selectedItemID] : document.getElementById("fixed_grid_row_" + selectedItemID);
                if (oHandle) prevRowClassName = oHandle.className;
                if (oHandle) oHandle.className = 'selectedRow';
                //if (oHandle && document.images['taskIcon'+selectedItemID]) hTaskBtn('taskIcon'+selectedItemID, true);

            }
        }
    }
    else {
        if (hoveredItemID > 0) {
            selectedItemID = hoveredItemID;
            document.getElementById("selectedItemID").value = selectedItemID;
            clickRowSrc = hoveredItemID;
            displayMenu();
        }
    }
}

function hideMenu() {
    //contextMenu.releaseCapture();
    contextMenu.style.display = "none";
    clickRowSrc = 0;
    allowMove = 0;

    var oHandle = document.all ? document.all["grid_row_" + selectedItemID] : document.getElementById("grid_row_" + selectedItemID);
    if (oHandle) oHandle.className = prevRowClassName;
    //if (oHandle && document.images['taskIcon'+selectedItemID]) hTaskBtn('taskIcon'+selectedItemID, false);

    oHandle = document.all ? document.all["fixed_grid_row_" + selectedItemID] : document.getElementById("fixed_grid_row_" + selectedItemID);
    if (oHandle) oHandle.className = prevRowClassName;
    //if (oHandle && document.images['taskIcon'+selectedItemID]) hTaskBtn('taskIcon'+selectedItemID, false);

    hoveredItemID = 0;
    selectedItemID = 0;
}

var clickTimerID = 0;
function switchMenu() {
    el = event.srcElement;
    if (el.className == "menuItem") {
        el.className = "highlightItem";
    }
    else if (el.className == "highlightItem") {
        el.className = "menuItem";
    }
    else {
        setClickTimer(4000);
    }
}

function setClickTimer(intDelay) {
    //	if (clickTimerID > 0) clearTimeout(clickTimerID);
    //	clickTimerID = setTimeout("hideMenu()", intDelay);
}

var selectedItemID = 0;
var hoveredItemID = 0;
var prevRowClassName = "";

function SelectRow(rowID) {
    if (rowID > 0) {
        selectedItemID = rowID;
        document.getElementById("selectedItemID").value = selectedItemID;
    }
    else {
        selectedItemID = 0;
        document.getElementById("selectedItemID").value = 0;
    }
}

function HR(rowID) {

    if (rowID > 0) {
        hoveredItemID = rowID;
        document.getElementById("hoveredItemID").value = hoveredItemID;
    }
    else {
        hoveredItemID = 0;
        document.getElementById("hoveredItemID").value = 0;
    }
}

var menuObj = "";
var allowMove = 0;
var o3_width = 130;
var o3_x = 100;
var o3_offsetx = -10;
var o3_y = 0;
var o3_offsety = 0;
var o3_aboveheight = 80;
var o3_hpos = "";
var o3_vpos = "";

function initPlaceLayers() {
    if ((ns4) || (ie4) || (ns6)) {
        if (ns4) menuObj = document.contextMenu
        if (ie4) menuObj = contextMenu.style
        if (ns6) menuObj = document.getElementById("contextMenu");
    }

    if ((ns4) || (ie4) || (ns6)) {
        document.onmousemove = mouseMove;
        if (ns4) document.captureEvents(Event.MOUSEMOVE);
    }
}

// Moves the layer
function mouseMove(e) {
    //	window.status = "" + event.x + " " + event.y + "";
    if (allowMove == 0) {
        if ((ns4) || (ns6)) { o3_x = e.pageX; o3_y = e.pageY; }
        if ((ie4) || (ie5)) { o3_x = event.x + self.document.body.scrollLeft; o3_y = event.y + self.document.body.scrollTop; }

        placeLayer();
    }
    else {
        //if allowmove == 1, then we've already displayed the contextmenu.  So,
        //every time the user moves their mouse over the available menu options,
        //reset the timer so the menu doesnt close until they stop moving their mouse.

        setClickTimer(4000); //every time the user moves his mouse, reset the click timer.
    }
}

function placeLayer() {
    var placeX, placeY;

    // HORIZONTAL PLACEMENT
    winoffset = (ie4) ? self.document.body.scrollLeft : self.pageXOffset;

    if (ie4) iwidth = self.document.body.clientWidth;
    if (ns4) iwidth = self.innerWidth;
    if (ns6) iwidth = self.outerWidth;

    if ((o3_x - winoffset) > ((eval(iwidth)) / 2)) {
        o3_hpos = "left";
    }
    else {
        o3_hpos = "right";
    }

    if (o3_hpos == "right") {
        placeX = o3_x + o3_offsetx;
        if ((eval(placeX) + eval(o3_width)) > (winoffset + iwidth)) {
            placeX = iwidth + winoffset - o3_width;
            if (placeX < 0) placeX = 0;
        }
    }
    if (o3_hpos == "left") {
        placeX = o3_x - o3_offsetx - o3_width;
        if (placeX < winoffset) placeX = winoffset;
    }

    // VERTICAL PLACEMENT
    scrolloffset = (ie4) ? self.document.body.scrollTop : self.pageYOffset;

    if (ie4) iheight = self.document.body.clientHeight;
    if (ns4) iheight = self.innerHeight;
    if (ns6) iheight = self.outerHeight;

    iheight = (eval(iheight)) / 2;
    if ((o3_y - scrolloffset) > iheight) {
        o3_vpos = "above";
    }
    else {
        o3_vpos = "below";
    }

    if (o3_vpos == "above") {
        if (o3_aboveheight == 0) {
            var divref = (ie4) ? self.document.all['contextMenu'] : menuObj;
            o3_aboveheight = (ns4) ? divref.clip.height : divref.offsetHeight;
        }
        placeY = o3_y - (o3_aboveheight + o3_offsety);
        if (placeY < scrolloffset) placeY = scrolloffset;
    }
    else {
        placeY = o3_y + o3_offsety;
    }

    // Actually move the object.	
    repositionTo(menuObj, placeX, placeY);
    //	window.status = "" + placeX + " " + placeY + ""; return true;
}

// Move a layer
function repositionTo(obj, xL, yL) {
    if ((ns4) || (ie4)) {
        obj.left = xL;
        obj.top = yL;
    }
    else if (ns6) {
        obj.style.left = xL + "px";
        obj.style.top = yL + "px";
    }

}



/*****************************/
/*** page for context menu ***/
/*****************************/

var itemEditURL = '';
var itemDeleteURL = '';
var itemAddURL = '';
var itemViewURL = '';
var itemCustomURL = '';
var itemCustomWidth = '';
var itemCustomHeight = '';

function checkMenuElement(checkValue, menuItemID) {
    var o = document.getElementById(menuItemID);
    if (o) {
        if (checkValue == "1")
            document.getElementById(menuItemID).className = "menuItem";
        else
            document.getElementById(menuItemID).className = "menuItemDisabled";
    }

}

function rowPermissions(allowEdit, allowRemove, allowCreate) {
    this.allowEdit = allowEdit;
    this.allowRemove = allowRemove;
    this.allowCreate = allowCreate;
}

var arRowPermissions = new Array();

function AddRowPermissions(RowID, allowEdit, allowRemove, allowCreate) {
    var i = arRowPermissions.length;
    arRowPermissions[i] = new Array();
    arRowPermissions[i][0] = RowID;
    arRowPermissions[i][1] = new rowPermissions(allowEdit, allowRemove, allowCreate);
}

function getRowPermissions(RowID) {
    var i;
    var obj = null;
    for (i = 0; i < arRowPermissions.length; i++) {
        if (arRowPermissions[i][0] == RowID) {
            obj = arRowPermissions[i][1];
            break;
        }
    }
    return obj;
}

function configureOptions(RowID) {
    if (isNaN(RowID)) {
        checkMenuElement("1", "ItemEdit");
        checkMenuElement("1", "ItemDelete");
        checkMenuElement("1", "ItemAdd");
        return;
    }

    var rowPermissions = getRowPermissions(RowID);
    if (rowPermissions == null) {
        checkMenuElement("1", "ItemEdit");
        checkMenuElement("1", "ItemDelete");
        checkMenuElement("1", "ItemAdd");
        return;
    }

    checkMenuElement(rowPermissions.allowEdit, "ItemEdit");
    checkMenuElement(rowPermissions.allowRemove, "ItemDelete");
    checkMenuElement(rowPermissions.allowCreate, "ItemAdd");
}

function clickMenu() {
    el = event.srcElement;
    if (el.className == "menuItemDisabled") return;

    hideMenu();
    var selectedItemID = document.getElementById("selectedItemID").value; 
    // if (!arRowPermissions[selectedItemID]) return;

    switch (el.id) {
        case "ItemEdit":
            openItemEditorWindow(selectedItemID);
            break;
        case "ItemView":
            openItemViewerWindow(selectedItemID);
            break;
        case "ItemDelete":
            deleteDocument(selectedItemID);
            break;
        case "ItemAdd":
            openItemEditorWindow(0);
            break;
        case "ItemCustom":
            openItemCustomWindow(selectedItemID);
            break;
        default:
            break;
    }
}

function openItemEditorWindow(RowID) {
    var url = '';
    if (!RowID && RowID == null)
        RowID = 0;
    if (RowID == 0) {
        // add
        if (itemAddURL != '')
            url = itemAddURL + ((itemAddURL.indexOf('?') >= 0) ? "&id=" : "?id=") + RowID;
    }
    else {
        // edit
        if (itemEditURL != '')
            url = itemEditURL + ((itemEditURL.indexOf('?') >= 0) ? "&id=" : "?id=") + RowID;
    }
    if (url != '') {
        editWin = window.open(url, "editWindow_" + RowID, "width=1150,height=750,toolbar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=1,resizable=1");
        editWin.focus();
    }
}

function openItemViewerWindow(RowID) {
    var url = '';
    if (!RowID && RowID == null)
        RowID = 0;
    if (RowID == 0) {
        url = '';
    }
    else {
        // view
        if (itemViewURL != '')
            url = itemViewURL + ((itemViewURL.indexOf('?') >= 0) ? "&id=" : "?id=") + RowID;
    }
    if (url != '') {
        viewWin = window.open(url, "viewWindow_" + RowID, "width=1000,height=750,toolbar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=1,resizable=1");
        viewWin.focus();
    }
}

function deleteDocument(RowID) {
    if (itemDeleteURL != '') {
        var url = itemDeleteURL + ((itemDeleteURL.indexOf('?') >= 0) ? "&id=" : "?id=") + RowID;
        if (confirm("Really remove this record?")) {
            document.location = url;
        }
    }
}

function launchNewWin(myLoc, myName, myWidth, myHeight) {
    var myFeatures = "directories=no,dependent=yes,width=" + myWidth + ",height=" + myHeight + ",hotkeys=no,location=no,menubar=no,resizable=yes,screenX=100,screenY=100,scrollbars=yes,titlebar=no,toolbar=no,status=no";
    var newWin = window.open(myLoc, myName, myFeatures);
}

function openItemCustomWindow(RowID) {
    var url = '';
    if (!RowID && RowID == null)
        RowID = 0;
    if (itemCustomURL != '') {
        url = itemCustomURL + ((itemCustomURL.indexOf('?') >= 0) ? "&id=" : "?id=") + RowID;
    }
    if (url != '') {
        editWin = window.open(url, "customWindow_" + RowID, "width=" + ((itemCustomWidth != '') ? itemCustomWidth : "1000") + ",height=" + ((itemCustomHeight != '') ? itemCustomHeight : "750") + ",toolbar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=1,resizable=1");
        editWin.focus();
    }
}