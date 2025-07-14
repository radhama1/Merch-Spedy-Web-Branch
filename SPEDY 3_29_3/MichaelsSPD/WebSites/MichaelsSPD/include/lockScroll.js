if (( parseInt(navigator.appVersion) >= 4) && (navigator.appName.indexOf("Netscape") != -1)) 
{
var NS4 = true;
} else {
var NS4 = false;
}

if (( parseInt(navigator.appVersion) >= 4) && (navigator.appName.indexOf("Microsoft") != -1 )) 
{
var IE4 = true;
} else {
var IE4 = false;
}

function doLoad() 
{
	if (IE4) onscroll = keepTogether;
//	if (NS4) setInterval("scrollLayer()",1);
}
var headFrame = parent.frames["DetailFrameHdr"];
var fixedFrame = parent.frames["FixedDetailFrame"];

function scrollLayer()
{
	headFrame.document.layers['defaultLyr'].left = -pageXOffset;
}

function keepTogether() 
{
	if(headFrame)  headFrame.document.body.scrollLeft = document.body.scrollLeft;
	if(fixedFrame) fixedFrame.document.body.scrollTop = document.body.scrollTop;
}

doLoad();
window.onResize = doLoad();
