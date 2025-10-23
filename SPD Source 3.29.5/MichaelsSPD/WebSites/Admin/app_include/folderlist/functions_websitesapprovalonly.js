//This function is responsible for showing/hiding the menu items
function doChangeTree2(e, boolOpen)
{
	var srcElement = e;
	if (srcElement != null)
	{
		//Only work with elements that have LEVEL in the classname
		if(srcElement.className.substr(0,5) == "LEVEL") 
		{
			//	alert(srcElement.id);
				if (boolOpen != "True")
				{
					fnAddItem(document.frmMenu.open, srcElement.id);
				}
				else
				{
					fnRemoveItem(document.frmMenu.open, srcElement.id);
				}
				document.frmMenu.submit();
		}
	}
}

//Adds the current element ID to a string stored in hidden HTML field.
//Only adds the ID if it is not already in there
function fnAddItem(objField, sElementID)
{
	var sCurrValue = objField.value;

	if (sCurrValue.indexOf(sElementID) == -1)
		objField.value = objField.value + ',' + sElementID;
}

//Removes a specific element ID from a string stored in hidden HTML field.
function fnRemoveItem(objField, sElementID)
{
	var sCurrValue = objField.value;
	var arValues = sCurrValue.split(',');
	var arNewValues = new Array(0);
	var x=0;
	
	for (i=0;i<arValues.length;i++)
		if (arValues[i] != sElementID)
		{
			arNewValues[x] = arValues[i];
			x++;
		}	
	
	sCurrValue = arNewValues.join(',');
	objField.value = sCurrValue;
}
