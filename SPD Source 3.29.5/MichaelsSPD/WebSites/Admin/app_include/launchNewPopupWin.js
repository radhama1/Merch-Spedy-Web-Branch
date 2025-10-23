function launchNewPopupWin(myLoc, myName, myWidth, myHeight, myFeatures)
{
	var myFeatures = "directories=0,dependent=1,width=" + myWidth + ",height=" + myHeight + ",hotkeys=0,screenX=100,screenY=100,toolbar=0," + myFeatures;
	var newWin = window.open(myLoc, myName, myFeatures);
}
