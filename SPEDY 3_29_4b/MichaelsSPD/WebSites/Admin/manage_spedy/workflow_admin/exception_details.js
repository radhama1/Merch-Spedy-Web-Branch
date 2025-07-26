
var COMMA_ENCODE = "{{COMMA}}";

function onDeptChanged()
{
	var oDept = $('Dept');
	var url;
	saveSelectValue('Dept');
	/*
	if (oDept.selectedIndex > 0) {
		clearSelect('Class', true);
		clearSelect('Sub_Class', true);
		$('Class_ProcessingImg').src = processing_Img.src;
		url = 'lookup_classes.asp?dept=' + escape(oDept.options[oDept.selectedIndex].value);
		new Ajax.Request(url, {
			method: 'get',
			onSuccess: function(transport) {
				loadSelect('Class', transport.responseText);
				$('Class_ProcessingImg').src = spacer_Img.src;
			},
			onFailure: function(transport) {
				alert('ERROR: Class lookup failed !');
				$('Class_ProcessingImg').src = spacer_Img.src;
			}
		});
	} else {
		
		clearSelect('Class', true);
		clearSelect('Sub_Class', true);
	}
	*/
}

function onClassChanged()
{
	var oDept = $('Dept');
	var oClass = $('Class');
	var url;
	saveSelectValue('Class');
	
	if (oClass.selectedIndex > 0) {
		clearSelect('Sub_Class', true);
		$('Sub_Class_ProcessingImg').src = processing_Img.src;
		url = 'lookup_subclasses.asp?dept=' + escape(oDept.options[oDept.selectedIndex].value) + '&class=' + escape(oClass.options[oClass.selectedIndex].value);
		new Ajax.Request(url, {
			method: 'get',
			onSuccess: function(transport) {
				loadSelect('Sub_Class', transport.responseText);
				$('Sub_Class_ProcessingImg').src = spacer_Img.src;
			},
			onFailure: function(transport) {
				alert('ERROR: Sub-Class lookup failed !');
				$('Sub_Class_ProcessingImg').src = spacer_Img.src;
			}
		});
	} else {
		
		clearSelect('Sub_Class', true);
	}
	
}

function onSubClassChanged()
{
	saveSelectValue('Sub_Class');
}

function loadSelect(selectID, valueString)
{
	var o = $(selectID);
	var arr, i;
	clearSelect(selectID, false);
	if(o){
		arr = valueString.split(',');
		for(i = 0; i < arr.length - 2; i += 2){
			addOption(o, arr[i], arr[i+1].replace(/{{COMMA}}/g, ','));
		}
		o.disabled = false;
		o.selectedIndex = 0;
	}
}
function saveSelectValue(selectID)
{
	var o = $(selectID);
	if(o){
		if($(selectID + '_Value')) $(selectID + '_Value').value = o.options[o.selectedIndex].value;
	}
}
function clearSelect(selectID, disable)
{
	if(!disable || disable == null) disable = false;
	var o = $(selectID);
	if(o){
		if($(selectID + '_Value')) $(selectID + '_Value').value = '';
		removeOptions(o, true);
		o.selectedIndex = 0;
		if(disable) o.disabled = true;
	}
}
function removeOptions(element, leaveFirst)
{
	var i;
	if(!leaveFirst || leaveFirst == null) leaveFirst = false;
	var bottom = (leaveFirst) ? 1 : 0;
	for(i = element.options.length - 1; i >= bottom; i--){
		element.remove(i);
	}
}
function addOption(element, value, text)
{
	var o = document.createElement("OPTION");
	o.text = text;
	o.value = value;
	element.options.add(o);
}
