
/*****************/
/*** AJAX Edit ***/
/*****************/

var gridSkipCol = '';
var cellAdjust = 20;
var gi = new Array();
function getGI(index){
    if (index >= 0 && index < gi.length) 
        return gi[index];
    else 
        return '';
}
//var alertstr = true;
function getGIID(colName) {
    var i;
    var id = -1;

    //var str = '';
    //for (i = 1; i < gi.length; i++) {
    //    str += gi[i] + '||';
    //}
    //if (alertstr) alert(str);
    //alertstr = false;

    for(i=1;i<gi.length;i++) {
        if(gi[i] != null && gi[i] == colName) {
            id = i;
            break;
        }
    }
    return id;
}
/*************************/
// listvalue cols (skip blank option)
/*************************/
var lvno = new Array();
function addLVNO(id) {
    lvno[lvno.length] = id;
}
function addLVNOByName(colName) {
    var id = getGIID(colName);
    if(id >= 0)
        addLVNO(id);
}
function addLVBlankOption(id) {
    var i;
    if(lvno.length > 0) {
        for(i = 0; i < lvno.length; i++) {
            if(lvno[i] == id) return false;
        }
    }
    return true;
}
/*************************/

/*************************/
/* LOCK CELLS            */
/*************************/
var lcarr = new Array();
function LockCell(){
    this.rowid = -1;
    this.cols = new Array();
}
LockCell.prototype.colExists = function(colid) {
    for(var i = 0; i < this.cols.length; i++){
        if(this.cols[i] == colid)
            return true;
    }
    return false;
}
LockCell.prototype.addCol = function(colid) {
    this.cols[this.cols.length] = colid;
}
function addLC(rowid, colid)
{
    var i;
    var lc = null;
    for(i = 0; i < lcarr.length; i++){
        if(lcarr[i].rowid == rowid){
            lc = lcarr[i];
            break;
        }
    }
    if(lc == null){
        lc = new LockCell();
        lc.rowid = rowid;
        lcarr[lcarr.length] = lc;
    }
    lc.addCol(colid);
}
function isCellLocked(rowid, colid){
    var i;
    for(i = 0; i < lcarr.length; i++){
        if(lcarr[i].rowid == rowid){
            if(lcarr[i].colExists(colid)){
                return true;
            }
            break;
        }
    }
    return false;
}
/*************************/
/*************************/

/*************************/
var grarr = new Array();
var gcarr = new Array();
function GridCell(){
  this.row = -1;
  this.col = -1;
  this.rowid = -1;
  this.colid = -1;
  this.validCell = function(){
    return (this.row != -1 && this.col != -1);
  }
}

function addGridRow(rid){
  var i = grarr.length;
  grarr[i] = rid;
  return i; // return the index
}
function addGR(rid){return addGridRow(rid);}

function getGridRowIndex(rid){
  var ret = -1, i;
  for (i = 0; i < grarr.length; i++) {
    if (grarr[i] == rid) {
      ret = i;
      break;
    }
  }
  return ret;
}

function addGridCol(cid){
  var i = gcarr.length;
  gcarr[i] = cid;
  return i; // return the index
}
function addGC(cid){return addGridCol(cid);}

function getGridColIndex(cid){
  var ret = -1, i;
  for (i = 0; i < gcarr.length; i++) { 
    if (gcarr[i] == cid) {
      ret = i;
      break;
    }
  }
  return ret;
}

function getGridCell(rid, cid){
  var r, c, i;
  r = getGridRowIndex(rid);
  c = getGridColIndex(cid);
  var gc = new GridCell();
  gc.row = r;
  gc.col = c;
  if(r != -1 && c != -1){
    gc.rowid = rid;
    gc.colid = cid;
  }
  return gc;
}

function getNextGridCell(rid, cid, direction){
    var rindex, cindex;
    var ngc = new GridCell();
    if (!direction || direction == null) 
        direction = "right";
    gc = getGridCell(rid, cid);
    if (gc.row != -1 && gc.col != -1) {
        switch (direction) {
            case "right":
            case "r":
                if (gc.col < (gcarr.length - 1)) {
                    // move right 1 col
                    ngc.row = gc.row;
                    ngc.col = gc.col + 1;
                }
                else {
                    if (gc.row < (grarr.length - 1) && gcarr.length > 0) {
                        //move down 1 row to first col
                        ngc.row = gc.row + 1;
                        ngc.col = 0;
                    }
                }
                break;
            case "left":
            case "l":
                if (gc.col > 0) {
                    // move left 1 col
                    ngc.row = gc.row;
                    ngc.col = gc.col - 1;
                }
                else {
                    if (gc.row > 0 && gcarr.length > 0) {
                        //move up 1 row to last col
                        ngc.row = gc.row - 1;
                        ngc.col = gcarr.length - 1;
                    }
                }
                break;
            case "up":
            case "u":
                if (gc.row > 0) {
                    ngc.row = gc.row - 1;
                    ngc.col = gc.col;
                }
                break;
            case "down":
            case "d":
                if (gc.row < (grarr.length - 1)) {
                    ngc.row = gc.row + 1;
                    ngc.col = gc.col;
                }
                break;
        }
    }
    if (ngc.validCell()) {
        ngc.rowid = grarr[ngc.row];
        ngc.colid = gcarr[ngc.col];
        if (gridSkipCol != '' && gi[ngc.colid] == gridSkipCol){
            return getNextGridCell(ngc.rowid, ngc.colid, direction);
        }
        if(isCellLocked(ngc.rowid, ngc.colid)){
            return getNextGridCell(ngc.rowid, ngc.colid, direction);
        }
    }
    
    return ngc;
}


/*************************/
function processEditKeyDown(o, e, rid, cid, type, setall){
  setall = (!setall || setall == null) ? false : true;
  var kc = (e.which) ? e.which : e.keyCode;
  var mc = false;
  switch (kc) {
    case 8:  // backspace
    case 16: // shift
    case 17: // ctrl
    case 18: // alt
    case 35: // end
    case 36: // home
    case 37: // left arrow
    case 39: // right arrow
    case 45: // insert
    case 46: // delete
      return true;
      break;
    case 38:
      // up arrow
      if (!setall) {
          mc = true;
          ngc = getNextGridCell(rid, cid, "u");
      }
      break;
    case 40:
      // down array
      if (!setall) {
          mc = true;
          ngc = getNextGridCell(rid, cid, "d");
      }
      break;
    case 9:
      // tab key
      if (!setall) {
          mc = true;
          if(e.shiftKey)
            ngc = getNextGridCell(rid, cid, "l");
          else
            ngc = getNextGridCell(rid, cid, "r");
      }
      break;
    case 13:
      // enter key
      if (!setall) {
          mc = true;
          ngc = new GridCell();
      } else {
        //setAllSave();
        var t = setTimeout('setAllSave();', 170);
        return false;
      }
      break;
    case 67:
    case 86:
    case 88:
    case 90:
	  if(e.ctrlKey) return true;
	  break;
  }
  if(mc==true){
    
    //var cmd  = Element.readAttribute(o, "onblur");
    var cmd = getElementAttribute(o, "onblur");
    cmd = cmd.replace(/this./g, "o.");
    Element.writeAttribute(o, "onblur", "");
    eval(cmd);
    if(ngc.row!=-1&&ngc.col!=-1){
      var obj = $("gc_"+ngc.rowid+"_"+ngc.colid);
      if (obj && obj != null) {
        cmd = Element.readAttribute(obj, "ondblclick");
        if (cmd != "" && cmd != null) {
          cmd = cmd.replace(/this,/, "$('gc_"+ngc.rowid+"_"+ngc.colid+"'),");
          //eval(cmd);
          var t = setTimeout(cmd, 170);
        }
      }
    }
    
    return false;
  }
  switch (type){
    case 'n':
      if ( (kc<48||kc>57) && (kc<96||kc>105) && (kc!=190&&kc!=110)) {
        return false;
      } else if(e.shiftKey) {
          return false;
      } else if(!isValidDecimal4($(o))) {
        return false;
      }
      break;
    case 'i':
      if ( (kc<48||kc>57) && (kc<96||kc>105))
        return false;
      else{
        if(e.shiftKey)
          return false;
      }
      break;
    case 's':
    case 'd':
    case 'dd':
      return true;
  }
  return true;
}

function getElementAttribute(o, attribute){
    var n =  o.attributes.getNamedItem(attribute);
    if(n) return n.value; else return '';
}

function isNumeric(stringValue){
    var val;
    val = parseFloat(stringValue);
    if (isNaN(val)) 
        return false;
    else 
        return true;
}

function hideWaitLayer(){
    Element.hide($("waitLyr"));
    window.status = "";
}

function cache_ShowWaitLayer(p_Status, p_InnerHTML){
    window.status = p_Status;
    $("waitText").innerHTML = p_InnerHTML;
    Element.show($("waitLyr"));
    $("waitLyr").style.top = document.body.scrollTop;
    
    return true;
}

var previousText;
var currentText;
var previousPrefix;
var previousSuffix;


//******************//
// REGULAR TEXT BOX
//******************//
function eC(cell, p_Column_ID, p_Row_ID, maxLen)
{
    if(isCellLocked(p_Row_ID, p_Column_ID)) return false;
    setAllClose();
    var edit = $(getEditID(p_Row_ID, p_Column_ID));
    previousText = new String(edit.innerText);
    currentText = new String(edit.innerText);
    var max = (!maxLen || maxLen == null || maxLen == '') ? '' : ' maxlength="' + maxLen.toString() + '"';
    
    var p_Column_Name = getGI(p_Column_ID);
    //gridDataCol_Resize("col_" + p_Column_ID + "_data", Element.getDimensions(cell).width);
    //gridDataCol_Resize("col_" + p_Column_ID + "_dataimg", Element.getDimensions(cell).width);
    edit.innerHTML = '<input ' +
    ' id="editCell"' +
    max + 
    ' ondblclick="event.cancelBubble = true;"' +
    ' onblur="setCell(this.parentElement, this.value, \'' +
    p_Column_ID +
    '\', \'' +
    p_Column_Name +
    '\', \'' +
    p_Row_ID +
    '\');" ' +
    ' value=""' +
    ' class="bodyText ' +
    //Element.classNames(cell) +
    'datarow editcell"' +
    ' style="width: ' +
    (Element.getDimensions(cell).width - cellAdjust) +
    'px;"' +
    ' onkeydown="return processEditKeyDown(this, event, \'' + p_Row_ID + '\', \'' + p_Column_ID + '\', \'s\');"' +
    '>';
    
    initGridDataLayout(p_Column_ID, p_Column_ID);

    Element.removeClassName('editCell', 'gCVE');
    Element.removeClassName('editCell', 'gCVW');
    $("editCell").value = (currentText == "&nbsp;") ? " " : currentText;
    $("editCell").focus();
    $("editCell").select();
}

function setCell(cell, value, p_Column_ID, p_Column_Name, p_Row_ID){
    // cell = <span id="gce_row_col"... ></span>
    if (previousText != value) saveData(p_Column_ID, p_Column_Name, p_Row_ID, value); else gridSkipCol = '';
    //alert(value + '  |||  ' + value.escapeHTML());
    cell.innerText = value + "";
    if(showChanges() && previousText != value) {
        var id = 'gce_' + p_Row_ID + '_' + p_Column_ID;
        var o1 = $(id), o2 = $(id + '_ORIG');
        if(o1 && o2) {
            showHideNLCGWrapper(id, o1.innerHTML, o2.value.escapeHTML());
        }
    }
    
    resizeGridCol(p_Column_ID);
}

//*****************//
// NUMBER TEXT BOX
//*****************//
function eNC(cell, p_Column_ID, p_Row_ID, intonly, maxLen, p_min, p_max){
    if(isCellLocked(p_Row_ID, p_Column_ID)) return false;
    setAllClose();
    var edit = $(getEditID(p_Row_ID, p_Column_ID));
    if (!intonly || intonly == null || intonly == '') 
        intonly = '0';
    var max = (!maxLen || maxLen == null || maxLen == '') ? '' : ' maxlength="' + maxLen.toString() + '"';
    if (!p_min || p_min == null) 
        p_min = '';
    if (!p_max || p_max == null) 
        p_max = '';
    var io = (intonly == '1') ? "1" : "0";
    var iot = (intonly == '1') ? "i" : "n";
    
    var p_Column_Name = getGI(p_Column_ID);
    
    previousText = new String(edit.innerText);
    currentText = new String(edit.innerText);
    previousPrefix = getNumberPrefix(currentText);
    previousSuffix = getNumberSuffix(currentText);
    
    edit.innerHTML = '<input ' +
    ' id="editCell"' +
    max + 
    ' ondblclick="event.cancelBubble = true;"' +
    ' onblur="setNumberCell(this.parentElement, this.value, \'' + p_Column_ID + '\', \'' +
    p_Column_Name +
    '\', \'' +
    p_Row_ID +
    '\', \'' +
    p_min +
    '\', \'' +
    p_max +
    '\', \'' +
    io +
    '\');" ' +
    ' value=""' +
    ' class="bodyText ' +
    //Element.classNames(cell) +
    'datarow editcell"' +
    ' style="width: ' +
    (Element.getDimensions(cell).width - cellAdjust) +
    'px;"' +
    ' onkeydown="return processEditKeyDown(this, event, \'' + p_Row_ID + '\', \'' + p_Column_ID + '\', \'' + iot + '\');"' +
    '>';
    
    initGridDataLayout(p_Column_ID, p_Column_ID);
    
    Element.removeClassName('editCell', 'gCVE');
    Element.removeClassName('editCell', 'gCVW');
    $("editCell").value = (currentText == "&nbsp;") ? " " : getNumberFromString(currentText);
    $("editCell").focus();
    $("editCell").select();
}

function setNumberCell(cell, value, p_Column_ID, p_Column_Name, p_Row_ID, p_min, p_max, intonly){
    // cell = <span id="gce_row_col"... ></span>
    var io = (intonly == "1") ? true : false;
    if(cell==null)
		return false;
    
    if (value == "" || (isNumeric(value) && ((io && isInteger(value)) || (!io)) && isNumberWithinRange(value, p_min, p_max))) {
        if(previousText != (previousPrefix + value + previousSuffix)) saveData(p_Column_ID, p_Column_Name, p_Row_ID, value); else gridSkipCol = '';
        cell.innerText = previousPrefix + value + previousSuffix + "";
        
        if(showChanges() && previousText != (previousPrefix + value + previousSuffix)) {
            var id = 'gce_' + p_Row_ID + '_' + p_Column_ID;
            var o1 = $(id), o2 = $(id + '_ORIG');
            if(o1 && o2) {
                showHideNLCGWrapper(id, parseFloat(getNumberFromString(o1.innerHTML)), parseFloat(getNumberFromString(o2.value.escapeHTML())));
            }
        }
        
        //if(previousText != value) initGridDataLayout(p_Column_ID, p_Column_ID);
    }
    else {
        var msg = (io) ? "Sorry, please enter a whole number" : "Sorry, please enter a number";
        if (isValidRange(p_min, p_max)) 
            msg += " between " + p_min + " and " + p_max;
        msg += ".";
        alert(msg);
        cell.innerText = previousText + "";
    }
    resizeGridCol(p_Column_ID);
}

function isValidRange(p_min, p_max){
    if (isInteger(p_min) && isNumeric(p_min) && isInteger(p_max) && isNumeric(p_max) && p_min.length >= 0 && p_max.length > 0) 
        return true;
    else 
        return false;
}

function isNumberWithinRange(value, p_min, p_max){
    if (isValidRange(p_min, p_max)) {
        var valtest = parseInt(value);
        if (valtest >= parseInt(p_min) && valtest <= parseInt(p_max)) 
            return true;
        else 
            return false;
    }
    else 
        return true;
}
var gridLV = new Array();
function getGridLVOptions(lvGroup, value)
{
    var i,s = "";
    for(i=0;i<gridLV.length;i++) {
        if(gridLV[i][0] == lvGroup){
            s += '<option value="' + gridLV[i][1] + '"';
            if(gridLV[i][1] == value)
                s += ' selected="selected"';
            s += '>' + gridLV[i][2] + '</option>';
        }
    }
    return s;
}
function getGridLVText(lvGroup, value)
{
    var i,s = "";
    for(i=0;i<gridLV.length;i++) {
        if(gridLV[i][0] == lvGroup){
            if(gridLV[i][1] == value) {
                 s += gridLV[i][2];
                 break;
            }
        }
    }
    return s;
}

//********************//
// DROP DOWN TEXT BOX
//********************//
function eDD(cell, p_Column_ID, p_Row_ID, lvGroup)
{
    if(isCellLocked(p_Row_ID, p_Column_ID)) return false;
    setAllClose();
    var edit = $(getEditID(p_Row_ID, p_Column_ID));
    previousText = new String(edit.innerText);
    currentText = new String(edit.innerText);
    
    var p_Column_Name = getGI(p_Column_ID);
    
    
    edit.innerHTML = '<select ' +
    ' id="editDDCell"' +
    ' ondblclick="event.cancelBubble = true;"' +
    ' onblur="setDropDownCell(this.parentElement, this.options[this.selectedIndex].value, \'' +
    p_Column_ID +
    '\', \'' +
    p_Column_Name +
    '\', \'' +
    p_Row_ID +
    '\');" ' +
    ' class="bodyText ' +
    //Element.classNames(cell) +
    'datarow editcell"' +
    ' onkeydown="return processEditKeyDown(this, event, \'' + p_Row_ID + '\', \'' + p_Column_ID + '\', \'l\');"' +
    '>' + ((addLVBlankOption(p_Column_ID)) ? '<option value=""></option>' : '') + getGridLVOptions(lvGroup, previousText) + '</select>';
    initGridDataLayout(p_Column_ID, p_Column_ID);
    Element.removeClassName('editDDCell', 'gCVE');
    Element.removeClassName('editDDCell', 'gCVW');
    $("editDDCell").focus();
    
}

function setDropDownCell(cell, value, p_Column_ID, p_Column_Name, p_Row_ID){
    //cell = <span id="gce_row_col"... ></span>
    if (previousText != value) saveData(p_Column_ID, p_Column_Name, p_Row_ID, value); else gridSkipCol = '';
    cell.innerText = value + "";
    if(showChanges() && previousText != value) {
        var id = 'gce_' + p_Row_ID + '_' + p_Column_ID;
        var o1 = $(id), o2 = $(id + '_ORIG');
        if(o1 && o2) {
            showHideNLCGWrapper(id, o1.innerHTML, o2.value.escapeHTML());
        }
    }
    
    resizeGridCol(p_Column_ID);
}

function selectDropDownOptionbyText(selObj, desiredText){
    for (i = 0; i < selObj.options.length; i++) {
        if (selObj.options[i].text == desiredText) {
            selObj.options[i].selected = true;
        }
    }
}

function selectDropDownOptionbyValue(selObj, desiredValue){
    for (i = 0; i < selObj.options.length; i++) {
        if (selObj.options[i].value == desiredValue) {
            selObj.options[i].selected = true;
        }
    }
}

function showWaitLayer(p_Status, p_InnerHTML){
    window.status = p_Status;
    $("waitText").innerHTML = p_InnerHTML;
    Element.show($("waitLyr"));
    $("waitLyr").style.top = document.body.scrollTop;
    
    return true;
}

function highlightRow(p_row_element_id){
    $(p_row_element_id).addClassName("rover")
}

function unhighlightRow(p_row_element_id){
    $(p_row_element_id).removeClassName("rover")
}

var CurrentDatePicker_ColumnID = "";
var CurrentDatePicker_ColumnName = "";
var CurrentDatePicker_RowID = "";
var CurrentDatePicker_TargetCell = new Object();

//***************//
// DATE TEXT BOX
//***************//
var griddate1;
function sDP(cell, p_Column_ID, p_Row_ID)
{
    if(isCellLocked(p_Row_ID, p_Column_ID)) return false;
    setAllClose();
    var edit = $(getEditID(p_Row_ID, p_Column_ID));
    previousText = new String(edit.innerText);
    currentText = new String(edit.innerText);

    
    var p_Column_Name = getGI(p_Column_ID);
    edit.innerHTML = '<span id="date1_' + p_Column_ID + '_' + p_Row_ID + '"><input type="text" ' +
    ' id="editCell"' +
    ' ondblclick="event.cancelBubble = true;"' +
    ' onblur="setDateCell(this.parentElement, this.value, \'' +
    p_Column_ID +
    '\', \'' +
    p_Column_Name +
    '\', \'' +
    p_Row_ID +
    '\');" ' +
    ' value=""' +
    ' class="bodyText ' +
    //Element.classNames(cell) +
    'datarow editcell"' +
    ' style="width: ' +
    (Element.getDimensions(cell).width - cellAdjust) +
    'px;"' +
    ' onkeydown="return processEditKeyDown(this, event, \'' + p_Row_ID + '\', \'' + p_Column_ID + '\', \'d\');"' +
    '></span>';
    
    initGridDataLayout(p_Column_ID, p_Column_ID);

    Element.removeClassName('editCell', 'gCVE');
    Element.removeClassName('editCell', 'gCVW');
    $("editCell").value = (currentText == "&nbsp;") ? "" : currentText;
    $("editCell").focus();
    $("editCell").select();
    
    griddate1 = new Spry.Widget.ValidationTextField("date1_" + p_Column_ID + "_" + p_Row_ID, "date", {format:"mm/dd/yyyy", isRequired:false, validateOn:["change"], useCharacterMasking:true});
}

function setDateCell(cell, value, p_Column_ID, p_Column_Name, p_Row_ID){
    // cell = <span id="gce_row_col"...></span>
    if(cell==null)
		return false;
    
    if (value == "" || (value != "" && isDate2(value))) {
        if(previousText != value) saveData(p_Column_ID, p_Column_Name, p_Row_ID, value); else gridSkipCol = '';
        cell.innerText = value + "";
        if(showChanges() && previousText != value) {
            var id = 'gce_' + p_Row_ID + '_' + p_Column_ID;
            var o1 = $(id), o2 = $(id + '_ORIG');
            if(o1 && o2) {
                showHideNLCGWrapper(id, o1.innerHTML, o2.value.escapeHTML());
            }
        }
    }
    else {
        var msg = "Please enter a valid date.";
        alert(msg);
        cell.innerText = previousText + "";
    }
    resizeGridCol(p_Column_ID);
}

var dtCh = "/";
var minYear = 1900;
var maxYear = 2100;

function isValidDecimal4(o) {
    var valid = true;
    var s = o.value, i, c, pos = -1;
    for(i = 0; i < s.length; i++) {
        c = s.charAt(i);
        if(c == '.'){
            if(pos < 0){
                pos = i;
            }else{
                valid = false;
                break;
            }
        }else {
            var s1 = getSelectedText();  
            if(pos >= 0 && ((i - pos + 1) > 4) && s1.length <= 0) {
                valid = false;
                break;
            }
        }
    }
    return valid;
}

function getSelectedText()
{
    var txt = '';
    if (window.getSelection) {
        txt = window.getSelection();
    } else if (document.getSelection) { // FireFox
        txt = document.getSelection();
    } else if (document.selection)  { // IE 6/7
        txt = document.selection.createRange().text;
    }
    return txt;
}

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
    //lp fix, do not do suffix if lenth is 1 or less
    if (s.lenght > 1){
        for (i = (s.length - 1); i >= 0; i--) {
            var c = s.charAt(i);
            if (((c < "0") || (c > "9")) && c != ".") 
                ret = c + ret;
            else 
                break;
        }
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

function isDate(dtStr){
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
        alert("The date format should be : mm/dd/yyyy");
        return false;
    }
    if (strMonth.length < 1 || month < 1 || month > 12) {
        alert("Please enter a valid month");
        return false;
    }
    if (strDay.length < 1 || day < 1 || day > 31 || (month == 2 && day > daysInFebruary(year)) || day > daysInMonth[month]) {
        alert("Please enter a valid day");
        return false;
    }
    if (strYear.length != 4 || year == 0 || year < minYear || year > maxYear) {
        alert("Please enter a valid 4 digit year between " + minYear + " and " + maxYear);
        return false;
    }
    if (dtStr.indexOf(dtCh, pos2 + 1) != -1 || isInteger(stripCharsInBag(dtStr, dtCh)) == false) {
        alert("Please enter a valid date");
        return false;
    }
    return true;
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

function isDate3(dateString)
{
    var d = Date.parse(dateString);
    if (isNaN(d))
        return false;
    else
        return true;
}

function isNumber(strIn){
    if (isNaN(strIn)) {
        alert("Please enter a valid number.")
        return false;
    }
    return true;
}




/**********************/
/*** SET ALL FIELDS ***/
/**********************/

var setalldrag = null;
var setallid = 0;
function showSetAll(cell, colID, headerText, func, funcparam)
{
    if(setallid > 0)
        setAllClose();
    var o = $('gridSetAll')
    if(o && colID > 0) {
        // set the id
        setallid = colID;
        // set the header text
        $('gridSetAllColumn').innerText = headerText;
        // set the control
        var funcstring = func + "($('gridSetAllData')," + colID;
        $('gridSetAllType').value = func;
        $('gridSetAllParam').value = funcparam;
        $('gridSetAllCID').value = colID;
        $('gridSetAllCName').value = getGI(colID);
        switch(func) {
            case "sDPSA":
                funcstring += ")";
                break;
            case "eNCSA":
                funcstring += ",'" + funcparam + "')";
                break;
            case "eDDSA":
                funcstring += ",'" + funcparam + "')";
                break;
            default:
                // eCSA
                funcstring += "," + funcparam + ")";
                break;
        }
        $('gridSetAllData').innerHTML = "";
        
        // position the div
        //var strElemID = cell.id;
		//if( strElemID != undefined )
		if(cell != undefined && cell != null)
		{
			var newXPos = Element.positionedOffset(cell).left + (cell.offsetWidth / 2) - 125;
			if(newXPos < 0)
			    newXPos = 0;
			var newYPos = Element.positionedOffset(cell).top + cell.offsetHeight;
			
			o.style.left = newXPos;// - 6;
			o.style.top = newYPos - 8;
		}
		// highlight the cell
		if($("col_"+setallid))
		    Element.addClassName($("col_"+setallid), "gHCHL");
        // show the div
        Element.show(o);
        eval(funcstring);
        // setup the draggable
        setalldrag = new Draggable('gridSetAll');// , {handle:'gridSetAllHeader'});
    }
}

function setAllClose()
{
    var o = $('gridSetAll')
    if(o) {
        // clear the header text
        $('gridSetAllColumn').innerHTML = "&nbsp;";
        // clear the control
        $('gridSetAllData').innerHTML = "&nbsp;";
        // hide the div
        //o.style.display = "none";
        Element.hide(o);
        // unhighlight the cell
		if($("col_"+setallid))
		    Element.removeClassName($("col_"+setallid), "gHCHL");
        // clear the draggable
        if(setalldrag != null) {
            setalldrag.destroy();
            setalldrag = null;
        }
    }
    // clear the id
    setallid = 0;
}

function setAllSave()
{
    var f = $('gridSetAllType').value;
    var param = $('gridSetAllParam').value;
    var cid = $('gridSetAllCID').value;
    var cname = $('gridSetAllCName').value;
    switch(f) {
            case "sDPSA":
                setDateCellSA($('gridSetAllData'), $("editCellSA").value, cid, cname);
                break;
            case "eNCSA":
                setNumberCellSA($('gridSetAllData'), $("editCellSA").value, cid, cname, '', '', param);
                break;
            case "eDDSA":
                var o = $("editDDCellSA");
                setDropDownCellSA($('gridSetAllData'), o.options[o.selectedIndex].value, cid, cname);
                break;
            default:
                // eCSA
                setCellSA($('gridSetAllData'), $("editCellSA").value, cid, cname);
                break;
    }
}


/*************************/
/*** AJAX Edit set all ***/
/*************************/

function eCSA(cell, p_Column_ID, maxLen)
{
    var max;
    if (!maxLen || maxLen == null || maxLen == '')
		max = '';
	else
		max = ' maxlength="' + maxLen.toString() + '"';
    
    var p_Column_Name = getGI(p_Column_ID);
    cell.innerHTML = '<input ' +
    ' id="editCellSA"' +
    max + 
    ' ondblclick="event.cancelBubble = true;"' +
    ' value=""' +
    ' class="bodyText ' +
    //Element.classNames(cell) +
    'datarow editcell"' +
    ' style="width: ' +
    (Element.getDimensions(cell).width - cellAdjust) +
    'px;"' +
    ' onkeydown="return processEditKeyDown(this, event, \'' + 0 + '\', \'' + p_Column_ID + '\', \'s\', true);"' +
    '>';

    $("editCellSA").value = "";
    $("editCellSA").focus();
    $("editCellSA").select();
}

function setCellSA(cell, value, p_Column_ID, p_Column_Name){
    saveDataSetAll(p_Column_ID, p_Column_Name, value);
    cell.innerText = "";
    setAllClose();
}

function eNCSA(cell, p_Column_ID, intonly, p_min, p_max){
    if (!intonly || intonly == null || intonly == '') 
        intonly = '0';
    if (!p_min || p_min == null) 
        p_min = '';
    if (!p_max || p_max == null) 
        p_max = '';
    var io = (intonly == '1') ? "1" : "0";
    var iot = (intonly == '1') ? "i" : "n";
    
    var p_Column_Name = getGI(p_Column_ID);
    
    cell.innerHTML = '<input ' +
    ' id="editCellSA"' +
    ' ondblclick="event.cancelBubble = true;"' +
    ' value=""' +
    ' class="bodyText ' +
    //Element.classNames(cell) +
    'datarow editcell"' +
    ' style="width: ' +
    (Element.getDimensions(cell).width - cellAdjust) +
    'px;"' +
    ' onkeydown="return processEditKeyDown(this, event, \'' + 0 + '\', \'' + p_Column_ID + '\', \'' + iot + '\', true);"' +
    '>';
    $("editCellSA").value = "";
    $("editCellSA").focus();
    $("editCellSA").select();
}

function setNumberCellSA(cell, value, p_Column_ID, p_Column_Name, p_min, p_max, intonly){
    var io = (intonly == "1") ? true : false;
    if(cell==null)
		return false;
    
    if (value == "" || (isNumeric(value) && ((io && isInteger(value)) || (!io)) && isNumberWithinRange(value, p_min, p_max))) {
        saveDataSetAll(p_Column_ID, p_Column_Name, value);
        cell.innerText = "";
        setAllClose();
    }
    else {
        var msg = (io) ? "Sorry, please enter a whole number" : "Sorry, please enter a number";
        if (isValidRange(p_min, p_max)) 
            msg += " between " + p_min + " and " + p_max;
        msg += ".";
        alert(msg);
    }
}

function eDDSA(cell, p_Column_ID, lvGroup)
{
    var p_Column_Name = getGI(p_Column_ID);
    
    cell.innerHTML = '<select ' +
    ' id="editDDCellSA"' +
    ' ondblclick="event.cancelBubble = true;"' +
    ' class="bodyText ' +
    //Element.classNames(cell) +
    'datarow editcell"' +
    ' onkeydown="return processEditKeyDown(this, event, \'' + 0 + '\', \'' + p_Column_ID + '\', \'l\', true);"' +
    '>' + ((addLVBlankOption(p_Column_ID)) ? '<option value=""></option>' : '') + getGridLVOptions(lvGroup, previousText) + '</select>';
    //initGridDataLayout(p_Column_ID, p_Column_ID);
    $("editDDCellSA").focus();
    
}

function setDropDownCellSA(cell, value, p_Column_ID, p_Column_Name){
    saveDataSetAll(p_Column_ID, p_Column_Name, value);
    cell.innerText = "";
    setAllClose();

}

var griddate1sa;
function sDPSA(cell, p_Column_ID)
{
    var p_Column_Name = getGI(p_Column_ID);
    cell.innerHTML = '<span id="date1_' + p_Column_ID + '"><input type="text" ' +
    ' id="editCellSA"' +
    ' ondblclick="event.cancelBubble = true;"' +
    ' value=""' +
    ' class="bodyText ' +
    //Element.classNames(cell) +
    'datarow editcell"' +
    ' style="width: ' +
    (Element.getDimensions(cell).width - cellAdjust) +
    'px;"' +
    ' onkeydown="return processEditKeyDown(this, event, \'' + 0 + '\', \'' + p_Column_ID + '\', \'d\', true);"' +
    '></span>';

    $("editCellSA").value = "";
    $("editCellSA").focus();
    $("editCellSA").select();
    
    griddate1sa = new Spry.Widget.ValidationTextField("date1_" + p_Column_ID, "date", {format:"mm/dd/yyyy", validateOn:["change"], useCharacterMasking:true});
}

function setDateCellSA(cell, value, p_Column_ID, p_Column_Name){
    if(cell==null)
		return false;
    
    if (value == "" || (value != "" && isDate2(value))) {
        saveDataSetAll(p_Column_ID, p_Column_Name, value);
        cell.innerText = "";
        setAllClose();
    }
    else {
        var msg = "Please enter a valid date.";
        alert(msg);
    }
}

/************************************/
/*** CHANGES (Change Controls)    ***/
/************************************/
var gridShowChanges = false;
function showChanges() { return gridShowChanges; }
function setShowChanges(show) {gridShowChanges = show;}
var changesSR = new Array(); // Skip Record(s)
function addSkipRecord(recID)
{
    var i = changesSR.length;
    changesSR[i] = recID.toString();
}
function skipRecord(recID)
{
    var i, skip = false;
    for(i = 0; i < changesSR.length; i++) {
        if(changesSR[i] == recID.toString()) {
            skip = true;
            break;
        }
    }
    return skip;
}

function getRowFromID(id)
{
    var arr = id.split('_');
    if(arr.length >= 2) return arr[1]; else return '';
}

function getColFromID(id)
{
    var arr = id.split('_');
    if(arr.length >= 3) return arr[2]; else return '';
}

function undoCell(id, val)
{
    // cell, value, p_Column_ID, p_Column_Name, p_Row_ID
    var cell = $(id);
    var value = val;
    var p_Column_ID = parseInt(getColFromID(id)); if(isNaN(p_Column_ID)) p_Column_ID = 0;
    var p_Column_Name = getGI(p_Column_ID);
    var p_Row_ID = parseInt(getRowFromID(id)); if(isNaN(p_Row_ID)) p_Row_ID = 0;
    
    // cell = <span id="gce_row_col"...></span>
    //if(cell==null)
	//	return false;

    saveData(p_Column_ID, p_Column_Name, p_Row_ID, value);
    //cell.innerText = value + "";
    hideNLCGWrapper(id);
    
    resizeGridCol(p_Column_ID);
}

function resizeGridColByName(p_Column_Name)
{
    var id = getGIID(p_Column_Name);
    if(id >= 0) {
        resizeGridCol(id);
    }
}
function resizeGridCol(p_Column_ID)
{
    resetGridCol(p_Column_ID);
    initGridDataLayout(p_Column_ID, p_Column_ID);
}

/***********************************************************************************************************/
/* *** TODO: FINISH THIS TO SUPPORT CHECKBOX CONTROLS ON THE GRID (WHICH ARE CURRENTLY NOT SUPPORTED). *** */
/***********************************************************************************************************/
function restoreNLCCBG(id, val) {
    // debugger;
    var e = $(id);
    var b = (val) ? true : false;
    //$(id).checked = b;
    if (e)
        e.innerText = (b) ? '[X]' : '';
    undoCell(id, val);
}

// Revert DropDown control (on the grid)
function restoreNLCDDG(id, val) {
    var e = $(id);
    if (e)
        e.innerText = val;
    undoCell(id, val);
    /*if (e) {
        for(var i = 0; i < e.options.length; i++){
            if(e.options[i].value == val){
                e.selectedIndex = i;
                break;
            }
        }
    }*/
}

function restoreNLCTBG(id, val){
    // debugger;
    var e = $(id);
    if (e)
        e.innerText = val;
    undoCell(id, val);
}

function restoreNLCNCG(id, val){
    // debugger;
    var e = $(id);
    if (e)
        e.innerText = val;
    undoCell(id, getNumberFromString(val));
}

function restoreNLCSP(id, column) {
    if(typeof undoSpecialControl == 'function') {
        undoSpecialControl(id, column);
    } else {
        alert('Special undo function (undoSpecialControl) is not defined.');
    }
}

function hideNLCGWrapper(id){
    var w = $('nlcCCC_' + id);
    var o = $('nlcCCRevert_' + id);
    var r = $('nlcCCOrigC_' + id);
    if(w&&o&&r){
        w.removeClassName('nlcCCC').removeClassName('nlcCCC_hide').addClassName('nlcCCC_hide');
        o.removeClassName('nlcHide').addClassName('nlcHide');
        r.removeClassName('nlcHide').addClassName('nlcHide');
    } else {
    alert('Error hiding wrapper for ' + id);
    }
}


function showNLCGWrapper(id){
    var w = $('nlcCCC_' + id);
    var o = $('nlcCCRevert_' + id);
    var r = $('nlcCCOrigC_' + id);
    if(w && o && r){
        w.removeClassName('nlcCCC').removeClassName('nlcCCC_hide').addClassName('nlcCCC');
        o.removeClassName('nlcHide');
        r.removeClassName('nlcHide');
    } else {
    alert('Error showing wrapper for ' + id);
    }
}

function showHideNLCGWrapper(id, val1, val2)
{
    var show;
    if(treatEmptyAsZeroNLCG(id)){
        if(isEmptyOrBlankNLCG(val1) && isEmptyOrBlankNLCG(val2))
            show = false;
        else
            show = (val1 != val2);
    } else {
        show = (val1 != val2);
    }
    if(show) {
        showNLCGWrapper(id);
    } else {
        hideNLCGWrapper(id);
    }
}

function treatEmptyAsZeroNLCG(id)
{
    var t = $(id + "_teaz");
    if(t && t.value == '1')
        return true;
    else
        return false;   
}
function isEmptyOrBlankNLCG(value) {
    if(isNaN(value))
        return true;
    else if(value.toString() == '' || value.toString() == '0')
        return true;
    else if(isNum(value.toString()) && convertToNumber(value.toString()) == 0)
        return true;
    else 
        return false;
}



/************************************/
/*** MISC FUNCTIONS               ***/
/************************************/

function getEditID(rowID, colID)
{
    return ('gce_' + rowID + '_' + colID);
}