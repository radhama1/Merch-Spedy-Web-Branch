
function preloadItemImages()
{
    var img1 = new Image(); img1.src = 'images/tab_po_header_on.gif';
    var img2 = new Image(); img2.src = 'images/tab_po_detail_off.gif';
}

function goUrl(url)
{
    document.location = url;
}

function setPageAsDirty() {
    $('hdnPageIsDirty').value = "1"
}