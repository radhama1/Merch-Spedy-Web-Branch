
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

function openUpload(r,sd)
{
    var url = 'upload.aspx?r=' + r + '&sd=' + sd;
    var win = window.open(url, 'upload', 'scrollbars=0,location=0,menubar=0,titlebar=0,toolbar=0,width=700,HEIGHT=325');
    win.focus();
    return false;
}

function openUploadItemMaintFile(itemtype, itemid, filetype, updateimage)
{
    if(updateimage == null) updateimage = '';
    var url = 'uploaditemmaintfile.aspx?itemtype=' + itemtype + '&itemid=' + itemid + '&filetype=' + filetype + '&updateimage=' + updateimage;
    var win = window.open(url, 'uploaditemmaintfile', 'status=0,scrollbars=0,location=0,menubar=0,titlebar=0,toolbar=0,width=580,HEIGHT=310');
    win.focus();
    return false;
}

function openUploadItemFile(itemtype, itemid, filetype, updateimage)
{
    if(updateimage == null) updateimage = '';
    var url = 'uploaditemfile.aspx?itemtype=' + itemtype + '&itemid=' + itemid + '&filetype=' + filetype + '&updateimage=' + updateimage;
    var win = window.open(url, 'uploaditemfile', 'status=0,scrollbars=0,location=0,menubar=0,titlebar=0,toolbar=0,width=580,HEIGHT=310');
    win.focus();
    return false;
}

function highlightControls()
{
    var i, a = highlightControls.arguments, e;
    for(i=0;i<a.length;i++){if(a[i] != null) {e = new Effect.Highlight(a[i], {startcolor:'#eee8aa', endcolor:'#ffff33', restorecolor:'#eee8aa', duration: 1.5}); e = null;} else alert('Highlight Error!');}    
    //for(i=0;i<a.length;i++){if(a[i] != null) {e = new Effect.Highlight(a[i], {endcolor:'#ffff33', restorecolor:''}); e = null;} else alert('Highlight Error!');}    
}
function highlightControlsNoBG()
{
    var i, a = highlightControlsNoBG.arguments, e;
    for(i=0;i<a.length;i++){if(a[i] != null) {e = new Effect.Highlight(a[i], {startcolor:'#ffffff', endcolor:'#ffff33', restorecolor:'#ffffff', duration: 1.5}); e = null;} else alert('Highlight Error!');}    
    //for(i=0;i<a.length;i++){if(a[i] != null) {e = new Effect.Highlight(a[i], {endcolor:'#ffff33', restorecolor:''}); e = null;} else alert('Highlight Error!');}    
}
function highlightControls2()
{
    var i, a = highlightControls2.arguments, e;
    //for(i=0;i<a.length;i++){if(a[i] != null) {e = new Effect.Highlight(a[i], {startcolor:'#eee8aa', endcolor:'#ffff33', restorecolor:'#eee8aa'}); e = null;} else alert('Highlight Error!');}    
    for(i=0;i<a.length;i++){if(a[i] != null) {e = new Effect.Highlight(a[i], {endcolor:'#ffff33', duration: 1.5}); e = null;} else alert('Highlight Error!');}    
}
function highlightControl()
{
    var i, a = highlightControl.arguments, e;
    //for(i=0;i<a.length;i++){if(a[i] != null) {e = new Effect.Highlight(a[i], {startcolor:'#eee8aa', endcolor:'#ffff33', restorecolor:'#eee8aa'}); e = null;} else alert('Highlight Error!');}    
    if(a.length > 0){if(a[0] != null) {e = new Effect.Highlight(a[0], {endcolor:((a[1] != null) ? a[1] : '#ffff33'), duration: 1.5}); e = null;} else alert('Highlight Error!');}    
}
function setControlValue(controlID, value, noHighlight, noBG)
{
    if(noHighlight == null || !noHighlight) noHighlight = false;
    if(noBG == null || !noBG) noBG = false;
    if($(controlID))
	{
        $(controlID).value = value;
        if($(controlID+'Edit'))
        {
            $(controlID+'Edit').value = value;
            if(!noHighlight) {if(!noBG) highlightControls(controlID+'Edit'); else highlightControlsNoBG(controlID+'Edit'); }
        } else {
            if(!noHighlight) {if(!noBG) highlightControls(controlID); else highlightControlsNoBG(controlID);}
        }
    }
    else
        alert('ERROR with control, ' + controlID + ' !!!!!');
}
function getXMLValue(xmlDoc, nodeName)
{
    if(xmlDoc.getElementsByTagName(nodeName) && xmlDoc.getElementsByTagName(nodeName)[0] && xmlDoc.getElementsByTagName(nodeName)[0].childNodes[0] != null)
        return xmlDoc.getElementsByTagName(nodeName)[0].childNodes[0].nodeValue;
    else
    {
        /*
        alert('nodeName: ' + nodeName);
        alert(xmlDoc.getElementsByTagName(nodeName));
        alert(xmlDoc.getElementsByTagName(nodeName)[0]);
        alert(xmlDoc.getElementsByTagName(nodeName)[0].childNodes);
        alert(xmlDoc.getElementsByTagName(nodeName)[0].childNodes[0]);
        alert('Results nodeName, ' + nodeName + ', not found !!!!!!!!!!!!!!!!!!!!!!'); 
        */
        return '';
    }
}

function isNum(stringValue){
    var val;
    val = parseFloat(stringValue);
    if (isNaN(val)) 
        return false;
    else 
        return true;
}

function convertToNumber(stringValue){
    if(!isNaN(parseFloat(stringValue)))
        return parseFloat(stringValue);
    else
        return 0;
}

function confirmAction(msg)
{
    return confirm(msg);
}

/**********************/
/*** MISC FUNCTIONS ***/
/**********************/

function goUrl(url)
{
    document.location = url;
}

function reloadPage(param)
{
    if(param == null)param = '';
	__doPostBack(param, '');
}

function URLEncodeStr(strToEncode) 
{ 
    var encodedStr = escape(strToEncode); 
    encodedStr = encodedStr.replace(/\+/g, "%2B").replace(/\//g, "%2F"); 
    return encodedStr; 
}

// Fire all the object's onXXX events for Changecontrol events
function fireAllEvents(id) {
    //debugger;
    var obj = $(id);
    if (obj) {
        var code = new String("");
        if (obj.type == "checkbox") {
            code = new String(obj.attributes.item("onclick").value);
        }
        else {
            code = new String(obj.attributes.item("onchange").value);
        }
        if (code.length > 0) {
            code = code.trim();
            eval(code);
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



// Necessary String functions
String.prototype.ltrim = function() {
    return this.replace(/^\s+/g, '');
}
String.prototype.rtrim = function() {
    return this.replace(/\s+$/g, '');
}
String.prototype.trim = function() {
    return this.replace(/^\s+|\s+$/g, '');
}

function buttonHiLight(on) {
    var btn = this.event.srcElement
    //var name = this.event.srcElement.id
    if (on && on == 1)
        btn.className = 'formButtonMO';
    else 
        btn.className = 'formButton';
}

function mAjaxBeginRequest(sender, args) {
    window.status = "Please wait...";
    document.body.style.cursor = "wait";
    // if a control is defined that caused a postback (not during initial load) or if this is called by a non .net ajax process
    // set it to disabled
    if ( (args) && (args._postBackElement) ) {
        var e = $(args._postBackElement.id);
        if (e) e.disabled = true;
    }
}

function mAjaxPageLoaded(sender, args) {
    window.status = "Done";
    document.body.style.cursor = "auto";
    // Turn control back on if one was passed in with the args parm
    if ( (sender) && (sender._postBackSettings) && (sender._postBackSettings.sourceElement) ) {
        var e = $(sender._postBackSettings.sourceElement.id);
        if (e) e.disabled = false;
    }
}

// Validation
function initValidationErrors(id)
{
    var valdisp = $(id);
    var i, err, l, c;
    if(valdisp) {
        var errs = valdisp.select('span.errLink');
        if(errs && errs.length > 0) {
            for(i = 0; i < errs.length; i++){
                err = errs[i];
                c = err.readAttribute("control");
                if(c != '' && controlExists(c)) {
                    l = err.innerHTML;
                    l = '<a onclick="goToError(\'' + c + '\'); return false;" href="#">' + l + '</a>';
                    err.innerHTML = l;
                }
            }
        }
    }
}

function goToError(id)
{
    var c = getControlByID(id);
    if(c){
        if(id.toUpperCase() == 'MSDSID') {
            if($('B_UpdateMSDS')) $('B_UpdateMSDS').focus();
        } else if(id.toUpperCase() == 'IMAGEID') {
            if($('B_UpdateImage')) $('B_UpdateImage').focus();
        } else {
            c.focus();
            c.select();
            highlightControl(c, '#3399ff');
        }
    }
}

function getControlByID(id)
{
    var c = $(id + 'Edit');
    if(!c) c = $(id.substr(0,1).toLowerCase() + id.substr(1) + 'Edit');
    if(!c) c = $(id);
    if(!c) c = $(id.substr(0,1).toLowerCase() + id.substr(1))
    if(!c) c = $(id + 'Edit' + '1');
    if(!c) c = $(id.substr(0,1).toLowerCase() + id.substr(1) + 'Edit' + '1');
    if(!c) c = $(id + '1');
    if(!c) c = $(id.substr(0,1).toLowerCase() + id.substr(1) + '1');    
    return c;
}

function controlExists(id)
{
    var c = getControlByID(id);
    if(c) {
        if(c.readAttribute('type') != 'hidden' || ((id.toUpperCase() == 'MSDSID' && $('B_UpdateMSDS')) || (id.toUpperCase() == 'IMAGEID' && $('B_UpdateImage')))) {
            if(!isHiddenElement(c))
                return true;
            else
                return false;
        } else {
            return false;
        }
    } else {
        return false;
    }
}

function isHiddenElement(elem)
{
    elem = $(elem);
    //if( (elem.viewportOffset() && (elem.viewportOffset().left <= 0 || elem.viewportOffset().top <= 0)) || !elem.visible() || elem.getStyle("display") == 'none' || elem.getStyle("visibility") == 'hidden') {
    if( !elem.visible() || elem.getStyle("display") == 'none' || elem.getStyle("visibility") == 'hidden') {
        return true;
    } else {
        return false;
    }
}

function WriteTime(label, datestring)
{
    var d = new Date();
    var ds = (datestring != null) ? datestring : d.toUTCString();
    var tt = (datestring != null) ? '' : ' (JS)';
    document.writeln("<div> TIME" + tt + ": " + ds + " - " + label + " " + "</div>");
}

function ValidateUSDate( strValue ) 
{
	var objRegExp = /^\d{1,2}(\-|\/|\.)\d{1,2}\1\d{4}$/
	if(!objRegExp.test(strValue))
	{
		return false;
	}
	else
	{
		var strSeparator;
		var arrayLookup;
		if (isNaN(strValue.substring(1,2)))
		{
			strSeparator = strValue.substring(1,2);
		var arrayLookup = { '1' : 31,'3' : 31, 
							'4' : 30,'5' : 31,
							'6' : 30,'7' : 31,
							'8' : 31,'9' : 30,
							'10' : 31,'11' : 30,
							'12' : 31};
		}
		else
		{
			strSeparator = strValue.substring(2,3);
			arrayLookup = { '01' : 31,'03' : 31, 
							'04' : 30,'05' : 31,
							'06' : 30,'07' : 31,
							'08' : 31,'09' : 30,
							'10' : 31,'11' : 30,
							'12' : 31};
		}
		var arrayDate = strValue.split(strSeparator); 

		var intDay = parseInt(arrayDate[1],10); 

		if(arrayLookup[arrayDate[0]] != null) 
		{
			if(intDay <= arrayLookup[arrayDate[0]] && intDay != 0)
			{
				return true; 
			}
		}
		var intMonth = parseInt(arrayDate[0],10);
		if (intMonth == 2) 
		{ 
			var intYear = parseInt(arrayDate[2]);
			if (intDay > 0 && intDay < 29) 
			{
				return true;
			}
			else if (intDay == 29) 
			{
				if ((intYear % 4 == 0) && (intYear % 100 != 0) || (intYear % 400 == 0)) 
				{
					return true;
				}   
			}
		}
	}  
	return false; 
}

function OpenNewPopupWindow(pURL, pWindowName, pWidth, pHeight)
{
    var left = (screen.width) ? (screen.width - pWidth)/2 : 0;
    var top = (screen.height) ? (screen.height - pHeight)/2 : 0;

    mywindow = window.open(pURL, pWindowName, 'scrollbars=1,location=0,menubar=0,titlebar=0,toolbar=0,width=' + pWidth + ',height=' + pHeight + ',resizable=1, top=' + top + ', left=' + left);
}