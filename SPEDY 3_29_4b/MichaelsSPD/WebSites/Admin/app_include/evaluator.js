/*********************************************************************
   Danny Goodman's evaluator.js JavaScript Debugging Library
   Copyright 2001 Danny Goodman (www.dannyg.com). All Rights Reserved.
   Excerpted from "JavaScript Bible" 4th Edition.
   
   v.2.0   First Public Release
   
   An embeddable evaluation control panel that lets you
   examine values, list object properties and values,
   and experiment with expression evaluation within
   the context of the page.
   
   Link the library into your page with the following tag
   set in the HEAD portion of your document:
   
   <SCRIPT LANGUAGE="JavaScript" SRC="evaluator.js"></SCRIPT>
   
   Then bring the evaluator into the rendered page by adding
   the following to the very bottom of your HTML document:
   
   <SCRIPT LANGUAGE="JavaScript">
   printEvaluator()
   </SCRIPT>
   
   To experiment with expression evaluation, use the
   26 global variables (a through z) to preserve values
   from one statement evaluation to the next. Globals
   retain their values until you reload the page.
   
***********************************************************************/

//======================================================================
// doIt - basic evaluator function.  Evaluates the text in the "ev_input" 
// field and puts it in the "ev_output field"
//======================================================================
function doIt(form){
	form.ev_output.value = eval(form.ev_input.value)
}

//======================================================================
// showProps - shows properties of object specified in the ev_inspector
// field and puts it in the ev_output field
//======================================================================
function showProps(form) {
	objName = form.ev_inspector.value
	obj = eval(objName)
	var msg = ""
	var count = 0
	for (var i in obj) {
		msg += objName + "." + i + "=" + obj[i] + "\n"
	}
	form.ev_output.value = msg
}

//======================================================================
// evalIfReady - checks to see if user hit carriage-return and then
// does evaluation
//======================================================================
function evalIfReady(form, evt) {
	evt = (evt) ? evt : (window.event) ? window.event : ""
	if (evt) {
		var theKey = (evt.which) ? evt.which : evt.keyCode
		if (theKey == 13) {
			doIt(form)
			return false	
		}
	}
	return true
}

//======================================================================
// showPropsIfReady - checks to see if user hit carriage return and
// if so calls showProps
//======================================================================
function showPropsIfReady(form, evt) {
	evt = (evt) ? evt : (window.event) ? window.event : ""
	if (evt) {
		var theKey = (evt.which) ? evt.which : evt.keyCode
		if (theKey == 13) {
			showProps(form)
			return false	
		}
	}
	return true
}

//======================================================================
// walkChildNodes - creates a visual node map of all nodes in the 
// document (IE5+ and NN6+ only)
//======================================================================
function walkChildNodes(objRef, n) {
	var obj
	if (objRef) {
		if (typeof objRef == "string") {
			obj = document.getElementById(objRef)
		} else {
			obj = objRef
		}
	} else {
		obj = (document.body.parentElement) ? 
			document.body.parentElement : document.body.parentNode
	}
	var output = ""
	var indent = ""
	var i, group, txt
	if (n) {
		for (i = 0; i < n; i++) {
			indent += "+---"
		}
	} else {
		n = 0
		output += "Child Nodes of <" + obj.tagName 
		output += ">\n=====================\n"
	}
	group = obj.childNodes
	for (i = 0; i < group.length; i++) {
		output += indent
		switch (group[i].nodeType) {
			case 1:
				output += "<" + group[i].tagName
				output += (group[i].id) ? " ID=" + group[i].id : ""
				output += (group[i].name) ? " NAME=" + group[i].name : ""
				output += ">\n"
				break
			case 3:
				txt = group[i].nodeValue.substr(0,15)
				output += "[Text:\"" + txt.replace(/[\r\n]/g,"<cr>")
				if (group[i].nodeValue.length > 15) {
					output += "..."
				}
				output += "\"]\n"
				break
			case 8:
				output += "[!COMMENT!]\n"
				break
			default:
				output += "[Node Type = " + group[i].nodeType + "]\n"
		}
		if (group[i].childNodes.length > 0) {
			output += walkChildNodes(group[i], n+1)
		}
	}
	return output
}

//======================================================================
// walkChildren - creates a visual map of all elements in the 
// document except (IE4+ only)
//======================================================================
function walkChildren(objRef, n) {
	var obj
	if (objRef) {
		if (typeof objRef == "string") {
			obj = document.getElementById(objRef)
		} else {
			obj = objRef
		}
	} else {
		obj = document.body.parentElement
	}
	var output = ""
	var indent = ""
	var i, group
	if (n) {
		for (i = 0; i < n; i++) {
			indent += "+---"
		}
	} else {
		n = 0
		output += "Children of <" + obj.tagName
		output += ">\n=====================\n"
	}
	group = obj.children
	for (i = 0; i < group.length; i++) {
		output += indent + "<" + group[i].tagName
		output += (group[i].id) ? " ID=" + group[i].id : ""
		output += (group[i].name) ? " NAME=" + group[i].name : ""
		output += ">\n"
		if (group[i].children.length > 0) {
			output += walkChildren(group[i], n+1)
		}
	}
	return output
}

//======================================================================
// trace - outputs a label and value for each invocation of the function;
// useful for tracing repetitive statements
//======================================================================
function trace(flag, label, value) {
	if (flag) {
		var msg = ""
   		if (trace.caller) {
			var funcName = trace.caller.toString()
			funcName = funcName.substring(9, funcName.indexOf(")") + 1)
			msg += "In " + funcName + ": "
		}
		msg += label + "=" + value + "\n"
		document.forms["ev_evaluator"].ev_output.value += msg
	}
}

//======================================================================
// printHTML - outputs evaluator form to current document
//======================================================================
function printEvaluator() {
	document.write('<HR SIZE=5>')
	document.writeln('<FORM NAME="ev_evaluator">')
	document.writeln('<P>Enter an expression to evaluate:<BR>')
	document.writeln('<INPUT TYPE="text" NAME="ev_input" SIZE=80 ')
	document.writeln('onKeyPress="return evalIfReady(this.form, event)">')
	document.writeln('<INPUT TYPE="button" VALUE="Evaluate" onClick="doIt(this.form)">&nbsp;')
	document.writeln('</P>')
	document.writeln('<P>')
	document.writeln('Results:<BR>')
	document.writeln('<TEXTAREA NAME="ev_output" COLS="80" ROWS="6" WRAP="virtual" READONLY></TEXTAREA>')
	document.writeln('</P>')
	document.writeln('<P>')
	document.writeln('Enter a reference to an object:<BR>')
	document.writeln('<INPUT TYPE="text" NAME="ev_inspector" SIZE=80 ')
	document.writeln('onKeyPress="return showPropsIfReady(this.form, event)">')
	document.writeln('<INPUT TYPE="button" VALUE="List Properties" onClick="showProps(this.form)"><BR>')
	document.writeln('</FORM>')
}
