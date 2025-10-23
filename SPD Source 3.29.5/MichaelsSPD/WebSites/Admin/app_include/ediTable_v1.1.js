// ediTable  v1.0
// Author: Ken Wallace

function ediTable(strTblID, strTblName, intCellPadding, intCellSpacing, intBorderWidth, intTblWidth, strClassName, strStyleStr)
{
	//set defaults for the new table
	this.ordinal = generateNewTableID();
	this.id = (arguments.length > 0 && strTblID != "") ? strTblID : "tbl_ediTable_" + this.ordinal + "";
	this.name = (arguments.length > 0 && strTblName != "") ? strTblName : this.id;
	this.cellpadding = (arguments.length > 0 && intCellPadding != "") ? intCellPadding : "2";
	this.cellspacing = (arguments.length > 0 && intCellSpacing != "") ? intCellSpacing : "0";
	this.border = (arguments.length > 0 && intBorderWidth != "") ? intBorderWidth : "0";
	this.width = (arguments.length > 0 && intTblWidth != "") ? intTblWidth : "0";
	this.className = (arguments.length > 0 && strClassName != "") ? strClassName : "";
	this.styleStr = (arguments.length > 0 && strStyleStr != "") ? strStyleStr : "";
	this.headClassName = "ediTable_head";
	this.rowClassName = "ediTable_row";
	this.rowAltClassName = "ediTable_rowAlt";
	this.footClassName = "ediTable_foot";
	
	//data entry properties
	this.editBehavior = new ediTable_editBehavior(this);
	
	//if asked to write out the table...
	this.write = function(parentElem)
	{
		var tblObj = this;
		ediTable_writeTable(tblObj, parentElem);
	}

	//if asked for the tables HTML content...
	this.HTML = function()
	{
		var tblObj = this;
		return ediTable_returnTable(tblObj);
	}
	
	this.Columns = new Array();
	this.Rows = new Array();
	
	this.addColumn = function(newCol)
	{
		return this.Columns.add(newCol);
	}

	this.addColumns = function(newCols)
	{
		var arNewCols = new Array();
		if (arguments.length == 1)
		{
			if (typeof(newCols) == "string")
			{
				this.addColumn(newCols);
				return this.Columns;
			}
			else
			{
				for (var i = 0; i < newCols.length; i++)
				{
					arNewCols[i] = newCols[i];
				}
			}
		}
		if (arguments.length > 1)
		{
			for (var i = 0; i < arguments.length; i++)
			{
				arNewCols[i] = arguments[i];
			}
		}

		for (var i = 0; i < arNewCols.length; i++)
		{
			this.Columns.add(arNewCols[i]);
			return this.Columns;
		}
	}
	
	this.Columns.add = function(colID)
	{
		var newCol = new ediTable_column();
		newCol.id = colID;
		newCol.label = newCol.id;
		this.push(newCol);
		return newCol;
	}
	
	this.Columns.getColumnByID = function(colID)
	{				
		var returnCol = new ediTable_column();
		for (var i = 0; i < this.length; i++)
		{
			if (this[i].id == colID)
			{
				returnCol = this[i];
				break;
			}
		}
		return returnCol;
	}

}

function ediTable_editBehavior(tblObj)
{
	this.allowAdd = false;
	this.allowDelete = false;
	this.validateEntries = false;
//	this.validationFunction = function(){ediTable_validateData(this)};
	this.limitRows = false;
	this.maxRows = -1;
	this.createMatchingHiddenElements = true;
	this.hiddenElementNamePrefix = tblObj.id + "_fld_";	
	this.hiddenElementNameSuffix = "";	
	this.allowSorting = false;
	this.editrowCaption = '<div id="editrowCaption" style="font-family: Times; font-size: 20px; font-weight: bold; line-height: 12px; width: 12px; height: 12px; clip: auto; overflow: hidden; border: 0px solid #000; padding-top: 2px; color: #000;">*</div>';
	this.addBtn_id = tblObj.id + "_btnAdd";
	this.addBtn_label = "Add";
	this.addBtn_className = "ediTable_addBtn";
	this.addBtn_styleStr = "";
	this.addBtn_customEvents = new ediTable_customEvents();
	this.addBtn_align = "";
	this.addBtn_vAlign = "";
	this.removeBtn_id_prefix = tblObj.id + "_btnRemove_";
	this.removeBtn_label = "X";
	this.removeBtn_className = "ediTable_removeBtn";
	this.removeBtn_styleStr = "";
	this.removeBtn_customEvents = new ediTable_customEvents();
	this.removeBtn_align = "";
	this.removeBtn_vAlign = "";
}

function ediTable_column()
{
	this.id = "";
	this.label = "";
	this.showDataEntryField = true;
	this.showCellData = true;
	this.showColHeader = true;
	this.allowSortBy = true;
	this.width = "";
	this.datatype = "string"; // "string", "number", "date", "multiline-text", "boolean", "select", "plaintext"
	this.datatype_ext = ""; // extended property, such as: "fixed", "precise", "defaultChecked"
	this.datatype_ext_value = ""; // value of the extended property
	this.align = "left"; // "left", "center", "right"
	this.vAlign = "top"; // "top", "middle", "bottom"
	this.editCell_select_options = []; // array of select list options (Applies only to "select" datatypes)
	/*
	Array should be formatted either like this:
		this.editCell_select_options[0] = [" <OPTION_VALUE0> ", "<OPTION_TEXT0>"];
		this.editCell_select_options[1] = [" <OPTION_VALUE1> ", "<OPTION_TEXT1>"];
		this.editCell_select_options[2] = [" <OPTION_VALUE2> ", "<OPTION_TEXT2>"];
	Or, like this:
		this.editCell_select_options = [ [" <OPTION_VALUE0> ", "<OPTION_TEXT0>"], [" <OPTION_VALUE1> ", "<OPTION_TEXT1>"], [" <OPTION_VALUE2> ", "<OPTION_TEXT2>"] ];
	Or, like this:
		this.editCell_select_options.push([" <OPTION_VALUE0> ", "<OPTION_TEXT0>"], [" <OPTION_VALUE1> ", "<OPTION_TEXT1>"], [" <OPTION_VALUE2> ", "<OPTION_TEXT2>"]);
	*/
	this.editCell_select_defaultOption = 0;
	this.editCell_select_isMultiLine = false;
	this.editCell_select_size = 1;
	this.editCell_maxLength = 1000;
	this.editCell_className = "ediTable_editCell";
	this.editCell_styleStr = "";
	this.editCell_defaultValue = "";
	this.editCell_validationFunction = null;
	this.required = false;
}

function ediTable_customEvents()
{
	this.onactivate = null; 
	this.onafterupdate = null; 
	this.onbeforeactivate = null; 
	this.onbeforecut = null; 
	this.onbeforedeactivate = null; 
	this.onbeforeeditfocus = null; 
	this.onbeforepaste = null; 
	this.onbeforeupdate = null; 
	this.onblur = null; 
	this.onclick = null; 
	this.oncontextmenu = null; 
	this.oncontrolselect = null; 
	this.oncut = null; 
	this.ondblclick = null; 
	this.ondeactivate = null; 
	this.ondragenter = null; 
	this.ondragleave = null; 
	this.ondragover = null; 
	this.ondrop = null; 
	this.onerrorupdate = null; 
	this.onfilterchange = null; 
	this.onfocus = null; 
	this.onfocusin = null; 
	this.onfocusout = null; 
	this.onhelp = null; 
	this.onkeydown = null; 
	this.onkeypress = null; 
	this.onkeyup = null; 
	this.onlosecapture = null; 
	this.onmousedown = null; 
	this.onmouseenter = null; 
	this.onmouseleave = null; 
	this.onmousemove = null; 
	this.onmouseout = null; 
	this.onmouseover = null; 
	this.onmouseup = null; 
	this.onmousewheel = null; 
	this.onmove = null; 
	this.onmoveend = null; 
	this.onmovestart = null; 
	this.onpaste = null; 
	this.onpropertychange = null; 
	this.onreadystatechange = null; 
	this.onresize = null; 
	this.onresizeend = null; 
	this.onresizestart = null; 
	this.onselectstart = null; 
	this.ontimeerror = null; 
}

var nextTableIDCache = 0;
function generateNewTableID()
{
	var returnID = nextTableIDCache;
	nextTableIDCache = nextTableIDCache + 1;
	return returnID;
}

function ediTable_clearDataEntryFields(tblObj)
{
	var oTable, oTBody;
	oTable = eval("" + tblObj.id);
	oTBody = oTable.tBodies[0];
	for (var j = 0; j < tblObj.Columns.length; j++)
	{
		if (tblObj.Columns[j].showDataEntryField)
		{
			switch(tblObj.Columns[j].datatype)
			{
				case "boolean":
					if (tblObj.Columns[j].datatype_ext == "defaultChecked" && tblObj.Columns[j].datatype_ext_value == true)
					{
						document.all[tblObj.id + '_new_' + tblObj.Columns[j].id].defaultChecked = true;
						document.all[tblObj.id + '_new_' + tblObj.Columns[j].id].checked = true;
					}
					else
					{
						document.all[tblObj.id + '_new_' + tblObj.Columns[j].id].defaultChecked = false;
						document.all[tblObj.id + '_new_' + tblObj.Columns[j].id].checked = false;
					}
					break;
				case "select":
					document.all[tblObj.id + '_new_' + tblObj.Columns[j].id].selectedIndex = tblObj.Columns[j].editCell_select_defaultOption;
					break;
				default:
					document.all[tblObj.id + '_new_' + tblObj.Columns[j].id].value = tblObj.Columns[j].editCell_defaultValue;
					break;
			}
		}
	}
}

function ediTable_updateDebugWindow(tblObj)
{
	if(typeof(document.all[tblObj.id].outerHTML) == "object")
	{
		debugStr = document.all[tblObj.id].outerHTML;
		if(typeof(debugWindow) == "object")
		{
			debugWindow.innerText = "";
			debugWindow.innerText = debugStr;
		}
	}
}

function ediTable_writeTable(tblObj, parentElem)
{
	if (typeof(tblObj) != "object") return false;
	var debugStr = "";
	if (parentElem != "" && typeof(parentElem) == "object")
	{
		parentElem.appendChild(ediTable_returnTable(tblObj));
	}
	else
	{
		var newTable = document.createElement("TABLE");
		newTable = ediTable_returnTable(tblObj);
	}
	ediTable_alternateRowColors(tblObj);
	ediTable_updateDebugWindow(tblObj);
	ediTable_clearDataEntryFields(tblObj);
	document.all["totNumRows_" + tblObj.id].value = tblObj.Rows.length;
}

function ediTable_returnTable(tblObj)
{
	if (typeof(tblObj) != "object") return false;
	
	//create a table
	var oTable = document.createElement("TABLE");
	
	//create table elements
	var oTHead = document.createElement("THEAD");
	var oTBody = document.createElement("TBODY");
	var oTFoot = document.createElement("TFOOT");
	
	// insert the created elements into oTable.
	oTable.appendChild(oTHead);
	oTable.appendChild(oTBody);
	oTable.appendChild(oTFoot);
	
	oTable.id = tblObj.id;
	oTable.setAttribute("name", tblObj.name, 0);
	oTable.cellPadding = (tblObj.cellpadding != "" && !isNaN(tblObj.cellpadding))? tblObj.cellpadding : "0";
	oTable.cellSpacing = (tblObj.cellspacing != "" && !isNaN(tblObj.cellspacing))? tblObj.cellspacing : "0";
	oTable.border = (tblObj.border != "" && !isNaN(tblObj.border))? tblObj.border : "0";
	oTable.width = (tblObj.width != "" && !isNaN(tblObj.width) && tblObj.width > 0)? tblObj.width : "";
	oTable.className = tblObj.className;
	oTable.style.cssText = tblObj.styleStr;

	var oRow, oCell, oButton, newRowVal, oNum, oElem;
	var msg = "";

	// HEADER ROW
	// create and insert a row into the header.
	oRow = document.createElement("TR");
	oRow.className = tblObj.headClassName;
	oTHead.appendChild(oRow);

	// create and insert cells into the header row.
	if (tblObj.editBehavior.editrowCaption != "")
	{
		oCell = document.createElement("TD");
		oCell.innerHTML = "&nbsp;";
		oRow.appendChild(oCell);

	}
	for (var i = 0; i < tblObj.Columns.length; i++)
	{
		oCell = document.createElement("TD");
		oCell.innerHTML = (tblObj.Columns[i].showColHeader == true)? tblObj.Columns[i].label : "&nbsp;";
		oCell.width = tblObj.Columns[i].width;
		oRow.appendChild(oCell);
	}
	oCell = document.createElement("TD");
	oCell.innerHTML = "&nbsp;";

	oElem = document.createElement("INPUT");
	oElem.type = "hidden";
	oElem.id = "totNumRows_" + tblObj.id;
	oElem.value = tblObj.Rows.length;
	oElem.setAttribute("name", oElem.id, 0);
	oCell.insertAdjacentElement('beforeEnd', oElem);

	oRow.appendChild(oCell);

	// BODY ROWS
	// Create and insert rows and cells into the body.
	for (var i = 0; i < tblObj.Rows.length; i++)
	{
		oRow = document.createElement("TR");
		oTBody.appendChild(oRow);

		if (tblObj.editBehavior.editrowCaption != "")
		{
			oCell = document.createElement("TD");
			oCell.innerHTML = "&nbsp;"; // maybe in the future put an ID number or an autonumber feature?
			oRow.appendChild(oCell);
		}
		for (var j = 0; j < tblObj.Columns.length; j++)
		{
			oCell = document.createElement("TD");

			oCell.align = tblObj.Columns[j].align;
			oCell.vAlign = tblObj.Columns[j].vAlign;

			newRowVal = (tblObj.Rows[i] instanceof Array) ? tblObj.Rows[i][j] : tblObj.Columns[j].defaultValue;
			newRowVal = (newRowVal != "") ? newRowVal : "&nbsp;";

			switch (tblObj.Columns[j].datatype)
			{
				case "number":
					switch (tblObj.Columns[j].datatype_ext)
					{
						case "fixed":
							newRowVal = (!isNaN(newRowVal)) ? newRowVal : 0;
							oNum = new Number(newRowVal);
							newRowVal = oNum.toFixed(tblObj.Columns[j].datatype_ext_value);
							break;
						case "precise":
							newRowVal = (!isNaN(newRowVal)) ? newRowVal : 0;
							oNum = new Number(newRowVal);
							newRowVal = oNum.toPrecision(tblObj.Columns[j].datatype_ext_value);
							break;
					}		

					oCell.innerHTML = (tblObj.Columns[j].showCellData == true)? newRowVal : "&nbsp;";

					msg += "tblObj.Rows[" + i + "][" + j + "] = " + tblObj.Rows[i][j] + "\n"
					
					oRow.appendChild(oCell);
					
					if (tblObj.editBehavior.createMatchingHiddenElements == true)
					{
						oElem = document.createElement("INPUT");
						oElem.type = "hidden";
						oElem.id = tblObj.editBehavior.hiddenElementNamePrefix + tblObj.Columns[j].id + "_" + i + tblObj.editBehavior.hiddenElementNameSuffix;
						oElem.value = newRowVal;
						oElem.setAttribute("name", oElem.id, 0);
						oCell.insertAdjacentElement('beforeEnd', oElem);
					}

					break;
				
				case "select":
					var newRowText;

					if (typeof(tblObj.Columns[j].editCell_select_options) != "object" || !(tblObj.Columns[j].editCell_select_options instanceof Array)) break;
					for (var y = 0; y < tblObj.Columns[j].editCell_select_options.length; y++)
					{
						if (tblObj.Rows[i][j] == tblObj.Columns[j].editCell_select_options[y][0])
						{
							newRowText = tblObj.Columns[j].editCell_select_options[y][1];
							newRowVal = tblObj.Columns[j].editCell_select_options[y][0];
						}
					}

					oCell.innerHTML = (tblObj.Columns[j].showCellData == true)? newRowText : "&nbsp;";

					msg += "tblObj.Rows[" + i + "][" + j + "] = " + tblObj.Rows[i][j] + " " + newRowVal + ":" + newRowText + "\n"
					
					oRow.appendChild(oCell);
					
					if (tblObj.editBehavior.createMatchingHiddenElements == true)
					{
						oElem = document.createElement("INPUT");
						oElem.type = "hidden";
						oElem.id = tblObj.editBehavior.hiddenElementNamePrefix + tblObj.Columns[j].id + "_" + i + tblObj.editBehavior.hiddenElementNameSuffix;
						oElem.value = newRowVal;
						oElem.setAttribute("name", oElem.id, 0);
						oCell.insertAdjacentElement('beforeEnd', oElem);
					}

					break;
				
				case "boolean":
					var boolStr_PositiveResponse, boolStr_NegativeResponse;
					var imgStr_Positive, imgStr_Negative;
					switch(tblObj.Columns[j].defaultValue)
					{
						case "true":
							boolStr_PositiveResponse = "true";
							boolStr_NegativeResponse = "false";
							break;
						case "TRUE":
							boolStr_PositiveResponse = "TRUE";
							boolStr_NegativeResponse = "FALSE";
							break;
						case "True":
							boolStr_PositiveResponse = "True";
							boolStr_NegativeResponse = "False";
							break;
						case "t":
							boolStr_PositiveResponse = "t";
							boolStr_NegativeResponse = "f";
							break;
						case "T":
							boolStr_PositiveResponse = "T";
							boolStr_NegativeResponse = "F";
							break;
						case "yes":
							boolStr_PositiveResponse = "yes";
							boolStr_NegativeResponse = "no";
							break;
						case "y":
							boolStr_PositiveResponse = "y";
							boolStr_NegativeResponse = "n";
							break;
						case "Y":
							boolStr_PositiveResponse = "Y";
							boolStr_NegativeResponse = "N";
							break;
						case "YES":
							boolStr_PositiveResponse = "YES";
							boolStr_NegativeResponse = "NO";
							break;
						case "Yes":
							boolStr_PositiveResponse = "Yes";
							boolStr_NegativeResponse = "No";
							break;
						case "1":
							boolStr_PositiveResponse = "1";
							boolStr_NegativeResponse = "0";
							break;
						case "0":
							boolStr_PositiveResponse = "0";
							boolStr_NegativeResponse = "-1";
							break;
						case "image":
							imgStr_Positive			 = tblObj.Columns[j].defaultValue_PositiveImage
							imgStr_Negative			 = tblObj.Columns[j].defaultValue_NegativeImage
							boolStr_PositiveResponse = "1";
							boolStr_NegativeResponse = "0";
							break;
						default:
							boolStr_PositiveResponse = tblObj.Columns[j].defaultValue;
							boolStr_NegativeResponse = "";
							break;
					}
					newRowVal = (tblObj.Rows[i][j] == boolStr_PositiveResponse) ? boolStr_PositiveResponse : boolStr_NegativeResponse;

				//	oCell.innerHTML = (tblObj.Columns[j].showCellData == true)? newRowVal : "&nbsp;";
					oCell.innerHTML = "&nbsp;";
					if (tblObj.Columns[j].showCellData == true)
					{
						if (tblObj.Columns[j].defaultValue == "image")
						{
							oCell.innerHTML = (tblObj.Rows[i][j] == boolStr_PositiveResponse) ? imgStr_Positive : imgStr_Negative;
						}
						else
						{
							oCell.innerHTML = newRowVal;
						}
					}

					msg += "tblObj.Rows[" + i + "][" + j + "] = " + tblObj.Rows[i][j] + "\n"
					
					oRow.appendChild(oCell);
					
					if (tblObj.editBehavior.createMatchingHiddenElements == true)
					{
						oElem = document.createElement("INPUT");
						oElem.type = "hidden";
						oElem.id = tblObj.editBehavior.hiddenElementNamePrefix + tblObj.Columns[j].id + "_" + i + tblObj.editBehavior.hiddenElementNameSuffix;
						oElem.value = newRowVal;
						oElem.setAttribute("name", oElem.id, 0);
						oCell.insertAdjacentElement('beforeEnd', oElem);
					}

					break;

				default:
					oCell.innerHTML = (tblObj.Columns[j].showCellData == true)? newRowVal : "&nbsp;";

					msg += "tblObj.Rows[" + i + "][" + j + "] = " + tblObj.Rows[i][j] + "\n"
					
					oRow.appendChild(oCell);
					
					if (tblObj.editBehavior.createMatchingHiddenElements == true)
					{
						oElem = document.createElement("INPUT");
						oElem.type = "hidden";
						oElem.id = tblObj.editBehavior.hiddenElementNamePrefix + tblObj.Columns[j].id + "_" + i + tblObj.editBehavior.hiddenElementNameSuffix;
						oElem.value = newRowVal;
						oElem.setAttribute("name", oElem.id, 0);
						oCell.insertAdjacentElement('beforeEnd', oElem);
					}

					break;
			}
		}

		if (tblObj.editBehavior.allowDelete == true)
		{
			oCell = document.createElement("TD");
			oCell.innerHTML = "&nbsp;";
			oCell.align = tblObj.editBehavior.removeBtn_align;
			oCell.vAlign = tblObj.editBehavior.removeBtn_vAlign;
			oRow.appendChild(oCell);
			oButton = document.createElement("BUTTON");
			oButton.id = tblObj.editBehavior.removeBtn_id_prefix + i;
			oButton.innerHTML = tblObj.editBehavior.removeBtn_label;
			oButton.className = tblObj.editBehavior.removeBtn_className;
			oButton.style.cssText = tblObj.editBehavior.removeBtn_styleStr;
			oButton.parentEdiTable = tblObj;
			oButton.onclick = (tblObj.editBehavior.removeBtn_customEvents.onclick != null)? tblObj.editBehavior.removeBtn_customEvents.onclick : function(){ediTable_removeRow(this)};
			oCell.insertAdjacentElement('afterBegin', oButton);
		}

	}

	// FOOTER ROW
	// Create and insert rows and cells into the body.
	oRow = document.createElement("TR");
	oTFoot.appendChild(oRow);

	if (tblObj.editBehavior.editrowCaption != "")
	{
		oCell = document.createElement("TD");
		oCell.className = tblObj.footClassName;
		oCell.innerHTML = tblObj.editBehavior.editrowCaption;
		oRow.appendChild(oCell);
	}
	for (var i = 0; i < tblObj.Columns.length; i++)
	{
		oCell = document.createElement("TD");
		oCell.className = tblObj.footClassName;
		oCell.align = tblObj.Columns[i].align;
		if (tblObj.Columns[i].showDataEntryField == true && tblObj.editBehavior.allowAdd == true)
		{
			switch(tblObj.Columns[i].datatype)
			{
				case "string":
					oCell.innerHTML = '<input type="text" name="' + tblObj.id + '_new_' + tblObj.Columns[i].id + '" id="' + tblObj.id + '_new_' + tblObj.Columns[i].id + '" value="' + tblObj.Columns[i].editCell_defaultValue + '" maxlength=' + tblObj.Columns[i].editCell_maxLength + ' class="' + tblObj.Columns[i].editCell_className + '" style="' + tblObj.Columns[i].editCell_styleStr + '">';
					break;

				case "number":
					oCell.innerHTML = '<input type="text" name="' + tblObj.id + '_new_' + tblObj.Columns[i].id + '" id="' + tblObj.id + '_new_' + tblObj.Columns[i].id + '" value="' + tblObj.Columns[i].editCell_defaultValue + '" maxlength=' + tblObj.Columns[i].editCell_maxLength + ' class="' + tblObj.Columns[i].editCell_className + '" style="text-align:right;' + tblObj.Columns[i].editCell_styleStr + '">';
					break;

				case "date":
					//	oCell.innerHTML = '<table cellspacing=0 cellpadding=0 border=0><tr><td><input type="text" name="' + tblObj.id + '_new_' + tblObj.Columns[i].id + '" id="' + tblObj.id + '_new_' + tblObj.Columns[i].id + '" value="' + tblObj.Columns[i].editCell_defaultValue + '" maxlength=10 class="' + tblObj.Columns[i].editCell_className + '" style="width:70px;' + tblObj.Columns[i].editCell_styleStr + '"></td><td><a href="javascript:ediTable_dateWin(\'new_' + tblObj.Columns[i].id + '\');"><img src="../../app_images/mini_calendar.gif" border=0 alt="Click here to select your date from a calendar"></a></td></tr></table>';
					var nTable = document.createElement("TABLE");
					nTable.border = 0;
					nTable.cellPadding = 0;
					nTable.cellSpacing = 0;
					nRow = nTable.insertRow();
				
					var nCell = nRow.insertCell();
					var nElem = document.createElement("INPUT");
					nElem.type = "text";
					nElem.id = tblObj.id + "_new_" + tblObj.Columns[i].id;
					nElem.setAttribute("name", nElem.id, 0);
					nElem.value = tblObj.Columns[i].editCell_defaultValue;
					nElem.maxLength = 10;
					nElem.className = tblObj.Columns[i].editCell_className;
					nElem.style.cssText = "width:70px;height:18px;" + tblObj.Columns[i].editCell_styleStr;
					nCell.insertAdjacentElement('afterBegin', nElem);
				
					var nCell = nRow.insertCell();
					var nElem = document.createElement("IMG");
					nElem.src = "../../app_images/mini_calendar.gif";
					nElem.border = 0;
					nElem.style.cssText = "cursor:hand;";
					nElem.style.cssText +=  tblObj.Columns[i].editCell_styleStr;
					var tempStr = tblObj.id + "_new_" + tblObj.Columns[i].id + "";
					nElem.id = tempStr + "_calendarimg";
					nElem.alt = "Click here to select your date from a calendar.";
					nElem.onclick = function()
					{
						var thisTarget = new String(this.id);
						thisTarget = thisTarget.replace("_calendarimg", "");
						ediTable_dateWin(eval("'" + thisTarget + "'"));
					}
					nCell.insertAdjacentElement('afterBegin', nElem);
									
					oCell.insertAdjacentElement('afterBegin', nTable);
					break;

				case "select":
					var nElem = document.createElement("SELECT");
					nElem.id = tblObj.id + "_new_" + tblObj.Columns[i].id;
					nElem.setAttribute("name", nElem.id, 0);
					nElem.style.cssText =  tblObj.Columns[i].editCell_styleStr;
					for (var z = 0; z < tblObj.Columns[i].editCell_select_options.length; z++)
					{
						var oOption = document.createElement("OPTION");
						oOption.value = tblObj.Columns[i].editCell_select_options[z][0];
						oOption.text = tblObj.Columns[i].editCell_select_options[z][1];
						nElem.add(oOption);
					}
					nElem.selectedIndex = tblObj.Columns[i].editCell_select_defaultOption;
					oCell.insertAdjacentElement('afterBegin', nElem);
					break;

				case "boolean":
					var defaultCheckedStr = (tblObj.Columns[i].datatype_ext == "defaultChecked" && tblObj.Columns[i].datatype_ext_value == true) ? "CHECKED" : ""; 
					if (tblObj.Columns[i].editCell_checkboxLabel)
					{
						if (tblObj.Columns[i].editCell_checkboxLabel.length > 0)
						{
							oCell.innerHTML = '<input type="checkbox" ' + defaultCheckedStr + ' name="' + tblObj.id + '_new_' + tblObj.Columns[i].id + '" id="' + tblObj.id + '_new_' + tblObj.Columns[i].id + '" value="' + tblObj.Columns[i].editCell_defaultValue + '" class="' + tblObj.Columns[i].editCell_className + '" style="border: 0px; ' + tblObj.Columns[i].editCell_styleStr + '"><label for="' + tblObj.id + '_new_' + tblObj.Columns[i].id + '">' + tblObj.Columns[i].editCell_checkboxLabel + '</label>';
						}
						else
						{
							oCell.innerHTML = '<input type="checkbox" ' + defaultCheckedStr + ' name="' + tblObj.id + '_new_' + tblObj.Columns[i].id + '" id="' + tblObj.id + '_new_' + tblObj.Columns[i].id + '" value="' + tblObj.Columns[i].editCell_defaultValue + '" class="' + tblObj.Columns[i].editCell_className + '" style="border: 0px; ' + tblObj.Columns[i].editCell_styleStr + '">';
						}
					}
					else
					{
						oCell.innerHTML = '<input type="checkbox" ' + defaultCheckedStr + ' name="' + tblObj.id + '_new_' + tblObj.Columns[i].id + '" id="' + tblObj.id + '_new_' + tblObj.Columns[i].id + '" value="' + tblObj.Columns[i].editCell_defaultValue + '" class="' + tblObj.Columns[i].editCell_className + '" style="border: 0px; ' + tblObj.Columns[i].editCell_styleStr + '">';
					}
					break;

				case "plaintext":
					break;

				case "multiline-text":
					oCell.innerHTML = '<textarea name="' + tblObj.id + '_new_' + tblObj.Columns[i].id + '" id="' + tblObj.id + '_new_' + tblObj.Columns[i].id + '" class="' + tblObj.Columns[i].editCell_className + '" style="' + tblObj.Columns[i].editCell_styleStr + '">' + tblObj.Columns[i].editCell_defaultValue + '</textarea>';
					break;

				default:
					oCell.innerHTML = '';
			}
		}
		else
		{
			oCell.innerHTML = "&nbsp;";
		}
		oRow.appendChild(oCell);
	}
	if (tblObj.editBehavior.allowAdd == true)
	{
		oCell = document.createElement("TD");
		oCell.className = tblObj.footClassName;
		oCell.innerHTML = "&nbsp;";
		oRow.appendChild(oCell);
		oButton = document.createElement("BUTTON");
		oButton.id = tblObj.editBehavior.addBtn_id;
		oButton.innerHTML = tblObj.editBehavior.addBtn_label;
		oButton.className = tblObj.editBehavior.addBtn_className;
		oButton.style.cssText = tblObj.editBehavior.addBtn_styleStr;
		oButton.onclick = (tblObj.editBehavior.addBtn_customEvents.onclick != null)? tblObj.editBehavior.addBtn_customEvents.onclick : function(){ediTable_insertRow(tblObj)};
		oCell.insertAdjacentElement('afterBegin', oButton);
	}

//	alert(msg);

	// Insert the table into the document tree.
	return oTable;
}

function ediTable_insertRow(tblObj)
{
	var oTable, oTBody, oRow, oCell, oButton, newRowOrd, newRowVal, oNum, oElem, msg;
	oTable = eval("" + tblObj.id);
	oTBody = oTable.tBodies[0];

	newRowOrd = tblObj.Rows.length;
	var tempAr = [];
	tblObj.Rows.push(tempAr);

	msg = "";
	
	// Create and insert rows and cells into the body.
	oRow = document.createElement("TR");
	oTBody.appendChild(oRow);

	if (tblObj.editBehavior.editrowCaption != "")
	{
		oCell = document.createElement("TD");
		oCell.innerHTML = "&nbsp;";
		oRow.appendChild(oCell);
	}

	for (var j = 0; j < tblObj.Columns.length; j++)
	{
		oCell = document.createElement("TD");
		newRowVal = (typeof(document.all[tblObj.id + "_new_" + tblObj.Columns[j].id]) == "object") ? document.all[tblObj.id + "_new_" + tblObj.Columns[j].id].value : tblObj.Columns[j].defaultValue;
		newRowVal = (newRowVal != "") ? newRowVal : "&nbsp;";
		
	//	if (tblObj.editBehavior.validateEntries == true)
	//	{
	//		var testThis = (1 == 2) ? function(){return false} : function(){if (!ediTable_validateNewData()) return false;};
	//	}
		switch (tblObj.Columns[j].datatype)
		{
			case "number":
				switch (tblObj.Columns[j].datatype_ext)
				{
					case "fixed":
						newRowVal = (!isNaN(newRowVal)) ? newRowVal : 0;
						oNum = new Number(newRowVal);
						newRowVal = oNum.toFixed(tblObj.Columns[j].datatype_ext_value);
						break;
					case "precise":
						newRowVal = (!isNaN(newRowVal)) ? newRowVal : 0;
						oNum = new Number(newRowVal);
						newRowVal = oNum.toPrecision(tblObj.Columns[j].datatype_ext_value);
						break;
				}		

				oCell.innerHTML = (tblObj.Columns[j].showCellData == true)? newRowVal : "&nbsp;";
				oCell.align = tblObj.Columns[j].align;
				oCell.vAlign = tblObj.Columns[j].vAlign;
				tblObj.Rows[newRowOrd][j] = newRowVal;
				msg += "tblObj.Rows[" + newRowOrd + "][" + j + "] = " + tblObj.Rows[newRowOrd][j] + "\n"
				
				oRow.appendChild(oCell);
				
				if (tblObj.editBehavior.createMatchingHiddenElements == true)
				{
					oElem = document.createElement("INPUT");
					oElem.type = "hidden";
					oElem.id = tblObj.editBehavior.hiddenElementNamePrefix + tblObj.Columns[j].id + "_" + newRowOrd + tblObj.editBehavior.hiddenElementNameSuffix;
					oElem.value = newRowVal;
					oElem.setAttribute("name", oElem.id, 0);
					oCell.insertAdjacentElement('beforeEnd', oElem);
				}

				break;
			
			case "date":
				var today = new Date()
				newRowVal = (newRowVal != "" && newRowVal != "&nbsp;") ? newRowVal : today.getMonth() + 1 + "/" + today.getDate() + "/" + today.getYear();

				oCell.innerHTML = (tblObj.Columns[j].showCellData == true)? newRowVal : "&nbsp;";
				oCell.align = tblObj.Columns[j].align;
				oCell.vAlign = tblObj.Columns[j].vAlign;
				tblObj.Rows[newRowOrd][j] = newRowVal;
				msg += "tblObj.Rows[" + newRowOrd + "][" + j + "] = " + tblObj.Rows[newRowOrd][j] + "\n"
				
				oRow.appendChild(oCell);
				
				if (tblObj.editBehavior.createMatchingHiddenElements == true)
				{
					oElem = document.createElement("INPUT");
					oElem.type = "hidden";
					oElem.id = tblObj.editBehavior.hiddenElementNamePrefix + tblObj.Columns[j].id + "_" + newRowOrd + tblObj.editBehavior.hiddenElementNameSuffix;
					oElem.value = newRowVal;
					oElem.setAttribute("name", oElem.id, 0);
					oCell.insertAdjacentElement('beforeEnd', oElem);
				}
				break;

			case "select":
				var newRowText = document.all[tblObj.id + "_new_" + tblObj.Columns[j].id][document.all["new_" + tblObj.Columns[j].id].selectedIndex].text;
				newRowVal = document.all[tblObj.id + "_new_" + tblObj.Columns[j].id].value;

				oCell.innerHTML = (tblObj.Columns[j].showCellData == true)? newRowText : "&nbsp;";
				oCell.align = tblObj.Columns[j].align;
				oCell.vAlign = tblObj.Columns[j].vAlign;
				tblObj.Rows[newRowOrd][j] = newRowVal;
				msg += "tblObj.Rows[" + newRowOrd + "][" + j + "] = " + tblObj.Rows[newRowOrd][j] + "\n"
				
				oRow.appendChild(oCell);
				
				if (tblObj.editBehavior.createMatchingHiddenElements == true)
				{
					oElem = document.createElement("INPUT");
					oElem.type = "hidden";
					oElem.id = tblObj.editBehavior.hiddenElementNamePrefix + tblObj.Columns[j].id + "_" + newRowOrd + tblObj.editBehavior.hiddenElementNameSuffix;
					oElem.value = newRowVal;
					oElem.setAttribute("name", oElem.id, 0);
					oCell.insertAdjacentElement('beforeEnd', oElem);
				}

				break;
			
			case "boolean":
				var boolStr_PositiveResponse, boolStr_NegativeResponse;
				var imgStr_Positive, imgStr_Negative;

				switch(tblObj.Columns[j].defaultValue)
				{
					case "true":
						boolStr_PositiveResponse = "true";
						boolStr_NegativeResponse = "false";
						break;
					case "TRUE":
						boolStr_PositiveResponse = "TRUE";
						boolStr_NegativeResponse = "FALSE";
						break;
					case "True":
						boolStr_PositiveResponse = "True";
						boolStr_NegativeResponse = "False";
						break;
					case "t":
						boolStr_PositiveResponse = "t";
						boolStr_NegativeResponse = "f";
						break;
					case "T":
						boolStr_PositiveResponse = "T";
						boolStr_NegativeResponse = "F";
						break;
					case "yes":
						boolStr_PositiveResponse = "yes";
						boolStr_NegativeResponse = "no";
						break;
					case "y":
						boolStr_PositiveResponse = "y";
						boolStr_NegativeResponse = "n";
						break;
					case "Y":
						boolStr_PositiveResponse = "Y";
						boolStr_NegativeResponse = "N";
						break;
					case "YES":
						boolStr_PositiveResponse = "YES";
						boolStr_NegativeResponse = "NO";
						break;
					case "Yes":
						boolStr_PositiveResponse = "Yes";
						boolStr_NegativeResponse = "No";
						break;
					case "1":
						boolStr_PositiveResponse = "1";
						boolStr_NegativeResponse = "0";
						break;
					case "0":
						boolStr_PositiveResponse = "0";
						boolStr_NegativeResponse = "-1";
						break;
					case "image":
						imgStr_Positive			 = tblObj.Columns[j].defaultValue_PositiveImage
						imgStr_Negative			 = tblObj.Columns[j].defaultValue_NegativeImage
						boolStr_PositiveResponse = "1";
						boolStr_NegativeResponse = "0";
						break;
					default:
						boolStr_PositiveResponse = tblObj.Columns[j].defaultValue;
						boolStr_NegativeResponse = "";
						break;
				}
				newRowVal = (document.all[tblObj.id + '_new_' + tblObj.Columns[j].id].checked == true) ? boolStr_PositiveResponse : boolStr_NegativeResponse;

				oCell.innerHTML = "&nbsp;";
				if (tblObj.Columns[j].showCellData == true)
				{
					if (tblObj.Columns[j].defaultValue == "image" && (imgStr_Positive != "" || imgStr_Negative != ""))
					{
						oCell.innerHTML = (document.all[tblObj.id + '_new_' + tblObj.Columns[j].id].checked == true) ? imgStr_Positive : imgStr_Negative;
					}
					else
					{
						oCell.innerHTML = newRowVal;
					}
				}

				oCell.align = tblObj.Columns[j].align;
				oCell.vAlign = tblObj.Columns[j].vAlign;
				tblObj.Rows[newRowOrd][j] = newRowVal;
				msg += "tblObj.Rows[" + newRowOrd + "][" + j + "] = " + tblObj.Rows[newRowOrd][j] + "\n"
				
				oRow.appendChild(oCell);
				
				if (tblObj.editBehavior.createMatchingHiddenElements == true)
				{
					oElem = document.createElement("INPUT");
					oElem.type = "hidden";
					oElem.id = tblObj.editBehavior.hiddenElementNamePrefix + tblObj.Columns[j].id + "_" + newRowOrd + tblObj.editBehavior.hiddenElementNameSuffix;
					oElem.value = newRowVal;
					oElem.setAttribute("name", oElem.id, 0);
					oCell.insertAdjacentElement('beforeEnd', oElem);
				}

				break;
			
			default:
				oCell.innerHTML = (tblObj.Columns[j].showCellData == true)? newRowVal : "&nbsp;";
				oCell.align = tblObj.Columns[j].align;
				oCell.vAlign = tblObj.Columns[j].vAlign;
				tblObj.Rows[newRowOrd][j] = newRowVal;
				msg += "tblObj.Rows[" + newRowOrd + "][" + j + "] = " + tblObj.Rows[newRowOrd][j] + "\n"
				
				oRow.appendChild(oCell);
				
				if (tblObj.editBehavior.createMatchingHiddenElements == true)
				{
					oElem = document.createElement("INPUT");
					oElem.type = "hidden";
					oElem.id = tblObj.editBehavior.hiddenElementNamePrefix + tblObj.Columns[j].id + "_" + newRowOrd + tblObj.editBehavior.hiddenElementNameSuffix;
					oElem.value = newRowVal;
					oElem.setAttribute("name", oElem.id, 0);
					oCell.insertAdjacentElement('beforeEnd', oElem);
				}

				break;
		}		
	}
	if (tblObj.editBehavior.allowDelete == true)
	{
		oCell = document.createElement("TD");
		oCell.innerHTML = "&nbsp;";
		oRow.appendChild(oCell);
		oButton = document.createElement("BUTTON");
		oButton.id = tblObj.editBehavior.removeBtn_id_prefix + newRowOrd;
		oButton.innerHTML = tblObj.editBehavior.removeBtn_label;
		oButton.className = tblObj.editBehavior.removeBtn_className;
		oButton.style.cssText = tblObj.editBehavior.removeBtn_styleStr;
		oButton.parentEdiTable = tblObj;
		oButton.onclick = (tblObj.editBehavior.removeBtn_customEvents.onclick != null)? tblObj.editBehavior.removeBtn_customEvents.onclick : function(){ediTable_removeRow(this)};
		oCell.insertAdjacentElement('afterBegin', oButton);
	}
	ediTable_alternateRowColors(tblObj);
	ediTable_updateDebugWindow(tblObj);
	ediTable_clearDataEntryFields(tblObj);
	document.all[tblObj.id + "_new_" + tblObj.Columns[0].id].focus();

	document.all["totNumRows_" + tblObj.id].value = tblObj.Rows.length;

//	alert(msg);
}

function ediTable_removeRow(btnObj)
{
	var oRow = btnObj.parentElement.parentElement;
	var tblObj = btnObj.parentEdiTable;
	var tblName = tblObj.id;
	var oTable = eval(tblName);
	var oTBody = oTable.tBodies[0];

	if(confirm("Really remove this row?"))
	{
		oTBody.deleteRow(oRow.sectionRowIndex);
	}
	ediTable_alternateRowColors(tblObj);
}

function ediTable_validateData(tblObj)
{
	//validation routine goes here
	return true;
}

function ediTable_alternateRowColors(tblObj)
{
	var oTable, oTBody, oRow;
	oTable = eval("" + tblObj.id);
	oTBody = oTable.tBodies[0];

	for (var i = 0; i < oTBody.rows.length; i++)
	{
		if (i % 2)
		{
			oTBody.rows[i].className = (tblObj.rowAltClassName != "") ? tblObj.rowAltClassName : tblObj.rowClassName;
		}
		else
		{
			oTBody.rows[i].className = tblObj.rowClassName;
		}
	}
}


//called when the Calendar icon is clicked
function ediTable_dateWin(field)
{ 
	hwnd = window.open('../../app_include/popup_calendar.asp?f=' + escape(field), 'winCalendar', 'width=150,height=150,toolbar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=0,resizable=0');
	hwnd.focus();
	return true;
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
	//	alert("The date format should be : mm/dd/yyyy")
		return false
	}
	if (strMonth.length<1 || month<1 || month>12){
	//	alert("Please enter a valid month")
		return false
	}
	if (strDay.length<1 || day<1 || day>31 || (month==2 && day>daysInFebruary(year)) || day > daysInMonth[month]){
	//	alert("Please enter a valid day")
		return false
	}
	if (strYear.length != 4 || year==0 || year<minYear || year>maxYear){
	//	alert("Please enter a valid 4 digit year between "+minYear+" and "+maxYear)
		return false
	}
	if (dtStr.indexOf(dtCh,pos2+1)!=-1 || isInteger(stripCharsInBag(dtStr, dtCh))==false){
	//	alert("Please enter a valid date")
		return false
	}
	return true
}

// Check that the number of characters in a string is between a max and a min
function isValidLength(string, min, max) {
	if (string.length < min || string.length > max) return false;
	else return true;
}

// Check that a credit card number is valid based using the LUHN formula (mod10 is 0)
function isValidCreditCard(number) {
	number = '' + number;
	
	if (number.length > 16 || number.length < 13 ) return false;
	else if (getMod10(number) != 0) return false;
	else if (arguments[1]) {
		var type = arguments[1];
		var first2digits = number.substring(0, 2);
		var first4digits = number.substring(0, 4);
		
		if (type.toLowerCase() == 'visa' && number.substring(0, 1) == 4 &&
			(number.length == 16 || number.length == 13 )) return true;
		else if (type.toLowerCase() == 'mastercard' && number.length == 16 &&
			(first2digits == '51' || first2digits == '52' || first2digits == '53' || first2digits == '54' || first2digits == '55')) return true;
		else if (type.toLowerCase() == 'american express' && number.length == 15 && 
			(first2digits == '34' || first2digits == '37')) return true;
		else if (type.toLowerCase() == 'diners club' && number.length == 14 && 
			(first2digits == '30' || first2digits == '36' || first2digits == '38')) return true;
		else if (type.toLowerCase() == 'discover' && number.length == 16 && first4digits == '6011') return true;
		else if (type.toLowerCase() == 'enroute' && number.length == 15 && 
			(first4digits == '2014' || first4digits == '2149')) return true;
		else if (type.toLowerCase() == 'jcb' && number.length == 16 &&
			(first4digits == '3088' || first4digits == '3096' || first4digits == '3112' || first4digits == '3158' || first4digits == '3337' || first4digits == '3528')) return true;
		
    // if the above card types are all the ones that the site accepts, change the line below to 'else return false'
    else return true;
	}
	else return true;
}

// Check that an email address is valid based on RFC 821 (?)
function isValidEmail(address) {
	if (address != '' && address.search) {
      if (address.search(/^\w+((-\w+)|(\.\w+))*\@[A-Za-z0-9]+((\.|-)[A-Za-z0-9]+)*\.[A-Za-z0-9]+$/) != -1) return true;
      else return false;
	}
	
   // allow empty strings to return true - screen these with either a 'required' test or a 'length' test
   else return true;
}

// Check that an email address has the form something@something.something
// This is a stricter standard than RFC 821 (?) which allows addresses like postmaster@localhost
function isValidEmailStrict(address) {
	if (isValidEmail(address) == false) return false;
	var domain = address.substring(address.indexOf('@') + 1);
	if (domain.indexOf('.') == -1) return false;
	if (domain.indexOf('.') == 0 || domain.indexOf('.') == domain.length - 1) return false;
	return true;
}

// Check that a US zip code is valid
function isValidZipcode(zipcode) {
	zipcode = removeSpaces(zipcode);
	if (!(zipcode.length == 5 || zipcode.length == 9 || zipcode.length == 10)) return false;
   if ((zipcode.length == 5 || zipcode.length == 9) && !isNumeric(zipcode)) return false;
   if (zipcode.length == 10 && zipcode.search && zipcode.search(/^\d{5}-\d{4}$/) == -1) return false;
   return true;
}

// Check that a Canadian postal code is valid
function isValidPostalcode(postalcode) {
	if (postalcode.search) {
		postalcode = removeSpaces(postalcode);
		if (postalcode.length == 6 && postalcode.search(/^[a-zA-Z]\d[a-zA-Z]\d[a-zA-Z]\d$/) != -1) return true;
		else if (postalcode.length == 7 && postalcode.search(/^[a-zA-Z]\d[a-zA-Z]-\d[a-zA-Z]\d$/) != -1) return true;
		else return false;
	}
	return true;
}

// Check that a US or Canadian phone number is valid
function isValidUSPhoneNumber(areaCode, prefixNumber, suffixNumber) {
   if (arguments.length == 1) {
      var phoneNumber = arguments[0];
      phoneNumber = phoneNumber.replace(/\D+/g, '');
      var length = phoneNumber.length;
      if (phoneNumber.length >= 7) {
         var areaCode = phoneNumber.substring(0, length-7);
         var prefixNumber = phoneNumber.substring(length-7, length-4);
         var suffixNumber = phoneNumber.substring(length-4);
      }
      else return false;
   }
   else if (arguments.length == 3) {
      var areaCode = arguments[0];
      var prefixNumber = arguments[1];
      var suffixNumber = arguments[2];
   }
   else return true;

   if (areaCode.length != 3 || !isNumeric(areaCode) || prefixNumber.length != 3 || !isNumeric(prefixNumber) || suffixNumber.length != 4 || !isNumeric(suffixNumber)) return false;
   return true;
}

// Check that a string contains only letters and numbers
function isAlphanumeric(string, ignoreWhiteSpace) {
	if (string.search) {
		if ((ignoreWhiteSpace && string.search(/[^\w\s]/) != -1) || (!ignoreWhiteSpace && string.search(/\W/) != -1)) return false;
	}
	return true;
}

// Check that a string contains only letters
function isAlphabetic(string, ignoreWhiteSpace) {
	if (string.search) {
		if ((ignoreWhiteSpace && string.search(/[^a-zA-Z\s]/) != -1) || (!ignoreWhiteSpace && string.search(/[^a-zA-Z]/) != -1)) return false;
	}
	return true;
}

// Check that a string contains only numbers
function isNumeric(string, ignoreWhiteSpace) {
	if (string.search) {
		if ((ignoreWhiteSpace && string.search(/[^\d\s]/) != -1) || (!ignoreWhiteSpace && string.search(/\D/) != -1)) return false;
	}
	return true;
}

// Remove characters that might cause security problems from a string 
function removeBadCharacters(string) {
	if (string.replace) {
		string.replace(/[<>\"\'%;\)\(&\+]/, '');
	}
	return string;
}

// Remove all spaces from a string
function removeSpaces(string) {
	var newString = '';
	for (var i = 0; i < string.length; i++) {
		if (string.charAt(i) != ' ') newString += string.charAt(i);
	}
	return newString;
}

// Remove leading and trailing whitespace from a string
function trimWhitespace(string) {
	var newString  = '';
	var substring  = '';
	beginningFound = false;
	
	// copy characters over to a new string
	// retain whitespace characters if they are between other characters
	for (var i = 0; i < string.length; i++) {
		
		// copy non-whitespace characters
		if (string.charAt(i) != ' ' && string.charCodeAt(i) != 9) {
			
			// if the temporary string contains some whitespace characters, copy them first
			if (substring != '') {
				newString += substring;
				substring = '';
			}
			newString += string.charAt(i);
			if (beginningFound == false) beginningFound = true;
		}
		
		// hold whitespace characters in a temporary string if they follow a non-whitespace character
		else if (beginningFound == true) substring += string.charAt(i);
	}
	return newString;
}

// Returns a checksum digit for a number using mod 10
function getMod10(number) {
	
	// convert number to a string and check that it contains only digits
	// return -1 for illegal input
	number = '' + number;
	number = removeSpaces(number);
	if (!isNumeric(number)) return -1;
	
	// calculate checksum using mod10
	var checksum = 0;
	for (var i = number.length - 1; i >= 0; i--) {
		var isOdd = ((number.length - i) % 2 != 0) ? true : false;
		digit = number.charAt(i);
		
		if (isOdd) checksum += parseInt(digit);
		else {
			var evenDigit = parseInt(digit) * 2;
			if (evenDigit >= 10) checksum += 1 + (evenDigit - 10);
			else checksum += evenDigit;
		}
	}
	return (checksum % 10);
}
