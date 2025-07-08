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

var headFrame_colReference = "divGridHeader";
var dataFrame_colReference = "divGrid";
var fixedDataFrame_colReference = "divFixedGrid";

var oHeaderHandle, oBodyHandle, oFixedBodyHandle;

function doLoad() 
{
	oHeaderHandle = document.all ? document.all[headFrame_colReference] : document.getElementById(headFrame_colReference);
	oBodyHandle = document.all ? document.all[dataFrame_colReference] : document.getElementById(dataFrame_colReference);
	oFixedBodyHandle = document.all ? document.all[fixedDataFrame_colReference] : document.getElementById(fixedDataFrame_colReference);

	oBodyHandle.onscroll = keepTogether;
}
doLoad();
function scrollLayer()
{
	oHeaderHandle.left = -pageXOffset;
}

function keepTogether() 
{
	oHeaderHandle.scrollLeft = oBodyHandle.scrollLeft;
	if(oFixedBodyHandle) {
		oFixedBodyHandle.scrollTop = oBodyHandle.scrollTop;
	}
}
