var isDirty = new Boolean;
isDirty = false;

//// See if the Parent needs a kick in the pants (refresh via postback)
//var refresh = $('hidRefreshParent')
//if (refresh) {
//    if (refresh.value == "1")
//        window.parent.opener.reloadPage();
//}

function CheckStatus(rowIndex) {

    var grItems = $('gvCostChanges');
    if (!grItems) return false;
    //debugger;
    var rowElement = grItems.rows[rowIndex];

    // Update cells as necessary to get correct offset.  .Net Visible=false cells don't count in the offset. Offset starts at 0
    var rowcell = rowElement.cells[5];  // Point to the hidden fields in the row
    var status = rowcell.children[3].value
    if (status == 'Active') {
        var cell3 = rowElement.cells[3];
        cell3.firstChild.innerHTML = 'Canceled';
        var cell4 = rowElement.cells[4];
        cell4.firstChild.value = 'Restore';
        rowcell.children[3].value = 'Canceled';
    }
    else {
        var cell3 = rowElement.cells[3];
        cell3.firstChild.innerHTML = 'Active';
        var cell4 = rowElement.cells[4];
        cell4.firstChild.value = 'Cancel';
        rowcell.children[3].value = 'Active';
    }
    isDirty = true;
    $('msg').innerHTML = "Changes not saved."
    return false;
}

function CloseWindow() {
    if (isDirty) {
        if (!confirm('Changes not Saved. Confirm you wish to close this window and lose your changes.'))
            return;
    }
    window.close();
}

