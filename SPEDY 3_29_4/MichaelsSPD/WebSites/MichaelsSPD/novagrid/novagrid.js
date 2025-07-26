
function gridHeaderCol_Resize(colReference, newWidth)
{
	if (document.getElementById)
	{
		var oHandle = document.getElementById(colReference);
		if (newWidth >= 0)
		{
			newWidth -= 0.2;
			oHandle.style.minWidth = newWidth.toString() + "px";
		}
	}
}

function gridDataCol_Resize(colReference, newWidth)
{
	if (document.getElementById)
	{
		var oHandle = document.getElementById(colReference);
		if (newWidth >= 0)
		{
			//newWidth -= 0.1;
			oHandle.style.minWidth = newWidth.toString() + "px";
		}
	}
}

function initFixedGridDataLayout(startCol, endCol)
{
	if (isNaN(startCol) || isNaN(endCol) || arguments.length != 2) initGridDataLayout_UnknownNumberOfCols();
	var msg = ">> startCol: " + startCol + "\n";
	msg = msg +  ">> endCol: " + endCol + "\n";
	var w = 0;

	for (var i = startCol; i <= endCol; i++)
	{
		var thisObjectName = "col_" + i;
		msg = msg + ">> thisObjectName " + thisObjectName + "\n";

		var odataHeaderHandle = document.all(thisObjectName);
		var odataRowsetHandle = document.all(thisObjectName + "_data");

		msg = msg + ">> odataHeaderHandle: " + odataHeaderHandle + "\n";
		msg = msg + ">> odataRowsetHandle: " + odataRowsetHandle + "\n";
		if (odataHeaderHandle && odataRowsetHandle)
		{
			var headercolWidth = odataHeaderHandle.scrollWidth;
			var datacolWidth = odataRowsetHandle.scrollWidth;

			if (headercolWidth < datacolWidth)
			{
				w += datacolWidth;
			}
			else if (headercolWidth > datacolWidth)
			{
				w += headercolWidth;
			}
			else
			{
				w += datacolWidth;
			}
			if (showGridLines == true) {w += 1;}

			if (headercolWidth < datacolWidth) { msg += " [resizeheader] "; datacolWidth++; gridHeaderCol_Resize(thisObjectName, datacolWidth); gridDataCol_Resize(thisObjectName + "_data", datacolWidth); }
			if (headercolWidth > datacolWidth) { msg += " [resizedata] "; headercolWidth++; gridDataCol_Resize(thisObjectName + "_data", headercolWidth); gridHeaderCol_Resize(thisObjectName, headercolWidth); }
			//if (headercolWidth > datacolWidth) { msg+=" [resizedataimg] "; gridDataCol_Resize(thisObjectName + "_dataimg", headercolWidth); }

			msg = msg + thisObjectName + ">> headercolWidth: " + headercolWidth + " datacolWidth:" + datacolWidth + "\n";
		}
	}
	if(showHighlightRow == true)
	{
		w += 20;
		if(showGridLines == true) {w += 1;}
	}

	fixedGridWidth = w;
	
	//alert(msg);
}
function reInitGrid()
{
	initGridDataLayout(gridSC, gridEC);
}

function resetGridCol(col)
{
    var thisObjectName = "col_" + col;
    gridHeaderCol_Resize(thisObjectName, 10);
    gridDataCol_Resize(thisObjectName + "_data", 10);
	gridDataCol_Resize(thisObjectName + "_dataimg", 10);
}
function initGridDataLayout(startCol, endCol)
{
	if (isNaN(startCol) || isNaN(endCol) || arguments.length != 2) initGridDataLayout_UnknownNumberOfCols();
	var msg = ">> startCol: " + startCol + "\n";
	msg = msg +  ">> endCol: " + endCol + "\n";
	
	for (var i = startCol; i <= endCol; i++)
	{
		var thisObjectName = "col_" + i;
		msg = msg + ">> thisObjectName " + thisObjectName + "\n";

		var odataHeaderHandle = document.all(thisObjectName);
		var odataRowsetHandle = document.all(thisObjectName + "_data");

		msg = msg + ">> odataHeaderHandle: " + odataHeaderHandle + "\n";
		msg = msg + ">> odataRowsetHandle: " + odataRowsetHandle + "\n";
		if (odataHeaderHandle && odataRowsetHandle)
		{
			var headercolWidth = odataHeaderHandle.scrollWidth;
			var datacolWidth = odataRowsetHandle.scrollWidth;

			if (headercolWidth < datacolWidth) { msg += " [resizeheader] "; gridHeaderCol_Resize(thisObjectName, datacolWidth); gridDataCol_Resize(thisObjectName + "_data", datacolWidth); }
			if (headercolWidth > datacolWidth) { msg += " [resizedata] "; gridDataCol_Resize(thisObjectName + "_data", headercolWidth); gridHeaderCol_Resize(thisObjectName, headercolWidth); }
			//if (headercolWidth > datacolWidth) {msg+=" [resizedataimg] "; gridDataCol_Resize(thisObjectName + "_dataimg", headercolWidth);}

			msg = msg + thisObjectName + ">> headercolWidth: " + headercolWidth + " datacolWidth:" + datacolWidth + "\n";
		}
	}
	
	//alert("[initGridDataLayout]: " + msg);
}

//this function attempts to figure out which columns are column headers and set their size.
//this function can be costly and slow when run against a table with a lot of columns and rows of data.
//whenever possible, pass the number of columns to the initDataLayout function.
function initGridDataLayout_UnknownNumberOfCols()
{
	var msg = "";
	for (var i = 0; i < document.all.length; i++)
	{
		if (document.all(i).id)
		{
			var thisObjectName = new String(document.all(i).id)
			if (thisObjectName.indexOf("col_") >= 0 && thisObjectName.indexOf("_data") < 0 && thisObjectName.indexOf("_data") < 0)
			{
				var odataHeaderHandle = eval("document.all." + thisObjectName);
				var odataRowsetHandle = eval("document.all." + thisObjectName + "_data");
				if (odataHeaderHandle && odataRowsetHandle)
				{
					var headercolWidth = odataHeaderHandle.scrollWidth;
					var datacolWidth = odataRowsetHandle.scrollWidth;

					if (headercolWidth < datacolWidth) gridHeaderCol_Resize(thisObjectName, datacolWidth);
					if (headercolWidth > datacolWidth) gridDataCol_Resize(thisObjectName + "_data", headercolWidth);
					if (headercolWidth > datacolWidth) gridDataCol_Resize(thisObjectName + "_dataimg", headercolWidth);

					msg = msg + thisObjectName + ">> headercolWidth: " + headercolWidth + " datacolWidth:" + datacolWidth + "\n";
				}
			}
		}
	}
	
	//alert("[initGridDataLayout_UnknownNumberOfCols]: " + msg);
}
		
function hGR()
{
	var i, el;
	for (i = 0; i < arguments.length; i++)
	{
		if (MM_findObj(arguments[i]))
		{
			$(arguments[i]).toggleClassName("gridrover");
		}
	}
}

function MM_findObj(n, d) { //v4.01
  var p,i,x;  if(!d) d=document; if((p=n.indexOf("?"))>0&&parent.frames.length) {
    d=parent.frames[n.substring(p+1)].document; n=n.substring(0,p);}
  if(!(x=d[n])&&d.all) x=d.all[n]; for (i=0;!x&&i<d.forms.length;i++) x=d.forms[i][n];
  for(i=0;!x&&d.layers&&i<d.layers.length;i++) x=MM_findObj(n,d.layers[i].document);
  if(!x && d.getElementById) x=d.getElementById(n); return x;
}

function MM_preloadImages() { //v3.0
  var d=document; if(d.images){ if(!d.MM_p) d.MM_p=new Array();
    var i,j=d.MM_p.length,a=MM_preloadImages.arguments; for(i=0; i<a.length; i++)
    if (a[i].indexOf("#")!=0){ d.MM_p[j]=new Image; d.MM_p[j++].src=a[i];}}
}

function MM_swapImgRestore() { //v3.0
  var i,x,a=document.MM_sr; for(i=0;a&&i<a.length&&(x=a[i])&&x.oSrc;i++) x.src=x.oSrc;
}

function MM_swapImage() { //v3.0
  var i,j=0,x,a=MM_swapImage.arguments; document.MM_sr=new Array; for(i=0;i<(a.length-2);i+=3)
   if ((x=MM_findObj(a[i]))!=null){document.MM_sr[j++]=x; if(!x.oSrc) x.oSrc=x.src; x.src=a[i+2];}
}

function showElement(elementID, setDisplay, displayType)
{
	var o = MM_findObj(elementID);
	var dtype = '';
	if(displayType && displayType != null)
		dtype = displayType;
	if(o){if(o.style)o=o.style;o.visibility='visible'; o.display=dtype;}
}

function hideElement(elementID, setDisplay)
{
	var o = MM_findObj(elementID);
	if(o){if(o.style)o=o.style;o.visibility='hidden'; o.display='none'}
}


function sortDetails(col, sortDirection)
{
	var sortArg = col + "," + sortDirection;
	__doPostBack('sortlist', sortArg);
}

function movePage()
{
    __doPostBack('paging', 'move');
}
function moveFirst()
{
	__doPostBack('paging', 'first');
}
function movePrev()
{
	__doPostBack('paging', 'prev');
}
function moveNext()
{
	__doPostBack('paging', 'next');
}
function moveLast()
{
	__doPostBack('paging', 'last');
}

function clearSearch(txtSearchID)
{
    var o = MM_findObj(txtSearchID);
    if(o) 
        o.value = "";
    __doPostBack(txtSearchID, '');
}

function changePageSize()
{
	var pageSizeID = gridPrefix + 'pageSize';
	var invalidChars = /\D/g;
	var ps = MM_findObj(pageSizeID)
	if (invalidChars.test(ps.value))
	{
		ps.select();
		alert("Please enter a valid number greater than 0 and less than 200 in the Record Count field.");
		ps.focus();
	}
	else
	{
		var pageSize = new Number(ps.value);
		if ((pageSize.valueOf() > 0)&&(pageSize.valueOf() <= 200))
		{
			movePage();
		}
		else
		{
			//pageSize.select();
		    alert("Please enter a valid number greater than 0 and less than 200 in the Record Count field.");
		    ps.focus();
		}
	}
}

var gridSC = 0;
var gridEC = 0;
var gridClientID = '';
var gridClientIDSep = '';
var gridPrefix = '';
var resizeGridOnResize = false;
var resizeFixedGrid = false;
var resizeGridHeight = true;
var showGridLines = false;
var showGridPaging = false;
var showHighlightRow = false;
var fixedGridWidth = 0;
var defaultGridHeight = "300";	
var gridFilterXML = '<Filter />';

window.onresize = resizeGrid;
function resizeGrid()
{
	if(resizeGridOnResize == false)
	{
		return;
	}
	var w = getClientWidth();
	var h = getWinHeight();
	var gc = $("gridContainer");
	var gf = $("gridFixed");
	var fgh = $("divFixedGridHeader");
	var fg = $("divFixedGrid");
	var gs = $("gridScrollable");
	var gh = $("divGridHeader");
	var g = $("divGrid");
	var p = $("pagingNavBar");
	var o = $("overlay");
	if(gc&&gf&&fgh&&fg&&gs&&gh&&g&&p)
	{
		var gridw = "100%"
		var gridh;
		var hh = gh.offsetHeight;
		var ph = p.offsetHeight; 
		// set the width of overlay
		setWidth(o, gridw);
		// grid wrapper
		setGridWidth(fixedGridWidth);
		// fix the width of the fixed grid
		setWidth(fgh, fixedGridWidth);
		setWidth(fg, fixedGridWidth);
		// fix the width of the scrollable grid
		if(resizeFixedGrid == true)
		{
			gridw = w - fixedGridWidth;		
		}
		setWidth(gs, gridw);
		setWidth(gh, gridw);
		setWidth(g, gridw);
		
		// fix the height of the grid (both)
		if(resizeGridHeight == true)
		{
			gridh = h - getAbsoluteTop(gh) - hh - 3;
			if(showGridPaging == true)
				gridh = (gridh - ph);
			if(gridh < defaultGridHeight)
				gridh = defaultGridHeight;
			gridh = gridh - 25;
			gridh = gridh + "px";
		}
		else
		{
		    gridh = defaultGridHeight - 25;
			gridh = gridh + "px";
		}
		setHeight(fg, gridh);
		setHeight(g, gridh);
		// set the height of overlay
		setHeight(o, (h - 1));
	}
	else
		alert("ERROR: Problem finding grid elements!  Cannot resize grid.");
	
}

function showGrid()
{
	hideElement("gridLoader", true);
	var fg = MM_findObj("divFixedGrid");
	var g = MM_findObj("divGrid");
	fg.className = "gridStyle";
	g.className = "gridStyle";
	showElement("divFixedGrid", false);
	showElement("divGrid", false);
}

function getWinHeight() {
  //var myWidth = 0
  var myHeight = 0;
  if( typeof( window.innerWidth ) == 'number' ) {
    //Non-IE
    //myWidth = window.innerWidth;
    myHeight = window.innerHeight;
  } else if( document.documentElement && ( document.documentElement.clientWidth || document.documentElement.clientHeight ) ) {
    //IE 6+ in 'standards compliant mode'
    //myWidth = document.documentElement.clientWidth;
    myHeight = document.documentElement.clientHeight;
  } else if( document.body && ( document.body.clientWidth || document.body.clientHeight ) ) {
    //IE 4 compatible
    //myWidth = document.body.clientWidth;
    myHeight = document.body.clientHeight;
  }
  return myHeight;
}

function alertSize() {
  var myWidth = 0, myHeight = 0;
  if( typeof( window.innerWidth ) == 'number' ) {
    //Non-IE
    myWidth = window.innerWidth;
    myHeight = window.innerHeight;
  } else if( document.documentElement && ( document.documentElement.clientWidth || document.documentElement.clientHeight ) ) {
    //IE 6+ in 'standards compliant mode'
    myWidth = document.documentElement.clientWidth;
    myHeight = document.documentElement.clientHeight;
  } else if( document.body && ( document.body.clientWidth || document.body.clientHeight ) ) {
    //IE 4 compatible
    myWidth = document.body.clientWidth;
    myHeight = document.body.clientHeight;
  }
  window.alert( 'Width = ' + myWidth );
  window.alert( 'Height = ' + myHeight );
}

function setGridWidth(w) {
	
	w += 4;
	var cols = w.toString() + 'px 1fr';
	//$('gridWrapper').setStyle({ 'grid-template-columns': cols });
	$$('.grid-container').each(function (element) {
		element.setStyle({ '-ms-grid-columns': cols });
		element.setStyle({ 'grid-template-columns': cols });
	});
}
function setWidth(obj, w)
{
	obj.style.width = w; return;
	if(obj.style)
		obj = obj.style;
	obj.width = w;
}
function setHeight(obj, h)
{
	if(obj.style)
		obj = obj.style;
	obj.height = h;
}
function getObjStyle(obj)
{
	if(obj.style)
		obj = obj.style;
	return obj;
}
function getWidth(obj)
{
	if(obj.style)
		obj = obj.style;
	return obj.width;
}
function getHeight(obj)
{
	if(obj.style)
		obj = obj.style;
	return obj.height;
}

function getClientWidth() {
	return filterResults (
		window.innerWidth ? window.innerWidth : 0,
		document.documentElement ? document.documentElement.clientWidth : 0,
		document.body ? document.body.clientWidth : 0
	);
}
function getClientHeight() {
	return filterResults (
		window.innerHeight ? window.innerHeight : 0,
		document.documentElement ? document.documentElement.clientHeight : 0,
		document.body ? document.body.clientHeight : 0
	);
}
function getScrollLeft() {
	return filterResults (
		window.pageXOffset ? window.pageXOffset : 0,
		document.documentElement ? document.documentElement.scrollLeft : 0,
		document.body ? document.body.scrollLeft : 0
	);
}
function getScrollTop() {
	return filterResults (
		window.pageYOffset ? window.pageYOffset : 0,
		document.documentElement ? document.documentElement.scrollTop : 0,
		document.body ? document.body.scrollTop : 0
	);
}
function filterResults(n_win, n_docel, n_body) {
	var n_result = n_win ? n_win : 0;
	if (n_docel && (!n_result || (n_result > n_docel)))
		n_result = n_docel;
	return n_body && (!n_result || (n_result > n_body)) ? n_body : n_result;
}


function getAbsoluteLeft(obj) {
	var curleft  = 0;
	if (obj.offsetParent) {
		do {
			curleft += obj.offsetLeft;
		} while (obj = obj.offsetParent);
	}
	return curleft;
}

function getAbsoluteTop(obj) {
	var curtop = 0;
	if (obj.offsetParent) {
		do {
			curtop += obj.offsetTop;
		} while (obj = obj.offsetParent);
	}
	return curtop;
}

/* Callbacks */
/*
function ReceiveServerData(rvalue, context)
{
}
*/


/*********************/
/*** Advanced Sort ***/
/*********************/

var sortSequence = new Array();
var sortDirection = new Array();

function sortDoCommit()
{
	__doPostBack('advancedsort', "1");
	Lightbox.hideAll();
}

function sortDoClear()
{
	var selObj_SortSequence;
	var selObj_SortDirection;
	for (var i = 0; i < 5; i++)
	{
		selObj_SortSequence = $(sortSequence[i]);
		selObj_SortDirection = $(sortDirection[i]);
		selObj_SortSequence.selectedIndex = 0;
		selObj_SortDirection.selectedIndex = 0;
	}
}

function sortValidateSelection(selObjOrdinal)
{
	if (isNaN(selObjOrdinal)) return false;
	
	var selObj_SortSequence = $(sortSequence[selObjOrdinal-1]);
	var selObj_SortDirection = $(sortDirection[selObjOrdinal-1]);
	var selObj_Value = selObj_SortSequence.options[selObj_SortSequence.selectedIndex].value;
	
	if (selObj_SortSequence.selectedIndex > 0)
	{
		if (selObj_SortDirection.selectedIndex == 0)
		{
			selObj_SortDirection.selectedIndex = 1;
		}
	}
	else
	{
		selObj_SortDirection.selectedIndex = 0;
	}
	
	//Load all the OTHER selections into an array
	var columnNameArray = new Array();
	for (var i = 1; i <= 5; i++)
	{
		if (i != selObjOrdinal)
		{
			var thisSortSel = $(sortSequence[i-1]);
			if (thisSortSel)
			{
				var thisSortSelValue = thisSortSel.options[thisSortSel.selectedIndex].value;
				if (thisSortSelValue != 0 && thisSortSelValue != "")
				{
					columnNameArray.push(thisSortSelValue);
				}
			}
			thisSortSelValue = "";
			thisSortSel = null;
		}
	}
	
	//See if this new selection has been chosen already.
	if (columnNameArray.indexOf(selObj_Value) >= 0)
	{
		alert("You have already selected this Column.\nYou may only select each column once.");
		selObj_SortSequence.selectedIndex = 0;
		selObj_SortDirection.selectedIndex = 0;				
	}

	columnNameArray = null;
	selObj_SortDirection = null;
	selObj_SortSequence = null;
}

/***********************/
/*** Advanced Filter ***/
/***********************/

/*
function chooseAction()
{

}
*/
function filterDoClear()
{
	resetForm();
}

function filterDoCommit(argValue)
{
	if (!argValue || argValue == null)
		argValue = "1";
	__doPostBack('advancedfilter', argValue);
	Lightbox.hideAll();
}

/*
var CallPlanTypeID_Options = <%=CallPlanTypeID_Options%>;
var AcctStrategyTypeID_Options = <%=AcctStrategyTypeID_Options%>;
var AcctDevelopmentTypeID_Options = <%=AcctDevelopmentTypeID_Options%>;
var MarketingTypeID_Options = <%=MarketingTypeID_Options%>;
var SalesToolTypeID_Options = <%=SalesToolTypeID_Options%>;
var TrainingTypeID_Options = <%=TrainingTypeID_Options%>;
var ProductsTypeID_Options = <%=ProductsTypeID_Options%>;
var SpecialPricingTypeID_Options = <%=SpecialPricingTypeID_Options%>;
var VisitObjective_Options = <%=VisitObjective_Options%>;
var ISRFollowup_Options = <%=ISRFollowup_Options%>;
var AEFollowup_Options = <%=AEFollowup_Options%>;
*/

var savedFilterObj = null; // = new SavedFilter(0);
/*
var arNumberVerbs = $A([["equals","equals"],["does not equal","does not equal"],["is greater than","is greater than"],["is greater than or equal to","is greater than or equal to"],["is less than","is less than"],["is less than or equal to","is less than or equal to"],["is in range","is in range"],["is not in range","is not in range"],["is unknown","is unknown"]]);
var arStringVerbs = $A([["is exactly","is exactly"],["contains","contains"],["sounds like","sounds like"],["is unknown","is unknown"]]);
var arSelectVerbs = $A([["equals","equals"],["does not equal","does not equal"],["is in range","is in range"],["is not in range","is not in range"]]);
var arDateVerbs = $A([["on","on"],["on or after","on or after"],["on or before","on or before"]]);
*/
var arNumberVerbs = $A([["equals","equals"],["does not equal","does not equal"],["is greater than","is greater than"],["is greater than or equal to","is greater than or equal to"],["is less than","is less than"],["is less than or equal to","is less than or equal to"],["is unknown","is unknown"]]);
var arStringVerbs = $A([["is exactly","is exactly"],["contains","contains"],["is unknown","is unknown"]]);
var arSelectVerbs = $A([["equals","equals"],["does not equal","does not equal"],["is in range","is in range"],["is not in range","is not in range"]]);
var arDateVerbs = $A([["on","on"],["on or after","on or after"],["on or before","on or before"]]);

function loadDefaultFilter()
{
	if(savedFilterObj != null)
		loadInterfaceFromSavedFilter(savedFilterObj);
	else
		resetForm();
}


function validateSelection(selObjOrdinal)
{
	if (isNaN(selObjOrdinal)) return false;
	
	var selObj_FilterConjunction =	$(selObjOrdinal + "_Filter_Conjunction");
	var selObj_FilterColumn =		$(selObjOrdinal + "_Filter_Column");
	var selObj_FilterVerb =			$(selObjOrdinal + "_Filter_Verb");
	var selObj_FilterColumnType =	selObj_FilterColumn.options[selObj_FilterColumn.selectedIndex].coltype;
	var selObj_ColumnName =			selObj_FilterColumn.options[selObj_FilterColumn.selectedIndex].colname;
	var selObj_FilterValue;
	var selObj_NextOrdinal = selObjOrdinal;
	
	if (selObjOrdinal <= 10) selObj_NextOrdinal++;
	
	if (selObj_FilterColumn.selectedIndex > 0)
	{
		if (selObjOrdinal > 1)
		{
			selObj_FilterConjunction.disabled = false;
			if (selObj_FilterConjunction.selectedIndex == 0)
			{
				selObj_FilterConjunction.selectedIndex = 1;
			}
		}
						
		Element.removeClassName(selObj_FilterConjunction, "disabled");
		Element.removeClassName(selObj_FilterVerb, "disabled");
		selObj_FilterVerb.disabled = false;
		selObj_FilterVerb.options.length = 0;
		selObj_FilterVerb.onchange = null;

		Element.hide($(selObjOrdinal + "_Filter_Value_Number"));
		Element.hide($(selObjOrdinal + "_Filter_Value_String"));
		Element.hide($(selObjOrdinal + "_Filter_Value_BetweenEntryBlock"));
		Element.hide($(selObjOrdinal + "_Filter_Value_Select"));
		Element.hide($(selObjOrdinal + "_Filter_Value_SelectMultiple"));
		Element.hide($(selObjOrdinal + "_Filter_Value_Date"));

		switch(selObj_FilterColumnType)
		{
			case "number":
			case "decimal":
			case "integer":
			case "long":
			case "smallint":
			case "int":
			case "bigint":
				Element.show($(selObjOrdinal + "_Filter_Value_Number"));
				selObj_FilterValue = $(selObjOrdinal + "_Filter_Value_Number");
				selObj_FilterValue.onkeypress = function(){
					switch($(selObjOrdinal + "_Filter_Verb").value)
					{
						case "is in range":
							if(this.value.length > 0){
								if($(selObj_NextOrdinal + "_Filter_Column")){
									$(selObj_NextOrdinal + "_Filter_Column").disabled = false;
									Element.removeClassName($(selObj_NextOrdinal + "_Filter_Column"), "disabled");
								}
							}
							break;
						case "is not in range":
							if(this.value.length > 0){
								if($(selObj_NextOrdinal + "_Filter_Column")){
									$(selObj_NextOrdinal + "_Filter_Column").disabled = false;
									Element.removeClassName($(selObj_NextOrdinal + "_Filter_Column"), "disabled");
								}
							}
							break;
						default:
							//in all other cases for number columns, make sure a valid number was entered.
							if(isNumber(this.value)){
								if(this.value.length > 0){
									if($(selObj_NextOrdinal + "_Filter_Column")){
										$(selObj_NextOrdinal + "_Filter_Column").disabled = false;
										Element.removeClassName($(selObj_NextOrdinal + "_Filter_Column"), "disabled");
									}
								}
							}
					}
				};
				selObj_FilterValue.onchange = function(){
					switch($(selObjOrdinal + "_Filter_Verb").value)
					{
						case "is in range":
							if(this.value.length > 0){
								if($(selObj_NextOrdinal + "_Filter_Column")){
									$(selObj_NextOrdinal + "_Filter_Column").disabled = false;
									Element.removeClassName($(selObj_NextOrdinal + "_Filter_Column"), "disabled");
								}
							}
							break;
						case "is not in range":
							if(this.value.length > 0){
								if($(selObj_NextOrdinal + "_Filter_Column")){
									$(selObj_NextOrdinal + "_Filter_Column").disabled = false;
									Element.removeClassName($(selObj_NextOrdinal + "_Filter_Column"), "disabled");
								}
							}
							break;
						default:
							//in all other cases for number columns, make sure a valid number was entered.
							if(isNumber(this.value)){
								if(this.value.length > 0){
									if($(selObj_NextOrdinal + "_Filter_Column")){
										$(selObj_NextOrdinal + "_Filter_Column").disabled = false;
										Element.removeClassName($(selObj_NextOrdinal + "_Filter_Column"), "disabled");
									}
								}
							}
					}
				};
				populateDropDown(selObj_FilterVerb, arNumberVerbs);
				break;
			case "string":
			case "varchar":
			case "nvarchar":
			case "char":
				Element.show($(selObjOrdinal + "_Filter_Value_String"));
				selObj_FilterValue = $(selObjOrdinal + "_Filter_Value_String");
				selObj_FilterValue.onkeypress = function(){
					if(this.value.length > 0){
						if($(selObj_NextOrdinal + "_Filter_Column")){
							$(selObj_NextOrdinal + "_Filter_Column").disabled = false;
							Element.removeClassName($(selObj_NextOrdinal + "_Filter_Column"), "disabled");
						}
					}
				};
				selObj_FilterValue.onchange = function(){
					if(this.value.length > 0){
						if($(selObj_NextOrdinal + "_Filter_Column")){
							$(selObj_NextOrdinal + "_Filter_Column").disabled = false;
							Element.removeClassName($(selObj_NextOrdinal + "_Filter_Column"), "disabled");
						}
					}
				};
				populateDropDown(selObj_FilterVerb, arStringVerbs);
				break;
			case "select":
			case "select2":
			case "listvalue":
				populateDropDown(selObj_FilterVerb, arSelectVerbs);
				Element.show($(selObjOrdinal + "_Filter_Value_Select"));
				selObj_FilterValue = $(selObjOrdinal + "_Filter_Value_Select");
				populateDropDown(selObj_FilterValue, eval(selObj_ColumnName + "_Options"));
				if($(selObj_NextOrdinal + "_Filter_Column")){
					$(selObj_NextOrdinal + "_Filter_Column").disabled = false
					Element.removeClassName($(selObj_NextOrdinal + "_Filter_Column"), "disabled");
				};
				selObj_FilterVerb.onchange = function(){
					Element.hide($(selObjOrdinal + "_Filter_Value_Select"));
					Element.hide($(selObjOrdinal + "_Filter_Value_SelectMultiple"));
					switch($(selObjOrdinal + "_Filter_Verb").value)
					{
						case "is in range":
							Element.show($(selObjOrdinal + "_Filter_Value_SelectMultiple"));
							selObj_FilterValue = $(selObjOrdinal + "_Filter_Value_SelectMultiple");
							populateDropDown(selObj_FilterValue, eval(selObj_ColumnName + "_Options"));
							if($(selObj_NextOrdinal + "_Filter_Column")){
								$(selObj_NextOrdinal + "_Filter_Column").disabled = false
								Element.removeClassName($(selObj_NextOrdinal + "_Filter_Column"), "disabled");
							};
							break;
						case "is not in range":
							Element.show($(selObjOrdinal + "_Filter_Value_SelectMultiple"));
							selObj_FilterValue = $(selObjOrdinal + "_Filter_Value_SelectMultiple");
							populateDropDown(selObj_FilterValue, eval(selObj_ColumnName + "_Options"));
							if($(selObj_NextOrdinal + "_Filter_Column")){
								$(selObj_NextOrdinal + "_Filter_Column").disabled = false
								Element.removeClassName($(selObj_NextOrdinal + "_Filter_Column"), "disabled");
							};
							break;
						default:
							Element.show($(selObjOrdinal + "_Filter_Value_Select"));
							selObj_FilterValue = $(selObjOrdinal + "_Filter_Value_Select");
							populateDropDown(selObj_FilterValue, eval(selObj_ColumnName + "_Options"));
							if($(selObj_NextOrdinal + "_Filter_Column")){
								$(selObj_NextOrdinal + "_Filter_Column").disabled = false
								Element.removeClassName($(selObj_NextOrdinal + "_Filter_Column"), "disabled");
							};
					}
				}
				break;
			case "date":
			case "dateselectcomplete":
			case "datetime":
				populateDropDown(selObj_FilterVerb, arDateVerbs);
				Element.show($(selObjOrdinal + "_Filter_Value_Date"));
				selObj_FilterValue = $(selObjOrdinal + "_Filter_Value_Date");
				var d = new Date(); selObj_FilterValue.value = "" + (d.getMonth()+1) + "/" + d.getDate() + "/" + d.getFullYear();
				selObj_FilterValue.select();
				selObj_FilterValue.focus();
				selObj_FilterValue.onblur = function(){
					if(isDate(this.value)){
						if(this.value.length > 0){
							if($(selObj_NextOrdinal + "_Filter_Column")){
								$(selObj_NextOrdinal + "_Filter_Column").disabled = false;
								Element.removeClassName($(selObj_NextOrdinal + "_Filter_Column"), "disabled");
							}
						}
					}
					else
					{
						this.select();
						this.focus();
					}
				};
				break;
			default:
				break;
		}
	}
	else
	{
		if(selObj_FilterConjunction) selObj_FilterConjunction.selectedIndex = 0;
		selObj_FilterVerb.options.length = 0;
		Element.hide($(selObjOrdinal + "_Filter_Value_Number"));
		Element.hide($(selObjOrdinal + "_Filter_Value_String"));
		Element.hide($(selObjOrdinal + "_Filter_Value_BetweenEntryBlock"));
		Element.hide($(selObjOrdinal + "_Filter_Value_Select"));
		Element.hide($(selObjOrdinal + "_Filter_Value_SelectMultiple"));
		Element.hide($(selObjOrdinal + "_Filter_Value_Date"));
	}
	
	selObj_FilterConjunction =	null;
	selObj_FilterColumn =		null;
	selObj_FilterVerb =			null;
	selObj_FilterValue =		null;
	selObj_FilterColumnType =	null;
}
function resetForm()
{
	for (var i = 1; i <= 10; i++)
	{
		var selObj_FilterConjunction =	$(i + "_Filter_Conjunction");
		var selObj_FilterColumn =		$(i + "_Filter_Column");
		var selObj_FilterVerb =			$(i + "_Filter_Verb");
		var selObj_FilterValue;

		if (selObj_FilterConjunction) selObj_FilterConjunction.selectedIndex = 0;
		selObj_FilterColumn.selectedIndex = 0;
		selObj_FilterVerb.options.length = 0;

		if (selObj_FilterConjunction) selObj_FilterConjunction.disabled = true;
		if (i > 1) selObj_FilterColumn.disabled = true;
		selObj_FilterVerb.disabled = true;

		if (selObj_FilterConjunction) Element.addClassName(selObj_FilterConjunction, "disabled");
		if (i > 1) Element.addClassName(selObj_FilterColumn, "disabled");
		Element.addClassName(selObj_FilterVerb, "disabled");

		Element.hide($(i + "_Filter_Value_Number"));
		Element.hide($(i + "_Filter_Value_String"));
		Element.hide($(i + "_Filter_Value_BetweenEntryBlock"));
		Element.hide($(i + "_Filter_Value_Select"));
		Element.hide($(i + "_Filter_Value_SelectMultiple"));
		Element.hide($(i + "_Filter_Value_Date"));
	
		selObj_FilterConjunction =	null;
		selObj_FilterColumn =		null;
		selObj_FilterVerb =			null;
		selObj_FilterValue =		null;
		selObj_FilterColumnType =	null;
	}
}
function populateDropDown(selObj, arOptions)
{
	selObj.options.length = 0;
	for (var index = 0, len = arOptions.length; index < len; ++index) 
	{   
		var myOptions = arOptions[index];
		var myOptionValue = myOptions[0];
		var myOptionText = myOptions[1];
		var newItemPosition = selObj.options.length;
		selObj.options[newItemPosition] = new Option(myOptionText, myOptionValue);
	} 
}
function selectDropDownOptionbyText(selObj, desiredText)
{
	for (i = 0; i < selObj.options.length; i++)
	{
		if (selObj.options[i].text == desiredText)
		{
			selObj.options[i].selected = true;
		}
	}
}
function selectDropDownOptionbyValue(selObj, desiredValue)
{
	for (i = 0; i < selObj.options.length; i++)
	{
		if (selObj.options[i].value == desiredValue)
		{
			selObj.options[i].selected = true;
		}
	}
}
function selectMultipleDropDownOptionbyValue(selObj, desiredValueArray)
{
	for (i = 0; i < selObj.options.length; i++)
	{
		for (j = 0; j < desiredValueArray.length; j++)
		{
			if (selObj.options[i].value == desiredValueArray[j])
			{
				selObj.options[i].selected = true;
			}
		}
	}
}

var dtCh= "/";
var minYear=1900;
var maxYear=2100;

function isInteger(s){
	var i;
	for (i = 0; i < s.length; i++){   
		// Check that current character is number.
		var c = s.charAt(i);
		if (((c < "0") || (c > "9"))) return false;
	}
	// All characters are numbers.
	return true;
}
function stripCharsInBag(s, bag){
	var i;
	var returnString = "";
	// Search through string's characters one by one.
	// If character is not in bag, append to returnString.
	for (i = 0; i < s.length; i++){   
		var c = s.charAt(i);
		if (bag.indexOf(c) == -1) returnString += c;
	}
	return returnString;
}
function daysInFebruary (year){
	// February has 29 days in any year evenly divisible by four,
	// EXCEPT for centurial years which are not also divisible by 400.
	return (((year % 4 == 0) && ( (!(year % 100 == 0)) || (year % 400 == 0))) ? 29 : 28 );
}
function DaysArray(n) {
	for (var i = 1; i <= n; i++) {
		this[i] = 31
		if (i==4 || i==6 || i==9 || i==11) {this[i] = 30}
		if (i==2) {this[i] = 29}
	} 
	return this
}
function isDate(dtStr){
	var daysInMonth = DaysArray(12)
	var pos1=dtStr.indexOf(dtCh)
	var pos2=dtStr.indexOf(dtCh,pos1+1)
	var strMonth=dtStr.substring(0,pos1)
	var strDay=dtStr.substring(pos1+1,pos2)
	var strYear=dtStr.substring(pos2+1)
	strYr=strYear
	if (strDay.charAt(0)=="0" && strDay.length>1) strDay=strDay.substring(1)
	if (strMonth.charAt(0)=="0" && strMonth.length>1) strMonth=strMonth.substring(1)
	for (var i = 1; i <= 3; i++) {
		if (strYr.charAt(0)=="0" && strYr.length>1) strYr=strYr.substring(1)
	}
	month=parseInt(strMonth)
	day=parseInt(strDay)
	year=parseInt(strYr)
	if (pos1==-1 || pos2==-1){
		alert("The date format should be : mm/dd/yyyy")
		return false
	}
	if (strMonth.length<1 || month<1 || month>12){
		alert("Please enter a valid month")
		return false
	}
	if (strDay.length<1 || day<1 || day>31 || (month==2 && day>daysInFebruary(year)) || day > daysInMonth[month]){
		alert("Please enter a valid day")
		return false
	}
	if (strYear.length != 4 || year==0 || year<minYear || year>maxYear){
		alert("Please enter a valid 4 digit year between "+minYear+" and "+maxYear)
		return false
	}
	if (dtStr.indexOf(dtCh,pos2+1)!=-1 || isInteger(stripCharsInBag(dtStr, dtCh))==false){
		alert("Please enter a valid date")
		return false
	}
	return true
}
function isNumber(strIn)
{
	if (isNaN(strIn)){
		alert("Please enter a valid number.")
		return false;
	}
	return true;
}
function chooseAction()
{
	$("Select_EditSavedFilter").disabled = true;
	$("Select_RemoveSavedFilter").disabled = true;

	Element.addClassName($("Select_EditSavedFilter"), "disabled");
	Element.addClassName($("Select_RemoveSavedFilter"), "disabled");
	
	$("Select_EditSavedFilter").selectedIndex = -1;
	$("Select_RemoveSavedFilter").selectedIndex = -1;

	if ($("chkAction_NewFilter").checked == true){
		resetInterface();
	}

	if ($("chkAction_ClearFilter")){
		if ($("chkAction_ClearFilter").checked == true){
			resetInterface();
		}
	}

	if ($("chkAction_EditSavedFilter").checked == true){
		$("Select_EditSavedFilter").disabled = false;
		$("Select_EditSavedFilter").onchange = function(){validateAction()};
		Element.removeClassName($("Select_EditSavedFilter"), "disabled");
	}
	if ($("chkAction_DeleteSavedFilter").checked == true){
		$("Select_RemoveSavedFilter").disabled = false;
		Element.removeClassName($("Select_RemoveSavedFilter"), "disabled");
	}
}
function validateAction()
{
	if ($("Select_EditSavedFilter").options.length > 0 && $("Select_EditSavedFilter").selectedIndex == 0) $("Select_EditSavedFilter").selectedIndex = 1;
	if ($("chkAction_EditSavedFilter").checked == true){
		$("EditSavedFilterID").value = $("Select_EditSavedFilter").options[$("Select_EditSavedFilter").selectedIndex].value
		filterDoCommit("1");
	}
	
	savedFilterObj = null;
}

// NovaXmlDoc
// --------------------
// object to handle cross browser XML handling (IE or DOMParser)
// --------------------
function NovaXmlDoc() {

	var _isIE, _xmlDoc, _domParser, _xmlSerializer;

	_isIE = false;
	_xmlDoc = null;
	_domParser = null;
	_xmlSerializer = null;

	this.init = function() {
		_init();
	};

	_init = function () {
		if (window.DOMParser) {
			_domParser = new DOMParser();
			_xmlSerializer = new XMLSerializer();
		}
		else {
			_isIE = true;
			_xmlDoc = new ActiveXObject("MSXML2.DOMDocument");
			_xmlDoc.async = false;
			_xmlDoc.setProperty("SelectionLanguage", "XPath");
		}
	};

	this.loadXML = function(xml) {
		if (_isIE) {
			if (xml == null || xml == undefined) xml = '';
			_xmlDoc.loadXML(xml);
		}
		else {
			// DomParser
			if (xml == null || xml == undefined) xml = '';
			_xmlDoc = _domParser.parseFromString(xml, 'text/xml');
		}
	};

	_getXML = function () {
		if (_isIE) {
			if (!_xmldoc.xml) return false;
			return _xmldoc.xml;
		}
		else {
			if (_xmlDoc != null && _xmlSerializer != null) {
				return _xmlSerializer.serializeToString(_xmlDoc);
			}
			else {
				return '';
            }
        }
    }

	this.init();
}
function SavedFilter(p_FilterID)
{
	var _xmldoc, _timeouthandle;

	_xmldoc = new NovaXmlDoc();

	this.Filter_ID = p_FilterID;

	this.xml = function()
	{
		return _xmldoc.getXML();
	}
	
	this.load = function()
	{
		_load();
	}

	_load = function()
	{
		_loadXML(gridFilterXML);
	}

	_loadXML = function(xml)
	{
		_xmldoc.loadXML(xml);
	}

	this.fetchParameterAttribute = function(p_paramOrdinal, p_paramAttr)
	{
		if (!_xmldoc.xml) return false;
		var retValue = "";
		var xPathString = "//Parameter[@FilterID='" + p_paramOrdinal + "'][@" + p_paramAttr + "]";

		if (_xmldoc.selectNodes(xPathString).length > 0)
		{
			retValue = _xmldoc.selectNodes(xPathString).item;
		}
		return retValue;
	}

	this.Filter_Parameter_Ordinal = 0;
	this.Filter_Parameter_Conjunction = "";
	this.Filter_Parameter_ColName = "";
	this.Filter_Parameter_ColOrdinal = 0;
	this.Filter_Parameter_VerbText = "";
	this.Filter_Parameter_Value = "";

	this.Filter_Parameter_Conjunction = function(p_paramOrdinal)
	{
		if (!_xmldoc.xml) return false;
		var retValue = "";
		var xPathString = "//Parameter[@FilterID='" + p_paramOrdinal + "']/@Conjunction";

		if (_xmldoc.selectNodes(xPathString).length > 0)
		{
			retValue = _xmldoc.selectSingleNode(xPathString).text;
		}
		return retValue;
	}
	this.Filter_Parameter_ColName = function(p_paramOrdinal)
	{
		if (!_xmldoc.xml) return false;
		var retValue = "";
		var xPathString = "//Parameter[@FilterID='" + p_paramOrdinal + "']/@ColName";

		if (_xmldoc.selectNodes(xPathString).length > 0)
		{
			retValue = _xmldoc.selectSingleNode(xPathString).text;
		}
		return retValue;
	}
	this.Filter_Parameter_ColOrdinal = function(p_paramOrdinal)
	{
		if (!_xmldoc.xml) return false;
		var retValue = "";
		var xPathString = "//Parameter[@FilterID='" + p_paramOrdinal + "']/@ColOrdinal";

		if (_xmldoc.selectNodes(xPathString).length > 0)
		{
			retValue = _xmldoc.selectSingleNode(xPathString).text;
		}
		return retValue;
	}
	this.Filter_Parameter_VerbText = function(p_paramOrdinal)
	{
		if (!_xmldoc.xml) return false;
		var retValue = "";
		var xPathString = "//Parameter[@FilterID='" + p_paramOrdinal + "']/@VerbText";

		if (_xmldoc.selectNodes(xPathString).length > 0)
		{
			retValue = _xmldoc.selectSingleNode(xPathString).text;
		}
		return retValue;
	}
	this.Filter_Parameter_Value = function(p_paramOrdinal)
	{
		if (!_xmldoc.xml) return false;
		var retValue = "";
		var xPathString = "//Parameter[@FilterID='" + p_paramOrdinal + "']";

		if (_xmldoc.selectNodes(xPathString).length > 0)
		{
			retValue = _xmldoc.selectSingleNode(xPathString).text;
		}
		return retValue;
	}

	this.load();
}
function loadInterfaceFromSavedFilter(savedFilterObj)
{
	for (var i = 1; i <= 10; i++)
	{
		if (savedFilterObj.Filter_Parameter_ColName(i) == "") return false;
	
		var selObj_FilterConjunction =	$(i + "_Filter_Conjunction");
		var selObj_FilterColumn =		$(i + "_Filter_Column");
		var selObj_FilterVerb =			$(i + "_Filter_Verb");
		var selObj_FilterValue;
		var selObj_NextOrdinal = i;
		if (i <= 10) selObj_NextOrdinal++;
		
		selObj_FilterColumn.disabled = false;
		Element.removeClassName(selObj_FilterColumn, "disabled");
		selectDropDownOptionbyValue(selObj_FilterColumn, savedFilterObj.Filter_Parameter_ColName(i));

		if($(selObj_NextOrdinal + "_Filter_Column")){
			$(selObj_NextOrdinal + "_Filter_Column").disabled = false;
			Element.removeClassName($(selObj_NextOrdinal + "_Filter_Column"), "disabled");
		}
						
		var selObj_FilterColumnType =	selObj_FilterColumn.options[selObj_FilterColumn.selectedIndex].coltype;
		var selObj_ColumnName =			selObj_FilterColumn.options[selObj_FilterColumn.selectedIndex].colname;
		
		if (selObj_FilterColumn.selectedIndex > 0)
		{
			if (i > 1)
			{
				selObj_FilterConjunction.disabled = false;
				selectDropDownOptionbyValue(selObj_FilterConjunction, savedFilterObj.Filter_Parameter_Conjunction(i));
				if (selObj_FilterConjunction.selectedIndex == 0)
				{
					selObj_FilterConjunction.selectedIndex = 1;
				}
			}
								
			Element.removeClassName(selObj_FilterConjunction, "disabled");
			Element.removeClassName(selObj_FilterVerb, "disabled");
			selObj_FilterVerb.disabled = false;
			selObj_FilterVerb.options.length = 0;

			Element.hide($(i + "_Filter_Value_Number"));
			Element.hide($(i + "_Filter_Value_String"));
			Element.hide($(i + "_Filter_Value_BetweenEntryBlock"));
			Element.hide($(i + "_Filter_Value_Select"));
			Element.hide($(i + "_Filter_Value_SelectMultiple"));
			Element.hide($(i + "_Filter_Value_Date"));

			switch(selObj_FilterColumnType)
			{
				case "number":
			    case "decimal":
			    case "integer":
			    case "long":
			    case "smallint":
			    case "int":
			    case "bigint":
					Element.show($(i + "_Filter_Value_Number"));
					selObj_FilterValue = $(i + "_Filter_Value_Number");
					selObj_FilterValue.value = savedFilterObj.Filter_Parameter_Value(i)
					selObj_FilterValue.onkeypress = function(){
						var selObjOrdinal = this.id.replace("_Filter_Value_Number", "");
						switch($(selObjOrdinal + "_Filter_Verb").value)
						{
							case "is in range":
								if(this.value.length > 0){
									if($(selObj_NextOrdinal + "_Filter_Column")){
										$(selObj_NextOrdinal + "_Filter_Column").disabled = false;
										Element.removeClassName($(selObj_NextOrdinal + "_Filter_Column"), "disabled");
									}
								}
								break;
							case "is not in range":
								if(this.value.length > 0){
									if($(selObj_NextOrdinal + "_Filter_Column")){
										$(selObj_NextOrdinal + "_Filter_Column").disabled = false;
										Element.removeClassName($(selObj_NextOrdinal + "_Filter_Column"), "disabled");
									}
								}
								break;
							default:
								//in all other cases for number columns, make sure a valid number was entered.
								if(isNumber(this.value)){
									if(this.value.length > 0){
										if($(selObj_NextOrdinal + "_Filter_Column")){
											$(selObj_NextOrdinal + "_Filter_Column").disabled = false;
											Element.removeClassName($(selObj_NextOrdinal + "_Filter_Column"), "disabled");
										}
									}
								}
						}
					};
					selObj_FilterValue.onchange = function(){
						var selObjOrdinal = this.id.replace("_Filter_Value_Number", "");
						switch($(selObjOrdinal + "_Filter_Verb").value)
						{
							case "is in range":
								if(this.value.length > 0){
									if($(selObj_NextOrdinal + "_Filter_Column")){
										$(selObj_NextOrdinal + "_Filter_Column").disabled = false;
										Element.removeClassName($(selObj_NextOrdinal + "_Filter_Column"), "disabled");
									}
								}
								break;
							case "is not in range":
								if(this.value.length > 0){
									if($(selObj_NextOrdinal + "_Filter_Column")){
										$(selObj_NextOrdinal + "_Filter_Column").disabled = false;
										Element.removeClassName($(selObj_NextOrdinal + "_Filter_Column"), "disabled");
									}
								}
								break;
							default:
								//in all other cases for number columns, make sure a valid number was entered.
								if(isNumber(this.value)){
									if(this.value.length > 0){
										if($(selObj_NextOrdinal + "_Filter_Column")){
											$(selObj_NextOrdinal + "_Filter_Column").disabled = false;
											Element.removeClassName($(selObj_NextOrdinal + "_Filter_Column"), "disabled");
										}
									}
								}
						}
					};
					populateDropDown(selObj_FilterVerb, arNumberVerbs);
					selectDropDownOptionbyValue(selObj_FilterVerb, savedFilterObj.Filter_Parameter_VerbText(i));
					break;
				case "string":
		        case "varchar":
		        case "nvarchar":
		        case "char":
					Element.show($(i + "_Filter_Value_String"));
					selObj_FilterValue = $(i + "_Filter_Value_String");
					selObj_FilterValue.value = savedFilterObj.Filter_Parameter_Value(i)
					selObj_FilterValue.onchange = function(){
						if(this.value.length > 0){
							if($(selObj_NextOrdinal + "_Filter_Column")){
								$(selObj_NextOrdinal + "_Filter_Column").disabled = false;
								Element.removeClassName($(selObj_NextOrdinal + "_Filter_Column"), "disabled");
							}
						}
					};
					populateDropDown(selObj_FilterVerb, arStringVerbs);
					selectDropDownOptionbyValue(selObj_FilterVerb, savedFilterObj.Filter_Parameter_VerbText(i));
					break;
				case "select":
				case "select2":
			    case "listvalue":
					populateDropDown(selObj_FilterVerb, arSelectVerbs);
					selectDropDownOptionbyValue(selObj_FilterVerb, savedFilterObj.Filter_Parameter_VerbText(i));
					switch($(i + "_Filter_Verb").value)
					{
						case "is in range":
							Element.show($(i + "_Filter_Value_SelectMultiple"));
							selObj_FilterValue = $(i + "_Filter_Value_SelectMultiple");
							populateDropDown(selObj_FilterValue, eval(selObj_ColumnName + "_Options"));
							selectMultipleDropDownOptionbyValue(selObj_FilterValue, savedFilterObj.Filter_Parameter_Value(i).split(", "));
							break;
						case "is not in range":
							Element.show($(i + "_Filter_Value_SelectMultiple"));
							selObj_FilterValue = $(i + "_Filter_Value_SelectMultiple");
							populateDropDown(selObj_FilterValue, eval(selObj_ColumnName + "_Options"));
							selectMultipleDropDownOptionbyValue(selObj_FilterValue, savedFilterObj.Filter_Parameter_Value(i).split(", "));
							break;
						default:
							Element.show($(i + "_Filter_Value_Select"));
							selObj_FilterValue = $(i + "_Filter_Value_Select");
							populateDropDown(selObj_FilterValue, eval(selObj_ColumnName + "_Options"));
							selectDropDownOptionbyValue(selObj_FilterValue, savedFilterObj.Filter_Parameter_Value(i));
					}
					if($(selObj_NextOrdinal + "_Filter_Column")){
						$(selObj_NextOrdinal + "_Filter_Column").disabled = false
						Element.removeClassName($(selObj_NextOrdinal + "_Filter_Column"), "disabled");
					};
					selObj_FilterVerb.onchange = function(){
						var selObj_SingleDropDown = $(this.id.replace("_Filter_Verb", "_Filter_Value_Select"));
						var selObj_MultiDropDown = $(this.id.replace("_Filter_Verb", "_Filter_Value_SelectMultiple"));
						Element.hide(selObj_SingleDropDown);
						Element.hide(selObj_MultiDropDown);
						switch(this.value)
						{
							case "is in range":
								Element.show(selObj_MultiDropDown);
								selObj_FilterValue = selObj_MultiDropDown;
								populateDropDown(selObj_FilterValue, eval(selObj_ColumnName + "_Options"));
								if($(selObj_NextOrdinal + "_Filter_Column")){
									$(selObj_NextOrdinal + "_Filter_Column").disabled = false
									Element.removeClassName($(selObj_NextOrdinal + "_Filter_Column"), "disabled");
								};
								break;
							case "is not in range":
								Element.show(selObj_MultiDropDown);
								selObj_FilterValue = selObj_MultiDropDown;
								populateDropDown(selObj_FilterValue, eval(selObj_ColumnName + "_Options"));
								if($(selObj_NextOrdinal + "_Filter_Column")){
									$(selObj_NextOrdinal + "_Filter_Column").disabled = false
									Element.removeClassName($(selObj_NextOrdinal + "_Filter_Column"), "disabled");
								};
								break;
							default:
								Element.show(selObj_SingleDropDown);
								selObj_FilterValue = selObj_SingleDropDown;
								populateDropDown(selObj_FilterValue, eval(selObj_ColumnName + "_Options"));
								if($(selObj_NextOrdinal + "_Filter_Column")){
									$(selObj_NextOrdinal + "_Filter_Column").disabled = false
									Element.removeClassName($(selObj_NextOrdinal + "_Filter_Column"), "disabled");
								};
						}
					}
					break;
				case "date":
			    case "dateselectcomplete":
			    case "datetime":
					Element.show($(i + "_Filter_Value_Date"));
					selObj_FilterValue = $(i + "_Filter_Value_Date");
					selObj_FilterValue.value = savedFilterObj.Filter_Parameter_Value(i)
					selObj_FilterValue.onblur = function(){
						if(isDate(this.value)){
							if(this.value.length > 0){
								if($(selObj_NextOrdinal + "_Filter_Column")){
									$(selObj_NextOrdinal + "_Filter_Column").disabled = false;
									Element.removeClassName($(selObj_NextOrdinal + "_Filter_Column"), "disabled");
								}
							}
						}
						else
						{
							this.select();
							this.focus();
						}
					};
					populateDropDown(selObj_FilterVerb, arDateVerbs);
					selectDropDownOptionbyValue(selObj_FilterVerb, savedFilterObj.Filter_Parameter_VerbText(i));
					break;
				default:
					break;
			}
		}
		else
		{
			if(selObj_FilterConjunction) selObj_FilterConjunction.selectedIndex = 0;
			selObj_FilterVerb.options.length = 0;
			Element.hide($(i + "_Filter_Value_Number"));
			Element.hide($(i + "_Filter_Value_String"));
			Element.hide($(i + "_Filter_Value_BetweenEntryBlock"));
			Element.hide($(i + "_Filter_Value_Select"));
			Element.hide($(i + "_Filter_Value_SelectMultiple"));
			Element.hide($(i + "_Filter_Value_Date"));
		}
		
		selObj_FilterConjunction =	null;
		selObj_FilterColumn =		null;
		selObj_FilterVerb =			null;
		selObj_FilterValue =		null;
		selObj_FilterColumnType =	null;
	}
}
function resetInterface()
{
	for (var i = 1; i <= 10; i++)
	{
		var selObj_FilterConjunction =	$(i + "_Filter_Conjunction");
		var selObj_FilterColumn =		$(i + "_Filter_Column");
		var selObj_FilterVerb =			$(i + "_Filter_Verb");
		var selObj_FilterValue;

		if (selObj_FilterConjunction) selObj_FilterConjunction.selectedIndex = 0;
		selObj_FilterColumn.selectedIndex = 0;
		selObj_FilterVerb.options.length = 0;

		if (selObj_FilterConjunction) selObj_FilterConjunction.disabled = true;
		if (i > 1) selObj_FilterColumn.disabled = true;
		selObj_FilterVerb.disabled = true;

		if (selObj_FilterConjunction) Element.addClassName(selObj_FilterConjunction, "disabled");
		if (i > 1) Element.addClassName(selObj_FilterColumn, "disabled");
		Element.addClassName(selObj_FilterVerb, "disabled");

		Element.hide($(i + "_Filter_Value_Number"));
		Element.hide($(i + "_Filter_Value_String"));
		Element.hide($(i + "_Filter_Value_BetweenEntryBlock"));
		Element.hide($(i + "_Filter_Value_Select"));
		Element.hide($(i + "_Filter_Value_SelectMultiple"));
		Element.hide($(i + "_Filter_Value_Date"));

		selObj_FilterConjunction =	null;
		selObj_FilterColumn =		null;
		selObj_FilterVerb =			null;
		selObj_FilterValue =		null;
		selObj_FilterColumnType =	null;
	}
}
function clickSaveAs()
{
	if ($("chkSaveAs").checked == true)
	{
		$("txtSaveAsName").disabled = false;
		$("Select_SendTo").disabled = false;
		Element.removeClassName($("txtSaveAsName"), "disabled");
		Element.removeClassName($("Select_SendTo"), "disabled");
		//$("Select_SendTo").options.selectedIndex = 0;
	}
	else
	{
		$("txtSaveAsName").disable = true;
		$("Select_SendTo").disable = true;
		Element.addClassName($("txtSaveAsName"), "disabled");
		Element.addClassName($("Select_SendTo"), "disabled");
		//$("Select_SendTo").options.selectedIndex = -1;
	}
}
