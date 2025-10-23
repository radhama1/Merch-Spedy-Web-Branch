
var callbackSep = "{{|}}";
var VALIDATION_IMAGE_UNKNOWN_SM = "images/valid_null_small.gif"
var VALIDATION_IMAGE_NOTVALID_SM = "images/valid_no_small.gif"
var VALIDATION_IMAGE_VALID_SM = "images/valid_yes_small.gif"

var itemViewURL = '';

function setItemHeaderTabValid() { setTabImage('itemHeaderImage', true); }
function setItemHeaderTabInvalid() { setTabImage('itemHeaderImage', false); }
function setItemDetailTabValid() { setTabImage('itemDetailImage', true); }
function setItemDetailTabInvalid() { setTabImage('itemDetailImage', false); }

function setTabImage(tab, valid) 
{
    if(valid == null || !valid) valid = false;
    if(valid) $(tab).src = VALIDATION_IMAGE_VALID_SM; else $(tab).src = VALIDATION_IMAGE_NOTVALID_SM;
}

function updateLastUpdated()
{
    var lu = $('lastUpdated');
    var me = $('lastUpdatedMe');
    if(lu && me) {
        lu.innerHTML = me.value;
    }
}
/*
function openItemViewWindow(RowID)
{
	var url = '';
	if(!RowID && RowID == null)
		RowID = 0;
	if(RowID > 0 && itemViewURL != '')
	    url = itemViewURL + ((itemViewURL.indexOf('?') >= 0) ? "&id=" : "?id=") + RowID;
	if(url != '')
	{
		var viewWin = window.open(url, "viewWindow_" + RowID, "width=980,height=700,toolbar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=1,resizable=0");
		viewWin.focus();
	}
}
*/

function lockImageCell(id, giid)
{
    if ($('B_UpdateImage'+id)) Element.writeAttribute($('B_UpdateImage'+id), "disabled", "disabled");
    if ($('B_DeleteImage'+id)) Element.writeAttribute($('B_DeleteImage'+id), "disabled", "disabled");
}
function lockMSDSCell(id, giid)
{
    if ($('B_UpdateMSDS'+id)) Element.writeAttribute($('B_UpdateMSDS'+id), "disabled", "disabled");
    if ($('B_DeleteMSDS'+id)) Element.writeAttribute($('B_DeleteMSDS'+id), "disabled", "disabled");
}

function updateImage(id, newid)
{
    var i = $('I_Image'+id);
    if(i){
        var isrc = i.src;
        if (newid != null && isNum(newid)) {
            i.src = 'images/app_icons/icon_jpg_small_on.gif?id=' + newid;
            if($('ImageID'+id)) $('ImageID'+id).value = newid;
            if($('B_UpdateImage'+id)) $('B_UpdateImage'+id).value = 'Update';
            if($('I_Image_Label'+id)) $('I_Image_Label'+id).innerText = '(view)';
            Element.writeAttribute($('B_DeleteImage'+id), "disabled", "");
            
            var cellid = 'gc_'+id+'_'+getGIID('ImageID');
            if($(cellid))
                Element.removeClassName(cellid, 'gCVE');
            
            goValue = "UPDATEIMAGE" + callbackSep + id + callbackSep + newid;
		    CallServer(goValue, "");
        }
    }
}

function updateMSDS(id, newid)
{
    var i = $('I_MSDS'+id);
    if(i){
        var isrc = i.src;
        if (newid != null && isNum(newid)) {
            i.src = 'images/app_icons/icon_pdf_small.gif?id=' + newid;
            if($('MSDSID'+id)) $('MSDSID'+id).value = newid;
            if($('B_UpdateMSDS'+id)) $('B_UpdateMSDS'+id).value = 'Update';
            if($('I_MSDS_Label'+id)) $('I_MSDS_Label'+id).innerText = '(view)';
            Element.writeAttribute($('B_DeleteMSDS'+id), "disabled", "");
            
            var cellid = 'gc_'+id+'_'+getGIID('MSDSID');
            if($(cellid))
                Element.removeClassName(cellid, 'gCVE');
            
            goValue = "UPDATEMSDS" + callbackSep + id + callbackSep + newid;
		    CallServer(goValue, "");
        }
    }
}

function showImage(id)
{
    var imgid;
    var isrc = $('I_Image'+id).src;
    if(isrc.indexOf('id=') > 0){
        imgid = isrc.substring(isrc.indexOf('id=')+3);
        var url = 'getimage.aspx?id=' + imgid;
        var i = window.open(url, "itemimg", "directories=no,height=600,width=955,menubar=no,resizable=yes,scrollbars=yes,status=no,titlebar=no,toolbar=no", true);
        i.focus();
    }else{
        //var cmd = Element.readAttribute('B_UpdateImage'+id, 'onclick'); // loses first 2 chars... boo !
        if($('B_UpdateImage'+id)) {
            if(!isCellLocked(id, getGIID('ImageID'))){
                var cmd = getElementAttribute($('B_UpdateImage'+id), 'onclick'); // from novagrid/gridajaxedit.js
                if(cmd != '')
                    eval(cmd);
            }
        }
    }
}
function showMSDS(id, filename)
{
    if(filename == null) filename = '';
    var imgid;
    var isrc = $('I_MSDS'+id).src;
    if(isrc.indexOf('id=') > 0){
        imgid = isrc.substring(isrc.indexOf('id=')+3);
        var url = 'getfile.aspx?ad=1&id=' + imgid + '&filename=' + filename;
        document.location = url;
    }else{
        //var cmd = Element.readAttribute('B_UpdateMSDS'+id, 'onclick'); // loses first 2 chars... boo !
        if($('B_UpdateMSDS'+id)) {
            if(!isCellLocked(id, getGIID('MSDSID'))){
                var cmd = getElementAttribute($('B_UpdateMSDS'+id), 'onclick'); // from novagrid/gridajaxedit.js
                if(cmd != '')
                    eval(cmd);
            }
        }
    }
}
function deleteImage(itemid)
{
    var id = '';
    if($('ImageID'+itemid)) id = $('ImageID'+itemid).value;
    if(confirmAction('Really delete this Item Image?')){
        goValue = "DELETEIMAGE" + callbackSep + itemid + callbackSep + id;
		CallServer(goValue, "");
        //clearImage();
    }
}
function clearImage(id)
{
    var i = $('I_Image'+id);
    if(i){
        i.src = 'images/app_icons/icon_jpg_small.gif';
        if($('ImageID'+id)) $('ImageID'+id).value = '';
        if($('B_UpdateImage'+id)) $('B_UpdateImage'+id).value = 'Upload';
        if($('I_Image_Label'+id)) $('I_Image_Label'+id).innerText = '(upload)';
        Element.writeAttribute($('B_DeleteImage'+id), "disabled", "disabled");
    }
}
function deleteMSDS(itemid)
{
    var id = '';
    if($('MSDSID'+itemid)) id = $('MSDSID'+itemid).value;
    if(confirmAction('Really delete this Item MSDS Sheet?')){
        goValue = "DELETEMSDS" + callbackSep + itemid + callbackSep + id;
		CallServer(goValue, "");
        //clearMSDS();
    }
}
function clearMSDS(id)
{
    var i = $('I_MSDS'+id);
    if(i){
        i.src = 'images/app_icons/icon_pdf_small_off.gif';
        if($('MSDSID'+id)) $('MSDSID'+id).value = '';
        if($('B_UpdateMSDS'+id)) $('B_UpdateMSDS'+id).value = 'Upload';
        if($('I_MSDS_Label'+id)) $('I_MSDS_Label'+id).innerText = '(upload)';
        Element.writeAttribute($('B_DeleteMSDS'+id), "disabled", "disabled");
    }
}

function getGridCellValue(controlID)
{
    if($(controlID))
	{
        return $(controlID).innerHTML;
    }
    else
        alert('ERROR GETTING GRID CELL VALUE!');
}

function setGridCellValue(controlID, value, noHighlight)
{
	if (controlID.substr(controlID.length - 2) == '-1') return;
    if (noHighlight == null || !noHighlight) noHighlight = false;
    if($(controlID))
	{
        $(controlID).innerHTML = value;
        //$(controlID).innerText = value;
        if(!noHighlight) highlightControls2(controlID);
        
        var p_Column_ID = parseInt(getColFromID(controlID));
        if(p_Column_ID >= 0) resizeGridCol(p_Column_ID);
    }
    else
        alert('ERROR SETTING GRID CELL VALUE!');
}

/*
function toggleCallbackOnFinish() {
	resizeGridOnResize = true;
	if ($("submissiondetail").visible() == true) {
		$("resizeBar").src = "images/btn_resize_up.gif";
		//resizeGridOnResize = false;
		resizeGridHeight = false;
		resizeGrid();
	} else {
		$("resizeBar").src = "images/btn_resize_dn.gif";
		//resizeGridOnResize = true;
		resizeGridHeight = true;
		resizeGrid();
	}
}
*/
function closeSettings(refresh)
{
    if(!refresh&&refresh!=null)
        refresh = false;
    Lightbox.hideAll();
    if(refresh==true)
    {
        __doPostBack('settings', '');
    }
}

function saveData(columnID, columnName, rowID, dataText)
{
	//alert("saveData");
	var goValue = "";
	if (columnID != null && columnName != null && rowID != null) // && dataText != null)
	{
		goValue = "100" + callbackSep + columnID + callbackSep + columnName + callbackSep + rowID + callbackSep + dataText;
		//alert("CallServer: " + goValue);
		CallServer(goValue, "");
	}
	else {alert("ERROR: There was a problem saving the cell data!");}
}
function saveDataSetAll(columnID, columnName, dataText)
{
	//alert("saveData");
	var goValue = "";
	var itemHeaderID = "";
	if($('hid'))
	    itemHeaderID = $('hid').value;
	if (columnID != null && columnName != null && itemHeaderID != "") // && dataText != null 
	{
		goValue = "200" + callbackSep + columnID + callbackSep + columnName + callbackSep + itemHeaderID + callbackSep + dataText;
		//alert("CallServer: " + goValue);
		CallServer(goValue, "");
	}
	else {alert("ERROR: There was a problem saving the set all data!");}
}
var _grvalue, _gcontext;
function ReceiveServerData(rvalue, context)
{
    _grvalue = rvalue; _gcontext = context;
    setTimeout('ReceiveServerData2(_grvalue, _gcontext);', 0);
}

function roundForDims(value, decimals) {
    return Number(Math.round(value + 'e' + decimals) + 'e-' + decimals);
}

function RoundDimCellsAndSet(dimCell) {
    if (dimCell) {
        var val = dimCell.innerHTML;
        if (isNum(val)) {
            val = roundForDims(parseFloat(val), 2);
            val = parseFloat(val).toFixed(2);
            setGridCellValue(dimCell.id, val, true);
        }
    }
}

function RoundDimCellsAndSet4(dimCell) {
    if (dimCell) {
        var val = dimCell.innerHTML;
        if (isNum(val)) {
            val = roundForDims(parseFloat(val), 4);
            val = parseFloat(val).toFixed(4);
            setGridCellValue(dimCell.id, val, true);
        }
    }
}

function ReceiveServerData2(rvaluein, contextin)
{
    var rvalue = rvaluein;
    var context = contextin;
	var arr;
	var i, msg = "";
	var noHL = false;
	if(rvalue != null && rvalue != '')
	{
		arr = rvalue.split(callbackSep);
		if (arr.length > 1)
		{
			if(arr[0] == "100")
			{
			    // saveData
			    gridSkipCol = '';

				if(arr[1] == "1")
				{
					//alert("SUCCESS !");
					updateLastUpdated();
					if(arr.length >= 5)
					{
					    if (arr[2] == "VendorUPC") {
					        // vendor upc
					        if ($(arr[3]))
					            $(arr[3]).innerHTML = arr[4];
					    }
					    else if (arr[2] == "EachCasePackCube") {
					        // inner case pack cube
					        if ($(arr[3] + getGIID("EachCasePackCube"))) {
					            if ($(arr[3] + getGIID("EachCasePackCube")).innerHTML == '' && arr[4] == '') {
					                noHL = true;
					            }
					        }
					        setGridCellValue(arr[3] + getGIID("EachCasePackCube"), arr[4], noHL);

					        //round the other each values
					        RoundDimCellsAndSet4($(arr[3] + getGIID("EachCaseHeight")));
					        RoundDimCellsAndSet4($(arr[3] + getGIID("EachCaseWidth")));
					        RoundDimCellsAndSet4($(arr[3] + getGIID("EachCaseLength")));
					        RoundDimCellsAndSet4($(arr[3] + getGIID("EachCaseWeight")));

					    }
					    else if (arr[2] == "InnerCasePackCube") {
					        // inner case pack cube
					        if ($(arr[3] + getGIID("InnerCasePackCube"))) {
					            if ($(arr[3] + getGIID("InnerCasePackCube")).innerHTML == '' && arr[4] == '') {
					                noHL = true;
					            }
					        }
					        setGridCellValue(arr[3] + getGIID("InnerCasePackCube"), arr[4], noHL);

					        //round the other each values
					        RoundDimCellsAndSet4($(arr[3] + getGIID("InnerCaseHeight")));
					        RoundDimCellsAndSet4($(arr[3] + getGIID("InnerCaseWidth")));
					        RoundDimCellsAndSet4($(arr[3] + getGIID("InnerCaseLength")));
					        RoundDimCellsAndSet4($(arr[3] + getGIID("InnerCaseWeight")));
					    }
					    else if (arr[2] == "MasterCasePackCube") {
					        // master case pack cube
					        if ($(arr[3] + getGIID("MasterCasePackCube"))) {
					            if ($(arr[3] + getGIID("MasterCasePackCube")).innerHTML == '' && arr[4] == '') {
					                noHL = true;
					            }
					        }
					        setGridCellValue(arr[3] + getGIID("MasterCasePackCube"), arr[4], noHL);

					        //round the other each values
					        RoundDimCellsAndSet4($(arr[3] + getGIID("MasterCaseHeight")));
					        RoundDimCellsAndSet4($(arr[3] + getGIID("MasterCaseWidth")));
					        RoundDimCellsAndSet4($(arr[3] + getGIID("MasterCaseLength")));
					        RoundDimCellsAndSet4($(arr[3] + getGIID("MasterCaseWeight")));
					    }
					    else if (arr[2] == "HybridConversionDate") {
					        setGridCellValue(arr[3] + getGIID("HybridConversionDate"), arr[4]);
					    }
					    else if (arr[2] == "BaseRetail" || arr[2] == "BaseRetailA" || arr[2] == "BaseRetailPP" || arr[2] == "BaseRetailAPP") {
					        var noHL = false;
					        if (arr[2] == "BaseRetailPP" || arr[2] == "BaseRetailAPP") {
					            if ($(arr[3] + getGIID("BaseRetail")) && $(arr[3] + getGIID("CentralRetail")) && $(arr[3] + getGIID("TestRetail"))) {
					                if ($(arr[3] + getGIID("BaseRetail")).innerText != $(arr[3] + getGIID("CentralRetail")).innerText || $(arr[3] + getGIID("BaseRetail")).innerText != $(arr[3] + getGIID("TestRetail")).innerText)
					                    noHL = false;
					                else
					                    noHL = true;
					            } else {
					                noHL = true;
					            }
					        }

					        var rarr = arr[4].split("__");
					        var br = rarr[0];
					        var ar = (rarr.length >= 2) ? rarr[1] : '';
					        //setGridCellValue(arr[3]+getGIID("BaseRetail"), br, noHL);

					        //Update Canada & Quebec
					        var baseRetailCanadaQuebecConst = 'BRCQ';
					        if (arr[2] == 'BaseRetail' && rarr.length >= 3 && rarr[2].substring(0, baseRetailCanadaQuebecConst.length) == baseRetailCanadaQuebecConst) {
					            setGridCellValue(arr[3] + getGIID("CanadaRetail"), rarr[3], noHL);
					            setGridCellValue(arr[3] + getGIID("RDQuebec"), rarr[3], noHL);
					        }

					        var idtemp = getGIID(arr[2]);
					        var cellname = arr[3] + idtemp;
					        //resetRow(arr[5], 'gCVE');
					        //Element.removeClassName(arr[3]+idtemp,'gCVE');
					        // to make code work with ie6 and slow comps, changed innerText to innerHTML LP Sept 22 09
					        if ($(arr[3] + getGIID("CentralRetail")).innerHTML == '$' || $(arr[3] + getGIID("CentralRetail")).innerHTML == '' || $('hdnWorkflowStageID').value == 5) {
					            setGridCellValue(arr[3] + getGIID("CentralRetail"), br, noHL);
					        }
					        if ($(arr[3] + getGIID("TestRetail")).innerText == '$' || $(arr[3] + getGIID("TestRetail")).innerText == '' || $('hdnWorkflowStageID').value == 5) {
					            setGridCellValue(arr[3] + getGIID("TestRetail"), br, noHL);
					        }
					        /*
					        if(arr[2] == "BaseRetailA" || arr[2] == "BaseRetailAPP") 
					        setGridCellValue(arr[3]+getGIID("AlaskaRetail"), arr[4]);
					        else
					        setGridCellValue(arr[3]+getGIID("AlaskaRetail"), '', elementTextEquals(arr[3]+getGIID("AlaskaRetail"), ''));
					        */
					        // lp change order 14 , only recal alaska retail when base is not ''
					        if (!elementTextEquals(arr[3] + getGIID("AlaskaRetail"), ar)) {
					            //if($(cellname).innerText.length != 0 && $(cellname).innerText != '$')
					            if ($(arr[3] + getGIID("BaseRetail")).innerText != '' && $(arr[3] + getGIID("BaseRetail")).innerText != '$') {
					                setGridCellValue(arr[3] + getGIID("AlaskaRetail"), ar);
					            }
					        }
					        // lp change order 14 Aug 19th, 2009, the price values are now editable, only change them when they are empty
					        if ($(arr[3] + getGIID("ZeroNineRetail")).innerText == '$' || $(arr[3] + getGIID("ZeroNineRetail")).innerText == '' || $('hdnWorkflowStageID').value == 5) {
					            setGridCellValue(arr[3] + getGIID("ZeroNineRetail"), br, noHL);
					        }
					        if ($(arr[3] + getGIID("CaliforniaRetail")).innerText == '$' || $(arr[3] + getGIID("CaliforniaRetail")).innerText == '' || $('hdnWorkflowStageID').value == 5) {
					            setGridCellValue(arr[3] + getGIID("CaliforniaRetail"), br, noHL);
					        }
					        if ($(arr[3] + getGIID("VillageCraftRetail")).innerText == '$' || $(arr[3] + getGIID("VillageCraftRetail")).innerText == '' || $('hdnWorkflowStageID').value == 5) {
					            setGridCellValue(arr[3] + getGIID("VillageCraftRetail"), br, noHL);
					        }

					        if ($(arr[3] + getGIID("Retail9")).innerText == '$' || $(arr[3] + getGIID("Retail9")).innerText == '' || $('hdnWorkflowStageID').value == 5) {
					            setGridCellValue(arr[3] + getGIID("Retail9"), br, noHL);
					        }
					        if ($(arr[3] + getGIID("Retail10")).innerText == '$' || $(arr[3] + getGIID("Retail10")).innerText == '' || $('hdnWorkflowStageID').value == 5) {
					            setGridCellValue(arr[3] + getGIID("Retail10"), br, noHL);
					        }
					        if ($(arr[3] + getGIID("Retail11")).innerText == '$' || $(arr[3] + getGIID("Retail11")).innerText == '' || $('hdnWorkflowStageID').value == 5) {
					            setGridCellValue(arr[3] + getGIID("Retail11"), br, noHL);
					        }
					        if ($(arr[3] + getGIID("Retail12")).innerText == '$' || $(arr[3] + getGIID("Retail12")).innerText == '' || $('hdnWorkflowStageID').value == 5) {
					            setGridCellValue(arr[3] + getGIID("Retail12"), br, noHL);
					        }
					        if ($(arr[3] + getGIID("Retail13")).innerText == '$' || $(arr[3] + getGIID("Retail13")).innerText == '' || $('hdnWorkflowStageID').value == 5) {
					            setGridCellValue(arr[3] + getGIID("Retail13"), br, noHL);
					        }
					        if ($(arr[3] + getGIID("RDPuertoRico")).innerText == '$' || $(arr[3] + getGIID("RDPuertoRico")).innerText == '' || $('hdnWorkflowStageID').value == 5) {
					            setGridCellValue(arr[3] + getGIID("RDPuertoRico"), br, noHL);
					        }
                            
					    }
					    else if (arr[2] == "AlaskaRetail") {
					        //setGridCellValue(arr[3]+getGIID("AlaskaRetail"), arr[4]);
					        //resetRow(arr[5], 'gCVE');
					    }
					    else if (arr[2] == "CanadaRetail") {
					        var noHL = false;

					        var rarr = arr[4].split("__");
					        var br = rarr[0];

					        if ($(arr[3] + getGIID("RDQuebec")).innerText == '$' || $(arr[3] + getGIID("RDQuebec")).innerText == '' || $("hdnWorkflowStageID").value == 5) {
					            setGridCellValue(arr[3] + getGIID("RDQuebec"), br, noHL);
					        }
					        //setGridCellValue(arr[3]+getGIID("CanadaRetail"), arr[4]);
					        //resetRow(arr[5], 'gCVE');
					    }
					    else if (arr[2] == "Hazardous" && arr[4] == '') {
					        setGridCellValue(arr[3] + getGIID("HazardousFlammable"), '', elementTextEquals(arr[3] + getGIID("HazardousFlammable"), ''));
					        setGridCellValue(arr[3] + getGIID("HazardousContainerType"), '', elementTextEquals(arr[3] + getGIID("HazardousContainerType"), ''));
					        setGridCellValue(arr[3] + getGIID("HazardousContainerSize"), '', elementTextEquals(arr[3] + getGIID("HazardousContainerSize"), ''));
					        setGridCellValue(arr[3] + getGIID("HazardousMSDSUOM"), '', elementTextEquals(arr[3] + getGIID("HazardousMSDSUOM"), ''));
					        setGridCellValue(arr[3] + getGIID("HazardousManufacturerName"), '', elementTextEquals(arr[3] + getGIID("HazardousManufacturerName"), ''));
					        setGridCellValue(arr[3] + getGIID("HazardousManufacturerCity"), '', elementTextEquals(arr[3] + getGIID("HazardousManufacturerCity"), ''));
					        setGridCellValue(arr[3] + getGIID("HazardousManufacturerState"), '', elementTextEquals(arr[3] + getGIID("HazardousManufacturerState"), ''));
					        setGridCellValue(arr[3] + getGIID("HazardousManufacturerPhone"), '', elementTextEquals(arr[3] + getGIID("HazardousManufacturerPhone"), ''));
					        setGridCellValue(arr[3] + getGIID("HazardousManufacturerCountry"), '', elementTextEquals(arr[3] + getGIID("HazardousManufacturerCountry"), ''));
					    }
					    else if (arr[2] == "CountryOfOriginName") {
					        if (arr[4] != '') {
					            setGridCellValue(arr[3] + getGIID("CountryOfOriginName"), arr[4]);
					        }
					    }
					    else if (arr[2] == "LikeItemSKU") {
					        var rarr = arr[4].split("__");
					        var itemDesc = rarr[0];
					        var baseRetail = (rarr.length >= 2) ? rarr[1] : '';
					        setGridCellValue(arr[3] + getGIID("LikeItemDescription"), itemDesc);
					        setGridCellValue(arr[3] + getGIID("LikeItemRetail"), baseRetail);

					    }
					    else if (arr[2] == "LikeItemUnitStoreMonth") {
					        var rarr = arr[4].split("__");
					        var AnnualRegularUnitForecast = rarr[0];
					        var AnnualRegRetailSales = (rarr.length >= 2) ? rarr[1] : '0';
					        setGridCellValue(arr[3] + getGIID("AnnualRegularUnitForecast"), AnnualRegularUnitForecast);
					        setGridCellValue(arr[3] + getGIID("AnnualRegRetailSales"), AnnualRegRetailSales);
					    }
					    else if (arr[2] == "AnnualRegularUnitForecast") {
					        var rarr = arr[4].split("__");
					        var CalcualtedUnitStoreMonth = rarr[0];
					        var AnnualRegRetailSales = (rarr.length >= 2) ? rarr[1] : '0';
					        setGridCellValue(arr[3] + getGIID("LikeItemUnitStoreMonth"), CalcualtedUnitStoreMonth);
					        setGridCellValue(arr[3] + getGIID("AnnualRegRetailSales"), AnnualRegRetailSales);

					    }
					    else if (arr[2] == "TotalUSCost") {
					        var rarr = arr[4].split("__");
					        var uscost = rarr[0];
					        var tuscost = (rarr.length >= 2) ? rarr[1] : '';
					        setGridCellValue(arr[3] + getGIID("USCost"), uscost);
					        setGridCellValue(arr[3] + getGIID("TotalUSCost"), tuscost);
					    }
					    else if (arr[2] == "TotalCanadaCost") {
					        var rarr = arr[4].split("__");
					        var ccost = rarr[0];
					        var tccost = (rarr.length >= 2) ? rarr[1] : '';
					        setGridCellValue(arr[3] + getGIID("CanadaCost"), ccost);
					        setGridCellValue(arr[3] + getGIID("TotalCanadaCost"), tccost);
					    }
					    else if (arr[2] == "TotalCosts") {
					        var rarr = arr[4].split("__");
					        var tuscost = rarr[0];
					        var tccost = (rarr.length >= 2) ? rarr[1] : '';
					        setGridCellValue(arr[3] + getGIID("TotalUSCost"), tuscost);
					        setGridCellValue(arr[3] + getGIID("TotalCanadaCost"), tccost);

					    }
					    else if (arr[2] == "EnglishShortDescription") {
					        setGridCellValue(arr[3] + getGIID("EnglishShortDescription"), arr[4]);
					    }
					    else if (arr[2] == "EnglishLongDescription") {
					        setGridCellValue(arr[3] + getGIID("EnglishLongDescription"), arr[4]);
					    }
					    else if ((arr[2] == "PLIEnglish") || (arr[2] == "PLIFrench") || (arr[2] == "PLISpanish"))  
					    {
					        //PLIs may have changed for all items, so reload page.
					        reloadPage();
					    }
					    else {
					        if ($(arr[3])) {
					            setGridCellValue(arr[3], arr[4], elementTextEquals(arr[3], arr[4]));
					        }
					    }
					}
					// refresh validation errors
					if(arr.length >= 7)
					{
					    resetRowErrors(arr[5]);
					    if(arr[6] != '') {
					        var toRun = "setCellErrors(" + arr[6] + ");";
					        eval(toRun);
					    }
					    if(arr.length >= 8 && arr[7] != '')
					        eval("resetValIcon(" + arr[5] + ", " + arr[7] + ");");
					    if(arr.length >= 9 && arr[8] != '')
					    {
					        var validBatch = (arr[8].length >= 1) ? arr[8].substr(0, 1) : '1';
					        var validIH = (arr[8].length >= 2) ? arr[8].substr(1, 1) : '1';
					        var validI = (arr[8].length >= 3) ? arr[8].substr(2, 1) : '1';
					        if(validBatch == '0') {
					            setItemHeaderTabInvalid(); setItemDetailTabInvalid();
					        } else {
					            if(validIH == '0') setItemHeaderTabInvalid(); else setItemHeaderTabValid();
					            if(validI == '0') setItemDetailTabInvalid(); else setItemDetailTabValid();
					        }
					    }
					    if(arr.length >= 10)
					    {
					        setValidationHTML(arr[9]);
					    }
					    if(arr.length >= 11)
					    {
					        if(arr[10] == '1')
					            reloadPage();
					    }
					    // GO VALIDATE ENTIRE SHEET
					    //var goValue = "300" + callbackSep + "";
					    //CallServer(goValue, "");
					    // *** NO NEED anymore -- validate entire list now
					}
				}
				else {alert("ERROR: There was a problem saving the cell data!");}
			}
			else if (arr[0] == "200")
			{
			    // saveDataSetAll
			    
			    if(arr[1] == "1")
				{
					//alert("SUCCESS !");
					reloadPage();
				}
				else {alert("ERROR: There was a problem saving the cell data!");}
			} 
			else if (arr[0] == "300")
			{
			    // VALIDATE ENTIRE SHEET
			    if(arr[1] == "1")
			    {
			        //alert("SUCCESS !");
					if(arr.length >= 3)
					
					{
					    if(arr[2] == "1") {
					        if($('itemDetailImage')) $('itemDetailImage').src = 'images/valid_yes_small.gif';
					        if($('validationDisplay')) Element.hide('validationDisplay');
					    } else {
					        if($('itemDetailImage')) $('itemDetailImage').src = 'images/valid_no_small.gif';
					        if($('validationDisplay')) Element.show('validationDisplay');
					    }
					}
			    }
			    else {alert("ERROR: There was a problem saving the cell data!");}
			}
			else if(arr[0] == "DELETEIMAGE")
			{
				if(arr[1] == "1" && arr.length >= 4)
				{
					clearImage(arr[2]);
					// refresh validation errors
					if(arr.length >= 5)
					{
					    resetRow(arr[2], 'gCVE');
					    if(arr[4] != '') {
					        var toRun = "setCellClass('gCVE', " + arr[4] + ");"
					        eval(toRun);
					    }
					    if(arr.length >= 6 && arr[5] != '')
					        eval("resetValIcon(" + arr[2] + ", " + arr[5] + ");");
					    
					    // GO VALIDATE ENTIRE SHEET
					    var goValue = "300" + callbackSep + "";
					    CallServer(goValue, "");
					}
				}
				else {alert("ERROR: There was a problem deleting the Item Image!");}
			} 
			else if(arr[0] == "DELETEMSDS")
			{
				if(arr[1] == "1" && arr.length >= 4)
				{
					clearMSDS(arr[2]);
					// refresh validation errors
					if(arr.length >= 5)
					{
					    resetRow(arr[2], 'gCVE');
					    if(arr[4] != '') {
					        var toRun = "setCellClass('gCVE', " + arr[4] + ");"
					        eval(toRun);
					    }
					    if(arr.length >= 6 && arr[5] != '')
					        eval("resetValIcon(" + arr[2] + ", " + arr[5] + ");");
					    
					    // GO VALIDATE ENTIRE SHEET
					    var goValue = "300" + callbackSep + "";
					    CallServer(goValue, "");
					}
				}
				else {alert("ERROR: There was a problem deleting the Item MSDS Sheet!");}
			}
			else if(arr[0] == "UPDATEMSDS")
			{
				if(arr[1] == "1" && arr.length >= 4)
				{
					// refresh validation errors
					if(arr.length >= 5)
					{
					    resetRow(arr[2], 'gCVE');
					    if(arr[4] != '') {
					        var toRun = "setCellClass('gCVE', " + arr[4] + ");"
					        eval(toRun);
					    }
					    if(arr.length >= 6 && arr[5] != '')
					        eval("resetValIcon(" + arr[2] + ", " + arr[5] + ");");
					    
					    // GO VALIDATE ENTIRE SHEET
					    var goValue = "300" + callbackSep + "";
					    CallServer(goValue, "");
					}
				}
				else {alert("ERROR: There was a problem updating the Item MSDS Sheet!");}
			}
			else if(arr[0] == "UPDATEIMAGE")
			{
				if(arr[1] == "1" && arr.length >= 4)
				{
					// refresh validation errors
					if(arr.length >= 5)
					{
					    resetRow(arr[2], 'gCVE');
					    if(arr[4] != '') {
					        var toRun = "setCellClass('gCVE', " + arr[4] + ");"
					        eval(toRun);
					    }
					    if(arr.length >= 6 && arr[5] != '')
					        eval("resetValIcon(" + arr[2] + ", " + arr[5] + ");");
					    
					    // GO VALIDATE ENTIRE SHEET
					    var goValue = "300" + callbackSep + "";
					    CallServer(goValue, "");
					}
				}
				else {alert("ERROR: There was a problem updating the Item Image!");}
			}
			
			else {alert("ERROR: Unknown callback response given!" + " (" + arr[0] + ")");}
		}
		else {alert("ERROR: Invalid callback response given!");}
	}
}


function openTaxWizard(id)
{
    if(isCellLocked(id, getGIID('TaxWizard'))) return false;
    var url = 'Tax_Wizard.aspx?type=D&id=' + id;
    var win = window.open(url, 'taxwiz', 'scrollbars=0,location=0,menubar=0,titlebar=0,toolbar=0,width=700,HEIGHT=525');
    return false;
}
function openTaxWizardSA(hid, id)
{
    var url = 'Tax_Wizard.aspx?type=D&sa=1&hid=' + hid + '&id=' + id;
    var win = window.open(url, 'taxwiz', 'scrollbars=0,location=0,menubar=0,titlebar=0,toolbar=0,width=700,HEIGHT=525');
    return false;
}
function updateItemTaxWizard(id, completed, taxUDA)
{
    if (!completed || completed == null)
        completed = false;
    if (taxUDA == null) taxUDA = 0;
    if (!isNum(taxUDA)) taxUDA = 0;
    var imgID = 'taxwiz'+id;
    if($(imgID)){
        $(imgID).src = (completed) ? 'images/checkbox_true.gif' : 'images/checkbox_false.gif';
    }
    var cell = 'gce_' + id + '_' + getGIID('TaxUDA');
    if($(cell)){
        $(cell).innerText = taxUDA;
        setCell($(cell), taxUDA, getGIID('TaxUDA'), 'Tax_UDA', id);
    }
    else
        alert('Error: Could not update Tax UDA after completing the Tax Wizard!');
}

function preloadItemImages()
{
    var img1 = new Image(); img1.src = 'images/tab_item_detail_on.gif';
}

var valArray = new Array();

function setValIcon(id, display)
{
    var o = $('h_row_'+id);
    if(o){o.innerHTML = (o.innerHTML + display);}
}
function resetValIcon(id, display)
{
    var o = $('h_row_'+id);
    if(o){o.innerHTML = ('<img src="./images/spacer.gif" width="20" height="1" alt="" />' + display);}
}

function elementEquals(elementid, value)
{
    if ($(elementid)){
        if ($(elementid).value == value)
            return true;
        else
            return false;
    } else {
        return false;
    }
}

function elementTextEquals(elementid, value)
{
    if ($(elementid)){
        if ($(elementid).innerText == value)
            return true;
        else
            return false;
    } else {
        return false;
    }
}

function setValidationHTML(value)
{
    var o = $('validationDisplayTD');
    if(o) o.innerHTML = value;
}

/**********************/
/*** MISC FUNCTIONS ***/
/**********************/

function resetRow(row, removeStyle)
{
    var i;
    var id;
    for (i = 1; i <= gridEC; i++) {
        id = 'gc_'+row+'_'+i;
        if($(id))
            Element.removeClassName(id, removeStyle);
    }
}

function setCellClass(addStyle, cells)
{
    var i, id;
    var a = setCellClass.arguments;
    for (i = 1; i < a.length; i++) {
        id = a[i];
        Element.addClassName(id, addStyle);
    }
}

function resetRowErrors(row)
{
    var i;
    var id;
    for (i = 1; i <= gridEC; i++) {
        id = 'gc_'+row+'_'+i;
        if($(id))
            Element.removeClassName(id, 'gCVE');
            Element.removeClassName(id, 'gCVW');
    }
}

function setCellErrors(cells)
{
    var i, id, etype;
    var a = setCellErrors.arguments;
    for (i = 0; i < a.length-1; i+=2) {
        id = a[i];
        etype = a[i+1];
        if(etype == '2')
            Element.addClassName(id, 'gCVW');
        else
            Element.addClassName(id, 'gCVE');
    }
}