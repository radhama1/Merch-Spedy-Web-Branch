
var callbackSep = "{{|}}";
var VALIDATION_IMAGE_UNKNOWN_SM = "images/valid_null_small.gif"
var VALIDATION_IMAGE_NOTVALID_SM = "images/valid_no_small.gif"
var VALIDATION_IMAGE_VALID_SM = "images/valid_yes_small.gif"

var VALIDATION_DISPLAY_UNKNOWN_SM = '<img src="images/valid_null_small.gif" width="11" height="11" border="0" alt="" />';
var VALIDATION_DISPLAY_NOTVALID_SM = '<img src="images/valid_no_small.gif" width="11" height="11" border="0" alt="" />';
var VALIDATION_DISPLAY_VALID_SM = '<img src="images/valid_yes_small.gif" width="11" height="11" border="0" alt="" />';

var itemViewURL = '';

function setValidationImage(valid) {
    if (valid == null || !valid) valid = false;
    if (valid) $('validFlagDisplay').innerHTML = VALIDATION_DISPLAY_VALID_SM; else $('validFlagDisplay').innerHTML = VALIDATION_DISPLAY_NOTVALID_SM;
}

function setItemHeaderTabValid() { setTabImage('itemHeaderImage', true); }
function setItemHeaderTabInvalid() { setTabImage('itemHeaderImage', false); }
function setItemDetailTabValid() { setTabImage('itemDetailImage', true); }
function setItemDetailTabInvalid() { setTabImage('itemDetailImage', false); }

function setTabImage(tab, valid) {
    if (valid == null || !valid) valid = false;
    if (valid) $(tab).src = VALIDATION_IMAGE_VALID_SM; else $(tab).src = VALIDATION_IMAGE_NOTVALID_SM;
}

//var effectivedate1;
function initPage() {
    // effectivedate1 = new Spry.Widget.ValidationTextField("txtEffectiveDate", "date", {format:"mm/dd/yyyy", isRequired:false, validateOn:["change"], useCharacterMasking:true});
}

function saveEffectiveDate() {
    $('txtEffectiveDateSaving').show();
    var goValue = "";
    var itemHeaderID = "";
    if ($('hid'))
        itemHeaderID = $('hid').value;
    goValue = "EFFECTIVEDATE" + callbackSep + itemHeaderID + callbackSep + $('txtEffectiveDate').value;
    CallServer(goValue, "");
    updateLastUpdated();
    return true;
}
function saveEffectiveDateComplete() {
    $('txtEffectiveDateSaving').hide();
}

function enableEffectiveDate(enable) {
    if (enable == null || !enable) enable = false;
    var txt = $('txtEffectiveDate');
    var img = $('tcalico_0');
    var btn = $('btnEffectiveDate');
    if (txt && img && btn) {
        if (enable) {
            txt.disabled = false;
            img.show();
            btn.disabled = false;
            btn.show();
        } else {
            txt.disabled = true;
            img.hide();
            btn.disabled = true;
            btn.hide();
        }
    } else {
        alert('Error ' + ((enable) ? 'enabling' : 'disabling') + ' Effective Date.');
    }
}

function updateLastUpdated() {
    var lu = $('lastUpdated');
    var me = $('lastUpdatedMe');
    if (lu && me) {
        lu.innerHTML = me.value;
    }
}

function openItemViewWindow(RowID) {
    var url = '';
    if (!RowID && RowID == null)
        RowID = 0;
    if (RowID > 0 && itemViewURL != '')
        url = itemViewURL + ((itemViewURL.indexOf('?') >= 0) ? "&id=" : "?id=") + RowID;
    if (url != '') {
        var viewWin = window.open(url, "viewWindow_" + RowID, "width=1000,height=750,toolbar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=1,resizable=1");
        viewWin.focus();
    }
}


function undoSpecialControl(id, column) {
    if (column != 'ImageID' && column != 'MSDSID') return;
    var itemID = getItemIDFromControlID(id);
    var colID = getGridColFromControlID(id);
    // get the original value
    var val = '';
    if (column == 'ImageID') {
        val = $('ImageID' + itemID + '_ORIG').value;
        if (val != '')
            $('I_Image' + itemID).src = 'images/app_icons/icon_jpg_small_on.gif?id=' + val;
        else
            $('I_Image' + itemID).src = 'images/app_icons/icon_jpg_small.gif';
    } else if (column == 'MSDSID') {
        val = $('MSDSID' + itemID + '_ORIG').value;
        if (val != '')
            $('I_MSDS' + itemID).src = 'images/app_icons/icon_pdf_small.gif?id=' + val;
        else
            $('I_MSDS' + itemID).src = 'images/app_icons/icon_pdf_small_off.gif';
    }
    // undo / save the value
    saveData(colID, column, itemID, val);
    // hide the wrapper
    hideNLCGWrapper(id);
    // resize the column
    resizeGridCol(colID);
}

function getGridCellValue(controlID) {
    if ($(controlID)) {
        return $(controlID).innerHTML;
    }
    else
        alert('ERROR GETTING GRID CELL VALUE!');
}

function getItemIDFromControlID(controlID) {
    var id = -1;
    var pos1 = controlID.toString().indexOf('_');
    var pos2 = controlID.toString().lastIndexOf('_');
    if (pos1 >= 0 && pos2 > pos1) {
        id = parseInt(controlID.toString().substring(pos1 + 1, pos2));
    }
    return id;
}

function getGridColFromControlID(controlID) {
    var id = -1;
    var pos = controlID.toString().lastIndexOf('_');
    if (pos >= 0) id = parseInt(controlID.toString().substr(pos + 1));
    return id;
}

function setGridCellValue(controlID, value, noHighlight)
{
    if (controlID.substr(controlID.length - 2) == '-1') return;
    if (noHighlight == null || !noHighlight) noHighlight = false;
    if (value == null || value == '') noHighlight = true;
    var control = $(controlID);
    if (control) {
        control.innerHTML = value;
        //$(controlID).innerText = value;
        if (showChanges()) {
            var controlOrig = $(controlID + '_ORIGS');
            if (controlOrig) {
                //                if(control.innerHTML == controlOrig.innerHTML)
                //                    hideNLCGWrapper(controlID);
                //                else
                //                    showNLCGWrapper(controlID);
                showHideNLCGWrapper(controlID, control.innerHTML, controlOrig.innerHTML);
            }
        }
        if (!noHighlight) highlightControls2(controlID);

        var p_Column_ID = parseInt(getColFromID(controlID));
        if (p_Column_ID >= 0) resizeGridCol(p_Column_ID);
    }
    else
        alert('ERROR SETTING GRID CELL VALUE!');
}

function closeSettings(refresh) {
    if (!refresh && refresh != null)
        refresh = false;
    Lightbox.hideAll();
    if (refresh == true) {
        __doPostBack('settings', '');
    }
}

function saveData(columnID, columnName, rowID, dataText) {
    //alert("saveData");
    var goValue = "";
    //alert(columnID + '  |  ' + columnName + '  |  ' + rowID);
    if (columnID != null && columnName != null && rowID != null) // && dataText != null)
    {
        goValue = "100" + callbackSep + columnID + callbackSep + columnName + callbackSep + rowID + callbackSep + dataText;
        //alert("saveData :: CallServer: " + goValue);
        CallServer(goValue, "");
    }
    else { alert("ERROR: There was a problem saving the cell data!"); }
}
function saveDataSetAll(columnID, columnName, dataText) {
    //alert("saveDataSetAll");
    var goValue = "";
    var itemHeaderID = "";
    if ($('hid'))
        itemHeaderID = $('hid').value;
    if (columnID != null && columnName != null && itemHeaderID != "") // && dataText != null 
    {
        goValue = "200" + callbackSep + columnID + callbackSep + columnName + callbackSep + itemHeaderID + callbackSep + dataText;
        //alert("saveDataSetAll :: CallServer: " + goValue);
        CallServer(goValue, "");
    }
    else { alert("ERROR: There was a problem saving the set all data!"); }
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

var _grvalue, _gcontext;
function ReceiveServerData(rvalue, context) {
    _grvalue = rvalue; _gcontext = context;
    setTimeout('ReceiveServerData2(_grvalue, _gcontext);', 0);
}
function ReceiveServerData2(rvaluein, contextin) {
    var rvalue = rvaluein;
    var context = contextin;
    var arr;
    var i, msg = "";
    var noHL = false;

    if (rvalue != null && rvalue != '') {
        arr = rvalue.split(callbackSep);
        if (arr.length > 1) {

            if (arr[0] == "100") {
                // saveData
                gridSkipCol = '';

                if (arr[1] == "1") {

                    //alert("SUCCESS !");
                    updateLastUpdated();
                    if (arr.length >= 5) {
                        if (arr[2] == "PrimaryUPC") {
                            // vendor upc
                            if ($(arr[3])) {
                                $(arr[3]).innerHTML = arr[4];
                                resizeGridColByName('PrimaryUPC');
                            }
                        }
                        else if (arr[2] == "EachCaseCube") {
                            // each case pack cube
                            if ($(arr[3] + getGIID("EachCaseCube"))) {
                                if ($(arr[3] + getGIID("EachCaseCube")).innerHTML == '' && arr[4] == '') {
                                    noHL = true;
                                }
                            }
                            setGridCellValue(arr[3] + getGIID("EachCaseCube"), arr[4], noHL);

                            //round the other each values
                            RoundDimCellsAndSet($(arr[3] + getGIID("EachCaseHeight")));
                            RoundDimCellsAndSet($(arr[3] + getGIID("EachCaseWidth")));
                            RoundDimCellsAndSet($(arr[3] + getGIID("EachCaseLength")));
                            RoundDimCellsAndSet4($(arr[3] + getGIID("EachCaseWeight")));
                        }
                        else if (arr[2] == "InnerCaseCube") {
                            // inner case pack cube
                            if ($(arr[3] + getGIID("InnerCaseCube"))) {
                                if ($(arr[3] + getGIID("InnerCaseCube")).innerHTML == '' && arr[4] == '') {
                                    noHL = true;
                                }
                            }
                            setGridCellValue(arr[3] + getGIID("InnerCaseCube"), arr[4], noHL);

                            //round the other each values
                            RoundDimCellsAndSet($(arr[3] + getGIID("InnerCaseHeight")));
                            RoundDimCellsAndSet($(arr[3] + getGIID("InnerCaseWidth")));
                            RoundDimCellsAndSet($(arr[3] + getGIID("InnerCaseLength")));
                            RoundDimCellsAndSet4($(arr[3] + getGIID("InnerCaseWeight")));

                        }
                        else if (arr[2] == "MasterCaseCube") {
                            // master case pack cube
                            if ($(arr[3] + getGIID("MasterCaseCube"))) {
                                if ($(arr[3] + getGIID("MasterCaseCube")).innerHTML == '' && arr[4] == '') {
                                    noHL = true;
                                }
                            }
                            setGridCellValue(arr[3] + getGIID("MasterCaseCube"), arr[4], noHL);

                            //round the other each values
                            RoundDimCellsAndSet($(arr[3] + getGIID("MasterCaseHeight")));
                            RoundDimCellsAndSet($(arr[3] + getGIID("MasterCaseWidth")));
                            RoundDimCellsAndSet($(arr[3] + getGIID("MasterCaseLength")));
                            RoundDimCellsAndSet4($(arr[3] + getGIID("MasterCaseWeight")));
                        }
                        else if (arr[2] == "MasterCaseWeight") {
                            RoundDimCellsAndSet4($(arr[3] + getGIID("MasterCaseWeight")));
                        }
                        else if (arr[2] == "CALC_EstLandedCost") {
                            // CalculateEstLandedCostAndStore
                            if (arr[1] == "1" && arr.length >= 5 && arr[4] != null && arr[4] != '') {
                                //var fromField = arr[0];
                                //alert(arr[3]);
                                // display values from XML
                                //var dsResults = new Spry.Data.XMLDataSet(null, "/calcresults");
                                var xmlDOMDoc = Spry.Utils.stringToXMLDoc(arr[4]);
                                //dsEmployees.setDataFromDoc(xmlDOMDoc);
                                //var x;
                                // dispcost
                                if ($(arr[3] + getGIID("DisplayerCost"))) {
                                    setGridCellValue(arr[3] + getGIID("DisplayerCost"), getXMLValue(xmlDOMDoc, 'dispcost'));
                                }
                                // prodcost
                                setGridCellValue(arr[3] + getGIID("ProductCost"), getXMLValue(xmlDOMDoc, 'prodcost'));
                                // fob
                                setGridCellValue(arr[3] + 26, getXMLValue(xmlDOMDoc, 'fob')); //getGIID("FOBShippingPoint"), getXMLValue(xmlDOMDoc, 'fob'));//
                                //setControlValue('FirstCost', getXMLValue(xmlDOMDoc, 'fob'));
                                // dutyper
                                setGridCellValue(arr[3] + getGIID("DutyPercent"), getXMLValue(xmlDOMDoc, 'dutyper'));
                                // addduty
                                setGridCellValue(arr[3] + getGIID("AdditionalDutyAmount"), getXMLValue(xmlDOMDoc, 'addduty'));
                                // supptariffper
                                setGridCellValue(arr[3] + getGIID("SuppTariffPercent"), getXMLValue(xmlDOMDoc, 'supptariffper'));
                                // eachesmc
                                setGridCellValue(arr[3] + getGIID("EachesMasterCase"), getXMLValue(xmlDOMDoc, 'eachesmc'));
                                // mclength
                                setGridCellValue(arr[3] + getGIID("MasterCaseLength"), getXMLValue(xmlDOMDoc, 'mclength'));
                                // mcwidth
                                setGridCellValue(arr[3] + getGIID("MasterCaseWidth"), getXMLValue(xmlDOMDoc, 'mcwidth'));
                                // mcheight
                                setGridCellValue(arr[3] + getGIID("MasterCaseHeight"), getXMLValue(xmlDOMDoc, 'mcheight'));
                                // oceanfre
                                setGridCellValue(arr[3] + getGIID("OceanFreightAmount"), getXMLValue(xmlDOMDoc, 'oceanfre'));
                                // agentcommper
                                setGridCellValue(arr[3] + getGIID("AgentCommissionPercent"), getXMLValue(xmlDOMDoc, 'agentcommper'));
                                // otherimportper 
                                setGridCellValue(arr[3] + getGIID("OtherImportCostsPercent"), getXMLValue(xmlDOMDoc, 'otherimportper'));
                                // packcost
                                //setGridCellValue(arr[3]+getGIID("PackagingCostAmount"), getXMLValue(xmlDOMDoc, 'packcost'));
                                
                                // cubicftpermc
                                setGridCellValue(arr[3] + getGIID("MasterCaseCube"), getXMLValue(xmlDOMDoc, 'cubicftpermc'));

                                // duty
                                setGridCellValue(arr[3] + getGIID("DutyAmount"), getXMLValue(xmlDOMDoc, 'duty'));
                                // SuppTariff
                                setGridCellValue(arr[3] + getGIID("SuppTariffAmount"), getXMLValue(xmlDOMDoc, 'supptariff'));
                                // ocean
                                setGridCellValue(arr[3] + getGIID("OceanFreightComputedAmount"), getXMLValue(xmlDOMDoc, 'ocean'));
                                // agentcomm
                                setGridCellValue(arr[3] + getGIID("AgentCommissionAmount"), getXMLValue(xmlDOMDoc, 'agentcomm'));
                                // otherimport
                                setGridCellValue(arr[3] + getGIID("OtherImportCostsAmount"), getXMLValue(xmlDOMDoc, 'otherimport'));
                                // totalimport
                                setGridCellValue(arr[3] + getGIID("ImportBurden"), getXMLValue(xmlDOMDoc, 'totalimport'));
                                //setControlValue('StoreTotalImportBurden', getXMLValue(xmlDOMDoc, 'totalimport'));
                                // totalcost
                                setGridCellValue(arr[3] + getGIID("WarehouseLandedCost"), getXMLValue(xmlDOMDoc, 'totalcost'));
                                //setControlValue('TotalWhseLandedCost', getXMLValue(xmlDOMDoc, 'totalcost'));
                                // outfreight
                                setGridCellValue(arr[3] + getGIID("OutboundFreight"), getXMLValue(xmlDOMDoc, 'outfreight'));
                                // ninewhse
                                setGridCellValue(arr[3] + getGIID("NinePercentWhseCharge"), getXMLValue(xmlDOMDoc, 'ninewhse'));
                                // totalstore
                                setGridCellValue(arr[3] + getGIID("TotalStoreLandedCost"), getXMLValue(xmlDOMDoc, 'totalstore'));
                                //calculateGMPercent();
                            }
                            else { alert("ERROR: There was a problem with the calculated fields!"); }
                        }
                        else if (arr[2] == "Hazardous" && arr[4] == '') {
                            setGridCellValue(arr[3] + getGIID("HazardousFlammable"), 'N', elementTextEquals(arr[3] + getGIID("HazardousFlammable"), 'N'));
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
                        else if (arr[2] == "ItemCosts") {
                            var rarr = arr[4].split("__");
                            var auc = rarr[0];
                            var icost = (rarr.length >= 2) ? rarr[1] : '';
                            var ticost = (rarr.length >= 3) ? rarr[2] : '';
                            if ($(arr[3] + getGIID("DisplayerCost"))) {
                                setGridCellValue(arr[3] + getGIID("DisplayerCost"), auc);
                            }
                            if ($(arr[3] + getGIID("ItemCost"))) {
                                setGridCellValue(arr[3] + getGIID("ItemCost"), icost);
                            }
                            if ($(arr[3] + getGIID("ProductCost"))) {
                                setGridCellValue(arr[3] + getGIID("ProductCost"), icost);
                            }
                            setGridCellValue(arr[3] + getGIID("FOBShippingPoint"), ticost);
                        }
                        else if (arr[2] == "EnglishShortDescription") {
                            setGridCellValue(arr[3] + getGIID("EnglishShortDescription"), arr[4]);
                        }
                        else if (arr[2] == "EnglishLongDescription") {
                            setGridCellValue(arr[3] + getGIID("EnglishLongDescription"), arr[4]);
                        }
                        else if (arr[2] == "PLIEnglish") {
                            if ($(arr[3] + getGIID("TIEnglish")).innerText == '') {
                                setGridCellValue(arr[3] + getGIID("TIEnglish"), arr[4]);
                            }
                        }
                        else if (arr[2] == "PLIFrench") {
                            if ($(arr[3] + getGIID("TIFrench")).innerText == '') {
                                setGridCellValue(arr[3] + getGIID("TIFrench"), arr[4]);
                            }
                        }
                        else {
                            // all other fields
                            if ($(arr[3])) {
                                setGridCellValue(arr[3], arr[4], elementTextEquals(arr[3], arr[4]));
                            }
                        }
                    }
                    // refresh validation errors
                    if (arr.length >= 7) {
                        resetRowErrors(arr[5]);
                        if (arr[6] != '') {
                            var toRun = "setCellErrors(" + arr[6] + ");";
                            eval(toRun);
                        }
                        if (arr.length >= 8 && arr[7] != '')
                            eval("resetValIcon(" + arr[5] + ", " + arr[7] + ");");
                        if (arr.length >= 9 && arr[8] != '') {
                            var validBatch = (arr[8].length >= 1) ? arr[8].substr(0, 1) : '1';
                            //var validIH = (arr[8].length >= 2) ? arr[8].substr(1, 1) : '1';
                            //var validI = (arr[8].length >= 3) ? arr[8].substr(2, 1) : '1';
                            /*
					        if(validBatch == '0') {
					            setItemHeaderTabInvalid(); setItemDetailTabInvalid();
					        } else {
					            if(validIH == '0') setItemHeaderTabInvalid(); else setItemHeaderTabValid();
					            if(validI == '0') setItemDetailTabInvalid(); else setItemDetailTabValid();
					        }
					        */
                            if (validBatch == '0')
                                setValidationImage(false);
                            else
                                setValidationImage(true);
                        }
                        if (arr.length >= 10) {
                            var newErrors = arr[9];
                            var index = newErrors.indexOf('~');
                            var id = newErrors.substr(0, index);
                            var errorList = newErrors.substr(index + 2, t.length);

                            setValidationHTML(id, errorList);
                        }
                    }
                    // effective date changes
                    if (arr.length >= 11) {
                        if (arr[10] == "1") {
                            enableEffectiveDate(true);
                            if (arr.length >= 12) {
                                if (arr[11] != '') {
                                    $('txtEffectiveDate').value = arr[11];
                                }
                            }
                        } else if (arr[10] == "0") {
                            enableEffectiveDate(false);
                        }
                    }
                    // REFRESH THE GRID ??
                    if (arr.length >= 13) {
                        if (arr[12] == "1") {
                            reloadPage();
                        }
                    }
                }
                else { alert("ERROR: There was a problem saving the cell data!"); }
            }
            else if (arr[0] == "200") {
                // saveDataSetAll

                if (arr[1] == "1") {
                    //alert("SUCCESS !");
                    reloadPage();
                }
                else { alert("ERROR: There was a problem saving the cell data!"); }
            }
            else if (arr[0] == "300") {
                // VALIDATE ENTIRE SHEET
                if (arr[1] == "1") {
                    //alert("SUCCESS !");
                    if (arr.length >= 3) {
                        if (arr[2] == "1") {
                            if ($('itemDetailImage')) $('itemDetailImage').src = 'images/valid_yes_small.gif';
                            if ($('validationDisplay')) Element.hide('validationDisplay');
                        } else {
                            if ($('itemDetailImage')) $('itemDetailImage').src = 'images/valid_no_small.gif';
                            if ($('validationDisplay')) Element.show('validationDisplay');
                        }
                    }
                }
                else { alert("ERROR: There was a problem saving the cell data!"); }
            }
            else if (arr[0] == "DELETEIMAGE") {
                if (arr[1] == "1" && arr.length >= 4) {
                    clearImage(arr[2]);
                    // refresh validation errors
                    if (arr.length >= 5) {
                        resetRow(arr[2], 'gCVE');
                        if (arr[4] != '') {
                            var toRun = "setCellClass('gCVE', " + arr[4] + ");"
                            eval(toRun);
                        }
                        if (arr.length >= 6 && arr[5] != '')
                            eval("resetValIcon(" + arr[2] + ", " + arr[5] + ");");

                        // GO VALIDATE ENTIRE SHEET
                        var goValue = "300" + callbackSep + "";
                        //CallServer(goValue, "");
                    }
                }
                else { alert("ERROR: There was a problem deleting the Item Image!"); }
            }
            else if (arr[0] == "DELETEMSDS") {
                if (arr[1] == "1" && arr.length >= 4) {
                    clearMSDS(arr[2]);
                    // refresh validation errors
                    if (arr.length >= 5) {
                        resetRow(arr[2], 'gCVE');
                        if (arr[4] != '') {
                            var toRun = "setCellClass('gCVE', " + arr[4] + ");"
                            eval(toRun);
                        }
                        if (arr.length >= 6 && arr[5] != '')
                            eval("resetValIcon(" + arr[2] + ", " + arr[5] + ");");

                        // GO VALIDATE ENTIRE SHEET
                        var goValue = "300" + callbackSep + "";
                        //CallServer(goValue, "");
                    }
                }
                else { alert("ERROR: There was a problem deleting the Item MSDS Sheet!"); }
            }
            else if (arr[0] == "UPDATEMSDS") {
                if (arr[1] == "1" && arr.length >= 4) {
                    // refresh validation errors
                    if (arr.length >= 5) {
                        resetRow(arr[2], 'gCVE');
                        if (arr[4] != '') {
                            var toRun = "setCellClass('gCVE', " + arr[4] + ");"
                            eval(toRun);
                        }
                        if (arr.length >= 6 && arr[5] != '')
                            eval("resetValIcon(" + arr[2] + ", " + arr[5] + ");");

                        // GO VALIDATE ENTIRE SHEET
                        var goValue = "300" + callbackSep + "";
                        //CallServer(goValue, "");
                    }
                }
                else { alert("ERROR: There was a problem updating the Item MSDS Sheet!"); }
            }
            else if (arr[0] == "UPDATEIMAGE") {
                if (arr[1] == "1" && arr.length >= 4) {
                    // refresh validation errors
                    if (arr.length >= 5) {
                        resetRow(arr[2], 'gCVE');
                        if (arr[4] != '') {
                            var toRun = "setCellClass('gCVE', " + arr[4] + ");"
                            eval(toRun);
                        }
                        if (arr.length >= 6 && arr[5] != '')
                            eval("resetValIcon(" + arr[2] + ", " + arr[5] + ");");

                        // GO VALIDATE ENTIRE SHEET
                        var goValue = "300" + callbackSep + "";
                        //CallServer(goValue, "");
                    }
                }
                else { alert("ERROR: There was a problem updating the Item Image!"); }
            }
            else if (arr[0] == "EFFECTIVEDATE") {
                if (arr[1] == "1") {
                    // save success
                    saveEffectiveDateComplete();
                }
                else { alert("ERROR: There was a problem updating the Effective Date!"); }
            }

            else { alert("ERROR: Unknown callback response given!" + " (" + arr[0] + ")"); }
        }
        else { alert("ERROR: Invalid callback response given!"); }
    }
}


function openTaxWizard(id) {
    var url = 'Tax_Wizard.aspx?type=D&id=' + id;
    var win = window.open(url, 'taxwiz', 'scrollbars=0,location=0,menubar=0,titlebar=0,toolbar=0,width=700,HEIGHT=525');
    return false;
}
function openTaxWizardSA(hid, id) {
    var url = 'Tax_Wizard.aspx?type=D&sa=1&hid=' + hid + '&id=' + id;
    var win = window.open(url, 'taxwiz', 'scrollbars=0,location=0,menubar=0,titlebar=0,toolbar=0,width=700,HEIGHT=525');
    return false;
}
function updateItemTaxWizard(id, completed, taxUDA) {
    if (!completed || completed == null)
        completed = false;
    if (taxUDA == null) taxUDA = 0;
    if (!isNum(taxUDA)) taxUDA = 0;
    var imgID = 'taxwiz' + id;
    if ($(imgID)) {
        $(imgID).src = (completed) ? 'images/checkbox_true.gif' : 'images/checkbox_false.gif';
    }
    var cell = 'gce_' + id + '_' + getGIID('TaxUDA');
    if ($(cell)) {
        $(cell).innerText = taxUDA;
        setCell($(cell), taxUDA, getGIID('TaxUDA'), 'Tax_UDA', id);
    }
    else
        alert('Error: Could not update Tax UDA after completing the Tax Wizard!');
}

function preloadItemImages() {
    var img1 = new Image(); img1.src = 'images/tab_item_detail_on.gif';
}

var valArray = new Array();

function setValIcon(id, display) {
    var o = $('h_row_' + id);
    if (o) { o.innerHTML = (o.innerHTML + display); }
}
function resetValIcon(id, display) {
    var o = $('h_row_' + id);
    if (o) { o.innerHTML = ('<img src="./images/spacer.gif" width="20" height="1" alt="" />' + display); }
}

function elementEquals(elementid, value) {
    if ($(elementid)) {
        if ($(elementid).value == value)
            return true;
        else
            return false;
    } else {
        return false;
    }
}

function elementTextEquals(elementid, value) {
    if ($(elementid)) {
        if ($(elementid).innerText == value)
            return true;
        else
            return false;
    } else {
        return false;
    }
}

function setValidationHTML(itemID, value) {

    //Create HTML node for new Error list
    var newVal = document.createElement('div');
    newVal.innerHTML = value;

    //Create a new Error list that contains all errors except errors related to the recordID  (thus removing these errors)
    var newHTML = document.createElement("ul");
    $('validationDisplayTD').select("li").each(function (li, index) {
        var spanMatch = $(li).select("span[title='" + itemID + "']");
        if (spanMatch.length == 0) {
            $(newHTML).insert(li);
        }
    });

    //Add new errors to the Error List
    var errorList = $(newVal).select('li');
    if (errorList.length > 0) {
        $(newVal).select('li').each(function (li, index) {
            $(newHTML).insert(li);
        });
    }

    //If there is still Errors or Warnings, then replace the old list with the new list
    if (newHTML.innerHTML != "") {
        //Replace the old Error List with the new Error List
        $('validationDisplayTD').innerHTML = '<div class="validationDisplay" id="validationDisplay" style="color: rgb(153, 51, 0);">Validation Errors <ul>' + newHTML.innerHTML + '</ul></div>';
        $('validationDisplayTD').setStyle('height', 'auto');
        $('validationDisplayTD').show();
    }
    else {
        //Blank out the Validation Summary (to hide it).
        $('validationDisplayTD').innerHTML = '';
        $('validationDisplayTD').setStyle('height', '1px');
        $('validationDisplayTD').hide();
    }

    //Set Batch Validity image
    if ($('validationDisplayTD').innerHTML.indexOf('sevError') > 0) {
        setValidationImage(false);
    }
    else {
        setValidationImage(true);
    }
    
}

/**********************/
/*** MISC FUNCTIONS ***/
/**********************/

function resetRow(row, removeStyle) {
    var i;
    var id;
    for (i = 1; i <= gridEC; i++) {
        id = 'gc_' + row + '_' + i;
        if ($(id))
            Element.removeClassName(id, removeStyle);
    }
}

function setCellClass(addStyle, cells) {
    var i, id;
    var a = setCellClass.arguments;
    for (i = 1; i < a.length; i++) {
        id = a[i];
        Element.addClassName(id, addStyle);
    }
}

function resetRowErrors(row) {
    var i;
    var id;
    for (i = 1; i <= gridEC; i++) {
        id = 'gc_' + row + '_' + i;
        if ($(id))
            Element.removeClassName(id, 'gCVE');
        Element.removeClassName(id, 'gCVW');
    }
}

function setCellErrors(cells) {
    var i, id, etype;
    var a = setCellErrors.arguments;
    for (i = 0; i < a.length - 1; i += 2) {
        id = a[i];
        etype = a[i + 1];
        if (etype == '2')
            Element.addClassName(id, 'gCVW');
        else
            Element.addClassName(id, 'gCVE');
    }
}