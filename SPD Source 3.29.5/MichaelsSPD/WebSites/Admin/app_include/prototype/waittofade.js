//This script (C) Copyright 37Signals LLC, BaseCamp, and Jason Fried
//SOURCE: http://www.basecamphq.com
//"Borrowed" from my good friend Jason Fried and his colleagues at 37Signals (http://www.37signals.com), as implemented at BaseCamp (http://www.basecamphq.com)
//Adapted for use by Ken Wallace for Ken Wallace Design, Redmill Software, 11/16/03.  Re-purposed by Ken Wallace for Nova Libra, Inc. 12/2/04

function waittofade(whatElem, howIntense, initDelay, transDelay) 
{
	if (document.getElementById(whatElem)) 
	{
		setTimeout("fadeIn('" + whatElem + "', '" + howIntense + "', " + transDelay + ")", initDelay);
	}
}

function fadeIn(whatElem, howIntense, transDelay) 
{
	var Color= new Array();
	Color[1] = "ff";
	Color[2] = "ee";
	Color[3] = "dd";
	Color[4] = "cc";
	Color[5] = "bb";
	Color[6] = "aa";
	Color[7] = "99";
	Color[8] = "88";
	Color[9] = "77";
	Color[10] = "66";
	Color[11] = "55";
	Color[12] = "44";
	Color[13] = "33";
	Color[14] = "22";
	Color[15] = "11";
	Color[16] = "00";

	if (howIntense >= 1) 
	{
		document.getElementById(whatElem).style.backgroundColor = "#ffff" + Color[howIntense];
		if (howIntense > 1) 
		{
			howIntense -= 1;
			setTimeout("fadeIn('" + whatElem + "', '" + howIntense + "', " + transDelay + ")", transDelay);
		} else {
			howIntense -= 1;
			setTimeout("fadeIn('" + whatElem + "', '" + howIntense + "', " + transDelay + ")", transDelay);
			document.getElementById(whatElem).style.backgroundColor = "transparent";
		}
	}
}
