var objPreviousLink = null;
					
//The following lines preload the menu images		
var imgPixel = new Image(31,16);
var imgLine = new Image(31,16);
//var imgDocJoin = new Image(31,16);
//var imgDoc = new Image(31,16);
var imgPlusOnly = new Image(31,16);
var imgMinusOnly = new Image(31,16);
var imgFolderOpen = new Image(31,16);
var imgFldrClosed = new Image(31,16);
var imgFldrClosedJoinempty = new Image(31,16);
var imgFldrClosedempty = new Image(31,16);
var imgDocPlusOnly = new Image(16,16);
var imgDocMinusOnly = new Image(16,16);
var imgDocFolderOpen = new Image(16,16);
var imgDocFldrClosed = new Image(16,16);
var imgDocFldrClosedJoinempty = new Image(16,16);
var imgDocFldrClosedempty = new Image(16,16);

imgPixel.src = iconImgPath + "pixel.gif";
imgLine.src = iconImgPath + "line.gif";
//imgDocJoin.src = iconImgPath + "docjoin.gif";
//imgDoc.src = iconImgPath + "doc.gif";
imgPlusOnly.src = iconImgPath + "plusonly.gif";
imgMinusOnly.src = iconImgPath + "minusonly.gif";
imgFolderOpen.src = iconImgPath + "folderopen.gif";
imgFldrClosed.src = iconImgPath + "folderclosed.gif";
imgFldrClosedJoinempty.src = iconImgPath + "folderclosedjoinempty.gif";
imgFldrClosedempty.src = iconImgPath + "folderclosedempty.gif";  
imgDocPlusOnly.src = iconImgPath + "plusonly.gif";
imgDocMinusOnly.src = iconImgPath + "minusonly.gif";
imgDocFolderOpen.src = iconImgPath + "doc_folderopen.gif";
imgDocFldrClosed.src = iconImgPath + "doc_folderclosed.gif";
imgDocFldrClosedJoinempty.src = iconImgPath + "doc_folderclosedjoinempty.gif";
imgDocFldrClosedempty.src = iconImgPath + "doc_folderclosedempty.gif";  
		
//This function queries the arClickedElementID[] and arAffectedMenuItemID[] arrays
//to get an object reference to the appropriate menu element to show or hide.
function fnLookupElementRef(sID, arClickedElementID, arAffectedMenuItemID)
{
//	var i;
//	for (i=0;i<arClickedElementID.length;i++)
//		if (arClickedElementID[i] == sID)
//			return document.getElementById(arAffectedMenuItemID[i]);		
//	return null;

	var i;
	for (i=0;i<arAffectedMenuItemID.length;i++)
		if (arAffectedMenuItemID[i] == sID)
			return document.getElementById(arAffectedMenuItemID[i+1]);		
	return null;

}
		
//This function is responsible for showing/hiding the menu items.  It
//also switches the images accordingly
function doChangeTree(e, arClickedElementID, arAffectedMenuItemID, strElementType)
{
	var targetID, srcElement, targetElement;
	srcElement = e;
	
	if (srcElement != null)			
		//Only work with elements that have LEVEL in the classname
		if(srcElement.className.substr(0,5) == "LEVEL") 
		{
			//Using the ID of the item that was clicked, we look up
			//and retrieve an object reference to the menu item that
			//should be shown or hidden
			targetElement = fnLookupElementRef(srcElement.id, arClickedElementID, arAffectedMenuItemID)		

			if (targetElement != null)
			{
				if (strElementType == "folder")
				{
					//Swap Folder Images
					fnChangeFolderStatus(srcElement, targetElement);
				}
				else
				{
					//Swap Document Images
					fnChangeDocumentStatus(srcElement, targetElement);
				}

				//If we have a value in the MODE field, it means we are clicking
				//on a site.  We should submit the menu so we can retrieve the
				//data for that site and rebuild the tree 
				if (srcElement.name == 'LoadOnDemand')
				{
					//We submit the menu only if the tree is being expanded.  
					if (targetElement.style.display == "none")
						document.frmMenu.submit();
				}
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

//Opens a closed folder and closes an open folder.  This function
//is responsible for all aspects of changing the folder status.
//Attributes are as follows:
//-------------------------------
//srcElement : Object reference to the folder that should be expanded/contracted
//targetElement : Object reference to the subfolder that should be displayed/hidden
function fnChangeFolderStatus(srcElement, targetElement)
{
	if (srcElement != null) 
	{
		//First find out if the current folder is empty
		//We find out based on the name of the image used
		if (srcElement.tagName == 'IMG')
		{
			var sImageSource = srcElement.src;
			if (sImageSource.indexOf("empty") == -1)
			{
				if (targetElement.style.display == "none")
				{
					//Our menu item is currently hidden, so display it
				//	targetElement.style.display = "";
										
					if (srcElement.className == "LEVEL1")
						//Set a special open-folder graphic for the root folder
						srcElement.src = imgMinusOnly.src;
					else
						//Otherwise, just show the standard icon
						srcElement.src = imgFolderOpen.src;
							
				//	dataLyr.style.display = "none";
				//	waitLyr.style.display = "";
					fnAddItem(document.frmMenu.hdnOpenFolders, srcElement.id);
					var parentDBIDSrc = eval("document.frmMenu.db_id_" + srcElement.id);
					if (parentDBIDSrc)
					{
						fnAddItem(document.frmMenu.open, parentDBIDSrc.value);
					}
				}
				else
				{
					//Our menu item is currently visible, so hide it
					targetElement.style.display = "none";
										
					if (srcElement.className == "LEVEL1")
						//Set a special closed-folder graphic for the root folder
						srcElement.src = imgPlusOnly.src;
					else
						//Otherwise, just show the standard icon
						srcElement.src = imgFldrClosed.src;
							
					fnRemoveItem(document.frmMenu.hdnOpenFolders, srcElement.id);
					var parentDBIDSrc = eval("document.frmMenu.db_id_" + srcElement.id);
					if (parentDBIDSrc)
					{
						fnRemoveItem(document.frmMenu.open, parentDBIDSrc.value);
					}
				}
			}
		} 
	}
}

function fnChangeDocumentStatus(srcElement, targetElement)
{
	if (srcElement != null) 
	{
		//First find out if the current folder is empty
		//We find out based on the name of the image used
		if (srcElement.tagName == 'IMG')
		{
			var sImageSource = srcElement.src;
			if (sImageSource.indexOf("empty") == -1)
			{
				if (targetElement.style.display == "none")
				{
					//Our menu item is currently hidden, so display it
				//	targetElement.style.display = "";
										
					if (srcElement.className == "LEVEL1")
						//Set a special open-folder graphic for the root folder
						srcElement.src = imgDocMinusOnly.src;
					else
						//Otherwise, just show the standard icon
						srcElement.src = imgDocFolderOpen.src;
							
				//	dataLyr.style.display = "none";
				//	waitLyr.style.display = "";
					fnAddItem(document.frmMenu.hdnOpenFolders, srcElement.id);
					var parentDBIDSrc = eval("document.frmMenu.db_id_" + srcElement.id);
					if (parentDBIDSrc)
					{
						fnAddItem(document.frmMenu.open, parentDBIDSrc.value);
					}

				}
				else
				{
					//Our menu item is currently visible, so hide it
					targetElement.style.display = "none";
										
					if (srcElement.className == "LEVEL1")
						//Set a special closed-folder graphic for the root folder
						srcElement.src = imgDocPlusOnly.src;
					else
						//Otherwise, just show the standard icon
						srcElement.src = imgDocFldrClosed.src;
							
					fnRemoveItem(document.frmMenu.hdnOpenFolders, srcElement.id);
					var parentDBIDSrc = eval("document.frmMenu.db_id_" + srcElement.id);
					if (parentDBIDSrc)
					{
						fnRemoveItem(document.frmMenu.open, parentDBIDSrc.value);
					}
				}
			}
		} 
	}
}


//This function highlights the text of a menu item.
//It also deselects the previously
//selected menu item.  It takes three parameters: 1) an
//object reference to the selected link, and 2) an 
//object reference to the previously selected link.  The
//function returns a reference to the currently selected link.
function fnSelectItem(objSelectedLink, objPreviousLink)
{	
	var bFound = false;
				
	//If we have previously selected a menu item, deselect it
	if (objPreviousLink != null)
		fnDeselectItem(objPreviousLink);
					
	//Find an object reference for our TD tag
	var objTD = objSelectedLink;
	while (objTD.tagName!="TD")
	{
		objTD=objTD.parentElement;
						
		if (objTD.tagName == "TD")
			bFound = true;
	}
					
	//Got the TD tag reference, so now highlight the cell	
	if (bFound == true)
	{
	//	objTD.className = "selected";
	}
					
	//Return reference to our selected item
	return objSelectedLink;
}
		
//This function removes the highlight from a
//previously selected menu item.  It takes an
//object reference to the item that needs deselecting.
function fnDeselectItem(objPreviousLink)
{
	if (objPreviousLink !=  null)
	{
		//Find an object reference for our TD tag
		var objTD = objPreviousLink;
		while (objTD.tagName!="TD")
			objTD=objTD.parentElement;
					
		//Change the style class for the TD tag 
		//back to normal
	//	objTD.className = "node";
	}
}