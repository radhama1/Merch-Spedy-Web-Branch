
/*
rule_details.js
scripts for rule_details.asp
*/

function MM_preloadImages() { //v3.0
  var d=document; if(d.images){ if(!d.MM_p) d.MM_p=new Array();
    var i,j=d.MM_p.length,a=MM_preloadImages.arguments; for(i=0; i<a.length; i++)
    if (a[i].indexOf("#")!=0){ d.MM_p[j]=new Image; d.MM_p[j++].src=a[i];}}
}

function MM_swapImgRestore() { //v3.0
  var i,x,a=document.MM_sr; for(i=0;a&&i<a.length&&(x=a[i])&&x.oSrc;i++) x.src=x.oSrc;
}

function MM_findObj(n, d) { //v4.01
  var p,i,x;  if(!d) d=document; if((p=n.indexOf("?"))>0&&parent.frames.length) {
    d=parent.frames[n.substring(p+1)].document; n=n.substring(0,p);}
  if(!(x=d[n])&&d.all) x=d.all[n]; for (i=0;!x&&i<d.forms.length;i++) x=d.forms[i][n];
  for(i=0;!x&&d.layers&&i<d.layers.length;i++) x=MM_findObj(n,d.layers[i].document);
  if(!x && d.getElementById) x=d.getElementById(n); return x;
}

function MM_swapImage() { //v3.0
  var i,j=0,x,a=MM_swapImage.arguments; document.MM_sr=new Array; for(i=0;i<(a.length-2);i+=3)
   if ((x=MM_findObj(a[i]))!=null){document.MM_sr[j++]=x; if(!x.oSrc) x.oSrc=x.src; x.src=a[i+2];}
}

var isMac = (navigator.appVersion.indexOf("Mac")!=-1) ? true : false;

function initTabs(thisTabName)
{
	clearMenus();
	switch (thisTabName)
	{
		case "descriptionTab":
			rule_description.style.display = "";
			break;
	}
}

function clickMenu(tabName)
{
	clearMenus();

	switch (tabName)
	{
		case "descriptionTab":
			rule_description.style.display = "";
			break;
		
		default:
			clearMenus();
			break;
	}
}

function clearMenus()
{
	rule_description.style.display = "none";
}
		
//called when the Calendar icon is clicked
function dateWin(field)
{ 
	hwnd = window.open('../../app_include/popup_calendar.asp?f=' + escape(field), 'winCalendar', 'width=150,height=150,toolbar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=0,resizable=0');
	hwnd.focus();
}

function isInteger(s){
	var i;
	if(s == null || s.toString() == '') return false;
	for (i = 0; i < s.length; i++){   
		// Check that current character is number.
		var c = s.charAt(i);
		if (((c < "0") || (c > "9"))) return false;
	}
	// All characters are numbers.
	return true;
}

function isInt(s) {
    var i = parseInt(s);
    if(!isNaN(i))
        return true;
    else
        return false;
}

function validateForm()
{
	
    var msg = '';
    var success = true;
    
    // check Rule Name (Validation_Rule)
	if (document.theForm.Validation_Rule.value == "")
	{
		parent.frames['header'].clickMenu("descriptionTab");
		if(document.getElementById("ValidationRuleWarningImg")) document.getElementById("ValidationRuleWarningImg").src = "./../images/alert_icon_small.gif";
		success=false;if(msg!='')msg+='\n';msg+="You did not specify a rule name."
	}
	else
	    if(document.getElementById("ValidationRuleWarningImg"))document.getElementById("ValidationRuleWarningImg").src = "./../images/spacer.gif";
	
	// check Field (Metadata_Column_ID)
	if (document.theForm.Metadata_Column_ID.selectedIndex <= 0)
	{
		parent.frames['header'].clickMenu("descriptionTab");
		if(document.getElementById("MetadataColumnIDWarningImg")) document.getElementById("MetadataColumnIDWarningImg").src = "./../images/alert_icon_small.gif";
		success=false;if(msg!='')msg+='\n';msg+="You did not select a field."
	}
	else
	    if(document.getElementById("MetadataColumnIDWarningImg"))document.getElementById("MetadataColumnIDWarningImg").src = "./../images/spacer.gif";
	
	// validate rule...
	Rule.validate();
	success = success && Rule.isValid;
	if(!Rule.isValid){
	    if(msg!='')msg+='\n';msg+=Rule.getErrorMessage();
	}
	
	if(!success){
	    alert(msg);
	} else {
	    Rule.serialize();
	    //alert($('ruleXML').value);
	    document.theForm.submit();
	}
}



//--------------------------------------------------//
//--------------------------------------------------//
//--------------------------------------------------//
//--------------------------------------------------//
//--------------------------------------------------//

function parseList2(list)
{
    var returnarr = [];
    var arr = list.split(',');
    var idx;
    for(var i = 0; i < arr.length - 1; i+= 2){
        idx = returnarr.length;
        returnarr[idx] = [];
        returnarr[idx][0] = arr[i];
        returnarr[idx][1] = arr[i + 1];
    }
    return returnarr;
}

function buildOptions(arr2, selectedValue) 
{
    if(selectedValue == null) selectedValue = '';
    var o, options = [];
    for(var i = 0; i < arr2.length; i++){
        if(arr2[i].length >= 2){
            o = new Option(arr2[i][1], arr2[i][0]);
            if(selectedValue != '' && selectedValue == arr2[i][0]) o.selected = true;
            options[options.length] = o;
        }
    }
    return options;
}

function buildSelect(id, arr2, selectFirst, selectedValue)
{
    if(selectFirst == null || !selectFirst) selectFirst = false;
    if(selectedValue == null) selectedValue = '';
    var o , options;
    for(var i = 0; i < arr2.length; i++){
        if(arr2[i].length >= 2){
            o = '<option value="' + arr2[i][0] + '"'
            if(selectedValue != '' && selectedValue == arr2[i][0]) o += ' selected="selected"';
            o += '>' + arr2[i][1] + '</option>';
            options += o;
        }
    }
    var select = '<select id="' + id + '">' + ((selectFirst) ? '<option value="">--Select--</option>' : '') + options + '</select>';
    return select;
}

function setupSelect(id, arr2, selectFirst, selectedValue)
{
    if(selectFirst == null || !selectFirst) selectFirst = false;
    if(selectedValue == null) selectedValue = '';
    var s = $(id);
    if(s && s.options){
        s.options.length = 0;
        if(selectFirst)s.options[0] = new Option('--Select--', '');
        var o;
        for(var i = 0; i < arr2.length; i++){
            if(arr2[i].length >= 2){
                o = new Option(arr2[i][1], arr2[i][0]);
                if(selectedValue != '' && selectedValue == arr2[i][0]) o.selected = true;
                s.options[s.options.length] = o;
            }
        }
    }
}

function getValue(id)
{
    var o = $(id);
    if(o) return o.value; else return '';
}

function setValue(id, value)
{
    var o = $(id);
    if(o) o.value = value;
}

function getSelectValue(id)
{
    var o = $(id);
    if(o) return o.options[o.selectedIndex].value; else return '';
}

function setSelectValue(id, value)
{
    var o = $(id);
    if(o){
        for(var i = 0; i < o.options.length; i++){
            if(o.options[i].value == value){
                o.selectedIndex = i;
                break;
            }
        }
    }
}

function fieldChanged()
{
    var rule = $('Validation_Rule'), cols = $('Metadata_Column_ID');
    if(rule && cols) {
        if(rule.value == '' && cols.selectedIndex > 0) {
            rule.value = cols.options[cols.selectedIndex].text;
        }
    }
}

function initPage()
{
    // init
}

function scrollToBottomOfPage()
{
    setTimeout("window.scrollTo(0, " + getDocumentHeight() + ");", 100);
}

function getDocumentHeight() {
    return Math.max(
        Math.max(document.body.scrollHeight, document.documentElement.scrollHeight),
        Math.max(document.body.offsetHeight, document.documentElement.offsetHeight),
        Math.max(document.body.clientHeight, document.documentElement.clientHeight)
    );
}

//--------------------------------------------------//
//--------------------------------------------------//
//--------------------------------------------------//
//--------------------------------------------------//
//--------------------------------------------------//

var SETNUMBER = 0;
var hightlightColor = '#91bf76';
var hightlightDuration = 0.8;
var hightlightDurationLong = 1.3;
var errors = $H(
    {
        Required: 'is a required field.',
        Valid: 'is not valid.',
        Range: 'must be between {VALUE 1} and {VALUE 1}.'
    }
);

var isNew = true;

var setupMode = false;

var fields = [];
var parentFields = [];
var stages = [];
var ruleTypes = [];
var severityTypes = [];
var conditionTypes = [];
var operators = parseList2(',,<=,<=,<,<,=,=,!=,!=,>,>,>=,>=,CONTAINS,Contains,!CONTAINS,!Contains,LIKE,Like');
var operatorsNumOnly = parseList2(',,<=,<=,<,<,=,=,!=,!=,>,>,>=,>=');
var oCSet, oC;

//--------------------------------------------------//
//--------------------------------------------------//
// Rule
//--------------------------------------------------//
//--------------------------------------------------//
var Rule = {
    id: 0,
    
    nextid: 1,
    
    nextcid: 1,
    
    conditionSets: [],
    
    isValid: true,
    
    ruleErrorMsg: '',
    
    addConditionSet: function(id, type) {
		
        id = (id == null) ? this.nextid : id;
        type = (type == null) ? 0 : type;
		this.nextid = id + 1;
		
        var pos = this.conditionSets.length + 1;
        this.conditionSets[this.conditionSets.length] = new ConditionSet(id, type, pos);
		
        if(!setupMode && pos > 1) {
            scrollToBottomOfPage();
        }
		
        // sortable 
        Sortable.create('condition_sets', { tag: 'fieldset', handle: 'handle', onUpdate: function() {Rule.reorderConditionSets();} });
        // return
		
        return this.conditionSets[this.conditionSets.length - 1];
    },
    
    getConditionSetCount: function() {
        return this.conditionSets.length;
    },
    
    deleteConditionSet: function(id) {
        for(var i = 0; i < this.conditionSets.length; i++){
            if(this.conditionSets[i].id == id){
                if(confirm('Delete Condition Set #' + this.conditionSets[i].ordinal.toString() + '?')){
                    this.conditionSets[i].deleteConditionSet();
                    this.conditionSets[i] = null;
                    this.conditionSets.splice(i, 1);
                    this.renumberConditionSets();
                    break;
                }
            }
        }
    },
    
    renumberConditionSets: function() {
        for(var i = 0; i < this.conditionSets.length; i++){
            this.conditionSets[i].setOrdinal(i+1);
        }
    },
    
    reorderConditionSets: function() {
        var newsets = [];
        var o, i, j, id;
        var arr = $('condition_sets').select('fieldset');
        for(i = 0; i < arr.length; i++){
            id = arr[i].id;
            id = id.replace(/ /g, '').replace('condition_set_', '');
            for(j = 0; j < this.conditionSets.length; j++){
                if(this.conditionSets[j].id.toString() == id){
                    newsets[newsets.length] = this.conditionSets[j];
                    break;
                }
            }
        }
        if(newsets.length > 0){
            this.conditionSets.length = 0;
            this.conditionSets = newsets;
            for(i = 0; i < this.conditionSets.length; i++){
                if(i == 0){
                    if($('condition_set_delete_'+this.conditionSets[i].id)) $('condition_set_delete_'+this.conditionSets[i].id).hide();
                } else {
                    if($('condition_set_delete_'+this.conditionSets[i].id)) $('condition_set_delete_'+this.conditionSets[i].id).show();
                }
            }
            this.renumberConditionSets();
        }
    },
    
    ruleTypeChanged: function(id) {
        for(var i = 0; i < this.conditionSets.length; i++){
            if(this.conditionSets[i].id == id){
                this.conditionSets[i].ruleTypeChanged();
            }
        }
    },
    
    severityChanged: function(id) {
        for(var i = 0; i < this.conditionSets.length; i++){
            if(this.conditionSets[i].id == id){
                this.conditionSets[i].severityChanged();
            }
        }
    },
    
    errorTextChanged: function(id) {
        for(var i = 0; i < this.conditionSets.length; i++){
            if(this.conditionSets[i].id == id){
                this.conditionSets[i].errorTextChanged();
            }
        }
    },
    
    stagesChanged: function(id) {
        for(var i = 0; i < this.conditionSets.length; i++){
            if(this.conditionSets[i].id == id){
                this.conditionSets[i].stagesChanged();
            }
        }
    },
    
    selectAllStages: function(id) {
        for(var i = 0; i < this.conditionSets.length; i++){
            if(this.conditionSets[i].id == id){
                this.conditionSets[i].selectAllStages();
            }
        }
    },
    
    addCondition: function(id, cid, type) {
        for(var i = 0; i < this.conditionSets.length; i++){
            if(this.conditionSets[i].id == id){
                return this.conditionSets[i].addCondition(cid, type);
            }
        }
        return null;
    },
    
    deleteCondition: function(id, cid) {
        for(var i = 0; i < this.conditionSets.length; i++){
            if(this.conditionSets[i].id == id){
                this.conditionSets[i].deleteCondition(cid);
            }
        }
    },
    
    conditionChanged: function(id, cid) {
        for(var i = 0; i < this.conditionSets.length; i++){
            if(this.conditionSets[i].id == id){
                this.conditionSets[i].conditionChanged(cid);
            }
        }
    },
    
    clearErrorMessage: function() {
        this.ruleErrorMsg = '';
    },
    
    getErrorMessage: function() {
        return this.ruleErrorMsg;
    },
    
    addErrorMessage: function(msg) {
        if(this.ruleErrorMsg != '') this.ruleErrorMsg += '\n';
        this.ruleErrorMsg += msg;
    },
    
    validate: function() {
        var valid = true, ret;
        this.clearErrorMessage();
        if(this.conditionSets.length < 1) {
            this.addErrorMessage('You must have at least one condition set.');
            valid = false;
        } else {
            for(var i = 0; i < this.conditionSets.length; i++) {
                ret = this.conditionSets[i].validate();
                valid = valid && ret;
            }
        }
        this.isValid = valid;
        return valid;
    },
    
    serialize: function() {
        var xml = '<rule id="' + this.id + '">\n';
        xml += '<conditionsets>\n';
        for(var i = 0; i < this.conditionSets.length; i++){
            xml += this.conditionSets[i].serialize();
        }
        xml += '</conditionsets>\n';
        xml += '</rule>';
		document.getElementById("ruleXML").value = xml;
        //$('ruleXML').value = xml;
    }
};

//--------------------------------------------------//
//--------------------------------------------------//
// ConditionSet
//--------------------------------------------------//
//--------------------------------------------------//
function ConditionSet(id, type, ordinal)
{
    this.id = id;
    this.type = type;
    this.ordinal = ordinal;
    this.conditions = [];
    this.errorText = '';
    this.severity = 1;
    this.stages = [];
    // condition ids
    this.nextid = 1;
    // init
    this.initialize();
}
ConditionSet.prototype.initialize = function() {

    var h = $('condition_set_template').innerHTML;
    h = h.replace(/SETPOSITION/g, this.ordinal.toString());
    h = h.replace(/SETNUMBER/g, this.id.toString());
	
    // add condition set
    //$('condition_sets').innerHTML += h;
	$('condition_sets').insert(h);
	
	
    // setup new condition set
    this.setupRuleTypes();
    this.setupSeverityTypes();
    this.setupStages();
    this.setupAddCondition();
    // show new condition set
    if(this.ordinal > 1){
        $('condition_set_' + this.id.toString()).show();
        if(!setupMode) new Effect.Highlight('condition_set_' + this.id.toString(), { startcolor: hightlightColor, endcolor: '#cccccc', duration: hightlightDuration });
    } else {
        $('condition_set_delete_' + this.id).hide();
        $('condition_set_' + this.id.toString()).show();
    }
}
ConditionSet.prototype.setOrdinal = function(ordinal) {
    this.ordinal = ordinal;
    var num = $('condition_set_position_' + this.id.toString()).innerText;
    $('condition_set_position_' + this.id.toString()).innerText = this.ordinal;
    if(num != this.ordinal.toString()){
        if(!setupMode) new Effect.Highlight('condition_set_legend_' + this.id.toString(), { startcolor: hightlightColor, endcolor: '#cccccc', duration: hightlightDurationLong });
    }
}
ConditionSet.prototype.setupRuleTypes = function()
{
    setupSelect('rule_type_'+this.id.toString(), ruleTypes, false, this.type.toString());
    this.ruleTypeChanged();
}
ConditionSet.prototype.ruleTypeChanged = function()
{
    var rt = $('rule_type_' + this.id.toString());
    var val = rt.options[rt.selectedIndex].value;
    this.type = val;
    var etc = $('error_text_control_' + this.id.toString());
    var et = $('error_text_' + this.id.toString());
    var ets = $('error_text_string_' + this.id.toString());
    if(val == '2')
        { et.value = ''; this.errorTextChanged(); etc.hide(); ets.innerText = errors.get('Required'); ets.show(); }
    else if(val == '3')
        { et.value = ''; this.errorTextChanged(); etc.hide(); ets.innerText = errors.get('Valid'); ets.show(); }
    else if(val == '4')
        { et.value = ''; this.errorTextChanged(); etc.hide(); ets.innerText = errors.get('Range'); ets.show(); }
    else // val == '1'
        { etc.show(); ets.hide(); ets.innerText = ''; } 
}
ConditionSet.prototype.setErrorText = function(value)
{
    var et = $('error_text_' + this.id.toString());
    et.value = value;
    this.errorText = value;
}
ConditionSet.prototype.errorTextChanged = function()
{
    var et = $('error_text_' + this.id.toString());
    this.errorText = et.value;
}
ConditionSet.prototype.setupSeverityTypes = function()
{
    setupSelect('severity_'+this.id.toString(), severityTypes, false, this.severity.toString());
    this.severityChanged();
}
ConditionSet.prototype.setSeverity = function(value)
{
    setSelectValue('severity_' + this.id.toString(), value);
    this.severity = value;
}
ConditionSet.prototype.severityChanged = function()
{
    var s = $('severity_' + this.id.toString());
    var val = s.options[s.selectedIndex].value;
    this.severity = val;
}
ConditionSet.prototype.stagesChanged = function()
{
    var s = '#stages_' + this.id.toString() + ' input';
    var arr = $$(s);
    this.stages.length = 0;
    for(var i = 0; i < arr.length; i++){
        if(arr[i].checked == true){
            this.addStage(arr[i].value);
        }
    }
}
ConditionSet.prototype.selectAllStages = function()
{
    var s = '#stages_' + this.id.toString() + ' input';
    var arr = $$(s);
    this.stages.length = 0;
    for(var i = 0; i < arr.length; i++){
        this.addStage(arr[i].value, true);
    }
}
ConditionSet.prototype.addStage = function(stageid, addOnForm) {
    if(addOnForm == null || !addOnForm) addOnForm = false;
    this.stages[this.stages.length] = parseInt(stageid);
    if(addOnForm){
        var s = '#stages_' + this.id.toString() + ' input';
        var arr = $$(s);
        for(var i = 0; i < arr.length; i++){
            if(arr[i].value == stageid.toString()){
                arr[i].checked = true;
            }
        }
    }
}
ConditionSet.prototype.addStages = function(stageids) {
    var arr = stageids.split(',');
    for(var i = 0; i < arr.length; i++){
        this.addStage(arr[i]);
    }
}
ConditionSet.prototype.setupStages = function()
{
    var s = $('stages_'+this.id.toString());
    var id, h = '';
    if(s){
        for(var i = 0; i < stages.length; i++){
            id = 'stage_' + this.id.toString();
            h += '<input type="checkbox" id="' + id + '" value="' + stages[i][0] + '" onclick="Rule.stagesChanged(' + this.id.toString() + ');" /> ' + stages[i][1] + '<br />';
        }
        s.innerHTML = h;
    }
}
ConditionSet.prototype.deleteConditionSet = function() {
    // delete the conditions
    for(var i = (this.conditions.length - 1); i >= 0; i--){
        this.conditions[i] = null;
    }
    this.conditions.length = 0;
    // remove condition set HTML
    $('condition_set_' + this.id.toString()).remove();
}
ConditionSet.prototype.setupAddCondition = function() {
    setupSelect('add_condition_type_'+this.id.toString(), conditionTypes, true, '');
}
ConditionSet.prototype.addCondition = function(id, type) {
    
    id = (id == null) ? this.nextid : id;
    type = (type == null) ? 0 : type;
    if(type == 0){
        var s = $('add_condition_type_'+this.id.toString());
        if(s.selectedIndex <= 0){
            alert('Please select the type of condition to add.');
            return null;
        } else {
            type = parseInt(s.options[s.selectedIndex].value);
        }
    }
    this.nextid = id + 1;
    var pos = this.conditions.length + 1;
    this.conditions[this.conditions.length] = new Condition(this.id, id, type, pos);
    if((pos) <= 1){
        $('conditions_string_' + this.id.toString()).hide();
    } else {
        this.conditions[pos-2].enableConjunction(true);
    }
    return this.conditions[this.conditions.length - 1];
}
ConditionSet.prototype.deleteCondition = function(id) {
    for(var i = 0; i < this.conditions.length; i++){
        if(this.conditions[i].id == id){
            if(confirm('Delete Condition #' + this.conditions[i].ordinal.toString() + ' from Condition Set #' + this.ordinal.toString() + '?')){
                this.conditions[i].deleteCondition();
                this.conditions[i] = null;
                this.conditions.splice(i, 1);
                this.renumberConditions();
                if(this.conditions.length <= 0){
                    $('conditions_string_'+this.id.toString()).show();
                } else {
                    this.conditions[this.conditions.length-1].enableConjunction(false);
                }
                break;
            }
        }
    }
}
ConditionSet.prototype.renumberConditions = function() {
    for(var i = 0; i < this.conditions.length; i++){
        this.conditions[i].setOrdinal(i+1);
    }
}
ConditionSet.prototype.conditionChanged = function(id) {
    for(var i = 0; i < this.conditions.length; i++){
        if(this.conditions[i].id == id){
            this.conditions[i].conditionChanged();
        }
    }
}
ConditionSet.prototype.validate = function() {
    var valid = true, ret;
    var found, conditionError = false;
    var i;
    // type
    if(this.type.toString() == '1' && this.errorText.replace(/ /g, '') == ''){
        Rule.addErrorMessage('Condition Set #' + this.ordinal.toString() + ': Error Text is required.');
        valid = false;
    }
    if(this.conditions.length < 1) {
        Rule.addErrorMessage('Condition Set #' + this.ordinal.toString() + ': Please add at least one condition.');
        valid = false;
    } else if(this.type.toString() == '2') {
        found = false;
        for(i = 0; i < this.conditions.length; i++){
            if(this.conditions[i].type.toString() == '5' || this.conditions[i].type.toString() == '21' || this.conditions[i].type.toString() == '30'){
                found = true;
                break;
            }
        }
        if(!found){
            Rule.addErrorMessage('Condition Set #' + this.ordinal.toString() + ': Please add either an "Empty", "Empty (After Removing)", or "Required Field" condition for condition set type, "Required Field".');
            valid = false;
            conditionError = true;
        }
    } else if(this.type.toString() == '4') {
        found = false;
        for(i = 0; i < this.conditions.length; i++){
            if(this.conditions[i].type.toString() == '20'){
                found = true;
                break;
            }
        }
        if(!found){
            Rule.addErrorMessage('Condition Set #' + this.ordinal.toString() + ': Please add a "Range" condition for condition set type, "Valid Range".');
            valid = false;
            conditionError = true;
        }
    }
    // conditions
    if(this.conditions.length >= 1) {
        for(i = 0; i < this.conditions.length; i++){
            ret = this.conditions[i].validate(this.ordinal);
            valid = valid && ret;
        }
    }
    var img = $('Set' + this.id.toString() + 'WarningImg');
    if(img) img.src = (valid) ? './../images/spacer.gif' : './../images/alert_icon_small.gif';
    return valid;
}
ConditionSet.prototype.serialize = function() {
    var i;
    var xml = '<conditionset id="' + this.id + '" type="' + this.type + '" severity="' + this.severity + '">\n';
    xml += '<errortext><![CDATA[' + this.errorText + ']]></errortext>\n';
    xml += '<stages>';
    for(i = 0; i < this.stages.length; i++){
        if(i > 0) xml += ",";
        xml += this.stages[i];
    }
    xml += '</stages>\n';
    xml += '<conditions>\n';
    for(i = 0; i < this.conditions.length; i++){
        xml += this.conditions[i].serialize();
    }
    xml += '</conditions>\n';
    xml += '</conditionset>\n';
    return xml;
}

//--------------------------------------------------//
//--------------------------------------------------//
// Condition
//--------------------------------------------------//
//--------------------------------------------------//
function Condition(setid, id, type, ordinal)
{
    this.setid = setid;
    this.id = (id != null) ? id : 0;
    this.type = (type != null) ? type : 0;
    this.ordinal = (ordinal != null) ? ordinal : 0;
    this.field1 = 0;
    this.field2 = 0;
    this.field3 = 0;
    this.value1 = '';
    this.value2 = '';
    this.value3 = '';
    this.operator = '';
    this.conjunction = 'AND';
    // init
    this.initialize();
}
Condition.prototype.initialize = function() {
    // init
    var h = '';
    var newid = 'condition_' + this.setid.toString() + '_' + this.id.toString();
    // create condition
    h = this.createCondition();
    // add condition
    //$('conditions_' + this.setid.toString()).innerHTML += h;
	$('conditions_' + this.setid.toString()).insert(h);
    // setup new condition
    this.setupCondition();
    // show new condition
    $(newid).show();
    if(!setupMode) new Effect.Highlight(newid, { startcolor: hightlightColor, endcolor: '#cccccc', duration: hightlightDuration });
}
Condition.prototype.setOrdinal = function(ordinal) {
    this.ordinal = ordinal;
    var ids = this.setid.toString() + '_' + this.id.toString();
    var num = $('condition_position_' + ids).innerText;
    $('condition_position_' + ids).innerText = this.ordinal;
    if(num != this.ordinal.toString()){
        if(!setupMode) new Effect.Highlight('condition_position_' + ids, { startcolor: hightlightColor, endcolor: '#cccccc', duration: hightlightDurationLong });
    }
}
Condition.prototype.createCondition = function() {
    var ids = this.setid.toString() + '_' + this.id.toString();
    var onchange = 'onchange="Rule.conditionChanged(' + this.setid.toString() + ', ' + this.id.toString() + ');"';
    var newid = 'condition_' + ids;
    // begin wrapper
    var h = '' + 
        '<div id="' + newid + '" class="condition" style="display: none;">' + 
        '<table border="0" cellpadding="1" cellspacing="0" width="100%" style="width: 100%">' + 
        '<tr>';
    // cell for ordinal
    h += '<td width="20" align="right" style="border-right: 1px solid #aaaaaa;" valign="top"><span id="condition_position_' + ids + '" class="conditionNum">' + this.ordinal.toString() + '</span></td>';
    // cell for controls
    h += '<td width="*" style="padding-left: 3px;">' + 
        '<input type="hidden" id="condition_type_' + ids + '" value="' + this.type.toString() + '" />';
    switch(this.type){
        case 1:
            // Alphabetic
            h += 'if <select id="condition_field1_' + ids + '" ' + onchange + '></select> is not <strong>Alphabetic</strong>';
            break;
        case 2:
            // Alphanumeric
            h += 'if <select id="condition_field1_' + ids + '" ' + onchange + '></select> is not <strong>Alphanumeric</strong>';
            break;
        case 3:
            // Divisible by (Field/Field)
            h += 'if <select id="condition_field1_' + ids + '" ' + onchange + '></select> is not <strong>Divisible by</strong> ' + 
                '<select id="condition_field2_' + ids + '" ' + onchange + '></select>';
            break;
        case 4:
            // Divisible by (Field/#)
            h += 'if <select id="condition_field1_' + ids + '" ' + onchange + '></select> is not <strong>Divisible by</strong> ' + 
                '<input type="text" id="condition_value1_' + ids + '" size="15" maxlength="255" ' + onchange + ' />';
            break;
        case 5:
            // Empty
            h += 'if <select id="condition_field1_' + ids + '" ' + onchange + '></select> is <strong>Empty</strong>';
            break;
        case 6:
            // Not Empty
            h += 'if <select id="condition_field1_' + ids + '" ' + onchange + '></select> is <strong>Not Empty</strong>';
            break;
        case 7:
            // General (Field/Field)
            h += '<select id="condition_field1_' + ids + '" ' + onchange + '></select> ' + 
                '<select id="condition_operator_' + ids + '" ' + onchange + '></select> ' + 
                '<select id="condition_field2_' + ids + '" ' + onchange + '></select>';
            break;
        case 8:
            // General (Field/value)
            h += '<select id="condition_field1_' + ids + '" ' + onchange + '></select> ' + 
                '<select id="condition_operator_' + ids + '" ' + onchange + '></select> ' + 
                '<input type="text" id="condition_value1_' + ids + '" size="15" maxlength="255" ' + onchange + ' />';
            break;
        case 9:
            // Length
            h += 'if <strong>Length</strong> of <select id="condition_field1_' + ids + '" ' + onchange + '></select> ' + 
                '<select id="condition_operator_' + ids + '" ' + onchange + '></select> ' + 
                '<input type="text" id="condition_value1_' + ids + '" size="15" maxlength="255" ' + onchange + ' />';
            break;
        case 10:
            // Lookup - Batch Departments
            h += 'if <strong>Lookup - Batch Departments</strong> fails';
            break;
        case 11:
            // Lookup - Batch Vendors
            h += 'if <strong>Lookup - Batch Vendors</strong> fails';
            break;
        case 12:
            // Lookup - UPC Validation*
            h += 'if <strong>Lookup - UPC Validation*</strong> fails';
            break;
        case 13:
            // Lookup - Valid Class
            h += 'if <strong>Lookup - Valid Class</strong> fails';
            break;
        case 14:
            // Lookup - Valid Country of Origin
            h += 'if <strong>Lookup - Valid Country of Origin</strong> fails';
            break;
        case 15:
            // Lookup - Valid Department
            h += 'if <strong>Lookup - Valid Department</strong> fails';
            break;
        case 16:
            // Lookup - Valid Sub-Class
            h += 'if <strong>Lookup - Valid Sub-Class</strong> fails';
            break;
        case 17:
            // Lookup - Valid Tax Value UDA
            h += 'if <strong>Lookup - Valid Tax Value UDA</strong> fails';
            break;
        case 18:
            // Lookup - Valid Vendor # (US)
            h += 'if <strong>Lookup - Valid Vendor # (US)</strong> fails';
            break;
        case 19:
            // Lookup - Valid Vendor # (Canadian)
            h += 'if <strong>Lookup - Valid Vendor # (Canadian)</strong> fails';
            break;
        case 20:
            // Range
            h += 'if <select id="condition_field1_' + ids + '" ' + onchange + '></select> ' + 
                ' not in <strong>Range</strong>: <br />' + 
                '<input type="text" id="condition_value1_' + ids + '" size="15" maxlength="255" ' + onchange + ' />' + 
                ' - ' + 
                '<input type="text" id="condition_value2_' + ids + '" size="15" maxlength="255" ' + onchange + ' />';
            break;
        case 21:
            // Required Field
            h += '<strong>Required Field</strong>: <select id="condition_field1_' + ids + '" ' + onchange + '></select>';
            break;
        case 22:
            // Valid Characters
            h += 'if <select id="condition_field1_' + ids + '" ' + onchange + '></select> ' + 
                ' does not have only <strong>Valid Characters</strong>: ' + 
                '<input type="text" id="condition_value1_' + ids + '" size="15" maxlength="255" ' + onchange + ' />';
            break;
        case 23:
            // Invalid Characters
            h += 'if <select id="condition_field1_' + ids + '" ' + onchange + '></select> ' + 
                ' has <strong>Invalid Characters</strong>: ' + 
                '<input type="text" id="condition_value1_' + ids + '" size="15" maxlength="255" ' + onchange + ' />';
            break;
        case 24:
            // Valid Field (type)
            h += 'if <select id="condition_field1_' + ids + '" ' + onchange + '></select> ' + 
                ' does not have a <strong>Valid Field</strong> value ';
            break;
        case 25:
            // Valid UPC
            h += 'if <select id="condition_field1_' + ids + '" ' + onchange + '></select> ' + 
                ' is not a <strong>Valid UPC</strong> ';
            break;
        case 26:
            // Value In
            h += 'if <select id="condition_field1_' + ids + '" ' + onchange + '></select> ' + 
                ' has <strong>Value In</strong>: ' + 
                '<input type="text" id="condition_value1_' + ids + '" size="15" maxlength="255" ' + onchange + ' />';
            break;
        case 27:
            // Value Not In
            h += 'if <select id="condition_field1_' + ids + '" ' + onchange + '></select> ' + 
                ' has <strong>Value Not In</strong>: ' + 
                '<input type="text" id="condition_value1_' + ids + '" size="15" maxlength="255" ' + onchange + ' />';
            break;
        case 28:
            // * End Validation *
            h += '<strong>End Validation</strong> if this is the only condition or if condition set fails.';
            break;
        case 29:
            // Lookup - Valid Vendor #
            h += 'if <strong>Lookup - Valid Vendor #</strong> fails';
            break;
        case 30:
            // Empty (After Removing)
            h += 'if <select id="condition_field1_' + ids + '" ' + onchange + '></select> ' + 
                ' is <strong>Empty</strong> after removing ' + 
                '<input type="text" id="condition_value1_' + ids + '" size="15" maxlength="255" ' + onchange + ' />';
            break;
        case 31:
            // Lookup - Batch D/DP Validation
            h += 'if <strong>Lookup - Batch D/DP Validation*</strong> fails';
            break;
        case 32:
            // Changes - General (Original Field/Value)
            h += 'Changes: Original Field <select id="condition_field1_' + ids + '" ' + onchange + '></select> ' + 
                '<select id="condition_operator_' + ids + '" ' + onchange + '></select> ' + 
                '<input type="text" id="condition_value1_' + ids + '" size="15" maxlength="255" ' + onchange + ' />';
            break;
        case 33:
            // Changes - General (Changed Field/Value)
            h += 'Changes: Changed Field <select id="condition_field1_' + ids + '" ' + onchange + '></select> ' + 
                '<select id="condition_operator_' + ids + '" ' + onchange + '></select> ' + 
                '<input type="text" id="condition_value1_' + ids + '" size="15" maxlength="255" ' + onchange + ' />';
            break;
        case 34:
            // Lookup - Pack Item Validation
            h += 'if <strong>Lookup - Pack Item Validation*</strong> fails';
            break;
        case 35:
            // Lookup - Seasonal Allocations
            h += 'if <strong>Lookup - Seasonal Allocations</strong> fails';
            break;
        case 36:
            // Lookup - Valid PO Date Range
             h += 'if <select id="condition_field1_' + ids + '" ' + onchange + '></select> ' + 
                ' is not in a <strong>Valid Date Range</strong> ';
            break;
		case 37:
            // Lookup - Valid PO SKu Store Loc.
            h += 'if <strong>Lookup - Valid PO SKu Store Loc.</strong> fails';
            break;
        case 38:
            // Lookup - Is Deleted
             h += 'if <select id="condition_field1_' + ids + '" ' + onchange + '></select> ' + 
                ' is <strong>DELETED</strong> ';
            break; 
        case 39:
            // Lookup - PO SKU (Field) does not match Item SKU
             h += 'if <select id="condition_field1_' + ids + '" ' + onchange + '></select> ' + 
                ' does not match Item SKU data ';
            break;
        case 40:
            // Lookup - PO Valid Ordered Quantity
            h += 'if <strong>Lookup - PO Valid Ordered Quantity</strong> fails';
            break;
        case 41:
            // Lookup - PO Must Order At Least One Item Per Location
            h += 'if <strong>Lookup - PO Location Ordered SKUs</strong> fails';
            break;
		case 42:
            // Lookup - Translation Descriptions must match
            h += 'if <strong>Lookup - Translation Descriptions must match</strong> fails';
            break;
		case 43:
            // Is Date
             h += '<strong>Is Date</strong>: <select id="condition_field1_' + ids + '" ' + onchange + '></select>';
            break;
		case 44:
			//Is Future Date
			  h += 'if <select id="condition_field1_' + ids + '" ' + onchange + '></select> is not more than ' + 
                '<input type="text" id="condition_value1_' + ids + '" size="15" maxlength="255" ' + onchange + ' /> days <strong> in the Future</strong>';
			break;
		case 45:
			//Lookup - Batch Type
			h+= 'if SKU is also in a different batch.';
			break;	
		case 46:
			//Lookup - Agent or Vendor
			h += 'if <strong> Lookup - Merch Burden or Vendor </strong> does not match supplier';
			break;
        case 47:
            //Lookup - Lookup - Valid Stocking Strategy Status
            h += 'if <strong> Lookup - Valid Stocking Strategy Status </strong> fails';
            break;
        case 48:
            //Lookup - Lookup - Valid Stocking Strategy Type
            h += 'if <strong> Lookup - Valid Stocking Strategy Type </strong> fails';
            break;
        case 49:
            //Lookup - Lookup - Inner Weight Eaches Compare Valid
            h += 'if <strong> Lookup - Inner Weight Eaches Compare </strong> fails';
            break;
        case 50:
            //Lookup - Lookup - Master Weight Eaches Compare Valid
            h += 'if <strong> Lookup - Master Weight Eaches Compare </strong> fails';
            break;
        case 51:
            //Lookup - Lookup - Inner Case Weight X Eaches Master Case / Eaches Inner Pack
            h += 'if <strong> Lookup - Master Weight Inner Eaches Ratio </strong> fails';
            break;
        //case 52:
        //    //Lookup - Lookup - Inner Case Weight X Eaches Master Case / Eaches Inner Pack
        //    h += 'if <strong> Lookup - Valid GTIN </strong> fails';
        //    break;
        default:
            h += 'ERROR: Tried to create a condition of an unknown type (' + this.type + ').';
            break;
    }
    h += '</td>';
    // cell for conjunction
    var andor = '<select id="condition_conjunction_' + ids + '" ' + onchange + ' disabled="disabled"><option value="AND">AND</option><option value="OR">OR</option></select>'; 
    h += '<td width="70" align="center" valign="middle" style="width:70px;">' + andor + '</td>'; 
    // cell for delete
    h += '<td width="25" align="right" valign="middle" style="width: 25px; padding-right: 2px;"><a id="condition_delete_' + ids + '" href="#" onclick="Rule.deleteCondition(' + this.setid.toString() + ', ' + this.id.toString() + '); return false;"><img src="./../images/action_x.gif" border="0" alt="" /></a></td>'; 
    // close
    h += '</tr>' + 
        '</table>' + 
        '</div>';
    // return
    return h;
}
Condition.prototype.setupCondition = function() {
    var ids = this.setid.toString() + '_' + this.id.toString();
    if($('condition_field1_'+ids)) setupSelect('condition_field1_'+ids, parentFields, true, '');
    if($('condition_field2_'+ids)) setupSelect('condition_field2_'+ids, parentFields, true, '');
    if($('condition_field3_'+ids)) setupSelect('condition_field3_'+ids, parentFields, true, '');
    if($('condition_operator_'+ids)){
        if(this.type == 9){
            // length
            setupSelect('condition_operator_'+ids, operatorsNumOnly, false, '');
        } else {
            // other
            setupSelect('condition_operator_'+ids, operators, false, '');
        }
    }
}
Condition.prototype.enableConjunction = function(enable) {
    enable = (enable == null || !enable) ? false : true;
    var ids = this.setid.toString() + '_' + this.id.toString();
    $('condition_conjunction_' + ids).disabled = !enable;
}
Condition.prototype.deleteCondition = function() {
    var ids = this.setid.toString() + '_' + this.id.toString();
    // remove condition set HTML
    $('condition_' + ids).remove();
}
Condition.prototype.setField1 = function(value) {
    var ids = this.setid.toString() + '_' + this.id.toString();
    if(value.toString() != '' && parseInt(value) > 0){
        this.field1 = parseInt(value);
        if($('condition_field1_'+ids)) setSelectValue('condition_field1_'+ids, this.field1.toString());
    } else {
        this.field1 = 0;
        if($('condition_field1_'+ids)) setSelectValue('condition_field1_'+ids, '');
    }
}
Condition.prototype.setField2 = function(value) {
    var ids = this.setid.toString() + '_' + this.id.toString();
    if(value.toString() != '' && parseInt(value) > 0){
        this.field2 = parseInt(value);
        if($('condition_field2_'+ids)) setSelectValue('condition_field2_'+ids, this.field2.toString());
    } else {
        this.field2 = 0;
        if($('condition_field2_'+ids)) setSelectValue('condition_field2_'+ids, '');
    }
}
Condition.prototype.setField3 = function(value) {
    var ids = this.setid.toString() + '_' + this.id.toString();
    if(value.toString() != '' && parseInt(value) > 0){
        this.field3 = parseInt(value);
        if($('condition_field3_'+ids)) setSelectValue('condition_field3_'+ids, this.field3.toString());
    } else {
        this.field3 = 0;
        if($('condition_field3_'+ids)) setSelectValue('condition_field3_'+ids, '');
    }
}
Condition.prototype.setValue1 = function(value) {
    var ids = this.setid.toString() + '_' + this.id.toString();
    this.value1 = value.toString();
    if($('condition_value1_'+ids)) setValue('condition_value1_'+ids, this.value1);
}
Condition.prototype.setValue2 = function(value) {
    var ids = this.setid.toString() + '_' + this.id.toString();
    this.value2 = value.toString();
    if($('condition_value2_'+ids)) setValue('condition_value2_'+ids, this.value2);
}
Condition.prototype.setValue3 = function(value) {
    var ids = this.setid.toString() + '_' + this.id.toString();
    this.value3 = value.toString();
    if($('condition_value3_'+ids)) setValue('condition_value3_'+ids, this.value3);
}
Condition.prototype.setOperator = function(value) {
    var ids = this.setid.toString() + '_' + this.id.toString();
    this.operator = value.toString();
    if($('condition_operator_'+ids)) setSelectValue('condition_operator_'+ids, this.operator);
}
Condition.prototype.setConjunction = function(value) {
    var ids = this.setid.toString() + '_' + this.id.toString();
    this.conjunction = value.toString();
    if($('condition_conjunction_'+ids)) setSelectValue('condition_conjunction_'+ids, this.conjunction);
}
Condition.prototype.conditionChanged = function() {
    var ids = this.setid.toString() + '_' + this.id.toString();
    if($('condition_field1_'+ids)) this.field1 = getSelectValue('condition_field1_'+ids);
    if($('condition_field2_'+ids)) this.field2 = getSelectValue('condition_field2_'+ids);
    if($('condition_field3_'+ids)) this.field3 = getSelectValue('condition_field3_'+ids);
    if($('condition_value1_'+ids)) this.value1 = getValue('condition_value1_'+ids);
    if($('condition_value2_'+ids)) this.value2 = getValue('condition_value2_'+ids);
    if($('condition_value3_'+ids)) this.value3 = getValue('condition_value3_'+ids);
    if($('condition_operator_'+ids)) this.operator = getSelectValue('condition_operator_'+ids);
    if($('condition_conjunction_'+ids)) this.conjunction = getSelectValue('condition_conjunction_'+ids);
}
Condition.prototype.validate = function(setordinal) {
    var valid = true;
    var errorStart = 'Condition Set #' + setordinal.toString() + ' - Condition #' + this.ordinal.toString() + ': ';
    var err = '';
    var n = 0;
    // validate based on condition type
    switch(this.type){
        case 1:
            // Alphabetic
            //h += 'if <select id="condition_field1_' + ids + '" ' + onchange + '></select> is not <strong>Alphabetic</strong>';
            if(this.field1.toString() == '' || this.field1.toString() == '0'){
                Rule.addErrorMessage(errorStart + 'Please select a field.');
                valid = false;
            }
            break;
        case 2:
            // Alphanumeric
            //h += 'if <select id="condition_field1_' + ids + '" ' + onchange + '></select> is not <strong>Alphanumeric</strong>';
            if(this.field1.toString() == '' || this.field1.toString() == '0'){
                Rule.addErrorMessage(errorStart + 'Please select a field.');
                valid = false;
            }
            break;
        case 3:
            // Divisible by (Field/Field)
            //h += 'if <select id="condition_field1_' + ids + '" ' + onchange + '></select> is not <strong>Divisible by</strong> ' + 
            //    '<select id="condition_field2_' + ids + '" ' + onchange + '></select>';
            if(this.field1.toString() == '' || this.field1.toString() == '0'){
                err = 'Please select the 1st field.';
                valid = false;
            }
            if(this.field2.toString() == '' || this.field2.toString() == '0'){
                if(err == '') err = 'Please select the 2nd field.'; else err = 'Please select the 1st and 2nd fields.';
                valid = false;
            }
            if(!valid) Rule.addErrorMessage(errorStart + err);
            break;
        case 4:
            // Divisible by (Field/#)
            //h += 'if <select id="condition_field1_' + ids + '" ' + onchange + '></select> is not <strong>Divisible by</strong> ' + 
            //    '<input type="text" id="condition_value1_' + ids + '" size="15" maxlength="255" ' + onchange + ' />';
            if(this.field1.toString() == '' || this.field1.toString() == '0'){
                err = 'Please select a field.';
                valid = false;
            }
            if(this.value1.toString() == ''){
                if(err == '') err = 'Please enter a value.'; else err = 'Please select a field and enter a value';
                valid = false;
            }
            if(!valid) Rule.addErrorMessage(errorStart + err);
            break;
        case 5:
            // Empty
            //h += 'if <select id="condition_field1_' + ids + '" ' + onchange + '></select> is <strong>Empty</strong>';
            if(this.field1.toString() == '' || this.field1.toString() == '0'){
                Rule.addErrorMessage(errorStart + 'Please select a field.');
                valid = false;
            }
            break;
        case 6:
            // Not Empty
            //h += 'if <select id="condition_field1_' + ids + '" ' + onchange + '></select> is <strong>Not Empty</strong>';
            if(this.field1.toString() == '' || this.field1.toString() == '0'){
                Rule.addErrorMessage(errorStart + 'Please select a field.');
                valid = false;
            }
            break;
        case 7:
            // General (Field/Field)
            //h += '<select id="condition_field1_' + ids + '" ' + onchange + '></select> ' + 
            //    '<select id="condition_operator_' + ids + '" ' + onchange + '></select> ' + 
            //    '<select id="condition_field2_' + ids + '" ' + onchange + '></select>';
            if(this.field1.toString() == '' || this.field1.toString() == '0'){
                //err = 'Please select the 1st field';
                n += 1;
                valid = false;
            }
            if(this.operator.toString() == ''){
                //err = 'Please select the operator.';
                n += 2;
                valid = false;
            }
            if(this.field2.toString() == '' || this.field2.toString() == '0'){
                //err = 'Please select the 2nd field.';
                n += 4;
                valid = false;
            }
            if(!valid) {
                if(n == 1) err = 'Please select the 1st field.';
                else if(n == 2) err = 'Please select the operator.';
                else if(n == 3) err = 'Please select the 1st field and the operator.';
                else if(n == 5) err = 'Please select the 1st field and the 2nd field.';
                else if(n == 6) err = 'Please select the operator and the 2nd field.';
                else if(n == 7) err = 'Please select the 1st field, the operator, and the 2nd field.';
                Rule.addErrorMessage(errorStart + err);
            }
            break;
        case 8:
            // General (Field/value)
            //h += '<select id="condition_field1_' + ids + '" ' + onchange + '></select> ' + 
            //    '<select id="condition_operator_' + ids + '" ' + onchange + '></select> ' + 
            //    '<input type="text" id="condition_value1_' + ids + '" size="15" maxlength="255" ' + onchange + ' />';
            if(this.field1.toString() == '' || this.field1.toString() == '0'){
                //Rule.addErrorMessage(errorStart + 'Please select a field.');
                err += 1;
                valid = false;
            }
            if(this.operator.toString() == ''){
                //Rule.addErrorMessage(errorStart + 'Please select the operator.');
                n += 2;
                valid = false;
            }
            /*
            if(this.value1.toString() == ''){
                //Rule.addErrorMessage(errorStart + 'Please enter a value.');
                n += 4;
                valid = false;
            }
            */
            if(!valid) {
                if(n == 1) err = 'Please select the 1st field.';
                else if(n == 2) err = 'Please select the operator.';
                else if(n == 3) err = 'Please select the 1st field and the operator.';
                Rule.addErrorMessage(errorStart + err);
            }
            break;
        case 9:
            // Length
            //h += 'if <strong>Length</strong> of <select id="condition_field1_' + ids + '" ' + onchange + '></select> ' + 
            //    '<select id="condition_operator_' + ids + '" ' + onchange + '></select> ' + 
            //    '<input type="text" id="condition_value1_' + ids + '" size="15" maxlength="255" ' + onchange + ' />';
            if(this.field1.toString() == '' || this.field1.toString() == '0'){
                //Rule.addErrorMessage(errorStart + 'Please select a field.');
                n += 1;
                valid = false;
            }
            if(this.operator.toString() == ''){
                //Rule.addErrorMessage(errorStart + 'Please select the operator.');
                n += 2;
                valid = false;
            }
            if(this.value1.toString() == ''){
                //Rule.addErrorMessage(errorStart + 'Please enter a value.');
                n += 4;
                valid = false;
            }
            if(!valid) {
                if(n == 1) err = 'Please select a field.';
                else if(n == 2) err = 'Please select the operator.';
                else if(n == 3) err = 'Please select a field and the operator.';
                else if(n == 5) err = 'Please select a field and enter a value.';
                else if(n == 6) err = 'Please select the operator and enter a value.';
                else if(n == 7) err = 'Please select a field, select the operator, and enter a value.';
                Rule.addErrorMessage(errorStart + err);
            }
            break;
        case 10:
            // Lookup - Batch Departments
            break;
        case 11:
            // Lookup - Batch Vendors
            break;
        case 12:
            // Lookup - UPC Validation*
            break;
        case 13:
            // Lookup - Valid Class
            break;
        case 14:
            // Lookup - Valid Country of Origin
            break;
        case 15:
            // Lookup - Valid Department
            break;
        case 16:
            // Lookup - Valid Sub-Class
            break;
        case 17:
            // Lookup - Valid Tax Value UDA
            break;
        case 18:
            // Lookup - Valid Vendor # (US)
            break;
        case 19:
            // Lookup - Valid Vendor # (Canadian)
            break;
        case 20:
            // Range
            //h += 'if <select id="condition_field1_' + ids + '" ' + onchange + '></select> ' + 
            //    ' not in <strong>Range</strong>: <br />' + 
            //    '<input type="text" id="condition_value1_' + ids + '" size="15" maxlength="255" ' + onchange + ' />' + 
            //    ' - ' + 
            //    '<input type="text" id="condition_value2_' + ids + '" size="15" maxlength="255" ' + onchange + ' />';
            if(this.field1.toString() == '' || this.field1.toString() == '0'){
                //Rule.addErrorMessage(errorStart + 'Please select a field.');
                n += 1;
                valid = false;
            }
            if(this.value1.toString() == ''){
                //Rule.addErrorMessage(errorStart + 'Please enter the 1st value.');
                n += 2;
                valid = false;
            }
            if(this.value2.toString() == ''){
                //Rule.addErrorMessage(errorStart + 'Please enter the 2nd value.');
                n += 4;
                valid = false;
            }
            if(!valid) {
                if(n == 1) err = 'Please select a field.';
                else if(n == 2) err = 'Please enter the 1st value';
                else if(n == 3) err = 'Please select a field and enter the 1st value.';
                else if(n == 5) err = 'Please select a field and enter the 2nd value.';
                else if(n == 6) err = 'Please enter the 1st and 2nd values.';
                else if(n == 7) err = 'Please select a field, enter the 1st value, and enter the 2nd value.';
                Rule.addErrorMessage(errorStart + err);
            }
            break;
        case 21:
            // Required Field
            //h += '<strong>Required Field</strong>: <select id="condition_field1_' + ids + '" ' + onchange + '></select>';
            if(this.field1.toString() == '' || this.field1.toString() == '0'){
                Rule.addErrorMessage(errorStart + 'Please select a field.');
                valid = false;
            }
            break;
        case 22:
            // Valid Characters
            //h += 'if <select id="condition_field1_' + ids + '" ' + onchange + '></select> ' + 
            //    ' does not have only <strong>Valid Characters</strong>: ' + 
            //    '<input type="text" id="condition_value1_' + ids + '" size="15" maxlength="255" ' + onchange + ' />';
            if(this.field1.toString() == '' || this.field1.toString() == '0'){
                err = 'Please select a field.';
                valid = false;
            }
            if(this.value1.toString() == ''){
                if(err == '') err = 'Please enter a value.'; else err = 'Please select a field and enter a value.';
                valid = false;
            }
            if(!valid) {
                Rule.addErrorMessage(errorStart + err);
            }
            break;
        case 23:
            // Invalid Characters
            //h += 'if <select id="condition_field1_' + ids + '" ' + onchange + '></select> ' + 
            //    ' has <strong>Invalid Characters</strong>: ' + 
            //    '<input type="text" id="condition_value1_' + ids + '" size="15" maxlength="255" ' + onchange + ' />';
            if(this.field1.toString() == '' || this.field1.toString() == '0'){
                err = 'Please select a field.';
                valid = false;
            }
            if(this.value1.toString() == ''){
                if(err == '') err = 'Please enter a value.'; else err = 'Please select a field and enter a value.';
                valid = false;
            }
            if(!valid) {
                Rule.addErrorMessage(errorStart + err);
            }
            break;
        case 24:
            // Valid Field (type
            //h += 'if <select id="condition_field1_' + ids + '" ' + onchange + '></select> ' + 
            //    ' does not have a <strong>Valid Field</strong> value ';
            if(this.field1.toString() == '' || this.field1.toString() == '0'){
                Rule.addErrorMessage(errorStart + 'Please select a field.');
                valid = false;
            }
            break;
        case 25:
            // Valid UPC
            //h += 'if <select id="condition_field1_' + ids + '" ' + onchange + '></select> ' + 
            //    ' is not a <strong>Valid UPC</strong> ';
            if(this.field1.toString() == '' || this.field1.toString() == '0'){
                Rule.addErrorMessage(errorStart + 'Please select a field.');
                valid = false;
            }
            break;
        case 26:
            // Value In
            //h += 'if <select id="condition_field1_' + ids + '" ' + onchange + '></select> ' + 
            //    ' has <strong>Value In</strong>: ' + 
            //    '<input type="text" id="condition_value1_' + ids + '" size="15" maxlength="255" ' + onchange + ' />';
            if(this.field1.toString() == '' || this.field1.toString() == '0'){
                err = 'Please select a field.';
                valid = false;
            }
            if(this.value1.toString() == ''){
                if(err == '') err = 'Please enter a value.'; else err = 'Please select a field and enter a value.';
                valid = false;
            }
            if(!valid) {
                Rule.addErrorMessage(errorStart + err);
            }
            break;
        case 27:
            // Value Not In
            //h += 'if <select id="condition_field1_' + ids + '" ' + onchange + '></select> ' + 
            //    ' has <strong>Value Not In</strong>: ' + 
            //    '<input type="text" id="condition_value1_' + ids + '" size="15" maxlength="255" ' + onchange + ' />';
            if(this.field1.toString() == '' || this.field1.toString() == '0'){
                err = 'Please select a field.';
                valid = false;
            }
            if(this.value1.toString() == ''){
                if(err == '') err = 'Please enter a value.'; else err = 'Please select a field and enter a value.';
                valid = false;
            }
            if(!valid) {
                Rule.addErrorMessage(errorStart + err);
            }
            break;
        case 28:
            // * End Validation *
            break;
        case 29:
            // Lookup - Valid Vendor #
            break;
        case 30:
            // Empty (After Removing)
            //h += 'if <select id="condition_field1_' + ids + '" ' + onchange + '></select> ' + 
            //    ' is <strong>Empty</strong> after removing ' + 
            //    '<input type="text" id="condition_value1_' + ids + '" size="15" maxlength="255" ' + onchange + ' />';
            if(this.field1.toString() == '' || this.field1.toString() == '0'){
                err = 'Please select a field.';
                valid = false;
            }
            if(this.value1.toString() == ''){
                if(err == '') err = 'Please enter a value.'; else err = 'Please select a field and enter a value.';
                valid = false;
            }
            if(!valid) {
                Rule.addErrorMessage(errorStart + err);
            }
            break;
        case 31:
            // Lookup - Batch D/DP Validation
            break;
        case 32:
            // Changes - General (Original Field/Value)
            //h += '<select id="condition_field1_' + ids + '" ' + onchange + '></select> ' + 
            //    '<select id="condition_operator_' + ids + '" ' + onchange + '></select> ' + 
            //    '<input type="text" id="condition_value1_' + ids + '" size="15" maxlength="255" ' + onchange + ' />';
            if(this.field1.toString() == '' || this.field1.toString() == '0'){
                //Rule.addErrorMessage(errorStart + 'Please select a field.');
                err += 1;
                valid = false;
            }
            if(this.operator.toString() == ''){
                //Rule.addErrorMessage(errorStart + 'Please select the operator.');
                n += 2;
                valid = false;
            }
            /*
            if(this.value1.toString() == ''){
                //Rule.addErrorMessage(errorStart + 'Please enter a value.');
                n += 4;
                valid = false;
            }
            */
            if(!valid) {
                if(n == 1) err = 'Please select the 1st field.';
                else if(n == 2) err = 'Please select the operator.';
                else if(n == 3) err = 'Please select the 1st field and the operator.';
                Rule.addErrorMessage(errorStart + err);
            }
            break;
        case 33:
            // Changes - General (Changed Field/Value)
            //h += '<select id="condition_field1_' + ids + '" ' + onchange + '></select> ' + 
            //    '<select id="condition_operator_' + ids + '" ' + onchange + '></select> ' + 
            //    '<input type="text" id="condition_value1_' + ids + '" size="15" maxlength="255" ' + onchange + ' />';
            if(this.field1.toString() == '' || this.field1.toString() == '0'){
                //Rule.addErrorMessage(errorStart + 'Please select a field.');
                err += 1;
                valid = false;
            }
            if(this.operator.toString() == ''){
                //Rule.addErrorMessage(errorStart + 'Please select the operator.');
                n += 2;
                valid = false;
            }
            /*
            if(this.value1.toString() == ''){
                //Rule.addErrorMessage(errorStart + 'Please enter a value.');
                n += 4;
                valid = false;
            }
            */
            if(!valid) {
                if(n == 1) err = 'Please select the 1st field.';
                else if(n == 2) err = 'Please select the operator.';
                else if(n == 3) err = 'Please select the 1st field and the operator.';
                Rule.addErrorMessage(errorStart + err);
            }
            break;
        case 34:
            // Lookup - Pack Item Validation
            break;
        case 35:
            // Lookup - Seasonal Allocations
            break;
       	case 36:
            // Lookup - Valid PO Date Range
            if(this.field1.toString() == '' || this.field1.toString() == '0'){
                Rule.addErrorMessage(errorStart + 'Please select a field.');
                valid = false;
            }
            break;
		case 37:
            // Lookup - Valid PO SKU Store Loc.
            break;
        case 38:
            // Lookup - Is DELETED
            if(this.field1.toString() == '' || this.field1.toString() == '0'){
                Rule.addErrorMessage(errorStart + 'Please select a field.');
                valid = false;
            }
            break;
		case 39:
			// Lookup - PO SKU (Field) does not match Item SKU
			if(this.field1.toString() == '' || this.field1.toString() == '0'){
				Rule.addErrorMessage(errorStart + 'Please select a field.');
				valid = false;
			}
			break;  	
		case 40:
			// Lookup - PO Valid Ordered Qty
			break;
		case 41:
			// Lookup - PO Must Order At Least One Item Per Location
			break;
		case 42:
			// Lookup - Translation Desc. must match
			break;
		case 43:
			// Is Date
			//h += '<strong>Is Date</strong>: <select id="condition_field1_' + ids + '" ' + onchange + '></select>';
			if(this.field1.toString() == '' || this.field1.toString() == '0'){
				Rule.addErrorMessage(errorStart + 'Please select a field.');
				valid = false;
			}
			break;
		case 44:
			// Is Future Date
			//h += 'if <select id="condition_field1_' + ids + '" ' + onchange + '></select> is not more than ' + 
			//    '<input type="text" id="condition_value1_' + ids + '" size="15" maxlength="255" ' + onchange + ' /> days <strong>in the Future</strong>' ;
			if(this.field1.toString() == '' || this.field1.toString() == '0'){
				err = 'Please select a field.';
				valid = false;
			}
			if(this.value1.toString() == ''){
				if(err == '') err = 'Please enter a whole number value.'; else err = 'Please select a field and enter a whole number value';
				valid = false;
			}
			if(!valid) {
				Rule.addErrorMessage(errorStart + err);
			}
			break;
		case 45:
			// Lookup - Batch Type
			break;			
		case 46:
			//Lookup - Agent or Vendor
		    break;
        case 47:
            //Lookup - Valid Stocking Strategy Status
            break;
        case 48:
            //Lookup - Valid Stocking Strategy Type
            break;
        case 49:
            //Lookup - Lookup - Inner Weight Eaches Compare Valid
            break;
        case 50:
            //Lookup - Lookup - Master Weight Eaches Compare Valid
            break;
        case 51:
            //Lookup - Lookup - Inner Case Weight X Eaches Master Case / Eaches Inner Pack
            break;
        //case 52:
        //    //Lookup - valid GTIN
        //    break;

		default:
			Rule.addErrorMessage(errorStart + 'This is a condition of an unknown type (' + this.type + ').');
			valid = false;
			break;
		
    }
    return valid;
}
Condition.prototype.serialize = function() {
    var i;
    var xml = '<condition id="' + this.id + '" type="' + this.type + '">\n';
    xml += '<field1>' + this.field1 + '</field1>\n';
    xml += '<field2>' + this.field2 + '</field2>\n';
    xml += '<field3>' + this.field3 + '</field3>\n';
    xml += '<value1><![CDATA[' + this.value1 + ']]></value1>\n';
    xml += '<value2><![CDATA[' + this.value2 + ']]></value2>\n';
    xml += '<value3><![CDATA[' + this.value3 + ']]></value3>\n';
    xml += '<operator><![CDATA[' + this.operator + ']]></operator>\n';
    xml += '<conjunction>' + this.conjunction + '</conjunction>\n';
    xml += '</condition>\n';
    return xml;
}

